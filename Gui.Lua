--[[
    AutoHub Organized UI (V6)
    Compact + draggable + END to hide/show
]]

pcall(function()
    local player = game:GetService("Players").LocalPlayer
    if not player then
        return
    end
    local pg = player:FindFirstChild("PlayerGui")
    if not pg then
        return
    end
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
    getgenv().AutoHubV6Loaded = nil
end)

if getgenv().AutoHubV6Loaded then
    return
end
getgenv().AutoHubV6Loaded = true

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

local hasVIM, VirtualInputManager = pcall(function()
    return game:GetService("VirtualInputManager")
end)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local VERSION = "V6-2026-04-26"
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
            "Auto Quest (aceitar/completar/entregar)",
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
        interval = 1.8,
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
        interval = 1.1,
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
        interval = 2.1,
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
        interval = 1.0,
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
        interval = 1.8,
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
        interval = 0.22,
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
        interval = 0.9,
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
        interval = 0.6,
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
        interval = 3.0,
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
        interval = 2.8,
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
        interval = 2.0,
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
        interval = 2.5,
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
        interval = 4.0,
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
        interval = 2.2,
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

local BOSS_KEYS = {
    "boss", "elite", "saber", "don swan", "cake prince", "rip indra", "dough king",
    "tushita", "soul reaper", "hydra", "elder turtle", "trex", "t-rex", "leviathan",
}

local LOOT_KEYS = {
    "chest", "drop", "loot", "coin", "reward", "fragment", "material", "ore", "scale", "scrap", "fruit",
}

local QUEST_KEYS = {
    "quest", "mission", "giver", "npc",
}

local NPC_KEYS = {
    "dealer", "quest", "trainer", "teacher", "npc", "blacksmith", "awak", "shop",
}

local ISLAND_KEYS = {
    "starter", "jungle", "pirate", "desert", "frozen", "marine", "sky", "prison", "colosseum",
    "magma", "underwater", "fountain", "kingdom", "green zone", "graveyard", "snow",
    "hot and cold", "cursed", "ice castle", "forgotten", "port town", "hydra",
    "great tree", "floating turtle", "haunted castle", "sea of treats", "mirage",
}

local State = {
    running = true,
    startedAt = os.clock(),
    items = {},
    itemOrder = {},
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
    cooldowns = {},
    cache = {
        lastBossSeen = "",
        lastAdminSeen = "",
    },
    stats = {
        actions = 0,
        errors = 0,
        last = "idle",
    },
    ui = {},
    conns = {},
    perception = {
        enemies = {},
        bosses = {},
        prompts = {},
        loot = {},
        fruits = {},
        islands = {},
        players = {},
        npcs = {},
        lastScan = 0,
    },
    config = {
        selectedCategory = "auto_farm",
        searchText = "",
        webhookUrl = "",
        mobKeyword = "",
        bossKeyword = "",
        fruitKeyword = "",
        autosaveSeconds = 20,
        threatDistance = 140,
        teleportPoints = {
            CFrame.new(0, 15, 0),
            CFrame.new(80, 15, 0),
            CFrame.new(-80, 15, 0),
        },
    },
}

local function trim(s)
    return (string.gsub(string.gsub(s or "", "^%s+", ""), "%s+$", ""))
end

local function now()
    return os.clock()
end

local function slugify(text)
    local s = string.lower(text)
    s = string.gsub(s, "[^%w]+", "_")
    s = string.gsub(s, "_+", "_")
    s = string.gsub(s, "^_", "")
    s = string.gsub(s, "_$", "")
    return s
end

local function resolveInterval(categoryId, lowerName, defaultInterval)
    local interval = defaultInterval
    if categoryId == "combate" then
        interval = 0.14
    elseif categoryId == "player_mods" then
        interval = 0.12
    elseif categoryId == "esp_visual" then
        interval = 0.55
    elseif categoryId == "server_runtime" then
        interval = 8
    elseif categoryId == "sistema_core" then
        interval = 6
    end
    if string.find(lowerName, "spawn detector", 1, true) then
        interval = 1.2
    elseif string.find(lowerName, "server hop", 1, true) or string.find(lowerName, "rejoin", 1, true) then
        interval = 12
    elseif string.find(lowerName, "anti afk", 1, true) then
        interval = 4
    elseif string.find(lowerName, "config save", 1, true) or string.find(lowerName, "save config", 1, true) then
        interval = 30
    elseif string.find(lowerName, "config load", 1, true) or string.find(lowerName, "load config", 1, true) then
        interval = 30
    end
    return interval
end

for _, cat in ipairs(CategoryDefs) do
    State.categoryLookup[cat.id] = cat
    table.insert(State.categoryOrder, cat.id)
    State.categoryItems[cat.id] = {}
    for idx, name in ipairs(cat.items) do
        local id = cat.id .. ":" .. slugify(name) .. ":" .. tostring(idx)
        local lower = string.lower(name)
        local interval = resolveInterval(cat.id, lower, cat.interval)
        local item = {
            id = id,
            name = name,
            lower = lower,
            categoryId = cat.id,
            interval = interval,
        }
        State.items[id] = item
        table.insert(State.itemOrder, id)
        table.insert(State.categoryItems[cat.id], id)
        State.toggles[id] = false
        State.nextRun[id] = 0
    end
end

local function containsAny(text, keys)
    local lower = string.lower(text or "")
    for _, key in ipairs(keys) do
        if string.find(lower, key, 1, true) then
            return true
        end
    end
    return false
end

local function hasWord(item, phrase)
    return string.find(item.lower, string.lower(phrase), 1, true) ~= nil
end

local function safeNotify(title, text)
    if now() - State.lastNotifyAt < 1.1 then
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

local function pushEvent(message)
    State.stats.last = message
    table.insert(State.eventQueue, {
        t = os.time(),
        m = message,
    })
    if #State.eventQueue > 150 then
        table.remove(State.eventQueue, 1)
    end
end

local function addAction(message, count)
    State.stats.actions = State.stats.actions + (count or 1)
    State.stats.last = message
end

local function addError(message)
    State.stats.errors = State.stats.errors + 1
    State.stats.last = message
end

local function cooldownReady(key, seconds)
    local t = State.cooldowns[key] or 0
    if now() - t >= seconds then
        State.cooldowns[key] = now()
        return true
    end
    return false
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
    local hrp = model:FindFirstChild("HumanoidRootPart")
    return hum ~= nil and hrp ~= nil and hum.Health > 0
end

local function distanceToPos(pos)
    local root = getRoot()
    if not root then
        return math.huge
    end
    return (root.Position - pos).Magnitude
end

local function getObjPosition(obj)
    if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
        return obj.HumanoidRootPart.Position
    end
    if obj:IsA("BasePart") then
        return obj.Position
    end
    return nil
end

