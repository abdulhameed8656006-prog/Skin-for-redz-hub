-- NLOX Neon Skin
-- Recolors a hub's UI at runtime (neon colors + soft glow on buttons).
-- Run this FIRST, then run the hub. It only skins UIs that appear after it starts.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Settings (edit if you want)
local GLOW_THICKNESS = 1.5        -- bigger = stronger glow
local GLOW_TRANSPARENCY = 0.45    -- smaller = stronger glow
local HOVER_TRANSPARENCY = 0.15
local PLAYERGUI_WINDOW = 120      -- seconds PlayerGui UIs are skinned after start

local CYAN = Color3.fromRGB(0, 230, 255)
local PURPLE = Color3.fromRGB(170, 80, 255)

local startTime = tick()

local skip = setmetatable({}, {__mode = "k"})
local done = setmetatable({}, {__mode = "k"})

---------------------------------------------------------------------
-- Color helpers
---------------------------------------------------------------------
local function neonColor(c)
    local h, s, v = c:ToHSV()
    -- white-ish (text) stays as it is
    if v > 0.8 and s < 0.2 then
        return c
    end
    -- bright / colorful -> neon (hues squeezed into cyan..purple)
    if s > 0.3 and v > 0.35 then
        return Color3.fromHSV(0.5 + h * 0.28, 0.85, math.max(v, 0.9))
    end
    -- dark / grey -> same brightness with a purple-navy tint
    return Color3.fromHSV(0.72, math.clamp(s + 0.35, 0, 0.6), v)
end

local function mapSequence(seq)
    local pts = {}
    for _, k in ipairs(seq.Keypoints) do
        table.insert(pts, ColorSequenceKeypoint.new(k.Time, neonColor(k.Value)))
    end
    return ColorSequence.new(pts)
end

---------------------------------------------------------------------
-- Glow (a soft neon outline)
---------------------------------------------------------------------
local function addGlow(obj, color, thickness, transparency)
    if obj:FindFirstChild("NloxGlow") then return end
    local s = Instance.new("UIStroke")
    s.Name = "NloxGlow"
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Color = color
    s.Thickness = thickness
    s.Transparency = transparency
    s.Parent = obj
    return s
end

---------------------------------------------------------------------
-- Style one element
---------------------------------------------------------------------
local function style(obj)
    if done[obj] or not obj.Parent then return end
    done[obj] = true

    pcall(function()
        if obj:IsA("GuiObject") and obj.BackgroundTransparency < 1 then
            obj.BackgroundColor3 = neonColor(obj.BackgroundColor3)
        end

        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            obj.TextColor3 = neonColor(obj.TextColor3)
        end

        if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
            local _, s = obj.ImageColor3:ToHSV()
            if s > 0.3 then
                obj.ImageColor3 = neonColor(obj.ImageColor3)
            end
        end

        if obj:IsA("ScrollingFrame") then
            obj.ScrollBarImageColor3 = CYAN
        end

        if obj:IsA("UIStroke") and obj.Name ~= "NloxGlow" then
            obj.Color = neonColor(obj.Color)
        end

        if obj:IsA("UIGradient") then
            obj.Color = mapSequence(obj.Color)
        end

        -- soft glow on buttons
        if (obj:IsA("TextButton") or obj:IsA("ImageButton")) and obj.BackgroundTransparency < 1 then
            local glow = addGlow(obj, CYAN, GLOW_THICKNESS, GLOW_TRANSPARENCY)
            if glow then
                obj.MouseEnter:Connect(function()
                    TweenService:Create(glow, TweenInfo.new(0.15), {Transparency = HOVER_TRANSPARENCY}):Play()
                end)
                obj.MouseLeave:Connect(function()
                    TweenService:Create(glow, TweenInfo.new(0.2), {Transparency = GLOW_TRANSPARENCY}):Play()
                end)
            end
        end

        -- soft glow around the main window
        if obj:IsA("Frame") and obj.Parent:IsA("ScreenGui")
            and (obj.Size.X.Offset > 200 or obj.Size.X.Scale > 0.2) then
            addGlow(obj, PURPLE, 2, 0.55)
        end
    end)
end

local function skinGui(gui)
    if skip[gui] or not gui:IsA("ScreenGui") then return end
    for _, d in ipairs(gui:GetDescendants()) do
        task.defer(style, d)
    end
    gui.DescendantAdded:Connect(function(d)
        task.defer(style, d)
    end)
end

---------------------------------------------------------------------
-- Watch for new UIs
---------------------------------------------------------------------
local containers = {}
pcall(function()
    if gethui then table.insert(containers, {gethui(), false}) end
end)
pcall(function()
    table.insert(containers, {game:GetService("CoreGui"), false})
end)
pcall(function()
    table.insert(containers, {player:WaitForChild("PlayerGui"), true})
end)

for _, entry in ipairs(containers) do
    local container, limited = entry[1], entry[2]
    -- everything that already exists is left alone
    for _, g in ipairs(container:GetChildren()) do
        skip[g] = true
    end
    container.ChildAdded:Connect(function(child)
        if limited and (tick() - startTime) > PLAYERGUI_WINDOW then return end
        task.defer(skinGui, child)
    end)
end

print("[NLOX] Neon skin active. Run your hub now.")







