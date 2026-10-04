-- ============================================
-- House of The Locust - 最终修复版
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- 加载WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
if not WindUI then return end

WindUI:AddTheme({
    Name = "冰白",
    Accent = "#80C0FF",
    Outline = "#6090C0",
    Text = "#FFFFFF",
    Placeholder = "#D0E0FF",
})

-- ESP设置
local ESP = {
    LocustESP = false,
    RedBlockESP = false,
    BlueBlockESP = false,
    YellowBlockESP = false,
    PlayerESP = false,
    BoxESP = false,
}

local espHighlights = {}
local espNameTags = {}
local espTargets = {}

local function clearAllESP()
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

local function getRootPart(model)
    if model:IsA("Model") then
        return model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    elseif model:IsA("BasePart") then
        return model
    end
    return nil
end

local function updateESP()
    clearAllESP()
    
    local targets = {}
    local seenModels = {}
    
    local function addTarget(obj, color, name)
        local parentModel = getParentModel(obj)
        if not seenModels[parentModel] then
            seenModels[parentModel] = true
            local rootPart = getRootPart(parentModel)
            if rootPart then
                table.insert(targets, {
                    Object = parentModel,
                    RootPart = rootPart,
                    Color = color,
                    Name = name,
                })
            end
        end
    end
    
    -- 透视怪物Locust
    if ESP.LocustESP then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name and obj.Name:lower():find("locust") then
                addTarget(obj, Color3.fromRGB(255, 0, 0), "Locust")
            end
        end
    end
    
    -- 透视红色方块（排除Detector）
    if ESP.RedBlockESP then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name and obj.Name:lower():find("red") and not obj.Name:lower():find("detector") then
                addTarget(obj, Color3.fromRGB(255, 60, 60), "红色方块")
            end
        end
    end
    
    -- 透视蓝色方块（排除Detector）
    if ESP.BlueBlockESP then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name and obj.Name:lower():find("blue") and not obj.Name:lower():find("detector") then
                addTarget(obj, Color3.fromRGB(60, 60, 255), "蓝色方块")
            end
        end
    end
    
    -- 透视黄色方块（排除Detector）
    if ESP.YellowBlockESP then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name and obj.Name:lower():find("yellow") and not obj.Name:lower():find("detector") then
                addTarget(obj, Color3.fromRGB(255, 220, 60), "黄色方块")
            end
        end
    end
    
    -- 透视玩家
    if ESP.PlayerESP then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                addTarget(plr.Character, Color3.fromRGB(0, 255, 0), plr.Name)
            end
        end
    end
    
    -- 透视盒子（排除Crates）
    if ESP.BoxESP then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name and (obj.Name:lower():find("box") or obj.Name:lower():find("chest") or obj.Name:lower():find("cabinet")) and not obj.Name:lower():find("crates") then
                addTarget(obj, Color3.fromRGB(255, 150, 0), "盒子")
            end
        end
    end
    
    for _, target in pairs(targets) do
        if target.Object and target.Object.Parent then
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
            billboard.MaxDistance = 500
            billboard.Parent = target.RootPart
            
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
            espTargets[target.Object] = target
        end
    end
end

RunService.Heartbeat:Connect(function()
    local anyESP = ESP.LocustESP or ESP.RedBlockESP or ESP.BlueBlockESP or ESP.YellowBlockESP or ESP.PlayerESP or ESP.BoxESP
    
    if not anyESP then
        if next(espHighlights) then
            clearAllESP()
        end
        return
    end
    
    local character = LocalPlayer.Character
    local characterRoot = character and character:FindFirstChild("HumanoidRootPart")
    
    if characterRoot then
        for obj, billboard in pairs(espNameTags) do
            local target = espTargets[obj]
            if target and billboard and billboard.Parent and target.RootPart and target.RootPart.Parent then
                local label = billboard:FindFirstChild("TextLabel")
                if label then
                    local distance = (characterRoot.Position - target.RootPart.Position).Magnitude
                    label.Text = target.Name .. " [" .. math.floor(distance) .. "米]"
                end
            else
                if espHighlights[obj] then pcall(function() espHighlights[obj]:Destroy() end); espHighlights[obj] = nil end
                if espNameTags[obj] then pcall(function() espNameTags[obj]:Destroy() end); espNameTags[obj] = nil end
                espTargets[obj] = nil
            end
        end
    end
end)

task.spawn(function()
    while true do
        updateESP()
        task.wait(2)
    end
end)

-- 调整速度
local speedEnabled = false
local speedValue = 100

local function setSpeed()
    local player = LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = speedValue
    end
end

RunService.Heartbeat:Connect(function()
    if speedEnabled then
        setSpeed()
    end
end)

-- 传送函数
local function teleportToPlayer(targetPlayer)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(targetPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
    end
end

local function teleportToBlock(colorName)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name and obj.Name:lower():find(colorName:lower()) and not obj.Name:lower():find("detector") then
            local rootPart = getRootPart(obj)
            if rootPart then
                character.HumanoidRootPart.CFrame = CFrame.new(rootPart.Position + Vector3.new(0, 3, 0))
                return true
            end
        end
    end
    return false
end

-- FPS计算
local fps = 0
local frameCount = 0
local lastFpsUpdate = tick()

RunService.Heartbeat:Connect(function()
    frameCount = frameCount + 1
    local currentTime = tick()
    if currentTime - lastFpsUpdate >= 1 then
        fps = frameCount
        frameCount = 0
        lastFpsUpdate = currentTime
    end
end)

-- WindUI窗口
local Window = WindUI:CreateWindow({
    Title = "蝗虫之屋",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(400, 350),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true,
})

-- 公告
Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "House of The Locust",
    Desc = "黑脚本--支持功能：\n\n• 透视怪物Locust\n• 透视红蓝黄方块\n• 透视玩家\n• 透视盒子\n• 调整速度\n• 传送玩家\n• 传送红蓝黄方块",
})

