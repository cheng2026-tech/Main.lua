-- 踢一个幸运方块 v2.0
-- WindUI蓝白版 | 自动踢+回家 | 自动收集钱

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
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VERSION = "v2.0"

local kickToggle = false
local kickRunning = false
local collectToggle = false
local collectRunning = false

local function walkTo(targetPos)
    local c = LocalPlayer.Character
    if not c or not c:FindFirstChild("HumanoidRootPart") or not c:FindFirstChild("Humanoid") then return end
    local hrp = c.HumanoidRootPart
    local hum = c.Humanoid
    hum.WalkSpeed = 50
    while (targetPos - hrp.Position).Magnitude > 3 do
        if not kickToggle then hum.WalkSpeed = 16; return end
        hum:MoveTo(targetPos)
        task.wait(0.05)
    end
    hum.WalkSpeed = 16
end

local function kickLoop()
    kickRunning = true
    local kickPos = Vector3.new(690, 3, 224)
    local homePos = Vector3.new(716, 3, 230)
    while kickRunning and kickToggle do
        walkTo(kickPos)
        if not kickToggle then break end
        pcall(function()
            ReplicatedStorage.Shared.Packages.Network.rev_KickEvent:FireServer(0.9670752994716167, 1)
        end)
        walkTo(homePos)
        if not kickToggle then break end
        task.wait(0)
    end
    kickRunning = false
end

local function collectLoop()
    collectRunning = true
    while collectRunning and collectToggle do
        for i = 1, 10 do
            if not collectToggle then break end
            pcall(function()
                ReplicatedStorage.Shared.Packages.Network.rev_B_Collect:FireServer(i)
            end)
        end
        task.wait(0)
    end
    collectRunning = false
end

local Window = WindUI:CreateWindow({
    Title = "踢一个幸运方块",
    Icon = "rbxassetid://129260712070622",
    IconThemed = true,
    Size = UDim2.fromOffset(400, 380),
    Theme = "冰白",
    Transparent = true,
})

Window:Tab({Title = "公告", Icon = "info"}):Paragraph({
    Title = "黑脚本--功能说明",
    Desc = "自动踢+走回家\n自动收集钱\n\n版本：" .. VERSION,
})

local Tab1 = Window:Tab({Title = "主要功能", Icon = "play"})
Tab1:Toggle({
    Title = "全自动",
    Value = false,
    Callback = function(v)
        kickToggle = v
        if v and not kickRunning then task.spawn(kickLoop) end
    end
})
Tab1:Paragraph({Title = "说明", Desc = "全自动踢加走回家适合挂机"})

Tab1:Divider()

Tab1:Toggle({
    Title = "自动收集钱",
    Value = false,
    Callback = function(v)
        collectToggle = v
        if v and not collectRunning then task.spawn(collectLoop) end
    end
})
Tab1:Paragraph({Title = "说明", Desc = "循环收集，可能被踢出"})

Window:Tab({Title = "设置", Icon = "settings"}):Button({
    Title = "关闭脚本",
    Callback = function()
        kickToggle = false
        collectToggle = false
        Window:Close()
    end
})

Window:OnClose(function()
    kickToggle = false
    collectToggle = false
end)

WindUI:Notify({Title = "踢一个幸运方块", Content = VERSION .. " 加载完成", Duration = 3})
