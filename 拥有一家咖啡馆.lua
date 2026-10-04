-- 我的咖啡厅 脚本 v1.11
-- 修复收碗洗走到水槽后不点左键的问题
local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

-- ==================== 服务引用 ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- ==================== 配置 ====================
local Settings = {
    AutoCollect = false,
    AutoCoffee = false,
    FullAuto = false,
    AutoQuest = false,
    IsMobile = true,
}

local savedPositions = {
    tablePos = nil,
    sinkPos = nil,
    coffeeBeanPos = nil,
    coffeeMachinePos = nil,
}

local originalWalkSpeed = 16
local configFileName = "MyCafe_Config.txt"
local VERSION = "v1.11"
local QuestLoop = nil

-- ==================== 停止所有功能 ====================
local function stopAll()
    Settings.AutoCollect = false
    Settings.AutoCoffee = false
    Settings.FullAuto = false
    
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, nil, 0)
    
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = originalWalkSpeed
    end
end

-- ==================== 保存/加载配置 ====================
local function saveConfig()
    if not savedPositions.tablePos or not savedPositions.sinkPos or not savedPositions.coffeeBeanPos or not savedPositions.coffeeMachinePos then
        WI:Notify({Title = "错误", Content = "请先定位所有位置！", Duration = 3})
        return
    end
    local data = {
        tableX = savedPositions.tablePos.X, tableY = savedPositions.tablePos.Y, tableZ = savedPositions.tablePos.Z,
        sinkX = savedPositions.sinkPos.X, sinkY = savedPositions.sinkPos.Y, sinkZ = savedPositions.sinkPos.Z,
        beanX = savedPositions.coffeeBeanPos.X, beanY = savedPositions.coffeeBeanPos.Y, beanZ = savedPositions.coffeeBeanPos.Z,
        machineX = savedPositions.coffeeMachinePos.X, machineY = savedPositions.coffeeMachinePos.Y, machineZ = savedPositions.coffeeMachinePos.Z,
    }
    pcall(function()
        writefile(configFileName, game:GetService("HttpService"):JSONEncode(data))
        WI:Notify({Title = "成功", Content = "所有坐标已保存！", Duration = 3})
    end)
end

local function loadConfig()
    local success, result = pcall(function()
        if isfile(configFileName) then
            return game:GetService("HttpService"):JSONDecode(readfile(configFileName))
        end
        return nil
    end)
    if success and result then
        savedPositions.tablePos = Vector3.new(result.tableX, result.tableY, result.tableZ)
        savedPositions.sinkPos = Vector3.new(result.sinkX, result.sinkY, result.sinkZ)
        savedPositions.coffeeBeanPos = Vector3.new(result.beanX, result.beanY, result.beanZ)
        savedPositions.coffeeMachinePos = Vector3.new(result.machineX, result.machineY, result.machineZ)
        WI:Notify({Title = "成功", Content = "上次坐标配置已加载！", Duration = 3})
        return true
    else
        WI:Notify({Title = "失败", Content = "没有找到保存的配置", Duration = 3})
        return false
    end
end

-- ==================== 获取当前位置 ====================
local function getCurrentPosition()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        return char.HumanoidRootPart.Position
    end
    return nil
end

-- ==================== 按E ====================
local function pressE()
    if Settings.IsMobile then
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled then
                local parent = obj.Parent
                if parent and parent:IsA("BasePart") then
                    if (root.Position - parent.Position).Magnitude < 15 then
                        pcall(function() fireproximityprompt(obj) end)
                        break
                    end
                end
            end
        end
    else
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
    end
end

-- ==================== 点左键 ====================
local function clickLeft()
    if Settings.IsMobile then
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ClickDetector") then
                local parent = obj.Parent
                if parent and parent:IsA("BasePart") then
                    if (root.Position - parent.Position).Magnitude < 20 then
                        pcall(function() fireclickdetector(obj) end)
                    end
                end
            end
        end
    else
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, nil, 0)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, nil, 0)
    end
end

-- ==================== 移动 ====================
local function moveTo(targetPos, settingKey)
    local char = LocalPlayer.Character
    if not char then return false end
    local humanoid = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return false end
    
    humanoid.WalkSpeed = 50
    humanoid:MoveTo(targetPos)
    
    local lastPos = root.Position
    local stuckTime = 0
    
    while (root.Position - targetPos).Magnitude > 5 do
        if not Settings[settingKey] then return false end
        if not char or not char.Parent then return false end
        if not root or not root.Parent then return false end
        
        if (root.Position - lastPos).Magnitude < 0.5 then
            stuckTime = stuckTime + 0.1
        else
            stuckTime = 0
            lastPos = root.Position
        end
        
        if stuckTime > 2 then
            humanoid.Jump = true
            stuckTime = 0
        end
        
        pressE()
        humanoid:MoveTo(targetPos)
        task.wait(0.1)
    end
    return true
end