local function getNearest(list, maxDist, predicate)
    local root = getRoot()
    if not root then
        return nil
    end
    local bestDist = maxDist or math.huge
    local best = nil
    for _, obj in ipairs(list) do
        if obj and obj.Parent and (not predicate or predicate(obj)) then
            local pos = getObjPosition(obj)
            if pos then
                local d = (root.Position - pos).Magnitude
                if d < bestDist then
                    bestDist = d
                    best = obj
                end
            end
        end
    end
    return best
end

local function moveToCFrame(cf, tween)
    local root = getRoot()
    if not root then
        return false
    end
    local ok = pcall(function()
        if tween then
            TweenService:Create(root, TweenInfo.new(0.18, Enum.EasingStyle.Linear), { CFrame = cf }):Play()
        else
            root.CFrame = cf
        end
    end)
    return ok
end

local function moveNearModel(model, distance, tween, behind)
    if not model or not model:FindFirstChild("HumanoidRootPart") then
        return false
    end
    local targetCF = model.HumanoidRootPart.CFrame
    local dist = distance or 6
    local offset = CFrame.new(0, 0, dist)
    if behind then
        offset = CFrame.new(0, 0, -dist)
    end
    return moveToCFrame(targetCF * offset, tween)
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
    local t = backpack:FindFirstChildOfClass("Tool")
    if t then
        pcall(function()
            t.Parent = char
        end)
    end
    return t
end

local function normalizeKeywordList(list)
    local out = {}
    for _, value in ipairs(list) do
        local text = trim(tostring(value or ""))
        if text ~= "" then
            table.insert(out, string.lower(text))
        end
    end
    return out
end

local function equipToolByKeywords(keys)
    local wanted = normalizeKeywordList(keys or {})
    local char = getCharacter()
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    local containers = {}
    if char then
        table.insert(containers, char)
    end
    if backpack then
        table.insert(containers, backpack)
    end

    local fallback = nil
    for _, cont in ipairs(containers) do
        for _, obj in ipairs(cont:GetChildren()) do
            if obj:IsA("Tool") then
                local lower = string.lower(obj.Name)
                fallback = fallback or obj
                local good = (#wanted == 0)
                if not good then
                    for _, k in ipairs(wanted) do
                        if string.find(lower, k, 1, true) then
                            good = true
                            break
                        end
                    end
                end
                if good then
                    if char and obj.Parent ~= char then
                        pcall(function()
                            obj.Parent = char
                        end)
                    end
                    return obj
                end
            end
        end
    end

    if fallback and char and fallback.Parent ~= char then
        pcall(function()
            fallback.Parent = char
        end)
    end
    return fallback
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

local function pressSkillKeys()
    if not hasVIM or not VirtualInputManager then
        return false
    end
    local keys = {
        Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V, Enum.KeyCode.F,
    }
    for _, key in ipairs(keys) do
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, key, false, game)
            VirtualInputManager:SendKeyEvent(false, key, false, game)
        end)
    end
    return true
end

local function getPromptText(prompt)
    local text = string.lower(prompt.Name or "")
    text = text .. " " .. string.lower(tostring(prompt.ObjectText))
    text = text .. " " .. string.lower(tostring(prompt.ActionText))
    if prompt.Parent then
        text = text .. " " .. string.lower(prompt.Parent.Name)
    end
    return text
end

local function tryPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then
        return false
    end
    local parentPart = prompt.Parent
    while parentPart and not parentPart:IsA("BasePart") do
        parentPart = parentPart.Parent
    end
    if not parentPart then
        return false
    end
    if distanceToPos(parentPart.Position) > (prompt.MaxActivationDistance + 7) then
        return false
    end
    local ok = pcall(function()
        fireproximityprompt(prompt)
    end)
    return ok
end

local function runPromptByKeywords(keys, maxCount)
    local count = 0
    local limit = maxCount or 2
    for _, prompt in ipairs(State.perception.prompts) do
        if prompt and prompt.Parent then
            local pText = getPromptText(prompt)
            if containsAny(pText, keys) then
                if tryPrompt(prompt) then
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

local function collectByKeywords(keys, maxDistance, maxCount)
    local count = 0
    local distLimit = maxDistance or 35
    local limit = maxCount or 10
    for _, part in ipairs(State.perception.loot) do
        if part and part.Parent then
            local lower = string.lower(part.Name)
            if containsAny(lower, keys) and distanceToPos(part.Position) <= distLimit then
                if touchPart(part) then
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