-- 透视
local ESPTab = Window:Tab({Title = "透视", Icon = "solar:eye-bold"})

ESPTab:Toggle({Title = "透视怪物Locust", Value = false, Callback = function(enabled) ESP.LocustESP = enabled; updateESP() end})
ESPTab:Toggle({Title = "透视红色方块", Value = false, Callback = function(enabled) ESP.RedBlockESP = enabled; updateESP() end})
ESPTab:Toggle({Title = "透视蓝色方块", Value = false, Callback = function(enabled) ESP.BlueBlockESP = enabled; updateESP() end})
ESPTab:Toggle({Title = "透视黄色方块", Value = false, Callback = function(enabled) ESP.YellowBlockESP = enabled; updateESP() end})
ESPTab:Toggle({Title = "透视玩家", Value = false, Callback = function(enabled) ESP.PlayerESP = enabled; updateESP() end})
ESPTab:Toggle({Title = "透视盒子", Value = false, Callback = function(enabled) ESP.BoxESP = enabled; updateESP() end})

-- 玩家
local PlayerTab = Window:Tab({Title = "玩家", Icon = "solar:user-bold"})

PlayerTab:Toggle({
    Title = "调整速度",
    Value = false,
    Callback = function(enabled)
        speedEnabled = enabled
        if enabled then setSpeed() else
            local player = LocalPlayer
            if player and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = 16
            end
        end
    end
})

PlayerTab:Slider({
    Title = "移动速度 (16-200)",
    Value = {Min = 16, Max = 200, Default = 100},
    Step = 1,
    Callback = function(speed) speedValue = speed; if speedEnabled then setSpeed() end end
})

PlayerTab:Divider()

local playerNames = {}
for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then table.insert(playerNames, plr.Name) end
end
if #playerNames == 0 then table.insert(playerNames, "无其他玩家") end

local selectedPlayer = playerNames[1] or "无其他玩家"

PlayerTab:Dropdown({
    Title = "选择玩家",
    Values = playerNames,
    Value = selectedPlayer,
    Callback = function(v) selectedPlayer = v end
})

PlayerTab:Button({
    Title = "传送到该玩家",
    Callback = function()
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Name == selectedPlayer then
                teleportToPlayer(plr)
                WindUI:Notify({Title = "传送成功", Content = "已传送到" .. plr.Name, Duration = 2})
                return
            end
        end
        WindUI:Notify({Title = "失败", Content = "找不到该玩家", Duration = 2})
    end
})

PlayerTab:Button({
    Title = "传送红色方块",
    Callback = function()
        if teleportToBlock("red") then WindUI:Notify({Title = "成功", Content = "已传送", Duration = 2}) else WindUI:Notify({Title = "失败", Content = "找不到", Duration = 2}) end
    end
})

PlayerTab:Button({
    Title = "传送蓝色方块",
    Callback = function()
        if teleportToBlock("blue") then WindUI:Notify({Title = "成功", Content = "已传送", Duration = 2}) else WindUI:Notify({Title = "失败", Content = "找不到", Duration = 2}) end
    end
})

PlayerTab:Button({
    Title = "传送黄色方块",
    Callback = function()
        if teleportToBlock("yellow") then WindUI:Notify({Title = "成功", Content = "已传送", Duration = 2}) else WindUI:Notify({Title = "失败", Content = "找不到", Duration = 2}) end
    end
})

-- 设置
local SettingsTab = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})

local statusParagraph = SettingsTab:Paragraph({
    Title = "功能状态",
    Desc = "加载中...",
})

task.spawn(function()
    while true do
        local status = ""
        if ESP.LocustESP then status = status .. "✅ 透视怪物\n" else status = status .. "❌ 透视怪物\n" end
        if ESP.RedBlockESP then status = status .. "✅ 透视红方块\n" else status = status .. "❌ 透视红方块\n" end
        if ESP.BlueBlockESP then status = status .. "✅ 透视蓝方块\n" else status = status .. "❌ 透视蓝方块\n" end
        if ESP.YellowBlockESP then status = status .. "✅ 透视黄方块\n" else status = status .. "❌ 透视黄方块\n" end
        if ESP.PlayerESP then status = status .. "✅ 透视玩家\n" else status = status .. "❌ 透视玩家\n" end
        if ESP.BoxESP then status = status .. "✅ 透视盒子\n" else status = status .. "❌ 透视盒子\n" end
        if speedEnabled then status = status .. "✅ 调整速度 (" .. speedValue .. ")\n" else status = status .. "❌ 调整速度\n" end
        status = status .. "FPS: " .. fps
        statusParagraph:SetDesc(status)
        task.wait(1)
    end
end)

SettingsTab:Button({
    Title = "关闭面板",
    Callback = function() Window:Close() end
})

WindUI:Notify({
    Title = "蝗虫之屋",
    Content = "加载完成",
    Duration = 3
})
