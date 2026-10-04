-- Blox Fruits 轻量化脚本 | V2.3

local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- ==================== 变量 ====================
local antiAfk = false
local speedEnabled = false
local speedValue = 20
local fruitEsp = false
local autoFarm = false
local farmRange = 50
local farmCooldown = 0.3
local cameraAngle = 0
local playerEsp = false
local playerEspRGB = false
local playerEspRGBSpeed = 2
local playerEspColor = Color3.fromRGB(0, 150, 255)
local chestEsp = false
local espHighlights = {}
local useUlt = true
local ultCooldown = 0
local ultInterval = 10
local autoFarmTarget = nil
local autoFarmAttacking = false
local selectedPlayerName = ""
local attackX = 200
local attackY = 100

-- 安全系统
local safeMode = false
local safeHealthThreshold = 100
local safeReturnHealth = 500
local isEvading = false
local safeOriginalPosition = nil
local bodyVelocity = nil
local bodyGyro = nil

-- ==================== 彩虹文字 ====================
local function RainbowText(text)
    local result = ""
    local length = #text
    local speed = tick() * 2
    for i = 1, length do
        local hue = (i / length + speed) % 1
        local r, g, b = Color3.fromHSV(hue, 1, 1):ToRGB()
        local char = text:sub(i, i)
        result = result .. '<font color="rgb(' .. math.floor(r*255) .. ',' .. math.floor(g*255) .. ',' .. math.floor(b*255) .. ')">' .. char .. '</font>'
    end
    return result
end

-- ==================== RGB颜色 ====================
local function GetPlayerESPColor()
    if playerEspRGB then
        local hue = (tick() * playerEspRGBSpeed) % 1
        return Color3.fromHSV(hue, 1, 1)
    end
    return playerEspColor
end

-- ==================== 安全系统 ====================
local function GetCurrentHealth()
    local char = LocalPlayer.Character
    if not char then return 99999 end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return 99999 end
    return hum.Health
end

local function FreezeInSky()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- 清除旧的
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    
    -- 创建BodyVelocity固定位置
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 100000
    bodyVelocity.Parent = hrp
    
    -- 创建BodyGyro固定朝向
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.CFrame = hrp.CFrame
    bodyGyro.MaxTorque = Vector3.new(1, 1, 1) * 100000
    bodyGyro.Parent = hrp
end

local function Unfreeze()
    if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
end

local function TeleportToSky()
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    if not isEvading then
        safeOriginalPosition = hrp.Position
    end
    
    -- 传到Y轴1000
    local skyPos = Vector3.new(hrp.Position.X, 1000, hrp.Position.Z)
    
    pcall(function()
        hrp.CFrame = CFrame.new(skyPos)
    end)
    
    -- 冻结在空中
    FreezeInSky()
    
    isEvading = true
    return true
end

local function TeleportBackDown()
    Unfreeze()
    
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local targetPos = safeOriginalPosition or hrp.Position
    
    pcall(function()
        hrp.CFrame = CFrame.new(targetPos)
    end)
    
    isEvading = false
    safeOriginalPosition = nil
    return true
end

task.spawn(function()
    while task.wait(0.3) do
        if safeMode then
            local health = GetCurrentHealth()
            
            if health <= safeHealthThreshold and not isEvading then
                TeleportToSky()
                if autoFarm then
                    autoFarmAttacking = false
                end
            elseif isEvading and health >= safeReturnHealth then
                TeleportBackDown()
            end
        else
            if isEvading then
                TeleportBackDown()
            end
        end
    end
end)

-- ==================== 防 AFK ====================
task.spawn(function()
    while task.wait(90) do
        if antiAfk then
            pcall(function()
                cameraAngle = (cameraAngle + 1) % 360
                local cam = Workspace.CurrentCamera
                if cam then
                    cam.CFrame = CFrame.new(cam.CFrame.Position) * CFrame.Angles(0, math.rad(cameraAngle), 0)
                end
            end)
        end
    end
end)

