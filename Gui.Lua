--[[
    AutoHub Compact Sidebar UI
    loadstring(game:HttpGet("URL"))()
]]

-- Force cleanup of old UI versions before loading this one.
pcall(function()
    local pg = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    for _, child in ipairs(pg:GetChildren()) do
        if child:IsA("ScreenGui") then
            local n = string.lower(child.Name)
            if string.find(n, "autohub") then
                child:Destroy()
            end
        end
    end
end)

pcall(function()
    getgenv().AutoHubCompactLoaded = nil
    getgenv().AutoHubGridLoaded = nil
    getgenv().AutoHubBFLoaded = nil
    getgenv().AutoHubLoaded = nil
end)

if getgenv().AutoHubCompactLoaded then
    return
end
getgenv().AutoHubCompactLoaded = true

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local SCRIPT_VERSION = "V4-2026-04-26"
local GUI_NAME = "AutoHubCompact_" .. SCRIPT_VERSION
local SAVE_FILE = "autohub_compact_config.json"

local Theme = {
    bg = Color3.fromRGB(7, 10, 18),
    panel = Color3.fromRGB(10, 14, 24),
    panel2 = Color3.fromRGB(12, 17, 29),
    row = Color3.fromRGB(13, 18, 31),
    border = Color3.fromRGB(32, 43, 73),
    text = Color3.fromRGB(234, 241, 255),
    muted = Color3.fromRGB(148, 166, 214),
    accent = Color3.fromRGB(66, 126, 255),
    off = Color3.fromRGB(71, 78, 110),
    ok = Color3.fromRGB(84, 219, 136),
}

local Features = {
    { id = "AutoFarm", title = "Fazenda de automoveis", desc = "Cultive automaticamente com loop otimizado.", icon = "F", interval = 0.40 },
    { id = "AutoMission", title = "Missao Automatica", desc = "Recebe e completa missoes sem perder task.", icon = "M", interval = 1.20 },
    { id = "AutoBoss", title = "Chefe Automatico", desc = "Busca e trava em bosses proximos.", icon = "B", interval = 0.90 },
    { id = "AutoAttack", title = "Ataque Automatico", desc = "Ataca continuamente para manter DPS.", icon = "A", interval = 0.14 },
    { id = "AutoSeaEvent", title = "Evento Auto Sea", desc = "Monitora eventos de mar e avisa.", icon = "S", interval = 2.50 },
    { id = "AutoCollect", title = "Coleta automatica", desc = "Coleta drops, itens e baus proximos.", icon = "C", interval = 0.45 },
    { id = "TeleportSystem", title = "Sistema de Teletransporte", desc = "Alterna pontos de teleporte.", icon = "T", interval = 3.20 },
    { id = "StatusUI", title = "Interface de status", desc = "Exibe status em tempo real.", icon = "U", interval = 0.35, default = true },
    { id = "WebhookNotify", title = "Notificacao de Webhook", desc = "Envia feed de eventos para webhook.", icon = "W", interval = 4.00 },
    { id = "MultiAccount", title = "Conta multipla", desc = "Rotaciona perfis predefinidos.", icon = "X", interval = 7.00 },
    { id = "ConfigSystem", title = "Configurar sistema", desc = "Auto save/load de configuracoes.", icon = "G", interval = 5.00, default = true },
    { id = "PerfOptimize", title = "Otimizacao de desempenho", desc = "Reduz efeitos para melhor FPS.", icon = "P", interval = 8.00 },
}

local State = {
    running = true,
    started = os.clock(),
    toggles = {},
    loops = {},
    rows = {},
    labels = {},
    eventQueue = {},
    lastNotify = 0,
    teleportIndex = 1,
    profileIndex = 1,
    uiVisible = true,
    stats = {
        actions = 0,
        errors = 0,
        last = "idle",
    },
    config = {
        webhookUrl = "",
        interactDistance = 28,
        autosaveSeconds = 20,
        teleportPoints = {
            CFrame.new(0, 15, 0),
            CFrame.new(80, 15, 0),
            CFrame.new(-80, 15, 0),
        },
    },
}

