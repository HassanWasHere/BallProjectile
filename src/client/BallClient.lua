local Event = game:GetService("ReplicatedStorage"):WaitForChild("BallEvent")
local LocalPlayer = game.Players.LocalPlayer
local CurrentBallPickedUp = nil
local CurrentBallRegistered = nil
local PickUp = Instance.new("BillboardGui", Workspace.CurrentCamera)
PickUp.AlwaysOnTop = true
PickUp.Size = UDim2.new(2,0,2,0)
PickUp.Enabled = false
local ImageLabel = Instance.new("ImageLabel", PickUp)
ImageLabel.Size = UDim2.new(1,0,1,0)

Event.OnClientEvent:connect(function(Event, Ball, PickupRange)
	local Character = LocalPlayer.Character
	if not Character then return end
	local HRP = Character:FindFirstChild("HumanoidRootPart")
	if not HRP then return end
	if Event == "BeginRegister" then
		print("REGISTER BEGUN")
		if not CurrentBallRegistered then
			CurrentBallRegistered = Ball
			PickUp.Adornee = Ball
			PickUp.Enabled = true					
		end
	elseif Event == "EndRegister" then
		print("REGISTER ENDED")
		PickUp.Enabled = false
		PickUp.Adornee = nil
		CurrentBallRegistered = nil
	end
end)
return {}
