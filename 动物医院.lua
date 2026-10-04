-- 动物医院 脚本 v3.2.0
-- WindUI蓝白版 | 防扣理智 | 自动前台 | 动物透视 | 传送 | 透视玩家 | 秒互动

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
if not WindUI then return end

WindUI:AddTheme({
    Name = "冰白",
    Accent = "#80C0FF",
    Outline = "#6090C0",
    Text = "#FFFFFF",
    Placeholder = "#D0E0FF",
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Settings = {
    NoSanity = false, AutoReception = false,
    ESP_Enabled = false, AnimalESP_Enabled = false, AnimalESP_ShowDistance = false,
    AnimalESP_OnlyAbnormal = false,
    InstantInteract = false,
    WalkSpeed = 16,
}

local VERSION = "v3.2.0"
local stopAll = false
local highlights = {}; local nameTags = {}
local animalHighlights = {}; local animalNameTags = {}
local noSanityHooks = {}
local originalDurations = {}
local descendantAddedConn = nil
local lastAnimalScan = 0
local cachedAnimals = {}

local EXCLUDED_NAMES = {"Dummy", "Nurse"}

local ABNORMAL_KEYWORDS = {
    "skinwalker", "skin walker", "monster", "entity", "creature", "fake", "impostor", "imposter",
    "mimic", "horror", "beast", "demon", "cryptid", "anomaly", "nightmare", "shapeshifter",
    "possessed", "haunted", "evil", "specter", "wraith", "phantom", "shadow", "abomination",
    "mutant", "stalker", "flesh", "gore", "blood", "scream", "unknown", "thing", "being",
    "presence", "intruder", "invader", "predator", "nonhuman", "paranormal", "supernatural",
    "slender", "sirenhead", "scp", "alternate", "doppelganger", "changeling",
    "异常", "诡异", "恐怖", "怪物", "伪人", "异常体", "诡异体", "恐怖体",
    "infected", "cursed", "twisted", "corrupted", "dark", "evil", "hell", "demon",
    "ghost", "spirit", "phantom", "wraith", "zombie", "undead", "mutated", "deformed",
}

local function isAbnormal(name)
    local lowerName = name:lower()
    for _, keyword in pairs(ABNORMAL_KEYWORDS) do
        if lowerName:find(keyword) then return true end
    end
    return false
end

local function shouldExcludeAnimal(name)
    for _, excluded in pairs(EXCLUDED_NAMES) do
        if name:lower() == excluded:lower() then return true end
    end
    return false
end

local function getPos()
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("HumanoidRootPart") then return c.HumanoidRootPart.Position end
    return nil
end

local function tp(pos)
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("HumanoidRootPart") then c.HumanoidRootPart.CFrame = CFrame.new(pos) end
end

local function setupNoSanity()
    if noSanityHooks.mtHook then return end
    local Event = ReplicatedStorage.Util.Net["RE/PlayerLostSanity"]
    noSanityHooks.mtHook = hookmetamethod(game, "__namecall", function(...)
        local self = ...; local method = getnamecallmethod()
        if self == Event and method == "FireServer" and Settings.NoSanity then return nil end
        return noSanityHooks.mtHook(...)
    end)
    noSanityHooks.oldFireServer = hookfunction(Event.FireServer, function(...)
        local self = ...
        if self == Event and Settings.NoSanity then return nil end
        return noSanityHooks.oldFireServer(self, ...)
    end)
end

-- 秒互动核心
local function modifyPrompt(prompt, enable)
    if enable then
        if not originalDurations[prompt] then
            originalDurations[prompt] = prompt.HoldDuration
        end
        prompt.HoldDuration = 0
    else
        local original = originalDurations[prompt]
        if original and prompt.Parent then
            prompt.HoldDuration = original
        end
    end
end

local function processAllPrompts(enable)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            modifyPrompt(obj, enable)
        end
    end
end

local function onDescendantAdded(descendant)
    if descendant:IsA("ProximityPrompt") then
        modifyPrompt(descendant, true)
    end
end

local function enableInstant()
    processAllPrompts(true)
    descendantAddedConn = Workspace.DescendantAdded:Connect(onDescendantAdded)
end

local function disableInstant()
    if descendantAddedConn then
        descendantAddedConn:Disconnect()
        descendantAddedConn = nil
    end
    for prompt, original in pairs(originalDurations) do
        if prompt.Parent then
            prompt.HoldDuration = original
        end
    end
    originalDurations = {}
end

local function hasAnimalNear(pos)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("Head") then
            local root = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
            if root and (pos - root.Position).Magnitude <= 20 then
                local isPlayer = false
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr.Character == obj then isPlayer = true; break end
                end
                if not isPlayer then return true end
            end
        end
    end
    return false
end

-- 自动前台
task.spawn(function()
    while true do
        if Settings.AutoReception and not stopAll then
            local pos1 = Vector3.new(-104, 3.4, 1.3); local pos2 = Vector3.new(-107.5, 3.4, 1.3)
            local pos3 = Vector3.new(-99, 3.4, 0.9); local pos4 = Vector3.new(-99, 3.4, 1.6)
            local waitPos = Vector3.new(-114, 3.4, -1.3)
            if hasAnimalNear(pos1) then
                tp(pos1); task.wait(2.5); VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil); task.wait(2); VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
                if not Settings.AutoReception or stopAll then continue end
                tp(pos2); task.wait(2.5); VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil); task.wait(2); VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
                if not Settings.AutoReception or stopAll then continue end
                tp(pos3); task.wait(2.5); VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil); task.wait(2); VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
                if not Settings.AutoReception or stopAll then continue end
                tp(pos4); task.wait(7.5); VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil); task.wait(3); VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
            else
                tp(waitPos); task.wait(2.5); VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil); task.wait(2); VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil); task.wait(10)
            end
        else task.wait(1) end
    end
