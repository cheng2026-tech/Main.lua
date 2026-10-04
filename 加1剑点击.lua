-- 🌙 加1剑点击 | V1.3

local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- 变量
local autoClick = false
local clickInterval = 0.01

local customRebirth = false
local rebirthAmount = 1
local rebirthInterval = 1

-- ==================== 自动点击 ====================
RunService.RenderStepped:Connect(function()
    if autoClick then
        pcall(function()
            local Event = game:GetService("ReplicatedStorage").ClickTrainEvent
            Event:FireServer(nil, 1165.9183349609, 680.84356689453)
        end)
    end
end)

-- ==================== 美化加力量值 ====================
spawn(function()
    while true do
        if customRebirth then
            pcall(function()
                local Event = game:GetService("ReplicatedStorage").ClickStrengthGained
                firesignal(Event.OnClientEvent, rebirthAmount, false, 1227.5510253906, 548.93878173828)
            end)
        end
        task.wait(rebirthInterval)
    end
end)

-- ==================== 删除墙壁 ====================
local function deleteWalls()
    local count = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        pcall(function()
            if obj.Name:find("Wall_") then
                obj:Destroy()
                count = count + 1
            end
        end)
    end
    WI:Notify({Title = "删除完成", Content = "已删除" .. count .. "个墙壁", Duration = 2})
end

-- ==================== UI ====================
WI:AddTheme({
    Name = "冰白",
    Accent = "#80C0FF",
    Outline = "#6090C0",
    Text = "#FFFFFF",
    Placeholder = "#D0E0FF"
})

local Window = WI:CreateWindow({
    Title = "加1剑点击",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(500, 320),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--加1剑点击 V1.3",
    Desc = "自动点击 | 美化加力量 | 删除墙壁"
})

local T2 = Window:Tab({Title = "主要功能", Icon = "solar:star-bold"})
T2:Section({Title = "自动点击"})
T2:Toggle({Title = "开启自动点击", Value = false, Callback = function(v) autoClick = v end})
T2:Slider({Title = "点击间隔", Value = {Min = 0.01, Max = 1, Default = 0.01}, Step = 0.01, Callback = function(v) clickInterval = v end})

T2:Section({Title = "美化加力量值"})
T2:Toggle({Title = "开启美化加力量", Value = false, Callback = function(v) customRebirth = v end})
T2:Input({Title = "输入数值", Value = "1", Placeholder = "输入数字...", Callback = function(v)
    local num = tonumber(v)
    if num then rebirthAmount = num end
end})
T2:Slider({Title = "执行间隔", Value = {Min = 0.5, Max = 10, Default = 1}, Step = 0.5, Callback = function(v) rebirthInterval = v end})

T2:Section({Title = "删除墙壁"})
T2:Button({Title = "删除所有墙壁", Justify = "Center", Callback = function() deleteWalls() end})

Window:Tab({Title = "设置", Icon = "solar:settings-bold"}):Button({
    Title = "关闭面板",
    Justify = "Center",
    Callback = function() Window:Close() end
})

WI:Notify({Title = "🌙 加1剑点击", Content = "V1.3 加载完成", Duration = 3})
print("🌙 加1剑点击 V1.3 加载完成")
