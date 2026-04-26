--[[
    AutoHub Organized UI (V5)
    Compact + draggable + END to hide/show
]]

pcall(function()
    local pg = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    for _, child in ipairs(pg:GetChildren()) do
        if child:IsA("ScreenGui") then
            local lower = string.lower(child.Name)
            if string.find(lower, "autohub", 1, true) then
                child:Destroy()
            end
        end
    end
end)

pcall(function()
    getgenv().AutoHubLoaded = nil
    getgenv().AutoHubBFLoaded = nil
    getgenv().AutoHubGridLoaded = nil
    getgenv().AutoHubCompactLoaded = nil
    getgenv().AutoHubV5Loaded = nil
end)

if getgenv().AutoHubV5Loaded then
    return
end
getgenv().AutoHubV5Loaded = true

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")

local hasVim, VirtualInputManager = pcall(function()
    return game:GetService("VirtualInputManager")
end)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local VERSION = "V5-2026-04-26"
local GUI_NAME = "AutoHub_Organized_" .. VERSION
local SAVE_FILE = "autohub_organized_config.json"

local Theme = {
    bg = Color3.fromRGB(7, 10, 18),
    panel = Color3.fromRGB(10, 14, 24),
    panel2 = Color3.fromRGB(12, 17, 29),
    row = Color3.fromRGB(13, 18, 31),
    rowActive = Color3.fromRGB(18, 26, 45),
    border = Color3.fromRGB(32, 43, 73),
    text = Color3.fromRGB(234, 241, 255),
    muted = Color3.fromRGB(148, 166, 214),
    accent = Color3.fromRGB(66, 126, 255),
    off = Color3.fromRGB(71, 78, 110),
    ok = Color3.fromRGB(84, 219, 136),
    warn = Color3.fromRGB(225, 168, 73),
}

local CategoryDefs = {
    {
        id = "auto_farm",
        label = "Auto Farm",
        interval = 0.45,
        items = {
            "Auto Farm Level",
            "Auto Farm (inimigo mais proximo)",
            "Auto Farm por selecao de mob",
            "Auto Quest",
            "Auto Farm com arma especifica",
            "Auto Farm com fruta especifica",
            "Auto Farm com fighting style",
            "Auto Farm com distancia segura",
            "Auto Farm com deteccao de HP",
            "Auto Farm inteligente (troca de ilha automaticamente)",
            "Auto Farm AFK",
            "Auto Farm com pathfinding (andar em vez de teleportar)",
            "Auto Farm com ataque automatico (M1 spam)",
            "Auto Farm com skills automaticas",
            "Auto Farm com posicionamento atras do inimigo",
        },
    },
    {
        id = "boss",
        label = "Boss",
        interval = 0.9,
        items = {
            "Auto Boss",
            "Auto Boss Select",
            "Auto Elite Hunter",
            "Auto Saber",
            "Auto Don Swan",
            "Auto Cake Prince",
            "Auto Rip Indra",
            "Auto Dough King",
            "Auto Tushita Quest",
            "Auto Boss Spawn Detector",
            "Auto Server Hop para boss",
        },
    },
    {
        id = "frutas",
        label = "Frutas",
        interval = 2.0,
        items = {
            "Auto Buy Fruit",
            "Auto Store Fruit",
            "Auto Drop Fruit",
            "Auto Eat Fruit",
            "Auto Random Fruit (Gacha)",
            "Auto Sniper Fruit (espera stock)",
            "Auto Mastery Fruit",
            "Auto Awakening (Raid)",
            "Auto Raid com fruta especifica",
        },
    },
    {
        id = "combate",
        label = "Combate",
        interval = 0.18,
        items = {
            "Kill Aura",
            "Fast Attack",
            "No Attack Delay",
            "Auto Click",
            "Auto Skill (Z, X, C, V, F)",
            "Auto Combo",
            "Auto Aim Skill",
            "Hitbox Expander",
            "Damage Amplifier (visual/client)",
        },
    },
    {
        id = "fighting_style",
        label = "Fighting Style",
        interval = 1.2,
        items = {
            "Auto Mastery Fighting Style",
            "Auto Switch Fighting Style",
            "Auto Unlock Style",
            "Auto Upgrade Style",
        },
    },
    {
        id = "espadas",
        label = "Espadas",
        interval = 1.2,
        items = {
            "Auto Sword Mastery",
            "Auto Equip Sword",
            "Auto Switch Sword",
            "Auto Upgrade Sword",
        },
    },
    {
        id = "armas",
        label = "Armas (Guns)",
        interval = 0.35,
        items = {
            "Auto Gun Farm",
            "Auto Shoot",
            "Aimbot Gun",
            "Auto Reload",
            "No Spread",
        },
    },
    {
        id = "raca",
        label = "Raca",
        interval = 2.2,
        items = {
            "Auto Race V2",
            "Auto Race V3",
            "Auto Race V4",
            "Auto Trials",
            "Auto Mirage Island",
            "Auto Gear",
            "Auto Upgrade Race",
        },
    },
    {
        id = "haki",
        label = "Haki",
        interval = 1.1,
        items = {
            "Auto Enhancement (Aura)",
            "Auto Observation Haki",
            "Auto Ken Haki",
            "Auto Buso Haki",
            "Auto Full Body Haki",
        },
    },
    {
        id = "teleport",
        label = "Teleport / Movimento",
        interval = 1.9,
        items = {
            "Teleport Island",
            "Teleport NPC",
            "Teleport Boss",
            "Teleport Player",
            "Tween Teleport (movimento suave)",
            "Instant Teleport",
            "Bring Mob",
            "Bring All Mobs",
            "Magnet Farm (puxa inimigos)",
        },
    },
    {
        id = "player_mods",
        label = "Player Mods",
        interval = 0.2,
        items = {
            "Walk Speed",
            "Jump Power",
            "Fly",
            "NoClip",
            "Infinite Jump",
            "Dash Boost",
            "Anti Stun",
            "No Knockback",
        },
    },
    {
        id = "esp_visual",
        label = "ESP (Visual)",
        interval = 1.3,
        items = {
            "Player ESP",
            "Enemy ESP",
            "Boss ESP",
            "Chest ESP",
            "Fruit ESP",
            "Island ESP",
            "NPC ESP",
            "Distance ESP",
            "Health ESP",
            "Tracers",
            "Boxes",
            "Highlight",
        },
    },
    {
        id = "recursos",
        label = "Recursos",
        interval = 0.65,
        items = {
            "Auto Chest",
            "Auto Collect",
            "Auto Loot",
            "Auto Money",
            "Auto Fragments",
            "Auto Drops",
            "Auto Materials",
        },
    },
    {
        id = "server_runtime",
        label = "Server / Sistema",
        interval = 6.0,
        items = {
            "Server Hop",
            "Auto Server Hop",
            "Join Low Player Server",
            "Rejoin",
            "Auto Reconnect",
            "Anti AFK",
        },
    },
    {
        id = "inteligencia",
        label = "Inteligencia / Deteccao",
        interval = 4.0,
        items = {
            "Detect Player Nearby",
            "Detect Admin",
            "Auto Leave (staff detectado)",
            "Anti Report",
            "Anti Ban (simulacao)",
            "Delay Randomizado / Simulacao de humano",
        },
    },
    {
        id = "misc",
        label = "Misc",
        interval = 4.0,
        items = {
            "Full Bright",
            "Remove Fog",
            "FPS Boost",
            "Remove Effects",
            "White Screen Mode",
            "Low Graphics Mode",
        },
    },
    {
        id = "stats",
        label = "Stats",
        interval = 2.1,
        items = {
            "Auto Stats",
            "Auto Melee",
            "Auto Defense",
            "Auto Sword",
            "Auto Gun",
            "Auto Blox Fruit",
        },
    },
    {
        id = "interface_tools",
        label = "Interface (GUI)",
        interval = 3.0,
        items = {
            "Toggle Button",
            "Dropdown Select",
            "Slider",
            "Keybind",
            "Save Config",
            "Load Config",
        },
    },
    {
        id = "sistema_core",
        label = "Sistema",
        interval = 4.5,
        items = {
            "Key System",
            "Script Hub",
            "Auto Update",
            "Config Save",
            "Config Load",
            "Webhook (Discord)",
        },
    },
    {
        id = "avancadas",
        label = "Especificas Avancadas",
        interval = 2.3,
        items = {
            "Auto Sea Event",
            "Auto Leviathan",
            "Auto Ship Raid",
            "Auto Haunted Event",
            "Auto Trial Puzzle",
            "Auto Temple",
            "Auto Gear Farming",
            "Auto Mirage Detection",
            "Auto Blue Gear",
        },
    },
}

