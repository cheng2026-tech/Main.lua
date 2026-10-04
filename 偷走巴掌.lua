-- 耳光大战 · 手套透视
-- WindUI蓝白版

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

local espEnabled = true
local espTags = {}
local priceFilter = 0
local baseEspEnabled = false
local baseTags = {}

-- ===== 踏板相关 =====
local platformEnabled = false      -- 功能开关
local platformPart = nil           -- 当前踏板
local platformGui = nil            -- 原生按钮 GUI
local platformBtn = nil            -- 原生按钮
local platformActive = false       -- 踏板是否已放下

local function formatPrice(price)
    local n = tonumber(price) or 0
    if n >= 100000000 then
        return string.format("%.1f亿", n / 100000000)
    elseif n >= 10000 then
        return string.format("%.1f万", n / 10000)
    else
        return tostring(n)
    end
end

local function formatTime(sec)
    sec = tonumber(sec) or 0
    if sec <= 0 then return "0秒" end
    local h = math.floor(sec / 3600)
    local m = math.floor((sec % 3600) / 60)
    local s = math.floor(sec % 60)
    if h > 0 then
        return string.format("%d时%d分%d秒", h, m, s)
    elseif m > 0 then
        return string.format("%d分%d秒", m, s)
    else
        return string.format("%d秒", s)
    end
end

