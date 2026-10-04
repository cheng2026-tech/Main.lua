local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
if not WindUI then return end

WindUI:AddTheme({
    Name = "冰白",
    Accent = "#80C0FF",
    Outline = "#6090C0",
    Text = "#FFFFFF",
    Placeholder = "#D0E0FF",
})

local Window = WindUI:CreateWindow({
    Title = "黑脚本--挖掘或逃脱",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(600, 350),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true,
})

local VERSION = "v1.0.0"
local Settings = {
    AutoSuckEnabled = false,
    SuckDelay = 0.5,
    SuckItems = {},
    SuckRadius = 5,
}

local ITEM_TYPES = {
    {DisplayName = "袜子", Keyword = "Sock"},
    {DisplayName = "肥皂", Keyword = "Soap"},
    {DisplayName = "骨头", Keyword = "Bone"},
    {DisplayName = "钱包", Keyword = "Wallet"},
    {DisplayName = "罐子", Keyword = "Can"},
    {DisplayName = "杯子", Keyword = "Cup"},
    {DisplayName = "鸭子", Keyword = "Duck"},
    {DisplayName = "石头", Keyword = "Rock"},
    {DisplayName = "足球", Keyword = "Football"},
    {DisplayName = "钥匙", Keyword = "Key", Exclude = {"KeycardScanner", "Keys"}},
    {DisplayName = "盘子", Keyword = "Plate"},
    {DisplayName = "鱼骨", Keyword = "Fish Bone"},
    {DisplayName = "金条", Keyword = "Gold Bar"},
    {DisplayName = "战利品箱", Keyword = "Loot Chest"},
    {DisplayName = "扳手", Keyword = "Wrench"},
    {DisplayName = "鞋子", Keyword = "Shoe"},
    {DisplayName = "金币", Keyword = "Gold Coin"},
    {DisplayName = "金锁", Keyword = "GoldLock"},
    {DisplayName = "钳子", Keyword = "Pliers"},
}

local itemDisplayNames = {}
for _, item in pairs(ITEM_TYPES) do
    table.insert(itemDisplayNames, item.DisplayName)
end

local AboutTab = Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"})
AboutTab:Paragraph({
    Title = "黑脚本--挖掘或逃脱 " .. VERSION,
    Desc = "功能：吸取物品 | 传送 | 删除预警\n更新日志：初始发布"
})

local MainTab = Window:Tab({Title = "主要功能", Icon = "solar:star-bold"})

MainTab:Dropdown({
    Title = "选择吸取物品",
    Values = itemDisplayNames,
    Value = {},
    Multi = true,
    AllowNone = true,
    Callback = function(v)
        Settings.SuckItems = v
    end
})

MainTab:Toggle({
    Title = "自动吸取",
    Value = false,
    Callback = function(v)
        Settings.AutoSuckEnabled = v
    end
})

MainTab:Slider({
    Title = "吸取延迟 (0.1-3秒)",
    Value = {Min = 0.1, Max = 3, Default = 0.5},
    Step = 0.1,
    Callback = function(v) Settings.SuckDelay = v end
})

MainTab:Slider({
    Title = "环绕范围 (3.5-10)",
    Value = {Min = 3.5, Max = 10, Default = 5},
    Step = 0.5,
    Callback = function(v) Settings.SuckRadius = v end
})

MainTab:Divider()

MainTab:Button({
    Title = "删除警察(纯鸡肋)",
    Callback = function()
        DeleteGuard()
    end
})

local TeleportTab = Window:Tab({Title = "传送", Icon = "solar:map-bold"})

TeleportTab:Paragraph({
    Title = "传送说明",
    Desc = "方便你们好挖好售卖在晚上"
})

TeleportTab:Button({
    Title = "传送回家",
    Callback = function()
        TeleportTo(Vector3.new(-37.4, -8.0, 41.6))
    end
})

TeleportTab:Button({
    Title = "传送道具商人",
    Callback = function()
        TeleportTo(Vector3.new(-47.7, -7.2, -39.7))
    end
})

TeleportTab:Button({
    Title = "传送食物商人",
    Callback = function()
        TeleportTo(Vector3.new(-17.8, -7.2, -35.9))
    end
})

