-- 神秘的杀手 脚本 v1.0.6
-- WindUI蓝白版 | 透视职业 | 传送 | 自动收集硬币

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
    SheriffESP = false,
    KillerESP = false,
    CivilianESP = false,
    AutoCoinEnabled = false,
    CoinDelay = 1,
}

local VERSION = "v1.0.6"
local espHighlights = {}
local espNameTags = {}
local espTargets = {}
local lastESPScan = 0
local isScanning = false
local lastCoinTime = 0
local visitedCoins = {}

-- 获取玩家职业（搜索整个角色包括背包和装饰）
local function getPlayerRole(player)
    -- 收集所有Tool的名字
    local toolNames = {}
    
    -- 背包
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                table.insert(toolNames, item.Name:lower())
            end
        end
    end
    
    -- 角色手上
    if player.Character then
        for _, item in pairs(player.Character:GetChildren()) do
            if item:IsA("Tool") then
                table.insert(toolNames, item.Name:lower())
            end
        end
    end
    
    -- 检查杀手（knife/kn/fe）
    for _, name in pairs(toolNames) do
        if name:find("knife") or name:find("kn") or name:find("fe") or name:find("shiv") or name:find("blade") then
            return "Killer"
        end
    end
    
    -- 检查警长（gun/shark/枪等）
    for _, name in pairs(toolNames) do
        if name:find("gun") or name:find("pistol") or name:find("revolver") or 
           name:find("shark") or name:find("鲨鱼") or name:find("枪") or
           name:find("rifle") or name:find("shotgun") or name:find("weapon") then
            return "Sheriff"
        end
    end
    
    -- 没有武器 = 平民
    return "Civilian"
end

local function getRoleInfo(role)
    if role == "Sheriff" then
        return "警长", Color3.fromRGB(0, 100, 255)
    elseif role == "Killer" then
        return "杀手", Color3.fromRGB(255, 0, 0)
    elseif role == "Civilian" then
        return "平民", Color3.fromRGB(0, 255, 0)
    end
    return "未知", Color3.fromRGB(200, 200, 200)
end

local function getRoot(obj)
    if obj:IsA("Model") then
        return obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
    elseif obj:IsA("BasePart") then
        return obj
    end
    return nil
end

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

