-- 🌙 夜幕降临 | V2.4

local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

-- 变量
local autoChop = false
local chopInterval = 0.1
local nightVision = false
local nightVisionBrightness = 0.15
local speedBoost = false
local speedValue = 50
local selectedPlayer = ""
local autoPickupRock = false
local autoPickupStick = false
local visitedRocks = {}
local visitedSticks = {}
local autoBerry = false
local visitedBerries = {}
local playerESP = false
local playerESPColor = Color3.fromRGB(255, 50, 50)
local playerESPObjects = {}
local caveESP = false
local caveESPColor = Color3.fromRGB(100, 200, 255)
local wolfESP = false
local wolfESPColor = Color3.fromRGB(180, 180, 180)
local deerESP = false
local deerESPColor = Color3.fromRGB(139, 90, 43)
local sheepESP = false
local sheepESPColor = Color3.fromRGB(230, 230, 230)
local suitcaseESP = false
local suitcaseESPColor = Color3.fromRGB(255, 200, 100)
local watchtowerESP = false
local watchtowerESPColor = Color3.fromRGB(255, 150, 50)
local espCache = {}
local removeFog = false

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

-- 检查位置15米内是否有名字包含fire的物品
local function hasFireNearby(pos)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name:find("fire") or obj.Name:find("Fire") then
            local root = getRoot(obj)
            if root and (root.Position - pos).Magnitude < 15 then
                return true
            end
        end
    end
    return false
end

-- ==================== 夜视 ====================
spawn(function()
    while true do
        if nightVision then
            pcall(function()
                Lighting.Brightness = 1.5
                Lighting.ClockTime = 14
                Lighting.FogEnd = 100000
                Lighting.GlobalShadows = false
                Lighting.ExposureCompensation = nightVisionBrightness
                Lighting.Ambient = Color3.fromRGB(255, 255, 255)
                Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            end)
        end
        task.wait(0.05)
    end
end)

