loadstring(game:HttpGet("https://raw.githubusercontent.com/hgvuyguyg/new/main/ui"))()
local ui = _G.ui
if type(ui) ~= "table" then warn("UI 加载失败") return end

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local function getParent()
    if gethui then local ok, h = pcall(gethui); if ok and h then return h end end
    return game:GetService("CoreGui")
end

local hudGui = Instance.new("ScreenGui")
hudGui.Name = "DisasterHUD"
hudGui.ResetOnSpawn = false
hudGui.DisplayOrder = 9999
hudGui.Parent = getParent()

local hudFrame = Instance.new("Frame")
hudFrame.Size = UDim2.new(0, 500, 0, 50)
hudFrame.Position = UDim2.new(0.5, -250, 0, 20)
hudFrame.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
hudFrame.BackgroundTransparency = 0.2
hudFrame.BorderSizePixel = 0
hudFrame.Visible = false
hudFrame.Parent = hudGui
Instance.new("UICorner", hudFrame).CornerRadius = UDim.new(0, 10)

local hudLabel = Instance.new("TextLabel")
hudLabel.Size = UDim2.new(1, -20, 1, 0)
hudLabel.Position = UDim2.new(0, 10, 0, 0)
hudLabel.BackgroundTransparency = 1
hudLabel.Text = "当前无灾害"
hudLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
hudLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
hudLabel.TextStrokeTransparency = 0
hudLabel.TextSize = 22
hudLabel.Font = Enum.Font.GothamBold
hudLabel.Parent = hudFrame

local mapFrame = Instance.new("Frame")
mapFrame.Size = UDim2.new(0, 400, 0, 40)
mapFrame.Position = UDim2.new(0.5, -200, 0, 78)
mapFrame.BackgroundColor3 = Color3.fromRGB(40, 80, 160)
mapFrame.BackgroundTransparency = 0.2
mapFrame.BorderSizePixel = 0
mapFrame.Visible = false
mapFrame.Parent = hudGui
Instance.new("UICorner", mapFrame).CornerRadius = UDim.new(0, 10)

local mapLabel = Instance.new("TextLabel")
mapLabel.Size = UDim2.new(1, -20, 1, 0)
mapLabel.Position = UDim2.new(0, 10, 0, 0)
mapLabel.BackgroundTransparency = 1
mapLabel.Text = "地图: ?"
mapLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
mapLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
mapLabel.TextStrokeTransparency = 0
mapLabel.TextSize = 18
mapLabel.Font = Enum.Font.GothamBold
mapLabel.Parent = mapFrame

local DISASTER_CN = {
    Tornado="龙卷风", LightningStorm="雷暴", Earthquake="地震",
    Sandstorm="沙尘暴", AcidRain="酸雨", MeteorShower="流星雨",
    FlashFlood="山洪", Tsunami="海啸", Fire="火灾",
    Rain="下雨", Snow="下雪", Thunderstorm="雷阵雨",
    Volcano="火山", HeavyRain="暴雨", Radiation="辐射",
}
local MAP_CN = {
    LaunchSite="发射场", Island="岛屿", Volcano="火山",
    City="城市", Desert="沙漠", Snowy="雪地",
    Beach="海滩", Forest="森林", Underwater="水下", Space="太空",
}

local function readWeather()
    local states = RS:FindFirstChild("States")
    if not states then return {} end
    local result = {}
    local weather = states:FindFirstChild("Weather")
    if weather then
        local function gb(n)
            local v = weather:FindFirstChild(n)
            if v and v:IsA("BoolValue") then return v.Value end
            return false
        end
        if gb("IsRaining") then table.insert(result, "下雨") end
        if gb("IsSnowing") then table.insert(result, "下雪") end
        if gb("IsSandstorm") then table.insert(result, "沙尘暴") end
        if gb("IsAcidRain") then table.insert(result, "酸雨") end
    end
    local eq = states:FindFirstChild("Earthquake")
    if eq and eq:IsA("BoolValue") and eq.Value then table.insert(result, "地震") end
    local dis = states:FindFirstChild("Disasters")
    if dis then
        for _, c in ipairs(dis:GetChildren()) do
            if c:IsA("BoolValue") and c.Value then
                table.insert(result, DISASTER_CN[c.Name] or c.Name)
            end
        end
    end
    return result
