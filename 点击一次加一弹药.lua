-- 点击一次加一弹药 独立脚本（变量已加ammo_前缀，不和主脚本冲突）

local Players = game:GetService("Players")
local ammo_PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

if not getgenv().ammo_ExecCount then getgenv().ammo_ExecCount = 0 end
getgenv().ammo_ExecCount = getgenv().ammo_ExecCount + 1

local ammo_ScreenGui = Instance.new("ScreenGui")
ammo_ScreenGui.Name = "AmmoClickUI"
ammo_ScreenGui.ResetOnSpawn = false
ammo_ScreenGui.Parent = ammo_PlayerGui

local ammo_Bar = Instance.new("Frame")
ammo_Bar.Size = UDim2.new(0, 280, 0, 46)
ammo_Bar.Position = UDim2.new(0.5, -140, 0, 8)
ammo_Bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ammo_Bar.BackgroundTransparency = 0.25
ammo_Bar.BorderSizePixel = 0
ammo_Bar.ZIndex = 20
ammo_Bar.Parent = ammo_ScreenGui
local ammo_BarCorner = Instance.new("UICorner")
ammo_BarCorner.CornerRadius = UDim.new(0, 14)
ammo_BarCorner.Parent = ammo_Bar
local ammo_RGBOutline = Instance.new("Frame")
ammo_RGBOutline.Size = UDim2.new(1, 3, 1, 3)
ammo_RGBOutline.Position = UDim2.new(0, -1.5, 0, -1.5)
ammo_RGBOutline.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ammo_RGBOutline.ZIndex = 19
ammo_RGBOutline.Parent = ammo_Bar
local ammo_RGBOutlineCorner = Instance.new("UICorner")
ammo_RGBOutlineCorner.CornerRadius = UDim.new(0, 15)
ammo_RGBOutlineCorner.Parent = ammo_RGBOutline
local ammo_barHue = 0
RunService.RenderStepped:Connect(function(delta)
    ammo_barHue = (ammo_barHue + delta * 0.3) % 1
    ammo_RGBOutline.BackgroundColor3 = Color3.fromHSV(ammo_barHue, 0.7, 1)
end)
local ammo_DragBtn = Instance.new("TextButton")
ammo_DragBtn.Size = UDim2.new(0, 60, 1, 0)
ammo_DragBtn.Position = UDim2.new(0, 0, 0, 0)
ammo_DragBtn.Text = "+"
ammo_DragBtn.TextColor3 = Color3.fromRGB(80, 80, 80)
ammo_DragBtn.Font = Enum.Font.GothamBold
ammo_DragBtn.TextSize = 22
ammo_DragBtn.BackgroundTransparency = 1
ammo_DragBtn.BorderSizePixel = 0
ammo_DragBtn.ZIndex = 21
ammo_DragBtn.AutoButtonColor = false
ammo_DragBtn.Parent = ammo_Bar
local ammo_Divider = Instance.new("Frame")
ammo_Divider.Size = UDim2.new(0, 1, 0.6, 0)
ammo_Divider.Position = UDim2.new(0, 60, 0.2, 0)
ammo_Divider.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
ammo_Divider.BorderSizePixel = 0
ammo_Divider.ZIndex = 22
ammo_Divider.Parent = ammo_Bar
local ammo_OpenBtn = Instance.new("TextButton")
ammo_OpenBtn.Size = UDim2.new(1, -64, 1, -6)
ammo_OpenBtn.Position = UDim2.new(0, 62, 0, 3)
ammo_OpenBtn.Text = "点击一次加一弹药"
ammo_OpenBtn.TextColor3 = Color3.fromRGB(40, 40, 40)
ammo_OpenBtn.Font = Enum.Font.GothamBold
ammo_OpenBtn.TextSize = 14
ammo_OpenBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ammo_OpenBtn.BackgroundTransparency = 0.15
ammo_OpenBtn.BorderSizePixel = 0
ammo_OpenBtn.ZIndex = 21
ammo_OpenBtn.AutoButtonColor = false
ammo_OpenBtn.Parent = ammo_Bar
local ammo_OpenCorner = Instance.new("UICorner")
ammo_OpenCorner.CornerRadius = UDim.new(0, 10)
ammo_OpenCorner.Parent = ammo_OpenBtn
ammo_OpenBtn.MouseEnter:Connect(function() ammo_OpenBtn.BackgroundColor3 = Color3.fromRGB(240, 240, 240) end)
ammo_OpenBtn.MouseLeave:Connect(function() ammo_OpenBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255) end)
local ammo_dragging = false
local ammo_dragStart = nil
local ammo_startPos = nil
ammo_DragBtn.MouseButton1Down:Connect(function()
    ammo_dragging = true
    ammo_dragStart = UserInputService:GetMouseLocation()
    ammo_startPos = ammo_Bar.Position
end)
ammo_DragBtn.MouseMoved:Connect(function(x, y)
    if ammo_dragging then
        local delta = UserInputService:GetMouseLocation() - ammo_dragStart
        ammo_Bar.Position = UDim2.new(ammo_startPos.X.Scale, ammo_startPos.X.Offset + delta.X, ammo_startPos.Y.Scale, ammo_startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then ammo_dragging = false end
end)

local ammo_MainFrame = Instance.new("Frame")
ammo_MainFrame.Size = UDim2.new(0, 580, 0, 440)
ammo_MainFrame.Position = UDim2.new(0.5, -290, 0.5, -220)
ammo_MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ammo_MainFrame.BackgroundTransparency = 0.06
ammo_MainFrame.Visible = false
ammo_MainFrame.ZIndex = 2
ammo_MainFrame.Parent = ammo_ScreenGui
local ammo_MainCorner = Instance.new("UICorner")
ammo_MainCorner.CornerRadius = UDim.new(0, 14)
ammo_MainCorner.Parent = ammo_MainFrame
local ammo_RGBBorder = Instance.new("Frame")
ammo_RGBBorder.Size = UDim2.new(1, 5, 1, 5)
ammo_RGBBorder.Position = UDim2.new(0, -2.5, 0, -2.5)
ammo_RGBBorder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ammo_RGBBorder.ZIndex = 1
ammo_RGBBorder.Parent = ammo_MainFrame
local ammo_RGBBorderCorner = Instance.new("UICorner")
ammo_RGBBorderCorner.CornerRadius = UDim.new(0, 16)
ammo_RGBBorderCorner.Parent = ammo_RGBBorder
local ammo_hue = 0
RunService.RenderStepped:Connect(function(delta)
    if ammo_MainFrame.Visible then ammo_hue = (ammo_hue + delta * 0.3) % 1; ammo_RGBBorder.BackgroundColor3 = Color3.fromHSV(ammo_hue, 0.7, 1) end
end)
local ammo_InnerPanel = Instance.new("Frame")
ammo_InnerPanel.Size = UDim2.new(1, -6, 1, -6)
ammo_InnerPanel.Position = UDim2.new(0, 3, 0, 3)
ammo_InnerPanel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ammo_InnerPanel.ClipsDescendants = true
ammo_InnerPanel.ZIndex = 3
ammo_InnerPanel.Parent = ammo_MainFrame
local ammo_InnerCorner = Instance.new("UICorner")
ammo_InnerCorner.CornerRadius = UDim.new(0, 12)
ammo_InnerCorner.Parent = ammo_InnerPanel
local ammo_TopBar = Instance.new("Frame")
ammo_TopBar.Size = UDim2.new(1, 0, 0, 36)
ammo_TopBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ammo_TopBar.BorderSizePixel = 0
ammo_TopBar.ZIndex = 10
ammo_TopBar.Parent = ammo_InnerPanel
local ammo_TopBarCorner = Instance.new("UICorner")
ammo_TopBarCorner.CornerRadius = UDim.new(0, 12)
ammo_TopBarCorner.Parent = ammo_TopBar
local ammo_TitleLabel = Instance.new("TextLabel")
ammo_TitleLabel.Size = UDim2.new(0, 120, 1, 0)
ammo_TitleLabel.Position = UDim2.new(0, 12, 0, 0)
ammo_TitleLabel.Text = "点击一次加一弹药"
ammo_TitleLabel.TextColor3 = Color3.fromRGB(50, 50, 50)
ammo_TitleLabel.Font = Enum.Font.GothamBold
ammo_TitleLabel.TextSize = 14
ammo_TitleLabel.BackgroundTransparency = 1
ammo_TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
ammo_TitleLabel.ZIndex = 11
ammo_TitleLabel.Parent = ammo_TopBar
local ammo_InfoBox = Instance.new("Frame")
ammo_InfoBox.Size = UDim2.new(0, 200, 0, 26)
ammo_InfoBox.Position = UDim2.new(0, 130, 0, 5)
ammo_InfoBox.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
ammo_InfoBox.BorderSizePixel = 0
ammo_InfoBox.ZIndex = 12
ammo_InfoBox.Parent = ammo_TopBar
local ammo_InfoCorner = Instance.new("UICorner")
ammo_InfoCorner.CornerRadius = UDim.new(0, 6)
ammo_InfoCorner.Parent = ammo_InfoBox
local ammo_InfoRGBOutline = Instance.new("Frame")
ammo_InfoRGBOutline.Size = UDim2.new(1, 2, 1, 2)
ammo_InfoRGBOutline.Position = UDim2.new(0, -1, 0, -1)
ammo_InfoRGBOutline.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ammo_InfoRGBOutline.ZIndex = 11
ammo_InfoRGBOutline.Parent = ammo_InfoBox
local ammo_InfoRGBCorner = Instance.new("UICorner")
ammo_InfoRGBCorner.CornerRadius = UDim.new(0, 7)
ammo_InfoRGBCorner.Parent = ammo_InfoRGBOutline
local ammo_infoHue = 0
RunService.RenderStepped:Connect(function(delta)
    ammo_infoHue = (ammo_infoHue + delta * 0.5) % 1
    ammo_InfoRGBOutline.BackgroundColor3 = Color3.fromHSV(ammo_infoHue, 0.7, 1)
end)
local ammo_InfoLabel = Instance.new("TextLabel")
ammo_InfoLabel.Size = UDim2.new(1, 0, 1, 0)
ammo_InfoLabel.Text = "V0.01 | " .. os.date("%m月%d日 %H:%M:%S")
ammo_InfoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ammo_InfoLabel.Font = Enum.Font.GothamBold
ammo_InfoLabel.TextSize = 10
ammo_InfoLabel.BackgroundTransparency = 1
ammo_InfoLabel.ZIndex = 13
ammo_InfoLabel.Parent = ammo_InfoBox
spawn(function()
    while true do
        ammo_InfoLabel.Text = "V0.01 | " .. os.date("%m月%d日 %H:%M:%S")
        wait(1)
    end
end)
local ammo_CloseButton = Instance.new("TextButton")
ammo_CloseButton.Size = UDim2.new(0, 28, 0, 28)
ammo_CloseButton.Position = UDim2.new(1, -34, 0, 4)
ammo_CloseButton.Text = "×"
ammo_CloseButton.TextColor3 = Color3.fromRGB(100, 100, 100)
ammo_CloseButton.Font = Enum.Font.GothamBold
ammo_CloseButton.TextSize = 18
ammo_CloseButton.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
ammo_CloseButton.BorderSizePixel = 0
ammo_CloseButton.ZIndex = 11
ammo_CloseButton.Parent = ammo_TopBar
local ammo_CloseCorner = Instance.new("UICorner")
ammo_CloseCorner.CornerRadius = UDim.new(1, 0)
ammo_CloseCorner.Parent = ammo_CloseButton
ammo_CloseButton.MouseEnter:Connect(function() ammo_CloseButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200) end)
ammo_CloseButton.MouseLeave:Connect(function() ammo_CloseButton.BackgroundColor3 = Color3.fromRGB(230, 230, 230) end)
local ammo_TopDivider = Instance.new("Frame")
ammo_TopDivider.Size = UDim2.new(1, -24, 0, 1)
ammo_TopDivider.Position = UDim2.new(0, 12, 0, 36)
ammo_TopDivider.BackgroundColor3 = Color3.fromRGB(225, 225, 225)
ammo_TopDivider.BorderSizePixel = 0
ammo_TopDivider.ZIndex = 10
ammo_TopDivider.Parent = ammo_InnerPanel
local ammo_MainContentContainer = Instance.new("Frame")
ammo_MainContentContainer.Size = UDim2.new(1, 0, 1, -36)
ammo_MainContentContainer.Position = UDim2.new(0, 0, 0, 36)
ammo_MainContentContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ammo_MainContentContainer.BorderSizePixel = 0
ammo_MainContentContainer.ZIndex = 5
ammo_MainContentContainer.Parent = ammo_InnerPanel

