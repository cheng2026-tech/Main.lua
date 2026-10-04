local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
if not WindUI then return end

local function RainbowText(text)
    local result = ""
    local length = #text
    local speed = tick() * 2
    for i = 1, length do
        local hue = (i / length + speed) % 1
        local r, g, b = Color3.fromHSV(hue, 1, 1):ToRGB()
        local char = text:sub(i, i)
        result = result .. '<font color="rgb(' .. math.floor(r*255) .. ',' .. math.floor(g*255) .. ',' .. math.floor(b*255) .. ')">' .. char .. '</font>'
    end
    return result
end

WindUI:AddTheme({
    Name = "冰白",
    Accent = "#80C0FF",
    Outline = "#6090C0",
    Text = "#FFFFFF",
    Placeholder = "#D0E0FF",
})

local Window = WindUI:CreateWindow({
    Title = "通用FPS脚本",
    Icon = "rbxassetid://129260712070622",
    IconThemed = true,
    Size = UDim2.fromOffset(620, 400),
    Theme = "冰白",
    Transparent = true,
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ==================== 变量 ====================
local AimbotEnabled = false
local AimbotFOV = 100
local AimbotSmoothness = 5
local AimbotTargetPart = "Head"
local AimbotCircleEnabled = false
local AimbotWallCheck = true
local AimbotVisibleOnly = true

local FOVColorMode = "自定义"
local FOVCustomColor = Color3.fromRGB(128, 192, 255)

local ESPEnabled = false
local ESPShowName = true
local ESPShowDistance = true
local ESPShowHealth = true
local ESPStyle = "高亮"
local ESPColorMode = "自定义"
local ESPCustomColor = Color3.fromRGB(255, 255, 255)
local ESPMaxDistance = 1000

local NameColorMode = "自定义"
local NameCustomColor = Color3.fromRGB(255, 255, 255)

local UnifiedRGB = false
local UnifiedRGBSpeed = 2

local TracerEnabled = false
local TracerColorMode = "自定义"
local TracerCustomColor = Color3.fromRGB(255, 255, 255)

local Highlights = {}
local ESPTexts = {}

-- ==================== 统一RGB颜色 ====================
local function GetUnifiedRGBColor()
    local hue = (tick() * UnifiedRGBSpeed) % 1
    return Color3.fromHSV(hue, 1, 1)
end

local function GetFOVColor()
    if UnifiedRGB then return GetUnifiedRGBColor() end
    if FOVColorMode == "彩虹RGB" then return GetUnifiedRGBColor() end
    return FOVCustomColor
end

local function GetESPColor()
    if UnifiedRGB then return GetUnifiedRGBColor() end
    if ESPColorMode == "彩虹RGB" then return GetUnifiedRGBColor() end
    return ESPCustomColor
end

local function GetNameColor()
    if UnifiedRGB then return GetUnifiedRGBColor() end
    if NameColorMode == "彩虹RGB" then return GetUnifiedRGBColor() end
    return NameCustomColor
end

local function GetTracerColor()
    if UnifiedRGB then return GetUnifiedRGBColor() end
    if TracerColorMode == "彩虹RGB" then return GetUnifiedRGBColor() end
    return TracerCustomColor
end

-- ==================== 可见性检测 ====================
local function IsVisible(targetPosition)
    local origin = Camera.CFrame.Position
    local direction = (targetPosition - origin).Unit
    local distance = (targetPosition - origin).Magnitude
    
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character or {}}
    
    local result = workspace:Raycast(origin, direction * distance, rayParams)
    
    if result then
        local hitChar = result.Instance:FindFirstAncestorOfClass("Model")
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character == hitChar and plr.Character:FindFirstChild("HumanoidRootPart") then
                return true
            end
        end
        return false
    end
    return true
end

-- ==================== 自瞄 ====================
local function GetBestTarget()
    local visibleTargets = {}
    local hiddenTargets = {}
    local viewportSize = Camera.ViewportSize
    local center = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char then continue end
        
        local hum = char:FindFirstChild("Humanoid")
        local target = char:FindFirstChild(AimbotTargetPart)
        if not hum or hum.Health <= 0 or not target then continue end
        
        local sp, onScreen = Camera:WorldToViewportPoint(target.Position)
        if not onScreen then continue end
        
        local dist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
        if dist > AimbotFOV then continue end
        
        local visible = IsVisible(target.Position)
        
        if visible then
            table.insert(visibleTargets, {player = plr, distance = dist})
        else
            table.insert(hiddenTargets, {player = plr, distance = dist})
        end
    end
    
    table.sort(visibleTargets, function(a, b) return a.distance < b.distance end)
    table.sort(hiddenTargets, function(a, b) return a.distance < b.distance end)
    
    if AimbotWallCheck and not AimbotVisibleOnly then
        return (visibleTargets[1] and visibleTargets[1].player) or (hiddenTargets[1] and hiddenTargets[1].player) or nil
    else
        return visibleTargets[1] and visibleTargets[1].player or nil
    end
end

-- ==================== FOV圈 ====================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 2
FOVCircle.Transparency = 0.5
FOVCircle.Filled = false

-- ==================== ESP绘制对象 ====================
local function CreateESPTexts(player)
    local texts = {}
    
    local nameTag = Drawing.new("Text")
    nameTag.Size = 14
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.OutlineColor = Color3.fromRGB(0, 0, 0)
    texts.NameTag = nameTag
    
    local distTag = Drawing.new("Text")
    distTag.Size = 13
    distTag.Center = true
    distTag.Outline = true
    distTag.OutlineColor = Color3.fromRGB(0, 0, 0)
    texts.DistTag = distTag
    
    local healthBar = Drawing.new("Line")
    healthBar.Thickness = 3
    texts.HealthBar = healthBar
    
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Filled = false
    texts.Box = box
    
    local tracer = Drawing.new("Line")
    tracer.Thickness = 1
    texts.Tracer = tracer
    
    ESPTexts[player] = texts
    return texts
end

local function RemoveESP(player)
    if ESPTexts[player] then
        for _, obj in pairs(ESPTexts[player]) do
            pcall(function() obj:Remove() end)
        end
        ESPTexts[player] = nil
    end
    if Highlights[player] then
        pcall(function() Highlights[player]:Destroy() end)
        Highlights[player] = nil
    end
end

-- ==================== 主循环 ====================
RunService.RenderStepped:Connect(function()
    local viewportSize = Camera.ViewportSize
    local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    
    -- FOV圈
    FOVCircle.Visible = AimbotCircleEnabled and AimbotEnabled
    FOVCircle.Position = screenCenter
    FOVCircle.Radius = AimbotFOV
    FOVCircle.Color = GetFOVColor()
    
    -- 自瞄
    if AimbotEnabled then
        local target = GetBestTarget()
        if target and target.Character then
            local tp = target.Character:FindFirstChild(AimbotTargetPart)
            if tp then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, tp.Position), AimbotSmoothness / 10)
            end
        end
    end
    
    -- 透视
    if ESPEnabled then
        local espColor = GetESPColor()
        local nameColor = GetNameColor()
        local tracerColor = GetTracerColor()
        local screenBottom = Vector2.new(viewportSize.X / 2, viewportSize.Y)
        
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LocalPlayer then continue end
            
            local char = plr.Character
            if not char then
                if ESPTexts[plr] then
                    for _, obj in pairs(ESPTexts[plr]) do obj.Visible = false end
                end
                if Highlights[plr] then Highlights[plr].Enabled = false end
                continue
            end
            
            local hum = char:FindFirstChild("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            
            if not hum or hum.Health <= 0 or not root then
                if ESPTexts[plr] then
                    for _, obj in pairs(ESPTexts[plr]) do obj.Visible = false end
                end
                if Highlights[plr] then Highlights[plr].Enabled = false end
                continue
            end
            
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local distance = myRoot and (myRoot.Position - root.Position).Magnitude or 0
            local tooFar = (distance > ESPMaxDistance)
            
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            
            if tooFar or not onScreen then
                if Highlights[plr] then Highlights[plr].Enabled = false end
                if ESPTexts[plr] then
                    ESPTexts[plr].Box.Visible = false
                    ESPTexts[plr].HealthBar.Visible = false
                    ESPTexts[plr].Tracer.Visible = false
                    if ESPShowName then
                        ESPTexts[plr].NameTag.Visible = true
                        ESPTexts[plr].NameTag.Text = plr.Name
                        ESPTexts[plr].NameTag.Position = Vector2.new(pos.X, pos.Y - 35)
                        ESPTexts[plr].NameTag.Color = nameColor
                    else
                        ESPTexts[plr].NameTag.Visible = false
                    end
                    if ESPShowDistance then
                        ESPTexts[plr].DistTag.Visible = true
                        ESPTexts[plr].DistTag.Text = string.format("%.0fm", distance)
                        ESPTexts[plr].DistTag.Position = Vector2.new(pos.X, pos.Y - 20)
                    else
                        ESPTexts[plr].DistTag.Visible = false
                    end
                end
                continue
            end
            
            if not ESPTexts[plr] then CreateESPTexts(plr) end
            local texts = ESPTexts[plr]
            
            if ESPShowName then
                texts.NameTag.Visible = true
                texts.NameTag.Text = plr.Name
                texts.NameTag.Position = Vector2.new(pos.X, pos.Y - 35)
                texts.NameTag.Color = nameColor
            else
                texts.NameTag.Visible = false
            end
            
            if ESPShowDistance then
                texts.DistTag.Visible = true
                texts.DistTag.Text = string.format("%.0fm", distance)
                texts.DistTag.Position = Vector2.new(pos.X, pos.Y - 20)
            else
                texts.DistTag.Visible = false
            end
            
            if ESPShowHealth then
                texts.HealthBar.Visible = true
                local hp = hum.Health / hum.MaxHealth
                local barLen = 40
                texts.HealthBar.From = Vector2.new(pos.X - barLen/2, pos.Y + 15)
                texts.HealthBar.To = Vector2.new(pos.X - barLen/2 + barLen * hp, pos.Y + 15)
                if hp > 0.5 then
                    texts.HealthBar.Color = Color3.fromRGB(0, 255, 0)
                elseif hp > 0.25 then
                    texts.HealthBar.Color = Color3.fromRGB(255, 255, 0)
                else
                    texts.HealthBar.Color = Color3.fromRGB(255, 0, 0)
                end
            else
                texts.HealthBar.Visible = false
            end
            
            if ESPStyle == "高亮" then
                texts.Box.Visible = false
                if not Highlights[plr] then
                    local hl = Instance.new("Highlight")
                    hl.Name = "ESPHighlight"
                    hl.FillTransparency = 0.5
                    hl.OutlineTransparency = 0
                    hl.Parent = char
                    Highlights[plr] = hl
                end
                Highlights[plr].Enabled = true
                Highlights[plr].FillColor = espColor
                Highlights[plr].OutlineColor = espColor
            elseif ESPStyle == "2D框" then
                if Highlights[plr] then Highlights[plr].Enabled = false end
                texts.Box.Visible = true
                local size = Vector2.new(2000 / pos.Z, 4000 / pos.Z)
                texts.Box.Size = size
                texts.Box.Position = Vector2.new(pos.X - size.X/2, pos.Y - size.Y/2)
                texts.Box.Color = espColor
            elseif ESPStyle == "3D框" then
                if Highlights[plr] then Highlights[plr].Enabled = false end
                texts.Box.Visible = true
                local size = Vector2.new(2000 / pos.Z, 4000 / pos.Z)
                texts.Box.Size = size
                texts.Box.Position = Vector2.new(pos.X - size.X/2, pos.Y - size.Y/2)
                texts.Box.Color = espColor
            end
            
            if TracerEnabled then
                texts.Tracer.Visible = true
                texts.Tracer.From = screenBottom
                texts.Tracer.To = Vector2.new(pos.X, pos.Y + 20)
                texts.Tracer.Color = tracerColor
            else
                texts.Tracer.Visible = false
            end
        end
    else
        for plr, _ in pairs(ESPTexts) do
            RemoveESP(plr)
        end
    end
end)

