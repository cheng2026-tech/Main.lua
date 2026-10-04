-- MM2 脚本 v1.0.1
-- WindUI蓝白版 | 透视职业 | 传送

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

local VERSION = "v1.0.1"
local showRoles = false
local espObjects = {}

local function getRole(plr)
    if not plr.Character then return "无" end
    
    local backpack = plr:FindFirstChild("Backpack")
    local character = plr.Character
    
    local hasKnife = false
    local hasGun = false
    
    if character then
        if character:FindFirstChild("Knife") then hasKnife = true end
        if character:FindFirstChild("Gun") then hasGun = true end
        if character:FindFirstChild("Revolver") then hasGun = true end
    end
    
    if backpack then
        if backpack:FindFirstChild("Knife") then hasKnife = true end
        if backpack:FindFirstChild("Gun") then hasGun = true end
        if backpack:FindFirstChild("Revolver") then hasGun = true end
    end
    
    if hasKnife then return "杀手" end
    if hasGun then return "警长" end
    return "平民"
end

local function getRoleColor(role)
    if role == "杀手" then return Color3.fromRGB(255, 0, 0) end
    if role == "警长" then return Color3.fromRGB(0, 150, 255) end
    return Color3.fromRGB(0, 255, 0)
end

local function addESP(plr, role)
    if not plr.Character then return end
    if espObjects[plr] then return end
    
    local head = plr.Character:FindFirstChild("Head")
    if not head then return end
    
    local color = getRoleColor(role)
    
    local highlight = Instance.new("Highlight")
    highlight.FillColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = color
    highlight.OutlineTransparency = 0.2
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = plr.Character
    
    local bg = Instance.new("BillboardGui")
    bg.Size = UDim2.new(0, 200, 0, 40)
    bg.AlwaysOnTop = true
    bg.MaxDistance = math.huge
    bg.Parent = head
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = plr.Name .. "\n[" .. role .. "]"
    label.TextColor3 = color
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextStrokeTransparency = 0.5
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.Parent = bg
    
    espObjects[plr] = {H = highlight, B = bg, LastRole = role}
end

local function scanRoles()
    if not showRoles then return end
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local role = getRole(plr)
            local data = espObjects[plr]
            
            if not data then
                addESP(plr, role)
            else
                -- 角色变了，更新颜色和文字
                if data.LastRole ~= role then
                    local color = getRoleColor(role)
                    data.H.FillColor = color
                    data.H.OutlineColor = color
                    local label = data.B:FindFirstChildWhichIsA("TextLabel")
                    if label then
                        label.Text = plr.Name .. "\n[" .. role .. "]"
                        label.TextColor3 = color
                    end
                    data.LastRole = role
                end
            end
        end
    end
end

-- 用 Heartbeat 独立刷新，缩放不影响
local lastScan = 0
RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - lastScan >= 1 then
        lastScan = now
        pcall(scanRoles)
    end
end)

local function teleportToRole(targetRole)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local role = getRole(plr)
            if role == targetRole then
                local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    hrp.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
                    WindUI:Notify({Title = "传送成功", Content = targetRole .. ": " .. plr.Name, Duration = 2})
                    return
                end
            end
        end
    end
    
    WindUI:Notify({Title = "未找到", Content = "没有找到 " .. targetRole, Duration = 2})
end

local function getPlayerNames()
    local names = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(names, plr.Name)
        end
    end
    if #names == 0 then table.insert(names, "无其他玩家") end
    return names
end

local Window = WindUI:CreateWindow({
    Title = "MM2",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(600, 350),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true,
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--MM2 " .. VERSION,
    Desc = "功能：透视职业 | 传送杀手/警长 | 传送玩家"
})

local MainTab = Window:Tab({Title = "主要功能", Icon = "solar:star-bold"})

MainTab:Toggle({
    Title = "透视职业",
    Desc = "杀手红色 | 警长蓝色 | 平民绿色\n要等发放武器才透视",
    Value = false,
    Callback = function(v)
        showRoles = v
    end
})

MainTab:Divider()

MainTab:Button({
    Title = "传送杀手",
    Callback = function()
        teleportToRole("杀手")
    end
})

MainTab:Button({
    Title = "传送警长",
    Callback = function()
        teleportToRole("警长")
    end
})

MainTab:Divider()

local playerNames = getPlayerNames()
local selectedPlayer = playerNames[1] or "无其他玩家"

local playerDropdown = MainTab:Dropdown({
    Title = "选择玩家",
    Values = playerNames,
    Value = selectedPlayer,
    Callback = function(v)
        selectedPlayer = v
    end
})

MainTab:Button({
    Title = "传送玩家",
    Callback = function()
        local target = Players:FindFirstChild(selectedPlayer)
        if target and target.Character then
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
                if hrp and targetRoot then
                    hrp.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
                    WindUI:Notify({Title = "传送成功", Content = target.Name, Duration = 2})
                end
            end
        else
            WindUI:Notify({Title = "失败", Content = "找不到该玩家", Duration = 2})
        end
    end
})

task.spawn(function()
    while true do
        playerNames = getPlayerNames()
        pcall(function()
            playerDropdown:SetValues(playerNames)
        end)
        task.wait(2)
    end
end)

local SettingsTab = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})
local statusPara = SettingsTab:Paragraph({Title = "功能状态", Desc = "加载中..."})

task.spawn(function()
    while true do
        local count = 0
        for _ in pairs(espObjects) do count = count + 1 end
        local status = ""
        status = status .. "透视职业: " .. (showRoles and "✅" or "❌") .. "\n"
        status = status .. "已透视: " .. count
        statusPara:SetDesc(status)
        task.wait(1)
    end
end)

SettingsTab:Button({
    Title = "关闭面板",
    Callback = function() Window:Close() end
})

Window:OnClose(function()
    showRoles = false
end)

WindUI:Notify({
    Title = "MM2",
    Content = VERSION .. " 加载完成",
    Duration = 2
})
