local Ball = {}
local Event = Instance.new("RemoteEvent", game:GetService("ReplicatedStorage"))
Event.Name = "BallEvent"

local Balls = {}

local Points = game:GetService("DataStoreService"):GetOrderedDataStore("Points")
local CurrentPoints = {}

function Ball.new(Parent, Position, PickupRange, TargetPart, TargetCallback)
	local newBall = {}
	setmetatable(newBall, {__index = Ball})
	newBall.Part = Instance.new("Part", Parent)
	newBall.Part.Shape = "Ball"
	newBall.Part.Size = Vector3.new(2,2,2)
	newBall.CurrentHolder = nil
	newBall.PickupRange = PickupRange or 1

	newBall.TargetPart = TargetPart
	
	newBall.SensorPart = Instance.new("Part", newBall.Part)
	newBall.SensorPart.Size = newBall.Part.Size * PickupRange
	newBall.SensorPart.Anchored = false
	newBall.SensorPart.CanCollide = false
	newBall.SensorPart.Transparency = 1
	newBall.SensorPart.Position = Position

	newBall.SensorWeld = Instance.new("Weld", newBall.SensorPart)
	newBall.SensorWeld.Part1 = newBall.Part
	newBall.SensorWeld.Part0 = newBall.SensorPart

	newBall.SensedPlayers = {}
	table.insert(Balls, newBall)
	return newBall
end

function Ball:init()
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
		if not RightArm or not Humanoid then return end
		self.Part.Parent = Character
		self.SensorPart.Massless = true
		self.SensorEvent1:disconnect()
		self.SensorEvent2:disconnect()
		self.PickupWeld = Instance.new("Weld", self.Part)
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
		self.ThrowAnimation.Looped = false
		self.ThrowAnimation:Play()
		
		self.PickupWeld:Destroy()

		local Origin = self.Part.Position

		self.Part.Parent = Workspace
		self.Part:SetNetworkOwner(nil) -- Have to give ownership to server to prevent rubberbanding..

		local BodyVelocity = Instance.new("BodyVelocity", self.Part)
		local velocity = CFrame.new(Origin, MousePos.p).lookVector * 120
		BodyVelocity.Velocity = velocity


		self.BVEvent = self.Part.Touched:connect(function(Hit)
			if Hit ~= self.SensorPart and Hit.Parent ~= Character then
				if BodyVelocity then
					BodyVelocity:Destroy()
				end
				self.BVEvent:disconnect()
				if Hit == self.TargetPart then
					self:Award()
				end
			end
		end)
		spawn(function()
			wait(.75)
			if BodyVelocity then
				BodyVelocity:Destroy()
			end
			self.BVEvent:disconnect()
			self:init()
		end)

	end
end

function Ball:Award()
	local Player = self.CurrentHolder
	if CurrentPoints[Player.userId] then
		CurrentPoints[Player.userId] = CurrentPoints[Player.userId] + 1
		_G.Update(CurrentPoints) -- NEVER USE, ONLY HERE FOR SHOWCASING. REMOVE!
	end
end

Event.OnServerEvent:connect(function(Player, Ball, Event, Input)
	if not Ball or not Player then return end
	if not Player.Character then return end
	for i,v in pairs(Balls) do
		if v.Part == Ball then
			Ball = v
		end
	end
	if Event == "Throw" then
		if Ball.Part.Parent ~= Player.Character then return end
		Ball:Throw(Input)
	elseif Event == "RequestPickup" then
		if Ball.SensedPlayers[Player.userId] then
			Ball:PickUp(Player)
		end
	end
end)

game.Players.PlayerAdded:connect(function(Player)
	Player:WaitForDataReady()
	CurrentPoints[Player.userId] = Points:GetAsync(Player.userId) or 0
end)

game.Players.PlayerRemoving:connect(function(Player)
	Points:SetAsync(Player.userId, CurrentPoints[Player.userId])
end)
return Ball




