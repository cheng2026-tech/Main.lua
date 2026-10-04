local CoreGui = game:GetService("CoreGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LoadingScreen"
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999999
screenGui.IgnoreGuiInset = true

local overlay = Instance.new("Frame")
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.Position = UDim2.new(0, 0, 0, 0)
overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
overlay.BorderSizePixel = 0
overlay.ZIndex = 999999
overlay.Active = true
overlay.Parent = screenGui

local blockBtn = Instance.new("TextButton")
blockBtn.Size = UDim2.new(1, 0, 1, 0)
blockBtn.BackgroundTransparency = 1
blockBtn.Text = ""
blockBtn.ZIndex = 999999
blockBtn.Active = true
blockBtn.Modal = true
blockBtn.Parent = screenGui

local spinner = Instance.new("Frame")
spinner.Size = UDim2.new(0, 60, 0, 60)
spinner.Position = UDim2.new(0.5, -30, 0.5, -30)
spinner.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
spinner.BorderSizePixel = 0
spinner.ZIndex = 1000000
spinner.Parent = screenGui
Instance.new("UICorner", spinner).CornerRadius = UDim.new(0, 12)

local spinText = Instance.new("TextLabel")
spinText.Size = UDim2.new(1, 0, 1, 0)
spinText.BackgroundTransparency = 1
spinText.Text = "⏳"
spinText.TextColor3 = Color3.fromRGB(200, 200, 200)
spinText.Font = Enum.Font.GothamBold
spinText.TextSize = 28
spinText.ZIndex = 1000001
spinText.Parent = spinner

local loadingText = Instance.new("TextLabel")
loadingText.Size = UDim2.new(0, 200, 0, 30)
loadingText.Position = UDim2.new(0.5, -100, 0.5, 40)
loadingText.BackgroundTransparency = 1
loadingText.Text = "正在连接服务器..."
loadingText.TextColor3 = Color3.fromRGB(150, 150, 150)
loadingText.Font = Enum.Font.GothamMedium
loadingText.TextSize = 14
loadingText.ZIndex = 1000000
loadingText.Parent = screenGui

local versionText = Instance.new("TextLabel")
versionText.Size = UDim2.new(1, 0, 0, 20)
versionText.Position = UDim2.new(0, 0, 1, -30)
versionText.BackgroundTransparency = 1
versionText.Text = "Roblox v" .. game.PlaceVersion
versionText.TextColor3 = Color3.fromRGB(100, 100, 100)
versionText.Font = Enum.Font.Gotham
versionText.TextSize = 11
versionText.ZIndex = 1000000
versionText.Parent = screenGui

local dotCount = 0
spawn(function()
    while true do
        dotCount = (dotCount + 1) % 4
        local dots = string.rep(".", dotCount)
        loadingText.Text = "正在加载无限罗宝，预计耗时10100年" .. dots
        spinText.Rotation = spinText.Rotation + 30
        task.wait(0.5)
    end
end)
