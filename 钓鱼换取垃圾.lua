-- 钓鱼换取垃圾 脚本 v1.0.0
-- WindUI蓝白版 | 自动售卖 | 自动升级

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
    AutoSellEnabled = false,
    SellDelay = 5,
    AutoLuckEnabled = false,
    LuckDelay = 3,
    AutoValueEnabled = false,
    ValueDelay = 3,
}

local VERSION = "v1.0.0"
local lastSellTime = 0
local lastLuckTime = 0
local lastValueTime = 0

-- 自动售卖
local function autoSell()
    local Event = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Gameplay") and ReplicatedStorage.Remotes.Gameplay:FindFirstChild("SellAllItems")
    if Event then
        Event:FireServer()
        return true
    end
    return false
end

-- 自动升级运气
local function autoLuck()
    local Event = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Gameplay") and ReplicatedStorage.Remotes.Gameplay:FindFirstChild("PurchaseUpgrade")
    if Event then
        Event:FireServer("LuckMultiplier")
        return true
    end
    return false
end

-- 自动升级价值倍率
local function autoValue()
    local Event = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Gameplay") and ReplicatedStorage.Remotes.Gameplay:FindFirstChild("PurchaseUpgrade")
    if Event then
        Event:FireServer("ValueMultiplier")
        return true
    end
    return false
end

-- 自动售卖循环
task.spawn(function()
    while true do
        if Settings.AutoSellEnabled then
            local currentTime = tick()
            if currentTime - lastSellTime >= Settings.SellDelay then
                autoSell()
                lastSellTime = currentTime
            end
        end
        task.wait(0.1)
    end
end)

-- 自动升级运气循环
task.spawn(function()
    while true do
        if Settings.AutoLuckEnabled then
            local currentTime = tick()
            if currentTime - lastLuckTime >= Settings.LuckDelay then
                autoLuck()
                lastLuckTime = currentTime
            end
        end
        task.wait(0.1)
    end
end)

-- 自动升级价值倍率循环
task.spawn(function()
    while true do
        if Settings.AutoValueEnabled then
            local currentTime = tick()
            if currentTime - lastValueTime >= Settings.ValueDelay then
                autoValue()
                lastValueTime = currentTime
            end
        end
        task.wait(0.1)
    end
end)

local Window = WindUI:CreateWindow({
    Title = "钓鱼换取垃圾",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(400, 350),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true,
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--钓鱼换取垃圾",
    Desc = "版本: " .. VERSION,
})

local MainTab = Window:Tab({Title = "主要", Icon = "solar:star-bold"})

MainTab:Toggle({
    Title = "自动售卖",
    Value = false,
    Callback = function(v) Settings.AutoSellEnabled = v end
})

MainTab:Slider({
    Title = "售卖延迟)",
    Value = {Min = 3, Max = 30, Default = 5},
    Step = 1,
    Callback = function(v) Settings.SellDelay = v end
})

MainTab:Divider()

MainTab:Toggle({
    Title = "自动升级运气",
    Value = false,
    Callback = function(v) Settings.AutoLuckEnabled = v end
})

MainTab:Slider({
    Title = "运气升级延迟",
    Value = {Min = 1, Max = 15, Default = 3},
    Step = 1,
    Callback = function(v) Settings.LuckDelay = v end
})

MainTab:Divider()

MainTab:Toggle({
    Title = "自动升级价值倍率",
    Value = false,
    Callback = function(v) Settings.AutoValueEnabled = v end
})

MainTab:Slider({
    Title = "价值升级延迟",
    Value = {Min = 1, Max = 15, Default = 3},
    Step = 1,
    Callback = function(v) Settings.ValueDelay = v end
})

local SettingsTab = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})

local statusParagraph = SettingsTab:Paragraph({
    Title = "功能状态",
    Desc = "正在加载..."
})

task.spawn(function()
    while true do
        local status = ""
        if Settings.AutoSellEnabled then status = status .. "✅ 自动售卖: 已开启\n" else status = status .. "❌ 自动售卖: 未开启\n" end
        if Settings.AutoLuckEnabled then status = status .. "✅ 自动升级运气: 已开启\n" else status = status .. "❌ 自动升级运气: 未开启\n" end
        if Settings.AutoValueEnabled then status = status .. "✅ 自动升级价值: 已开启\n" else status = status .. "❌ 自动升级价值: 未开启\n" end
        statusParagraph:SetDesc(status)
        task.wait(1)
    end
end)

SettingsTab:Button({
    Title = "关闭面板",
    Callback = function() Window:Close() end
})

Window:OnClose(function() end)

WindUI:Notify({
    Title = "钓鱼换取垃圾",
    Content = VERSION .. " 加载完成",
    Duration = 3
})
