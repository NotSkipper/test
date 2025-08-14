local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local noclipConnection -- to store the connection
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local Window = Rayfield:CreateWindow({
   Name = "Mango Hub -- Steal A Youtuber",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Steal A Youtuber",
   LoadingSubtitle = "by Covarun",
   ShowText = "Script", -- for mobile users to unhide rayfield, change if you'd like
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Mangoe Hub"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

local Tab = Window:CreateTab("Main", 0) -- Title, Image

local Toggle = Tab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Flag = "Toggle1",
   Callback = function(Value)
       if Value then
           -- Enable noclip
           noclipConnection = RunService.Stepped:Connect(function()
               if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                   for _, part in pairs(player.Character:GetDescendants()) do
                       if part:IsA("BasePart") then
                           part.CanCollide = false
                       end
                   end
               end
           end)
       else
           -- Disable noclip
           if noclipConnection then
               noclipConnection:Disconnect()
               noclipConnection = nil
           end
           -- Restore CanCollide to true (optional)
           if player.Character then
               for _, part in pairs(player.Character:GetDescendants()) do
                   if part:IsA("BasePart") then
                       part.CanCollide = true
                   end
               end
           end
       end
   end,
})

local TweenService = game:GetService("TweenService")
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- Adjust this to get the correct player's base
local base = workspace:WaitForChild("Bases"):WaitForChild("BaseTemplate") -- Change this if needed

local isCollecting = false

-- Function to check if a slot is occupied
local function isSlotOccupied(slot)
    local config = slot:FindFirstChild("Configuration")
    if config then
        local occupied = config:FindFirstChild("Occupied")
        return occupied and occupied:IsA("BoolValue") and occupied.Value
    end
    return false
end

-- Function to tween to a position
local function tweenTo(position)
    local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(position)})
    tween:Play()
    tween.Completed:Wait()
end

-- Get all slots from all floors
local function getAllSlots()
    local allSlots = {}

    -- Floor 1 (base): has Slots directly
    local floor1Slots = base:FindFirstChild("Slots")
    if floor1Slots then
        for _, slot in pairs(floor1Slots:GetChildren()) do
            table.insert(allSlots, slot)
        end
    end

    -- Floors 2 and 3: Slots inside Piso2 and Piso3
    for _, floorName in pairs({"Piso2", "Piso3"}) do
        local floor = base:FindFirstChild(floorName)
        if floor then
            local slots = floor:FindFirstChild("Slots")
            if slots then
                for _, slot in pairs(slots:GetChildren()) do
                    table.insert(allSlots, slot)
                end
            end
        end
    end

    return allSlots
end

-- Main loop function
local function collectLoop()
    while isCollecting do
        local allSlots = getAllSlots()
        for _, slot in pairs(allSlots) do
            if isSlotOccupied(slot) then
                local collectPart = slot:FindFirstChild("Collect")
                if collectPart then
                    tweenTo(collectPart.Position + Vector3.new(0, 5, 0))
                    wait(1.5) -- Wait to ensure touch registers
                end
            end
        end
        for i = 1, 120 do -- Wait 2 minutes, can be interrupted
            if not isCollecting then break end
            wait(1)
        end
    end
end

-- Rayfield Toggle UI
Tab:CreateToggle({
    Name = "Auto Collect Cash",
    CurrentValue = false,
    Flag = "AutoCollectCash",
    Callback = function(state)
        isCollecting = state
        if state then
            spawn(collectLoop)
        end
    end,
})

local instantEnabled = false

-- Function to make all prompts instant
local function setPromptsInstant(state)
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            prompt.HoldDuration = state and 0 or 1 -- 0 for instant, 1 is default
        end
    end
end

-- Optional: Keep listening for newly added prompts
workspace.DescendantAdded:Connect(function(descendant)
    if instantEnabled and descendant:IsA("ProximityPrompt") then
        descendant.HoldDuration = 0
    end
end)

-- Rayfield toggle (attach to your Tab/UI)
Tab:CreateToggle({
    Name = "Instant Interact (No Hold)",
    CurrentValue = false,
    Flag = "InstantInteractToggle",
    Callback = function(state)
        instantEnabled = state
        setPromptsInstant(state)
    end,
})

