-- 🌙 一次尘土飞扬的旅行 | V1.2

local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera
local Stats = game:GetService("Stats")

-- 变量
local playerESP = false
local playerESPColor = Color3.fromRGB(255, 50, 50)
local showDistance = false

local mutantESP = false
local mutantESPColor = Color3.fromRGB(255, 100, 0)
local mutantESPRange = 500

local fireMutantESP = false
local fireMutantESPColor = Color3.fromRGB(255, 50, 0)
local fireMutantESPRange = 500

local buffESP = false
local buffESPColor = Color3.fromRGB(50, 255, 200)
local buffESPRange = 500

local carFly = false
local flySpeed = 200

local speedBoost = false
local speedValue = 50

local infiniteJump = false
local hasDoubleJumped = false

local nightVision = false
local nightVisionBrightness = 0.15

local selectedPlayerName = ""

local espCache = {}
local playerESPObjects = {}

-- ==================== 辅助函数 ====================
local function getRoot(obj)
    if obj:IsA("Model") then
        return obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head") or obj:FindFirstChild("Handle")
    elseif obj:IsA("BasePart") then
        return obj
    end
    for _, c in ipairs(obj:GetDescendants()) do
        if c:IsA("BasePart") then return c end
    end
    return nil
end

local function getNames()
    local n = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(n, p.Name) end
    end
    if #n == 0 then table.insert(n, "无玩家") end
    return n
end

-- ==================== 冰白主题 ====================
WI:AddTheme({
    Name = "冰白",
    Accent = "#80C0FF",
    Outline = "#6090C0",
    Text = "#FFFFFF",
    Placeholder = "#D0E0FF"
})

-- ==================== 夜视 ====================
spawn(function()
    local nightEffect = nil
    while true do
        if nightVision then
            pcall(function()
                if not nightEffect then
                    nightEffect = Instance.new("ColorCorrectionEffect")
                    nightEffect.Parent = Lighting
                end
                nightEffect.Brightness = nightVisionBrightness
                nightEffect.Contrast = 0.2
                nightEffect.Saturation = -0.3
                Lighting.Brightness = 1.2
                Lighting.ClockTime = 14
                Lighting.FogEnd = 100000
                Lighting.GlobalShadows = false
            end)
        else
            pcall(function()
                if nightEffect then nightEffect:Destroy(); nightEffect = nil end
                Lighting.Brightness = 1; Lighting.FogEnd = 500; Lighting.GlobalShadows = true
            end)
        end
        task.wait(0.3)
    end
end)

-- ==================== 飞车 ====================
RunService.RenderStepped:Connect(function()
    if carFly then
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end

            local direction = Camera.CFrame.LookVector
            local velocity = direction * flySpeed
            root.Velocity = velocity

            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and obj.Name:find("Car") then
                    local carRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildOfClass("BasePart")
                    if carRoot and (carRoot.Position - root.Position).Magnitude < 15 then
                        carRoot.Velocity = velocity
                    end
                end
            end
        end)
    end
end)

-- ==================== 无限跳 ====================
UserInputService.JumpRequest:Connect(function()
    if not infiniteJump then return end
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if humanoid.FloorMaterial == Enum.Material.Air and not hasDoubleJumped then
        hasDoubleJumped = true
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        root.Velocity = Vector3.new(root.Velocity.X, 50, root.Velocity.Z)
    elseif humanoid.FloorMaterial ~= Enum.Material.Air then
        hasDoubleJumped = false
    end
end)

LocalPlayer.CharacterAdded:Connect(function() hasDoubleJumped = false end)

-- ==================== 速度 ====================
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

-- ==================== ESP系统 ====================
local function ClearESP()
    for _, d in ipairs(espCache) do
        pcall(function() if d.hl then d.hl:Destroy() end if d.bb then d.bb:Destroy() end end)
    end
    espCache = {}
end

local function CreateESP(obj, color, name, dist)
    local root = getRoot(obj)
    if not root then return end

    local hl = Instance.new("Highlight")
    hl.FillColor = color
    hl.FillTransparency = 0.4
    hl.OutlineColor = color
    hl.OutlineTransparency = 0
    hl.Adornee = obj
    hl.Parent = obj
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    table.insert(espCache, {hl = hl})

    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, 200, 0, 30)
    bb.StudsOffset = Vector3.new(0, 2.5, 0)
    bb.AlwaysOnTop = true
    bb.Parent = root
    table.insert(espCache, {bb = bb})

    local nl = Instance.new("TextLabel")
    nl.Size = UDim2.new(1, 0, 1, 0)
    nl.BackgroundTransparency = 1
    nl.TextColor3 = Color3.new(1, 1, 1)
    nl.Text = name
    nl.Font = Enum.Font.SourceSansBold
    nl.TextSize = 14
    nl.TextStrokeTransparency = 0
    nl.TextStrokeColor3 = Color3.new(0, 0, 0)
    nl.Parent = bb

    if dist >= 0 then
        local dl = Instance.new("TextLabel")
        dl.Size = UDim2.new(1, 0, 0, 18)
        dl.Position = UDim2.new(0, 0, 0.55, 0)
        dl.BackgroundTransparency = 1
        dl.TextColor3 = Color3.new(0.8, 0.8, 0.8)
        dl.Text = dist .. "m"
        dl.Font = Enum.Font.SourceSans
        dl.TextSize = 12
        dl.Parent = bb
    end
