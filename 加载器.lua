-- 动态黑脚本库加载器
-- 自动读取仓库中所有 .lua 文件，并生成按钮
-- 适用于公开仓库：cheng2026-tech/Main.lua

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

local function repoFiles()
    local result = {}
    local success, response = pcall(function()
        return game:HttpGet("https://api.github.com/repos/cheng2026-tech/Main.lua/contents?ref=main")
    end)

    if not success or not response then
        return result
    end

    local okDecode, data = pcall(function()
        return HttpService:JSONDecode(response)
    end)

    if not okDecode or type(data) ~= "table" then
        return result
    end

    for _, item in ipairs(data) do
        if item and item.type == "file" and item.name and item.download_url then
            table.insert(result, {
                Name = item.name,
                URL = item.download_url,
            })
        end
    end

    table.sort(result, function(a, b)
        return a.Name < b.Name
    end)

    return result
end

local scriptList = repoFiles()

if #scriptList == 0 then
    scriptList = {
        {Name = "加载器.lua", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/%E5%8A%A0%E8%BD%BD%E5%99%A8.lua"},
        {Name = "飞行世界.lua", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/%E9%A3%9E%E8%A1%8C%E4%B8%96%E7%95%8C.lua"},
        {Name = "伐木大亨2.lua", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/%E4%BC%90%E6%9C%A8%E5%A4%A7%E4%BA%A82.lua"},
        {Name = "为你的城市供电.lua", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/%E4%B8%BA%E4%BD%A0%E7%9A%84%E5%9F%8E%E5%B8%82%E4%BE%9B%E7%94%B5.lua"},
        {Name = "住宅大逃杀.lua", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/%E4%BD%8F%E5%AE%85%E5%A4%A7%E9%80%83%E6%9D%80.lua"},
        {Name = "俄亥俄州.lua", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/%E4%BF%84%E4%BA%A5%E4%BF%84%E5%B7%9E.lua"},
        {Name = "blox Fruit.lua", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/blox%20Fruit.lua"},
        {Name = "fisch.lua", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/fisch.lua"},
        {Name = "fps通用.lua", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/fps%E9%80%9A%E7%94%A8.lua"},
        {Name = "重型钓鱼.lua", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/%E9%87%8D%E5%9E%8B%E9%92%93%E9%B1%BC.lua"},
    }
end

local Window = WindUI:CreateWindow({
    Title = "黑脚本库",
    Icon = "solar:folder-bold",
    Size = UDim2.fromOffset(550, 620),
    ToggleKey = Enum.KeyCode.RightShift,
    Acrylic = true,
    ScrollBarEnabled = true,
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "动态总加载器",
    Desc = "仓库：cheng2026-tech/Main.lua\n已自动扫描所有 .lua 文件\n共 " .. #scriptList .. " 个脚本\n按 RightShift 开关面板",
})

local scriptTab = Window:Tab({Title = "脚本列表", Icon = "solar:folder-bold"})

local function addButton(script)
    scriptTab:Button({
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
    addButton(script)
end

local about = Window:Tab({Title = "关于", Icon = "solar:info-bold"})
about:Paragraph({
    Title = "说明",
    Desc = "1. 此加载器会自动读取仓库中所有 .lua 文件\n2. 点击任意脚本即可直接加载\n3. 只要仓库公开，脚本列表会自动更新\n4. 如果有新文件上传，重开加载器即可刷新",
})
about:Button({
    Title = "刷新脚本列表",
    Justify = "Center",
    Color = Color3.fromRGB(76, 175, 80),
    Callback = function()
        scriptList = repoFiles()
        if #scriptList == 0 then
            notify("刷新失败", "无法获取仓库文件列表", 2)
            return
        end
        notify("已刷新", "共发现 " .. #scriptList .. " 个脚本", 2)
        Window:Close()
        local newWindow = WindUI:CreateWindow({
            Title = "黑脚本库",
            Icon = "solar:folder-bold",
            Size = UDim2.fromOffset(550, 620),
            ToggleKey = Enum.KeyCode.RightShift,
            Acrylic = true,
            ScrollBarEnabled = true,
        })
        -- 重新构建（此处不再递归，避免复杂度）
        newWindow:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
            Title = "动态总加载器",
            Desc = "仓库：cheng2026-tech/Main.lua\n已自动扫描所有 .lua 文件\n共 " .. #scriptList .. " 个脚本\n按 RightShift 开关面板",
        })
        local newTab = newWindow:Tab({Title = "脚本列表", Icon = "solar:folder-bold"})
        for _, script in ipairs(scriptList) do
            newTab:Button({
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

notify("加载器", "动态总加载器已启动\n共 " .. #scriptList .. " 个脚本", 3)
