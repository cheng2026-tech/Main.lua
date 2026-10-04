-- 🌙 死铁轨 | Wind UI

local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

-- ==================== 变量 ====================
local zombieESP = false
local zombieESPColor = Color3.fromRGB(255, 50, 50)
local zombieESPRange = 500

local bondESP = false
local bondESPColor = Color3.fromRGB(50, 255, 50)
local bondESPRange = 500

local werewolfESP = false
local werewolfESPColor = Color3.fromRGB(139, 90, 43)
local werewolfESPRange = 500

local nightVision = false
local nightVisionBrightness = 0.15

local doubleJumpEnabled = false
local hasDoubleJumped = false

local autoFarmBond = false

local autoAttack = false
local selectedWeapon = "铁铲"

local autoLootAll = false
local lootAllDelay = 0.01

local espCache = {}

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

local function ClearESP()
    for _, d in ipairs(espCache) do
        pcall(function()
            if d.hl then d.hl:Destroy() end
            if d.bb then d.bb:Destroy() end
        end)
    end
    espCache = {}
end

-- ==================== 吸全图物品（修复：不破坏正常拾取）====================
local function StartAutoLootAll()
    if autoLootAll then return end
    autoLootAll = true
    spawn(function()
        local Event = game:GetService("ReplicatedStorage").Shared.Universe.Network.RemoteEvent.Store
        local currentID = 1700
        local maxID = 4000
        
        while autoLootAll and currentID <= maxID do
            pcall(function()
                Event:FireServer(currentID)
            end)
            pcall(function()
                Event:FireServer(currentID)
            end)
            
            currentID = currentID + 1
            task.wait(lootAllDelay)
        end
        
        if currentID > maxID then
            WI:Notify({Title = "吸全图物品", Content = "已完成1700-4000全部ID", Duration = 3})
            autoLootAll = false
        end
    end)
end

local function StopAutoLootAll()
    autoLootAll = false
end

-- ==================== 冰白主题 ====================
WI:AddTheme({
    Name = "冰白",
    Accent = "#80C0FF",
    Outline = "#6090C0",
    Text = "#FFFFFF",
    Placeholder = "#D0E0FF"
})

-- ==================== 夜视 ====================
spawn(function()
    local nightEffect = nil
    while true do
        if nightVision then
            pcall(function()
                if not nightEffect then
                    nightEffect = Instance.new("ColorCorrectionEffect")
                    nightEffect.Parent = Lighting
                end
                nightEffect.Brightness = nightVisionBrightness
                nightEffect.Contrast = 0.2
                nightEffect.Saturation = -0.3
                Lighting.Brightness = 1.2
                Lighting.ClockTime = 14
                Lighting.FogEnd = 100000
                Lighting.GlobalShadows = false
            end)
        else
            pcall(function()
                if nightEffect then
                    nightEffect:Destroy()
                    nightEffect = nil
                end
                Lighting.Brightness = 1
                Lighting.FogEnd = 500
                Lighting.GlobalShadows = true
            end)
        end
        task.wait(0.3)
    end
end)

-- ==================== 二段跳 ====================
UserInputService.JumpRequest:Connect(function()
    if not doubleJumpEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if humanoid.FloorMaterial == Enum.Material.Air and not hasDoubleJumped then
        hasDoubleJumped = true
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        root.Velocity = Vector3.new(root.Velocity.X, 50, root.Velocity.Z)
    elseif humanoid.FloorMaterial ~= Enum.Material.Air then
        hasDoubleJumped = false
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    hasDoubleJumped = false
end)

-- ==================== ESP系统 ====================
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
    bb.MaxDistance = 500
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

    if zombieESP then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and (obj.Name == "Model_Runner" or obj.Name == "Model_Walker") then
                local root = getRoot(obj)
                if root then
                    local d = (hrp.Position - root.Position).Magnitude
                    if d <= zombieESPRange then
                        local label = "僵尸"
                        if obj.Name == "Model_Runner" then label = "Runner" else label = "Walker" end
                        CreateESP(obj, zombieESPColor, label, math.floor(d))
                    end
                end
            end
        end
    end

    if werewolfESP then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == "Model_Werewolf" then
                local root = getRoot(obj)
                if root then
                    local d = (hrp.Position - root.Position).Magnitude
                    if d <= werewolfESPRange then
                        CreateESP(obj, werewolfESPColor, "狼人", math.floor(d))
                    end
                end
            end
        end
    end

    if bondESP then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == "bond" then
                local root = getRoot(obj)
                if root then
                    local d = (hrp.Position - root.Position).Magnitude
                    if d <= bondESPRange then
                        CreateESP(obj, bondESPColor, "债券", math.floor(d))
                    end
                end
            end
        end
    end
end

task.spawn(function()
    while true do
        UpdateESP()
        task.wait(0.5)
    end
end)

