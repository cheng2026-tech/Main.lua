-- 🌙 俄亥俄州 | V1.2

local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Camera = Workspace.CurrentCamera
local VirtualInputManager = game:GetService("VirtualInputManager")

-- 反反作弊（轻量版）
local antiCheatEnabled = false
local function EnableAntiCheat()
    task.spawn(function()
        while antiCheatEnabled and task.wait(3) do
            pcall(function()
                for _, name in ipairs({"AntiCheat", "AC", "Anti", "Detector", "Ban", "Kick"}) do
                    local rs = game:GetService("ReplicatedStorage")
                    if rs:FindFirstChild(name) then rs[name]:Destroy() end
                    if Workspace:FindFirstChild(name) then Workspace[name]:Destroy() end
                    if LocalPlayer.PlayerScripts:FindFirstChild(name) then LocalPlayer.PlayerScripts[name]:Destroy() end
                    if LocalPlayer.PlayerGui:FindFirstChild(name) then LocalPlayer.PlayerGui[name]:Destroy() end
                end
            end)
        end
    end)
end

-- 变量
local atmESP = false
local atmESPColor = Color3.fromRGB(0, 255, 100)
local atmESPObjects = {}

local autoATM = false
local atmStayTime = 3
local atmCooldown = {}
local atmRunning = false

local playerESP = false
local playerESPColor = Color3.fromRGB(255, 50, 50)
local showDistance = false
local playerESPObjects = {}

local speedBoost = false
local speedValue = 50

local aimbotEnabled = false
local aimbotTarget = "Head"
local aimbotSmoothness = 5
local aimbotFOV = 200

local autoRespawn = false
local lastDeathPos = nil

local selectedPlayerName = ""

-- ==================== 原地复活 ====================
LocalPlayer.CharacterAdded:Connect(function(char)
    if not autoRespawn then return end
    if lastDeathPos then
        task.wait(0.3)
        pcall(function()
            local hrp = char:WaitForChild("HumanoidRootPart", 3)
            if hrp then
                hrp.CFrame = CFrame.new(lastDeathPos)
                WI:Notify({Title = "原地复活", Content = "已传回死亡位置", Duration = 2})
            end
        end)
    end
end)

spawn(function()
    while true do
        if autoRespawn then
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hum and hrp and hum.Health > 0 then
                    lastDeathPos = hrp.Position
                end
            end
        end
        task.wait(0.5)
    end
end)

-- ==================== ATM透视 ====================
local function clearATM()
    for _, obj in ipairs(atmESPObjects) do pcall(function() obj:Destroy() end) end
    atmESPObjects = {}
end

local function refreshATM()
    clearATM()
    if not atmESP then return end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("Model") and obj.Name == "ATM" then
                local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildOfClass("BasePart")
                if not root then
                    for _, child in ipairs(obj:GetDescendants()) do
                        if child:IsA("BasePart") then root = child; break end
                    end
                end
                if root then
                    local hl = Instance.new("Highlight")
                    hl.FillColor = atmESPColor
                    hl.FillTransparency = 0.3
                    hl.OutlineColor = atmESPColor
                    hl.OutlineTransparency = 0.2
                    hl.Adornee = obj
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = obj
                    table.insert(atmESPObjects, hl)

                    local bb = Instance.new("BillboardGui")
                    bb.Size = UDim2.new(0, 150, 0, 30)
                    bb.StudsOffset = Vector3.new(0, 3, 0)
                    bb.AlwaysOnTop = true
                    bb.Adornee = root
                    bb.Parent = root
                    table.insert(atmESPObjects, bb)

                    local lb = Instance.new("TextLabel")
                    lb.Size = UDim2.new(1, 0, 1, 0)
                    lb.BackgroundTransparency = 1
                    lb.Text = "ATM"
                    lb.TextColor3 = atmESPColor
                    lb.TextStrokeTransparency = 0
                    lb.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    lb.Font = Enum.Font.SourceSansBold
                    lb.TextSize = 18
                    lb.Parent = bb
                end
            end
        end)
    end
end

task.spawn(function()
    while task.wait(1.5) do
        pcall(function()
            if atmESP then refreshATM() else clearATM() end
        end)
    end
end)

-- ==================== 自动ATM ====================
local function findNearestATM(hrp)
    local best, bestD = nil, math.huge
    for _, obj in ipairs(Workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("Model") and obj.Name == "ATM" then
                local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildOfClass("BasePart")
                if not root then
                    for _, child in ipairs(obj:GetDescendants()) do
                        if child:IsA("BasePart") then root = child; break end
                    end
                end
                if root then
                    local d = (hrp.Position - root.Position).Magnitude
                    if d < bestD then bestD = d; best = {root = root, atm = obj} end
                end
            end
        end)
    end
    return best
end

