-- 🌙 清理所有树叶 | V1.8

local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- 变量
local autoCollect = false
local collectInterval = 0.05
local autoSell = false
local sellInterval = 5
local speedBoost = false
local speedValue = 50
local currentLeafId = 1
local autoDexterity = false
local autoHold = false
local autoGrasp = false
local upgradeInterval = 1

-- ==================== 冰白主题 ====================
WI:AddTheme({
    Name = "冰白",
    Accent = "#80C0FF",
    Outline = "#6090C0",
    Text = "#FFFFFF",
    Placeholder = "#D0E0FF"
})

-- ==================== 速度 ====================
RunService.RenderStepped:Connect(function()
    if speedBoost then
        pcall(function()
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then
                c.Humanoid.WalkSpeed = speedValue
            end
        end)
    end
end)

-- ==================== 自动清理树叶（ID从1到100000循环）====================
spawn(function()
    while true do
        if autoCollect then
            pcall(function()
                local Event = game:GetService("ReplicatedStorage").Remotes.CollectLeaf
                Event:FireServer(currentLeafId)
                currentLeafId = currentLeafId + 1
                if currentLeafId > 100000 then currentLeafId = 1 end
            end)
        end
        task.wait(collectInterval)
    end
end)

-- ==================== 自动售卖 ====================
spawn(function()
    while true do
        if autoSell then
            pcall(function()
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then
                    task.wait(0.5)
                    return
                end
                local hrp = char.HumanoidRootPart
                local startPos = hrp.Position

                hrp.CFrame = CFrame.new(55.5, 65.4, -50.3)
                task.wait(0.5)

                local Event = game:GetService("ReplicatedStorage").Remotes.EmptyBackpack
                Event:FireServer()
                task.wait(0.5)

                hrp.CFrame = CFrame.new(startPos)
            end)
        end
        task.wait(sellInterval)
    end
end)

-- ==================== 自动升级 ====================
spawn(function()
    while true do
        if autoDexterity then
            pcall(function()
                local Event = game:GetService("ReplicatedStorage").Remotes.BuyUpgrade
                Event:FireServer("Hand", "Dexterity")
            end)
        end
        task.wait(upgradeInterval)
    end
end)

spawn(function()
    while true do
        if autoHold then
            pcall(function()
                local Event = game:GetService("ReplicatedStorage").Remotes.BuyUpgrade
                Event:FireServer("Hand", "Hold")
            end)
        end
        task.wait(upgradeInterval)
    end
end)

spawn(function()
    while true do
        if autoGrasp then
            pcall(function()
                local Event = game:GetService("ReplicatedStorage").Remotes.BuyUpgrade
                Event:FireServer("Hand", "Grasp")
            end)
        end
        task.wait(upgradeInterval)
    end
end)

-- ==================== UI ====================
local Window = WI:CreateWindow({
    Title = "清理所有树叶",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(400, 350),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--清理所有树叶",
    Desc = "自动清理 | 自动售卖 | 自动升级 | 速度"
})

local T2 = Window:Tab({Title = "主要功能", Icon = "solar:star-bold"})
T2:Toggle({Title = "自动清理树叶", Value = false, Callback = function(v) autoCollect = v; if v then currentLeafId = 1 end end})
T2:Slider({Title = "清理间隔(秒)", Value = {Min = 0.01, Max = 1, Default = 0.05}, Step = 0.01, Callback = function(v) collectInterval = v end})
T2:Divider()
T2:Toggle({Title = "自动售卖", Value = false, Callback = function(v) autoSell = v end})
T2:Slider({Title = "售卖延迟(秒)", Value = {Min = 1, Max = 30, Default = 5}, Step = 1, Callback = function(v) sellInterval = v end})
T2:Divider()
T2:Toggle({Title = "自动升级敏捷", Value = false, Callback = function(v) autoDexterity = v end})
T2:Toggle({Title = "自动升最大值", Value = false, Callback = function(v) autoHold = v end})
T2:Toggle({Title = "自动升级抓握", Value = false, Callback = function(v) autoGrasp = v end})
T2:Slider({Title = "升级间隔(秒)", Value = {Min = 0.5, Max = 10, Default = 1}, Step = 0.5, Callback = function(v) upgradeInterval = v end})

local T3 = Window:Tab({Title = "玩家", Icon = "solar:user-bold"})
T3:Toggle({Title = "速度加成", Value = false, Callback = function(v) speedBoost = v end})
T3:Slider({Title = "速度值", Value = {Min = 16, Max = 200, Default = 50}, Callback = function(v) speedValue = v end})

local T4 = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})
local statusParagraph = T4:Paragraph({Title = "功能状态", Desc = "加载中..."})

spawn(function()
    while true do
        pcall(function()
            local fps = math.floor(1 / (RunService.RenderStepped:Wait() or 0.016))
            local status = "FPS: " .. fps .. "\n\n" ..
                "清理树叶: " .. (autoCollect and "✅" or "❌") .. "\n" ..
                "当前ID: " .. currentLeafId .. "\n" ..
                "售卖: " .. (autoSell and "✅" or "❌") .. "\n" ..
                "敏捷: " .. (autoDexterity and "✅" or "❌") .. "\n" ..
                "最大值: " .. (autoHold and "✅" or "❌") .. "\n" ..
                "抓握: " .. (autoGrasp and "✅" or "❌") .. "\n" ..
                "速度: " .. (speedBoost and "✅ " .. speedValue or "❌")
            statusParagraph:SetDesc(status)
        end)
        task.wait(0.5)
    end
end)

T4:Button({Title = "关闭面板", Justify = "Center", Callback = function() Window:Close() end})

WI:Notify({Title = "🌙 清理所有树叶", Content = "加载完成", Duration = 3})
print("🌙 清理所有树叶 加载完成")
