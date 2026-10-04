-- 清洗键盘 脚本 v2.9
-- 修复定位按钮
local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Settings = {
    AutoScrub = false, AutoScrubPlace = false, KeyboardCount = 2, WalkSpeed = 16, ESP_Enabled = false,
    AutoLuck = false, AutoSpeed = false, AutoSoap = false, AutoWorker = false, AutoRadius = false,
    LuckDelay = 10, SpeedDelay = 10, SoapDelay = 10, WorkerDelay = 10, RadiusDelay = 10,
}

local savedPositions = { soapPos = nil, waterPos = nil, keyboardPos = nil, homePos = nil }
local VERSION = "v2.9"
local stopAll = false
local highlights = {}
local nameTags = {}

local function getPos()
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("HumanoidRootPart") then
        return c.HumanoidRootPart.Position
    end
    return nil
end

-- 定位函数（单独写，确保能被调用）
local function locateSoap()
    local p = getPos()
    if p then
        savedPositions.soapPos = p
        WI:Notify({Title = "成功", Content = "肥皂位置已定位", Duration = 1})
    end
end

local function locateWater()
    local p = getPos()
    if p then
        savedPositions.waterPos = p
        WI:Notify({Title = "成功", Content = "肥皂水位置已定位", Duration = 1})
    end
end

local function locateKeyboard()
    local p = getPos()
    if p then
        savedPositions.keyboardPos = p
        WI:Notify({Title = "成功", Content = "键盘位置已定位", Duration = 1})
    end
end

local function locateHome()
    local p = getPos()
    if p then
        savedPositions.homePos = p
        WI:Notify({Title = "成功", Content = "家位置已定位", Duration = 1})
    end
end

local function clearAll()
    savedPositions.soapPos = nil
    savedPositions.waterPos = nil
    savedPositions.keyboardPos = nil
    savedPositions.homePos = nil
    WI:Notify({Title = "清除", Content = "所有定位已清除", Duration = 1})
end

local function tp(pos)
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("HumanoidRootPart") then
        c.HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end

local function setSpeed(s)
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("Humanoid") then
        c.Humanoid.WalkSpeed = s
    end
end

local function walkAround()
    local c = LocalPlayer.Character
    if not c then return end
    local hum = c:FindFirstChild("Humanoid")
    local root = c:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end
    hum.WalkSpeed = 20
    local sp = root.Position
    local t = tick()
    while tick() - t < 2 do
        if stopAll then return end
        hum:MoveTo(sp + Vector3.new(math.random(-5,5),0,math.random(-5,5)))
        task.wait(0.3)
        hum:MoveTo(sp + Vector3.new(math.random(-3,3),0,math.random(-3,3)))
        task.wait(0.3)
    end
end

local function pressE()
    VirtualInputManager:SendKeyEvent(true,Enum.KeyCode.E,false,nil)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false,Enum.KeyCode.E,false,nil)
end

local function spamScrub()
    local t = tick()
    while tick()-t<5 do
        if not Settings.AutoScrubPlace or stopAll then break end
        pcall(function() ReplicatedStorage["ffrostflame_bridgenet2@1.0.0"].dataRemoteEvent:FireServer({{Action="Scrub"},"\x06"}) end)
        task.wait(0.1)
    end
end

-- 自动洗键盘
task.spawn(function() while true do if Settings.AutoScrub and not stopAll then pcall(function() ReplicatedStorage["ffrostflame_bridgenet2@1.0.0"].dataRemoteEvent:FireServer({{Action="Scrub"},"\x06"}) end) task.wait(0.1) else task.wait(1) end end end)

-- 自动洗+放+肥皂
task.spawn(function()
    while true do
        if Settings.AutoScrubPlace and not stopAll then
            if not savedPositions.soapPos or not savedPositions.waterPos or not savedPositions.keyboardPos or not savedPositions.homePos then task.wait(1) else
                tp(savedPositions.soapPos) task.wait(5)
                if not Settings.AutoScrubPlace or stopAll then continue end
                tp(savedPositions.waterPos) task.wait(0.5) pressE() task.wait(2.5)
                if not Settings.AutoScrubPlace or stopAll then continue end
                for i=1,Settings.KeyboardCount do
                    if not Settings.AutoScrubPlace or stopAll then break end
                    tp(savedPositions.keyboardPos) task.wait(0.3) walkAround()
                    if not Settings.AutoScrubPlace or stopAll then break end
                    spamScrub()
                    if not Settings.AutoScrubPlace or stopAll then break end
                    tp(savedPositions.homePos) task.wait(0.5)
                end
                if Settings.AutoScrubPlace and not stopAll then task.wait(5) end
            end
        else task.wait(1) end
    end
end)

