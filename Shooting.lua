-- NOVA HUB Premium: Speed / High Jump / Fly / No Clip
-- Neon menu with glow pulse, flash effect and ON/OFF labels.
-- Works in most games (R6 + R15).

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Settings (edit these if you want)
local SPEED_ON = 60
local JUMP_POWER_ON = 150
local JUMP_HEIGHT_ON = 50
local FLY_SPEED = 70

-- Colors
local PURPLE = Color3.fromRGB(150, 70, 255)
local CYAN = Color3.fromRGB(0, 210, 255)
local BG = Color3.fromRGB(14, 14, 24)
local ROW = Color3.fromRGB(26, 26, 42)
local ROW_ON = Color3.fromRGB(34, 28, 62)
local OFF_PILL = Color3.fromRGB(62, 62, 86)
local OFF_STROKE = Color3.fromRGB(48, 48, 72)
local GREY = Color3.fromRGB(120, 120, 150)

local state = {Speed = false, HighJump = false, Fly = false, NoClip = false}

local function getHumanoid()
    local char = player.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    local char = player.Character
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
end

---------------------------------------------------------------------
-- GUI parent (safest place your executor supports)
---------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "NovaHubPremium"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999

pcall(function()
    if syn and syn.protect_gui then syn.protect_gui(gui) end
end)

local parented = false
pcall(function()
    if gethui then
        local old = gethui():FindFirstChild("NovaHubPremium")
        if old then old:Destroy() end
        gui.Parent = gethui()
        parented = true
    end
end)
if not parented then
    pcall(function()
        local old = game:GetService("CoreGui"):FindFirstChild("NovaHubPremium")
        if old then old:Destroy() end
        gui.Parent = game:GetService("CoreGui")
        parented = true
    end)
end
if not parented then
    local pg = player:WaitForChild("PlayerGui")
    local old = pg:FindFirstChild("NovaHubPremium")
    if old then old:Destroy() end
    gui.Parent = pg
end

---------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------
local function corner(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = obj
    return c
end

local function stroke(obj, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = obj
    return s
end

local function gradient(obj, c1, c2, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c1, c2)
    g.Rotation = rotation or 0
    g.Parent = obj
    return g
end

local function tween(obj, time, props, style)
    local t = TweenService:Create(obj, TweenInfo.new(time, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

---------------------------------------------------------------------
-- Main window
---------------------------------------------------------------------
local WIDTH = 250
local FULL_HEIGHT = 296
local MINI_HEIGHT = 52

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, WIDTH, 0, 0)
frame.Position = UDim2.new(0, 20, 0.5, -FULL_HEIGHT / 2)
frame.BackgroundColor3 = BG
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Parent = gui
corner(frame, 14)
local frameStroke = stroke(frame, Color3.new(1, 1, 1), 1.6, 0.1)
local frameGradient = gradient(frameStroke, PURPLE, CYAN, 45)

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, -12, 0, 40)
header.Position = UDim2.new(0, 6, 0, 6)
header.BackgroundColor3 = Color3.new(1, 1, 1)
header.BorderSizePixel = 0
header.Parent = frame
corner(header, 10)
local headerGradient = gradient(header, PURPLE, CYAN, 0)

local logo = Instance.new("TextLabel")
logo.Size = UDim2.new(0, 30, 1, 0)
logo.Position = UDim2.new(0, 8, 0, 0)
logo.BackgroundTransparency = 1
logo.Text = "✦"
logo.TextColor3 = Color3.new(1, 1, 1)
logo.Font = Enum.Font.GothamBlack
logo.TextSize = 24
logo.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -90, 1, 0)
title.Position = UDim2.new(0, 38, 0, 0)
title.BackgroundTransparency = 1
title.Text = "NOVA HUB"
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBlack
title.TextSize = 18
title.Parent = header

local mini = Instance.new("TextButton")
mini.Size = UDim2.new(0, 28, 0, 28)
mini.Position = UDim2.new(1, -34, 0.5, -14)
mini.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mini.BackgroundTransparency = 0.6
mini.Text = "–"
mini.TextColor3 = Color3.new(1, 1, 1)
mini.Font = Enum.Font.GothamBold
mini.TextSize = 18
mini.BorderSizePixel = 0
mini.AutoButtonColor = false
mini.Parent = header
corner(mini, 8)

-- Slowly rotating gradients (premium shimmer)
RunService.RenderStepped:Connect(function()
    local r = (tick() * 40) % 360
    frameGradient.Rotation = r
    headerGradient.Rotation = (r * 0.5) % 360
end)

-- Dragging (mouse + touch)
do
    local dragging, dragStart, startPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Body
local body = Instance.new("Frame")
body.Size = UDim2.new(1, 0, 1, -52)
body.Position = UDim2.new(0, 0, 0, 52)
body.BackgroundTransparency = 1
body.Parent = frame

local minimized = false
local function setMinimized(v)
    minimized = v
    mini.Text = v and "+" or "–"
    if v then
        body.Visible = false
        tween(frame, 0.22, {Size = UDim2.new(0, WIDTH, 0, MINI_HEIGHT)})
    else
        tween(frame, 0.22, {Size = UDim2.new(0, WIDTH, 0, FULL_HEIGHT)})
        task.delay(0.1, function() body.Visible = true end)
    end
end
mini.MouseButton1Click:Connect(function() setMinimized(not minimized) end)

-- PC: RightShift hides / shows the menu
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then
        gui.Enabled = not gui.Enabled
    end
end)

