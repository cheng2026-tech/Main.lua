-- 破碎之梦 脚本 v1.8.0
-- WindUI蓝白版 | 完整版

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
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Settings = {
    -- 透视
    CRTESP = false,
    PrincipalESP = false,
    ClockESP = false,
    DreadEntityESP = false,
    PeripheralESP = false,
    -- 自动
    AutoCRT = false,
    AutoDoor = false,
    DeleteStudents = false,
    AutoMemory1 = false,
    AutoCoin = false,
    AutoMemory2 = false,
    SemiAutoClear = false,
    -- 玩家
    SpeedEnabled = false,
    SpeedValue = 100,
}

local VERSION = "v1.8.0"
local espHighlights = {}
local espNameTags = {}
local espTargets = {}
local lastESPScan = 0
local isScanning = false
local visitedCRTs = {}
local visitedDoors = {}
local visitedMemories1 = {}
local visitedCoins = {}
local visitedMemories2 = {}
local isSemiAutoRunning = false

local function getRoot(obj)
    if obj:IsA("Model") then
        return obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
    elseif obj:IsA("BasePart") then
        return obj
    end
    return nil
end

local function getParentModel(obj)
    local parent = obj.Parent
    while parent and parent ~= Workspace do
        if parent:IsA("Model") then
            return parent
        end
        parent = parent.Parent
    end
    return obj
end

local function teleportTo(pos, name)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        WindUI:Notify({Title = "传送失败", Content = "角色未加载", Duration = 2})
        return false
    end
    character.HumanoidRootPart.CFrame = CFrame.new(pos)
    WindUI:Notify({Title = "传送成功", Content = "已传送到" .. name, Duration = 2})
    return true
end

-- 清理ESP
local function clearESP()
    for _, h in pairs(espHighlights) do pcall(function() h:Destroy() end) end
    for _, t in pairs(espNameTags) do pcall(function() t:Destroy() end) end
    table.clear(espHighlights)
    table.clear(espNameTags)
    table.clear(espTargets)
end

-- 增量更新ESP
local function incrementalUpdateESP()
    if isScanning then return end
    isScanning = true
    
    task.spawn(function()
        local seenObjects = {}
        local newTargets = {}
        
        local espConfigs = {
            {Setting = Settings.CRTESP, Keyword = "crt", Color = Color3.fromRGB(0, 150, 255), Name = "电脑"},
            {Setting = Settings.PrincipalESP, Keyword = "untrustedadult", Color = Color3.fromRGB(255, 0, 0), Name = "校长"},
            {Setting = Settings.ClockESP, Keyword = "clock", Exclude = "cam", Color = Color3.fromRGB(255, 200, 0), Name = "钟表"},
            {Setting = Settings.DreadEntityESP, Keyword = "dreadentity", Color = Color3.fromRGB(200, 0, 200), Name = "梦魇"},
            {Setting = Settings.PeripheralESP, Keyword = "peripheral", Color = Color3.fromRGB(255, 100, 0), Name = "爬行者"},
        }
        
        for _, config in pairs(espConfigs) do
            if config.Setting then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj.Name then
                        local lowerName = obj.Name:lower()
                        if lowerName:find(config.Keyword) and (not config.Exclude or not lowerName:find(config.Exclude)) then
                            local parentModel = getParentModel(obj)
                            seenObjects[parentModel] = true
                            if not espHighlights[parentModel] then
                                table.insert(newTargets, {Object = parentModel, Color = config.Color, Name = config.Name})
                            end
                        end
                    end
                end
            end
        end
        
        for obj, h in pairs(espHighlights) do
            if not seenObjects[obj] then
                pcall(function() h:Destroy() end)
                espHighlights[obj] = nil
                if espNameTags[obj] then pcall(function() espNameTags[obj]:Destroy() end); espNameTags[obj] = nil end
                espTargets[obj] = nil
            end
        end
        
        for _, target in pairs(newTargets) do
            if target.Object and target.Object.Parent then
                local rootPart = getRoot(target.Object)
                if rootPart then
                    local h = Instance.new("Highlight")
                    h.FillColor = target.Color
                    h.FillTransparency = 0.5
                    h.OutlineColor = target.Color
                    h.OutlineTransparency = 0.3
                    h.Parent = target.Object
                    espHighlights[target.Object] = h
                    
                    local billboard = Instance.new("BillboardGui")
                    billboard.Size = UDim2.new(0, 150, 0, 25)
                    billboard.AlwaysOnTop = true
                    billboard.MaxDistance = 300
                    billboard.Parent = rootPart
                    
                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.Text = target.Name
                    label.TextColor3 = target.Color
                    label.Font = Enum.Font.GothamBold
                    label.TextSize = 13
                    label.TextStrokeTransparency = 0.5
                    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    label.Parent = billboard
                    
                    espNameTags[target.Object] = billboard
                    espTargets[target.Object] = {RootPart = rootPart, Name = target.Name}
                end
            end
        end
        
        isScanning = false
    end)
