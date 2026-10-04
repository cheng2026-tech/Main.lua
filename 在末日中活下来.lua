-- 在末日中活下来 脚本 v3.7
-- WindUI蓝白版 | 透视物品/僵尸+爬虫/宝箱/玩家 | 坐标加速 | 智能杀戮光环

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
local Lighting = game:GetService("Lighting")

local Settings = {
    ESP_Items = false, ESP_Items_Dist = false, ESP_Zombie = false,
    ESP_Default = false, ESP_Players = false,
    NoFog = false, NightVision = false,
    SpeedBoost = false, SpeedValue = 5, NoClip = false,
    AutoGo = false, GoTarget = "废料",
    KillAura = false, KillRange = 30,
    AutoHome = false,
}

local VERSION = "v3.7"
local stopAll = false
local homePos = Vector3.new(0.7, 3.2, -8)

local itemNames = {
    ["scrap"] = {cn = "废料", color = Color3.fromRGB(180, 180, 180)},
    ["fuel"] = {cn = "燃料", color = Color3.fromRGB(255, 150, 50)},
    ["battery"] = {cn = "电池", color = Color3.fromRGB(255, 255, 50)},
    ["bloxiade"] = {cn = "运动饮料", color = Color3.fromRGB(50, 200, 255)},
    ["long ammo"] = {cn = "长弹药", color = Color3.fromRGB(255, 200, 50)},
    ["screws"] = {cn = "螺丝", color = Color3.fromRGB(150, 150, 150)},
    ["pistol"] = {cn = "手枪", color = Color3.fromRGB(255, 100, 50)},
    ["pistol ammo"] = {cn = "手枪弹药", color = Color3.fromRGB(255, 150, 100)},
    ["shells"] = {cn = "弹壳", color = Color3.fromRGB(200, 180, 50)},
    ["spatula"] = {cn = "锅铲", color = Color3.fromRGB(200, 200, 200)},
    ["beans"] = {cn = "豆子罐头", color = Color3.fromRGB(150, 200, 50)},
    ["bloxy cola"] = {cn = "可乐", color = Color3.fromRGB(255, 50, 50)},
    ["chips"] = {cn = "薯片", color = Color3.fromRGB(255, 200, 100)},
    ["bandage"] = {cn = "绷带", color = Color3.fromRGB(255, 255, 255)},
}

local function getPos()
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("HumanoidRootPart") then return c.HumanoidRootPart.Position end
    return nil
end

local function clearAll()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "ESP_HL" or obj.Name == "ESP_Tag" then
            pcall(function() obj:Destroy() end)
        end
    end
end

local function addESP(obj, name, color)
    if not obj or not obj.Parent then return end
    local oldHL = obj:FindFirstChild("ESP_HL")
    if oldHL then pcall(function() oldHL:Destroy() end) end
    local h = Instance.new("Highlight")
    h.Name = "ESP_HL"; h.FillColor = color; h.FillTransparency = 0.4
    h.OutlineColor = color; h.OutlineTransparency = 0.2
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; h.Parent = obj
    
    local part = obj:IsA("Model") and (obj:FindFirstChild("Head") or obj:FindFirstChildWhichIsA("BasePart") or obj.PrimaryPart) or obj
    if part and part.Parent then
        local oldTag = part:FindFirstChild("ESP_Tag")
        if oldTag then pcall(function() oldTag:Destroy() end) end
        local bg = Instance.new("BillboardGui")
        bg.Name = "ESP_Tag"; bg.Size = UDim2.new(0, 130, 0, 30)
        bg.AlwaysOnTop = true; bg.MaxDistance = math.huge; bg.Parent = part
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0); label.BackgroundTransparency = 1
        label.Text = name; label.TextColor3 = color
        label.Font = Enum.Font.GothamBold; label.TextSize = 13
        label.TextStrokeTransparency = 0.5; label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.Parent = bg
    end
end

