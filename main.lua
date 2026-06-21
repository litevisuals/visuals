local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local TargetGui = (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui")
local Stats = game:GetService("Stats")

local function tween(obj, props, time, style)
    local tInfo = TweenInfo.new(time or 0.25, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local anim = TweenService:Create(obj, tInfo, props)
    anim:Play()
    return anim
end

local function makeDraggable(clickObj, dragObj)
    local drag, dragStart, sPos
    clickObj.InputBegan:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true; dragStart = i.Position; sPos = dragObj.Position end 
    end)
    UserInputService.InputChanged:Connect(function(i) 
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then 
            local delta = i.Position - dragStart
            dragObj.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y)
        end 
    end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end)
end

if TargetGui:FindFirstChild("LiteVisuals") then TargetGui.LiteVisuals:Destroy() end

local Screen = Instance.new("ScreenGui", TargetGui)
Screen.Name = "LiteVisuals"; Screen.ResetOnSpawn = false

local currentLang = "RU"
local activeMods = {} 
local flySpeed, walkSpeed, spinSpeed, magnetSize = 50, 16, 40, 10
local isMenuOpen, noclipEnabled, espEnabled, espNames, espMM2, rgbEffectsEnabled, graphicsEnabled, magnetEnabled, spinEnabled, flingEnabled = true, false, false, false, false, false, false, false, false, false

local Localization = {
    RU = {
        MainTab = "Читы", VisualsTab = "Визуалы", SettingsTab = "Настройки", ActiveModsTitle = "АКТИВНО:",
        ActiveBuild = "АКТИВЕН", Speedhack = "Speedhack", WalkSpeed = "Скорость бега",
        Fly = "Fly (WASD)", FlySpeed = "Скорость полета", SpinBot = "Spin Bot", SpinSpeed = "Скорость вращения",
        Noclip = "Noclip", Fling = "Orbit Fling (Улет врага)", Esp = "Neon ESP (Wallhack)", EspNames = "ESP Никнеймы", 
        EspMM2 = "ESP Роли (MM2 Мардер)", Fov = "FOV (Растяг)", Widget = "Мини-виджет (Stats)", 
        ActiveList = "Список включенного", Rainbow = "Rainbow Glow", LangBtn = "Язык: RU", 
        Graphics = "Улучшенная графика (RTX)", Magnet = "Магнит пуль (Hitbox Expand)"
    },
    EN = {
        MainTab = "Main Hacks", VisualsTab = "Visuals", SettingsTab = "Settings", ActiveModsTitle = "ACTIVE MODS:",
        ActiveBuild = "ACTIVE BUILD", Speedhack = "Speedhack", WalkSpeed = "Walk Speed",
        Fly = "Fly (WASD)", FlySpeed = "Fly Speed", SpinBot = "Spin Bot", SpinSpeed = "Spin Speed",
        Noclip = "Noclip", Fling = "Orbit Fling (Nearest)", Esp = "Neon ESP (Wallhack)", EspNames = "ESP Names", 
        EspMM2 = "ESP Roles (MM2)", Fov = "FOV Tracker", Widget = "Stats Widget (Drag)", 
        ActiveList = "Active Mods Widget", Rainbow = "Rainbow Glow", LangBtn = "Lang: EN", 
        Graphics = "Enhance Graphics (RTX)", Magnet = "Bullet Magnet (Hitbox Expand)"
    }
}

local textObjects = {}
local function registerText(obj, key, isTab) textObjects[obj] = {key = key, isTab = isTab} end
local function updateLanguage(lang)
    currentLang = lang
    for obj, data in pairs(textObjects) do
        if obj and obj.Parent then obj.Text = data.isTab and "   " .. Localization[lang][data.key] or Localization[lang][data.key] end
    end
end

local MainCanvas = Instance.new("CanvasGroup", Screen)
MainCanvas.Size = UDim2.new(0, 520, 0, 330); MainCanvas.Position = UDim2.new(0.5, -260, 0.5, -165); MainCanvas.BackgroundTransparency = 1; MainCanvas.ClipsDescendants = false
local Main = Instance.new("Frame", MainCanvas)
Main.Size = UDim2.new(1, 0, 1, 0); Main.BackgroundColor3 = Color3.fromRGB(16, 16, 18); Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", Main); MainStroke.Color = Color3.fromRGB(32, 32, 36); MainStroke.Thickness = 1.5
makeDraggable(Main, MainCanvas)

