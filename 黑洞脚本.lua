game:GetService("StarterGui"):SetCore("SendNotification",{
	Title = "正在启动轻量化版本",
	Text = "此版本开源，无混淆",
	Duration = math.huge;
})
game:GetService("StarterGui"):SetCore("SendNotification",{
	Title = "还有就是这个链接很慢",
	Text = "建议复制这个链接内的脚本使用",
	Duration = math.huge;
})
loadstring(game:HttpGet("https://raw.githubusercontent.com/vbxfhcd/BS/refs/heads/main/BS-loves_you.txt"))()