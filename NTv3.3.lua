-- NT 多功能工具 V3.3（修复点击高亮）
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Mouse = LocalPlayer:GetMouse()

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NT_MultiTool"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

-- 坐标显示
local coordFrame = Instance.new("Frame")
coordFrame.Size = UDim2.new(0, 280, 0, 80)
coordFrame.Position = UDim2.new(1, -290, 0, 10)
coordFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
coordFrame.BackgroundTransparency = 0.2
coordFrame.BorderSizePixel = 0
coordFrame.Visible = false
coordFrame.Parent = ScreenGui
Instance.new("UICorner", coordFrame).CornerRadius = UDim.new(0, 12)

local coordLabel = Instance.new("TextLabel")
coordLabel.Size = UDim2.new(1, 0, 1, 0)
coordLabel.BackgroundTransparency = 1
coordLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
coordLabel.Text = "📍 X: 0  Y: 0  Z: 0"
coordLabel.Font = Enum.Font.GothamBold
coordLabel.TextSize = 22
coordLabel.TextXAlignment = Enum.TextXAlignment.Center
coordLabel.Parent = coordFrame

local coordShow = false

local function UpdateCoord()
    while coordShow do
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local pos = hrp.Position
                coordLabel.Text = string.format("📍 X: %.1f  Y: %.1f  Z: %.1f", pos.X, pos.Y, pos.Z)
            end
        end
        task.wait(0.1)
    end
end

-- 主窗口
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 580)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -290)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -60, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.new(1, 1, 1)
TitleLabel.Text = "NT 多功能工具 V3.3"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -66, 0.5, -14)
MinBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
MinBtn.Text = "−"
MinBtn.TextColor3 = Color3.new(1, 1, 1)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 16
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TitleBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(1, 0)

local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame:TweenSize(UDim2.new(0, 480, 0, 36), "Out", "Quad", 0.15)
        MinBtn.Text = "+"
    else
        MainFrame:TweenSize(UDim2.new(0, 480, 0, 580), "Out", "Quad", 0.15)
        MinBtn.Text = "−"
    end
end)

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 40)
TabBar.Position = UDim2.new(0, 0, 0, 36)
TabBar.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local Tab1Btn = Instance.new("TextButton")
Tab1Btn.Size = UDim2.new(0, 120, 1, 0)
Tab1Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
Tab1Btn.Text = "主要功能"
Tab1Btn.TextColor3 = Color3.new(1, 1, 1)
Tab1Btn.Font = Enum.Font.GothamBold
Tab1Btn.TextSize = 12
Tab1Btn.BorderSizePixel = 0
Tab1Btn.Parent = TabBar

local Tab2Btn = Instance.new("TextButton")
Tab2Btn.Size = UDim2.new(0, 120, 1, 0)
Tab2Btn.Position = UDim2.new(0, 120, 0, 0)
Tab2Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
Tab2Btn.Text = "控制"
Tab2Btn.TextColor3 = Color3.fromRGB(180, 180, 200)
Tab2Btn.Font = Enum.Font.GothamBold
Tab2Btn.TextSize = 12
Tab2Btn.BorderSizePixel = 0
Tab2Btn.Parent = TabBar

local Tab3Btn = Instance.new("TextButton")
Tab3Btn.Size = UDim2.new(0, 120, 1, 0)
Tab3Btn.Position = UDim2.new(0, 240, 0, 0)
Tab3Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
Tab3Btn.Text = "脚本"
Tab3Btn.TextColor3 = Color3.fromRGB(180, 180, 200)
Tab3Btn.Font = Enum.Font.GothamBold
Tab3Btn.TextSize = 12
Tab3Btn.BorderSizePixel = 0
Tab3Btn.Parent = TabBar

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -20, 1, -96)
ContentArea.Position = UDim2.new(0, 10, 0, 86)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

local Tab1Content = Instance.new("ScrollingFrame")
Tab1Content.Size = UDim2.new(1, 0, 1, 0)
Tab1Content.BackgroundTransparency = 1
Tab1Content.BorderSizePixel = 0
Tab1Content.ScrollBarThickness = 4
Tab1Content.CanvasSize = UDim2.new(0, 0, 0, 350)
Tab1Content.Parent = ContentArea

local Tab2Content = Instance.new("ScrollingFrame")
Tab2Content.Size = UDim2.new(1, 0, 1, 0)
Tab2Content.BackgroundTransparency = 1
Tab2Content.BorderSizePixel = 0
Tab2Content.ScrollBarThickness = 4
Tab2Content.CanvasSize = UDim2.new(0, 0, 0, 700)
Tab2Content.Visible = false
Tab2Content.Parent = ContentArea

local Tab3Content = Instance.new("Frame")
Tab3Content.Size = UDim2.new(1, 0, 1, 0)
Tab3Content.BackgroundTransparency = 1
Tab3Content.Visible = false
Tab3Content.Parent = ContentArea