end)

-- 优化动物ESP - 缓存扫描
local function getAnimalModels()
    local animals = {}
    local playerChars = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character then playerChars[plr.Character] = true end
    end
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("Head") then
            if not playerChars[obj] and not shouldExcludeAnimal(obj.Name) then
                -- 如果开启了只显示异常体，则过滤
                if Settings.AnimalESP_OnlyAbnormal then
                    if isAbnormal(obj.Name) then
                        table.insert(animals, obj)
                    end
                else
                    table.insert(animals, obj)
                end
            end
        end
    end
    return animals
end

local function clearAnimalESP()
    for _, h in pairs(animalHighlights) do pcall(function() h:Destroy() end) end
    for _, t in pairs(animalNameTags) do pcall(function() t:Destroy() end) end
    table.clear(animalHighlights); table.clear(animalNameTags)
    table.clear(cachedAnimals)
end

RunService.Heartbeat:Connect(function()
    if not Settings.AnimalESP_Enabled then 
        if next(animalHighlights) or next(animalNameTags) then
            clearAnimalESP()
        end
        return 
    end
    
    -- 每2秒才扫描一次动物列表，减少性能消耗
    local currentTime = tick()
    if currentTime - lastAnimalScan > 2 then
        cachedAnimals = getAnimalModels()
        lastAnimalScan = currentTime
        
        -- 清理不存在的动物
        local activeAnimals = {}
        for _, animal in pairs(cachedAnimals) do activeAnimals[animal] = true end
        for animal, _ in pairs(animalHighlights) do
            if not activeAnimals[animal] then
                if animalHighlights[animal] then pcall(function() animalHighlights[animal]:Destroy() end); animalHighlights[animal] = nil end
                if animalNameTags[animal] then pcall(function() animalNameTags[animal]:Destroy() end); animalNameTags[animal] = nil end
            end
        end
    end
    
    -- 使用缓存的动物列表
    for _, animal in pairs(cachedAnimals) do
        if animal and animal.Parent then
            local head = animal:FindFirstChild("Head")
            local root = animal:FindFirstChild("HumanoidRootPart") or animal.PrimaryPart
            if head then
                local isAbnormalAnimal = isAbnormal(animal.Name)
                local dist = ""
                if Settings.AnimalESP_ShowDistance and root then
                    local d = 0; local c = LocalPlayer.Character
                    if c and c:FindFirstChild("HumanoidRootPart") then d = (root.Position - c.HumanoidRootPart.Position).Magnitude end
                    dist = "\n[" .. math.floor(d) .. "m]"
                end
                local displayName = (isAbnormalAnimal and "[异常] " or "") .. animal.Name .. dist
                local nameColor = isAbnormalAnimal and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(100, 255, 100)
                local fillColor = isAbnormalAnimal and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(100, 255, 100)
                
                if not animalHighlights[animal] then
                    local h = Instance.new("Highlight"); h.FillColor = fillColor; h.FillTransparency = 0.5
                    h.OutlineColor = fillColor; h.OutlineTransparency = 0.3; h.Parent = animal; animalHighlights[animal] = h
                else 
                    animalHighlights[animal].FillColor = fillColor 
                end
                
                if not animalNameTags[animal] then
                    local bg = Instance.new("BillboardGui"); bg.Size = UDim2.new(0, 200, 0, 40)
                    bg.AlwaysOnTop = true; bg.MaxDistance = math.huge; bg.Parent = head
                    local l = Instance.new("TextLabel"); l.Size = UDim2.new(1, 0, 1, 0); l.BackgroundTransparency = 1
                    l.Text = displayName; l.TextColor3 = nameColor; l.Font = Enum.Font.GothamBold; l.TextSize = 14
                    l.TextStrokeTransparency = 0.5; l.TextStrokeColor3 = Color3.fromRGB(0, 0, 0); l.Parent = bg
                    animalNameTags[animal] = bg
                else
                    local label = animalNameTags[animal]:FindFirstChild("TextLabel")
                    if label then 
                        label.Text = displayName
                        label.TextColor3 = nameColor
                    end
                end
            end
        end
    end
end)