-- ==================== 速度循环 ====================
task.spawn(function()
    while task.wait(0.1) do
        if speedEnabled then
            pcall(function()
                local c = LocalPlayer.Character
                if c and c:FindFirstChild("Humanoid") then
                    c.Humanoid.WalkSpeed = speedValue
                end
            end)
        end
    end
end)

-- ==================== 大招 Z 键 ====================
local function PressZ()
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Z, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Z, false, game)
    end)
end

task.spawn(function()
    while task.wait(0.5) do
        if autoFarm and useUlt and not isEvading then
            local now = tick()
            if now - ultCooldown >= ultInterval then
                ultCooldown = now
                PressZ()
            end
        end
    end
end)

-- ==================== NPC 过滤 ====================
local function shouldSkipNPC(obj)
    local name = obj.Name:lower()
    local skipNames = {
        "shop", "keeper", "store", "merchant", "dealer", "pirate adventurer",
        "商人", "经销商", "商店", "npc", "quest", "任务", "dark", "黑暗",
        "set home point", "home point", "sethome", "setspawn", "black"
    }
    for _, keyword in ipairs(skipNames) do
        if name:find(keyword) then
            return true
        end
    end
    return false
end

local function isNPC(obj)
    if not obj or not obj:IsA("Model") then return false end
    if Players:GetPlayerFromCharacter(obj) then return false end
    local hum = obj:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if not obj:FindFirstChild("HumanoidRootPart") then return false end
    if shouldSkipNPC(obj) then return false end
    return true
end

-- ==================== 攻击（快速连点右上角）====================
local function AttackFixedPoint()
    pcall(function()
        local screenSize = Workspace.CurrentCamera.ViewportSize
        local x = screenSize.X - attackX
        local y = attackY
        for i = 1, 3 do
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
            task.wait()
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
            task.wait()
        end
    end)
end

-- ==================== 自动刷NPC ====================
local function findClosestNPC()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local closest = nil
    local closestDist = farmRange
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if isNPC(obj) then
            local npcRoot = obj:FindFirstChild("HumanoidRootPart")
            if npcRoot then
                local dist = (hrp.Position - npcRoot.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = obj
                end
            end
        end
    end
    
    return closest
end

local function teleportAboveNPC(npc)
    if not npc then return false end
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local npcRoot = npc:FindFirstChild("HumanoidRootPart")
    if not npcRoot then return false end
    
    local abovePos = npcRoot.Position + Vector3.new(0, 3, -2)
    
    pcall(function()
        hrp.CFrame = CFrame.new(abovePos, npcRoot.Position)
    end)
end

task.spawn(function()
    while task.wait(farmCooldown) do
        if autoFarm and not isEvading then
            if not autoFarmTarget or not autoFarmTarget.Parent or not isNPC(autoFarmTarget) then
                autoFarmTarget = findClosestNPC()
            end
            
            if autoFarmTarget then
                teleportAboveNPC(autoFarmTarget)
                AttackFixedPoint()
                autoFarmAttacking = true
            else
                autoFarmAttacking = false
            end
        else
            autoFarmTarget = nil
            autoFarmAttacking = false
        end
    end
end)

-- ==================== ESP ====================
local function clearESP()
    for _, obj in pairs(espHighlights) do
        pcall(function() obj:Destroy() end)
    end
    espHighlights = {}
end

local function updatePlayerESP()
    if not playerEsp then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            pcall(function()
                local char = p.Character
                local old = char:FindFirstChild("PlayerESP")
                if old then old:Destroy() end
                
                local hl = Instance.new("Highlight")
                hl.Name = "PlayerESP"
                local color = GetPlayerESPColor()
                hl.FillColor = color
                hl.FillTransparency = 0.3
                hl.OutlineColor = color
                hl.OutlineTransparency = 0
                hl.Adornee = char
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = char
                table.insert(espHighlights, hl)
            end)
        end
    end
end

local function updateFruitESP()
    if not fruitEsp then return end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("Model") and obj.Name:lower():find("fruit") then
                local old = obj:FindFirstChild("FruitESP")
                if old then old:Destroy() end
                local hl = Instance.new("Highlight")
                hl.Name = "FruitESP"
                hl.FillColor = Color3.fromRGB(255, 200, 50)
                hl.FillTransparency = 0.2
                hl.OutlineColor = Color3.new(1, 1, 1)
                hl.Adornee = obj
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = obj
                table.insert(espHighlights, hl)
            end
        end)
    end