-- ==================== 玩家事件 ====================
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(0.3)
        if ESPEnabled then
            RemoveESP(plr)
            CreateESPTexts(plr)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(plr)
    RemoveESP(plr)
end)

-- ==================== 窗口变化监听 ====================
local lastViewportSize = Camera.ViewportSize
RunService.Heartbeat:Connect(function()
    local currentSize = Camera.ViewportSize
    if currentSize ~= lastViewportSize then
        lastViewportSize = currentSize
        if ESPEnabled then
            for plr, _ in pairs(ESPTexts) do
                RemoveESP(plr)
            end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    CreateESPTexts(plr)
                end
            end
        end
    end
end)

-- ==================== UI创建 ====================
local MainSection = Window:Section({Title = "通用FPS脚本", Opened = true})

-- 公告
local Tab1 = MainSection:Tab({Title = "公告", Icon = "info"})
Tab1:Paragraph({Title = "黑脚本--通用FPS", Desc = "自瞄 | 透视 | 射线 | 穿墙检测"})
Tab1:Paragraph({Title = "功能说明", Desc = "主要：自瞄设置、FOV圈\n其余功能：透视、射线、RGB颜色\n设置：关于脚本"})

-- 主要（自瞄）
local Tab2 = MainSection:Tab({Title = "主要", Icon = "crosshair"})
Tab2:Section({Title = "自瞄设置"})
Tab2:Toggle({Title = "开启自瞄", Value = false, Callback = function(v) AimbotEnabled = v end})
Tab2:Slider({Title = "平滑度", Value = {Min = 1, Max = 10, Default = 5}, Callback = function(v) AimbotSmoothness = v end})
Tab2:Slider({Title = "FOV圈大小", Value = {Min = 50, Max = 500, Default = 100}, Callback = function(v) AimbotFOV = v end})
Tab2:Dropdown({Title = "自瞄部位", Values = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, Value = "Head", Callback = function(v) AimbotTargetPart = v end})
Tab2:Toggle({Title = "穿墙自瞄（关闭=不瞄墙后）", Value = false, Callback = function(v) AimbotWallCheck = not v end})
Tab2:Toggle({Title = "优先可见目标", Value = true, Callback = function(v) AimbotVisibleOnly = v end})

