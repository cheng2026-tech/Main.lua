-- 森林中的99夜 | V3.4 | 第一部分

local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Camera = Workspace.CurrentCamera

local HOME_POSITION = Vector3.new(10, 4, -0.4)
local MAX_ESP_DISTANCE = 5000

-- ==================== 变量 ====================
local nightVision = false
local nightVisionValue = 2

local forestEnabled = false
local forestPullLog, forestPullCoal, forestPullOil, forestPullBandage = false, false, false, false
local forestPullCarrot, forestPullBerry, forestPullCake, forestPullIron = false, false, false, false
local forestPullMicrowave, forestPullScrew, forestPullFan, forestPullTire = false, false, false, false
local forestPullRifle, forestPullRifleAmmo, forestPullLeatherBody = false, false, false
local forestPullBrokenMicrowave, forestPullFuelCanister = false, false
local collectRadius = 3.5

local forestExcludedNames = {"Workbench", "工作台", "Table", "Crafting"}
local forestOilKeywords = {"Barrel", "Oil", "桶", "油"}
local forestIronKeywords = {"Iron", "铁板", "铁", "Sheet", "Metal"}
local forestScrewKeywords = {"Screw", "螺丝", "钉", "Bolt"}

local speedEnabled = false
local speedValue = 20
local playerESP = false
local playerESPColor = Color3.fromRGB(255, 50, 50)

local bunnyESP, bunnyESPColor = false, Color3.fromRGB(255, 150, 200)
local wolfESP, wolfESPColor = false, Color3.fromRGB(180, 180, 180)
local alphaWolfESP, alphaWolfESPColor = false, Color3.fromRGB(200, 50, 50)
local bearESP, bearESPColor = false, Color3.fromRGB(139, 90, 43)
local chestESP, chestESPColor = false, Color3.fromRGB(255, 215, 0)
local stoneESP, stoneESPColor = false, Color3.fromRGB(200, 170, 120)
local berryESP, berryESPColor = false, Color3.fromRGB(100, 150, 255)
local childESP, childESPColor = false, Color3.fromRGB(255, 100, 100)
local showDistance = false

local nameRGBEnabled, nameRGBSpeed, unifiedRGB = false, 2, false
local tracerEnabled = false
local tracerColor = Color3.fromRGB(255, 255, 255)

local espCache, tracerCache, playerESPCache = {}, {}, {}
local selectedTeleportItem = nil
local selectedChildTeleport = nil
local ESP_UPDATE_INTERVAL = 0.5
local PULL_INTERVAL = 1.0

-- ==================== 辅助函数 ====================
local function GetRGBColor()
    return Color3.fromHSV((tick() * nameRGBSpeed) % 1, 1, 1)
end

local function GetNameColor(baseColor)
    if unifiedRGB or nameRGBEnabled then return GetRGBColor() end
    return baseColor
end

local function IsWithinDistance(pos)
    return (pos - HOME_POSITION).Magnitude <= MAX_ESP_DISTANCE
end

local function forestIsExcluded(obj)
    for _, name in ipairs(forestExcludedNames) do
        if string.find(obj.Name, name) then return true end
        if obj.Parent and string.find(obj.Parent.Name, name) then return true end
    end
    return false
end

local function forestIsOilBarrel(obj)
    for _, kw in ipairs(forestOilKeywords) do
        if string.find(obj.Name, kw) then return true end
    end
    return false
end

local function forestIsIronPlate(obj)
    for _, kw in ipairs(forestIronKeywords) do
        if string.find(obj.Name, kw) then return true end
    end
    return false
end

local function forestIsScrew(obj)
    for _, kw in ipairs(forestScrewKeywords) do
        if string.find(obj.Name, kw) then return true end
    end
    return false
end

-- ==================== 夜视（每帧刷新）====================
local function ApplyNightVision()
    pcall(function()
        if nightVision then
            Lighting.Brightness = nightVisionValue
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.ExposureCompensation = nightVisionValue - 1
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        else
            Lighting.Brightness = 2
            Lighting.ClockTime = 12
            Lighting.FogEnd = 500
            Lighting.ExposureCompensation = 0
            Lighting.Ambient = Color3.fromRGB(127, 127, 127)
            Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
        end
    end)
end

RunService.RenderStepped:Connect(function()
    if nightVision then ApplyNightVision() end
end)

