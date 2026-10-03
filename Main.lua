local BASE = "https://raw.githubusercontent.com/cheng2026-tech/fictional-funicular/main/"

if not _G.wait  then _G.wait  = task.wait  end
if not _G.spawn then _G.spawn = task.spawn end
if not _G.delay then _G.delay = task.delay end

local HS = game:GetService("HttpService")

local ok, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)
if not ok or not WindUI then return end

local function notify(title, content, dur, icon)
    pcall(function()
        WindUI:Notify({
            Title = title,
            Content = content,
            Duration = dur or 4,
            Icon = icon,
        })
    end)
end

local Window = WindUI:CreateWindow({
    Title = "爱国者 Hub",
    Author = "大肥鱼 | QQ: 3106633104",
    Icon = "rbxassetid://75478609949910",
    Folder = "爱国者Hub",
    Size = UDim2.fromOffset(620, 460),
    Theme = "Crimson",
    HasOutline = true,
})

Window:EditOpenButton({
    Title = "Patriot",
    CornerRadius = UDim.new(4, 16),
    StrokeThickness = 0.75,
    Draggable = true,
})
Window:Tag({ Title = "v1.0", Color = Color3.fromHex("#306aff") })

local Scripts = {
    {
        Name = "菜鸟竞技场",
        Author = "大肥鱼",
        Icon = "swords",
        Url = "https://raw.githubusercontent.com/cheng2026-tech/-Ioo/refs/heads/main/niaoniao.lua",
        Desc = "⚠️ 全自动 PvP 战斗，有封号风险",
        Warning = true,
        WarningText = "此脚本为全自动化 PvP 战斗工具\n\n可能违反游戏规则，使用可能导致账号被封。\n\n你已了解风险并自行承担后果？",
    },
    {
        Name = "地狱塔",
        Author = "大肥鱼",
        Icon = "tower",
        Url = "https://raw.githubusercontent.com/cheng2026-tech/fluffy-octo-tribble/refs/heads/main/obfuscated_1791017105761.lua.txt",
        Desc = "跑酷辅助：F 飞行 / T 传最高点 / R 重置位置",
    },
}

local WARN_PATH = "PatriotHub_WarningConfirmed.json"
local WC = {}
pcall(function()
    if isfile(WARN_PATH) then
        local raw = readfile(WARN_PATH)
        if raw and raw ~= "" then WC = HS:JSONDecode(raw) or {} end
    end
end)

local function isConfirmed(n) return WC[n] == true end
local function markConfirmed(n)
    WC[n] = true
    pcall(function() writefile(WARN_PATH, HS:JSONEncode(WC)) end)
end

local function showDialog(script, cb)
    local parent = gethui and gethui() or game:GetService("CoreGui")

    local ov = Instance.new("Frame")
    ov.Size = UDim2.new(1, 0, 1, 0)
    ov.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    ov.BackgroundTransparency = 0.5
    ov.BorderSizePixel = 0
    ov.ZIndex = 999999
    ov.Parent = parent

    local d = Instance.new("Frame")
    d.Size = UDim2.new(0, 400, 0, 280)
    d.Position = UDim2.new(0.5, -200, 0.5, -140)
    d.BackgroundColor3 = Color3.fromRGB(28, 18, 18)
    d.BorderSizePixel = 0
    d.ZIndex = 1000000
    d.Parent = ov

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 14)
    c.Parent = d

    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(255, 90, 90)
    s.Thickness = 2
    s.Parent = d

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -40, 0, 36)
    t.Position = UDim2.new(0, 20, 0, 16)
    t.BackgroundTransparency = 1
    t.Text = "⚠️ 风险提示"
    t.TextColor3 = Color3.fromRGB(255, 150, 150)
    t.TextSize = 20
    t.Font = Enum.Font.GothamBold
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Parent = d

    local ct = Instance.new("TextLabel")
    ct.Size = UDim2.new(1, -40, 0, 140)
    ct.Position = UDim2.new(0, 20, 0, 58)
    ct.BackgroundTransparency = 1
    ct.Text = script.WarningText or "确认加载？"
    ct.TextColor3 = Color3.fromRGB(235, 235, 245)
    ct.TextSize = 14
    ct.TextWrapped = true
    ct.TextXAlignment = Enum.TextXAlignment.Left
    ct.TextYAlignment = Enum.TextYAlignment.Top
    ct.Parent = d

    local b1 = Instance.new("TextButton")
    b1.Size = UDim2.new(0, 160, 0, 40)
    b1.Position = UDim2.new(0, 20, 1, -58)
    b1.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    b1.BorderSizePixel = 0
    b1.Text = "取消"
    b1.TextColor3 = Color3.fromRGB(240, 240, 255)
    b1.Font = Enum.Font.GothamBold
    b1.Parent = d

    local c1 = Instance.new("UICorner")
    c1.CornerRadius = UDim.new(0, 8)
    c1.Parent = b1

    local b2 = Instance.new("TextButton")
    b2.Size = UDim2.new(0, 180, 0, 40)
    b2.Position = UDim2.new(1, -200, 1, -58)
    b2.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    b2.BorderSizePixel = 0
    b2.Text = "我已了解，确认加载"
    b2.TextColor3 = Color3.fromRGB(255, 255, 255)
    b2.Font = Enum.Font.GothamBold
    b2.Parent = d

    local c2 = Instance.new("UICorner")
    c2.CornerRadius = UDim.new(0, 8)
    c2.Parent = b2

    b1.MouseButton1Click:Connect(function()
        ov:Destroy()
        cb(false)
    end)
    b2.MouseButton1Click:Connect(function()
        ov:Destroy()
        markConfirmed(script.Name)
        cb(true)
    end)
end

local function loadScript(s)
    local function doLoad()
        task.spawn(function()
            pcall(function()
                local src = game:HttpGet(s.Url)
                if src and src ~= "" then
                    local fn = loadstring(src)
                    if fn then fn() end
                end
            end)
        end)
    end

    if s.Warning and not isConfirmed(s.Name) then
        showDialog(s, function(ok)
            if ok then doLoad() end
        end)
        return
    end
    doLoad()
end

local ScriptsTab = Window:Tab({ Title = "脚本列表", Icon = "file-code" })
ScriptsTab:Section({ Title = "官方脚本", TextXAlignment = "Left" })

for _, s in ipairs(Scripts) do
    ScriptsTab:Button({
        Title = s.Name,
        Desc = s.Desc or ("作者: " .. s.Author),
        Icon = s.Icon,
        Callback = function() loadScript(s) end,
    })
end

ScriptsTab:Button({
    Title = "重置风险确认记录",
    Icon = "rotate-ccw",
    Callback = function()
        WC = {}
        pcall(function() writefile(WARN_PATH, "{}") end)
    end,
})

local AboutTab = Window:Tab({ Title = "关于", Icon = "info" })
AboutTab:Paragraph({ Title = "爱国者 Hub", Desc = "版本 1.0 · 永久免费" })
AboutTab:Paragraph({ Title = "作者", Desc = "大肥鱼 | QQ: 3106633104" })

notify("爱国者 Hub 已加载", "版本 1.0", 5, "bell-ring")
