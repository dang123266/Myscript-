local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Đảm bảo UI không bị mất khi reset nhân vật
local success, parentGui = pcall(function() return CoreGui end)
if not success then parentGui = Players.LocalPlayer:WaitForChild("PlayerGui") end

-- 1. Tạo giao diện Nút nổi
local gui = Instance.new("ScreenGui")
gui.Name = "AntiHorrorMod"
gui.ResetOnSpawn = false
gui.Parent = parentGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 55, 0, 55)
button.Position = UDim2.new(0.8, 0, 0.2, 0) -- Góc phải màn hình
button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.GothamBold
button.TextSize = 13
button.Text = "Sáng\nOFF"
button.Parent = gui

-- Làm nút hình tròn cho đẹp
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = button

-- 2. Biến điều khiển
local isEnabled = false
local loopConnection

-- 3. Hàm kích hoạt Ánh sáng & Kháng nhiễu
local function applyAntiHorror()
    if not isEnabled then return end
    
    -- A. Chỉnh độ sáng vừa đủ dịu mắt (Màu xám nhạt, không dùng trắng lóa 255)
    Lighting.Ambient = Color3.fromRGB(150, 150, 150) 
    Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 150)
    Lighting.Brightness = 1.2 
    Lighting.ClockTime = 12 
    Lighting.FogEnd = 999999 -- Xóa sương mù

    -- B. Kháng nhiễu: Tìm và tắt hết các hiệu ứng ảo giác, mờ, sọc màn hình
    local function removeNoise(parentObj)
        if not parentObj then return end
        for _, v in pairs(parentObj:GetDescendants()) do
            if v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") then
                v.Enabled = false
            end
        end
    end
    
    -- Quét nhiễu ở cả Lighting và Camera (nhiều game giấu hiệu ứng trong Camera)
    removeNoise(Lighting)
    removeNoise(workspace.CurrentCamera)
end

-- 4. Code Kéo Thả (Tối ưu riêng cho Cảm ứng điện thoại)
local dragging, dragInput, dragStart, startPos

button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = button.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

button.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- 5. Xử lý sự kiện khi ấn chạm vào nút
button.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    if isEnabled then
        -- Bật Mod
        button.Text = "Sáng\nON"
        button.BackgroundColor3 = Color3.fromRGB(0, 150, 0) -- Nút đổi sang màu xanh lá
        -- Khóa vòng lặp: Ép game không thể đổi màu lại
        loopConnection = RunService.RenderStepped:Connect(applyAntiHorror)
    else
        -- Tắt Mod
        button.Text = "Sáng\nOFF"
        button.BackgroundColor3 = Color3.fromRGB(40, 40, 40) -- Nút về lại màu xám đen
        if loopConnection then
            loopConnection:Disconnect()
        end
    end
end)