local function deduplicateByName(objects)
    local result = {}
    for _, data in ipairs(objects) do
        local part = data.obj:IsA("Model") and (data.obj:FindFirstChildWhichIsA("BasePart") or data.obj.PrimaryPart) or data.obj
        if part then
            local tooClose = false
            for _, existing in ipairs(result) do
                local ep = existing.obj:IsA("Model") and (existing.obj:FindFirstChildWhichIsA("BasePart") or existing.obj.PrimaryPart) or existing.obj
                if ep and data.cn == existing.cn and (ep.Position - part.Position).Magnitude < 10 then
                    tooClose = true; break
                end
            end
            if not tooClose then table.insert(result, data) end
        end
    end
    return result
end

local function getAllEnemies()
    local enemies = {}
    local myPos = getPos()
    if not myPos then return enemies end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
            local name = obj.Name:lower()
            if name:find("zombie") or name:find("crawler") then
                local root = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if root then
                    local dist = (myPos - root.Position).Magnitude
                    if dist <= Settings.KillRange then
                        table.insert(enemies, obj)
                    end
                end
            end
        end
    end
    return enemies
end

-- 每0.5秒刷新ESP
task.spawn(function()
    while true do
        if Settings.ESP_Items or Settings.ESP_Zombie or Settings.ESP_Default or Settings.ESP_Players then
            scanAll()
        end
        task.wait(0.5)
    end
end)

local function scanAll()
    if not (Settings.ESP_Items or Settings.ESP_Zombie or Settings.ESP_Default or Settings.ESP_Players) then
        clearAll()
        return
    end
    
    local items = {}
    local enemies = {}
    local defaults = {}
    local players = {}
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if not obj:IsA("Model") and not obj:IsA("BasePart") then continue end
        local name = obj.Name:lower()
        
        if Settings.ESP_Zombie and (name:find("zombie") or name:find("crawler")) then
            local label = name:find("crawler") and "爬虫" or "僵尸"
            local color = name:find("crawler") and Color3.fromRGB(200, 50, 200) or Color3.fromRGB(255, 80, 80)
            table.insert(enemies, {obj = obj, cn = label, color = color})
        end
        
        if name == "default" and Settings.ESP_Default then
            table.insert(defaults, {obj = obj, cn = "宝箱", color = Color3.fromRGB(255, 200, 50)})
        end
        
        if Settings.ESP_Items then
            for itemKey, itemData in pairs(itemNames) do
                if name == itemKey then
                    table.insert(items, {obj = obj, cn = itemData.cn, color = itemData.color})
                    break
                end
            end
        end
    end
    
    if Settings.ESP_Players then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                table.insert(players, {obj = plr.Character, cn = plr.Name, color = Color3.fromRGB(70, 255, 70)})
            end
        end
    end
    
    items = deduplicateByName(items)
    enemies = deduplicateByName(enemies)
    
    clearAll()
    for _, data in ipairs(items) do addESP(data.obj, data.cn, data.color) end
    for _, data in ipairs(enemies) do addESP(data.obj, data.cn, data.color) end
    for _, data in ipairs(defaults) do addESP(data.obj, data.cn, data.color) end
    for _, data in ipairs(players) do addESP(data.obj, data.cn, data.color) end
end

-- 距离更新
task.spawn(function()
    while true do
        if Settings.ESP_Items_Dist then
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                local myRoot = c.HumanoidRootPart
                for _, tag in pairs(workspace:GetDescendants()) do
                    if tag:IsA("BillboardGui") and tag.Name == "ESP_Tag" then
                        local label = tag:FindFirstChildWhichIsA("TextLabel")
                        local parent = tag.Parent
                        if label and parent then
                            local dist = (myRoot.Position - parent.Position).Magnitude
                            local text = label.Text:gsub(" %d+m$", "")
                            label.Text = text .. " " .. math.floor(dist) .. "m"
                        end
                    end
                end
            end
        end
        task.wait(0.3)
    end
end)

local function findItemPart(targetCN)
    local targetKey = nil
    for key, data in pairs(itemNames) do if data.cn == targetCN then targetKey = key; break end end
    if not targetKey then return nil end
    local myPos = getPos()
    if not myPos then return nil end
    local best, bestDist = nil, 1000
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            if obj.Name:lower() == targetKey then
                local part = obj:IsA("Model") and (obj:FindFirstChildWhichIsA("BasePart") or obj.PrimaryPart) or obj
                if part then
                    local dist = (myPos - part.Position).Magnitude
                    if dist < bestDist and dist > 5 then bestDist = dist; best = part end
                end
            end
        end
    end
    return best
