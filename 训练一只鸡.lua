-- 🌙 训练一只鸡 | V1.3

local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- 变量
local autoMoney = false
local homePosition = nil
local ironCount = 10
local currentIron = 0
local visitedLoose = {}

local playerESP = false
local playerESPColor = Color3.fromRGB(255, 50, 50)
local showDistance = false
local playerESPObjects = {}

local speedBoost = false
local speedValue = 50

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

local function findNearestLoose(hrp)
    local best, bestDist = nil, math.huge
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name:find("Loose") then
            local root = getRoot(obj)
            if root and not visitedLoose[obj] then
                local d = (hrp.Position - root.Position).Magnitude
                if d < bestDist then
                    bestDist = d
                    best = {obj = obj, root = root}
                end
            end
        end
    end
    return best
end

local function wiggle()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end

    -- 小幅度移动一下触发服务器刷新
    local origPos = hrp.Position
    humanoid:MoveTo(origPos + Vector3.new(3, 0, 0))
    task.wait(0.3)
    humanoid:MoveTo(origPos)
    task.wait(0.3)
end

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

-- ==================== Auto Money ====================
spawn(function()
    while true do
        if autoMoney then
            pcall(function()
                if not homePosition then
                    WI:Notify({Title = "Auto Money", Content = "请先设置家位置", Duration = 2})
                    autoMoney = false
                    return
                end

                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then
                    task.wait(1)
                    return
                end
                local hrp = char.HumanoidRootPart

                local target = findNearestLoose(hrp)
                if not target then
                    visitedLoose = {}
                    WI:Notify({Title = "Auto Money", Content = "所有Loose已去过，重置记录", Duration = 2})
                    task.wait(0.5)
                    return
                end

                -- 传送到铁片上方
                local targetPos = target.root.Position
                hrp.CFrame = CFrame.new(targetPos.X, targetPos.Y + 5, targetPos.Z)
                visitedLoose[target.obj] = true
                task.wait(0.3)

                -- 稍微动一下触发刷新
                wiggle()
                currentIron = currentIron + 1
                WI:Notify({Title = "Auto Money", Content = "已收集 " .. currentIron .. "/" .. ironCount .. " 个铁", Duration = 1})

                -- 收够了回家
                if currentIron >= ironCount then
                    currentIron = 0
                    visitedLoose = {}
                    -- 传送到家上方
                    hrp.CFrame = CFrame.new(homePosition.X, homePosition.Y + 3, homePosition.Z)
                    task.wait(0.3)
                    wiggle()
                    WI:Notify({Title = "Auto Money", Content = "已回家，休息中", Duration = 2})
                    task.wait(2)
                end
            end)
        end
        task.wait(0.3)
    end
end)

-- ==================== 设置家 ====================
local function setHome()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        WI:Notify({Title = "设置失败", Content = "角色不存在", Duration = 2})
        return
    end
    homePosition = char.HumanoidRootPart.Position
    WI:Notify({Title = "设置成功", Content = "已记录家位置", Duration = 2})
end

-- ==================== 玩家ESP ====================
local function clearPlayer()
    for _, obj in ipairs(playerESPObjects) do
        pcall(function() obj:Destroy() end)
    end
    playerESPObjects = {}
end