local function incrementalUpdateESP()
    if isScanning then return end
    isScanning = true
    
    task.spawn(function()
        local seenObjects = {}
        local newTargets = {}
        
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local role = getPlayerRole(plr)
                local roleName, roleColor = getRoleInfo(role)
                
                local shouldShow = false
                
                if Settings.SheriffESP and roleName == "警长" then
                    shouldShow = true
                elseif Settings.KillerESP and roleName == "杀手" then
                    shouldShow = true
                elseif Settings.CivilianESP and roleName == "平民" then
                    shouldShow = true
                end
                
                if shouldShow then
                    seenObjects[plr.Character] = true
                    
                    -- 检查是否需要更新颜色（职业可能变化）
                    if espHighlights[plr.Character] then
                        espHighlights[plr.Character].FillColor = roleColor
                        espHighlights[plr.Character].OutlineColor = roleColor
                        if espNameTags[plr.Character] then
                            local label = espNameTags[plr.Character]:FindFirstChild("TextLabel")
                            if label then
                                label.TextColor3 = roleColor
                                espTargets[plr.Character].Name = roleName .. " " .. plr.Name
                            end
                        end
                    else
                        table.insert(newTargets, {
                            Object = plr.Character,
                            Color = roleColor,
                            Name = roleName .. " " .. plr.Name,
                        })
                    end
                end
            end
        end
        
        -- 移除不在列表中的ESP
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
        
        -- 添加新ESP
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

-- ESP循环（每2秒刷新，并检查玩家加入/离开）
local function updateESP()
    local anyESP = Settings.SheriffESP or Settings.KillerESP or Settings.CivilianESP
    
    if not anyESP then
        if next(espHighlights) then clearESP() end
        return
    end
    
    local currentTime = tick()
    
    if currentTime - lastESPScan > 2 then
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
end

RunService.Heartbeat:Connect(updateESP)

-- 玩家加入时立即刷新
Players.PlayerAdded:Connect(function()
    lastESPScan = 0
end)

-- 玩家离开时清理
Players.PlayerRemoving:Connect(function(plr)
    if espHighlights[plr.Character] then
        pcall(function() espHighlights[plr.Character]:Destroy() end)
        espHighlights[plr.Character] = nil
    end
    if espNameTags[plr.Character] then
        pcall(function() espNameTags[plr.Character]:Destroy() end)
        espNameTags[plr.Character] = nil
    end
    espTargets[plr.Character] = nil
end)

-- CoinContainer收集
local function getAllCoinContainers()
    local containers = {}
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "CoinContainer" then
            local rootPart = getRoot(obj)
            if rootPart then
                table.insert(containers, {Object = obj, RootPart = rootPart, Position = rootPart.Position})
            end
        end
    end
    
    pcall(function()
        for _, obj in getnilinstances() do
            if obj.Name == "CoinContainer" then
                table.insert(containers, {Object = obj, RootPart = obj, Position = obj.Position})
            end
        end
    end)
    
    return containers
end

local function autoCollectCoin()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    
    local rootPart = character.HumanoidRootPart
    local containers = getAllCoinContainers()
    
    if #containers == 0 then return false end
    
    local target = nil
    for _, container in pairs(containers) do
        if not visitedCoins[container.Object] then
            target = container
            break
        end
    end
    
    if not target then
        visitedCoins = {}
        target = containers[1]
    end
    
    if target and target.RootPart and target.RootPart.Parent then
        rootPart.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
        visitedCoins[target.Object] = true
        return true
    end
    
    return false
end

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

local function getCivilians()
    local civilians = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if getPlayerRole(plr) == "Civilian" then
                table.insert(civilians, plr)
            end
        end
    end
    return civilians
end

local function getSheriffs()
    local sheriffs = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if getPlayerRole(plr) == "Sheriff" then
                table.insert(sheriffs, plr)
            end
        end
    end
    return sheriffs
end

local function teleportToCivilian()
    local civilians = getCivilians()
    if #civilians == 0 then
        WindUI:Notify({Title = "未找到", Content = "没有平民", Duration = 2})
        return
    end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local target = civilians[1]
    character.HumanoidRootPart.CFrame = CFrame.new(target.Character.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
    WindUI:Notify({Title = "传送成功", Content = "已传送到平民 " .. target.Name, Duration = 2})
end

local function teleportToSheriff()
    local sheriffs = getSheriffs()
    if #sheriffs == 0 then
        WindUI:Notify({Title = "未找到", Content = "没有警长", Duration = 2})
        return
    end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local target = sheriffs[1]
    character.HumanoidRootPart.CFrame = CFrame.new(target.Character.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
    WindUI:Notify({Title = "传送成功", Content = "已传送到警长 " .. target.Name, Duration = 2})
end

local Window = WindUI:CreateWindow({
    Title = "神秘的杀手",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(400, 350),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true,
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--神秘的杀手",
    Desc = "版本: " .. VERSION,
})

local MainTab = Window:Tab({Title = "主要", Icon = "solar:star-bold"})

MainTab:Toggle({Title = "自动收集硬币", Value = false, Callback = function(v) Settings.AutoCoinEnabled = v; if v then visitedCoins = {} end end})
MainTab:Slider({Title = "收集延迟 (0.5-5秒)", Value = {Min = 0.5, Max = 5, Default = 1}, Step = 0.5, Callback = function(v) Settings.CoinDelay = v end})

local ESPTab = Window:Tab({Title = "透视", Icon = "solar:eye-bold"})

ESPTab:Toggle({Title = "透视警长", Value = false, Callback = function(v) Settings.SheriffESP = v; if v then lastESPScan = 0 end end})
ESPTab:Toggle({Title = "透视杀手", Value = false, Callback = function(v) Settings.KillerESP = v; if v then lastESPScan = 0 end end})
ESPTab:Toggle({Title = "透视平民", Value = false, Callback = function(v) Settings.CivilianESP = v; if v then lastESPScan = 0 end end})

local KillerTab = Window:Tab({Title = "杀手专属", Icon = "solar:star-bold"})

KillerTab:Button({Title = "传送平民", Callback = function() teleportToCivilian() end})
KillerTab:Button({Title = "传送警长", Callback = function() teleportToSheriff() end})

local SettingsTab = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})

local statusParagraph = SettingsTab:Paragraph({Title = "功能状态", Desc = "正在加载..."})

task.spawn(function()
    while true do
        local status = ""
        if Settings.AutoCoinEnabled then status = status .. "✅ 自动收集硬币: 已开启\n" else status = status .. "❌ 自动收集硬币: 未开启\n" end
        if Settings.SheriffESP then status = status .. "✅ 透视警长: 已开启\n" else status = status .. "❌ 透视警长: 未开启\n" end
        if Settings.KillerESP then status = status .. "✅ 透视杀手: 已开启\n" else status = status .. "❌ 透视杀手: 未开启\n" end
        if Settings.CivilianESP then status = status .. "✅ 透视平民: 已开启\n" else status = status .. "❌ 透视平民: 未开启\n" end
        statusParagraph:SetDesc(status)
        task.wait(1)
    end
end)

SettingsTab:Button({Title = "关闭面板", Callback = function() Window:Close() end})

Window:OnClose(function() clearESP() end)

WindUI:Notify({Title = "神秘的杀手", Content = VERSION .. " 加载完成", Duration = 3})
