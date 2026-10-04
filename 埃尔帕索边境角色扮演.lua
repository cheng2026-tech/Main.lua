-- 埃尔帕索边境角色扮演 脚本 v1.0.1
-- WindUI蓝白版 | 传送 | 透视玩家 | 调速度 | 飞行 | 碰撞箱

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
if not WindUI then return end

WindUI:AddTheme({
    Name = "冰白",
    Accent = "#80C0FF",
    Outline = "#6090C0",
    Text = "#FFFFFF",
    Placeholder = "#D0E0FF",
})

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local flying = false
local flySpeed = 500
local isFlyingMode = false
local flyConnection = nil

-- ========== 传送 ==========
local function smoothFly(targetPos)
    if not HumanoidRootPart then return end
    local distance = (targetPos - HumanoidRootPart.Position).Magnitude
    local tweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(distance / flySpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local tween = tweenService:Create(HumanoidRootPart, tweenInfo, {CFrame = CFrame.new(targetPos)})
    tween:Play()
end

local function flyTo(targetPos)
    if not flying then
        flying = true
        Humanoid.PlatformStand = true
    end
    smoothFly(targetPos)
    delay(10, function()
        if flying then
            flying = false
            Humanoid.PlatformStand = false
        end
    end)
end

-- ========== 飞行模式 ==========
local function toggleFly()
    isFlyingMode = not isFlyingMode
    
    if isFlyingMode then
        Humanoid.PlatformStand = true
        WindUI:Notify({Title = "飞行", Content = "已开启 (WASD移动, Space上升, Shift下降)", Duration = 3})
        
        flyConnection = game:GetService("RunService").Heartbeat:Connect(function()
            local moveDir = Vector3.new()
            local forward = Camera.CFrame.LookVector
            local right = Camera.CFrame.RightVector
            local up = Vector3.new(0, 1, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + forward end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - forward end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - right end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + right end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + up end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - up end
            
            if moveDir.Magnitude > 0 then
                moveDir = moveDir.Unit * 50
                HumanoidRootPart.Position = HumanoidRootPart.Position + moveDir * 0.016
            end
        end)
    else
        Humanoid.PlatformStand = false
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        WindUI:Notify({Title = "飞行", Content = "已关闭", Duration = 2})
    end
end

-- ========== 透视玩家 ==========
local espEnabled = false
local espConnections = {}

local function enableESP()
    espEnabled = true
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= Player then
            local function applyHighlight(character)
                if character and not character:FindFirstChild("ESP_Highlight") then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "ESP_Highlight"
                    highlight.FillColor = Color3.fromRGB(128, 192, 255)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.Parent = character
                end
            end
            if player.Character then applyHighlight(player.Character) end
            local conn = player.CharacterAdded:Connect(applyHighlight)
            table.insert(espConnections, conn)
        end
    end
end

local function disableESP()
    espEnabled = false
    for _, conn in pairs(espConnections) do
        conn:Disconnect()
    end
    espConnections = {}
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("ESP_Highlight") then
            player.Character.ESP_Highlight:Destroy()
        end
    end
end

-- ========== 碰撞箱 ==========
local function setHitboxSize(size)
    if HumanoidRootPart then
        HumanoidRootPart.Size = Vector3.new(size, size, size)
        WindUI:Notify({Title = "碰撞箱", Content = "已设置为 " .. size, Duration = 2})
    end
end

-- ========== UI ==========
local Window = WindUI:CreateWindow({
    Title = "埃尔帕索边境角色扮演",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(580, 420),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true,
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--埃尔帕索边境角色扮演 v1.0.1",
    Desc = "功能：传送 | 透视玩家 | 调速度 | 飞行 | 碰撞箱\n\n更新日志：v1.0.1 添加飞行和碰撞箱\n\n传送时可能遇到传到终点后被拉回的情况需点两次",
})

local MainTab = Window:Tab({Title = "主要功能", Icon = "solar:star-bold"})

MainTab:Button({
    Title = "传送出生点",
    Callback = function()
        flyTo(Vector3.new(-1948.4, 5.6, -1.9))
        WindUI:Notify({Title = "飞行开始", Content = "正在飞往出生点...", Duration = 2})
    end
})

MainTab:Button({
    Title = "传送售卖点",
    Callback = function()
        flyTo(Vector3.new(3489.9, 5.5, -755.5))
        WindUI:Notify({Title = "飞行开始", Content = "正在飞往售卖点...", Duration = 2})
    end
})

MainTab:Divider()

MainTab:Input({
    Title = "碰撞箱大小",
    Placeholder = "输入数值 (如: 2)",
    Callback = function(v)
        local size = tonumber(v)
        if size and size > 0 then
            setHitboxSize(size)
        else
            WindUI:Notify({Title = "错误", Content = "请输入有效数值", Duration = 2})
        end
    end
})

local PlayerTab = Window:Tab({Title = "玩家", Icon = "solar:user-bold"})

PlayerTab:Toggle({
    Title = "透视玩家",
    Value = false,
    Callback = function(v)
        if v then
            enableESP()
            WindUI:Notify({Title = "透视", Content = "已开启玩家透视", Duration = 2})
        else
            disableESP()
            WindUI:Notify({Title = "透视", Content = "已关闭玩家透视", Duration = 2})
        end
    end
})

PlayerTab:Divider()

PlayerTab:Slider({
    Title = "移动速度",
    Value = {Min = 16, Max = 100, Default = 16},
    Step = 1,
    Callback = function(v)
        if Humanoid then
            Humanoid.WalkSpeed = v
        end
    end
})

PlayerTab:Divider()

PlayerTab:Toggle({
    Title = "飞行模式",
    Value = false,
    Callback = function(v)
        toggleFly()
    end
})

local SettingsTab = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})
SettingsTab:Button({Title = "关闭面板", Callback = function() Window:Close() end})

-- ========== 角色重生 ==========
Player.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    Humanoid = Character:WaitForChild("Humanoid")
    flying = false
    isFlyingMode = false
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
end)

WindUI:Notify({
    Title = "埃尔帕索边境角色扮演",
    Content = "脚本加载完成",
    Duration = 3
})