end

RunService.Heartbeat:Connect(function()
    if not (Settings.CRTESP or Settings.PrincipalESP or Settings.ClockESP or Settings.DreadEntityESP or Settings.PeripheralESP) then
        if next(espHighlights) then clearESP() end
        return
    end
    
    local currentTime = tick()
    
    if currentTime - lastESPScan > 5 then
        lastESPScan = currentTime
        incrementalUpdateESP()
    end
    
    local character = LocalPlayer.Character
    local characterRoot = character and character:FindFirstChild("HumanoidRootPart")
    
    if characterRoot then
        for obj, billboard in pairs(espNameTags) do
            local target = espTargets[obj]
            if target and billboard and billboard.Parent and target.RootPart and target.RootPart.Parent then
                local label = billboard:FindFirstChild("TextLabel")
                if label then
                    local dist = (characterRoot.Position - target.RootPart.Position).Magnitude
                    label.Text = target.Name .. " [" .. math.floor(dist) .. "米]"
                end
            end
        end
    end
end)

-- 调速度
local function setSpeed()
    local player = LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = Settings.SpeedValue
    end
end

RunService.Heartbeat:Connect(function()
    if Settings.SpeedEnabled then setSpeed() end
end)

-- 飞行加载
local function loadFlyScript()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/飞饼"))()
end

-- 自动电脑
local function autoCRT()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    local rootPart = character.HumanoidRootPart
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name and obj.Name:lower():find("crt") then
            local parentModel = getParentModel(obj)
            local rootPart2 = getRoot(parentModel)
            if rootPart2 and not visitedCRTs[parentModel] then
                rootPart.CFrame = CFrame.new(rootPart2.Position + Vector3.new(0, 2, 0))
                visitedCRTs[parentModel] = true
                WindUI:Notify({Title = "自动电脑", Content = "请自己按E", Duration = 2})
                task.wait(3)
                return true
            end
        end
    end
    return false
end

task.spawn(function()
    while true do
        if Settings.AutoCRT then
            autoCRT()
            task.wait(1)
        else
            task.wait(0.5)
        end
    end
end)

-- 自动开门
local function autoDoor()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    local rootPart = character.HumanoidRootPart
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name and obj.Name:lower():find("movingdoor") then
            local parentModel = getParentModel(obj)
            local rootPart2 = getRoot(parentModel)
            if rootPart2 and not visitedDoors[parentModel] then
                local dist = (rootPart.Position - rootPart2.Position).Magnitude
                if dist <= 300 then
                    rootPart.CFrame = CFrame.new(rootPart2.Position + Vector3.new(0, 2, 0))
                    visitedDoors[parentModel] = true
                    WindUI:Notify({Title = "自动开门", Content = "请自己按E", Duration = 2})
                    task.wait(3)
                    return true
                end
            end
        end
    end
    return false
end

task.spawn(function()
    while true do
        if Settings.AutoDoor then
            autoDoor()
            task.wait(1)
        else
            task.wait(0.5)
        end
    end
end)

-- 删除学生
task.spawn(function()
    while true do
        if Settings.DeleteStudents then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj.Name and obj.Name:lower():find("shadowfriend") then
                    pcall(function() obj:Destroy() end)
                end
            end
            task.wait(1)
        else
            task.wait(0.5)
        end
    end
end)

-- 自动收集回忆1
local function autoMemory1()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    local rootPart = character.HumanoidRootPart
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name and obj.Name:lower():find("memoryrecollector") then
            local parentModel = getParentModel(obj)
            local rootPart2 = getRoot(parentModel)
            if rootPart2 and rootPart2:IsA("BasePart") and not visitedMemories1[parentModel] then
                rootPart.CFrame = CFrame.new(rootPart2.Position + Vector3.new(0, 2, 0))
                visitedMemories1[parentModel] = true
                return true
            end
        end
    end
    return false