-- ==================== 刷债券 ====================
local function FarmBonds()
    autoFarmBond = true
    spawn(function()
        local RS = game:GetService("ReplicatedStorage")
        local world = require(RS.Shared.Universe.ECS.world)
        local comps = require(RS.Shared.Universe.ECS.components)
        local replicator = require(RS.Client.Universe.Replication.clientReplicator)
        local Remotes = require(RS.Shared.Universe.Remotes)
        local Event = game:GetService("ReplicatedStorage").Shared.Universe.Network.RemoteEvent.Actionable
        while autoFarmBond do
            pcall(function()
                local char = world:get_resource(comps.ClientStateResource).localCharacter
                if char then
                    if not world:has(char, comps.Sack) then
                        world:add(char, comps.Sack)
                        world:set(char, comps.Sack, {contents = {}, maxContents = 10})
                    end
                    for id = 1, 100000 do
                        if world:has(id, comps.Storable) and world:get(id, comps.ObjectId) == "bond" then
                            local sr = replicator:get_server_entity(id)
                            if sr and sr ~= id then
                                Remotes.Store:FireServer(sr)
                                Event:FireServer(sr)
                            end
                        end
                    end
                end
            end)
            task.wait(1)
        end
        WI:Notify({Title = "刷债券", Content = "所有债券已刷完", Duration = 3})
    end)
end

-- ==================== 自动攻击 ====================
local weaponData = {
    ["铁铲"] = {toolName = "Shovel", timestamp = 1786259955.31, direction = Vector3.new(-0.5501235127449, -0.11845375597477, -0.82663947343826)},
    ["吸血刀"] = {toolName = "Vampire Knife", timestamp = 1786261382.1931, direction = Vector3.new(0.9853847026825, 0.012312123551965, 0.16989815235138)},
    ["长矛"] = {toolName = "Spear", timestamp = 1786261414.8305, direction = Vector3.new(0.31296426057816, -0.25160911679268, 0.91583091020584)}
}

local attackLoopRunning = false
local function StartAutoAttack()
    if attackLoopRunning then return end
    autoAttack = true
    attackLoopRunning = true
    spawn(function()
        local Event = game:GetService("ReplicatedStorage").Shared.Universe.Network.RemoteEvent.SwingMelee
        while autoAttack do
            local data = weaponData[selectedWeapon]
            pcall(function()
                local char = LocalPlayer.Character
                if char and data and char:FindFirstChild(data.toolName) then
                    Event:FireServer(char[data.toolName], data.timestamp, data.direction)
                end
            end)
            task.wait(0.01)
        end
        attackLoopRunning = false
    end)
end

-- ==================== UI ====================
local Window = WI:CreateWindow({
    Title = "黑脚本--死铁轨",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(540, 360),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true
})

-- 1. 公告
Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--死铁轨",
    Desc = "支持功能：\n\n• 透视僵尸/狼人/债券\n• 刷债券\n• 多武器快速攻击\n• 吸全图物品(1700-4000)\n• 夜视\n• 二段跳"
})

-- 2. 主要
local T2 = Window:Tab({Title = "主要", Icon = "solar:star-bold"})
T2:Dropdown({Title = "选择武器", Values = {"铁铲", "吸血刀", "长矛"}, Value = "铁铲", Multi = false, AllowNone = false, Callback = function(v) selectedWeapon = v end})
T2:Button({Title = "开始快速攻击", Justify = "Center", Callback = function()
    if autoAttack then WI:Notify({Title = "提示", Content = "已经在攻击了", Duration = 2}) return end
    StartAutoAttack()
    WI:Notify({Title = "快速攻击", Content = "已开启 " .. selectedWeapon, Duration = 2})
end})
T2:Button({Title = "停止快速攻击", Justify = "Center", Callback = function()
    autoAttack = false; WI:Notify({Title = "快速攻击", Content = "已停止", Duration = 2})
end})

-- 3. 刷债券
local T3 = Window:Tab({Title = "刷债券", Icon = "solar:dollar-bold"})
T3:Paragraph({Title = "自动刷债券", Desc = "一键循环拾取地图上所有债券"})
T3:Divider()
T3:Button({Title = "开始刷债券", Justify = "Center", Callback = function()
    if autoFarmBond then WI:Notify({Title = "提示", Content = "已经在刷了", Duration = 2}) return end
    FarmBonds()
    WI:Notify({Title = "刷债券", Content = "开始执行...", Duration = 2})
end})
T3:Button({Title = "停止刷债券", Justify = "Center", Callback = function()
    autoFarmBond = false; WI:Notify({Title = "刷债券", Content = "已停止", Duration = 2})
end})

