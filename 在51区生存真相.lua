-- 在51区生存真相 脚本 v1.0.0
-- WindUI蓝白版 | 自动重置

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
    AutoRebirthEnabled = false,
}

local VERSION = "v1.0.0"
local lastRebirthTime = 0
local RebirthDelay = 5 -- 固定5秒

-- 自动重置
local function autoRebirth()
    local Event = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("RebirthRequest")
    if Event then
        Event:InvokeServer()
        return true
    end
    return false
end

-- 自动重置循环（5秒固定）
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
    Title = "在51区生存真相",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(400, 350),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true,
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--在51区生存真相",
    Desc = "版本: " .. VERSION .. "\n\n支持功能：\n• 自动重置（每5秒）",
})

local MainTab = Window:Tab({Title = "主要", Icon = "solar:star-bold"})

MainTab:Toggle({
    Title = "自动重置",
    Value = false,
    Callback = function(enabled)
        Settings.AutoRebirthEnabled = enabled
        
        if enabled then
            WindUI:Notify({
                Title = "自动重置已开启",
                Content = "每5秒重置（固定）",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "自动重置已关闭",
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
    if Settings.AutoRebirthEnabled then
        status = status .. "✅ 自动重置: 已开启 (5秒)\n"
    else
        status = status .. "❌ 自动重置: 未开启\n"
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
    Title = "在51区生存真相",
    Content = VERSION .. " 加载完成",
    Duration = 3
})
