-- 开采一座山 脚本 v2.5
-- WindUI版 | 自动挖矿(过滤碎石) | 真正长按E | 夜视 | 透视
local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Settings = {
    NightVision = false,
    AutoMine = false,
    MineCount = 5,
    ESP_Minerals = false,
    ESP_ShowPrice = false,
    ESP_MinPrice = 0,
    ESP_ShowDist = false,
    ESP_Players = false,
    WalkSpeed = 16,
}

local VERSION = "v2.5"
local stopAll = false
local isSelling = false
local highlights = {}
local tags = {}
local playerHighlights = {}
local playerTags = {}

-- ==================== 预估价格 ====================
local function estimatePrice(name)
    local lower = name:lower()
    if lower:find("celestial") or lower:find("divine") or lower:find("eternal") then return 500000000, "传说" end
    if lower:find("mythic") or lower:find("ancient") or lower:find("primordial") then return 100000000, "神话" end
    if lower:find("diamond") then return 50000000, "钻石" end
    if lower:find("void") or lower:find("abyssal") then return 30000000, "虚空" end
    if lower:find("rainbow") or lower:find("spectrum") then return 20000000, "彩虹" end
    if lower:find("emerald") then return 8000000, "祖母绿" end
    if lower:find("ruby") then return 6000000, "红宝石" end
    if lower:find("sapphire") then return 5000000, "蓝宝石" end
    if lower:find("amethyst") then return 4000000, "紫水晶" end
    if lower:find("mythril") then return 12000000, "秘银" end
    if lower:find("platinum") then return 3000000, "铂金" end
    if lower:find("uranium") then return 6000000, "铀" end
    if lower:find("titanium") then return 2000000, "钛" end
    if lower:find("gold") and not lower:find("golden") then return 1500000, "金" end
    if lower:find("topaz") then return 2500000, "黄玉" end
    if lower:find("opal") then return 3500000, "蛋白石" end
    if lower:find("jade") then return 4000000, "翡翠" end
    if lower:find("rose") then return 2000000, "玫瑰" end
    if lower:find("crystal") then return 500000, "水晶" end
    if lower:find("obsidian") then return 800000, "黑曜石" end
    if lower:find("silver") then return 300000, "银" end
    if lower:find("quartz") then return 200000, "石英" end
    if lower:find("marble") then return 400000, "大理石" end
    if lower:find("gem") then return 600000, "宝石" end
    if lower:find("ore") then return 100000, "矿石" end
    if lower:find("iron") then return 80000, "铁" end
    if lower:find("copper") then return 40000, "铜" end
    if lower:find("coal") then return 15000, "煤" end
    if lower:find("granite") then return 30000, "花岗岩" end
    if lower:find("stone") then return 5000, "石头" end
    if lower:find("rock") then return 3000, "岩石" end
    if lower:find("t10") or lower:find("tier10") then return 100000000, "T10" end
    if lower:find("t5") or lower:find("tier5") then return 2000000, "T5" end
    if lower:find("t4") or lower:find("tier4") then return 800000, "T4" end
    if lower:find("t3") or lower:find("tier3") then return 300000, "T3" end
    if lower:find("t2") or lower:find("tier2") then return 100000, "T2" end
    if lower:find("t1") or lower:find("tier1") then return 30000, "T1" end
    return nil, nil
end

-- ==================== 排除工具 ====================
local function isTool(obj)
    if obj:IsA("Tool") then return true end
    local parent = obj.Parent
    while parent do
        if parent:IsA("Tool") then return true end
        if parent:IsA("Model") and parent:FindFirstChild("Humanoid") then return true end
        if parent:IsA("Backpack") then return true end
        parent = parent.Parent
    end
    if obj:FindFirstAncestorOfClass("Tool") then return true end
    return false
end

-- ==================== 排除碎石(没有Velocity的静止小石头) ====================
local function isDebris(obj)
    -- 检查是否是碎石/掉落物
    if obj:IsA("BasePart") then
        -- 如果有速度，说明在移动，是碎石
        if obj.Velocity.Magnitude > 1 then return true end
        -- 如果很小且透明，可能是碎片
        if obj.Size.Magnitude < 1 and obj.Transparency > 0.5 then return true end
    end
    -- 检查名字是否带particle/fragment/debris/rubble
    local name = obj.Name:lower()
    if name:find("particle") or name:find("fragment") or name:find("debris") or name:find("rubble") then return true end
    if name:find("chunk") or name:find("piece") or name:find("shard") then return true end
    
    return false
