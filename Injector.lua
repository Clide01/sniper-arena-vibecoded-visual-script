-- ==============================================================================
-- ZHUB-STYLE DYNAMIC GATEWAY (HWID-LOCKED + 24H AUTOMATED EXPIRATION)
-- Features: Device Binding, Unique Dynamic Keys, Modern Dark UI, Auto-Clipboard
-- ==============================================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- 1. EXTRACT DEVICE HWID (Unique per PC/Mobile Device)
local DeviceHWID = RbxAnalyticsService:GetClientId()

-- 2. YOUR CONFIGURATION (Replace with your Platoboost/KeyAuth details)
local ServiceID = "24469" -- Replace with your Service ID
local GatewayBaseUrl = "https://platoboost.com/getkey/" .. ServiceID .. "?hwid=" .. DeviceHWID
local VerifyApiUrl = "https://platoboost.com/api/verify?id=" .. ServiceID .. "&hwid=" .. DeviceHWID .. "&key="

-- 3. BUILD THE MODERN UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModernDynamicGateway"
ScreenGui.Parent = (CoreGui:FindFirstChild("RobloxGui") and CoreGui) or LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 220)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(45, 45, 55)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "ARSENAL SPOOFER"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, 0, 0, 20)
Subtitle.Position = UDim2.new(0, 0, 0, 40)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Device-Bound 24h Key System"
Subtitle.TextColor3 = Color3.fromRGB(120, 120, 140)
Subtitle.TextSize = 12
Subtitle.Font = Enum.Font.Gotham
Subtitle.Parent = MainFrame

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(0, 310, 0, 42)
KeyInput.Position = UDim2.new(0.5, -155, 0, 80)
KeyInput.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.PlaceholderText = "Paste your 24h key here..."
KeyInput.Text = ""
KeyInput.TextSize = 13
KeyInput.Font = Enum.Font.Gotham
KeyInput.Parent = MainFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 8)
InputCorner.Parent = KeyInput

local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Size = UDim2.new(0, 148, 0, 40)
GetKeyBtn.Position = UDim2.new(0, 25, 0, 145)
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
GetKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GetKeyBtn.Text = "Get Key (Work.ink)"
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.TextSize = 13
GetKeyBtn.Parent = MainFrame

local GetKeyCorner = Instance.new("UICorner")
GetKeyCorner.CornerRadius = UDim.new(0, 8)
GetKeyCorner.Parent = GetKeyBtn

local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Size = UDim2.new(0, 148, 0, 40)
VerifyBtn.Position = UDim2.new(0, 187, 0, 145)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 132, 255)
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.Text = "Verify Device Key"
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.TextSize = 13
VerifyBtn.Parent = MainFrame

local VerifyCorner = Instance.new("UICorner")
VerifyCorner.CornerRadius = UDim.new(0, 8)
VerifyCorner.Parent = VerifyBtn

-- 4. BUTTON HANDLERS
GetKeyBtn.MouseButton1Click:Connect(function()
    setclipboard(GatewayBaseUrl)
    GetKeyBtn.Text = "Link Copied!"
    task.wait(2)
    GetKeyBtn.Text = "Get Key (Work.ink)"
end)

VerifyBtn.MouseButton1Click:Connect(function()
    local userKey = string.gsub(KeyInput.Text, "^%s*(.-)%s*$", "%1")
    if userKey == "" then
        VerifyBtn.Text = "Enter Key First!"
        task.wait(1.5)
        VerifyBtn.Text = "Verify Device Key"
        return
    end

    VerifyBtn.Text = "Authenticating..."
    
    -- API Call to check HWID + Key validity
    local responseSuccess, responseBody = pcall(function()
        return game:HttpGet(VerifyApiUrl .. userKey)
    end)

    if responseSuccess then
        -- Expecting JSON response like {"valid": true} from the Key Service
        local decodeSuccess, data = pcall(function()
            return HttpService:JSONDecode(responseBody)
        end)

        if decodeSuccess and data.valid == true then
            VerifyBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 90)
            VerifyBtn.Text = "Key Valid!"
            task.wait(1)
            ScreenGui:Destroy()
            LoadMasterSpoofer()
        else
            VerifyBtn.BackgroundColor3 = Color3.fromRGB(210, 40, 40)
            VerifyBtn.Text = "Invalid / Expired"
            task.wait(2)
            VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 132, 255)
            VerifyBtn.Text = "Verify Device Key"
        end
    else
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(210, 40, 40)
        VerifyBtn.Text = "Server Error"
        task.wait(2)
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 132, 255)
        VerifyBtn.Text = "Verify Device Key"
    end
end)

-- 5. MAIN SPOOFER INJECTION
function LoadMasterSpoofer()
    -- [Insert your obfuscated/clean V85 Main Spoofer code here]
    print("[SYSTEM] Key verified successfully for HWID: " .. DeviceHWID)
end
