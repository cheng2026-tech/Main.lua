-- 🌙 声名远外 | V3.1 快捷杀戮修复

local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- 变量
local speedBoost = false
local speedValue = 50
local policeESP = false
local policeESPColor = Color3.fromRGB(100, 150, 255)
local espCache = {}
local killAura = false
local killAuraRange = 20
local killAuraInterval = 0.1
local antiCheatEnabled = false
local bypassMode = false
local smartDetection = true

-- 快捷杀戮
local quickKillEnabled = false
local quickKillHits = 3
local quickKillCooldown = false
local quickKillGui = nil
local quickKillButton = nil
local quickKillCooldownLabel = nil

-- ==================== 冰白主题 ====================
WI:AddTheme({
    Name = "冰白",
    Accent = "#80C0FF",
    Outline = "#6090C0",
    Text = "#FFFFFF",
    Placeholder = "#D0E0FF"
})

-- ==================== 轻量反作弊 ====================
local function EnableAntiCheat()
    antiCheatEnabled = true
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if antiCheatEnabled and (method == "FireServer" or method == "InvokeServer") then
            local str = tostring(self)
            local lower = str:lower()
            if lower:find("kick") or lower:find("ban") then
                return nil
            end
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
    WI:Notify({Title = "反作弊", Content = "已开启轻量防护", Duration = 2})
end

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

local function hasNumber(name)
    return name:match("%d") ~= nil
end

-- ==================== 坐标加速 ====================
spawn(function()
    while true do
        if speedBoost then
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local humanoid = char:FindFirstChild("Humanoid")
                if not hrp or not humanoid then return end
                humanoid.WalkSpeed = speedValue
                local moveDir = humanoid.MoveDirection
                if moveDir.Magnitude > 0 then
                    hrp.CFrame = hrp.CFrame + moveDir * ((speedValue - 16) * 0.05)
                end
            end)
        end
        task.wait(0.03)
    end
end)

-- ==================== 执行一次杀戮 ====================
local function doOneKill()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local knife = nil
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Tool") then knife = child; break end
        end
        if not knife then return end

        local Event = ReplicatedStorage:FindFirstChild("RS_Package")
        if Event then Event = Event:FindFirstChild("Assets") end
        if Event then Event = Event:FindFirstChild("Remotes") end
        if Event then Event = Event:FindFirstChild("MeleeDamage") end
        if not Event then return end

        local policeList = Workspace:FindFirstChild("Police")
        if not policeList then return end

        for _, police in ipairs(policeList:GetChildren()) do
            if police:IsA("Model") then
                local humanoid = police:FindFirstChild("Humanoid")
                local root = getRoot(police)
                if humanoid and humanoid.Health > 0 and root then
                    if (hrp.Position - root.Position).Magnitude <= killAuraRange then
                        if bypassMode then
                            Event:FireServer(police, knife, 100)
                            Event:FireServer(police, knife, 50)
                            Event:FireServer(police, knife, 75)
                            Event:FireServer(police, knife, 100)
                        else
                            Event:FireServer(police, knife, 100)
                            Event:FireServer(police, knife, 100)
                            Event:FireServer(police, knife, 100)
                        end
                    end
                end
            end
        end
    end)
end

