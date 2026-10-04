-- 被遗弃 脚本 v1.5
-- WindUI版 | 自动循环调速 | 飞行 | 去雾+夜视
local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

local Settings = {
    ESP_Generator = false,
    ESP_Survivor = false,
    ESP_Killer = false,
    NoFog = false,
    NightVision = false,
    WalkSpeed = 16,
}

local VERSION = "v1.5"
local stopAll = false
local espObjects = {}

-- ==================== 队伍检测 ====================
local function getTeam(player)
    local char = player.Character
    if not char then return "Unknown" end
    if player.Team then
        local tn = player.Team.Name:lower()
        if tn:find("killer") or tn:find("beast") or tn:find("monster") or tn:find("hunter") then return "Killer" end
        if tn:find("survivor") or tn:find("escape") or tn:find("runner") then return "Survivor" end
    end
    if player.TeamColor then
        local tc = player.TeamColor
        if tc == BrickColor.new("Really red") or tc == BrickColor.new("Bright red") then return "Killer" end
        if tc == BrickColor.new("Bright blue") or tc == BrickColor.new("Bright green") then return "Survivor" end
    end
    local hum = char:FindFirstChild("Humanoid")
    if hum and (hum.MaxHealth > 100 or hum.WalkSpeed > 25) then return "Killer" end
    for _, child in pairs(char:GetDescendants()) do
        if child:IsA("StringValue") then
            local v = child.Value:lower()
            if v:find("killer") then return "Killer" end
            if v:find("survivor") then return "Survivor" end
        end
    end
    for _, item in pairs(char:GetChildren()) do
        if item:IsA("Tool") then
            local n = item.Name:lower()
            if n:find("knife") or n:find("axe") or n:find("weapon") or n:find("claw") then return "Killer" end
        end
    end
    return "Unknown"
end

-- ==================== 清理ESP ====================
local function clearAllESP()
    for _, data in pairs(espObjects) do
        if data.highlight then pcall(function() data.highlight:Destroy() end) end
        if data.tag then pcall(function() data.tag:Destroy() end) end
    end
    table.clear(espObjects)
end

-- ==================== 创建标签 ====================
local function createTag(model, name, color)
    local part = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart") or model.PrimaryPart
    if not part then return nil end
    local bg = Instance.new("BillboardGui")
    bg.Size = UDim2.new(0, 150, 0, 25)
    bg.AlwaysOnTop = true
    bg.MaxDistance = 500
    bg.Parent = part
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = color
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextStrokeTransparency = 0.5
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.Parent = bg
    return bg
end

-- ==================== 添加ESP ====================
local function addESP(model, category, color, labelName)
    local id = model:GetFullName()
    if espObjects[id] then return end
    for eid, data in pairs(espObjects) do
        if data.category == category then
            local dist = (model:GetPivot().Position - data.model:GetPivot().Position).Magnitude
            if dist < 10 then return end
        end
    end
    local h = Instance.new("Highlight")
    h.FillColor = color; h.FillTransparency = 0.4; h.OutlineColor = color; h.OutlineTransparency = 0.2
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; h.Parent = model
    local tag = createTag(model, labelName, color)
    espObjects[id] = {highlight = h, tag = tag, model = model, category = category}
end

-- ==================== 扫描 ====================
local function scanAll()
    local c = LocalPlayer.Character
    local root = c and c:FindFirstChild("HumanoidRootPart")
    if Settings.ESP_Generator then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name:lower():find("generator") then
                if root and (root.Position - obj:GetPivot().Position).Magnitude <= 500 then
                    addESP(obj, "generator", Color3.fromRGB(255, 200, 50), "发电机")
                end
            end
        end
    end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char or not char:FindFirstChild("Head") then continue end
        local team = getTeam(plr)
        local labelName = team .. " " .. plr.Name
        if team == "Survivor" and Settings.ESP_Survivor then addESP(char, "survivor", Color3.fromRGB(70, 200, 70), labelName) end
        if team == "Killer" and Settings.ESP_Killer then addESP(char, "killer", Color3.fromRGB(255, 80, 80), labelName) end
    end
