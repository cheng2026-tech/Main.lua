-- 免费音箱 脚本 v1.0
-- WindUI版 | 输入音频ID播放 | 停止 | 主题切换

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
if not WindUI then return end

local Window = WindUI:CreateWindow({
    Title = "免费音箱",
    Icon = "rbxassetid://129260712070622",
    IconThemed = true,
    Author = "音箱播放器",
    Folder = "黑脚本",
    Size = UDim2.fromOffset(480, 300),
    Theme = "Dark",
})

local currentSound = nil
local currentSoundId = ""

local function playSound(id)
    -- 停止之前的
    if currentSound then
        pcall(function() currentSound:Destroy() end)
        currentSound = nil
    end
    
    if id == "" then return end
    
    -- 处理ID格式
    local soundId = id
    if not soundId:find("rbxassetid://") then
        soundId = "rbxassetid://" .. soundId
    end
    
    -- 创建Sound对象
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = 5
    sound.Parent = workspace
    
    pcall(function()
        sound:Play()
        currentSound = sound
        currentSoundId = id
        WindUI:Notify({Title = "播放中", Content = "正在播放音频", Duration = 3})
    end)
    
    -- 播放完毕自动清理
    sound.Ended:Connect(function()
        if sound == currentSound then
            pcall(function() sound:Destroy() end)
            currentSound = nil
        end
    end)
end

local function stopSound()
    if currentSound then
        pcall(function()
            currentSound:Stop()
            currentSound:Destroy()
        end)
        currentSound = nil
        WindUI:Notify({Title = "已停止", Content = "音频已停止播放", Duration = 2})
    end
end

-- ==================== 公告 ====================
local Tab1 = Window:Tab({Title = "公告", Icon = "info"})
Tab1:Paragraph({
    Title = "使用说明",
    Desc = [[
    1. 输入音频ID（数字即可）
    2. 点击播放按钮
    3. 点击停止按钮结束播放
    
    音频ID来自Roblox音频库
    例如：9123456789
    
    设置页可切换主题和透明度
    ]],
})

-- ==================== 主要 ====================
local Tab2 = Window:Tab({Title = "主要", Icon = "play"})

local audioInput = ""
Tab2:Input({
    Title = "音频ID",
    Value = "",
    Placeholder = "输入音频ID...",
    Callback = function(v)
        audioInput = v
    end,
})

Tab2:Button({
    Title = "播放",
    Callback = function()
        playSound(audioInput)
    end,
})

Tab2:Button({
    Title = "停止",
    Callback = function()
        stopSound()
    end,
})

-- ==================== 设置 ====================
local Tab3 = Window:Tab({Title = "设置", Icon = "settings"})

local themeValues = {}
for name, _ in pairs(WindUI:GetThemes()) do
    table.insert(themeValues, name)
end

Tab3:Dropdown({
    Title = "选择主题",
    Values = themeValues,
    Value = WindUI:GetCurrentTheme(),
    Callback = function(theme)
        WindUI:SetTheme(theme)
    end,
})

Tab3:Toggle({
    Title = "透明窗口",
    Value = WindUI:GetTransparency(),
    Callback = function(state)
        Window:ToggleTransparency(state)
    end,
})

Window:OnClose(function()
    stopSound()
end)
