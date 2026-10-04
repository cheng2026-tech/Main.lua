-- 穿着已留下映像深刻 脚本 v1.0.3
-- WindUI蓝白版 | 自动捡钱

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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Settings = {
    AutoMoneyEnabled = false,
    MoneyDelay = 1,
}

local VERSION = "v1.0.3"
local lastMoneyTime = 0
local lastMoneyScan = 0
local cachedMoney = {}
local currentMoneyIndex = 0

-- 获取所有Money（只获取BasePart和Model类型，避免贴纸干扰）
local function getAllMoney()
    local currentTime = tick()
    if currentTime - lastMoneyScan < 3 and #cachedMoney > 0 then
        return cachedMoney
    end
    
    local moneyList = {}
    local seenObjects = {}
    
    -- 搜索workspace中的BasePart
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name and obj.Name:lower():find("money") then
            if not seenObjects[obj] then
                seenObjects[obj] = true
                table.insert(moneyList, {
                    Object = obj,
                    Position = obj.Position,
                })
            end
        end
    end
    
    -- 搜索workspace中的Model
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name and obj.Name:lower():find("money") then
            if not seenObjects[obj] then
                seenObjects[obj] = true
                local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
                if rootPart then
                    table.insert(moneyList, {
                        Object = obj,
                        Position = rootPart.Position,
                    })
                end
            end
        end
    end
    
    -- 搜索getnilinstances中的BasePart
    pcall(function()
        for _, obj in getnilinstances() do
            if obj:IsA("BasePart") and obj.Name and obj.Name:lower():find("money") then
                if not seenObjects[obj] then
                    seenObjects[obj] = true
                    table.insert(moneyList, {
                        Object = obj,
                        Position = obj.Position,
                    })
                end
            end
        end
    end)
    
    cachedMoney = moneyList
    lastMoneyScan = currentTime
    return moneyList
end

-- 自动捡钱（按顺序一个个传送）
local function autoPickMoney()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    
    local rootPart = character.HumanoidRootPart
    local moneyList = getAllMoney()
    
    if #moneyList == 0 then
        return false
    end
    
    -- 按顺序传送
    currentMoneyIndex = currentMoneyIndex + 1
    if currentMoneyIndex > #moneyList then
        currentMoneyIndex = 1
    end
    
    local money = moneyList[currentMoneyIndex]
    if money and money.Object and money.Object.Parent then
        rootPart.CFrame = CFrame.new(money.Position + Vector3.new(0, 3, 0))
        return true
    end
    
    return false
end

-- 自动捡钱循环
task.spawn(function()
    while true do
        if Settings.AutoMoneyEnabled then
            local currentTime = tick()
            if currentTime - lastMoneyTime >= Settings.MoneyDelay then
                autoPickMoney()
                lastMoneyTime = currentTime
            end
        end
        task.wait(0.05)
    end
end)

local Window = WindUI:CreateWindow({
    Title = "穿着已留下映像深刻",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(400, 350),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true,
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--穿着已留下映像深刻",
    Desc = "版本: " .. VERSION .. "\n\n支持功能：\n• 自动捡钱（按顺序传送）",
})

local MainTab = Window:Tab({Title = "主要功能", Icon = "solar:star-bold"})

MainTab:Toggle({
    Title = "自动捡钱",
    Value = false,
    Callback = function(enabled)
        Settings.AutoMoneyEnabled = enabled
        
        if enabled then
            currentMoneyIndex = 0
            local count = #getAllMoney()
            WindUI:Notify({
                Title = "自动捡钱已开启",
                Content = "找到 " .. count .. " 个Money",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "自动捡钱已关闭",
                Content = "已停止",
                Duration = 2
            })
        end
    end
})

MainTab:Slider({
    Title = "捡钱延迟 (0.1-5秒)",
    Value = {Min = 0.1, Max = 5, Default = 1},
    Step = 0.1,
    Callback = function(delay)
        Settings.MoneyDelay = delay
    end
})

MainTab:Button({
    Title = "手动捡钱一次",
    Callback = function()
        local success = autoPickMoney()
        if success then
            WindUI:Notify({
                Title = "成功",
                Content = "已传送到Money",
                Duration = 2
            })
        else
            WindUI:Notify({
                Title = "失败",
                Content = "找不到Money或角色未加载",
                Duration = 2
            })
        end
    end
})

MainTab:Button({
    Title = "刷新Money列表",
    Callback = function()
        lastMoneyScan = 0
        currentMoneyIndex = 0
        local count = #getAllMoney()
        WindUI:Notify({
            Title = "刷新完成",
            Content = "找到 " .. count .. " 个Money",
            Duration = 2
        })
    end
})

local SettingsTab = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})

local statusParagraph = SettingsTab:Paragraph({
    Title = "功能状态",
    Desc = "正在加载..."
})

local function updateStatus()
    local status = ""
    if Settings.AutoMoneyEnabled then
        status = status .. "✅ 自动捡钱: 已开启\n"
        status = status .. "找到Money: " .. #cachedMoney .. "个\n"
        status = status .. "当前第: " .. currentMoneyIndex .. "个\n"
    else
        status = status .. "❌ 自动捡钱: 未开启\n"
    end
    statusParagraph:SetDesc(status)
end

RunService.Heartbeat:Connect(function() updateStatus() end)

SettingsTab:Button({
    Title = "关闭面板",
    Callback = function() Window:Close() end
})

Window:OnClose(function() end)

WindUI:Notify({
    Title = "穿着已留下映像深刻",
    Content = VERSION .. " 加载完成",
    Duration = 3
})