local function runTeleportCycle(useTween)
    local points = State.config.teleportPoints
    if #points == 0 then
        return false
    end
    State.teleportIndex = (State.teleportIndex % #points) + 1
    return moveToCFrame(points[State.teleportIndex], useTween)
end

local function ensureAntiAfk()
    if State.conns.antiAfk then
        return
    end
    State.conns.antiAfk = LocalPlayer.Idled:Connect(function()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
end

local function ensureInfiniteJump()
    if State.conns.infJump then
        return
    end
    State.conns.infJump = UserInputService.JumpRequest:Connect(function()
        if not State.running then
            return
        end
        if State.flagsInfJump then
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
        g.Name = GUI_NAME .. "_WhiteOverlay"
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
    local nh = Instance.new("Highlight")
    nh.Name = "AH_ESP"
    nh.Adornee = adornee
    nh.FillColor = color
    nh.OutlineColor = color
    nh.FillTransparency = 0.78
    nh.OutlineTransparency = 0.18
    nh.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    nh:SetAttribute("seen", true)
    nh.Parent = Workspace
    State.highlights[key] = nh
end

local function categoryPhraseEnabled(categoryId, phrase)
    local p = string.lower(phrase)
    for _, id in ipairs(State.categoryItems[categoryId]) do
        if State.toggles[id] then
            local item = State.items[id]
            if item and string.find(item.lower, p, 1, true) then
                return true
            end
        end
    end
    return false
end

local function refreshESPVisuals()
    local showPlayer = categoryPhraseEnabled("esp_visual", "player esp")
    local showEnemy = categoryPhraseEnabled("esp_visual", "enemy esp")
    local showBoss = categoryPhraseEnabled("esp_visual", "boss esp")
    local showChest = categoryPhraseEnabled("esp_visual", "chest esp")
    local showFruit = categoryPhraseEnabled("esp_visual", "fruit esp")
    local showNpc = categoryPhraseEnabled("esp_visual", "npc esp")
    local showIsland = categoryPhraseEnabled("esp_visual", "island esp")
    local showAny = showPlayer or showEnemy or showBoss or showChest or showFruit or showNpc or showIsland

    if not showAny then
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

    local budget = 0
    if showEnemy or showBoss then
        for _, model in ipairs(State.perception.enemies) do
            if budget > 120 then
                break
            end
            local lower = string.lower(model.Name)
            if showBoss and containsAny(lower, BOSS_KEYS) then
                upsertHighlight("B:" .. tostring(model), model, Color3.fromRGB(255, 109, 109))
                budget = budget + 1
            elseif showEnemy and not containsAny(lower, BOSS_KEYS) then
                upsertHighlight("E:" .. tostring(model), model, Color3.fromRGB(255, 205, 90))
                budget = budget + 1
            end
        end
    end

    if showChest or showFruit then
        for _, part in ipairs(State.perception.loot) do
            if budget > 200 then
                break
            end
            local lower = string.lower(part.Name)
            if showChest and containsAny(lower, { "chest", "treasure" }) then
                upsertHighlight("C:" .. tostring(part), part, Color3.fromRGB(255, 225, 120))
                budget = budget + 1
            elseif showFruit and containsAny(lower, { "fruit", "blox" }) then
                upsertHighlight("F:" .. tostring(part), part, Color3.fromRGB(218, 132, 255))
                budget = budget + 1
            end
        end
    end

    if showNpc then
        for _, npc in ipairs(State.perception.npcs) do
            if budget > 260 then
                break
            end
            upsertHighlight("N:" .. tostring(npc), npc, Color3.fromRGB(153, 239, 171))
            budget = budget + 1
        end
    end

    if showIsland then
        for _, island in ipairs(State.perception.islands) do
            if budget > 300 then
                break
            end
            upsertHighlight("I:" .. tostring(island), island, Color3.fromRGB(122, 226, 255))
            budget = budget + 1
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
                title = "Event Feed",
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
    local data = {
        toggles = State.toggles,
        config = {
            selectedCategory = State.config.selectedCategory,
            searchText = State.config.searchText,
            webhookUrl = State.config.webhookUrl,
            mobKeyword = State.config.mobKeyword,
            bossKeyword = State.config.bossKeyword,
            fruitKeyword = State.config.fruitKeyword,
            autosaveSeconds = State.config.autosaveSeconds,
            threatDistance = State.config.threatDistance,
            teleportPoints = {},
        },
    }
    for _, cf in ipairs(State.config.teleportPoints) do
        local p = cf.Position
        table.insert(data.config.teleportPoints, { p.X, p.Y, p.Z })
    end
    return data
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
        local c = decoded.config
        if type(c.selectedCategory) == "string" and State.categoryLookup[c.selectedCategory] then
            State.config.selectedCategory = c.selectedCategory
        end
        State.config.searchText = tostring(c.searchText or State.config.searchText)
        State.config.webhookUrl = tostring(c.webhookUrl or State.config.webhookUrl)
        State.config.mobKeyword = tostring(c.mobKeyword or State.config.mobKeyword)
        State.config.bossKeyword = tostring(c.bossKeyword or State.config.bossKeyword)
        State.config.fruitKeyword = tostring(c.fruitKeyword or State.config.fruitKeyword)
        State.config.autosaveSeconds = tonumber(c.autosaveSeconds) or State.config.autosaveSeconds
        State.config.threatDistance = tonumber(c.threatDistance) or State.config.threatDistance
        if type(c.teleportPoints) == "table" and #c.teleportPoints > 0 then
            State.config.teleportPoints = {}
            for _, row in ipairs(c.teleportPoints) do
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

local function refreshPerception()
    local p = State.perception
    p.enemies = {}
    p.bosses = {}
    p.prompts = {}
    p.loot = {}
    p.fruits = {}
    p.islands = {}
    p.players = {}
    p.npcs = {}

    local desc = Workspace:GetDescendants()
    local budget = 0
    for _, obj in ipairs(desc) do
        budget = budget + 1
        if budget > 18000 then
            break
        end

        if obj:IsA("Model") then
            local lower = string.lower(obj.Name)
            if isEnemyModel(obj) then
                table.insert(p.enemies, obj)
                if containsAny(lower, BOSS_KEYS) then
                    table.insert(p.bosses, obj)
                end
            elseif containsAny(lower, NPC_KEYS) then
                table.insert(p.npcs, obj)
            elseif containsAny(lower, ISLAND_KEYS) then
                table.insert(p.islands, obj)
            end
        elseif obj:IsA("ProximityPrompt") then
            table.insert(p.prompts, obj)
        elseif obj:IsA("BasePart") then
            local lower = string.lower(obj.Name)
            if containsAny(lower, LOOT_KEYS) then
                table.insert(p.loot, obj)
            end
            if containsAny(lower, { "fruit", "blox" }) then
                table.insert(p.fruits, obj)
            end
            if containsAny(lower, ISLAND_KEYS) then
                table.insert(p.islands, obj)
            end
        end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(p.players, plr.Character)
        end
    end
    p.lastScan = now()
end

local function nearestEnemy(maxDist, bossOnly, pattern)
    local list = bossOnly and State.perception.bosses or State.perception.enemies
    local needle = pattern and string.lower(pattern) or nil
    return getNearest(list, maxDist or 150, function(model)
        if not model or not model.Parent then
            return false
        end
        if needle and needle ~= "" then
            return string.find(string.lower(model.Name), needle, 1, true) ~= nil
        end
        return true
    end)
end

local function nearestPlayer(maxDist)
    return getNearest(State.perception.players, maxDist or 1500, nil)
end

local function nearestNpcByKeywords(keys, maxDist)
    local lowerKeys = normalizeKeywordList(keys)
    return getNearest(State.perception.npcs, maxDist or 1200, function(model)
        local lower = string.lower(model.Name)
        return containsAny(lower, lowerKeys)
    end)
end

local function nearestIsland(maxDist)
    return getNearest(State.perception.islands, maxDist or 3000, nil)
end

local function bringEnemies(all)
    local root = getRoot()
    if not root then
        return false
    end
    local count = 0
    for _, enemy in ipairs(State.perception.enemies) do
        if enemy and enemy.Parent and enemy:FindFirstChild("HumanoidRootPart") then
            local dist = (root.Position - enemy.HumanoidRootPart.Position).Magnitude
            if dist <= 260 then
                pcall(function()
                    local offset = Vector3.new((count % 6) * 2, 0, math.floor(count / 6) * 2)
                    enemy.HumanoidRootPart.CFrame = root.CFrame * CFrame.new(offset)
                end)
                count = count + 1
                if not all and count >= 1 then
                    break
                end
                if count >= 24 then
                    break
                end
            end
        end
    end
    return count > 0
end

local function detectPossibleAdmin()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local lower = string.lower(plr.Name .. " " .. plr.DisplayName)
            if containsAny(lower, { "admin", "mod", "staff", "owner", "developer" }) then
                return plr
            end
        end
    end
    return nil
end

local function applyHumanoidMods()
    local hum = getHumanoid()
    local root = getRoot()
    if not hum then
        return false
    end
    local changed = false

    if categoryPhraseEnabled("player_mods", "walk speed") then
        if hum.WalkSpeed < 32 then
            hum.WalkSpeed = 32
            changed = true
        end
    end
    if categoryPhraseEnabled("player_mods", "dash boost") then
        if hum.WalkSpeed < 44 then
            hum.WalkSpeed = 44
            changed = true
        end
    end
    if categoryPhraseEnabled("player_mods", "jump power") then
        hum.UseJumpPower = true
        if hum.JumpPower < 85 then
            hum.JumpPower = 85
            changed = true
        end
    end
    if categoryPhraseEnabled("player_mods", "noclip") then
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
    if categoryPhraseEnabled("player_mods", "anti stun") then
        hum.PlatformStand = false
        hum.Sit = false
        changed = true
    end
    if categoryPhraseEnabled("player_mods", "no knockback") and root then
        root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
        changed = true
    end
    if categoryPhraseEnabled("player_mods", "fly") and root then
        root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 24, root.AssemblyLinearVelocity.Z)
        changed = true
    end
    State.flagsInfJump = categoryPhraseEnabled("player_mods", "infinite jump")
    return changed
end

local function applyLowGraphics()
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.Brightness = 1
        Lighting.FogEnd = 9e9
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

local function tryStatsRemote(statName)
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local lower = string.lower(obj.Name)
            if containsAny(lower, { "addpoint", "addstat", "upstat", "stats", "point" }) then
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

    if hasWord(item, "afk") then
        ensureAntiAfk()
        acted = true
    end
    if hasWord(item, "quest") then
        local ok, c = runPromptByKeywords(QUEST_KEYS, 2)
        acted = ok or acted
        if c > 0 then
            addAction("quest x" .. tostring(c), c)
        end
    end

    local pattern = nil
    if hasWord(item, "selecao de mob") then
        pattern = trim(State.config.mobKeyword)
    end
    local target = nearestEnemy(190, false, pattern)

    if target then
        local hum = target:FindFirstChildOfClass("Humanoid")
        if hasWord(item, "deteccao de hp") and hum and hum.Health <= 5 then
            return acted
        end

        local safeDist = categoryPhraseEnabled("auto_farm", "distancia segura") and 10 or 6
        local behind = hasWord(item, "posicionamento atras")
        local useTween = hasWord(item, "pathfinding")

        acted = moveNearModel(target, safeDist, useTween, behind) or acted

        if hasWord(item, "fruta especifica") then
            acted = activateTool(equipToolByKeywords({ State.config.fruitKeyword, "fruit", "blox" })) or acted
        elseif hasWord(item, "arma especifica") then
            acted = activateTool(equipToolByKeywords({ State.config.mobKeyword, "sword", "gun" })) or acted
        elseif hasWord(item, "fighting style") then
            acted = activateTool(equipAnyTool()) or acted
        end

        if hasWord(item, "ataque automatico") or hasWord(item, "inimigo") or hasWord(item, "farm level") then
            acted = activateTool(equipAnyTool()) or acted
        end
        if hasWord(item, "skills automaticas") then
            acted = pressSkillKeys() or acted
        end
    else
        if hasWord(item, "inteligente") then
            acted = runTeleportCycle(true) or acted
        end
    end

    return acted
end

local function runBoss(item)
    local pattern = trim(State.config.bossKeyword)
    if hasWord(item, "saber") then
        pattern = "saber"
    elseif hasWord(item, "don swan") then
        pattern = "don swan"
    elseif hasWord(item, "cake prince") then
        pattern = "cake prince"
    elseif hasWord(item, "rip indra") then
        pattern = "rip indra"
    elseif hasWord(item, "dough king") then
        pattern = "dough king"
    elseif hasWord(item, "tushita") then
        pattern = "tushita"
    elseif hasWord(item, "elite") then
        pattern = "elite"
    end

    local boss = nearestEnemy(900, true, pattern)
    if hasWord(item, "spawn detector") then
        if boss and State.cache.lastBossSeen ~= boss.Name then
            State.cache.lastBossSeen = boss.Name
            pushEvent("boss spawn: " .. boss.Name)
            safeNotify("AutoHub", "Boss detectado: " .. boss.Name)
            return true
        end
        return false
    end

    if boss then
        local moved = moveNearModel(boss, 12, false, false)
        local atk = activateTool(equipAnyTool())
        return moved or atk
    end

    if hasWord(item, "server hop") and cooldownReady("boss_hop", 120) then
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
        pushEvent("boss hop called")
        return true
    end
    return false
end

local function runFrutas(item)
    if hasWord(item, "buy") then
        local ok = runPromptByKeywords({ "dealer", "fruit", "buy", "shop" }, 1)
        return ok
    elseif hasWord(item, "store") then
        local ok = runPromptByKeywords({ "store", "inventory", "fruit" }, 1)
        return ok
    elseif hasWord(item, "drop") then
        local tool = equipToolByKeywords({ State.config.fruitKeyword, "fruit" })
        if tool then
            pcall(function()
                tool.Parent = Workspace
            end)
            return true
        end
        return false
    elseif hasWord(item, "eat") then
        return activateTool(equipToolByKeywords({ State.config.fruitKeyword, "fruit" }))
    elseif hasWord(item, "random") or hasWord(item, "gacha") then
        local ok = runPromptByKeywords({ "cousin", "random", "fruit", "gacha" }, 1)
        return ok
    elseif hasWord(item, "sniper") then
        local wanted = trim(State.config.fruitKeyword)
        if wanted ~= "" then
            for _, f in ipairs(State.perception.fruits) do
                if string.find(string.lower(f.Name), string.lower(wanted), 1, true) then
                    pushEvent("desired fruit found: " .. f.Name)
                    safeNotify("AutoHub", "Fruta detectada: " .. f.Name)
                    return true
                end
            end
        end
        local ok = runPromptByKeywords({ "stock", "dealer", "fruit" }, 1)
        return ok
    elseif hasWord(item, "mastery") then
        local target = nearestEnemy(140, false, nil)
        if target then
            moveNearModel(target, 8, false, false)
        end
        return activateTool(equipToolByKeywords({ State.config.fruitKeyword, "fruit", "blox" }))
    elseif hasWord(item, "awakening") or hasWord(item, "raid") then
        local ok = runPromptByKeywords({ "raid", "awak", "awaken", "chip" }, 2)
        local toolOk = false
        if hasWord(item, "fruta especifica") then
            toolOk = activateTool(equipToolByKeywords({ State.config.fruitKeyword, "fruit", "blox" }))
        end
        return ok or toolOk
    end
    return false
end

local function runCombate(item)
    local acted = false
    local target = nearestEnemy(170, false, nil)

    if target then
        if hasWord(item, "auto aim") then
            local root = getRoot()
            if root and target:FindFirstChild("HumanoidRootPart") then
                root.CFrame = CFrame.lookAt(root.Position, target.HumanoidRootPart.Position)
                acted = true
            end
        end
        if hasWord(item, "hitbox") and target:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                target.HumanoidRootPart.Size = Vector3.new(8, 8, 8)
                target.HumanoidRootPart.Transparency = 0.5
                target.HumanoidRootPart.CanCollide = false
            end)
            acted = true
        end

        if hasWord(item, "kill aura") or hasWord(item, "fast attack") or hasWord(item, "no attack delay") or hasWord(item, "auto click") then
            acted = moveNearModel(target, 6, false, false) or acted
            acted = activateTool(equipAnyTool()) or acted
        end
        if hasWord(item, "auto skill") or hasWord(item, "auto combo") then
            acted = pressSkillKeys() or acted
        end
        if hasWord(item, "damage amplifier") then
            acted = true
        end
    else
        if hasWord(item, "auto click") or hasWord(item, "fast attack") then
            acted = activateTool(equipAnyTool()) or acted
        end
    end

    return acted
end

local function runFightingStyle(item)
    local promptOk = runPromptByKeywords({ "style", "trainer", "teacher", "karate", "claw", "step", "godhuman", "breath" }, 1)
    local atkOk = activateTool(equipAnyTool())
    return promptOk or atkOk
end

local function runEspadas(item)
    local acted = false
    if hasWord(item, "upgrade") then
        acted = runPromptByKeywords({ "blacksmith", "upgrade", "enhance", "sword" }, 1) or acted
    end
    if hasWord(item, "switch") then
        acted = activateTool(equipToolByKeywords({ "sword", "katana", "blade", "sabre", "trident", "scythe" })) or acted
    else
        acted = activateTool(equipToolByKeywords({ "sword", "katana", "blade", "sabre", "trident", "scythe" })) or acted
    end
    return acted
end

local function runArmas(item)
    local acted = false
    local tool = equipToolByKeywords({ "gun", "rifle", "bow", "musket", "kabucha", "flintlock", "acidum" })
    if hasWord(item, "aimbot") then
        local target = nearestEnemy(230, false, nil)
        local root = getRoot()
        if root and target and target:FindFirstChild("HumanoidRootPart") then
            root.CFrame = CFrame.lookAt(root.Position, target.HumanoidRootPart.Position)
            acted = true
        end
    end
    if hasWord(item, "reload") and hasVIM and VirtualInputManager then
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
        end)
        acted = true
    end
    if hasWord(item, "no spread") and tool then
        for _, d in ipairs(tool:GetDescendants()) do
            if d:IsA("NumberValue") and string.find(string.lower(d.Name), "spread", 1, true) then
                d.Value = 0
                acted = true
            end
        end
    end
    acted = activateTool(tool) or acted
    return acted
