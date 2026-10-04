-- 逃跑者 脚本 v1.9.1
-- WindUI蓝白版 | 绕过反作弊 | 杀戮光环 | 调整速度 | NPC透视 | 玩家透视 | 油桶透视 | 飞行 | 传送

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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Settings = {
    AntiCheatBypass = false,
    KillAuraEnabled = false,
    KillDelay = 0.1,
    KillRange = 50,
    KillDamage = 13,
    SpeedEnabled = false,
    SpeedValue = 100,
    FlyEnabled = false,
    NPCESPEnabled = false,
    PlayerESPEnabled = false,
    JerrycanESPEnabled = false,
}

local VERSION = "v1.9.1"
local lastKillTime = 0
local mtHook = nil
local killAuraConnection = nil
local npcHighlights = {}
local npcNameTags = {}
local playerHighlights = {}
local playerNameTags = {}
local jerrycanHighlights = {}
local jerrycanNameTags = {}
local cachedNPCs = {}
local cachedPlayers = {}
local cachedJerrycans = {}

local function getAllNPCs()
    local npcs = {}
    local playerChars = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character then playerChars[plr.Character] = true end
    end
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("Head") then
            if not playerChars[obj] then table.insert(npcs, obj) end
        end
    end
    return npcs
end

local function getAllPlayers()
    local players = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(players, plr)
        end
    end
    return players
end

local function getAllJerrycans()
    local jerrycans = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("jerrycan") or obj.Name:lower():find("油桶") then
            local rootPart = obj:IsA("Model") and (obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart) or obj
            if rootPart then
                table.insert(jerrycans, {Object = obj, RootPart = rootPart, Position = rootPart.Position})
            end
        end
    end
    return jerrycans
end

local function enableAntiCheatBypass()
    if mtHook then return end
    local mt = getrawmetatable(game)
    local oldIndex = mt.__index
    setreadonly(mt, false)
    mt.__index = newcclosure(function(self, key)
        if key == "AssemblyLinearVelocity" and self.Name == "HumanoidRootPart" then
            return Vector3.new()
        end
        return oldIndex(self, key)
    end)
    setreadonly(mt, true)
    mtHook = oldIndex
end

local function disableAntiCheatBypass()
    if not mtHook then return end
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    mt.__index = mtHook
    setreadonly(mt, true)
    mtHook = nil
end

local function getNearestNPC()
    local nearestNPC = nil
    local nearestDistance = Settings.KillRange
    local myPosition = nil
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        myPosition = LocalPlayer.Character.HumanoidRootPart.Position
    else
        return nil
    end
    for _, npc in pairs(getAllNPCs()) do
        local humanoid = npc:FindFirstChild("Humanoid")
        local rootPart = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
        if humanoid and humanoid.Health > 0 and rootPart then
            local distance = (myPosition - rootPart.Position).Magnitude
            if distance < nearestDistance then
                nearestDistance = distance
                nearestNPC = npc
            end
        end
    end
    return nearestNPC
end

local function killAura()
    local nearestNPC = getNearestNPC()
    if nearestNPC then
        local humanoid = nearestNPC:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health > 0 then
            local Event = ReplicatedStorage:FindFirstChild("FlowClient") and ReplicatedStorage.FlowClient:FindFirstChild("ClientRunner") and ReplicatedStorage.FlowClient.ClientRunner:FindFirstChild("Event")
            if Event then
                Event:FireServer("NPCs", "Damage", humanoid, Settings.KillDamage)
                return true
            end
        end
    end
    return false
end

local function startKillAura()
    if killAuraConnection then return end
    killAuraConnection = RunService.Heartbeat:Connect(function()
        if Settings.KillAuraEnabled then
            local currentTime = tick()
            if currentTime - lastKillTime >= Settings.KillDelay then
                killAura()
                lastKillTime = currentTime
            end
        end
    end)
end

local function setSpeed()
    local player = LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = Settings.SpeedValue
    end
end

task.spawn(function()
    while true do
        if Settings.SpeedEnabled then setSpeed() end
        task.wait(0.5)
    end
end)

-- 清理ESP
local function clearNPCESP()
    for _, h in pairs(npcHighlights) do pcall(function() h:Destroy() end) end
    for _, t in pairs(npcNameTags) do pcall(function() t:Destroy() end) end
    table.clear(npcHighlights)
    table.clear(npcNameTags)
    table.clear(cachedNPCs)
end

