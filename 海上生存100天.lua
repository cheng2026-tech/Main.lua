-- 海上生存100天 | V1.5

local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Camera = Workspace.CurrentCamera

-- ==================== 变量 ====================
local nightVision = false
local nightVisionValue = 2

local speedEnabled = false
local speedValue = 20

local playerESP = false
local playerESPColor = Color3.fromRGB(255, 50, 50)

local chestESP = false
local chestESPColor = Color3.fromRGB(255, 215, 0)

local tracerEnabled = false
local tracerColor = Color3.fromRGB(255, 255, 255)
local showDistance = false

local espCache = {}
local tracerCache = {}
local playerESPCache = {}

local ESP_UPDATE_INTERVAL = 0.5

local visitedChests = {}

-- 家位置
local homePosition = nil
local selectedPlayer = nil

-- ==================== 辅助 ====================
local function GetRoot(obj)
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

local function GetChestID(obj)
    local root = GetRoot(obj)
    if root then
        local pos = root.Position
        return string.format("%.0f_%.0f_%.0f", pos.X, pos.Y, pos.Z)
    end
    return nil
end

-- 获取所有玩家名字列表
local function GetPlayerNames()
    local names = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(names, plr.Name)
        end
    end
    return names
end

-- ==================== 夜视 ====================
local function ApplyNightVision()
    pcall(function()
        if nightVision then
            Lighting.Brightness = nightVisionValue
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.ExposureCompensation = nightVisionValue - 1
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        else
            Lighting.Brightness = 2
            Lighting.ClockTime = 12
            Lighting.FogEnd = 500
            Lighting.ExposureCompensation = 0
            Lighting.Ambient = Color3.fromRGB(127, 127, 127)
            Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
        end
    end)
end

RunService.RenderStepped:Connect(function()
    if nightVision then ApplyNightVision() end
end)

-- ==================== 速度 ====================
RunService.RenderStepped:Connect(function()
    if speedEnabled then
        pcall(function()
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then
                c.Humanoid.WalkSpeed = speedValue
            end
        end)
    end
end)

-- ==================== 飞行 ====================
local function LoadFlyScript()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/飞饼"))()
    end)
    WI:Notify({Title = "飞行", Content = "飞行脚本已加载", Duration = 2})
end

-- ==================== ESP系统 ====================
local function ClearESP()
    for obj in pairs(espCache) do pcall(function() obj:Destroy() end) end
    espCache = {}
    for _, line in ipairs(tracerCache) do pcall(function() line:Remove() end) end
    tracerCache = {}
    for _, hl in ipairs(playerESPCache) do pcall(function() hl:Destroy() end) end
    playerESPCache = {}
end

local function CreateESP(obj, color, displayName)
    local root = GetRoot(obj)
    if not root then return end

    local hl = Instance.new("Highlight")
    hl.FillColor = color
    hl.FillTransparency = 0.5
    hl.OutlineColor = color
    hl.OutlineTransparency = 0
    hl.Adornee = obj
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = obj
    espCache[hl] = true

    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, 200, 0, 40)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Parent = root
    espCache[bb] = true

    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(1, 0, 1, 0)
    lb.BackgroundTransparency = 1
    lb.Text = displayName
    lb.TextColor3 = color
    lb.TextStrokeTransparency = 0
    lb.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    lb.Font = Enum.Font.SourceSansBold
    lb.TextSize = 18
    lb.Parent = bb

    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if showDistance and hrp then
        local dist = math.floor((hrp.Position - root.Position).Magnitude)
        local db = Instance.new("BillboardGui")
        db.Size = UDim2.new(0, 100, 0, 25)
        db.StudsOffset = Vector3.new(0, 1.5, 0)
        db.AlwaysOnTop = true
        db.Parent = root
        espCache[db] = true

        local dl = Instance.new("TextLabel")
        dl.Size = UDim2.new(1, 0, 1, 0)
        dl.BackgroundTransparency = 1
        dl.Text = dist .. "m"
        dl.TextColor3 = Color3.fromRGB(255, 255, 255)
        dl.TextStrokeTransparency = 0
        dl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        dl.Font = Enum.Font.SourceSansBold
        dl.TextSize = 14
        dl.Parent = db
    end

    if tracerEnabled and hrp then
        local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if onScreen then
            local line = Drawing.new("Line")
            line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            line.To = Vector2.new(screenPos.X, screenPos.Y)
            line.Color = tracerColor
            line.Thickness = 1
            line.Visible = true
            table.insert(tracerCache, line)
        end
    end
end

