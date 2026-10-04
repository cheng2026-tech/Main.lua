-- 🌙 加1翅膀偷脑残 | V1.9

local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- 变量
local speedBoost = false
local speedValue = 50
local selectedRare = ""
local selectedMutation = ""
local autoTimeReward = false
local autoRebirth = false
local autoStamina = false
local autoCarry = false
local autoSpeedUp = false
local autoMaxSpeed = false
local unifiedInterval = 3

-- ==================== 冰白主题 ====================
WI:AddTheme({
    Name = "冰白",
    Accent = "#80C0FF",
    Outline = "#6090C0",
    Text = "#FFFFFF",
    Placeholder = "#D0E0FF"
})

-- ==================== 辅助函数 ====================
local function getRoot(obj)
    if obj:IsA("Model") then
        return obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head") or obj:FindFirstChild("Handle")
    elseif obj:IsA("BasePart") then
        return obj
    end
    for _, c in ipairs(obj:GetDescendants()) do
        if c:IsA("BasePart") then return c end
    end
    return nil
end

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

-- ==================== 自动领时间奖励 ====================
spawn(function()
    local rewardNum = 1
    while true do
        if autoTimeReward then
            pcall(function()
                local Event = game:GetService("ReplicatedStorage").Remotes.TimeRewards.TimeRewardClaimed
                Event:FireServer(rewardNum)
                rewardNum = rewardNum + 1
                if rewardNum > 12 then rewardNum = 1 end
            end)
            task.wait(1)
        else
            task.wait(0.5)
        end
    end
end)

-- ==================== 自动重生 ====================
spawn(function()
    while true do
        if autoRebirth then
            pcall(function()
                local Event = game:GetService("ReplicatedStorage").Events.RequestRebirth
                Event:FireServer()
            end)
            task.wait(unifiedInterval)
        else
            task.wait(0.5)
        end
    end
end)

-- ==================== 自动升耐力 ====================
spawn(function()
    while true do
        if autoStamina then
            pcall(function()
                local Event = game:GetService("ReplicatedStorage").Remotes.UpgradeRequested
                Event:FireServer("Stamina", 1)
            end)
            task.wait(unifiedInterval)
        else
            task.wait(0.5)
        end
    end
end)

-- ==================== 自动升级携带 ====================
spawn(function()
    while true do
        if autoCarry then
            pcall(function()
                local Event = game:GetService("ReplicatedStorage").Remotes.UpgradeRequested
                Event:FireServer("Carry", 1)
            end)
            task.wait(unifiedInterval)
        else
            task.wait(0.5)
        end
    end
end)

-- ==================== 自动升级速度 ====================
spawn(function()
    while true do
        if autoSpeedUp then
            pcall(function()
                local Event = game:GetService("ReplicatedStorage").Remotes.UpgradeRequested
                Event:FireServer("Speed", 1)
            end)
            task.wait(unifiedInterval)
        else
            task.wait(0.5)
        end
    end
end)

-- ==================== 自动升级最大速度 ====================
spawn(function()
    while true do
        if autoMaxSpeed then
            pcall(function()
                local Event = game:GetService("ReplicatedStorage").Remotes.UpgradeRequested
                Event:FireServer("Speed", 132)
            end)
            task.wait(unifiedInterval)
        else
            task.wait(0.5)
        end
    end
end)

-- ==================== 传送函数 ====================
local function teleportToPos(x, y, z, label)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        WI:Notify({Title = "传送失败", Content = "角色不存在", Duration = 2})
        return
    end
    char.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
    WI:Notify({Title = "传送成功", Content = "已到" .. label, Duration = 2})
end

local function teleportToNearestWithKeyword(keyword, label)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    local hrp = char.HumanoidRootPart
    local closest, closestDist = nil, math.huge

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name:find(keyword) then
            local root = getRoot(obj)
            if root then
                local d = (hrp.Position - root.Position).Magnitude
                if d > 2 and not Players:GetPlayerFromCharacter(obj) then
                    if d < closestDist then
                        closestDist = d
                        closest = root
                    end
                end
            end
        end
    end

    if closest then
        hrp.CFrame = closest.CFrame * CFrame.new(0, 3, 0)
        return true
    end
    return false
end

-- ==================== UI ====================
local Window = WI:CreateWindow({
    Title = "加1翅膀偷脑残",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(500, 380),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--加1翅膀偷脑残",
    Desc = "自动功能 | 传送 | 脑残beta | 速度 | 飞行\n这游戏玩人是傻子吗😂😂😂"
})

-- 自动标签页
local T2 = Window:Tab({Title = "自动", Icon = "solar:bolt-bold"})
T2:Section({Title = "统一间隔"})
T2:Slider({Title = "间隔(秒)", Value = {Min = 1, Max = 10, Default = 3}, Step = 0.5, Callback = function(v) unifiedInterval = v end})