end

local lastESPUpdate = 0
local function UpdateESP()
    if tick() - lastESPUpdate < 0.5 then return end
    lastESPUpdate = tick()
    ClearESP()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if mutantESP then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == "Mutant" then
                local root = getRoot(obj)
                if root then
                    local d = (hrp.Position - root.Position).Magnitude
                    if d <= mutantESPRange then
                        CreateESP(obj, mutantESPColor, "突变体", math.floor(d))
                    end
                end
            end
        end
    end

    if fireMutantESP then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == "Fire Mutant" then
                local root = getRoot(obj)
                if root then
                    local d = (hrp.Position - root.Position).Magnitude
                    if d <= fireMutantESPRange then
                        CreateESP(obj, fireMutantESPColor, "火焰僵尸", math.floor(d))
                    end
                end
            end
        end
    end

    if buffESP then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == "Buff" then
                local root = getRoot(obj)
                if root then
                    local d = (hrp.Position - root.Position).Magnitude
                    if d <= buffESPRange then
                        CreateESP(obj, buffESPColor, "加特", math.floor(d))
                    end
                end
            end
        end
    end
end

task.spawn(function()
    while task.wait(0.5) do
        pcall(function() UpdateESP() end)
    end
end)

-- ==================== 玩家ESP ====================
local function clearPlayer()
    for _, obj in ipairs(playerESPObjects) do
        pcall(function() obj:Destroy() end)
    end
    playerESPObjects = {}
end

local function refreshPlayerESP()
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
        pcall(function() refreshPlayerESP() end)
    end
end)

-- ==================== 传送函数 ====================
local function teleportToNearest(name, label)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local closest, closestDist = nil, math.huge

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name == name then
            local root = getRoot(obj)
            if root then
                local d = (hrp.Position - root.Position).Magnitude
                if d < closestDist then
                    closestDist = d
                    closest = root
                end
            end
        end
    end

    if closest then
        hrp.CFrame = closest.CFrame * CFrame.new(0, 5, 0)
        WI:Notify({Title = "传送成功", Content = "已到" .. label, Duration = 2})
    else
        WI:Notify({Title = "传送失败", Content = "没找到" .. label, Duration = 2})
    end
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

-- ==================== UI ====================
local Window = WI:CreateWindow({
    Title = "尘土飞扬的旅程",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(500, 380),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--一次尘土飞扬的旅行 V1.2",
    Desc = "飞车(看哪飞哪) | 夜视 | 传送\n透视 | 速度 | 飞行"
})

local T2 = Window:Tab({Title = "主要功能", Icon = "solar:star-bold"})
T2:Section({Title = "飞车"})
T2:Toggle({Title = "开启飞车", Value = false, Callback = function(v) carFly = v end})
T2:Slider({Title = "飞行速度", Value = {Min = 0, Max = 1000, Default = 200}, Step = 10, Callback = function(v) flySpeed = v end})

T2:Section({Title = "夜视"})
T2:Toggle({Title = "开启夜视", Value = false, Callback = function(v) nightVision = v end})
T2:Slider({Title = "夜视亮度", Value = {Min = 0.05, Max = 0.5, Default = 0.15}, Step = 0.01, Callback = function(v) nightVisionBrightness = v end})

T2:Section({Title = "透视"})
T2:Toggle({Title = "透视突变体", Value = false, Callback = function(v) mutantESP = v end})
T2:Colorpicker({Title = "突变体颜色", Default = Color3.fromRGB(255, 100, 0), Callback = function(c) mutantESPColor = c end})
T2:Toggle({Title = "透视火焰僵尸", Value = false, Callback = function(v) fireMutantESP = v end})
T2:Colorpicker({Title = "火焰僵尸颜色", Default = Color3.fromRGB(255, 50, 0), Callback = function(c) fireMutantESPColor = c end})
T2:Toggle({Title = "透视加特", Value = false, Callback = function(v) buffESP = v end})
T2:Colorpicker({Title = "加特颜色", Default = Color3.fromRGB(50, 255, 200), Callback = function(c) buffESPColor = c end})

