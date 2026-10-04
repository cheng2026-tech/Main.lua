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
    Title = "黑脚本--伐木大亨2",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(520, 380),
    Theme = "冰白",
    Transparent = true,
})

-- ===== 基础变量 =====
local lp = game.Players.LocalPlayer
local Mouse = lp:GetMouse()
local RunService = game:GetService("RunService")

local function tp(pos)
    if typeof(pos) == "CFrame" then
        lp.Character:SetPrimaryPartCFrame(pos)
    elseif typeof(pos) == "Vector3" then
        lp.Character:MoveTo(pos)
    end
end

local function notify(title, text, duration)
    duration = duration or 3
    WindUI:Notify({Title = title, Content = text, Duration = duration})
end

-- 功能状态
local autoCutEnabled = false

-- ===== 树类型 =====
local TreeTypes = {"普通树", "幻影木", "沼泽黄金", "樱花", "蓝木", "冰木", "火山木", "橡木", "黄金木", "雪地松", "椰子树"}
local TreeMap = {
    ["普通树"] = "Generic", ["幻影木"] = "LoneCave", ["沼泽黄金"] = "GoldSwampy",
    ["樱花"] = "Cherry", ["蓝木"] = "CaveCrawler", ["冰木"] = "Frost",
    ["火山木"] = "Volcano", ["橡木"] = "Oak", ["黄金木"] = "SnowGlow",
    ["雪地松"] = "Pine", ["椰子树"] = "Palm"
}
local selectedTree = "Generic"

-- ===== 公告 =====
Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--伐木大亨2",
    Desc = "砍树 | 卖木 | 传送 | 基地 | 购买\n飞行 | 传送玩家 | 实时状态"
})

-- ===== 主要功能 =====
local Tab1 = Window:Tab({Title = "主要功能", Icon = "solar:star-bold"})

Tab1:Section({Title = "砍树"})
Tab1:Dropdown({
    Title = "树类型",
    Values = TreeTypes,
    Value = "普通树",
    Callback = function(v)
        selectedTree = TreeMap[v] or "Generic"
    end
})
Tab1:Button({
    Title = "带树到面前",
    Callback = function()
        local found = false
        for _, region in pairs(workspace:GetChildren()) do
            if region.Name == "TreeRegion" then
                for _, tree in pairs(region:GetChildren()) do
                    if tree:FindFirstChild("TreeClass") and tree.TreeClass.Value == selectedTree then
                        if tree:FindFirstChild("WoodSection") then
                            local pos = lp.Character.HumanoidRootPart.CFrame
                            for i = 1, 30 do
                                game.ReplicatedStorage.Interaction.ClientIsDragging:FireServer(tree)
                                tree:SetPrimaryPartCFrame(pos)
                                task.wait()
                            end
                            found = true
                            notify("黑", "已带树到面前")
                            break
                        end
                    end
                end
            end
            if found then break end
        end
        if not found then notify("黑", "没有找到该类型树木") end
    end
})

Tab1:Button({
    Title = "自动砍树（循环）",
    Callback = function()
        autoCutEnabled = not autoCutEnabled
        if autoCutEnabled then
            notify("黑", "自动砍树已开启")
            task.spawn(function()
                while autoCutEnabled do
                    local found = false
                    for _, region in pairs(workspace:GetChildren()) do
                        if region.Name == "TreeRegion" then
                            for _, tree in pairs(region:GetChildren()) do
                                if tree:FindFirstChild("TreeClass") and tree.TreeClass.Value == selectedTree then
                                    if tree:FindFirstChild("WoodSection") then
                                        local pos = lp.Character.HumanoidRootPart.CFrame
                                        for i = 1, 25 do
                                            game.ReplicatedStorage.Interaction.ClientIsDragging:FireServer(tree)
                                            tree:SetPrimaryPartCFrame(pos)
                                            task.wait()
                                        end
                                        found = true
                                        break
                                    end
                                end
                            end
                        end
                        if found then break end
                    end
                    if not found then task.wait(3) end
                    task.wait(0.5)
                end
                notify("黑", "自动砍树已停止")
            end)
        else
            notify("黑", "自动砍树已停止")
        end
    end
})

