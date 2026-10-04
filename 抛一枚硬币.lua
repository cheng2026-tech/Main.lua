-- 抛一枚硬币 | V1.7

local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

-- ==================== 变量 ====================
local autoCoin = false
local autoSell = false
local fullAuto = false
local autoLuck = false
local autoValue = false
local autoThread = nil
local sellThread = nil
local luckThread = nil
local valueThread = nil

local speedValue = 16
local speedEnabled = false
local jumpValue = 50
local jumpEnabled = false
local infiniteJumpEnabled = false
local espEnabled = false
local espHighlights = {}

-- ==================== 获取事件 ====================
local function GetCoinEvent()
    local assets = ReplicatedStorage:FindFirstChild("Assets")
    if not assets then return nil end
    local events = assets:FindFirstChild("Events")
    if not events then return nil end
    return events:FindFirstChild("CoinLanded")
end

local function GetSellEvent()
    local assets = ReplicatedStorage:FindFirstChild("Assets")
    if not assets then return nil end
    local events = assets:FindFirstChild("Events")
    if not events then return nil end
    return events:FindFirstChild("SellAll")
end

local function GetUpgradeEvent()
    local assets = ReplicatedStorage:FindFirstChild("Assets")
    if not assets then return nil end
    local events = assets:FindFirstChild("Events")
    if not events then return nil end
    return events:FindFirstChild("RequestUpgrade")
end

-- ==================== 执行函数 ====================
function DoCoin()
    local Event = GetCoinEvent()
    if Event then
        Event:FireServer(3, Vector3.new(-1155.8050537109, 0.72600001096725, -175.0212097168), "Basic Coin", nil, nil)
        return true
    end
    return false
end

function DoSell()
    local Event = GetSellEvent()
    if Event then
        Event:FireServer()
        print("售卖")
        return true
    end
    return false
end

function DoLuck()
    local Event = GetUpgradeEvent()
    if Event then
        Event:FireServer("Luck Multiplier")
        print("升级运气")
        return true
    end
    return false
end

function DoValue()
    local Event = GetUpgradeEvent()
    if Event then
        Event:FireServer("Value Multiplier")
        print("升级价值倍率")
        return true
    end
    return false
end

-- ==================== 全自动模式 ====================
function StartFullAuto()
    if autoThread then task.cancel(autoThread); autoThread = nil end
    if sellThread then task.cancel(sellThread); sellThread = nil end
    autoThread = task.spawn(function()
        while fullAuto do
            pcall(DoCoin)
            task.wait()
        end
    end)
    sellThread = task.spawn(function()
        while fullAuto do
            task.wait(5)
            pcall(DoSell)
        end
    end)
end

-- ==================== ESP ====================
function clearESP()
    for _, obj in pairs(espHighlights) do
        pcall(function() obj:Destroy() end)
    end
    espHighlights = {}
end

function updateESP()
    clearESP()
    if not espEnabled then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hl = Instance.new("Highlight")
            hl.FillColor = Color3.fromRGB(0, 150, 255)
            hl.FillTransparency = 0.3
            hl.OutlineColor = Color3.new(1, 1, 1)
            hl.Adornee = p.Character
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = p.Character
            table.insert(espHighlights, hl)
        end
    end
end

task.spawn(function()
    while true do
        if espEnabled then
            updateESP()
        else
            clearESP()
        end
        task.wait(0.5)
    end
end)

-- ==================== Wind UI ====================
local MainWindow = WI:CreateWindow({
    Title = "抛一枚硬币",
    Icon = "solar:coin-bold",
    Size = UDim2.fromOffset(480, 520),
    ToggleKey = Enum.KeyCode.RightShift,
    Acrylic = true,
    ScrollBarEnabled = true
})

-- ==================== 公告 ====================
local T1 = MainWindow:Tab({Title = "公告", Icon = "solar:info-bold"})

