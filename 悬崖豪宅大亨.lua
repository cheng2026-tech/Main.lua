-- 悬崖豪宅大亨 | V1.0

local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ==================== 变量 ====================
local autoCollect = false
local autoThread = nil
local speedValue = 16
local speedEnabled = false
local jumpValue = 50
local jumpEnabled = false
local infiniteJumpEnabled = false
local espEnabled = false
local espHighlights = {}

-- ==================== 获取事件 ====================
local function GetCollectEvent()
    local runtime = ReplicatedStorage:FindFirstChild("Runtime")
    if not runtime then return nil end
    local actors = runtime:FindFirstChild("Actors")
    if not actors then return nil end
    for _, actor in ipairs(actors:GetChildren()) do
        if actor.Name:find("Player_") then
            local events = actor:FindFirstChild("Events")
            if events then
                return events:FindFirstChild("CollectMoney")
            end
        end
    end
    return nil
end

-- ==================== 收集钱 ====================
function DoCollect()
    local Event = GetCollectEvent()
    if Event then
        Event:FireServer()
        return true
    end
    return false
end

-- ==================== 速度/跳跃循环 ====================
task.spawn(function()
    while true do
        if speedEnabled then
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then
                c.Humanoid.WalkSpeed = speedValue
            end
        end
        if jumpEnabled then
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then
                c.Humanoid.JumpPower = jumpValue
            end
        end
        task.wait(0.1)
    end
end)

-- ==================== 无限跳跃 ====================
UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        local c = LocalPlayer.Character
        if c and c:FindFirstChild("Humanoid") then
            c.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ==================== ESP ====================
local function clearESP()
    for _, obj in pairs(espHighlights) do
        pcall(function() obj:Destroy() end)
    end
    espHighlights = {}
end

local function updateESP()
    clearESP()
    if not espEnabled then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            pcall(function()
                local char = p.Character
                local hl = Instance.new("Highlight")
                hl.FillColor = Color3.fromRGB(0, 150, 255)
                hl.FillTransparency = 0.3
                hl.OutlineColor = Color3.new(1, 1, 1)
                hl.Adornee = char
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = char
                table.insert(espHighlights, hl)
                
                local bb = Instance.new("BillboardGui")
                bb.Size = UDim2.new(0, 200, 0, 30)
                bb.AlwaysOnTop = true
                bb.Parent = char
                local head = char:FindFirstChild("Head")
                if head then bb.Adornee = head end
                
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.TextColor3 = Color3.new(1, 1, 1)
                label.Text = p.Name
                label.Font = Enum.Font.SourceSansBold
                label.TextSize = 14
                label.TextStrokeColor3 = Color3.new(0, 0, 0)
                label.TextStrokeTransparency = 0.5
                label.Parent = bb
                table.insert(espHighlights, bb)
            end)
        end
    end
end

task.spawn(function()
    while true do
        if espEnabled then
            updateESP()
        else
            clearESP()
        end
        task.wait(0.5)
    end
end)

-- ==================== Wind UI ====================
local MainWindow = WI:CreateWindow({
    Title = "悬崖豪宅大亨",
    Icon = "solar:building-bold",
    Size = UDim2.fromOffset(480, 500),
    ToggleKey = Enum.KeyCode.RightShift,
    Acrylic = true,
    ScrollBarEnabled = true
})

-- ==================== 公告 ====================
local T1 = MainWindow:Tab({Title = "公告", Icon = "solar:info-bold"})
T1:Paragraph({
    Title = "黑脚本--🏰 悬崖豪宅大亨",
    Desc = "版本 V1.0\n\n功能列表：\n- 自动收集钱\n- 手动收集钱\n- 速度调节\n- 跳跃高度\n- 无限跳跃\n- 透视所有人"
})
T1:Button({
    Title = "关闭面板",
    Justify = "Center",
    Color = Color3.fromHex("#888888"),
    Callback = function()
        MainWindow:Close()
    end
})

-- ==================== 主要功能 ====================
local T2 = MainWindow:Tab({Title = "主要功能", Icon = "solar:settings-bold"})

T2:Paragraph({
    Title = "💰 收集功能",
    Desc = "自动或手动收集钱"
})

T2:Divider()

