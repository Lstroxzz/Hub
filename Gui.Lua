--[[
    Auto Hub (LuaU) - single file version
    Host this file and execute with:
    loadstring(game:HttpGet("URL"))()
]]

if getgenv().AutoHubLoaded then
    warn("[AutoHub] Script already loaded.")
    return
end
getgenv().AutoHubLoaded = true

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local HUB_NAME = "AutoHubV1"
local SAVE_FILE = "autohub_config.json"

local Config = {
    Theme = {
        Background = Color3.fromRGB(8, 10, 22),
        Card = Color3.fromRGB(14, 16, 35),
        CardBorder = Color3.fromRGB(35, 40, 75),
        Accent = Color3.fromRGB(64, 111, 255),
        AccentOff = Color3.fromRGB(62, 66, 93),
        TextMain = Color3.fromRGB(240, 243, 255),
        TextMuted = Color3.fromRGB(162, 170, 210),
        Success = Color3.fromRGB(86, 219, 135),
    },
    AutoSaveInterval = 20,
    WebhookUrl = "",
    TeleportPoints = {
        CFrame.new(0, 10, 0),
        CFrame.new(40, 10, 0),
        CFrame.new(-40, 10, 0),
    },
    InteractDistance = 20,
    NotificationCooldown = 2,
}

local FeatureDefs = {
    { id = "AutoFarm", title = "Fazenda automatica", desc = "Executa farming continuo com coleta e prompts.", interval = 0.4 },
    { id = "AutoMission", title = "Missao automatica", desc = "Busca e ativa alvos de missao automaticamente.", interval = 1.2 },
    { id = "AutoBoss", title = "Chefe automatico", desc = "Detecta chefes proximos e engaja rotinas de combate.", interval = 1.0 },
    { id = "AutoAttack", title = "Ataque automatico", desc = "Ativa arma/ferramenta continuamente em combate.", interval = 0.15 },
    { id = "AutoSeaEvent", title = "Evento Auto Sea", desc = "Monitora eventos marinhos e responde quando surgem.", interval = 2.0 },
    { id = "AutoCollect", title = "Coleta automatica", desc = "Coleta drops, itens e recompensas ao redor.", interval = 0.4 },
    { id = "TeleportSystem", title = "Sistema de Teletransporte", desc = "Alterna entre rotas definidas no Config.TeleportPoints.", interval = 3.0 },
    { id = "StatusUI", title = "Interface de status", desc = "Atualiza painel de status em tempo real.", interval = 0.5, default = true },
    { id = "WebhookNotify", title = "Notificacao Webhook", desc = "Envia logs para webhook quando houver eventos.", interval = 3.0 },
    { id = "MultiAccount", title = "Conta multipla", desc = "Gerencia perfis de configuracao em rotacao.", interval = 6.0 },
    { id = "ConfigSystem", title = "Configurar sistema", desc = "Auto save/load de configuracoes do hub.", interval = 5.0, default = true },
    { id = "PerfOptimize", title = "Otimizacao de desempenho", desc = "Aplica configuracoes visuais de baixa carga.", interval = 8.0 },
}

local State = {
    running = true,
    startedAt = os.clock(),
    toggles = {},
    loops = {},
    cards = {},
    labels = {},
    stats = { actions = 0, errors = 0, lastAction = "idle" },
    eventQueue = {},
    lastNotification = 0,
    teleportIndex = 1,
    profileIndex = 1,
    ui = {},
}

for _, feature in ipairs(FeatureDefs) do
    State.toggles[feature.id] = feature.default == true
end

local function now()
    return os.clock()
end

local function pushEvent(message)
    table.insert(State.eventQueue, { at = os.time(), player = LocalPlayer.Name, message = message })
    State.stats.lastAction = message
end

local function setLabel(name, text)
    local label = State.labels[name]
    if label then
        label.Text = text
    end
end

local function notify(title, text)
    if now() - State.lastNotification < Config.NotificationCooldown then
        return
    end
    State.lastNotification = now()
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 3 })
    end)
end