Tab2:Section({Title = "FOV圈设置"})
Tab2:Toggle({Title = "显示FOV圈", Value = false, Callback = function(v) AimbotCircleEnabled = v end})
Tab2:Dropdown({Title = "FOV颜色模式", Values = {"自定义", "彩虹RGB"}, Value = "自定义", Callback = function(v) FOVColorMode = v end})
Tab2:Colorpicker({Title = "FOV自定义颜色", Default = Color3.fromRGB(128, 192, 255), Callback = function(c) FOVCustomColor = c end})

-- 其余功能（透视）
local Tab3 = MainSection:Tab({Title = "其余功能", Icon = "eye"})

Tab3:Section({Title = "统一RGB设置"})
Tab3:Toggle({Title = "统一RGB（所有颜色同步）", Value = false, Callback = function(v) UnifiedRGB = v end})
Tab3:Slider({Title = "统一RGB速度", Value = {Min = 0.5, Max = 5, Default = 2}, Step = 0.5, Callback = function(v) UnifiedRGBSpeed = v end})

Tab3:Section({Title = "透视设置"})
Tab3:Toggle({Title = "开启透视", Value = false, Callback = function(v)
    ESPEnabled = v
    if not v then for plr, _ in pairs(ESPTexts) do RemoveESP(plr) end end
end})
Tab3:Toggle({Title = "显示名字", Value = true, Callback = function(v) ESPShowName = v end})
Tab3:Toggle({Title = "显示距离", Value = true, Callback = function(v) ESPShowDistance = v end})
Tab3:Toggle({Title = "显示血量", Value = true, Callback = function(v) ESPShowHealth = v end})
Tab3:Slider({Title = "最大透视距离", Value = {Min = 100, Max = 5000, Default = 1000}, Callback = function(v) ESPMaxDistance = v end})
Tab3:Dropdown({Title = "透视样式", Values = {"高亮", "2D框", "3D框"}, Value = "高亮", Callback = function(v) ESPStyle = v end})

