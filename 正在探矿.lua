-- 正在探矿 脚本 v1.0.1
-- WindUI蓝白版 | 自动挖沙 | 自动洗砂 | 自动买全部

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
    AutoDigEnabled = false,
    DigDelay = 0.5,
    DigPower = 1,
    AutoShakeEnabled = false,
    ShakeDelay = 0.5,
    AutoSellAllEnabled = false,
    SellAllDelay = 1,
}

local VERSION = "v1.0.1"
local lastDigTime = 0
local lastShakeTime = 0
local lastSellTime = 0

-- 自动挖沙
local function autoDig()
    local character = LocalPlayer.Character
    if not character then return false end
    
    local plasticPan = character:FindFirstChild("Plastic Pan")
    if not plasticPan then return false end
    
    local scripts = plasticPan:FindFirstChild("Scripts")
    if not scripts then return false end
    
    local collectEvent = scripts:FindFirstChild("Collect")
    if not collectEvent then return false end
    
    pcall(function()
        collectEvent:InvokeServer(Settings.DigPower, false)
    end)
    
    return true
end

-- 自动洗砂
local function autoShake()
    local character = LocalPlayer.Character
    if not character then return false end
    
    local plasticPan = character:FindFirstChild("Plastic Pan")
    if not plasticPan then return false end
    
    local scripts = plasticPan:FindFirstChild("Scripts")
    if not scripts then return false end
    
    local shakeEvent = scripts:FindFirstChild("Shake")
    if not shakeEvent then return false end
    
    pcall(function()
        shakeEvent:FireServer()
    end)
    
    return true
end

-- 自动买全部
local function autoSellAll()
    local Event = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Shop") and ReplicatedStorage.Remotes.Shop:FindFirstChild("SellAll")
    if not Event then return false end
    
    pcall(function()
        Event:InvokeServer()
    end)
    
    return true
end

-- 自动挖沙循环
task.spawn(function()
    while true do
        if Settings.AutoDigEnabled then
            local currentTime = tick()
            if currentTime - lastDigTime >= Settings.DigDelay then
                autoDig()
                lastDigTime = currentTime
            end
        end
        task.wait(0.05)
    end
end)

-- 自动洗砂循环
task.spawn(function()
    while true do
        if Settings.AutoShakeEnabled then
            local currentTime = tick()
            if currentTime - lastShakeTime >= Settings.ShakeDelay then
                autoShake()
                lastShakeTime = currentTime
            end
        end
        task.wait(0.05)
    end
end)

-- 自动买全部循环
task.spawn(function()
    while true do
        if Settings.AutoSellAllEnabled then
            local currentTime = tick()
            if currentTime - lastSellTime >= Settings.SellAllDelay then
                autoSellAll()
                lastSellTime = currentTime
            end
        end
        task.wait(0.05)
    end
end)

local Window = WindUI:CreateWindow({
    Title = "正在探矿",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(400, 350),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true,
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--正在探矿",
    Desc = "版本: " .. VERSION .. "\n\n支持功能：\n• 自动挖沙（力度可调0.1-2）\n• 自动洗砂\n• 自动买全部",
})

local MainTab = Window:Tab({Title = "主要功能", Icon = "solar:star-bold"})

MainTab:Toggle({
    Title = "自动挖沙",
    Value = false,
    Callback = function(enabled)
        Settings.AutoDigEnabled = enabled
        
        if enabled then
            WindUI:Notify({
                Title = "自动挖沙已开启",
                Content = "力度: " .. Settings.DigPower,
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "自动挖沙已关闭",
                Content = "已停止",
                Duration = 2
            })
        end
    end
})

MainTab:Slider({
    Title = "挖沙力度 (0.1-2)",
    Value = {Min = 0.1, Max = 2, Default = 1},
    Step = 0.1,
    Callback = function(power)
        Settings.DigPower = power
    end
})

MainTab:Slider({
    Title = "挖沙延迟 (0.1-3秒)",
    Value = {Min = 0.1, Max = 3, Default = 0.5},
    Step = 0.1,
    Callback = function(delay)
        Settings.DigDelay = delay
    end
})

MainTab:Divider()

MainTab:Toggle({
    Title = "自动洗砂",
    Value = false,
    Callback = function(enabled)
        Settings.AutoShakeEnabled = enabled
        
        if enabled then
            WindUI:Notify({
                Title = "自动洗砂已开启",
                Content = "延迟: " .. Settings.ShakeDelay .. "秒",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "自动洗砂已关闭",
                Content = "已停止",
                Duration = 2
            })
        end
    end
})

MainTab:Slider({
    Title = "洗砂延迟 (0.1-3秒)",
    Value = {Min = 0.1, Max = 3, Default = 0.5},
    Step = 0.1,
    Callback = function(delay)
        Settings.ShakeDelay = delay
    end
})

MainTab:Divider()

MainTab:Toggle({
    Title = "自动买全部",
    Value = false,
    Callback = function(enabled)
        Settings.AutoSellAllEnabled = enabled
        
        if enabled then
            WindUI:Notify({
                Title = "自动买全部已开启",
                Content = "延迟: " .. Settings.SellAllDelay .. "秒",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "自动买全部已关闭",
                Content = "已停止",
                Duration = 2
            })
        end
    end
})

MainTab:Slider({
    Title = "买全部延迟 (0.5-5秒)",
    Value = {Min = 0.5, Max = 5, Default = 1},
    Step = 0.5,
    Callback = function(delay)
        Settings.SellAllDelay = delay
    end
})

MainTab:Divider()

MainTab:Button({
    Title = "手动挖沙一次",
    Callback = function()
        if autoDig() then
            WindUI:Notify({
                Title = "成功",
                Content = "已挖沙",
                Duration = 2
            })
        else
            WindUI:Notify({
                Title = "失败",
                Content = "找不到Plastic Pan",
                Duration = 2
            })
        end
    end
})

MainTab:Button({
    Title = "手动洗砂一次",
    Callback = function()
        if autoShake() then
            WindUI:Notify({
                Title = "成功",
                Content = "已洗砂",
                Duration = 2
            })
        else
            WindUI:Notify({
                Title = "失败",
                Content = "找不到Plastic Pan",
                Duration = 2
            })
        end
    end
})

MainTab:Button({
    Title = "手动买全部一次",
    Callback = function()
        if autoSellAll() then
            WindUI:Notify({
                Title = "成功",
                Content = "已买全部",
                Duration = 2
            })
        else
            WindUI:Notify({
                Title = "失败",
                Content = "找不到SellAll事件",
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
    if Settings.AutoDigEnabled then
        status = status .. "✅ 自动挖沙: 已开启 (力度: " .. Settings.DigPower .. ")\n"
    else
        status = status .. "❌ 自动挖沙: 未开启\n"
    end
    if Settings.AutoShakeEnabled then
        status = status .. "✅ 自动洗砂: 已开启\n"
    else
        status = status .. "❌ 自动洗砂: 未开启\n"
    end
    if Settings.AutoSellAllEnabled then
        status = status .. "✅ 自动买全部: 已开启\n"
    else
        status = status .. "❌ 自动买全部: 未开启\n"
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
    Title = "正在探矿",
    Content = VERSION .. " 加载完成",
    Duration = 3
})
