-- 🌙 在寒冷中生存 | V1.3

local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- 变量
local woodESP = false
local woodESPColor = Color3.fromRGB(139, 90, 43)
local woodESPRange = 500

local playerESP = false
local playerESPColor = Color3.fromRGB(255, 50, 50)
local showDistance = false

local autoWoodFarm = false
local visitedWoods = {}

local speedBoost = false
local speedValue = 50

local homePosition = nil

local teleportStepSize = 30
local teleportInterval = 2
local stopTeleport = false

local espCache = {}
local playerESPObjects = {}

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

-- ==================== 安全传送（可自定义间隔，可停止）====================
local function safeTeleport(targetPos)
    stopTeleport = false
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    local hrp = char.HumanoidRootPart
    local dist = (hrp.Position - targetPos).Magnitude

    if dist <= teleportStepSize then
        hrp.CFrame = CFrame.new(targetPos)
        return true
    else
        local direction = (targetPos - hrp.Position).Unit
        local remaining = dist

        while remaining > teleportStepSize do
            if stopTeleport then
                WI:Notify({Title = "传送停止", Content = "已中断传送", Duration = 2})
                return false
            end
            local nextPos = hrp.Position + direction * teleportStepSize
            hrp.CFrame = CFrame.new(nextPos)
            remaining = (hrp.Position - targetPos).Magnitude

            local waited = 0
            while waited < teleportInterval do
                if stopTeleport then
                    WI:Notify({Title = "传送停止", Content = "已中断传送", Duration = 2})
                    return false
                end
                task.wait(0.1)
                waited = waited + 0.1
            end
        end

        if stopTeleport then
            WI:Notify({Title = "传送停止", Content = "已中断传送", Duration = 2})
            return false
        end
        hrp.CFrame = CFrame.new(targetPos)
        return true
    end
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

-- ==================== 枯木ESP ====================
local function ClearESP()
    for _, d in ipairs(espCache) do
        pcall(function() if d.hl then d.hl:Destroy() end if d.bb then d.bb:Destroy() end end)
    end
    espCache = {}
end

local function CreateESP(obj, color, name, dist)
    local root = getRoot(obj)
    if not root then return end

    local hl = Instance.new("Highlight")
    hl.FillColor = color
    hl.FillTransparency = 0.4
    hl.OutlineColor = color
    hl.OutlineTransparency = 0
    hl.Adornee = obj
    hl.Parent = obj
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    table.insert(espCache, {hl = hl})

    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, 200, 0, 30)
    bb.StudsOffset = Vector3.new(0, 2.5, 0)
    bb.AlwaysOnTop = true
    bb.Parent = root
    table.insert(espCache, {bb = bb})

    local nl = Instance.new("TextLabel")
    nl.Size = UDim2.new(1, 0, 1, 0)
    nl.BackgroundTransparency = 1
    nl.TextColor3 = Color3.new(1, 1, 1)
    nl.Text = name
    nl.Font = Enum.Font.SourceSansBold
    nl.TextSize = 14
    nl.TextStrokeTransparency = 0
    nl.TextStrokeColor3 = Color3.new(0, 0, 0)
    nl.Parent = bb

    if dist >= 0 then
        local dl = Instance.new("TextLabel")
        dl.Size = UDim2.new(1, 0, 0, 18)
        dl.Position = UDim2.new(0, 0, 0.55, 0)
        dl.BackgroundTransparency = 1
        dl.TextColor3 = Color3.new(0.8, 0.8, 0.8)
        dl.Text = dist .. "m"
        dl.Font = Enum.Font.SourceSans
        dl.TextSize = 12
        dl.Parent = bb
    end
end

local lastESPUpdate = 0
local function UpdateESP()
    if tick() - lastESPUpdate < 0.5 then return end
    lastESPUpdate = tick()
    ClearESP()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if woodESP then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and (obj.Name:find("Tutorial_") or obj.Name:find("Green")) then
                local root = getRoot(obj)
                if root then
                    local d = (hrp.Position - root.Position).Magnitude
                    if d <= woodESPRange then
                        CreateESP(obj, woodESPColor, "枯木", math.floor(d))
                    end
                end
            end
        end
    end
end

task.spawn(function()
    while task.wait(0.5) do
        pcall(function() UpdateESP() end)
    end
end)

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

-- ==================== 传送最近枯木 ====================
local function teleportToNearestWood()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        WI:Notify({Title = "传送失败", Content = "角色不存在", Duration = 2})
        return
    end
    local hrp = char.HumanoidRootPart
    local closest, closestDist = nil, math.huge

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name:find("Tutorial_") or obj.Name:find("Green")) then
            local root = getRoot(obj)
            if root then
                local d = (hrp.Position - root.Position).Magnitude
                if d < closestDist then
                    closestDist = d
                    closest = root
                end
            end
        end
    end

    if closest then
        safeTeleport(closest.Position + Vector3.new(0, 3, 0))
    else
        WI:Notify({Title = "传送失败", Content = "没找到枯木", Duration = 2})
    end
end

