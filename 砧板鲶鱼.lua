-- 砧板鲶鱼 脚本 v1.0.9
-- WindUI蓝白版 | 自动钓鱼 | 自动卖鱼

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
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local VERSION = "v1.0.9"
local autoFish = false
local autoSell = false
local sellInterval = 5

local function castRod()
    local Msg = ReplicatedStorage:FindFirstChild("Msg")
    if not Msg then return false end
    local RF = Msg:FindFirstChild("RemoteFunction")
    if not RF then return false end
    local Fn = RF:FindFirstChild("RemoteFunction")
    if not Fn then return false end
    pcall(function()
        Fn:InvokeServer("CastRod", {
            Vector3.new(0.00097740325145423, -2.1752037355327e-05, -0.99999952316284),
            1.4301986820962
        })
    end)
    return true
end

local function fishingCharge()
    local Msg = ReplicatedStorage:FindFirstChild("Msg")
    if not Msg then return false end
    local RE = Msg:FindFirstChild("RemoteEvent")
    if not RE then return false end
    local Ev = RE:FindFirstChild("RemoteEvent")
    if not Ev then return false end
    pcall(function()
        Ev:FireServer("FishingCharge", true)
    end)
    return true
end

local function endFishing()
    local Msg = ReplicatedStorage:FindFirstChild("Msg")
    if not Msg then return false end
    local RF = Msg:FindFirstChild("RemoteFunction")
    if not RF then return false end
    local Fn = RF:FindFirstChild("RemoteFunction")
    if not Fn then return false end
    pcall(function()
        Fn:InvokeServer("EndFishing")
    end)
    return true
end

local function sellAllFish()
    local Msg = ReplicatedStorage:FindFirstChild("Msg")
    if not Msg then
        warn("[卖鱼] 找不到 Msg")
        return false
    end
    local RF = Msg:FindFirstChild("RemoteFunction")
    if not RF then
        warn("[卖鱼] 找不到 RemoteFunction")
        return false
    end
    local TalkFunc = RF:FindFirstChild("TalkFunc")
    if not TalkFunc then
        warn("[卖鱼] 找不到 TalkFunc")
        return false
    end
    
    local shopFolder = nil
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj.Name == "玩家的商店" then
            shopFolder = obj
            break
        end
    end
    if not shopFolder then
        warn("[卖鱼] 找不到 玩家的商店")
        return false
    end
    
    local myPlot = shopFolder:FindFirstChild(tostring(LocalPlayer.UserId))
    if not myPlot then
        warn("[卖鱼] 找不到自己的地皮: " .. tostring(LocalPlayer.UserId))
        return false
    end
    
    local animalPlatform = myPlot:FindFirstChild("AnimalPlatform")
    if not animalPlatform then
        warn("[卖鱼] 找不到 AnimalPlatform")
        return false
    end
    
    local duck = animalPlatform:FindFirstChild("Duck")
    if not duck then
        warn("[卖鱼] 找不到 Duck")
        return false
    end
    
    pcall(function()
        TalkFunc:InvokeServer(
            "卖掉全部刚完鱼的鱼",
            {
                npcId = 1,
                npcModel = duck
            }
        )
    end)
    print("[卖鱼] 已发送卖鱼请求")
    return true
end

task.spawn(function()
    while true do
        if autoFish then
            castRod()
            task.wait(4)
            fishingCharge()
            task.wait(10)
            endFishing()
            task.wait(1)
        else
            task.wait(0.5)
        end
    end
end)

task.spawn(function()
    while true do
        if autoSell then
            sellAllFish()
            task.wait(sellInterval)
        else
            task.wait(0.5)
        end
    end
end)

local Window = WindUI:CreateWindow({
    Title = "砧板鲶鱼",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(600, 350),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true,
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本--砧板鲶鱼 " .. VERSION,
    Desc = "功能：自动钓鱼 | 自动卖鱼"
})

local MainTab = Window:Tab({Title = "主要功能", Icon = "solar:star-bold"})

MainTab:Toggle({
    Title = "自动钓鱼",
    Desc = "抛竿→4秒→蓄力→10秒→收竿",
    Value = false,
    Callback = function(v)
        autoFish = v
    end
})

MainTab:Divider()

MainTab:Toggle({
    Title = "自动卖鱼",
    Value = false,
    Callback = function(v)
        autoSell = v
    end
})

MainTab:Slider({
    Title = "卖鱼间隔（秒）",
    Value = {Min = 1, Max = 30, Default = 5},
    Step = 1,
    Callback = function(v)
        sellInterval = v
    end
})

MainTab:Divider()

MainTab:Button({
    Title = "手动卖一次鱼",
    Callback = function()
        local ok = sellAllFish()
        if ok then
            WindUI:Notify({Title = "卖鱼", Content = "已发送请求", Duration = 2})
        else
            WindUI:Notify({Title = "卖鱼失败", Content = "看控制台F9", Duration = 3})
        end
    end
})

local SettingsTab = Window:Tab({Title = "设置", Icon = "solar:settings-bold"})
local statusPara = SettingsTab:Paragraph({Title = "功能状态", Desc = "加载中..."})

task.spawn(function()
    while true do
        local status = ""
        status = status .. "自动钓鱼: " .. (autoFish and "✅" or "❌") .. "\n"
        status = status .. "自动卖鱼: " .. (autoSell and "✅" or "❌") .. " (" .. sellInterval .. "秒)"
        statusPara:SetDesc(status)
        task.wait(1)
    end
end)

SettingsTab:Button({
    Title = "关闭面板",
    Callback = function() Window:Close() end
})

Window:OnClose(function()
    autoFish = false
    autoSell = false
end)

WindUI:Notify({
    Title = "砧板鲶鱼",
    Content = VERSION .. " 加载完成",
    Duration = 2
})