local function clearPlayerESP()
    for _, h in pairs(playerHighlights) do pcall(function() h:Destroy() end) end
    for _, t in pairs(playerNameTags) do pcall(function() t:Destroy() end) end
    table.clear(playerHighlights)
    table.clear(playerNameTags)
    table.clear(cachedPlayers)
end

local function clearJerrycanESP()
    for _, h in pairs(jerrycanHighlights) do pcall(function() h:Destroy() end) end
    for _, t in pairs(jerrycanNameTags) do pcall(function() t:Destroy() end) end
    table.clear(jerrycanHighlights)
    table.clear(jerrycanNameTags)
    table.clear(cachedJerrycans)
end

-- 更新ESP标签距离
local function updateESPDistance()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
    
    for npc, bg in pairs(npcNameTags) do
        if bg and bg.Parent and bg.Parent.Parent then
            local rootPart = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
            if rootPart then
                local dist = (myPos - rootPart.Position).Magnitude
                local label = bg:FindFirstChildWhichIsA("TextLabel")
                if label then
                    label.Text = "NPC\n[" .. math.floor(dist) .. "米]"
                end
            end
        end
    end
    
    for plr, bg in pairs(playerNameTags) do
        if bg and bg.Parent and bg.Parent.Parent then
            if plr.Character then
                local rootPart = plr.Character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    local dist = (myPos - rootPart.Position).Magnitude
                    local label = bg:FindFirstChildWhichIsA("TextLabel")
                    if label then
                        label.Text = plr.Name .. "\n[" .. math.floor(dist) .. "米]"
                    end
                end
            end
        end
    end
    
    for obj, bg in pairs(jerrycanNameTags) do
        if bg and bg.Parent and bg.Parent.Parent then
            local rootPart = obj:IsA("Model") and (obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart) or obj
            if rootPart then
                local dist = (myPos - rootPart.Position).Magnitude
                local label = bg:FindFirstChildWhichIsA("TextLabel")
                if label then
                    label.Text = "油桶\n[" .. math.floor(dist) .. "米]"
                end
            end
        end
    end
end