-- ==================== 自动领任务钱 ====================
local function startAutoQuest()
    if QuestLoop then return end
    
    pcall(function()
        local Event = ReplicatedStorage.Shared.RBXUtil.Net["RF/ClaimPathQuest"]
        Event:InvokeServer()
    end)
    
    QuestLoop = task.spawn(function()
        while Settings.AutoQuest do
            task.wait(30)
            if not Settings.AutoQuest then break end
            pcall(function()
                local Event = ReplicatedStorage.Shared.RBXUtil.Net["RF/ClaimPathQuest"]
                Event:InvokeServer()
            end)
        end
        QuestLoop = nil
    end)
end

-- ==================== 自动收碗+洗 ====================
local function startAutoCollect()
    if not savedPositions.tablePos then
        WI:Notify({Title = "错误", Content = "请先定位桌子！", Duration = 3})
        Settings.AutoCollect = false
        return
    end
    if not savedPositions.sinkPos then
        WI:Notify({Title = "错误", Content = "请先定位水槽！", Duration = 3})
        Settings.AutoCollect = false
        return
    end
    
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Humanoid") then
        WI:Notify({Title = "错误", Content = "角色未加载！", Duration = 3})
        Settings.AutoCollect = false
        return
    end
    
    task.spawn(function()
        while Settings.AutoCollect do
            -- 去桌子
            moveTo(savedPositions.tablePos, "AutoCollect")
            if not Settings.AutoCollect then break end
            pressE()
            task.wait(0.5)
            
            -- 去水槽
            moveTo(savedPositions.sinkPos, "AutoCollect")
            if not Settings.AutoCollect then break end
            pressE()
            task.wait(0.3)
            
            -- 疯狂点左键10秒洗碗
            local t = tick()
            while tick() - t < 10 do
                if not Settings.AutoCollect then break end
                clickLeft()
                task.wait(0.05)
            end
            
            task.wait(0.3)
        end
        
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = originalWalkSpeed
        end
    end)
end

-- ==================== 自动做咖啡 ====================
local function startAutoCoffee()
    if not savedPositions.coffeeBeanPos then
        WI:Notify({Title = "错误", Content = "请先定位咖啡豆！", Duration = 3})
        Settings.AutoCoffee = false
        return
    end
    if not savedPositions.coffeeMachinePos then
        WI:Notify({Title = "错误", Content = "请先定位咖啡机！", Duration = 3})
        Settings.AutoCoffee = false
        return
    end
    
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Humanoid") then
        WI:Notify({Title = "错误", Content = "角色未加载！", Duration = 3})
        Settings.AutoCoffee = false
        return
    end
    
    task.spawn(function()
        while Settings.AutoCoffee do
            -- 去咖啡豆
            moveTo(savedPositions.coffeeBeanPos, "AutoCoffee")
            if not Settings.AutoCoffee then break end
            pressE()
            task.wait(0.5)
            
            -- 去咖啡机
            moveTo(savedPositions.coffeeMachinePos, "AutoCoffee")
            if not Settings.AutoCoffee then break end
            pressE()
            task.wait(0.3)
            
            -- 疯狂点左键5秒做咖啡
            local t = tick()
            while tick() - t < 5 do
                if not Settings.AutoCoffee then break end
                clickLeft()
                task.wait(0.05)
            end
            
            task.wait(0.3)
        end
        
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = originalWalkSpeed
        end
    end)
end

-- ==================== 全自动模式 ====================
local function startFullAuto()
    if not savedPositions.tablePos or not savedPositions.sinkPos or not savedPositions.coffeeBeanPos or not savedPositions.coffeeMachinePos then
        WI:Notify({Title = "错误", Content = "请先定位所有4个位置！", Duration = 3})
        Settings.FullAuto = false
        return
    end
    
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Humanoid") then
        WI:Notify({Title = "错误", Content = "角色未加载！", Duration = 3})
        Settings.FullAuto = false
        return
    end
    
    task.spawn(function()
        while Settings.FullAuto do
            -- 做咖啡：去咖啡豆
            moveTo(savedPositions.coffeeBeanPos, "FullAuto")
            if not Settings.FullAuto then break end
            pressE()
            task.wait(0.5)
            
            -- 做咖啡：去咖啡机
            moveTo(savedPositions.coffeeMachinePos, "FullAuto")
            if not Settings.FullAuto then break end
            pressE()
            task.wait(0.3)
            
            -- 点左键5秒
            local t = tick()
            while tick() - t < 5 do
                if not Settings.FullAuto then break end
                clickLeft()
                task.wait(0.05)
            end
            if not Settings.FullAuto then break end
            
            task.wait(0.3)
            
            -- 收碗：去桌子
            moveTo(savedPositions.tablePos, "FullAuto")
            if not Settings.FullAuto then break end
            pressE()
            task.wait(0.5)
            
            -- 收碗：去水槽
            moveTo(savedPositions.sinkPos, "FullAuto")
            if not Settings.FullAuto then break end
            pressE()
            task.wait(0.3)
            
            -- 点左键10秒
            t = tick()
            while tick() - t < 10 do
                if not Settings.FullAuto then break end
                clickLeft()
                task.wait(0.05)
            end
            
            task.wait(0.3)
        end
        
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = originalWalkSpeed
        end
    end)