local function getCharacter()
    return LocalPlayer.Character
end

local function getRootPart()
    local character = getCharacter()
    if not character then
        return nil
    end
    return character:FindFirstChild("HumanoidRootPart")
end

local function distanceTo(position)
    local root = getRootPart()
    if not root then
        return math.huge
    end
    return (root.Position - position).Magnitude
end

local function safeActivatePrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then
        return false
    end
    local parentPart = prompt.Parent
    if not parentPart or not parentPart:IsA("BasePart") then
        return false
    end
    if distanceTo(parentPart.Position) > (prompt.MaxActivationDistance + 5) then
        return false
    end
    pcall(function()
        fireproximityprompt(prompt)
    end)
    return true
end

local function touchPart(part)
    local root = getRootPart()
    if not root or not part or not part:IsA("BasePart") then
        return false
    end
    pcall(function()
        firetouchinterest(root, part, 0)
        firetouchinterest(root, part, 1)
    end)
    return true
end

local function runHttpPost(url, bodyTable)
    local payload = HttpService:JSONEncode(bodyTable)
    local requestFn = request or http_request or (syn and syn.request)

    if requestFn then
        local ok = pcall(function()
            requestFn({
                Url = url,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = payload,
            })
        end)
        return ok
    end

    local ok = pcall(function()
        HttpService:PostAsync(url, payload, Enum.HttpContentType.ApplicationJson)
    end)
    return ok
end

local function serializeConfig()
    local serializable = {
        AutoSaveInterval = Config.AutoSaveInterval,
        WebhookUrl = Config.WebhookUrl,
        InteractDistance = Config.InteractDistance,
        NotificationCooldown = Config.NotificationCooldown,
        TeleportPoints = {},
        Toggles = State.toggles,
    }

    for _, cf in ipairs(Config.TeleportPoints) do
        local p = cf.Position
        table.insert(serializable.TeleportPoints, { p.X, p.Y, p.Z })
    end
    return serializable
end

local function loadConfigFromDisk()
    if not readfile or not isfile then
        return
    end
    if not isfile(SAVE_FILE) then
        return
    end

    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(SAVE_FILE))
    end)
    if not ok or type(data) ~= "table" then
        return
    end

    Config.AutoSaveInterval = tonumber(data.AutoSaveInterval) or Config.AutoSaveInterval
    Config.WebhookUrl = tostring(data.WebhookUrl or Config.WebhookUrl)
    Config.InteractDistance = tonumber(data.InteractDistance) or Config.InteractDistance
    Config.NotificationCooldown = tonumber(data.NotificationCooldown) or Config.NotificationCooldown

    if type(data.TeleportPoints) == "table" and #data.TeleportPoints > 0 then
        Config.TeleportPoints = {}
        for _, v in ipairs(data.TeleportPoints) do
            if type(v) == "table" and #v >= 3 then
                table.insert(Config.TeleportPoints, CFrame.new(tonumber(v[1]) or 0, tonumber(v[2]) or 10, tonumber(v[3]) or 0))
            end
        end
    end

    if type(data.Toggles) == "table" then
        for featureId, enabled in pairs(data.Toggles) do
            if State.toggles[featureId] ~= nil then
                State.toggles[featureId] = enabled == true
            end
        end
    end
end

local function saveConfigToDisk()
    if not writefile then
        return
    end
    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(serializeConfig())
    end)
    if ok then
        pcall(function()
            writefile(SAVE_FILE, encoded)
        end)
    end
end

local function setPerformanceMode()
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 1
    end)
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("PostEffect") then
                obj.Enabled = false
            end
        end
    end)
    pcall(function()
        if setfpscap then
            setfpscap(120)
        end
    end)
end

local function runAutoFarm()
    local count = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local name = string.lower(obj.Name)
            if string.find(name, "farm") or string.find(name, "collect") or string.find(name, "harvest") then
                if safeActivatePrompt(obj) then
                    count = count + 1
                end
            end
        end
    end
    if count > 0 then
        State.stats.actions = State.stats.actions + count
        pushEvent("AutoFarm x" .. tostring(count))
    end
