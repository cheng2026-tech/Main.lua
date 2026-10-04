-- 🌙 贪婪的种植者 | V1.1

local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- 变量
local autoSell = false
local sellInterval = 3

local autoFarm = false
local selectedCrop = ""
local cropList = {"松子"}

local playerESP = false
local playerESPColor = Color3.fromRGB(255, 50, 50)
local showDistance = false
local playerESPObjects = {}

local speedBoost = false
local speedValue = 50

-- ==================== 自动售卖 ====================
spawn(function()
    while true do
        if autoSell then
            pcall(function()
                local Event = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.6.0"].knit.Services.SellStandService.RF.SellAll
                Event:InvokeServer()
            end)
        end
        task.wait(sellInterval)
    end
end)

-- ==================== 自动种植农场 ====================
local function findNearestPine(hrp)
    local best, bestD = nil, math.huge
    for _, obj in ipairs(Workspace:GetDescendants()) do
        pcall(function()
            if obj.Name:find("Pine") then
                local root = obj:IsA("BasePart") and obj or (obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildOfClass("BasePart"))
                if root then
                    local d = (hrp.Position - root.Position).Magnitude
                    -- 只找100米以内的
                    if d <= 100 and d < bestD then
                        bestD = d
                        best = root
                    end
                end
            end
        end)
    end
    return best
end

local function startAutoFarm()
    autoFarm = true
    spawn(function()
        local plantEvent = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.6.0"].knit.Services.PlantRoundService.RF.StartRound
        local collectEvent = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.6.0"].knit.Services.PlantRoundService.RF.CollectDeadTree

        while autoFarm do
            pcall(function()
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then
                    task.wait(2)
                    return
                end
                local hrp = char.HumanoidRootPart
                local humanoid = char:FindFirstChild("Humanoid")
                if not humanoid then
                    task.wait(2)
                    return
                end

                -- 找100米内最近的Pine
                local target = findNearestPine(hrp)
                if not target then
                    WI:Notify({Title = "自动农场", Content = "100米内没找到Pine", Duration = 2})
                    task.wait(3)
                    return
                end

                -- 走过去
                local startTime = tick()
                local reached = false
                while tick() - startTime < 15 and autoFarm do
                    local dist = (hrp.Position - target.Position).Magnitude
                    if dist < 5 then
                        reached = true
                        break
                    end
                    humanoid:MoveTo(target.Position)
                    task.wait(0.2)
                end

                if not reached then
                    task.wait(1)
                    return
                end

                task.wait(0.5)

                -- 长按E 1秒
                local endTime = tick() + 1
                while tick() < endTime and autoFarm do
                    pcall(function()
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    end)
                    task.wait(0.05)
                end
                pcall(function()
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                end)

                task.wait(0.3)

                -- 种植
                plantEvent:InvokeServer("Pine", "None")
                WI:Notify({Title = "自动农场", Content = "已种植Pine", Duration = 2})

                -- 等5秒
                local waitEnd = tick() + 5
                while tick() < waitEnd and autoFarm do
                    task.wait(0.5)
                end

                -- 收集
                collectEvent:InvokeServer()
                WI:Notify({Title = "自动农场", Content = "已收集", Duration = 2})

                task.wait(1)
            end)
        end
    end)
end

-- ==================== 玩家透视 ====================
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

-- ==================== UI ====================
WI:AddTheme({
    Name = "冰白",
    Accent = "#80C0FF",
    Outline = "#6090C0",
    Text = "#FFFFFF",
    Placeholder = "#D0E0FF"
})

local Window = WI:CreateWindow({
    Title = "贪婪的种植者",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(500, 420),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--贪婪的种植者 V1.1",
    Desc = "自动售卖 | 自动农场(100米内) | 透视\n速度 | 飞行\n我功能就就这么点 你就受着吧😂"
})

local T2 = Window:Tab({Title = "主要功能", Icon = "solar:star-bold"})
T2:Section({Title = "自动售卖"})
T2:Toggle({Title = "开启自动售卖", Value = false, Callback = function(v) autoSell = v end})
T2:Slider({Title = "售卖间隔(秒)", Value = {Min = 1, Max = 10, Default = 3}, Step = 0.5, Callback = function(v) sellInterval = v end})

T2:Section({Title = "自动农场"})
T2:Dropdown({
    Title = "选择作物",
    Values = cropList,
    Value = "",
    Multi = false,
    AllowNone = true,
    Callback = function(v)
        if type(v) == "string" and v ~= "" then
            selectedCrop = v
        else
            selectedCrop = ""
        end
    end
})
T2:Button({Title = "开始自动农场", Justify = "Center", Callback = function()
    if selectedCrop == "" then
        WI:Notify({Title = "提示", Content = "请先选择作物", Duration = 2})
        return
    end
    if autoFarm then
        WI:Notify({Title = "提示", Content = "已经在运行了", Duration = 2})
        return
    end
    startAutoFarm()
    WI:Notify({Title = "自动农场", Content = "已开启 - " .. selectedCrop, Duration = 2})
end})
T2:Button({Title = "停止自动农场", Justify = "Center", Callback = function()
    autoFarm = false
    WI:Notify({Title = "自动农场", Content = "已停止", Duration = 2})
end})
T2:Paragraph({Title = "范围限制", Desc = "只检测角色100米内的Pine物品"})

local T3 = Window:Tab({Title = "玩家", Icon = "solar:user-bold"})
T3:Section({Title = "透视"})
T3:Toggle({Title = "透视所有玩家", Value = false, Callback = function(v) playerESP = v end})
T3:Colorpicker({Title = "颜色", Default = Color3.fromRGB(255, 50, 50), Callback = function(c) playerESPColor = c end})
T3:Toggle({Title = "显示距离", Value = false, Callback = function(v) showDistance = v end})
T3:Section({Title = "速度"})
T3:Toggle({Title = "速度加成", Value = false, Callback = function(v) speedBoost = v end})
T3:Slider({Title = "速度值", Value = {Min = 16, Max = 200, Default = 50}, Callback = function(v) speedValue = v end})
T3:Section({Title = "飞行"})
T3:Button({Title = "加载飞行脚本", Justify = "Center", Callback = function()
    pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/飞饼"))() end)
    WI:Notify({Title = "飞行", Content = "已加载", Duration = 2})
end})

Window:Tab({Title = "设置", Icon = "solar:settings-bold"}):Button({
    Title = "关闭面板",
    Justify = "Center",
    Callback = function() Window:Close() end
})

Window:OnClose(function()
    autoFarm = false
    clearPlayer()
end)

WI:Notify({Title = "🌙 贪婪的种植者", Content = "V1.1 加载完成 | 100米限制", Duration = 3})
print("🌙 贪婪的种植者 V1.1 加载完成")
