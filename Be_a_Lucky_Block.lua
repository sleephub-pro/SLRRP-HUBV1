local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- [[ บริการและตัวแปรเริ่มต้น ]]
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- อ้างอิง Knit Services (จากสคริปต์เดิม)
local KnitPath = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services")
local RunningServiceRF = KnitPath:WaitForChild("RunningService"):WaitForChild("RF")
local PlayerServiceRF = KnitPath:WaitForChild("PlayerService"):WaitForChild("RF")
local ContainerServiceRF = KnitPath:WaitForChild("ContainerService"):WaitForChild("RF")

-- [[ สร้างหน้าต่าง GUI หลัก ]]
local Window = Fluent:CreateWindow({
    Title = "SLEEP HUB PROMAX (Fluent)",
    SubTitle = "Be a Lucky Block",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, 
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- [[ สร้างระบบไอคอนเปิด/ปิด (Floating Toggle Button) ]]
local function CreateToggleButton()
    local UserInputService = game:GetService("UserInputService")
    local ScreenGui = Instance.new("ScreenGui")
    local ToggleButton = Instance.new("ImageButton")
    local UICorner = Instance.new("UICorner")

    ScreenGui.Name = "FluentToggleGui"
    ScreenGui.Parent = game:GetService("CoreGui")
    
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Parent = ScreenGui
    ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ToggleButton.Position = UDim2.new(0.05, 0, 0.2, 0)
    ToggleButton.Size = UDim2.new(0, 60, 0, 60)
    ToggleButton.Image = "rbxassetid://113876946783161"
    
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = ToggleButton

    ToggleButton.MouseButton1Click:Connect(function()
        Window:Minimize()
    end)

    -- ลากปุ่มได้
    local dragging, dragInput, dragStart, startPos
    ToggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = ToggleButton.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            ToggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    ToggleButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end
CreateToggleButton()

-- [[ ตั้งค่า Tabs ]]
local Tabs = {
    Main = Window:AddTab({ Title = "Main Farm", Icon = "star" }),
    Extra = Window:AddTab({ Title = "Player Stats", Icon = "user" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- ===================== [ MAIN TAB ] =====================
do
    Tabs.Main:AddParagraph({ Title = "Auto Farm Section", Content = "ฟังก์ชันหลักสำหรับฟาร์ม Lucky Block" })

    -- 1. ออโต้ฟาร์ม (Warp)
    local MainEnabled = false
    local Distance1, Distance2 = -5, -5

    Tabs.Main:AddToggle("AutoFarmWarp", {Title = "ออโต้ฟาร์ม (Warp)", Default = false}):OnChanged(function(v)
        MainEnabled = v
    end)

    task.spawn(function()
        while true do
            if MainEnabled then
                local char = LocalPlayer.Character
                local line = workspace:FindFirstChild("Line")
                if char and char:FindFirstChild("HumanoidRootPart") and line and line:IsA("BasePart") then
                    char.HumanoidRootPart.CFrame = line.CFrame * CFrame.new(0, 0, Distance1)
                    task.wait(0.1)
                    char.HumanoidRootPart.CFrame = line.CFrame * CFrame.new(0, 0, Distance2)
                end
            end
            task.wait(0.1)
        end
    end)

    -- 2. ใช้คู่กับออโต้ฟาร์ม (Knit Remote)
    local KnitLoop = false
    Tabs.Main:AddToggle("KnitFarm", {Title = "ใช้คู่กับออโต้ฟาร์ม (Remote)", Default = false}):OnChanged(function(v)
        KnitLoop = v
        if v then
            task.spawn(function()
                while KnitLoop do
                    pcall(function()
                        RunningServiceRF.Collected:InvokeServer(tostring(LocalPlayer.UserId))
                        RunningServiceRF.OpenLuckyBlock:InvokeServer("base14")
                        RunningServiceRF.UpdateCFrame:InvokeServer(CFrame.new(-447.7, 53.1, -2105.2))
                    end)
                    task.wait(0.01)
                end
            end)
        end
    end)

    -- 3. มอนจับไม่ได้
    local AntiMob = false
    local savedProperties = {}
    Tabs.Main:AddToggle("AntiMob", {Title = "มอนจับไม่ได้", Default = false}):OnChanged(function(v)
        AntiMob = v
        if not v then
            for obj, props in pairs(savedProperties) do
                pcall(function()
                    if obj then obj.CanTouch = props.CanTouch; obj.CanQuery = props.CanQuery end
                end)
            end
            savedProperties = {}
        end
    end)

    task.spawn(function()
        while true do
            if AntiMob then
                local folder = workspace:FindFirstChild("BossTouchDetectors")
                if folder then
                    for _, obj in ipairs(folder:GetDescendants()) do
                        if obj:IsA("BasePart") then
                            if not savedProperties[obj] then
                                savedProperties[obj] = {CanTouch = obj.CanTouch, CanQuery = obj.CanQuery}
                            end
                            obj.CanTouch = false
                            obj.CanQuery = false
                        end
                    end
                end
            end
            task.wait(0.5)
        end
    end)

    -- 4. ใส่ตัวที่ดีที่สุด
    local AutoBest = false
    local BestDelay = 5
    Tabs.Main:AddToggle("AutoPlaceBest", {Title = "ใส่ตัวที่ดีที่สุด", Default = false}):OnChanged(function(v)
        AutoBest = v
    end)
    Tabs.Main:AddSlider("BestDelay", {Title = "ดีเลย์ใส่ตัว (วินาที)", Min = 0, Max = 60, Default = 5, Rounding = 1}):OnChanged(function(v)
        BestDelay = v
    end)

    task.spawn(function()
        while true do
            if AutoBest then
                pcall(function() ContainerServiceRF.PlaceBest:InvokeServer() end)
            end
            task.wait(BestDelay)
        end
    end)

    -- 5. อัพเกรดทั้งหมด
    local AutoUpgrade = false
    Tabs.Main:AddToggle("AutoUpgrade", {Title = "อัพทั้งหมด", Default = false}):OnChanged(function(v)
        AutoUpgrade = v
        if v then
            task.spawn(function()
                while AutoUpgrade do
                    for i = 1, 50 do
                        task.spawn(function() pcall(function() ContainerServiceRF.UpgradeBrainrot:InvokeServer(tostring(i)) end) end)
                    end
                    task.wait(0.1)
                end
            end)
        end
    end)

    -- 6. รีตัวละคร
    local AutoReload = false
    Tabs.Main:AddToggle("AutoReload", {Title = "รีตัวละครอัตโนมัติ", Default = false}):OnChanged(function(v)
        AutoReload = v
        if v then
            task.spawn(function()
                while AutoReload do
                    pcall(function() PlayerServiceRF.ReloadCharacter:InvokeServer() end)
                    task.wait(1)
                end
            end)
        end
    end)

    -- 7. ลดความแลค
    Tabs.Main:AddToggle("AntiLag", {Title = "ลดความแลค (ลบ RunningModels)", Default = false}):OnChanged(function(v)
        getgenv().AntiLag = v
        while getgenv().AntiLag do
            local folder = workspace:FindFirstChild("RunningModels")
            if folder then
                for _, obj in ipairs(folder:GetChildren()) do obj:Destroy() end
            end
            task.wait(0.1)
        end
    end)
end

-- ===================== [ EXTRA TAB ] =====================
do
    local walkEnabled, jumpEnabled = false, false
    local wsValue, jpValue = 16, 50

    local function updateStats()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            local hum = char.Humanoid
            hum.UseJumpPower = true
            hum.WalkSpeed = walkEnabled and wsValue or 16
            hum.JumpPower = jumpEnabled and jpValue or 50
        end
    end

    Tabs.Extra:AddSlider("WalkSpeed", {Title = "WalkSpeed", Min = 16, Max = 500, Default = 16, Rounding = 0}):OnChanged(function(v)
        wsValue = v; if walkEnabled then updateStats() end
    end)

    Tabs.Extra:AddToggle("WSEnabled", {Title = "เปิดใช้งาน WalkSpeed", Default = false}):OnChanged(function(v)
        walkEnabled = v; updateStats()
    end)

    Tabs.Extra:AddSlider("JumpPower", {Title = "JumpPower", Min = 50, Max = 500, Default = 50, Rounding = 0}):OnChanged(function(v)
        jpValue = v; if jumpEnabled then updateStats() end
    end)

    Tabs.Extra:AddToggle("JPEnabled", {Title = "เปิดใช้งาน JumpPower", Default = false}):OnChanged(function(v)
        jumpEnabled = v; updateStats()
    end)

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5); updateStats()
    end)
end

-- ===================== [ SETTINGS & SAVE ] =====================
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("SleepHubFluent")
SaveManager:SetFolder("SleepHubFluent/Configs")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()

Fluent:Notify({
    Title = "SLEEP HUB",
    Content = "สคริปต์โหลดเสร็จสมบูรณ์!",
    Duration = 5
})