local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 150, 1, 0); Sidebar.BackgroundColor3 = Color3.fromRGB(11, 11, 13); Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)
local SideCover = Instance.new("Frame", Sidebar)
SideCover.Size = UDim2.new(0, 15, 1, 0); SideCover.Position = UDim2.new(1, -15, 0, 0); SideCover.BackgroundColor3 = Color3.fromRGB(11, 11, 13); SideCover.BorderSizePixel = 0

local function createMacDot(color, xOffset)
    local dot = Instance.new("Frame", Sidebar); dot.Size = UDim2.new(0, 10, 0, 10); dot.Position = UDim2.new(0, xOffset, 0, 16); dot.BackgroundColor3 = color; Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
end
createMacDot(Color3.fromRGB(255, 95, 86), 16); createMacDot(Color3.fromRGB(255, 189, 46), 32); createMacDot(Color3.fromRGB(39, 201, 63), 48)

local LogoTitle = Instance.new("TextLabel", Sidebar)
LogoTitle.Size = UDim2.new(1, -20, 0, 20); LogoTitle.Position = UDim2.new(0, 16, 0, 42); LogoTitle.BackgroundTransparency = 1; LogoTitle.Text = "LITE VISUALS"; LogoTitle.TextColor3 = Color3.new(1, 1, 1); LogoTitle.Font = Enum.Font.GothamBold; LogoTitle.TextSize = 15

local StatusIndicator = Instance.new("Frame", Sidebar)
StatusIndicator.Size = UDim2.new(0, 6, 0, 6); StatusIndicator.Position = UDim2.new(0, 18, 0, 68); StatusIndicator.BackgroundColor3 = Color3.fromRGB(75, 255, 100); Instance.new("UICorner", StatusIndicator).CornerRadius = UDim.new(1, 0)
local StatusLabel = Instance.new("TextLabel", Sidebar)
StatusLabel.Font = Enum.Font.GothamBold; StatusLabel.TextColor3 = Color3.fromRGB(100, 100, 105); StatusLabel.TextSize = 9; StatusLabel.Position = UDim2.new(0, 29, 0, 65); StatusLabel.BackgroundTransparency = 1; StatusLabel.TextXAlignment = Enum.TextXAlignment.Left; registerText(StatusLabel, "ActiveBuild")

local InfoFrame = Instance.new("Frame", Sidebar)
InfoFrame.Size = UDim2.new(0.8, 0, 0, 45); InfoFrame.Position = UDim2.new(0.1, 0, 1, -115); InfoFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22); Instance.new("UICorner", InfoFrame).CornerRadius = UDim.new(0, 6); local InfoStroke = Instance.new("UIStroke", InfoFrame); InfoStroke.Color = Color3.fromRGB(25, 25, 30)
local SideFPSLabel = Instance.new("TextLabel", InfoFrame); SideFPSLabel.Size = UDim2.new(1, -10, 0.5, 0); SideFPSLabel.Position = UDim2.new(0, 10, 0, 2); SideFPSLabel.BackgroundTransparency = 1; SideFPSLabel.Text = "FPS: --"; SideFPSLabel.TextColor3 = Color3.fromRGB(200, 200, 205); SideFPSLabel.Font = Enum.Font.GothamBold; SideFPSLabel.TextSize = 10; SideFPSLabel.TextXAlignment = Enum.TextXAlignment.Left; local SideTimeLabel = Instance.new("TextLabel", InfoFrame); SideTimeLabel.Size = UDim2.new(1, -10, 0.5, 0); SideTimeLabel.Position = UDim2.new(0, 10, 0.5, -2); SideTimeLabel.BackgroundTransparency = 1; SideTimeLabel.Text = "TIME: --"; SideTimeLabel.TextColor3 = Color3.fromRGB(130, 130, 135); SideTimeLabel.Font = Enum.Font.GothamSemibold; SideTimeLabel.TextSize = 10; SideTimeLabel.TextXAlignment = Enum.TextXAlignment.Left