-- 玩家ESP
local function clearESP()
    for _, h in pairs(highlights) do pcall(function() h:Destroy() end) end
    for _, t in pairs(nameTags) do pcall(function() t:Destroy() end) end
    table.clear(highlights); table.clear(nameTags)
end

RunService.Heartbeat:Connect(function()
    if not Settings.ESP_Enabled then clearESP(); return end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char or not char:FindFirstChild("Head") then continue end
        local isSkin = isAbnormal(plr.Name)
        local displayName = (isSkin and "[异常] " or "") .. plr.Name
        local fillColor = isSkin and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(255, 100, 100)
        local nameColor = isSkin and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(255, 255, 255)
        if not highlights[plr] then
            local h = Instance.new("Highlight"); h.FillColor = fillColor; h.FillTransparency = 0.5
            h.OutlineColor = fillColor; h.OutlineTransparency = 0.3; h.Parent = char; highlights[plr] = h
        else highlights[plr].FillColor = fillColor end
        if highlights[plr] and highlights[plr].Parent ~= char then highlights[plr].Parent = char end
        if not nameTags[plr] then
            local bg = Instance.new("BillboardGui"); bg.Size = UDim2.new(0, 200, 0, 25)
            bg.AlwaysOnTop = true; bg.MaxDistance = math.huge; bg.Parent = char.Head
            local l = Instance.new("TextLabel"); l.Size = UDim2.new(1, 0, 1, 0); l.BackgroundTransparency = 1
            l.Text = displayName; l.TextColor3 = nameColor; l.Font = Enum.Font.GothamBold; l.TextSize = 14
            l.TextStrokeTransparency = 0.5; l.TextStrokeColor3 = Color3.fromRGB(0, 0, 0); l.Parent = bg
            nameTags[plr] = bg
        else
            local label = nameTags[plr]:FindFirstChild("TextLabel")
            if label then label.Text = displayName; label.TextColor3 = nameColor end
        end
        if nameTags[plr] and nameTags[plr].Parent ~= char.Head then nameTags[plr].Parent = char.Head end
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    if highlights[plr] then pcall(function() highlights[plr]:Destroy() end); highlights[plr] = nil end
    if nameTags[plr] then pcall(function() nameTags[plr]:Destroy() end); nameTags[plr] = nil end
end)

local function setSpeed(s)
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = s end
end
RunService.Heartbeat:Connect(function() if Settings.WalkSpeed ~= 16 then setSpeed(Settings.WalkSpeed) end end)

local function getPlayerNames()
    local names = {}
    for _, plr in pairs(Players:GetPlayers()) do if plr ~= LocalPlayer then table.insert(names, plr.Name) end end
    if #names == 0 then table.insert(names, "无其他玩家") end
    return names
end

local Window = WindUI:CreateWindow({
    Title = "动物医院", Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(400, 350), Theme = "冰白", Transparent = true,
})

Window:Tab({Title = "公告", Icon = "info"}):Paragraph({
    Title = "黑脚本--功能说明",
    Desc = "防扣理智 | 自动前台 | 动物透视\n传送房间 | 透视玩家 | 秒互动\n\n版本：" .. VERSION,
})

local Tab1 = Window:Tab({Title = "主要", Icon = "play"})
Tab1:Toggle({Title = "防止扣除理智", Value = false, Callback = function(v) Settings.NoSanity = v; if v then setupNoSanity() end end})
Tab1:Paragraph({Title = "说明", Desc = "开启后扣理智正常，喝咖啡恢复"})
Tab1:Divider()
Tab1:Toggle({Title = "自动前台", Value = false, Callback = function(v) Settings.AutoReception = v end})
Tab1:Divider()
Tab1:Toggle({Title = "动物透视", Value = false, Callback = function(v) Settings.AnimalESP_Enabled = v; if not v then clearAnimalESP() end end})
Tab1:Toggle({Title = "显示动物距离", Value = false, Callback = function(v) Settings.AnimalESP_ShowDistance = v end})
Tab1:Toggle({Title = "只显示异常体", Value = false, Callback = function(v) Settings.AnimalESP_OnlyAbnormal = v; if v then lastAnimalScan = 0 end end})
Tab1:Divider()
Tab1:Toggle({Title = "秒互动", Value = false, Callback = function(v) 
    Settings.InstantInteract = v
    if v then
        enableInstant()
        WindUI:Notify({Title = "秒互动", Content = "已开启", Duration = 2})
    else
        disableInstant()
        WindUI:Notify({Title = "秒互动", Content = "已关闭", Duration = 2})
    end
end})