end

local function runRaca(item)
    local acted = false
    if hasWord(item, "mirage") then
        local island = nearestIsland(2000)
        if island and string.find(string.lower(island.Name), "mirage", 1, true) then
            local part = island:IsA("BasePart") and island or island:FindFirstChild("HumanoidRootPart")
            if part then
                acted = moveToCFrame(part.CFrame + Vector3.new(0, 10, 0), true) or acted
            end
        end
    end
    if hasWord(item, "trial") or hasWord(item, "gear") or hasWord(item, "v2") or hasWord(item, "v3") or hasWord(item, "v4") then
        acted = runPromptByKeywords({ "trial", "gear", "race", "awakening", "v2", "v3", "v4", "temple" }, 2) or acted
    end
    return acted
end

local function runHaki(item)
    local acted = false
    acted = runPromptByKeywords({ "haki", "aura", "instinct", "ken", "buso", "enhancement" }, 1) or acted
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local lower = string.lower(obj.Name)
            if containsAny(lower, { "haki", "aura", "instinct", "ken", "buso" }) then
                local ok = pcall(function()
                    obj:FireServer()
                end)
                if ok then
                    acted = true
                    break
                end
            end
        end
    end
    acted = activateTool(equipAnyTool()) or acted
    return acted
end

local function runTeleport(item)
    if hasWord(item, "bring all mobs") then
        return bringEnemies(true)
    end
    if hasWord(item, "bring mob") or hasWord(item, "magnet") then
        return bringEnemies(false)
    end
    if hasWord(item, "teleport player") then
        local target = nearestPlayer(2200)
        if target and target:FindFirstChild("HumanoidRootPart") then
            return moveToCFrame(target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 8), false)
        end
        return false
    end
    if hasWord(item, "teleport boss") then
        local boss = nearestEnemy(2000, true, trim(State.config.bossKeyword))
        if boss then
            return moveNearModel(boss, 12, false, false)
        end
        return false
    end
    if hasWord(item, "teleport npc") then
        local npc = nearestNpcByKeywords(NPC_KEYS, 2000)
        if npc then
            if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") then
                return moveToCFrame(npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, 8), false)
            end
        end
        return false
    end
    if hasWord(item, "teleport island") then
        local island = nearestIsland(4000)
        if island then
            local part = island:IsA("BasePart") and island or island:FindFirstChild("HumanoidRootPart")
            if part then
                return moveToCFrame(part.CFrame + Vector3.new(0, 12, 0), false)
            end
        end
        return runTeleportCycle(false)
    end
    if hasWord(item, "tween teleport") then
        return runTeleportCycle(true)
    end
    if hasWord(item, "instant teleport") then
        return runTeleportCycle(false)
    end
    return runTeleportCycle(false)