local Profile = Instance.new("Frame", Sidebar)
Profile.Size = UDim2.new(1, 0, 0, 55); Profile.Position = UDim2.new(0, 0, 1, -55); Profile.BackgroundTransparency = 1
local Avatar = Instance.new("ImageLabel", Profile); Avatar.Size = UDim2.new(0, 32, 0, 32); Avatar.Position = UDim2.new(0, 16, 0, 11); Avatar.Image = "rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=48&h=48"; Avatar.BackgroundColor3 = Color3.fromRGB(25, 25, 30); Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)
local PName = Instance.new("TextLabel", Profile); PName.Size = UDim2.new(1, -60, 0, 15); PName.Position = UDim2.new(0, 56, 0, 19); PName.BackgroundTransparency = 1; PName.Text = LocalPlayer.DisplayName; PName.TextColor3 = Color3.new(1, 1, 1); PName.Font = Enum.Font.GothamSemibold; PName.TextXAlignment = Enum.TextXAlignment.Left; PName.TextSize = 12

local TabContainer = Instance.new("Frame", Main)
TabContainer.Size = UDim2.new(1, -150, 1, 0); TabContainer.Position = UDim2.new(0, 150, 0, 0); TabContainer.BackgroundTransparency = 1
local TopTitle = Instance.new("TextLabel", TabContainer); TopTitle.Size = UDim2.new(1, -20, 0, 50); TopTitle.Position = UDim2.new(0, 20, 0, 0); TopTitle.BackgroundTransparency = 1; TopTitle.TextColor3 = Color3.new(1, 1, 1); TopTitle.Font = Enum.Font.GothamBold; TopTitle.TextSize = 16
local TopLine = Instance.new("Frame", TabContainer); TopLine.Size = UDim2.new(1, -40, 0, 1); TopLine.Position = UDim2.new(0, 20, 0, 48); TopLine.BackgroundColor3 = Color3.fromRGB(28, 28, 32); TopLine.BorderSizePixel = 0

local Pages, TabButtons = {}, {}
local function createTab(nameKey, yPos)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(0.85, 0, 0, 32); btn.Position = UDim2.new(0.075, 0, 0, yPos); btn.Font = Enum.Font.GothamSemibold; btn.TextColor3 = Color3.fromRGB(140, 140, 145); btn.TextXAlignment = Enum.TextXAlignment.Left; btn.TextSize = 11; btn.BackgroundColor3 = Color3.fromRGB(24, 24, 28); btn.BackgroundTransparency = 1; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    local bStroke = Instance.new("UIStroke", btn); bStroke.Color = Color3.fromRGB(35, 35, 40); bStroke.Enabled = false
    registerText(btn, nameKey, true)
    
    local page = Instance.new("ScrollingFrame", TabContainer)
    page.Size = UDim2.new(1, -30, 1, -70); page.Position = UDim2.new(0, 20, 0, 60); page.BackgroundTransparency = 1; page.ScrollBarThickness = 0; page.Visible = false
    Instance.new("UIListLayout", page).Padding = UDim.new(0, 8)
    
    table.insert(Pages, page); table.insert(TabButtons, btn)
    btn.MouseButton1Click:Connect(function()
        for i, p in pairs(Pages) do p.Visible = false; tween(TabButtons[i], {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(140, 140, 145)}, 0.15); TabButtons[i].UIStroke.Enabled = false end
        page.Visible = true; TopTitle.Text = Localization[currentLang][nameKey]; tween(btn, {BackgroundTransparency = 0, TextColor3 = Color3.new(1, 1, 1)}, 0.15); bStroke.Enabled = true
    end)
    return page
end

local MainTab = createTab("MainTab", 95)
local VisualsTab = createTab("VisualsTab", 135)
local SettingsTab = createTab("SettingsTab", 175)
MainTab.Visible = true; TabButtons[1].BackgroundTransparency = 0; TabButtons[1].TextColor3 = Color3.new(1, 1, 1); TabButtons[1].UIStroke.Enabled = true