-- 升级循环
task.spawn(function() while true do if Settings.AutoLuck and not stopAll then pcall(function() ReplicatedStorage["ffrostflame_bridgenet2@1.0.0"].dataRemoteEvent:FireServer({{Action="Buy",Id="Luck"},"\n"}) end) task.wait(Settings.LuckDelay) else task.wait(1) end end end)
task.spawn(function() while true do if Settings.AutoSpeed and not stopAll then pcall(function() ReplicatedStorage["ffrostflame_bridgenet2@1.0.0"].dataRemoteEvent:FireServer({{Action="Buy",Id="Speed"},"\n"}) end) task.wait(Settings.SpeedDelay) else task.wait(1) end end end)
task.spawn(function() while true do if Settings.AutoSoap and not stopAll then pcall(function() ReplicatedStorage["ffrostflame_bridgenet2@1.0.0"].dataRemoteEvent:FireServer({{Action="Buy",Id="Soap"},"\x13"}) end) task.wait(Settings.SoapDelay) else task.wait(1) end end end)
task.spawn(function() while true do if Settings.AutoWorker and not stopAll then pcall(function() ReplicatedStorage["ffrostflame_bridgenet2@1.0.0"].dataRemoteEvent:FireServer({{Action="Buy",Id="Worker"},"\x13"}) end) task.wait(Settings.WorkerDelay) else task.wait(1) end end end)
task.spawn(function() while true do if Settings.AutoRadius and not stopAll then pcall(function() ReplicatedStorage["ffrostflame_bridgenet2@1.0.0"].dataRemoteEvent:FireServer({{Action="Buy",Id="Radius"},"\x13"}) end) task.wait(Settings.RadiusDelay) else task.wait(1) end end end)

-- ESP
local function clearESP()
    for _,h in pairs(highlights) do pcall(function() h:Destroy() end) end
    table.clear(highlights)
    for _,t in pairs(nameTags) do pcall(function() t:Destroy() end) end
    table.clear(nameTags)
end

RunService.Heartbeat:Connect(function()
    if not Settings.ESP_Enabled then clearESP() return end
    for _,plr in pairs(Players:GetPlayers()) do
        if plr==LocalPlayer then
            if highlights[plr] then pcall(function() highlights[plr]:Destroy() end) highlights[plr]=nil end
            if nameTags[plr] then pcall(function() nameTags[plr]:Destroy() end) nameTags[plr]=nil end
        else
            local char=plr.Character
            if char and char:FindFirstChild("Head") then
                if not highlights[plr] then local h=Instance.new("Highlight") h.FillColor=Color3.fromRGB(255,100,100) h.FillTransparency=0.5 h.OutlineColor=Color3.fromRGB(255,50,50) h.OutlineTransparency=0.3 highlights[plr]=h end
                if highlights[plr] and highlights[plr].Parent~=char then highlights[plr].Parent=char end
                if not nameTags[plr] then local bg=Instance.new("BillboardGui") bg.Size=UDim2.new(0,120,0,25) bg.AlwaysOnTop=true bg.MaxDistance=math.huge local l=Instance.new("TextLabel") l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=1 l.Text=plr.Name l.TextColor3=Color3.fromRGB(255,255,255) l.Font=Enum.Font.GothamBold l.TextSize=14 l.TextStrokeTransparency=0.5 l.TextStrokeColor3=Color3.fromRGB(0,0,0) l.Parent=bg nameTags[plr]=bg end
                if nameTags[plr] and nameTags[plr].Parent~=char.Head then nameTags[plr].Parent=char.Head end
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    if highlights[plr] then pcall(function() highlights[plr]:Destroy() end) highlights[plr]=nil end
    if nameTags[plr] then pcall(function() nameTags[plr]:Destroy() end) nameTags[plr]=nil end
end)

RunService.Heartbeat:Connect(function() if Settings.WalkSpeed~=16 then setSpeed(Settings.WalkSpeed) end end)

-- UI
local Win = WI:CreateWindow({
    Title = "清洗键盘",
    Icon = "solar:keyboard-bold",
    Size = UDim2.fromOffset(400, 440),
    Acrylic = true,
})

Win:Tab({Title="公告",Icon="solar:home-bold"}):Paragraph({Title="黑脚本--功能说明",Desc="自动洗键盘 | 自动升级\n透视 | 调速度 | 延迟10秒\n\n版本："..VERSION})

