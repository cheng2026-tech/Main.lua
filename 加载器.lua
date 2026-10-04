-- 黑脚本库加载器
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
if not WindUI then 
    print("WindUI加载失败")
    return 
end

local Scripts = {
    {Name = "飞行世界", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/%E9%A3%9E%E8%A1%8C%E4%B8%96%E7%95%8C.lua"},
    {Name = "伐木大亨2", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/%E4%BC%90%E6%9C%A8%E5%A4%A7%E4%BA%A82.lua"},
    {Name = "为你的城市供电", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/%E4%B8%BA%E4%BD%A0%E7%9A%84%E5%9F%8E%E5%B8%82%E4%BE%9B%E7%94%B5.lua"},
    {Name = "blox Fruit", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/blox%20Fruit.lua"},
    {Name = "Fisch", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/fisch.lua"},
    {Name = "Po大Po", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/po%E5%A4%A7po.lua"},
    {Name = "住宅大逃杀", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/%E4%BD%8F%E5%AE%85%E5%A4%A7%E9%80%83%E6%9D%80.lua"},
    {Name = "偷走巴掌", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/%E5%81%B7%E8%B5%B0%E5%B7%B4%E6%8E%8C.lua"},
    {Name = "击杀头目", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/%E5%87%BB%E6%9D%80%E5%A4%B4%E7%9B%AE.lua"},
    {Name = "俄亥俄州", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/%E4%BF%84%E4%BA%A5%E4%BF%84%E5%B7%9E.lua"},
    {Name = "穿着已留下映像深刻", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/dit.lua"},
    {Name = "偷一个蛋", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/%E5%81%B7%E4%B8%80%E4%B8%AA%E8%9B%8B.lua"},
    {Name = "NTv3.3", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/NTv3.3.lua"},
    {Name = "fps通用", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/fps%E9%80%9A%E7%94%A8.lua"},
    {Name = "Doors", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/Doors.lua"},
    {Name = "ROB脚本", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/ROB%E8%84%9A%E6%9C%AC.lua"},
    {Name = "Remote", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/Remote.lua"},
    {Name = "Tx翻译", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/Tx%E7%BF%BB%E8%AF%91.lua"},
    {Name = "Loarder脚本", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/Loarder%E8%84%9A%E6%9C%AC.lua"},
    {Name = "黑洞脚本", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/%E9%BB%91%E6%B4%9E%E8%84%9A%E6%9C%AC.lua"},
    {Name = "黄某脚本", URL = "https://raw.githubusercontent.com/cheng2026-tech/Main.lua/main/%E9%BB%84%E6%9F%90%E8%84%9A%E6%9C%AC.lua"},
}

local Window = WindUI:CreateWindow({
    Title = "黑脚本库加载器",
    Icon = "solar:code-bold",
    Size = UDim2.fromOffset(500, 600),
    ToggleKey = Enum.KeyCode.RightShift,
})

Window:Tab({Title = "公告", Icon = "solar:info-circle-bold"}):Paragraph({
    Title = "黑脚本库加载器",
    Desc = "包含 " .. #Scripts .. " 个脚本\n点击下方按钮直接加载\n按 RightShift 开关面板"
})

local ScriptTab = Window:Tab({Title = "脚本列表", Icon = "solar:folder-bold"})

for i, script in ipairs(Scripts) do
    local success = false
    ScriptTab:Button({
        Title = script.Name,
        Justify = "Center",
        Color = Color3.fromRGB(100, 150, 255),
        Callback = function()
            WindUI:Notify({
                Title = "加载中",
                Content = "正在加载 " .. script.Name,
                Duration = 2
            })
            
            pcall(function()
                loadstring(game:HttpGet(script.URL))()
                WindUI:Notify({
                    Title = "成功",
                    Content = script.Name .. " 加载完成",
                    Duration = 2
                })
            end)
        end
    })
end

local InfoTab = Window:Tab({Title = "关于", Icon = "solar:info-bold"})
InfoTab:Paragraph({
    Title = "使用说明",
    Desc = "1. 在脚本列表中选择要加载的脚本\n2. 点击按钮自动加载\n3. 等待脚本初始化完成\n\n如遇加载失败，请检查网络连接"
})

InfoTab:Button({
    Title = "关闭加载器",
    Justify = "Center",
    Color = Color3.fromRGB(200, 50, 50),
    Callback = function()
        Window:Close()
    end
})

WindUI:Notify({
    Title = "加载器",
    Content = "黑脚本库加载器已启动",
    Duration = 3
})
