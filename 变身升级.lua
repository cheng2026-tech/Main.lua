-- 变身升级 脚本 v1.0.5
-- WindUI蓝白版 | 自动吃食 | 跳跃冲刺 | 移速调整

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
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local VERSION = "v1.0.5"
local autoEat = false
local jumpBoost = false
local speedEnabled = false
local speedValue = 16
local isMoving = false
local lastJumpTime = 0

local function getNearestFood()
    local char = LocalPlayer.Character
    if not char then return nil end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local myPos = hrp.Position
    local nearest = nil
    local nearestDist = math.huge
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local name = obj.Name:lower()
            if name:find("food") then
                local rootPart = nil
                if obj:IsA("Model") then
                    rootPart = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                elseif obj:IsA("BasePart") then
                    rootPart = obj
                end
                if rootPart then
                    local dist = (myPos - rootPart.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearest = rootPart
                    end
                end
            end
        end
    end
    
    return nearest
end

task.spawn(function()
    while true do
        if speedEnabled then
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = speedValue
                end
            end
        end
        task.wait(0.3)
    end
end)

local function moveToFood(targetPos)
    if isMoving then return end
    isMoving = true
    
    local char = LocalPlayer.Character
    if not char then
        isMoving = false
        return
    end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        isMoving = false
        return
    end
    
    local startPos = hrp.Position
    local totalDist = (targetPos - startPos).Magnitude
    
    if totalDist < 3 then
        isMoving = false
        return
    end
    
    local stepSize = 5
    local steps = math.max(1, math.floor(totalDist / stepSize))
    local direction = (targetPos - startPos).Unit
    
    for i = 1, steps do
        if not autoEat then break end
        local newPos = startPos + direction * (stepSize * i)
        hrp.CFrame = CFrame.new(newPos)
        task.wait(0.08)
    end
    
    hrp.CFrame = CFrame.new(targetPos)
    isMoving = false
end

task.spawn(function()
    while true do
        if autoEat then
            local food = getNearestFood()
            if food then
                moveToFood(food.Position + Vector3.new(0, 2, 0))
            end
            task.wait(1.5)
        else
            task.wait(0.5)
        end
    end
end)

-- 跳跃冲刺 50速 0.1秒
local function doJumpDash()
    if not jumpBoost then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local forward = hrp.CFrame.LookVector
    local targetPos = hrp.Position + forward * 5
    
    local tweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local tween = tweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})
    tween:Play()
end

UserInputService.JumpRequest:Connect(function()
    if jumpBoost then
        task.spawn(function()
            task.wait(0.05)
            doJumpDash()
        end)
    end
end)

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    if humanoid:GetState() == Enum.HumanoidStateType.Jumping then
        if jumpBoost and tick() - lastJumpTime > 0.5 then
            lastJumpTime = tick()
            task.spawn(function()
                task.wait(0.05)
                doJumpDash()
            end)
        end
    end
end)

local Window = WindUI:CreateWindow({
    Title = "变身升级",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(600, 350),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true,
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--变身升级 v1.0.5",
    Desc = "功能：自动吃食 | 跳跃冲刺(50速/0.1秒) | 移速调整"
})

local MainTab = Window:Tab({Title = "主要功能", Icon = "solar:star-bold"})

MainTab:Toggle({
    Title = "自动吃食",
    Value = false,
    Callback = function(v)
        autoEat = v
        if not v then isMoving = false end
    end
})

MainTab:Divider()

MainTab:Toggle({
    Title = "跳跃冲刺",
    Value = false,
    Callback = function(v)
        jumpBoost = v
    end
})

MainTab:Divider()

MainTab:Toggle({
    Title = "调整移速",
    Value = false,
    Callback = function(v)
        speedEnabled = v
    end
})

MainTab:Slider({
    Title = "移速值 (16-30)",
    Value = {Min = 16, Max = 30, Default = 16},
    Step = 1,
    Callback = function(v)
        speedValue = v
    end
})

local SettingsTab = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})
local statusPara = SettingsTab:Paragraph({Title = "功能状态", Desc = "加载中..."})

task.spawn(function()
    while true do
        local status = ""
        status = status .. "自动吃食: " .. (autoEat and "已开启" or "未开启") .. "\n"
        status = status .. "跳跃冲刺: " .. (jumpBoost and "已开启" or "未开启") .. "\n"
        status = status .. "调整移速: " .. (speedEnabled and "已开启 (" .. speedValue .. ")" or "未开启") .. "\n"
        local food = getNearestFood()
        status = status .. "最近食物: " .. (food and "已找到" or "未找到") .. "\n"
        status = status .. "帧率: " .. math.floor(1 / task.wait()) .. " FPS"
        statusPara:SetDesc(status)
        task.wait(1)
    end
end)

SettingsTab:Button({
    Title = "关闭面板",
    Callback = function()
        Window:Close()
    end
})

Window:OnClose(function()
    autoEat = false
    jumpBoost = false
    isMoving = false
end)

WindUI:Notify({
    Title = "变身升级",
    Content = "v1.0.5 加载完成",
    Duration = 3
})
