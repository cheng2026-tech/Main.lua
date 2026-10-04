-- 重型钓鱼脚本 | V1.0

local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ==================== 变量 ====================
local autoFish = false
local autoSell = false
local isFishing = false

-- ==================== 钓鱼坐标 ====================
local FISH_POSITION = Vector3.new(-309.4, 9.8, -27.7)
local CAST_CFRAME = CFrame.new(-308.75762939453, 9.7615242004395, -29.612356185913, 0.026869159191847, 0, 0.9996389746666, 0, 1, 0, -0.9996389746666, 0, 0.026869159191847)

-- ==================== 工具函数：角色移动 ====================
function WalkToPosition(targetPos)
    local character = LocalPlayer.Character
    if not character then return false end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return false end
    
    local tween = TweenService:Create(hrp, TweenInfo.new(3, Enum.EasingStyle.Linear), {
        Position = targetPos
    })
    tween:Play()
    tween.Completed:Wait()
    
    return true
end

-- ==================== 投竿 ====================
function CastRod()
    local Event = ReplicatedStorage:FindFirstChild("Events")
    if Event then
        Event = Event:FindFirstChild("Fishing")
        if Event then
            Event:FireServer(CAST_CFRAME)
            print("🎣 投竿")
            return true
        end
    end
    return false
end

-- ==================== 售卖 ====================
function SellFish()
    local Event = ReplicatedStorage:FindFirstChild("Events")
    if Event then
        Event = Event:FindFirstChild("SellFish")
        if Event then
            Event:FireServer("All")
            print("💰 已售卖所有鱼")
            
            -- 右上角弹窗通知
            WI:Notify({
                Title = "💰 售卖成功",
                Content = "已售卖所有鱼！",
                Duration = 3,
                Type = "success"
            })
            return true
        end
    end
    return false
end

-- ==================== 点击左键 ====================
function ClickLeft()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game:GetService("UserInputService").MouseIcon, 1)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game:GetService("UserInputService").MouseIcon, 1)
end

-- ==================== 钓鱼循环 ====================
function StartFishing()
    if isFishing then return end
    isFishing = true
    
    print("🎣 开始钓鱼流程...")
    
    -- 1. 走到钓鱼位置
    print("🚶 走向钓鱼点...")
    local success = WalkToPosition(FISH_POSITION)
    if not success then
        print("❌ 移动失败")
        isFishing = false
        return
    end
    print("✅ 到达钓鱼点")
    
    task.wait(0.5)
    
    -- 2. 投竿
    print("🎣 投竿...")
    CastRod()
    
    -- 3. 等待4秒
    print("⏳ 等待鱼上钩...")
    task.wait(4)
    
    -- 4. 循环点击左键（每0.2秒一次）
    print("🖱️ 开始收线...")
    local clickCount = 0
    while autoFish and isFishing do
        ClickLeft()
        clickCount = clickCount + 1
        if clickCount % 10 == 0 then
            print("🔄 已点击 " .. clickCount .. " 次")
        end
        task.wait(0.2)
    end
    
    print("⏹️ 钓鱼停止")
    isFishing = false
end

-- ==================== 主窗口 ====================
local MainWindow = WI:CreateWindow({
    Title = "重型钓鱼脚本",
    Icon = "solar:fishing-bold",
    Size = UDim2.fromOffset(480, 400),
    ToggleKey = Enum.KeyCode.RightShift,
    Acrylic = true,
    ScrollBarEnabled = true
})

-- ==================== 公告标签页 ====================
local T1 = MainWindow:Tab({Title = "公告", Icon = "solar:info-bold"})

T1:Paragraph({
    Title = "🎣 重型钓鱼脚本",
    Desc = "版本 V1.0\n\n功能列表：\n- 自动钓鱼\n- 自动售卖\n\n使用说明：\n1. 进入游戏\n2. 打开自动化标签页\n3. 开启对应功能"
})

T1:Button({
    Title = "关闭面板",
    Justify = "Center",
    Color = Color3.fromHex("#888888"),
    Callback = function()
        MainWindow:Close()
    end
})

-- ==================== 自动化标签页 ====================
local T2 = MainWindow:Tab({Title = "自动化", Icon = "solar:settings-bold"})

T2:Paragraph({
    Title = "⚙️ 自动化设置",
    Desc = "开启后自动执行对应操作"
})

T2:Divider()

T2:Toggle({
    Title = "🎣 自动钓鱼  [BETA 0.01]",
    Value = false,
    Callback = function(v)
        autoFish = v
        print("自动钓鱼: " .. (v and "开启" or "关闭"))
        if v then
            task.spawn(function()
                while autoFish do
                    StartFishing()
                    if autoFish then
                        print("🔄 等待5秒后重新钓鱼...")
                        task.wait(5)
                    end
                end
            end)
        else
            isFishing = false
        end
    end
})

T2:Toggle({
    Title = "💰 自动售卖",
    Value = false,
    Callback = function(v)
        autoSell = v
        print("自动售卖: " .. (v and "开启" or "关闭"))
        if v then
            task.spawn(function()
                while autoSell do
                    SellFish()
                    task.wait(10)
                end
            end)
        end
    end
})

-- ==================== 启动弹窗 ====================
WI:Popup({
    Title = "重型钓鱼脚本",
    Content = "加载完成\n按 RightShift 开关面板",
    Buttons = {{
        Title = "确定",
        Variant = "Primary",
        Callback = function() end
    }}
})

print("✅ 重型钓鱼脚本加载完成")
print("🟢 打开自动化标签页开启自动钓鱼")
