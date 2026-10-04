-- 草地增量模拟器 | V1.3

local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- ==================== 变量 ====================
local loopCollect = false
local autoUpgradeValue = false
local autoUpgradeAmount = false
local autoUpgradeSpawn = false
local autoRebirth = false
local autoFarm = false
local autoFarmIsland = 1
local fullAuto = false
local collectThread = nil
local upgradeValueThread = nil
local upgradeAmountThread = nil
local upgradeSpawnThread = nil
local rebirthThread = nil
local farmThread = nil
local speedValue = 16
local speedEnabled = false
local espEnabled = false
local espHighlights = {}

-- ==================== 岛屿坐标（1岛） ====================
local ISLAND_1_PATHS = {
    Vector3.new(537, 19, -1054),
    Vector3.new(567, 19, -1054),
    Vector3.new(541, 19, -1044),
    Vector3.new(567, 19, -1038),
    Vector3.new(538, 19, -1030),
    Vector3.new(563, 19, -1023),
}

local ISLAND_PATHS = {
    [1] = ISLAND_1_PATHS,
    [2] = {},  -- 暂未实现
    [3] = {},  -- 暂未实现
    [4] = {},  -- 暂未实现
}

-- ==================== 获取事件 ====================
local function GetCollectEvent()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if not remotes then return nil end
    return remotes:FindFirstChild("GrassCollect")
end

local function GetUpgradeEvent()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if not remotes then return nil end
    return remotes:FindFirstChild("Upgrade")
end

local function GetRebirthEvent()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if not remotes then return nil end
    return remotes:FindFirstChild("Rebirth")
end

-- ==================== 收集草 ====================
function DoCollect()
    local Event = GetCollectEvent()
    if Event then
        Event:FireServer({
            normal = 1,
            ruby = 0,
            silver = 0,
            golden = 0,
            diamond = 0
        })
        return true
    end
    return false
end

-- ==================== 升级草值 ====================
function DoUpgradeValue()
    local Event = GetUpgradeEvent()
    if Event then
        Event:FireServer({
            {
                currencyName = "Grass",
                autoBuy = false,
                amount = 1,
                max = 99,
                upgradeValue = "GrassValue",
                cost = 853
            }
        })
        return true
    end
    return false
end

-- ==================== 升级草量 ====================
function DoUpgradeAmount()
    local Event = GetUpgradeEvent()
    if Event then
        Event:FireServer({
            {
                currencyName = "Grass",
                autoBuy = false,
                amount = 1,
                max = 49,
                upgradeValue = "GrassAmount",
                cost = 238
            }
        })
        return true
    end
    return false
end

-- ==================== 升级成长率 ====================
function DoUpgradeSpawn()
    local Event = GetUpgradeEvent()
    if Event then
        Event:FireServer({
            {
                currencyName = "Grass",
                autoBuy = false,
                amount = 1,
                max = 7,
                upgradeValue = "SpawnRate1",
                cost = 5
            }
        })
        return true
    end
    return false
end

-- ==================== 重生 ====================
function DoRebirth()
    local Event = GetRebirthEvent()
    if Event then
        Event:FireServer()
        return true
    end
    return false
end

-- ==================== 模拟玩家移动 ====================
local function WalkTo(targetPos)
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return false end
    
    humanoid:MoveTo(targetPos)
    
    local startTime = tick()
    local timeout = 15
    while tick() - startTime < timeout do
        local dist = (hrp.Position - targetPos).Magnitude
        if dist < 2.5 then
            return true
        end
        task.wait(0.05)
    end
    return true
end

-- ==================== 速度循环 ====================
task.spawn(function()
    while true do
        if speedEnabled then
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then
                c.Humanoid.WalkSpeed = speedValue
            end
        end
        task.wait(0.1)
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
                hl.FillColor = Color3.fromRGB(0, 150, 255)
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
                label.TextStrokeTransparency = 0.5
                label.Parent = bb
                table.insert(espHighlights, bb)
            end)
        end
    end
end

task.spawn(function()
    while true do
        if espEnabled then
            updateESP()
        else
            clearESP()
        end
        task.wait(0.5)
    end
end)

-- ==================== 自动割草 ====================
function StartAutoFarm()
    if farmThread then
        task.cancel(farmThread)
        farmThread = nil
    end
    farmThread = task.spawn(function()
        while autoFarm do
            pcall(function()
                local paths = ISLAND_PATHS[autoFarmIsland] or ISLAND_1_PATHS
                if #paths == 0 then
                    print("⚠️ 该岛屿暂无路径")
                    task.wait(1)
                    return
                end
                for _, pos in ipairs(paths) do
                    if not autoFarm then break end
                    WalkTo(pos)
                    task.wait(0.2)
                end
                if autoFarm then
                    pcall(DoCollect)
                end
            end)
            task.wait(0.3)
        end
    end)