-- ==================== 自动枯木农场 ====================
local function findUnvisitedWood(hrp)
    local best, bestDist = nil, math.huge
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name:find("Tutorial_") or obj.Name:find("Green")) then
            local root = getRoot(obj)
            if root and not visitedWoods[obj] then
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

spawn(function()
    while true do
        if autoWoodFarm then
            pcall(function()
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then
                    task.wait(1)
                    return
                end
                local hrp = char.HumanoidRootPart

                local target = findUnvisitedWood(hrp)
                if not target then
                    visitedWoods = {}
                    WI:Notify({Title = "枯木农场", Content = "已重置记录", Duration = 2})
                    task.wait(1)
                    return
                end

                safeTeleport(target.root.Position + Vector3.new(0, 3, 0))
                visitedWoods[target.obj] = true
                task.wait(0.3)

                local endTime = tick() + 5
                while tick() < endTime and autoWoodFarm do
                    pcall(function()
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    end)
                    task.wait(0.02)
                    pcall(function()
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    end)
                    task.wait(0.02)
                end
            end)
        end
        task.wait(0.5)
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

local function teleportHome()
    if not homePosition then
        WI:Notify({Title = "传送失败", Content = "请先设置家", Duration = 2})
        return
    end
    safeTeleport(homePosition)
end

local function teleportToShop()
    safeTeleport(Vector3.new(1414, -15.6, 967))
end

-- ==================== UI ====================
local Window = WI:CreateWindow({
    Title = "在寒冷中生存",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(500, 410),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--在寒冷中生存 V1.3",
    Desc = "透视枯木 | 自动农场 | 可调传送\n透视玩家 | 速度 | 飞行"
})

local T2 = Window:Tab({Title = "主要功能", Icon = "solar:star-bold"})
T2:Section({Title = "透视枯木"})
T2:Toggle({Title = "透视枯木", Value = false, Callback = function(v) woodESP = v end})
T2:Colorpicker({Title = "枯木颜色", Default = Color3.fromRGB(139, 90, 43), Callback = function(c) woodESPColor = c end})
T2:Slider({Title = "透视范围", Value = {Min = 0, Max = 10000, Default = 500}, Step = 10, Callback = function(v) woodESPRange = v end})

T2:Section({Title = "传送设置"})
T2:Slider({Title = "每次传送距离", Value = {Min = 10, Max = 50, Default = 30}, Step = 5, Callback = function(v) teleportStepSize = v end})
T2:Slider({Title = "传送间隔(秒)", Value = {Min = 1, Max = 5, Default = 2}, Step = 0.5, Callback = function(v) teleportInterval = v end})
T2:Button({Title = "停止传送", Justify = "Center", Callback = function() stopTeleport = true end})

T2:Section({Title = "枯木传送"})
T2:Button({Title = "传送到最近枯木", Justify = "Center", Callback = function() teleportToNearestWood() end})

T2:Section({Title = "自动枯木农场"})
T2:Toggle({Title = "开启自动农场", Value = false, Callback = function(v) autoWoodFarm = v; if not v then visitedWoods = {} end end})

local T3 = Window:Tab({Title = "传送", Icon = "solar:map-bold"})
T3:Section({Title = "家"})
T3:Button({Title = "设置当前位置为家", Justify = "Center", Callback = function() setHome() end})
T3:Button({Title = "传送回家", Justify = "Center", Callback = function() teleportHome() end})

T3:Section({Title = "装饰商店"})
T3:Button({Title = "传送到装饰商店", Justify = "Center", Callback = function() teleportToShop() end})

local T4 = Window:Tab({Title = "玩家", Icon = "solar:user-bold"})
T4:Section({Title = "透视"})
T4:Toggle({Title = "透视所有玩家", Value = false, Callback = function(v) playerESP = v end})
T4:Colorpicker({Title = "颜色", Default = Color3.fromRGB(255, 50, 50), Callback = function(c) playerESPColor = c end})
T4:Toggle({Title = "显示距离", Value = false, Callback = function(v) showDistance = v end})
T4:Section({Title = "速度"})
T4:Toggle({Title = "速度加成", Value = false, Callback = function(v) speedBoost = v end})
T4:Slider({Title = "速度值", Value = {Min = 16, Max = 200, Default = 50}, Callback = function(v) speedValue = v end})
T4:Section({Title = "飞行"})
T4:Button({Title = "加载飞行脚本", Justify = "Center", Callback = function()
    pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/飞饼"))() end)
    WI:Notify({Title = "飞行", Content = "已加载", Duration = 2})
end})

Window:Tab({Title = "设置", Icon = "solar:settings-bold"}):Button({
    Title = "关闭面板",
    Justify = "Center",
    Callback = function() Window:Close() end
})

Window:OnClose(function()
    ClearESP()
    clearPlayer()
    stopTeleport = true
end)

WI:Notify({Title = "🌙 在寒冷中生存", Content = "V1.3 加载完成 | 可调传送", Duration = 3})
print("🌙 在寒冷中生存 V1.3 加载完成")