end

local function runPlayerMods(item)
    return applyHumanoidMods()
end

local function runEspVisual(item)
    return refreshESPVisuals()
end

local function runRecursos(item)
    local keys = LOOT_KEYS
    if hasWord(item, "chest") then
        keys = { "chest", "treasure" }
    elseif hasWord(item, "fragments") then
        keys = { "fragment", "frag" }
    elseif hasWord(item, "materials") then
        keys = { "material", "ore", "scale", "scrap" }
    elseif hasWord(item, "money") then
        keys = { "money", "coin", "cash", "reward" }
    elseif hasWord(item, "drops") then
        keys = { "drop", "loot", "reward" }
    end
    local collectOk, c = collectByKeywords(keys, 42, 8)
    local promptOk = runPromptByKeywords({ "collect", "claim", "reward", "loot", "fragment" }, 2)
    if c > 0 then
        addAction("collect x" .. tostring(c), c)
    end
    return collectOk or promptOk
end

local function runServerRuntime(item)
    if hasWord(item, "anti afk") then
        ensureAntiAfk()
        return true
    end
    if hasWord(item, "rejoin") or hasWord(item, "server hop") or hasWord(item, "join low player") then
        if cooldownReady("server_hop", 90) then
            pcall(function()
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end)
            pushEvent("server hop called")
            return true
        end
        return false
    end
    if hasWord(item, "reconnect") then
        if cooldownReady("reconnect", 120) then
            pcall(function()
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end)
            return true
        end
        return false
    end
    return false
