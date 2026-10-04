-- 🌙 把足球踢进太空 | V1.0

local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

-- 变量
local autoClick = false
local clickInterval = 0.01
local autoKick = false

-- ==================== 冰白主题 ====================
WI:AddTheme({
    Name = "冰白",
    Accent = "#80C0FF",
    Outline = "#6090C0",
    Text = "#FFFFFF",
    Placeholder = "#D0E0FF"
})

-- ==================== 自动点击 ====================
spawn(function()
    while true do
        if autoClick then
            pcall(function()
                local Event = game:GetService("ReplicatedStorage").MookNet.Reliable
                Event:FireServer(
                    (function(bytes)
                        local b = buffer.create(#bytes)
                        for i = 1, #bytes do
                            buffer.writeu8(b, i - 1, bytes[i])
                        end
                        return b
                    end)({232, 121, 199, 65, 0}),
                    {}
                )
            end)
        end
        task.wait(clickInterval)
    end
end)

-- ==================== Auto Kick ====================
spawn(function()
    while true do
        if autoKick then
            pcall(function()
                local Event = game:GetService("ReplicatedStorage").MookNet.Reliable
                Event:FireServer(
                    (function(bytes)
                        local b = buffer.create(#bytes)
                        for i = 1, #bytes do
                            buffer.writeu8(b, i - 1, bytes[i])
                        end
                        return b
                    end)({211, 220, 250, 115, 0}),
                    {}
                )
            end)
        end
        task.wait(0.1)
    end
end)

-- ==================== UI ====================
local Window = WI:CreateWindow({
    Title = "把足球踢进太空",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(500, 280),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--把足球踢进太空",
    Desc = "自动点击 | Auto Kick"
})

local T2 = Window:Tab({Title = "主要功能", Icon = "solar:star-bold"})
T2:Section({Title = "自动点击"})
T2:Toggle({Title = "开启自动点击", Value = false, Callback = function(v) autoClick = v end})
T2:Slider({Title = "点击间隔(秒)", Value = {Min = 0.01, Max = 1, Default = 0.01}, Step = 0.01, Callback = function(v) clickInterval = v end})

T2:Section({Title = "Auto Kick"})
T2:Toggle({Title = "开启Auto Kick", Value = false, Callback = function(v) autoKick = v end})

local T3 = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})
local statusParagraph = T3:Paragraph({Title = "功能状态", Desc = "加载中..."})

spawn(function()
    while true do
        pcall(function()
            local fps = math.floor(1 / (game:GetService("RunService").RenderStepped:Wait() or 0.016))
            local status = "FPS: " .. fps .. "\n\n" ..
                "自动点击: " .. (autoClick and "✅" or "❌") .. "\n" ..
                "Auto Kick: " .. (autoKick and "✅" or "❌")
            statusParagraph:SetDesc(status)
        end)
        task.wait(0.5)
    end
end)

T3:Button({Title = "关闭面板", Justify = "Center", Callback = function() Window:Close() end})

WI:Notify({Title = "🌙 把足球踢进太空", Content = "加载完成", Duration = 3})
print("🌙 把足球踢进太空 加载完成")
