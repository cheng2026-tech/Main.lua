-- 机器人滑膛枪 脚本 v1.0.4
-- WindUI蓝白版 | 透视NPC | 自瞄NPC

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
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local npcESP = false
local autoAim = false
local espObjects = {}
local aimConn = nil

local function isPlayer(model)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character == model then return true end
    end
    return false
end

local function isNPC(model)
    if not model or not model:IsA("Model") then return false end
    if isPlayer(model) then return false end
    if not model:FindFirstChild("Head") then return false end
    if not model:FindFirstChild("Humanoid") then return false end
    return true
end

local function getAllNPCs()
    local npcs = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and isNPC(obj) then
            table.insert(npcs, obj)
        end
    end
    return npcs
end

local function clearESP()
    for _, obj in pairs(espObjects) do
        pcall(function() obj.Highlight:Destroy() end)
        pcall(function() obj.Billboard:Destroy() end)
    end
    espObjects = {}
end

local function updateESP()
    if not npcESP then
        clearESP()
        return
    end
    
    local npcs = getAllNPCs()
    
    for npc, obj in pairs(espObjects) do
        local found = false
        for _, n in ipairs(npcs) do
            if n == npc then found = true break end
        end
        if not found or not npc.Parent then
            pcall(function() obj.Highlight:Destroy() end)
            pcall(function() obj.Billboard:Destroy() end)
            espObjects[npc] = nil
        end
    end
    
    for _, npc in ipairs(npcs) do
        if not espObjects[npc] then
            local head = npc:FindFirstChild("Head")
            if head then
                local highlight = Instance.new("Highlight")
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.FillTransparency = 0.5
                highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineTransparency = 0.2
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = npc
                
                local bg = Instance.new("BillboardGui")
                bg.Size = UDim2.new(0, 200, 0, 40)
                bg.AlwaysOnTop = true
                bg.MaxDistance = math.huge
                bg.Parent = head
                
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Text = npc.Name
                label.TextColor3 = Color3.fromRGB(255, 0, 0)
                label.Font = Enum.Font.GothamBold
                label.TextSize = 14
                label.TextStrokeTransparency = 0.5
                label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                label.Parent = bg
                
                espObjects[npc] = {Highlight = highlight, Billboard = bg}
            end
        end
    end
end

local function getNearestNPC()
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local myPos = myRoot.Position
    
    local nearest = nil
    local nearestDist = math.huge
    
    for _, npc in ipairs(getAllNPCs()) do
        local head = npc:FindFirstChild("Head")
        local humanoid = npc:FindFirstChild("Humanoid")
        if head and humanoid and humanoid.Health > 0 then
            local d = (myPos - head.Position).Magnitude
            if d < nearestDist then
                nearestDist = d
                nearest = npc
            end
        end
    end
    
    return nearest
end

local function startAimLoop()
    if aimConn then aimConn:Disconnect() end
    aimConn = RunService.RenderStepped:Connect(function()
        if not autoAim then return end
        local npc = getNearestNPC()
        if npc then
            local head = npc:FindFirstChild("Head")
            if head then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
            end
        end
    end)
end

local Window = WindUI:CreateWindow({
    Title = "机器人滑膛枪",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(600, 350),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true,
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--机器人滑膛枪 v1.0.4",
    Desc = "功能：透视NPC | 自瞄NPC\n\n自动识别所有非玩家的NPC"
})

local MainTab = Window:Tab({Title = "主要功能", Icon = "solar:star-bold"})

MainTab:Toggle({
    Title = "透视NPC",
    Value = false,
    Callback = function(v)
        npcESP = v
        if not v then clearESP() end
    end
})

MainTab:Toggle({
    Title = "自瞄NPC",
    Value = false,
    Callback = function(v)
        autoAim = v
        if v then startAimLoop() end
    end
})

task.spawn(function()
    while true do
        updateESP()
        task.wait(1)
    end
end)

local SettingsTab = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})
local statusPara = SettingsTab:Paragraph({Title = "功能状态", Desc = "加载中..."})

task.spawn(function()
    while true do
        local npcs = getAllNPCs()
        local status = ""
        status = status .. "透视NPC: " .. (npcESP and "✅" or "❌") .. "\n"
        status = status .. "自瞄NPC: " .. (autoAim and "✅" or "❌") .. "\n"
        status = status .. "NPC数量: " .. #npcs .. "\n"
        status = status .. "帧率: " .. math.floor(1 / task.wait()) .. " FPS"
        statusPara:SetDesc(status)
        task.wait(1)
    end
end)

SettingsTab:Button({
    Title = "关闭面板",
    Callback = function()
        Window:Close()
    end
})

Window:OnClose(function()
    npcESP = false
    autoAim = false
    clearESP()
    if aimConn then aimConn:Disconnect() end
end)

WindUI:Notify({
    Title = "机器人滑膛枪",
    Content = "v1.0.4 加载完成",
    Duration = 3
})
