-- 住宅大屠杀 脚本 v1.3.0
-- WindUI蓝白版 | 透视怪物 | 夜视 | 自动补充燃料

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
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local espMonster = false
local nightVision = false
local autoRefuel = false
local espObjects = {}
local nightEffect = nil
local nightActive = false
local refuelStartPos = nil

local function isPlayer(model)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character == model then return true end
    end
    return false
end

local function isMonster(model)
    if not model or not model:IsA("Model") then return false end
    if isPlayer(model) then return false end
    local name = model.Name:lower()
    if name:find("mutant") or name:find("monster") then
        return true
    end
    return false
end

local function getRoot(model)
    return model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
end

local function addESP(obj, color, label)
    if not obj or not obj.Parent then return end
    if espObjects[obj] then return end
    
    local root = getRoot(obj)
    if not root then return end
    
    local box = Instance.new("SelectionBox")
    box.Adornee = obj
    box.Color3 = color
    box.LineThickness = 0.1
    box.Transparency = 0.5
    box.Parent = obj
    
    local bg = Instance.new("BillboardGui")
    bg.Size = UDim2.new(0, 200, 0, 40)
    bg.AlwaysOnTop = true
    bg.MaxDistance = math.huge
    bg.Parent = root
    
    local labelGui = Instance.new("TextLabel")
    labelGui.Size = UDim2.new(1, 0, 1, 0)
    labelGui.BackgroundTransparency = 1
    labelGui.Text = label
    labelGui.TextColor3 = color
    labelGui.Font = Enum.Font.GothamBold
    labelGui.TextSize = 14
    labelGui.TextStrokeTransparency = 0.5
    labelGui.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    labelGui.Parent = bg
    
    espObjects[obj] = {H = box, B = bg}
end

local function scanAndAdd()
    if not espMonster then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local myPos = hrp.Position
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and isMonster(obj) then
            local root = getRoot(obj)
            if root then
                local d = (myPos - root.Position).Magnitude
                if d <= 1000 then
                    addESP(obj, Color3.fromRGB(255, 0, 0), obj.Name)
                end
            end
        end
    end
end

local function updateNightVision()
    if nightVision and not nightActive then
        if not nightEffect then
            nightEffect = Instance.new("ColorCorrectionEffect")
            nightEffect.Name = "NightVisionEffect"
            nightEffect.Brightness = 0.05
            nightEffect.Contrast = 0.05
            nightEffect.Saturation = -0.1
            nightEffect.TintColor = Color3.fromRGB(200, 230, 200)
            nightEffect.Parent = Lighting
        end
        Lighting.Brightness = 1.5
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(120, 140, 120)
        Lighting.OutdoorAmbient = Color3.fromRGB(120, 140, 120)
        nightActive = true
    elseif not nightVision and nightActive then
        if nightEffect then
            nightEffect:Destroy()
            nightEffect = nil
        end
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
        nightActive = false
    end
end

local function fireClick()
    pcall(function()
        local vim = game:GetService("VirtualInputManager")
        local center = workspace.CurrentCamera.ViewportSize / 2
        vim:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 1)
        task.wait(0.05)
        vim:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 1)
    end)
end

local refuelRunning = false

local function doAutoRefuel()
    if refuelRunning then return end
    refuelRunning = true
    
    local char = LocalPlayer.Character
    if not char then refuelRunning = false return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then refuelRunning = false return end
    
    if not refuelStartPos then
        refuelStartPos = hrp.CFrame
    end
    
    hrp.CFrame = CFrame.new(Vector3.new(-77.2, 4.7, -128.6) + Vector3.new(0, 2, 0))
    task.wait(1)
    fireClick()
    task.wait(0.3)
    fireClick()
    task.wait(1)
    
    hrp.CFrame = CFrame.new(Vector3.new(-80.8, 4.7, -136.5) + Vector3.new(0, 2, 0))
    task.wait(1)
    fireClick()
    task.wait(0.3)
    fireClick()
    task.wait(1)
    
    refuelRunning = false
end

local function returnToStart()
    if refuelStartPos then
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = refuelStartPos
            end
        end
        refuelStartPos = nil
    end
end

local lastScan = 0
local lastRefuel = 0
RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - lastScan >= 2 then
        lastScan = now
        pcall(scanAndAdd)
        pcall(updateNightVision)
    end
    if autoRefuel and not refuelRunning and now - lastRefuel >= 8 then
        lastRefuel = now
        task.spawn(doAutoRefuel)
    end
end)

local Window = WindUI:CreateWindow({
    Title = "住宅大屠杀",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(600, 350),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true,
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑--住宅大屠杀 v1.3.0",
    Desc = "功能：透视怪物 | 夜视 | 自动补充燃料"
})

local MainTab = Window:Tab({Title = "主要功能", Icon = "solar:star-bold"})

MainTab:Toggle({
    Title = "透视怪物",
    Value = false,
    Callback = function(v) espMonster = v end
})

MainTab:Divider()

MainTab:Toggle({
    Title = "夜视",
    Value = false,
    Callback = function(v) nightVision = v end
})

MainTab:Divider()

MainTab:Toggle({
    Title = "自动补充燃料",
    Desc = "仅适配第一夜",
    Value = false,
    Callback = function(v)
        autoRefuel = v
        if not v then returnToStart() end
    end
})

local SettingsTab = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})
local statusPara = SettingsTab:Paragraph({Title = "功能状态", Desc = "加载中..."})

local lastStatus = 0
RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - lastStatus >= 1 then
        lastStatus = now
        local status = ""
        status = status .. "透视怪物: " .. (espMonster and "✅" or "❌") .. "\n"
        status = status .. "夜视: " .. (nightVision and "✅" or "❌") .. "\n"
        status = status .. "自动补充燃料: " .. (autoRefuel and "✅" or "❌")
        pcall(function() statusPara:SetDesc(status) end)
    end
end)

SettingsTab:Button({
    Title = "关闭面板",
    Callback = function() Window:Close() end
})

Window:OnClose(function()
    espMonster = false
    nightVision = false
    autoRefuel = false
    returnToStart()
end)

WindUI:Notify({
    Title = "住宅大屠杀",
    Content = "v1.3.0 加载完成",
    Duration = 3
})
