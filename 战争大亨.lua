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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local Settings = {
    ESP_Players = false,
    RPGAura = false,
    NightVision = false,
    LoopKillAll = false,
    RPGAutoLock = false,
    WalkSpeed = 16,
    SelectedTeam = "delta",
}

local VERSION = "v1.5"
local highlights = {}
local nameTags = {}
local rpgTarget = nil
local loopKillAllConnection = nil

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
    root.CFrame = CFrame.new(pos)
end

local function getNearestPlayer()
    local nearest = nil
    local shortestDistance = math.huge
    local myPos = getPos()
    if not myPos then return nil end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local distance = (myPos - char.HumanoidRootPart.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                nearest = plr
            end
        end
    end
    return nearest
end

local function setNightVision(enabled)
    if enabled then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    else
        Lighting.Brightness = 1
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = true
        Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
    end
end

task.spawn(function()
    while true do
        if Settings.NightVision then
            setNightVision(true)
        end
        task.wait(2)
    end
end)

local function breakShield()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("RPG") then
        WindUI:Notify({Title = "错误", Content = "需要手持RPG！", Duration = 3})
        return
    end
    
    local team = Settings.SelectedTeam
    task.spawn(function()
        for i = 1, 25 do
            pcall(function()
                if team == "delta" then
                    local function GetNil(Name, DebugId)
                        for _, Object in getnilinstances() do
                            if Object.Name == Name and Object:GetDebugId() == DebugId then return Object end
                        end
                    end
                    ReplicatedStorage.RocketSystem.Events.RocketHit:FireServer({
                        Normal = Vector3.new(-0.70713424682617, 0, -0.70707929134369),
                        Player = LocalPlayer,
                        HitPart = GetNil("Shield2", "1_12274073"),
                        Origin = Vector3.new(1336.1254882812, 94.653617858887, -4319.9208984375),
                        Label = "CHANGCHENG66Rocket0",
                        Vehicle = char.RPG,
                        Position = Vector3.new(1729.2888183594, 70.149597167969, -4140.1342773438),
                        Weapon = char.RPG
                    })
                elseif team == "echo" then
                    ReplicatedStorage.RocketSystem.Events.RocketHit:FireServer({
                        Normal = Vector3.new(-0.42259299755096, 0, -0.9063196182251),
                        Player = LocalPlayer,
                        HitPart = workspace.Tycoon.Tycoons.Echo.PurchasedObjects["Base Shield"].Shield.Shield2,
                        Origin = Vector3.new(2438.7231445312, 255.71713256836, -3574.8215332031),
                        Label = "CHANGCHENG66Rocket1",
                        Vehicle = char.RPG,
                        Position = Vector3.new(2642.2507324219, 142.3239440918, -3352.16796875),
                        Weapon = char.RPG
                    })
                elseif team == "kilo" then
                    WindUI:Notify({Title = "提示", Content = "kilo破盾数据待补充", Duration = 3})
                    return
                end
            end)
            task.wait(0.08)
        end
        WindUI:Notify({Title = "✅ 完成", Content = team .. "已破盾！", Duration = 3})
    end)
end

local function fireRPGAtTarget(targetPlayer, shots)
    if not targetPlayer or not targetPlayer.Character then return end
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("RPG") or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local returnPos = getPos()
    if not returnPos then return end
    
    local targetPos = targetRoot.Position
    tp(targetPos + Vector3.new(0, 100, 0))
    
    for i = 1, shots do
        task.wait(0.1)
        pcall(function()
            ReplicatedStorage.RocketSystem.Events.RocketHit:FireServer({
                Normal = Vector3.new(0, -1, 0),
                HitPart = targetRoot,
                Player = LocalPlayer,
                Origin = char.HumanoidRootPart.Position,
                Position = targetRoot.Position,
                Vehicle = char.RPG,
                Label = "RPGAura",
                Weapon = char.RPG
            })
        end)
    end
    
    task.wait(0.2)
    tp(returnPos)
end

local function killAllOnce()
    local players = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(players, plr)
        end
    end
    if #players == 0 then return end
    for _, plr in pairs(players) do
        fireRPGAtTarget(plr, 3)
        task.wait(0.3)
    end
end

local function killAll()
    local players = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(players, plr)
        end
    end
    if #players == 0 then
        WindUI:Notify({Title = "错误", Content = "没有可攻击的玩家！", Duration = 3})
        return
    end
    task.spawn(function()
        killAllOnce()
        WindUI:Notify({Title = "✅ 完成", Content = "已攻击全图 " .. #players .. " 名玩家！", Duration = 3})
    end)
end

local function startLoopKillAll()
    Settings.LoopKillAll = true
    loopKillAllConnection = task.spawn(function()
        while Settings.LoopKillAll do
            killAllOnce()
            task.wait(1)
        end
    end)
    WindUI:Notify({Title = "🔄 持续全图杀", Content = "已开启，点击停止按钮关闭", Duration = 3})
end

local function stopLoopKillAll()
    Settings.LoopKillAll = false
    if loopKillAllConnection then
        task.cancel(loopKillAllConnection)
        loopKillAllConnection = nil
    end
    WindUI:Notify({Title = "⏹ 已停止", Content = "持续全图杀已关闭", Duration = 3})
end

local function killNearest()
    local nearest = getNearestPlayer()
    if not nearest then
        WindUI:Notify({Title = "错误", Content = "附近没有玩家！", Duration = 3})
        return
    end
    fireRPGAtTarget(nearest, 4)
    WindUI:Notify({Title = "✅ 完成", Content = "已攻击最近敌人: " .. nearest.Name, Duration = 3})
end

task.spawn(function()
    while true do
        if Settings.RPGAura and rpgTarget then
            local targetPlayer = nil
            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Name == rpgTarget then targetPlayer = plr; break end
            end
            if targetPlayer then
                fireRPGAtTarget(targetPlayer, 3)
            end
            task.wait(0.5)
        else
            task.wait(1)
        end
    end
end)

task.spawn(function()
    while true do
        if Settings.RPGAutoLock then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("RPG") and char:FindFirstChild("HumanoidRootPart") then
                local nearest = getNearestPlayer()
                if nearest and nearest.Character and nearest.Character:FindFirstChild("HumanoidRootPart") then
                    local targetRoot = nearest.Character.HumanoidRootPart
                    local myRoot = char.HumanoidRootPart
                    
                    myRoot.CFrame = CFrame.new(myRoot.Position, Vector3.new(targetRoot.Position.X, myRoot.Position.Y, targetRoot.Position.Z))
                    
                    pcall(function()
                        ReplicatedStorage.RocketSystem.Events.RocketHit:FireServer({
                            Normal = (targetRoot.Position - myRoot.Position).Unit,
                            HitPart = targetRoot,
                            Player = LocalPlayer,
                            Origin = myRoot.Position,
                            Position = targetRoot.Position,
                            Vehicle = char.RPG,
                            Label = "RPGAutoLock",
                            Weapon = char.RPG
                        })
                    end)
                end
            end
            task.wait(0.05)
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

local function updateESP()
    clearESP()
    if not Settings.ESP_Players then return end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char or not char:FindFirstChild("Head") then continue end
        local h = Instance.new("Highlight")
        h.Name = "ESP_PlayerHL"
        h.FillColor = Color3.fromRGB(70, 255, 70)
        h.FillTransparency = 0.4
        h.OutlineColor = Color3.fromRGB(50, 220, 50)
        h.OutlineTransparency = 0.2
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent = char
        table.insert(highlights, h)
        
        local bg = Instance.new("BillboardGui")
        bg.Name = "ESP_PlayerTag"
        bg.Size = UDim2.new(0, 150, 0, 25)
        bg.AlwaysOnTop = true
        bg.MaxDistance = math.huge
        bg.Adornee = char.Head
        bg.Parent = char.Head
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = plr.Name
        label.TextColor3 = Color3.fromRGB(70, 255, 70)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.TextStrokeTransparency = 0.5
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.Parent = bg
        table.insert(nameTags, bg)
    end
end

local lastESPUpdate = 0
RunService.RenderStepped:Connect(function(deltaTime)
    lastESPUpdate = lastESPUpdate + deltaTime
    if lastESPUpdate >= 0.5 then
        lastESPUpdate = 0
        if Settings.ESP_Players then
            updateESP()
        elseif #highlights > 0 then
            clearESP()
        end
    end
end)

local function setSpeed(s)
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = s end
end
RunService.Heartbeat:Connect(function() if Settings.WalkSpeed ~= 16 then setSpeed(Settings.WalkSpeed) end end)

local function loadFly()
    pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/飞饼"))() end)
end

local function getPlayerNames()
    local names = {}
    for _, plr in pairs(Players:GetPlayers()) do if plr ~= LocalPlayer then table.insert(names, plr.Name) end end
    if #names == 0 then table.insert(names, "无其他玩家") end
    return names
end

local Window = WindUI:CreateWindow({
    Title = "战争大亨", Icon = "rbxassetid://129260712070622", IconThemed = true,
    Size = UDim2.fromOffset(400, 400), Theme = "冰白", Transparent = true,
})

Window:Tab({Title = "公告", Icon = "info"}):Paragraph({
    Title = "黑脚本--战争大亨 " .. VERSION,
    Desc = "智能破盾 | 持续全图杀 | 夜视 | 无冷却锁人",
})

local playerNames = getPlayerNames()
local selectedPlayer = playerNames[1] or "无其他玩家"

local Tab1 = Window:Tab({Title = "主要", Icon = "play"})
Tab1:Dropdown({Title = "选择破盾队伍", Values = {"delta", "echo", "kilo"}, Value = "delta", Callback = function(v) Settings.SelectedTeam = v end})
Tab1:Button({Title = "破盾(本功能仅作者可用)", Callback = breakShield})
Tab1:Divider()
Tab1:Dropdown({Title = "选择目标", Values = playerNames, Value = selectedPlayer, Callback = function(v) rpgTarget = v end})
Tab1:Toggle({Title = "RPG杀戮(选择目标)", Value = false, Callback = function(v) Settings.RPGAura = v end})
Tab1:Divider()
Tab1:Button({Title = "杀最近敌人", Callback = killNearest})
Tab1:Button({Title = "杀全图", Callback = killAll})
Tab1:Divider()
Tab1:Button({Title = "开启持续全图杀(开了爽飞天)", Callback = startLoopKillAll})
Tab1:Button({Title = "停止持续全图杀", Callback = stopLoopKillAll})
Tab1:Divider()
Tab1:Toggle({Title = "RPG无冷却自动锁人", Value = false, Callback = function(v) Settings.RPGAutoLock = v end})

local Tab2 = Window:Tab({Title = "玩家", Icon = "users"})
Tab2:Toggle({Title = "透视玩家", Value = false, Callback = function(v) Settings.ESP_Players = v end})
Tab2:Toggle({Title = "夜视", Value = false, Callback = function(v) Settings.NightVision = v end})
Tab2:Button({Title = "飞行", Callback = loadFly})
Tab2:Dropdown({Title = "选择玩家", Values = playerNames, Value = selectedPlayer, Callback = function(v) selectedPlayer = v end})
Tab2:Button({Title = "传送到该玩家", Callback = function() for _, plr in pairs(Players:GetPlayers()) do if plr.Name == selectedPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then tp(plr.Character.HumanoidRootPart.Position) end end end})
Tab2:Input({Title = "移动速度", Value = "16", Callback = function(v) local n = tonumber(v) if n and n >= 10 and n <= 200 then Settings.WalkSpeed = n end end})
Tab2:Button({Title = "重置速度", Callback = function() Settings.WalkSpeed = 16 end})

Window:Tab({Title = "设置", Icon = "settings"}):Button({Title = "关闭脚本", Callback = function() Settings.ESP_Players = false; Settings.RPGAura = false; Settings.NightVision = false; Settings.LoopKillAll = false; Settings.RPGAutoLock = false; if loopKillAllConnection then task.cancel(loopKillAllConnection) end; clearESP(); setSpeed(16); Window:Close() end})
Window:OnClose(function() Settings.ESP_Players = false; Settings.RPGAura = false; Settings.NightVision = false; Settings.LoopKillAll = false; Settings.RPGAutoLock = false; if loopKillAllConnection then task.cancel(loopKillAllConnection) end; clearESP(); setSpeed(16) end)

WindUI:Notify({Title = "战争大亨", Content = VERSION .. " 加载完成", Duration = 3})