local ammo_NavFrame = Instance.new("Frame")
ammo_NavFrame.Size = UDim2.new(0, 135, 1, 0)
ammo_NavFrame.Position = UDim2.new(0, 0, 0, 0)
ammo_NavFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ammo_NavFrame.BackgroundTransparency = 0.03
ammo_NavFrame.BorderSizePixel = 0
ammo_NavFrame.ZIndex = 6
ammo_NavFrame.Parent = ammo_MainContentContainer
local ammo_NavDivider = Instance.new("Frame")
ammo_NavDivider.Size = UDim2.new(0, 1, 1, 0)
ammo_NavDivider.Position = UDim2.new(1, 0, 0, 0)
ammo_NavDivider.BackgroundColor3 = Color3.fromRGB(225, 225, 225)
ammo_NavDivider.BorderSizePixel = 0
ammo_NavDivider.ZIndex = 7
ammo_NavDivider.Parent = ammo_NavFrame
local ammo_NavScroll = Instance.new("ScrollingFrame")
ammo_NavScroll.Size = UDim2.new(1, 0, 1, 0)
ammo_NavScroll.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ammo_NavScroll.BackgroundTransparency = 0.03
ammo_NavScroll.BorderSizePixel = 0
ammo_NavScroll.ScrollBarThickness = 0
ammo_NavScroll.CanvasSize = UDim2.new(0, 0, 0, 200)
ammo_NavScroll.ZIndex = 6
ammo_NavScroll.Parent = ammo_NavFrame
local ammo_NavList = Instance.new("UIListLayout")
ammo_NavList.Padding = UDim.new(0, 2)
ammo_NavList.Parent = ammo_NavScroll
local ammo_NavTopPad = Instance.new("Frame")
ammo_NavTopPad.Size = UDim2.new(1, 0, 0, 5)
ammo_NavTopPad.BackgroundTransparency = 1
ammo_NavTopPad.Parent = ammo_NavScroll
local ammo_navItems = {{name = "公告", icon = "📢"},{name = "主要功能", icon = "⚙️"}}
local ammo_navButtons = {}
local ammo_selectedNav = nil
local ammo_ContentArea = Instance.new("Frame")
ammo_ContentArea.Size = UDim2.new(1, -136, 1, 0)
ammo_ContentArea.Position = UDim2.new(0, 136, 0, 0)
ammo_ContentArea.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ammo_ContentArea.BorderSizePixel = 0
ammo_ContentArea.ZIndex = 6
ammo_ContentArea.Parent = ammo_MainContentContainer
local ammo_contentPages = {}
function ammo_switchContent(n) for a, b in pairs(ammo_contentPages) do b.Visible = (a == n) end end
local function ammo_selectNav(button, itemName)
    if ammo_selectedNav then ammo_selectedNav.BackgroundColor3 = Color3.fromRGB(255, 255, 255) end
    button.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
    ammo_selectedNav = button
    ammo_TitleLabel.Text = itemName
    ammo_switchContent(itemName)