-- 单个ESP循环处理所有功能
local function processESP()
    local currentTime = tick()
    
    if Settings.NPCESPEnabled then
        if currentTime - lastNPCScan > 5 then
            clearNPCESP()
            cachedNPCs = getAllNPCs()
            lastNPCScan = currentTime
            
            for _, npc in pairs(cachedNPCs) do
                if npc and npc.Parent then
                    local head = npc:FindFirstChild("Head")
                    local rootPart = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
                    
                    if head and rootPart then
                        local h = Instance.new("Highlight")
                        h.FillColor = Color3.fromRGB(255, 0, 0)
                        h.FillTransparency = 0.5
                        h.OutlineColor = Color3.fromRGB(255, 0, 0)
                        h.OutlineTransparency = 0.3
                        h.Parent = npc
                        npcHighlights[npc] = h
                        
                        local dist = ""
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local d = (rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                            dist = "\n[" .. math.floor(d) .. "米]"
                        end
                        
                        local bg = Instance.new("BillboardGui")
                        bg.Size = UDim2.new(0, 200, 0, 40)
                        bg.AlwaysOnTop = true
                        bg.MaxDistance = math.huge
                        bg.Parent = head
                        
                        local l = Instance.new("TextLabel")
                        l.Size = UDim2.new(1, 0, 1, 0)
                        l.BackgroundTransparency = 1
                        l.Text = "NPC" .. dist
                        l.TextColor3 = Color3.fromRGB(255, 0, 0)
                        l.Font = Enum.Font.GothamBold
                        l.TextSize = 14
                        l.TextStrokeTransparency = 0.5
                        l.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        l.Parent = bg
                        npcNameTags[npc] = bg
                    end
                end
            end
        end
    elseif next(npcHighlights) then
        clearNPCESP()
    end
    
    if Settings.PlayerESPEnabled then
        if currentTime - lastPlayerScan > 5 then
            clearPlayerESP()
            cachedPlayers = getAllPlayers()
            lastPlayerScan = currentTime
            
            for _, plr in pairs(cachedPlayers) do
                if plr.Character and plr.Character.Parent then
                    local head = plr.Character:FindFirstChild("Head")
                    local rootPart = plr.Character:FindFirstChild("HumanoidRootPart")
                    
                    if head and rootPart then
                        local h = Instance.new("Highlight")
                        h.FillColor = Color3.fromRGB(0, 0, 255)
                        h.FillTransparency = 0.5
                        h.OutlineColor = Color3.fromRGB(0, 0, 255)
                        h.OutlineTransparency = 0.3
                        h.Parent = plr.Character
                        playerHighlights[plr] = h
                        
                        local dist = ""
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local d = (rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                            dist = "\n[" .. math.floor(d) .. "米]"
                        end
                        
                        local bg = Instance.new("BillboardGui")
                        bg.Size = UDim2.new(0, 200, 0, 40)
                        bg.AlwaysOnTop = true
                        bg.MaxDistance = math.huge
                        bg.Parent = head
                        
                        local l = Instance.new("TextLabel")
                        l.Size = UDim2.new(1, 0, 1, 0)
                        l.BackgroundTransparency = 1
                        l.Text = plr.Name .. dist
                        l.TextColor3 = Color3.fromRGB(0, 0, 255)
                        l.Font = Enum.Font.GothamBold
                        l.TextSize = 14
                        l.TextStrokeTransparency = 0.5
                        l.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        l.Parent = bg
                        playerNameTags[plr] = bg
                    end
                end
            end
        end
    elseif next(playerHighlights) then
        clearPlayerESP()
    end
    
    if Settings.JerrycanESPEnabled then
        if currentTime - lastJerrycanScan > 5 then
            clearJerrycanESP()
            cachedJerrycans = getAllJerrycans()
            lastJerrycanScan = currentTime
            
            for _, jerrycan in pairs(cachedJerrycans) do
                if jerrycan.Object and jerrycan.Object.Parent then
                    local h = Instance.new("Highlight")
                    h.FillColor = Color3.fromRGB(0, 255, 0)
                    h.FillTransparency = 0.5
                    h.OutlineColor = Color3.fromRGB(0, 255, 0)
                    h.OutlineTransparency = 0.3
                    h.Parent = jerrycan.Object
                    jerrycanHighlights[jerrycan.Object] = h
                    
                    local dist = ""
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local d = (jerrycan.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                        dist = "\n[" .. math.floor(d) .. "米]"
                    end
                    
                    local bg = Instance.new("BillboardGui")
                    bg.Size = UDim2.new(0, 200, 0, 40)
                    bg.AlwaysOnTop = true
                    bg.MaxDistance = math.huge
                    bg.Parent = jerrycan.RootPart
                    
                    local l = Instance.new("TextLabel")
                    l.Size = UDim2.new(1, 0, 1, 0)
                    l.BackgroundTransparency = 1
                    l.Text = "油桶" .. dist
                    l.TextColor3 = Color3.fromRGB(0, 255, 0)
                    l.Font = Enum.Font.GothamBold
                    l.TextSize = 14
                    l.TextStrokeTransparency = 0.5
                    l.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    l.Parent = bg
                    jerrycanNameTags[jerrycan.Object] = bg
                end
            end
        end
    elseif next(jerrycanHighlights) then
        clearJerrycanESP()
    end
    
    updateESPDistance()
end

RunService.Heartbeat:Connect(processESP)

-- 飞行加载
local function loadFlyScript()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/飞饼"))()
end

-- 传送到最近油桶
local function teleportToNearestJerrycan()
    local jerrycans = getAllJerrycans()
    if #jerrycans == 0 then
        WindUI:Notify({Title = "未找到油桶", Content = "附近没有油桶", Duration = 2})
        return false
    end
    
    local nearestJerrycan = nil
    local nearestDistance = math.huge
    local myPosition = nil
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        myPosition = LocalPlayer.Character.HumanoidRootPart.Position
    else
        WindUI:Notify({Title = "错误", Content = "找不到角色位置", Duration = 2})
        return false
    end
    
    for _, jerrycan in pairs(jerrycans) do
        local distance = (myPosition - jerrycan.Position).Magnitude
        if distance < nearestDistance then
            nearestDistance = distance
            nearestJerrycan = jerrycan
        end
    end
    
    if nearestJerrycan and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(nearestJerrycan.Position + Vector3.new(0, 3, 0))
        WindUI:Notify({Title = "传送成功", Content = "已传送到最近油桶", Duration = 2})
        return true
    end
    return false
end

-- 传送到出售区
local function teleportToPawnCounter()
    local found = false
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "PawnCounter" then
            local rootPart = obj:IsA("Model") and (obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart) or obj
            if rootPart and rootPart.Position then
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(rootPart.Position + Vector3.new(0, 5, 0))
                    WindUI:Notify({Title = "传送成功", Content = "已传送到出售区", Duration = 2})
                    found = true
                    break
                end
            end
        end
    end
    
    if not found then
        WindUI:Notify({Title = "未找到", Content = "找不到出售区", Duration = 2})
    end
end

-- 传送到汽车
local function teleportToCar()
    local found = false
    for _, obj in pairs(Workspace:GetDescendants()) do
        local lowerName = obj.Name:lower()
        if lowerName:find("paint") or lowerName:find("car") or lowerName:find("vehicle") or lowerName:find("汽车") or lowerName:find("车") then
            local rootPart = obj:IsA("Model") and (obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart) or obj
            if rootPart and rootPart.Position then
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(rootPart.Position + Vector3.new(0, 5, 0))
                    WindUI:Notify({Title = "传送成功", Content = "已传送到汽车上方", Duration = 2})
                    found = true
                    break
                end
            end
        end
    end
    
    if not found then
        WindUI:Notify({Title = "未找到", Content = "找不到汽车", Duration = 2})
    end
end

-- 传送墨西哥（传送到最近名字带Command的物体）
local function teleportToMexico()
    local found = false
    local myPos = nil
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        myPos = LocalPlayer.Character.HumanoidRootPart.Position
    else
        WindUI:Notify({Title = "错误", Content = "找不到角色位置", Duration = 2})
        return
    end
    
    local nearestCommand = nil
    local nearestDist = math.huge
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name and (obj.Name:lower():find("command") or obj.Name:lower():find("cmd")) then
            local rootPart = obj:IsA("Model") and (obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart) or obj
            if rootPart and rootPart.Position then
                local dist = (myPos - rootPart.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearestCommand = rootPart
                end
                found = true
            end
        end
    end
    
    if nearestCommand then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(nearestCommand.Position + Vector3.new(0, 3, 0))
            WindUI:Notify({Title = "传送成功", Content = "已传送到墨西哥(Command)", Duration = 2})
        end
    else
        WindUI:Notify({Title = "未找到", Content = "找不到Command传送点", Duration = 2})
    end
end

-- 获取玩家列表
local function getPlayerNames()
    local names = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(names, plr.Name)
        end
    end
    if #names == 0 then table.insert(names, "无其他玩家") end
    return names
end

local Window = WindUI:CreateWindow({
    Title = "黑脚本--逃跑者",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(400, 350),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true,
})

-- 公告
Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--逃跑者 " .. VERSION,
    Desc = "支持功能：\n\n• 绕过反作弊\n• 杀戮光环（伤害可调13-10000）\n• NPC透视\n• 玩家透视\n• 油桶透视\n• 调整速度\n• 飞行\n• 传送油桶/出售区/汽车/墨西哥\n\n版本说明：\n• v1.9.1 墨西哥传送改为单次传送Command",
})

-- 主要
local MainTab = Window:Tab({Title = "主要", Icon = "solar:star-bold"})

MainTab:Button({
    Title = "绕过反作弊",
    Callback = function()
        if not mtHook then
            enableAntiCheatBypass()
            WindUI:Notify({Title = "绕过反作弊已开启", Content = "AssemblyLinearVelocity已屏蔽", Duration = 3})
        else
            disableAntiCheatBypass()
            WindUI:Notify({Title = "绕过反作弊已关闭", Content = "已恢复原始状态", Duration = 3})
        end
    end
})

MainTab:Divider()

MainTab:Toggle({
    Title = "杀戮光环",
    Value = false,
    Callback = function(enabled)
        Settings.KillAuraEnabled = enabled
        if enabled then
            startKillAura()
            WindUI:Notify({Title = "杀戮光环已开启", Content = "伤害: " .. Settings.KillDamage, Duration = 3})
        else
            WindUI:Notify({Title = "杀戮光环已关闭", Content = "已停止", Duration = 2})
        end
    end
})

MainTab:Slider({
    Title = "杀戮延迟 (0.01-1秒)",
    Value = {Min = 0.01, Max = 1, Default = 0.1},
    Step = 0.01,
    Callback = function(delay) Settings.KillDelay = delay end
})

MainTab:Slider({
    Title = "杀戮范围 (10-10000)",
    Value = {Min = 10, Max = 10000, Default = 50},
    Step = 10,
    Callback = function(range) Settings.KillRange = range end
})

MainTab:Slider({
    Title = "杀戮伤害 (13-10000)",
    Value = {Min = 13, Max = 10000, Default = 13},
    Step = 1,
    Callback = function(damage) Settings.KillDamage = damage end
})

MainTab:Divider()

MainTab:Button({
    Title = "传送到出售区",
    Callback = function() teleportToPawnCounter() end
})

MainTab:Button({
    Title = "传送到汽车",
    Callback = function() teleportToCar() end
})

MainTab:Button({
    Title = "传送到墨西哥",
    Callback = function() teleportToMexico() end
})

MainTab:Divider()

local playerNames = getPlayerNames()
local selectedPlayer = playerNames[1] or "无其他玩家"
MainTab:Dropdown({
    Title = "选择玩家",
    Values = playerNames,
    Value = selectedPlayer,
    Callback = function(v) selectedPlayer = v end
})

MainTab:Button({
    Title = "传送到该玩家",
    Callback = function()
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Name == selectedPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(plr.Character.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
                WindUI:Notify({Title = "传送成功", Content = "已传送到" .. plr.Name, Duration = 2})
                return
            end
        end
        WindUI:Notify({Title = "未找到", Content = "找不到该玩家", Duration = 2})
    end
})

-- 视觉
local VisualTab = Window:Tab({Title = "视觉", Icon = "solar:eye-bold"})

VisualTab:Toggle({
    Title = "NPC透视",
    Value = false,
    Callback = function(enabled)
        Settings.NPCESPEnabled = enabled
        if not enabled then clearNPCESP() end
    end
})

VisualTab:Divider()

VisualTab:Toggle({
    Title = "玩家透视",
    Value = false,
    Callback = function(enabled)
        Settings.PlayerESPEnabled = enabled
        if not enabled then clearPlayerESP() end
    end
})

VisualTab:Divider()

VisualTab:Toggle({
    Title = "油桶透视",
    Value = false,
    Callback = function(enabled)
        Settings.JerrycanESPEnabled = enabled
        if not enabled then clearJerrycanESP() end
    end
})

-- 玩家
local PlayerTab = Window:Tab({Title = "玩家", Icon = "solar:user-bold"})

PlayerTab:Toggle({
    Title = "调整速度",
    Value = false,
    Callback = function(enabled)
        Settings.SpeedEnabled = enabled
        if enabled then
            setSpeed()
            WindUI:Notify({Title = "调整速度已开启", Content = "速度: " .. Settings.SpeedValue, Duration = 3})
        else
            WindUI:Notify({Title = "调整速度已关闭", Content = "已停止", Duration = 2})
        end
    end
})

PlayerTab:Slider({
    Title = "移动速度 (16-500)",
    Value = {Min = 16, Max = 500, Default = 100},
    Step = 1,
    Callback = function(speed)
        Settings.SpeedValue = speed
        if Settings.SpeedEnabled then setSpeed() end
    end
})

PlayerTab:Divider()

PlayerTab:Button({
    Title = "飞行",
    Callback = function()
        loadFlyScript()
        Settings.FlyEnabled = true
        WindUI:Notify({Title = "飞行已加载", Content = "使用飞行脚本", Duration = 3})
    end
})

PlayerTab:Divider()

PlayerTab:Button({
    Title = "传送到最近油桶",
    Callback = function() teleportToNearestJerrycan() end
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
        
        if mtHook then status = status .. "✅ 绕过反作弊: 已开启\n" else status = status .. "❌ 绕过反作弊: 未开启\n" end
        if Settings.KillAuraEnabled then status = status .. "✅ 杀戮光环: 已开启 (伤害: " .. Settings.KillDamage .. ")\n" else status = status .. "❌ 杀戮光环: 未开启\n" end
        if Settings.NPCESPEnabled then status = status .. "✅ NPC透视: 已开启 (" .. #cachedNPCs .. "个NPC)\n" else status = status .. "❌ NPC透视: 未开启\n" end
        if Settings.PlayerESPEnabled then status = status .. "✅ 玩家透视: 已开启 (" .. #cachedPlayers .. "个玩家)\n" else status = status .. "❌ 玩家透视: 未开启\n" end
        if Settings.JerrycanESPEnabled then status = status .. "✅ 油桶透视: 已开启 (" .. #cachedJerrycans .. "个油桶)\n" else status = status .. "❌ 油桶透视: 未开启\n" end
        if Settings.SpeedEnabled then status = status .. "✅ 调整速度: 已开启 (" .. Settings.SpeedValue .. ")\n" else status = status .. "❌ 调整速度: 未开启\n" end
        
        statusParagraph:SetDesc(status)
        task.wait(2)
    end
end)

SettingsTab:Button({
    Title = "关闭面板",
    Callback = function()
        Window:Close()
    end
})

Window:OnClose(function()
    -- 不关闭功能，只关闭面板
end)

WindUI:Notify({
    Title = "逃跑者",
    Content = VERSION .. " 加载完成",
    Duration = 3
})