local BossKeywords = {
    "boss", "saber", "don swan", "cake prince", "rip indra", "dough king", "tushita",
    "soul reaper", "hydra", "elder turtle", "t-rex", "trex", "leviathan",
}

local IslandKeywords = {
    "starter", "jungle", "pirate village", "desert", "frozen village", "marineford",
    "sky", "prison", "colosseum", "magma", "underwater", "fountain",
    "kingdom of rose", "green zone", "graveyard", "snow mountain", "hot and cold",
    "cursed ship", "ice castle", "forgotten", "port town", "hydra island",
    "great tree", "floating turtle", "haunted castle", "sea of treats", "mirage",
}

local State = {
    running = true,
    startedAt = os.clock(),
    items = {},
    toggles = {},
    nextRun = {},
    categoryItems = {},
    categoryOrder = {},
    categoryLookup = {},
    visibleRows = {},
    categoryButtons = {},
    highlights = {},
    eventQueue = {},
    activeCount = 0,
    teleportIndex = 1,
    profileIndex = 1,
    lastNotifyAt = 0,
    uiVisible = true,
    flags = {
        requestRenderRows = false,
    },
    cache = {
        lastBossNotice = "",
        lastAdminNotice = 0,
    },
    stats = {
        actions = 0,
        errors = 0,
        last = "idle",
    },
    ui = {},
    connections = {},
    config = {
        selectedCategory = "auto_farm",
        searchText = "",
        webhookUrl = "",
        autosaveSeconds = 20,
        teleportPoints = {
            CFrame.new(0, 15, 0),
            CFrame.new(80, 15, 0),
            CFrame.new(-80, 15, 0),
        },
    },
}

local function slugify(text)
    local s = string.lower(text)
    s = string.gsub(s, "[^%w]+", "_")
    s = string.gsub(s, "_+", "_")
    s = string.gsub(s, "^_", "")
    s = string.gsub(s, "_$", "")
    return s
end

for _, cat in ipairs(CategoryDefs) do
    State.categoryLookup[cat.id] = cat
    table.insert(State.categoryOrder, cat.id)
    State.categoryItems[cat.id] = {}
    for idx, itemName in ipairs(cat.items) do
        local id = cat.id .. "__" .. slugify(itemName) .. "_" .. tostring(idx)
        local item = {
            id = id,
            name = itemName,
            lower = string.lower(itemName),
            categoryId = cat.id,
            interval = cat.interval,
        }
        State.items[id] = item
        State.toggles[id] = false
        State.nextRun[id] = 0
        table.insert(State.categoryItems[cat.id], id)
    end
end

local function trim(s)
    return (string.gsub(string.gsub(s or "", "^%s+", ""), "%s+$", ""))
end

local function now()
    return os.clock()
end

local function safeNotify(title, text)
    if now() - State.lastNotifyAt < 1.2 then
        return
    end
    State.lastNotifyAt = now()
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 3,
        })
    end)
end

local function pushEvent(text)
    State.stats.last = text
    table.insert(State.eventQueue, {
        t = os.time(),
        m = text,
    })
    if #State.eventQueue > 120 then
        table.remove(State.eventQueue, 1)
    end
end

local function addAction(label, amount)
    State.stats.actions = State.stats.actions + (amount or 1)
    State.stats.last = label
end

local function addError(label)
    State.stats.errors = State.stats.errors + 1
    State.stats.last = label
end

local function getCharacter()
    return LocalPlayer.Character
end

local function getHumanoid()
    local char = getCharacter()
    if not char then
        return nil
    end
    return char:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    local char = getCharacter()
    if not char then
        return nil
    end
    return char:FindFirstChild("HumanoidRootPart")
end

local function findBasePart(obj)
    local current = obj
    while current and not current:IsA("BasePart") do
        current = current.Parent
    end
    return current
end

local function containsAny(lowerText, keywords)
    for _, key in ipairs(keywords) do
        if string.find(lowerText, key, 1, true) then
            return true
        end
    end
    return false
end

local function isEnemyModel(model)
    if not model or not model:IsA("Model") then
        return false
    end
    if model == getCharacter() then
        return false
    end
    if Players:GetPlayerFromCharacter(model) then
        return false
    end
    local hum = model:FindFirstChildOfClass("Humanoid")
    local root = model:FindFirstChild("HumanoidRootPart")
    return hum ~= nil and root ~= nil and hum.Health > 0
end

local function isBossName(lowerName)
    return containsAny(lowerName, BossKeywords)
end

local function distanceTo(position)
    local root = getRoot()
    if not root then
        return math.huge
    end
    return (root.Position - position).Magnitude
end

local function findNearestEnemy(maxDistance, bossOnly, explicitPattern)
    local root = getRoot()
    if not root then
        return nil
    end
    local nearest = nil
    local best = maxDistance or 150
    local pattern = explicitPattern and string.lower(explicitPattern) or nil
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if isEnemyModel(obj) then
            local lowerName = string.lower(obj.Name)
            if (not bossOnly or isBossName(lowerName)) and (not pattern or string.find(lowerName, pattern, 1, true)) then
                local dist = (root.Position - obj.HumanoidRootPart.Position).Magnitude
                if dist < best then
                    best = dist
                    nearest = obj
                end
            end
        end
    end
    return nearest
end

local function teleportNearModel(model, backDistance, useTween)
    local root = getRoot()
    if not root or not model or not model:FindFirstChild("HumanoidRootPart") then
        return false
    end
    local targetCFrame = model.HumanoidRootPart.CFrame * CFrame.new(0, 0, backDistance or 6)
    local ok = pcall(function()
        if useTween then
            TweenService:Create(root, TweenInfo.new(0.18, Enum.EasingStyle.Linear), { CFrame = targetCFrame }):Play()
        else
            root.CFrame = targetCFrame
        end
    end)
    return ok
end

