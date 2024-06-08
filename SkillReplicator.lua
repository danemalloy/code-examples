-- written by dane1up

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local Replicated = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local _Workspace = game:GetService("Workspace")

local remotes = Replicated.Remotes
local events = remotes.Events

local serverModules = script.Parent.Parent.ServerModules
local functionsModule = require(serverModules.FunctionsModule)
local stopAnims = require(serverModules.StopAnimsModule)
local counterModule = require(serverModules.CounterModule)
local damageModule  = require(serverModules.DamageModule)
local ragdollModule = require(serverModules.RagdollModule)
local stunModule = require(serverModules.StunModule)
local knockbackModule = require(serverModules.KnockbackModule)

local isBehind = function(character: Model, characterHit: Model)
	local projectedVector = characterHit.PrimaryPart.CFrame:VectorToObjectSpace(character.HumanoidRootPart.CFrame.LookVector)*Vector3.new(1,0,1)
	local angle = math.atan2(projectedVector.Z, projectedVector.X)

	if angle > -360 and angle < -280 or angle < 80 and angle > 0 then
		return false
	else
		return true
	end
end

return {
	["Combo"] = function(player: Player, ...: {any})
		local data = {...}
		data = data[1]
		print(`data: {data} | received on server`)

		local extra = data["Extra"]

		local character = player.Character
		local human = character.Humanoid

		for _, v: Tool in character:GetChildren() do
			if v:IsA("Tool") then return end
		end

		if character.Status:FindFirstChild("Blocking") or character.Status:FindFirstChild("Action") or character.Status:FindFirstChild("Ragdoll") or character.Status:FindFirstChild("Stun") then return end
		character:WaitForChild("Stats")

		local damageHuman = function(humanHit, m1Value)
			local bypass = false
			if m1Value== 4 and extra == "Downslam" then
				bypass = true
			end
			if humanHit.Health <= 0 then return end
			if humanHit.Parent.Status:FindFirstChild("iFrame") or humanHit.Parent.Status:FindFirstChild("Ragdoll") then return end
			if counterModule(character, humanHit.Parent) then
				return
			else
				if humanHit.Parent.Status:FindFirstChild("Blocking") and isBehind(character, humanHit.Parent) == false and bypass == false then
					functionsModule.fireClientWithDist(
						{
							["Origin"] = character.HumanoidRootPart.Position,
							["Distance"] = 150,
							["Event"] = events.MovesetReplicator}, {"HitBlock", {["hitCharacter"]=humanHit.Parent}
						}
					)
					return
				else
					damageModule(character, humanHit.Parent, data["Damage"])
					if m1Value == 4 then
						task.delay(0.1, function()
							for _, v: Folder? in character.Status:GetChildren() do
								if v.Name ~= "Action" and v.Name ~= "M1ing" then continue end
								v:Destroy()
							end
						end)
					end

					local bodyVelocity1 = Instance.new("BodyVelocity")
					bodyVelocity1.MaxForce = Vector3.new(22000, 22000, 22000)
					bodyVelocity1.Velocity = (humanHit.Parent.HumanoidRootPart.Position-character.HumanoidRootPart.Position).Unit*9
					bodyVelocity1.Parent = character.HumanoidRootPart
					Debris:AddItem(bodyVelocity1, 0.15)

					local normalStunDuration = data["Stun"]
					stunModule(humanHit.Parent, normalStunDuration, false)

					if m1Value == 4 and extra == "Downslam" then
						stunModule(character, 2, true)
						ragdollModule.use(humanHit.Parent, 2, true)
						if not humanHit.Parent:FindFirstChild("HyperArmor") and not humanHit.Parent:FindFirstChild("SuperArmor") then
							functionsModule.fireClientWithDist(
								{
									["Origin"] = character.HumanoidRootPart.Position,
									["Distance"] = 150,
									["Event"] = events.MovesetReplicator}, {"Downslam", {["hitCharacter"]=humanHit.Parent}
								}
							)

							local bodyVelocity2 = Instance.new("BodyVelocity")
							bodyVelocity2.MaxForce = Vector3.new(40000, 40000, 40000)
							bodyVelocity2.Velocity = Vector3.new(0, -40000, 0)
							bodyVelocity2.Parent = humanHit.Parent.HumanoidRootPart
							Debris:AddItem(bodyVelocity2, 0.8)

							humanHit.Parent.HumanoidRootPart.CFrame *= CFrame.Angles(math.rad(90), 0, 0)
						end
					elseif m1Value == 4 and extra == "Uppercut" then
						functionsModule.fireClientWithDist(
							{
								["Origin"] = character.HumanoidRootPart.Position,
								["Distance"] = 150,
								["Event"] = events.MovesetReplicator}, {"Uppercut", {["hitCharacter"]=humanHit.Parent}
							}
						)

						stunModule(humanHit.Parent, 1.5, true)
						ragdollModule.use(humanHit.Parent,1.5,true)
						knockbackModule(humanHit.Parent, (humanHit.Parent.HumanoidRootPart.CFrame.UpVector).Unit, data["Knockback"], 0.2)

						local uppercutFolder = Instance.new("Folder")
						uppercutFolder.Name = "Uppercut"
						uppercutFolder.Parent = character.Status
						Debris:AddItem(uppercutFolder, 3)
					elseif m1Value == 4 and not extra then
						stunModule(humanHit.Parent, 1, true)
						ragdollModule.use(humanHit.Parent, 1, true)
						if not humanHit.Parent.Status:FindFirstChild("HyperArmor") and not humanHit.Parent.Status:FindFirstChild("SuperArmor") then
							local bodyVelocity3 = Instance.new("BodyVelocity")
							bodyVelocity3.MaxForce = Vector3.new(22000, 22000, 22000)
							bodyVelocity3.Velocity = ((humanHit.Parent.HumanoidRootPart.Position-character.HumanoidRootPart.Position).Unit*25)+(Vector3.new(0,3,0)*10)
							bodyVelocity3.Parent = humanHit.Parent.HumanoidRootPart
							Debris:AddItem(bodyVelocity3, 0.2)
						end
					else
						knockbackModule(humanHit.Parent, (humanHit.Parent.HumanoidRootPart.Position-character.HumanoidRootPart.Position).Unit, 12, 0.15)
					end
					if data["Slash"] == true then
						functionsModule.fireClientWithDist(
							{
								["Origin"] = character.HumanoidRootPart.Position,
								["Distance"] = 150,
								["Event"] = events.MovesetReplicator}, {"M1Hit", {["hitCharacter"]=humanHit.Parent}
							}
						)
					end

					if humanHit.Parent.Status:FindFirstChild("HyperArmor") then return end
					if m1Value == 4 then return end
					stopAnims(humanHit.Parent)

					local hitAnims = Replicated.Assets.Animations.HitAnims:GetChildren()
					local anim = hitAnims[math.random(1, #hitAnims)]
					local track = humanHit:LoadAnimation(anim)
					track.Priority = Enum.AnimationPriority.Action
					track:Play()
				end
			end
		end

		if tick()-character.Stats.lastTimeM1.Value < data["M1Delay"] or tick()-character.Stats.lastM1End.Value < data["lastDelay"] then return end
		if tick()-character.Stats.lastTimeM1.Value > data["Refresh"] then
			if not character.Status:FindFirstChild("StopRefresh") then
				character.Stats.Combo.Value = 1
			end
		end

		if character.Status:FindFirstChild("Sprinting") then
			character.Status.Sprinting:Destroy()
			stopAnims(character)
		end

		human.WalkSpeed = 11
		human.JumpPower = 0

		character.Stats.M1.Value = character.Stats.Combo.Value
		character.Stats.lastTimeM1.Value = tick()

		local m1Value = character.Stats.M1.Value
		local action = Instance.new("Folder")
		action.Name = "Action"
		action.Parent = character.Status

		if character.Stats.Combo.Value ~= 4 then -- max m1 cycle
			Debris:AddItem(action, data["Action"])
		else
			Debris:AddItem(action, data["Action"]+0.4)
		end

		local interrupted = false
		local animation
		local track

		if m1Value ~= 4 or not extra then
			functionsModule.fireClientWithDist(
				{
					["Origin"] = character.HumanoidRootPart.Position,
					["Distance"] = 150,
					["Event"] = events.MovesetReplicator}, {"Swing", {["character"]=character,["SFX"]=m1Value}
				}
			)
		end

		if m1Value == 4 and extra == "Downslam" then
			animation = Replicated.Assets.Animations.M1s.Downslam
			track = human.Animator:LoadAnimation(animation)
			track.Priority = Enum.AnimationPriority.Action
			track:Play()
		elseif m1Value == 4 and extra == "Uppercut" then
			animation = Replicated.Assets.Animations.M1s.Uppercut
			track = human.Animator:LoadAnimation(animation)
			track.Priority = Enum.AnimationPriority.Action
			track:Play()
		else
			animation = Replicated.Assets.Animations.M1s["FistM"..character.Stats.Combo.Value]
			track = human.Animator:LoadAnimation(animation)
			track.Priority = Enum.AnimationPriority.Action
			track:Play()
		end

		if character.Stats.Combo.Value == 4 then
			character.Stats.Combo.Value = 1
			character.Stats.lastM1End.Value = tick()
		else
			character.Stats.Combo.Value += 1
		end

		local stunCheck
		local stunRemove
		local reached

		stunCheck = character.Status.ChildAdded:Connect(function(child)
			if child.Name == "Stun" or child.Name == "Action"  then
				stunCheck:Disconnect()
				interrupted = true
				track:Stop()
			end
			if child.Name == "Blocking" then
				stunCheck:Disconnect()
				character.Humanoid.WalkSpeed = 7
				interrupted = true
				track:Stop()
			end
			if child.Name == "Sprinting" then
				for _, v: Folder? in character.Status:GetChildren() do
					if v.Name ~= "Sprinting" then continue end
					v:Destroy()
				end
				stopAnims(character)
			end
		end)

		stunRemove = character.Status.ChildRemoved:Connect(function(_)
			if not character.Status:FindFirstChild("Stun") and not character.Status:FindFirstChild("Action") and not character.Status:FindFirstChild("Blocking") and not character.Status:FindFirstChild("M1ing") and not character.Status:FindFirstChild("Sprinting") then
				if character.Status:FindFirstChild("Stun") or character.Status:FindFirstChild("Action") or character.Status:FindFirstChild("Blocking") or character.Status:FindFirstChild("M1ing") or character.Status:FindFirstChild("Sprinting") then
					stunRemove:Disconnect()
					return
				end
				human.WalkSpeed = character.Stats.defaultSpeed.Value
				human.JumpPower = 40
				stunRemove:Disconnect()
			end
		end)

		reached = track:GetMarkerReachedSignal("Hit"):Connect(function()
			reached:Disconnect()
			if interrupted then return end
			if stunCheck then
				stunCheck:Disconnect()
			end
			if m1Value == 4 then
				character.Humanoid.WalkSpeed = 0
				character.Humanoid.JumpPower = 0
			end

			if character.Stats.M1.Value == 4 then
				local action2 = Instance.new("Folder")
				action2.Name = "Action"
				action2.Parent = character.Status
				Debris:AddItem(action2, 0.6)
			end

			local params = OverlapParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			local hitCharacters = {character}
			params.FilterDescendantsInstances = hitCharacters

			local hit = false
			task.delay(data["HitboxDuration"], function()
				if m1Value == 4 and hit == false and extra then
					functionsModule.fireClientWithDist(
						{
							["Origin"] = character.HumanoidRootPart.Position,
							["Distance"] = 150,
							["Event"] = events.MovesetReplicator}, {"Miss", {["character"]=character,["extra"]=extra}
						}
					)
				end
				task.wait(1)
				hitCharacters = {}
			end)

			local clock = tick()
			while tick() - clock <= data["HitboxDuration"] do
				task.wait()
				for _, v: BasePart | Part in _Workspace:GetPartBoundsInBox(character.HumanoidRootPart.CFrame*data["HitboxOffset"],data["HitboxSize"], params) do
					if v.Name ~= "HumanoidRootPart" then continue end

					local humanHit = v.Parent.Humanoid
					if table.find(hitCharacters, humanHit.Parent) then continue end
					hit = true
					task.spawn(function()
						damageHuman(humanHit,m1Value)
					end)
					table.insert(hitCharacters, humanHit.Parent)
					if m1Value == 4 and extra == "Downslam" then return end
				end
			end
		end)
	end,

	["Vital Strike"] = function(player: Player, ...: {any})
		local data = {...}
		data = data[1]
		print(`data: {data} | received on server`)

		local character = player.Character
		local human = character.Humanoid

		if character.Status:FindFirstChild("Blocking") or character.Status:FindFirstChild("Action") or character.Status:FindFirstChild("Ragdoll") or character.Status:FindFirstChild("Stun") or ragdollModule.isInAir(character) == true then return end
		character:WaitForChild("Stats")

		print("player is not in an inactive state")
		if tick()-character.Stats.Ability1CD.Value < data["CD"] then return end
		stopAnims(character)

		local action = Instance.new("Folder")
		action.Name = "Action"
		action.Parent = character.Status
		Debris:AddItem(action, 1.2)

		human.WalkSpeed = 1
		human.JumpPower = 0

		character.Stats.Ability1CD.Value = tick()

		local track = human.Animator:LoadAnimation(Replicated.Assets.Animations.MoveAnims.Move1.Stabs)
		track.Priority = Enum.AnimationPriority.Action
		track:Play()

		local i = 0
		local stunCheck
		local stunRemove
		local reached

		stunCheck = character.Status.ChildAdded:Connect(function(child)
			if child.Name ~= "Stun" then return end
			stunCheck:Disconnect()
			reached:Disconnect()
			track:Stop()
		end)

		stunRemove = character.Status.ChildRemoved:Connect(function()
			if character.Status:FindFirstChild("Stun") or character.Status:FindFirstChild("Action") or character.Status:FindFirstChild("Blocking") or character.Status:FindFirstChild("M1ing") or character.Status:FindFirstChild("Sprinting") then return end
			human.WalkSpeed = character.Stats.defaultSpeed.Value
			human.JumpPower = 40
			human.AutoRotate = true
			stunRemove:Disconnect()
		end)

		task.delay(track.Length, function()
			stunCheck:Disconnect()
			reached:Disconnect()
		end)

		reached = track:GetMarkerReachedSignal("Hit", "Kick"):Connect(function()
			i += 1
			if i == 1 then
				functionsModule.fireClientWithDist(
					{
						["Origin"] = character.HumanoidRootPart.Position,
						["Distance"] = 150,
						["Event"] = events.MovesetReplicator}, {"SMSkill1Slice", {["character"]=character}
					}
				)
			elseif i == 3 then
				functionsModule.fireClientWithDist(
					{
						["Origin"] = character.HumanoidRootPart.Position,
						["Distance"] = 0,
						["Event"] = events.MovesetReplicator}, {"SMSkill1Timer", {"none"}
					}
				)
			end

			local active = true

			local params = OverlapParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			local hitCharacters = {character}
			params.FilterDescendantsInstances = hitCharacters

			task.delay(1, function()
				hitCharacters = {}
			end)

			local hitCharacter

			local stunCheck2
			stunCheck2 = character.Status.ChildAdded:Connect(function(child)
				if child.Name ~= "Stun" then return end
				active = false
				stunCheck2:Disconnect()
			end)

			local clock = tick()
			task.delay(0.12, function()
				if i ~= 2 then return end
				track:AdjustSpeed(0.3)
				task.wait(0.5)
				track:Stop()
			end)

			while true do
				if tick()-clock >= 0.1 then break end
				task.wait()
				for _, v: Part? in workspace:GetPartBoundsInBox(character.HumanoidRootPart.CFrame*CFrame.new(0,1,-4),Vector3.new(6,6,6), params) do
					if not v.Parent:FindFirstChild("Humanoid") then continue end
					if not active then return end
					hitCharacter = v.Parent
					local humanHit = hitCharacter.Humanoid
					if table.find(hitCharacters,hitCharacter) then continue end
					task.spawn(function()
						local damage = 5
						if hitCharacter.Humanoid.Health <= 0 or hitCharacter.Status:FindFirstChild("Ragdoll") or hitCharacter.Status:FindFirstChild("iFrame") or counterModule(character, hitCharacter) == true then return end
						if i == 1 then
							if hitCharacter:FindFirstChild("Blocking") and isBehind(character, hitCharacter) == false then
								functionsModule.fireClientWithDist(
									{
										["Origin"] = character.HumanoidRootPart.Position,
										["Distance"] = 150,
										["Event"] = events.MovesetReplicator}, {"HitBlock", {["hitCharacter"]=hitCharacter}
									}
								)
								return
							end

							damageModule(character, hitCharacter, damage)
							stopAnims(hitCharacter)
							stunModule(hitCharacter, 1, false)

							if not hitCharacter.Status:FindFirstChild("HyperArmor") and not hitCharacter.Status:FindFirstChild("SuperArmor") then
								local bodyVelocity1 = Instance.new("BodyVelocity")
								bodyVelocity1.MaxForce = Vector3.new(22000,22000,22000)
								bodyVelocity1.Velocity = ((hitCharacter.HumanoidRootPart.Position-character.HumanoidRootPart.Position).Unit*12)
								Debris:AddItem(bodyVelocity1, 0.2)
							end

							functionsModule.fireClientWithDist(
								{
									["Origin"] = character.HumanoidRootPart.Position,
									["Distance"] = 150,
									["Event"] = events.MovesetReplicator}, {"SMSkill1Hit1", {["hitCharacter"]=hitCharacter}
								}
							)

							local hitAnims = Replicated.Assets.Animations.HitAnims:GetChildren()
							local anim = hitAnims[math.random(1,#hitAnims)]
							local track2 = humanHit.Animator:LoadAnimation(anim)
							track2.Priority = Enum.AnimationPriority.Action
							track2:Play()
						elseif i == 2 then
							task.spawn(function()
								stunModule(hitCharacter, 2.2, true, true)

								local iFrame = Instance.new("Folder")
								iFrame.Name = "iFrame"
								iFrame.Parent = character.Status
								Debris:AddItem(iFrame, 2.2)

								local action2 = Instance.new("Folder")
								action2.Name = "Action"
								action2.Parent = character.Status
								Debris:AddItem(action, 2.7)

								hitCharacter.HumanoidRootPart.Anchored = true
								humanHit.AutoRotate = false
								human.WalkSpeed = 0
								character.HumanoidRootPart.Anchored = true
								human.AutoRotate = false

								task.spawn(function()
									for _, v2: BasePart in hitCharacter:GetDescendants() do
										if not v2:IsA("BasePart") then continue end
										v2.CollisionGroup = "Extra"
									end
								end)

								hitCharacter.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame*CFrame.new(0,0,-3)*CFrame.Angles(0,math.rad(180),0)

								functionsModule.fireClientWithDist(
									{
										["Origin"] = character.HumanoidRootPart.Position,
										["Distance"] = 150,
										["Event"] = events.MovesetReplicator}, {"SMSkill1Grab", {["hitCharacter"]=hitCharacter,["character"]=character}
									}
								)

								task.wait(2.2)

								hitCharacter.HumanoidRootPart.Anchored = false
								humanHit.AutoRotate = true
								character.HumanoidRootPart.Anchored = false
								human.AutoRotate = true
							end)

							functionsModule.fireClientWithDist(
								{
									["Origin"] = character.HumanoidRootPart.Position,
									["Distance"] = 150,
									["Event"] = events.MovesetReplicator}, {"SMSkill1Hit2", {["hitCharacter"]=hitCharacter,["character"]=character}
								}
							)

							local hitAnims = Replicated.Assets.Animations.HitAnims:GetChildren()
							local anim = hitAnims[math.random(1,#hitAnims)]
							local track2 = humanHit.Animator:LoadAnimation(anim)
							track2.Priority = Enum.AnimationPriority.Action
							track2:Play()
						elseif i == 3 then
							if humanHit.Health <= 0 or hitCharacter.Status:FindFirstChild("iFrame") or hitCharacter.Status:FindFirstChild("Ragdoll") or counterModule(character, hitCharacter) == true then return end
							if hitCharacter.Status:FindFirstChild("Blocking") and isBehind(character) == false then
								functionsModule.fireClientWithDist(
									{
										["Origin"] = character.HumanoidRootPart.Position,
										["Distance"] = 150,
										["Event"] = events.MovesetReplicator}, {"HitBlock", {["hitCharacter"]=hitCharacter}
									}
								)
								return
							end

							functionsModule.fireClientWithDist(
								{
									["Origin"] = character.HumanoidRootPart.Position,
									["Distance"] = 150,
									["Event"] = events.MovesetReplicator}, {"SMSkill1Hit3", {["hitCharacter"]=hitCharacter,["character"]=character}
								}
							)

							damageModule(character, hitCharacter, damage)
							stopAnims(hitCharacter)
							stunModule(hitCharacter,1,false)

							task.wait(0.3)

							local anim = Replicated.Assets.Animations.MoveAnims.Move1.Reactions
							local track3 = humanHit.Animator:LoadAnimation(anim)
							track3.Priority = Enum.AnimationPriority.Action
							track3:Play()
						elseif i == 4 then
							if humanHit.Health <= 0 or hitCharacter.Status:FindFirstChild("iFrame") or hitCharacter.Status:FindFirstChild("Ragdoll") or counterModule(character, hitCharacter) == true then return end
							if hitCharacter.Status:FindFirstChild("Blocking") and isBehind(character) == false then 
								functionsModule.fireClientWithDist(
									{
										["Origin"] = character.HumanoidRootPart.Position,
										["Distance"] = 150,
										["Event"] = events.MovesetReplicator}, {"HitBlock", {["hitCharacter"]=hitCharacter}
									}
								)
								return
							end

							functionsModule.fireClientWithDist(
								{
									["Origin"] = character.HumanoidRootPart.Position,
									["Distance"] = 150,
									["Event"] = events.MovesetReplicator}, {"SMSkill1Hit4", {["hitCharacter"]=hitCharacter,["character"]=character}
								}
							)

							damageModule(character, hitCharacter, damage)
							stopAnims(hitCharacter)
							stunModule(hitCharacter,1,false)

							if not character.Status:FindFirstChild("Bleed") and not character.Status:FindFirstChild("Paralysis") then return end
							local effect
							if character.Status:FindFirstChild("Bleed") then
								effect = "Bleed"
							elseif character.Status:FindFirstChild("Paralysis") then
								effect = "Paralysis"
							end

							local anim = Replicated.Assets.Animations.MoveAnims.Move1.Reactions
							local track4 = humanHit.Animator:LoadAnimation(anim)
							track4.Priority = Enum.AnimationPriority.Action
							track4:Stop(0.1)

							local effectFolder = Instance.new("Folder")
							effectFolder.Name = effect
							effectFolder.Parent = hitCharacter.Status
							Debris:AddIteme(effectFolder,2)

							if effect == "Paralysis" then
								stunModule(hitCharacter,2,false,true)
								functionsModule.fireClientWithDist(
									{
										["Origin"] = character.HumanoidRootPart.Position,
										["Distance"] = 150,
										["Event"] = events.MovesetReplicator}, {"BleedEffect", {["hitCharacter"]=hitCharacter}
									}
								)
								TweenService:Create(character.Humanoid, TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.In,0),{Health = hitCharacter.Humanoid.Health-10}):Play()
								local anim2 = Replicated.Assets.Animations.MoveAnims.Move1.Paralysis
								local track5 = humanHit.Animator:LoadAnimation(anim2)
								track5.Priority = Enum.AnimationPriority.Action
								track5:Play()
							else
								TweenService:Create(character.Humanoid, TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.In,0),{Health = hitCharacter.Humanoid.Health-10}):Play()
								functionsModule.fireClientWithDist(
									{
										["Origin"] = character.HumanoidRootPart.Position,
										["Distance"] = 150,
										["Event"] = events.MovesetReplicator}, {"BleedEffect", {["hitCharacter"]=hitCharacter}
									}
								)
							end
						elseif i == 5 then
							if humanHit.Health <= 0 or hitCharacter.Status:FindFirstChild("iFrame") or hitCharacter.Status:FindFirstChild("Ragdoll") or counterModule(character, hitCharacter) == true then return end

							damageModule(character, hitCharacter, damage)
							stopAnims(hitCharacter)
							stunModule(hitCharacter,1,false)

							if not hitCharacter.Status:FindFirstChild("HyperArmor") and not hitCharacter.Status:FindFirstChild("SuperArmor") then 
								local bodyVelocity2 = Instance.new("BodyVelocity")
								bodyVelocity2.MaxForce = Vector3.new(22000,22000,22000)
								bodyVelocity2.Velocity = ((hitCharacter.HumanoidRootPart.Position-character.HumanoidRootPart.Position).Unit*25)+(Vector3.new(0,3,0)*10)
								Debris:AddItem(bodyVelocity2, 0.2)
							end

							if hitCharacter.Status:FindFirstChild("Paralysis") then return end
							ragdollModule.use(hitCharacter, 1.5, true)
						end
					end)
					table.insert(hitCharacters, hitCharacter)
					if i == 2 then return end
				end
			end
		end)

		stunCheck = character.Status.ChildAdded:Connect(function(child)
			if child.Name ~= "Stun" then return end
			stunCheck:Disconnect()
			reached:Disconnect()
			track:Stop()
		end)

		stunRemove = character.Status.ChildRemoved:Connect(function()
			if character.Status:FindFirstChild("Stun") or character.Status:FindFirstChild("Action") or character.Status:FindFirstChild("Blocking") or character.Status:FindFirstChild("M1ing") or character.Status:FindFirstChild("Sprinting") then return end
			stunRemove:Disconnect()
			character.Humanoid.WalkSpeed = character.Stats.defaultSpeed.Value
			character.Humanoid.JumpPower = 40
			character.Humanoid.AutoRotate = true
		end)
	end,
}