end

task.spawn(function()
    while true do
        if Settings.AutoMemory1 then
            autoMemory1()
            task.wait(1)
        else
            task.wait(0.5)
        end
    end
end)

-- 自动收集硬币
local function autoCoin()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    local rootPart = character.HumanoidRootPart
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name and obj.Name:lower():find("coinitem") then
            local parentModel = getParentModel(obj)
            local rootPart2 = getRoot(parentModel)
            if rootPart2 and rootPart2:IsA("BasePart") and not visitedCoins[parentModel] then
                rootPart.CFrame = CFrame.new(rootPart2.Position + Vector3.new(0, 2, 0))
                visitedCoins[parentModel] = true
                task.wait(2)
                return true
            end
        end
    end
    return false
end

task.spawn(function()
    while true do
        if Settings.AutoCoin then
            autoCoin()
            task.wait(1)
        else
            task.wait(0.5)
        end
    end
end)

-- 自动收集回忆2
local function autoMemory2()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    local rootPart = character.HumanoidRootPart
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name and obj.Name:lower():find("memoryrecollector") then
            local parentModel = getParentModel(obj)
            local rootPart2 = getRoot(parentModel)
            if rootPart2 and rootPart2:IsA("BasePart") and not visitedMemories2[parentModel] then
                rootPart.CFrame = CFrame.new(rootPart2.Position + Vector3.new(0, 2, 0))
                visitedMemories2[parentModel] = true
                return true
            end
        end
    end
    return false
end

task.spawn(function()
    while true do
        if Settings.AutoMemory2 then
            autoMemory2()
            task.wait(1)
        else
            task.wait(0.5)
        end
    end
end)

-- 半自动通关
local function semiAutoClear()
    if isSemiAutoRunning then return end
    isSemiAutoRunning = true
    
    task.spawn(function()
        teleportTo(Vector3.new(103.8, 194.0, 88.5), "第一步")
        WindUI:Notify({Title = "半自动通关", Content = "请自己按E（5秒）", Duration = 5})
        task.wait(5)
        if not Settings.SemiAutoClear then isSemiAutoRunning = false; return end
        
        teleportTo(Vector3.new(-23.3, 238.5, 148.7), "第二步")
        WindUI:Notify({Title = "半自动通关", Content = "请自己按E（5秒）", Duration = 5})
        task.wait(5)
        if not Settings.SemiAutoClear then isSemiAutoRunning = false; return end
        
        teleportTo(Vector3.new(103.8, 194.0, 88.5), "第三步")
        WindUI:Notify({Title = "半自动通关", Content = "请自己按E（5秒）", Duration = 5})
        task.wait(5)
        if not Settings.SemiAutoClear then isSemiAutoRunning = false; return end
        
        teleportTo(Vector3.new(435.3, 171.0, 171.5), "第四步")
        task.wait(3) -- 改3秒防虚空
        if not Settings.SemiAutoClear then isSemiAutoRunning = false; return end
        
        teleportTo(Vector3.new(405.7, 171.0, 344.7), "第五步")
        task.wait(3) -- 改3秒防虚空
        if not Settings.SemiAutoClear then isSemiAutoRunning = false; return end
        
        teleportTo(Vector3.new(2026.3, 170.9, 357.4), "终点")
        WindUI:Notify({Title = "半自动通关", Content = "可以往前走通关了！", Duration = 5})
        isSemiAutoRunning = false
    end)
end

-- 获得物品
local function pickupItem(itemName)
    local Event = ReplicatedStorage:FindFirstChild("PickupPickupable")
    if not Event then return false end
    
    if itemName == "carrot" then
        pcall(function()
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("PickupableItem") then
                Event:FireServer(character.PickupableItem)
            end
        end)
    elseif itemName == "whiteradish" then
        pcall(function()
            if Workspace:FindFirstChild("Pickupables") and Workspace.Pickupables:FindFirstChild("White Radish") then
                Event:FireServer(Workspace.Pickupables["White Radish"])
            end
        end)
    elseif itemName == "sunflower" then
        pcall(function()
            if Workspace:FindFirstChild("Pickupables") and Workspace.Pickupables:FindFirstChild("Sunflower Seeds") then
                Event:FireServer(Workspace.Pickupables["Sunflower Seeds"])
            end
        end)
    elseif itemName == "mushroom" then
        pcall(function()
            if Workspace:FindFirstChild("Pickupables") and Workspace.Pickupables:FindFirstChild("Mushroom") then
                Event:FireServer(Workspace.Pickupables.Mushroom)
            end
        end)
    end
    return true