local function refreshPlayerESP()
    clearPlayer()
    if not playerESP then return end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            pcall(function()
                local c = plr.Character
                local root = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Head")
                if not root then return end

                local hl = Instance.new("Highlight")
                hl.FillColor = playerESPColor
                hl.FillTransparency = 0.3
                hl.OutlineColor = playerESPColor
                hl.OutlineTransparency = 0.2
                hl.Adornee = c
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = c
                table.insert(playerESPObjects, hl)

                local bb = Instance.new("BillboardGui")
                bb.Size = UDim2.new(0, 200, 0, 30)
                bb.StudsOffset = Vector3.new(0, 3, 0)
                bb.AlwaysOnTop = true
                bb.Adornee = root
                bb.Parent = root
                table.insert(playerESPObjects, bb)

                local lb = Instance.new("TextLabel")
                lb.Size = UDim2.new(1, 0, 1, 0)
                lb.BackgroundTransparency = 1
                lb.Text = plr.Name
                lb.TextColor3 = playerESPColor
                lb.TextStrokeTransparency = 0
                lb.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                lb.Font = Enum.Font.SourceSansBold
                lb.TextSize = 16
                lb.Parent = bb

                if showDistance then
                    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if myRoot then
                        local d = math.floor((myRoot.Position - root.Position).Magnitude)
                        local db = Instance.new("BillboardGui")
                        db.Size = UDim2.new(0, 100, 0, 20)
                        db.StudsOffset = Vector3.new(0, -1.5, 0)
                        db.AlwaysOnTop = true
                        db.Adornee = root
                        db.Parent = root
                        table.insert(playerESPObjects, db)

                        local dl = Instance.new("TextLabel")
                        dl.Size = UDim2.new(1, 0, 1, 0)
                        dl.BackgroundTransparency = 1
                        dl.Text = d .. "m"
                        dl.TextColor3 = Color3.fromRGB(255, 255, 255)
                        dl.TextStrokeTransparency = 0
                        dl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        dl.Font = Enum.Font.SourceSansBold
                        dl.TextSize = 14
                        dl.Parent = db
                    end
                end
            end)
        end
    end
end

task.spawn(function()
    while task.wait(1.5) do
        pcall(function() refreshPlayerESP() end)
    end
end)

-- ==================== UI ====================
local Window = WI:CreateWindow({
    Title = "训练一只鸡",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(500, 380),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--训练一只鸡 V1.3",
    Desc = "Auto Money | 设置家 | 调铁数\n透视玩家 | 速度 | 飞行"
})

local T2 = Window:Tab({Title = "主要功能", Icon = "solar:star-bold"})
T2:Section({Title = "Auto Money"})
T2:Button({Title = "设置当前位置为家", Justify = "Center", Callback = function() setHome() end})
T2:Slider({Title = "多少个铁后回家", Value = {Min = 1, Max = 50, Default = 10}, Step = 1, Callback = function(v) ironCount = v end})
T2:Toggle({Title = "开启Auto Money", Value = false, Callback = function(v) autoMoney = v; if not v then visitedLoose = {}; currentIron = 0 end end})

local T3 = Window:Tab({Title = "玩家", Icon = "solar:user-bold"})
T3:Section({Title = "透视"})
T3:Toggle({Title = "透视所有玩家", Value = false, Callback = function(v) playerESP = v end})
T3:Colorpicker({Title = "颜色", Default = Color3.fromRGB(255, 50, 50), Callback = function(c) playerESPColor = c end})
T3:Toggle({Title = "显示距离", Value = false, Callback = function(v) showDistance = v end})
T3:Section({Title = "速度"})
T3:Toggle({Title = "速度加成", Value = false, Callback = function(v) speedBoost = v end})
T3:Slider({Title = "速度值", Value = {Min = 16, Max = 200, Default = 50}, Callback = function(v) speedValue = v end})
T3:Section({Title = "飞行"})
T3:Button({Title = "加载飞行脚本", Justify = "Center", Callback = function()
    pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/飞饼"))() end)
    WI:Notify({Title = "飞行", Content = "已加载", Duration = 2})
end})

Window:Tab({Title = "设置", Icon = "solar:settings-bold"}):Button({
    Title = "关闭面板",
    Justify = "Center",
    Callback = function() Window:Close() end
})

Window:OnClose(function()
    clearPlayer()
    autoMoney = false
end)

WI:Notify({Title = "🌙 训练一只鸡", Content = "V1.3 加载完成", Duration = 3})
print("🌙 训练一只鸡 V1.3 加载完成")
