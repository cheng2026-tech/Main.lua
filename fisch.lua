-- Fisch 脚本 v1.0
-- WindUI版 | 自动售卖 | 透视 | 无限跳 | 调速度
local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Settings = {
    AutoSell = false,
    SellDelay = 10,
    ESP_Enabled = false,
    InfiniteJump = false,
    WalkSpeed = 16,
}

local VERSION = "v1.0"
local stopAll = false
local highlights = {}
local nameTags = {}

-- ==================== 自动售卖 ====================
task.spawn(function()
    while true do
        if Settings.AutoSell and not stopAll then
            task.wait(Settings.SellDelay)
            if not Settings.AutoSell or stopAll then continue end
            pcall(function()
                ReplicatedStorage.events.SellAll:InvokeServer({
                    voice = 12,
                    uid = "merchant_moosewood",
                    idle = workspace.world.npcs["Marc Merchant"].description.idle,
                    npc = workspace.world.npcs["Marc Merchant"]
                })
            end)
        else
            task.wait(1)
        end
    end
end)

-- ==================== 无限跳 ====================
UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ==================== ESP ====================
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

-- ==================== 速度 ====================
local function setSpeed(s)
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = s end
end

RunService.Heartbeat:Connect(function()
    if Settings.WalkSpeed ~= 16 then setSpeed(Settings.WalkSpeed) end
end)

-- ==================== UI ====================
local Win = WI:CreateWindow({
    Title = "Fisch",
    Icon = "solar:fishing-bold",
    Size = UDim2.fromOffset(400, 440),
    Acrylic = true,
})

-- 公告
Win:Tab({Title = "公告", Icon = "solar:home-bold"}):Paragraph({
    Title = "黑脚本--功能说明",
    Desc = "自动售卖 | 可调延迟\n透视 | 无限跳 | 调速度\n\n版本：" .. VERSION
})

-- 自动
local t1 = Win:Tab({Title = "自动", Icon = "solar:play-bold"})
t1:Toggle({
    Title = "自动售卖",
    Value = false,
    Callback = function(v) Settings.AutoSell = v end
})
t1:Divider()
t1:Input({
    Title = "售卖间隔(秒)",
    Value = "10",
    Callback = function(v)
        local n = tonumber(v)
        if n and n >= 0 and n <= 100 then Settings.SellDelay = n end
    end
})
t1:Paragraph({
    Title = "⚠️ 警告",
    Desc = "此脚本没有绕过反作弊\n使用可能会被踢出游戏！\n风险自负！"
})

-- 玩家
local t2 = Win:Tab({Title = "玩家", Icon = "solar:user-bold"})
t2:Toggle({
    Title = "开启透视",
    Value = false,
    Callback = function(v) Settings.ESP_Enabled = v if not v then clearESP() end end
})
t2:Divider()
t2:Toggle({
    Title = "无限跳跃",
    Value = false,
    Callback = function(v) Settings.InfiniteJump = v end
})
t2:Divider()
t2:Input({
    Title = "移动速度",
    Value = "16",
    Callback = function(v)
        local n = tonumber(v)
        if n and n >= 10 and n <= 100 then Settings.WalkSpeed = n end
    end
})
t2:Divider()
t2:Button({
    Title = "重置速度",
    Justify = "Center",
    Color = Color3.fromHex("#888888"),
    Callback = function() Settings.WalkSpeed = 16 end
})

-- 设置
Win:Tab({Title = "设置", Icon = "solar:settings-bold"}):Button({
    Title = "关闭脚本",
    Justify = "Center",
    Color = Color3.fromHex("#ff4444"),
    Callback = function()
        stopAll = true
        Settings.AutoSell = false
        Settings.ESP_Enabled = false
        Settings.InfiniteJump = false
        clearESP()
        setSpeed(16)
        pcall(function() local g = game:GetService("CoreGui"):FindFirstChild("WindUI") if g then g:Destroy() end end)
    end
})

WI:Notify({Title = "Fisch", Content = VERSION .. " 加载完成", Duration = 5})
print("Fisch " .. VERSION .. " 已加载")