local lastUpdate = 0
local function UpdateESP()
    if tick() - lastUpdate < ESP_UPDATE_INTERVAL then return end
    lastUpdate = tick()
    ClearESP()

    if playerESP then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                pcall(function()
                    local root = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character:FindFirstChild("Head")
                    if root then
                        local hl = Instance.new("Highlight")
                        hl.FillColor = playerESPColor
                        hl.FillTransparency = 0.4
                        hl.OutlineColor = playerESPColor
                        hl.Adornee = plr.Character
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Parent = plr.Character
                        table.insert(playerESPCache, hl)

                        local bb = Instance.new("BillboardGui")
                        bb.Size = UDim2.new(0, 200, 0, 40)
                        bb.StudsOffset = Vector3.new(0, 3, 0)
                        bb.AlwaysOnTop = true
                        bb.Parent = root
                        table.insert(playerESPCache, bb)

                        local lb = Instance.new("TextLabel")
                        lb.Size = UDim2.new(1, 0, 1, 0)
                        lb.BackgroundTransparency = 1
                        lb.Text = plr.Name
                        lb.TextColor3 = playerESPColor
                        lb.TextStrokeTransparency = 0
                        lb.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        lb.Font = Enum.Font.SourceSansBold
                        lb.TextSize = 18
                        lb.Parent = bb
                    end
                end)
            end
        end
    end

    if chestESP then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") or obj:IsA("BasePart") then
                local name = obj.Name
                if name == "Lid" or name == "Chest" then
                    pcall(function() CreateESP(obj, chestESPColor, "宝箱") end)
                end
            end
        end
    end
end

task.spawn(function() while task.wait(ESP_UPDATE_INTERVAL) do UpdateESP() end end)

-- ==================== 传送 ====================
local function SetHome()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        WI:Notify({Title = "设置失败", Content = "角色不存在", Duration = 2})
        return
    end
    homePosition = char.HumanoidRootPart.Position
    WI:Notify({Title = "设置成功", Content = "已记录当前位置为家", Duration = 2})
end

local function TeleportHome()
    if not homePosition then
        WI:Notify({Title = "传送失败", Content = "请先设置家的位置", Duration = 2})
        return
    end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        WI:Notify({Title = "传送失败", Content = "角色不存在", Duration = 2})
        return
    end
    char.HumanoidRootPart.CFrame = CFrame.new(homePosition)
    WI:Notify({Title = "传送成功", Content = "已回家", Duration = 2})
end

local function TeleportToPlayer()
    if not selectedPlayer then
        WI:Notify({Title = "传送失败", Content = "请先选择玩家", Duration = 2})
        return
    end
    local target = Players:FindFirstChild(selectedPlayer)
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
        WI:Notify({Title = "传送失败", Content = "目标玩家不在线或未加载", Duration = 2})
        return
    end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        WI:Notify({Title = "传送失败", Content = "角色不存在", Duration = 2})
        return
    end
    local targetPos = target.Character.HumanoidRootPart.Position
    char.HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(2, 0, 0))
    WI:Notify({Title = "传送成功", Content = "已传送到 " .. selectedPlayer, Duration = 2})
end

local function ResetVisitedChests()
    visitedChests = {}
    WI:Notify({Title = "已重置", Content = "宝箱记录已清空", Duration = 2})
end