end

-- 获得玩具熊
local function getBearPart(part)
    local Event = ReplicatedStorage:FindFirstChild("PickupPickupable")
    if not Event then return false end
    
    if part == 1 or part == 2 then
        pcall(function()
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("PickupableItem") then
                Event:FireServer(character.PickupableItem)
            end
        end)
    elseif part == 3 then
        pcall(function()
            if Workspace:FindFirstChild("Pickupables") and Workspace.Pickupables:FindFirstChild("Stuffed Bear Part 3") then
                Event:FireServer(Workspace.Pickupables["Stuffed Bear Part 3"])
            end
        end)
    elseif part == 4 then
        pcall(function()
            if Workspace:FindFirstChild("Pickupables") and Workspace.Pickupables:FindFirstChild("Stuffed Bear Part 4") then
                Event:FireServer(Workspace.Pickupables["Stuffed Bear Part 4"])
            end
        end)
    end
    return true
end

-- 触发过场动画
local function triggerCutscene(name)
    local Event = ReplicatedStorage:FindFirstChild(name)
    if Event then
        Event:FireServer()
        return true
    end
    return false
end

local Window = WindUI:CreateWindow({
    Title = "黑脚本--破碎之梦",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(400, 350),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true,
})

-- 公告
Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--破碎之梦",
    Desc = "版本: " .. VERSION,
})

-- 第一章
local Chapter1Tab = Window:Tab({Title = "第一章", Icon = "solar:book-bold"})

Chapter1Tab:Paragraph({Title = "云端剧场", Desc = ""})
Chapter1Tab:Toggle({Title = "透视电脑", Value = false, Callback = function(v) Settings.CRTESP = v; if v then incrementalUpdateESP() end end})
Chapter1Tab:Toggle({Title = "自动电脑", Value = false, Callback = function(v) Settings.AutoCRT = v; if v then visitedCRTs = {} end end})

Chapter1Tab:Divider()
Chapter1Tab:Paragraph({Title = "梦境小学", Desc = ""})
Chapter1Tab:Toggle({Title = "透视钟表", Value = false, Callback = function(v) Settings.ClockESP = v; if v then incrementalUpdateESP() end end})
Chapter1Tab:Toggle({Title = "透视校长", Value = false, Callback = function(v) Settings.PrincipalESP = v; if v then incrementalUpdateESP() end end})
Chapter1Tab:Toggle({Title = "开启地下室所有门", Value = false, Callback = function(v) Settings.AutoDoor = v; if v then visitedDoors = {} end end})
Chapter1Tab:Toggle({Title = "删除所有学生", Value = false, Callback = function(v) Settings.DeleteStudents = v end})

Chapter1Tab:Divider()
Chapter1Tab:Paragraph({Title = "绿岸海滩", Desc = ""})
Chapter1Tab:Toggle({Title = "自动收集回忆", Value = false, Callback = function(v) Settings.AutoMemory1 = v; if v then visitedMemories1 = {} end end})

Chapter1Tab:Divider()
Chapter1Tab:Paragraph({Title = "失控之时", Desc = ""})
Chapter1Tab:Toggle({Title = "透视梦魇", Value = false, Callback = function(v) Settings.DreadEntityESP = v; if v then incrementalUpdateESP() end end})
Chapter1Tab:Toggle({Title = "自动收集硬币", Value = false, Callback = function(v) Settings.AutoCoin = v; if v then visitedCoins = {} end end})

-- 第二章
local Chapter2Tab = Window:Tab({Title = "第二章", Icon = "solar:book-bold"})

Chapter2Tab:Paragraph({Title = "家园景观", Desc = ""})
Chapter2Tab:Toggle({Title = "透视爬行者", Value = false, Callback = function(v) Settings.PeripheralESP = v; if v then incrementalUpdateESP() end end})
Chapter2Tab:Button({Title = "传送回忆点", Callback = function() teleportTo(Vector3.new(103.9, 7.0, -975.9), "回忆点") end})
Chapter2Tab:Divider()
Chapter2Tab:Button({Title = "获得玩具熊1", Callback = function() getBearPart(1) end})
Chapter2Tab:Button({Title = "获得玩具熊2", Callback = function() getBearPart(2) end})
Chapter2Tab:Button({Title = "获得玩具熊3", Callback = function() getBearPart(3) end})
Chapter2Tab:Button({Title = "获得玩具熊4", Callback = function() getBearPart(4) end})
Chapter2Tab:Divider()
Chapter2Tab:Toggle({Title = "自动收集回忆", Value = false, Callback = function(v) Settings.AutoMemory2 = v; if v then visitedMemories2 = {} end end})

