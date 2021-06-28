local Event = game:GetService("ReplicatedStorage"):WaitForChild("BallEvent")
local Input = game:GetService("UserInputService")
local LocalPlayer = game.Players.LocalPlayer
local CurrentBallPickedUp = nil
local CurrentBallRegistered = nil
local PickUp = Instance.new("BillboardGui", Workspace.CurrentCamera)
PickUp.AlwaysOnTop = true
PickUp.Size = UDim2.new(2,0,2,0)
PickUp.Enabled = false
local ImageLabel = Instance.new("ImageLabel", PickUp)
ImageLabel.Size = UDim2.new(1,0,1,0)
ImageLabel.BackgroundTransparency = 1
ImageLabel.Image = "rbxassetid://7017736579"

Event.OnClientEvent:connect(function(Event, Ball, PickupRange)
	local Character = LocalPlayer.Character
	if not Character then return end
	local HRP = Character:FindFirstChild("HumanoidRootPart")
	if not HRP then return end
	if Event == "BeginRegister" then
		if CurrentBallPickedUp or CurrentBallRegistered then return end
		CurrentBallRegistered = Ball
		PickUp.Adornee = Ball
		PickUp.Enabled = true					
	elseif Event == "EndRegister" then
		if CurrentBallPickedUp then return end
		PickUp.Enabled = false
		PickUp.Adornee = nil
		CurrentBallRegistered = nil
	elseif Event == "PickedUp" then
		CurrentBallPickedUp = Ball
		PickUp.Enabled = false
		PickUp.Adornee = nil
	end
end)

Input.InputBegan:connect(function(inp, gp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1 then
		if CurrentBallPickedUp then
			local Mouse = LocalPlayer:GetMouse()
			Mouse.TargetFilter = LocalPlayer.Character
			local MousePos = Mouse.Hit
			Event:FireServer(CurrentBallPickedUp,"Throw", MousePos)
			CurrentBallPickedUp = nil
			CurrentBallRegistered = nil
		end
	elseif inp.KeyCode == Enum.KeyCode.E then	
		if CurrentBallRegistered and not CurrentBallPickedUp then
			Event:FireServer(CurrentBallRegistered, "RequestPickup")
		end
	end
end)
return {}
