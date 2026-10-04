-- 🌙 超级商店生存 | V1.0

local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

-- 变量
local employeeESP = false
local employeeESPColor = Color3.fromRGB(255, 200, 50)
local employeeESPRange = 500

local foodESP = false
local foodESPColor = Color3.fromRGB(50, 255, 50)
local foodESPRange = 500

local nightVision = false
local nightVisionBrightness = 0.15

local speedBoost = false
local speedValue = 50

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
                if nightEffect then nightEffect:Destroy(); nightEffect = nil end
                Lighting.Brightness = 1; Lighting.FogEnd = 500; Lighting.GlobalShadows = true
            end)
        end
        task.wait(0.3)
    end
end)

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

-- ==================== ESP系统 ====================
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

    -- 员工透视
    if employeeESP then
        local employeeNames = {"Employee", "BuffEmployee"}
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") then
                for _, empName in ipairs(employeeNames) do
                    if obj.Name == empName then
                        local root = getRoot(obj)
                        if root then
                            local d = (hrp.Position - root.Position).Magnitude
                            if d <= employeeESPRange then
                                CreateESP(obj, employeeESPColor, empName, math.floor(d))
                            end
                        end
                        break
                    end
                end
            end
        end
    end

    -- 食物透视
    if foodESP then
        local foodNames = {"Hotdog", "Burger", "Cola"}
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") then
                for _, foodName in ipairs(foodNames) do
                    if obj.Name == foodName then
                        local root = getRoot(obj)
                        if root then
                            local d = (hrp.Position - root.Position).Magnitude
                            if d <= foodESPRange then
                                CreateESP(obj, foodESPColor, foodName, math.floor(d))
                            end
                        end
                        break
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

-- ==================== UI ====================
local Window = WI:CreateWindow({
    Title = "超级商店生存",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(500, 380),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--超级商店生存 V1.0",
    Desc = "透视员工/BuffEmployee | 透视食物\n夜视 | 速度 | 飞行"
})

local T2 = Window:Tab({Title = "主要功能", Icon = "solar:star-bold"})
T2:Section({Title = "夜视"})
T2:Toggle({Title = "开启夜视", Value = false, Callback = function(v) nightVision = v end})
T2:Slider({Title = "夜视亮度", Value = {Min = 0.05, Max = 0.5, Default = 0.15}, Step = 0.01, Callback = function(v) nightVisionBrightness = v end})

T2:Section({Title = "透视员工"})
T2:Toggle({Title = "透视员工", Value = false, Callback = function(v) employeeESP = v end})
T2:Colorpicker({Title = "员工颜色", Default = Color3.fromRGB(255, 200, 50), Callback = function(c) employeeESPColor = c end})
T2:Slider({Title = "透视范围", Value = {Min = 0, Max = 10000, Default = 500}, Step = 10, Callback = function(v) employeeESPRange = v end})

T2:Section({Title = "透视食物"})
T2:Toggle({Title = "透视食物", Value = false, Callback = function(v) foodESP = v end})
T2:Colorpicker({Title = "食物颜色", Default = Color3.fromRGB(50, 255, 50), Callback = function(c) foodESPColor = c end})
T2:Slider({Title = "透视范围", Value = {Min = 0, Max = 10000, Default = 500}, Step = 10, Callback = function(v) foodESPRange = v end})

local T3 = Window:Tab({Title = "玩家", Icon = "solar:user-bold"})
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
    ClearESP()
end)

WI:Notify({Title = "🌙 超级商店生存", Content = "V1.0 加载完成", Duration = 3})
print("🌙 超级商店生存 V1.0 加载完成")