task.spawn(function()
    while task.wait(0.3) do
        if not autoATM or atmRunning then continue end
        local char = LocalPlayer.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        atmRunning = true
        local nearest = findNearestATM(hrp)
        if nearest then
            local now = tick()
            if not atmCooldown[nearest.atm] or (now - atmCooldown[nearest.atm]) > 15 then
                pcall(function() hrp.CFrame = nearest.root.CFrame * CFrame.new(0, 0, 3) end)
                atmCooldown[nearest.atm] = tick()
                task.wait(0.3)
                local endT = tick() + atmStayTime
                while tick() < endT and autoATM do
                    pcall(function() VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0) end)
                    task.wait(0.05)
                    pcall(function() VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0) end)
                    task.wait(0.1)
                end
            end
        end
        atmRunning = false
    end
end)

-- ==================== 玩家透视 ====================
local function clearPlayer()
    for _, obj in ipairs(playerESPObjects) do pcall(function() obj:Destroy() end) end
    playerESPObjects = {}
end

local function refreshPlayer()
    clearPlayer()
    if not playerESP then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            pcall(function()
                local c = plr.Character
                local root = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Head")
                if not root then return end
                local hl = Instance.new("Highlight")
                hl.FillColor = playerESPColor
                hl.FillTransparency = 0.3
                hl.OutlineColor = playerESPColor
                hl.OutlineTransparency = 0.2
                hl.Adornee = c
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = c
                table.insert(playerESPObjects, hl)
                local bb = Instance.new("BillboardGui")
                bb.Size = UDim2.new(0, 200, 0, 30)
                bb.StudsOffset = Vector3.new(0, 3, 0)
                bb.AlwaysOnTop = true
                bb.Adornee = root
                bb.Parent = root
                table.insert(playerESPObjects, bb)
                local lb = Instance.new("TextLabel")
                lb.Size = UDim2.new(1, 0, 1, 0)
                lb.BackgroundTransparency = 1
                lb.Text = plr.Name
                lb.TextColor3 = playerESPColor
                lb.TextStrokeTransparency = 0
                lb.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                lb.Font = Enum.Font.SourceSansBold
                lb.TextSize = 16
                lb.Parent = bb
                if showDistance then
                    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if myRoot then
                        local d = math.floor((myRoot.Position - root.Position).Magnitude)
                        local db = Instance.new("BillboardGui")
                        db.Size = UDim2.new(0, 100, 0, 20)
                        db.StudsOffset = Vector3.new(0, -1.5, 0)
                        db.AlwaysOnTop = true
                        db.Adornee = root
                        db.Parent = root
                        table.insert(playerESPObjects, db)
                        local dl = Instance.new("TextLabel")
                        dl.Size = UDim2.new(1, 0, 1, 0)
                        dl.BackgroundTransparency = 1
                        dl.Text = d .. "m"
                        dl.TextColor3 = Color3.fromRGB(255, 255, 255)
                        dl.TextStrokeTransparency = 0
                        dl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        dl.Font = Enum.Font.SourceSansBold
                        dl.TextSize = 14
                        dl.Parent = db
                    end
                end
            end)
        end
    end
end

task.spawn(function()
    while task.wait(1.5) do
        pcall(function()
            if playerESP then refreshPlayer() else clearPlayer() end
        end)
    end
end)

-- ==================== 速度（每帧刷新）====================
RunService.RenderStepped:Connect(function()
    if speedBoost then
        pcall(function()
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then
                c.Humanoid.WalkSpeed = speedValue
            end
        end)
    end
end)

-- ==================== 自瞄 ====================
local aimbotLock = false
RunService.RenderStepped:Connect(function()
    if not aimbotEnabled or aimbotLock then return end
    aimbotLock = true
    pcall(function()
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local best, bestD = nil, aimbotFOV
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local t = p.Character:FindFirstChild(aimbotTarget)
                local h = p.Character:FindFirstChild("Humanoid")
                if t and h and h.Health > 0 then
                    local sp, on = Camera:WorldToViewportPoint(t.Position)
                    if on then
                        local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if d < bestD then bestD = d; best = p end
                    end
                end
            end
        end
        if best and best.Character then
            local tp = best.Character:FindFirstChild(aimbotTarget)
            if tp then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, tp.Position), aimbotSmoothness / 15)
            end
        end
    end)
    aimbotLock = false
end)

-- ==================== 传送玩家 ====================
local function getNames()
    local n = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(n, p.Name) end
    end
    if #n == 0 then table.insert(n, "无玩家") end
    return n
end

local function tpPlayer(name)
    if not name or name == "" or name == "无玩家" then return end
    local t = Players:FindFirstChild(name)
    if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
        local c = LocalPlayer.Character
        if c and c:FindFirstChild("HumanoidRootPart") then
            c.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, 0)
            WI:Notify({Title = "传送成功", Content = name, Duration = 2})
        end
    end