local Tab2 = Window:Tab({Title = "传送", Icon = "map-pin"})
Tab2:Button({Title = "传送前台", Callback = function() tp(Vector3.new(-103, 3.4, 4.2)) end})
Tab2:Button({Title = "房间一", Callback = function() tp(Vector3.new(-167, 3.5, -54.4)) end})
Tab2:Button({Title = "房间二", Callback = function() tp(Vector3.new(-126, 3.5, -49.8)) end})
Tab2:Button({Title = "房间三", Callback = function() tp(Vector3.new(-167, 3.5, -91.6)) end})
Tab2:Button({Title = "房间四", Callback = function() tp(Vector3.new(-121, 3.5, -86.5)) end})
Tab2:Button({Title = "房间五", Callback = function() tp(Vector3.new(-144, 3.5, -117)) end})
Tab2:Button({Title = "房间六", Callback = function() tp(Vector3.new(-125, 3.5, 51.7)) end})
Tab2:Button({Title = "房间七", Callback = function() tp(Vector3.new(-166, 3.5, 54)) end})
Tab2:Button({Title = "手术室", Callback = function() tp(Vector3.new(-145, 3.5, 83.1)) end})
Tab2:Divider()
local playerNames = getPlayerNames()
local selectedPlayer = playerNames[1] or "无其他玩家"
Tab2:Dropdown({Title = "选择玩家", Values = playerNames, Value = selectedPlayer, Callback = function(v) selectedPlayer = v end})
Tab2:Button({Title = "传送到该玩家", Callback = function() for _, plr in pairs(Players:GetPlayers()) do if plr.Name == selectedPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then tp(plr.Character.HumanoidRootPart.Position) end end end})

local Tab3 = Window:Tab({Title = "玩家", Icon = "users"})
Tab3:Toggle({Title = "透视玩家", Value = false, Callback = function(v) Settings.ESP_Enabled = v; if not v then clearESP() end end})
Tab3:Input({Title = "移动速度", Value = "16", Callback = function(v) local n = tonumber(v) if n and n >= 10 and n <= 100 then Settings.WalkSpeed = n end end})
Tab3:Button({Title = "重置速度", Callback = function() Settings.WalkSpeed = 16 end})

-- 设置标签页
local SettingsTab = Window:Tab({Title = "设置", Icon = "settings"})

local statusParagraph = SettingsTab:Paragraph({
    Title = "功能状态",
    Desc = "正在加载..."
})

local function updateStatus()
    local status = ""
    
    if Settings.NoSanity then
        status = status .. "✅ 防止扣除理智: 已开启\n"
    else
        status = status .. "❌ 防止扣除理智: 未开启\n"
    end
    
    if Settings.AutoReception then
        status = status .. "✅ 自动前台: 已开启\n"
    else
        status = status .. "❌ 自动前台: 未开启\n"
    end
    
    if Settings.AnimalESP_Enabled then
        status = status .. "✅ 动物透视: 已开启"
        if Settings.AnimalESP_OnlyAbnormal then
            status = status .. " (仅异常体)"
        end
        status = status .. "\n"
    else
        status = status .. "❌ 动物透视: 未开启\n"
    end
    
    if Settings.ESP_Enabled then
        status = status .. "✅ 透视玩家: 已开启\n"
    else
        status = status .. "❌ 透视玩家: 未开启\n"
    end
    
    if Settings.InstantInteract then
        status = status .. "✅ 秒互动: 已开启\n"
    else
        status = status .. "❌ 秒互动: 未开启\n"
    end
    
    statusParagraph:SetDesc(status)
end

RunService.Heartbeat:Connect(function()
    updateStatus()
end)

SettingsTab:Button({Title = "关闭脚本", Callback = function() stopAll = true; Settings.NoSanity = false; Settings.AnimalESP_Enabled = false; Settings.InstantInteract = false; disableInstant(); clearAnimalESP(); clearESP(); setSpeed(16); Window:Close() end})
Window:OnClose(function() stopAll = true; Settings.NoSanity = false; Settings.InstantInteract = false; disableInstant(); clearAnimalESP(); clearESP(); setSpeed(16) end)

WindUI:Notify({Title = "动物医院", Content = VERSION .. " 加载完成", Duration = 3})
