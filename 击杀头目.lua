-- 击杀头目 脚本 v1.0.0
-- WindUI蓝白版 | 无限力量 | 无限钱

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

local Settings = {
    InfinitePowerEnabled = false,
    InfiniteMoneyEnabled = false,
    PowerDelay = 0.5,
    MoneyDelay = 0.5,
}

local VERSION = "v1.0.0"
local lastPowerTime = 0
local lastMoneyTime = 0

-- 无限力量
local function useInfinitePower()
    local Event = ReplicatedStorage:FindFirstChild("Event") and ReplicatedStorage.Event:FindFirstChild("Train")
    if Event then
        Event:FireServer(9e9999999999)
        return true
    end
    return false
end

-- 无限钱
local function useInfiniteMoney()
    local Event = ReplicatedStorage:FindFirstChild("Event") and ReplicatedStorage.Event:FindFirstChild("WinGain")
    if Event then
        Event:FireServer(9e99999999)
        return true
    end
    return false
end

-- 无限力量循环
task.spawn(function()
    while true do
        if Settings.InfinitePowerEnabled then
            local currentTime = tick()
            if currentTime - lastPowerTime >= Settings.PowerDelay then
                useInfinitePower()
                lastPowerTime = currentTime
            end
        end
        task.wait(0.05)
    end
end)

-- 无限钱循环
task.spawn(function()
    while true do
        if Settings.InfiniteMoneyEnabled then
            local currentTime = tick()
            if currentTime - lastMoneyTime >= Settings.MoneyDelay then
                useInfiniteMoney()
                lastMoneyTime = currentTime
            end
        end
        task.wait(0.05)
    end
end)

local Window = WindUI:CreateWindow({
    Title = "击杀头目",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(400, 350),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true,
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--击杀头目",
    Desc = "版本: " .. VERSION .. "\n\n支持功能：\n• 无限力量\n• 无限钱",
})

local MainTab = Window:Tab({Title = "主要功能", Icon = "solar:star-bold"})

MainTab:Toggle({
    Title = "无限力量",
    Value = false,
    Callback = function(enabled)
        Settings.InfinitePowerEnabled = enabled
        
        if enabled then
            WindUI:Notify({
                Title = "无限力量已开启",
                Content = "延迟: " .. Settings.PowerDelay .. "秒",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "无限力量已关闭",
                Content = "已停止",
                Duration = 2
            })
        end
    end
})

MainTab:Slider({
    Title = "力量延迟 (0.1-5秒)",
    Value = {Min = 0.1, Max = 5, Default = 0.5},
    Step = 0.1,
    Callback = function(delay)
        Settings.PowerDelay = delay
    end
})

MainTab:Divider()

MainTab:Toggle({
    Title = "无限钱",
    Value = false,
    Callback = function(enabled)
        Settings.InfiniteMoneyEnabled = enabled
        
        if enabled then
            WindUI:Notify({
                Title = "无限钱已开启",
                Content = "延迟: " .. Settings.MoneyDelay .. "秒",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "无限钱已关闭",
                Content = "已停止",
                Duration = 2
            })
        end
    end
})

MainTab:Slider({
    Title = "金钱延迟 (0.1-5秒)",
    Value = {Min = 0.1, Max = 5, Default = 0.5},
    Step = 0.1,
    Callback = function(delay)
        Settings.MoneyDelay = delay
    end
})

MainTab:Divider()

MainTab:Button({
    Title = "手动获得一次力量",
    Callback = function()
        if useInfinitePower() then
            WindUI:Notify({
                Title = "成功",
                Content = "已获得力量",
                Duration = 2
            })
        else
            WindUI:Notify({
                Title = "失败",
                Content = "找不到Train事件",
                Duration = 2
            })
        end
    end
})

MainTab:Button({
    Title = "手动获得一次金钱",
    Callback = function()
        if useInfiniteMoney() then
            WindUI:Notify({
                Title = "成功",
                Content = "已获得金钱",
                Duration = 2
            })
        else
            WindUI:Notify({
                Title = "失败",
                Content = "找不到WinGain事件",
                Duration = 2
            })
        end
    end
})

local SettingsTab = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})

local statusParagraph = SettingsTab:Paragraph({
    Title = "功能状态",
    Desc = "正在加载..."
})

local function updateStatus()
    local status = ""
    if Settings.InfinitePowerEnabled then
        status = status .. "✅ 无限力量: 已开启\n"
    else
        status = status .. "❌ 无限力量: 未开启\n"
    end
    if Settings.InfiniteMoneyEnabled then
        status = status .. "✅ 无限钱: 已开启\n"
    else
        status = status .. "❌ 无限钱: 未开启\n"
    end
    statusParagraph:SetDesc(status)
end

RunService.Heartbeat:Connect(function() updateStatus() end)

SettingsTab:Button({
    Title = "关闭面板",
    Callback = function() Window:Close() end
})

Window:OnClose(function() end)

WindUI:Notify({
    Title = "击杀头目",
    Content = VERSION .. " 加载完成",
    Duration = 3
})