end

-- ==================== Wind UI ====================
local MainWindow = WI:CreateWindow({
    Title = "草地增量模拟器",
    Icon = "solar:grass-bold",
    Size = UDim2.fromOffset(480, 540),
    ToggleKey = Enum.KeyCode.RightShift,
    Acrylic = true,
    ScrollBarEnabled = true
})

-- ==================== 公告 ====================
local T1 = MainWindow:Tab({Title = "公告", Icon = "solar:info-bold"})
T1:Paragraph({
    Title = "黑脚本--🌿 草地增量模拟器",
    Desc = "版本 V1.3\n\n功能列表：\n- 循环加草（0.01秒）\n- 自动升级草值/草量/成长率\n- 自动重生\n- 自动割草（1岛）\n- 全自动模式\n- 速度调节\n- 透视所有人"
})
T1:Button({
    Title = "关闭面板",
    Justify = "Center",
    Color = Color3.fromHex("#888888"),
    Callback = function()
        MainWindow:Close()
    end
})

-- ==================== 主要功能 ====================
local T2 = MainWindow:Tab({Title = "主要功能", Icon = "solar:settings-bold"})

T2:Paragraph({
    Title = "🌱 主要功能",
    Desc = "循环加草和自动割草"
})

T2:Divider()

T2:Toggle({
    Title = "🔄 循环加草",
    Value = false,
    Callback = function(v)
        loopCollect = v
        if loopCollect then
            if collectThread then
                task.cancel(collectThread)
                collectThread = nil
            end
            collectThread = task.spawn(function()
                while loopCollect do
                    pcall(DoCollect)
                    task.wait(0.01)
                end
            end)
            print("🔄 循环加草已开启（0.01秒）")
            WI:Notify({
                Title = "✅ 已开启",
                Content = "循环加草已开启（0.01秒）",
                Duration = 2,
                Type = "success"
            })
        else
            if collectThread then
                task.cancel(collectThread)
                collectThread = nil
            end
            print("🔄 循环加草已关闭")
            WI:Notify({
                Title = "⏹️ 已关闭",
                Content = "循环加草已关闭",
                Duration = 2,
                Type = "warning"
            })
        end
    end
})

T2:Divider()

-- ==================== 自动割草 ====================
T2:Paragraph({
    Title = "🌾 自动割草",
    Desc = "自动在岛屿上行走割草"
})

T2:Dropdown({
    Title = "选择岛屿",
    Values = {"1岛", "2岛（暂不可用）", "3岛（暂不可用）", "4岛（暂不可用）"},
    Value = "1岛",
    Callback = function(v)
        if v == "1岛" then
            autoFarmIsland = 1
        elseif v == "2岛（暂不可用）" then
            autoFarmIsland = 2
            WI:Notify({
                Title = "⚠️ 提示",
                Content = "2岛暂未开放",
                Duration = 2,
                Type = "warning"
            })
        elseif v == "3岛（暂不可用）" then
            autoFarmIsland = 3
            WI:Notify({
                Title = "⚠️ 提示",
                Content = "3岛暂未开放",
                Duration = 2,
                Type = "warning"
            })
        elseif v == "4岛（暂不可用）" then
            autoFarmIsland = 4
            WI:Notify({
                Title = "⚠️ 提示",
                Content = "4岛暂未开放",
                Duration = 2,
                Type = "warning"
            })
        end
    end
})

T2:Toggle({
    Title = "🌾 自动割草",
    Value = false,
    Callback = function(v)
        autoFarm = v
        if autoFarm then
            StartAutoFarm()
            print("🌾 自动割草已开启（"..autoFarmIsland.."岛）")
            WI:Notify({
                Title = "✅ 已开启",
                Content = "自动割草已开启（"..autoFarmIsland.."岛）",
                Duration = 2,
                Type = "success"
            })
        else
            if farmThread then
                task.cancel(farmThread)
                farmThread = nil
            end
            print("🌾 自动割草已关闭")
            WI:Notify({
                Title = "⏹️ 已关闭",
                Content = "自动割草已关闭",
                Duration = 2,
                Type = "warning"
            })
        end
    end
})

-- ==================== 自动 ====================
local T3 = MainWindow:Tab({Title = "自动", Icon = "solar:auto-bold"})

T3:Paragraph({
    Title = "🤖 自动升级",
    Desc = "自动升级草值、草量和成长率"
})

T3:Divider()