local function TeleportToNearestChest()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        WI:Notify({Title = "传送失败", Content = "角色不存在", Duration = 2})
        return
    end
    local hrp = char.HumanoidRootPart

    local chestList = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local name = obj.Name
            if name == "Lid" or name == "Chest" then
                pcall(function()
                    local root = GetRoot(obj)
                    if root then
                        local chestID = GetChestID(obj)
                        local dist = (hrp.Position - root.Position).Magnitude
                        if dist > 20 and not visitedChests[chestID] then
                            table.insert(chestList, {root = root, dist = dist, id = chestID})
                        end
                    end
                end)
            end
        end
    end

    if #chestList == 0 then
        local anyChest = false
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") or obj:IsA("BasePart") then
                if obj.Name == "Lid" or obj.Name == "Chest" then anyChest = true; break end
            end
        end
        if anyChest then
            WI:Notify({Title = "提示", Content = "20米外未去过的宝箱已空，已自动重置", Duration = 3})
            ResetVisitedChests()
        else
            WI:Notify({Title = "传送失败", Content = "没找到任何宝箱", Duration = 2})
        end
        return
    end

    table.sort(chestList, function(a, b) return a.dist < b.dist end)
    local target = chestList[1]
    pcall(function() hrp.CFrame = target.root.CFrame * CFrame.new(0, 2, 0) end)
    visitedChests[target.id] = true
    WI:Notify({Title = "传送成功", Content = math.floor(target.dist) .. "米外 | 剩余" .. (#chestList - 1) .. "个", Duration = 2})
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
    Title = "海上生存100天",
    Icon = "rbxassetid://129260712070622",
    IconThemed = true,
    Size = UDim2.fromOffset(480, 420),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true
})

-- 1. 公告
Window:Tab({Title = "公告", Icon = "info"}):Paragraph({
    Title = "黑脚本--海上生存100天 V1.5",
    Desc = "智能宝箱 | 设置家 | 传送玩家 | 飞行 | 速度 | 夜视 | 玩家透视"
})

-- 2. 主要功能
local T2 = Window:Tab({Title = "主要功能", Icon = "settings"})
T2:Section({Title = "宝箱透视"})
T2:Toggle({Title = "透视宝箱", Value = false, Callback = function(v) chestESP = v end})
T2:Colorpicker({Title = "宝箱颜色", Default = Color3.fromRGB(255, 215, 0), Callback = function(c) chestESPColor = c end})
T2:Toggle({Title = "显示距离", Value = false, Callback = function(v) showDistance = v end})
T2:Toggle({Title = "射线指示", Value = false, Callback = function(v) tracerEnabled = v end})
T2:Colorpicker({Title = "射线颜色", Default = Color3.fromRGB(255, 255, 255), Callback = function(c) tracerColor = c end})

T2:Section({Title = "宝箱传送"})
T2:Button({Title = "传送到最近宝箱", Justify = "Center", Color = Color3.fromRGB(255, 215, 0), Callback = TeleportToNearestChest})
T2:Button({Title = "重置宝箱记录", Justify = "Center", Color = Color3.fromRGB(100, 200, 255), Callback = ResetVisitedChests})

-- 3. 传送
local T3 = Window:Tab({Title = "传送", Icon = "map"})
T3:Section({Title = "家的位置"})
T3:Button({Title = "设置当前位置为家", Justify = "Center", Color = Color3.fromRGB(80, 255, 80), Callback = SetHome})
T3:Button({Title = "传送回家", Justify = "Center", Color = Color3.fromRGB(255, 140, 0), Callback = TeleportHome})

T3:Section({Title = "传送到玩家"})
T3:Dropdown({Title = "选择玩家", Values = GetPlayerNames(), Value = "", Multi = false, AllowNone = true, Callback = function(v)
    if type(v) == "string" and v ~= "" then
        selectedPlayer = v
    else
        selectedPlayer = nil
    end
end})
T3:Button({Title = "传送到该玩家", Justify = "Center", Color = Color3.fromRGB(255, 100, 100), Callback = TeleportToPlayer})

-- 4. 玩家
local T4 = Window:Tab({Title = "玩家", Icon = "user"})
T4:Section({Title = "夜视"})
T4:Toggle({Title = "开启夜视", Value = false, Callback = function(v)
    nightVision = v
    if not v then ApplyNightVision() end
end})
T4:Slider({Title = "亮度", Value = {Min = 1, Max = 5, Default = 2}, Step = 0.5, Callback = function(v) nightVisionValue = v end})

T4:Section({Title = "移动速度"})
T4:Toggle({Title = "可调移速", Value = false, Callback = function(v)
    speedEnabled = v
    if not v then
        pcall(function()
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = 16 end
        end)
    end
end})
T4:Slider({Title = "移速数值", Value = {Min = 16, Max = 100, Default = 20}, Step = 1, Callback = function(v) speedValue = v end})

T4:Section({Title = "飞行"})
T4:Button({Title = "加载飞行脚本", Justify = "Center", Color = Color3.fromRGB(100, 200, 255), Callback = LoadFlyScript})

T4:Section({Title = "玩家透视"})
T4:Toggle({Title = "透视所有玩家", Value = false, Callback = function(v) playerESP = v end})
T4:Colorpicker({Title = "玩家透视颜色", Default = Color3.fromRGB(255, 50, 50), Callback = function(c) playerESPColor = c end})

-- 5. 设置
local T5 = Window:Tab({Title = "设置", Icon = "settings"})
T5:Paragraph({Title = "海上生存100天 V1.5", Desc = "冰白主题 | 设置家 | 传送玩家"})
T5:Button({Title = "关闭界面", Callback = function() Window:Close() end})

Window:OnClose(function()
    ClearESP()
end)

WI:Notify({Title = "海上生存100天", Content = "V1.5 加载完成", Duration = 3})
print("海上生存100天 V1.5 加载完成")