-- ==================== 快捷杀戮按钮 ====================
local function createQuickKillButton()
    if quickKillGui then quickKillGui:Destroy() end

    quickKillGui = Instance.new("ScreenGui")
    quickKillGui.Name = "QuickKill"
    quickKillGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    quickKillGui.ResetOnSpawn = false
    quickKillGui.Parent = game:GetService("CoreGui")

    quickKillButton = Instance.new("TextButton")
    quickKillButton.Size = UDim2.new(0, 80, 0, 80)
    quickKillButton.Position = UDim2.new(1, -110, 1, -300)
    quickKillButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    quickKillButton.BackgroundTransparency = 0.3
    quickKillButton.BorderSizePixel = 0
    quickKillButton.Text = "💀\n杀戮"
    quickKillButton.TextColor3 = Color3.new(1, 1, 1)
    quickKillButton.Font = Enum.Font.SourceSansBold
    quickKillButton.TextSize = 18
    quickKillButton.ZIndex = 9999
    quickKillButton.Parent = quickKillGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = quickKillButton

    quickKillCooldownLabel = Instance.new("TextLabel")
    quickKillCooldownLabel.Size = UDim2.new(0, 100, 0, 25)
    quickKillCooldownLabel.Position = UDim2.new(1, -120, 1, -270)
    quickKillCooldownLabel.BackgroundTransparency = 1
    quickKillCooldownLabel.Text = ""
    quickKillCooldownLabel.TextColor3 = Color3.new(1, 1, 1)
    quickKillCooldownLabel.Font = Enum.Font.SourceSansBold
    quickKillCooldownLabel.TextSize = 14
    quickKillCooldownLabel.TextStrokeTransparency = 0
    quickKillCooldownLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    quickKillCooldownLabel.ZIndex = 9999
    quickKillCooldownLabel.Parent = quickKillGui

    quickKillButton.MouseButton1Click:Connect(function()
        if not quickKillEnabled then return end
        if quickKillCooldown then return end

        if quickKillHits == 4 then
            -- 无限模式
            quickKillCooldown = true
            quickKillButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
            quickKillButton.Text = "💀\n无限中"

            spawn(function()
                while quickKillEnabled and quickKillHits == 4 do
                    doOneKill()
                    task.wait(killAuraInterval)
                end
                quickKillCooldown = false
                quickKillButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
                quickKillButton.Text = "💀\n杀戮"
            end)
        else
            -- 有限次数
            quickKillCooldown = true
            quickKillButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
            quickKillButton.Text = "💀\n攻击中"

            spawn(function()
                for i = 1, quickKillHits do
                    doOneKill()
                    task.wait(0.05)
                end

                for i = 10, 1, -1 do
                    quickKillCooldownLabel.Text = "冷却 " .. i .. "秒"
                    quickKillButton.Text = i .. "s"
                    task.wait(1)
                end
                quickKillCooldownLabel.Text = ""
                quickKillCooldown = false
                quickKillButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
                quickKillButton.Text = "💀\n杀戮"
            end)
        end
    end)
end

local function removeQuickKillButton()
    if quickKillGui then
        quickKillGui:Destroy()
        quickKillGui = nil
        quickKillButton = nil
        quickKillCooldownLabel = nil
    end
end

-- ==================== 杀戮光环 ====================
spawn(function()
    while true do
        if killAura then
            doOneKill()
        end
        task.wait(killAuraInterval)
    end
end)

-- ==================== ESP ====================
local function ClearESP()
    for _, d in ipairs(espCache) do
        pcall(function() if d.hl then d.hl:Destroy() end if d.bb then d.bb:Destroy() end end)
    end
    espCache = {}
end

local function CreateESP(obj, color, name)
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
end

local lastESPUpdate = 0
local function UpdateESP()
    if tick() - lastESPUpdate < 0.3 then return end
    lastESPUpdate = tick()
    ClearESP()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if policeESP then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and not Players:GetPlayerFromCharacter(obj) then
                local humanoid = obj:FindFirstChild("Humanoid")
                if humanoid and hasNumber(obj.Name) and not obj.Name:lower():find("bot") then
                    local root = getRoot(obj)
                    if root and (hrp.Position - root.Position).Magnitude <= 500 then
                        CreateESP(obj, policeESPColor, "警察")
                    end
                end
            end
        end
    end
end

task.spawn(function()
    while task.wait(0.3) do
        pcall(function() UpdateESP() end)
    end
end)

-- ==================== UI ====================
local Window = WI:CreateWindow({
    Title = "黑脚本--声名远外",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(400, 400),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--声名远外 V3.1",
    Desc = "杀戮光环 | 快捷杀戮 | 透视警察 | 速度"
})