local Button = Tab:CreateButton({
    Name = "Enable Anti Idle",
    Callback = function()
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer

        local GC = getconnections or get_signal_cons
        if GC then
            for _, v in pairs(GC(player.Idled)) do
                if v["Disable"] then
                    v["Disable"](v)
                elseif v["Disconnect"] then
                    v["Disconnect"](v)
                end
            end
        else
            local VirtualUser = cloneref(game:GetService("VirtualUser"))
            player.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end

        -- Rayfield notification
        Rayfield:Notify({
            Title = "Anti Idle",
            Content = "Anti Idle has been enabled. You won't get kicked for being afk.",
            Duration = 6.5,
            Image = 4483362458,
        })
    end,
})

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local Bases = workspace:WaitForChild("Bases")

local instantEnabled = true

local function setPromptsInstant(state)
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            prompt.HoldDuration = state and 0 or 1
        end
    end
end

workspace.DescendantAdded:Connect(function(descendant)
    if instantEnabled and descendant:IsA("ProximityPrompt") then
        descendant.HoldDuration = 0
    end
end)

setPromptsInstant(instantEnabled)

local function parseMoneyString(moneyStr)
    local numberPart, suffix = moneyStr:match("([%d%.]+)%s*([KMBkmb]?)")
    if not numberPart then return 0 end

    local numberValue = tonumber(numberPart) or 0
    local multiplier = 1

    suffix = suffix:upper()
    if suffix == "K" then
        multiplier = 1e3
    elseif suffix == "M" then
        multiplier = 1e6
    elseif suffix == "B" then
        multiplier = 1e9
    end

    return numberValue * multiplier
end

local function findYourBase()
    for _, base in ipairs(Bases:GetChildren()) do
        local config = base:FindFirstChild("Configuration")
        if config then
            local playerValue = config:FindFirstChild("Player")
            if playerValue and playerValue.Value == player then
                return base
            end
        end
    end
    return nil
end

local Button = Tab:CreateButton({
    Name = "Steal Best Youtuber",
    Callback = function()
        local yourBase = findYourBase()
        if not yourBase then
            warn("Could not find your base!")
            return
        end

        print("Your base found:", yourBase.Name)

        local highestMPSValue = 0
        local bestYoutuberModel = nil
        local bestBase = nil

        for _, base in ipairs(Bases:GetChildren()) do
            if base ~= yourBase then
                local ignoreFolder = base:FindFirstChild("Ignore")
                if ignoreFolder then
                    for _, child in ipairs(ignoreFolder:GetChildren()) do
                        local hrpChild = child:FindFirstChild("HumanoidRootPart")
                        if hrpChild then
                            local thingAttachment = hrpChild:FindFirstChild("ThingAttachment")
                            if thingAttachment then
                                local youtuberGui = thingAttachment:FindFirstChild("YoutuberGui")
                                if youtuberGui then
                                    local moneyLabel = youtuberGui:FindFirstChild("MoneyPerSecond", true)
                                    if moneyLabel and moneyLabel:IsA("TextLabel") then
                                        local value = parseMoneyString(moneyLabel.Text)
                                        if value > highestMPSValue then
                                            highestMPSValue = value
                                            bestYoutuberModel = child
                                            bestBase = base
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        if not bestYoutuberModel then
            warn("No suitable youtuber found in other bases.")
            return
        end

        print("Best youtuber found in base:", bestBase.Name, "Model:", bestYoutuberModel.Name, "MoneyPerSecond:", highestMPSValue)

        local targetHrp = bestYoutuberModel:FindFirstChild("HumanoidRootPart")
        if not targetHrp then
            warn("Best youtuber model missing HumanoidRootPart!")
            return
        end

        -- Teleport instantly to youtuber + 5 studs above
        hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 5, 0)

        wait(0.1)

        -- Find the ProximityPrompt on the youtuber model or descendants
        local prompt = nil
        for _, descendant in ipairs(bestYoutuberModel:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") then
                prompt = descendant
                break
            end
        end

        if not prompt then
            warn("No ProximityPrompt found on best youtuber model!")
            hrp.CFrame = yourBase.PrimaryPart.CFrame * CFrame.new(0, 5, 0)
            return
        end

        -- Improved prompt interaction
        if prompt.Trigger then
            prompt:Trigger(player)
        elseif prompt.Triggered then
            prompt.Triggered:Fire(player)
        else
            prompt:InputHoldBegin()
            wait(0.15)
            prompt:InputHoldEnd()
        end

        print("Stole from youtuber!")

        hrp.CFrame = yourBase.PrimaryPart.CFrame * CFrame.new(0, 5, 0)

        print("Returned to base.")

        Rayfield:Notify({
            Title = "Steal Best Youtuber",
            Content = "Successfully stole from "..bestYoutuberModel.Name,
            Duration = 5,
            Image = 4483362458,
        })
    end,
})