Tab1:Section({Title = "木头处理"})
Tab1:Button({
    Title = "卖所有木板",
    Callback = function()
        local count = 0
        for _, plank in pairs(workspace.PlayerModels:GetChildren()) do
            if plank.Name == "Plank" and plank:FindFirstChild("Owner") and plank.Owner.Value == lp then
                if plank:FindFirstChild("WoodSection") then
                    for i = 1, 15 do
                        game.ReplicatedStorage.Interaction.ClientIsDragging:FireServer(plank)
                        plank.WoodSection.CFrame = CFrame.new(315, -0.3, 86)
                        task.wait()
                    end
                    count = count + 1
                end
            end
        end
        notify("黑", "已处理 " .. count .. " 个木板")
    end
})
Tab1:Button({
    Title = "卖所有木头",
    Callback = function()
        local count = 0
        for _, log in pairs(workspace.LogModels:GetChildren()) do
            if log:FindFirstChild("Owner") and log.Owner.Value == lp then
                if log:FindFirstChild("WoodSection") then
                    for i = 1, 15 do
                        game.ReplicatedStorage.Interaction.ClientIsDragging:FireServer(log)
                        log.WoodSection.CFrame = CFrame.new(315, -0.3, 86)
                        task.wait()
                    end
                    count = count + 1
                end
            end
        end
        notify("黑", "已处理 " .. count .. " 个木头")
    end
})

Tab1:Section({Title = "基地"})
Tab1:Button({
    Title = "获取免费土地",
    Callback = function()
        local count = 0
        for _, prop in pairs(workspace.Properties:GetChildren()) do
            if prop:FindFirstChild("Owner") and prop.Owner.Value == nil then
                if prop:FindFirstChild("OriginSquare") then
                    game.ReplicatedStorage.PropertyPurchasing.ClientPurchasedProperty:FireServer(
                        prop, prop.OriginSquare.OriginCFrame.Value.p + Vector3.new(0, 3, 0)
                    )
                    count = count + 1
                    task.wait(0.1)
                end
            end
        end
        notify("黑", "购买了 " .. count .. " 块土地")
    end
})
Tab1:Button({
    Title = "最大化土地",
    Callback = function()
        local base, square
        for _, prop in pairs(workspace.Properties:GetChildren()) do
            if prop:FindFirstChild("Owner") and prop.Owner.Value == lp then
                base = prop
                square = prop.OriginSquare
                break
            end
        end
        if not base then notify("黑", "没有找到你的基地") return end
        local spos = square.Position
        local directions = {
            Vector3.new(40,0,0), Vector3.new(-40,0,0), Vector3.new(0,0,40), Vector3.new(0,0,-40),
            Vector3.new(40,0,40), Vector3.new(40,0,-40), Vector3.new(-40,0,40), Vector3.new(-40,0,-40),
            Vector3.new(80,0,0), Vector3.new(-80,0,0), Vector3.new(0,0,80), Vector3.new(0,0,-80),
            Vector3.new(80,0,80), Vector3.new(80,0,-80), Vector3.new(-80,0,80), Vector3.new(-80,0,-80)
        }
        for _, dir in pairs(directions) do
            game.ReplicatedStorage.PropertyPurchasing.ClientExpandedProperty:FireServer(base, CFrame.new(spos + dir))
            task.wait(0.05)
        end
        notify("黑", "土地已最大化")
    end
})

Tab1:Section({Title = "购买"})
local ShopItems = {"银斧头", "钢斧", "硬化斧", "锯木机", "小汽车", "大卡车", "炸药"}
local ShopMap = {
    ["银斧头"] = "SilverAxe", ["钢斧"] = "Axe2", ["硬化斧"] = "Axe3",
    ["锯木机"] = "Sawmill2", ["小汽车"] = "UtilityTruck", ["大卡车"] = "Pickup1",
    ["炸药"] = "Dynamite"
}
Tab1:Dropdown({
    Title = "选择购买物品",
    Values = ShopItems,
    Value = "银斧头",
    Callback = function(v) bai_buyItem = ShopMap[v] end
})
Tab1:Button({
    Title = "购买",
    Callback = function()
        if not bai_buyItem then notify("黑", "请先选择物品") return end
        local itemName = bai_buyItem
        local found = false
        for _, store in pairs(workspace.Stores:GetChildren()) do
            if store.Name == "ShopItems" then
                for _, item in pairs(store:GetChildren()) do
                    if item:FindFirstChild("BoxItemName") and item.BoxItemName.Value == itemName then
                        local cashier = workspace.Stores.WoodRUs.Thom
                        if cashier then
                            tp(cashier.HumanoidRootPart.CFrame + Vector3.new(0, 0, 3))
                            task.wait(0.5)
                            game.ReplicatedStorage.NPCDialog.PlayerChatted:InvokeServer(
                                {Character = cashier, Name = "Thom", ID = 7}, "ConfirmPurchase"
                            )
                            found = true
                            notify("黑", "正在购买 " .. itemName)
                        end
                        break
                    end
                end
            end
            if found then break end
        end
        if not found then notify("黑", "未找到该物品") end
    end
})

-- ===== 传送 =====
local Tab2 = Window:Tab({Title = "传送", Icon = "solar:map-bold"})

