-- 活了7天 脚本 v4.7 稳定版
-- WindUI版 | 彻底修复传送 | 蓝莓斜前方 | 流畅透视

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
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")

local Settings = {
    ESP_Animal = false, ESP_Monster = false, ESP_Building = false, ESP_Scrap = false, ESP_Player = false,
    AutoScrap = false, AutoBerry = false,
    NightVision = false, WalkSpeed = 16,
}

local savedWaypoints = {}
local homePos = nil
local VERSION = "v4.7"

local VALID_KEY = "黑脚本牛逼666"
local scrapUnlocked = false
local keyPopup = nil

local animalNameMap = {
    ["moose"] = "驼鹿", ["boar"] = "野猪", ["bear"] = "熊", ["deer"] = "鹿", ["wolf"] = "狼",
    ["rabbit"] = "兔子", ["fox"] = "狐狸", ["chicken"] = "鸡", ["cow"] = "牛", ["pig"] = "猪",
    ["sheep"] = "羊", ["goat"] = "山羊", ["duck"] = "鸭子", ["squirrel"] = "松鼠", ["raccoon"] = "浣熊",
}
local animalNames = {}
for k, _ in pairs(animalNameMap) do table.insert(animalNames, k) end

local monsterNames = {"cat", "zombie", "monster", "enemy", "beast", "creature", "demon", "ghost", "skeleton", "goblin", "troll", "orc", "spider", "snake", "dragon", "boss", "mutant"}

local buildingNameMap = {
    ["beacon_house"] = "培根小屋", ["Minecart"] = "矿车", ["witch_house"] = "女巫小屋",
    ["lost_key_shack"] = "失钥棚屋", ["abandoned_shack"] = "废弃棚屋", ["orbital_blocker"] = "轨道阻挡器",
}

local function getPos()
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("HumanoidRootPart") then return c.HumanoidRootPart.Position end
    return nil
end

local function tp(pos)
    local c = LocalPlayer.Character
    if not c then return end
    local root = c:FindFirstChild("HumanoidRootPart")
    if not root then return end
    -- 只做基本的Y轴检查
    if pos.Y < -20 then return end
    if pos.Y > 5000 then return end
    root.CFrame = CFrame.new(pos)
end

local function clearAll()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "ESP_HL" or obj.Name == "ESP_Tag" then
            pcall(function() obj:Destroy() end)
        end
    end
end

local function isPlayerModel(model)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character == model then return true end
        if plr.Character and model:IsDescendantOf(plr.Character) then return true end
    end
    return false
end

local function classifyModel(model)
    local name = model.Name:lower()
    local hum = model:FindFirstChild("Humanoid")
    if not hum or hum.Health <= 0 then
        if name == "scrap" then return "scrap", "废料" end
        for key, label in pairs(buildingNameMap) do
            if model.Name == key then return "building", label end
        end
        return nil, nil
    end
    for aName, aLabel in pairs(animalNameMap) do if name == aName then return "animal", aLabel end end
    for _, aName in ipairs(animalNames) do if name:find(aName) then return "animal", animalNameMap[aName] or "动物" end end
    for _, mName in ipairs(monsterNames) do if name:find(mName) then return "monster", "怪物" end end
    return nil, nil
end

local function addESP(obj, objType, labelName, part)
    local color
    if objType == "animal" then color = Color3.fromRGB(255, 200, 50)
    elseif objType == "monster" then color = Color3.fromRGB(255, 80, 80)
    elseif objType == "building" then color = Color3.fromRGB(100, 200, 255)
    elseif objType == "scrap" then color = Color3.fromRGB(180, 180, 180)
    elseif objType == "player" then color = Color3.fromRGB(70, 255, 70)
    else return end
    
    local h = Instance.new("Highlight")
    h.Name = "ESP_HL"; h.FillColor = color; h.FillTransparency = 0.4
    h.OutlineColor = color; h.OutlineTransparency = 0.2
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; h.Parent = obj
    
    if part then
        local bg = Instance.new("BillboardGui")
        bg.Name = "ESP_Tag"; bg.Size = UDim2.new(0, 150, 0, 30)
        bg.AlwaysOnTop = true; bg.MaxDistance = math.huge; bg.Parent = part
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0); label.BackgroundTransparency = 1
        label.Text = labelName; label.TextColor3 = color
        label.Font = Enum.Font.GothamBold; label.TextSize = 14
        label.TextStrokeTransparency = 0.5; label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.Parent = bg
    end