for _, feature in ipairs(Features) do
    State.toggles[feature.id] = feature.default == true
end

local function now()
    return os.clock()
end

local function notify(title, text)
    if now() - State.lastNotify < 1.2 then
        return
    end
    State.lastNotify = now()
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 3,
        })
    end)
end

local function pushEvent(msg)
    State.stats.last = msg
    table.insert(State.eventQueue, { t = os.time(), m = msg })
end

local function bumpAction(msg, amount)
    State.stats.actions = State.stats.actions + (amount or 1)
    State.stats.last = msg
end

local function bumpError(msg)
    State.stats.errors = State.stats.errors + 1
    State.stats.last = msg
end

local function getRoot()
    local char = LocalPlayer.Character
    if not char then
        return nil
    end
    return char:FindFirstChild("HumanoidRootPart")
end

local function distTo(pos)
    local root = getRoot()
    if not root then
        return math.huge
    end
    return (root.Position - pos).Magnitude
end

local function firePrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then
        return false
    end
    local parent = prompt.Parent
    if not parent or not parent:IsA("BasePart") then
        return false
    end
    if distTo(parent.Position) > (prompt.MaxActivationDistance + 6) then
        return false
    end
    local ok = pcall(function()
        fireproximityprompt(prompt)
    end)
    return ok
end

local function touchPart(part)
    local root = getRoot()
    if not root or not part or not part:IsA("BasePart") then
        return false
    end
    local ok = pcall(function()
        firetouchinterest(root, part, 0)
        firetouchinterest(root, part, 1)
    end)
    return ok
end

local function equipTool()
    local char = LocalPlayer.Character
    if not char then
        return nil
    end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        return tool
    end
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if backpack then
        local bTool = backpack:FindFirstChildOfClass("Tool")
        if bTool then
            pcall(function()
                bTool.Parent = char
            end)
            return bTool
        end
    end
    return nil
end

local function postWebhook(url, payload)
    local requestFn = request or http_request or (syn and syn.request)
    local body = HttpService:JSONEncode(payload)
    if requestFn then
        local ok = pcall(function()
            requestFn({
                Url = url,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = body,
            })
        end)
        return ok
    end
    local ok = pcall(function()
        HttpService:PostAsync(url, body, Enum.HttpContentType.ApplicationJson)
    end)
    return ok
end

local function saveConfig()
    if not writefile then
        return
    end
    local out = {
        toggles = State.toggles,
        config = {
            webhookUrl = State.config.webhookUrl,
            interactDistance = State.config.interactDistance,
            autosaveSeconds = State.config.autosaveSeconds,
            teleportPoints = {},
        },
    }
    for _, cf in ipairs(State.config.teleportPoints) do
        local p = cf.Position
        table.insert(out.config.teleportPoints, { p.X, p.Y, p.Z })
    end
    local ok, text = pcall(function()
        return HttpService:JSONEncode(out)
    end)
    if ok then
        pcall(function()
            writefile(SAVE_FILE, text)
        end)
    end
end

local function loadConfig()
    if not readfile or not isfile or not isfile(SAVE_FILE) then
        return
    end
    local ok, decoded = pcall(function()
        return HttpService:JSONDecode(readfile(SAVE_FILE))
    end)
    if not ok or type(decoded) ~= "table" then
        return
    end
    if type(decoded.toggles) == "table" then
        for k, v in pairs(decoded.toggles) do
            if State.toggles[k] ~= nil then
                State.toggles[k] = v == true
            end
        end
    end
    if type(decoded.config) == "table" then
        State.config.webhookUrl = tostring(decoded.config.webhookUrl or State.config.webhookUrl)
        State.config.interactDistance = tonumber(decoded.config.interactDistance) or State.config.interactDistance
        State.config.autosaveSeconds = tonumber(decoded.config.autosaveSeconds) or State.config.autosaveSeconds
        if type(decoded.config.teleportPoints) == "table" and #decoded.config.teleportPoints > 0 then
            State.config.teleportPoints = {}
            for _, row in ipairs(decoded.config.teleportPoints) do
                if type(row) == "table" and #row >= 3 then
                    table.insert(State.config.teleportPoints, CFrame.new(tonumber(row[1]) or 0, tonumber(row[2]) or 15, tonumber(row[3]) or 0))
                end
            end
        end
    end