T1:Paragraph({
    Title = "黑脚本--抛一枚硬币",
    Desc = "版本 V1.7\n\n功能列表：\n- 自动抛硬币（Toggle）\n- 手动售卖（点击按钮）\n- 全自动模式（疯狂抛硬币+每5秒售卖）\n- 自动升级运气（每10秒）\n- 自动升级价值倍率（每10秒）\n- 速度调节\n- 跳跃高度\n- 无限跳跃\n- 玩家透视"
})

T1:Button({
    Title = "关闭面板",
    Justify = "Center",
    Color = Color3.fromHex("#888888"),
    Callback = function()
        MainWindow:Close()
    end
})

-- ==================== 主要功能 ====================
local T2 = MainWindow:Tab({Title = "主要功能", Icon = "solar:settings-bold"})

T2:Paragraph({
    Title = "主要功能",
    Desc = "点击按钮或Toggle控制功能"
})

T2:Divider()

T2:Toggle({
    Title = "自动抛硬币",
    Value = false,
    Callback = function(v)
        autoCoin = v
        if autoCoin then
            if autoThread then task.cancel(autoThread); autoThread = nil end
            autoThread = task.spawn(function()
                while autoCoin do
                    pcall(DoCoin)
                    task.wait()
                end
            end)
            print("自动抛硬币已开启（无冷却）")
            WI:Notify({
                Title = "已开启",
                Content = "自动抛硬币已开启（无冷却）",
                Duration = 2,
                Type = "success"
            })
        else
            if autoThread then task.cancel(autoThread); autoThread = nil end
            print("自动抛硬币已关闭")
            WI:Notify({
                Title = "已关闭",
                Content = "自动抛硬币已关闭",
                Duration = 2,
                Type = "warning"
            })
        end
    end
})

T2:Button({
    Title = "手动售卖",
    Justify = "Center",
    Color = Color3.fromRGB(255, 200, 50),
    Callback = function()
        if DoSell() then
            WI:Notify({
                Title = "售卖成功",
                Content = "已执行售卖",
                Duration = 2,
                Type = "success"
            })
        else
            WI:Notify({
                Title = "售卖失败",
                Content = "未找到售卖事件",
                Duration = 2,
                Type = "error"
            })
        end
    end
})

T2:Divider()

T2:Toggle({
    Title = "全自动模式",
    Value = false,
    Callback = function(v)
        fullAuto = v
        if fullAuto then
            autoCoin = false
            StartFullAuto()
            print("全自动模式已开启（疯狂抛硬币+每5秒售卖）")
            WI:Notify({
                Title = "已开启",
                Content = "全自动模式已开启（疯狂抛硬币+每5秒售卖）",
                Duration = 2,
                Type = "success"
            })
        else
            if autoThread then task.cancel(autoThread); autoThread = nil end
            if sellThread then task.cancel(sellThread); sellThread = nil end
            print("全自动模式已关闭")
            WI:Notify({
                Title = "已关闭",
                Content = "全自动模式已关闭",
                Duration = 2,
                Type = "warning"
            })
        end
    end
})

T2:Divider()

T2:Toggle({
    Title = "自动升级运气",
    Value = false,
    Callback = function(v)
        autoLuck = v
        if autoLuck then
            if luckThread then task.cancel(luckThread); luckThread = nil end
            luckThread = task.spawn(function()
                while autoLuck do
                    pcall(DoLuck)
                    task.wait(10)
                end
            end)
            print("自动升级运气已开启（每10秒）")
            WI:Notify({
                Title = "已开启",
                Content = "自动升级运气已开启（每10秒）",
                Duration = 2,
                Type = "success"
            })
        else
            if luckThread then task.cancel(luckThread); luckThread = nil end
            print("自动升级运气已关闭")
            WI:Notify({
                Title = "已关闭",
                Content = "自动升级运气已关闭",
                Duration = 2,
                Type = "warning"
            })
        end
    end
})