local function runTeleportCycle(useTween)
    local root = getRoot()
    if not root then
        return false
    end
    local points = State.config.teleportPoints
    if #points == 0 then
        return false
    end
    State.teleportIndex = (State.teleportIndex % #points) + 1
    local cf = points[State.teleportIndex]
    local ok = pcall(function()
        if useTween then
            TweenService:Create(root, TweenInfo.new(0.22, Enum.EasingStyle.Linear), { CFrame = cf }):Play()
        else
            root.CFrame = cf
        end
    end)
    return ok
end

local function activatePrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then
        return false
    end
    local part = findBasePart(prompt.Parent)
    if not part then
        return false
    end
    if distanceTo(part.Position) > (prompt.MaxActivationDistance + 8) then
        return false
    end
    local ok = pcall(function()
        fireproximityprompt(prompt)
    end)
    return ok
end

local function promptMatches(prompt, keywords)
    local text = string.lower(prompt.Name)
    text = text .. " " .. string.lower(tostring(prompt.ObjectText))
    text = text .. " " .. string.lower(tostring(prompt.ActionText))
    if prompt.Parent then
        text = text .. " " .. string.lower(prompt.Parent.Name)
    end
    return containsAny(text, keywords)
end

local function runPromptKeywords(keywords, maxCount)
    local count = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and promptMatches(obj, keywords) then
            if activatePrompt(obj) then
                count = count + 1
                if maxCount and count >= maxCount then
                    break
                end
            end
        end
    end
    return count > 0, count
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

local function collectPartsByKeywords(keywords, maxDistance, maxCount)
    local count = 0
    local limit = maxCount or 10
    local distanceLimit = maxDistance or 35
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local lowerName = string.lower(obj.Name)
            if containsAny(lowerName, keywords) and distanceTo(obj.Position) <= distanceLimit then
                if touchPart(obj) then
                    count = count + 1
                    if count >= limit then
                        break
                    end
                end
            end
        end
    end
    return count > 0, count
end

local function equipAnyTool()
    local char = getCharacter()
    if not char then
        return nil
    end
    local equipped = char:FindFirstChildOfClass("Tool")
    if equipped then
        return equipped
    end
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if not backpack then
        return nil
    end
    local found = backpack:FindFirstChildOfClass("Tool")
    if found then
        pcall(function()
            found.Parent = char
        end)
    end
    return found
end

local function equipToolByKeywords(keywords)
    local char = getCharacter()
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    local buckets = {}
    if char then
        table.insert(buckets, char)
    end
    if backpack then
        table.insert(buckets, backpack)
    end
    for _, bucket in ipairs(buckets) do
        for _, tool in ipairs(bucket:GetChildren()) do
            if tool:IsA("Tool") then
                local lowerName = string.lower(tool.Name)
                if not keywords or containsAny(lowerName, keywords) then
                    if char and tool.Parent ~= char then
                        pcall(function()
                            tool.Parent = char
                        end)
                    end
                    return tool
                end
            end
        end
    end
    return equipAnyTool()
end

local function activateTool(tool)
    local t = tool or equipAnyTool()
    if not t then
        return false
    end
    local ok = pcall(function()
        t:Activate()
    end)
    return ok
end

local function sendSkillKeys()
    if not hasVim or not VirtualInputManager then
        return false
    end
    local keys = {
        Enum.KeyCode.Z,
        Enum.KeyCode.X,
        Enum.KeyCode.C,
        Enum.KeyCode.V,
        Enum.KeyCode.F,
    }
    for _, key in ipairs(keys) do
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, key, false, game)
            VirtualInputManager:SendKeyEvent(false, key, false, game)
        end)
    end
    return true
end

local function getCategoryEnabledCount(categoryId)
    local count = 0
    for _, id in ipairs(State.categoryItems[categoryId]) do
        if State.toggles[id] then
            count = count + 1
        end
    end
    return count
end

local function isEnabledByName(categoryId, phrase)
    local lowerPhrase = string.lower(phrase)
    for _, id in ipairs(State.categoryItems[categoryId]) do
        if State.toggles[id] then
            local item = State.items[id]
            if string.find(item.lower, lowerPhrase, 1, true) then
                return true
            end
        end
    end
    return false
end

local function isEnabledAnywhere(phrase)
    local lowerPhrase = string.lower(phrase)
    for id, enabled in pairs(State.toggles) do
        if enabled then
            local item = State.items[id]
            if item and string.find(item.lower, lowerPhrase, 1, true) then
                return true
            end
        end
    end
    return false
end