end

local function readMap()
    local states = RS:FindFirstChild("States")
    if not states then return "?" end
    local m = states:FindFirstChild("Map")
    if m and m:IsA("StringValue") then
        return MAP_CN[m.Value] or m.Value
    end
    return "?"
end

local currentFPS = 0
local fpsFrames = 0
local fpsLast = tick()
RunService.RenderStepped:Connect(function()
    fpsFrames = fpsFrames + 1
    if tick() - fpsLast >= 1 then
        currentFPS = fpsFrames
        fpsFrames = 0
        fpsLast = tick()
    end
end)

local WIN_W, WIN_H = 460, 340
local SIDEBAR_W = 100
local CONTENT_W = WIN_W - SIDEBAR_W
local PAD = 16
local CW = CONTENT_W - PAD * 2

-- ★ 前向声明
local mainWin
local confirmPopup = nil

local function showConfirm()
    if confirmPopup then return end
    confirmPopup = ui.createPanel({
        w = 260, h = 170,
        title = "确认关闭",
        center = true,
        minimizable = false,
        showPlayer = false,
        onClose = function()
            if confirmPopup then confirmPopup:destroy() end
            confirmPopup = nil
        end,
    })
    ui.createLabel({
        parent = confirmPopup.body,
        x = 0, y = 14, w = 260, h = 22,
        text = "确定要关闭脚本吗？",
        align = Enum.TextXAlignment.Center,
        textSize = 13,
    })
    ui.createButton({
        parent = confirmPopup.body,
        x = 16, y = 50, w = 228, h = 40,
        layout = "card",
        text = "确认关闭",
        icon = ">",
        onClick = function()
            if confirmPopup then confirmPopup:destroy(); confirmPopup = nil end
            if mainWin then mainWin:destroy() end
            if hudGui then hudGui:Destroy() end
        end,
    })
    ui.createButton({
        parent = confirmPopup.body,
        x = 16, y = 98, w = 228, h = 40,
        layout = "card",
        text = "取消",
        icon = ">",
        onClick = function()
            if confirmPopup then confirmPopup:destroy(); confirmPopup = nil end
        end,
    })
end

mainWin = ui.createPanel({
    w = WIN_W, h = WIN_H,
    title = "灾难之岛",
    tabs = { "主要", "玩家", "设置" },
    sidebarWidth = SIDEBAR_W,
    showPlayer = true,
    center = true,
    onClose = function()
        showConfirm()
    end,
})

-- Tab 1
local T1 = mainWin.tabs[1]
ui.createLabel({parent=T1,x=PAD,y=10,w=CW,h=18,text="灾害与地图",textSize=12})

local hudEnabled=false
local function updateHUD()
    if not hudEnabled then hudFrame.Visible=false; return end
    local list=readWeather()
    if #list==0 then
        hudFrame.Visible=true
        hudFrame.BackgroundColor3=Color3.fromRGB(40,120,60)
        hudLabel.Text="当前无灾害"
    else
        hudFrame.Visible=true
        hudFrame.BackgroundColor3=Color3.fromRGB(180,40,40)
        hudLabel.Text="当前灾害: "..table.concat(list," / ")
    end
end

ui.createToggle({parent=T1,x=PAD,y=34,w=36,h=20,value=false,
    onChange=function(v)
        hudEnabled=v
        if v then
            updateHUD()
            task.spawn(function() while hudEnabled do updateHUD() task.wait(1) end end)
        else hudFrame.Visible=false end
    end})
ui.createLabel({parent=T1,x=PAD+46,y=34,w=200,h=20,text="透视灾害",textSize=11})

local mapEnabled=false
local function updateMapHUD()
    if not mapEnabled then mapFrame.Visible=false; return end
    mapFrame.Visible=true
    mapLabel.Text="地图: "..readMap()
end
ui.createToggle({parent=T1,x=PAD,y=62,w=36,h=20,value=false,
    onChange=function(v)
        mapEnabled=v
        if v then
            updateMapHUD()
            task.spawn(function() while mapEnabled do updateMapHUD() task.wait(2) end end)
        else mapFrame.Visible=false end
    end})
