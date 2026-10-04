-- 寻找菜鸟变身 脚本 v1.1.0
-- WindUI蓝白版 | 自动捡硬币 | 自动寻找菜鸟 | 透视菜鸟 | 保护模式

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

local Settings = {
    AutoCoinEnabled = false,
    CoinDelay = 1,
    AutoNoobieEnabled = false,
    NoobieDelay = 1,
    NoobieESP = false,
    ProtectMode = true,
    MaxTeleportsBeforePause = 5,
    PauseDuration = 30,
}

local VERSION = "v1.1.0"
local lastCoinTime = 0
local lastNoobieTime = 0
local visitedCoins = {}
local visitedNoobies = {}
local teleportCount = 0
local isPaused = false
local pauseEndTime = 0
local espHighlights = {}
local espNameTags = {}
local espTargets = {}
local lastESPScan = 0
local isScanning = false

-- 获取根部件
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

-- 获取所有Coin
local function getAllCoins()
    local coins = {}
    local seenModels = {}
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name and obj.Name:lower():find("coin") then
            local parentModel = getParentModel(obj)
            if not seenModels[parentModel] then
                seenModels[parentModel] = true
                local rootPart = getRoot(parentModel)
                if rootPart then
                    table.insert(coins, {Object = parentModel, RootPart = rootPart, Position = rootPart.Position})
                end
            end
        end
    end
    
    pcall(function()
        for _, obj in getnilinstances() do
            if obj.Name and obj.Name:lower():find("coin") then
                table.insert(coins, {Object = obj, RootPart = obj, Position = obj.Position})
            end
        end
    end)
    
    return coins
end

-- 获取所有Noobie
local function getAllNoobies()
    local noobies = {}
    local seenModels = {}
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name and obj.Name:lower():find("noobie") and not obj.Name:lower():find("coin") then
            local parentModel = getParentModel(obj)
            if not seenModels[parentModel] then
                seenModels[parentModel] = true
                local rootPart = getRoot(parentModel)
                if rootPart then
                    table.insert(noobies, {Object = parentModel, RootPart = rootPart, Position = rootPart.Position})
                end
            end
        end
    end
    
    pcall(function()
        for _, obj in getnilinstances() do
            if obj.Name and obj.Name:lower():find("noobie") and not obj.Name:lower():find("coin") then
                table.insert(noobies, {Object = obj, RootPart = obj, Position = obj.Position})
            end
        end
    end)
    
    return noobies
end

-- 检查是否在暂停中
local function checkPause()
    if not Settings.ProtectMode then return false end
    
    if isPaused then
        if tick() >= pauseEndTime then
            isPaused = false
            teleportCount = 0
            WindUI:Notify({Title = "保护模式", Content = "暂停结束，继续传送", Duration = 3})
            return false
        end
        return true
    end
    
    if teleportCount >= Settings.MaxTeleportsBeforePause then
        isPaused = true
        pauseEndTime = tick() + Settings.PauseDuration
        WindUI:Notify({
            Title = "⚠️ 保护模式",
            Content = "已传送" .. teleportCount .. "次，暂停" .. Settings.PauseDuration .. "秒",
            Duration = 5
        })
        return true
    end
    
    return false
end

-- 自动捡硬币
local function autoCollectCoin()
    if checkPause() then return false end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    
    local rootPart = character.HumanoidRootPart
    local coins = getAllCoins()
    
    if #coins == 0 then return false end
    
    local target = nil
    for _, coin in pairs(coins) do
        if not visitedCoins[coin.Object] then
            target = coin
            break
        end
    end
    
    if not target then
        visitedCoins = {}
        target = coins[1]
    end
    
    if target and target.RootPart and target.RootPart.Parent then
        rootPart.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
        visitedCoins[target.Object] = true
        teleportCount = teleportCount + 1
        return true
    end
    
    return false
end

-- 自动寻找菜鸟
local function autoFindNoobie()
    if checkPause() then return false end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    
    local rootPart = character.HumanoidRootPart
    local noobies = getAllNoobies()
    
    if #noobies == 0 then return false end
    
    local target = nil
    for _, noobie in pairs(noobies) do
        if not visitedNoobies[noobie.Object] then
            target = noobie
            break
        end
    end
    
    if not target then
        return false
    end
    
    if target and target.RootPart and target.RootPart.Parent then
        rootPart.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
        visitedNoobies[target.Object] = true
        teleportCount = teleportCount + 1
        return true
    end
    
    return false
end

-- 自动捡硬币循环
task.spawn(function()
    while true do
        if Settings.AutoCoinEnabled then
            local currentTime = tick()
            if currentTime - lastCoinTime >= Settings.CoinDelay then
                autoCollectCoin()
                lastCoinTime = currentTime
            end
        end
        task.wait(0.1)
    end
end)

-- 自动寻找菜鸟循环
task.spawn(function()
    while true do
        if Settings.AutoNoobieEnabled then
            local currentTime = tick()
            if currentTime - lastNoobieTime >= Settings.NoobieDelay then
                autoFindNoobie()
                lastNoobieTime = currentTime
            end
        end
        task.wait(0.1)
    end
end)

