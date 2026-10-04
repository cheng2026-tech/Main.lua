-- 种植花园2 脚本 v1.7
-- WindUI版 | 修复消失 | 自动偷菜长按E3秒 | 自动收货
local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local Settings = {
    AutoHarvest = false,
    AutoSteal = false,
    ESP_Enabled = false,
    WalkSpeed = 16,
}

local savedPositions = { farmPos = nil, stealPos = nil }
local VERSION = "v1.7"
local stopAll = false
local highlights = {}
local nameTags = {}

local function getPos()
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("HumanoidRootPart") then return c.HumanoidRootPart.Position end
    return nil
end

local function tp(pos)
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("HumanoidRootPart") then c.HumanoidRootPart.CFrame = CFrame.new(pos) end
end

local function pressE()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil)
    task.wait(0.08)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
end

local function holdE(duration)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil)
    task.wait(duration)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
end

local function setSpeed(s)
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = s end
end

-- 自动收货
task.spawn(function()
    while true do
        if Settings.AutoHarvest and not stopAll then
            if not savedPositions.farmPos then task.wait(1) continue end
            tp(savedPositions.farmPos)
            task.wait(0.5)
            local t = tick()
            while tick() - t < 3 do
                if not Settings.AutoHarvest or stopAll then break end
                pressE()
                task.wait(0.15)
            end
            task.wait(1)
        else
            task.wait(1)
        end
    end
end)

-- 自动偷菜
task.spawn(function()
    while true do
        if Settings.AutoSteal and not stopAll then
            if not savedPositions.stealPos or not savedPositions.farmPos then task.wait(1) continue end
            tp(savedPositions.stealPos)
            task.wait(0.5)
            holdE(3)
            task.wait(0.3)
            tp(savedPositions.farmPos)
            task.wait(1)
        else
            task.wait(1)
        end
    end
end)

-- ESP
local function clearESP()
    for _, h in pairs(highlights) do pcall(function() h:Destroy() end) end
    table.clear(highlights)
    for _, t in pairs(nameTags) do pcall(function() t:Destroy() end) end
    table.clear(nameTags)
end

RunService.Heartbeat:Connect(function()
    if not Settings.ESP_Enabled then clearESP() return end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then
            if highlights[plr] then pcall(function() highlights[plr]:Destroy() end) highlights[plr] = nil end
            if nameTags[plr] then pcall(function() nameTags[plr]:Destroy() end) nameTags[plr] = nil end
        else
            local char = plr.Character
            if char and char:FindFirstChild("Head") then
                if not highlights[plr] then
                    local h = Instance.new("Highlight")
                    h.FillColor = Color3.fromRGB(255, 100, 100)
                    h.FillTransparency = 0.5
                    h.OutlineColor = Color3.fromRGB(255, 50, 50)
                    h.OutlineTransparency = 0.3
                    highlights[plr] = h
                end
                if highlights[plr] and highlights[plr].Parent ~= char then highlights[plr].Parent = char end
                if not nameTags[plr] then
                    local bg = Instance.new("BillboardGui")
                    bg.Size = UDim2.new(0, 120, 0, 25)
                    bg.AlwaysOnTop = true
                    bg.MaxDistance = math.huge
                    local l = Instance.new("TextLabel")
                    l.Size = UDim2.new(1, 0, 1, 0)
                    l.BackgroundTransparency = 1
                    l.Text = plr.Name
                    l.TextColor3 = Color3.fromRGB(255, 255, 255)
                    l.Font = Enum.Font.GothamBold
                    l.TextSize = 14
                    l.TextStrokeTransparency = 0.5
                    l.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    l.Parent = bg
                    nameTags[plr] = bg
                end
                if nameTags[plr] and nameTags[plr].Parent ~= char.Head then nameTags[plr].Parent = char.Head end
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    if highlights[plr] then pcall(function() highlights[plr]:Destroy() end) highlights[plr] = nil end
    if nameTags[plr] then pcall(function() nameTags[plr]:Destroy() end) nameTags[plr] = nil end
end)

RunService.Heartbeat:Connect(function()
    if Settings.WalkSpeed ~= 16 then setSpeed(Settings.WalkSpeed) end
end)

local function locateFarm()
    local p = getPos()
    if p then savedPositions.farmPos = p end
    WI:Notify({Title = "成功", Content = "种菜位置已定位", Duration = 1})
