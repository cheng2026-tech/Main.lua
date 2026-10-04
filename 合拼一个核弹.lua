-- 合并核弹 脚本 v1.2.0
-- WindUI蓝白版 | 自动合并 | 自动锁定 | 放下核弹

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
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Settings = {
    AutoMergeEnabled = false,
    AutoLockEnabled = false,
    MergeDelay = 0.5,
    SearchRange = 80,
}

local VERSION = "v1.2.0"
local lastMergeTime = 0
local lastLockTime = 0
local currentTarget = nil
local lastNukeScan = 0
local cachedNukes = {}

-- 查找所有核弹（带缓存优化）
local function findAllNukes()
    local currentTime = tick()
    if currentTime - lastNukeScan < 2 and #cachedNukes > 0 then
        return cachedNukes
    end
    
    local nukes = {}
    local myPosition = nil
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        myPosition = LocalPlayer.Character.HumanoidRootPart.Position
    end
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == "Nuke" then
            local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
            if rootPart then
                -- 只搜索范围内的核弹
                if not myPosition or (myPosition - rootPart.Position).Magnitude <= Settings.SearchRange then
                    table.insert(nukes, {
                        Model = obj,
                        RootPart = rootPart,
                        Position = rootPart.Position,
                        Size = rootPart.Size,
                    })
                end
            end
        elseif obj:IsA("BasePart") and obj.Name == "Nuke" then
            -- 只搜索范围内的核弹
            if not myPosition or (myPosition - obj.Position).Magnitude <= Settings.SearchRange then
                table.insert(nukes, {
                    Model = obj,
                    RootPart = obj,
                    Position = obj.Position,
                    Size = obj.Size,
                })
            end
        end
    end
    
    cachedNukes = nukes
    lastNukeScan = currentTime
    return nukes
end

-- 判断两个核弹是否相同
local function areSameNuke(nuke1, nuke2)
    if not nuke1 or not nuke2 then return false end
    if nuke1.Model == nuke2.Model then return false end
    
    local size1 = nuke1.Size
    local size2 = nuke2.Size
    
    if size1 and size2 then
        local sizeDiff = (size1 - size2).Magnitude
        if sizeDiff < 0.1 then
            return true
        end
    end
    
    return false
end

-- 找到两个相同的核弹
local function findMatchingNukes()
    local allNukes = findAllNukes()
    
    if #allNukes < 2 then return nil, nil end
    
    for i = 1, #allNukes do
        for j = i + 1, #allNukes do
            if areSameNuke(allNukes[i], allNukes[j]) then
                return allNukes[i], allNukes[j]
            end
        end
    end
    
    return nil, nil
end

-- 走到核弹旁边
local function walkToNuke(nuke)
    if not nuke or not nuke.RootPart then return false end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("Humanoid") or not character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    
    local humanoid = character.Humanoid
    local rootPart = character.HumanoidRootPart
    local targetPosition = nuke.Position + Vector3.new(0, 0, 3)
    
    humanoid:MoveTo(targetPosition)
    humanoid.WalkSpeed = 16
    
    local startTime = tick()
    while tick() - startTime < 3 do
        if (rootPart.Position - targetPosition).Magnitude < 2 then
            return true
        end
        task.wait(0.1)
    end
    
    return true
end

-- 放下核弹
local function dropNuke()
    local Event = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Remotes") and ReplicatedStorage.Packages.Remotes:FindFirstChild("Networking") and ReplicatedStorage.Packages.Remotes.Networking:FindFirstChild("RE/Pickup/Drop")
    
    if Event then
        Event:FireServer(
            CFrame.new(553.29541015625, 17.571453094482, 269.31860351562, 0.94582825899124, -7.0731487333831e-09, -0.32466760277748, 8.901917425419e-09, 1, 4.1474317313828e-09, 0.32466766238213, -6.8129213381951e-09, 0.94582825899124)
        )
        return true
    end
    
    return false
end

-- 自动锁定
local function autoLock()
    local Event = ReplicatedStorage:FindFirstChild("NukeRemotes") and ReplicatedStorage.NukeRemotes:FindFirstChild("RequestLockBase")
    
    if Event then
        Event:FireServer()
        return true
    end
    
    return false
end

