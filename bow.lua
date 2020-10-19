local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local TweenService = game:GetService("TweenService")
local firstViewModel = game:GetService("ReplicatedStorage"):WaitForChild("FirstPersonViewModel"):Clone()
local bow = game:GetService("ReplicatedStorage"):WaitForChild("Bow"):Clone()
local camera = game.Workspace.CurrentCamera
local http  = game:GetService("HttpService")

local Arrows = {}
Arrows.__index = Arrows

function Arrows.new(Arrow)

	local self = {}

	setmetatable(self, Arrows)

	self.arrow = Arrow
	self.Airresistance = 0.05
	self.Force = 3
	self.Range = 100
	self.DirectionFrame = camera.CFrame * CFrame.new(Vector3.new(0,0,-self.Range))
	self.Position = self.arrow.Position
	self.connection = nil
	self.isTouch = self.arrow.Touched:Connect(function(part)
		if string.match(part:GetFullName(), player.Name) == nil then
			--self.arrow.Position = self.arrow.Position  +  (self.arrow.Position - part.Position)
			local difference = self.arrow.CFrame
			local default_Orientation = self.arrow.Orientation
			local weld  =  Instance.new("Weld")
			weld.Name = "ArrowWeld"
			weld.Part0 = self.arrow
			weld.Part1 = part
			weld.Parent = self.arrow
			difference = difference - self.arrow.CFrame.Position
			weld.C1 = difference

			self.arrow.Velocity = Vector3.new(0,0,0)
			self.arrow.Parent = part


			self.connection:Disconnect()
			self.arrow:Destroy()
			if part.Parent:FindFirstChild("Humanoid") ~= nil then

				part.Parent.Humanoid:TakeDamage(5)
				script.Folder.HitSound:Play()

			end
			local defaultPartColor = part.BrickColor
			part.BrickColor = BrickColor.Green()
			print("PART CHANGING COLOR"..tostring(part.Name))
			wait(0.5)
			part.BrickColor = defaultPartColor


		end
	end)
	return self


end

function Arrows:setDirection(CFrameValue)
	self.DirectionFrame = CFrameValue
	return
end

function Arrows:setPosition(positionValue)
	self.Position = positionValue
	return
end


function Arrows:Fire()
	local Gravity = 196.20
	local Force =  self.Force
	local Range =  self.Range
	local timeDistance = 1
	self.arrow.Weld:Destroy()
	local Direction = self.DirectionFrame

	local Velocity =    ( ((Direction.Position - self.Position))  * Force)
	local BodyForce = Instance.new("BodyVelocity")
	local Gyro = Instance.new("BodyGyro")
	Gyro.Parent = self.arrow
	local downwardsForceConstant = 3
	local Mass = self.arrow:GetMass() * Gravity


	---0.852620602, 0.0369920097, -0.521219432
	---0.0523753613, 0.170953929, 0.983886003

	BodyForce.MaxForce = Vector3.new(Mass,Mass, Mass)
	BodyForce.Parent = self.arrow
	self.arrow.Velocity =  Velocity
	self.arrow.CFrame =   CFrame.new(self.Position ,  Direction.Position  )
	Gyro.CFrame =    CFrame.new(self.Position, Direction.Position  * Velocity.Unit )
	Gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	local  raycastResult;





	local airResistance =  self.Airresistance







	self.arrow.Parent = game.Workspace
	self.connection = game:GetService("RunService").Stepped:Connect(function(value)

		airResistance = airResistance + self.Airresistance
		self.arrow.Velocity = self.arrow.Velocity - Vector3.new(0,airResistance,0)
		Gyro.CFrame = CFrame.new(self.arrow.Position, self.arrow.Velocity.Unit + self.arrow.Position)
		BodyForce.Velocity = Velocity
		--[[
		raycastResult = workspace:Raycast(self.arrow.Position, Vector3.new(0,0,(self.arrow.Size.Z/2) * 15.75))


		if raycastResult and string.match(raycastResult.Instance:GetFullName(), player.Name) == nil then

			self.arrow.Anchored = true
			Gyro.Parent = nil
			BodyForce.Parent = nil
			self.arrow.Velocity = Vector3.new(0,0,0)
			connection:Disconnect()
		end

--]]
	end)




end

local Arrow = Arrows.new(bow.Arrow)
-----  Make Everything on the body transparent for testing purposes ----


game:GetService("UserInputService").MouseIconEnabled = false
---  THIS IS FOR THE Z ON THR RIGHT ARM- -2.5
firstViewModel.Parent = character
firstViewModel.RightArm.Weld.C1 = CFrame.new(Vector3.new(0,-1.5,-2.5))  * CFrame.Angles(math.deg(0),90,-80)
firstViewModel.LeftArm.Weld.C1 = CFrame.new(Vector3.new(-2.5,-1.5,-3.5))  * CFrame.Angles(math.deg(0), -150,-80)
bow.Arrow.Weld.C1 = CFrame.new(Vector3.new(0.1,0,0))
bow.Parent = character
--- Now weld the bow into the left and right arm  ---



game:GetService("UserInputService").InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		TweenService:Create(firstViewModel.RightArm.Weld, TweenInfo.new(1), {C1 =  CFrame.new(Vector3.new(0,-1.5,1))  * CFrame.Angles(math.deg(0),90,-80)}):Play()
		TweenService:Create(bow.Arrow.Weld, TweenInfo.new(1), {C1 =  CFrame.new(Vector3.new(0.1,0,1)) }):Play()


	end

end)


game:GetService("UserInputService").InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		TweenService:Create(firstViewModel.RightArm.Weld, TweenInfo.new(0.1), {C1 =   CFrame.new(Vector3.new(0,-1.5,-2.5))  * CFrame.Angles(math.deg(0),90,-80)}):Play()
		--TweenService:Create(bow.Arrow.Weld, TweenInfo.new(0.1), {C1 =  CFrame.new(Vector3.new(0.1,0,0)) }):Play()

		Arrow:setDirection(camera.CFrame  * CFrame.new(Vector3.new(0,0,-Arrow.Range)))
		Arrow:setPosition(bow.Arrow.Position)
		Arrow:Fire()
		wait(0.1)
		local newArrow = game:GetService("ReplicatedStorage").Arrow:Clone()
		newArrow.Weld.Part1 = bow.Handle
		newArrow.Parent = bow
		Arrow = Arrows.new(newArrow)
		print("Shot Fired")
	end
end)






local handleWeld = Instance.new("Weld")
handleWeld.Part0 = bow.Handle
handleWeld.Part1 = firstViewModel.LeftArm
handleWeld.Parent = bow.Handle

handleWeld.C1 = CFrame.new(Vector3.new(0.3,-1.5,0.7)) *   CFrame.Angles(-0.8,0,80)
--bow.PrimaryPart.CFrame = firstViewModel.LeftArm.CFrame * CFrame.new(Vector3.new(1, 0, -1))

local testPart = Instance.new("Part")
testPart.Parent = game.Workspace
testPart.Size = Vector3.new(2,2,2)
testPart.Anchored = true
testPart.CanCollide = false
testPart.Name = "CAMERATESTPART"
testPart.BrickColor = BrickColor.Red()


game:GetService("RunService").RenderStepped:Connect(function()
	firstViewModel.PrimaryPart.CFrame = camera.CFrame
	--testPart.Position = (camera.CFrame * CFrame.new(Vector3.new(0,0,-Arrow.Range))).Position
end)
