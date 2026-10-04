-- 吃吃世界 | V2.1

local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ==================== 变量 ====================
local speedValue = 16
local speedEnabled = false
local autoGrab = false
local autoEat = false
local grabThread = nil
local eatThread = nil

-- ==================== 主窗口 ====================
local MainWindow = WI:CreateWindow({
    Title = "吃吃世界",
    Icon = "solar:food-bold",
    Size = UDim2.fromOffset(480, 440),
    ToggleKey = Enum.KeyCode.RightShift,
    Acrylic = true,
    ScrollBarEnabled = true
})

-- ==================== 公告标签页 ====================
local T1 = MainWindow:Tab({Title = "公告", Icon = "solar:info-bold"})

T1:Paragraph({
    Title = "黑脚本--🍽️ 吃吃世界",
    Desc = "版本 V2.1\n\n功能列表：\n- 自动捡物（Toggle）\n- 自动吃（Toggle）\n- 手动售卖（点击按钮）\n- 速度调节"
})

T1:Button({
    Title = "关闭面板",
    Justify = "Center",
    Color = Color3.fromHex("#888888"),
    Callback = function()
        MainWindow:Close()
    end
})

-- ==================== 自动化标签页 ====================
local T2 = MainWindow:Tab({Title = "自动化", Icon = "solar:settings-bold"})

T2:Paragraph({
    Title = "⚙️ 自动化设置",
    Desc = "Toggle开关控制自动功能，按钮手动触发"
})

T2:Divider()

-- ==================== 获取事件 ====================
local function GetGrabEvent()
    local char = LocalPlayer.Character
    if not char then return nil end
    local events = char:FindFirstChild("Events")
    if not events then return nil end
    return events:FindFirstChild("Grab")
end

local function GetEatEvent()
    local char = LocalPlayer.Character
    if not char then return nil end
    local events = char:FindFirstChild("Events")
    if not events then return nil end
    return events:FindFirstChild("Eat")
end

local function GetSellEvent()
    local char = LocalPlayer.Character
    if not char then return nil end
    local events = char:FindFirstChild("Events")
    if not events then return nil end
    return events:FindFirstChild("Sell")
end

-- ==================== 自动捡物 ====================
T2:Toggle({
    Title = "📦 自动捡物",
    Value = false,
    Callback = function(v)
        autoGrab = v
        if autoGrab then
            if grabThread then
                task.cancel(grabThread)
                grabThread = nil
            end
            grabThread = task.spawn(function()
                while autoGrab do
                    pcall(function()
                        local Event = GetGrabEvent()
                        if Event then
                            Event:FireServer(false, false, false)
                        end
                    end)
                    task.wait(0.3)
                end
            end)
            print("📦 自动捡物已开启")
        else
            if grabThread then
                task.cancel(grabThread)
                grabThread = nil
            end
            print("📦 自动捡物已关闭")
        end
    end
})

-- ==================== 自动吃 ====================
T2:Toggle({
    Title = "🍽️ 自动吃",
    Value = false,
    Callback = function(v)
        autoEat = v
        if autoEat then
            if eatThread then
                task.cancel(eatThread)
                eatThread = nil
            end
            eatThread = task.spawn(function()
                while autoEat do
                    pcall(function()
                        local Event = GetEatEvent()
                        if Event then
                            Event:FireServer()
                        end
                    end)
                    task.wait(0.3)
                end
            end)
            print("🍽️ 自动吃已开启")
        else
            if eatThread then
                task.cancel(eatThread)
                eatThread = nil
            end
            print("🍽️ 自动吃已关闭")
        end
    end
})

T2:Divider()

-- ==================== 手动售卖（点击按钮，不是Toggle） ====================
T2:Paragraph({
    Title = "💰 手动售卖",
    Desc = "点击按钮执行一次售卖"
})

T2:Button({
    Title = "💰 售卖",
    Justify = "Center",
    Color = Color3.fromRGB(255, 200, 50),
    Callback = function()
        pcall(function()
            local Event = GetSellEvent()
            if Event then
                Event:FireServer()
                print("💰 售卖成功")
                WI:Notify({
                    Title = "💰 售卖成功",
                    Content = "已执行售卖",
                    Duration = 2,
                    Type = "success"
                })
            else
                WI:Notify({
                    Title = "❌ 失败",
                    Content = "未找到售卖事件",
                    Duration = 2,
                    Type = "error"
                })
            end
        end)
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
    Title = "吃吃世界",
    Content = "加载完成\n按 RightShift 开关面板\n\n版本 V2.1\n✅ 售卖改为手动点击",
    Buttons = {{
        Title = "确定",
        Variant = "Primary",
        Callback = function() end
    }}
})

print("✅ 吃吃世界 V2.1 加载完成")
