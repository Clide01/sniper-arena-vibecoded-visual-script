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
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

-- 1. YOUR MONETIZATION & VERIFICATION LINKS
local GatewayLink = "https://work.ink/2K1W/tuesday" 
local VerifierLink = "https://pastebin.com/raw/u6L2iNec" 

-- 2. BUILD THE MODERN CUSTOM UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModernKeyGateway"
ScreenGui.Parent = (CoreGui:FindFirstChild("RobloxGui") and CoreGui) or Players.LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 200)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "ARSENAL PREMIUM SPOOFER"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, 0, 0, 20)
Subtitle.Position = UDim2.new(0, 0, 0, 35)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Please authenticate to continue."
Subtitle.TextColor3 = Color3.fromRGB(150, 150, 150)
Subtitle.TextSize = 12
Subtitle.Font = Enum.Font.Gotham
Subtitle.Parent = MainFrame

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(0, 300, 0, 40)
KeyInput.Position = UDim2.new(0.5, -150, 0, 75)
KeyInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.PlaceholderText = "Enter your daily key here..."
KeyInput.Text = ""
KeyInput.TextSize = 14
KeyInput.Font = Enum.Font.Gotham
KeyInput.Parent = MainFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 6)
InputCorner.Parent = KeyInput

local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Size = UDim2.new(0, 140, 0, 35)
GetKeyBtn.Position = UDim2.new(0, 25, 0, 140)
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
GetKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GetKeyBtn.Text = "Get Key"
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.TextSize = 14
GetKeyBtn.Parent = MainFrame

local GetKeyCorner = Instance.new("UICorner")
GetKeyCorner.CornerRadius = UDim.new(0, 6)
GetKeyCorner.Parent = GetKeyBtn

local CheckKeyBtn = Instance.new("TextButton")
CheckKeyBtn.Size = UDim2.new(0, 140, 0, 35)
CheckKeyBtn.Position = UDim2.new(0, 185, 0, 140)
CheckKeyBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
CheckKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CheckKeyBtn.Text = "Verify Key"
CheckKeyBtn.Font = Enum.Font.GothamBold
CheckKeyBtn.TextSize = 14
CheckKeyBtn.Parent = MainFrame

local CheckKeyCorner = Instance.new("UICorner")
CheckKeyCorner.CornerRadius = UDim.new(0, 6)
CheckKeyCorner.Parent = CheckKeyBtn

-- 3. GATEWAY LOGIC
GetKeyBtn.MouseButton1Click:Connect(function()
    setclipboard(GatewayLink)
    GetKeyBtn.Text = "Link Copied!"
    task.wait(2)
    GetKeyBtn.Text = "Get Key"
end)

CheckKeyBtn.MouseButton1Click:Connect(function()
    CheckKeyBtn.Text = "Checking..."
    local success, currentDailyKey = pcall(function()
        return game:HttpGet(VerifierLink)
    end)
    
    -- Trim any accidental spaces or hidden line breaks from Pastebin
    currentDailyKey = string.gsub(currentDailyKey, "^%s*(.-)%s*$", "%1")
    local userInput = string.gsub(KeyInput.Text, "^%s*(.-)%s*$", "%1")
    
    if success and userInput == currentDailyKey then
        CheckKeyBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        CheckKeyBtn.Text = "Success!"
        task.wait(1)
        ScreenGui:Destroy()
        LoadMasterSpoofer() -- Boot the main script
    else
        CheckKeyBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        CheckKeyBtn.Text = "Invalid Key"
        task.wait(2)
        CheckKeyBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
        CheckKeyBtn.Text = "Verify Key"
    end
end)