end

-- 自动前往
task.spawn(function()
    while true do
        if Settings.AutoGo and not stopAll then
            local part = findItemPart(Settings.GoTarget)
            if part then
                local c = LocalPlayer.Character
                if c and c:FindFirstChild("HumanoidRootPart") then
                    c.HumanoidRootPart.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
                end
            end
            task.wait(2)
        else
            task.wait(1)
        end
    end
end)

-- 传送回家
task.spawn(function()
    while true do
        if Settings.AutoHome and not stopAll then
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                c.HumanoidRootPart.CFrame = CFrame.new(homePos)
            end
            task.wait(0.5)
        else
            task.wait(1)
        end
    end
end)

local function updateFog()
    Lighting.FogEnd = Settings.NoFog and 100000 or 500
    Lighting.FogStart = Settings.NoFog and 50000 or 0
end

local function updateNightVision()
    if Settings.NightVision then
        Lighting.Brightness = 5; Lighting.ClockTime = 14
        Lighting.FogEnd = 10000; Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 180)
    else
        Lighting.Brightness = 1; Lighting.FogEnd = 500; Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
    end
end

local function setNoClip(v)
    LocalPlayer.CharacterAdded:Connect(function(char)
        if v then task.wait(0.5); for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end end
    end)
    local char = LocalPlayer.Character
    if char then for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = not v end end end
end

-- 坐标加速
task.spawn(function()
    while true do
        if Settings.SpeedBoost then
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                local hrp = c.HumanoidRootPart
                local humanoid = c:FindFirstChild("Humanoid")
                if humanoid then
                    local moveDir = humanoid.MoveDirection
                    if moveDir.Magnitude > 0.1 then
                        local step = Settings.SpeedValue * 0.3
                        hrp.Position = hrp.Position + moveDir * step
                    end
                end
            end
        end
        task.wait()
    end
end)

-- 杀戮光环
task.spawn(function()
    while true do
        if Settings.KillAura then
            local enemies = getAllEnemies()
            if #enemies > 0 then
                local char = LocalPlayer.Character
                if char then
                    local bat = char:FindFirstChild("Bat")
                    if bat then
                        local swing = bat:FindFirstChild("Swing")
                        local hitTargets = bat:FindFirstChild("HitTargets")
                        if swing and hitTargets then
                            pcall(function() swing:FireServer() end)
                            pcall(function() hitTargets:FireServer(enemies) end)
                        end
                    end
                end
            end
            task.wait(0.1)
        else
            task.wait(1)
        end
    end
end)

local itemCNList = {}
for _, data in pairs(itemNames) do table.insert(itemCNList, data.cn) end

local function getPlayerNames()
    local names = {}
    for _, plr in pairs(Players:GetPlayers()) do if plr ~= LocalPlayer then table.insert(names, plr.Name) end end
    if #names == 0 then table.insert(names, "无其他玩家") end
    return names
end

local Window = WindUI:CreateWindow({
    Title = "黑脚本--在末日中活下来", Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(400, 350), Theme = "冰白", Transparent = true,
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "在末日中活下来 v3.7",
    Desc = "功能：透视物品/僵尸+爬虫/宝箱/玩家\n坐标加速 | 传送回家(开关) | 智能杀戮光环"
})

