-- 割草冒险 脚本 v1.0.2
-- WindUI蓝白版 | 删除草 | 自动点击 | 自动售卖 | 自动重生 | 飞行 | 透视玩家

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
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Settings = {
    AutoClick = false,
    AutoSell = false,
    AutoRebirth = false,
    PlayerESP = false,
}

local playerHighlights = {}
local playerNameTags = {}
local cachedPlayers = {}
local lastPlayerScan = 0

local clickDelay = 0.01
local sellDelay = 5
local rebirthDelay = 5

local function getAllPlayers()
    local players = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(players, plr)
        end
    end
    return players
end

local function clearPlayerESP()
    for _, h in pairs(playerHighlights) do pcall(function() h:Destroy() end) end
    for _, t in pairs(playerNameTags) do pcall(function() t:Destroy() end) end
    table.clear(playerHighlights)
    table.clear(playerNameTags)
    table.clear(cachedPlayers)
end

local function updatePlayerESP()
    if not Settings.PlayerESP then
        clearPlayerESP()
        return
    end
    
    local currentTime = tick()
    if currentTime - lastPlayerScan > 5 then
        clearPlayerESP()
        cachedPlayers = getAllPlayers()
        lastPlayerScan = currentTime
        
        for _, plr in pairs(cachedPlayers) do
            if plr.Character and plr.Character.Parent then
                local head = plr.Character:FindFirstChild("Head")
                local rootPart = plr.Character:FindFirstChild("HumanoidRootPart")
                
                if head and rootPart then
                    local h = Instance.new("Highlight")
                    h.FillColor = Color3.fromRGB(0, 0, 255)
                    h.FillTransparency = 0.4
                    h.OutlineColor = Color3.fromRGB(0, 0, 255)
                    h.OutlineTransparency = 0.2
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.Parent = plr.Character
                    playerHighlights[plr] = h
                    
                    local bg = Instance.new("BillboardGui")
                    bg.Size = UDim2.new(0, 200, 0, 40)
                    bg.AlwaysOnTop = true
                    bg.MaxDistance = math.huge
                    bg.Parent = head
                    
                    local l = Instance.new("TextLabel")
                    l.Size = UDim2.new(1, 0, 1, 0)
                    l.BackgroundTransparency = 1
                    l.Text = plr.Name
                    l.TextColor3 = Color3.fromRGB(0, 0, 255)
                    l.Font = Enum.Font.GothamBold
                    l.TextSize = 14
                    l.TextStrokeTransparency = 0.5
                    l.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    l.Parent = bg
                    playerNameTags[plr] = bg
                end
            end
        end
    end
end

RunService.Heartbeat:Connect(updatePlayerESP)

local Window = WindUI:CreateWindow({
    Title = "加一割草冒险",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(600, 350),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true,
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "加一割草冒险 v1.0.2",
    Desc = "功能：删除草 | 自动点击 | 自动售卖 | 自动重生 | 飞行 | 透视玩家\n\n由于服务器增加反作弊，暂无传送终点等功能"
})

local MainTab = Window:Tab({Title = "主要功能", Icon = "solar:star-bold"})

MainTab:Button({
    Title = "删除所有草",
    Callback = function()
        local count = 0
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name and obj.Name:lower():find("grass") then
                pcall(function() obj:Destroy() count = count + 1 end)
            end
        end
        WindUI:Notify({Title = "删除完成", Content = "已删除 " .. count .. " 个草", Duration = 2})
    end
})

MainTab:Divider()

MainTab:Toggle({
    Title = "自动点击",
    Value = false,
    Callback = function(v) Settings.AutoClick = v end
})

MainTab:Slider({
    Title = "点击延迟",
    Value = {Min = 0.01, Max = 0.1, Default = 0.01},
    Step = 0.01,
    Callback = function(v) clickDelay = v end
})

MainTab:Divider()

MainTab:Toggle({
    Title = "自动售卖",
    Value = false,
    Callback = function(v) Settings.AutoSell = v end
})

MainTab:Slider({
    Title = "售卖延迟",
    Value = {Min = 1, Max = 10, Default = 5},
    Step = 1,
    Callback = function(v) sellDelay = v end
})

MainTab:Divider()

MainTab:Toggle({
    Title = "自动重生",
    Value = false,
    Callback = function(v) Settings.AutoRebirth = v end
})

MainTab:Slider({
    Title = "重生延迟",
    Value = {Min = 1, Max = 10, Default = 5},
    Step = 1,
    Callback = function(v) rebirthDelay = v end
})