local function updateActiveMods()
    if not ActiveListWidget then return end
    local str = ""
    for k, v in pairs(activeMods) do if v then str = str .. "• " .. k .. "\n" end end
    if str == "" then str = "Nothing active" end
    ActiveListText.Text = str
end

local function createToggle(parent, textKey, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.95, 0, 0, 40); frame.BackgroundColor3 = Color3.fromRGB(20, 20, 24); Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6); Instance.new("UIStroke", frame).Color = Color3.fromRGB(28, 28, 32)
    local label = Instance.new("TextLabel", frame); label.Size = UDim2.new(1, -60, 1, 0); label.Position = UDim2.new(0, 14, 0, 0); label.BackgroundTransparency = 1; label.TextColor3 = Color3.fromRGB(210, 210, 215); label.Font = Enum.Font.Gotham; label.TextXAlignment = Enum.TextXAlignment.Left; label.TextSize = 12; registerText(label, textKey)
    local switchBg = Instance.new("TextButton", frame); switchBg.Size = UDim2.new(0, 36, 0, 20); switchBg.Position = UDim2.new(1, -50, 0.5, -10); switchBg.Text = ""; switchBg.BackgroundColor3 = default and Color3.fromRGB(85, 85, 105) or Color3.fromRGB(32, 32, 38); Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)
    local switchDot = Instance.new("Frame", switchBg); switchDot.Size = UDim2.new(0, 16, 0, 16); switchDot.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8); switchDot.BackgroundColor3 = default and Color3.new(1, 1, 1) or Color3.fromRGB(150, 150, 155); Instance.new("UICorner", switchDot).CornerRadius = UDim.new(1, 0)
    
    local toggled = default
    local function updateVisuals()
        pcall(function() activeMods[Localization[currentLang][textKey]] = toggled end); updateActiveMods()
        if toggled then tween(switchDot, {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Color3.new(1, 1, 1)}, 0.15); tween(switchBg, {BackgroundColor3 = Color3.fromRGB(85, 85, 105)}, 0.15)
        else tween(switchDot, {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Color3.fromRGB(150, 150, 155)}, 0.15); tween(switchBg, {BackgroundColor3 = Color3.fromRGB(32, 32, 38)}, 0.15) end
    end
    switchBg.MouseButton1Click:Connect(function() toggled = not toggled; updateVisuals(); pcall(callback, toggled) end)
    return frame, function(val) toggled = val; updateVisuals() end
end

local function createAttachedSlider(parent, textKey, min, max, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.95, 0, 0, 44); frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22); Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6); Instance.new("UIStroke", frame).Color = Color3.fromRGB(26, 26, 30)
    local label = Instance.new("TextLabel", frame); label.Size = UDim2.new(0.6, 0, 0, 22); label.Position = UDim2.new(0, 14, 0, 2); label.BackgroundTransparency = 1; label.TextColor3 = Color3.fromRGB(150, 150, 155); label.Font = Enum.Font.Gotham; label.TextXAlignment = Enum.TextXAlignment.Left; label.TextSize = 11; registerText(label, textKey)
    local valLabel = Instance.new("TextLabel", frame); valLabel.Size = UDim2.new(0, 50, 0, 22); valLabel.Position = UDim2.new(1, -64, 0, 2); valLabel.BackgroundTransparency = 1; valLabel.Text = tostring(default); valLabel.TextColor3 = Color3.fromRGB(130, 130, 135); valLabel.Font = Enum.Font.GothamSemibold; valLabel.TextXAlignment = Enum.TextXAlignment.Right; valLabel.TextSize = 11
    local slideBg = Instance.new("TextButton", frame); slideBg.Size = UDim2.new(1, -28, 0, 4); slideBg.Position = UDim2.new(0, 14, 0, 28); slideBg.Text = ""; slideBg.BackgroundColor3 = Color3.fromRGB(32, 32, 38); Instance.new("UICorner", slideBg).CornerRadius = UDim.new(1, 0)
    local slideFill = Instance.new("Frame", slideBg); slideFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0); slideFill.BackgroundColor3 = Color3.fromRGB(95, 95, 115); Instance.new("UICorner", slideFill).CornerRadius = UDim.new(1, 0)
    local dragging = false
    local function update(input)
        local pos = math.clamp((input.Position.X - slideBg.AbsolutePosition.X) / slideBg.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + ((max - min) * pos))
        slideFill.Size = UDim2.new(pos, 0, 1, 0); valLabel.Text = tostring(val); pcall(callback, val)
    end
    slideBg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; update(i) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update(i) end end)
    return frame, function(value) slideFill.Size = UDim2.new(math.clamp((value - min) / (max - min), 0, 1), 0, 1, 0); valLabel.Text = tostring(value) end
