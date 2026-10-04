-- 钓鱼吧 脚本 v2.2
-- 修复按钮 | 修复售卖次数 | 瞬移 | ESP
local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Settings = {
    AutoFish = false,
    ESP_Enabled = false,
    ESP_ShowName = false,
    ESP_ShowTracer = false,
    WalkSpeed = 16,
    SellCount = 5,
}

local fishPos = nil
local fishCount = 0
local VERSION = "v2.2"
local drawings = {}
local stopAll = false

-- 获取位置
local function getPos()
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("HumanoidRootPart") then
        return c.HumanoidRootPart.Position
    end
end

-- 瞬移
local function tp(pos)
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("HumanoidRootPart") then
        c.HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end

-- 点击
local function click()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, nil, 0)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, nil, 0)
end

-- 速度
local function setSpeed(s)
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("Humanoid") then
        c.Humanoid.WalkSpeed = s
    end
end

-- 主循环
task.spawn(function()
    while true do
        if Settings.AutoFish and not stopAll and fishPos then
            local c = LocalPlayer.Character
            if not c or not c:FindFirstChild("HumanoidRootPart") then
                task.wait(1)
                continue
            end
            local root = c.HumanoidRootPart
            
            -- 瞬移到钓鱼点
            tp(fishPos)
            task.wait(0.3)
            
            -- 抛竿
            pcall(function()
                ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/ac1676c3fd743ee17cbe53d738373697d0a8fdcc1aa013d9c215e057cbec2d4e"]:FireServer(1)
            end)
            
            task.wait(0.5)
            click()
            task.wait(5)
            
            if not Settings.AutoFish or stopAll then continue end
            
            click()
            task.wait(0.3)
            
            -- 收竿
            local t = tick()
            while tick() - t < 5 do
                if not Settings.AutoFish or stopAll then break end
                click()
                task.wait(0.06)
            end
            
            if not Settings.AutoFish or stopAll then continue end
            
            fishCount = fishCount + 1
            
            -- 检查是否该售卖
            if fishCount >= Settings.SellCount then
                task.wait(0.3)
                pcall(function()
                    ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/2c53b7807db17f9e08707561c51286321b16235d650d396a8701c9d406b7464f"]:InvokeServer()
                end)
                fishCount = 0
            end
            
            task.wait(0.5)
        else
            task.wait(1)
        end
    end
end)

-- ESP
RunService.RenderStepped:Connect(function()
    for _, d in pairs(drawings) do
        pcall(function() d:Remove() end)
    end
    table.clear(drawings)
    
    if not Settings.ESP_Enabled then return end
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        
        local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then continue end
        
        if Settings.ESP_ShowName then
            local d = Drawing.new("Text")
            d.Text = plr.Name
            d.Size = 14
            d.Position = Vector2.new(pos.X, pos.Y - 40)
            d.Color = Color3.fromRGB(255, 255, 255)
            d.Center = true
            d.Outline = true
            d.OutlineColor = Color3.new(0, 0, 0)
            d.Visible = true
            table.insert(drawings, d)
        end
        
        if Settings.ESP_ShowTracer then
            local d = Drawing.new("Line")
            d.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            d.To = Vector2.new(pos.X, pos.Y)
            d.Color = Color3.fromRGB(255, 80, 80)
            d.Thickness = 1.5
            d.Transparency = 0.4
            d.Visible = true
            table.insert(drawings, d)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if Settings.WalkSpeed ~= 16 then
        setSpeed(Settings.WalkSpeed)
    end
end)

-- UI
local Win = WI:CreateWindow({
    Title = "钓鱼吧",
    Icon = "solar:fishing-bold",
    Size = UDim2.fromOffset(400, 430),
    Acrylic = true,
    ScrollBarEnabled = true,
})

Win:Tab({Title = "公告", Icon = "solar:home-bold"}):Paragraph({
    Title = "黑脚本--说明",
    Desc = "定位钓鱼点->开启自动\n瞬移到点->抛竿->收竿\n钓满N条原地售卖\n脚本未绕过😭😭😭\n版本：" .. VERSION
})

local tP = Win:Tab({Title = "定位", Icon = "solar:map-point-bold"})
tP:Button({
    Title = "定位钓鱼点",
    Justify = "Center",
    Color = Color3.fromHex("#4CAF50"),
    Callback = function()
        local p = getPos()
        if p then
            fishPos = p
            WI:Notify({Title = "成功", Content = "钓鱼点已定位", Duration = 2})
        else
            WI:Notify({Title = "失败", Content = "无法获取位置", Duration = 2})
        end
    end
})

local tA = Win:Tab({Title = "自动", Icon = "solar:play-bold"})
tA:Toggle({
    Title = "自动钓鱼+售卖",
    Value = false,
    Callback = function(v)
        Settings.AutoFish = v
        if v then
            if not fishPos then
                WI:Notify({Title = "错误", Content = "请先定位钓鱼点！", Duration = 3})
                Settings.AutoFish = false
                return
            end
            stopAll = false
            fishCount = 0
        else
            stopAll = true
            setSpeed(16)
        end
    end
})
tA:Divider()
tA:Input({
    Title = "钓几条后售卖",
    Value = "5",
    Callback = function(v)
        local n = tonumber(v)
        if n and n >= 1 then
            Settings.SellCount = n
        end
    end
})

local tPl = Win:Tab({Title = "玩家", Icon = "solar:user-bold"})
tPl:Toggle({
    Title = "开启透视",
    Value = false,
    Callback = function(v) Settings.ESP_Enabled = v end
})
tPl:Divider()
tPl:Toggle({
    Title = "显示名字",
    Value = false,
    Callback = function(v) Settings.ESP_ShowName = v end
})
tPl:Divider()
tPl:Toggle({
    Title = "追踪线",
    Value = false,
    Callback = function(v) Settings.ESP_ShowTracer = v end
})
tPl:Divider()
tPl:Input({
    Title = "移动速度",
    Value = "16",
    Callback = function(v)
        local n = tonumber(v)
        if n and n >= 10 and n <= 30 then
            Settings.WalkSpeed = n
        end
    end
})
tPl:Divider()
tPl:Button({
    Title = "重置速度",
    Justify = "Center",
    Color = Color3.fromHex("#888888"),
    Callback = function() Settings.WalkSpeed = 16 end
})

Win:Tab({Title = "设置", Icon = "solar:settings-bold"}):Button({
    Title = "关闭脚本",
    Justify = "Center",
    Color = Color3.fromHex("#ff4444"),
    Callback = function()
        stopAll = true
        Settings.AutoFish = false
        setSpeed(16)
        Win:Close()
    end
})

WI:Notify({Title = "钓鱼吧", Content = VERSION .. " 加载完成", Duration = 5})
print("钓鱼吧 " .. VERSION .. " 已加载")
