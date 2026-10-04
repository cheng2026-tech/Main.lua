-- 动态黑脚本库加载器（GitHub Tree API 版）
-- 自动读取仓库中所有 .lua 文件，并生成按钮
-- 仓库：cheng2026-tech/Main.lua
-- 兼容 120+ 个脚本，避免 GitHub Contents API 分页限制

local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

local ok, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not ok or not WindUI then
    StarterGui:SetCore("SendNotification", {
        Title = "加载器",
        Text = "WindUI 加载失败，脚本退出",
        Duration = 5,
    })
    return
end

local function notify(title, text, duration)
    duration = duration or 3
    pcall(function()
        WindUI:Notify({
            Title = title,
            Content = text,
            Duration = duration,
        })
    end)
end

local function urlEncodePath(path)
    if type(path) ~= "string" then
        return path
    end

    local encoded = HttpService:UrlEncode(path)
    encoded = encoded:gsub("%+", "%%20")
    return encoded
end

local function fetchRepoScripts()
    local result = {}

    local okReq, res = pcall(function()
        return game:HttpGet("https://api.github.com/repos/cheng2026-tech/Main.lua/git/trees/main?recursive=1")
    end)

    if not okReq or not res then
        return result
    end

    local okDecode, data = pcall(function()
        return HttpService:JSONDecode(res)
    end)

    if not okDecode or type(data) ~= "table" or type(data.tree) ~= "table" then
        return result
    end

    for _, item in ipairs(data.tree) do
        if item and item.type == "blob" and item.path and item.path:lower():match("%.lua$") then
            local name = item.path:match("[^/]+$") or item.path
            if name ~= "加载器.lua" then
                local rawUrl = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/" .. urlEncodePath(item.path)
                table.insert(result, {
                    Name = name,
                    URL = rawUrl,
                    Path = item.path,
                })
            end
        end
    end

    table.sort(result, function(a, b)
        return a.Name < b.Name
    end)

    return result
end

local scriptList = fetchRepoScripts()

if #scriptList == 0 then
    scriptList = {
        {Name = "Doors.lua", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/Doors.lua"},
        {Name = "blox Fruit.lua", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/blox%20Fruit.lua"},
        {Name = "fisch.lua", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/fisch.lua"},
        {Name = "fps通用.lua", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/fps%E9%80%9A%E7%94%A8.lua"},
        {Name = "为你的城市供电.lua", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/%E4%B8%BA%E4%BD%A0%E7%9A%84%E5%9F%8E%E5%B8%82%E4%BE%9B%E7%94%B5.lua"},
        {Name = "伐木大亨2.lua", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/%E4%BC%90%E6%9C%A8%E5%A4%A7%E4%BA%A82.lua"},
        {Name = "飞行世界.lua", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/%E9%A3%9E%E8%A1%8C%E4%B8%95%E7%95%8C.lua"},
    }
end

local Window = WindUI:CreateWindow({
    Title = "黑脚本库",
    Icon = "solar:folder-bold",
    Size = UDim2.fromOffset(620, 720),
    ToggleKey = Enum.KeyCode.RightShift,
    Acrylic = true,
    ScrollBarEnabled = true,
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "动态总加载器",
    Desc = "仓库：cheng2026-tech/Main.lua\n自动扫描仓库全部 .lua 文件\n共 " .. #scriptList .. " 个脚本\n按 RightShift 开关面板",
})

local scriptTab = Window:Tab({Title = "脚本列表", Icon = "solar:folder-bold"})

local function addButton(targetTab, script)
    targetTab:Button({
        Title = script.Name,
        Justify = "Center",
        Color = Color3.fromRGB(104, 147, 255),
        Callback = function()
            notify("加载中", "正在加载：" .. script.Name, 2)
            local okLoad, result = pcall(function()
                local fn = loadstring(game:HttpGet(script.URL))
                if type(fn) == "function" then
                    fn()
                end
            end)

            if okLoad then
                notify("成功", script.Name .. " 加载完成", 2)
            else
                notify("失败", script.Name .. " 加载失败\n请检查脚本或网络", 3)
            end
        end,
    })
end

for _, script in ipairs(scriptList) do
    addButton(scriptTab, script)
end

local about = Window:Tab({Title = "关于", Icon = "solar:info-bold"})
about:Paragraph({
    Title = "说明",
    Desc = "1. 该加载器会读取 GitHub 仓库的全部 .lua 文件\n2. 直接点击脚本即可加载\n3. 不受 GitHub Contents 分页限制\n4. 新增脚本后重开加载器即可刷新",
})
about:Button({
    Title = "刷新脚本列表",
    Justify = "Center",
    Color = Color3.fromRGB(76, 175, 80),
    Callback = function()
        local newList = fetchRepoScripts()
        if #newList == 0 then
            notify("刷新失败", "无法获取仓库文件列表", 2)
            return
        end

        scriptList = newList
        notify("已刷新", "共发现 " .. #scriptList .. " 个脚本", 2)

        -- 关闭原窗口后重新创建，避免按钮重复堆叠
        Window:Close()

        local refreshedWindow = WindUI:CreateWindow({
            Title = "黑脚本库",
            Icon = "solar:folder-bold",
            Size = UDim2.fromOffset(620, 720),
            ToggleKey = Enum.KeyCode.RightShift,
            Acrylic = true,
            ScrollBarEnabled = true,
        })

        refreshedWindow:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
            Title = "动态总加载器",
            Desc = "仓库：cheng2026-tech/Main.lua\n自动扫描仓库全部 .lua 文件\n共 " .. #scriptList .. " 个脚本\n按 RightShift 开关面板",
        })

        local refreshedTab = refreshedWindow:Tab({Title = "脚本列表", Icon = "solar:folder-bold"})
        for _, script in ipairs(scriptList) do
            addButton(refreshedTab, script)
        end
    end,
})

about:Button({
    Title = "关闭加载器",
    Justify = "Center",
    Color = Color3.fromRGB(220, 80, 80),
    Callback = function()
        Window:Close()
    end,
})

notify("加载器", "总加载器已启动\n共 " .. #scriptList .. " 个脚本", 3)