-- 清理ESP
local function clearESP()
    for _, h in pairs(espHighlights) do
        pcall(function() h:Destroy() end)
    end
    for _, t in pairs(espNameTags) do
        pcall(function() t:Destroy() end)
    end
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
        
        if Settings.NoobieESP then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj.Name and obj.Name:lower():find("noobie") and not obj.Name:lower():find("coin") then
                    local parentModel = getParentModel(obj)
                    seenObjects[parentModel] = true
                    if not espHighlights[parentModel] then
                        table.insert(newTargets, {
                            Object = parentModel,
                            Color = Color3.fromRGB(0, 255, 0),
                            Name = "菜鸟",
                        })
                    end
                end
            end
        end
        
        for obj, h in pairs(espHighlights) do
            if not seenObjects[obj] then
                pcall(function() h:Destroy() end)
                espHighlights[obj] = nil
                if espNameTags[obj] then
                    pcall(function() espNameTags[obj]:Destroy() end)
                    espNameTags[obj] = nil
                end
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
                    billboard.Size = UDim2.new(0, 200, 0, 25)
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
    if not Settings.NoobieESP then
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

local Window = WindUI:CreateWindow({
    Title = "黑脚本--寻找菜鸟变身",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(400, 350),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true,
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--寻找菜鸟变身",
    Desc = "版本: " .. VERSION .. "\n\n⚠️ 警告：传送10次以上可能被封禁！\n请开启保护模式谨慎使用！",
})

-- 主要
local MainTab = Window:Tab({Title = "主要", Icon = "solar:star-bold"})

MainTab:Paragraph({
    Title = "⚠️ 封禁警告",
    Desc = "传送10次以上有被封禁风险！\n保护模式会在5次后暂停30秒。",
})

MainTab:Toggle({
    Title = "保护模式",
    Value = true,
    Callback = function(v) Settings.ProtectMode = v end
})

MainTab:Divider()

MainTab:Toggle({
    Title = "自动捡硬币",
    Value = false,
    Callback = function(v)
        Settings.AutoCoinEnabled = v
        if v then
            visitedCoins = {}
            teleportCount = 0
            isPaused = false
        end
    end
})

MainTab:Slider({
    Title = "硬币延迟 (0.5-5秒)",
    Value = {Min = 0.5, Max = 5, Default = 1},
    Step = 0.5,
    Callback = function(v) Settings.CoinDelay = v end
})

MainTab:Divider()

MainTab:Toggle({
    Title = "自动寻找菜鸟",
    Value = false,
    Callback = function(v)
        Settings.AutoNoobieEnabled = v
        if v then
            visitedNoobies = {}
            teleportCount = 0
            isPaused = false
        end
    end
})

MainTab:Slider({
    Title = "菜鸟延迟 (0.5-5秒)",
    Value = {Min = 0.5, Max = 5, Default = 1},
    Step = 0.5,
    Callback = function(v) Settings.NoobieDelay = v end
})

-- 透视
local ESPTab = Window:Tab({Title = "透视", Icon = "solar:eye-bold"})

ESPTab:Toggle({
    Title = "透视菜鸟",
    Value = false,
    Callback = function(v)
        Settings.NoobieESP = v
        if v then incrementalUpdateESP() end
    end
})

-- 设置
local SettingsTab = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})

local statusParagraph = SettingsTab:Paragraph({
    Title = "功能状态",
    Desc = "正在加载..."
})

task.spawn(function()
    while true do
        local status = ""
        if Settings.ProtectMode then status = status .. "✅ 保护模式: 已开启\n" else status = status .. "❌ 保护模式: 未开启\n" end
        if Settings.AutoCoinEnabled then status = status .. "✅ 自动捡硬币: 已开启\n" else status = status .. "❌ 自动捡硬币: 未开启\n" end
        if Settings.AutoNoobieEnabled then status = status .. "✅ 自动寻找菜鸟: 已开启\n" else status = status .. "❌ 自动寻找菜鸟: 未开启\n" end
        if Settings.NoobieESP then status = status .. "✅ 透视菜鸟: 已开启\n" else status = status .. "❌ 透视菜鸟: 未开启\n" end
        if isPaused then
            local remaining = math.max(0, pauseEndTime - tick())
            status = status .. "⏸️ 暂停中: " .. math.floor(remaining) .. "秒后继续\n"
        else
            status = status .. "传送次数: " .. teleportCount .. "/" .. Settings.MaxTeleportsBeforePause .. "\n"
        end
        statusParagraph:SetDesc(status)
        task.wait(1)
    end
end)

SettingsTab:Button({
    Title = "关闭面板",
    Callback = function() Window:Close() end
})

Window:OnClose(function() clearESP() end)

WindUI:Notify({
    Title = "寻找菜鸟变身",
    Content = VERSION .. " 加载完成",
    Duration = 3
})