end
for _, item in ipairs(ammo_navItems) do
    local NavButton = Instance.new("TextButton")
    NavButton.Size = UDim2.new(1, -12, 0, 36); NavButton.Position = UDim2.new(0, 6, 0, 0)
    NavButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255); NavButton.Text = ""
    NavButton.BorderSizePixel = 0; NavButton.ZIndex = 7; NavButton.AutoButtonColor = false; NavButton.Parent = ammo_NavScroll
    local NavCorner = Instance.new("UICorner"); NavCorner.CornerRadius = UDim.new(0, 8); NavCorner.Parent = NavButton
    local NavIcon = Instance.new("TextLabel")
    NavIcon.Size = UDim2.new(0, 14, 1, 0); NavIcon.Position = UDim2.new(0, 2, 0, 0)
    NavIcon.Text = item.icon; NavIcon.TextSize = 10; NavIcon.BackgroundTransparency = 1
    NavIcon.TextXAlignment = Enum.TextXAlignment.Left; NavIcon.ZIndex = 8; NavIcon.Parent = NavButton
    local NavLabel = Instance.new("TextLabel")
    NavLabel.Size = UDim2.new(1, -22, 1, 0); NavLabel.Position = UDim2.new(0, 26, 0, 0)
    NavLabel.Text = "  " .. item.name; NavLabel.TextColor3 = Color3.fromRGB(60, 60, 60)
    NavLabel.Font = Enum.Font.GothamSemibold; NavLabel.TextSize = 11; NavLabel.BackgroundTransparency = 1
    NavLabel.TextXAlignment = Enum.TextXAlignment.Left; NavLabel.ZIndex = 8; NavLabel.Parent = NavButton
    NavButton.MouseButton1Click:Connect(function() ammo_selectNav(NavButton, item.name) end)
    NavButton.MouseEnter:Connect(function() if NavButton ~= ammo_selectedNav then NavButton.BackgroundColor3 = Color3.fromRGB(240, 240, 240) end end)
    NavButton.MouseLeave:Connect(function() if NavButton ~= ammo_selectedNav then NavButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255) end end)
    table.insert(ammo_navButtons, {button = NavButton, name = item.name})