-- ==================== 速度（每帧刷新）====================
RunService.RenderStepped:Connect(function()
    if speedEnabled then
        pcall(function()
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then
                c.Humanoid.WalkSpeed = speedValue
            end
        end)
    end
end)

-- ==================== 飞行 ====================
local function LoadFlyScript()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/飞饼"))()
    end)
    WI:Notify({Title = "飞行", Content = "飞行脚本已加载", Duration = 2})
end

-- ==================== 删除敌对生物 ====================
local function KillAllEnemies()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        WI:Notify({Title = "删除失败", Content = "角色不存在", Duration = 2})
        return
    end
    local hrp = char.HumanoidRootPart
    local killY = hrp.Position.Y + 10000
    local count = 0

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name == "Wolf" or obj.Name == "Bear" or obj.Name == "Alpha Wolf") then
            pcall(function()
                local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")
                if not root then
                    for _, c in ipairs(obj:GetDescendants()) do
                        if c:IsA("BasePart") then root = c; break end
                    end
                end
                if root then
                    if obj:IsA("Model") then
                        obj:MoveTo(Vector3.new(hrp.Position.X, killY, hrp.Position.Z))
                    else
                        root.CFrame = CFrame.new(hrp.Position.X, killY, hrp.Position.Z)
                    end
                    count = count + 1
                end
            end)
        end
    end
    WI:Notify({Title = "删除敌对生物", Content = "已删除 " .. count .. " 个生物", Duration = 2})
end

print("第一部分加载完成，请运行第二部分")
-- 森林中的99夜 | V3.4 | 第二部分

-- ==================== 吸取物品 ====================
local function forestPullItems()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local allItems, processed = {}, {}

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            if forestPullLog and obj.Name == "Log" and not processed[obj] and not forestIsExcluded(obj) then
                table.insert(allItems, obj); processed[obj] = true
            end
            if forestPullCoal and obj.Name == "Coal" and not processed[obj] and not forestIsExcluded(obj) then
                table.insert(allItems, obj); processed[obj] = true
            end
        end

        if obj:IsA("Model") and not processed[obj] and not obj:FindFirstChild("Humanoid") and not forestIsExcluded(obj) then
            local children = obj:GetChildren()
            local partCount, hasCap, hasMain, hasTie, hasHandle, hasPart, hasLeaf = 0, false, false, false, false, false, false
            local hasAttachPoint, hasBack, hasBase, hasGlass, hasStand = false, false, false, false, false
            local hasHead, hasMiddle, hasFans, hasRim, hasCenter = false, false, false, false, false

            for _, child in ipairs(children) do
                if child:IsA("BasePart") then
                    partCount = partCount + 1
                    local n = child.Name
                    if n == "Cap" then hasCap = true elseif n == "Main" then hasMain = true
                    elseif n == "Tie" then hasTie = true elseif n == "Handle" then hasHandle = true
                    elseif n == "Part" then hasPart = true elseif n == "Leaf" then hasLeaf = true
                    elseif n == "AttachPoint" then hasAttachPoint = true elseif n == "Back" then hasBack = true
                    elseif n == "Base" then hasBase = true elseif n == "Glass" then hasGlass = true
                    elseif n == "Stand" then hasStand = true elseif n == "Head" then hasHead = true
                    elseif n == "Middle" then hasMiddle = true elseif n == "Fans" then hasFans = true
                    elseif n == "Rim" then hasRim = true elseif n == "Center" then hasCenter = true
                    end
                end
            end

            local matched = false
            if forestPullOil and hasCap and hasMain and forestIsOilBarrel(obj) then matched = true
            elseif forestPullBandage and hasTie and hasHandle then matched = true
            elseif forestPullCarrot and hasPart and hasLeaf and hasHandle and not hasCap and not hasMain and not hasTie then matched = true
            elseif forestPullBerry and hasPart and hasHandle and not hasLeaf and not hasCap and not hasMain and not hasTie then matched = true
            elseif forestPullCake and hasHandle and partCount == 1 and not hasCap and not hasMain and not hasTie and not hasPart and not hasLeaf then matched = true
            elseif forestPullIron and hasMain and not hasCap and not hasTie and not hasHandle and not hasPart and not hasLeaf and forestIsIronPlate(obj) then matched = true
            elseif forestPullMicrowave and hasPart and hasMain and hasBack and hasBase and hasGlass and hasAttachPoint then matched = true
            elseif forestPullScrew and hasMain and not hasCap and not hasTie and not hasHandle and not hasPart and not hasLeaf and forestIsScrew(obj) then matched = true
            elseif forestPullFan and hasStand and hasMain and hasHead and hasMiddle and hasFans then matched = true
            elseif forestPullTire and hasRim and hasCenter and hasMain and hasPart then matched = true
            elseif forestPullRifle and obj.Name == "Rifle" then matched = true
            elseif forestPullRifleAmmo and obj.Name == "Rifle Ammo" then matched = true
            elseif forestPullLeatherBody and obj.Name == "Leather Body" then matched = true
            elseif forestPullBrokenMicrowave and obj.Name == "Broken Microwave" then matched = true
            elseif forestPullFuelCanister and obj.Name == "Fuel Canister" then matched = true
            end

            if matched then
                table.insert(allItems, obj); processed[obj] = true
            end
        end
    end

    local total = #allItems
    if total > 0 then
        local radius, groundY = collectRadius, hrp.Position.Y - 1.0
        local angleStep = (2 * math.pi) / total
        for i, obj in ipairs(allItems) do
            local angle = i * angleStep
            local tp = Vector3.new(hrp.Position.X + math.cos(angle) * radius, groundY, hrp.Position.Z + math.sin(angle) * radius)
            pcall(function()
                if obj:IsA("Model") then obj:MoveTo(tp) else obj.CFrame = CFrame.new(tp) end
            end)
        end
    end