Chapter2Tab:Divider()
Chapter2Tab:Paragraph({Title = "往昔未来", Desc = ""})
Chapter2Tab:Toggle({Title = "半自动通关", Value = false, Callback = function(v)
    Settings.SemiAutoClear = v
    if v then semiAutoClear() else isSemiAutoRunning = false end
end})

Chapter2Tab:Divider()
Chapter2Tab:Paragraph({Title = "静默林地", Desc = ""})
Chapter2Tab:Button({Title = "获得胡萝卜", Callback = function() pickupItem("carrot") end})
Chapter2Tab:Button({Title = "获得白萝卜", Callback = function() pickupItem("whiteradish") end})
Chapter2Tab:Button({Title = "获得葵花籽", Callback = function() pickupItem("sunflower") end})
Chapter2Tab:Button({Title = "获得蘑菇", Callback = function() pickupItem("mushroom") end})

Chapter2Tab:Divider()
Chapter2Tab:Paragraph({Title = "未定之境", Desc = ""})
Chapter2Tab:Button({Title = "触发过场动画1", Callback = function() triggerCutscene("StartFirstCutscene") end})
Chapter2Tab:Button({Title = "触发过场动画2", Callback = function() triggerCutscene("StartHardIntro") end})
Chapter2Tab:Button({Title = "触发过场动画3", Callback = function() triggerCutscene("StartEndingCutscene") end})

-- 玩家
local PlayerTab = Window:Tab({Title = "玩家", Icon = "solar:user-bold"})

PlayerTab:Toggle({
    Title = "调整速度",
    Value = false,
    Callback = function(v)
        Settings.SpeedEnabled = v
        if v then setSpeed() else
            local player = LocalPlayer
            if player and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = 16
            end
        end
    end
})

PlayerTab:Slider({
    Title = "移动速度",
    Value = {Min = 16, Max = 500, Default = 100},
    Step = 1,
    Callback = function(v) Settings.SpeedValue = v; if Settings.SpeedEnabled then setSpeed() end end
})

PlayerTab:Divider()

PlayerTab:Button({
    Title = "飞行",
    Callback = function()
        loadFlyScript()
        WindUI:Notify({Title = "飞行已加载", Content = "使用远程飞行脚本", Duration = 3})
    end
})

-- 设置
local SettingsTab = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})

local statusParagraph = SettingsTab:Paragraph({Title = "功能状态", Desc = "正在加载..."})

task.spawn(function()
    while true do
        local status = ""
        if Settings.CRTESP then status = status .. "✅ 透视电脑\n" end
        if Settings.AutoCRT then status = status .. "✅ 自动电脑\n" end
        if Settings.ClockESP then status = status .. "✅ 透视钟表\n" end
        if Settings.PrincipalESP then status = status .. "✅ 透视校长\n" end
        if Settings.AutoDoor then status = status .. "✅ 自动开门\n" end
        if Settings.DeleteStudents then status = status .. "✅ 删除学生\n" end
        if Settings.AutoMemory1 then status = status .. "✅ 自动回忆1\n" end
        if Settings.DreadEntityESP then status = status .. "✅ 透视梦魇\n" end
        if Settings.AutoCoin then status = status .. "✅ 自动硬币\n" end
        if Settings.PeripheralESP then status = status .. "✅ 透视爬行者\n" end
        if Settings.AutoMemory2 then status = status .. "✅ 自动回忆2\n" end
        if Settings.SemiAutoClear then status = status .. "✅ 半自动通关\n" end
        if Settings.SpeedEnabled then status = status .. "✅ 调速度(" .. Settings.SpeedValue .. ")\n" end
        if status == "" then status = "所有功能未开启" end
        statusParagraph:SetDesc(status)
        task.wait(1)
    end
end)

SettingsTab:Button({Title = "关闭面板", Callback = function() Window:Close() end})

Window:OnClose(function() clearESP() end)

WindUI:Notify({Title = "破碎之梦", Content = VERSION .. " 加载完成", Duration = 3})
