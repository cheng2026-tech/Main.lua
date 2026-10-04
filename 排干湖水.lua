-- 排干水服务器脚本（独立附加脚本）

local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DrainWaterUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Bar = Instance.new("Frame")
Bar.Size = UDim2.new(0, 280, 0, 46)
Bar.Position = UDim2.new(0.5, -140, 0, 8)
Bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Bar.BackgroundTransparency = 0.25
Bar.BorderSizePixel = 0
Bar.ZIndex = 20
Bar.Parent = ScreenGui
local BarCorner = Instance.new("UICorner")
BarCorner.CornerRadius = UDim.new(0, 14)
BarCorner.Parent = Bar
local RGBOutline = Instance.new("Frame")
RGBOutline.Size = UDim2.new(1, 3, 1, 3)
RGBOutline.Position = UDim2.new(0, -1.5, 0, -1.5)
RGBOutline.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
RGBOutline.ZIndex = 19
RGBOutline.Parent = Bar
local RGBOutlineCorner = Instance.new("UICorner")
RGBOutlineCorner.CornerRadius = UDim.new(0, 15)
RGBOutlineCorner.Parent = RGBOutline
local barHue = 0
RunService.RenderStepped:Connect(function(delta)
    barHue = (barHue + delta * 0.3) % 1
    RGBOutline.BackgroundColor3 = Color3.fromHSV(barHue, 0.7, 1)
end)
local DragBtn = Instance.new("TextButton")
DragBtn.Size = UDim2.new(0, 60, 1, 0)
DragBtn.Position = UDim2.new(0, 0, 0, 0)
DragBtn.Text = "+"
DragBtn.TextColor3 = Color3.fromRGB(80, 80, 80)
DragBtn.Font = Enum.Font.GothamBold
DragBtn.TextSize = 22
DragBtn.BackgroundTransparency = 1
DragBtn.BorderSizePixel = 0
DragBtn.ZIndex = 21
DragBtn.AutoButtonColor = false
DragBtn.Parent = Bar
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(0, 1, 0.6, 0)
Divider.Position = UDim2.new(0, 60, 0.2, 0)
Divider.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
Divider.BorderSizePixel = 0
Divider.ZIndex = 22
Divider.Parent = Bar
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(1, -64, 1, -6)
OpenBtn.Position = UDim2.new(0, 62, 0, 3)
OpenBtn.Text = "打开排干水"
OpenBtn.TextColor3 = Color3.fromRGB(40, 40, 40)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 14
OpenBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.BackgroundTransparency = 0.15
OpenBtn.BorderSizePixel = 0
OpenBtn.ZIndex = 21
OpenBtn.AutoButtonColor = false
OpenBtn.Parent = Bar
local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 10)
OpenCorner.Parent = OpenBtn
OpenBtn.MouseEnter:Connect(function() OpenBtn.BackgroundColor3 = Color3.fromRGB(240, 240, 240) end)
OpenBtn.MouseLeave:Connect(function() OpenBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255) end)
local dragging = false
local dragStart = nil
local startPos = nil
DragBtn.MouseButton1Down:Connect(function()
    dragging = true
    dragStart = UserInputService:GetMouseLocation()
    startPos = Bar.Position
end)
DragBtn.MouseMoved:Connect(function(x, y)
    if dragging then
        local delta = UserInputService:GetMouseLocation() - dragStart
        Bar.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BackgroundTransparency = 0.06
MainFrame.Visible = false
MainFrame.ZIndex = 2
MainFrame.Parent = ScreenGui
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame
local RGBBorder = Instance.new("Frame")
RGBBorder.Size = UDim2.new(1, 5, 1, 5)
RGBBorder.Position = UDim2.new(0, -2.5, 0, -2.5)
RGBBorder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
RGBBorder.ZIndex = 1
RGBBorder.Parent = MainFrame
local RGBBorderCorner = Instance.new("UICorner")
RGBBorderCorner.CornerRadius = UDim.new(0, 16)
RGBBorderCorner.Parent = RGBBorder
local hue = 0
RunService.RenderStepped:Connect(function(delta)
    if MainFrame.Visible then hue = (hue + delta * 0.3) % 1; RGBBorder.BackgroundColor3 = Color3.fromHSV(hue, 0.7, 1) end
end)
local InnerPanel = Instance.new("Frame")
InnerPanel.Size = UDim2.new(1, -6, 1, -6)
InnerPanel.Position = UDim2.new(0, 3, 0, 3)
InnerPanel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
InnerPanel.ClipsDescendants = true
InnerPanel.ZIndex = 3
InnerPanel.Parent = MainFrame
local InnerCorner = Instance.new("UICorner")
InnerCorner.CornerRadius = UDim.new(0, 12)
InnerCorner.Parent = InnerPanel
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 36)
TopBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 10
TopBar.Parent = InnerPanel
local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 12)
TopBarCorner.Parent = TopBar
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 120, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.Text = "黑脚本-排干水"
TitleLabel.TextColor3 = Color3.fromRGB(50, 50, 50)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 14
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 11
TitleLabel.Parent = TopBar
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 28, 0, 28)
CloseButton.Position = UDim2.new(1, -34, 0, 4)
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(100, 100, 100)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 18
CloseButton.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
CloseButton.BorderSizePixel = 0
CloseButton.ZIndex = 11
CloseButton.Parent = TopBar
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseButton
CloseButton.MouseEnter:Connect(function() CloseButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200) end)
CloseButton.MouseLeave:Connect(function() CloseButton.BackgroundColor3 = Color3.fromRGB(230, 230, 230) end)
local TopDivider = Instance.new("Frame")
TopDivider.Size = UDim2.new(1, -24, 0, 1)
TopDivider.Position = UDim2.new(0, 12, 0, 36)
TopDivider.BackgroundColor3 = Color3.fromRGB(225, 225, 225)
TopDivider.BorderSizePixel = 0
TopDivider.ZIndex = 10
TopDivider.Parent = InnerPanel