end

local function updateChestESP()
    if not chestEsp then return end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("Model") and obj.Name:lower():find("treasure") then
                local old = obj:FindFirstChild("ChestESP")
                if old then old:Destroy() end
                local hl = Instance.new("Highlight")
                hl.Name = "ChestESP"
                hl.FillColor = Color3.fromRGB(255, 215, 0)
                hl.FillTransparency = 0.2
                hl.OutlineColor = Color3.new(1, 1, 1)
                hl.Adornee = obj
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = obj
                table.insert(espHighlights, hl)
            end
        end)
    end
end

task.spawn(function()
    while task.wait(0.5) do
        clearESP()
        if playerEsp then updatePlayerESP() end
        if fruitEsp then updateFruitESP() end
        if chestEsp then updateChestESP() end
    end
end)

-- ==================== 传送功能 ====================
local function GetPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(names, p.Name)
        end
    end
    return names
end

local function TeleportToPlayer(playerName)
    if not playerName or playerName == "" then
        WI:Notify({Title = "传送失败", Content = "请先选择一名玩家", Duration = 2})
        return
    end
    local target = Players:FindFirstChild(playerName)
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
        WI:Notify({Title = "传送失败", Content = "玩家不存在", Duration = 2})
        return
    end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    char.HumanoidRootPart.CFrame = CFrame.new(target.Character.HumanoidRootPart.Position + Vector3.new(0, 2, 0))
    WI:Notify({Title = "传送成功", Content = "已传送到 " .. playerName, Duration = 2})
end

-- ==================== 冰白主题 ====================
WI:AddTheme({
    Name = "冰白",
    Accent = "#80C0FF",
    Outline = "#6090C0",
    Text = "#FFFFFF",
    Placeholder = "#D0E0FF",
})

-- ==================== Wind UI ====================
local MainWindow = WI:CreateWindow({
    Title = "Blox Fruits",
    Icon = "rbxassetid://129260712070622",
    IconThemed = true,
    Size = UDim2.fromOffset(480, 400),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true
})

-- 公告
local T1 = MainWindow:Tab({Title = "公告", Icon = "info"})
T1:Paragraph({Title = "黑脚本--Blox Fruits V2.3", Desc = "轻量化脚本\n自动刷NPC | ESP透视 | 移速修改\n安全系统(空中固定) | 传送玩家"})

-- 主要功能
local T2 = MainWindow:Tab({Title = "主要功能", Icon = "settings"})
T2:Toggle({Title = "AntiAFK", Value = false, Callback = function(v) antiAfk = v end})
T2:Divider()
T2:Toggle({Title = "自动刷NPC", Value = false, Callback = function(v) autoFarm = v; if not v then autoFarmTarget = nil; autoFarmAttacking = false end end})
T2:Input({Title = "攻击范围（米）", Value = "50", Callback = function(v) local n = tonumber(v); if n and n > 0 then farmRange = n end end})
T2:Input({Title = "攻击间隔（秒）", Value = "0.3", Callback = function(v) local n = tonumber(v); if n and n > 0 then farmCooldown = n end end})
T2:Divider()
T2:Toggle({Title = "放大招（Z键）", Value = true, Callback = function(v) useUlt = v end})
T2:Input({Title = "大招间隔（秒）", Value = "10", Callback = function(v) local n = tonumber(v); if n and n > 0 then ultInterval = n end end})