-- Footer
local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, 0, 0, 18)
footer.Position = UDim2.new(0, 0, 1, -22)
footer.BackgroundTransparency = 1
footer.Text = "tap a row to toggle"
footer.TextColor3 = GREY
footer.Font = Enum.Font.Gotham
footer.TextSize = 12
footer.Parent = body

---------------------------------------------------------------------
-- Toggle rows: switch + ON/OFF label + glow pulse + flash
---------------------------------------------------------------------
local function makeToggle(icon, label, key, y, onToggle)
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, -20, 0, 46)
    row.Position = UDim2.new(0, 10, 0, y)
    row.BackgroundColor3 = ROW
    row.Text = ""
    row.AutoButtonColor = false
    row.BorderSizePixel = 0
    row.ClipsDescendants = true
    row.Parent = body
    corner(row, 10)
    local rowStroke = stroke(row, OFF_STROKE, 1.2, 0)

    local ic = Instance.new("TextLabel")
    ic.Size = UDim2.new(0, 30, 1, 0)
    ic.Position = UDim2.new(0, 8, 0, 0)
    ic.BackgroundTransparency = 1
    ic.Text = icon
    ic.TextSize = 18
    ic.Font = Enum.Font.GothamBold
    ic.TextColor3 = GREY
    ic.Parent = row

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, -150, 1, 0)
    txt.Position = UDim2.new(0, 40, 0, 0)
    txt.BackgroundTransparency = 1
    txt.Text = label
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.TextColor3 = Color3.fromRGB(210, 210, 230)
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 15
    txt.Parent = row

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0, 34, 1, 0)
    status.Position = UDim2.new(1, -96, 0, 0)
    status.BackgroundTransparency = 1
    status.Text = "OFF"
    status.TextColor3 = GREY
    status.Font = Enum.Font.GothamBlack
    status.TextSize = 12
    status.Parent = row

    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0, 44, 0, 22)
    pill.Position = UDim2.new(1, -54, 0.5, -11)
    pill.BackgroundColor3 = OFF_PILL
    pill.BorderSizePixel = 0
    pill.Parent = row
    corner(pill, 11)
    local pillGlow = stroke(pill, CYAN, 1.5, 1)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(0, 2, 0.5, -9)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.Parent = pill
    corner(knob, 9)

    -- white flash that fades out when switched on
    local flash = Instance.new("Frame")
    flash.Size = UDim2.new(1, 0, 1, 0)
    flash.BackgroundColor3 = Color3.new(1, 1, 1)
    flash.BackgroundTransparency = 1
    flash.BorderSizePixel = 0
    flash.ZIndex = 5
    flash.Active = false
    flash.Parent = row
    corner(flash, 10)

    local pulse -- looping glow tween while ON

    row.MouseButton1Click:Connect(function()
        state[key] = not state[key]
        local on = state[key]

        tween(knob, 0.2, {Position = on and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}, Enum.EasingStyle.Back)
        tween(pill, 0.2, {BackgroundColor3 = on and CYAN or OFF_PILL})
        tween(row, 0.2, {BackgroundColor3 = on and ROW_ON or ROW})
        tween(ic, 0.2, {TextColor3 = on and CYAN or GREY})
        tween(txt, 0.2, {TextColor3 = on and Color3.new(1, 1, 1) or Color3.fromRGB(210, 210, 230)})
        tween(pillGlow, 0.2, {Transparency = on and 0.35 or 1})

        status.Text = on and "ON" or "OFF"
        tween(status, 0.2, {TextColor3 = on and CYAN or GREY})

        if pulse then pulse:Cancel() pulse = nil end
        if on then
            -- flash
            flash.BackgroundTransparency = 0.65
            tween(flash, 0.4, {BackgroundTransparency = 1})
            -- glowing border that gently pulses while ON
            rowStroke.Color = PURPLE
            rowStroke.Thickness = 1.6
            rowStroke.Transparency = 0.05
            pulse = TweenService:Create(
                rowStroke,
                TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
                {Transparency = 0.55}
            )
            pulse:Play()
        else
            rowStroke.Thickness = 1.2
            tween(rowStroke, 0.2, {Color = OFF_STROKE, Transparency = 0})
        end

        if onToggle then onToggle(on) end
    end)