local T2 = Window:Tab({Title = "主要功能", Icon = "solar:star-bold"})

T2:Toggle({Title = "开启反作弊", Value = false, Callback = function(v)
    if v then
        EnableAntiCheat()
    else
        antiCheatEnabled = false
    end
end})

T2:Divider()

T2:Toggle({Title = "杀戮光环", Value = false, Callback = function(v)
    killAura = v
    if v then
        WI:Notify({Title = "💀 杀戮光环", Content = "已开启！", Duration = 3})
    end
end})

T2:Toggle({Title = "绕过模式", Value = false, Callback = function(v)
    bypassMode = v
end})

T2:Toggle({Title = "智能检测", Value = true, Callback = function(v)
    smartDetection = v
end})

T2:Slider({Title = "攻击范围", Value = {Min = 5, Max = 100, Default = 20}, Step = 5, Callback = function(v) killAuraRange = v end})
T2:Slider({Title = "攻击间隔", Value = {Min = 0.05, Max = 0.5, Default = 0.1}, Step = 0.05, Callback = function(v) killAuraInterval = v end})

T2:Divider()

T2:Section({Title = "快捷杀戮"})
T2:Dropdown({
    Title = "攻击次数",
    Values = {"1次", "2次", "3次", "无限"},
    Value = "3次",
    Multi = false,
    AllowNone = false,
    Callback = function(v)
        if v == "1次" then quickKillHits = 1
        elseif v == "2次" then quickKillHits = 2
        elseif v == "3次" then quickKillHits = 3
        elseif v == "无限" then quickKillHits = 4
        end
    end
})
T2:Button({Title = "创建杀戮按钮", Justify = "Center", Callback = function()
    quickKillEnabled = true
    createQuickKillButton()
    WI:Notify({Title = "快捷杀戮", Content = "按钮已创建", Duration = 2})
end})
T2:Button({Title = "删除杀戮按钮", Justify = "Center", Callback = function()
    quickKillEnabled = false
    removeQuickKillButton()
    WI:Notify({Title = "快捷杀戮", Content = "按钮已删除", Duration = 2})
end})

T2:Divider()

T2:Toggle({Title = "速度加成", Value = false, Callback = function(v) speedBoost = v end})
T2:Slider({Title = "速度值", Value = {Min = 16, Max = 300, Default = 100}, Callback = function(v) speedValue = v end})

local T3 = Window:Tab({Title = "透视", Icon = "solar:eye-bold"})
T3:Toggle({Title = "透视警察", Value = false, Callback = function(v) policeESP = v end})
T3:Colorpicker({Title = "警察颜色", Default = Color3.fromRGB(100, 150, 255), Callback = function(c) policeESPColor = c end})

local T4 = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})
local statusParagraph = T4:Paragraph({Title = "功能状态", Desc = "加载中..."})

spawn(function()
    while true do
        pcall(function()
            local fps = math.floor(1 / (RunService.RenderStepped:Wait() or 0.016))
            local status = "FPS: " .. fps .. "\n\n" ..
                "反作弊: " .. (antiCheatEnabled and "✅" or "❌") .. "\n" ..
                "杀戮光环: " .. (killAura and "✅" or "❌") .. "\n" ..
                "快捷杀戮: " .. (quickKillEnabled and "✅" or "❌") .. "\n" ..
                "透视警察: " .. (policeESP and "✅" or "❌") .. "\n" ..
                "速度: " .. (speedBoost and "✅ " .. speedValue or "❌")
            statusParagraph:SetDesc(status)
        end)
        task.wait(0.5)
    end
end)

T4:Button({Title = "关闭面板", Justify = "Center", Callback = function() Window:Close() end})

WI:Notify({Title = "🌙 声名远外", Content = "V3.1 加载完成", Duration = 3})
print("🌙 声名远外 V3.1 加载完成")