-- 安全系统
T2:Section({Title = "安全系统"})
T2:Toggle({Title = "开启安全模式", Value = false, Callback = function(v) safeMode = v; if not v and isEvading then TeleportBackDown() end end})
T2:Input({Title = "血量低于多少逃跑", Value = "100", Callback = function(v) local n = tonumber(v); if n and n > 0 then safeHealthThreshold = n end end})
T2:Input({Title = "血量恢复到多少返回", Value = "500", Callback = function(v) local n = tonumber(v); if n and n > 0 then safeReturnHealth = n end end})

-- 玩家
local T3 = MainWindow:Tab({Title = "玩家", Icon = "user"})
T3:Toggle({Title = "可调移速", Value = false, Callback = function(v) speedEnabled = v; if not v then local c = LocalPlayer.Character; if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = 16 end end end})
T3:Input({Title = "移速数值", Value = "20", Callback = function(v) local n = tonumber(v); if n and n > 0 and n <= 100 then speedValue = n end end})
T3:Button({Title = "推荐速度（25）", Justify = "Center", Color = Color3.fromRGB(255, 200, 50), Callback = function() speedValue = 25; if speedEnabled then local c = LocalPlayer.Character; if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = 25 end end end})

-- ESP
local T4 = MainWindow:Tab({Title = "ESP透视", Icon = "eye"})
T4:Toggle({Title = "透视玩家", Value = false, Callback = function(v) playerEsp = v end})
T4:Toggle({Title = "玩家RGB模式", Value = false, Callback = function(v) playerEspRGB = v end})
T4:Colorpicker({Title = "玩家透视颜色", Default = Color3.fromRGB(0, 150, 255), Callback = function(c) playerEspColor = c end})
T4:Slider({Title = "RGB速度", Value = {Min = 0.5, Max = 5, Default = 2}, Step = 0.5, Callback = function(v) playerEspRGBSpeed = v end})
T4:Divider()
T4:Toggle({Title = "透视果实", Value = false, Callback = function(v) fruitEsp = v end})
T4:Divider()
T4:Toggle({Title = "透视宝箱", Value = false, Callback = function(v) chestEsp = v end})

-- 传送
local T5 = MainWindow:Tab({Title = "传送", Icon = "map"})
T5:Paragraph({Title = "传送玩家", Desc = "选择一名玩家后点击传送"})
T5:Divider()

local playerDropdown = nil
local function RefreshPlayerList()
    local names = GetPlayerNames()
    if #names == 0 then table.insert(names, "无玩家") end
    if playerDropdown then
        playerDropdown:SetValues(names)
        playerDropdown:SetValue(names[1] or "无玩家")
    end
end

playerDropdown = T5:Dropdown({
    Title = "选择玩家",
    Values = GetPlayerNames(),
    Value = GetPlayerNames()[1] or "无玩家",
    Callback = function(v) selectedPlayerName = v end
})

T5:Button({Title = "刷新玩家列表", Justify = "Center", Color = Color3.fromRGB(76, 175, 80), Callback = function()
    RefreshPlayerList()
    WI:Notify({Title = "已刷新", Content = "玩家列表已更新", Duration = 2})
end})

T5:Divider()

T5:Button({Title = "传送至选定玩家", Justify = "Center", Color = Color3.fromRGB(255, 200, 50), Callback = function()
    if not selectedPlayerName or selectedPlayerName == "" or selectedPlayerName == "无玩家" then
        WI:Notify({Title = "传送失败", Content = "请先选择一名玩家", Duration = 2})
        return
    end
    TeleportToPlayer(selectedPlayerName)
end})

Window:OnClose(function()
    Unfreeze()
end)

print("Blox Fruits V2.3 加载完成")