end

local function runAutoFarm()
    local root = getRoot()
    if not root then
        return
    end
    local target, best = nil, 120
    for _, model in ipairs(Workspace:GetDescendants()) do
        if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") and model:FindFirstChild("HumanoidRootPart") then
            if model ~= LocalPlayer.Character then
                local hum = model:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local d = (root.Position - model.HumanoidRootPart.Position).Magnitude
                    if d < best then
                        best = d
                        target = model
                    end
                end
            end
        end
    end
    if target then
        pcall(function()
            root.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 6)
        end)
        bumpAction("Farm: " .. target.Name)
    end
end

local function runAutoMission()
    local count = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local n = string.lower(obj.Name)
            if string.find(n, "quest") or string.find(n, "mission") or string.find(n, "npc") then
                if firePrompt(obj) then
                    count = count + 1
                end
            end
        end
    end
    if count > 0 then
        bumpAction("Mission x" .. tostring(count), count)
    end
end

local function runAutoBoss()
    local root = getRoot()
    if not root then
        return
    end
    local bossKeys = { "boss", "hydra", "rip_indra", "t-rex", "t rex", "elder turtle", "soul reaper" }
    local closest, closestDist = nil, 250
    for _, model in ipairs(Workspace:GetDescendants()) do
        if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") and model:FindFirstChildOfClass("Humanoid") then
            local lower = string.lower(model.Name)
            for _, key in ipairs(bossKeys) do
                if string.find(lower, key) then
                    local d = (root.Position - model.HumanoidRootPart.Position).Magnitude
                    if d < closestDist then
                        closestDist = d
                        closest = model
                    end
                    break
                end
            end
        end
    end
    if closest then
        pcall(function()
            root.CFrame = closest.HumanoidRootPart.CFrame * CFrame.new(0, 0, 9)
        end)
        bumpAction("Boss: " .. closest.Name)
        pushEvent("Boss detectado: " .. closest.Name)
    end
end

local function runAutoAttack()
    local tool = equipTool()
    if tool then
        pcall(function()
            tool:Activate()
        end)
        bumpAction("Attack")
    end
end

local function runAutoSeaEvent()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local n = string.lower(obj.Name)
        if string.find(n, "sea") or string.find(n, "ship raid") or string.find(n, "mirage") then
            pushEvent("Evento marinho: " .. obj.Name)
            notify("AutoHub", "Evento detectado: " .. obj.Name)
            bumpAction("SeaEvent")
            return
        end
    end
end

local function runAutoCollect()
    local count = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = string.lower(obj.Name)
            if (string.find(n, "chest") or string.find(n, "drop") or string.find(n, "fruit")) and distTo(obj.Position) <= State.config.interactDistance then
                if touchPart(obj) then
                    count = count + 1
                end
            end
        elseif obj:IsA("ProximityPrompt") then
            local p = string.lower(obj.Name)
            if string.find(p, "collect") or string.find(p, "claim") then
                if firePrompt(obj) then
                    count = count + 1
                end
            end
        end
    end
    if count > 0 then
        bumpAction("Collect x" .. tostring(count), count)
    end
end

