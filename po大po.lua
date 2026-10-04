-- Po大Po | V1.0

local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ==================== 变量 ====================
local autoPull = false
local autoThread = nil

-- ==================== 获取事件 ====================
local function GetPacketEvent()
    local packets = ReplicatedStorage:FindFirstChild("Packets")
    if not packets then return nil end
    local packet = packets:FindFirstChild("Packet")
    if not packet then return nil end
    return packet:FindFirstChild("RemoteEvent")
end

-- ==================== 执行拉 ====================
function DoPull()
    local Event = GetPacketEvent()
    if Event then
        local bytes = {0, 0, 0, 0}
        local b = buffer.create(#bytes)
        for i = 1, #bytes do
            buffer.writeu8(b, i - 1, bytes[i])
        end
        Event:FireServer(b)
        print("拉")
        return true
    else
        print("未找到Packet事件")
        return false
    end
end

-- ==================== 自动拉 ====================
function StartAutoPull()
    if autoThread then
        task.cancel(autoThread)
        autoThread = nil
    end
    autoThread = task.spawn(function()
        while autoPull do
            pcall(DoPull)
            task.wait(1)
        end
    end)
end

-- ==================== Wind UI ====================
local MainWindow = WI:CreateWindow({
    Title = "Po大Po",
    Icon = "solar:game-bold",
    Size = UDim2.fromOffset(480, 440),
    ToggleKey = Enum.KeyCode.RightShift,
    Acrylic = true,
    ScrollBarEnabled = true
})

-- ==================== 公告 ====================
local T1 = MainWindow:Tab({Title = "公告", Icon = "solar:info-bold"})

T1:Paragraph({
    Title = "黑脚本--Po大Po",
    Desc = "版本 V1.0\n\n功能列表：\n- 自动拉（间隔1秒）\n- 手动拉（点击按钮）\n- 速度调节\n\n警告：自动拉有概率被踢出游戏"
})

T1:Button({
    Title = "关闭面板",
    Justify = "Center",
    Color = Color3.fromHex("#888888"),
    Callback = function()
        MainWindow:Close()
    end
})

-- ==================== 自动功能 ====================
local T2 = MainWindow:Tab({Title = "自动功能", Icon = "solar:settings-bold"})

T2:Paragraph({
    Title = "自动功能",
    Desc = "开启后自动执行"
})

T2:Divider()

T2:Toggle({
    Title = "自动拉",
    Value = false,
    Callback = function(v)
        autoPull = v
        if autoPull then
            StartAutoPull()
            print("自动拉已开启（间隔1秒）")
            WI:Notify({
                Title = "已开启",
                Content = "自动拉已开启（间隔1秒）",
                Duration = 2,
                Type = "success"
            })
        else
            if autoThread then
                task.cancel(autoThread)
                autoThread = nil
            end
            print("自动拉已关闭")
            WI:Notify({
                Title = "已关闭",
                Content = "自动拉已关闭",
                Duration = 2,
                Type = "warning"
            })
        end
    end
})

T2:Paragraph({
    Title = "⚠️ 警告",
    Desc = "自动拉有概率被踢出游戏，请谨慎使用"
})

T2:Divider()

T2:Button({
    Title = "手动拉",
    Justify = "Center",
    Color = Color3.fromRGB(255, 200, 50),
    Callback = function()
        local success = DoPull()
        if success then
            WI:Notify({
                Title = "拉成功",
                Content = "已执行拉",
                Duration = 2,
                Type = "success"
            })
        else
            WI:Notify({
                Title = "拉失败",
                Content = "未找到Packet事件",
                Duration = 2,
                Type = "error"
            })
        end
    end
})

-- ==================== 玩家 ====================
local T3 = MainWindow:Tab({Title = "玩家", Icon = "solar:user-bold"})

T3:Paragraph({
    Title = "玩家设置",
    Desc = "调节玩家属性"
})

T3:Divider()

local speedValue = 16
local speedEnabled = false

T3:Toggle({
    Title = "开启速度调节",
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
            if speedEnabled then
                local c = LocalPlayer.Character
                if c and c:FindFirstChild("Humanoid") then
                    c.Humanoid.WalkSpeed = speedValue
                end
            end
        end
    end
})

T3:Button({
    Title = "推荐（20速度）",
    Justify = "Center",
    Color = Color3.fromRGB(255, 200, 50),
    Callback = function()
        speedValue = 20
        if speedEnabled then
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then
                c.Humanoid.WalkSpeed = 20
            end
        end
    end
})

-- ==================== 速度循环 ====================
task.spawn(function()
    while true do
        if speedEnabled then
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then
                c.Humanoid.WalkSpeed = speedValue
            end
        end
        task.wait(0.1)
    end
end)

-- ==================== 启动弹窗 ====================
WI:Popup({
    Title = "Po大Po",
    Content = "加载完成\n按 RightShift 开关面板\n\n版本 V1.0\n\n⚠️ 自动拉有概率被踢出游戏",
    Buttons = {{
        Title = "确定",
        Variant = "Primary",
        Callback = function() end
    }}
})

print("Po大Po V1.0 加载完成")