-- 变量
local showNames = false
local showHighlight = false
local autoRefresh = false
local nameLabels = {}
local highlightObjects = {}
local selectedItems = {}
local excludeMode = false
local singleMode = false
local clickHighlightMode = false
local searchQuery = ""
local searchRadius = 100
local refreshThread = nil
local clickHighlightTarget = nil
-- 获取物品
local function GetAllItemsInRadius()
    local items = {}
    local char = LocalPlayer.Character
    if not char then return items end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return items end
    local pos = hrp.Position
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local objPos = nil
            if obj:IsA("BasePart") then
                objPos = obj.Position
            elseif obj:IsA("Model") then
                local p = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if p then objPos = p.Position end
            end
            if objPos and (pos - objPos).Magnitude <= searchRadius then
                table.insert(items, obj)
            end
        end
    end
    return items
end

local function GetUniqueItemNames()
    local items = GetAllItemsInRadius()
    local nameMap = {}
    for _, obj in ipairs(items) do
        if searchQuery == "" or obj.Name:lower():find(searchQuery:lower()) then
            nameMap[obj.Name] = true
        end
    end
    local names = {}
    for name, _ in pairs(nameMap) do table.insert(names, name) end
    table.sort(names)
    return names
end

local function ClearHighlights()
    for _, hl in pairs(highlightObjects) do
        pcall(function() hl:Destroy() end)
    end
    highlightObjects = {}
end

local function UpdateNameLabels()
    for _, label in pairs(nameLabels) do pcall(function() label:Destroy() end) end
    nameLabels = {}
    ClearHighlights()
    if not showNames and not showHighlight then return end
    local items = GetAllItemsInRadius()
    for _, obj in ipairs(items) do
        pcall(function()
            local isSelected = selectedItems[obj.Name] ~= nil
            local isClickTarget = (clickHighlightMode and obj == clickHighlightTarget)
            if showNames then
                local showLabel = false
                if clickHighlightMode then
                    showLabel = isClickTarget
                elseif singleMode then
                    showLabel = isSelected
                elseif excludeMode then
                    showLabel = not isSelected
                else
                    showLabel = true
                end
                if showLabel then
                    local target = obj
                    if obj:IsA("Model") then
                        local p = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                        if p then target = p end
                    end
                    local label = Instance.new("BillboardGui")
                    label.Size = UDim2.new(0, 200, 0, 30)
                    label.AlwaysOnTop = true
                    label.Parent = target
                    label.Adornee = target
                    local text = Instance.new("TextLabel")
                    text.Size = UDim2.new(1, 0, 1, 0)
                    text.BackgroundTransparency = 1
                    text.TextColor3 = Color3.new(1, 1, 1)
                    text.Text = obj.Name
                    text.Font = Enum.Font.SourceSansBold
                    text.TextSize = 12
                    text.TextStrokeColor3 = Color3.new(0, 0, 0)
                    text.TextStrokeTransparency = 0.3
                    text.Parent = label
                    table.insert(nameLabels, label)
                end
            end
            if showHighlight then
                local shouldHighlight = false
                if clickHighlightMode then
                    shouldHighlight = isClickTarget
                elseif singleMode then
                    shouldHighlight = isSelected
                elseif excludeMode then
                    shouldHighlight = not isSelected
                else
                    shouldHighlight = isSelected
                end
                if shouldHighlight then
                    local hl = Instance.new("Highlight")
                    hl.FillColor = Color3.fromRGB(255, 100, 100)
                    hl.FillTransparency = 0.2
                    hl.OutlineColor = Color3.new(1, 1, 1)
                    hl.Adornee = obj
                    hl.Parent = obj
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    table.insert(highlightObjects, hl)
                end
            end
        end)
    end
end

-- ===== 修复：点击高亮检测 =====
local function GetRootObject(part)
    -- 从点击的部件向上查找
    local current = part
    while current do
        -- 如果是 Model（玩家、实体等）
        if current:IsA("Model") then
            return current
        end
        -- 如果是 BasePart 且父级是 Model
        if current:IsA("BasePart") and current.Parent and current.Parent:IsA("Model") then
            return current.Parent
        end
        current = current.Parent
    end
    return part
end

Mouse.Button1Down:Connect(function()
    if not clickHighlightMode then return end
    if not showHighlight then return end
    
    local clicked = Mouse.Target
    if not clicked then return end
    
    -- 获取根对象
    local rootObj = GetRootObject(clicked)
    if not rootObj then return end
    
    -- 检查是否在范围内
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local pos = char.HumanoidRootPart.Position
        local objPos = nil
        if rootObj:IsA("BasePart") then
            objPos = rootObj.Position
        elseif rootObj:IsA("Model") then
            local p = rootObj.PrimaryPart or rootObj:FindFirstChildWhichIsA("BasePart")
            if p then objPos = p.Position end
        end
        if objPos and (pos - objPos).Magnitude > searchRadius then
            return
        end
    end
    
    -- 切换高亮
    if clickHighlightTarget == rootObj then
        clickHighlightTarget = nil
        print("取消高亮: " .. rootObj.Name)
    else
        clickHighlightTarget = rootObj
        print("高亮目标: " .. rootObj.Name .. " (" .. rootObj.ClassName .. ")")
    end
    UpdateNameLabels()
end)