local Tab = Window:CreateTab("ESP", 0) -- Title, Image

-- Create folder for ESPs
local CoreGui = game:GetService("CoreGui")
local Youtubers = workspace:WaitForChild("Youtubers")

local espFolder = CoreGui:FindFirstChild("YoutuberESP") or Instance.new("Folder", CoreGui)
espFolder.Name = "YoutuberESP"

local espColor = Color3.fromRGB(255, 0, 0)
local espEnabled = false
local heartbeatConnection

-- Wait for valid part
local function waitForPart(model, timeout)
    local t = 0
    while t < timeout do
        if not model or not model.Parent then return nil end
        local part = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
        if part then return part end
        t += 0.1
        task.wait(0.1)
    end
    return nil
end

-- Create or update ESP
local function createOrUpdateESP(model)
    if not model:IsA("Model") then return end
    local name = model.Name

    -- Check if ESP already exists
    local existingESP = espFolder:FindFirstChild(name)

    if existingESP then
        -- Update Adornee if model changed
        local part = waitForPart(model, 2)
        if part then
            existingESP.Adornee = part
        end
        return
    end

    -- Create new ESP
    local part = waitForPart(model, 5)
    if not part then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = name
    billboard.Adornee = part
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = espColor
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    label.Parent = billboard

    billboard.Parent = espFolder
end

-- Remove all ESPs
local function clearAllESP()
    espFolder:ClearAllChildren()
end

-- Main toggle function
local function setESPState(state)
    espEnabled = state

    if espEnabled then
        -- Start heartbeat scanner
        heartbeatConnection = RunService.Heartbeat:Connect(function()
            local seen = {}

            for _, model in ipairs(Youtubers:GetChildren()) do
                if model:IsA("Model") and model.Name then
                    seen[model.Name] = model
                    task.spawn(createOrUpdateESP, model)
                end
            end

            -- Remove any ESPs for Youtubers no longer present
            for _, gui in ipairs(espFolder:GetChildren()) do
                if not seen[gui.Name] then
                    gui:Destroy()
                end
            end
        end)

    else
        clearAllESP()
        if heartbeatConnection then
            heartbeatConnection:Disconnect()
            heartbeatConnection = nil
        end
    end
end

-- UI Toggle
local Toggle = Tab:CreateToggle({
    Name = "ESP for Youtubers in Street",
    CurrentValue = false,
    Flag = "Toggle1",
    Callback = setESPState,
})

-- UI Color Picker
local ColorPicker = Tab:CreateColorPicker({
    Name = "ESP Color",
    Color = espColor,
    Flag = "ColorPicker1",
    Callback = function(newColor)
        espColor = newColor
        for _, gui in ipairs(espFolder:GetChildren()) do
            if gui:IsA("BillboardGui") then
                local label = gui:FindFirstChildOfClass("TextLabel")
                if label then
                    label.TextColor3 = espColor
                end
            end
        end
    end,
})

-- SERVICES
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- SETTINGS
local boxESPEnabled = false
local boxESPColor = Color3.fromRGB(255, 0, 0)
local youtuberBoxes = {}

-- FUNCTION: Create Drawing Box
local function createBox(model)
	if not model:IsA("Model") or not model:FindFirstChild("HumanoidRootPart") then return end

	if youtuberBoxes[model] then return end

	local box = Drawing.new("Square")
	box.Visible = false
	box.Color = boxESPColor
	box.Thickness = 2
	box.Transparency = 1
	box.Filled = false

	youtuberBoxes[model] = box
end

-- FUNCTION: Remove Drawing Box
local function removeBox(model)
	if youtuberBoxes[model] then
		youtuberBoxes[model]:Remove()
		youtuberBoxes[model] = nil
	end
end