Tab3:Section({Title = "透视颜色"})
Tab3:Dropdown({Title = "高亮/框颜色模式", Values = {"自定义", "彩虹RGB"}, Value = "自定义", Callback = function(v) ESPColorMode = v end})
Tab3:Colorpicker({Title = "高亮/框自定义颜色", Default = Color3.fromRGB(255, 255, 255), Callback = function(c) ESPCustomColor = c end})

Tab3:Section({Title = "名字颜色"})
Tab3:Dropdown({Title = "名字颜色模式", Values = {"自定义", "彩虹RGB"}, Value = "自定义", Callback = function(v) NameColorMode = v end})
Tab3:Colorpicker({Title = "名字自定义颜色", Default = Color3.fromRGB(255, 255, 255), Callback = function(c) NameCustomColor = c end})

Tab3:Section({Title = "射线设置"})
Tab3:Toggle({Title = "开启射线", Value = false, Callback = function(v) TracerEnabled = v end})
Tab3:Dropdown({Title = "射线颜色模式", Values = {"自定义", "彩虹RGB"}, Value = "自定义", Callback = function(v) TracerColorMode = v end})
Tab3:Colorpicker({Title = "射线自定义颜色", Default = Color3.fromRGB(255, 255, 255), Callback = function(c) TracerCustomColor = c end})

-- 设置
local Tab4 = MainSection:Tab({Title = "设置", Icon = "settings"})
Tab4:Paragraph({Title = "通用FPS脚本", Desc = "v2.0.0 | WindUI | 冰白主题"})
Tab4:Paragraph({Title = "功能列表", Desc = "✅ 自瞄优先可见\n✅ 穿墙检测\n✅ 统一RGB模式\n✅ 名字独立RGB\n✅ 2D/3D框透视\n✅ 射线追踪"})
Tab4:Button({Title = "关闭界面", Callback = function() Window:Close() end})

Window:SelectTab(1)

Window:OnClose(function()
    for plr, _ in pairs(ESPTexts) do
        RemoveESP(plr)
    end
    ESPTexts = {}
    Highlights = {}
end)

WindUI:Notify({Title = "通用FPS脚本", Content = "加载完成！", Duration = 3})