local function runTeleportSystem()
    local root = getRoot()
    if not root or #State.config.teleportPoints == 0 then
        return
    end
    State.teleportIndex = (State.teleportIndex % #State.config.teleportPoints) + 1
    pcall(function()
        root.CFrame = State.config.teleportPoints[State.teleportIndex]
    end)
    bumpAction("Teleport #" .. tostring(State.teleportIndex))
end

local function runWebhookNotify()
    if State.config.webhookUrl == "" or #State.eventQueue == 0 then
        return
    end
    local fields = {}
    for _ = 1, math.min(5, #State.eventQueue) do
        local e = table.remove(State.eventQueue, 1)
        table.insert(fields, {
            name = os.date("%X", e.t),
            value = e.m,
            inline = false,
        })
    end
    local payload = {
        username = "AutoHub Compact",
        embeds = {
            {
                title = "Eventos",
                description = "Player: " .. LocalPlayer.Name,
                color = 4169983,
                fields = fields,
            },
        },
    }
    if postWebhook(State.config.webhookUrl, payload) then
        bumpAction("Webhook")
    else
        bumpError("Webhook fail")
    end
end

local function runMultiAccount()
    local profiles = {
        { AutoFarm = true, AutoCollect = true, AutoAttack = true, AutoBoss = false },
        { AutoFarm = false, AutoCollect = true, AutoAttack = true, AutoBoss = true },
        { AutoFarm = true, AutoMission = true, AutoCollect = false, AutoAttack = true, TeleportSystem = true },
    }
    State.profileIndex = (State.profileIndex % #profiles) + 1
    local p = profiles[State.profileIndex]
    for k, v in pairs(p) do
        if State.toggles[k] ~= nil then
            State.toggles[k] = v
        end
    end
    pushEvent("Perfil #" .. tostring(State.profileIndex))
end

local lastAutoSave = now()
local function runConfigSystem()
    if now() - lastAutoSave >= State.config.autosaveSeconds then
        lastAutoSave = now()
        saveConfig()
        bumpAction("Config saved")
    end
end

local function runPerfOptimize()
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.Brightness = 1
        Lighting.FogEnd = 9e9
    end)
    pcall(function()
        for _, d in ipairs(Workspace:GetDescendants()) do
            if d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Smoke") or d:IsA("Fire") then
                d.Enabled = false
            elseif d:IsA("PostEffect") then
                d.Enabled = false
            end
        end
    end)
    bumpAction("Perf mode")
end

local Runners = {
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

local function corner(target, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = target
end

local function stroke(target, color)
    local s = Instance.new("UIStroke")
    s.Thickness = 1
    s.Color = color or Theme.border
    s.Parent = target
end

local function makeDraggable(frame, handle)
    local dragging = false
    local startPos
    local startInput

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startPos = frame.Position
            startInput = input.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startInput
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function updateRowVisual(id)
    local row = State.rows[id]
    if not row then
        return
    end
    local enabled = State.toggles[id]
    row.toggle.Text = enabled and "ON" or "OFF"
    row.toggle.BackgroundColor3 = enabled and Theme.accent or Theme.off
    row.dot.BackgroundColor3 = enabled and Theme.ok or Theme.off
end

local function createUI()
    local old = PlayerGui:FindFirstChild(GUI_NAME)
    if old then
        old:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = GUI_NAME
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = PlayerGui

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 620, 0, 350)
    main.Position = UDim2.new(0.5, -310, 0.5, -175)
    main.BackgroundColor3 = Theme.bg
    main.Parent = gui
    corner(main, 12)
    stroke(main)

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 11, 21)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(6, 9, 17)),
    })
    grad.Rotation = 90
    grad.Parent = main

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 32)
    header.BackgroundTransparency = 1
    header.Parent = main

    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(0, 20, 0, 20)
    logo.Position = UDim2.new(0, 7, 0, 6)
    logo.BackgroundTransparency = 1
    logo.Font = Enum.Font.GothamBold
    logo.Text = "@"
    logo.TextSize = 14
    logo.TextColor3 = Theme.accent
    logo.Parent = header

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 240, 0, 18)
    title.Position = UDim2.new(0, 30, 0, 7)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.TextColor3 = Theme.text
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "AutoHub Compact " .. SCRIPT_VERSION
    title.Parent = header

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(0, 180, 0, 14)
    subtitle.Position = UDim2.new(0.5, -90, 0, 9)
    subtitle.BackgroundTransparency = 1
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 10
    subtitle.TextColor3 = Theme.muted
    subtitle.Text = "Farming | END = Hide/Show"
    subtitle.Parent = header

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 24, 0, 20)
    close.Position = UDim2.new(1, -30, 0, 6)
    close.Text = "X"
    close.Font = Enum.Font.GothamBold
    close.TextSize = 11
    close.TextColor3 = Theme.text
    close.BackgroundColor3 = Color3.fromRGB(45, 26, 36)
    close.Parent = header
    corner(close, 6)
    stroke(close)

    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 150, 1, -38)
    sidebar.Position = UDim2.new(0, 6, 0, 32)
    sidebar.BackgroundColor3 = Theme.panel
    sidebar.Parent = main
    corner(sidebar, 10)
    stroke(sidebar)

    local search = Instance.new("TextBox")
    search.Size = UDim2.new(1, -12, 0, 22)
    search.Position = UDim2.new(0, 6, 0, 6)
    search.PlaceholderText = "Search section or fun"
    search.Text = ""
    search.Font = Enum.Font.Gotham
    search.TextSize = 10
    search.TextColor3 = Theme.text
    search.PlaceholderColor3 = Theme.muted
    search.BackgroundColor3 = Theme.panel2
    search.Parent = sidebar
    corner(search, 6)
    stroke(search)

    local menuItems = {
        "Setting Farm",
        "Farming",
        "Misc",
        "Auto Reroll",
        "Dungeon",
        "Tower",
        "Boss Rush",
        "Auto Webhook",
    }

    local menuButtons = {}
    for i, name in ipairs(menuItems) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -12, 0, 21)
        b.Position = UDim2.new(0, 6, 0, 32 + ((i - 1) * 23))
        b.Text = "  " .. name
        b.Font = Enum.Font.Gotham
        b.TextSize = 10
        b.TextColor3 = Theme.text
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.BackgroundColor3 = (name == "Farming") and Theme.row or Theme.panel
        b.AutoButtonColor = false
        b.Parent = sidebar
        corner(b, 6)
        menuButtons[name] = b
        b.MouseButton1Click:Connect(function()
            for _, btn in pairs(menuButtons) do
                btn.BackgroundColor3 = Theme.panel
            end
            b.BackgroundColor3 = Theme.row
        end)
    end

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -162, 1, -38)
    content.Position = UDim2.new(0, 156, 0, 32)
    content.BackgroundColor3 = Theme.panel
    content.Parent = main
    corner(content, 10)
    stroke(content)

    local contentHeader = Instance.new("TextLabel")
    contentHeader.Size = UDim2.new(1, -12, 0, 20)
    contentHeader.Position = UDim2.new(0, 8, 0, 6)
    contentHeader.BackgroundTransparency = 1
    contentHeader.Font = Enum.Font.GothamBold
    contentHeader.TextSize = 12
    contentHeader.TextColor3 = Theme.text
    contentHeader.TextXAlignment = Enum.TextXAlignment.Left
    contentHeader.Text = "Farming"
    contentHeader.Parent = content

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -12, 0, 14)
    status.Position = UDim2.new(0, 8, 0, 22)
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.Gotham
    status.TextSize = 9
    status.TextColor3 = Theme.muted
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Text = "Uptime: 0s | Acoes: 0 | Erros: 0 | Last: idle"
    status.Parent = content
    State.labels.status = status

    local list = Instance.new("ScrollingFrame")
    list.Size = UDim2.new(1, -8, 1, -42)
    list.Position = UDim2.new(0, 4, 0, 38)
    list.CanvasSize = UDim2.new(0, 0, 0, 0)
    list.BackgroundTransparency = 1
    list.ScrollBarThickness = 4
    list.Parent = content

    local y = 0
    for i, feature in ipairs(Features) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -8, 0, 26)
        row.Position = UDim2.new(0, 4, 0, y)
        row.BackgroundColor3 = Theme.row
        row.Parent = list
        corner(row, 6)
        stroke(row, Color3.fromRGB(28, 40, 70))

        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 7, 0, 7)
        dot.Position = UDim2.new(0, 7, 0.5, -3)
        dot.BackgroundColor3 = Theme.off
        dot.Parent = row
        corner(dot, 4)

        local name = Instance.new("TextLabel")
        name.Size = UDim2.new(1, -118, 1, 0)
        name.Position = UDim2.new(0, 18, 0, 0)
        name.BackgroundTransparency = 1
        name.Font = Enum.Font.Gotham
        name.TextSize = 10
        name.TextColor3 = Theme.text
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.Text = feature.title
        name.Parent = row

        local arrow = Instance.new("TextLabel")
        arrow.Size = UDim2.new(0, 14, 1, 0)
        arrow.Position = UDim2.new(1, -68, 0, 0)
        arrow.BackgroundTransparency = 1
        arrow.Font = Enum.Font.GothamBold
        arrow.TextSize = 9
        arrow.TextColor3 = Theme.muted
        arrow.Text = ">"
        arrow.Parent = row

        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0, 44, 0, 18)
        toggle.Position = UDim2.new(1, -50, 0.5, -9)
        toggle.Font = Enum.Font.GothamBold
        toggle.TextSize = 9
        toggle.TextColor3 = Theme.text
        toggle.Parent = row
        corner(toggle, 6)

        toggle.MouseButton1Click:Connect(function()
            State.toggles[feature.id] = not State.toggles[feature.id]
            updateRowVisual(feature.id)
            pushEvent(feature.title .. " -> " .. (State.toggles[feature.id] and "ON" or "OFF"))
        end)

        State.rows[feature.id] = { row = row, toggle = toggle, dot = dot }
        updateRowVisual(feature.id)

        y = y + 28
        if i == 1 then
            row.BackgroundColor3 = Color3.fromRGB(16, 23, 40)
        end
    end
    list.CanvasSize = UDim2.new(0, 0, 0, y + 2)

    close.MouseButton1Click:Connect(function()
        State.running = false
        gui:Destroy()
        getgenv().AutoHubCompactLoaded = nil
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then
            return
        end
        if input.KeyCode == Enum.KeyCode.End then
            State.uiVisible = not State.uiVisible
            main.Visible = State.uiVisible
        end
    end)

    makeDraggable(main, header)