local function ensureAntiAfk()
    if State.connections.antiAfk then
        return
    end
    State.connections.antiAfk = LocalPlayer.Idled:Connect(function()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
end

local function ensureInfiniteJump()
    if State.connections.infJump then
        return
    end
    State.connections.infJump = UserInputService.JumpRequest:Connect(function()
        if not State.running then
            return
        end
        if isEnabledByName("player_mods", "infinite jump") then
            local hum = getHumanoid()
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

local function ensureWhiteOverlay(enabled)
    if enabled then
        if State.ui.whiteOverlay then
            return
        end
        local g = Instance.new("ScreenGui")
        g.Name = GUI_NAME .. "_White"
        g.ResetOnSpawn = false
        g.IgnoreGuiInset = true
        g.Parent = PlayerGui
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, 0, 1, 0)
        f.BackgroundColor3 = Color3.new(1, 1, 1)
        f.BorderSizePixel = 0
        f.Parent = g
        State.ui.whiteOverlay = g
    else
        if State.ui.whiteOverlay then
            State.ui.whiteOverlay:Destroy()
            State.ui.whiteOverlay = nil
        end
    end
end

local function clearHighlights()
    for key, h in pairs(State.highlights) do
        pcall(function()
            h:Destroy()
        end)
        State.highlights[key] = nil
    end
end

local function upsertHighlight(key, adornee, color)
    if not adornee then
        return
    end
    local h = State.highlights[key]
    if h and h.Parent and h.Adornee == adornee then
        h.FillColor = color
        h.OutlineColor = color
        h:SetAttribute("seen", true)
        return
    end
    if h then
        pcall(function()
            h:Destroy()
        end)
    end
    local newH = Instance.new("Highlight")
    newH.Name = "AH_HL"
    newH.FillColor = color
    newH.FillTransparency = 0.78
    newH.OutlineColor = color
    newH.OutlineTransparency = 0.15
    newH.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    newH.Adornee = adornee
    newH:SetAttribute("seen", true)
    newH.Parent = Workspace
    State.highlights[key] = newH
end

local function refreshESP()
    local showPlayer = isEnabledByName("esp_visual", "player esp")
    local showEnemy = isEnabledByName("esp_visual", "enemy esp")
    local showBoss = isEnabledByName("esp_visual", "boss esp")
    local showChest = isEnabledByName("esp_visual", "chest esp")
    local showFruit = isEnabledByName("esp_visual", "fruit esp")
    local showNpc = isEnabledByName("esp_visual", "npc esp")
    local showIsland = isEnabledByName("esp_visual", "island esp")

    if not (showPlayer or showEnemy or showBoss or showChest or showFruit or showNpc or showIsland) then
        clearHighlights()
        return false
    end

    for _, h in pairs(State.highlights) do
        if h and h.Parent then
            h:SetAttribute("seen", false)
        end
    end

    if showPlayer then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                upsertHighlight("P:" .. tostring(plr), plr.Character, Color3.fromRGB(86, 155, 255))
            end
        end
    end

    local objectBudget = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if objectBudget > 120 then
            break
        end
        if obj:IsA("Model") then
            local lower = string.lower(obj.Name)
            if showBoss and isEnemyModel(obj) and isBossName(lower) then
                upsertHighlight("B:" .. tostring(obj), obj, Color3.fromRGB(255, 111, 111))
                objectBudget = objectBudget + 1
            elseif showEnemy and isEnemyModel(obj) then
                upsertHighlight("E:" .. tostring(obj), obj, Color3.fromRGB(255, 205, 90))
                objectBudget = objectBudget + 1
            elseif showNpc and containsAny(lower, { "npc", "quest", "dealer", "trainer", "teacher" }) then
                upsertHighlight("N:" .. tostring(obj), obj, Color3.fromRGB(149, 239, 167))
                objectBudget = objectBudget + 1
            end
        elseif obj:IsA("BasePart") then
            local lower = string.lower(obj.Name)
            if showChest and containsAny(lower, { "chest", "treasure" }) then
                upsertHighlight("C:" .. tostring(obj), obj, Color3.fromRGB(255, 228, 122))
                objectBudget = objectBudget + 1
            elseif showFruit and containsAny(lower, { "fruit", "blox" }) then
                upsertHighlight("F:" .. tostring(obj), obj, Color3.fromRGB(219, 141, 255))
                objectBudget = objectBudget + 1
            elseif showIsland and containsAny(lower, IslandKeywords) then
                upsertHighlight("I:" .. tostring(obj), obj, Color3.fromRGB(122, 226, 255))
                objectBudget = objectBudget + 1
            end
        end
    end

    for key, h in pairs(State.highlights) do
        local seen = h and h.Parent and h:GetAttribute("seen")
        if not seen then
            pcall(function()
                h:Destroy()
            end)
            State.highlights[key] = nil
        end
    end

    return true
end

local function postWebhook(url, payload)
    local body = HttpService:JSONEncode(payload)
    local requestFn = request or http_request or (syn and syn.request)
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

local function sendWebhookBatch()
    local url = trim(State.config.webhookUrl)
    if url == "" or #State.eventQueue == 0 then
        return false
    end
    local fields = {}
    for _ = 1, math.min(8, #State.eventQueue) do
        local e = table.remove(State.eventQueue, 1)
        table.insert(fields, {
            name = os.date("%X", e.t),
            value = e.m,
            inline = false,
        })
    end
    local payload = {
        username = "AutoHub Organized",
        embeds = {
            {
                title = "Automation Feed",
                description = "Player: " .. LocalPlayer.Name,
                color = 4169983,
                fields = fields,
            },
        },
    }
    local ok = postWebhook(url, payload)
    if ok then
        State.stats.last = "webhook sent"
    end
    return ok
end

local function encodeConfig()
    local out = {
        toggles = State.toggles,
        config = {
            selectedCategory = State.config.selectedCategory,
            searchText = State.config.searchText,
            webhookUrl = State.config.webhookUrl,
            autosaveSeconds = State.config.autosaveSeconds,
            teleportPoints = {},
        },
    }
    for _, cf in ipairs(State.config.teleportPoints) do
        local p = cf.Position
        table.insert(out.config.teleportPoints, { p.X, p.Y, p.Z })
    end
    return out
end

local function saveConfig()
    if not writefile then
        return false
    end
    local ok, text = pcall(function()
        return HttpService:JSONEncode(encodeConfig())
    end)
    if not ok then
        return false
    end
    local wOk = pcall(function()
        writefile(SAVE_FILE, text)
    end)
    return wOk
end

local function loadConfig()
    if not readfile or not isfile or not isfile(SAVE_FILE) then
        return false
    end
    local ok, decoded = pcall(function()
        return HttpService:JSONDecode(readfile(SAVE_FILE))
    end)
    if not ok or type(decoded) ~= "table" then
        return false
    end

    if type(decoded.toggles) == "table" then
        for id, value in pairs(decoded.toggles) do
            if State.toggles[id] ~= nil then
                State.toggles[id] = value == true
            end
        end
    end
    if type(decoded.config) == "table" then
        if type(decoded.config.selectedCategory) == "string" and State.categoryLookup[decoded.config.selectedCategory] then
            State.config.selectedCategory = decoded.config.selectedCategory
        end
        State.config.searchText = tostring(decoded.config.searchText or "")
        State.config.webhookUrl = tostring(decoded.config.webhookUrl or "")
        State.config.autosaveSeconds = tonumber(decoded.config.autosaveSeconds) or State.config.autosaveSeconds
        if type(decoded.config.teleportPoints) == "table" and #decoded.config.teleportPoints > 0 then
            State.config.teleportPoints = {}
            for _, row in ipairs(decoded.config.teleportPoints) do
                if type(row) == "table" and #row >= 3 then
                    table.insert(
                        State.config.teleportPoints,
                        CFrame.new(tonumber(row[1]) or 0, tonumber(row[2]) or 15, tonumber(row[3]) or 0)
                    )
                end
            end
        end
    end
    return true
end

local function findNearestPlayerCharacter(maxDistance)
    local root = getRoot()
    if not root then
        return nil
    end
    local best = maxDistance or 500
    local target = nil
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (root.Position - plr.Character.HumanoidRootPart.Position).Magnitude
            if dist < best then
                best = dist
                target = plr.Character
            end
        end
    end
    return target
end

local function findNearestKeywordObject(keywords, maxDistance)
    local root = getRoot()
    if not root then
        return nil
    end
    local best = maxDistance or 600
    local found = nil
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
            local lower = string.lower(obj.Name)
            if containsAny(lower, keywords) then
                local dist = (root.Position - obj.HumanoidRootPart.Position).Magnitude
                if dist < best then
                    best = dist
                    found = obj
                end
            end
        elseif obj:IsA("BasePart") then
            local lower = string.lower(obj.Name)
            if containsAny(lower, keywords) then
                local dist = (root.Position - obj.Position).Magnitude
                if dist < best then
                    best = dist
                    found = obj
                end
            end
        end
    end
    return found
end

local function bringEnemies(radius, bringAll)
    local root = getRoot()
    if not root then
        return false
    end
    local count = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if isEnemyModel(obj) then
            local d = (root.Position - obj.HumanoidRootPart.Position).Magnitude
            if d <= 250 then
                pcall(function()
                    local offset = Vector3.new((count % 6) * 2, 0, math.floor(count / 6) * 2)
                    obj.HumanoidRootPart.CFrame = root.CFrame * CFrame.new(offset)
                end)
                count = count + 1
                if not bringAll and count >= 1 then
                    break
                end
                if count >= (radius or 18) then
                    break
                end
            end
        end
    end
    return count > 0
end

local function setHumanoidProps()
    local hum = getHumanoid()
    local root = getRoot()
    if not hum then
        return false
    end
    local changed = false

    if isEnabledByName("player_mods", "walk speed") then
        if hum.WalkSpeed < 32 then
            hum.WalkSpeed = 32
            changed = true
        end
    end

    if isEnabledByName("player_mods", "dash boost") then
        if hum.WalkSpeed < 44 then
            hum.WalkSpeed = 44
            changed = true
        end
    end

    if isEnabledByName("player_mods", "jump power") then
        hum.UseJumpPower = true
        if hum.JumpPower < 85 then
            hum.JumpPower = 85
            changed = true
        end
    end

    if isEnabledByName("player_mods", "noclip") then
        local char = getCharacter()
        if char then
            for _, obj in ipairs(char:GetDescendants()) do
                if obj:IsA("BasePart") and obj.CanCollide then
                    obj.CanCollide = false
                    changed = true
                end
            end
        end
    end

    if isEnabledByName("player_mods", "anti stun") then
        hum.PlatformStand = false
        hum.Sit = false
        changed = true
    end

    if isEnabledByName("player_mods", "no knockback") and root then
        root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
        changed = true
    end

    if isEnabledByName("player_mods", "infinite jump") then
        ensureInfiniteJump()
    end

    if isEnabledByName("player_mods", "fly") and root then
        pcall(function()
            root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 22, root.AssemblyLinearVelocity.Z)
        end)
        changed = true
    end

    return changed
end

local function applyLowGraphics()
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 1
    end)
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") then
                obj.Enabled = false
            elseif obj:IsA("PostEffect") then
                obj.Enabled = false
            end
        end
    end)
end

local function detectPossibleAdmin()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local lower = string.lower(plr.Name .. " " .. plr.DisplayName)
            if containsAny(lower, { "admin", "mod", "owner", "developer", "staff" }) then
                return plr
            end
        end
    end
    return nil
end

local function tryFireStatsRemote(statName)
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local lower = string.lower(obj.Name)
            if containsAny(lower, { "addpoint", "addstat", "upstat", "stats", "add point" }) then
                local ok = pcall(function()
                    obj:FireServer(statName, 1)
                end)
                if ok then
                    return true
                end
            end
        end
    end
    return false
end

local function runAutoFarm(item)
    local acted = false
    if string.find(item.lower, "quest", 1, true) then
        local ok, c = runPromptKeywords({ "quest", "mission", "giver", "npc" }, 2)
        acted = ok or acted
        if c and c > 0 then
            addAction("quest x" .. tostring(c), c)
        end
    end
    if string.find(item.lower, "skills", 1, true) then
        acted = sendSkillKeys() or acted
    end
    if string.find(item.lower, "afk", 1, true) then
        ensureAntiAfk()
        acted = true
    end

    local target = findNearestEnemy(140, false, nil)
    if target then
        local hum = target:FindFirstChildOfClass("Humanoid")
        if isEnabledByName("auto_farm", "deteccao de hp") and hum and hum.Health <= 5 then
            return acted
        end
        local useTween = string.find(item.lower, "pathfinding", 1, true) ~= nil
        local backDistance = isEnabledByName("auto_farm", "distancia segura") and 10 or 6
        if isEnabledByName("auto_farm", "posicionamento atras") then
            backDistance = 8
        end
        acted = teleportNearModel(target, backDistance, useTween) or acted
        if string.find(item.lower, "ataque", 1, true) or isEnabledByName("auto_farm", "ataque automatico") then
            acted = activateTool(equipAnyTool()) or acted
        end
    else
        if string.find(item.lower, "inteligente", 1, true) then
            acted = runTeleportCycle(true) or acted
        end
    end
    return acted