end

local function runInteligencia(item)
    if hasWord(item, "detect player nearby") then
        local playerChar = nearestPlayer(State.config.threatDistance)
        if playerChar then
            pushEvent("player nearby: " .. playerChar.Name)
            return true
        end
        return false
    end
    if hasWord(item, "detect admin") then
        local admin = detectPossibleAdmin()
        if admin then
            if State.cache.lastAdminSeen ~= admin.Name then
                State.cache.lastAdminSeen = admin.Name
                safeNotify("AutoHub", "Possivel staff: " .. admin.Name)
                pushEvent("possible staff: " .. admin.Name)
            end
            return true
        end
        return false
    end
    if hasWord(item, "auto leave") then
        local admin = detectPossibleAdmin()
        if admin and cooldownReady("autoleave", 12) then
            pcall(function()
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end)
            pushEvent("auto leave triggered")
            return true
        end
        return false
    end
    if hasWord(item, "delay randomizado") then
        task.wait(math.random() * 0.2)
        return true
    end
    if hasWord(item, "anti report") or hasWord(item, "anti ban") then
        return true
    end
    return false
end

local function runMisc(item)
    if hasWord(item, "full bright") then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        return true
    end
    if hasWord(item, "remove fog") then
        Lighting.FogEnd = 9e9
        return true
    end
    if hasWord(item, "fps boost") or hasWord(item, "remove effects") or hasWord(item, "low graphics mode") then
        applyLowGraphics()
        return true
    end
    if hasWord(item, "white screen mode") then
        ensureWhiteOverlay(true)
        return true
    end
    return false
end

local function runStats(item)
    local stat = "Melee"
    if hasWord(item, "defense") then
        stat = "Defense"
    elseif hasWord(item, "sword") then
        stat = "Sword"
    elseif hasWord(item, "gun") then
        stat = "Gun"
    elseif hasWord(item, "blox fruit") then
        stat = "Demon Fruit"
    end
    return tryStatsRemote(stat)
end

local function runInterfaceTools(item)
    if hasWord(item, "save config") then
        local ok = saveConfig()
        if ok then
            safeNotify("AutoHub", "config saved")
        end
        return ok
    end
    if hasWord(item, "load config") then
        local ok = loadConfig()
        if ok then
            safeNotify("AutoHub", "config loaded")
        end
        return ok
    end
    return true
end

local function runSistemaCore(item)
    if hasWord(item, "config save") then
        return saveConfig()
    end
    if hasWord(item, "config load") then
        return loadConfig()
    end
    if hasWord(item, "webhook") then
        return sendWebhookBatch()
    end
    if hasWord(item, "auto update") then
        pushEvent("auto update check")
        return true
    end
    return true
end

local function runAvancadas(item)
    local keys = { "event" }
    if hasWord(item, "sea event") then
        keys = { "sea", "ship raid", "event" }
    elseif hasWord(item, "leviathan") then
        keys = { "leviathan" }
    elseif hasWord(item, "ship raid") then
        keys = { "ship", "raid" }
    elseif hasWord(item, "haunted") then
        keys = { "haunted", "castle" }
    elseif hasWord(item, "trial puzzle") then
        keys = { "trial", "puzzle" }
    elseif hasWord(item, "temple") then
        keys = { "temple" }
    elseif hasWord(item, "gear farming") or hasWord(item, "blue gear") then
        keys = { "gear", "blue gear" }
    elseif hasWord(item, "mirage") then
        keys = { "mirage" }
    end

    local island = nearestIsland(2500)
    if island and containsAny(string.lower(island.Name), keys) then
        local part = island:IsA("BasePart") and island or island:FindFirstChild("HumanoidRootPart")
        if part then
            moveToCFrame(part.CFrame + Vector3.new(0, 10, 0), true)
            pushEvent(item.name .. ": " .. island.Name)
            return true
        end
    end
    local promptOk = runPromptByKeywords(keys, 1)
    if promptOk then
        pushEvent(item.name .. ": prompt")
    end
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
    esp_visual = runEspVisual,
    recursos = runRecursos,
    server_runtime = runServerRuntime,
    inteligencia = runInteligencia,
    misc = runMisc,
    stats = runStats,
    interface_tools = runInterfaceTools,
    sistema_core = runSistemaCore,
    avancadas = runAvancadas,
}

local function shouldAutoDisable(item)
    return hasWord(item, "save config")
        or hasWord(item, "load config")
        or hasWord(item, "config save")
        or hasWord(item, "config load")
        or hasWord(item, "server hop")
        or hasWord(item, "rejoin")
        or hasWord(item, "join low player")
end

local function executeItem(item)
    local handler = CategoryHandlers[item.categoryId]
    if not handler then
        return false
    end
    return handler(item)
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
    local currentInput

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startPos = frame.Position
            startInput = input.Position
            currentInput = input
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == currentInput then
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

local function updateCategoryButtonVisual(activeCategory)
    for catId, button in pairs(State.categoryButtons) do
        button.BackgroundColor3 = (catId == activeCategory) and Theme.rowActive or Theme.panel2
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

