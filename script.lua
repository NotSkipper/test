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

local function isNumber(value)
    return typeof(value) == "number"
end

local Slider = Tab:CreateSlider({
   Name = "Speed",
   Range = {16, 250},  -- Default walk speed is 16, max 250 for safety
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "SpeedSlider",
   Callback = function(Value)
       if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
           if isNumber(Value) then
               LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = Value
           end
       end
   end,
})