end

local function updateStatus()
    local active = 0
    for _, enabled in pairs(State.toggles) do
        if enabled then
            active = active + 1
        end
    end
    if State.labels.status then
        State.labels.status.Text = "Uptime: " .. tostring(math.floor(now() - State.started)) ..
            "s | Ativos: " .. tostring(active) ..
            " | Acoes: " .. tostring(State.stats.actions) ..
            " | Erros: " .. tostring(State.stats.errors) ..
            " | Last: " .. tostring(State.stats.last)
    end
    for id, _ in pairs(State.rows) do
        updateRowVisual(id)
    end
end

local function startLoops()
    for _, feature in ipairs(Features) do
        if not State.loops[feature.id] then
            State.loops[feature.id] = task.spawn(function()
                while State.running do
                    if State.toggles[feature.id] then
                        if feature.id ~= "StatusUI" then
                            local run = Runners[feature.id]
                            if run then
                                local ok, err = pcall(run)
                                if not ok then
                                    bumpError("Err " .. feature.id)
                                    warn("[AutoHub][" .. feature.id .. "] " .. tostring(err))
                                end
                            end
                        end
                    end
                    task.wait(feature.interval)
                end
            end)
        end
    end
end

local function autosaveLoop()
    task.spawn(function()
        local last = now()
        while State.running do
            if now() - last >= State.config.autosaveSeconds then
                last = now()
                saveConfig()
            end
            task.wait(1)
        end
    end)
end

local function boot()
    loadConfig()
    createUI()
    startLoops()
    autosaveLoop()

    task.spawn(function()
        while State.running do
            updateStatus()
            task.wait(0.25)
        end
    end)

    RunService.Heartbeat:Connect(function()
        if not State.running then
            return
        end
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health <= 0 then
                pushEvent("Player morreu")
            end
        end
    end)

    notify("AutoHub", "Compact UI carregada " .. SCRIPT_VERSION)
end

boot()