ui.createLabel({parent=T1,x=PAD+46,y=62,w=200,h=20,text="透视地图",textSize=11})

local DODGE_POS=Vector3.new(410.7,145.2,-597.5)
local dodgeEnabled=false
local dodgeOriginPos=nil
ui.createToggle({parent=T1,x=PAD,y=90,w=36,h=20,value=false,
    onChange=function(v)
        dodgeEnabled=v
        if v then
            local char=LP.Character
            if char then
                local hrp=char:FindFirstChild("HumanoidRootPart")
                if hrp then dodgeOriginPos=hrp.Position end
            end
            task.spawn(function()
                while dodgeEnabled do
                    local list=readWeather()
                    if #list>0 then
                        local c=LP.Character
                        if c then
                            local hrp=c:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                hrp.CFrame=CFrame.new(DODGE_POS)
                                hrp.AssemblyLinearVelocity=Vector3.zero
                            end
                        end
                    end
                    task.wait(2)
                end
            end)
        else
            if dodgeOriginPos then
                local char=LP.Character
                if char then
                    local hrp=char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame=CFrame.new(dodgeOriginPos)
                        hrp.AssemblyLinearVelocity=Vector3.zero
                    end
                end
                dodgeOriginPos=nil
            end
        end
    end})
ui.createLabel({parent=T1,x=PAD+46,y=90,w=260,h=20,text="自动躲避",textSize=11})

ui.createLabel({parent=T1,x=PAD,y=122,w=CW,h=18,text="快捷传送",textSize=12})

ui.createButton({parent=T1,x=PAD,y=148,w=CW,h=40,
    layout="card", text="传送灾难点", icon=">",
    onClick=function()
        local char=LP.Character
        if not char then return end
        local hrp=char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        hrp.CFrame=CFrame.new(Vector3.new(97,23,-27))
        hrp.AssemblyLinearVelocity=Vector3.zero
    end})
ui.createButton({parent=T1,x=PAD,y=196,w=CW,h=40,
    layout="card", text="传送出生点", icon=">",
    onClick=function()
        local char=LP.Character
        if not char then return end
        local hrp=char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        hrp.CFrame=CFrame.new(DODGE_POS)
        hrp.AssemblyLinearVelocity=Vector3.zero
    end})

-- Tab 2
local T2 = mainWin.tabs[2]
ui.createLabel({parent=T2,x=PAD,y=10,w=CW,h=18,text="角色设置",textSize=12})

ui.createSlider({
    parent=T2,x=PAD,y=36,w=CW,h=26,
    min=16,max=300,value=16,
    showValue=true,
    onChange=function(v)
        local char=LP.Character
        if char then
            local h=char:FindFirstChildOfClass("Humanoid")
            if h then h.WalkSpeed=v end
        end
    end})
ui.createLabel({parent=T2,x=PAD,y=68,w=200,h=16,text="移动速度",textSize=10,
    color=ui.Theme.TEXT_MUTED})

local playerESPEnabled=false
local playerESP={}
local function createPlayerESP(plr)
    if not plr.Character then return end
    local hrp=plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or playerESP[plr] then return end
    local hl=Instance.new("Highlight")
    hl.Adornee=plr.Character
    hl.FillColor=Color3.fromRGB(0,200,255)
    hl.FillTransparency=0.5
    hl.OutlineColor=Color3.fromRGB(0,255,255)
    hl.OutlineTransparency=0
    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent=getParent()
    local bb=Instance.new("BillboardGui")
    bb.Adornee=hrp
    bb.Size=UDim2.new(0,200,0,40)
    bb.StudsOffset=Vector3.new(0,3,0)
    bb.AlwaysOnTop=true
    bb.MaxDistance=5000
    bb.Parent=getParent()
    local textLbl=Instance.new("TextLabel")
    textLbl.Size=UDim2.new(1,0,1,0)
    textLbl.BackgroundTransparency=1
    textLbl.Text=plr.Name
    textLbl.TextColor3=Color3.fromRGB(0,255,255)
    textLbl.TextStrokeColor3=Color3.fromRGB(0,0,0)
    textLbl.TextStrokeTransparency=0
    textLbl.TextSize=16
    textLbl.Font=Enum.Font.GothamBold
    textLbl.Parent=bb
    playerESP[plr]={hl=hl,bb=bb,textLbl=textLbl}