-- FUNCTION: Clear All Boxes
local function clearAllBoxes()
	for model, box in pairs(youtuberBoxes) do
		box:Remove()
	end
	youtuberBoxes = {}
end

-- HEARTBEAT: Update Box Positions
RunService.RenderStepped:Connect(function()
	if not boxESPEnabled then return end

	for model, box in pairs(youtuberBoxes) do
		local root = model:FindFirstChild("HumanoidRootPart")
		if root and root:IsDescendantOf(workspace) then
			local cf = root.CFrame
			local screenPos, onScreen = Camera:WorldToViewportPoint(cf.Position)

			if onScreen then
				local scale = Camera:WorldToViewportPoint(cf.Position + Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(cf.Position - Vector3.new(0, 3, 0)).Y
				box.Size = Vector2.new(scale * 1.5, scale * 2)
				box.Position = Vector2.new(screenPos.X - box.Size.X / 2, screenPos.Y - box.Size.Y / 2)
				box.Color = boxESPColor
				box.Visible = true
			else
				box.Visible = false
			end
		else
			box.Visible = false
		end
	end
end)

-- FUNCTION: Main Toggle
local function toggleBoxESP(state)
	boxESPEnabled = state

	if boxESPEnabled then
		-- Initial scan
		for _, model in ipairs(Youtubers:GetChildren()) do
			createBox(model)
		end

		-- Track new Youtubers
		Youtubers.ChildAdded:Connect(function(model)
			task.wait(0.1)
			createBox(model)
		end)

		-- Remove ESP on Youtuber removal
		Youtubers.ChildRemoved:Connect(function(model)
			removeBox(model)
		end)
	else
		clearAllBoxes()
	end
end

-- UI: Box ESP Toggle
local Toggle = Tab:CreateToggle({
	Name = "Box ESP",
	CurrentValue = false,
	Flag = "BoxESP_Toggle",
	Callback = function(Value)
		toggleBoxESP(Value)
	end,
})

-- UI: Color Picker
local ColorPicker = Tab:CreateColorPicker({
	Name = "Box Color",
	Color = boxESPColor,
	Flag = "ColorPicker1",
	Callback = function(newColor)
		boxESPColor = newColor
	end,
})

-- SERVICES
local CoreGui = game:GetService("CoreGui")

-- CONFIG
local ChamsFolder = CoreGui:FindFirstChild("YoutuberChams") or Instance.new("Folder", CoreGui)
ChamsFolder.Name = "YoutuberChams"

local chamsEnabled = false
local chamsColor = Color3.fromRGB(255, 0, 0)
local currentChams = {}

-- APPLY/UPDATE Chams Each Frame
local function refreshChams()
    if not chamsEnabled then return end

    local seen = {}

    for _, model in ipairs(Youtubers:GetChildren()) do
        if model:IsA("Model") then
            seen[model] = true

            if not currentChams[model] then
                local highlight = Instance.new("Highlight")
                highlight.Adornee = model
                highlight.FillColor = chamsColor
                highlight.FillTransparency = 0.5
                highlight.OutlineColor = Color3.new(0, 0, 0)
                highlight.OutlineTransparency = 0
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = ChamsFolder

                currentChams[model] = highlight
            else
                currentChams[model].FillColor = chamsColor
            end
        end
    end

    -- Remove Chams for models no longer present
    for model, highlight in pairs(currentChams) do
        if not seen[model] then
            highlight:Destroy()
            currentChams[model] = nil
        end
    end
end

-- RENDER LOOP
RunService.RenderStepped:Connect(refreshChams)

-- TOGGLE FUNCTION
local function setChamsState(state)
    chamsEnabled = state
    if not state then
        for _, highlight in pairs(currentChams) do
            highlight:Destroy()
        end
        currentChams = {}
    end
end

-- UI: Toggle
local ChamsToggle = Tab:CreateToggle({
    Name = "Chams ESP",
    CurrentValue = false,
    Flag = "ChamsToggle",
    Callback = setChamsState,
})

-- UI: Color Picker
local ChamsColorPicker = Tab:CreateColorPicker({
    Name = "Chams Color",
    Color = chamsColor,
    Flag = "ChamsColorPicker",
    Callback = function(newColor)
        chamsColor = newColor
        for _, highlight in pairs(currentChams) do
            highlight.FillColor = chamsColor
        end
    end,
})

local Workspace = game:GetService("Workspace")

local ESPFolder = CoreGui:FindFirstChild("MoneyPerSecondESP") or Instance.new("Folder", CoreGui)
ESPFolder.Name = "MoneyPerSecondESP"

local espEnabled = false
local minMPS = 0
local espTexts = {}

-- Parse MPS text into number
local function parseMPS(text)
    if not text then return 0 end
    local cleaned = text:gsub("[^%d]", "") -- Remove $, commas, etc.
    local num = tonumber(cleaned)
    return num or 0
end

-- Create ESP for a model
local function createESP(model)
    if espTexts[model] then return end

    local hrp = model:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local attachment = hrp:FindFirstChild("ThingAttachment")
    if not attachment then return end

    local gui = attachment:FindFirstChild("YoutuberGui")
    if not gui then return end

    local mps = gui:FindFirstChild("MoneyPerSecond")
    if not mps or not mps:IsA("TextLabel") then return end

    local mpsValue = parseMPS(mps.Text)
    if mpsValue < minMPS then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "MoneyPerSecondESP"
    billboard.Adornee = hrp
    billboard.Size = UDim2.new(0, 120, 0, 35)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = ESPFolder

    local textLabel = Instance.new("TextLabel")
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.TextColor3 = Color3.new(1, 1, 0)
    textLabel.TextStrokeTransparency = 0.5
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextScaled = true
    textLabel.Text = mps.Text
    textLabel.Parent = billboard

    espTexts[model] = {Billboard = billboard, SourceLabel = mps, TextLabel = textLabel}
end

-- Remove ESP for a model
local function removeESP(model)
    if espTexts[model] then
        espTexts[model].Billboard:Destroy()
        espTexts[model] = nil
    end
end

-- Update text and apply filtering live
local function updateESPs()
    for model, data in pairs(espTexts) do
        if data.SourceLabel and data.SourceLabel.Parent then
            local newVal = parseMPS(data.SourceLabel.Text)
            if newVal >= minMPS then
                data.TextLabel.Text = data.SourceLabel.Text
            else
                removeESP(model)
            end
        else
            removeESP(model)
        end
    end
end

-- Refresh ESPs based on new filter or toggle
local function refreshESPs()
    if not espEnabled then return end

    local seen = {}

    for _, model in ipairs(Youtubers:GetChildren()) do
        seen[model] = true
        if not espTexts[model] then
            createESP(model)
        end
    end

    for model in pairs(espTexts) do
        if not seen[model] then
            removeESP(model)
        end
    end
end

-- Connections
local childAddedConn
local childRemovedConn

local function setupListeners()
    if childAddedConn then childAddedConn:Disconnect() end
    if childRemovedConn then childRemovedConn:Disconnect() end

    childAddedConn = Youtubers.ChildAdded:Connect(function(model)
        task.wait(0.1)
        if espEnabled then
            createESP(model)
        end
    end)

    childRemovedConn = Youtubers.ChildRemoved:Connect(removeESP)
end

-- Update every frame
RunService.RenderStepped:Connect(function()
    if espEnabled then
        updateESPs()
    end
end)

-- Toggle ESP
local Toggle = Tab:CreateToggle({
    Name = "Money Per Second ESP",
    CurrentValue = false,
    Flag = "MoneyPerSecondESP",
    Callback = function(value)
        espEnabled = value
        if espEnabled then
            refreshESPs()
            setupListeners()
        else
            for model in pairs(espTexts) do
                removeESP(model)
            end
            if childAddedConn then childAddedConn:Disconnect() end
            if childRemovedConn then childRemovedConn:Disconnect() end
        end
    end,
})

-- Dropdown filter
local Dropdown = Tab:CreateDropdown({
    Name = "Minimum Money/Sec",
    Options = {"0+", "5000+", "10000+", "50000+", "250000+", "1000000+", "5000000+"},
    CurrentOption = {"0+"},
    MultipleOptions = false,
    Flag = "MPSFilter",
    Callback = function(option)
        local selected = option[1]
        local cleaned = selected:gsub("[^%d]", "")
        minMPS = tonumber(cleaned) or 0

        if espEnabled then
            -- Rebuild everything to apply new filter
            for model in pairs(espTexts) do
                removeESP(model)
            end
            refreshESPs()
        end
    end,
})
