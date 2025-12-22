local WindUI

do
    local ok, result = pcall(function()
        return require("./src/Init")
    end)
    
    if ok then
        WindUI = result
    else 
        WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
    end
end

function createPopup()
    return WindUI:Popup({
        Title = "Welcome to the WindUI!",
        Icon = "bird",
        Content = "การใช้สคลิปไม่ปลอดภัย ใช้อย่างระมัดระวังด้วยนะครับ",
        Buttons = {
            {
                Title = "เข้าใจแล้ว",
                Icon = "bird",
            },
        }
    })
end



-- */  Window  /* --
local Window = WindUI:CreateWindow({
    Title = "SLEEP HUB PRO MAX",
    Author = "by .ftgs • Footagesus",
    Folder = "ftgshub",
    Icon = "rbxassetid://121030902371363",
    IconSize = 22*2,
    NewElements = true,
    --Size = UDim2.fromOffset(700,700),
    
    HideSearchBar = false,
    
    OpenButton = {
        Title = " SLEEP HIB UI", -- can be changed
        CornerRadius = UDim.new(1,0), -- fully rounded
        StrokeThickness = 3, -- removing outline
        Enabled = true, -- enable or disable openbutton
        Draggable = true,
        OnlyMobile = false,
        
        Color = ColorSequence.new( -- gradient
            Color3.fromHex("#30FF6A"), 
            Color3.fromHex("#e7ff2f")
        )
    },
})










local Tab = Window:Tab({
    Title = "หนัาหลัก",
    Icon = "bird", -- optional
    Locked = false,
})









local Toggle = Tab:Toggle({
    Title = "ออโต้ยิง (ปกติ)",
    Desc = "",
    Icon = "bird",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)

        --------------------------------------------------
        --// SERVICES
        --------------------------------------------------
        local Players = game:GetService("Players")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local player = Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()

        --------------------------------------------------
        --// PATH
        --------------------------------------------------
        local WorldSea = workspace:WaitForChild("WorldSea")
        local ToolFolder = workspace:WaitForChild("Zoogo1001")
        local FireRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("FireRE")

        --------------------------------------------------
        --// CONFIG
        --------------------------------------------------
        local RANGE = 300
        local FIRE_DELAY = 0.1

        --------------------------------------------------
        --// STATE
        --------------------------------------------------
        local ScriptEnabled = state
        local Billboard

        --------------------------------------------------
        --// TOOL CHECK
        --------------------------------------------------
        local function getAllTools()
            for _,v in pairs(ToolFolder:GetDescendants()) do
                if v:IsA("Tool") then
                    v.Parent = player.Backpack
                end
            end
        end

        --------------------------------------------------
        --// FIND NEAREST TARGET
        --------------------------------------------------
        local function getNearestTarget()
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if not hrp then return nil end

            local nearest, dist = nil, RANGE
            for _,sea in pairs(WorldSea:GetChildren()) do
                for _,obj in pairs(sea:GetChildren()) do
                    if obj:IsA("BasePart") then
                        local d = (obj.Position - hrp.Position).Magnitude
                        if d <= dist then
                            dist = d
                            nearest = obj
                        end
                    end
                end
            end
            return nearest
        end

        --------------------------------------------------
        --// BILLBOARD
        --------------------------------------------------
        local function showBillboard(target)
            if Billboard then Billboard:Destroy() end
            if not target then return end

            Billboard = Instance.new("BillboardGui")
            Billboard.Size = UDim2.new(0,150,0,40)
            Billboard.StudsOffset = Vector3.new(0,2,0)
            Billboard.AlwaysOnTop = true
            Billboard.Adornee = target

            local label = Instance.new("TextLabel", Billboard)
            label.Size = UDim2.new(1,0,1,0)
            label.BackgroundTransparency = 0.2
            label.BackgroundColor3 = Color3.fromRGB(120,80,255)
            label.Text = "🎯 ยิง : "..target.Name
            label.TextColor3 = Color3.new(1,1,1)
            label.TextScaled = true
            label.Font = Enum.Font.GothamBold

            Billboard.Parent = target
        end

        --------------------------------------------------
        --// FIRE LOOP
        --------------------------------------------------
        task.spawn(function()
            getAllTools()
            while task.wait(FIRE_DELAY) do
                if not ScriptEnabled then
                    if Billboard then Billboard:Destroy() end
                    break
                end

                local target = getNearestTarget()
                if target then
                    showBillboard(target)

                    local tool = player.Character:FindFirstChildOfClass("Tool")
                    if tool then
                        FireRemote:FireServer(
                            "Hit",
                            {
                                fishInstance = target,
                                HitPos = target.Position,
                                toolInstance = tool
                            }
                        )
                    end
                end
            end
        end)
    end
})



















local OldPos = nil -- ตัวแปรเก็บค่าตำแหน่งเดิม

local Toggle = Tab:Toggle({
    Title = "ออโต้ยิง (วาปใต้ดิน)",
    Desc = "",
    Icon = "bird",
    Type = "Checkbox",
    Value = false,
    Callback = function(state) 
        _G.ScriptEnabled = state 

        local Players = game:GetService("Players")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local player = Players.LocalPlayer
        
        local WorldSea = workspace:WaitForChild("WorldSea")
        local ToolFolder = workspace:WaitForChild("Zoogo1001")
        local FireRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("FireRE")

        local FIRE_DELAY = 0.1

        --// ฟังก์ชันล็อคตัว/ปลดล็อค
        local function toggleFreeze(character, isLocked)
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            -- ลบของเก่า
            for _, v in pairs(hrp:GetChildren()) do
                if v.Name == "FreezeVelocity" or v.Name == "FreezeGyro" then
                    v:Destroy()
                end
            end

            if isLocked then
                local bv = Instance.new("BodyVelocity", hrp)
                bv.Name = "FreezeVelocity"
                bv.Velocity = Vector3.new(0, 0, 0)
                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)

                local bg = Instance.new("BodyGyro", hrp)
                bg.Name = "FreezeGyro"
                bg.CFrame = hrp.CFrame
                bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            end
        end

        --------------------------------------------------
        --// เริ่มทำงาน
        --------------------------------------------------
        if _G.ScriptEnabled then
            -- 1. บันทึกตำแหน่งปัจจุบันก่อนเริ่มวาร์ป
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                OldPos = player.Character.HumanoidRootPart.CFrame
            end

            task.spawn(function()
                while _G.ScriptEnabled do
                    local character = player.Character
                    local hrp = character and character:FindFirstChild("HumanoidRootPart")
                    
                    -- ค้นหาเป้าหมาย
                    local target = nil
                    local dist = math.huge
                    for _, sea in pairs(WorldSea:GetChildren()) do
                        for _, obj in pairs(sea:GetChildren()) do
                            if obj:IsA("BasePart") then
                                local d = (obj.Position - (hrp and hrp.Position or Vector3.zero)).Magnitude
                                if d < dist then
                                    dist = d
                                    target = obj
                                end
                            end
                        end
                    end

                    if hrp and target then
                        -- ล็อคตัวให้นิ่ง
                        if not hrp:FindFirstChild("FreezeVelocity") then
                            toggleFreeze(character, true)
                        end

                        -- วาร์ปไปใต้เป้าหมาย 15 หน่วย
                        hrp.CFrame = CFrame.new(target.Position + Vector3.new(0, -15, 0))

                        -- เช็คอาวุธและยิง
                        local tool = character:FindFirstChildOfClass("Tool")
                        if not tool then
                            for _, v in pairs(ToolFolder:GetDescendants()) do
                                if v:IsA("Tool") then v.Parent = character break end
                            end
                        else
                            FireRemote:FireServer("Hit", {
                                fishInstance = target,
                                HitPos = target.Position,
                                toolInstance = tool
                            })
                        end
                    end
                    task.wait(FIRE_DELAY)
                end
            end)
        else
            --// เมื่อกดปิด (OFF)
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                -- 1. ปลดล็อคตัวละครให้นิ่ง
                toggleFreeze(player.Character, false)
                
                -- 2. วาร์ปกลับจุดเดิม (ถ้ามีค่าที่บันทึกไว้)
                if OldPos then
                    player.Character.HumanoidRootPart.CFrame = OldPos
                end
            end
        end
    end
})










-- Auto-collect UIDs + Auto-sell example
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- CONFIG
local SELL_INTERVAL = 1            -- วินาทีระหว่างการส่งคำสั่งขาย (ปรับถ้าจำเป็น)
local FILTER_BY_NAME = "Fish"      -- ถ้าอยากกรองเฉพาะไอเท็มที่ชื่อมีคำนี้ (set = nil to disable)
local ONLY_TOOLS = true            -- ถ้าเป็น true จะเลือกแค่ Tools (มักเป็นกรณีไอเท็มใน Backpack)
local VERBOSE = true               -- ถ้า true จะพิมพ์ผลที่ console (debug)

-- ฟังก์ชันช่วย: ตรวจว่าสตริงเป็น UID (เลขยาวๆ)
local function isUIDString(s)
	if type(s) ~= "string" then return false end
	return s:match("^%d+$") and #s >= 6 -- ปรับความยาวขั้นต่ำได้
end

-- ฟังก์ชันช่วย: ลองหา UID ใน Instance (Attribute / StringValue / child with common names / instance.Name)
local function findUIDInInstance(inst)
	-- check attribute
	local ok, attr = pcall(function() return inst:GetAttribute("UID") end)
	if ok and attr and isUIDString(tostring(attr)) then return tostring(attr) end

	-- check common attribute names
	local commonAttrs = {"ID","ItemId","UniqueId","UIDValue"}
	for _, a in ipairs(commonAttrs) do
		local ok2, val = pcall(function() return inst:GetAttribute(a) end)
		if ok2 and val and isUIDString(tostring(val)) then return tostring(val) end
	end

	-- check child StringValue/IntValue/Value objects
	for _, child in ipairs(inst:GetChildren()) do
		local cn = child.Name:lower()
		if (cn == "uid" or cn == "id" or cn == "itemid" or cn == "uniqueid" or cn == "uidvalue" or cn == "idvalue") then
			if child:IsA("StringValue") then
				local v = child.Value
				if isUIDString(v) then return v end
			elseif child:IsA("IntValue") or child:IsA("NumberValue") then
				local v = tostring(child.Value)
				if isUIDString(v) then return v end
			end
		end
		-- ถ้า child เองมี attribute UID
		local ok3, attr2 = pcall(function() return child:GetAttribute("UID") end)
		if ok3 and attr2 and isUIDString(tostring(attr2)) then return tostring(attr2) end
	end

	-- check instance name (บางเกมตั้งชื่อเป็นเลข UID)
	if isUIDString(inst.Name) then return inst.Name end

	-- not found
	return nil
end

-- ฟังก์ชันหลัก: ดึง UID จากแหล่งข้อมูลที่เป็นไปได้
local function collectUIDs()
	local uids = {}
	local seen = {}

	-- ช่วยเพิ่ม UID ถ้าพบ
	local function addUID(u)
		if not u or u == "" then return end
		if not seen[u] then
			seen[u] = true
			table.insert(uids, u)
		end
	end

	-- ตรวจพื้นที่มาตรฐานหลายที่ (Backpack, Character, player.Inventory, PlayerFolder)
	local containers = {}

	-- Backpack
	if player:FindFirstChild("Backpack") then table.insert(containers, player.Backpack) end
	-- Character
	if player.Character then table.insert(containers, player.Character) end
	-- บางเกมเก็บ Inventory ใน Player.Inventory หรือ Player:FindFirstChild("Inventory")
	if player:FindFirstChild("Inventory") then table.insert(containers, player.Inventory) end
	-- บางเกมเก็บใน folder ชื่อ "FolderItems" / "Items" / "Bag" / "Data"
	for _, n in ipairs({"Items","Bag","FolderItems","PlayerItems","Data","Storage"}) do
		if player:FindFirstChild(n) then table.insert(containers, player[n]) end
	end

	-- workspace หรืออื่น ๆ ที่เกมอาจเก็บ
	-- ตัวอย่าง: workspace:WaitForChild("DroppedItems") (ไม่บังคับใส่ แต่เราจะค้นใน workspace ใกล้ๆ player)
	if workspace:FindFirstChild(player.Name .. "_Inventory") then
		table.insert(containers, workspace[player.Name .. "_Inventory"])
	end

	-- scan each container
	for _, cont in ipairs(containers) do
		for _, item in ipairs(cont:GetChildren()) do
			-- ถ้าต้องการเฉพาะ Tools
			if ONLY_TOOLS then
				if item:IsA("Tool") or item.ClassName == "Tool" then
					-- try to find uid
					local u = findUIDInInstance(item)
					if u then
						-- optional name filter
						if not FILTER_BY_NAME or item.Name:lower():find(FILTER_BY_NAME:lower()) then
							addUID(u)
						end
					end
				end
			else
				-- ไม่จำกัด type
				local u = findUIDInInstance(item)
				if u then
					if not FILTER_BY_NAME or item.Name:lower():find(FILTER_BY_NAME:lower()) then
						addUID(u)
					end
				end
			end
		end
	end

	-- บางเกมเก็บ UID ไว้ใน PlayerGui หรือ ReplicatedStorage (ตัวเลือกเพิ่มเติม)
	-- ตัวอย่าง: ตรวจ PlayerGui children ที่อาจเป็นรายการ
	if player:FindFirstChild("PlayerGui") then
		for _, g in ipairs(player.PlayerGui:GetChildren()) do
			for _, item in ipairs(g:GetChildren()) do
				local u = findUIDInInstance(item)
				if u then addUID(u) end
			end
		end
	end

	-- คืนค่าเป็น table ของ string UIDs
	if VERBOSE then
		print("[AutoSell] Collected UIDs:", #uids)
		for i, v in ipairs(uids) do print(" -", i, v) end
	end

	return uids
end

-- ฟังก์ชันส่งขาย
local function sellUIDs(uids)
	if not uids or #uids == 0 then return end
	local args = {
		"SellAll",
		{
			UIDs = uids
		}
	}
	-- pcall ป้องกัน error
	pcall(function()
		local remotes = ReplicatedStorage:FindFirstChild("Remotes")
		if remotes and remotes:FindFirstChild("FishRE") then
			remotes.FishRE:FireServer(unpack(args))
			if VERBOSE then print("[AutoSell] Fired SellAll with", #uids, "UIDs") end
		else
			warn("[AutoSell] Remote 'Remotes/FishRE' not found")
		end
	end)
end

-- Toggle logic (ใช้กับ Tab:Toggle)
local selling = false
local sellLoop

local function startAutoSell()
	if selling then return end
	selling = true

	sellLoop = task.spawn(function()
		while selling do
			local collected = collectUIDs()
			if #collected > 0 then
				sellUIDs(collected)
			end
			task.wait(SELL_INTERVAL)
		end
	end)
end

local function stopAutoSell()
	selling = false
	if sellLoop then
		-- sellLoop will naturally stop; nil it for cleanliness
		sellLoop = nil
	end
end

-- ตัวอย่างการเชื่อม Toggle (แทนที่ Tab ด้วย UI ของคุณ)
local Toggle = Tab:Toggle({
	Title = "ออโต้ขายปลา",
	Desc = "",
	Icon = "bird",
	Type = "Checkbox",
	Value = false,
	Callback = function(state)
		if state then
			startAutoSell()
		else
			stopAutoSell()
		end
	end
})













local Players = game:GetService("Players")
local player = Players.LocalPlayer

local Slider = Tab:Slider({
    Title = "Speed",
    Desc = "ปรับความเร็วในการเดิน",
    Step = 1, -- ปรับทีละ 1
    Value = {
        Min = 20,
        Max = 120,
        Default = 70,
    },
    Callback = function(value)
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = value
        end
    end
})








local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local running = false

local function StartLoop()
    task.spawn(function()
        while running do
            task.wait(0.01)

            local gui = player:FindFirstChild("PlayerGui")
            if not gui then continue end

            local screenUser = gui:FindFirstChild("ScreenUser")
            if not screenUser then continue end

            local skillFolder = screenUser:FindFirstChild("Skill")
            if not skillFolder then continue end

            for _, v in ipairs(skillFolder:GetChildren()) do
                -- 🔍 ตรวจชื่อ Skill + ตัวเลข
                if string.match(v.Name, "^Skill%d+$") then
                    local args = {
                        "Skill",
                        {
                            ID = v.Name
                        }
                    }

                    ReplicatedStorage
                        :WaitForChild("Remotes")
                        :WaitForChild("FishRE")
                        :FireServer(unpack(args))
                end
            end
        end
    end)
end
local Toggle = Tab:Toggle({
    Title = "Auto Skill",
    Desc = "ตรวจ Skill + ตัวเลข แล้วยิงอัตโนมัติ",
    Icon = "bird",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        running = state
        if state then
            StartLoop()
        end
    end
})
