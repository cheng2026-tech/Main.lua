-- 按下一个键帽 脚本 v1.0.1
-- WindUI蓝白版 | 自动踩键帽 | 自动买员工 | 自动领取 | 自动抽取 | 自动重生

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
    AutoKeycapEnabled = false,
    AutoBuyWorkerEnabled = false,
    AutoClaimEnabled = false,
    AutoRollEnabled = false,
    AutoRebirthEnabled = false,
    RollDelay = 1,
}

local VERSION = "v1.0.1"
local lastKeycapTime = 0
local lastBuyWorkerTime = 0
local lastClaimTime = 0
local lastRollTime = 0
local lastRebirthTime = 0
local KeycapDelay = 0.01
local BuyWorkerDelay = 10
local RebirthDelay = 10

-- 自动踩键帽
local function autoKeycap()
    local Event = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("_Index") and ReplicatedStorage.Packages._Index:FindFirstChild("leifstout_networker@0.3.1") and ReplicatedStorage.Packages._Index["leifstout_networker@0.3.1"]:FindFirstChild("networker") and ReplicatedStorage.Packages._Index["leifstout_networker@0.3.1"].networker:FindFirstChild("_remotes") and ReplicatedStorage.Packages._Index["leifstout_networker@0.3.1"].networker._remotes:FindFirstChild("Keycaps") and ReplicatedStorage.Packages._Index["leifstout_networker@0.3.1"].networker._remotes.Keycaps:FindFirstChild("RemoteEvent")
    
    if Event then
        Event:FireServer("SubmitPresses", "Plot3", {44})
        return true
    end
    return false
end

-- 自动买员工
local function autoBuyWorker()
    local Event = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("_Index") and ReplicatedStorage.Packages._Index:FindFirstChild("leifstout_networker@0.3.1") and ReplicatedStorage.Packages._Index["leifstout_networker@0.3.1"]:FindFirstChild("networker") and ReplicatedStorage.Packages._Index["leifstout_networker@0.3.1"].networker:FindFirstChild("_remotes") and ReplicatedStorage.Packages._Index["leifstout_networker@0.3.1"].networker._remotes:FindFirstChild("Workers") and ReplicatedStorage.Packages._Index["leifstout_networker@0.3.1"].networker._remotes.Workers:FindFirstChild("RemoteEvent")
    
    if Event then
        Event:FireServer("BuyWorkers", 1)
        return true
    end
    return false
end

-- 自动领取抽到键帽
local function autoClaim()
    local Event = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("_Index") and ReplicatedStorage.Packages._Index:FindFirstChild("leifstout_networker@0.3.1") and ReplicatedStorage.Packages._Index["leifstout_networker@0.3.1"]:FindFirstChild("networker") and ReplicatedStorage.Packages._Index["leifstout_networker@0.3.1"].networker:FindFirstChild("_remotes") and ReplicatedStorage.Packages._Index["leifstout_networker@0.3.1"].networker._remotes:FindFirstChild("Unlock") and ReplicatedStorage.Packages._Index["leifstout_networker@0.3.1"].networker._remotes.Unlock:FindFirstChild("RemoteEvent")
    
    if Event then
        Event:FireServer("ClaimUnlock", 1)
        return true
    end
    return false
end

-- 自动抽取键帽
local function autoRoll()
    local Event = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("_Index") and ReplicatedStorage.Packages._Index:FindFirstChild("leifstout_networker@0.3.1") and ReplicatedStorage.Packages._Index["leifstout_networker@0.3.1"]:FindFirstChild("networker") and ReplicatedStorage.Packages._Index["leifstout_networker@0.3.1"].networker:FindFirstChild("_remotes") and ReplicatedStorage.Packages._Index["leifstout_networker@0.3.1"].networker._remotes:FindFirstChild("Unlock") and ReplicatedStorage.Packages._Index["leifstout_networker@0.3.1"].networker._remotes.Unlock:FindFirstChild("RemoteEvent")
    
    if Event then
        Event:FireServer("RequestRoll", "Plot3")
        return true
    end
    return false
end

-- 自动重生
local function autoRebirth()
    local Event = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("_Index") and ReplicatedStorage.Packages._Index:FindFirstChild("leifstout_networker@0.3.1") and ReplicatedStorage.Packages._Index["leifstout_networker@0.3.1"]:FindFirstChild("networker") and ReplicatedStorage.Packages._Index["leifstout_networker@0.3.1"].networker:FindFirstChild("_remotes") and ReplicatedStorage.Packages._Index["leifstout_networker@0.3.1"].networker._remotes:FindFirstChild("Rebirth") and ReplicatedStorage.Packages._Index["leifstout_networker@0.3.1"].networker._remotes.Rebirth:FindFirstChild("RemoteEvent")
    
    if Event then
        Event:FireServer("Rebirth")
        return true
    end
    return false
end

-- 自动踩键帽循环
task.spawn(function()
    while true do
        if Settings.AutoKeycapEnabled then
            local currentTime = tick()
            if currentTime - lastKeycapTime >= KeycapDelay then
                autoKeycap()
                lastKeycapTime = currentTime
            end
        end
        task.wait(0.005)
    end
end)

