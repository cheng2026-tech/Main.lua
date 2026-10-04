-- 启示录 脚本 v2.7 Pro Max
-- WindUI蓝白版 | 修复关闭透视仍显示 | 夜视30秒刷新 | 高度400

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
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Settings = {
    ESP_TutorialLoot = false, ESP_CommonLoot = false, ESP_UncommonLoot = false,
    ESP_Zombie = false, ESP_Collision = false, ESP_DronePad = false,
    ESP_Strawberry = false, ESP_Blueberry = false, ESP_Potato = false,
    ESP_Players = false, ESP_ShowDist = false,
    AutoLoot = false, LootMode = "全部宝箱",
    AutoStrawberry = false, AutoBlueberry = false, AutoPotato = false, SafeMode = true,
    TreeAura = false, SandAura = false, StoneAura = false,
    NightVision = false, WalkSpeed = 16,
}

local VERSION = "v2.7 Pro Max"

local lootNames = {
    ["TutorialLoot"] = {cn = "教程箱", color = Color3.fromRGB(255, 200, 50)},
    ["CommonLoot"] = {cn = "普通箱", color = Color3.fromRGB(150, 150, 150)},
    ["UncommonLoot"] = {cn = "铜箱", color = Color3.fromRGB(200, 150, 50)},
}

local realZombieNames = {"Zombie", "Mutant Zombie"}

local espData = {}

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
    if pos.Y < -100 or pos.Y > 5000 then return end
    root.CFrame = CFrame.new(pos)
end

local function destroyESP(id)
    if espData[id] then
        if espData[id].highlight then pcall(function() espData[id].highlight:Destroy() end) end
        if espData[id].tag then pcall(function() espData[id].tag:Destroy() end) end
        espData[id] = nil
    end
end

local function clearAllESP()
    for id, _ in pairs(espData) do
        destroyESP(id)
    end
end

local function addESP(obj, name, color, category)
    local id = category .. "_" .. obj:GetFullName()
    if espData[id] then
        local existing = espData[id]
        if existing.tag and existing.tag.Parent then
            local label = existing.tag:FindFirstChildWhichIsA("TextLabel")
            if label then label.Text = name; label.TextColor3 = color end
        end
        if existing.highlight and existing.highlight.Parent then
            existing.highlight.FillColor = color; existing.highlight.OutlineColor = color
        end
        return
    end
    
    local h = Instance.new("Highlight")
    h.Name = "ESP_HL"; h.FillColor = color; h.FillTransparency = 0.4
    h.OutlineColor = color; h.OutlineTransparency = 0.2
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = obj
    
    local part = obj:IsA("Model") and (obj:FindFirstChild("Head") or obj:FindFirstChildWhichIsA("BasePart") or obj.PrimaryPart) or obj
    local tag = nil
    if part then
        local bg = Instance.new("BillboardGui")
        bg.Name = "ESP_Tag"; bg.Size = UDim2.new(0, 150, 0, 30)
        bg.AlwaysOnTop = true; bg.MaxDistance = math.huge
        bg.Parent = part
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0); label.BackgroundTransparency = 1
        label.Text = name; label.TextColor3 = color
        label.Font = Enum.Font.GothamBold; label.TextSize = 14
        label.TextStrokeTransparency = 0.5; label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.Parent = bg
        tag = bg
    end
    espData[id] = {highlight = h, tag = tag, obj = obj, category = category}
end

local function isRealZombie(obj)
    for _, zName in ipairs(realZombieNames) do
        if obj.Name == zName then return true end
    end
    return false
end

local function hasZombiesNear(pos, count)
    local found = 0
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and isRealZombie(obj) then
            local hum = obj:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local zPos = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
                if zPos and (pos - zPos.Position).Magnitude <= 100 then
                    found = found + 1
                    if found >= count then return true end
                end
            end
        end
    end
    return false
end

-- 清理某个类别的ESP
local function clearCategory(category)
    local toRemove = {}
    for id, data in pairs(espData) do
        if data.category == category then
            table.insert(toRemove, id)
        end
    end
    for _, id in ipairs(toRemove) do
        destroyESP(id)
    end
end