-- 定位（用独立函数名）
local t1=Win:Tab({Title="定位",Icon="solar:map-point-bold"})
t1:Button({Title="定位肥皂位置",Justify="Center",Color=Color3.fromHex("#FF9800"),Callback=locateSoap})
t1:Divider()
t1:Button({Title="定位肥皂水位置",Justify="Center",Color=Color3.fromHex("#03A9F4"),Callback=locateWater})
t1:Divider()
t1:Button({Title="定位键盘位置",Justify="Center",Color=Color3.fromHex("#4CAF50"),Callback=locateKeyboard})
t1:Divider()
t1:Button({Title="定位家位置",Justify="Center",Color=Color3.fromHex("#9C27B0"),Callback=locateHome})
t1:Divider()
t1:Button({Title="清除所有定位",Justify="Center",Color=Color3.fromHex("#ff4444"),Callback=clearAll})

-- 自动
local t2=Win:Tab({Title="自动",Icon="solar:play-bold"})
t2:Toggle({Title="自动洗键盘",Value=false,Callback=function(v) Settings.AutoScrub=v if not v and not Settings.AutoScrubPlace then stopAll=true else stopAll=false end end})
t2:Divider()
t2:Toggle({Title="自动洗+放+肥皂",Value=false,Callback=function(v) Settings.AutoScrubPlace=v if v then if not savedPositions.soapPos or not savedPositions.waterPos or not savedPositions.keyboardPos or not savedPositions.homePos then WI:Notify({Title="错误",Content="请先定位所有4个位置！",Duration=3}) Settings.AutoScrubPlace=false return end stopAll=false elseif not Settings.AutoScrub then stopAll=true end end})
t2:Divider()
t2:Input({Title="洗几个键盘",Value="2",Callback=function(v) local n=tonumber(v) if n and n>=1 then Settings.KeyboardCount=n end end})

-- 升级
local t3=Win:Tab({Title="升级",Icon="solar:arrow-up-bold"})
t3:Toggle({Title="自动升级肥皂运气",Value=false,Callback=function(v) Settings.AutoLuck=v end})
t3:Input({Title="延迟(秒)",Value="10",Callback=function(v) local n=tonumber(v) if n and n>=0.1 then Settings.LuckDelay=n end end})
t3:Divider()
t3:Toggle({Title="自动升级肥皂速度",Value=false,Callback=function(v) Settings.AutoSpeed=v end})
t3:Input({Title="延迟(秒)",Value="10",Callback=function(v) local n=tonumber(v) if n and n>=0.1 then Settings.SpeedDelay=n end end})
t3:Divider()
t3:Toggle({Title="自动升级肥皂最大值",Value=false,Callback=function(v) Settings.AutoSoap=v end})
t3:Input({Title="延迟(秒)",Value="10",Callback=function(v) local n=tonumber(v) if n and n>=0.1 then Settings.SoapDelay=n end end})
t3:Divider()
t3:Toggle({Title="自动升级工人速度",Value=false,Callback=function(v) Settings.AutoWorker=v end})
t3:Input({Title="延迟(秒)",Value="10",Callback=function(v) local n=tonumber(v) if n and n>=0.1 then Settings.WorkerDelay=n end end})
t3:Divider()
t3:Toggle({Title="自动升级按下半径",Value=false,Callback=function(v) Settings.AutoRadius=v end})
t3:Input({Title="延迟(秒)",Value="10",Callback=function(v) local n=tonumber(v) if n and n>=0.1 then Settings.RadiusDelay=n end end})

-- 玩家
local t4=Win:Tab({Title="玩家",Icon="solar:user-bold"})
t4:Toggle({Title="开启透视",Value=false,Callback=function(v) Settings.ESP_Enabled=v if not v then clearESP() end end})
t4:Divider()
t4:Input({Title="移动速度",Value="16",Callback=function(v) local n=tonumber(v) if n and n>=10 and n<=50 then Settings.WalkSpeed=n end end})
t4:Divider()
t4:Button({Title="重置速度",Justify="Center",Color=Color3.fromHex("#888888"),Callback=function() Settings.WalkSpeed=16 end})

-- 设置
Win:Tab({Title="设置",Icon="solar:settings-bold"}):Button({Title="关闭脚本",Justify="Center",Color=Color3.fromHex("#ff4444"),Callback=function() stopAll=true for k,_ in pairs(Settings) do if type(Settings[k])=="boolean" then Settings[k]=false end end Settings.WalkSpeed=16 clearESP() setSpeed(16) pcall(function() local g=game:GetService("CoreGui"):FindFirstChild("WindUI") if g then g:Destroy() end end) end})

WI:Notify({Title="清洗键盘",Content=VERSION.." 加载完成",Duration=5})
print("清洗键盘 "..VERSION.." 已加载")
