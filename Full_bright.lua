local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- Lưu trạng thái gốc an toàn
local originalValues = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    Atmosphere = nil,
    Effects = {}
}

-- Hàm lưu trạng thái Atmosphere
local function saveAtmos()
    local atmos = Lighting:FindFirstChildOfClass("Atmosphere")
    if atmos then
        originalValues.Atmosphere = {Density = atmos.Density, Haze = atmos.Haze}
    end
end

-- 1. Tạo Giao diện
local gui = Instance.new("ScreenGui")
gui.Name = "AntiHorrorGui"
gui.ResetOnSpawn = false
gui.Parent = (CoreGui:FindFirstChild("RobloxGui") and CoreGui.RobloxGui) or CoreGui

local btn = Instance.new("TextButton")
btn.Name = "ToggleButton"
btn.Size = UDim2.new(0, 60, 0, 60)
btn.Position = UDim2.new(0.8, 0, 0.2, 0)
btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
btn.Text = "Sáng\nOFF"
btn.TextColor3 = Color3.new(1,1,1)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 12
btn.Parent = gui

Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

-- 2. Logic xử lý chính
local isActive = false

local function setEffect(enabled)
    if enabled then
        saveAtmos()
        -- Lưu các effect hiện tại để tắt
        for _, v in pairs(Lighting:GetDescendants()) do
            if v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("SunRaysEffect") then
                originalValues.Effects[v] = v.Enabled
                v.Enabled = false
            end
        end
    else
        -- Phục hồi
        Lighting.Ambient = originalValues.Ambient
        Lighting.OutdoorAmbient = originalValues.OutdoorAmbient
        Lighting.Brightness = originalValues.Brightness
        Lighting.ClockTime = originalValues.ClockTime
        Lighting.FogEnd = originalValues.FogEnd
        
        local atmos = Lighting:FindFirstChildOfClass("Atmosphere")
        if atmos and originalValues.Atmosphere then
            atmos.Density = originalValues.Atmosphere.Density
            atmos.Haze = originalValues.Atmosphere.Haze
        end
        
        for v, state in pairs(originalValues.Effects) do
            if v and v.Parent then v.Enabled = state end
        end
        originalValues.Effects = {}
    end
end

-- Vòng lặp chống "Anti-cheat" của game
RunService.RenderStepped:Connect(function()
    if isActive then
        pcall(function()
            Lighting.Ambient = Color3.fromRGB(150, 150, 150)
            Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 150)
            Lighting.Brightness = 1.5
            Lighting.ClockTime = 14
            Lighting.FogEnd = 999999
            
            local atmos = Lighting:FindFirstChildOfClass("Atmosphere")
            if atmos then
                atmos.Density = 0
                atmos.Haze = 0
            end
        end)
    end
end)

-- 3. Sự kiện
btn.MouseButton1Click:Connect(function()
    isActive = not isActive
    btn.Text = isActive and "Sáng\nON" or "Sáng\nOFF"
    btn.BackgroundColor3 = isActive and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 40)
    setEffect(isActive)
end)

-- Code kéo thả
local dragging, dragStart, startPos
btn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = btn.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