end

local function isMineral(obj)
    if isTool(obj) then return false end
    if isDebris(obj) then return false end
    if not obj:IsA("BasePart") and not obj:IsA("Model") then return false end
    if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then return false end
    local name = obj.Name:lower()
    if name:find("ground") or name:find("floor") or name:find("wall") then return false end
    if name:find("tree") or name:find("grass") or name:find("plant") then return false end
    if name:find("door") or name:find("window") or name:find("light") then return false end
    if name:find("player") or name:find("spawn") or name:find("base") then return false end
    if name:find("handle") or name:find("mesh") then return false end
    if name:find("pickaxe") or name:find("drill") or name:find("hammer") or name:find("tool") then return false end
    local price, _ = estimatePrice(obj.Name)
    return price ~= nil
end

-- ==================== 获取矿物位置 ====================
local function getMineralPart(obj)
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") then
        return obj:FindFirstChildWhichIsA("BasePart") or obj.PrimaryPart or obj:FindFirstChild("Head")
    end
    return nil
end

-- ==================== 获取位置/传送 ====================
local function getPos()
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("HumanoidRootPart") then return c.HumanoidRootPart.Position end
    return nil
end

local function tp(pos)
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("HumanoidRootPart") then c.HumanoidRootPart.CFrame = CFrame.new(pos) end
end

-- ==================== 售卖 ====================
local function sellAll()
    isSelling = true
    local returnPos = getPos()
    if not returnPos then isSelling = false return end
    tp(Vector3.new(-39, 29.1, 1065))
    task.wait(0.5)
    pcall(function() ReplicatedStorage.Remotes.SellRequest:FireServer("all") end)
    task.wait(0.5)
    tp(returnPos)
    isSelling = false
end

-- ==================== 找最近矿物 ====================
local function findNearestMineralObj()
    local myPos = getPos()
    if not myPos then return nil end
    local best, bestDist = nil, math.huge
    for _, obj in pairs(workspace:GetDescendants()) do
        if isMineral(obj) then
            local part = getMineralPart(obj)
            if part then
                local dist = (myPos - part.Position).Magnitude
                if dist < bestDist then bestDist = dist; best = obj end
            end
        end
    end
    return best
end

-- ==================== 挖一个矿 ====================
local function mineOne()
    local targetObj = findNearestMineralObj()
    if not targetObj then return false end
    
    local targetPart = getMineralPart(targetObj)
    if not targetPart then return false end
    
    tp(targetPart.Position + Vector3.new(0, 3, 0))
    task.wait(0.5)
    
    -- 按下E保持2秒
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil)
    local holdStart = tick()
    while tick() - holdStart < 2 do
        if stopAll or isSelling then
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
            return false
        end
        task.wait(0.1)
    end
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
    task.wait(0.3)
    
    -- 疯狂点左键5秒 + 实时跟随
    local t = tick()
    while tick() - t < 5 do
        if stopAll or isSelling then return false end
        
        local currentPart = getMineralPart(targetObj)
        if currentPart and currentPart.Parent then
            local myPos = getPos()
            if myPos and (myPos - currentPart.Position).Magnitude > 5 then
                tp(currentPart.Position + Vector3.new(0, 3, 0))
            end
        end
        
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, nil, 0)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, nil, 0)
        task.wait(0.05)
    end
    
    return true
end

-- ==================== 自动挖矿循环 ====================
task.spawn(function()
    while true do
        if Settings.AutoMine and not stopAll then
            local count = 0
            while count < Settings.MineCount do
                if not Settings.AutoMine or stopAll or isSelling then break end
                if mineOne() then count = count + 1 end
                task.wait(0.5)
            end
            if Settings.AutoMine and not stopAll and count >= Settings.MineCount then sellAll() end
            task.wait(1)
        else
            task.wait(1)
        end
    end
end)