end

local ammo_announcementPage = Instance.new("ScrollingFrame")
ammo_announcementPage.Size = UDim2.new(1, 0, 1, 0)
ammo_announcementPage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ammo_announcementPage.BorderSizePixel = 0
ammo_announcementPage.ScrollBarThickness = 3
ammo_announcementPage.Visible = false
ammo_announcementPage.ZIndex = 7
ammo_announcementPage.Parent = ammo_ContentArea
local ammo_announcementText = Instance.new("TextLabel")
ammo_announcementText.Size = UDim2.new(1, -20, 0, 400)
ammo_announcementText.Position = UDim2.new(0, 10, 0, 10)
ammo_announcementText.Text = "📢 C工作室\n\n本脚本由C工作室亲自制作 点一次加一弹药\n非常简易\n\n感谢使用！"
ammo_announcementText.TextColor3 = Color3.fromRGB(70, 70, 70)
ammo_announcementText.Font = Enum.Font.Gotham
ammo_announcementText.TextSize = 13
ammo_announcementText.BackgroundTransparency = 1
ammo_announcementText.TextXAlignment = Enum.TextXAlignment.Left
ammo_announcementText.TextYAlignment = Enum.TextYAlignment.Top
ammo_announcementText.TextWrapped = true
ammo_announcementText.LineHeight = 1.8
ammo_announcementText.ZIndex = 8
ammo_announcementText.Parent = ammo_announcementPage
ammo_contentPages["公告"] = ammo_announcementPage

