-- 🌙 我的木材农场 | V1.1

local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- 变量
local autoChipper = false
local autoAxeSpeed = false
local autoStump = false
local autoPlaytime = false
local upgradeInterval = 1
local playtimeReward = 1

-- ==================== 冰白主题 ====================
WI:AddTheme({
    Name = "冰白",
    Accent = "#80C0FF",
    Outline = "#6090C0",
    Text = "#FFFFFF",
    Placeholder = "#D0E0FF"
})

-- ==================== 自动升级加工木材 ====================
spawn(function()
    while true do
        if autoChipper then
            pcall(function()
                local Event = game:GetService("ReplicatedStorage").ChipperAction
                Event:FireServer("upgrade")
            end)
        end
        task.wait(upgradeInterval)
    end
end)

-- ==================== 自动升级斧头速度 ====================
spawn(function()
    while true do
        if autoAxeSpeed then
            pcall(function()
                local Event = game:GetService("ReplicatedStorage").TreeAction
                Event:FireServer("axespeed")
            end)
        end
        task.wait(upgradeInterval)
    end
end)

-- ==================== 自动升级树桩 ====================
spawn(function()
    while true do
        if autoStump then
            pcall(function()
                local Event = game:GetService("ReplicatedStorage").TreeAction
                Event:FireServer("buystump")
            end)
        end
        task.wait(upgradeInterval)
    end
end)

-- ==================== 自动领时间奖励（1-7循环）====================
spawn(function()
    while true do
        if autoPlaytime then
            pcall(function()
                local Event = game:GetService("ReplicatedStorage").PlotRemotes.PlaytimeClaim
                Event:FireServer(playtimeReward)
                playtimeReward = playtimeReward + 1
                if playtimeReward > 7 then playtimeReward = 1 end
            end)
        end
        task.wait(1)
    end
end)

-- ==================== UI ====================
local Window = WI:CreateWindow({
    Title = "我的木材农场",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(400, 380),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--我的木材农场",
    Desc = "自动升级 | 自动领时间奖励"
})

local T2 = Window:Tab({Title = "主要功能", Icon = "solar:star-bold"})
T2:Toggle({Title = "自动升级加工木材", Value = false, Callback = function(v) autoChipper = v end})
T2:Toggle({Title = "自动升级斧头速度", Value = false, Callback = function(v) autoAxeSpeed = v end})
T2:Toggle({Title = "自动升级树桩", Value = false, Callback = function(v) autoStump = v end})
T2:Slider({Title = "升级间隔(秒)", Value = {Min = 0.5, Max = 10, Default = 1}, Step = 0.5, Callback = function(v) upgradeInterval = v end})
T2:Divider()
T2:Toggle({Title = "自动领时间奖励", Value = false, Callback = function(v) autoPlaytime = v; if v then playtimeReward = 1 end end})

local T3 = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})
local statusParagraph = T3:Paragraph({Title = "功能状态", Desc = "加载中..."})

spawn(function()
    while true do
        pcall(function()
            local fps = math.floor(1 / (RunService.RenderStepped:Wait() or 0.016))
            local status = "FPS: " .. fps .. "\n\n" ..
                "加工木材: " .. (autoChipper and "✅" or "❌") .. "\n" ..
                "斧头速度: " .. (autoAxeSpeed and "✅" or "❌") .. "\n" ..
                "树桩: " .. (autoStump and "✅" or "❌") .. "\n" ..
                "时间奖励: " .. (autoPlaytime and "✅ 当前" .. playtimeReward or "❌")
            statusParagraph:SetDesc(status)
        end)
        task.wait(0.5)
    end
end)

T3:Button({Title = "关闭面板", Justify = "Center", Callback = function() Window:Close() end})

WI:Notify({Title = "🌙 我的木材农场", Content = "加载完成", Duration = 3})
print("🌙 我的木材农场 加载完成")