end

local function scanEverything()
    for _, obj in pairs(workspace:GetDescendants()) do
        if not obj:IsA("Model") and not obj:IsA("BasePart") then continue end
        if isPlayerModel(obj) then continue end
        if obj:FindFirstChild("ESP_HL") then continue end
        local objType, labelName = classifyModel(obj)
        if not objType then continue end
        if objType == "animal" and not Settings.ESP_Animal then continue end
        if objType == "monster" and not Settings.ESP_Monster then continue end
        if objType == "building" and not Settings.ESP_Building then continue end
        if objType == "scrap" and not Settings.ESP_Scrap then continue end
        local part = obj:IsA("Model") and (obj:FindFirstChild("Head") or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart") or obj.PrimaryPart) or obj
        if part then addESP(obj, objType, labelName, part) end
    end
    if Settings.ESP_Player then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                if not plr.Character:FindFirstChild("ESP_HL") then
                    addESP(plr.Character, "player", plr.Name, plr.Character.Head)
                end
            end
        end
    end
end

local function showKeyPopup()
    if scrapUnlocked then return end
    if keyPopup then keyPopup.Enabled = true; return end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "KeyPopup"; gui.Parent = game:GetService("CoreGui"); gui.ResetOnSpawn = false
    keyPopup = gui
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 280, 0, 160); bg.Position = UDim2.new(0.5, -140, 0.5, -80)
    bg.BackgroundColor3 = Color3.fromRGB(25, 25, 35); bg.BorderSizePixel = 0; bg.ZIndex = 999; bg.Parent = gui
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 12)
    
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, 0, 0, 30); t.BackgroundTransparency = 1; t.Text = "🔐 验证卡密"
    t.TextColor3 = Color3.fromRGB(255,255,255); t.Font = Enum.Font.GothamBold; t.TextSize = 16; t.ZIndex = 1000; t.Parent = bg
    
    local ib = Instance.new("TextBox")
    ib.Size = UDim2.new(1, -30, 0, 36); ib.Position = UDim2.new(0, 15, 0, 40)
    ib.BackgroundColor3 = Color3.fromRGB(45, 45, 55); ib.Text = ""
    ib.PlaceholderText = "输入卡密..."; ib.PlaceholderColor3 = Color3.fromRGB(140,140,150)
    ib.TextColor3 = Color3.fromRGB(255,255,255); ib.Font = Enum.Font.GothamMedium; ib.TextSize = 14
    ib.BorderSizePixel = 0; ib.ZIndex = 1000; ib.Parent = bg
    Instance.new("UICorner", ib).CornerRadius = UDim.new(0, 8)
    
    local h = Instance.new("TextLabel")
    h.Size = UDim2.new(1, 0, 0, 18); h.Position = UDim2.new(0, 0, 0, 82)
    h.BackgroundTransparency = 1; h.Text = ""; h.TextColor3 = Color3.fromRGB(255,90,90)
    h.Font = Enum.Font.GothamMedium; h.TextSize = 11; h.ZIndex = 1000; h.Parent = bg
    
    local cb = Instance.new("TextButton")
    cb.Size = UDim2.new(1, -30, 0, 34); cb.Position = UDim2.new(0, 15, 0, 110)
    cb.BackgroundColor3 = Color3.fromRGB(70, 150, 255); cb.Text = "验证"
    cb.TextColor3 = Color3.fromRGB(255,255,255); cb.Font = Enum.Font.GothamBold; cb.TextSize = 14
    cb.BorderSizePixel = 0; cb.ZIndex = 1000; cb.Parent = bg
    Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 8)
    
    cb.MouseButton1Click:Connect(function()
        if ib.Text == VALID_KEY then
            scrapUnlocked = true; gui.Enabled = false
            WindUI:Notify({Title = "✅ 验证成功", Content = "已解锁！", Duration = 3})
        else h.Text = "❌ 卡密错误！" end
    end)
