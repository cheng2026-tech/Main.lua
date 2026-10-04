-- 新手间接式 脚本 v1.0.0
-- WindUI蓝白版 | 自动升级菜鸟 | 自动重生 | 自动买更多菜鸟

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
    AutoUpgradeNoobEnabled = false,
    AutoRebirthEnabled = false,
    AutoMoreNoobEnabled = false,
}

local VERSION = "v1.0.0"
local lastUpgradeNoobTime = 0
local lastRebirthTime = 0
local lastMoreNoobTime = 0
local UpgradeNoobDelay = 0.01 -- 固定
local RebirthDelay = 10 -- 固定
local MoreNoobDelay = 1 -- 固定

-- 自动升级菜鸟
local function autoUpgradeNoob()
    local Event = ReplicatedStorage:FindFirstChild("__Net") and ReplicatedStorage.__Net:FindFirstChild("MainRemote")
    if Event then
        Event:FireServer("UpgradeNoob", "Starter")
        return true
    end
    return false
end

-- 自动重生
local function autoRebirth()
    local Event = ReplicatedStorage:FindFirstChild("__Net") and ReplicatedStorage.__Net:FindFirstChild("MainRemote")
    if Event then
        Event:FireServer("Rebirth")
        return true
    end
    return false
end

-- 自动买更多菜鸟
local function autoMoreNoob()
    local Event = ReplicatedStorage:FindFirstChild("__Net") and ReplicatedStorage.__Net:FindFirstChild("MainRemote")
    if Event then
        Event:FireServer("UpgradeUpgrade", "Rebirth", "MoreOof")
        return true
    end
    return false
end

-- 自动升级菜鸟循环（0.01秒固定）
task.spawn(function()
    while true do
        if Settings.AutoUpgradeNoobEnabled then
            local currentTime = tick()
            if currentTime - lastUpgradeNoobTime >= UpgradeNoobDelay then
                autoUpgradeNoob()
                lastUpgradeNoobTime = currentTime
            end
        end
        task.wait(0.005)
    end
end)

-- 自动重生循环（10秒固定）
task.spawn(function()
    while true do
        if Settings.AutoRebirthEnabled then
            local currentTime = tick()
            if currentTime - lastRebirthTime >= RebirthDelay then
                autoRebirth()
                lastRebirthTime = currentTime
            end
        end
        task.wait(0.05)
    end
end)

-- 自动买更多菜鸟循环（1秒固定）
task.spawn(function()
    while true do
        if Settings.AutoMoreNoobEnabled then
            local currentTime = tick()
            if currentTime - lastMoreNoobTime >= MoreNoobDelay then
                autoMoreNoob()
                lastMoreNoobTime = currentTime
            end
        end
        task.wait(0.05)
    end
end)

local Window = WindUI:CreateWindow({
    Title = "新手间接式",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(400, 350),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true,
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--新手间接式",
    Desc = "版本: " .. VERSION,
})

local MainTab = Window:Tab({Title = "主要", Icon = "solar:star-bold"})

MainTab:Toggle({
    Title = "自动升级菜鸟",
    Value = false,
    Callback = function(v)
        Settings.AutoUpgradeNoobEnabled = v
        if v then
            WindUI:Notify({Title = "已开启", Content = "延迟0.01秒（固定）", Duration = 3})
        end
    end
})

MainTab:Divider()

MainTab:Toggle({
    Title = "自动重生",
    Value = false,
    Callback = function(v)
        Settings.AutoRebirthEnabled = v
        if v then
            WindUI:Notify({Title = "已开启", Content = "延迟10秒（固定）", Duration = 3})
        end
    end
})

MainTab:Divider()

MainTab:Toggle({
    Title = "自动买更多菜鸟",
    Value = false,
    Callback = function(v)
        Settings.AutoMoreNoobEnabled = v
        if v then
            WindUI:Notify({Title = "已开启", Content = "延迟1秒（固定）", Duration = 3})
        end
    end
})

local SettingsTab = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})

local statusParagraph = SettingsTab:Paragraph({
    Title = "功能状态",
    Desc = "正在加载..."
})

task.spawn(function()
    while true do
        local status = ""
        if Settings.AutoUpgradeNoobEnabled then status = status .. "✅ 自动升级菜鸟: 已开启 (0.01秒)\n" else status = status .. "❌ 自动升级菜鸟: 未开启\n" end
        if Settings.AutoRebirthEnabled then status = status .. "✅ 自动重生: 已开启 (10秒)\n" else status = status .. "❌ 自动重生: 未开启\n" end
        if Settings.AutoMoreNoobEnabled then status = status .. "✅ 自动买更多菜鸟: 已开启 (1秒)\n" else status = status .. "❌ 自动买更多菜鸟: 未开启\n" end
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
    Title = "新手间接式",
    Content = VERSION .. " 加载完成",
    Duration = 3
})