local PlayerTab = Window:Tab({Title = "玩家", Icon = "solar:user-bold"})

PlayerTab:Button({
    Title = "飞行",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/飞饼"))()
        WindUI:Notify({Title = "飞行", Content = "飞行脚本已加载", Duration = 2})
    end
})

PlayerTab:Divider()

PlayerTab:Toggle({
    Title = "透视玩家",
    Value = false,
    Callback = function(v)
        Settings.PlayerESP = v
        if not v then clearPlayerESP() end
    end
})

local SettingsTab = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})
local statusPara = SettingsTab:Paragraph({Title = "功能状态", Desc = "加载中..."})

task.spawn(function()
    while true do
        if Settings.AutoClick then
            local Event = ReplicatedStorage:FindFirstChild("Packages")
            if Event then
                local Index = Event:FindFirstChild("_Index")
                if Index then
                    local acecateer = Index:FindFirstChild("acecateer_knit@1.7.2")
                    if acecateer then
                        local knit = acecateer:FindFirstChild("knit")
                        if knit then
                            local Services = knit:FindFirstChild("Services")
                            if Services then
                                local StrengthService = Services:FindFirstChild("StrengthService")
                                if StrengthService then
                                    local RE = StrengthService:FindFirstChild("RE")
                                    if RE then
                                        local ClickRequested = RE:FindFirstChild("ClickRequested")
                                        if ClickRequested then
                                            pcall(function() ClickRequested:FireServer() end)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            task.wait(clickDelay)
        else
            task.wait(0.5)
        end
    end
end)

task.spawn(function()
    while true do
        if Settings.AutoSell then
            local Event = ReplicatedStorage:FindFirstChild("Packages")
            if Event then
                local Index = Event:FindFirstChild("_Index")
                if Index then
                    local acecateer = Index:FindFirstChild("acecateer_knit@1.7.2")
                    if acecateer then
                        local knit = acecateer:FindFirstChild("knit")
                        if knit then
                            local Services = knit:FindFirstChild("Services")
                            if Services then
                                local DataService = Services:FindFirstChild("DataService")
                                if DataService then
                                    local RF = DataService:FindFirstChild("RF")
                                    if RF then
                                        local SellAllBackpackLoot = RF:FindFirstChild("SellAllBackpackLoot")
                                        if SellAllBackpackLoot then
                                            pcall(function() SellAllBackpackLoot:InvokeServer() end)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            task.wait(sellDelay)
        else
            task.wait(0.5)
        end
    end
end)

task.spawn(function()
    while true do
        if Settings.AutoRebirth then
            local Event = ReplicatedStorage:FindFirstChild("Packages")
            if Event then
                local Index = Event:FindFirstChild("_Index")
                if Index then
                    local acecateer = Index:FindFirstChild("acecateer_knit@1.7.2")
                    if acecateer then
                        local knit = acecateer:FindFirstChild("knit")
                        if knit then
                            local Services = knit:FindFirstChild("Services")
                            if Services then
                                local RebirtService = Services:FindFirstChild("RebirtService")
                                if RebirtService then
                                    local RE = RebirtService:FindFirstChild("RE")
                                    if RE then
                                        local RebirthButtonClicked = RE:FindFirstChild("RebirthButtonClicked")
                                        if RebirthButtonClicked then
                                            pcall(function() RebirthButtonClicked:FireServer() end)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            task.wait(rebirthDelay)
        else
            task.wait(0.5)
        end
    end
end)

task.spawn(function()
    while true do
        local grassCount = 0
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name and obj.Name:lower():find("grass") then
                grassCount = grassCount + 1
            end
        end
        local status = ""
        status = status .. "草数量: " .. grassCount .. "\n"
        status = status .. "自动点击: " .. (Settings.AutoClick and "已开启" or "未开启") .. "\n"
        status = status .. "自动售卖: " .. (Settings.AutoSell and "已开启" or "未开启") .. "\n"
        status = status .. "自动重生: " .. (Settings.AutoRebirth and "已开启" or "未开启") .. "\n"
        status = status .. "透视玩家: " .. (Settings.PlayerESP and "已开启" or "未开启") .. "\n"
        status = status .. "帧率: " .. math.floor(1 / task.wait()) .. " FPS"
        statusPara:SetDesc(status)
        task.wait(1)
    end
end)

SettingsTab:Button({
    Title = "关闭面板",
    Callback = function()
        Window:Close()
    end
})

Window:OnClose(function()
    clearPlayerESP()
end)

WindUI:Notify({
    Title = "割草冒险",
    Content = "v1.0.2 加载完成",
    Duration = 3
})