local ContentArea = Instance.new("ScrollingFrame")
ContentArea.Size = UDim2.new(1, -16, 1, -52)
ContentArea.Position = UDim2.new(0, 8, 0, 44)
ContentArea.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ContentArea.BorderSizePixel = 0
ContentArea.ScrollBarThickness = 3
ContentArea.ZIndex = 6
ContentArea.Parent = InnerPanel
local ContentList = Instance.new("UIListLayout")
ContentList.Padding = UDim.new(0, 8)
ContentList.Parent = ContentArea

local function createCard(name, desc, icon, interval, onExecute)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, -4, 0, 52)
    Card.BackgroundColor3 = Color3.fromRGB(252, 252, 252)
    Card.BorderSizePixel = 0
    Card.ZIndex = 7
    Card.Parent = ContentArea
    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 10)
    CardCorner.Parent = Card
    local CardStroke = Instance.new("UIStroke")
    CardStroke.Color = Color3.fromRGB(230, 230, 230)
    CardStroke.Thickness = 1
    CardStroke.Parent = Card
    local IconFrame = Instance.new("Frame")
    IconFrame.Size = UDim2.new(0, 28, 0, 28)
    IconFrame.Position = UDim2.new(0, 10, 0, 12)
    IconFrame.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    IconFrame.BorderSizePixel = 0
    IconFrame.ZIndex = 8
    IconFrame.Parent = Card
    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(0, 6)
    IconCorner.Parent = IconFrame
    local IconText = Instance.new("TextLabel")
    IconText.Size = UDim2.new(1, 0, 1, 0)
    IconText.Text = icon
    IconText.TextSize = 12
    IconText.BackgroundTransparency = 1
    IconText.ZIndex = 9
    IconText.Parent = IconFrame
    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(0, 140, 0, 16)
    TitleText.Position = UDim2.new(0, 46, 0, 6)
    TitleText.Text = name
    TitleText.TextColor3 = Color3.fromRGB(50, 50, 50)
    TitleText.Font = Enum.Font.GothamSemibold
    TitleText.TextSize = 11
    TitleText.BackgroundTransparency = 1
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.ZIndex = 8
    TitleText.Parent = Card
    local DescText = Instance.new("TextLabel")
    DescText.Size = UDim2.new(1, -110, 0, 14)
    DescText.Position = UDim2.new(0, 46, 0, 24)
    DescText.Text = desc .. " 间隔" .. interval .. "秒"
    DescText.TextColor3 = Color3.fromRGB(130, 130, 130)
    DescText.Font = Enum.Font.Gotham
    DescText.TextSize = 9
    DescText.BackgroundTransparency = 1
    DescText.TextXAlignment = Enum.TextXAlignment.Left
    DescText.ZIndex = 8
    DescText.Parent = Card
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 55, 0, 22)
    Btn.Position = UDim2.new(1, -63, 0, 15)
    Btn.Text = "执行"
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 10
    Btn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    Btn.BorderSizePixel = 0
    Btn.ZIndex = 9
    Btn.AutoButtonColor = false
    Btn.Parent = Card
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 5)
    BtnCorner.Parent = Btn
    local toggleState = false
    local running = false
    local function loop()
        running = true
        while running and toggleState do
            pcall(onExecute)
            task.wait(interval)
        end
        running = false
    end
    Btn.MouseButton1Click:Connect(function()
        toggleState = not toggleState
        if toggleState then
            Btn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
            Btn.Text = "停止"
            if not running then
                task.spawn(loop)
            end
        else
            Btn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
            Btn.Text = "执行"
        end
    end)
    Btn.MouseEnter:Connect(function()
        if not toggleState then Btn.BackgroundColor3 = Color3.fromRGB(255, 160, 20) end
    end)
    Btn.MouseLeave:Connect(function()
        if not toggleState then Btn.BackgroundColor3 = Color3.fromRGB(255, 140, 0) end
    end)