local function scanAll()
    -- 清理关闭的类别
    if not Settings.ESP_TutorialLoot then clearCategory("TutorialLoot") end
    if not Settings.ESP_CommonLoot then clearCategory("CommonLoot") end
    if not Settings.ESP_UncommonLoot then clearCategory("UncommonLoot") end
    if not Settings.ESP_Zombie then clearCategory("zombie") end
    if not Settings.ESP_Collision then clearCategory("collision") end
    if not Settings.ESP_DronePad then clearCategory("drone") end
    if not Settings.ESP_Strawberry then clearCategory("strawberry") end
    if not Settings.ESP_Blueberry then clearCategory("blueberry") end
    if not Settings.ESP_Potato then clearCategory("potato") end
    if not Settings.ESP_Players then clearCategory("player") end
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if not obj:IsA("Model") and not obj:IsA("BasePart") then continue end
        local name = obj.Name
        
        if Settings.ESP_Zombie and isRealZombie(obj) then
            addESP(obj, "僵尸", Color3.fromRGB(255, 80, 80), "zombie")
        end
        
        for lootName, lootData in pairs(lootNames) do
            if name == lootName then
                if (lootName == "TutorialLoot" and Settings.ESP_TutorialLoot) then
                    addESP(obj, lootData.cn, lootData.color, "TutorialLoot")
                elseif (lootName == "CommonLoot" and Settings.ESP_CommonLoot) then
                    addESP(obj, lootData.cn, lootData.color, "CommonLoot")
                elseif (lootName == "UncommonLoot" and Settings.ESP_UncommonLoot) then
                    addESP(obj, lootData.cn, lootData.color, "UncommonLoot")
                end
            end
        end
        
        if name:lower():find("collision") and Settings.ESP_Collision then
            addESP(obj, "汽车残骸", Color3.fromRGB(180, 120, 60), "collision")
        end
        
        if name:lower():find("drone") and Settings.ESP_DronePad then
            addESP(obj, "无人机坪", Color3.fromRGB(100, 200, 255), "drone")
        end
        
        if name == "StrawberryBush" and Settings.ESP_Strawberry then
            addESP(obj, "草莓", Color3.fromRGB(255, 100, 100), "strawberry")
        end
        
        if name == "BlueberryBush" and Settings.ESP_Blueberry then
            addESP(obj, "蓝莓", Color3.fromRGB(100, 100, 255), "blueberry")
        end
        
        if name == "PotatoPlant" and Settings.ESP_Potato then
            addESP(obj, "土豆", Color3.fromRGB(200, 180, 100), "potato")
        end
    end
    
    if Settings.ESP_Players then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                addESP(plr.Character, plr.Name, Color3.fromRGB(70, 255, 70), "player")
            end
        end
    end
end

task.spawn(function() while true do scanAll(); task.wait(3) end end)

task.spawn(function()
    while true do
        if Settings.ESP_ShowDist then
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                local myRoot = c.HumanoidRootPart
                for id, data in pairs(espData) do
                    if data.tag and data.tag.Parent and data.obj and data.obj.Parent then
                        local label = data.tag:FindFirstChildWhichIsA("TextLabel")
                        if label then
                            local part = data.obj:IsA("Model") and (data.obj:FindFirstChildWhichIsA("BasePart") or data.obj.PrimaryPart) or data.obj
                            if part then
                                local dist = (myRoot.Position - part.Position).Magnitude
                                local text = label.Text:gsub(" %d+m$", "")
                                label.Text = text .. " " .. math.floor(dist) .. "m"
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

task.spawn(function()
    while true do
        if Settings.TreeAura then
            pcall(function() ReplicatedStorage.Network.Items.ToolAction:FireServer("click", workspace.Spawned:GetChildren()[47], false) end)
            task.wait(0.05)
        else task.wait(1) end
    end
end)

task.spawn(function()
    while true do
        if Settings.SandAura then
            pcall(function() ReplicatedStorage.Network.Items.ToolAction:FireServer("click", workspace.Spawned.Sandstone, false) end)
            task.wait(0.05)
        else task.wait(1) end
    end
end)

task.spawn(function()
    while true do
        if Settings.StoneAura then
            pcall(function() ReplicatedStorage.Network.Items.ToolAction:FireServer("click", workspace.Spawned:GetChildren()[465], false) end)
            task.wait(0.05)
        else task.wait(1) end
    end
end)

local function goToAirDrop()
    local nearest = nil
    local nearestDist = math.huge
    local myPos = getPos()
    if not myPos then return end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            if obj.Name == "AirDrop" then
                local part = obj:IsA("Model") and (obj:FindFirstChildWhichIsA("BasePart") or obj.PrimaryPart) or obj
                if part then
                    local dist = (myPos - part.Position).Magnitude
                    if dist < nearestDist then nearestDist = dist; nearest = part end
                end
            end
        end
    end
    if nearest then tp(nearest.Position + Vector3.new(2, 3, -2)) end
end

local function collectAll(nameMatch)
    local targets = {}
    local usedPos = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            if obj.Name == nameMatch then
                local part = obj:IsA("Model") and (obj:FindFirstChildWhichIsA("BasePart") or obj.PrimaryPart) or obj
                if part and part.Position.Y > -100 then
                    if Settings.SafeMode and hasZombiesNear(part.Position, 2) then continue end
                    local pos = part.Position
                    local dup = false
                    for _, up in ipairs(usedPos) do
                        if (pos - up).Magnitude < 8 then dup = true; break end
                    end
                    if not dup then
                        table.insert(targets, part)
                        table.insert(usedPos, pos)
                    end
                end
            end
        end
    end
    return targets
end

local function collectLoot()
    local nameList = {}
    if Settings.LootMode == "全部宝箱" then nameList = {"TutorialLoot", "CommonLoot", "UncommonLoot"}
    elseif Settings.LootMode == "教程箱" then nameList = {"TutorialLoot"}
    elseif Settings.LootMode == "普通箱" then nameList = {"CommonLoot"}
    elseif Settings.LootMode == "铜箱" then nameList = {"UncommonLoot"} end
    
    local targets = {}
    local usedPos = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            for _, n in ipairs(nameList) do
                if obj.Name == n then
                    local part = obj:IsA("Model") and (obj:FindFirstChildWhichIsA("BasePart") or obj.PrimaryPart) or obj
                    if part and part.Position.Y > -100 then
                        if Settings.SafeMode and hasZombiesNear(part.Position, 2) then continue end
                        local pos = part.Position
                        local dup = false
                        for _, up in ipairs(usedPos) do
                            if (pos - up).Magnitude < 8 then dup = true; break end
                        end
                        if not dup then
                            table.insert(targets, part)
                            table.insert(usedPos, pos)
                        end
                    end
                end
            end
        end
    end
    return targets
end

task.spawn(function()
    while true do
        if Settings.AutoLoot then
            local targets = collectLoot()
            for _, part in ipairs(targets) do
                if not Settings.AutoLoot then break end
                if part and part.Parent then
                    tp(part.Position + Vector3.new(0, 3, 0))
                    task.wait(0.3)
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, nil)
                    task.wait(0.15)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, nil)
                    task.wait(2)
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.C, false, nil)
                    task.wait(0.15)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.C, false, nil)
                    task.wait(0.3)
                end
            end
            Settings.AutoLoot = false
        end
        task.wait(0.5)
    end