end
local function clearPlayerESP()
    for _,d in pairs(playerESP) do
        if d.hl then d.hl:Destroy() end
        if d.bb then d.bb:Destroy() end
    end
    playerESP={}
end
local function updatePlayerESP()
    local myHrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end
    local myPos=myHrp.Position
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LP and plr.Character then
            createPlayerESP(plr)
            local d=playerESP[plr]
            if d and d.textLbl then
                local hrp=plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dist=math.floor((hrp.Position-myPos).Magnitude)
                    d.textLbl.Text=string.format("%s\n[%d m]",plr.Name,dist)
                end
            end
        end
    end
    for plr,d in pairs(playerESP) do
        if not plr.Character or not plr.Character.Parent then
            d.hl:Destroy(); d.bb:Destroy()
            playerESP[plr]=nil
        end
    end
end

ui.createToggle({parent=T2,x=PAD,y=96,w=36,h=20,value=false,
    onChange=function(v)
        playerESPEnabled=v
        if v then
            task.spawn(function()
                while playerESPEnabled do pcall(updatePlayerESP); task.wait(1) end
            end)
        else clearPlayerESP() end
    end})
ui.createLabel({parent=T2,x=PAD+46,y=96,w=260,h=20,text="玩家透视",textSize=11})

local vehicleFlyEnabled=false
local vehicleSpeed=200
local vehicleFlyConn=nil
local function getVehicle()
    local char=LP.Character
    if not char then return nil end
    local h=char:FindFirstChildOfClass("Humanoid")
    if not h or not h.SeatPart then return nil end
    local model=h.SeatPart
    for i=1,5 do
        if model.Parent and model.Parent:IsA("Model") then model=model.Parent
        else break end
    end
    return model
end

ui.createSlider({
    parent=T2,x=PAD,y=128,w=CW,h=26,
    min=50,max=1000,value=200,
    showValue=true,
    onChange=function(v) vehicleSpeed=v end})
ui.createLabel({parent=T2,x=PAD,y=160,w=200,h=16,text="载具速度",textSize=10,
    color=ui.Theme.TEXT_MUTED})

