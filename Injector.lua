local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')
local Workspace = game:GetService('Workspace')

local LocalPlayer = Players.LocalPlayer

-- 1. FETCH EXTERNAL DATABASE (SECRET GIST)
local skinDbUrl = "https://gist.githubusercontent.com/Clide01/4e7b2abdb007ab6714c5eae2a2c4c63a/raw/f9635dc5d41af3de167e32b785fee9f33704adaf/Skins_Database.lua" .. "?t=" .. tostring(tick())
local SkinDB = loadstring(game:HttpGet(skinDbUrl))()

-- 2. INITIALIZE GLOBAL STATE
getgenv().VisualSpooferState = {
    PrimaryBase = "AWP",
    PrimaryTarget = SkinDB.PrimarySkins[1],
    MeleeBase = "Wakizashi",
    MeleeTarget = SkinDB.MeleeSkins[1],
    IsHooked = false
}

-- 3. BUILD UI WITH COMMERCIAL KEY INTERFACE
local Window = Rayfield:CreateWindow({
    Name = "Modular Arsenal Spoofer",
    LoadingTitle = "Loading Commercial Master...",
    LoadingSubtitle = "by Clide01",
    ConfigurationSaving = { Enabled = false },
    KeySystem = true, -- Forced Active
    KeySettings = {
        Title = "Key Verification System",
        Subtitle = "Daily Ad-Link Gateway",
        Note = "Complete the ads to generate today's master key.",
        FileName = "ClideSpooferKeyConfig", 
        SaveKey = false, -- Automatically caches key in user's workspace folder
        GrabKeyFromUrl = true, 
        Key = {"https://pastebin.com/raw/6aje5Kp8"}, -- CHANGE THIS to your secret master key
        Url = "https://controlc.com/xbazx9pa" -- CHANGE THIS to your monetization link
    }
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

-- 4. INJECT ENGINE & NETWORK HOOKS
Tab:CreateSection("Execution")

Tab:CreateButton({Name="Initialize Master Hooks (Run Once)",Callback=function()
    if getgenv().VisualSpooferState.IsHooked then 
        Rayfield:Notify({Title="Already Hooked!",Content="Update dropdowns and reset character to apply changes!",Duration=4})
        return 
    end

    -- Inventory Image Render Crash Patch
    local oldNewIndex
    oldNewIndex = hookmetamethod(game, "__newindex", function(t, k, v)
        if not checkcaller() and k == "Image" and typeof(v) == "Instance" then v = "rbxassetid://0" end
        return oldNewIndex(t, k, v)
    end)

    -- In-Place Remote Argument Scrubber
    local function DeepMaskTable(tbl, state)
        for k, v in pairs(tbl) do
            if type(v) == "string" then
                if v == state.PrimaryTarget then tbl[k] = state.PrimaryBase
                elseif v == state.MeleeTarget then tbl[k] = state.MeleeBase end
            elseif type(v) == "table" then DeepMaskTable(v, state) end
        end
    end

    -- Network Masking Hook (Prevents server-side inventory verification kicks)
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
                    elseif type(v) == "table" then 
                        DeepMaskTable(args[i], state) 
                    end
                end
            end
            return oldNamecall(self, unpack(args))
        end
        return oldNamecall(self, ...)
    end)

    -- Stable Client OOP Engine Override
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

                            if self._IsEnemyWeaponBrand or not self._IsLocalWeaponBrand then
                                return originalMethod(self, arg1, ...)
                            end
                            
                            local state = getgenv().VisualSpooferState
                            local spoofedArg = arg1

                            if type(arg1) == "string" then 
                                if string.find(arg1, state.PrimaryBase) then spoofedArg = state.PrimaryTarget 
                                elseif string.find(arg1, state.MeleeBase) then spoofedArg = state.MeleeTarget end 
                            end
                            
                            if self.Name then 
                                if string.find(self.Name, state.PrimaryBase) or self.Name == state.PrimaryTarget then 
                                    self.Skin = state.PrimaryTarget
                                    self.Name = state.PrimaryTarget 
                                    if self.WeaponName then self.WeaponName = state.PrimaryTarget end
                                elseif string.find(self.Name, state.MeleeBase) or self.Name == state.MeleeTarget then 
                                    self.Skin = state.MeleeTarget
                                    self.Name = state.MeleeTarget 
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
    else 
        Rayfield:Notify({Title="Error",Content="Could not hook target environment classes.",Duration=5}) 
    end 
end})

Rayfield:Init()