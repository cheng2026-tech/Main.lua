-- 汉堡包 v2.28
-- WindUI蓝白版 | 杀戮光环 | 自动粉碎 | 自动收钱 | NPC透视

local P = game:GetService("Players")
local WS = game:GetService("Workspace")
local RS = game:GetService("ReplicatedStorage")
local C = game:GetService("CoreGui")
local LP = P.LocalPlayer
if not LP then return end

local MeleeEvent
pcall(function()
    -- 尝试多个可能路径
    MeleeEvent = RS.Network.MeleeHitEvent
    if not MeleeEvent then
        MeleeEvent = RS:FindFirstChild("Network") and RS.Network:FindFirstChild("MeleeHitEvent")
    end
    if not MeleeEvent then
        for _, v in pairs(RS:GetDescendants()) do
            if v.Name == "MeleeHitEvent" or v.Name == "MeleeHit" then
                MeleeEvent = v
                break
            end
        end
    end
end)

for _, g in ipairs(C:GetChildren()) do
    if g:IsA("ScreenGui") then
        local n = g.Name
        if n == "A" or n:find("Burger") or n == "WindUI" then
            pcall(function() g:Destroy() end)
        end
    end
end

local WI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WI then return end

WI:AddTheme({
    Name = "冰白",
    Accent = "#80C0FF",
    Outline = "#6090C0",
    Text = "#FFFFFF",
    Placeholder = "#D0E0FF",
})

local S = {
    KillNPC = false,
    GrindBodies = false,
    CollectMoney = false,
    EspEnabled = false,
    KillRange = 50,
    MaxTargets = 5,
}
local killTargets = {}
local EO = {}

local function mKW(n, l)
    if not n then return false end
    local ln = n:lower()
    for _, k in ipairs(l) do
        if ln:find(k, 1, true) then return true end
    end
    return false
end

