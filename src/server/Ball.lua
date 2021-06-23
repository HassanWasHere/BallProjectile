local Ball = {}
local Event = Instance.new("RemoteEvent", game:GetService("ReplicatedStorage"))
Event.Name = "BallEvent"


function Ball.new(Parent, Position, PickupRange)
	local newBall = {}
	setmetatable(newBall, {__index = Ball})
	newBall.Part = Instance.new("Part", Parent)
	newBall.Part.Shape = "Ball"
	newBall.Part.Size = Vector3.new(2,2,2)
	newBall.Part.Position = Position
	newBall.CurrentHolder = nil
	newBall.TouchEvent = newBall.Part.Touched:connect(newBall.PickUp)
	newBall.PickupRange = PickupRange or 1
	
	newBall.SensorPart = Instance.new("Part", newBall.Part)
	newBall.SensorPart.Size = newBall.Part.Size * PickupRange
	newBall.SensorPart.Anchored = false
	newBall.SensorPart.CanCollide = false
	newBall.SensorPart.Transparency = 1
	
	newBall.SensorWeld = Instance.new("Weld", newBall.SensorPart)
	newBall.SensorWeld.Part0 = newBall.Part
	newBall.SensorWeld.Part1 = newBall.SensorPart

	newBall.SensedPlayers = {}

	newBall.SensorPart.Touched:connect(function(Hit)
		wait()
		if Hit.Parent and Hit.Parent:FindFirstChild("HumanoidRootPart") and Hit.Name == "HumanoidRootPart" then
			local Player = game.Players:GetPlayerFromCharacter(Hit.Parent)
			if not newBall.SensedPlayers[Player.userId] then
				newBall.SensedPlayers[Player.userId] = true
				Event:FireClient(Player, "BeginRegister", newBall.Part, PickupRange)
			end
		end
	end)

	newBall.SensorPart.TouchEnded:connect(function(Hit)
		wait()
		if Hit.Parent and Hit.Parent:FindFirstChild("HumanoidRootPart") and Hit.Name == "HumanoidRootPart" then
			local Player = game.Players:GetPlayerFromCharacter(Hit.Parent)
			if newBall.SensedPlayers[Player.userId] then
				newBall.SensedPlayers[Player.userId] = nil
				Event:FireClient(Player, "EndRegister")
			end
		end
	end)
	return newBall
end

function Ball:PickUp(HitPart)

end

function Ball:Throw()

end


return Ball