local ammo_mainPage = Instance.new("ScrollingFrame")
ammo_mainPage.Size = UDim2.new(1, 0, 1, 0)
ammo_mainPage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ammo_mainPage.BorderSizePixel = 0
ammo_mainPage.ScrollBarThickness = 3
ammo_mainPage.Visible = false
ammo_mainPage.ZIndex = 7
ammo_mainPage.Parent = ammo_ContentArea
local ammo_mainPageList = Instance.new("UIListLayout")
ammo_mainPageList.Padding = UDim.new(0, 6)
ammo_mainPageList.Parent = ammo_mainPage
local ammo_mainPageSpacer = Instance.new("Frame")
ammo_mainPageSpacer.Size = UDim2.new(1, 0, 0, 6)
ammo_mainPageSpacer.BackgroundTransparency = 1
ammo_mainPageSpacer.Parent = ammo_mainPage

local ammo_Card = Instance.new("Frame")
ammo_Card.Size = UDim2.new(1, -16, 0, 46)
ammo_Card.Position = UDim2.new(0, 8, 0, 0)
ammo_Card.BackgroundColor3 = Color3.fromRGB(252, 252, 252)
ammo_Card.BorderSizePixel = 0
ammo_Card.ZIndex = 7
ammo_Card.Parent = ammo_mainPage
local ammo_CardCorner = Instance.new("UICorner")
ammo_CardCorner.CornerRadius = UDim.new(0, 10)
ammo_CardCorner.Parent = ammo_Card
local ammo_CardStroke = Instance.new("UIStroke")
ammo_CardStroke.Color = Color3.fromRGB(230, 230, 230)
ammo_CardStroke.Thickness = 1
ammo_CardStroke.Parent = ammo_Card
local ammo_IconFrame = Instance.new("Frame")
ammo_IconFrame.Size = UDim2.new(0, 26, 0, 26)
ammo_IconFrame.Position = UDim2.new(0, 10, 0, 10)
ammo_IconFrame.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
ammo_IconFrame.BorderSizePixel = 0
ammo_IconFrame.ZIndex = 8
ammo_IconFrame.Parent = ammo_Card
local ammo_IconCorner = Instance.new("UICorner")
ammo_IconCorner.CornerRadius = UDim.new(0, 6)
ammo_IconCorner.Parent = ammo_IconFrame
local ammo_IconText = Instance.new("TextLabel")
ammo_IconText.Size = UDim2.new(1, 0, 1, 0)
ammo_IconText.Text = "🦶"
ammo_IconText.TextSize = 11
ammo_IconText.BackgroundTransparency = 1
ammo_IconText.ZIndex = 9
ammo_IconText.Parent = ammo_IconFrame
local ammo_TitleText = Instance.new("TextLabel")
ammo_TitleText.Size = UDim2.new(0, 180, 0, 15)
ammo_TitleText.Position = UDim2.new(0, 44, 0, 5)
ammo_TitleText.Text = "自动点击"
ammo_TitleText.TextColor3 = Color3.fromRGB(50, 50, 50)
ammo_TitleText.Font = Enum.Font.GothamSemibold
ammo_TitleText.TextSize = 11
ammo_TitleText.BackgroundTransparency = 1
ammo_TitleText.TextXAlignment = Enum.TextXAlignment.Left
ammo_TitleText.ZIndex = 8
ammo_TitleText.Parent = ammo_Card
local ammo_DescText = Instance.new("TextLabel")
ammo_DescText.Size = UDim2.new(1, -100, 0, 13)
ammo_DescText.Position = UDim2.new(0, 44, 0, 22)
ammo_DescText.Text = "自动帮你点开枪"
ammo_DescText.TextColor3 = Color3.fromRGB(130, 130, 130)
ammo_DescText.Font = Enum.Font.Gotham
ammo_DescText.TextSize = 9
ammo_DescText.BackgroundTransparency = 1
ammo_DescText.TextXAlignment = Enum.TextXAlignment.Left
ammo_DescText.ZIndex = 8
ammo_DescText.Parent = ammo_Card
local ammo_Btn = Instance.new("TextButton")
ammo_Btn.Size = UDim2.new(0, 50, 0, 20)
ammo_Btn.Position = UDim2.new(1, -58, 0, 13)
ammo_Btn.Text = "执行"
ammo_Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
ammo_Btn.Font = Enum.Font.GothamBold
ammo_Btn.TextSize = 10
ammo_Btn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
ammo_Btn.BorderSizePixel = 0
ammo_Btn.ZIndex = 9
ammo_Btn.AutoButtonColor = false
ammo_Btn.Parent = ammo_Card
local ammo_BtnCorner = Instance.new("UICorner")
ammo_BtnCorner.CornerRadius = UDim.new(0, 5)
ammo_BtnCorner.Parent = ammo_Btn
local ammo_toggleState = false
local ammo_running = false
local function ammo_loop()
    ammo_running = true
    while ammo_running and ammo_toggleState do
        pcall(function()
            game:GetService("ReplicatedStorage")
                :WaitForChild("Packages")
                :WaitForChild("_Index")
                :WaitForChild("sleitnick_knit@1.7.0")
                :WaitForChild("knit")
                :WaitForChild("Services")
                :WaitForChild("KickService")
                :WaitForChild("RF")
                :WaitForChild("AddKick")
                :InvokeServer()
        end)
        task.wait(0)
    end
    ammo_running = false