local function RefreshControlList()
    for _, child in ipairs(Tab2Content:GetChildren()) do
        if child.Name == "ControlItem" or child.Name == "SearchBar" or child.Name == "ModeToggle" or child.Name == "BatchBtns" then
            child:Destroy()
        end
    end
    local searchFrame = Instance.new("Frame")
    searchFrame.Name = "SearchBar"
    searchFrame.Size = UDim2.new(1, 0, 0, 34)
    searchFrame.Position = UDim2.new(0, 0, 0, 55)
    searchFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    searchFrame.BorderSizePixel = 0
    searchFrame.Parent = Tab2Content
    Instance.new("UICorner", searchFrame).CornerRadius = UDim.new(0, 6)
    local searchIcon = Instance.new("TextLabel")
    searchIcon.Size = UDim2.new(0, 24, 1, 0)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Text = "🔍"
    searchIcon.TextSize = 14
    searchIcon.Font = Enum.Font.Gotham
    searchIcon.Parent = searchFrame
    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -130, 1, -6)
    searchBox.Position = UDim2.new(0, 24, 0, 3)
    searchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    searchBox.BorderSizePixel = 0
    searchBox.TextColor3 = Color3.new(1, 1, 1)
    searchBox.PlaceholderText = "输入物品名称..."
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 12
    searchBox.Text = searchQuery
    searchBox.Parent = searchFrame
    Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 4)
    local searchBtn = Instance.new("TextButton")
    searchBtn.Size = UDim2.new(0, 50, 1, -6)
    searchBtn.Position = UDim2.new(1, -54, 0, 3)
    searchBtn.BackgroundColor3 = Color3.fromRGB(70, 150, 255)
    searchBtn.Text = "搜索"
    searchBtn.TextColor3 = Color3.new(1, 1, 1)
    searchBtn.Font = Enum.Font.GothamBold
    searchBtn.TextSize = 11
    searchBtn.BorderSizePixel = 0
    searchBtn.Parent = searchFrame
    Instance.new("UICorner", searchBtn).CornerRadius = UDim.new(0, 4)
    searchBtn.MouseButton1Click:Connect(function()
        searchQuery = searchBox.Text
        RefreshControlList()
        UpdateNameLabels()
    end)

    local modeFrame = Instance.new("Frame")
    modeFrame.Name = "ModeToggle"
    modeFrame.Size = UDim2.new(1, 0, 0, 88)
    modeFrame.Position = UDim2.new(0, 0, 0, 93)
    modeFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    modeFrame.BorderSizePixel = 0
    modeFrame.Parent = Tab2Content
    Instance.new("UICorner", modeFrame).CornerRadius = UDim.new(0, 6)

    local modeLabel = Instance.new("TextLabel")
    modeLabel.Size = UDim2.new(0.5, 0, 0.35, 0)
    modeLabel.Position = UDim2.new(0, 8, 0, 2)
    modeLabel.BackgroundTransparency = 1
    modeLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    if clickHighlightMode then
        modeLabel.Text = "🖱️ 点击高亮模式"
    elseif singleMode then
        modeLabel.Text = "单透视模式"
    else
        modeLabel.Text = excludeMode and "🚫 排除" or "✅ 包含"
    end
    modeLabel.Font = Enum.Font.Gotham
    modeLabel.TextSize = 11
    modeLabel.TextXAlignment = Enum.TextXAlignment.Left
    modeLabel.Parent = modeFrame

    local modeBtn1 = Instance.new("TextButton")
    modeBtn1.Size = UDim2.new(0, 45, 0, 20)
    modeBtn1.Position = UDim2.new(1, -148, 0, 4)
    modeBtn1.BackgroundColor3 = (not singleMode and not excludeMode and not clickHighlightMode) and Color3.fromRGB(70, 150, 255) or Color3.fromRGB(80, 80, 90)
    modeBtn1.Text = "包含"
    modeBtn1.TextColor3 = Color3.new(1, 1, 1)
    modeBtn1.Font = Enum.Font.GothamBold
    modeBtn1.TextSize = 9
    modeBtn1.BorderSizePixel = 0
    modeBtn1.Parent = modeFrame
    Instance.new("UICorner", modeBtn1).CornerRadius = UDim.new(0, 4)

    local modeBtn2 = Instance.new("TextButton")
    modeBtn2.Size = UDim2.new(0, 45, 0, 20)
    modeBtn2.Position = UDim2.new(1, -100, 0, 4)
    modeBtn2.BackgroundColor3 = (excludeMode and not singleMode and not clickHighlightMode) and Color3.fromRGB(255, 100, 50) or Color3.fromRGB(80, 80, 90)
    modeBtn2.Text = "排除"
    modeBtn2.TextColor3 = Color3.new(1, 1, 1)
    modeBtn2.Font = Enum.Font.GothamBold
    modeBtn2.TextSize = 9
    modeBtn2.BorderSizePixel = 0
    modeBtn2.Parent = modeFrame
    Instance.new("UICorner", modeBtn2).CornerRadius = UDim.new(0, 4)

    local modeBtn3 = Instance.new("TextButton")
    modeBtn3.Size = UDim2.new(0, 45, 0, 20)
    modeBtn3.Position = UDim2.new(1, -148, 0, 28)
    modeBtn3.BackgroundColor3 = (singleMode and not clickHighlightMode) and Color3.fromRGB(200, 50, 200) or Color3.fromRGB(80, 80, 90)
    modeBtn3.Text = "单透"
    modeBtn3.TextColor3 = Color3.new(1, 1, 1)
    modeBtn3.Font = Enum.Font.GothamBold
    modeBtn3.TextSize = 9
    modeBtn3.BorderSizePixel = 0
    modeBtn3.Parent = modeFrame
    Instance.new("UICorner", modeBtn3).CornerRadius = UDim.new(0, 4)

    local modeBtn4 = Instance.new("TextButton")
    modeBtn4.Size = UDim2.new(0, 85, 0, 20)
    modeBtn4.Position = UDim2.new(1, -100, 0, 28)
    modeBtn4.BackgroundColor3 = clickHighlightMode and Color3.fromRGB(255, 200, 50) or Color3.fromRGB(80, 80, 90)
    modeBtn4.Text = "🖱️ 点击高亮"
    modeBtn4.TextColor3 = Color3.new(1, 1, 1)
    modeBtn4.Font = Enum.Font.GothamBold
    modeBtn4.TextSize = 9
    modeBtn4.BorderSizePixel = 0
    modeBtn4.Parent = modeFrame
    Instance.new("UICorner", modeBtn4).CornerRadius = UDim.new(0, 4)

    local hintLabel = Instance.new("TextLabel")
    hintLabel.Size = UDim2.new(0.7, 0, 0.3, 0)
    hintLabel.Position = UDim2.new(0, 8, 0, 56)
    hintLabel.BackgroundTransparency = 1
    hintLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
    hintLabel.Text = clickHighlightMode and "💡 点击场景中的物品/玩家进行高亮" or ""
    hintLabel.Font = Enum.Font.Gotham
    hintLabel.TextSize = 10
    hintLabel.TextXAlignment = Enum.TextXAlignment.Left
    hintLabel.Parent = modeFrame

    local function updateModeBtns()
        modeBtn1.BackgroundColor3 = (not singleMode and not excludeMode and not clickHighlightMode) and Color3.fromRGB(70, 150, 255) or Color3.fromRGB(80, 80, 90)
        modeBtn2.BackgroundColor3 = (excludeMode and not singleMode and not clickHighlightMode) and Color3.fromRGB(255, 100, 50) or Color3.fromRGB(80, 80, 90)
        modeBtn3.BackgroundColor3 = (singleMode and not clickHighlightMode) and Color3.fromRGB(200, 50, 200) or Color3.fromRGB(80, 80, 90)
        modeBtn4.BackgroundColor3 = clickHighlightMode and Color3.fromRGB(255, 200, 50) or Color3.fromRGB(80, 80, 90)
        if clickHighlightMode then
            modeLabel.Text = "🖱️ 点击高亮模式"
            hintLabel.Text = "💡 点击场景中的物品/玩家进行高亮"
        elseif singleMode then
            modeLabel.Text = "单透视模式"
            hintLabel.Text = ""
        else
            modeLabel.Text = excludeMode and "🚫 排除" or "✅ 包含"
            hintLabel.Text = ""
        end
    end

    modeBtn1.MouseButton1Click:Connect(function()
        clickHighlightMode = false; clickHighlightTarget = nil; singleMode = false; excludeMode = false
        updateModeBtns(); RefreshControlList(); UpdateNameLabels()
    end)
    modeBtn2.MouseButton1Click:Connect(function()
        clickHighlightMode = false; clickHighlightTarget = nil; singleMode = false; excludeMode = true
        updateModeBtns(); RefreshControlList(); UpdateNameLabels()
    end)
    modeBtn3.MouseButton1Click:Connect(function()
        clickHighlightMode = false; clickHighlightTarget = nil; singleMode = true; excludeMode = false
        updateModeBtns(); RefreshControlList(); UpdateNameLabels()
    end)
    modeBtn4.MouseButton1Click:Connect(function()
        clickHighlightMode = not clickHighlightMode
        if not clickHighlightMode then clickHighlightTarget = nil end
        singleMode = false; excludeMode = false
        updateModeBtns(); RefreshControlList(); UpdateNameLabels()
    end)

    local batchFrame = Instance.new("Frame")
    batchFrame.Name = "BatchBtns"
    batchFrame.Size = UDim2.new(1, 0, 0, 30)
    batchFrame.Position = UDim2.new(0, 0, 0, 187)
    batchFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    batchFrame.BorderSizePixel = 0
    batchFrame.Parent = Tab2Content
    Instance.new("UICorner", batchFrame).CornerRadius = UDim.new(0, 6)
    local allBtn = Instance.new("TextButton")
    allBtn.Size = UDim2.new(0, 80, 1, -6)
    allBtn.Position = UDim2.new(0, 10, 0, 3)
    allBtn.BackgroundColor3 = Color3.fromRGB(70, 150, 255)
    allBtn.Text = "全部勾选"
    allBtn.TextColor3 = Color3.new(1, 1, 1)
    allBtn.Font = Enum.Font.GothamBold
    allBtn.TextSize = 10
    allBtn.BorderSizePixel = 0
    allBtn.Parent = batchFrame
    Instance.new("UICorner", allBtn).CornerRadius = UDim.new(0, 4)
    local noneBtn = Instance.new("TextButton")
    noneBtn.Size = UDim2.new(0, 80, 1, -6)
    noneBtn.Position = UDim2.new(1, -90, 0, 3)
    noneBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    noneBtn.Text = "全部取消"
    noneBtn.TextColor3 = Color3.new(1, 1, 1)
    noneBtn.Font = Enum.Font.GothamBold
    noneBtn.TextSize = 10
    noneBtn.BorderSizePixel = 0
    noneBtn.Parent = batchFrame
    Instance.new("UICorner", noneBtn).CornerRadius = UDim.new(0, 4)
    allBtn.MouseButton1Click:Connect(function()
        if clickHighlightMode then return end
        selectedItems = {}
        local names = GetUniqueItemNames()
        for _, name in ipairs(names) do selectedItems[name] = true end
        RefreshControlList(); UpdateNameLabels()
    end)
    noneBtn.MouseButton1Click:Connect(function()
        if clickHighlightMode then return end
        selectedItems = {}
        RefreshControlList(); UpdateNameLabels()
    end)

    local names = GetUniqueItemNames()
    for i, name in ipairs(names) do
        local frame = Instance.new("Frame")
        frame.Name = "ControlItem"
        frame.Size = UDim2.new(1, 0, 0, 34)
        frame.Position = UDim2.new(0, 0, 0, 225 + (i-1) * 38)
        frame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        frame.BorderSizePixel = 0
        frame.Parent = Tab2Content
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.65, 0, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(220, 220, 220)
        label.Text = name
        label.Font = Enum.Font.Gotham
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0, 40, 0, 22)
        toggle.Position = UDim2.new(1, -46, 0.5, -11)
        toggle.BackgroundColor3 = selectedItems[name] and Color3.fromRGB(70, 150, 255) or Color3.fromRGB(80, 80, 90)
        toggle.Text = ""
        toggle.BorderSizePixel = 0
        toggle.Parent = frame
        Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 16, 0, 16)
        dot.Position = selectedItems[name] and UDim2.new(0, 20, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        dot.BorderSizePixel = 0
        dot.Parent = toggle
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        toggle.MouseButton1Click:Connect(function()
            if clickHighlightMode then return end
            selectedItems[name] = not selectedItems[name]
            toggle.BackgroundColor3 = selectedItems[name] and Color3.fromRGB(70, 150, 255) or Color3.fromRGB(80, 80, 90)
            dot.Position = selectedItems[name] and UDim2.new(0, 20, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            UpdateNameLabels()
        end)
    end
    Tab2Content.CanvasSize = UDim2.new(0, 0, 0, 225 + #names * 38 + 30)
end

local function StartAutoRefresh()
    if refreshThread then task.cancel(refreshThread); refreshThread = nil end
    if not autoRefresh then return end
    refreshThread = task.spawn(function()
        while autoRefresh do
            pcall(function() UpdateNameLabels() end)
            task.wait(1)
        end
    end)
end

local function CreateToggle(parent, title, yPos, defaultState, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 34)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    frame.BorderSizePixel = 0
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Text = title
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 40, 0, 22)
    toggle.Position = UDim2.new(1, -46, 0.5, -11)
    toggle.BackgroundColor3 = defaultState and Color3.fromRGB(70, 150, 255) or Color3.fromRGB(80, 80, 90)
    toggle.Text = ""
    toggle.BorderSizePixel = 0
    toggle.Parent = frame
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 16, 0, 16)
    dot.Position = defaultState and UDim2.new(0, 20, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    dot.Parent = toggle
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    local state = defaultState or false
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.BackgroundColor3 = state and Color3.fromRGB(70, 150, 255) or Color3.fromRGB(80, 80, 90)
        dot.Position = state and UDim2.new(0, 20, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        if callback then callback(state) end
    end)
end

CreateToggle(Tab1Content, "显示物品名称", 0, false, function(v) showNames = v; UpdateNameLabels() end)
CreateToggle(Tab1Content, "高亮选中物品", 42, false, function(v) showHighlight = v; UpdateNameLabels() end)
CreateToggle(Tab1Content, "📍 显示坐标（右上角）", 84, false, function(v)
    coordShow = v; coordFrame.Visible = v; if v then task.spawn(UpdateCoord) end
end)

local rangeFrame = Instance.new("Frame")
rangeFrame.Size = UDim2.new(1, 0, 0, 34)
rangeFrame.Position = UDim2.new(0, 0, 0, 126)
rangeFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
rangeFrame.BorderSizePixel = 0
rangeFrame.Parent = Tab1Content
Instance.new("UICorner", rangeFrame).CornerRadius = UDim.new(0, 6)
local rangeLabel = Instance.new("TextLabel")
rangeLabel.Size = UDim2.new(0.55, 0, 1, 0)
rangeLabel.Position = UDim2.new(0, 12, 0, 0)
rangeLabel.BackgroundTransparency = 1
rangeLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
rangeLabel.Text = "范围: " .. searchRadius .. "m"
rangeLabel.Font = Enum.Font.Gotham
rangeLabel.TextSize = 12
rangeLabel.TextXAlignment = Enum.TextXAlignment.Left
rangeLabel.Parent = rangeFrame
local rangeInput = Instance.new("TextBox")
rangeInput.Size = UDim2.new(0, 70, 1, -6)
rangeInput.Position = UDim2.new(1, -76, 0, 3)
rangeInput.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
rangeInput.BorderSizePixel = 0
rangeInput.TextColor3 = Color3.new(1, 1, 1)
rangeInput.Text = "100"
rangeInput.Font = Enum.Font.Gotham
rangeInput.TextSize = 12
rangeInput.Parent = rangeFrame
Instance.new("UICorner", rangeInput).CornerRadius = UDim.new(0, 4)
rangeInput.FocusLost:Connect(function()
    local num = tonumber(rangeInput.Text)
    if num and num >= 1 and num <= 10000 then
        searchRadius = num
        rangeLabel.Text = "范围: " .. searchRadius .. "m"
        UpdateNameLabels()
    end
end)

CreateToggle(Tab1Content, "自动刷新（每秒）", 168, false, function(v) autoRefresh = v; if v then StartAutoRefresh() end end)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, 210)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
statusLabel.Text = "状态: 就绪"
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 11
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.Parent = Tab1Content

local controlTitle = Instance.new("TextLabel")
controlTitle.Size = UDim2.new(1, 0, 0, 25)
controlTitle.BackgroundTransparency = 1
controlTitle.TextColor3 = Color3.fromRGB(180, 180, 200)
controlTitle.Text = "📋 搜索 → 点击物品 → 切换高亮"
controlTitle.Font = Enum.Font.GothamBold
controlTitle.TextSize = 12
controlTitle.Parent = Tab2Content

local refreshControlBtn = Instance.new("TextButton")
refreshControlBtn.Size = UDim2.new(1, 0, 0, 28)
refreshControlBtn.Position = UDim2.new(0, 0, 0, 27)
refreshControlBtn.BackgroundColor3 = Color3.fromRGB(70, 150, 255)
refreshControlBtn.Text = "🔄 刷新列表"
refreshControlBtn.TextColor3 = Color3.new(1, 1, 1)
refreshControlBtn.Font = Enum.Font.GothamBold
refreshControlBtn.TextSize = 12
refreshControlBtn.BorderSizePixel = 0
refreshControlBtn.Parent = Tab2Content
Instance.new("UICorner", refreshControlBtn).CornerRadius = UDim.new(0, 6)
refreshControlBtn.MouseButton1Click:Connect(function() RefreshControlList() end)
-- 脚本执行界面 (Tab3)
local scriptTitle = Instance.new("TextLabel")
scriptTitle.Size = UDim2.new(1, 0, 0, 30)
scriptTitle.Position = UDim2.new(0, 0, 0, 5)
scriptTitle.BackgroundTransparency = 1
scriptTitle.TextColor3 = Color3.fromRGB(180, 180, 200)
scriptTitle.Text = "📜 执行 Lua 脚本"
scriptTitle.Font = Enum.Font.GothamBold
scriptTitle.TextSize = 16
scriptTitle.Parent = Tab3Content

local scriptInput = Instance.new("TextBox")
scriptInput.Size = UDim2.new(1, -20, 0, 250)
scriptInput.Position = UDim2.new(0, 10, 0, 40)
scriptInput.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
scriptInput.BorderSizePixel = 0
scriptInput.TextColor3 = Color3.fromRGB(200, 220, 255)
scriptInput.Text = ""
scriptInput.PlaceholderText = "在此输入 Lua 脚本...\n例如: print('Hello from NT!')"
scriptInput.Font = Enum.Font.Code
scriptInput.TextSize = 13
scriptInput.MultiLine = true
scriptInput.ClearTextOnFocus = false
scriptInput.TextXAlignment = Enum.TextXAlignment.Left
scriptInput.TextYAlignment = Enum.TextYAlignment.Top
scriptInput.Parent = Tab3Content
Instance.new("UICorner", scriptInput).CornerRadius = UDim.new(0, 8)

local btnContainer = Instance.new("Frame")
btnContainer.Size = UDim2.new(1, -20, 0, 45)
btnContainer.Position = UDim2.new(0, 10, 0, 300)
btnContainer.BackgroundTransparency = 1
btnContainer.Parent = Tab3Content

local execBtn = Instance.new("TextButton")
execBtn.Size = UDim2.new(0.3, -5, 1, 0)
execBtn.Position = UDim2.new(0, 0, 0, 0)
execBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
execBtn.Text = "▶ 执行"
execBtn.TextColor3 = Color3.new(1, 1, 1)
execBtn.Font = Enum.Font.GothamBold
execBtn.TextSize = 16
execBtn.BorderSizePixel = 0
execBtn.Parent = btnContainer
Instance.new("UICorner", execBtn).CornerRadius = UDim.new(0, 8)

local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(0.3, -5, 1, 0)
clearBtn.Position = UDim2.new(0.35, 5, 0, 0)
clearBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
clearBtn.Text = "🗑 清除"
clearBtn.TextColor3 = Color3.new(1, 1, 1)
clearBtn.Font = Enum.Font.GothamBold
clearBtn.TextSize = 16
clearBtn.BorderSizePixel = 0
clearBtn.Parent = btnContainer
Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 8)