T2:Toggle({
    Title = "自动升级价值倍率",
    Value = false,
    Callback = function(v)
        autoValue = v
        if autoValue then
            if valueThread then task.cancel(valueThread); valueThread = nil end
            valueThread = task.spawn(function()
                while autoValue do
                    pcall(DoValue)
                    task.wait(10)
                end
            end)
            print("自动升级价值倍率已开启（每10秒）")
            WI:Notify({
                Title = "已开启",
                Content = "自动升级价值倍率已开启（每10秒）",
                Duration = 2,
                Type = "success"
            })
        else
            if valueThread then task.cancel(valueThread); valueThread = nil end
            print("自动升级价值倍率已关闭")
            WI:Notify({
                Title = "已关闭",
                Content = "自动升级价值倍率已关闭",
                Duration = 2,
                Type = "warning"
            })
        end
    end
})

-- ==================== 玩家 ====================
local T3 = MainWindow:Tab({Title = "玩家", Icon = "solar:user-bold"})

T3:Paragraph({
    Title = "玩家设置",
    Desc = "调节玩家属性"
})

T3:Divider()

T3:Toggle({
    Title = "开启速度调节",
    Value = false,
    Callback = function(v)
        speedEnabled = v
        if not v then
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then
                c.Humanoid.WalkSpeed = 16
            end
        end
    end
})

T3:Input({
    Title = "速度数值",
    Description = "输入1-200",
    Value = "16",
    Callback = function(v)
        local num = tonumber(v)
        if num and num > 0 and num <= 200 then
            speedValue = num
            if speedEnabled then
                local c = LocalPlayer.Character
                if c and c:FindFirstChild("Humanoid") then
                    c.Humanoid.WalkSpeed = speedValue
                end
            end
        end
    end
})

T3:Button({
    Title = "推荐（20速度）",
    Justify = "Center",
    Color = Color3.fromRGB(255, 200, 50),
    Callback = function()
        speedValue = 20
        if speedEnabled then
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then
                c.Humanoid.WalkSpeed = 20
            end
        end
    end
})

T3:Divider()

T3:Toggle({
    Title = "开启跳跃高度",
    Value = false,
    Callback = function(v)
        jumpEnabled = v
        if not v then
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then
                c.Humanoid.JumpPower = 50
            end
        end
    end
})

T3:Input({
    Title = "跳跃数值",
    Description = "输入1-500",
    Value = "50",
    Callback = function(v)
        local num = tonumber(v)
        if num and num > 0 and num <= 500 then
            jumpValue = num
            if jumpEnabled then
                local c = LocalPlayer.Character
                if c and c:FindFirstChild("Humanoid") then
                    c.Humanoid.JumpPower = jumpValue
                end
            end
        end
    end
})

T3:Button({
    Title = "推荐（80跳跃）",
    Justify = "Center",
    Color = Color3.fromRGB(255, 200, 50),
    Callback = function()
        jumpValue = 80
        if jumpEnabled then
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then
                c.Humanoid.JumpPower = 80
            end
        end
    end
})

T3:Divider()

T3:Toggle({
    Title = "无限跳跃",
    Value = false,
    Callback = function(v)
        infiniteJumpEnabled = v
    end
})

T3:Divider()

T3:Toggle({
    Title = "透视玩家",
    Value = false,
    Callback = function(v)
        espEnabled = v
        if not v then
            clearESP()
        end
    end
})

-- ==================== 速度/跳跃循环 ====================
task.spawn(function()
    while true do
        if speedEnabled then
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then
                c.Humanoid.WalkSpeed = speedValue
            end
        end
        if jumpEnabled then
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then
                c.Humanoid.JumpPower = jumpValue
            end
        end
        task.wait(0.1)
    end
end)

UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        local c = LocalPlayer.Character
        if c and c:FindFirstChild("Humanoid") then
            c.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ==================== 启动弹窗 ====================
WI:Popup({
    Title = "抛一枚硬币",
    Content = "加载完成\n按 RightShift 开关面板\n\n版本 V1.7\n\n新增玩家标签页",
    Buttons = {{
        Title = "确定",
        Variant = "Primary",
        Callback = function() end
    }}
})

print("抛一枚硬币 V1.7 加载完成")