end

task.spawn(function() while task.wait(PULL_INTERVAL) do if forestEnabled then forestPullItems() end end end)

-- ==================== ESP系统 ====================
local function ClearESP()
    for obj in pairs(espCache) do pcall(function() obj:Destroy() end) end; espCache = {}
    for _, line in ipairs(tracerCache) do pcall(function() line:Remove() end) end; tracerCache = {}
    for _, hl in ipairs(playerESPCache) do pcall(function() hl:Destroy() end) end; playerESPCache = {}
end

local function CreateESP(obj, color, displayName)
    local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head") or obj:FindFirstChild("Handle")
    if not root then for _, c in ipairs(obj:GetDescendants()) do if c:IsA("BasePart") then root = c; break end end end
    if not root then return end
    if not IsWithinDistance(root.Position) then return end

    local hl = Instance.new("Highlight")
    hl.FillColor, hl.FillTransparency, hl.OutlineColor = color, 0.5, color
    hl.Adornee, hl.DepthMode, hl.Parent = obj, Enum.HighlightDepthMode.AlwaysOnTop, obj
    espCache[hl] = true

    local bb = Instance.new("BillboardGui")
    bb.Size, bb.StudsOffset, bb.AlwaysOnTop, bb.Parent = UDim2.new(0, 200, 0, 40), Vector3.new(0, 3, 0), true, root
    espCache[bb] = true
    local lb = Instance.new("TextLabel")
    lb.Size, lb.BackgroundTransparency, lb.Text = UDim2.new(1, 0, 1, 0), 1, displayName
    lb.TextColor3, lb.TextStrokeTransparency, lb.TextStrokeColor3 = GetNameColor(color), 0, Color3.fromRGB(0, 0, 0)
    lb.Font, lb.TextSize, lb.Parent = Enum.Font.SourceSansBold, 18, bb

    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if showDistance and hrp then
        local db = Instance.new("BillboardGui")
        db.Size, db.StudsOffset, db.AlwaysOnTop, db.Parent = UDim2.new(0, 100, 0, 25), Vector3.new(0, 1.5, 0), true, root
        espCache[db] = true
        local dl = Instance.new("TextLabel")
        dl.Size, dl.BackgroundTransparency, dl.Text = UDim2.new(1, 0, 1, 0), 1, math.floor((hrp.Position - root.Position).Magnitude) .. "m"
        dl.TextColor3, dl.TextStrokeTransparency, dl.TextStrokeColor3 = Color3.fromRGB(255, 255, 255), 0, Color3.fromRGB(0, 0, 0)
        dl.Font, dl.TextSize, dl.Parent = Enum.Font.SourceSansBold, 14, db
    end

    if tracerEnabled and hrp then
        local sp, on = Camera:WorldToViewportPoint(root.Position)
        if on then
            local line = Drawing.new("Line")
            line.From, line.To = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y), Vector2.new(sp.X, sp.Y)
            line.Color, line.Thickness, line.Visible = tracerColor, 1, true
            table.insert(tracerCache, line)
        end
    end
