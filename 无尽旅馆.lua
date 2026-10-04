-- 无尽旅馆 脚本 v1.0.16
-- WindUI蓝白版 | 透视物品

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
local Camera = Workspace.CurrentCamera

local VERSION = "v1.0.16"
local espEnabled = false
local espGhost = false
local espHighlights = {}
local espTags = {}
local showDist = false
local speedEnabled = false
local speedValue = 16
local isFlying = false
local flyConnection = nil

local refreshPoints = {
    Vector3.new(-187.1, 44.2, 333.7),
    Vector3.new(-190.1, 44.0, 259.5),
    Vector3.new(-71.7, 41.2, 217.1),
    Vector3.new(-24.3, 42.9, 344.7),
    Vector3.new(-151.6, 45.3, 379.5),
}

local itemColors = {
    key = Color3.fromRGB(255, 215, 0),
    safe = Color3.fromRGB(0, 255, 200),
    box2 = Color3.fromRGB(100, 200, 255),
    pea = Color3.fromRGB(50, 255, 50),
    coin = Color3.fromRGB(255, 200, 50),
    hintpaper = Color3.fromRGB(200, 150, 255),
    chest = Color3.fromRGB(150, 100, 50),
}
local ghostColor = Color3.fromRGB(255, 0, 0)

local function clearESP()
    for _, h in pairs(espHighlights) do pcall(function() h:Destroy() end) end
    for _, t in pairs(espTags) do pcall(function() t:Destroy() end) end
    table.clear(espHighlights)
    table.clear(espTags)
end

local function startFlyTo(targetPos)
    if isFlying then return end
    isFlying = true
    
    local char = LocalPlayer.Character
    if not char then
        isFlying = false
        return
    end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        isFlying = false
        return
    end
    
    local startPos = hrp.Position
    local dist = (targetPos - startPos).Magnitude
    local speed = 300
    local steps = math.max(10, math.floor(dist / speed * 60))
    
    for i = 0, steps do
        if not isFlying then break end
        local t = i / steps
        local currentPos = startPos + (targetPos - startPos) * t
        hrp.CFrame = CFrame.new(currentPos)
        task.wait()
    end
    
    hrp.CFrame = CFrame.new(targetPos)
    isFlying = false
end

local function flyRefreshRooms()
    local char = LocalPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local startPos = hrp.Position
    
    WindUI:Notify({Title = "刷新房间", Content = "开始飞行...", Duration = 2})
    
    for _, point in pairs(refreshPoints) do
        startFlyTo(point)
        task.wait(0.3)
    end
    
    startFlyTo(startPos)
    WindUI:Notify({Title = "刷新完成", Content = "已回到起点", Duration = 2})
end

local function scanAndESP()
    if not espEnabled and not espGhost then
        clearESP()
        return
    end
    
    local myPos = nil
    local myY = nil
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        myPos = LocalPlayer.Character.HumanoidRootPart.Position
        myY = myPos.Y
    end
    
    local blockPos = Vector3.new(291.6, 8.4, 645.0)
    local blockRadius = 30
    
    local foundKeys = {}
    local foundSafes = {}
    local foundCoins = {}
    local ghostY = math.huge
    local closestGhost = nil
    local ghostDist = math.huge
    
    if espGhost then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") or obj:IsA("BasePart") then
                local nameLower = obj.Name:lower()
                if nameLower:find("monster_") then
                    local rootPart = nil
                    if obj:IsA("Model") then
                        rootPart = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                    elseif obj:IsA("BasePart") then
                        rootPart = obj
                    end
                    if rootPart and myY and myPos then
                        local dist = (myPos - rootPart.Position).Magnitude
                        if dist > 1000 then
                            -- skip
                        else
                            local distY = math.abs(myY - rootPart.Position.Y)
                            if distY < ghostY then
                                ghostY = distY
                                closestGhost = {obj = obj, rootPart = rootPart}
                                ghostDist = dist
                            end
                        end
                    end
                end
            end
        end
    end
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local name = obj.Name
            local nameLower = name:lower()
            
            local isTarget = false
            local displayName = name
            local useColor = Color3.fromRGB(255, 255, 255)
            local dist = nil
            
            local rootPart = nil
            if obj:IsA("Model") then
                rootPart = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            elseif obj:IsA("BasePart") then
                rootPart = obj
            end
            
            if rootPart then
                local distToBlock = (rootPart.Position - blockPos).Magnitude
                if distToBlock < blockRadius then
                    -- skip
                else
                    if myPos then
                        dist = math.floor((myPos - rootPart.Position).Magnitude)
                    end
                    
                    if espEnabled then
                        if nameLower == "key" then
                            if foundKeys["钥匙"] then
                                -- skip
                            else
                                isTarget = true
                                foundKeys["钥匙"] = true
                                displayName = "🔑 钥匙"
                                useColor = itemColors.key
                            end
                        elseif nameLower:find("safe") or nameLower:find("保险箱") then
                            if foundSafes["保险箱"] then
                                -- skip
                            else
                                isTarget = true
                                foundSafes["保险箱"] = true
                                displayName = "🔒 保险箱"
                                useColor = itemColors.safe
                            end
                        elseif nameLower:find("box2") then
                            isTarget = true
                            displayName = "📦 箱子"
                            useColor = itemColors.box2
                        elseif nameLower:find("pea") then
                            isTarget = true
                            displayName = "🟢 豆子"
                            useColor = itemColors.pea
                        elseif nameLower:find("coin") then
                            if foundCoins["硬币"] then
                                -- skip
                            else
                                isTarget = true
                                foundCoins["硬币"] = true
                                displayName = "🪙 硬币"
                                useColor = itemColors.coin
                            end
                        elseif nameLower:find("hintpaper") then
                            isTarget = true
                            displayName = "📄 提示纸"
                            useColor = itemColors.hintpaper
                        elseif nameLower:find("chest") or nameLower:find("箱子") then
                            isTarget = true
                            displayName = "📦 箱子"
                            useColor = itemColors.chest
                        end
                    end
                    
                    if espGhost and closestGhost and obj == closestGhost.obj then
                        isTarget = true
                        displayName = "👻 鬼"
                        useColor = ghostColor
                        dist = math.floor(ghostDist)
                    end
                    
                    if isTarget and not espHighlights[obj] then
                        local h = Instance.new("Highlight")
                        h.FillColor = useColor
                        h.FillTransparency = 0.4
                        h.OutlineColor = useColor
                        h.OutlineTransparency = 0.2
                        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        h.Parent = obj
                        espHighlights[obj] = h
                        
                        local bg = Instance.new("BillboardGui")
                        bg.Size = UDim2.new(0, 180, 0, 40)
                        bg.AlwaysOnTop = true
                        bg.MaxDistance = math.huge
                        bg.Parent = rootPart
                        
                        local label = Instance.new("TextLabel")
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 1
                        label.Text = displayName
                        label.TextColor3 = useColor
                        label.Font = Enum.Font.GothamBold
                        label.TextSize = 14
                        label.TextStrokeTransparency = 0.5
                        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        label.Parent = bg
                        
                        if showDist and dist then
                            local distLabel = Instance.new("TextLabel")
                            distLabel.Size = UDim2.new(1, 0, 0, 16)
                            distLabel.Position = UDim2.new(0, 0, 0.6, 0)
                            distLabel.BackgroundTransparency = 1
                            distLabel.Text = dist .. "m"
                            distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                            distLabel.Font = Enum.Font.Gotham
                            distLabel.TextSize = 12
                            distLabel.TextStrokeTransparency = 0.5
                            distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                            distLabel.Parent = bg
                        end
                        
                        espTags[obj] = bg
                    end
                end
            end
        end
    end