end

local function runBoss(item)
    local wanted = nil
    if string.find(item.lower, "saber", 1, true) then
        wanted = "saber"
    elseif string.find(item.lower, "don swan", 1, true) then
        wanted = "don swan"
    elseif string.find(item.lower, "cake prince", 1, true) then
        wanted = "cake prince"
    elseif string.find(item.lower, "rip indra", 1, true) then
        wanted = "rip indra"
    elseif string.find(item.lower, "dough king", 1, true) then
        wanted = "dough king"
    elseif string.find(item.lower, "tushita", 1, true) then
        wanted = "tushita"
    end

    local target = findNearestEnemy(520, true, wanted)
    if string.find(item.lower, "spawn detector", 1, true) then
        if target and State.cache.lastBossNotice ~= target.Name then
            State.cache.lastBossNotice = target.Name
            pushEvent("boss spawn: " .. target.Name)
            safeNotify("AutoHub", "Boss detectado: " .. target.Name)
            return true
        end
        return false
    end

    if target then
        local moved = teleportNearModel(target, 11, false)
        local attacked = activateTool(equipAnyTool())
        return moved or attacked
    end

    if string.find(item.lower, "server hop", 1, true) then
        pushEvent("sem boss local, server hop sugerido")
    end
    return false
end

local function runFrutas(item)
    if string.find(item.lower, "buy", 1, true) then
        local ok = runPromptKeywords({ "dealer", "fruit", "shop", "buy" }, 1)
        return ok
    elseif string.find(item.lower, "store", 1, true) then
        local ok = runPromptKeywords({ "store", "inventory", "fruit" }, 1)
        return ok
    elseif string.find(item.lower, "drop", 1, true) then
        local tool = equipToolByKeywords({ "fruit" })
        if tool then
            pcall(function()
                tool.Parent = Workspace
            end)
            return true
        end
        return false
    elseif string.find(item.lower, "eat", 1, true) then
        return activateTool(equipToolByKeywords({ "fruit" }))
    elseif string.find(item.lower, "gacha", 1, true) or string.find(item.lower, "random", 1, true) then
        local ok = runPromptKeywords({ "cousin", "random", "fruit" }, 1)
        return ok
    elseif string.find(item.lower, "sniper", 1, true) then
        local ok = runPromptKeywords({ "stock", "dealer", "fruit" }, 1)
        return ok
    elseif string.find(item.lower, "mastery", 1, true) then
        return activateTool(equipToolByKeywords({ "fruit" }))
    elseif string.find(item.lower, "awakening", 1, true) or string.find(item.lower, "raid", 1, true) then
        local ok = runPromptKeywords({ "raid", "awak", "awaken", "chip" }, 2)
        return ok
    end
    return false
end

local function runCombate(item)
    local acted = false
    if string.find(item.lower, "hitbox", 1, true) then
        local target = findNearestEnemy(85, false, nil)
        if target and target:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                target.HumanoidRootPart.Size = Vector3.new(8, 8, 8)
                target.HumanoidRootPart.Transparency = 0.4
                target.HumanoidRootPart.CanCollide = false
            end)
            acted = true
        end
    end
    if string.find(item.lower, "skill", 1, true) or string.find(item.lower, "combo", 1, true) or string.find(item.lower, "aim", 1, true) then
        acted = sendSkillKeys() or acted
    end

    local target = findNearestEnemy(120, false, nil)
    if target then
        acted = teleportNearModel(target, 6, false) or acted
    end
    acted = activateTool(equipAnyTool()) or acted
    return acted
end

local function runFightingStyle(item)
    local acted = false
    local promptOk = runPromptKeywords({
        "style", "teacher", "trainer", "karate", "claw", "step", "godhuman", "kung", "breath",
    }, 1)
    acted = promptOk or acted
    acted = activateTool(equipAnyTool()) or acted
    return acted
end

local function runEspadas(item)
    local tool = equipToolByKeywords({ "sword", "katana", "blade", "sabre", "scythe", "trident" })
    return activateTool(tool)
end

local function runArmas(item)
    local tool = equipToolByKeywords({ "gun", "rifle", "bow", "musket", "kabucha", "flintlock", "acidum" })
    return activateTool(tool)
end

local function runRaca(item)
    local acted = false
    if containsAny(item.lower, { "mirage", "trial", "gear" }) then
        local obj = findNearestKeywordObject({ "mirage", "trial", "gear", "temple" }, 900)
        if obj then
            pushEvent("race target: " .. obj.Name)
            acted = true
        end
    end
    local promptOk = runPromptKeywords({ "race", "trial", "gear", "awakening", "v2", "v3", "v4" }, 2)
    return acted or promptOk
end

local function runHaki(item)
    local acted = false
    local promptOk = runPromptKeywords({ "haki", "aura", "buso", "ken", "instinct", "observation" }, 1)
    acted = promptOk or acted
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local lower = string.lower(obj.Name)
            if containsAny(lower, { "haki", "aura", "instinct", "buso", "ken" }) then
                local ok = pcall(function()
                    obj:FireServer()
                end)
                acted = ok or acted
                if ok then
                    break
                end
            end
        end
    end
    acted = activateTool(equipAnyTool()) or acted
    return acted
end

local function runTeleport(item)
    if string.find(item.lower, "player", 1, true) then
        local char = findNearestPlayerCharacter(1200)
        if char and char:FindFirstChild("HumanoidRootPart") then
            local root = getRoot()
            if root then
                root.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, 0, 7)
                return true
            end
        end
        return false
    end
    if string.find(item.lower, "boss", 1, true) then
        local boss = findNearestEnemy(1400, true, nil)
        if boss then
            return teleportNearModel(boss, 12, false)
        end
        return false
    end
    if string.find(item.lower, "npc", 1, true) then
        local npc = findNearestKeywordObject({ "npc", "quest", "dealer", "teacher", "trainer" }, 1600)
        if npc then
            local root = getRoot()
            if root then
                local part = npc:IsA("BasePart") and npc or npc:FindFirstChild("HumanoidRootPart")
                if part then
                    root.CFrame = part.CFrame * CFrame.new(0, 0, 6)
                    return true
                end
            end
        end
        return false
    end
    if string.find(item.lower, "island", 1, true) then
        local island = findNearestKeywordObject(IslandKeywords, 3000)
        if island then
            local root = getRoot()
            if root then
                local part = island:IsA("BasePart") and island or island:FindFirstChild("HumanoidRootPart")
                if part then
                    root.CFrame = part.CFrame * CFrame.new(0, 12, 0)
                    return true
                end
            end
        end
        return runTeleportCycle(false)
    end
    if string.find(item.lower, "bring all mobs", 1, true) then
        return bringEnemies(30, true)
    end
    if string.find(item.lower, "bring mob", 1, true) or string.find(item.lower, "magnet", 1, true) then
        return bringEnemies(12, false)
    end
    if string.find(item.lower, "tween teleport", 1, true) then
        return runTeleportCycle(true)
    end
    if string.find(item.lower, "instant teleport", 1, true) then
        return runTeleportCycle(false)
    end
    return runTeleportCycle(false)
end

local function runPlayerMods(item)
    return setHumanoidProps()
end

local function runESP(item)
    return refreshESP()
end

local function runRecursos(item)
    local acted = false
    local keywords = { "drop", "loot", "coin", "chest", "material", "fragment" }
    if string.find(item.lower, "chest", 1, true) then
        keywords = { "chest", "treasure" }
    elseif string.find(item.lower, "fragments", 1, true) then
        keywords = { "fragment", "frag" }
    elseif string.find(item.lower, "materials", 1, true) then
        keywords = { "material", "ore", "scale", "scrap" }
    elseif string.find(item.lower, "money", 1, true) then
        keywords = { "coin", "money", "cash", "reward" }
    elseif string.find(item.lower, "drops", 1, true) then
        keywords = { "drop", "loot", "reward" }
    end
    local collectOk, c = collectPartsByKeywords(keywords, 40, 8)
    acted = collectOk or acted
    if c and c > 0 then
        addAction("collect x" .. tostring(c), c)
    end
    local promptOk = runPromptKeywords({ "collect", "claim", "reward", "loot", "fragment" }, 2)
    acted = promptOk or acted
    return acted