local function setCategory(categoryId)
    if not State.categoryLookup[categoryId] then
        return
    end
    State.config.selectedCategory = categoryId
    if State.ui.categoryTitle then
        State.ui.categoryTitle.Text = State.categoryLookup[categoryId].label
    end
    updateCategoryButtonVisual(categoryId)
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

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 12, 22)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(6, 9, 17)),
    })
    gradient.Rotation = 90
    gradient.Parent = main

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundTransparency = 1
    header.Parent = main

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 320, 0, 18)
    title.Position = UDim2.new(0, 8, 0, 6)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.TextColor3 = Theme.text
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "AutoHub Organized " .. VERSION
    title.Parent = header

    local hint = Instance.new("TextLabel")
    hint.Size = UDim2.new(0, 120, 0, 14)
    hint.Position = UDim2.new(1, -150, 0, 8)
    hint.BackgroundTransparency = 1
    hint.Font = Enum.Font.Gotham
    hint.TextSize = 10
    hint.TextColor3 = Theme.muted
    hint.TextXAlignment = Enum.TextXAlignment.Right
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
    sidebar.Size = UDim2.new(0, 174, 1, -36)
    sidebar.Position = UDim2.new(0, 6, 0, 30)
    sidebar.BackgroundColor3 = Theme.panel
    sidebar.Parent = main
    corner(sidebar, 8)
    stroke(sidebar)

    local catTitle = Instance.new("TextLabel")
    catTitle.Size = UDim2.new(1, -12, 0, 16)
    catTitle.Position = UDim2.new(0, 6, 0, 6)
    catTitle.BackgroundTransparency = 1
    catTitle.Font = Enum.Font.GothamBold
    catTitle.TextSize = 11
    catTitle.TextColor3 = Theme.text
    catTitle.TextXAlignment = Enum.TextXAlignment.Left
    catTitle.Text = "Categorias"
    catTitle.Parent = sidebar

    local catScroll = Instance.new("ScrollingFrame")
    catScroll.Size = UDim2.new(1, -8, 1, -28)
    catScroll.Position = UDim2.new(0, 4, 0, 24)
    catScroll.BackgroundTransparency = 1
    catScroll.ScrollBarThickness = 4
    catScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    catScroll.Parent = sidebar
    State.ui.catScroll = catScroll

    local catLayout = Instance.new("UIListLayout")
    catLayout.Padding = UDim.new(0, 4)
    catLayout.Parent = catScroll
    catLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        catScroll.CanvasSize = UDim2.new(0, 0, 0, catLayout.AbsoluteContentSize.Y + 4)
    end)

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -186, 1, -36)
    content.Position = UDim2.new(0, 180, 0, 30)
    content.BackgroundColor3 = Theme.panel
    content.Parent = main
    corner(content, 8)
    stroke(content)

    local contentHeader = Instance.new("TextLabel")
    contentHeader.Size = UDim2.new(0, 170, 0, 16)
    contentHeader.Position = UDim2.new(0, 8, 0, 6)
    contentHeader.BackgroundTransparency = 1
    contentHeader.Font = Enum.Font.GothamBold
    contentHeader.TextSize = 11
    contentHeader.TextColor3 = Theme.text
    contentHeader.TextXAlignment = Enum.TextXAlignment.Left
    contentHeader.Parent = content
    State.ui.categoryTitle = contentHeader

    local countLabel = Instance.new("TextLabel")
    countLabel.Size = UDim2.new(0, 90, 0, 14)
    countLabel.Position = UDim2.new(1, -96, 0, 7)
    countLabel.BackgroundTransparency = 1
    countLabel.Font = Enum.Font.Gotham
    countLabel.TextSize = 10
    countLabel.TextColor3 = Theme.muted
    countLabel.TextXAlignment = Enum.TextXAlignment.Right
    countLabel.Parent = content
    State.ui.countLabel = countLabel

    local search = Instance.new("TextBox")
    search.Size = UDim2.new(0, 106, 0, 20)
    search.Position = UDim2.new(0, 8, 0, 24)
    search.PlaceholderText = "Search"
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
    webhook.Size = UDim2.new(0, 122, 0, 20)
    webhook.Position = UDim2.new(0, 118, 0, 24)
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
    saveBtn.Size = UDim2.new(0, 36, 0, 20)
    saveBtn.Position = UDim2.new(0, 244, 0, 24)
    saveBtn.Text = "Save"
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = 9
    saveBtn.TextColor3 = Theme.text
    saveBtn.BackgroundColor3 = Theme.panel2
    saveBtn.Parent = content
    corner(saveBtn, 5)
    stroke(saveBtn)

    local loadBtn = Instance.new("TextButton")
    loadBtn.Size = UDim2.new(0, 36, 0, 20)
    loadBtn.Position = UDim2.new(0, 284, 0, 24)
    loadBtn.Text = "Load"
    loadBtn.Font = Enum.Font.GothamBold
    loadBtn.TextSize = 9
    loadBtn.TextColor3 = Theme.text
    loadBtn.BackgroundColor3 = Theme.panel2
    loadBtn.Parent = content
    corner(loadBtn, 5)
    stroke(loadBtn)

    local onBtn = Instance.new("TextButton")
    onBtn.Size = UDim2.new(0, 20, 0, 20)
    onBtn.Position = UDim2.new(0, 324, 0, 24)
    onBtn.Text = "+"
    onBtn.Font = Enum.Font.GothamBold
    onBtn.TextSize = 11
    onBtn.TextColor3 = Theme.text
    onBtn.BackgroundColor3 = Theme.ok
    onBtn.Parent = content
    corner(onBtn, 5)
    stroke(onBtn)

    local offBtn = Instance.new("TextButton")
    offBtn.Size = UDim2.new(0, 20, 0, 20)
    offBtn.Position = UDim2.new(0, 348, 0, 24)
    offBtn.Text = "-"
    offBtn.Font = Enum.Font.GothamBold
    offBtn.TextSize = 11
    offBtn.TextColor3 = Theme.text
    offBtn.BackgroundColor3 = Theme.warn
    offBtn.Parent = content
    corner(offBtn, 5)
    stroke(offBtn)

    local mobBox = Instance.new("TextBox")
    mobBox.Size = UDim2.new(0, 114, 0, 20)
    mobBox.Position = UDim2.new(0, 8, 0, 46)
    mobBox.PlaceholderText = "Mob keyword"
    mobBox.Text = State.config.mobKeyword
    mobBox.Font = Enum.Font.Gotham
    mobBox.TextSize = 10
    mobBox.TextColor3 = Theme.text
    mobBox.PlaceholderColor3 = Theme.muted
    mobBox.BackgroundColor3 = Theme.panel2
    mobBox.Parent = content
    corner(mobBox, 5)
    stroke(mobBox)
    State.ui.mobBox = mobBox

    local bossBox = Instance.new("TextBox")
    bossBox.Size = UDim2.new(0, 114, 0, 20)
    bossBox.Position = UDim2.new(0, 126, 0, 46)
    bossBox.PlaceholderText = "Boss keyword"
    bossBox.Text = State.config.bossKeyword
    bossBox.Font = Enum.Font.Gotham
    bossBox.TextSize = 10
    bossBox.TextColor3 = Theme.text
    bossBox.PlaceholderColor3 = Theme.muted
    bossBox.BackgroundColor3 = Theme.panel2
    bossBox.Parent = content
    corner(bossBox, 5)
    stroke(bossBox)
    State.ui.bossBox = bossBox

    local fruitBox = Instance.new("TextBox")
    fruitBox.Size = UDim2.new(0, 114, 0, 20)
    fruitBox.Position = UDim2.new(0, 244, 0, 46)
    fruitBox.PlaceholderText = "Fruit keyword"
    fruitBox.Text = State.config.fruitKeyword
    fruitBox.Font = Enum.Font.Gotham
    fruitBox.TextSize = 10
    fruitBox.TextColor3 = Theme.text
    fruitBox.PlaceholderColor3 = Theme.muted
    fruitBox.BackgroundColor3 = Theme.panel2
    fruitBox.Parent = content
    corner(fruitBox, 5)
    stroke(fruitBox)
    State.ui.fruitBox = fruitBox

    local list = Instance.new("ScrollingFrame")
    list.Size = UDim2.new(1, -8, 1, -90)
    list.Position = UDim2.new(0, 4, 0, 70)
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
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -8, 0, 22)
        b.BackgroundColor3 = Theme.panel2
        b.Text = cat.label .. " (" .. tostring(#cat.items) .. ")"
        b.Font = Enum.Font.Gotham
        b.TextSize = 10
        b.TextColor3 = Theme.text
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.AutoButtonColor = false
        b.Parent = catScroll
        corner(b, 5)
        stroke(b, Theme.border)

        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 8)
        pad.Parent = b

        b.MouseButton1Click:Connect(function()
            setCategory(cat.id)
        end)
        State.categoryButtons[cat.id] = b
    end

    for _, cat in ipairs(CategoryDefs) do
        createCategoryButton(cat)
    end

    function renderRows()
        for _, r in pairs(State.visibleRows) do
            if r.frame and r.frame.Parent then
                r.frame:Destroy()
            end
        end
        State.visibleRows = {}

        local catId = State.config.selectedCategory
        local ids = State.categoryItems[catId] or {}
        local filter = string.lower(trim(State.config.searchText))
        local y = 0
        local visible = 0
        local enabledCount = 0

        for _, itemId in ipairs(ids) do
            local item = State.items[itemId]
            if item then
                if State.toggles[itemId] then
                    enabledCount = enabledCount + 1
                end
                if filter == "" or string.find(item.lower, filter, 1, true) then
                    visible = visible + 1
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
                    name.Size = UDim2.new(1, -100, 1, 0)
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
                        dot = dot,
                        toggle = toggle,
                    }
                    updateRowVisual(itemId)
                    y = y + 26
                end
            end
        end

        list.CanvasSize = UDim2.new(0, 0, 0, y + 2)
        countLabel.Text = tostring(enabledCount) .. "/" .. tostring(#ids) .. " ON"
        contentHeader.Text = State.categoryLookup[catId].label .. " [" .. tostring(visible) .. "]"
        updateCategoryButtonVisual(catId)
    end

    search:GetPropertyChangedSignal("Text"):Connect(function()
        State.config.searchText = search.Text
        renderRows()
    end)

    local function syncFields()
        State.config.webhookUrl = trim(webhook.Text)
        State.config.mobKeyword = trim(mobBox.Text)
        State.config.bossKeyword = trim(bossBox.Text)
        State.config.fruitKeyword = trim(fruitBox.Text)
    end

    webhook.FocusLost:Connect(syncFields)
    mobBox.FocusLost:Connect(syncFields)
    bossBox.FocusLost:Connect(syncFields)
    fruitBox.FocusLost:Connect(syncFields)

    saveBtn.MouseButton1Click:Connect(function()
        syncFields()
        if saveConfig() then
            safeNotify("AutoHub", "Config saved")
        else
            safeNotify("AutoHub", "Save failed")
        end
    end)

    loadBtn.MouseButton1Click:Connect(function()
        if loadConfig() then
            search.Text = State.config.searchText
            webhook.Text = State.config.webhookUrl
            mobBox.Text = State.config.mobKeyword
            bossBox.Text = State.config.bossKeyword
            fruitBox.Text = State.config.fruitKeyword
            setCategory(State.config.selectedCategory)
            renderRows()
            safeNotify("AutoHub", "Config loaded")
        else
            safeNotify("AutoHub", "No config found")
        end
    end)

    onBtn.MouseButton1Click:Connect(function()
        local cat = State.config.selectedCategory
        for _, id in ipairs(State.categoryItems[cat]) do
            State.toggles[id] = true
            State.nextRun[id] = 0
        end
        renderRows()
    end)

    offBtn.MouseButton1Click:Connect(function()
        local cat = State.config.selectedCategory
        for _, id in ipairs(State.categoryItems[cat]) do
            State.toggles[id] = false
        end
        renderRows()
    end)

    close.MouseButton1Click:Connect(function()
        State.running = false
    end)

    State.conns.endKey = UserInputService.InputBegan:Connect(function(input, gp)
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

local function refreshStatusText()
    local uptime = math.floor(now() - State.startedAt)
    if State.ui.footer then
        State.ui.footer.Text = "Uptime: " .. tostring(uptime)
            .. "s | Active: " .. tostring(State.activeCount)
            .. " | Actions: " .. tostring(State.stats.actions)
            .. " | Errors: " .. tostring(State.stats.errors)
            .. " | Last: " .. tostring(State.stats.last)
    end
end

local function cleanup()
    State.running = false

    for _, conn in pairs(State.conns) do
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
        getgenv().AutoHubV6Loaded = nil
    end)
end

local function schedulerLoop()
    task.spawn(function()
        while State.running do
            local current = now()
            local active = 0

            for _, itemId in ipairs(State.itemOrder) do
                if State.toggles[itemId] then
                    active = active + 1
                    local item = State.items[itemId]
                    if item and current >= (State.nextRun[itemId] or 0) then
                        State.nextRun[itemId] = current + (item.interval or 1)
                        local ok, acted = pcall(function()
                            return executeItem(item)
                        end)
                        if not ok then
                            addError("err: " .. item.name)
                        elseif acted then
                            addAction(item.name, 1)
                            if shouldAutoDisable(item) then
                                State.toggles[itemId] = false
                                updateRowVisual(itemId)
                            end
                        end
                    end
                end
            end

            State.activeCount = active
            task.wait(0.08)
        end
    end)
end

local function perceptionLoop()
    task.spawn(function()
        while State.running do
            local ok, err = pcall(refreshPerception)
            if not ok then
                addError("perception err")
                warn("[AutoHub] perception error: " .. tostring(err))
            end
            task.wait(0.45)
        end
    end)
end

local function statusLoop()
    task.spawn(function()
        while State.running do
            if categoryPhraseEnabled("misc", "white screen mode") then
                ensureWhiteOverlay(true)
            else
                ensureWhiteOverlay(false)
            end
            refreshStatusText()
            task.wait(0.25)
        end
    end)
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

local function runtimeHeartbeat()
    State.conns.heartbeat = RunService.Heartbeat:Connect(function()
        if not State.running then
            return
        end
        if categoryPhraseEnabled("server_runtime", "anti afk") or categoryPhraseEnabled("auto_farm", "afk") then
            ensureAntiAfk()
        end
        if categoryPhraseEnabled("misc", "fps boost") or categoryPhraseEnabled("misc", "low graphics mode") then
            applyLowGraphics()
        end
        if categoryPhraseEnabled("esp_visual", "highlight") or categoryPhraseEnabled("esp_visual", "boxes") then
            refreshESPVisuals()
        end
        applyHumanoidMods()
    end)
end

local function boot()
    loadConfig()
    buildUI()
    ensureInfiniteJump()
    refreshPerception()

    perceptionLoop()
    schedulerLoop()
    statusLoop()
    autosaveLoop()
    runtimeHeartbeat()

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