end
ammo_Btn.MouseButton1Click:Connect(function()
    ammo_toggleState = not ammo_toggleState
    if ammo_toggleState then
        ammo_Btn.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
        ammo_Btn.Text = "停止"
        if not ammo_running then
            task.spawn(ammo_loop)
        end
    else
        ammo_Btn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
        ammo_Btn.Text = "执行"
    end
end)
ammo_Btn.MouseEnter:Connect(function()
    if not ammo_toggleState then ammo_Btn.BackgroundColor3 = Color3.fromRGB(255, 160, 20) end
end)
ammo_Btn.MouseLeave:Connect(function()
    if not ammo_toggleState then ammo_Btn.BackgroundColor3 = Color3.fromRGB(255, 140, 0) end
end)

ammo_mainPage.CanvasSize = UDim2.new(0, 0, 0, 60)
ammo_contentPages["主要功能"] = ammo_mainPage

ammo_contentPages["公告"].Visible = true

local ammo_isOpen = false
local function ammo_openPanel()
    ammo_isOpen = true
    ammo_MainFrame.Size = UDim2.new(0, 0, 0, 0); ammo_MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    ammo_MainFrame.Visible = true
    TweenService:Create(ammo_MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 580, 0, 440), Position = UDim2.new(0.5, -290, 0.5, -220)}):Play()
end
local function ammo_closePanel()
    ammo_isOpen = false
    TweenService:Create(ammo_MainFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
    wait(0.15); ammo_MainFrame.Visible = false
end
ammo_OpenBtn.MouseButton1Click:Connect(function()
    if ammo_isOpen then ammo_closePanel() else ammo_openPanel() end
end)
ammo_CloseButton.MouseButton1Click:Connect(function() ammo_closePanel() end)
ammo_selectNav(ammo_navButtons[1].button, "公告")