T2:Toggle({
    Title = "🔄 自动收集钱",
    Value = false,
    Callback = function(v)
        autoCollect = v
        if autoCollect then
            if autoThread then
                task.cancel(autoThread)
                autoThread = nil
            end
            autoThread = task.spawn(function()
                while autoCollect do
                    pcall(DoCollect)
                    task.wait(1)
                end
            end)
            print("🔄 自动收集钱已开启")
            WI:Notify({
                Title = "✅ 已开启",
                Content = "自动收集钱已开启（每秒1次）",
                Duration = 2,
                Type = "success"
            })
        else
            if autoThread then
                task.cancel(autoThread)
                autoThread = nil
            end
            print("🔄 自动收集钱已关闭")
            WI:Notify({
                Title = "⏹️ 已关闭",
                Content = "自动收集钱已关闭",
                Duration = 2,
                Type = "warning"
            })
        end
    end
})

T2:Paragraph({
    Title = "⚠️ 提示",
    Desc = "开启后可能钱会客户端显示零，\n但真正的钱会加上去"
})

T2:Divider()

T2:Button({
    Title = "💰 手动收集钱",
    Justify = "Center",
    Color = Color3.fromRGB(255, 200, 50),
    Callback = function()
        local success = DoCollect()
        if success then
            WI:Notify({
                Title = "💰 收集成功",
                Content = "已执行收集",
                Duration = 2,
                Type = "success"
            })
        else
            WI:Notify({
                Title = "❌ 收集失败",
                Content = "未找到收集事件",
                Duration = 2,
                Type = "error"
            })
        end
    end
})

-- ==================== 玩家 ====================
local T3 = MainWindow:Tab({Title = "玩家", Icon = "solar:user-bold"})

T3:Paragraph({
    Title = "👤 玩家设置",
    Desc = "调节玩家属性"
})

T3:Divider()

T3:Toggle({
    Title = "🏃 开启速度调节",
    Value = false,
    Callback = function(v)
        speedEnabled = v
        if not v then
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then
                c.Humanoid.WalkSpeed = 16
            end
        end
    end
})

T3:Input({
    Title = "速度数值",
    Description = "输入1-200",
    Value = "16",
    Callback = function(v)
        local num = tonumber(v)
        if num and num > 0 and num <= 200 then
            speedValue = num
        end
    end
})

T3:Button({
    Title = "⭐ 推荐（25速度）",
    Justify = "Center",
    Color = Color3.fromRGB(255, 200, 50),
    Callback = function()
        speedValue = 25
        if speedEnabled then
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then
                c.Humanoid.WalkSpeed = 25
            end
        end
    end
})

T3:Divider()

T3:Toggle({
    Title = "🦘 开启跳跃高度",
    Value = false,
    Callback = function(v)
        jumpEnabled = v
        if not v then
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then
                c.Humanoid.JumpPower = 50
            end
        end
    end
})

T3:Input({
    Title = "跳跃数值",
    Description = "输入1-500",
    Value = "50",
    Callback = function(v)
        local num = tonumber(v)
        if num and num > 0 and num <= 500 then
            jumpValue = num
        end
    end
})

T3:Button({
    Title = "⭐ 推荐（80跳跃）",
    Justify = "Center",
    Color = Color3.fromRGB(255, 200, 50),
    Callback = function()
        jumpValue = 80
        if jumpEnabled then
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then
                c.Humanoid.JumpPower = 80
            end
        end
    end
})

T3:Divider()

T3:Toggle({
    Title = "♾️ 无限跳跃",
    Value = false,
    Callback = function(v)
        infiniteJumpEnabled = v
    end
})

T3:Divider()

T3:Toggle({
    Title = "👁️ 透视所有人",
    Value = false,
    Callback = function(v)
        espEnabled = v
        if not v then
            clearESP()
        end
    end
})

-- ==================== 启动弹窗 ====================
WI:Popup({
    Title = "悬崖豪宅大亨",
    Content = "加载完成\n按 RightShift 开关面板\n\n版本 V1.0",
    Buttons = {{
        Title = "确定",
        Variant = "Primary",
        Callback = function() end
    }}
})

print("✅ 悬崖豪宅大亨 V1.0 加载完成")