end

local function runAutoMission()
    local count = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local n = string.lower(obj.Name)
            if string.find(n, "quest") or string.find(n, "mission") then
                if safeActivatePrompt(obj) then
                    count = count + 1
                end
            end
        end
    end
    if count > 0 then
        State.stats.actions = State.stats.actions + count
        pushEvent("Mission trigger x" .. tostring(count))
    end
end

local function runAutoBoss()
    local root = getRootPart()
    if not root then
        return
    end

    local closestBoss, closestDist = nil, math.huge
    for _, model in ipairs(Workspace:GetDescendants()) do
        if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") and model:FindFirstChild("HumanoidRootPart") then
            local n = string.lower(model.Name)
            if string.find(n, "boss") or string.find(n, "chefe") then
                local dist = (root.Position - model.HumanoidRootPart.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestBoss = model
                end
            end
        end
    end

    if closestBoss and closestDist < 150 then
        pcall(function()
            root.CFrame = closestBoss.HumanoidRootPart.CFrame * CFrame.new(0, 0, 6)
        end)
        State.stats.actions = State.stats.actions + 1
        pushEvent("Boss tracked: " .. closestBoss.Name)
    end
end

local function runAutoAttack()
    local character = getCharacter()
    if not character then
        return
    end

    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then
        local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
        if backpack then
            local backupTool = backpack:FindFirstChildOfClass("Tool")
            if backupTool then
                pcall(function()
                    backupTool.Parent = character
                end)
                tool = backupTool
            end
        end
    end

    if tool then
        pcall(function()
            tool:Activate()
        end)
        State.stats.actions = State.stats.actions + 1
        State.stats.lastAction = "Attacking"
    end
end

local function runAutoSeaEvent()
    local root = getRootPart()
    if not root then
        return
    end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        local n = string.lower(obj.Name)
        if string.find(n, "sea") or string.find(n, "marine") or string.find(n, "naval") then
            if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
                pcall(function()
                    root.CFrame = obj.HumanoidRootPart.CFrame * CFrame.new(0, 0, 10)
                end)
                State.stats.actions = State.stats.actions + 1
                pushEvent("Sea event: " .. obj.Name)
                break
            elseif obj:IsA("BasePart") then
                pcall(function()
                    root.CFrame = obj.CFrame + Vector3.new(0, 5, 0)
                end)
                State.stats.actions = State.stats.actions + 1
                pushEvent("Sea marker: " .. obj.Name)
                break
            end
        end
    end
end

local function runAutoCollect()
    local count = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = string.lower(obj.Name)
            local isLoot = string.find(n, "loot") or string.find(n, "drop") or string.find(n, "coin") or string.find(n, "chest")
            if isLoot and distanceTo(obj.Position) <= Config.InteractDistance then
                if touchPart(obj) then
                    count = count + 1
                end
            end
        elseif obj:IsA("ProximityPrompt") then
            local np = string.lower(obj.Name)
            if string.find(np, "claim") or string.find(np, "collect") then
                if safeActivatePrompt(obj) then
                    count = count + 1
                end
            end
        end
    end
    if count > 0 then
        State.stats.actions = State.stats.actions + count
        pushEvent("AutoCollect x" .. tostring(count))
    end
end

local function runTeleportSystem()
    local root = getRootPart()
    if not root or #Config.TeleportPoints == 0 then
        return
    end
    State.teleportIndex = (State.teleportIndex % #Config.TeleportPoints) + 1
    local nextPoint = Config.TeleportPoints[State.teleportIndex]
    pcall(function()
        root.CFrame = nextPoint
    end)
    State.stats.actions = State.stats.actions + 1
    pushEvent("Teleport point #" .. tostring(State.teleportIndex))
end

local function runWebhookNotify()
    if Config.WebhookUrl == "" or #State.eventQueue == 0 then
        return
    end

    local payload = {
        username = "AutoHub",
        content = "Player: " .. LocalPlayer.Name,
        embeds = {
            {
                title = "Automation Events",
                description = "Recent activity from AutoHub",
                color = 3447003,
                fields = {},
            },
        },
    }

    local fields = payload.embeds[1].fields
    local maxRows = math.min(5, #State.eventQueue)
    for _ = 1, maxRows do
        local event = table.remove(State.eventQueue, 1)
        table.insert(fields, {
            name = os.date("%X", event.at),
            value = event.message,
            inline = false,
        })
    end

    local ok = runHttpPost(Config.WebhookUrl, payload)
    if ok then
        State.stats.lastAction = "Webhook sent"
    else
        State.stats.errors = State.stats.errors + 1
    end
end

local function runMultiAccount()
    local profiles = {
        { AutoFarm = true, AutoCollect = true, AutoAttack = false },
        { AutoFarm = false, AutoCollect = true, AutoAttack = true, AutoBoss = true },
        { AutoMission = true, AutoSeaEvent = true, TeleportSystem = true },
    }

    State.profileIndex = (State.profileIndex % #profiles) + 1
    local profile = profiles[State.profileIndex]
    for k, v in pairs(profile) do
        if State.toggles[k] ~= nil then
            State.toggles[k] = v
        end
    end
    pushEvent("Profile swap #" .. tostring(State.profileIndex))
end

local lastAutoSave = now()
local function runConfigSystem()
    if now() - lastAutoSave >= Config.AutoSaveInterval then
        lastAutoSave = now()
        saveConfigToDisk()
        State.stats.lastAction = "Config saved"
    end
end

local function runPerfOptimize()
    setPerformanceMode()
    State.stats.lastAction = "Performance tuned"
end

local FeatureRunners = {
    AutoFarm = runAutoFarm,
    AutoMission = runAutoMission,
    AutoBoss = runAutoBoss,
    AutoAttack = runAutoAttack,
    AutoSeaEvent = runAutoSeaEvent,
    AutoCollect = runAutoCollect,
    TeleportSystem = runTeleportSystem,
    WebhookNotify = runWebhookNotify,
    MultiAccount = runMultiAccount,
    ConfigSystem = runConfigSystem,
    PerfOptimize = runPerfOptimize,
}

local function styleCorner(target, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = target
end

local function makeDraggable(frame, handle)
    local dragging = false
    local startPos
    local startInputPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startPos = frame.Position
            startInputPos = input.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startInputPos
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function updateCardVisual(featureId)
    local cardData = State.cards[featureId]
    if not cardData then
        return
    end
    local enabled = State.toggles[featureId]
    local button = cardData.toggleButton
    button.Text = enabled and "ON" or "OFF"
    button.BackgroundColor3 = enabled and Config.Theme.Accent or Config.Theme.AccentOff
end

local function createUI()
    local oldGui = PlayerGui:FindFirstChild(HUB_NAME)
    if oldGui then
        oldGui:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = HUB_NAME
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = PlayerGui
    State.ui.gui = gui

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 980, 0, 620)
    main.Position = UDim2.new(0.5, -490, 0.5, -310)
    main.BackgroundColor3 = Config.Theme.Background
    main.BorderSizePixel = 0
    main.Parent = gui
    styleCorner(main, 12)
    State.ui.main = main

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(33, 38, 70)
    stroke.Thickness = 1
    stroke.Parent = main

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 58)
    header.BackgroundTransparency = 1
    header.Parent = main

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 20, 0, 12)
    title.Size = UDim2.new(0, 500, 0, 32)
    title.Font = Enum.Font.GothamBold
    title.Text = "AutoHub Control Center"
    title.TextColor3 = Config.Theme.TextMain
    title.TextSize = 22
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 42, 0, 32)
    close.Position = UDim2.new(1, -52, 0, 12)
    close.Text = "X"
    close.Font = Enum.Font.GothamBold
    close.TextSize = 16
    close.TextColor3 = Config.Theme.TextMain
    close.BackgroundColor3 = Color3.fromRGB(42, 28, 46)
    close.Parent = header
    styleCorner(close, 8)

    local minimize = Instance.new("TextButton")
    minimize.Size = UDim2.new(0, 42, 0, 32)
    minimize.Position = UDim2.new(1, -100, 0, 12)
    minimize.Text = "-"
    minimize.Font = Enum.Font.GothamBold
    minimize.TextSize = 20
    minimize.TextColor3 = Config.Theme.TextMain
    minimize.BackgroundColor3 = Color3.fromRGB(22, 29, 56)
    minimize.Parent = header
    styleCorner(minimize, 8)

    local statusBar = Instance.new("Frame")
    statusBar.Size = UDim2.new(1, -40, 0, 46)
    statusBar.Position = UDim2.new(0, 20, 0, 64)
    statusBar.BackgroundColor3 = Color3.fromRGB(12, 15, 30)
    statusBar.Parent = main
    styleCorner(statusBar, 8)
    State.ui.statusBar = statusBar

    local statusLayout = Instance.new("UIListLayout")
    statusLayout.FillDirection = Enum.FillDirection.Horizontal
    statusLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    statusLayout.Padding = UDim.new(0, 16)
    statusLayout.Parent = statusBar

    local statusPad = Instance.new("UIPadding")
    statusPad.PaddingLeft = UDim.new(0, 14)
    statusPad.PaddingTop = UDim.new(0, 12)
    statusPad.Parent = statusBar

    local function addStatus(key, labelText)
        local label = Instance.new("TextLabel")
        label.Name = key
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(0, 210, 0, 22)
        label.Font = Enum.Font.Gotham
        label.TextColor3 = Config.Theme.TextMuted
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = labelText
        label.Parent = statusBar
        State.labels[key] = label
    end

    addStatus("uptime", "Uptime: 0s")
    addStatus("active", "Active: 0")
    addStatus("actions", "Actions: 0")
    addStatus("errors", "Errors: 0")
    addStatus("last", "Last: idle")

    local scroll = Instance.new("ScrollingFrame")
    scroll.Position = UDim2.new(0, 20, 0, 124)
    scroll.Size = UDim2.new(1, -40, 1, -144)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 6
    scroll.Parent = main

    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(0, 228, 0, 154)
    grid.CellPadding = UDim2.new(0, 10, 0, 10)
    grid.HorizontalAlignment = Enum.HorizontalAlignment.Left
    grid.Parent = scroll

    grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, grid.AbsoluteContentSize.Y + 10)
    end)

    for _, feature in ipairs(FeatureDefs) do
        local card = Instance.new("Frame")
        card.BackgroundColor3 = Config.Theme.Card
        card.BorderSizePixel = 0
        card.Parent = scroll
        styleCorner(card, 10)

        local cStroke = Instance.new("UIStroke")
        cStroke.Thickness = 1
        cStroke.Color = Config.Theme.CardBorder
        cStroke.Parent = card

        local icon = Instance.new("Frame")
        icon.Size = UDim2.new(0, 34, 0, 34)
        icon.Position = UDim2.new(0, 14, 0, 12)
        icon.BackgroundColor3 = Color3.fromRGB(25, 30, 62)
        icon.Parent = card
        styleCorner(icon, 8)

        local iconDot = Instance.new("Frame")
        iconDot.Size = UDim2.new(0, 12, 0, 12)
        iconDot.Position = UDim2.new(0.5, -6, 0.5, -6)
        iconDot.BackgroundColor3 = Config.Theme.Accent
        iconDot.Parent = icon
        styleCorner(iconDot, 6)

        local nameLabel = Instance.new("TextLabel")
        nameLabel.BackgroundTransparency = 1
        nameLabel.Position = UDim2.new(0, 14, 0, 54)
        nameLabel.Size = UDim2.new(1, -28, 0, 25)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextColor3 = Config.Theme.TextMain
        nameLabel.TextSize = 18
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Text = feature.title
        nameLabel.Parent = card

        local desc = Instance.new("TextLabel")
        desc.BackgroundTransparency = 1
        desc.Position = UDim2.new(0, 14, 0, 82)
        desc.Size = UDim2.new(1, -28, 0, 42)
        desc.Font = Enum.Font.Gotham
        desc.TextColor3 = Config.Theme.TextMuted
        desc.TextSize = 12
        desc.TextWrapped = true
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.TextYAlignment = Enum.TextYAlignment.Top
        desc.Text = feature.desc
        desc.Parent = card

        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0, 62, 0, 24)
        toggle.Position = UDim2.new(1, -76, 1, -34)
        toggle.Font = Enum.Font.GothamBold
        toggle.TextSize = 12
        toggle.TextColor3 = Config.Theme.TextMain
        toggle.Parent = card
        styleCorner(toggle, 7)

        toggle.MouseButton1Click:Connect(function()
            State.toggles[feature.id] = not State.toggles[feature.id]
            updateCardVisual(feature.id)
            notify("AutoHub", feature.title .. " -> " .. (State.toggles[feature.id] and "ON" or "OFF"))
        end)

        State.cards[feature.id] = { frame = card, toggleButton = toggle, icon = iconDot }
        updateCardVisual(feature.id)
    end

    local minimized = false
    minimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            TweenService:Create(main, TweenInfo.new(0.2), { Size = UDim2.new(0, 360, 0, 58) }):Play()
            scroll.Visible = false
            statusBar.Visible = false
            title.Text = "AutoHub"
        else
            TweenService:Create(main, TweenInfo.new(0.2), { Size = UDim2.new(0, 980, 0, 620) }):Play()
            task.wait(0.2)
            scroll.Visible = true
            statusBar.Visible = true
            title.Text = "AutoHub Control Center"
        end
    end)

    close.MouseButton1Click:Connect(function()
        State.running = false
        gui:Destroy()
        getgenv().AutoHubLoaded = nil
    end)

    makeDraggable(main, header)
