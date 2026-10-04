local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

-- 服务
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 配置（默认关闭）
local Settings = {
    AutoFarm_Enabled = false,
    AutoBoost_Enabled = false,
    FarmDelay = 0.5,
    BoostDelay = 1,
}

-- 循环线程
local FarmLoop = nil
local BoostLoop = nil

-- 自动刷钱循环
local function StartAutoFarm()
    if FarmLoop then return end
    FarmLoop = RunService.Heartbeat:Connect(function()
        if not Settings.AutoFarm_Enabled then
            if FarmLoop then FarmLoop:Disconnect() FarmLoop = nil end
            return
        end
        pcall(function()
            local Event = ReplicatedStorage.Events.CashEvent
            Event:FireServer(1999)
        end)
        task.wait(Settings.FarmDelay)
    end)
end

-- 无限加成循环
local function StartAutoBoost()
    if BoostLoop then return end
    BoostLoop = RunService.Heartbeat:Connect(function()
        if not Settings.AutoBoost_Enabled then
            if BoostLoop then BoostLoop:Disconnect() BoostLoop = nil end
            return
        end
        pcall(function()
            local Event = ReplicatedStorage.Events.ApplyBoost
            Event:FireServer(100)
        end)
        task.wait(Settings.BoostDelay)
    end)
end

-- 创建窗口
local Win = WI:CreateWindow({
    Title = "画一个滑雪板",
    Icon = "solar:skateboarding-bold",
    Size = UDim2.fromOffset(420, 480),
    ToggleKey = Enum.KeyCode.RightShift,
    Acrylic = true,
    ScrollBarEnabled = true,
})

-- 公告标签页
local TabAnnounce = Win:Tab({
    Title = "公告",
    Icon = "solar:notification-bold"
})

TabAnnounce:Paragraph({
    Title = "功能说明--黑脚本",
    Desc = [[
    主要功能：
    
    自动刷钱 - 循环获取游戏货币
    无限加成 - 持续应用加速效果
    
    使用提示：
    按RightShift开关菜单
    开启后自动循环执行
    
    注意：
    合理使用，避免刷太快被检测
    建议配合游戏正常游玩使用
    ]]
})

-- 自动标签页
local TabAuto = Win:Tab({
    Title = "自动",
    Icon = "solar:play-bold"
})

TabAuto:Toggle({
    Title = "自动刷钱",
    Value = Settings.AutoFarm_Enabled,
    Callback = function(v)
        Settings.AutoFarm_Enabled = v
        if v then
            StartAutoFarm()
            WI:Notify({
                Title = "提示",
                Content = "自动刷钱已开启",
                Duration = 2
            })
        else
            if FarmLoop then 
                FarmLoop:Disconnect() 
                FarmLoop = nil 
            end
            WI:Notify({
                Title = "提示",
                Content = "自动刷钱已关闭",
                Duration = 2
            })
        end
    end
})

TabAuto:Divider()

TabAuto:Input({
    Title = "刷钱延迟(秒)",
    Value = tostring(Settings.FarmDelay),
    Callback = function(v)
        local num = tonumber(v)
        if num and num >= 0.1 then
            Settings.FarmDelay = num
        end
    end
})

TabAuto:Divider()

TabAuto:Toggle({
    Title = "无限加成",
    Value = Settings.AutoBoost_Enabled,
    Callback = function(v)
        Settings.AutoBoost_Enabled = v
        if v then
            StartAutoBoost()
            WI:Notify({
                Title = "提示",
                Content = "无限加成已开启",
                Duration = 2
            })
        else
            if BoostLoop then 
                BoostLoop:Disconnect() 
                BoostLoop = nil 
            end
            WI:Notify({
                Title = "提示",
                Content = "无限加成已关闭",
                Duration = 2
            })
        end
    end
})

TabAuto:Divider()

TabAuto:Input({
    Title = "加成延迟(秒)",
    Value = tostring(Settings.BoostDelay),
    Callback = function(v)
        local num = tonumber(v)
        if num and num >= 0.1 then
            Settings.BoostDelay = num
        end
    end
})

-- 设置标签页
local TabSettings = Win:Tab({
    Title = "设置",
    Icon = "solar:settings-bold"
})

TabSettings:Toggle({
    Title = "毛玻璃效果",
    Value = true,
    Callback = function(v)
        WI:Notify({
            Title = "提示",
            Content = "更改将在下次打开窗口时生效",
            Duration = 2
        })
    end
})

TabSettings:Divider()

TabSettings:Button({
    Title = "关闭脚本",
    Justify = "Center",
    Color = Color3.fromHex("#ff4444"),
    Callback = function()
        if FarmLoop then FarmLoop:Disconnect() FarmLoop = nil end
        if BoostLoop then BoostLoop:Disconnect() BoostLoop = nil end
        Win:Close()
    end
})

-- 启动通知
WI:Notify({
    Title = "画一个滑雪板",
    Content = "脚本加载完成！\n按RightShift打开菜单",
    Duration = 5
})

print("画一个滑雪板 脚本已加载")
print("按RightShift开关窗口")