-- 4. ESP透视
local T4 = Window:Tab({Title = "ESP透视", Icon = "solar:eye-bold"})
T4:Toggle({Title = "透视僵尸", Value = false, Callback = function(v) zombieESP = v end})
T4:Colorpicker({Title = "僵尸颜色", Default = Color3.fromRGB(255, 50, 50), Callback = function(c) zombieESPColor = c end})
T4:Slider({Title = "僵尸透视范围", Value = {Min = 0, Max = 10000, Default = 500}, Step = 10, Callback = function(v) zombieESPRange = v end})
T4:Divider()
T4:Toggle({Title = "透视狼人", Value = false, Callback = function(v) werewolfESP = v end})
T4:Colorpicker({Title = "狼人颜色", Default = Color3.fromRGB(139, 90, 43), Callback = function(c) werewolfESPColor = c end})
T4:Slider({Title = "狼人透视范围", Value = {Min = 0, Max = 10000, Default = 500}, Step = 10, Callback = function(v) werewolfESPRange = v end})
T4:Divider()
T4:Toggle({Title = "透视债券", Value = false, Callback = function(v) bondESP = v end})
T4:Colorpicker({Title = "债券颜色", Default = Color3.fromRGB(50, 255, 50), Callback = function(c) bondESPColor = c end})
T4:Slider({Title = "债券透视范围", Value = {Min = 0, Max = 10000, Default = 500}, Step = 10, Callback = function(v) bondESPRange = v end})

-- 5. 吸全图物品
local T5 = Window:Tab({Title = "吸物品", Icon = "solar:magnet-bold"})
T5:Toggle({
    Title = "吸全图物品",
    Value = false,
    Callback = function(v)
        if v then
            StartAutoLootAll()
        else
            StopAutoLootAll()
        end
    end
})
T5:Slider({
    Title = "吸取延迟 (0-1秒)",
    Value = {Min = 0, Max = 1, Default = 0.01},
    Step = 0.01,
    Callback = function(v)
        lootAllDelay = v
    end
})
T5:Divider()
T5:Button({Title = "开始吸取", Justify = "Center", Callback = function()
    if autoLootAll then
        WI:Notify({Title = "提示", Content = "已经在吸取了", Duration = 2})
        return
    end
    StartAutoLootAll()
    WI:Notify({Title = "吸全图物品", Content = "开始从1700吸取到4000", Duration = 2})
end})
T5:Button({Title = "停止吸取", Justify = "Center", Callback = function()
    StopAutoLootAll()
    WI:Notify({Title = "吸全图物品", Content = "已停止", Duration = 2})
end})

-- 6. 玩家
local T6 = Window:Tab({Title = "玩家", Icon = "solar:user-bold"})
T6:Toggle({Title = "夜视", Value = false, Callback = function(v) nightVision = v end})
T6:Slider({Title = "夜视亮度", Value = {Min = 0.05, Max = 0.5, Default = 0.15}, Step = 0.01, Callback = function(v) nightVisionBrightness = v end})
T6:Toggle({Title = "二段跳", Value = false, Callback = function(v) doubleJumpEnabled = v; hasDoubleJumped = false end})

-- 7. 设置
local T7 = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})

local statusParagraph = T7:Paragraph({
    Title = "功能状态",
    Desc = "正在加载..."
})

task.spawn(function()
    while true do
        local status = ""
        
        if zombieESP then status = status .. "✅ 僵尸透视: 已开启\n" else status = status .. "❌ 僵尸透视: 未开启\n" end
        if werewolfESP then status = status .. "✅ 狼人透视: 已开启\n" else status = status .. "❌ 狼人透视: 未开启\n" end
        if bondESP then status = status .. "✅ 债券透视: 已开启\n" else status = status .. "❌ 债券透视: 未开启\n" end
        if autoFarmBond then status = status .. "✅ 刷债券: 已开启\n" else status = status .. "❌ 刷债券: 未开启\n" end
        if autoAttack then status = status .. "✅ 快速攻击: 已开启 (" .. selectedWeapon .. ")\n" else status = status .. "❌ 快速攻击: 未开启\n" end
        if autoLootAll then status = status .. "✅ 吸全图物品: 已开启\n" else status = status .. "❌ 吸全图物品: 未开启\n" end
        if nightVision then status = status .. "✅ 夜视: 已开启\n" else status = status .. "❌ 夜视: 未开启\n" end
        if doubleJumpEnabled then status = status .. "✅ 二段跳: 已开启\n" else status = status .. "❌ 二段跳: 未开启\n" end
        
        statusParagraph:SetDesc(status)
        task.wait(2)
    end
end)

T7:Button({
    Title = "关闭面板",
    Callback = function()
        Window:Close()
    end
})

Window:OnClose(function() ClearESP() end)

WI:Notify({Title = "死铁轨", Content = "加载完成 | 按RightShift开关", Duration = 3})
print("死铁轨 加载完成")