end

local function runServerRuntime(item)
    if string.find(item.lower, "anti afk", 1, true) then
        ensureAntiAfk()
        return true
    end
    if string.find(item.lower, "rejoin", 1, true)
        or string.find(item.lower, "server hop", 1, true)
        or string.find(item.lower, "join low player", 1, true) then
        local ok = pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
        if ok then
            pushEvent("teleport service called")
        end
        return ok
    end
    if string.find(item.lower, "reconnect", 1, true) then
        ensureAntiAfk()
        return true
    end
    return false
end

local function runInteligencia(item)
    if string.find(item.lower, "detect player nearby", 1, true) then
        local nearest = findNearestPlayerCharacter(120)
        if nearest then
            pushEvent("player nearby: " .. nearest.Name)
            return true
        end
        return false
    end
    if string.find(item.lower, "detect admin", 1, true) then
        local admin = detectPossibleAdmin()
        if admin then
            if now() - State.cache.lastAdminNotice > 10 then
                State.cache.lastAdminNotice = now()
                safeNotify("AutoHub", "Possivel staff: " .. admin.Name)
                pushEvent("possible staff: " .. admin.Name)
            end
            return true
        end
        return false
    end
    if string.find(item.lower, "auto leave", 1, true) then
        local admin = detectPossibleAdmin()
        if admin then
            pcall(function()
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end)
            return true
        end
        return false
    end
    if string.find(item.lower, "delay randomizado", 1, true) then
        task.wait(math.random() * 0.2)
        return true
    end
    if string.find(item.lower, "anti report", 1, true) or string.find(item.lower, "anti ban", 1, true) then
        return true
    end
    return false
end

local function runMisc(item)
    if string.find(item.lower, "full bright", 1, true) then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        return true
    end
    if string.find(item.lower, "remove fog", 1, true) then
        Lighting.FogEnd = 9e9
        return true
    end
    if string.find(item.lower, "fps boost", 1, true)
        or string.find(item.lower, "remove effects", 1, true)
        or string.find(item.lower, "low graphics mode", 1, true) then
        applyLowGraphics()
        return true
    end
    if string.find(item.lower, "white screen mode", 1, true) then
        ensureWhiteOverlay(true)
        return true
    end
    return false
end

local function runStats(item)
    local stat = "Melee"
    if string.find(item.lower, "defense", 1, true) then
        stat = "Defense"
    elseif string.find(item.lower, "sword", 1, true) then
        stat = "Sword"
    elseif string.find(item.lower, "gun", 1, true) then
        stat = "Gun"
    elseif string.find(item.lower, "blox fruit", 1, true) then
        stat = "Demon Fruit"
    elseif string.find(item.lower, "auto stats", 1, true) then
        stat = "Melee"
    end
    return tryFireStatsRemote(stat)
end

local function runInterfaceTools(item)
    if string.find(item.lower, "save config", 1, true) then
        local ok = saveConfig()
        if ok then
            safeNotify("AutoHub", "config saved")
        end
        return ok
    end
    if string.find(item.lower, "load config", 1, true) then
        local ok = loadConfig()
        if ok then
            State.flags.requestRenderRows = true
            safeNotify("AutoHub", "config loaded")
        end
        return ok
    end
    if string.find(item.lower, "keybind", 1, true) then
        return true
    end
    return false
end

local function runSystemCore(item)
    if string.find(item.lower, "config save", 1, true) then
        return saveConfig()
    end
    if string.find(item.lower, "config load", 1, true) then
        local ok = loadConfig()
        if ok then
            State.flags.requestRenderRows = true
        end
        return ok
    end
    if string.find(item.lower, "webhook", 1, true) then
        return sendWebhookBatch()
    end
    if string.find(item.lower, "auto update", 1, true) then
        pushEvent("auto update check placeholder")
        return true
    end
    if string.find(item.lower, "key system", 1, true) or string.find(item.lower, "script hub", 1, true) then
        return true
    end
    return false
end

local function runAdvanced(item)
    local keywords = {}
    if string.find(item.lower, "sea event", 1, true) then
        keywords = { "sea event", "ship raid", "sea" }
    elseif string.find(item.lower, "leviathan", 1, true) then
        keywords = { "leviathan" }
    elseif string.find(item.lower, "ship raid", 1, true) then
        keywords = { "ship raid", "ship" }
    elseif string.find(item.lower, "haunted", 1, true) then
        keywords = { "haunted", "castle" }
    elseif string.find(item.lower, "trial puzzle", 1, true) then
        keywords = { "trial", "puzzle" }
    elseif string.find(item.lower, "temple", 1, true) then
        keywords = { "temple" }
    elseif string.find(item.lower, "gear", 1, true) then
        keywords = { "gear", "blue gear" }
    elseif string.find(item.lower, "mirage", 1, true) then
        keywords = { "mirage" }
    else
        keywords = { "event" }
    end

    local target = findNearestKeywordObject(keywords, 1800)
    if target then
        pushEvent(item.name .. ": " .. target.Name)
        if target:IsA("Model") and target:FindFirstChild("HumanoidRootPart") then
            teleportNearModel(target, 14, false)
        elseif target:IsA("BasePart") then
            local root = getRoot()
            if root then
                root.CFrame = target.CFrame + Vector3.new(0, 10, 0)
            end
        end
        return true
    end

    local promptOk = runPromptKeywords(keywords, 1)
    return promptOk
end

local CategoryHandlers = {
    auto_farm = runAutoFarm,
    boss = runBoss,
    frutas = runFrutas,
    combate = runCombate,
    fighting_style = runFightingStyle,
    espadas = runEspadas,
    armas = runArmas,
    raca = runRaca,
    haki = runHaki,
    teleport = runTeleport,
    player_mods = runPlayerMods,
    esp_visual = runESP,
    recursos = runRecursos,
    server_runtime = runServerRuntime,
    inteligencia = runInteligencia,
    misc = runMisc,
    stats = runStats,
    interface_tools = runInterfaceTools,
    sistema_core = runSystemCore,
    avancadas = runAdvanced,
}

local function shouldAutoDisable(item)
    local n = item.lower
    return string.find(n, "config save", 1, true)
        or string.find(n, "config load", 1, true)
        or string.find(n, "save config", 1, true)
        or string.find(n, "load config", 1, true)
        or string.find(n, "rejoin", 1, true)
        or string.find(n, "join low player", 1, true)
        or string.find(n, "server hop", 1, true)
end

local function runItem(item)
    local handler = CategoryHandlers[item.categoryId]
    if not handler then
        return false
    end
    local acted = handler(item)
    if acted then
        addAction(item.name, 1)
    end
    return acted
end