end

task.spawn(function()
    while true do
        pcall(scanAndESP)
        task.wait(2)
    end
end)

task.spawn(function()
    while true do
        if speedEnabled then
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = speedValue
                end
            end
        end
        task.wait(0.3)
    end
end)

local Window = WindUI:CreateWindow({
    Title = "无尽旅馆",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(600, 350),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true,
    Background = "https://i.ibb.co/5xB47QLN/IMG-5677.jpg",
    BackgroundImageTransparency = 0.42,
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "无尽旅馆 v1.0.16",
    Desc = "功能：透视物品 | 透视鬼 | 刷新房间(飞行) | 显示距离 | 调整速度"
})

local MainTab = Window:Tab({Title = "主要功能", Icon = "solar:star-bold"})

MainTab:Toggle({
    Title = "透视物品",
    Value = false,
    Callback = function(v)
        espEnabled = v
        if not v and not espGhost then
            clearESP()
        end
    end
})

MainTab:Divider()

MainTab:Toggle({
    Title = "透视鬼",
    Value = false,
    Callback = function(v)
        espGhost = v
        if not v and not espEnabled then
            clearESP()
        end
    end
})

MainTab:Divider()

MainTab:Toggle({
    Title = "显示距离",
    Value = false,
    Callback = function(v)
        showDist = v
    end
})

MainTab:Divider()

MainTab:Toggle({
    Title = "调整速度",
    Value = false,
    Callback = function(v)
        speedEnabled = v
    end
})

MainTab:Slider({
    Title = "速度值",
    Value = {Min = 16, Max = 200, Default = 16},
    Step = 1,
    Callback = function(v)
        speedValue = v
    end
})

MainTab:Divider()

MainTab:Button({
    Title = "刷新所有房间",
    Callback = function()
        flyRefreshRooms()
    end
})

local SettingsTab = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})
local statusPara = SettingsTab:Paragraph({Title = "功能状态", Desc = "加载中..."})

task.spawn(function()
    while true do
        local status = ""
        status = status .. "透视物品: " .. (espEnabled and "✅" or "❌") .. "\n"
        status = status .. "透视鬼: " .. (espGhost and "✅" or "❌") .. "\n"
        status = status .. "显示距离: " .. (showDist and "✅" or "❌") .. "\n"
        status = status .. "调整速度: " .. (speedEnabled and ("✅ " .. speedValue) or "❌") .. "\n"
        status = status .. "帧率: " .. math.floor(1 / task.wait()) .. " FPS"
        statusPara:SetDesc(status)
        task.wait(1)
    end
end)

SettingsTab:Button({
    Title = "关闭面板",
    Callback = function()
        Window:Close()
    end
})

Window:OnClose(function()
    clearESP()
    isFlying = false
end)

WindUI:Notify({
    Title = "无尽旅馆",
    Content = "v1.0.16 加载完成",
    Duration = 3
})