end

local lastUpdate = 0
local function UpdateESP()
    if tick() - lastUpdate < ESP_UPDATE_INTERVAL then return end
    lastUpdate = tick()
    ClearESP()

    if playerESP then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                pcall(function()
                    local root = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character:FindFirstChild("Head")
                    if root and IsWithinDistance(root.Position) then
                        local hl = Instance.new("Highlight")
                        hl.FillColor, hl.FillTransparency, hl.OutlineColor = playerESPColor, 0.4, playerESPColor
                        hl.Adornee, hl.DepthMode, hl.Parent = plr.Character, Enum.HighlightDepthMode.AlwaysOnTop, plr.Character
                        table.insert(playerESPCache, hl)
                        local bb = Instance.new("BillboardGui")
                        bb.Size, bb.StudsOffset, bb.AlwaysOnTop, bb.Parent = UDim2.new(0, 200, 0, 40), Vector3.new(0, 3, 0), true, root
                        table.insert(playerESPCache, bb)
                        local lb = Instance.new("TextLabel")
                        lb.Size, lb.BackgroundTransparency, lb.Text = UDim2.new(1, 0, 1, 0), 1, plr.Name
                        lb.TextColor3, lb.TextStrokeTransparency, lb.TextStrokeColor3 = GetNameColor(playerESPColor), 0, Color3.fromRGB(0, 0, 0)
                        lb.Font, lb.TextSize, lb.Parent = Enum.Font.SourceSansBold, 18, bb
                    end
                end)
            end
        end
    end

    if not (bunnyESP or wolfESP or alphaWolfESP or bearESP or chestESP or stoneESP or berryESP or childESP) and not tracerEnabled then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if not obj:IsA("Model") then continue end
        pcall(function()
            local n = obj.Name
            if bunnyESP and n == "Bunny" then CreateESP(obj, bunnyESPColor, "兔子")
            elseif wolfESP and n == "Wolf" then CreateESP(obj, wolfESPColor, "狼")
            elseif alphaWolfESP and n == "Alpha Wolf" then CreateESP(obj, alphaWolfESPColor, "阿尔法狼")
            elseif bearESP and n == "Bear" then CreateESP(obj, bearESPColor, "熊")
            elseif chestESP and n == "ChestLid" then CreateESP(obj, chestESPColor, "宝箱")
            elseif stoneESP and n == "Stone" then CreateESP(obj, stoneESPColor, "宝藏土堆")
            elseif berryESP and n == "Berry" then CreateESP(obj, berryESPColor, "蓝莓")
            elseif childESP and string.find(n, "Lost Child") then CreateESP(obj, childESPColor, "小孩")
            end
        end)
    end
end

task.spawn(function() while task.wait(ESP_UPDATE_INTERVAL) do UpdateESP() end end)

-- ==================== 传送 ====================
local function TeleportToNearest(targetName, displayName)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp, closest, closestDist = char.HumanoidRootPart, nil, math.huge

    for _, obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            local match = false
            if obj:IsA("Model") then
                if obj.Name == targetName then match = true end
                if string.find(targetName, "Lost Child") and string.find(obj.Name, "Lost Child") and obj.Name == targetName then match = true end
            end
            if obj:IsA("BasePart") and obj.Name == targetName then match = true end

            if match then
                local root = nil
                if obj:IsA("Model") then
                    root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head") or obj:FindFirstChild("Handle")
                    if not root then for _, c in ipairs(obj:GetDescendants()) do if c:IsA("BasePart") then root = c; break end end end
                else root = obj end
                if root then
                    local d = (hrp.Position - root.Position).Magnitude
                    if d < closestDist then closestDist = d; closest = root end
                end
            end
        end)
    end

    if closest then
        pcall(function() hrp.CFrame = closest.CFrame * CFrame.new(0, 2, 0) end)
        WI:Notify({Title = "传送成功", Content = displayName, Duration = 2})
    else
        WI:Notify({Title = "传送失败", Content = "没找到" .. displayName, Duration = 3})
    end
end