-- ==================== 去雾 ====================
spawn(function()
    while true do
        if removeFog then
            pcall(function()
                Lighting.FogEnd = 100000
                Lighting.FogStart = 50000
            end)
        end
        task.wait(0.05)
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

-- ==================== 自动砍树 ====================
spawn(function()
    while true do
        if autoChop then
            pcall(function()
                local Event = game:GetService("ReplicatedStorage").Remotes.Events.AxeSwingEvent
                Event:FireServer("251:242")
            end)
        end
        task.wait(chopInterval)
    end
end)

-- ==================== 自动捡Rock（跳过fire附近）====================
spawn(function()
    while true do
        if autoPickupRock then
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
                    if obj.Name == "Rock" and not obj.Name:find("Rock_") and not visitedRocks[obj] then
                        local root = getRoot(obj)
                        if root then
                            local d = (hrp.Position - root.Position).Magnitude
                            if d < closestDist and not hasFireNearby(root.Position) then
                                closestDist = d
                                closest = root
                                closestObj = obj
                            end
                        end
                    end
                end

                if not closest then
                    visitedRocks = {}
                    task.wait(1)
                    return
                end

                hrp.CFrame = CFrame.new(closest.Position + Vector3.new(0, 5, 0))
                visitedRocks[closestObj] = true
                task.wait(0.3)

                local prompt = nil
                for _, d in ipairs(Workspace:GetDescendants()) do
                    if d:IsA("ProximityPrompt") and d.Parent then
                        local ppos = nil
                        if d.Parent:IsA("BasePart") then ppos = d.Parent.Position
                        elseif d.Parent:IsA("Model") then
                            local bp = d.Parent:FindFirstChildWhichIsA("BasePart")
                            if bp then ppos = bp.Position end
                        end
                        if ppos and (ppos - closest.Position).Magnitude < 8 then
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

-- ==================== 自动捡Stick（跳过fire附近）====================
spawn(function()
    while true do
        if autoPickupStick then
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
                    if obj.Name == "Stick" and not visitedSticks[obj] then
                        local root = getRoot(obj)
                        if root then
                            local d = (hrp.Position - root.Position).Magnitude
                            if d < closestDist and not hasFireNearby(root.Position) then
                                closestDist = d
                                closest = root
                                closestObj = obj
                            end
                        end
                    end
                end

                if not closest then
                    visitedSticks = {}
                    task.wait(1)
                    return
                end

                hrp.CFrame = CFrame.new(closest.Position + Vector3.new(0, 5, 0))
                visitedSticks[closestObj] = true
                task.wait(0.3)

                local prompt = nil
                for _, d in ipairs(Workspace:GetDescendants()) do
                    if d:IsA("ProximityPrompt") and d.Parent then
                        local ppos = nil
                        if d.Parent:IsA("BasePart") then ppos = d.Parent.Position
                        elseif d.Parent:IsA("Model") then
                            local bp = d.Parent:FindFirstChildWhichIsA("BasePart")
                            if bp then ppos = bp.Position end
                        end
                        if ppos and (ppos - closest.Position).Magnitude < 8 then
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

-- ==================== 自动草莓虫 ====================
spawn(function()
    while true do
        if autoBerry then
            pcall(function()
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then
                    task.wait(0.5)
                    return
                end
                local hrp = char.HumanoidRootPart

                local closest = nil
                local closestDist = math.huge

                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if (obj.Name:find("berry") or obj.Name:find("Berry")) and not visitedBerries[obj] then
                        local root = getRoot(obj)
                        if root then
                            local d = (hrp.Position - root.Position).Magnitude
                            local isNearVisited = false
                            for visitedObj, _ in pairs(visitedBerries) do
                                local vroot = getRoot(visitedObj)
                                if vroot and (vroot.Position - root.Position).Magnitude < 15 then
                                    isNearVisited = true
                                    break
                                end
                            end
                            if not isNearVisited and d < closestDist then
                                closestDist = d
                                closest = root
                            end
                        end
                    end
                end

                if not closest then
                    visitedBerries = {}
                    task.wait(1)
                    return
                end

                hrp.CFrame = CFrame.new(closest.Position + Vector3.new(0, 5, 0))
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj.Name:find("berry") or obj.Name:find("Berry") then
                        local root = getRoot(obj)
                        if root and (root.Position - closest.Position).Magnitude < 15 then
                            visitedBerries[obj] = true
                        end
                    end
                end
                task.wait(0.3)

                local prompt = nil
                for _, d in ipairs(Workspace:GetDescendants()) do
                    if d:IsA("ProximityPrompt") and d.Parent then
                        local ppos = nil
                        if d.Parent:IsA("BasePart") then ppos = d.Parent.Position
                        elseif d.Parent:IsA("Model") then
                            local bp = d.Parent:FindFirstChildWhichIsA("BasePart")
                            if bp then ppos = bp.Position end
                        end
                        if ppos and (ppos - closest.Position).Magnitude < 8 then
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
    if caveESP then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name:find("Cave") and not Players:GetPlayerFromCharacter(obj) then
                local root = getRoot(obj)
                if root then CreateESP(obj, caveESPColor, "洞穴") end
            end
        end
    end
    if wolfESP then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name:find("Wolf") and not Players:GetPlayerFromCharacter(obj) then
                local root = getRoot(obj)
                if root then CreateESP(obj, wolfESPColor, "狼") end
            end
        end
    end
    if deerESP then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name:find("Deer") and not Players:GetPlayerFromCharacter(obj) then
                local root = getRoot(obj)
                if root then CreateESP(obj, deerESPColor, "鹿") end
            end
        end
    end
    if sheepESP then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name:find("Sheep") and not Players:GetPlayerFromCharacter(obj) then
                local root = getRoot(obj)
                if root then CreateESP(obj, sheepESPColor, "羊") end
            end
        end
    end
    if suitcaseESP then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name:find("Suitcase") and not Players:GetPlayerFromCharacter(obj) then
                local root = getRoot(obj)
                if root then CreateESP(obj, suitcaseESPColor, "行李箱") end
            end
        end
    end
    if watchtowerESP then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name:find("WatchTower") and not Players:GetPlayerFromCharacter(obj) then
                local root = getRoot(obj)
                if root then CreateESP(obj, watchtowerESPColor, "瞭望塔") end
            end
        end
    end
end

task.spawn(function()
    while task.wait(0.3) do
        pcall(function() UpdateESP() end)
    end
end)

-- ==================== 玩家ESP ====================
local function clearPlayerESP()
    for _, obj in ipairs(playerESPObjects) do
        pcall(function() obj:Destroy() end)
    end
    playerESPObjects = {}
end

local function refreshPlayerESP()
    clearPlayerESP()
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
            end)
        end
    end
end

task.spawn(function()
    while task.wait(1) do
        pcall(function() refreshPlayerESP() end)
    end
end)

-- ==================== 传送 ====================
local function teleportToNearest(name, label)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        WI:Notify({Title = "失败", Content = "角色不存在", Duration = 2})
        return
    end
    local hrp = char.HumanoidRootPart
    local closest, closestDist = nil, math.huge
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name:find(name) and not Players:GetPlayerFromCharacter(obj) then
            local root = getRoot(obj)
            if root then
                local d = (hrp.Position - root.Position).Magnitude
                if d < closestDist and d > 2 then
                    closestDist = d
                    closest = root
                end
            end
        end
    end
    if closest then
        hrp.CFrame = CFrame.new(closest.Position + Vector3.new(0, 5, 0))
        WI:Notify({Title = "成功", Content = "已到" .. label, Duration = 2})
    else
        WI:Notify({Title = "失败", Content = "没找到", Duration = 2})
    end
end

local function getPlayerNames()
    local n = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(n, p.Name) end
    end
    if #n == 0 then table.insert(n, "无玩家") end
    return n
end

local function tpPlayer(name)
    if not name or name == "" or name == "无玩家" then return end
    local target = Players:FindFirstChild(name)
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    char.HumanoidRootPart.CFrame = CFrame.new(target.Character.HumanoidRootPart.Position + Vector3.new(0, 2, 0))
    WI:Notify({Title = "成功", Content = "已传送", Duration = 2})
end

-- ==================== UI ====================
local Window = WI:CreateWindow({
    Title = "夜幕降临",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(500, 380),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--夜幕降临",
    Desc = "自动砍树 | 捡物品 | 草莓虫\n夜视 | 透视 | 传送 | 速度 | 去雾"
})

local T2 = Window:Tab({Title = "主要功能", Icon = "solar:star-bold"})
T2:Toggle({Title = "自动砍树", Value = false, Callback = function(v) autoChop = v end})
T2:Slider({Title = "砍树间隔", Value = {Min = 0.01, Max = 1, Default = 0.1}, Step = 0.01, Callback = function(v) chopInterval = v end})
T2:Divider()
T2:Toggle({Title = "自动捡石头", Value = false, Callback = function(v) autoPickupRock = v; if v then visitedRocks = {} end end})
T2:Toggle({Title = "自动捡木棍", Value = false, Callback = function(v) autoPickupStick = v; if v then visitedSticks = {} end end})
T2:Toggle({Title = "自动草莓虫", Value = false, Callback = function(v) autoBerry = v; if v then visitedBerries = {} end end})
T2:Divider()
T2:Toggle({Title = "夜视", Value = false, Callback = function(v) nightVision = v end})
T2:Slider({Title = "夜视亮度", Value = {Min = 0.05, Max = 0.5, Default = 0.15}, Step = 0.01, Callback = function(v) nightVisionBrightness = v end})
T2:Toggle({Title = "去雾(暂时没用)", Value = false, Callback = function(v) removeFog = v end})

local T3 = Window:Tab({Title = "透视", Icon = "solar:eye-bold"})
T3:Toggle({Title = "透视玩家", Value = false, Callback = function(v) playerESP = v end})
T3:Colorpicker({Title = "玩家颜色", Default = Color3.fromRGB(255, 50, 50), Callback = function(c) playerESPColor = c end})
T3:Divider()
T3:Toggle({Title = "透视洞穴", Value = false, Callback = function(v) caveESP = v end})
T3:Colorpicker({Title = "洞穴颜色", Default = Color3.fromRGB(100, 200, 255), Callback = function(c) caveESPColor = c end})
T3:Toggle({Title = "透视狼", Value = false, Callback = function(v) wolfESP = v end})
T3:Colorpicker({Title = "狼颜色", Default = Color3.fromRGB(180, 180, 180), Callback = function(c) wolfESPColor = c end})
T3:Toggle({Title = "透视鹿", Value = false, Callback = function(v) deerESP = v end})
T3:Colorpicker({Title = "鹿颜色", Default = Color3.fromRGB(139, 90, 43), Callback = function(c) deerESPColor = c end})
T3:Toggle({Title = "透视羊", Value = false, Callback = function(v) sheepESP = v end})
T3:Colorpicker({Title = "羊颜色", Default = Color3.fromRGB(230, 230, 230), Callback = function(c) sheepESPColor = c end})
T3:Toggle({Title = "透视行李箱", Value = false, Callback = function(v) suitcaseESP = v end})
T3:Colorpicker({Title = "行李箱颜色", Default = Color3.fromRGB(255, 200, 100), Callback = function(c) suitcaseESPColor = c end})
T3:Toggle({Title = "透视瞭望塔", Value = false, Callback = function(v) watchtowerESP = v end})
T3:Colorpicker({Title = "瞭望塔颜色", Default = Color3.fromRGB(255, 150, 50), Callback = function(c) watchtowerESPColor = c end})

local T4 = Window:Tab({Title = "传送", Icon = "solar:map-bold"})
T4:Button({Title = "传送飞机", Justify = "Center", Callback = function() teleportToNearest("Character", "飞机") end})
T4:Button({Title = "传送行李箱", Justify = "Center", Callback = function() teleportToNearest("Suitcase", "行李箱") end})
T4:Button({Title = "传送最近草莓", Justify = "Center", Callback = function() teleportToNearest("berry", "草莓") end})
T4:Button({Title = "传送床", Justify = "Center", Callback = function() teleportToNearest("bed", "床") end})
T4:Divider()
local dd = T4:Dropdown({Title = "选择玩家", Values = getPlayerNames(), Value = "", Multi = false, AllowNone = true, Callback = function(v)
    if type(v) == "string" then selectedPlayer = v else selectedPlayer = "" end
end})
T4:Button({Title = "刷新列表", Justify = "Center", Callback = function()
    local n = getPlayerNames(); dd:SetValues(n); dd:SetValue(n[1])
end})
T4:Button({Title = "传送到该玩家", Justify = "Center", Callback = function() tpPlayer(selectedPlayer) end})

local T5 = Window:Tab({Title = "玩家", Icon = "solar:user-bold"})
T5:Toggle({Title = "速度加成", Value = false, Callback = function(v) speedBoost = v end})
T5:Slider({Title = "速度值", Value = {Min = 16, Max = 200, Default = 50}, Callback = function(v) speedValue = v end})
T5:Button({Title = "加载飞行脚本", Justify = "Center", Callback = function()
    pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/飞饼"))() end)
    WI:Notify({Title = "飞行", Content = "已加载", Duration = 2})
end})

local T6 = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})
local statusParagraph = T6:Paragraph({Title = "功能状态", Desc = "加载中..."})
spawn(function()
    while true do
        pcall(function()
            local fps = math.floor(1 / (RunService.RenderStepped:Wait() or 0.016))
            local status = "FPS: " .. fps .. "\n\n" ..
                "砍树: " .. (autoChop and "✅" or "❌") .. "\n" ..
                "夜视: " .. (nightVision and "✅" or "❌") .. "\n" ..
                "去雾: " .. (removeFog and "✅" or "❌") .. "\n" ..
                "速度: " .. (speedBoost and "✅ " .. speedValue or "❌")
            statusParagraph:SetDesc(status)
        end)
        task.wait(0.5)
    end
end)
T6:Button({Title = "关闭面板", Justify = "Center", Callback = function() Window:Close() end})

WI:Notify({Title = "🌙 夜幕降临", Content = "加载完成 | 跳过fire", Duration = 3})
print("🌙 夜幕降临 加载完成")