T3:Toggle({
    Title = "📈 自动升级草值",
    Value = false,
    Callback = function(v)
        autoUpgradeValue = v
        if autoUpgradeValue then
            if upgradeValueThread then
                task.cancel(upgradeValueThread)
                upgradeValueThread = nil
            end
            upgradeValueThread = task.spawn(function()
                while autoUpgradeValue do
                    pcall(DoUpgradeValue)
                    task.wait(1)
                end
            end)
            print("📈 自动升级草值已开启（1秒）")
            WI:Notify({
                Title = "✅ 已开启",
                Content = "自动升级草值已开启（1秒）",
                Duration = 2,
                Type = "success"
            })
        else
            if upgradeValueThread then
                task.cancel(upgradeValueThread)
                upgradeValueThread = nil
            end
            print("📈 自动升级草值已关闭")
            WI:Notify({
                Title = "⏹️ 已关闭",
                Content = "自动升级草值已关闭",
                Duration = 2,
                Type = "warning"
            })
        end
    end
})

T3:Toggle({
    Title = "📊 自动升级草量",
    Value = false,
    Callback = function(v)
        autoUpgradeAmount = v
        if autoUpgradeAmount then
            if upgradeAmountThread then
                task.cancel(upgradeAmountThread)
                upgradeAmountThread = nil
            end
            upgradeAmountThread = task.spawn(function()
                while autoUpgradeAmount do
                    pcall(DoUpgradeAmount)
                    task.wait(1)
                end
            end)
            print("📊 自动升级草量已开启（1秒）")
            WI:Notify({
                Title = "✅ 已开启",
                Content = "自动升级草量已开启（1秒）",
                Duration = 2,
                Type = "success"
            })
        else
            if upgradeAmountThread then
                task.cancel(upgradeAmountThread)
                upgradeAmountThread = nil
            end
            print("📊 自动升级草量已关闭")
            WI:Notify({
                Title = "⏹️ 已关闭",
                Content = "自动升级草量已关闭",
                Duration = 2,
                Type = "warning"
            })
        end
    end
})

T3:Toggle({
    Title = "📈 自动升级成长率",
    Value = false,
    Callback = function(v)
        autoUpgradeSpawn = v
        if autoUpgradeSpawn then
            if upgradeSpawnThread then
                task.cancel(upgradeSpawnThread)
                upgradeSpawnThread = nil
            end
            upgradeSpawnThread = task.spawn(function()
                while autoUpgradeSpawn do
                    pcall(DoUpgradeSpawn)
                    task.wait(1)
                end
            end)
            print("📈 自动升级成长率已开启（1秒）")
            WI:Notify({
                Title = "✅ 已开启",
                Content = "自动升级成长率已开启（1秒）",
                Duration = 2,
                Type = "success"
            })
        else
            if upgradeSpawnThread then
                task.cancel(upgradeSpawnThread)
                upgradeSpawnThread = nil
            end
            print("📈 自动升级成长率已关闭")
            WI:Notify({
                Title = "⏹️ 已关闭",
                Content = "自动升级成长率已关闭",
                Duration = 2,
                Type = "warning"
            })
        end
    end
})

T3:Divider()

T3:Toggle({
    Title = "🔄 自动重生",
    Value = false,
    Callback = function(v)
        autoRebirth = v
        if autoRebirth then
            if rebirthThread then
                task.cancel(rebirthThread)
                rebirthThread = nil
            end
            rebirthThread = task.spawn(function()
                while autoRebirth do
                    pcall(DoRebirth)
                    task.wait(5)
                end
            end)
            print("🔄 自动重生已开启（5秒）")
            WI:Notify({
                Title = "✅ 已开启",
                Content = "自动重生已开启（5秒）",
                Duration = 2,
                Type = "success"
            })
        else
            if rebirthThread then
                task.cancel(rebirthThread)
                rebirthThread = nil
            end
            print("🔄 自动重生已关闭")
            WI:Notify({
                Title = "⏹️ 已关闭",
                Content = "自动重生已关闭",
                Duration = 2,
                Type = "warning"
            })
        end
    end
})

T3:Divider()