-- ==================== 物品列表 ====================
local itemList = {"Log","Coal","Oil Barrel","Bandage","Carrot","Berry","Cake","Iron Plate","Microwave","Screw","Fan","Tire","Rifle","Rifle Ammo","Leather Body","Broken Microwave","Fuel Canister"}

local itemDisplayNames = {
    "🪵 木头 (Log)", "🪨 煤炭 (Coal)", "🛢️ 油桶 (Oil Barrel)", "🩹 绷带 (Bandage)",
    "🥕 胡萝卜 (Carrot)", "🫐 浆果 (Berry)", "🍰 蛋糕 (Cake)", "🔩 铁板 (Iron Plate)",
    "📡 微波炉 (Microwave)", "🔧 螺丝钉 (Screw)", "🌀 风扇 (Fan)", "🛞 轮胎 (Tire)",
    "🔫 步枪 (Rifle)", "💊 步枪弹药 (Rifle Ammo)", "🦺 皮革套 (Leather Body)",
    "💥 坏微波炉 (Broken Microwave)", "📮 邮箱 (Fuel Canister)"
}
local itemNameMap = {
    ["Log"]="木头",["Coal"]="煤炭",["Oil Barrel"]="油桶",["Bandage"]="绷带",
    ["Carrot"]="胡萝卜",["Berry"]="浆果",["Cake"]="蛋糕",["Iron Plate"]="铁板",
    ["Microwave"]="微波炉",["Screw"]="螺丝钉",["Fan"]="风扇",["Tire"]="轮胎",
    ["Rifle"]="步枪",["Rifle Ammo"]="步枪弹药",["Leather Body"]="皮革套",
    ["Broken Microwave"]="坏微波炉",["Fuel Canister"]="邮箱"
}

local childList = {"Lost Child1", "Lost Child2", "Lost Child3", "Lost Child4"}
local childDisplayNames = {"🧒 小孩一 (Lost Child1)", "🧒 小孩二 (Lost Child2)", "🧒 小孩三 (Lost Child3)", "🧒 小孩四 (Lost Child4)"}
local childNameMap = {["Lost Child1"]="小孩一", ["Lost Child2"]="小孩二", ["Lost Child3"]="小孩三", ["Lost Child4"]="小孩四"}

-- ==================== 主题 ====================
WI:AddTheme({Name = "冰白", Accent = "#80C0FF", Outline = "#6090C0", Text = "#FFFFFF", Placeholder = "#D0E0FF"})

-- ==================== UI ====================
local Window = WI:CreateWindow({
    Title = "黑脚本--森林中的99夜", Icon = "rbxassetid://129260712070622", IconThemed = true,
    Size = UDim2.fromOffset(520, 420), ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白", Transparent = true, ScrollBarEnabled = true
})

Window:Tab({Title = "公告", Icon = "info"}):Paragraph({Title = "黑脚本--森林中的99夜 V3.4", Desc = "速度/夜视实时刷新 | 透视阿尔法狼 | 删除敌对生物 | 中文菜单"})

local T2 = Window:Tab({Title = "主要功能", Icon = "settings"})
T2:Section({Title = "夜视"})
T2:Toggle({Title = "开启夜视", Value = false, Callback = function(v)
    nightVision = v
    if not v then ApplyNightVision() end
end})
T2:Slider({Title = "亮度", Value = {Min = 1, Max = 5, Default = 2}, Step = 0.5, Callback = function(v) nightVisionValue = v end})

