-- 河北唐县 脚本 v2.0
-- WindUI蓝白版 | 远程买车 | 冰淇淋刷钱 | 传送玩家 | 透视 | 调速度

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
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Settings = {
    AutoIceCream = false,
    ESP_Enabled = false,
    WalkSpeed = 16,
}

local VERSION = "v2.0"
local stopAll = false
local firstRun = true
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

local function interactNearby()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local p = obj.Parent
            if p and p:IsA("BasePart") and (root.Position - p.Position).Magnitude < 20 then
                pcall(function() fireproximityprompt(obj) end)
            end
        end
        if obj:IsA("ClickDetector") then
            local p = obj.Parent
            if p and p:IsA("BasePart") and (root.Position - p.Position).Magnitude < 20 then
                pcall(function() fireclickdetector(obj) end)
            end
        end
    end
end

local function buyCar()
    local returnPos = getPos()
    if not returnPos then return end
    tp(Vector3.new(-3307, 11.8, 3799))
    task.wait(2)
    local t = tick()
    while tick() - t < 2 do interactNearby(); task.wait(0.05) end
    task.wait(0.3)
    tp(returnPos)
end

task.spawn(function()
    while true do
        if Settings.AutoIceCream and not stopAll then
            if firstRun then
                pcall(function() ReplicatedStorage.Feature_RemoteEvent.TeamSwitch:FireServer("Mixue Ice Cream") end)
                task.wait(2)
                firstRun = false
            end
            if not Settings.AutoIceCream or stopAll then continue end
            pcall(function() ReplicatedStorage.JobDataEvent:FireServer("GrabCone") end)
            task.wait(0.3)
            if not Settings.AutoIceCream or stopAll then continue end
            pcall(function() ReplicatedStorage.JobDataEvent:FireServer("FillCone") end)
            task.wait(0.3)
            if not Settings.AutoIceCream or stopAll then continue end
            pcall(function()
                local function GetNil(Name, DebugId)
                    for _, Object in getnilinstances() do
                        if Object.Name == Name and Object:GetDebugId() == DebugId then return Object end
                    end
                end
                ReplicatedStorage.JobDataEvent:FireServer("ServeCustomer", GetNil("Customer5", "0_471794"))
            end)
            task.wait(0.5)
        else
            task.wait(1)
        end
    end
end)

local function clearESP()
    for _, h in pairs(highlights) do pcall(function() h:Destroy() end) end
    for _, t in pairs(nameTags) do pcall(function() t:Destroy() end) end
    table.clear(highlights)
    table.clear(nameTags)
end

RunService.Heartbeat:Connect(function()
    if not Settings.ESP_Enabled then clearESP() return end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char or not char:FindFirstChild("Head") then continue end
        local h = Instance.new("Highlight")
        h.FillColor = Color3.fromRGB(255, 100, 100); h.FillTransparency = 0.5
        h.OutlineColor = Color3.fromRGB(255, 50, 50); h.OutlineTransparency = 0.3; h.Parent = char
        table.insert(highlights, h)
        local bg = Instance.new("BillboardGui")
        bg.Size = UDim2.new(0, 120, 0, 25); bg.AlwaysOnTop = true; bg.MaxDistance = math.huge; bg.Parent = char.Head
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 1, 0); l.BackgroundTransparency = 1
        l.Text = plr.Name; l.TextColor3 = Color3.fromRGB(255, 255, 255)
        l.Font = Enum.Font.GothamBold; l.TextSize = 14
        l.TextStrokeTransparency = 0.5; l.TextStrokeColor3 = Color3.fromRGB(0, 0, 0); l.Parent = bg
        table.insert(nameTags, bg)
    end
end)

local function setSpeed(s)
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = s end
end
task.spawn(function() while true do if Settings.WalkSpeed ~= 16 then setSpeed(Settings.WalkSpeed) end task.wait(0.05) end end)

local function getPlayerNames()
    local names = {}
    for _, plr in pairs(Players:GetPlayers()) do if plr ~= LocalPlayer then table.insert(names, plr.Name) end end
    if #names == 0 then table.insert(names, "无其他玩家") end
    return names
end

local Window = WindUI:CreateWindow({
    Title = "河北唐县", Icon = "rbxassetid://129260712070622", IconThemed = true,
    Size = UDim2.fromOffset(400, 440), Theme = "冰白", Transparent = true,
})

Window:Tab({Title = "公告", Icon = "info"}):Paragraph({
    Title = "黑脚本--功能说明",
    Desc = "远程买车 | 冰淇淋刷钱\n传送玩家 | 透视 | 调速度\n\n版本：" .. VERSION,
})

local Tab1 = Window:Tab({Title = "主要", Icon = "play"})
Tab1:Button({Title = "远程买车", Callback = buyCar})
Tab1:Paragraph({Title = "说明", Desc = "远程买车很好用"})
Tab1:Divider()
Tab1:Toggle({Title = "冰淇淋刷钱", Value = false, Callback = function(v) Settings.AutoIceCream = v; if v then firstRun = true end end})
Tab1:Paragraph({Title = "说明", Desc = "首次加入Mixue→拿甜筒→装满→服务顾客"})

local playerNames = getPlayerNames()
local selectedPlayer = playerNames[1] or "无其他玩家"
local Tab2 = Window:Tab({Title = "玩家", Icon = "users"})
Tab2:Toggle({Title = "开启透视", Value = false, Callback = function(v) Settings.ESP_Enabled = v; if not v then clearESP() end end})
Tab2:Dropdown({Title = "选择玩家", Values = playerNames, Value = selectedPlayer, Callback = function(v) selectedPlayer = v end})
Tab2:Button({Title = "传送到该玩家", Callback = function() for _, plr in pairs(Players:GetPlayers()) do if plr.Name == selectedPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then tp(plr.Character.HumanoidRootPart.Position) end end end})
Tab2:Input({Title = "移动速度", Value = "16", Callback = function(v) local n = tonumber(v) if n and n >= 0 and n <= 100 then Settings.WalkSpeed = n end end})
Tab2:Button({Title = "重置速度", Callback = function() Settings.WalkSpeed = 16 end})

Window:Tab({Title = "设置", Icon = "settings"}):Button({Title = "关闭脚本", Callback = function() stopAll = true; Settings.AutoIceCream = false; Settings.ESP_Enabled = false; clearESP(); setSpeed(16); Window:Close() end})
Window:OnClose(function() stopAll = true; Settings.AutoIceCream = false; Settings.ESP_Enabled = false; clearESP(); setSpeed(16) end)

WindUI:Notify({Title = "河北唐县", Content = VERSION .. " 加载完成", Duration = 3})