-- ==================== 全自动模式 ====================
T3:Toggle({
    Title = "⚡ 全自动模式",
    Value = false,
    Callback = function(v)
        fullAuto = v
        if fullAuto then
            loopCollect = true
            autoUpgradeValue = true
            autoUpgradeAmount = true
            autoUpgradeSpawn = true
            autoRebirth = true
            autoFarm = true
            
            if collectThread then task.cancel(collectThread) end
            collectThread = task.spawn(function()
                while loopCollect do pcall(DoCollect) task.wait(0.01) end
            end)
            
            if upgradeValueThread then task.cancel(upgradeValueThread) end
            upgradeValueThread = task.spawn(function()
                while autoUpgradeValue do pcall(DoUpgradeValue) task.wait(1) end
            end)
            
            if upgradeAmountThread then task.cancel(upgradeAmountThread) end
            upgradeAmountThread = task.spawn(function()
                while autoUpgradeAmount do pcall(DoUpgradeAmount) task.wait(1) end
            end)
            
            if upgradeSpawnThread then task.cancel(upgradeSpawnThread) end
            upgradeSpawnThread = task.spawn(function()
                while autoUpgradeSpawn do pcall(DoUpgradeSpawn) task.wait(1) end
            end)
            
            if rebirthThread then task.cancel(rebirthThread) end
            rebirthThread = task.spawn(function()
                while autoRebirth do pcall(DoRebirth) task.wait(5) end
            end)
            
            if farmThread then task.cancel(farmThread) end
            StartAutoFarm()
            
            print("⚡ 全自动模式已开启")
            WI:Notify({
                Title = "✅ 已开启",
                Content = "全自动模式已开启（所有功能已启动）",
                Duration = 3,
                Type = "success"
            })
        else
            loopCollect = false
            autoUpgradeValue = false
            autoUpgradeAmount = false
            autoUpgradeSpawn = false
            autoRebirth = false
            autoFarm = false
            
            if collectThread then task.cancel(collectThread); collectThread = nil end
            if upgradeValueThread then task.cancel(upgradeValueThread); upgradeValueThread = nil end
            if upgradeAmountThread then task.cancel(upgradeAmountThread); upgradeAmountThread = nil end
            if upgradeSpawnThread then task.cancel(upgradeSpawnThread); upgradeSpawnThread = nil end
            if rebirthThread then task.cancel(rebirthThread); rebirthThread = nil end
            if farmThread then task.cancel(farmThread); farmThread = nil end
            
            print("⚡ 全自动模式已关闭")
            WI:Notify({
                Title = "⏹️ 已关闭",
                Content = "全自动模式已关闭",
                Duration = 2,
                Type = "warning"
            })
        end
    end
})

-- ==================== 玩家 ====================
local T4 = MainWindow:Tab({Title = "玩家", Icon = "solar:user-bold"})

T4:Paragraph({
    Title = "👤 玩家设置",
    Desc = "速度调节和透视"
})

T4:Divider()

T4:Toggle({
    Title = "🏃 开启速度调节",
    Value = false,
    Callback = function(v)
        speedEnabled = v
        if not v then
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then
                c.Humanoid.WalkSpeed = 16
            end
        end
    end
})

T4:Input({
    Title = "速度数值",
    Description = "输入1-200",
    Value = "16",
    Callback = function(v)
        local num = tonumber(v)
        if num and num > 0 and num <= 200 then
            speedValue = num
        end
    end
})

T4:Button({
    Title = "⭐ 推荐（25速度）",
    Justify = "Center",
    Color = Color3.fromRGB(255, 200, 50),
    Callback = function()
        speedValue = 25
        if speedEnabled then
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then
                c.Humanoid.WalkSpeed = 25
            end
        end
    end
})

T4:Divider()

T4:Toggle({
    Title = "👁️ 透视所有人",
    Value = false,
    Callback = function(v)
        espEnabled = v
        if not v then
            clearESP()
        end
    end
})

-- ==================== 设置 ====================
local T5 = MainWindow:Tab({Title = "设置", Icon = "solar:settings-bold"})

T5:Paragraph({
    Title = "⚙️ UI设置",
    Desc = "调整界面外观"
})

T5:Divider()

local themeNames = {
    "BlueWhite", "Dark", "Light", "Rose", "Plant",
    "Ocean", "Sunset", "Midnight", "Forest",
    "Lavender", "Coral", "Mint", "Sky",
    "Blood", "Lemon", "Cyber"
}

T5:Dropdown({
    Title = "🎨 UI主题",
    Values = themeNames,
    Value = "Plant",
    Callback = function(v)
        pcall(function()
            WI:SetTheme(v)
        end)
    end
})

T5:Divider()

T5:Slider({
    Title = "窗口透明度",
    Value = 0,
    Min = 0,
    Max = 1,
    Step = 0.05,
    Callback = function(v)
        pcall(function()
            MainWindow:SetBackgroundTransparency(v)
        end)
    end
})

T5:Divider()

T5:Button({
    Title = "🔄 重置UI位置",
    Justify = "Center",
    Color = Color3.fromRGB(76, 175, 80),
    Callback = function()
        pcall(function()
            MainWindow:SetPosition(UDim2.new(0.5, -240, 0.5, -270))
            WI:Notify({
                Title = "✅ 已重置",
                Content = "UI位置已重置",
                Duration = 2,
                Type = "success"
            })
        end)
    end
})

-- ==================== 启动弹窗 ====================
WI:Popup({
    Title = "草地增量模拟器",
    Content = "加载完成\n按 RightShift 开关面板\n\n版本 V1.3\n✅ 自动割草改为模拟玩家移动",
    Buttons = {{
        Title = "确定",
        Variant = "Primary",
        Callback = function() end
    }}
})

print("✅ 草地增量模拟器 V1.3 加载完成")