ui.createToggle({parent=T2,x=PAD,y=186,w=36,h=20,value=false,
    onChange=function(v)
        vehicleFlyEnabled=v
        if v then
            if vehicleFlyConn then vehicleFlyConn:Disconnect() end
            vehicleFlyConn=RunService.Heartbeat:Connect(function()
                if not vehicleFlyEnabled then return end
                local vehicle=getVehicle()
                if not vehicle then return end
                local cam=workspace.CurrentCamera
                if not cam then return end
                local dir=Vector3.zero
                local cf=cam.CFrame
                if UIS:IsKeyDown(Enum.KeyCode.W) then dir=dir+cf.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then dir=dir-cf.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then dir=dir+cf.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then dir=dir-cf.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then dir=dir+Vector3.new(0,1,0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir=dir-Vector3.new(0,1,0) end
                if dir.Magnitude>0 then
                    for _,p in pairs(vehicle:GetDescendants()) do
                        if p:IsA("BasePart") then
                            pcall(function() p.AssemblyLinearVelocity=dir.Unit*vehicleSpeed end)
                        end
                    end
                else
                    for _,p in pairs(vehicle:GetDescendants()) do
                        if p:IsA("BasePart") then
                            pcall(function() p.AssemblyLinearVelocity=Vector3.zero end)
                        end
                    end
                end
            end)
        else
            if vehicleFlyConn then vehicleFlyConn:Disconnect(); vehicleFlyConn=nil end
        end
    end})
ui.createLabel({parent=T2,x=PAD+46,y=186,w=260,h=20,text="载具飞行",textSize=11})

local suckEnabled=false
local suckRange=200
local suckRadius=8
local suckItems={}
local suckAngle=0
local suckConn=nil
local EXCLUDE={"Map","Island","World","Lobby","Terrain","Camera","Weather","Pets","GameDebris","RoundDebris","Effects"}
local function isExcluded(obj)
    local cur=obj
    for i=1,8 do
        if not cur then break end
        for _,n in ipairs(EXCLUDE) do
            if cur.Name==n then return true end
        end
        cur=cur.Parent
    end
    for _,p in ipairs(Players:GetPlayers()) do
        if p.Character and obj:IsDescendantOf(p.Character) then return true end
    end
    return false
end
local function isSuckable(obj)
    if not obj.Parent then return false end
    if obj:IsA("BasePart") then
        if obj.Anchored then return false end
        if isExcluded(obj) then return false end
        if obj.Size.Magnitude>20 then return false end
        return true
    end
    return false
end
local function suckScan()
    suckItems={}
    local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local myPos=hrp.Position
    for _,obj in ipairs(workspace:GetDescendants()) do
        if isSuckable(obj) then
            if (obj.Position-myPos).Magnitude<=suckRange then
                table.insert(suckItems,obj)
            end
        end
    end
end

ui.createSlider({
    parent=T2,x=PAD,y=218,w=CW,h=26,
    min=50,max=2000,value=200,
    showValue=true,
    onChange=function(v) suckRange=v end})
ui.createLabel({parent=T2,x=PAD,y=250,w=200,h=16,text="吸附范围",textSize=10,
    color=ui.Theme.TEXT_MUTED})

ui.createToggle({parent=T2,x=PAD,y=276,w=36,h=20,value=false,
    onChange=function(v)
        suckEnabled=v
        if v then
            suckScan()
            task.spawn(function()
                while suckEnabled do suckScan(); task.wait(2) end
            end)
            if suckConn then suckConn:Disconnect() end
            suckConn=RunService.Heartbeat:Connect(function(dt)
                if not suckEnabled then return end
                local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                suckAngle=suckAngle+dt*3
                local count=#suckItems
                if count==0 then return end
                for i,item in ipairs(suckItems) do
                    if item.Parent then
                        local a=suckAngle+(i/count)*math.pi*2
                        local targetPos=hrp.Position+Vector3.new(
                            math.cos(a)*suckRadius,
                            math.sin(suckAngle*2+i)*3+5,
                            math.sin(a)*suckRadius
                        )
                        pcall(function()
                            item.CFrame=CFrame.new(targetPos)
                            item.AssemblyLinearVelocity=Vector3.zero
                        end)
                    end
                end
            end)
        else
            if suckConn then suckConn:Disconnect(); suckConn=nil end
            suckItems={}
        end
    end})
ui.createLabel({parent=T2,x=PAD+46,y=276,w=260,h=20,text="物品吸附",textSize=11})

-- Tab 3
local T3 = mainWin.tabs[3]
ui.createLabel({parent=T3,x=PAD,y=10,w=CW,h=18,text="运行状态",textSize=12})

local statusDesc = ui.createDescriptionBox({
    parent=T3, x=PAD, y=34, w=CW,
    title="实时监控",
    text="加载中...",
})
local statusBody=nil
for _,child in ipairs(statusDesc:GetChildren()) do
    if child:IsA("TextLabel") and child.Text~="实时监控" then
        statusBody=child
    end
end

task.spawn(function()
    while mainWin and mainWin.frame and mainWin.frame.Parent do
        local lines={
            "FPS: "..currentFPS,
            "地图: "..readMap(),
            "",
            "透视灾害  "..(hudEnabled and "已开启" or "未开启"),
            "透视地图  "..(mapEnabled and "已开启" or "未开启"),
            "自动躲避  "..(dodgeEnabled and "已开启" or "未开启"),
            "玩家透视  "..(playerESPEnabled and "已开启" or "未开启"),
            "载具飞行  "..(vehicleFlyEnabled and "已开启" or "未开启"),
            "物品吸附  "..(suckEnabled and "已开启" or "未开启"),
        }
        if statusBody then
            pcall(function() statusBody.Text=table.concat(lines,"\n") end)
        end
        task.wait(0.5)
    end
end)

print("[灾难之岛] v3.2 已加载")