local function gT(kw)
    local c = LP.Character
    if c then
        for _, t in ipairs(c:GetChildren()) do
            if t:IsA("Tool") and mKW(t.Name, kw) then return t end
        end
    end
    local bp = LP:FindFirstChild("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and mKW(t.Name, kw) then return t end
        end
    end
    return nil
end

local function eq(t)
    if not t then return false end
    local c = LP.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    if not h then return false end
    if t.Parent ~= c then
        h:EquipTool(t)
        wait(0.15)
    end
    return true
end

local function isMe(m)
    for _, p in ipairs(P:GetPlayers()) do
        if p.Character == m then return true end
    end
    return false
end

local function fHP(model)
    if not model or not model:IsA("Model") then return nil end
    for _, n in ipairs({"Head","UpperTorso","Torso","LowerTorso"}) do
        local p = model:FindFirstChild(n, true)
        if p and p:IsA("BasePart") then return p end
    end
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then return d end
    end
    return nil
end

local NF = Vector3.new(0, 0, 1)

local function getNPCs(range)
    local npcs = {}
    local c = LP.Character
    if not c then return npcs end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if not hrp then return npcs end
    local pos = hrp.Position
    local seen = {}
    local rr = range + 5

    for _, obj in pairs(WS:GetDescendants()) do
        if obj:IsA("Model") and not seen[obj] and not isMe(obj) then
            local h = obj:FindFirstChildOfClass("Humanoid")
            local mp = obj:FindFirstChild("HumanoidRootPart")
            if h and mp and h.Health > 0 then
                local d = (mp.Position - pos).Magnitude
                if d <= rr then
                    seen[obj] = true
                    local name = obj.Name:lower()
                    if name:find("npc") or name:find("customer") or name:find("enemy") or name:find("zombie") then
                        table.insert(npcs, {M=obj, H=h, P=mp, D=d})
                    end
                end
            end
        end
    end
    table.sort(npcs, function(a, b) return a.D < b.D end)
    return npcs
end

local function doKill()
    if not MeleeEvent then 
        print("杀戮光环: MeleeEvent未找到")
        return 
    end
    local c = LP.Character
    if not c then killTargets = {}; return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if not hrp then killTargets = {}; return end
    local pos = hrp.Position
    local maxT = S.MaxTargets or 5

    local alive = {}
    for _, t in ipairs(killTargets) do
        if t.P and t.P.Parent == t.M then
            local hNow = t.M:FindFirstChildOfClass("Humanoid")
            if hNow and hNow.Health > 0 then
                table.insert(alive, t)
            end
        end
    end
    killTargets = alive

    if #killTargets < maxT then
        local existing = {}
        for _, t in ipairs(killTargets) do existing[t.M] = true end
        local npcs = getNPCs(S.KillRange)
        for _, npc in ipairs(npcs) do
            if #killTargets >= maxT then break end
            if not existing[npc.M] then
                table.insert(killTargets, npc)
                existing[npc.M] = true
            end
        end
    end

    if #killTargets == 0 then return end

    local tool = gT({"spatula","shovel","knife","sword","bat","hammer","axe","weapon","cleaver"})
    if not tool then killTargets = {}; return end
    eq(tool)

    for _, t in ipairs(killTargets) do
        local hNow = t.M:FindFirstChildOfClass("Humanoid")
        if hNow and hNow.Health > 0 then
            local hp = fHP(t.M)
            if not hp then hp = t.P end
            if hp then
                pcall(function()
                    MeleeEvent:FireServer(hp, hp.Position, NF, 26)
                end)
                wait(0.05)
                pcall(function()
                    MeleeEvent:FireServer(hp, hp.Position, NF, 26)
                end)
                wait(0.05)
            end
        end
    end

    local newList = {}
    for _, t in ipairs(killTargets) do
        local hNow = t.M:FindFirstChildOfClass("Humanoid")
        if hNow and hNow.Health > 0 then
            table.insert(newList, t)
        end
    end
    killTargets = newList
end

local function doESP()
    if not S.EspEnabled then
        for t, _ in pairs(EO) do
            pcall(function() EO[t].B:Destroy() end)
            pcall(function() EO[t].H:Destroy() end)
            EO[t] = nil
        end
        return
    end

    local c = LP.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    local pos = hrp and hrp.Position

    for _, obj in pairs(WS:GetDescendants()) do
        if obj:IsA("Humanoid") and obj.Parent and obj.Parent:IsA("Model") then
            local m = obj.Parent
            if not isMe(m) then
                local mp = m:FindFirstChild("HumanoidRootPart")
                local d = pos and mp and (mp.Position - pos).Magnitude or 999

                if d > 200 or obj.Health <= 0 then
                    if EO[m] then
                        pcall(function() EO[m].B:Destroy() end)
                        pcall(function() EO[m].H:Destroy() end)
                        EO[m] = nil
                    end
                elseif d <= 200 and obj.Health > 0 and not EO[m] then
                    local bb = Instance.new("BillboardGui")
                    bb.Size = UDim2.new(0, 200, 0, 50)
                    bb.MaxDistance = 200
                    bb.AlwaysOnTop = true
                    bb.StudsOffset = Vector3.new(0, 4, 0)
                    bb.Parent = m

                    local tl = Instance.new("TextLabel")
                    tl.Size = UDim2.new(1, 0, 1, 0)
                    tl.Text = "NPC"
                    tl.TextColor3 = Color3.fromRGB(255, 40, 40)
                    tl.BackgroundTransparency = 0.7
                    tl.BackgroundColor3 = Color3.new(0, 0, 0)
                    tl.TextScaled = true
                    tl.Font = Enum.Font.SourceSansBold
                    tl.Parent = bb

                    local hl = Instance.new("Highlight")
                    hl.FillColor = Color3.fromRGB(255, 40, 40)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.3
                    hl.OutlineTransparency = 0
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = m

                    EO[m] = {B = bb, H = hl}
                end
            end
        end
    end
end

local WN = WI:CreateWindow({
    Title = "汉堡包",
    Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(500, 350),
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "冰白",
    Transparent = true,
    ScrollBarEnabled = true,
    HideSearchBar = true,
    OnClose = function()
        S.KillNPC = false
        S.GrindBodies = false
        S.CollectMoney = false
        S.EspEnabled = false
        killTargets = {}
        for t, _ in pairs(EO) do
            pcall(function() EO[t].B:Destroy() end)
            pcall(function() EO[t].H:Destroy() end)
            EO[t] = nil
        end
    end
})

local t1 = WN:Tab({Title = "公告", Icon = "solar:bell-bold"})
t1:Paragraph({
    Title = "黑脚本--汉堡包",
    Desc = "版本: v1.00 秋辞死妈\n\n功能列表:\n1. 杀戮光环 - 自动攻击范围内NPC\n2. 自动粉碎 - 捡尸体装袋丢进Grinder\n3. 自动收钱 - 自动拾取地上金钱\n4. NPC透视 - 高亮显示NPC位置\n\n按 RightShift 打开/关闭面板"
})

local t2 = WN:Tab({Title = "主要功能", Icon = "solar:star-bold"})
t2:Toggle({Title = "杀戮光环", Value = false, Callback = function(v) S.KillNPC = v if not v then killTargets = {} end end})
t2:Toggle({Title = "自动粉碎", Value = false, Callback = function(v) S.GrindBodies = v end})
t2:Toggle({Title = "自动收钱", Value = false, Callback = function(v) S.CollectMoney = v end})
t2:Divider()
t2:Toggle({Title = "NPC透视", Value = false, Callback = function(v) S.EspEnabled = v if not v then for t, _ in pairs(EO) do pcall(function() EO[t].B:Destroy() end) pcall(function() EO[t].H:Destroy() end) EO[t] = nil end end end})
t2:Divider()
t2:Slider({Title = "攻击范围", Step = 5, Value = {Min = 5, Max = 200, Default = 50}, Callback = function(v) S.KillRange = v end})
t2:Slider({Title = "最大目标数", Step = 1, Value = {Min = 1, Max = 10, Default = 5}, Callback = function(v) S.MaxTargets = v end})

local t3 = WN:Tab({Title = "设置", Icon = "solar:settings-bold"})
local statusPara = t3:Paragraph({Title = "功能状态", Desc = "加载中..."})

task.spawn(function()
    while true do
        local status = ""
        status = status .. "杀戮光环: " .. (S.KillNPC and "✅" or "❌") .. "\n"
        status = status .. "自动粉碎: " .. (S.GrindBodies and "✅" or "❌") .. "\n"
        status = status .. "自动收钱: " .. (S.CollectMoney and "✅" or "❌") .. "\n"
        status = status .. "NPC透视: " .. (S.EspEnabled and "✅" or "❌") .. "\n"
        status = status .. "攻击范围: " .. S.KillRange .. "\n"
        status = status .. "目标数: " .. S.MaxTargets .. "\n"
        status = status .. "MeleeEvent: " .. (MeleeEvent and "✅" or "❌") .. "\n"
        status = status .. "帧率: " .. math.floor(1 / task.wait()) .. " FPS"
        statusPara:SetDesc(status)
        task.wait(1)
    end
end)

print("[汉堡包] 加载完成")
while true do
    pcall(function()
        if S.KillNPC then doKill() end
        doESP()
    end)
    wait(0.2)
end
