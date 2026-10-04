-- 🌙 因为脑残退化而倒下 | V1.1

local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- 变量
local selectedBrainrot = ""
local autoRebirth = false

-- ==================== 冰白主题 ====================
WI:AddTheme({
    Name = "冰白",
    Accent = "#80C0FF",
    Outline = "#6090C0",
    Text = "#FFFFFF",
    Placeholder = "#D0E0FF"
})

-- ==================== 辅助 ====================
local function getRoot(obj)
    if obj:IsA("Model") then
        return obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head") or obj:FindFirstChild("Handle") or obj.PrimaryPart
    elseif obj:IsA("BasePart") then
        return obj
    end
    for _, c in ipairs(obj:GetDescendants()) do
        if c:IsA("BasePart") then return c end
    end
    return nil
end

-- ==================== 传送 ====================
local function teleportToPos(x, y, z, label)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        WI:Notify({Title = "失败", Content = "角色不存在", Duration = 2})
        return
    end
    char.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
    WI:Notify({Title = "成功", Content = "已到" .. label, Duration = 2})
end

local function teleportToNearest(keyword, label)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        WI:Notify({Title = "失败", Content = "角色不存在", Duration = 2})
        return
    end
    local hrp = char.HumanoidRootPart
    local closest, closestDist = nil, math.huge

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name:find(keyword) then
            local root = getRoot(obj)
            if root then
                local d = (hrp.Position - root.Position).Magnitude
                if d < closestDist and d > 2 then
                    closestDist = d
                    closest = root
                end
            end
        end
    end

    if closest then
        hrp.CFrame = CFrame.new(closest.Position + Vector3.new(0, 5, 0))
        WI:Notify({Title = "成功", Content = "已到" .. label, Duration = 2})
    else
        WI:Notify({Title = "失败", Content = "没找到" .. label, Duration = 2})
    end
end

-- ==================== 自动重生 ====================
spawn(function()
    while true do
        if autoRebirth then
            pcall(function()
                local Event = game:GetService("ReplicatedStorage").BrainrotStorage.Events.RequestRebirth
                Event:FireServer()
            end)
            task.wait(10)
        else
            task.wait(0.5)
        end
    end
end)

-- ==================== UI ====================
local Window = WI:CreateWindow({
    Title = "因为脑残退化而倒下",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(400, 380),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--因为脑残退化而倒下",
    Desc = "传送区域/回家 | 管理员硬币 | 脑残 | 自动重生\n玩这个游戏的人是东子😂😂😂"
})

local T2 = Window:Tab({Title = "传送", Icon = "solar:map-bold"})

T2:Section({Title = "区域传送"})
T2:Button({Title = "传送超越区域", Justify = "Center", Callback = function() teleportToPos(48.8, -6922, -2459, "超越区域") end})
T2:Button({Title = "传送深渊区域", Justify = "Center", Callback = function() teleportToPos(128, -1913.2, -2466, "深渊区域") end})
T2:Button({Title = "传送永恒区域", Justify = "Center", Callback = function() teleportToPos(106, 2086.9, -2405, "永恒区域") end})
T2:Button({Title = "传送回家", Justify = "Center", Callback = function() teleportToPos(117, 14590.4, -2597, "家") end})

T2:Section({Title = "物品传送"})
T2:Button({Title = "传送管理员硬币", Justify = "Center", Callback = function() teleportToNearest("AdminCoin", "管理员硬币") end})

T2:Section({Title = "脑残传送"})
T2:Dropdown({
    Title = "选择脑残",
    Values = {"帕萨特脑残", "键盘脑残"},
    Value = "",
    Multi = false,
    AllowNone = true,
    Callback = function(v)
        if type(v) == "string" and v ~= "" then
            if v == "帕萨特脑残" then
                selectedBrainrot = "SpawnedItem"
            elseif v == "键盘脑残" then
                selectedBrainrot = "Cube"
            end
        else
            selectedBrainrot = ""
        end
    end
})
T2:Button({Title = "传送到该脑残", Justify = "Center", Callback = function()
    if selectedBrainrot == "" then
        WI:Notify({Title = "失败", Content = "请先选择脑残", Duration = 2})
        return
    end
    teleportToNearest(selectedBrainrot, "脑残")
end})

T2:Section({Title = "自动重生"})
T2:Toggle({Title = "开启自动重生(10秒)", Value = false, Callback = function(v) autoRebirth = v end})

local T3 = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})
local statusParagraph = T3:Paragraph({Title = "功能状态", Desc = "加载中..."})

spawn(function()
    while true do
        pcall(function()
            local fps = math.floor(1 / (RunService.RenderStepped:Wait() or 0.016))
            local status = "FPS: " .. fps .. "\n\n" ..
                "自动重生: " .. (autoRebirth and "✅" or "❌") .. "\n" ..
                "选中脑残: " .. (selectedBrainrot or "无")
            statusParagraph:SetDesc(status)
        end)
        task.wait(0.5)
    end
end)

T3:Button({Title = "关闭面板", Justify = "Center", Callback = function() Window:Close() end})

WI:Notify({Title = "🌙 因为脑残退化而倒下", Content = "加载完成", Duration = 3})
print("🌙 因为脑残退化而倒下 加载完成")