end

local function updateStatusLabels()
    local uptime = math.floor(now() - State.startedAt)
    local active = 0
    for _, enabled in pairs(State.toggles) do
        if enabled then
            active = active + 1
        end
    end

    setLabel("uptime", "Uptime: " .. tostring(uptime) .. "s")
    setLabel("active", "Active: " .. tostring(active))
    setLabel("actions", "Actions: " .. tostring(State.stats.actions))
    setLabel("errors", "Errors: " .. tostring(State.stats.errors))
    setLabel("last", "Last: " .. tostring(State.stats.lastAction))

    if State.ui.statusBar then
        State.ui.statusBar.Visible = State.toggles.StatusUI == true
    end

    for featureId, cardData in pairs(State.cards) do
        cardData.icon.BackgroundColor3 = State.toggles[featureId] and Config.Theme.Success or Config.Theme.AccentOff
        updateCardVisual(featureId)
    end
end

local function startFeatureLoop(feature)
    if State.loops[feature.id] then
        return
    end
    State.loops[feature.id] = task.spawn(function()
        while State.running do
            if State.toggles[feature.id] then
                local runner = FeatureRunners[feature.id]
                if runner then
                    local ok, err = pcall(runner)
                    if not ok then
                        State.stats.errors = State.stats.errors + 1
                        State.stats.lastAction = "Err(" .. feature.id .. ")"
                        warn("[AutoHub] " .. feature.id .. " error: " .. tostring(err))
                    end
                end
            end
            task.wait(feature.interval or 1)
        end
    end)
end

local function boot()
    loadConfigFromDisk()
    createUI()
    notify("AutoHub", "Loaded with " .. tostring(#FeatureDefs) .. " systems.")

    for _, feature in ipairs(FeatureDefs) do
        startFeatureLoop(feature)
    end

    task.spawn(function()
        while State.running do
            updateStatusLabels()
            task.wait(0.3)
        end
    end)

    RunService.Heartbeat:Connect(function()
        if not State.running then
            return
        end
        local character = getCharacter()
        if character and character:FindFirstChild("Humanoid") then
            if character.Humanoid.Health <= 0 then
                pushEvent("Player died")
            end
        end
    end)
end

boot()