-- 自动合并主逻辑
local function autoMerge()
    local nuke1, nuke2 = findMatchingNukes()
    
    if nuke1 and nuke2 then
        currentTarget = nuke1.Model
        
        walkToNuke(nuke1)
        task.wait(Settings.MergeDelay)
        
        walkToNuke(nuke2)
        task.wait(Settings.MergeDelay)
        
        return true
    else
        currentTarget = nil
        dropNuke()
        return false
    end
end

-- 自动合并循环
task.spawn(function()
    while true do
        if Settings.AutoMergeEnabled then
            local currentTime = tick()
            if currentTime - lastMergeTime >= Settings.MergeDelay then
                autoMerge()
                lastMergeTime = currentTime
            end
        end
        task.wait(0.2)
    end
end)

-- 自动锁定循环
task.spawn(function()
    while true do
        if Settings.AutoLockEnabled then
            local currentTime = tick()
            if currentTime - lastLockTime >= 1 then
                autoLock()
                lastLockTime = currentTime
            end
        end
        task.wait(0.1)
    end
end)

local Window = WindUI:CreateWindow({
    Title = "合并核弹",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(400, 350),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true,
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--合并核弹",
    Desc = "版本: " .. VERSION,
})

local MainTab = Window:Tab({Title = "主要功能", Icon = "solar:star-bold"})

MainTab:Toggle({
    Title = "自动合并",
    Value = false,
    Callback = function(enabled)
        Settings.AutoMergeEnabled = enabled
        
        if enabled then
            WindUI:Notify({
                Title = "自动合并已开启",
                Content = "搜索范围: " .. Settings.SearchRange .. "米",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "自动合并已关闭",
                Content = "已停止合并",
                Duration = 2
            })
            currentTarget = nil
        end
    end
})

MainTab:Slider({
    Title = "合并延迟 (0.1-3秒)",
    Value = {Min = 0.1, Max = 3, Default = 0.5},
    Step = 0.1,
    Callback = function(delay)
        Settings.MergeDelay = delay
    end
})

MainTab:Divider()

MainTab:Toggle({
    Title = "自动锁定",
    Value = false,
    Callback = function(enabled)
        Settings.AutoLockEnabled = enabled
        
        if enabled then
            WindUI:Notify({
                Title = "自动锁定已开启",
                Content = "每秒锁定一次",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "自动锁定已关闭",
                Content = "已停止锁定",
                Duration = 2
            })
        end
    end
})

MainTab:Divider()

MainTab:Button({
    Title = "手动合并一次",
    Callback = function()
        autoMerge()
    end
})

MainTab:Button({
    Title = "放下核弹",
    Callback = function()
        local success = dropNuke()
        if success then
            WindUI:Notify({
                Title = "成功",
                Content = "已放下核弹",
                Duration = 2
            })
        else
            WindUI:Notify({
                Title = "失败",
                Content = "找不到放下事件",
                Duration = 2
            })
        end
    end
})

local SettingsTab = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})

local statusParagraph = SettingsTab:Paragraph({
    Title = "功能状态",
    Desc = "正在加载..."
})

local function updateStatus()
    local status = ""
    
    if Settings.AutoMergeEnabled then
        status = status .. "✅ 自动合并: 已开启\n"
        status = status .. "搜索范围: " .. Settings.SearchRange .. "米\n"
        
        if currentTarget then
            status = status .. "当前目标: " .. currentTarget.Name .. "\n"
        else
            status = status .. "当前目标: 寻找中...\n"
        end
        
        local allNukes = findAllNukes()
        status = status .. "范围内核弹: " .. #allNukes .. "\n"
    else
        status = status .. "❌ 自动合并: 未开启\n"
    end
    
    if Settings.AutoLockEnabled then
        status = status .. "✅ 自动锁定: 已开启\n"
    else
        status = status .. "❌ 自动锁定: 未开启\n"
    end
    
    statusParagraph:SetDesc(status)
end

RunService.Heartbeat:Connect(function()
    updateStatus()
end)

SettingsTab:Button({
    Title = "关闭面板",
    Callback = function()
        Window:Close()
    end
})

Window:OnClose(function()
    Settings.AutoMergeEnabled = false
    Settings.AutoLockEnabled = false
    currentTarget = nil
end)

WindUI:Notify({
    Title = "合并核弹",
    Content = VERSION .. " 加载完成",
    Duration = 3
})