end)

task.spawn(function()
    while true do
        if Settings.AutoStrawberry then
            local targets = collectAll("StrawberryBush")
            for _, part in ipairs(targets) do
                if not Settings.AutoStrawberry then break end
                if part and part.Parent then
                    tp(part.Position + Vector3.new(0, 3, 0))
                    task.wait(0.3)
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, nil)
                    task.wait(0.15)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, nil)
                    task.wait(0.5)
                end
            end
            Settings.AutoStrawberry = false
        end
        task.wait(0.5)
    end
end)

task.spawn(function()
    while true do
        if Settings.AutoBlueberry then
            local targets = collectAll("BlueberryBush")
            for _, part in ipairs(targets) do
                if not Settings.AutoBlueberry then break end
                if part and part.Parent then
                    tp(part.Position + Vector3.new(0, 3, 0))
                    task.wait(0.3)
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, nil)
                    task.wait(0.15)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, nil)
                    task.wait(0.5)
                end
            end
            Settings.AutoBlueberry = false
        end
        task.wait(0.5)
    end
end)

task.spawn(function()
    while true do
        if Settings.AutoPotato then
            local targets = collectAll("PotatoPlant")
            for _, part in ipairs(targets) do
                if not Settings.AutoPotato then break end
                if part and part.Parent then
                    tp(part.Position + Vector3.new(0, 3, 0))
                    task.wait(0.3)
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, nil)
                    task.wait(0.15)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, nil)
                    task.wait(0.5)
                end
            end
            Settings.AutoPotato = false
        end
        task.wait(0.5)
    end
end)

-- 夜视30秒刷新
local nightVisionTimer = nil
local function updateNightVision()
    if Settings.NightVision then
        Lighting.Brightness = 8
        Lighting.ClockTime = 14
        Lighting.FogEnd = 10000
        Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 200)
        if nightVisionTimer then nightVisionTimer:Disconnect() end
        nightVisionTimer = task.spawn(function()
            while Settings.NightVision do
                task.wait(30)
                if not Settings.NightVision then break end
                Lighting.Brightness = 1
                task.wait(0.3)
                Lighting.Brightness = 8
                Lighting.ClockTime = 14
                Lighting.FogEnd = 10000
                Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 200)
            end
        end)
    else
        Lighting.Brightness = 1
        Lighting.FogEnd = 100
        Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
        if nightVisionTimer then nightVisionTimer:Disconnect(); nightVisionTimer = nil end
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
    Title = "启示录", Icon = "rbxassetid://129260712070622", IconThemed = true,
    Size = UDim2.fromOffset(400, 400), Theme = "冰白", Transparent = true,
})

Window:Tab({Title = "公告", Icon = "info"}):Paragraph({
    Title = "黑脚本--启示录 " .. VERSION,
    Desc = "砍树+砂岩+石头光环 | 空投传送\n透视+自动采集 | 夜视30秒刷新\n脚本最大帮助者:CHANGCHENG66",
})