end

local function locateSteal()
    local p = getPos()
    if p then savedPositions.stealPos = p end
    WI:Notify({Title = "成功", Content = "偷菜位置已定位", Duration = 1})
end

local function clearAll()
    savedPositions.farmPos = nil
    savedPositions.stealPos = nil
    WI:Notify({Title = "清除", Content = "所有定位已清除", Duration = 1})
end

local function getPlayerNames()
    local names = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then table.insert(names, plr.Name) end
    end
    if #names == 0 then table.insert(names, "无其他玩家") end
    return names
end

-- UI
local Win = WI:CreateWindow({
    Title = "种植花园2",
    Icon = "solar:leaf-bold",
    Size = UDim2.fromOffset(400, 460),
    Acrylic = true,
})

Win:Tab({Title = "公告", Icon = "solar:home-bold"}):Paragraph({
    Title = "黑脚本--功能说明",
    Desc = "自动收货 | 自动偷菜\n传送玩家 | 透视 | 调速度\n\n版本：" .. VERSION
})

local t1 = Win:Tab({Title = "定位", Icon = "solar:map-point-bold"})
t1:Button({Title = "定位种菜位置", Justify = "Center", Color = Color3.fromHex("#4CAF50"), Callback = locateFarm})
t1:Divider()
t1:Button({Title = "定位偷菜位置", Justify = "Center", Color = Color3.fromHex("#FF9800"), Callback = locateSteal})
t1:Divider()
t1:Button({Title = "清除所有定位", Justify = "Center", Color = Color3.fromHex("#ff4444"), Callback = clearAll})

local t2 = Win:Tab({Title = "主要", Icon = "solar:play-bold"})
t2:Toggle({Title = "自动收货", Value = false, Callback = function(v) Settings.AutoHarvest = v if v and not savedPositions.farmPos then WI:Notify({Title = "错误", Content = "请先定位种菜位置！", Duration = 3}) Settings.AutoHarvest = false end end})
t2:Divider()
t2:Toggle({Title = "自动偷菜", Value = false, Callback = function(v) Settings.AutoSteal = v if v and (not savedPositions.stealPos or not savedPositions.farmPos) then WI:Notify({Title = "错误", Content = "请先定位偷菜位置和种菜位置！", Duration = 3}) Settings.AutoSteal = false end end})
t2:Paragraph({Title = "⚠️ 注意", Desc = "确定在晚上偷！\n必须先定位家和偷菜地方！"})

local playerNames = getPlayerNames()
local selectedPlayer = playerNames[1] or "无其他玩家"
local t3 = Win:Tab({Title = "玩家", Icon = "solar:user-bold"})
t3:Toggle({Title = "开启透视", Value = false, Callback = function(v) Settings.ESP_Enabled = v if not v then clearESP() end end})
t3:Divider()
t3:Dropdown({Title = "选择玩家", Values = playerNames, Value = selectedPlayer, Callback = function(v) selectedPlayer = v end})
t3:Divider()
t3:Button({Title = "传送到该玩家", Justify = "Center", Color = Color3.fromHex("#03A9F4"), Callback = function() for _, plr in pairs(Players:GetPlayers()) do if plr.Name == selectedPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then tp(plr.Character.HumanoidRootPart.Position) return end end end})
t3:Divider()
t3:Input({Title = "移动速度", Value = "16", Callback = function(v) local n = tonumber(v) if n and n >= 10 and n <= 100 then Settings.WalkSpeed = n end end})
t3:Divider()
t3:Button({Title = "重置速度", Justify = "Center", Color = Color3.fromHex("#888888"), Callback = function() Settings.WalkSpeed = 16 end})

Win:Tab({Title = "设置", Icon = "solar:settings-bold"}):Button({
    Title = "关闭脚本", Justify = "Center", Color = Color3.fromHex("#ff4444"),
    Callback = function()
        stopAll = true
        Settings.AutoHarvest = false
        Settings.AutoSteal = false
        Settings.ESP_Enabled = false
        clearESP()
        setSpeed(16)
        pcall(function() local g = game:GetService("CoreGui"):FindFirstChild("WindUI") if g then g:Destroy() end end)
    end
})

WI:Notify({Title = "种植花园2", Content = VERSION .. " 加载完成", Duration = 5})