T2:Section({Title = "物品吸附"})
T2:Toggle({Title = "开启吸附总开关", Value = false, Callback = function(v) forestEnabled = v end})
T2:Slider({Title = "光环半径", Value = {Min = 1, Max = 10, Default = 3.5}, Step = 0.5, Callback = function(v) collectRadius = v end})
T2:Dropdown({Title = "选择要吸附的物品（可多选）", Values = itemDisplayNames, Value = {}, Multi = true, AllowNone = true, Callback = function(v)
    forestPullLog,forestPullCoal,forestPullOil,forestPullBandage = false,false,false,false
    forestPullCarrot,forestPullBerry,forestPullCake,forestPullIron = false,false,false,false
    forestPullMicrowave,forestPullScrew,forestPullFan,forestPullTire = false,false,false,false
    forestPullRifle,forestPullRifleAmmo,forestPullLeatherBody = false,false,false
    forestPullBrokenMicrowave,forestPullFuelCanister = false,false
    for _,item in ipairs(v) do
        if string.find(item, "Log)") then forestPullLog=true
        elseif string.find(item, "Coal)") then forestPullCoal=true
        elseif string.find(item, "Oil Barrel)") then forestPullOil=true
        elseif string.find(item, "Bandage)") then forestPullBandage=true
        elseif string.find(item, "Carrot)") then forestPullCarrot=true
        elseif string.find(item, "Berry)") then forestPullBerry=true
        elseif string.find(item, "Cake)") then forestPullCake=true
        elseif string.find(item, "Iron Plate)") then forestPullIron=true
        elseif string.find(item, "Microwave)") and not string.find(item, "Broken") then forestPullMicrowave=true
        elseif string.find(item, "Screw)") then forestPullScrew=true
        elseif string.find(item, "Fan)") then forestPullFan=true
        elseif string.find(item, "Tire)") then forestPullTire=true
        elseif string.find(item, "Rifle)") then forestPullRifle=true
        elseif string.find(item, "Rifle Ammo)") then forestPullRifleAmmo=true
        elseif string.find(item, "Leather Body)") then forestPullLeatherBody=true
        elseif string.find(item, "Broken Microwave)") then forestPullBrokenMicrowave=true
        elseif string.find(item, "Fuel Canister)") then forestPullFuelCanister=true
        end
    end
end})

T2:Section({Title = "⚠️ 测试功能"})
T2:Button({Title = "🗑️ 删除所有敌对生物", Justify = "Center", Color = Color3.fromRGB(255, 60, 60), Callback = KillAllEnemies})

local T3 = Window:Tab({Title = "玩家", Icon = "user"})
T3:Section({Title = "移动速度"})
T3:Toggle({Title = "可调移速", Value = false, Callback = function(v)
    speedEnabled = v
    if not v then pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = 16 end) end
end})
T3:Slider({Title = "移速数值", Value = {Min = 16, Max = 100, Default = 20}, Step = 1, Callback = function(v) speedValue = v end})
T3:Section({Title = "飞行"})
T3:Button({Title = "加载飞行脚本", Justify = "Center", Color = Color3.fromRGB(100, 200, 255), Callback = LoadFlyScript})
T3:Section({Title = "玩家透视"})
T3:Toggle({Title = "透视所有玩家", Value = false, Callback = function(v) playerESP = v end})
T3:Colorpicker({Title = "玩家透视颜色", Default = Color3.fromRGB(255, 50, 50), Callback = function(c) playerESPColor = c end})

local T4 = Window:Tab({Title = "传送", Icon = "map"})
T4:Section({Title = "传送到指定物品"})
T4:Dropdown({Title = "选择物品", Values = itemDisplayNames, Value = "", Multi = false, AllowNone = true, Callback = function(v)
    if type(v)=="string" and v~="" then
        for _,itemName in ipairs(itemList) do if string.find(v, itemName) then selectedTeleportItem = itemName; break end end
    else selectedTeleportItem = nil end
end})
T4:Button({Title = "传送到该物品", Justify = "Center", Color = Color3.fromRGB(255, 140, 0), Callback = function()
    if selectedTeleportItem then TeleportToNearest(selectedTeleportItem, itemNameMap[selectedTeleportItem] or selectedTeleportItem)
    else WI:Notify({Title = "传送失败", Content = "请先选择物品", Duration = 2}) end
end})
T4:Section({Title = "传送到指定小孩"})
T4:Dropdown({Title = "选择小孩", Values = childDisplayNames, Value = "", Multi = false, AllowNone = true, Callback = function(v)
    if type(v)=="string" and v~="" then
        for _,childName in ipairs(childList) do if string.find(v, childName) then selectedChildTeleport = childName; break end end
    else selectedChildTeleport = nil end
end})
T4:Button({Title = "传送到该小孩", Justify = "Center", Color = Color3.fromRGB(255, 100, 100), Callback = function()
    if selectedChildTeleport then TeleportToNearest(selectedChildTeleport, childNameMap[selectedChildTeleport] or selectedChildTeleport)
    else WI:Notify({Title = "传送失败", Content = "请先选择小孩", Duration = 2}) end
end})
T4:Section({Title = "快捷传送"})
T4:Button({Title = "传送回家", Justify = "Center", Color = Color3.fromRGB(80, 192, 255), Callback = function()
    local c = LocalPlayer.Character; if c and c:FindFirstChild("HumanoidRootPart") then c.HumanoidRootPart.CFrame = CFrame.new(10, 4, -0.4); WI:Notify({Title = "传送成功", Content = "已回家", Duration = 2}) end
end})
T4:Button({Title = "传送到最近宝箱", Justify = "Center", Color = Color3.fromRGB(255, 215, 0), Callback = function() TeleportToNearest("ChestLid", "宝箱") end})
T4:Button({Title = "传送到最近蓝莓", Justify = "Center", Color = Color3.fromRGB(100, 150, 255), Callback = function() TeleportToNearest("Berry", "蓝莓") end})