local Tab1 = Window:Tab({Title = "主要", Icon = "solar:star-bold"})
Tab1:Toggle({Title = "透视物品", Value = false, Callback = function(v) Settings.ESP_Items = v; scanAll() end})
Tab1:Toggle({Title = "显示距离", Value = false, Callback = function(v) Settings.ESP_Items_Dist = v end})
Tab1:Divider()
Tab1:Toggle({Title = "透视僵尸+爬虫", Value = false, Callback = function(v) Settings.ESP_Zombie = v; scanAll() end})
Tab1:Toggle({Title = "透视宝箱", Value = false, Callback = function(v) Settings.ESP_Default = v; scanAll() end})
Tab1:Divider()
Tab1:Toggle({Title = "去雾", Value = false, Callback = function(v) Settings.NoFog = v; updateFog() end})
Tab1:Toggle({Title = "夜视", Value = false, Callback = function(v) Settings.NightVision = v; updateNightVision() end})
Tab1:Divider()
Tab1:Dropdown({Title = "前往物品", Values = itemCNList, Value = "废料", Callback = function(v) Settings.GoTarget = v end})
Tab1:Toggle({Title = "自动前往", Value = false, Callback = function(v) Settings.AutoGo = v end})
Tab1:Divider()
Tab1:Toggle({Title = "杀戮光环", Value = false, Callback = function(v) Settings.KillAura = v end})
Tab1:Slider({Title = "攻击范围 (15-50)", Value = {Min = 15, Max = 50, Default = 30}, Step = 1, Callback = function(v) Settings.KillRange = v end})

local Tab2 = Window:Tab({Title = "传送", Icon = "solar:map-bold"})
Tab2:Toggle({Title = "传送回家（开关）", Value = false, Callback = function(v) Settings.AutoHome = v end})
Tab2:Divider()
local playerNames = getPlayerNames()
local selectedPlayer = playerNames[1] or "无其他玩家"
Tab2:Dropdown({Title = "选择玩家", Values = playerNames, Value = selectedPlayer, Callback = function(v) selectedPlayer = v end})
Tab2:Button({Title = "传送到该玩家", Callback = function() 
    for _, plr in pairs(Players:GetPlayers()) do 
        if plr.Name == selectedPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then 
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                c.HumanoidRootPart.CFrame = CFrame.new(plr.Character.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
            end
        end 
    end 
end})

local Tab3 = Window:Tab({Title = "玩家", Icon = "solar:user-bold"})
Tab3:Toggle({Title = "透视玩家", Value = false, Callback = function(v) Settings.ESP_Players = v; scanAll() end})
Tab3:Toggle({Title = "穿墙", Value = false, Callback = function(v) Settings.NoClip = v; setNoClip(v) end})
Tab3:Toggle({Title = "坐标加速", Value = false, Callback = function(v) Settings.SpeedBoost = v end})
Tab3:Slider({Title = "加速值 (1-30)", Value = {Min = 1, Max = 30, Default = 5}, Step = 1, Callback = function(v) Settings.SpeedValue = v end})

local SettingsTab = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})
local statusPara = SettingsTab:Paragraph({Title = "功能状态", Desc = "加载中..."})

task.spawn(function()
    while true do
        local status = ""
        status = status .. "透视物品: " .. (Settings.ESP_Items and "已开启" or "未开启") .. "\n"
        status = status .. "透视僵尸+爬虫: " .. (Settings.ESP_Zombie and "已开启" or "未开启") .. "\n"
        status = status .. "透视宝箱: " .. (Settings.ESP_Default and "已开启" or "未开启") .. "\n"
        status = status .. "透视玩家: " .. (Settings.ESP_Players and "已开启" or "未开启") .. "\n"
        status = status .. "坐标加速: " .. (Settings.SpeedBoost and "已开启 (" .. Settings.SpeedValue .. ")" or "未开启") .. "\n"
        status = status .. "杀戮光环: " .. (Settings.KillAura and "已开启" or "未开启") .. "\n"
        status = status .. "传送回家: " .. (Settings.AutoHome and "已开启" or "未开启") .. "\n"
        status = status .. "帧率: " .. math.floor(1 / task.wait()) .. " FPS"
        statusPara:SetDesc(status)
        task.wait(1)
    end
end)

SettingsTab:Button({Title = "关闭脚本", Callback = function() stopAll = true; clearAll(); updateNightVision(); updateFog(); Window:Close() end})
Window:OnClose(function() stopAll = true; clearAll(); updateNightVision(); updateFog() end)

WindUI:Notify({Title = "在末日中活下来", Content = VERSION .. " 加载完成", Duration = 3})
