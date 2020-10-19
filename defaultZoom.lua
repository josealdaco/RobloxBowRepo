local FPMaximumDistance = 0.6
local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local renderConnection;
local Camera = game.Workspace.CurrentCamera
local FirstPersonToggle = false
local function renderFirstPerson(character)
	---- We need to ensure to make the arms and weapons visible ---
	for _, Localmodel in pairs(character:GetChildren()) do
		if Localmodel:IsA("Model") then
			for _, part in pairs(Localmodel:GetChildren()) do
				if part:IsA("Part") or part:IsA("MeshPart") then
					-- Only baseparts have a LocalTransparencyModifier property

					part.LocalTransparencyModifier  = 0

				end
			end

		end


	end
end

local function onRenderStep()
	-- Determine wether we are in first person and adjust transparency
	local isfirstperson = (character.Head.CFrame.Position - Camera.CFrame.Position).Magnitude < FPMaximumDistance;
	if (isfirstperson) then
		FirstPersonToggle = true
		print("WE ARE IN FIRST PERSON")
		renderFirstPerson(character)
		--SetCharacterLocalTransparency(FirstPersonLocalTransparency, char);
	else
		FirstPersonToggle = false
		print("We are not in first person")
		--SetCharacterLocalTransparency(ThirdPresonLocalTransparency, char);
	end
end



humanoid.Died:Connect(function()
	renderConnection:Disconnect()
end)

renderConnection = game:GetService("RunService").RenderStepped:Connect(onRenderStep)
