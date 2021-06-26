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
	newBall.PickupRange = PickupRange or 1
	
	newBall.PickupWeld = Instance.new("Weld", newBall.Part)

	newBall.SensorPart = Instance.new("Part", newBall.Part)
	newBall.SensorPart.Size = newBall.Part.Size * PickupRange
	newBall.SensorPart.Anchored = false
	newBall.SensorPart.CanCollide = false
	newBall.SensorPart.Transparency = 1
	
	newBall.SensorWeld = Instance.new("Weld", newBall.SensorPart)
	newBall.SensorWeld.Part0 = newBall.Part
	newBall.SensorWeld.Part1 = newBall.SensorPart

	newBall.SensedPlayers = {}

	return newBall
end

function Ball:init()
	self.TouchEvent = self.Part.Touched:connect(function(HitPart) -- TODO: here for testing, replace with E to pickup
		local Player = self:IsHitPlayer(HitPart)
		if Player then
			self:PickUp(Player)
		end
	end)
	self.SensorEvent1 = self.SensorPart.Touched:connect(function(Hit)
		wait()
		local Player = self:IsHitPlayer(Hit, "HumanoidRootPart")
		if Player then
			if not self.SensedPlayers[Player.userId] then
				self.SensedPlayers[Player.userId] = true
				Event:FireClient(Player, "BeginRegister", self.Part)
			end
		end
	end)

	self.SensorEvent2 = self.SensorPart.TouchEnded:connect(function(Hit)
		wait()
		local Player = self:IsHitPlayer(Hit, "HumanoidRootPart")
		if Player then
			if self.SensedPlayers[Player.userId] then
				self.SensedPlayers[Player.userId] = nil
				Event:FireClient(Player, "EndRegister")
			end
		end
	end)
	self.RemoteEvent = Event.OnServerEvent:connect(function(Player, Event, Input)
		if Player then
			if Event == "Throw" then
				self:Throw(Input)
			elseif Event == "Pickup" then
				self:PickUp(Player)
			end
		end
	end)
end

function Ball:IsHitPlayer(HitPart, ...)
	local Filter = {...}
	if HitPart.Parent then
		if HitPart.Parent:FindFirstChild("Humanoid") then
			if #Filter > 0 then
				if HitPart.Name == Filter[1] then
					return game.Players:GetPlayerFromCharacter(HitPart.Parent) or false
				else
					return false
				end
			else
				return game.Players:GetPlayerFromCharacter(HitPart.Parent) or false
			end
		end
	end
end

function Ball:PickUp(Player)
	if Player then
		local Character = Player.Character
		local RightArm = Character:FindFirstChild("RightHand")
		local Humanoid = Character:FindFirstChild("Humanoid")
		self.SensorPart.Massless = true
		self.TouchEvent:disconnect()
		self.SensorEvent1:disconnect()
		self.SensorEvent2:disconnect()
		self.PickupWeld.Part0 = RightArm
		self.PickupWeld.Part1 = self.Part
		self.PickupWeld.C0 = CFrame.new(0,-1,0)
		self.HoldAnimation = Humanoid:LoadAnimation(Character.Animate.toolnone:GetChildren()[1]) -- TODO: replace with real animation....
		self.HoldAnimation:Play()
		Event:FireClient(Player, "PickedUp", self.Part)
		self.CurrentHolder = Player
	end
end

function Ball:Throw(MousePos)
	if self.CurrentHolder then
		local Player = self.CurrentHolder
		local Character = Player.Character
		local Humanoid = Character:FindFirstChild("Humanoid")
		self.HoldAnimation:Stop()
		self.ThrowAnimation = Humanoid:LoadAnimation(Character.Animate.point:GetChildren()[1])
		self.ThrowAnimation:Play()
		Event:FireClient(Player, "Dropped")
		
		self.PickupWeld:Destroy()

		local Origin = self.Part.Position

		local BodyVelocity = Instance.new("BodyVelocity", self.Part)
		local velocity = CFrame.new(Origin, MousePos.p).lookVector * 50
		BodyVelocity.Velocity = velocity

		self.Part.Touched:connect(function(Hit)
			if Hit ~= self.SensorPart and Hit.Parent ~= Character then
				BodyVelocity:Destroy()
			end
		end)
	end
end


return Ball




