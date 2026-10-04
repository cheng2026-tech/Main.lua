-- 🌙 跳跃盗取足球球员 | V1.6

local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- 变量
local speedBoost = false
local speedValue = 50

local jumpBoost = false
local jumpPower = 50

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

-- ==================== 跳跃高度 ====================
RunService.RenderStepped:Connect(function()
    if jumpBoost then
        pcall(function()
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then
                c.Humanoid.JumpPower = jumpPower
            end
        end)
    end
end)

-- ==================== 传送 ====================
local function teleportToTop()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        WI:Notify({Title = "传送失败", Content = "角色不存在", Duration = 2})
        return
    end
    char.HumanoidRootPart.CFrame = CFrame.new(196, 2240.1, -1300)
    WI:Notify({Title = "传送成功", Content = "已到顶部", Duration = 2})
end

local function teleportToBottom()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        WI:Notify({Title = "传送失败", Content = "角色不存在", Duration = 2})
        return
    end
    char.HumanoidRootPart.CFrame = CFrame.new(196, 3, 282)
    WI:Notify({Title = "传送成功", Content = "已到底部", Duration = 2})
end

local function teleportToNearest(keyword, label)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        WI:Notify({Title = "传送失败", Content = "角色不存在", Duration = 2})
        return
    end
    local hrp = char.HumanoidRootPart
    local closestObj = nil
    local closestDist = math.huge
    local closestPos = nil

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name:find(keyword) then
            local pos = nil
            if obj:IsA("BasePart") then
                pos = obj.Position
            elseif obj:IsA("Model") then
                local p = obj:FindFirstChildWhichIsA("BasePart") or obj.PrimaryPart
                if p then pos = p.Position end
            end
            if pos then
                local d = (hrp.Position - pos).Magnitude
                if d < closestDist then
                    closestDist = d
                    closestObj = obj
                    closestPos = pos
                end
            end
        end
    end

    if closestObj and closestPos then
        hrp.CFrame = CFrame.new(closestPos.X, closestPos.Y + 3, closestPos.Z)
        WI:Notify({Title = "传送成功", Content = "已到" .. label .. " (" .. closestObj.Name .. ")", Duration = 2})
    else
        -- 列出名字匹配的物品帮助排查
        local names = {}
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name:find(keyword) then
                table.insert(names, obj.Name)
            end
        end
        if #names > 0 then
            local msg = "找到以下物品但无法获取位置:\n"
            for i = 1, math.min(5, #names) do
                msg = msg .. names[i] .. "\n"
            end
            WI:Notify({Title = "排查信息", Content = msg, Duration = 5})
        else
            WI:Notify({Title = "传送失败", Content = "没找到包含'" .. keyword .. "'的物品", Duration = 3})
        end
    end
end

-- ==================== 删除VIP墙 ====================
local function deleteVIPDoors()
    local count = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        pcall(function()
            if obj.Name == "VIPDoors" then
                obj:Destroy()
                count = count + 1
            end
        end)
    end
    WI:Notify({Title = "删除完成", Content = "已删除" .. count .. "个VIP墙", Duration = 2})
end

-- ==================== UI ====================
local Window = WI:CreateWindow({
    Title = "跳跃盗取足球球员",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(500, 400),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--跳跃盗取足球球员 V1.6",
    Desc = "传送顶部/底部 | 幸运方块 | 删除VIP墙\n跳跃高度 | 速度 | 飞行"
})

local T2 = Window:Tab({Title = "主要功能", Icon = "solar:star-bold"})
T2:Section({Title = "传送"})
T2:Button({Title = "传送到顶部", Justify = "Center", Callback = function() teleportToTop() end})
T2:Button({Title = "传送到底部", Justify = "Center", Callback = function() teleportToBottom() end})
T2:Button({Title = "传送到OG幸运方块", Justify = "Center", Callback = function() teleportToNearest("OG", "OG幸运方块") end})
T2:Button({Title = "传送到西班牙幸运方块", Justify = "Center", Callback = function() teleportToNearest("Spain", "西班牙幸运方块") end})
T2:Button({Title = "传送到冠军幸运方块", Justify = "Center", Callback = function() teleportToNearest("Champion", "冠军幸运方块") end})

T2:Section({Title = "删除VIP墙"})
T2:Button({Title = "删除所有VIP墙", Justify = "Center", Callback = function() deleteVIPDoors() end})

local T3 = Window:Tab({Title = "玩家", Icon = "solar:user-bold"})
T3:Section({Title = "速度"})
T3:Toggle({Title = "速度加成", Value = false, Callback = function(v) speedBoost = v end})
T3:Slider({Title = "速度值", Value = {Min = 16, Max = 200, Default = 50}, Callback = function(v) speedValue = v end})

T3:Section({Title = "跳跃"})
T3:Toggle({Title = "跳跃加成", Value = false, Callback = function(v) jumpBoost = v; if not v then pcall(function() LocalPlayer.Character.Humanoid.JumpPower = 50 end) end end})
T3:Slider({Title = "跳跃高度", Value = {Min = 50, Max = 500, Default = 50}, Step = 10, Callback = function(v) jumpPower = v end})

T3:Section({Title = "飞行"})
T3:Button({Title = "加载飞行脚本", Justify = "Center", Callback = function()
    pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/飞饼"))() end)
    WI:Notify({Title = "飞行", Content = "已加载", Duration = 2})
end})

-- 设置
local T4 = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})
local statusParagraph = T4:Paragraph({Title = "功能状态", Desc = "加载中..."})

spawn(function()
    while true do
        pcall(function()
            local fps = math.floor(1 / (RunService.RenderStepped:Wait() or 0.016))
            local status = "FPS: " .. fps .. "\n\n" ..
                "速度: " .. (speedBoost and "✅ " .. speedValue or "❌") .. "\n" ..
                "跳跃: " .. (jumpBoost and "✅ " .. jumpPower or "❌")
            statusParagraph:SetDesc(status)
        end)
        task.wait(0.5)
    end
end)

Window:OnClose(function() end)

WI:Notify({Title = "🌙 跳跃盗取足球球员", Content = "V1.6 加载完成", Duration = 3})
print("🌙 跳跃盗取足球球员 V1.6 加载完成")