end

-- 收集目标（简单去重，不过滤）
local function getTargets(nameMatch)
    local targets = {}
    local usedPos = {}
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            if obj.Name:lower():find(nameMatch) then
                local part = obj:IsA("Model") and (obj:FindFirstChildWhichIsA("BasePart") or obj.PrimaryPart) or obj
                if part then
                    local pos = part.Position
                    if pos.Y < -100 then continue end
                    
                    local dup = false
                    for _, up in ipairs(usedPos) do
                        if (pos - up).Magnitude < 8 then dup = true; break end
                    end
                    if dup then continue end
                    
                    table.insert(targets, part)
                    table.insert(usedPos, pos)
                end
            end
        end
    end
    return targets
end

-- ==================== 捡废料 ====================
task.spawn(function()
    while true do
        if Settings.AutoScrap and scrapUnlocked then
            local targets = getTargets("^scrap$")  -- 精确匹配scrap
            for _, part in ipairs(targets) do
                if not Settings.AutoScrap then break end
                if part and part.Parent then
                    tp(part.Position + Vector3.new(0, 3, 0))
                    task.wait(0.15)
                    for i = 1, 3 do
                        if not Settings.AutoScrap then break end
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, nil)
                        task.wait(0.05)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, nil)
                        task.wait(0.05)
                    end
                end
            end
            Settings.AutoScrap = false
        end
        task.wait(0.5)
    end
end)

-- ==================== 捡蓝莓（斜前方位置） ====================
task.spawn(function()
    while true do
        if Settings.AutoBerry and scrapUnlocked then
            local targets = getTargets("berry")
            for _, part in ipairs(targets) do
                if not Settings.AutoBerry then break end
                if part and part.Parent then
                    -- 传送到蓝莓斜前方（偏移2格，方便点到）
                    local offsetPos = part.Position + Vector3.new(2, 3, -2)
                    tp(offsetPos)
                    task.wait(0.2)
                    local t = tick()
                    while tick() - t < 3 do
                        if not Settings.AutoBerry then break end
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, nil)
                        task.wait(0.08)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, nil)
                        task.wait(0.08)
                    end
                end
            end
            Settings.AutoBerry = false
        end
        task.wait(0.5)
    end
end)

task.spawn(function() while true do scanEverything(); task.wait(5) end end)

local function updateNightVision()
    if Settings.NightVision then
        Lighting.Brightness = 5; Lighting.ClockTime = 14
        Lighting.FogEnd = 10000; Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 180)
    else
        Lighting.Brightness = 1; Lighting.FogEnd = 100; Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
    end
end

local function loadFly()
    pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/飞饼"))() end)
end

local function setSpeed(s)
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = s end
end
RunService.Heartbeat:Connect(function() if Settings.WalkSpeed ~= 16 then setSpeed(Settings.WalkSpeed) end end)

local function getPlayerNames()
    local names = {}
    for _, plr in pairs(Players:GetPlayers()) do if plr ~= LocalPlayer then table.insert(names, plr.Name) end end
    if #names == 0 then table.insert(names, "无其他玩家") end
    return names
end

local Window = WindUI:CreateWindow({
    Title = "活了7天", Icon = "rbxassetid://129260712070622", IconThemed = true,
    Size = UDim2.fromOffset(400, 470), Theme = "冰白", Transparent = true,
})