local Tab1 = Window:Tab({Title = "透视", Icon = "eye"})
Tab1:Toggle({Title = "透视教程箱", Value = false, Callback = function(v) Settings.ESP_TutorialLoot = v; scanAll() end})
Tab1:Toggle({Title = "透视普通箱", Value = false, Callback = function(v) Settings.ESP_CommonLoot = v; scanAll() end})
Tab1:Toggle({Title = "透视铜箱", Value = false, Callback = function(v) Settings.ESP_UncommonLoot = v; scanAll() end})
Tab1:Toggle({Title = "透视草莓", Value = false, Callback = function(v) Settings.ESP_Strawberry = v; scanAll() end})
Tab1:Toggle({Title = "透视蓝莓", Value = false, Callback = function(v) Settings.ESP_Blueberry = v; scanAll() end})
Tab1:Toggle({Title = "透视土豆", Value = false, Callback = function(v) Settings.ESP_Potato = v; scanAll() end})
Tab1:Toggle({Title = "透视僵尸", Value = false, Callback = function(v) Settings.ESP_Zombie = v; scanAll() end})
Tab1:Toggle({Title = "透视汽车残骸", Value = false, Callback = function(v) Settings.ESP_Collision = v; scanAll() end})
Tab1:Toggle({Title = "透视无人机坪", Value = false, Callback = function(v) Settings.ESP_DronePad = v; scanAll() end})
Tab1:Toggle({Title = "显示距离", Value = false, Callback = function(v) Settings.ESP_ShowDist = v end})
Tab1:Toggle({Title = "夜视(30秒刷新)", Value = false, Callback = function(v) Settings.NightVision = v; updateNightVision() end})

local Tab2 = Window:Tab({Title = "自动", Icon = "play"})
Tab2:Toggle({Title = "砍树光环", Value = false, Callback = function(v) Settings.TreeAura = v end})
Tab2:Toggle({Title = "砂岩光环", Value = false, Callback = function(v) Settings.SandAura = v end})
Tab2:Toggle({Title = "石头光环", Value = false, Callback = function(v) Settings.StoneAura = v end})
Tab2:Paragraph({Title = "说明", Desc = "站在目标旁自动刷，不掉耐久"})
Tab2:Divider()
Tab2:Toggle({Title = "安全模式", Value = true, Callback = function(v) Settings.SafeMode = v end})
Tab2:Dropdown({Title = "宝箱类型", Values = {"全部宝箱", "教程箱", "普通箱", "铜箱"}, Value = "全部宝箱", Callback = function(v) Settings.LootMode = v end})
Tab2:Toggle({Title = "自动开宝箱", Value = false, Callback = function(v) Settings.AutoLoot = v end})
Tab2:Toggle({Title = "自动草莓", Value = false, Callback = function(v) Settings.AutoStrawberry = v end})
Tab2:Toggle({Title = "自动蓝莓", Value = false, Callback = function(v) Settings.AutoBlueberry = v end})
Tab2:Toggle({Title = "自动土豆", Value = false, Callback = function(v) Settings.AutoPotato = v end})
Tab2:Button({Title = "传送到空投", Callback = goToAirDrop})

local playerNames = getPlayerNames()
local selectedPlayer = playerNames[1] or "无其他玩家"
local Tab3 = Window:Tab({Title = "玩家", Icon = "users"})
Tab3:Toggle({Title = "透视玩家", Value = false, Callback = function(v) Settings.ESP_Players = v; scanAll() end})
Tab3:Button({Title = "飞行", Callback = loadFly})
Tab3:Dropdown({Title = "选择玩家", Values = playerNames, Value = selectedPlayer, Callback = function(v) selectedPlayer = v end})
Tab3:Button({Title = "传送到该玩家", Callback = function() for _, plr in pairs(Players:GetPlayers()) do if plr.Name == selectedPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then tp(plr.Character.HumanoidRootPart.Position) end end end})
Tab3:Input({Title = "移动速度", Value = "16", Callback = function(v) local n = tonumber(v) if n and n >= 10 and n <= 50 then Settings.WalkSpeed = n end end})
Tab3:Button({Title = "重置速度", Callback = function() Settings.WalkSpeed = 16 end})

Window:Tab({Title = "设置", Icon = "settings"}):Button({Title = "关闭脚本", Callback = function() for k, _ in pairs(Settings) do if type(Settings[k]) == "boolean" then Settings[k] = false end end; clearAllESP(); updateNightVision(); setSpeed(16); Window:Close() end})
Window:OnClose(function() clearAllESP(); updateNightVision(); setSpeed(16) end)

WindUI:Notify({Title = "启示录", Content = VERSION .. " 加载完成", Duration = 3})
