-- 为你的城市供电 | V2.0

local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- ==================== 变量 ====================
local speedValue = 16
local speedEnabled = false
local autoLockBase = false
local lockThread = nil

-- ==================== 坐标 ====================
local BASE_POS = Vector3.new(-56, 4.4, 311.9)
local SELL_POS = Vector3.new(958, 4.1, 271)

-- ==================== 主窗口 ====================
local MainWindow = WI:CreateWindow({
    Title = "为你的城市供电",
    Icon = "solar:city-bold",
    Size = UDim2.fromOffset(480, 400),
    ToggleKey = Enum.KeyCode.RightShift,
    Acrylic = true,
    ScrollBarEnabled = true
})

-- ==================== 公告标签页 ====================
local T1 = MainWindow:Tab({Title = "公告", Icon = "solar:info-bold"})

T1:Paragraph({
    Title = "黑脚本--⚡ 为你的城市供电",
    Desc = "版本 V2.0\n\n功能列表：\n- 传送至终点售卖\n- 自动锁定基地\n- 速度调节"
})

T1:Button({
    Title = "关闭面板",
    Justify = "Center",
    Color = Color3.fromHex("#888888"),
    Callback = function()
        MainWindow:Close()
    end
})

-- ==================== 主要功能标签页 ====================
local T2 = MainWindow:Tab({Title = "主要功能", Icon = "solar:city-bold"})

T2:Paragraph({
    Title = "🚀 主要功能",
    Desc = "点击下方按钮传送或开启自动化"
})

T2:Divider()

-- ==================== 传送至终点售卖 ====================
T2:Button({
    Title = "📍 传送至终点售卖",
    Justify = "Center",
    Color = Color3.fromRGB(255, 200, 50),
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(SELL_POS)
            WI:Notify({
                Title = "✅ 传送成功",
                Content = "已传送到终点售卖",
                Duration = 2,
                Type = "success"
            })
        else
            WI:Notify({
                Title = "❌ 传送失败",
                Content = "未找到角色",
                Duration = 2,
                Type = "error"
            })
        end
    end
})

T2:Divider()

-- ==================== 自动锁定基地 ====================
T2:Toggle({
    Title = "🏠 自动锁定基地",
    Value = false,
    Callback = function(v)
        autoLockBase = v
        if autoLockBase then
            if lockThread then
                task.cancel(lockThread)
                lockThread = nil
            end
            lockThread = task.spawn(function()
                while autoLockBase do
                    pcall(function()
                        local char = LocalPlayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            char.HumanoidRootPart.CFrame = CFrame.new(BASE_POS)
                            print("🏠 锁定基地传送")
                        end
                    end)
                    task.wait(30)
                end
            end)
            WI:Notify({
                Title = "✅ 已开启",
                Content = "自动锁定基地已开启（每30秒传送）",
                Duration = 2,
                Type = "success"
            })
            print("🏠 自动锁定基地已开启")
        else
            if lockThread then
                task.cancel(lockThread)
                lockThread = nil
            end
            WI:Notify({
                Title = "⏹️ 已关闭",
                Content = "自动锁定基地已关闭",
                Duration = 2,
                Type = "warning"
            })
            print("🏠 自动锁定基地已关闭")
        end
    end
})

-- ==================== 玩家标签页 ====================
local T3 = MainWindow:Tab({Title = "玩家", Icon = "solar:user-bold"})

T3:Paragraph({
    Title = "👤 玩家设置",
    Desc = "调节玩家属性"
})

T3:Divider()

T3:Toggle({
    Title = "开启速度调节",
    Value = false,
    Callback = function(v)
        speedEnabled = v
        if not v then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = 16
            end
        end
        print("速度调节: "..(v and "开启" or "关闭"))
    end
})

T3:Input({
    Title = "速度数值",
    Description = "输入数字后点击更新",
    Value = "16",
    Callback = function(v)
        local num = tonumber(v)
        if num and num > 0 and num <= 100 then
            speedValue = num
            print("✅ 速度已设置为: "..num)
            WI:Notify({
                Title = "✅ 已更新",
                Content = "速度已设为 "..num,
                Duration = 2,
                Type = "success"
            })
            if speedEnabled then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.WalkSpeed = speedValue
                end
            end
        else
            WI:Notify({
                Title = "❌ 错误",
                Content = "请输入1-100之间的数字",
                Duration = 2,
                Type = "error"
            })
        end
    end
})

T3:Button({
    Title = "🔄 更新速度",
    Justify = "Center",
    Color = Color3.fromRGB(255, 200, 50),
    Callback = function()
        if speedEnabled then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = speedValue
                WI:Notify({
                    Title = "✅ 已更新",
                    Content = "速度已设为 "..speedValue,
                    Duration = 2,
                    Type = "success"
                })
            end
        else
            WI:Notify({
                Title = "⚠️ 提示",
                Content = "请先开启速度调节",
                Duration = 2,
                Type = "warning"
            })
        end
    end
})

-- ==================== 速度循环 ====================
spawn(function()
    while true do
        if speedEnabled then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = speedValue
            end
        end
        task.wait(0.1)
    end
end)

-- ==================== 启动弹窗 ====================
WI:Popup({
    Title = "为你的城市供电",
    Content = "加载完成\n按 RightShift 开关面板\n\n版本 V2.0",
    Buttons = {{
        Title = "确定",
        Variant = "Primary",
        Callback = function() end
    }}
})

print("✅ 为你的城市供电 V2.0 加载完成")