local T5 = Window:Tab({Title = "透视", Icon = "eye"})
T5:Section({Title = "RGB设置"})
T5:Toggle({Title = "统一RGB", Value = false, Callback = function(v) unifiedRGB = v end})
T5:Toggle({Title = "名字RGB", Value = false, Callback = function(v) nameRGBEnabled = v end})
T5:Slider({Title = "RGB速度", Value = {Min = 0.5, Max = 5, Default = 2}, Step = 0.5, Callback = function(v) nameRGBSpeed = v end})
T5:Section({Title = "射线"})
T5:Toggle({Title = "开启射线", Value = false, Callback = function(v) tracerEnabled = v end})
T5:Colorpicker({Title = "射线颜色", Default = Color3.fromRGB(255, 255, 255), Callback = function(c) tracerColor = c end})
T5:Section({Title = "动物"})
T5:Toggle({Title = "透视兔子", Value = false, Callback = function(v) bunnyESP = v end})
T5:Colorpicker({Title = "兔子颜色", Default = Color3.fromRGB(255, 150, 200), Callback = function(c) bunnyESPColor = c end})
T5:Toggle({Title = "透视狼", Value = false, Callback = function(v) wolfESP = v end})
T5:Colorpicker({Title = "狼颜色", Default = Color3.fromRGB(180, 180, 180), Callback = function(c) wolfESPColor = c end})
T5:Toggle({Title = "透视阿尔法狼", Value = false, Callback = function(v) alphaWolfESP = v end})
T5:Colorpicker({Title = "阿尔法狼颜色", Default = Color3.fromRGB(200, 50, 50), Callback = function(c) alphaWolfESPColor = c end})
T5:Toggle({Title = "透视熊", Value = false, Callback = function(v) bearESP = v end})
T5:Colorpicker({Title = "熊颜色", Default = Color3.fromRGB(139, 90, 43), Callback = function(c) bearESPColor = c end})
T5:Section({Title = "物品"})
T5:Toggle({Title = "透视宝箱", Value = false, Callback = function(v) chestESP = v end})
T5:Colorpicker({Title = "宝箱颜色", Default = Color3.fromRGB(255, 215, 0), Callback = function(c) chestESPColor = c end})
T5:Toggle({Title = "透视宝藏土堆", Value = false, Callback = function(v) stoneESP = v end})
T5:Colorpicker({Title = "土堆颜色", Default = Color3.fromRGB(200, 170, 120), Callback = function(c) stoneESPColor = c end})
T5:Toggle({Title = "透视蓝莓", Value = false, Callback = function(v) berryESP = v end})
T5:Colorpicker({Title = "蓝莓颜色", Default = Color3.fromRGB(100, 150, 255), Callback = function(c) berryESPColor = c end})
T5:Section({Title = "小孩"})
T5:Toggle({Title = "透视小孩", Value = false, Callback = function(v) childESP = v end})
T5:Colorpicker({Title = "小孩颜色", Default = Color3.fromRGB(255, 100, 100), Callback = function(c) childESPColor = c end})
T5:Toggle({Title = "显示距离", Value = false, Callback = function(v) showDistance = v end})

local T6 = Window:Tab({Title = "设置", Icon = "settings"})
T6:Paragraph({Title = "黑脚本--森林中的99夜 V3.4", Desc = "速度/夜视每帧刷新 | 面板关闭不重置"})
T6:Button({Title = "关闭界面", Callback = function() Window:Close() end})

Window:OnClose(function()
    ClearESP()
end)

WI:Notify({Title = "森林中的99夜", Content = "V3.4 加载完成", Duration = 3})
print("森林中的99夜 V3.4 加载完成")