function LoadMasterSpoofer()
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    local ReplicatedStorage = game:GetService('ReplicatedStorage')
    local Workspace = game:GetService('Workspace')

    local skinDbUrl = "https://gist.githubusercontent.com/Clide01/4e7b2abdb007ab6714c5eae2a2c4c63a/raw/f9635dc5d41af3de167e32b785fee9f33704adaf/Skins_Database.lua" .. "?t=" .. tostring(tick())
    local SkinDB = loadstring(game:HttpGet(skinDbUrl))()

    getgenv().VisualSpooferState = {
        PrimaryBase = "AWP", PrimaryTarget = SkinDB.PrimarySkins[1],
        MeleeBase = "ClassKnife", MeleeTarget = SkinDB.MeleeSkins[1],
        IsHooked = false
    }

    local Window = Rayfield:CreateWindow({
        Name = "Modular Arsenal Spoofer",
        LoadingTitle = "Authenticating Premium...",
        LoadingSubtitle = "by Clide01",
        ConfigurationSaving = { Enabled = false },
        KeySystem = false -- Disabled because our Custom Gateway handled it!
    })

    local Tab = Window:CreateTab("Arsenal Spoofer")

    Tab:CreateSection("Primary Weapon")
    Tab:CreateDropdown({Name="Equipped Primary (Base)",Options=SkinDB.PrimaryBases,CurrentOption={getgenv().VisualSpooferState.PrimaryBase},MultipleOptions=false,Callback=function(Options) getgenv().VisualSpooferState.PrimaryBase = Options[1] end})
    local PrimaryDropdown 
    Tab:CreateInput({Name="Search Primary Skins",PlaceholderText="Type to filter...",Callback=function(Text)
           local filtered = {}
           for _, skin in ipairs(SkinDB.PrimarySkins) do if string.find(string.lower(skin), string.lower(Text)) then table.insert(filtered, skin) end end
           if #filtered == 0 then table.insert(filtered, "No Results") end
           if PrimaryDropdown then PrimaryDropdown:Refresh(filtered, true) end
    end})
    PrimaryDropdown = Tab:CreateDropdown({Name="Target Primary (Skin)",Options=SkinDB.PrimarySkins,CurrentOption={getgenv().VisualSpooferState.PrimaryTarget},MultipleOptions=false,Callback=function(Options) if Options[1] ~= "No Results" then getgenv().VisualSpooferState.PrimaryTarget = Options[1] end end})

    Tab:CreateSection("Melee Weapon")
    Tab:CreateDropdown({Name="Equipped Melee (Base)",Options=SkinDB.MeleeBases,CurrentOption={getgenv().VisualSpooferState.MeleeBase},MultipleOptions=false,Callback=function(Options) getgenv().VisualSpooferState.MeleeBase = Options[1] end})
    local MeleeDropdown
    Tab:CreateInput({Name="Search Melee Skins",PlaceholderText="Type to filter...",Callback=function(Text)
           local filtered = {}
           for _, skin in ipairs(SkinDB.MeleeSkins) do if string.find(string.lower(skin), string.lower(Text)) then table.insert(filtered, skin) end end
           if #filtered == 0 then table.insert(filtered, "No Results") end
           if MeleeDropdown then MeleeDropdown:Refresh(filtered, true) end
    end})
    MeleeDropdown = Tab:CreateDropdown({Name="Target Melee (Skin)",Options=SkinDB.MeleeSkins,CurrentOption={getgenv().VisualSpooferState.MeleeTarget},MultipleOptions=false,Callback=function(Options) if Options[1] ~= "No Results" then getgenv().VisualSpooferState.MeleeTarget = Options[1] end end})

    Tab:CreateSection("Execution")
    Tab:CreateButton({Name="Initialize Master Hooks (Run Once)",Callback=function()
        if getgenv().VisualSpooferState.IsHooked then 
            Rayfield:Notify({Title="Already Hooked!",Content="Update dropdowns and reset character to apply changes!",Duration=4})
            return 
        end

        local oldNewIndex
        oldNewIndex = hookmetamethod(game, "__newindex", function(t, k, v)
            if not checkcaller() and k == "Image" and typeof(v) == "Instance" then v = "rbxassetid://0" end
            return oldNewIndex(t, k, v)
        end)

        local function DeepMaskTable(tbl, state)
            for k, v in pairs(tbl) do
                if type(v) == "string" then
                    if v == state.PrimaryTarget then tbl[k] = state.PrimaryBase
                    elseif v == state.MeleeTarget then tbl[k] = state.MeleeBase end
                elseif type(v) == "table" then DeepMaskTable(v, state) end
            end
        end

        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
                local args = {...}
                local state = getgenv().VisualSpooferState
                if state and state.IsHooked then
                    for i, v in ipairs(args) do
                        if type(v) == "string" then
                            if v == state.PrimaryTarget then args[i] = state.PrimaryBase
                            elseif v == state.MeleeTarget then args[i] = state.MeleeBase end
                        elseif type(v) == "table" then DeepMaskTable(args[i], state) end
                    end
                end
                return oldNamecall(self, unpack(args))
            end
            return oldNamecall(self, ...)
        end)

        local weaponModule = ReplicatedStorage.Client['WeaponController']:WaitForChild('Weapon')
        local targets = {weaponModule, weaponModule:FindFirstChild('Gun'), weaponModule:FindFirstChild('Melee')}
        local hooksApplied = 0
        local targetMethods = {'SetSkin', '_loadModel', '_setupModel', 'LoadSkinedAssets', 'PlaySound', '_playSound'}
        
        for _, moduleInstance in ipairs(targets) do 
            if moduleInstance then 
                local success, ClassTable = pcall(require, moduleInstance)
                if success and type(ClassTable) == "table" then 
                    for _, methodName in ipairs(targetMethods) do 
                        if type(ClassTable[methodName]) == "function" and not ClassTable["_H"..methodName] then 
                            ClassTable["_H"..methodName] = true
                            local originalMethod = ClassTable[methodName]
                            
                            ClassTable[methodName] = function(self, arg1, ...) 
                                for _, arg in pairs({arg1, ...}) do 
                                    if type(arg) == "string" then
                                        if string.find(arg, "ThirdPerson") or string.find(arg, "Carry") then self._IsEnemyWeaponBrand = true 
                                        elseif string.find(arg, "FirstPerson") then self._IsLocalWeaponBrand = true end
                                    end
                                end

                                if not self._IsEnemyWeaponBrand and not self._IsLocalWeaponBrand then
                                    local weaponModel = self.Model or self.model or self.Instance or self.WeaponModel
                                    if typeof(weaponModel) == "Instance" and weaponModel:IsDescendantOf(Workspace.CurrentCamera) then self._IsLocalWeaponBrand = true end
                                    if self.IsLocal == true or self.isLocal == true or self.IsFirstPerson == true then self._IsLocalWeaponBrand = true end
                                end

                                if self._IsEnemyWeaponBrand or not self._IsLocalWeaponBrand then return originalMethod(self, arg1, ...) end
                                
                                local state = getgenv().VisualSpooferState
                                local spoofedArg = arg1

                                if type(arg1) == "string" then 
                                    if string.find(arg1, state.PrimaryBase) then spoofedArg = state.PrimaryTarget 
                                    elseif string.find(arg1, state.MeleeBase) then spoofedArg = state.MeleeTarget end 
                                end
                                
                                if self.Name then 
                                    if string.find(self.Name, state.PrimaryBase) or self.Name == state.PrimaryTarget then 
                                        self.Skin = state.PrimaryTarget; self.Name = state.PrimaryTarget 
                                        if self.WeaponName then self.WeaponName = state.PrimaryTarget end
                                    elseif string.find(self.Name, state.MeleeBase) or self.Name == state.MeleeTarget then 
                                        self.Skin = state.MeleeTarget; self.Name = state.MeleeTarget 
                                        if self.WeaponName then self.WeaponName = state.MeleeTarget end
                                    end 
                                end
                                
                                return originalMethod(self, spoofedArg, ...)
                            end
                            hooksApplied = hooksApplied + 1 
                        end 
                    end 
                end 
            end 
        end
        
        if hooksApplied > 0 then 
            getgenv().VisualSpooferState.IsHooked = true
            Rayfield:Notify({Title="Stable Master Initialized!",Content="Visual textures, particles, and custom SFX loaded.",Duration=6}) 
        end 
    end})

    Rayfield:Init()
end
    print("[SYSTEM] Key verified successfully for HWID: " .. DeviceHWID)
end