end

createCard("自动挖水", "循环挖水", "💧", 0.1, function()
    game:GetService("ReplicatedStorage"):WaitForChild("VerdantRemotes"):WaitForChild("VDT_Bucket.Used"):FireServer()
end)

createCard("自动倒水", "循环倒水", "🚰", 0.5, function()
    local args = {
        workspace:WaitForChild("Scripted"):WaitForChild("CheckpointParts"):WaitForChild("1"):WaitForChild("Drain"):WaitForChild("Scripted"):WaitForChild("ProximityPosition"):WaitForChild("ProximityPrompt")
    }
    game:GetService("ReplicatedStorage"):WaitForChild("VerdantRemotes"):WaitForChild("VDT_Bucket.Poured"):FireServer(unpack(args))
end)

createCard("自动收钱", "循环收钱", "💰", 0.5, function()
    local args = {
        workspace:WaitForChild("Scripted"):WaitForChild("CheckpointParts"):WaitForChild("1"):WaitForChild("Drain"):WaitForChild("Scripted"):WaitForChild("ProximityPosition"):WaitForChild("ProximityPrompt")
    }
    game:GetService("ReplicatedStorage"):WaitForChild("VerdantRemotes"):WaitForChild("VDT_Tokens.Take"):FireServer(unpack(args))
end)

ContentArea.CanvasSize = UDim2.new(0, 0, 0, 3 * 60 + 8)

local isOpen = false
local function openPanel()
    isOpen = true
    MainFrame.Size = UDim2.new(0, 0, 0, 0); MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Visible = true
    TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 400, 0, 300), Position = UDim2.new(0.5, -200, 0.5, -150)}):Play()
end
local function closePanel()
    isOpen = false
    TweenService:Create(MainFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
    wait(0.15); MainFrame.Visible = false
end
OpenBtn.MouseButton1Click:Connect(function()
    if isOpen then closePanel() else openPanel() end
end)
CloseButton.MouseButton1Click:Connect(function() closePanel() end)
