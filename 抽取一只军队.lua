-- 抽取一只军队 脚本 v1.1.2
-- WindUI蓝白版 | 自动攻击 | 全自动传送索敌

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
local Camera = workspace.CurrentCamera

local Settings = {
    AutoAttackEnabled = false,
    AttackDelay = 0.1,
    FullAutoEnabled = false,
    NPCRange = 50,
}

local VERSION = "v1.1.2"
local lastAttackTime = 0
local lastSearchTime = 0
local currentNPC = nil

local function findNearestNPC()
    local nearestNPC = nil
    local nearestDistance = Settings.NPCRange
    
    local myPosition = nil
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        myPosition = LocalPlayer.Character.HumanoidRootPart.Position
    else
        return nil
    end
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("npc") then
            local humanoid = obj:FindFirstChild("Humanoid")
            local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
            
            if humanoid and humanoid.Health > 0 and rootPart then
                local distance = (myPosition - rootPart.Position).Magnitude
                
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestNPC = obj
                end
            end
        end
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Name:lower():find("npc") then
            if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") then
                local humanoid = player.Character.Humanoid
                local rootPart = player.Character.HumanoidRootPart
                
                if humanoid.Health > 0 then
                    local distance = (myPosition - rootPart.Position).Magnitude
                    
                    if distance < nearestDistance then
                        nearestDistance = distance
                        nearestNPC = player.Character
                    end
                end
            end
        end
    end
    
    return nearestNPC
end

local function teleportAndAimAtNPC()
    if not currentNPC then return end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local rootPart = character.HumanoidRootPart
    local npcRootPart = currentNPC:FindFirstChild("HumanoidRootPart") or currentNPC.PrimaryPart
    
    if not npcRootPart then return end
    
    local offset = (rootPart.Position - npcRootPart.Position).Unit
    if offset.Magnitude < 0.1 then
        offset = Vector3.new(0, 0, 2)
    end
    
    local targetPosition = npcRootPart.Position + offset * 2
    rootPart.CFrame = CFrame.new(targetPosition)
    
    local npcHead = currentNPC:FindFirstChild("Head") or npcRootPart
    if npcHead then
        local lookAt = CFrame.lookAt(Camera.CFrame.Position, npcHead.Position)
        Camera.CFrame = lookAt
    end
end

RunService.Heartbeat:Connect(function()
    if Settings.AutoAttackEnabled then
        local currentTime = tick()
        if currentTime - lastAttackTime >= Settings.AttackDelay then
            local Event = ReplicatedStorage:FindFirstChild("SwordSwingEvent")
            if Event then
                Event:FireServer()
                lastAttackTime = currentTime
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if Settings.FullAutoEnabled then
        local currentTime = tick()
        if currentTime - lastSearchTime >= 0.1 then
            currentNPC = findNearestNPC()
            lastSearchTime = currentTime
            
            if currentNPC then
                teleportAndAimAtNPC()
                
                if not Settings.AutoAttackEnabled then
                    Settings.AutoAttackEnabled = true
                end
            else
                if Settings.AutoAttackEnabled then
                    Settings.AutoAttackEnabled = false
                end
            end
        end
    end
end)

local Window = WindUI:CreateWindow({
    Title = "抽取一只军队",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(400, 350),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true,
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--抽取一只军队",
    Desc = "版本: " .. VERSION,
})

local MainTab = Window:Tab({Title = "主要功能", Icon = "solar:star-bold"})

MainTab:Toggle({
    Title = "自动攻击",
    Value = false,
    Callback = function(enabled)
        Settings.AutoAttackEnabled = enabled
        
        if enabled then
            WindUI:Notify({
                Title = "自动攻击已开启",
                Content = "攻击延迟: " .. Settings.AttackDelay .. "秒",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "自动攻击已关闭",
                Content = "已停止攻击",
                Duration = 2
            })
        end
    end
})

MainTab:Slider({
    Title = "攻击延迟 (0.01-1秒)",
    Value = {Min = 0.01, Max = 1, Default = 0.1},
    Step = 0.01,
    Callback = function(delay)
        Settings.AttackDelay = delay
    end
})

MainTab:Divider()

MainTab:Toggle({
    Title = "全自动索敌",
    Value = false,
    Callback = function(enabled)
        Settings.FullAutoEnabled = enabled
        
        if enabled then
            WindUI:Notify({
                Title = "全自动已开启",
                Content = "自动传送到NPC旁边并攻击",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "全自动已关闭",
                Content = "已停止全自动",
                Duration = 2
            })
        end
    end
})

MainTab:Slider({
    Title = "NPC搜索范围",
    Value = {Min = 10, Max = 500, Default = 50},
    Step = 10,
    Callback = function(range)
        Settings.NPCRange = range
    end
})

local SettingsTab = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})

local statusParagraph = SettingsTab:Paragraph({
    Title = "功能状态",
    Desc = "正在加载..."
})

local function updateStatus()
    local status = ""
    
    if Settings.AutoAttackEnabled then
        status = status .. "✅ 自动攻击: 已开启\n"
    else
        status = status .. "❌ 自动攻击: 未开启\n"
    end
    
    if Settings.FullAutoEnabled then
        status = status .. "✅ 全自动索敌: 已开启\n"
        
        if currentNPC then
            status = status .. "当前目标: " .. currentNPC.Name .. "\n"
        else
            status = status .. "当前目标: 未找到NPC\n"
        end
    else
        status = status .. "❌ 全自动索敌: 未开启\n"
    end
    
    statusParagraph:SetDesc(status)
end

RunService.Heartbeat:Connect(function()
    updateStatus()
end)

SettingsTab:Button({
    Title = "关闭面板",
    Callback = function()
        Window:Close()
    end
})

Window:OnClose(function()
    Settings.AutoAttackEnabled = false
    Settings.FullAutoEnabled = false
    currentNPC = nil
end)

WindUI:Notify({
    Title = "抽取一只军队",
    Content = VERSION .. " 加载完成",
    Duration = 3
})
