-- 装载卡车 脚本 v1.3
-- WindUI版 | 自动重生 | 一键透视(Highlight) | 双端自定义时间
local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Settings = {
    NoSleep = false,
    AFK = false,
    AutoLoad = false,
    AutoRebirth = false,
    BeltDelay = 5,
    TruckDelay = 5,
    ESP_Enabled = false,
    WalkSpeed = 16,
}

local savedPositions = { beltPos = nil, truckPos = nil }
local VERSION = "v1.3"
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

local function setSpeed(s)
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = s end
end

local function locateBelt()
    local p = getPos()
    if p then savedPositions.beltPos = p end
    WI:Notify({Title = "成功", Content = "传送带尾端已定位", Duration = 1})
end

local function locateTruck()
    local p = getPos()
    if p then savedPositions.truckPos = p end
    WI:Notify({Title = "成功", Content = "卡车尾端已定位", Duration = 1})
end

local function clearPositions()
    savedPositions.beltPos = nil
    savedPositions.truckPos = nil
    WI:Notify({Title = "清除", Content = "定位已清除", Duration = 1})
end

-- 禁止睡觉
task.spawn(function()
    while true do
        if Settings.NoSleep and not stopAll then
            pcall(function() ReplicatedStorage.Events.WakeWorker:FireServer(workspace.ActiveWorkers["6176143658_Worker_1"]) end)
            task.wait(1)
        else task.wait(1) end
    end
end)

-- AFK
task.spawn(function()
    while true do
        if Settings.AFK and not stopAll then
            task.wait(600)
            if not Settings.AFK or stopAll then continue end
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid.Jump = true end
        else task.wait(1) end
    end
end)

-- 自动装货
task.spawn(function()
    while true do
        if Settings.AutoLoad and not stopAll then
            if not savedPositions.beltPos or not savedPositions.truckPos then task.wait(1) continue end
            tp(savedPositions.beltPos)
            task.wait(Settings.BeltDelay)
            if not Settings.AutoLoad or stopAll then continue end
            tp(savedPositions.truckPos)
            task.wait(Settings.TruckDelay)
        else task.wait(1) end
    end
end)

-- 自动重生
task.spawn(function()
    while true do
        if Settings.AutoRebirth and not stopAll then
            task.wait(60)
            if not Settings.AutoRebirth or stopAll then continue end
            pcall(function() ReplicatedStorage.Events.Rebirth:FireServer() end)
        else task.wait(1) end
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

-- UI
local Win = WI:CreateWindow({
    Title = "装载卡车",
    Icon = "solar:truck-bold",
    Size = UDim2.fromOffset(400, 440),
    Acrylic = true,
})

Win:Tab({Title = "公告", Icon = "solar:home-bold"}):Paragraph({
    Title = "黑脚本--功能说明",
    Desc = "禁止睡觉 | AFK | 自动重生\n自动装货 | 双端自定义时间\n一键透视 | 调速度\n\n版本：" .. VERSION
})

local t1 = Win:Tab({Title = "主要", Icon = "solar:play-bold"})
t1:Toggle({Title = "禁止工人睡觉", Value = false, Callback = function(v) Settings.NoSleep = v end})
t1:Divider()
t1:Toggle({Title = "AFK模式", Value = false, Callback = function(v) Settings.AFK = v end})

local t2 = Win:Tab({Title = "定位", Icon = "solar:map-point-bold"})
t2:Button({Title = "定位传送带尾端", Justify = "Center", Color = Color3.fromHex("#4CAF50"), Callback = locateBelt})
t2:Divider()
t2:Button({Title = "定位卡车尾端", Justify = "Center", Color = Color3.fromHex("#2196F3"), Callback = locateTruck})
t2:Divider()
t2:Button({Title = "清除所有定位", Justify = "Center", Color = Color3.fromHex("#ff4444"), Callback = clearPositions})

local t3 = Win:Tab({Title = "自动", Icon = "solar:rocket-bold"})
t3:Toggle({Title = "自动装货送卡车", Value = false, Callback = function(v) Settings.AutoLoad = v if v then if not savedPositions.beltPos or not savedPositions.truckPos then WI:Notify({Title="错误", Content="请先定位两个位置！", Duration=3}) Settings.AutoLoad = false end end end})
t3:Divider()
t3:Input({Title = "传送带等待(秒)", Value = "5", Callback = function(v) local n = tonumber(v) if n and n >= 1 then Settings.BeltDelay = n end end})
t3:Divider()
t3:Input({Title = "卡车等待(秒)", Value = "5", Callback = function(v) local n = tonumber(v) if n and n >= 1 then Settings.TruckDelay = n end end})
t3:Divider()
t3:Toggle({Title = "自动重生", Value = false, Callback = function(v) Settings.AutoRebirth = v end})
t3:Paragraph({Title = "说明", Desc = "每60秒自动重生一次"})

local t4 = Win:Tab({Title = "玩家", Icon = "solar:user-bold"})
t4:Toggle({Title = "开启透视", Value = false, Callback = function(v) Settings.ESP_Enabled = v if not v then clearESP() end end})
t4:Divider()
t4:Input({Title = "移动速度", Value = "16", Callback = function(v) local n = tonumber(v) if n and n >= 10 and n <= 50 then Settings.WalkSpeed = n end end})
t4:Divider()
t4:Button({Title = "重置速度", Justify = "Center", Color = Color3.fromHex("#888888"), Callback = function() Settings.WalkSpeed = 16 end})

Win:Tab({Title = "设置", Icon = "solar:settings-bold"}):Button({
    Title = "关闭脚本", Justify = "Center", Color = Color3.fromHex("#ff4444"),
    Callback = function()
        stopAll = true
        for k, _ in pairs(Settings) do if type(Settings[k]) == "boolean" then Settings[k] = false end end
        Settings.WalkSpeed = 16
        clearESP() setSpeed(16)
        pcall(function() local g = game:GetService("CoreGui"):FindFirstChild("WindUI") if g then g:Destroy() end end)
    end
})

WI:Notify({Title = "装载卡车", Content = VERSION .. " 加载完成", Duration = 5})
print("装载卡车 " .. VERSION .. " 已加载")
