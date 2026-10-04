-- 🌙 我的恐龙生存生活 | V1.4

local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- 变量
local autoEat = false
local visitedFoods = {}
local foodMode = "全部食物"
local playerESP = false
local playerESPColor = Color3.fromRGB(255, 50, 50)
local showDistance = false
local playerESPObjects = {}
local speedBoost = false
local speedValue = 50
local selectedPlayer = ""
local goldFoodESP = false
local goldFoodESPColor = Color3.fromRGB(255, 215, 0)
local blueFoodESP = false
local blueFoodESPColor = Color3.fromRGB(50, 150, 255)
local espCache = {}

-- ==================== 冰白主题 ====================
WI:AddTheme({
    Name = "冰白",
    Accent = "#80C0FF",
    Outline = "#6090C0",
    Text = "#FFFFFF",
    Placeholder = "#D0E0FF"
})

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

local function getPlayerNames()
    local n = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(n, p.Name) end
    end
    if #n == 0 then table.insert(n, "无玩家") end
    return n
end

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

-- ==================== 自动吃（跳过Y轴高5以上的）====================
spawn(function()
    while true do
        if autoEat then
            pcall(function()
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then
                    task.wait(0.5)
                    return
                end
                local hrp = char.HumanoidRootPart

                local closest = nil
                local closestDist = math.huge
                local closestObj = nil

                for _, obj in ipairs(Workspace:GetDescendants()) do
                    local match = false
                    if foodMode == "全部食物" then
                        if obj.Name == "Food" then match = true end
                    elseif foodMode == "金食物" then
                        if obj.Name == "GoldFood" then match = true end
                    elseif foodMode == "蓝食物" then
                        if obj.Name == "BlueFood" then match = true end
                    end

                    if match and not visitedFoods[obj] then
                        local root = getRoot(obj)
                        if root then
                            -- 跳过Y轴比玩家高5以上的
                            if root.Position.Y > hrp.Position.Y + 5 then
                                continue
                            end
                            local d = (hrp.Position - root.Position).Magnitude
                            if d < closestDist then
                                closestDist = d
                                closest = root
                                closestObj = obj
                            end
                        end
                    end
                end

                if not closest then
                    visitedFoods = {}
                    task.wait(1)
                    return
                end

                local foodPos = closest.Position
                local faceDirection = (foodPos - hrp.Position).Unit
                local standPos = foodPos - faceDirection * 3
                standPos = Vector3.new(standPos.X, foodPos.Y, standPos.Z)

                hrp.CFrame = CFrame.new(standPos, foodPos)
                visitedFoods[closestObj] = true
                task.wait(0.3)

                local prompt = nil
                for _, d in ipairs(Workspace:GetDescendants()) do
                    if d:IsA("ProximityPrompt") and d.Enabled and d.Parent then
                        local ppos = nil
                        if d.Parent:IsA("BasePart") then ppos = d.Parent.Position
                        elseif d.Parent:IsA("Model") then
                            local bp = d.Parent:FindFirstChildWhichIsA("BasePart")
                            if bp then ppos = bp.Position end
                        end
                        if ppos and (ppos - foodPos).Magnitude < 8 then
                            prompt = d
                            break
                        end
                    end
                end
                if prompt then fireproximityprompt(prompt) end
                task.wait(0.2)
            end)
        end
        task.wait(0.3)
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

-- ==================== 食物ESP ====================
local function ClearFoodESP()
    for _, d in ipairs(espCache) do
        pcall(function() if d.hl then d.hl:Destroy() end if d.bb then d.bb:Destroy() end end)
    end
    espCache = {}
end

local function CreateFoodESP(obj, color, name)
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

local lastFoodESPUpdate = 0
local function UpdateFoodESP()
    if tick() - lastFoodESPUpdate < 0.3 then return end
    lastFoodESPUpdate = tick()
    ClearFoodESP()

    if goldFoodESP then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == "GoldFood" then
                local root = getRoot(obj)
                if root then CreateFoodESP(obj, goldFoodESPColor, "金食物") end
            end
        end
    end

    if blueFoodESP then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == "BlueFood" then
                local root = getRoot(obj)
                if root then CreateFoodESP(obj, blueFoodESPColor, "蓝食物") end
            end
        end
    end
end

task.spawn(function()
    while task.wait(0.3) do
        pcall(function() UpdateFoodESP() end)
    end
end)

-- ==================== 传送玩家 ====================
local function tpPlayer(name)
    if not name or name == "" or name == "无玩家" then
        WI:Notify({Title = "失败", Content = "请先选择玩家", Duration = 2})
        return
    end
    local target = Players:FindFirstChild(name)
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
        WI:Notify({Title = "失败", Content = "目标不存在", Duration = 2})
        return
    end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    char.HumanoidRootPart.CFrame = CFrame.new(target.Character.HumanoidRootPart.Position + Vector3.new(0, 2, 0))
    WI:Notify({Title = "成功", Content = "已传送", Duration = 2})
end

-- ==================== UI ====================
local Window = WI:CreateWindow({
    Title = "我的恐龙生活",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(500, 380),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--我的恐龙生活",
    Desc = "自动吃(跳过高空) | 透视玩家/金/蓝食物 | 传送玩家\n速度 | 飞行"
})

local T2 = Window:Tab({Title = "主要功能", Icon = "solar:star-bold"})
T2:Dropdown({
    Title = "食物类型",
    Values = {"全部食物", "金食物", "蓝食物"},
    Value = "全部食物",
    Multi = false,
    AllowNone = false,
    Callback = function(v)
        foodMode = v
        visitedFoods = {}
    end
})
T2:Toggle({Title = "自动吃", Value = false, Callback = function(v)
    autoEat = v
    if v then visitedFoods = {} end
end})

-- 玩家标签页包含透视+传送+速度+飞行
local T3 = Window:Tab({Title = "玩家", Icon = "solar:user-bold"})
T3:Section({Title = "透视"})
T3:Toggle({Title = "透视玩家", Value = false, Callback = function(v) playerESP = v end})
T3:Colorpicker({Title = "玩家颜色", Default = Color3.fromRGB(255, 50, 50), Callback = function(c) playerESPColor = c end})
T3:Toggle({Title = "显示距离", Value = false, Callback = function(v) showDistance = v end})
T3:Divider()
T3:Toggle({Title = "透视金食物", Value = false, Callback = function(v) goldFoodESP = v end})
T3:Colorpicker({Title = "金食物颜色", Default = Color3.fromRGB(255, 215, 0), Callback = function(c) goldFoodESPColor = c end})
T3:Toggle({Title = "透视蓝食物", Value = false, Callback = function(v) blueFoodESP = v end})
T3:Colorpicker({Title = "蓝食物颜色", Default = Color3.fromRGB(50, 150, 255), Callback = function(c) blueFoodESPColor = c end})
T3:Divider()
T3:Section({Title = "传送玩家"})
local dd = T3:Dropdown({Title = "选择玩家", Values = getPlayerNames(), Value = "", Multi = false, AllowNone = true, Callback = function(v)
    if type(v) == "string" then selectedPlayer = v else selectedPlayer = "" end
end})
T3:Button({Title = "刷新列表", Justify = "Center", Callback = function()
    local n = getPlayerNames(); dd:SetValues(n); dd:SetValue(n[1])
end})
T3:Button({Title = "传送到该玩家", Justify = "Center", Callback = function() tpPlayer(selectedPlayer) end})
T3:Divider()
T3:Section({Title = "速度"})
T3:Toggle({Title = "速度加成", Value = false, Callback = function(v) speedBoost = v end})
T3:Slider({Title = "速度值", Value = {Min = 16, Max = 500, Default = 50}, Step = 1, Callback = function(v) speedValue = v end})
T3:Section({Title = "飞行"})
T3:Button({Title = "加载飞行脚本", Justify = "Center", Callback = function()
    pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/飞饼"))() end)
    WI:Notify({Title = "飞行", Content = "已加载", Duration = 2})
end})

local T4 = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})
local statusParagraph = T4:Paragraph({Title = "功能状态", Desc = "加载中..."})

spawn(function()
    while true do
        pcall(function()
            local fps = math.floor(1 / (RunService.RenderStepped:Wait() or 0.016))
            local status = "FPS: " .. fps .. "\n\n" ..
                "自动吃: " .. (autoEat and "✅" or "❌") .. "\n" ..
                "模式: " .. foodMode .. "\n" ..
                "透视玩家: " .. (playerESP and "✅" or "❌") .. "\n" ..
                "透视金: " .. (goldFoodESP and "✅" or "❌") .. "\n" ..
                "透视蓝: " .. (blueFoodESP and "✅" or "❌") .. "\n" ..
                "速度: " .. (speedBoost and "✅ " .. speedValue or "❌")
            statusParagraph:SetDesc(status)
        end)
        task.wait(0.5)
    end
end)

T4:Button({Title = "关闭面板", Justify = "Center", Callback = function() Window:Close() end})

WI:Notify({Title = "🌙 我的恐龙生存生活", Content = "加载完成", Duration = 3})
print("🌙 我的恐龙生存生活 加载完成")