end

-- ==================== 创建窗口 ====================
local Win = WI:CreateWindow({
    Title = "我的咖啡厅",
    Icon = "solar:cup-hot-bold",
    Size = UDim2.fromOffset(420, 460),
    Acrylic = true,
    ScrollBarEnabled = true,
})

-- ==================== 公告标签页 ====================
local TabAnnounce = Win:Tab({
    Title = "公告",
    Icon = "solar:home-bold"
})

TabAnnounce:Paragraph({
    Title = "He--Script 使用说明",
    Desc = [[
    1. 定位页设置4个坐标
    2. 选择手机/电脑模式
    3. 开启需要的功能
    
    移动时：一直按E
    到达后：补E + 疯狂点左键
    
    收碗洗：点左键10秒
    做咖啡：点左键5秒
    
    版本：]] .. VERSION
})

-- ==================== 定位标签页 ====================
local TabPosition = Win:Tab({
    Title = "定位",
    Icon = "solar:map-point-bold"
})

TabPosition:Button({Title = "定位桌子", Justify = "Center", Color = Color3.fromHex("#4CAF50"), Callback = function() local pos = getCurrentPosition() if pos then savedPositions.tablePos = pos end WI:Notify({Title = "定位成功", Content = "桌子", Duration = 1}) end})
TabPosition:Divider()
TabPosition:Button({Title = "定位水槽", Justify = "Center", Color = Color3.fromHex("#2196F3"), Callback = function() local pos = getCurrentPosition() if pos then savedPositions.sinkPos = pos end WI:Notify({Title = "定位成功", Content = "水槽", Duration = 1}) end})
TabPosition:Divider()
TabPosition:Button({Title = "定位咖啡豆", Justify = "Center", Color = Color3.fromHex("#8D6E63"), Callback = function() local pos = getCurrentPosition() if pos then savedPositions.coffeeBeanPos = pos end WI:Notify({Title = "定位成功", Content = "咖啡豆", Duration = 1}) end})
TabPosition:Divider()
TabPosition:Button({Title = "定位咖啡机", Justify = "Center", Color = Color3.fromHex("#607D8B"), Callback = function() local pos = getCurrentPosition() if pos then savedPositions.coffeeMachinePos = pos end WI:Notify({Title = "定位成功", Content = "咖啡机", Duration = 1}) end})
TabPosition:Divider()
TabPosition:Button({Title = "保存当前坐标", Justify = "Center", Color = Color3.fromHex("#FF9800"), Callback = function() saveConfig() end})
TabPosition:Divider()
TabPosition:Button({Title = "加载上次配置", Justify = "Center", Color = Color3.fromHex("#9C27B0"), Callback = function() loadConfig() end})

-- ==================== 自动标签页 ====================
local TabAuto = Win:Tab({
    Title = "自动",
    Icon = "solar:play-bold"
})

TabAuto:Toggle({Title = "手机模式", Value = true, Callback = function(v) Settings.IsMobile = v end})
TabAuto:Divider()
TabAuto:Toggle({Title = "自动领任务钱", Value = false, Callback = function(v) Settings.AutoQuest = v if v then startAutoQuest() end end})
TabAuto:Divider()
TabAuto:Toggle({Title = "自动收碗+洗", Value = false, Callback = function(v) if v then stopAll() Settings.AutoCollect = true startAutoCollect() else stopAll() end end})
TabAuto:Divider()
TabAuto:Toggle({Title = "自动做咖啡", Value = false, Callback = function(v) if v then stopAll() Settings.AutoCoffee = true startAutoCoffee() else stopAll() end end})
TabAuto:Divider()
TabAuto:Toggle({Title = "全自动模式", Value = false, Callback = function(v) if v then stopAll() Settings.FullAuto = true startFullAuto() else stopAll() end end})

-- ==================== 设置标签页 ====================
local TabSettings = Win:Tab({
    Title = "设置",
    Icon = "solar:settings-bold"
})

TabSettings:Button({Title = "清除定位坐标", Justify = "Center", Color = Color3.fromHex("#888888"), Callback = function() savedPositions.tablePos = nil savedPositions.sinkPos = nil savedPositions.coffeeBeanPos = nil savedPositions.coffeeMachinePos = nil WI:Notify({Title = "提示", Content = "所有坐标已清除", Duration = 2}) end})
TabSettings:Divider()
TabSettings:Button({Title = "关闭脚本", Justify = "Center", Color = Color3.fromHex("#ff4444"), Callback = function() Settings.AutoQuest = false stopAll() Win:Close() end})

-- ==================== 启动通知 ====================
WI:Notify({Title = "我的咖啡厅", Content = "脚本加载完成！" .. VERSION, Duration = 5})
print("我的咖啡厅 " .. VERSION .. " 脚本已加载")