TeleportTab:Button({
    Title = "传送袋子商人",
    Callback = function()
        TeleportTo(Vector3.new(27.2, -7.2, -30.4))
    end
})

TeleportTab:Button({
    Title = "传送售卖哥",
    Callback = function()
        TeleportTo(Vector3.new(94.8, -7.2, -9.3))
    end
})

local SettingsTab = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})
local SettingsPara = SettingsTab:Paragraph({Title = "功能状态", Desc = "加载中..."})

task.spawn(function()
    while true do
        local status = ""
        if Settings.AutoSuckEnabled then
            status = status .. "自动吸取: 已开启\n"
            local items = Settings.SuckItems or {}
            if #items > 0 then
                status = status .. "物品: " .. table.concat(items, ", ") .. "\n"
            else
                status = status .. "物品: 无\n"
            end
            status = status .. "范围: " .. Settings.SuckRadius .. "\n"
        else
            status = status .. "自动吸取: 未开启\n"
        end
        local fps = math.floor(1 / task.wait())
        status = status .. "当前帧率: " .. fps .. " FPS"
        SettingsPara:SetDesc(status)
        task.wait(1)
    end
end)

local function getAllItemsOfType(itemType)
    local items = {}
    local seenObjects = {}
    local keyword = itemType.Keyword:lower()
    local excludes = itemType.Exclude or {}

    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name then
            local name = v.Name:lower()
            if name:find(keyword) then
                local shouldExclude = false
                for _, excludeWord in pairs(excludes) do
                    if name:find(excludeWord:lower()) then
                        shouldExclude = true
                        break
                    end
                end
                
                if not shouldExclude then
                    local rootPart = nil
                    local objSize = nil
                    
                    if v:IsA("BasePart") then
                        rootPart = v
                        objSize = math.max(v.Size.X, v.Size.Y, v.Size.Z)
                    elseif v:IsA("Model") then
                        rootPart = v:FindFirstChild("HumanoidRootPart") or v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
                        local modelSize = v:GetExtentsSize()
                        objSize = math.max(modelSize.X, modelSize.Y, modelSize.Z)
                    end
                    
                    if rootPart and objSize and objSize <= 8 and not seenObjects[v] then
                        seenObjects[v] = true
                        table.insert(items, {Object = v, RootPart = rootPart})
                    end
                end
            end
        end
    end

    return items
end

task.spawn(function()
    while true do
        if Settings.AutoSuckEnabled then
            local player = game.Players.LocalPlayer
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local playerRoot = player.Character.HumanoidRootPart
                local selectedItems = Settings.SuckItems or {}
                local angleStep = 0

                for _, displayName in pairs(selectedItems) do
                    if not Settings.AutoSuckEnabled then break end
                    local itemType = nil
                    for _, it in pairs(ITEM_TYPES) do
                        if it.DisplayName == displayName then
                            itemType = it
                            break
                        end
                    end
                    if itemType then
                        local items = getAllItemsOfType(itemType)
                        for _, item in pairs(items) do
                            if not Settings.AutoSuckEnabled then break end
                            if item.RootPart and item.RootPart.Parent then
                                local angle = math.rad(angleStep)
                                local x = math.cos(angle) * Settings.SuckRadius
                                local z = math.sin(angle) * Settings.SuckRadius
                                local targetPos = playerRoot.Position + Vector3.new(x, 0, z)
                                item.RootPart.CFrame = CFrame.new(targetPos)
                                angleStep = angleStep + 15
                            end
                        end
                    end
                    task.wait(0.05)
                end
            end
        end
        task.wait(Settings.SuckDelay)
    end
end)

function TeleportTo(pos)
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end

function DeleteGuard()
    local count = 0
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "Guard" then
            pcall(function() v:Destroy() end)
            count = count + 1
        end
    end
    if count > 0 then
        WindUI:Notify({Title = "删除成功", Content = "已删除 " .. count .. " 个预警", Duration = 2})
    else
        WindUI:Notify({Title = "未找到", Content = "没有找到预警", Duration = 2})
    end
end

WindUI:Notify({
    Title = "挖掘或逃脱",
    Content = VERSION .. " 加载完成",
    Duration = 3
})
