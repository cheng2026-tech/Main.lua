-- 谁打了一巴掌 脚本 v1.0.6
-- WindUI蓝白版 | 刷钱 | 显示最近玩家

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
if not WindUI then return end

WindUI:AddTheme({
    Name = "冰白",
    Accent = "#80C0FF",
    Outline = "#6090C0",
    Text = "#FFFFFF",
    Placeholder = "#D0E0FF",
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:FindFirstChild("Events")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local VERSION = "v1.0.6"
local boxFarm = false
local chairFarm = false
local showPlayer = false
local screenGui = nil
local frame = nil
local textLabel = nil

local function createUI()
    if screenGui then
        screenGui:Destroy()
        screenGui = nil
    end
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SlapDisplay"
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 9999
    screenGui.Enabled = true
    
    frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 60)
    frame.Position = UDim2.new(0.5, -175, 0.02, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)
    
    textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "附近玩家: 无"
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 20
    textLabel.TextScaled = true
    textLabel.Parent = frame
end

local function destroyUI()
    if screenGui then
        screenGui:Destroy()
        screenGui = nil
        frame = nil
        textLabel = nil
    end
end

local function getNearestPlayer()
    local char = LocalPlayer.Character
    if not char then return "无" end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return "无" end
    local myPos = hrp.Position
    local nearest = nil
    local nearestDist = math.huge
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local targetHrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if targetHrp then
                local dist = (myPos - targetHrp.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearest = plr
                end
            end
        end
    end
    
    if nearest then
        return nearest.DisplayName
    end
    return "无"
end

task.spawn(function()
    while true do
        if showPlayer then
            local name = getNearestPlayer()
            if textLabel then
                textLabel.Text = "附近玩家: " .. name
            end
        end
        task.wait(0.5)
    end
end)

task.spawn(function()
    while true do
        if boxFarm and Events then
            local CreateRE = Events:FindFirstChild("CreateRE")
            if CreateRE then
                pcall(function()
                    CreateRE:FireServer("Slap Premium Crate", "Cammon", 0)
                end)
            end
        end
        task.wait(0.1)
    end
end)

task.spawn(function()
    while true do
        if chairFarm and Events then
            local CreateRE = Events:FindFirstChild("CreateRE")
            if CreateRE then
                pcall(function()
                    CreateRE:FireServer("Chair Premium Crate", "Cammon", 0)
                end)
            end
        end
        task.wait(0.1)
    end
end)

local Window = WindUI:CreateWindow({
    Title = "谁打了一巴掌",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(600, 350),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true,
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--谁打了一巴掌 v1.0.6",
    Desc = "功能：刷钱 | 显示最近玩家\n秋辞死妈"
})

local MainTab = Window:Tab({Title = "主要功能", Icon = "solar:star-bold"})

MainTab:Toggle({
    Title = "刷钱(巴掌农场)",
    Value = false,
    Callback = function(v)
        boxFarm = v
    end
})

MainTab:Divider()

MainTab:Toggle({
    Title = "刷钱(椅子农场)",
    Value = false,
    Callback = function(v)
        chairFarm = v
    end
})

MainTab:Divider()

MainTab:Toggle({
    Title = "显示最近玩家",
    Value = false,
    Callback = function(v)
        showPlayer = v
        if v then
            createUI()
        else
            destroyUI()
        end
    end
})

local SettingsTab = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})
local statusPara = SettingsTab:Paragraph({Title = "功能状态", Desc = "加载中..."})

task.spawn(function()
    while true do
        local status = ""
        status = status .. "箱子农场: " .. (boxFarm and "✅" or "❌") .. "\n"
        status = status .. "椅子农场: " .. (chairFarm and "✅" or "❌") .. "\n"
        status = status .. "显示最近玩家: " .. (showPlayer and "✅" or "❌") .. "\n"
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
    boxFarm = false
    chairFarm = false
    destroyUI()
end)

WindUI:Notify({
    Title = "谁打了一巴掌",
    Content = "v1.0.6 加载完成",
    Duration = 3
})