Tab2:Section({Title = "传送地点"})
local Locations = {
    "出生点", "木材反斗城", "土地商店", "桥", "码头", "椰子岛",
    "洞穴", "火山", "沼泽", "家具店", "盒子车行", "雪山", "回家"
}
local LocationMap = {
    ["出生点"] = CFrame.new(174, 10.5, 66),
    ["木材反斗城"] = CFrame.new(270, 4, 60),
    ["土地商店"] = CFrame.new(270, 3, -98),
    ["桥"] = CFrame.new(112, 37, -892),
    ["码头"] = CFrame.new(1136, 0, -206),
    ["椰子岛"] = CFrame.new(2614, -4, -34),
    ["洞穴"] = CFrame.new(3590, -177, 415),
    ["火山"] = CFrame.new(-1588, 623, 1069),
    ["沼泽"] = CFrame.new(-1216, 131, -822),
    ["家具店"] = CFrame.new(486, 3, -1722),
    ["盒子车行"] = CFrame.new(509, 3, -1458),
    ["雪山"] = CFrame.new(1487, 415, 3259),
}
Tab2:Dropdown({
    Title = "选择地点",
    Values = Locations,
    Value = "出生点",
    Callback = function(v)
        local cframe = LocationMap[v]
        if v == "回家" then
            for _, prop in pairs(workspace.Properties:GetChildren()) do
                if prop:FindFirstChild("Owner") and prop.Owner.Value == lp then
                    if prop:FindFirstChild("OriginSquare") then
                        tp(prop.OriginSquare.CFrame + Vector3.new(0, 10, 0))
                        notify("黑", "已回家")
                        return
                    end
                end
            end
            notify("黑", "没有找到基地")
        elseif cframe then
            tp(cframe)
            notify("黑", "已传送到 " .. v)
        end
    end
})

Tab2:Section({Title = "传送玩家"})
local playerNames = {}
for _, p in ipairs(game.Players:GetPlayers()) do
    if p ~= lp then table.insert(playerNames, p.Name) end
end
if #playerNames == 0 then table.insert(playerNames, "无玩家") end
local selectedPlayer = ""
Tab2:Dropdown({
    Title = "选择玩家",
    Values = playerNames,
    Value = "",
    Multi = false,
    AllowNone = true,
    Callback = function(v)
        if type(v) == "string" and v ~= "" then
            selectedPlayer = v
        else
            selectedPlayer = ""
        end
    end
})
Tab2:Button({
    Title = "传送到该玩家",
    Callback = function()
        if selectedPlayer == "" or selectedPlayer == "无玩家" then
            notify("黑", "请先选择玩家")
            return
        end
        local target = game.Players:FindFirstChild(selectedPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            tp(target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 0))
            notify("黑", "已传送到 " .. selectedPlayer)
        else
            notify("黑", "玩家不存在")
        end
    end
})

-- ===== 工具 =====
local Tab3 = Window:Tab({Title = "工具", Icon = "solar:wrench-bold"})
Tab3:Section({Title = "飞行"})
Tab3:Button({
    Title = "加载飞行脚本",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/飞饼"))() end)
        notify("黑", "飞行脚本已加载")
    end
})
Tab3:Section({Title = "其他"})
Tab3:Button({
    Title = "远程拾取斧头",
    Callback = function()
        notify("黑", "点击地上的斧头拾取", 2)
        local conn
        conn = Mouse.Button1Down:Connect(function()
            local target = Mouse.Target
            if target and target.Parent and target.Parent:FindFirstChild("ToolName") then
                if target.Parent:FindFirstChild("Owner") and target.Parent.Owner.Value == lp then
                    game.ReplicatedStorage.Interaction.ClientInteracted:FireServer(target.Parent, "Pick up tool")
                    notify("黑", "已拾取")
                    conn:Disconnect()
                end
            end
        end)
    end
})
Tab3:Button({
    Title = "重进服务器",
    Callback = function()
        game:GetService("TeleportService"):Teleport(13822889)
    end
})

-- ===== 设置 =====
local Tab4 = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})
local statusParagraph = Tab4:Paragraph({Title = "功能状态", Desc = "加载中..."})

spawn(function()
    while true do
        pcall(function()
            local fps = math.floor(1 / (RunService.RenderStepped:Wait() or 0.016))
            local status = "FPS: " .. fps .. "\n\n" ..
                "自动砍树: " .. (autoCutEnabled and "✅" or "❌") .. "\n" ..
                "当前树类型: " .. selectedTree .. "\n" ..
                "面板: 冰白主题"
            statusParagraph:SetDesc(status)
        end)
        task.wait(0.5)
    end
end)

Tab4:Button({
    Title = "关闭面板",
    Callback = function() Window:Close() end
})

-- ===== 启动 =====
WindUI:Notify({Title = "🌙 黑 - 伐木大亨2", Content = "整合版加载完成", Duration = 3})
