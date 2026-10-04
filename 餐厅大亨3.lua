-- 🌙 餐厅大亨3 | V3.2

local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)

if not success or not WindUI then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "错误",
        Text = "UI库加载失败",
        Duration = 5
    })
    return
end

_G.WindUI = WindUI
local WI = _G.WindUI

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- 变量
local autoInteract = false
local autoCollect = false
local autoCollectFood = false
local speedValue = 16
local speedEnabled = false
local espEnabled = false
local espHighlights = {}
local collectedTables = {}
local collectedFoods = {}
local COLLECT_RADIUS = 200
local isWorking = false
local selectedPlayer = ""

-- ==================== 冰白主题 ====================
WI:AddTheme({
    Name = "冰白",
    Accent = "#80C0FF",
    Outline = "#6090C0",
    Text = "#FFFFFF",
    Placeholder = "#D0E0FF"
})

-- ==================== 速度循环 ====================
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

-- ==================== ESP ====================
local function clearESP()
    for _, obj in pairs(espHighlights) do
        pcall(function() obj:Destroy() end)
    end
    espHighlights = {}
end

local function updateESP()
    clearESP()
    if not espEnabled then return end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            pcall(function()
                local char = p.Character
                local hl = Instance.new("Highlight")
                hl.FillColor = Color3.fromRGB(80, 160, 255)
                hl.FillTransparency = 0.3
                hl.OutlineColor = Color3.new(1, 1, 1)
                hl.Adornee = char
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = char
                table.insert(espHighlights, hl)

                local bb = Instance.new("BillboardGui")
                bb.Size = UDim2.new(0, 200, 0, 30)
                bb.AlwaysOnTop = true
                bb.Parent = char
                local head = char:FindFirstChild("Head")
                if head then bb.Adornee = head end

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.TextColor3 = Color3.new(1, 1, 1)
                label.Text = p.Name
                label.Font = Enum.Font.SourceSansBold
                label.TextSize = 14
                label.TextStrokeColor3 = Color3.new(0, 0, 0)
                label.TextStrokeTransparency = 0
                label.Parent = bb
                table.insert(espHighlights, bb)
            end)
        end
    end
end

task.spawn(function()
    while true do
        task.wait(1)
        if espEnabled then updateESP() else clearESP() end
    end
end)

-- ==================== 传送玩家 ====================
local function GetPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(names, p.Name) end
    end
    if #names == 0 then table.insert(names, "无玩家") end
    return names
end

local function TeleportToPlayer(playerName)
    if not playerName or playerName == "" or playerName == "无玩家" then
        WI:Notify({Title = "失败", Content = "请选择玩家", Duration = 2})
        return
    end
    local target = Players:FindFirstChild(playerName)
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
        WI:Notify({Title = "失败", Content = "目标不存在", Duration = 2})
        return
    end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    char.HumanoidRootPart.CFrame = CFrame.new(target.Character.HumanoidRootPart.Position + Vector3.new(0, 2, 0))
    WI:Notify({Title = "成功", Content = "已传送到 " .. playerName, Duration = 2})
end

-- ==================== 自动互动 ====================
task.spawn(function()
    while true do
        task.wait(0.15)
        if autoInteract and not isWorking then
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                local pos = hrp.Position

                for _, o in ipairs(Workspace:GetDescendants()) do
                    if o:IsA("ProximityPrompt") and o.Enabled then
                        local parent = o.Parent
                        if parent then
                            local ppos = nil
                            if parent:IsA("BasePart") then
                                ppos = parent.Position
                            elseif parent:IsA("Model") then
                                local bp = parent:FindFirstChildWhichIsA("BasePart")
                                if bp then ppos = bp.Position end
                            end
                            if ppos and (ppos - pos).Magnitude < 10 then
                                fireproximityprompt(o)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ==================== 统一收集循环（Bill+Food有序）====================
task.spawn(function()
    while true do
        task.wait(0.3)
        if (autoCollect or autoCollectFood) and not isWorking then
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                local closest = nil
                local closestDist = math.huge
                local closestType = ""

                -- 找最近的Bill
                if autoCollect then
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj.Name == "Bill" and not collectedTables[obj] then
                            local pos = nil
                            if obj:IsA("BasePart") then pos = obj.Position
                            elseif obj:IsA("Model") then
                                local bp = obj:FindFirstChildWhichIsA("BasePart")
                                if bp then pos = bp.Position end
                            end
                            if pos then
                                local d = (hrp.Position - pos).Magnitude
                                if d < closestDist and d <= COLLECT_RADIUS then
                                    closestDist = d
                                    closest = {obj = obj, pos = pos}
                                    closestType = "Bill"
                                end
                            end
                        end
                    end
                end

                -- 找最近的Food
                if autoCollectFood then
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj.Name == "Food" and not collectedFoods[obj] then
                            local pos = nil
                            if obj:IsA("BasePart") then pos = obj.Position
                            elseif obj:IsA("Model") then
                                local bp = obj:FindFirstChildWhichIsA("BasePart")
                                if bp then pos = bp.Position end
                            end
                            if pos then
                                local d = (hrp.Position - pos).Magnitude
                                if d < closestDist and d <= COLLECT_RADIUS then
                                    closestDist = d
                                    closest = {obj = obj, pos = pos}
                                    closestType = "Food"
                                end
                            end
                        end
                    end
                end

                if not closest then
                    task.wait(1)
                    return
                end

                isWorking = true
                hrp.CFrame = CFrame.new(closest.pos + Vector3.new(0, 2, 0))
                task.wait(0.3)

                local prompt = nil
                if closest.obj:IsA("BasePart") then
                    prompt = closest.obj:FindFirstChildOfClass("ProximityPrompt")
                elseif closest.obj:IsA("Model") then
                    for _, d in ipairs(closest.obj:GetDescendants()) do
                        if d:IsA("ProximityPrompt") then
                            prompt = d
                            break
                        end
                    end
                end

                if prompt and prompt.Enabled then
                    fireproximityprompt(prompt)
                end

                if closestType == "Bill" then
                    collectedTables[closest.obj] = true
                elseif closestType == "Food" then
                    collectedFoods[closest.obj] = true
                end

                isWorking = false
                task.wait(0.2)

                -- 如果所有都收集完了，重置记录
                local allDone = true
                if autoCollect then
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj.Name == "Bill" and not collectedTables[obj] then
                            allDone = false
                            break
                        end
                    end
                end
                if autoCollectFood and allDone then
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj.Name == "Food" and not collectedFoods[obj] then
                            allDone = false
                            break
                        end
                    end
                end
                if allDone then
                    collectedTables = {}
                    collectedFoods = {}
                end
            end)
        end
    end
end)