end

-- ==================== 冰白主题 ====================
WI:AddTheme({
    Name = "冰白",
    Accent = "#80C0FF",
    Outline = "#6090C0",
    Text = "#FFFFFF",
    Placeholder = "#D0E0FF"
})

-- ==================== UI ====================
local Window = WI:CreateWindow({
    Title = "俄亥俄州",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(500, 420),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true
})

-- 公告
Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--俄亥俄州 V1.2",
    Desc = "ATM透视 | 自动ATM | 传送 | 自瞄\n原地复活 | 性能优化 | 速度不失效"
})

-- 主要功能
local T2 = Window:Tab({Title = "主要功能", Icon = "solar:star-bold"})
T2:Section({Title = "反反作弊"})
T2:Toggle({Title = "开启反作弊", Value = false, Callback = function(v) antiCheatEnabled = v; if v then EnableAntiCheat() end end})
T2:Section({Title = "ATM透视"})
T2:Toggle({Title = "透视ATM机", Value = false, Callback = function(v) atmESP = v end})
T2:Colorpicker({Title = "ATM颜色", Default = Color3.fromRGB(0, 255, 100), Callback = function(c) atmESPColor = c end})
T2:Section({Title = "自动ATM机"})
T2:Toggle({Title = "自动打ATM", Value = false, Callback = function(v) autoATM = v; atmRunning = false; if v then atmCooldown = {} end end})
T2:Slider({Title = "停留时间", Value = {Min = 1, Max = 10, Default = 3}, Callback = function(v) atmStayTime = v end})
T2:Section({Title = "原地复活"})
T2:Toggle({Title = "开启原地复活", Value = false, Callback = function(v) autoRespawn = v end})
T2:Paragraph({Title = "说明", Desc = "检测死亡位置，重生后自动传送回去"})

-- 传送
local T3 = Window:Tab({Title = "传送", Icon = "solar:map-bold"})
T3:Section({Title = "传送玩家"})
local dd = T3:Dropdown({Title = "选择玩家", Values = getNames(), Value = "", Multi = false, AllowNone = true, Callback = function(v)
    if type(v) == "string" then selectedPlayerName = v
    elseif type(v) == "table" and #v > 0 then selectedPlayerName = v[1]
    else selectedPlayerName = "" end
end})
T3:Button({Title = "刷新玩家列表", Justify = "Center", Callback = function()
    local n = getNames(); dd:SetValues(n); dd:SetValue(n[1])
end})
T3:Button({Title = "传送到该玩家", Justify = "Center", Callback = function() tpPlayer(selectedPlayerName) end})
T3:Section({Title = "固定传送"})
T3:Button({Title = "枪店", Justify = "Center", Callback = function() pcall(function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(1553, 6.2, -616.8) end) end})
T3:Button({Title = "珠宝店", Justify = "Center", Callback = function() pcall(function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(1542, 6.2, -680) end) end})
T3:Button({Title = "银行金库", Justify = "Center", Callback = function() pcall(function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(1090, 8.2, -334) end) end})

-- 玩家
local T4 = Window:Tab({Title = "玩家", Icon = "solar:user-bold"})
T4:Section({Title = "透视"})
T4:Toggle({Title = "透视玩家", Value = false, Callback = function(v) playerESP = v end})
T4:Colorpicker({Title = "颜色", Default = Color3.fromRGB(255, 50, 50), Callback = function(c) playerESPColor = c end})
T4:Toggle({Title = "显示距离", Value = false, Callback = function(v) showDistance = v end})
T4:Section({Title = "速度"})
T4:Toggle({Title = "速度加成", Value = false, Callback = function(v) speedBoost = v end})
T4:Slider({Title = "速度值", Value = {Min = 16, Max = 200, Default = 50}, Callback = function(v) speedValue = v end})
T4:Section({Title = "飞行"})
T4:Button({Title = "加载飞行脚本", Justify = "Center", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/飞饼"))() end})
T4:Section({Title = "自瞄"})
T4:Toggle({Title = "开启自瞄", Value = false, Callback = function(v) aimbotEnabled = v end})
T4:Dropdown({Title = "部位", Values = {"Head", "HumanoidRootPart"}, Value = "Head", Multi = false, Callback = function(v) aimbotTarget = v end})
T4:Slider({Title = "平滑度", Value = {Min = 1, Max = 10, Default = 5}, Callback = function(v) aimbotSmoothness = v end})
T4:Slider({Title = "FOV", Value = {Min = 50, Max = 500, Default = 200}, Callback = function(v) aimbotFOV = v end})

Window:OnClose(function()
    clearATM()
    clearPlayer()
end)

WI:Notify({Title = "🌙 俄亥俄州", Content = "V1.2 加载完成", Duration = 3})
print("🌙 俄亥俄州 V1.2 加载完成")