Window:Tab({Title = "公告", Icon = "info"}):Paragraph({
    Title = "黑脚本--v4.7 Ultra",
    Desc = "废料精确匹配 | 精准强大无敌 | 流畅不卡",
})

local Tab1 = Window:Tab({Title = "主要", Icon = "play"})
Tab1:Toggle({Title = "透视动物", Value = false, Callback = function(v) Settings.ESP_Animal = v; scanEverything() end})
Tab1:Toggle({Title = "透视怪物", Value = false, Callback = function(v) Settings.ESP_Monster = v; scanEverything() end})
Tab1:Toggle({Title = "透视建筑", Value = false, Callback = function(v) Settings.ESP_Building = v; scanEverything() end})
Tab1:Toggle({Title = "透视废料", Value = false, Callback = function(v) Settings.ESP_Scrap = v; scanEverything() end})
Tab1:Toggle({Title = "夜视", Value = false, Callback = function(v) Settings.NightVision = v; updateNightVision() end})
Tab1:Divider()
Tab1:Toggle({Title = "自动捡废料", Value = false, Callback = function(v)
    if v and not scrapUnlocked then showKeyPopup(); Settings.AutoScrap = false; return end
    Settings.AutoScrap = v
end})
Tab1:Toggle({Title = "自动捡蓝莓", Value = false, Callback = function(v)
    if v and not scrapUnlocked then showKeyPopup(); Settings.AutoBerry = false; return end
    Settings.AutoBerry = v
end})

local Tab2 = Window:Tab({Title = "传送", Icon = "map-pin"})
Tab2:Button({Title = "定位家位置", Callback = function() local p = getPos() if p then homePos = p end end})
Tab2:Button({Title = "传送回家", Callback = function() if homePos then tp(homePos) end end})
Tab2:Divider()
local wpName = ""
Tab2:Input({Title = "定位名称", Value = "", Placeholder = "输入名称...", Callback = function(v) wpName = v end})
Tab2:Button({Title = "保存当前位置", Callback = function()
    if wpName == "" then return end
    local p = getPos() if p then savedWaypoints[wpName] = p; Tab2:Divider(); Tab2:Button({Title = "去 " .. wpName, Callback = function() tp(p) end}) end
end})
for name, pos in pairs(savedWaypoints) do Tab2:Divider(); Tab2:Button({Title = "去 " .. name, Callback = function() tp(pos) end}) end

local playerNames = getPlayerNames()
local selectedPlayer = playerNames[1] or "无其他玩家"
local Tab3 = Window:Tab({Title = "玩家", Icon = "users"})
Tab3:Toggle({Title = "透视玩家", Value = false, Callback = function(v) Settings.ESP_Player = v; scanEverything() end})
Tab3:Button({Title = "飞行", Callback = loadFly})
Tab3:Dropdown({Title = "选择玩家", Values = playerNames, Value = selectedPlayer, Callback = function(v) selectedPlayer = v end})
Tab3:Button({Title = "传送到该玩家", Callback = function() for _, plr in pairs(Players:GetPlayers()) do if plr.Name == selectedPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then tp(plr.Character.HumanoidRootPart.Position) end end end})
Tab3:Input({Title = "移动速度", Value = "16", Callback = function(v) local n = tonumber(v) if n and n >= 10 and n <= 50 then Settings.WalkSpeed = n end end})
Tab3:Button({Title = "重置速度", Callback = function() Settings.WalkSpeed = 16 end})

Window:Tab({Title = "设置", Icon = "settings"}):Button({Title = "关闭脚本", Callback = function() clearAll(); updateNightVision(); setSpeed(16); Window:Close() end})
Window:OnClose(function() clearAll(); updateNightVision(); setSpeed(16) end)

WindUI:Notify({Title = "活了7天", Content = VERSION .. " 加载完成", Duration = 3})