local exampleBtn = Instance.new("TextButton")
exampleBtn.Size = UDim2.new(0.3, -5, 1, 0)
exampleBtn.Position = UDim2.new(0.7, 5, 0, 0)
exampleBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
exampleBtn.Text = "📋 示例"
exampleBtn.TextColor3 = Color3.new(1, 1, 1)
exampleBtn.Font = Enum.Font.GothamBold
exampleBtn.TextSize = 16
exampleBtn.BorderSizePixel = 0
exampleBtn.Parent = btnContainer
Instance.new("UICorner", exampleBtn).CornerRadius = UDim.new(0, 8)

local statusMsg = Instance.new("TextLabel")
statusMsg.Size = UDim2.new(1, -20, 0, 50)
statusMsg.Position = UDim2.new(0, 10, 0, 355)
statusMsg.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
statusMsg.BorderSizePixel = 0
statusMsg.TextColor3 = Color3.fromRGB(200, 200, 220)
statusMsg.Text = "状态: 就绪"
statusMsg.Font = Enum.Font.Gotham
statusMsg.TextSize = 13
statusMsg.TextWrapped = true
statusMsg.Parent = Tab3Content
Instance.new("UICorner", statusMsg).CornerRadius = UDim.new(0, 8)

local outputFrame = Instance.new("ScrollingFrame")
outputFrame.Size = UDim2.new(1, -20, 0, 100)
outputFrame.Position = UDim2.new(0, 10, 0, 415)
outputFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
outputFrame.BorderSizePixel = 0
outputFrame.ScrollBarThickness = 4
outputFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
outputFrame.Parent = Tab3Content
Instance.new("UICorner", outputFrame).CornerRadius = UDim.new(0, 8)