-- ==================== UI ====================
local Window = WI:CreateWindow({
    Title = "黑--餐厅大亨3",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(540, 380),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--餐厅大亨3",
    Desc = "V3.2 | 有序收集 | 互不干扰\n冰白透明 | 自动互动 | 透视 | 速度 \n8月13号重大修改 | 已修复胡乱传送"
})

local T2 = Window:Tab({Title = "主要功能", Icon = "solar:star-bold"})
T2:Toggle({Title = "自动互动", Value = false, Callback = function(v) autoInteract = v end})
T2:Divider()
T2:Slider({Title = "收集半径", Value = {Min = 10, Max = 500, Default = 200}, Step = 10, Callback = function(v) COLLECT_RADIUS = v end})
T2:Toggle({Title = "自动收钱", Value = false, Callback = function(v)
    autoCollect = v
    if v then collectedTables = {} end
end})
T2:Toggle({Title = "自动收餐盘", Value = false, Callback = function(v)
    autoCollectFood = v
    if v then collectedFoods = {} end
end})

local T3 = Window:Tab({Title = "玩家", Icon = "solar:user-bold"})
T3:Toggle({Title = "速度调节", Value = false, Callback = function(v)
    speedEnabled = v
    if not v then pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = 16 end) end
end})
T3:Slider({Title = "速度值", Value = {Min = 16, Max = 200, Default = 16}, Step = 1, Callback = function(v) speedValue = v end})
T3:Divider()
T3:Toggle({Title = "透视所有玩家", Value = false, Callback = function(v) espEnabled = v end})
T3:Divider()
local dd = T3:Dropdown({Title = "选择玩家", Values = GetPlayerNames(), Value = "", Multi = false, AllowNone = true, Callback = function(v)
    if type(v) == "string" then selectedPlayer = v else selectedPlayer = "" end
end})
T3:Button({Title = "刷新列表", Justify = "Center", Callback = function()
    local n = GetPlayerNames()
    dd:SetValues(n)
    dd:SetValue(n[1])
end})
T3:Button({Title = "传送到该玩家", Justify = "Center", Callback = function() TeleportToPlayer(selectedPlayer) end})

local T4 = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})
local statusParagraph = T4:Paragraph({Title = "功能状态", Desc = "加载中..."})

spawn(function()
    while true do
        pcall(function()
            local fps = math.floor(1 / (RunService.RenderStepped:Wait() or 0.016))
            local status = "FPS: " .. fps .. "\n\n" ..
                "自动互动: " .. (autoInteract and "✅" or "❌") .. "\n" ..
                "自动收钱: " .. (autoCollect and "✅" or "❌") .. "\n" ..
                "自动收餐盘: " .. (autoCollectFood and "✅" or "❌") .. "\n" ..
                "速度: " .. (speedEnabled and "✅ " .. speedValue or "❌") .. "\n" ..
                "透视: " .. (espEnabled and "✅" or "❌")
            statusParagraph:SetDesc(status)
        end)
        task.wait(0.5)
    end
end)

T4:Button({Title = "关闭面板", Justify = "Center", Callback = function() Window:Close() end})

WI:Notify({Title = "🌙 餐厅大亨3", Content = "V3.2 加载完成", Duration = 3})
print("🌙 餐厅大亨3 V3.2 加载完成")