end

local DragWidget = Instance.new("Frame", Screen)
DragWidget.Size = UDim2.new(0, 190, 0, 65); DragWidget.Position = UDim2.new(0.1, 0, 0.1, 0); DragWidget.BackgroundColor3 = Color3.fromRGB(12, 12, 14); DragWidget.Visible = false; Instance.new("UICorner", DragWidget).CornerRadius = UDim.new(0, 6)
local WidgetStroke = Instance.new("UIStroke", DragWidget); WidgetStroke.Color = Color3.fromRGB(30, 30, 35)
local WidgetTg = Instance.new("TextLabel", DragWidget); WidgetTg.Size = UDim2.new(1, 0, 0, 20); WidgetTg.Position = UDim2.new(0, 10, 0, 6); WidgetTg.BackgroundTransparency = 1; WidgetTg.Text = "t.me/LITEVISUALS_OFFCIAL"; WidgetTg.Font = Enum.Font.GothamBold; WidgetTg.TextSize = 10; WidgetTg.TextColor3 = Color3.fromRGB(90, 160, 255); WidgetTg.TextXAlignment = Enum.TextXAlignment.Left
local WidgetFps = Instance.new("TextLabel", DragWidget); WidgetFps.Size = UDim2.new(0.5, 0, 0, 18); WidgetFps.Position = UDim2.new(0, 10, 0, 26); WidgetFps.BackgroundTransparency = 1; WidgetFps.Text = "FPS: --"; WidgetFps.Font = Enum.Font.Gotham; WidgetFps.TextSize = 11; WidgetFps.TextColor3 = Color3.new(1,1,1); WidgetFps.TextXAlignment = Enum.TextXAlignment.Left
local WidgetPing = Instance.new("TextLabel", DragWidget); WidgetPing.Size = UDim2.new(0.5, 0, 0, 18); WidgetPing.Position = UDim2.new(0, 10, 0, 42); WidgetPing.BackgroundTransparency = 1; WidgetPing.Text = "PING: -- ms"; WidgetPing.Font = Enum.Font.Gotham; WidgetPing.TextSize = 11; WidgetPing.TextColor3 = Color3.fromRGB(180, 180, 185); WidgetPing.TextXAlignment = Enum.TextXAlignment.Left
makeDraggable(DragWidget, DragWidget)

ActiveListWidget = Instance.new("Frame", Screen)
ActiveListWidget.Size = UDim2.new(0, 160, 0, 120); ActiveListWidget.Position = UDim2.new(0.1, 0, 0.25, 0); ActiveListWidget.BackgroundColor3 = Color3.fromRGB(12, 12, 14); ActiveListWidget.BackgroundTransparency = 0.3; ActiveListWidget.Visible = false; Instance.new("UICorner", ActiveListWidget).CornerRadius = UDim.new(0, 6)
local ALStroke = Instance.new("UIStroke", ActiveListWidget); ALStroke.Color = Color3.fromRGB(50, 50, 55)
local ALTitle = Instance.new("TextLabel", ActiveListWidget); ALTitle.Size = UDim2.new(1, 0, 0, 25); ALTitle.BackgroundTransparency = 1; ALTitle.Font = Enum.Font.GothamBold; ALTitle.TextColor3 = Color3.fromRGB(90, 160, 255); ALTitle.TextSize = 11; registerText(ALTitle, "ActiveModsTitle")
ActiveListText = Instance.new("TextLabel", ActiveListWidget); ActiveListText.Size = UDim2.new(1, -20, 1, -30); ActiveListText.Position = UDim2.new(0, 10, 0, 25); ActiveListText.BackgroundTransparency = 1; ActiveListText.Font = Enum.Font.Gotham; ActiveListText.TextColor3 = Color3.new(1,1,1); ActiveListText.TextSize = 11; ActiveListText.TextXAlignment = Enum.TextXAlignment.Left; ActiveListText.TextYAlignment = Enum.TextYAlignment.Top
makeDraggable(ActiveListWidget, ActiveListWidget)