-- ==================== 夜视 ====================
local function updateNightVision()
    Lighting.Brightness = Settings.NightVision and 3 or 1
    Lighting.ClockTime = Settings.NightVision and 14 or 0
    Lighting.OutdoorAmbient = Settings.NightVision and Color3.fromRGB(100, 100, 120) or Color3.fromRGB(0, 0, 0)
end

-- ==================== 透视矿物 ====================
local function clearMineralESP()
    for _, h in pairs(highlights) do pcall(function() h:Destroy() end) end
    for _, t in pairs(tags) do pcall(function() t:Destroy() end) end
    table.clear(highlights)
    table.clear(tags)
end

local function scanMinerals()
    clearMineralESP()
    if not Settings.ESP_Minerals then return end
    for _, obj in pairs(workspace:GetDescendants()) do
        if isMineral(obj) then
            local price, displayName = estimatePrice(obj.Name)
            if not price or price < Settings.ESP_MinPrice then continue end
            local part = getMineralPart(obj)
            if not part then continue end
            local color = Color3.fromHSV((math.log(price + 1) / 25) % 1, 0.8, 0.9)
            local h = Instance.new("Highlight")
            h.FillColor = color; h.FillTransparency = 0.4; h.OutlineColor = color; h.OutlineTransparency = 0.2
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; h.Parent = obj
            table.insert(highlights, h)
            local bg = Instance.new("BillboardGui")
            bg.Size = UDim2.new(0, 130, 0, 30); bg.AlwaysOnTop = true; bg.MaxDistance = 10000; bg.Parent = part
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1, 0, 1, 0); l.BackgroundTransparency = 1
            l.Text = Settings.ESP_ShowPrice and (displayName .. "\n$" .. (price >= 1000000 and string.format("%.1fM", price/1000000) or price >= 1000 and string.format("%.1fK", price/1000) or tostring(price))) or displayName
            l.TextColor3 = color; l.Font = Enum.Font.GothamBold; l.TextSize = 12
            l.TextStrokeTransparency = 0.5; l.TextStrokeColor3 = Color3.fromRGB(0, 0, 0); l.Parent = bg
            table.insert(tags, bg)
        end
    end
end

-- ==================== 距离更新 ====================
RunService.Heartbeat:Connect(function()
    if not Settings.ESP_Minerals or not Settings.ESP_ShowDist then return end
    local c = LocalPlayer.Character
    if not c or not c:FindFirstChild("HumanoidRootPart") then return end
    local root = c.HumanoidRootPart
    for i, data in ipairs(tags) do
        if data and data.Parent and highlights[i] and highlights[i].Parent then
            local parent = highlights[i].Parent
            local part = getMineralPart(parent)
            if part then
                local dist = (root.Position - part.Position).Magnitude
                local l = data:FindFirstChildWhichIsA("TextLabel")
                if l then l.Text = l.Text:gsub("|.%d+m", "") .. " | " .. math.floor(dist) .. "m" end
            end
        end
    end
end)

-- ==================== 透视玩家 ====================
local function clearPlayerESP()
    for _, h in pairs(playerHighlights) do pcall(function() h:Destroy() end) end
    for _, t in pairs(playerTags) do pcall(function() t:Destroy() end) end
    table.clear(playerHighlights)
    table.clear(playerTags)
end

local function scanPlayers()
    clearPlayerESP()
    if not Settings.ESP_Players then return end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char or not char:FindFirstChild("Head") then continue end
        local h = Instance.new("Highlight")
        h.FillColor = Color3.fromRGB(70, 200, 70); h.FillTransparency = 0.4
        h.OutlineColor = Color3.fromRGB(50, 180, 50); h.OutlineTransparency = 0.2; h.Parent = char
        table.insert(playerHighlights, h)
        local bg = Instance.new("BillboardGui")
        bg.Size = UDim2.new(0, 120, 0, 22); bg.AlwaysOnTop = true; bg.MaxDistance = math.huge; bg.Parent = char.Head
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 1, 0); l.BackgroundTransparency = 1
        l.Text = plr.Name; l.TextColor3 = Color3.fromRGB(70, 200, 70)
        l.Font = Enum.Font.GothamBold; l.TextSize = 12
        l.TextStrokeTransparency = 0.5; l.TextStrokeColor3 = Color3.fromRGB(0, 0, 0); l.Parent = bg
        table.insert(playerTags, bg)
    end