local outputLabel = Instance.new("TextLabel")
outputLabel.Size = UDim2.new(1, -10, 0, 20)
outputLabel.Position = UDim2.new(0, 5, 0, 2)
outputLabel.BackgroundTransparency = 1
outputLabel.TextColor3 = Color3.fromRGB(150, 200, 150)
outputLabel.Text = "输出区:"
outputLabel.Font = Enum.Font.GothamBold
outputLabel.TextSize = 11
outputLabel.TextXAlignment = Enum.TextXAlignment.Left
outputLabel.Parent = outputFrame

local outputLines = {}
local function AddOutput(text, color)
    if not text or text == "" then return end
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 18)
    label.Position = UDim2.new(0, 5, 0, #outputLines * 20 + 22)
    label.BackgroundTransparency = 1
    label.TextColor3 = color or Color3.fromRGB(200, 220, 255)
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.Parent = outputFrame
    table.insert(outputLines, label)
    local totalHeight = #outputLines * 20 + 30
    outputFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
    outputFrame.CanvasPosition = Vector2.new(0, math.max(0, totalHeight - outputFrame.AbsoluteSize.Y))
end

local function ClearOutput()
    for _, child in pairs(outputFrame:GetChildren()) do
        if child ~= outputLabel then child:Destroy() end
    end
    outputLines = {}
    outputFrame.CanvasSize = UDim2.new(0, 0, 0, 30)
end

execBtn.MouseButton1Click:Connect(function()
    local code = scriptInput.Text
    if code == "" or code:gsub("%s", "") == "" then
        statusMsg.Text = "⚠️ 错误: 请输入脚本代码"
        statusMsg.TextColor3 = Color3.fromRGB(255, 180, 100)
        return
    end
    statusMsg.Text = "⏳ 正在执行脚本..."
    statusMsg.TextColor3 = Color3.fromRGB(100, 200, 255)
    local outputCapture = {}
    local oldPrint = print
    print = function(...)
        local args = {...}
        local str = ""
        for i, v in ipairs(args) do
            str = str .. tostring(v)
            if i < #args then str = str .. " " end
        end
        table.insert(outputCapture, str)
        oldPrint(...)
    end
    local success, err = pcall(function()
        local func = loadstring(code)
        if func then func() else error("脚本语法错误") end
    end)
    print = oldPrint
    if not success then
        statusMsg.Text = "❌ 错误: " .. tostring(err or "未知错误")
        statusMsg.TextColor3 = Color3.fromRGB(255, 100, 100)
        AddOutput("❌ " .. tostring(err or "未知错误"), Color3.fromRGB(255, 100, 100))
    else
        statusMsg.Text = "✅ 脚本执行成功!"
        statusMsg.TextColor3 = Color3.fromRGB(100, 255, 100)
        AddOutput("✅ 脚本执行成功", Color3.fromRGB(100, 255, 100))
        if #outputCapture > 0 then
            for _, line in ipairs(outputCapture) do
                AddOutput("📤 " .. line, Color3.fromRGB(200, 220, 255))
            end
        else
            AddOutput("📤 (无输出)", Color3.fromRGB(150, 150, 180))
        end
    end
end)

clearBtn.MouseButton1Click:Connect(function()
    scriptInput.Text = ""
    statusMsg.Text = "状态: 已清除"
    statusMsg.TextColor3 = Color3.fromRGB(200, 200, 220)
    ClearOutput()
end)

exampleBtn.MouseButton1Click:Connect(function()
    scriptInput.Text = [[
-- NT 脚本示例
local player = game.Players.LocalPlayer
local character = player.Character
print("当前玩家: " .. player.Name)
print("游戏名称: " .. game.Name)
if character and character.Humanoid then
    print("血量: " .. character.Humanoid.Health)
    print("移速: " .. character.Humanoid.WalkSpeed)
end
print("✅ 脚本执行完成!")
]]
    statusMsg.Text = "📋 已加载示例脚本"
    statusMsg.TextColor3 = Color3.fromRGB(180, 200, 255)
    ClearOutput()
end)

-- Tab 切换
Tab1Btn.MouseButton1Click:Connect(function()
    Tab1Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    Tab1Btn.TextColor3 = Color3.new(1, 1, 1)
    Tab2Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    Tab2Btn.TextColor3 = Color3.fromRGB(180, 180, 200)
    Tab3Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    Tab3Btn.TextColor3 = Color3.fromRGB(180, 180, 200)
    Tab1Content.Visible = true
    Tab2Content.Visible = false
    Tab3Content.Visible = false
end)

Tab2Btn.MouseButton1Click:Connect(function()
    Tab2Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    Tab2Btn.TextColor3 = Color3.new(1, 1, 1)
    Tab1Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    Tab1Btn.TextColor3 = Color3.fromRGB(180, 180, 200)
    Tab3Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    Tab3Btn.TextColor3 = Color3.fromRGB(180, 180, 200)
    Tab1Content.Visible = false
    Tab2Content.Visible = true
    Tab3Content.Visible = false
    RefreshControlList()
end)

Tab3Btn.MouseButton1Click:Connect(function()
    Tab3Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    Tab3Btn.TextColor3 = Color3.new(1, 1, 1)
    Tab1Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    Tab1Btn.TextColor3 = Color3.fromRGB(180, 180, 200)
    Tab2Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    Tab2Btn.TextColor3 = Color3.fromRGB(180, 180, 200)
    Tab1Content.Visible = false
    Tab2Content.Visible = false
    Tab3Content.Visible = true
end)

RefreshControlList()
print("✅ NT 多功能工具 V3.3 加载完成!")
print("💡 进入「控制」→「点击高亮」模式，点击场景中的任何物品/玩家即可高亮")