RunService.RenderStepped:Connect(function(dt)
    local fps = math.floor(1 / dt); SideFPSLabel.Text = "FPS: " .. fps; WidgetFps.Text = "FPS: " .. fps; SideTimeLabel.Text = "TIME: " .. os.date("%H:%M")
    local s, pingValue = pcall(function() return math.floor(Stats.Network.ServerToClientPing:GetValue() * 1000) end); WidgetPing.Text = "PING: " .. (s and pingValue or "0") .. " ms"
    if rgbEffectsEnabled then local rainbowColor = Color3.fromHSV((tick() % 4) / 4, 0.6, 1); MainStroke.Color = rainbowColor; WidgetStroke.Color = rainbowColor; ALStroke.Color = rainbowColor; StatusIndicator.BackgroundColor3 = rainbowColor
    else MainStroke.Color = Color3.fromRGB(32, 32, 36); WidgetStroke.Color = Color3.fromRGB(30, 30, 35); ALStroke.Color = Color3.fromRGB(50, 50, 55); StatusIndicator.BackgroundColor3 = Color3.fromRGB(75, 255, 100) end
end)

local orbitAngle = 0
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        if magnetEnabled then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local targetHrp = p.Character.HumanoidRootPart
                    targetHrp.Size = Vector3.new(magnetSize, magnetSize, magnetSize)
                    targetHrp.Transparency = 0.7
                    targetHrp.Material = Enum.Material.ForceField
                    targetHrp.CanCollide = false
                end
            end
        end
        if spinEnabled then hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0) end
        
        if flingEnabled then
            local target = nil
            local minDist = math.huge
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                    if dist < minDist then minDist = dist; target = p end
                end
            end
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                orbitAngle = orbitAngle + 0.6
                local tHrp = target.Character.HumanoidRootPart
                local offset = Vector3.new(math.cos(orbitAngle) * 2.5, 0, math.sin(orbitAngle) * 2.5)
                for _, part in pairs(char:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
                hrp.Velocity = Vector3.new(50000, 50000, 50000)
                hrp.CFrame = tHrp.CFrame + offset
            end
        end
    end
end)

local walkSlider, setWalk = createAttachedSlider(MainTab, "WalkSpeed", 16, 150, 16, function(val) walkSpeed = val; if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = val end end)
walkSlider.Visible = false; createToggle(MainTab, "Speedhack", false, function(state) walkSlider.Visible = state; if state then if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = walkSpeed end else if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = 16 end end end)

local flySlider, setFly = createAttachedSlider(MainTab, "FlySpeed", 20, 150, 50, function(val) flySpeed = val end)
flySlider.Visible = false; local flyLoop, keysPressed = nil, {}
createToggle(MainTab, "Fly", false, function(state)
    local char = LocalPlayer.Character; flySlider.Visible = state
    if state then
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local bv = Instance.new("BodyVelocity", char.HumanoidRootPart); bv.Name = "LVFlyBV"; bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        local bg = Instance.new("BodyGyro", char.HumanoidRootPart); bg.Name = "LVFlyBG"; bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9); bg.P = 9e4
        UserInputService.InputBegan:Connect(function(i, gp) if not gp then keysPressed[i.KeyCode] = true end end)
        UserInputService.InputEnded:Connect(function(i) keysPressed[i.KeyCode] = nil end)
        flyLoop = RunService.RenderStepped:Connect(function()
            if not char:FindFirstChild("HumanoidRootPart") or not bv.Parent then return end
            bg.CFrame = Camera.CFrame; local direction = Vector3.new(0, 0, 0)
            if keysPressed[Enum.KeyCode.W] then direction = direction + Camera.CFrame.LookVector end
            if keysPressed[Enum.KeyCode.S] then direction = direction - Camera.CFrame.LookVector end
            if keysPressed[Enum.KeyCode.A] then direction = direction - Camera.CFrame.RightVector end
            if keysPressed[Enum.KeyCode.D] then direction = direction + Camera.CFrame.RightVector end
            bv.Velocity = direction.Magnitude > 0 and direction.Unit * flySpeed or Vector3.new(0,0,0)
        end)
    else
        if flyLoop then flyLoop:Disconnect() end
        if char and char:FindFirstChild("HumanoidRootPart") then if char.HumanoidRootPart:FindFirstChild("LVFlyBV") then char.HumanoidRootPart.LVFlyBV:Destroy() end if char.HumanoidRootPart:FindFirstChild("LVFlyBG") then char.HumanoidRootPart.LVFlyBG:Destroy() end end
        keysPressed = {}
    end