local function createTag(glove)
    if espTags[glove] then return end

    local price = tonumber(glove:GetAttribute("Price")) or 0
    local weight = tonumber(glove:GetAttribute("Weight")) or 0

    local color = Color3.fromRGB(200, 200, 200)
    if price >= 10000000 then
        color = Color3.fromRGB(255, 50, 255)
    elseif price >= 1000000 then
        color = Color3.fromRGB(255, 215, 0)
    elseif price >= 100000 then
        color = Color3.fromRGB(255, 100, 100)
    elseif price >= 10000 then
        color = Color3.fromRGB(255, 150, 50)
    elseif price >= 1000 then
        color = Color3.fromRGB(100, 200, 255)
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "GloveESP"
    billboard.Size = UDim2.new(0, 180, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 1000
    billboard.Parent = glove

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = glove.Name
    nameLabel.TextColor3 = color
    nameLabel.TextSize = 18
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center
    nameLabel.Parent = billboard

    local priceLabel = Instance.new("TextLabel")
    priceLabel.Size = UDim2.new(1, 0, 0, 16)
    priceLabel.Position = UDim2.new(0, 0, 0, 20)
    priceLabel.BackgroundTransparency = 1
    priceLabel.Text = "💰 " .. formatPrice(price)
    priceLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
    priceLabel.TextSize = 14
    priceLabel.Font = Enum.Font.GothamBold
    priceLabel.TextStrokeTransparency = 0.3
    priceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    priceLabel.TextXAlignment = Enum.TextXAlignment.Center
    priceLabel.Parent = billboard

    local weightLabel = Instance.new("TextLabel")
    weightLabel.Size = UDim2.new(1, 0, 0, 14)
    weightLabel.Position = UDim2.new(0, 0, 0, 36)
    weightLabel.BackgroundTransparency = 1
    weightLabel.Text = "⚖ " .. tostring(weight)
    weightLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    weightLabel.TextSize = 12
    weightLabel.Font = Enum.Font.Gotham
    weightLabel.TextStrokeTransparency = 0.3
    weightLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    weightLabel.TextXAlignment = Enum.TextXAlignment.Center
    weightLabel.Parent = billboard

    espTags[glove] = {
        billboard = billboard,
        nameLabel = nameLabel,
        priceLabel = priceLabel,
        weightLabel = weightLabel,
    }
end

local function updateTag(glove)
    local tag = espTags[glove]
    if not tag then return end

    local price = tonumber(glove:GetAttribute("Price")) or 0
    local weight = tonumber(glove:GetAttribute("Weight")) or 0

    local color = Color3.fromRGB(200, 200, 200)
    if price >= 10000000 then
        color = Color3.fromRGB(255, 50, 255)
    elseif price >= 1000000 then
        color = Color3.fromRGB(255, 215, 0)
    elseif price >= 100000 then
        color = Color3.fromRGB(255, 100, 100)
    elseif price >= 10000 then
        color = Color3.fromRGB(255, 150, 50)
    elseif price >= 1000 then
        color = Color3.fromRGB(100, 200, 255)
    end

    tag.nameLabel.Text = glove.Name
    tag.nameLabel.TextColor3 = color
    tag.priceLabel.Text = "💰 " .. formatPrice(price)
    tag.weightLabel.Text = "⚖ " .. tostring(weight)
end

local function removeTag(glove)
    if espTags[glove] then
        espTags[glove].billboard:Destroy()
        espTags[glove] = nil
    end
end

local function shouldShow(glove)
    local price = tonumber(glove:GetAttribute("Price")) or 0
    return price >= priceFilter
end

local function scanGloves()
    local found = {}

    local gloveLine = workspace:FindFirstChild("GloveLine")
    if gloveLine then
        for _, obj in pairs(gloveLine:GetChildren()) do
            if obj:IsA("Model") or obj:IsA("BasePart") then
                if shouldShow(obj) then
                    found[obj] = true
                    if not espTags[obj] then
                        createTag(obj)
                    else
                        updateTag(obj)
                    end
                end
            end
        end
    end

    local gloves = workspace:FindFirstChild("Gloves")
    if gloves then
        for _, obj in pairs(gloves:GetChildren()) do
            if obj:IsA("Model") or obj:IsA("BasePart") then
                if shouldShow(obj) then
                    found[obj] = true
                    if not espTags[obj] then
                        createTag(obj)
                    else
                        updateTag(obj)
                    end
                end
            end
        end
    end

    local plots = workspace:FindFirstChild("Plots")
    if plots then
        for _, plot in pairs(plots:GetChildren()) do
            for _, obj in pairs(plot:GetDescendants()) do
                if (obj:IsA("Model") or obj:IsA("BasePart")) and obj:GetAttribute("Price") then
                    if shouldShow(obj) then
                        found[obj] = true
                        if not espTags[obj] then
                            createTag(obj)
                        else
                            updateTag(obj)
                        end
                    end
                end
            end
        end
    end

    for glove, _ in pairs(espTags) do
        if not found[glove] or not glove.Parent then
            removeTag(glove)
        end
    end
end

local function createBaseTag(plot)
    if baseTags[plot] then return end

    local lockTimer = tonumber(plot:GetAttribute("LockTimer")) or 0
    local cps = tonumber(plot:GetAttribute("CPS")) or 0
    local owner = plot.Name

    if owner == "Vacant" then
        return
    end

    local overhead = plot:FindFirstChild("BaseOverhead") or plot:FindFirstChild("PlotPoint") or plot:FindFirstChild("PlotIdentifier")
    local attachPart = overhead or plot:FindFirstChildWhichIsA("BasePart")
    if not attachPart then
        for _, child in pairs(plot:GetDescendants()) do
            if child:IsA("BasePart") then
                attachPart = child
                break
            end
        end
    end
    if not attachPart then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "BaseESP"
    billboard.Size = UDim2.new(0, 220, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 8, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 5000
    billboard.Parent = attachPart

    local ownerLabel = Instance.new("TextLabel")
    ownerLabel.Size = UDim2.new(1, 0, 0, 20)
    ownerLabel.Position = UDim2.new(0, 0, 0, 0)
    ownerLabel.BackgroundTransparency = 1
    ownerLabel.Text = "🏠 " .. owner
    ownerLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    ownerLabel.TextSize = 16
    ownerLabel.Font = Enum.Font.GothamBold
    ownerLabel.TextStrokeTransparency = 0.3
    ownerLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    ownerLabel.Parent = billboard

    local timeLabel = Instance.new("TextLabel")
    timeLabel.Size = UDim2.new(1, 0, 0, 18)
    timeLabel.Position = UDim2.new(0, 0, 0, 20)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = "⏱ " .. formatTime(lockTimer)
    timeLabel.TextColor3 = lockTimer > 0 and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(100, 255, 100)
    timeLabel.TextSize = 14
    timeLabel.Font = Enum.Font.GothamBold
    timeLabel.TextStrokeTransparency = 0.3
    timeLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    timeLabel.Parent = billboard

    local stateLabel = Instance.new("TextLabel")
    stateLabel.Size = UDim2.new(1, 0, 0, 16)
    stateLabel.Position = UDim2.new(0, 0, 0, 38)
    stateLabel.BackgroundTransparency = 1
    stateLabel.Text = "💰 " .. formatPrice(cps) .. "/秒"
    stateLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
    stateLabel.TextSize = 13
    stateLabel.Font = Enum.Font.GothamBold
    stateLabel.TextStrokeTransparency = 0.3
    stateLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    stateLabel.Parent = billboard

    baseTags[plot] = {
        billboard = billboard,
        ownerLabel = ownerLabel,
        timeLabel = timeLabel,
        stateLabel = stateLabel,
    }
end

local function updateBaseTag(plot)
    local tag = baseTags[plot]
    if not tag then return end

    local lockTimer = tonumber(plot:GetAttribute("LockTimer")) or 0
    local cps = tonumber(plot:GetAttribute("CPS")) or 0
    local owner = plot.Name

    tag.ownerLabel.Text = "🏠 " .. owner
    tag.timeLabel.Text = "⏱ " .. formatTime(lockTimer)
    tag.timeLabel.TextColor3 = lockTimer > 0 and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(100, 255, 100)
    tag.stateLabel.Text = "💰 " .. formatPrice(cps) .. "/秒"
end

local function removeBaseTag(plot)
    if baseTags[plot] then
        baseTags[plot].billboard:Destroy()
        baseTags[plot] = nil
    end
end

local function scanBases()
    if not baseEspEnabled then
        for base, _ in pairs(baseTags) do removeBaseTag(base) end
        return
    end

    local found = {}

    local plots = workspace:FindFirstChild("Plots")
    if plots then
        for _, plot in pairs(plots:GetChildren()) do
            if plot:IsA("Model") and plot.Name ~= "Vacant" then
                found[plot] = true
                if not baseTags[plot] then
                    createBaseTag(plot)
                else
                    updateBaseTag(plot)
                end
            end
        end
    end

    for base, _ in pairs(baseTags) do
        if not found[base] or not base.Parent then
            removeBaseTag(base)
        end
    end
end

-- ===== 踏板功能 =====
local function removePlatform()
    if platformPart then
        pcall(function() platformPart:Destroy() end)
        platformPart = nil
    end
    platformActive = false
end

local function createPlatform()
    removePlatform()

    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local pos = hrp.Position - Vector3.new(0, 3, 0)

    local part = Instance.new("Part")
    part.Name = "WindPlatform"
    part.Size = Vector3.new(6, 1, 6)
    part.Position = pos
    part.Anchored = true
    part.CanCollide = true
    part.Material = Enum.Material.Neon
    part.Color = Color3.fromRGB(128, 192, 255)
    part.Transparency = 0.2
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Parent = workspace

    platformPart = part
    platformActive = true
end

local function togglePlatform()
    if platformActive then
        removePlatform()
    else
        createPlatform()
    end
    -- 更新按钮文字
    if platformBtn then
        platformBtn.Text = platformActive and "收起踏板" or "放下踏板"
    end
end

local function createPlatformGui()
    if platformGui then return end

    local gui = Instance.new("ScreenGui")
    gui.Name = "WindPlatformGui"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local btn = Instance.new("TextButton")
    btn.Name = "PlatformBtn"
    btn.Size = UDim2.new(0, 130, 0, 40)
    btn.Position = UDim2.new(0, 20, 0.5, -20)
    btn.BackgroundColor3 = Color3.fromRGB(128, 192, 255)
    btn.BackgroundTransparency = 0.1
    btn.Text = "放下踏板"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 16
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = true
    btn.Visible = false

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(96, 144, 192)
    stroke.Thickness = 1.5
    stroke.Parent = btn

    btn.MouseButton1Click:Connect(togglePlatform)

    btn.Parent = gui

    platformGui = gui
    platformBtn = btn
end

local function setPlatformEnabled(enabled)
    platformEnabled = enabled
    createPlatformGui()
    if platformBtn then
        platformBtn.Visible = enabled
    end
    if not enabled then
        removePlatform()
        if platformBtn then
            platformBtn.Text = "放下踏板"
        end
    end
end

-- 角色重生时自动收起踏板，防止残留
LocalPlayer.CharacterAdded:Connect(function()
    removePlatform()
    if platformBtn then
        platformBtn.Text = "放下踏板"
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if espEnabled then
            pcall(scanGloves)
        end
        pcall(scanBases)
    end
end)

local Window = WindUI:CreateWindow({
    Title = "耳光大战",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(600, 350),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true,
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--手套透视 v1.0.4",
    Desc = "功能：手套透视 | 基地解锁时间 | 价格过滤 | 踏板"
})

local MainTab = Window:Tab({Title = "主要功能", Icon = "solar:star-bold"})

MainTab:Toggle({
    Title = "手套透视",
    Value = true,
    Callback = function(v)
        espEnabled = v
        if not v then
            for glove, _ in pairs(espTags) do removeTag(glove) end
        end
    end
})

MainTab:Input({
    Title = "最低价格过滤",
    Placeholder = "0 = 显示全部",
    Value = "0",
    Callback = function(v)
        local num = tonumber(v)
        if num then
            priceFilter = num
            for glove, _ in pairs(espTags) do removeTag(glove) end
            scanGloves()
        end
    end
})

MainTab:Divider()

MainTab:Toggle({
    Title = "透视基地解锁时间",
    Desc = "显示所有者 / 解锁倒计时 / CPS",
    Value = false,
    Callback = function(v)
        baseEspEnabled = v
        if not v then
            for base, _ in pairs(baseTags) do removeBaseTag(base) end
        end
    end
})

MainTab:Divider()

MainTab:Toggle({
    Title = "踏板",
    Desc = "开启后屏幕左侧出现按钮，点击放下/收起踏板",
    Value = false,
    Callback = function(v)
        setPlatformEnabled(v)
    end
})

local SettingsTab = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})
local statusPara = SettingsTab:Paragraph({Title = "功能状态", Desc = "加载中..."})

task.spawn(function()
    while true do
        task.wait(1)
        local gloveCount = 0
        for _ in pairs(espTags) do gloveCount = gloveCount + 1 end
        local baseCount = 0
        for _ in pairs(baseTags) do baseCount = baseCount + 1 end
        statusPara:SetDesc(
            "显示手套: " .. gloveCount .. "\n" ..
            "显示基地: " .. baseCount .. "\n" ..
            "过滤价格: ≥" .. formatPrice(priceFilter) .. "\n" ..
            "踏板: " .. (platformActive and "✅ 已放下" or (platformEnabled and "⏸ 未放下" or "❌"))
        )
    end
end)

SettingsTab:Button({
    Title = "关闭面板",
    Callback = function() Window:Close() end
})

WindUI:Notify({
    Title = "耳光大战",
    Content = "v1.0.4 加载完成",
    Duration = 3
})