end

local function fullRebuild() clearAllESP(); scanAll() end
task.spawn(function() while true do task.wait(5) if not stopAll then fullRebuild() end end end)
workspace.DescendantAdded:Connect(function(obj) if obj:IsA("Model") and obj.Name:lower():find("generator") and Settings.ESP_Generator then addESP(obj, "generator", Color3.fromRGB(255, 200, 50), "发电机") end end)

-- ==================== 去雾/夜视 ====================
local function updateFog() Lighting.FogEnd = Settings.NoFog and 10000 or 100; Lighting.FogStart = Settings.NoFog and 5000 or 0 end
local function updateNightVision() Lighting.Brightness = Settings.NightVision and 3 or 1; Lighting.ClockTime = Settings.NightVision and 14 or 0; Lighting.OutdoorAmbient = Settings.NightVision and Color3.fromRGB(100, 100, 120) or Color3.fromRGB(0, 0, 0) end

-- ==================== 循环调速（自动） ====================
local function setSpeed(s)
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = s end
end

task.spawn(function()
    while true do
        if Settings.WalkSpeed ~= 16 then
            setSpeed(Settings.WalkSpeed)
        end
        task.wait(0.05)  -- 每0.05秒设置一次，防止被拉回
    end
end)

-- ==================== 飞行 ====================
local function loadFly()
    pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/飞饼"))() end)
end

-- ==================== UI ====================
local Win = WI:CreateWindow({Title = "被遗弃", Icon = "solar:ghost-bold", Size = UDim2.fromOffset(400, 440), Acrylic = true})
Win:Tab({Title = "公告", Icon = "solar:home-bold"}):Paragraph({Title = "黑脚本--功能说明", Desc = "调速自动循环不拉回\n透视发电机(黄)500米\n透视幸存者(绿)杀手(红)\n去雾|夜视|飞行\n\n版本：" .. VERSION})
local t1 = Win:Tab({Title = "主要", Icon = "solar:play-bold"})
t1:Toggle({Title = "透视发电机", Value = false, Callback = function(v) Settings.ESP_Generator = v fullRebuild() end})
t1:Divider()
t1:Toggle({Title = "去雾", Value = false, Callback = function(v) Settings.NoFog = v updateFog() end})
t1:Divider()
t1:Toggle({Title = "夜视", Value = false, Callback = function(v) Settings.NightVision = v updateNightVision() end})
t1:Divider()
t1:Button({Title = "点击开启飞行", Justify = "Center", Color = Color3.fromHex("#03A9F4"), Callback = loadFly})
t1:Divider()
t1:Input({Title = "移动速度", Value = "16", Callback = function(v) local n = tonumber(v) if n and n >= 0 and n <= 100 then Settings.WalkSpeed = n end end})
t1:Divider()
t1:Button({Title = "重置速度", Justify = "Center", Color = Color3.fromHex("#888888"), Callback = function() Settings.WalkSpeed = 16 setSpeed(16) end})
local t2 = Win:Tab({Title = "幸存者", Icon = "solar:user-check-bold"})
t2:Toggle({Title = "透视杀手", Value = false, Callback = function(v) Settings.ESP_Killer = v fullRebuild() end})
local t3 = Win:Tab({Title = "杀手", Icon = "solar:user-cross-bold"})
t3:Toggle({Title = "透视幸存者", Value = false, Callback = function(v) Settings.ESP_Survivor = v fullRebuild() end})
Win:Tab({Title = "设置", Icon = "solar:settings-bold"}):Button({Title = "关闭脚本", Justify = "Center", Color = Color3.fromHex("#ff4444"), Callback = function() stopAll = true for k, _ in pairs(Settings) do if type(Settings[k]) == "boolean" then Settings[k] = false end end Settings.WalkSpeed = 16 updateFog() updateNightVision() clearAllESP() setSpeed(16) pcall(function() local g = game:GetService("CoreGui"):FindFirstChild("WindUI") if g then g:Destroy() end end) end})
WI:Notify({Title = "被遗弃", Content = VERSION .. " 加载完成", Duration = 5})