end)

local spinSlider, setSpin = createAttachedSlider(MainTab, "SpinSpeed", 10, 150, 40, function(val) spinSpeed = val end)
spinSlider.Visible = false; createToggle(MainTab, "SpinBot", false, function(state) spinSlider.Visible = state; spinEnabled = state end)

local noclipLoop = nil; createToggle(MainTab, "Noclip", false, function(state) noclipEnabled = state; if noclipEnabled then noclipLoop = RunService.Stepped:Connect(function() if LocalPlayer.Character then for _, part in pairs(LocalPlayer.Character:GetChildren()) do if part:IsA("BasePart") then part.CanCollide = false end end end end) else if noclipLoop then noclipLoop:Disconnect() end end end)

createToggle(MainTab, "Fling", false, function(state) flingEnabled = state end)

local magnetSlider = createAttachedSlider(MainTab, "Magnet", 2, 50, 10, function(val) magnetSize = val end); magnetSlider.Visible = false; createToggle(MainTab, "Magnet", false, function(state) magnetEnabled = state; magnetSlider.Visible = state end)

local espFolder = Instance.new("Folder", Screen); espFolder.Name = "ESP"

local function checkMM2Role(player)
    local char = player.Character; local bp = player:FindFirstChild("Backpack")
    local isMurderer = (char and char:FindFirstChild("Knife")) or (bp and bp:FindFirstChild("Knife"))
    local isSheriff = (char and (char:FindFirstChild("Gun") or char:FindFirstChild("Revolver"))) or (bp and (bp:FindFirstChild("Gun") or bp:FindFirstChild("Revolver")))
    
    if isMurderer then return Color3.fromRGB(255, 0, 0), "MURDER" end 
    if isSheriff then return Color3.fromRGB(0, 0, 255), "SHERIFF" end 
    return nil, "INNOCENT"
end

local function applyESP(player)
    if player == LocalPlayer then return end
    local function init()
        local char = player.Character; if not char or espFolder:FindFirstChild(player.Name) then return end
        
        local high = Instance.new("Highlight", espFolder)
        high.Name = player.Name; high.Adornee = char; high.FillTransparency = 0.5; high.OutlineTransparency = 0
        
        local bill = Instance.new("BillboardGui", espFolder); bill.Name = player.Name.."_TXT"; bill.Adornee = char:WaitForChild("Head"); bill.Size = UDim2.new(0, 120, 0, 40); bill.StudsOffset = Vector3.new(0, 3, 0); bill.AlwaysOnTop = true
        local txt = Instance.new("TextLabel", bill); txt.Size = UDim2.new(1,0,1,0); txt.BackgroundTransparency = 1; txt.Font = Enum.Font.GothamBold; txt.TextSize = 10; txt.TextStrokeTransparency = 0; txt.TextColor3 = Color3.new(1,1,1)
        
        local c; c = RunService.RenderStepped:Connect(function()
            if not espEnabled or not char or not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0 then 
                c:Disconnect(); high:Destroy(); bill:Destroy(); return 
            end
            
            local color
            local mm2Color, role = checkMM2Role(player)
            
            if espMM2 and mm2Color then
                color = mm2Color
            else
                local t = tick()
                local wave = (math.sin(t * 2) + 1) / 2
                local purple = Color3.fromRGB(138, 43, 226)
                local cyan = Color3.fromRGB(0, 191, 255)
                color = purple:Lerp(cyan, wave)
            end
            
            high.FillColor = color
            high.OutlineColor = color
            
            local finalText = ""
            if espNames then finalText = player.Name .. "\n" end
            if espMM2 and role ~= "INNOCENT" then finalText = finalText .. "[" .. role .. "]" end
            
            txt.Text = finalText
            txt.TextColor3 = color
            bill.Enabled = (espNames or (espMM2 and role ~= "INNOCENT"))
        end)
    end
    player.CharacterAdded:Connect(init); if player.Character then init() end