local T3 = Window:Tab({Title = "传送", Icon = "solar:map-bold"})
T3:Section({Title = "物品传送"})
T3:Button({Title = "传送到Samuel", Justify = "Center", Callback = function() teleportToNearest("Samuel", "Samuel") end})
T3:Button({Title = "传送到公交站", Justify = "Center", Callback = function() teleportToNearest("BusStop", "公交站") end})
T3:Button({Title = "传送到交赏金区", Justify = "Center", Callback = function() teleportToNearest("@SellModel", "交赏金区") end})
T3:Button({Title = "传送到回收厂", Justify = "Center", Callback = function()
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("HumanoidRootPart") then
        c.HumanoidRootPart.CFrame = CFrame.new(63, 6.7, -1355)
        WI:Notify({Title = "传送成功", Content = "已到回收厂", Duration = 2})
    end
end})
T3:Button({Title = "传送到出生点", Justify = "Center", Callback = function()
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("HumanoidRootPart") then
        c.HumanoidRootPart.CFrame = CFrame.new(153, 6.2, 7832)
        WI:Notify({Title = "传送成功", Content = "已到出生点", Duration = 2})
    end
end})

T3:Section({Title = "传送玩家"})
local dd = T3:Dropdown({Title = "选择玩家", Values = getNames(), Value = "", Multi = false, AllowNone = true, Callback = function(v)
    if type(v) == "string" then selectedPlayerName = v
    elseif type(v) == "table" and #v > 0 then selectedPlayerName = v[1]
    else selectedPlayerName = "" end
end})
T3:Button({Title = "刷新列表", Justify = "Center", Callback = function()
    local n = getNames(); dd:SetValues(n); dd:SetValue(n[1])
end})
T3:Button({Title = "传送到该玩家", Justify = "Center", Callback = function() tpPlayer(selectedPlayerName) end})

local T4 = Window:Tab({Title = "玩家", Icon = "solar:user-bold"})
T4:Section({Title = "透视"})
T4:Toggle({Title = "透视所有玩家", Value = false, Callback = function(v) playerESP = v end})
T4:Colorpicker({Title = "颜色", Default = Color3.fromRGB(255, 50, 50), Callback = function(c) playerESPColor = c end})
T4:Toggle({Title = "显示距离", Value = false, Callback = function(v) showDistance = v end})
T4:Section({Title = "无限跳"})
T4:Toggle({Title = "开启无限跳", Value = false, Callback = function(v) infiniteJump = v; hasDoubleJumped = false end})
T4:Section({Title = "速度"})
T4:Toggle({Title = "速度加成", Value = false, Callback = function(v) speedBoost = v end})
T4:Slider({Title = "速度值", Value = {Min = 16, Max = 200, Default = 50}, Callback = function(v) speedValue = v end})
T4:Section({Title = "飞行"})
T4:Button({Title = "加载飞行脚本", Justify = "Center", Callback = function()
    pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/飞饼"))() end)
    WI:Notify({Title = "飞行", Content = "已加载", Duration = 2})
end})

-- 设置（实时状态+帧率）
local T5 = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})
local statusParagraph = T5:Paragraph({Title = "功能状态", Desc = "加载中..."})

spawn(function()
    while true do
        pcall(function()
            local fps = math.floor(1 / (RunService.RenderStepped:Wait() or 0.016))
            local status = "FPS: " .. fps .. "\n\n" ..
                "飞车: " .. (carFly and "✅" or "❌") .. "  夜视: " .. (nightVision and "✅" or "❌") .. "\n" ..
                "无限跳: " .. (infiniteJump and "✅" or "❌") .. "  透视玩家: " .. (playerESP and "✅" or "❌") .. "\n" ..
                "速度加成: " .. (speedBoost and "✅" or "❌") .. "  透视突变体: " .. (mutantESP and "✅" or "❌") .. "\n" ..
                "透视火焰僵尸: " .. (fireMutantESP and "✅" or "❌") .. "  透视加特: " .. (buffESP and "✅" or "❌")
            statusParagraph:SetDesc(status)
        end)
        task.wait(0.5)
    end
end)

T5:Button({Title = "关闭面板", Justify = "Center", Callback = function() Window:Close() end})

Window:OnClose(function()
    ClearESP()
    clearPlayer()
end)

WI:Notify({Title = "🌙 一次尘土飞扬的旅行", Content = "V1.2 加载完成", Duration = 3})
print("🌙 一次尘土飞扬的旅行 V1.2 加载完成")
