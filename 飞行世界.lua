-- 飞行世界 脚本 v1.2.2
-- WindUI蓝白版 | 完成配送 | 智能检测卡地 | 半自动模式 | 自定义刷新时间

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
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local VERSION = "v1.2.2"
local isFlying = false
local flySpeed = 1000
local stuckCheck = false
local stuckCount = 0
local semiAutoMode = false
local scanInterval = 5

local function getPlayerVehicle()
    local character = LocalPlayer.Character
    if not character then return nil end
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("VehicleSeat") and obj.Occupant == character then
            local parent = obj.Parent
            if parent and parent:IsA("Model") then
                return parent
            end
        end
    end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.SeatPart then
        local seat = humanoid.SeatPart
        local parent = seat.Parent
        if parent and parent:IsA("Model") then
            return parent
        end
    end
    
    return nil
end

local function getVehicleRoot(vehicle)
    if not vehicle then return nil end
    local root = vehicle:FindFirstChild("HumanoidRootPart")
    if not root then
        root = vehicle.PrimaryPart
    end
    if not root then
        for _, part in pairs(vehicle:GetDescendants()) do
            if part:IsA("BasePart") then
                root = part
                break
            end
        end
    end
    return root
end

local function getNearestHighlight()
    local character = LocalPlayer.Character
    if not character then return nil, nil end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, nil end
    
    local myPos = hrp.Position
    local targetPos = nil
    local nearestDist = math.huge
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "Highlight" then
            local rootPart = nil
            if obj:IsA("Model") then
                rootPart = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            elseif obj:IsA("BasePart") then
                rootPart = obj
            end
            
            if rootPart and rootPart.Position then
                local dist = (myPos - rootPart.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    targetPos = rootPart.Position
                end
            end
        end
    end
    
    return targetPos, nearestDist
end

local function flyTo(targetPos)
    if isFlying then return end
    isFlying = true
    
    local character = LocalPlayer.Character
    if not character then
        isFlying = false
        WindUI:Notify({Title = "失败", Content = "找不到角色", Duration = 2})
        return
    end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        isFlying = false
        WindUI:Notify({Title = "失败", Content = "找不到HumanoidRootPart", Duration = 2})
        return
    end
    
    local vehicle = getPlayerVehicle()
    local vehicleRoot = vehicle and getVehicleRoot(vehicle)
    
    local startPos = hrp.Position
    local startVehiclePos = vehicleRoot and vehicleRoot.Position or startPos
    
    local highPos = Vector3.new(startPos.X, startPos.Y + 1000, startPos.Z)
    local highVehiclePos = Vector3.new(startVehiclePos.X, startVehiclePos.Y + 1000, startVehiclePos.Z)
    
    local targetHighPos = Vector3.new(targetPos.X, startPos.Y + 1000, targetPos.Z)
    local targetHighVehiclePos = Vector3.new(targetPos.X, startVehiclePos.Y + 1000, targetPos.Z)
    
    local midPos = Vector3.new(targetPos.X, targetPos.Y + 20, targetPos.Z)
    local midVehiclePos = Vector3.new(targetPos.X, targetPos.Y + 18, targetPos.Z)
    
    local finalPos = Vector3.new(targetPos.X, targetPos.Y + 5, targetPos.Z)
    local finalVehiclePos = Vector3.new(targetPos.X, targetPos.Y + 3, targetPos.Z)
    
    local speed = flySpeed
    
    local dist1 = (highPos - startPos).Magnitude
    local steps1 = math.max(5, math.floor(dist1 / speed * 60))
    for i = 0, steps1 do
        if not isFlying then break end
        local t = i / steps1
        local currentPos = startPos + (highPos - startPos) * t
        hrp.CFrame = CFrame.new(currentPos)
        if vehicleRoot then
            vehicleRoot.CFrame = CFrame.new(startVehiclePos + (highVehiclePos - startVehiclePos) * t)
        end
        task.wait()
    end
    
    local dist2 = (targetHighPos - highPos).Magnitude
    local steps2 = math.max(5, math.floor(dist2 / speed * 60))
    for i = 0, steps2 do
        if not isFlying then break end
        local t = i / steps2
        local currentPos = highPos + (targetHighPos - highPos) * t
        hrp.CFrame = CFrame.new(currentPos)
        if vehicleRoot then
            vehicleRoot.CFrame = CFrame.new(highVehiclePos + (targetHighVehiclePos - highVehiclePos) * t)
        end
        task.wait()
    end
    
    local dist3 = (midPos - targetHighPos).Magnitude
    local steps3 = math.max(5, math.floor(dist3 / speed * 60))
    for i = 0, steps3 do
        if not isFlying then break end
        local t = i / steps3
        local currentPos = targetHighPos + (midPos - targetHighPos) * t
        hrp.CFrame = CFrame.new(currentPos)
        if vehicleRoot then
            vehicleRoot.CFrame = CFrame.new(targetHighVehiclePos + (midVehiclePos - targetHighVehiclePos) * t)
        end
        task.wait()
    end
    
    local dist4 = (finalPos - midPos).Magnitude
    local steps4 = math.max(25, math.floor(dist4 / 10 * 60))
    for i = 0, steps4 do
        if not isFlying then break end
        local t = i / steps4
        local currentPos = midPos + (finalPos - midPos) * t
        hrp.CFrame = CFrame.new(currentPos)
        if vehicleRoot then
            vehicleRoot.CFrame = CFrame.new(midVehiclePos + (finalVehiclePos - midVehiclePos) * t)
        end
        task.wait()
    end
    
    hrp.CFrame = CFrame.new(finalPos)
    if vehicleRoot then
        vehicleRoot.CFrame = CFrame.new(finalVehiclePos)
    end
    
    isFlying = false
end

-- 半自动模式循环
task.spawn(function()
    while true do
        if semiAutoMode then
            local targetPos, dist = getNearestHighlight()
            if targetPos and dist > 20 then
                WindUI:Notify({Title = "半自动", Content = "检测到配送点，距离" .. math.floor(dist) .. "米，开始配送", Duration = 2})
                flyTo(targetPos)
                task.wait(2)
            elseif targetPos and dist <= 20 then
                task.wait(scanInterval)
            else
                task.wait(scanInterval)
            end
        else
            task.wait(1)
        end
    end
end)

-- 智能检测卡地
task.spawn(function()
    while true do
        if stuckCheck then
            local character = LocalPlayer.Character
            if character then
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local currentPos = hrp.Position
                    
                    if currentPos.Y < 0 then
                        stuckCount = stuckCount + 1
                        if stuckCount > 3 then
                            local rescuePos = Vector3.new(currentPos.X, 100, currentPos.Z)
                            hrp.CFrame = CFrame.new(rescuePos)
                            
                            local vehicle = getPlayerVehicle()
                            if vehicle then
                                local vehicleRoot = getVehicleRoot(vehicle)
                                if vehicleRoot then
                                    vehicleRoot.CFrame = CFrame.new(rescuePos + Vector3.new(0, 2, 0))
                                end
                            end
                            
                            WindUI:Notify({Title = "救援", Content = "检测到卡地，已传送到高空", Duration = 2})
                            stuckCount = 0
                        end
                    else
                        stuckCount = 0
                    end
                end
            end
        end
        task.wait(1)
    end
end)

local Window = WindUI:CreateWindow({
    Title = "黑脚本--飞行世界",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(600, 350),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true,
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--飞行世界 " .. VERSION,
    Desc = "功能：完成配送 | 智能检测卡地 | 半自动模式\n\n半自动模式：检测到Highlight距离>20米自动飞过去\n自定义检测间隔"
})

local MainTab = Window:Tab({Title = "主要功能", Icon = "solar:star-bold"})

MainTab:Button({
    Title = "完成一次配送",
    Callback = function()
        local targetPos, dist = getNearestHighlight()
        if targetPos then
            flyTo(targetPos)
        else
            WindUI:Notify({Title = "失败", Content = "找不到Highlight", Duration = 2})
        end
    end
})

MainTab:Divider()

MainTab:Toggle({
    Title = "半自动模式 (Alpha)",
    Desc = "距离>20米自动配送，≤20米不配送\n温馨提示开启时需关闭引擎\n概率掉进海里出现bug",
    Value = false,
    Callback = function(enabled)
        semiAutoMode = enabled
        if enabled then
            WindUI:Notify({Title = "半自动模式", Content = "已开启，阈值20米", Duration = 2})
        else
            WindUI:Notify({Title = "半自动模式", Content = "已关闭", Duration = 2})
        end
    end
})

MainTab:Slider({
    Title = "检测间隔 (5-60秒)",
    Value = {Min = 5, Max = 60, Default = 5},
    Step = 1,
    Callback = function(v)
        scanInterval = v
        WindUI:Notify({Title = "间隔已设置", Content = "当前间隔: " .. v .. "秒", Duration = 1})
    end
})

MainTab:Divider()

MainTab:Slider({
    Title = "飞行速度 (1000-20000)",
    Value = {Min = 1000, Max = 20000, Default = 1000},
    Step = 100,
    Callback = function(v)
        flySpeed = v
        WindUI:Notify({Title = "速度已设置", Content = "当前速度: " .. v, Duration = 1})
    end
})

MainTab:Divider()

MainTab:Toggle({
    Title = "智能检测卡地",
    Value = false,
    Callback = function(enabled)
        stuckCheck = enabled
        stuckCount = 0
    end
})

local SettingsTab = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})
local statusPara = SettingsTab:Paragraph({Title = "功能状态", Desc = "加载中..."})

task.spawn(function()
    while true do
        local status = ""
        local targetPos, dist = getNearestHighlight()
        status = status .. "半自动模式: " .. (semiAutoMode and "已开启" or "未开启") .. "\n"
        status = status .. "最近Highlight: " .. (targetPos and math.floor(dist) .. "米" or "未找到") .. "\n"
        status = status .. "检测间隔: " .. scanInterval .. "秒\n"
        status = status .. "飞行速度: " .. flySpeed .. "\n"
        status = status .. "卡地检测: " .. (stuckCheck and "已开启" or "未开启") .. "\n"
        
        local vehicle = getPlayerVehicle()
        status = status .. "载具状态: " .. (vehicle and "已找到" or "未找到") .. "\n"
        status = status .. "飞行中: " .. (isFlying and "是" or "否") .. "\n"
        
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
    isFlying = false
    stuckCheck = false
    semiAutoMode = false
end)

WindUI:Notify({
    Title = "飞行世界",
    Content = VERSION .. " 加载完成",
    Duration = 3
})