end

---------------------------------------------------------------------
-- Fly helpers
---------------------------------------------------------------------
local flyBV, flyBG

local function stopFly()
    if flyBV then flyBV:Destroy() flyBV = nil end
    if flyBG then flyBG:Destroy() flyBG = nil end
    local hum = getHumanoid()
    if hum then hum.PlatformStand = false end
end

local function startFly()
    local root = getRoot()
    local hum = getHumanoid()
    if not root or not hum then return end
    if flyBV then flyBV:Destroy() end
    if flyBG then flyBG:Destroy() end

    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBV.Velocity = Vector3.zero
    flyBV.Parent = root

    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBG.P = 9e4
    flyBG.CFrame = root.CFrame
    flyBG.Parent = root

    hum.PlatformStand = true
end

---------------------------------------------------------------------
-- Rows
---------------------------------------------------------------------
makeToggle("»", "Speed", "Speed", 4)
makeToggle("▲", "High Jump", "HighJump", 56)
makeToggle("✈", "Fly", "Fly", 108, function(on)
    if on then startFly() else stopFly() end
end)
makeToggle("◌", "No Clip", "NoClip", 160)

---------------------------------------------------------------------
-- Main loops: keep everything applied even if the game resets it
---------------------------------------------------------------------
local defaults = setmetatable({}, {__mode = "k"})
local applied = {Speed = false, HighJump = false}

RunService.Heartbeat:Connect(function()
    local hum = getHumanoid()
    if not hum then return end

    if not defaults[hum] then
        defaults[hum] = {
            speed = hum.WalkSpeed,
            power = hum.JumpPower,
            height = hum.JumpHeight,
        }
    end
    local d = defaults[hum]

    if state.Speed then
        hum.WalkSpeed = SPEED_ON
        applied.Speed = true
    elseif applied.Speed then
        hum.WalkSpeed = d.speed
        applied.Speed = false
    end

    if state.HighJump then
        hum.JumpPower = JUMP_POWER_ON
        hum.JumpHeight = JUMP_HEIGHT_ON
        applied.HighJump = true
    elseif applied.HighJump then
        hum.JumpPower = d.power
        hum.JumpHeight = d.height
        applied.HighJump = false
    end

    if state.Fly then
        local root = getRoot()
        if root and (not flyBV or not flyBV.Parent or flyBV.Parent ~= root) then
            startFly()
        end
        if not hum.PlatformStand then hum.PlatformStand = true end
    end
end)

RunService.RenderStepped:Connect(function()
    if not state.Fly or not flyBV or not flyBG then return end
    local hum = getHumanoid()
    local camera = workspace.CurrentCamera
    if not hum or not camera then return end

    local md = hum.MoveDirection
    local look = camera.CFrame.LookVector
    local vel = Vector3.zero

    if md.Magnitude > 0 then
        -- move where you walk; look up/down to climb or dive (works on mobile)
        local flat = Vector3.new(look.X, 0, look.Z)
        local forward = flat.Magnitude > 0 and md:Dot(flat.Unit) or 0
        vel = md * FLY_SPEED + Vector3.new(0, look.Y * forward * FLY_SPEED, 0)
    end

    -- PC: Space = up, Left Shift = down
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        vel += Vector3.new(0, FLY_SPEED, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        vel -= Vector3.new(0, FLY_SPEED, 0)
    end

    flyBV.Velocity = vel
    flyBG.CFrame = CFrame.new(Vector3.zero, Vector3.new(look.X, 0, look.Z))
end)

RunService.Stepped:Connect(function()
    if not state.NoClip then return end
    local char = player.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
end)

player.CharacterRemoving:Connect(function()
    if flyBV then flyBV:Destroy() flyBV = nil end
    if flyBG then flyBG:Destroy() flyBG = nil end
end)

-- Open animation
tween(frame, 0.35, {Size = UDim2.new(0, WIDTH, 0, FULL_HEIGHT)})







