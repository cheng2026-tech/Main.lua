-- 拯救你的猫咪 脚本 v1.0.4
-- WindUI蓝白版 | 自动收集种子

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
local Workspace = game:GetService("Workspace")

local Settings = {
    AutoSeedEnabled = false,
    SeedDelay = 1,
}

local VERSION = "v1.0.4"
local lastSeedTime = 0
local lastSeedScan = 0
local cachedStageButtons = {}
local visitedStageButtons = {}

-- 获取所有StageButton（按距离从远到近排序）
local function getAllStageButtons()
    local currentTime = tick()
    if currentTime - lastSeedScan < 3 and #cachedStageButtons > 0 then
        return cachedStageButtons
    end
    
    local buttons = {}
    local myPosition = nil
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        myPosition = LocalPlayer.Character.HumanoidRootPart.Position
    end
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name and obj.Name:lower():find("stagebutton") then
            local rootPart = nil
            if obj:IsA("Model") then
                rootPart = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            elseif obj:IsA("BasePart") then
                rootPart = obj
            end
            
            if rootPart then
                local distance = 0
                if myPosition then
                    distance = (myPosition - rootPart.Position).Magnitude
                end
                table.insert(buttons, {
                    Object = obj,
                    RootPart = rootPart,
                    Position = rootPart.Position,
                    Distance = distance,
                })
            end
        end
    end
    
    table.sort(buttons, function(a, b) return a.Distance > b.Distance end)
    
    cachedStageButtons = buttons
    lastSeedScan = currentTime
    return buttons
end

-- 获取下一个未访问的StageButton
local function getNextUnvisitedStageButton()
    local buttons = getAllStageButtons()
    
    for _, button in pairs(buttons) do
        if not visitedStageButtons[button.Object] then
            return button
        end
    end
    
    -- 全部访问过了，重置
    visitedStageButtons = {}
    return buttons[1]
end

-- 自动收集种子
local function autoCollectSeed()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    
    local rootPart = character.HumanoidRootPart
    local target = getNextUnvisitedStageButton()
    
    if not target then return false end
    
    rootPart.CFrame = CFrame.new(target.Position + Vector3.new(0, 10, 0))
    visitedStageButtons[target.Object] = true
    
    return true
end

-- 自动收集种子循环
task.spawn(function()
    while true do
        if Settings.AutoSeedEnabled then
            local currentTime = tick()
            if currentTime - lastSeedTime >= Settings.SeedDelay then
                autoCollectSeed()
                lastSeedTime = currentTime
            end
        end
        task.wait(0.05)
    end
end)

local Window = WindUI:CreateWindow({
    Title = "拯救你的猫咪",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(400, 350),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true,
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--拯救你的猫咪",
    Desc = "版本: " .. VERSION .. "\n\n支持功能：\n• 自动收集种子（传送到最远StageButton，不重复）",
})

local MainTab = Window:Tab({Title = "主要功能", Icon = "solar:star-bold"})

MainTab:Toggle({
    Title = "自动收集种子",
    Value = false,
    Callback = function(enabled)
        Settings.AutoSeedEnabled = enabled
        
        if enabled then
            local buttons = getAllStageButtons()
            WindUI:Notify({
                Title = "自动收集已开启",
                Content = "找到 " .. #buttons .. " 个StageButton",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "自动收集已关闭",
                Content = "已停止",
                Duration = 2
            })
        end
    end
})

MainTab:Slider({
    Title = "收集延迟 (0.5-5秒)",
    Value = {Min = 0.5, Max = 5, Default = 1},
    Step = 0.5,
    Callback = function(delay)
        Settings.SeedDelay = delay
    end
})

MainTab:Button({
    Title = "手动收集一次",
    Callback = function()
        if autoCollectSeed() then
            WindUI:Notify({Title = "成功", Content = "已传送到StageButton", Duration = 2})
        else
            WindUI:Notify({Title = "失败", Content = "找不到StageButton", Duration = 2})
        end
    end
})

local SettingsTab = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})

local statusParagraph = SettingsTab:Paragraph({
    Title = "功能状态",
    Desc = "正在加载..."
})

task.spawn(function()
    while true do
        local status = ""
        
        if Settings.AutoSeedEnabled then
            status = status .. "✅ 自动收集种子: 已开启\n"
            status = status .. "找到: " .. #cachedStageButtons .. "个\n"
            local visitedCount = 0
            for _ in pairs(visitedStageButtons) do visitedCount = visitedCount + 1 end
            status = status .. "已访问: " .. visitedCount .. "个\n"
        else
            status = status .. "❌ 自动收集种子: 未开启\n"
        end
        
        statusParagraph:SetDesc(status)
        task.wait(1)
    end
end)

SettingsTab:Button({
    Title = "关闭面板",
    Callback = function() Window:Close() end
})

Window:OnClose(function() end)

WindUI:Notify({
    Title = "拯救你的猫咪",
    Content = VERSION .. " 加载完成",
    Duration = 3
})
