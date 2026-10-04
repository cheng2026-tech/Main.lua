-- 🌙 加一肌肉破坏墙壁 | V1.2

local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- 变量
local autoClick = false
local clickInterval = 0.005
local autoRebirth = false
local autoWin = false

-- ==================== 冰白主题 ====================
WI:AddTheme({
    Name = "冰白",
    Accent = "#80C0FF",
    Outline = "#6090C0",
    Text = "#FFFFFF",
    Placeholder = "#D0E0FF"
})

-- ==================== 免费OP点击 ====================
spawn(function()
    while true do
        if autoClick then
            pcall(function()
                local Event = game:GetService("ReplicatedStorage").Remotes.Train
                Event:FireServer()
            end)
        end
        task.wait(clickInterval)
    end
end)

-- ==================== 自动重生 ====================
spawn(function()
    while true do
        if autoRebirth then
            pcall(function()
                local Event = game:GetService("ReplicatedStorage").Remotes.Rebirth
                Event:InvokeServer()
            end)
        end
        task.wait(5)
    end
end)

-- ==================== 自动赢 ====================
spawn(function()
    while true do
        if autoWin then
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local humanoid = char:FindFirstChild("Humanoid")
                if not hrp or not humanoid then return end

                humanoid.WalkSpeed = 16
                humanoid:MoveTo(Vector3.new(117, 67.9, -1650))
                task.wait(0.5)
            end)
        end
        task.wait(0.3)
    end
end)

-- ==================== UI ====================
local Window = WI:CreateWindow({
    Title = "加一肌肉破坏墙壁",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(500, 330),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--加一肌肉破坏墙壁",
    Desc = "OP点击 | 自动重生(5秒) | 自动赢\n模拟走路16速\n 功能这么少不是我懒是反作弊太强做不出来😭"
})

local T2 = Window:Tab({Title = "主要功能", Icon = "solar:star-bold"})
T2:Section({Title = "免费OP点击"})
T2:Toggle({Title = "开启免费OP点击", Value = false, Callback = function(v) autoClick = v end})
T2:Slider({Title = "点击间隔(秒)", Value = {Min = 0.005, Max = 0.5, Default = 0.005}, Step = 0.005, Callback = function(v) clickInterval = v end})

T2:Section({Title = "自动重生"})
T2:Toggle({Title = "开启自动重生", Value = false, Callback = function(v) autoRebirth = v end})

T2:Section({Title = "自动赢"})
T2:Toggle({Title = "开启自动赢", Value = false, Callback = function(v) autoWin = v end})

local T3 = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})
local statusParagraph = T3:Paragraph({Title = "功能状态", Desc = "加载中..."})

spawn(function()
    while true do
        pcall(function()
            local fps = math.floor(1 / (RunService.RenderStepped:Wait() or 0.016))
            local status = "FPS: " .. fps .. "\n\n" ..
                "OP点击: " .. (autoClick and "✅" or "❌") .. "\n" ..
                "自动重生: " .. (autoRebirth and "✅" or "❌") .. "\n" ..
                "自动赢: " .. (autoWin and "✅" or "❌")
            statusParagraph:SetDesc(status)
        end)
        task.wait(0.5)
    end
end)

T3:Button({Title = "关闭面板", Justify = "Center", Callback = function() Window:Close() end})

WI:Notify({Title = "🌙 加一肌肉破坏墙壁", Content = "加载完成", Duration = 3})
print("🌙 加一肌肉破坏墙壁 加载完成")