end

-- ==================== 调速 ====================
local function setSpeed(s)
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = s end
end
task.spawn(function() while true do if Settings.WalkSpeed ~= 16 then setSpeed(Settings.WalkSpeed) end task.wait(0.05) end end)

-- ==================== 传送玩家 ====================
local function getPlayerNames()
    local names = {}
    for _, plr in pairs(Players:GetPlayers()) do if plr ~= LocalPlayer then table.insert(names, plr.Name) end end
    if #names == 0 then table.insert(names, "无其他玩家") end
    return names
end

-- ==================== UI ====================
local Win = WI:CreateWindow({
    Title = "开采一座山", Icon = "solar:mountain-bold",
    Size = UDim2.fromOffset(400, 500), Acrylic = true,
})

Win:Tab({Title = "公告", Icon = "solar:home-bold"}):Paragraph({
    Title = "黑脚本--功能说明", Desc = "自动挖矿(过滤碎石)\n真正长按E | 实时跟随矿石\n挖N个→售卖 | 夜视\n透视矿物 | 透视玩家\n\n版本：" .. VERSION
})

local t1 = Win:Tab({Title = "主要", Icon = "solar:play-bold"})
t1:Toggle({Title = "自动挖矿", Value = false, Callback = function(v) Settings.AutoMine = v end})
t1:Input({Title = "挖几个后售卖", Value = "5", Callback = function(v) local n = tonumber(v) if n and n >= 1 then Settings.MineCount = n end end})
t1:Divider()
t1:Button({Title = "一键售卖", Justify = "Center", Color = Color3.fromHex("#FF9800"), Callback = sellAll})
t1:Divider()
t1:Toggle({Title = "夜视", Value = false, Callback = function(v) Settings.NightVision = v updateNightVision() end})

local t2 = Win:Tab({Title = "透视", Icon = "solar:eye-bold"})
t2:Toggle({Title = "透视矿物", Value = false, Callback = function(v) Settings.ESP_Minerals = v scanMinerals() end})
t2:Toggle({Title = "显示价格", Value = false, Callback = function(v) Settings.ESP_ShowPrice = v scanMinerals() end})
t2:Paragraph({Title = "⚠️", Desc = "价格是预估的，可能不准！"})
t2:Divider()
t2:Dropdown({Title = "最低价格筛选", Values = {"0","10K","100K","1M","10M","50M","100M","500M"}, Value = "0", Callback = function(v) local s = v:gsub("K","000"):gsub("M","000000"):gsub("B","000000000"); Settings.ESP_MinPrice = tonumber(s) or 0 scanMinerals() end})
t2:Divider()
t2:Toggle({Title = "显示距离", Value = false, Callback = function(v) Settings.ESP_ShowDist = v end})

local playerNames = getPlayerNames()
local selectedPlayer = playerNames[1] or "无其他玩家"
local t3 = Win:Tab({Title = "玩家", Icon = "solar:user-bold"})
t3:Toggle({Title = "透视玩家", Value = false, Callback = function(v) Settings.ESP_Players = v scanPlayers() end})
t3:Divider()
t3:Dropdown({Title = "选择玩家", Values = playerNames, Value = selectedPlayer, Callback = function(v) selectedPlayer = v end})
t3:Divider()
t3:Button({Title = "传送到该玩家", Justify = "Center", Color = Color3.fromHex("#03A9F4"), Callback = function() for _, plr in pairs(Players:GetPlayers()) do if plr.Name == selectedPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then tp(plr.Character.HumanoidRootPart.Position) return end end end})
t3:Divider()
t3:Input({Title = "移动速度", Value = "16", Callback = function(v) local n = tonumber(v) if n and n >= 10 and n <= 200 then Settings.WalkSpeed = n end end})
t3:Divider()
t3:Button({Title = "重置速度", Justify = "Center", Color = Color3.fromHex("#888888"), Callback = function() Settings.WalkSpeed = 16 end})

WI:Notify({Title = "开采一座山", Content = VERSION .. " 加载完成", Duration = 5})