local function corner(target, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
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
    local activeInput

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startPos = frame.Position
            startInput = input.Position
            activeInput = input
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == activeInput then
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

local function setCategoryButtonVisual(activeId)
    for catId, btn in pairs(State.categoryButtons) do
        btn.BackgroundColor3 = (catId == activeId) and Theme.rowActive or Theme.panel2
    end
end

local function updateRowVisual(itemId)
    local row = State.visibleRows[itemId]
    if not row then
        return
    end
    local enabled = State.toggles[itemId] == true
    row.toggle.Text = enabled and "ON" or "OFF"
    row.toggle.BackgroundColor3 = enabled and Theme.accent or Theme.off
    row.dot.BackgroundColor3 = enabled and Theme.ok or Theme.off
end

local renderRows

local function setCategory(catId)
    if not State.categoryLookup[catId] then
        return
    end
    State.config.selectedCategory = catId
    setCategoryButtonVisual(catId)
    if State.ui.categoryTitle then
        local cat = State.categoryLookup[catId]
        State.ui.categoryTitle.Text = cat.label
    end
    if renderRows then
        renderRows()
    end
end

local function buildUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = GUI_NAME
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = PlayerGui
    State.ui.gui = gui

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 620, 0, 350)
    main.Position = UDim2.new(0.5, -310, 0.5, -175)
    main.BackgroundColor3 = Theme.bg
    main.Parent = gui
    corner(main, 10)
    stroke(main)
    State.ui.main = main

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 12, 22)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(6, 9, 17)),
    })
    grad.Rotation = 90
    grad.Parent = main

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundTransparency = 1
    header.Parent = main

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 340, 0, 18)
    title.Position = UDim2.new(0, 8, 0, 6)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.TextColor3 = Theme.text
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "AutoHub Organized " .. VERSION
    title.Parent = header

    local hint = Instance.new("TextLabel")
    hint.Size = UDim2.new(0, 180, 0, 14)
    hint.Position = UDim2.new(1, -210, 0, 8)
    hint.BackgroundTransparency = 1
    hint.Font = Enum.Font.Gotham
    hint.TextSize = 10
    hint.TextColor3 = Theme.muted
    hint.Text = "END hide/show"
    hint.Parent = header

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 24, 0, 20)
    close.Position = UDim2.new(1, -30, 0, 5)
    close.Text = "X"
    close.Font = Enum.Font.GothamBold
    close.TextSize = 11
    close.TextColor3 = Theme.text
    close.BackgroundColor3 = Color3.fromRGB(45, 26, 36)
    close.Parent = header
    corner(close, 6)
    stroke(close)

    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 172, 1, -36)
    sidebar.Position = UDim2.new(0, 6, 0, 30)
    sidebar.BackgroundColor3 = Theme.panel
    sidebar.Parent = main
    corner(sidebar, 8)
    stroke(sidebar)

    local categoryTitle = Instance.new("TextLabel")
    categoryTitle.Size = UDim2.new(1, -12, 0, 16)
    categoryTitle.Position = UDim2.new(0, 6, 0, 6)
    categoryTitle.BackgroundTransparency = 1
    categoryTitle.Font = Enum.Font.GothamBold
    categoryTitle.TextSize = 11
    categoryTitle.TextColor3 = Theme.text
    categoryTitle.TextXAlignment = Enum.TextXAlignment.Left
    categoryTitle.Text = "Categorias"
    categoryTitle.Parent = sidebar

    local catScroll = Instance.new("ScrollingFrame")
    catScroll.Size = UDim2.new(1, -8, 1, -28)
    catScroll.Position = UDim2.new(0, 4, 0, 24)
    catScroll.BackgroundTransparency = 1
    catScroll.ScrollBarThickness = 4
    catScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    catScroll.Parent = sidebar
    State.ui.categoryScroll = catScroll

    local catLayout = Instance.new("UIListLayout")
    catLayout.Padding = UDim.new(0, 4)
    catLayout.Parent = catScroll
    catLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        catScroll.CanvasSize = UDim2.new(0, 0, 0, catLayout.AbsoluteContentSize.Y + 4)
    end)

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -184, 1, -36)
    content.Position = UDim2.new(0, 180, 0, 30)
    content.BackgroundColor3 = Theme.panel
    content.Parent = main
    corner(content, 8)
    stroke(content)

    local contentHeader = Instance.new("TextLabel")
    contentHeader.Size = UDim2.new(0, 150, 0, 16)
    contentHeader.Position = UDim2.new(0, 8, 0, 6)
    contentHeader.BackgroundTransparency = 1
    contentHeader.Font = Enum.Font.GothamBold
    contentHeader.TextSize = 12
    contentHeader.TextColor3 = Theme.text
    contentHeader.TextXAlignment = Enum.TextXAlignment.Left
    contentHeader.Parent = content
    State.ui.categoryTitle = contentHeader

    local countLabel = Instance.new("TextLabel")
    countLabel.Size = UDim2.new(0, 120, 0, 14)
    countLabel.Position = UDim2.new(1, -128, 0, 8)
    countLabel.BackgroundTransparency = 1
    countLabel.Font = Enum.Font.Gotham
    countLabel.TextSize = 10
    countLabel.TextColor3 = Theme.muted
    countLabel.TextXAlignment = Enum.TextXAlignment.Right
    countLabel.Parent = content
    State.ui.countLabel = countLabel

    local search = Instance.new("TextBox")
    search.Size = UDim2.new(0, 116, 0, 20)
    search.Position = UDim2.new(0, 8, 0, 24)
    search.PlaceholderText = "Search function"
    search.Text = State.config.searchText
    search.Font = Enum.Font.Gotham
    search.TextSize = 10
    search.TextColor3 = Theme.text
    search.PlaceholderColor3 = Theme.muted
    search.BackgroundColor3 = Theme.panel2
    search.Parent = content
    corner(search, 5)
    stroke(search)
    State.ui.search = search

    local webhook = Instance.new("TextBox")
    webhook.Size = UDim2.new(0, 150, 0, 20)
    webhook.Position = UDim2.new(0, 128, 0, 24)
    webhook.PlaceholderText = "Webhook URL"
    webhook.Text = State.config.webhookUrl
    webhook.Font = Enum.Font.Gotham
    webhook.TextSize = 10
    webhook.TextColor3 = Theme.text
    webhook.PlaceholderColor3 = Theme.muted
    webhook.BackgroundColor3 = Theme.panel2
    webhook.Parent = content
    corner(webhook, 5)
    stroke(webhook)
    State.ui.webhook = webhook

    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0, 40, 0, 20)
    saveBtn.Position = UDim2.new(0, 284, 0, 24)
    saveBtn.Text = "Save"
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = 9
    saveBtn.TextColor3 = Theme.text
    saveBtn.BackgroundColor3 = Theme.panel2
    saveBtn.Parent = content
    corner(saveBtn, 5)
    stroke(saveBtn)

    local loadBtn = Instance.new("TextButton")
    loadBtn.Size = UDim2.new(0, 40, 0, 20)
    loadBtn.Position = UDim2.new(0, 328, 0, 24)
    loadBtn.Text = "Load"
    loadBtn.Font = Enum.Font.GothamBold
    loadBtn.TextSize = 9
    loadBtn.TextColor3 = Theme.text
    loadBtn.BackgroundColor3 = Theme.panel2
    loadBtn.Parent = content
    corner(loadBtn, 5)
    stroke(loadBtn)

    local onBtn = Instance.new("TextButton")
    onBtn.Size = UDim2.new(0, 24, 0, 20)
    onBtn.Position = UDim2.new(0, 372, 0, 24)
    onBtn.Text = "+"
    onBtn.Font = Enum.Font.GothamBold
    onBtn.TextSize = 11
    onBtn.TextColor3 = Theme.text
    onBtn.BackgroundColor3 = Theme.ok
    onBtn.Parent = content
    corner(onBtn, 5)
    stroke(onBtn)

    local offBtn = Instance.new("TextButton")
    offBtn.Size = UDim2.new(0, 24, 0, 20)
    offBtn.Position = UDim2.new(0, 400, 0, 24)
    offBtn.Text = "-"
    offBtn.Font = Enum.Font.GothamBold
    offBtn.TextSize = 11
    offBtn.TextColor3 = Theme.text
    offBtn.BackgroundColor3 = Theme.warn
    offBtn.Parent = content
    corner(offBtn, 5)
    stroke(offBtn)

    local list = Instance.new("ScrollingFrame")
    list.Size = UDim2.new(1, -8, 1, -76)
    list.Position = UDim2.new(0, 4, 0, 48)
    list.CanvasSize = UDim2.new(0, 0, 0, 0)
    list.BackgroundTransparency = 1
    list.ScrollBarThickness = 4
    list.Parent = content
    State.ui.list = list

    local footer = Instance.new("TextLabel")
    footer.Size = UDim2.new(1, -12, 0, 14)
    footer.Position = UDim2.new(0, 8, 1, -18)
    footer.BackgroundTransparency = 1
    footer.Font = Enum.Font.Gotham
    footer.TextSize = 10
    footer.TextColor3 = Theme.muted
    footer.TextXAlignment = Enum.TextXAlignment.Left
    footer.Text = "Status: booting..."
    footer.Parent = content
    State.ui.footer = footer

    local function createCategoryButton(cat)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -8, 0, 22)
        btn.BackgroundColor3 = Theme.panel2
        btn.Text = cat.label .. " (" .. tostring(#cat.items) .. ")"
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 10
        btn.TextColor3 = Theme.text
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.AutoButtonColor = false
        btn.Parent = catScroll
        corner(btn, 5)
        stroke(btn, Theme.border)

        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 8)
        pad.Parent = btn

        btn.MouseButton1Click:Connect(function()
            setCategory(cat.id)
        end)
        State.categoryButtons[cat.id] = btn
    end

    for _, cat in ipairs(CategoryDefs) do
        createCategoryButton(cat)
    end

    function renderRows()
        for _, row in pairs(State.visibleRows) do
            if row.frame and row.frame.Parent then
                row.frame:Destroy()
            end
        end
        State.visibleRows = {}

        local catId = State.config.selectedCategory
        local ids = State.categoryItems[catId] or {}
        local filter = string.lower(trim(State.config.searchText))
        local y = 0
        local visibleCount = 0

        for _, itemId in ipairs(ids) do
            local item = State.items[itemId]
            if item then
                if filter == "" or string.find(item.lower, filter, 1, true) then
                    visibleCount = visibleCount + 1
                    local row = Instance.new("Frame")
                    row.Size = UDim2.new(1, -8, 0, 24)
                    row.Position = UDim2.new(0, 4, 0, y)
                    row.BackgroundColor3 = Theme.row
                    row.Parent = list
                    corner(row, 5)
                    stroke(row, Color3.fromRGB(28, 40, 70))

                    local dot = Instance.new("Frame")
                    dot.Size = UDim2.new(0, 7, 0, 7)
                    dot.Position = UDim2.new(0, 7, 0.5, -3)
                    dot.BackgroundColor3 = Theme.off
                    dot.Parent = row
                    corner(dot, 4)

                    local name = Instance.new("TextLabel")
                    name.Size = UDim2.new(1, -98, 1, 0)
                    name.Position = UDim2.new(0, 18, 0, 0)
                    name.BackgroundTransparency = 1
                    name.Font = Enum.Font.Gotham
                    name.TextSize = 10
                    name.TextColor3 = Theme.text
                    name.TextXAlignment = Enum.TextXAlignment.Left
                    name.Text = item.name
                    name.Parent = row

                    local toggle = Instance.new("TextButton")
                    toggle.Size = UDim2.new(0, 48, 0, 18)
                    toggle.Position = UDim2.new(1, -54, 0.5, -9)
                    toggle.Font = Enum.Font.GothamBold
                    toggle.TextSize = 9
                    toggle.TextColor3 = Theme.text
                    toggle.Parent = row
                    corner(toggle, 5)

                    toggle.MouseButton1Click:Connect(function()
                        State.toggles[itemId] = not State.toggles[itemId]
                        State.nextRun[itemId] = 0
                        updateRowVisual(itemId)
                        pushEvent(item.name .. " -> " .. (State.toggles[itemId] and "ON" or "OFF"))
                    end)

                    State.visibleRows[itemId] = {
                        frame = row,
                        toggle = toggle,
                        dot = dot,
                    }
                    updateRowVisual(itemId)

                    y = y + 26
                end
            end
        end

        list.CanvasSize = UDim2.new(0, 0, 0, y + 2)

        local total = #ids
        local enabled = getCategoryEnabledCount(catId)
        countLabel.Text = tostring(enabled) .. "/" .. tostring(total) .. " ON"
        contentHeader.Text = State.categoryLookup[catId].label .. " [" .. tostring(visibleCount) .. "]"
        setCategoryButtonVisual(catId)
    end

    search:GetPropertyChangedSignal("Text"):Connect(function()
        State.config.searchText = search.Text
        renderRows()
    end)

    webhook.FocusLost:Connect(function()
        State.config.webhookUrl = trim(webhook.Text)
    end)

    saveBtn.MouseButton1Click:Connect(function()
        State.config.webhookUrl = trim(webhook.Text)
        if saveConfig() then
            safeNotify("AutoHub", "Config saved")
        else
            safeNotify("AutoHub", "Save failed")
        end
    end)

    loadBtn.MouseButton1Click:Connect(function()
        if loadConfig() then
            webhook.Text = State.config.webhookUrl
            search.Text = State.config.searchText
            renderRows()
            safeNotify("AutoHub", "Config loaded")
        else
            safeNotify("AutoHub", "No config found")
        end
    end)

    onBtn.MouseButton1Click:Connect(function()
        local catId = State.config.selectedCategory
        for _, itemId in ipairs(State.categoryItems[catId]) do
            State.toggles[itemId] = true
            State.nextRun[itemId] = 0
        end
        renderRows()
    end)

    offBtn.MouseButton1Click:Connect(function()
        local catId = State.config.selectedCategory
        for _, itemId in ipairs(State.categoryItems[catId]) do
            State.toggles[itemId] = false
        end
        renderRows()
    end)

    close.MouseButton1Click:Connect(function()
        State.running = false
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
    setCategory(State.config.selectedCategory)
end

local function refreshStatus()
    local uptime = math.floor(now() - State.startedAt)
    if State.ui.footer then
        State.ui.footer.Text = "Uptime: " .. tostring(uptime)
            .. "s | Active: " .. tostring(State.activeCount)
            .. " | Actions: " .. tostring(State.stats.actions)
            .. " | Errors: " .. tostring(State.stats.errors)
            .. " | Last: " .. tostring(State.stats.last)
    end
    if not isEnabledByName("misc", "white screen mode") then
        ensureWhiteOverlay(false)
    end
end

local function cleanup()
    State.running = false

    for _, conn in pairs(State.connections) do
        if conn then
            pcall(function()
                conn:Disconnect()
            end)
        end
    end

    clearHighlights()
    ensureWhiteOverlay(false)

    if State.ui.gui then
        pcall(function()
            State.ui.gui:Destroy()
        end)
    end

    pcall(function()
        getgenv().AutoHubV5Loaded = nil
    end)
end

local function startScheduler()
    task.spawn(function()
        while State.running do
            local current = now()
            local active = 0

            for itemId, item in pairs(State.items) do
                if State.toggles[itemId] then
                    active = active + 1
                    if current >= (State.nextRun[itemId] or 0) then
                        State.nextRun[itemId] = current + (item.interval or 1)
                        local ok, acted = pcall(function()
                            return runItem(item)
                        end)
                        if not ok then
                            addError("err: " .. item.name)
                        else
                            if acted then
                                State.stats.last = item.name
                            end
                            if shouldAutoDisable(item) then
                                State.toggles[itemId] = false
                                updateRowVisual(itemId)
                            end
                        end
                    end
                end
            end

            State.activeCount = active

            if State.flags.requestRenderRows and renderRows then
                State.flags.requestRenderRows = false
                renderRows()
            end

            task.wait(0.1)
        end
    end)
end

local function startStatusLoop()
    task.spawn(function()
        while State.running do
            refreshStatus()
            task.wait(0.25)
        end
    end)
end

local function startAutosave()
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
    buildUI()
    startScheduler()
    startStatusLoop()
    startAutosave()
    ensureInfiniteJump()

    State.connections.heartbeat = RunService.Heartbeat:Connect(function()
        if not State.running then
            return
        end
        if isEnabledByName("server_runtime", "anti afk") then
            ensureAntiAfk()
        end
    end)

    safeNotify("AutoHub", "Organized UI loaded (" .. VERSION .. ")")
end

local ok, err = pcall(boot)
if not ok then
    warn("[AutoHub] boot error: " .. tostring(err))
    cleanup()
end

task.spawn(function()
    while State.running do
        task.wait(0.2)
    end
    cleanup()
end)