end

createToggle(VisualsTab, "Esp", false, function(state) espEnabled = state; if state then for _, p in pairs(Players:GetPlayers()) do applyESP(p) end; Players.PlayerAdded:Connect(applyESP) else espFolder:ClearAllChildren() end end)
createToggle(VisualsTab, "EspNames", false, function(state) espNames = state end)
createToggle(VisualsTab, "EspMM2", false, function(state) espMM2 = state end)
createAttachedSlider(VisualsTab, "Fov", 70, 120, 70, function(val) Camera.FieldOfView = val end)

local defaultLighting = {Ambient = Lighting.Ambient, Brightness = Lighting.Brightness, GlobalShadows = Lighting.GlobalShadows}; local CC = Instance.new("ColorCorrectionEffect", Lighting); CC.Enabled = false; CC.Saturation = 0.3; CC.Contrast = 0.1; local Bloom = Instance.new("BloomEffect", Lighting); Bloom.Enabled = false; Bloom.Intensity = 0.3
createToggle(VisualsTab, "Graphics", false, function(state) graphicsEnabled = state; CC.Enabled = state; Bloom.Enabled = state; if state then Lighting.Ambient = Color3.fromRGB(150, 150, 150); Lighting.Brightness = 2; Lighting.GlobalShadows = true else Lighting.Ambient = defaultLighting.Ambient; Lighting.Brightness = defaultLighting.Brightness; Lighting.GlobalShadows = defaultLighting.GlobalShadows end end)

local LangFrame = Instance.new("Frame", SettingsTab); LangFrame.Size = UDim2.new(0.95, 0, 0, 40); LangFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24); Instance.new("UICorner", LangFrame).CornerRadius = UDim.new(0, 6); Instance.new("UIStroke", LangFrame).Color = Color3.fromRGB(28, 28, 32)
local LangBtn = Instance.new("TextButton", LangFrame); LangBtn.Size = UDim2.new(1, 0, 1, 0); LangBtn.BackgroundTransparency = 1; LangBtn.Font = Enum.Font.GothamBold; LangBtn.TextColor3 = Color3.fromRGB(90, 160, 255); LangBtn.TextSize = 12; registerText(LangBtn, "LangBtn")
LangBtn.MouseButton1Click:Connect(function() if currentLang == "RU" then updateLanguage("EN") else updateLanguage("RU") end; TopTitle.Text = Localization[currentLang][TabButtons[1].Visible and "MainTab" or "SettingsTab"]; updateActiveMods() end)

createToggle(SettingsTab, "Widget", false, function(state) DragWidget.Visible = state end); createToggle(SettingsTab, "ActiveList", false, function(state) ActiveListWidget.Visible = state end); createToggle(SettingsTab, "Rainbow", false, function(state) rgbEffectsEnabled = state end)

updateLanguage("RU"); TopTitle.Text = Localization[currentLang]["MainTab"]; updateActiveMods()

local function toggleMenu()
    if isMenuOpen then MainCanvas:TweenSize(UDim2.new(0, 520, 0, 0), "Out", "Quart", 0.3, true, function() MainCanvas.Visible = false end); isMenuOpen = false
    else MainCanvas.Visible = true; MainCanvas:TweenSize(UDim2.new(0, 520, 0, 330), "Out", "Back", 0.3, true); isMenuOpen = true end
end
UserInputService.InputBegan:Connect(function(i, gp) if not gp and i.KeyCode == Enum.KeyCode.LeftAlt then toggleMenu() end end)
print("Lite Visuals updated successfully.")