-- 自动买员工循环
task.spawn(function()
    while true do
        if Settings.AutoBuyWorkerEnabled then
            local currentTime = tick()
            if currentTime - lastBuyWorkerTime >= BuyWorkerDelay then
                autoBuyWorker()
                lastBuyWorkerTime = currentTime
            end
        end
        task.wait(0.05)
    end
end)

-- 自动领取循环
task.spawn(function()
    while true do
        if Settings.AutoClaimEnabled then
            local currentTime = tick()
            if currentTime - lastClaimTime >= 1 then
                autoClaim()
                lastClaimTime = currentTime
            end
        end
        task.wait(0.05)
    end
end)

-- 自动抽取循环
task.spawn(function()
    while true do
        if Settings.AutoRollEnabled then
            local currentTime = tick()
            if currentTime - lastRollTime >= Settings.RollDelay then
                autoRoll()
                lastRollTime = currentTime
            end
        end
        task.wait(0.05)
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

local Window = WindUI:CreateWindow({
    Title = "按下一个键帽",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(400, 350),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true,
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--按下一个键帽",
    Desc = "版本: " .. VERSION .. "\n\n支持功能：\n• 自动踩键帽（0.01秒固定）\n• 自动买员工（10秒固定）\n• 自动领取抽到键帽\n• 自动抽取键帽\n• 自动重生（10秒固定）",
})

local MainTab = Window:Tab({Title = "主要功能", Icon = "solar:star-bold"})

MainTab:Toggle({
    Title = "自动踩键帽",
    Value = false,
    Callback = function(enabled)
        Settings.AutoKeycapEnabled = enabled
        
        if enabled then
            WindUI:Notify({
                Title = "自动踩键帽已开启",
                Content = "延迟: 0.01秒（固定）",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "自动踩键帽已关闭",
                Content = "已停止",
                Duration = 2
            })
        end
    end
})

MainTab:Divider()

MainTab:Toggle({
    Title = "自动买员工",
    Value = false,
    Callback = function(enabled)
        Settings.AutoBuyWorkerEnabled = enabled
        
        if enabled then
            WindUI:Notify({
                Title = "自动买员工已开启",
                Content = "每10秒买1个（固定）",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "自动买员工已关闭",
                Content = "已停止",
                Duration = 2
            })
        end
    end
})

MainTab:Divider()

MainTab:Toggle({
    Title = "自动领取抽到键帽",
    Value = false,
    Callback = function(enabled)
        Settings.AutoClaimEnabled = enabled
        
        if enabled then
            WindUI:Notify({
                Title = "自动领取已开启",
                Content = "每1秒领取一次",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "自动领取已关闭",
                Content = "已停止",
                Duration = 2
            })
        end
    end
})

MainTab:Divider()

MainTab:Toggle({
    Title = "自动抽取键帽",
    Value = false,
    Callback = function(enabled)
        Settings.AutoRollEnabled = enabled
        
        if enabled then
            WindUI:Notify({
                Title = "自动抽取已开启",
                Content = "延迟: " .. Settings.RollDelay .. "秒",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "自动抽取已关闭",
                Content = "已停止",
                Duration = 2
            })
        end
    end
})

MainTab:Slider({
    Title = "抽取延迟 (0.5-5秒)",
    Value = {Min = 0.5, Max = 5, Default = 1},
    Step = 0.5,
    Callback = function(delay)
        Settings.RollDelay = delay
    end
})

MainTab:Divider()

MainTab:Toggle({
    Title = "自动重生",
    Value = false,
    Callback = function(enabled)
        Settings.AutoRebirthEnabled = enabled
        
        if enabled then
            WindUI:Notify({
                Title = "自动重生已开启",
                Content = "每10秒重生（固定）",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "自动重生已关闭",
                Content = "已停止",
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
    if Settings.AutoKeycapEnabled then
        status = status .. "✅ 自动踩键帽: 已开启 (0.01秒)\n"
    else
        status = status .. "❌ 自动踩键帽: 未开启\n"
    end
    if Settings.AutoBuyWorkerEnabled then
        status = status .. "✅ 自动买员工: 已开启 (10秒)\n"
    else
        status = status .. "❌ 自动买员工: 未开启\n"
    end
    if Settings.AutoClaimEnabled then
        status = status .. "✅ 自动领取: 已开启\n"
    else
        status = status .. "❌ 自动领取: 未开启\n"
    end
    if Settings.AutoRollEnabled then
        status = status .. "✅ 自动抽取: 已开启 (" .. Settings.RollDelay .. "秒)\n"
    else
        status = status .. "❌ 自动抽取: 未开启\n"
    end
    if Settings.AutoRebirthEnabled then
        status = status .. "✅ 自动重生: 已开启 (10秒)\n"
    else
        status = status .. "❌ 自动重生: 未开启\n"
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
    Title = "按下一个键帽",
    Content = VERSION .. " 加载完成",
    Duration = 3
})