T2:Section({Title = "自动功能"})
T2:Toggle({Title = "自动领时间奖励", Value = false, Callback = function(v) autoTimeReward = v end})
T2:Toggle({Title = "自动重生", Value = false, Callback = function(v) autoRebirth = v end})
T2:Divider()
T2:Toggle({Title = "自动升耐力", Value = false, Callback = function(v) autoStamina = v end})
T2:Toggle({Title = "自动升级携带", Value = false, Callback = function(v) autoCarry = v end})
T2:Toggle({Title = "自动升级速度", Value = false, Callback = function(v) autoSpeedUp = v end})
T2:Toggle({Title = "自动升级最大速度", Value = false, Callback = function(v) autoMaxSpeed = v end})

-- 传送标签页
local T3 = Window:Tab({Title = "传送", Icon = "solar:map-bold"})
T3:Section({Title = "固定传送"})
T3:Button({Title = "传送到上帝脑残区", Justify = "Center", Callback = function() teleportToPos(31, 3.2, 9999, "上帝脑残区") end})
T3:Button({Title = "传送到宇宙脑残区", Justify = "Center", Callback = function() teleportToPos(17, 3.2, 6141, "宇宙脑残区") end})
T3:Button({Title = "传送回家", Justify = "Center", Callback = function() teleportToPos(32, 3.2, -45, "家") end})

T3:Section({Title = "稀有脑残 (beta)"})
T3:Dropdown({
    Title = "选择稀有脑残",
    Values = {"蓝莓章鱼", "铅笔脑残", "龙龟脑残"},
    Value = "",
    Multi = false,
    AllowNone = true,
    Callback = function(v)
        if type(v) == "string" and v ~= "" then
            if v == "蓝莓章鱼" then selectedRare = "Blueberrinni"
            elseif v == "铅笔脑残" then selectedRare = "Pakrahma"
            elseif v == "龙龟脑残" then selectedRare = "Mesh"
            end
        else selectedRare = "" end
    end
})
T3:Dropdown({
    Title = "选择突变类型",
    Values = {"无", "金突变", "银河突变", "彩虹突变"},
    Value = "无",
    Multi = false,
    AllowNone = false,
    Callback = function(v)
        if v == "金突变" then selectedMutation = "Gold "
        elseif v == "银河突变" then selectedMutation = "Galaxy "
        elseif v == "彩虹突变" then selectedMutation = "Rainbow "
        else selectedMutation = "" end
    end
})
T3:Button({Title = "传送到该脑残", Justify = "Center", Callback = function()
    if not selectedRare or selectedRare == "" then
        WI:Notify({Title = "失败", Content = "请先选择稀有脑残", Duration = 2})
        return
    end
    local searchKeyword = selectedMutation .. selectedRare
    local found = teleportToNearestWithKeyword(searchKeyword, "脑残")
    if found then
        WI:Notify({Title = "传送成功", Content = "已到脑残", Duration = 2})
    else
        WI:Notify({Title = "失败", Content = "没找到脑残", Duration = 2})
    end
end})

-- 玩家标签页
local T4 = Window:Tab({Title = "玩家", Icon = "solar:user-bold"})
T4:Section({Title = "速度"})
T4:Toggle({Title = "速度加成", Value = false, Callback = function(v) speedBoost = v end})
T4:Slider({Title = "速度值", Value = {Min = 16, Max = 200, Default = 50}, Callback = function(v) speedValue = v end})
T4:Section({Title = "飞行"})
T4:Button({Title = "加载飞行脚本", Justify = "Center", Callback = function()
    pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/飞饼"))() end)
    WI:Notify({Title = "飞行", Content = "已加载", Duration = 2})
end})

-- 设置标签页
local T5 = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})
local statusParagraph = T5:Paragraph({Title = "功能状态", Desc = "加载中..."})

spawn(function()
    while true do
        pcall(function()
            local fps = math.floor(1 / (RunService.RenderStepped:Wait() or 0.016))
            local status = "FPS: " .. fps .. "\n\n" ..
                "时间奖励: " .. (autoTimeReward and "✅" or "❌") .. "\n" ..
                "重生: " .. (autoRebirth and "✅" or "❌") .. "\n" ..
                "升耐力: " .. (autoStamina and "✅" or "❌") .. "\n" ..
                "升携带: " .. (autoCarry and "✅" or "❌") .. "\n" ..
                "升速度: " .. (autoSpeedUp and "✅" or "❌") .. "\n" ..
                "最大速度: " .. (autoMaxSpeed and "✅" or "❌") .. "\n" ..
                "统一间隔: " .. unifiedInterval .. "秒"
            statusParagraph:SetDesc(status)
        end)
        task.wait(0.5)
    end
end)

T5:Button({Title = "关闭面板", Justify = "Center", Callback = function() Window:Close() end})

WI:Notify({Title = "🌙 加1翅膀偷脑残", Content = "加载完成", Duration = 3})
print("🌙 加1翅膀偷脑残 加载完成")
