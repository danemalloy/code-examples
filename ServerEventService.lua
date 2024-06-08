-- written by dane1up

local Market_Place_Service = game:GetService("MarketplaceService")
local Replicated_Storage = game:GetService("ReplicatedStorage")
local Bagde_Service = game:GetService("BadgeService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local _workspace = game:GetService("Workspace")

local Eggs_Service = require(script.Eggs_Service)
local Pets_Info = require(Replicated_Storage:WaitForChild("Modules"):WaitForChild("Pets"))

local OOP = {}

local List = {}

local Debounce = {}
local Debounce_2 = {}

local Codes = {

	[string.upper('freeboost')] = {
		Type = 'Boosts',
		Type_ = 'Pets',
		Get = 10,
		Data = 'CD_1',
		Result = 'Success! +10 Minutes of x2 Pets Boost!'
	};
	[string.upper('release')] = {
		Type = 'Pets',
		Type_ = 'Blue Baby Dragon',
		Get = 5,
		Data = 'CD_2',
		Result = 'Success! +1 Free Blue Baby Dragon!'
	};
	[string.upper('100likes')] = {
		Type = 'Boosts',
		Type_ = 'Coins',
		Get = 15,
		Data = 'CD_3',
		Result = 'Success! +15 Minutes of x2 Coins Boost!'
	};
	[string.upper('superop')] = {
		Type = 'Boosts',
		Type_ = 'Pets',
		Get = 10,
		Data = 'CD_4',
		Result = 'Success! +10 Minutes of x2 Pets Boost!'
	};
}

local Promise = require(Replicated_Storage:WaitForChild("Promise"))

local Event_2 = Replicated_Storage.Remotes:WaitForChild('Purchased')

local Client_Event_ = Replicated_Storage.Remotes.Client_Event
local Call_Server = Replicated_Storage.Remotes.Call_Server
local Event_ = Replicated_Storage.Remotes.Server_Event
local Aura_Event = Replicated_Storage.Remotes.Aura

OOP.Clear_Aura = function(Char)
	return Promise.new(function(resolve,_,_)
		for _,v in Char:GetChildren() do
			for _,n in v:GetChildren() do
				if n:IsA("ParticleEmitter") then
					n.Parent = nil
				end
			end	
		end
		resolve()
	end):catch(function(err)
		warn(err)
	end)
end
	
OOP.Load_Aura = function(Char)
	return Promise.new(function(resolve,_,_)
		for _,v in Char:GetChildren() do
			for _,n in v:GetChildren() do
				if n:IsA("ParticleEmitter") then
					n.Parent = nil
				end
			end
		end
		resolve()
	end):catch(function(err)
		warn(err)
	end)
end

Replicated_Storage.Remotes.Exchange.OnServerInvoke = function(Player,Amount)
	return Promise.new(function(resolve,_,_)
		if Player then
			if (math.floor(1 * Amount * 0.01)) > 0 then
				if Amount <= Player.Stats.Gems.Value then
					Player.Stats.Diamonds.Value += math.floor(1 * Amount * 0.01)
					Player.Total_Stats.Total_Diamonds.Value += math.floor(1 * Amount * 0.01)
					Replicated_Storage.Remotes.Client_Menssage:FireClient(Player,'Success!')
					Player.Stats.Gems.Value -= Amount
					resolve(true)
				else
					resolve(false)
				end
			end
			resolve(false)
		else
			resolve(false)
		end
		resolve(false)
	end):catch(function(err)
		warn(err)
	end)
end

OOP.Check_2_Game_Pass = function(Player, Id)
	return Promise.new(function(resolve,_,_)
		if Player then
			List = {
				['x2Coins'] = 809544777,
				['x2Pets'] = 809345762,
				['x2Gems'] = 809811220,
				['Teleport'] = 809554618,
				['x2Boosts'] = 829526646,
				['x2Rebirths'] = 809591746,
				['OpenEggs'] = 809593743,
			}
			if Id then
				for i,v in List do
					if v == Id then
						Player.GM[i].Value = true
						if i == 'x2Boosts' then
							Player.Boosts.x2_Boost_P.Value = 2
						elseif i == 'Teleport' then
							Player.GM.Teleport.Value = true
						elseif i == 'x2Pets' then
							Player.Boosts.xB_Pets.Value = 2
						elseif i == 'x2Gems' then
							Player.Boosts.xB_Gems.Value = 2
						elseif i == 'x2Coins' then
							Player.Boosts.xB_Coins.Value = 2
						--elseif i == 'OpenEggs' then
						elseif i == 'x2Rebirths' then
							Player.Stats.Rebirth_Bos.Value = 2
						end
					end
				end
			end
			resolve()
		else
			resolve()
		end
		resolve()
	end):catch(function(err)
		warn(err)
	end)
end

OOP.Check_Game_Pass = function(Player,Id)
	return Promise.new(function(resolve,_,_)
		if Player then
			List = {
				['x2Coins'] = 809544777,
				['x2Pets'] = 809345762,
				['x2Gems'] = 809811220,
				['Teleport'] = 809554618,
				['x2Boosts'] = 829526646,
				['x2Rebirths'] = 809591746,
				['OpenEggs'] = 809593743,
			}
			for Name,ID in List do
				if Market_Place_Service:UserOwnsGamePassAsync(Player.UserId,ID) then
					Player.GM[Name].Value = true		
					if Name == 'x2Boosts' then
						Player.Boosts.x2_Boost_P.Value = 2
					elseif Name == 'Teleport' then
						Player.GM.Teleport.Value = true
					elseif Name == 'x2Pets' then
						Player.Boosts.xB_Pets.Value = 2
					elseif Name == 'x2Gems' then
						Player.Boosts.xB_Gems.Value = 2
					elseif Name == 'x2Coins' then
						Player.Boosts.xB_Coins.Value = 2
					--elseif Name == 'OpenEggs' then
					elseif Name == 'x2Rebirths' then
						Player.Stats.Rebirth_Bos.Value = 2
					end
					OOP.Check_2_Game_Pass(Player,ID)
				end
			end
			if Player then
				for _, v in Player.GM:GetChildren() do
					if Market_Place_Service:UserOwnsGamePassAsync(Player.UserId,List[v.Name]) then
						Player.GM[v.Name].Value = true		
						if v.Name == 'x2Boosts' then
							Player.Boosts.x2_Boost_P.Value = 2
						elseif v.Name == 'Teleport' then
							Player.GM.Teleport.Value = true
						elseif v.Name == 'x2Pets' then
							Player.Boosts.xB_Pets.Value = 2
						elseif v.Name == 'x2Gems' then
							Player.Boosts.xB_Gems.Value = 2
						elseif v.Name == 'x2Coins' then
							Player.Boosts.xB_Coins.Value = 2
						--elseif v.Name == 'OpenEggs' then
						elseif v.Name == 'x2Rebirths' then
							Player.Stats.Rebirth_Bos.Value = 2
						end
					end
				end
				for _, v in Player.GM:GetChildren() do
					if v.Value == true then
						if v.Name == 'x2Boosts' then
							Player.Boosts.x2_Boost_P.Value = 2
						elseif v.Name == 'Teleport' then
							Player.GM.Teleport.Value = true
						elseif v.Name == 'x2Pets' then
							Player.Boosts.xB_Pets.Value = 2
						elseif v.Name == 'x2Gems' then
							Player.Boosts.xB_Gems.Value = 2
						elseif v.Name == 'x2Coins' then
							Player.Boosts.xB_Coins.Value = 2
						--elseif v.Name == 'OpenEggs' then
						elseif v.Name == 'x2Rebirths' then
							Player.Stats.Rebirth_Bos.Value = 2
						end
					end
				end
				if Id then
					for i,v in List do
						if v == Id then
							Player.GM[i].Value = true
							if i == 'x2Boosts' then
								Player.Boosts.x2_Boost_P.Value = 2
							elseif i == 'Teleport' then
								Player.GM.Teleport.Value = true
							elseif i == 'x2Pets' then
								Player.Boosts.xB_Pets.Value = 2
							elseif i == 'x2Gems' then
								Player.Boosts.xB_Gems.Value = 2
							elseif i == 'x2Coins' then
								Player.Boosts.xB_Coins.Value = 2
							--elseif i == 'OpenEggs' then
							elseif i == 'x2Rebirths' then
								Player.Stats.Rebirth_Bos.Value = 2
							end
						end
					end
				end
			end
			resolve()
		else
			resolve()
		end
		resolve()
	end):catch(function(err)
		warn(err)
	end)
end

Replicated_Storage.Remotes.Area_Call.OnServerInvoke = function(Player,Area)
	return Promise.new(function(resolve,_,_)
		if Player then
			if _workspace.Areas:FindFirstChild(Area.Name) then
				if Player:DistanceFromCharacter(_workspace.Areas:FindFirstChild(Area.Name).Position_.Position) <= 15 then
					if Player.AREAS[Area.Name].Value == 'false' then
						local Cost = _workspace.Areas:FindFirstChild(Area.Name).Cost
						if Player.Stats.Gems.Value >= Cost.Value then
							Replicated_Storage.Remotes.Client_Menssage:FireClient(Player,'Success!')
							Player.Stats.Gems.Value -= Cost.Value
							Player.AREAS[Area.Name].Value = 'true'
							Replicated_Storage.Remotes.Area_Call:InvokeClient(Player)
							resolve(true)
						else
							Replicated_Storage.Remotes.Client_Menssage:FireClient(Player,'You Need More Gems, Rebirth to Get Some!')
							resolve(false)
						end
					else
						resolve(false)
					end
				end
			end
			resolve(false)
		else
			resolve(false)
		end
	end):catch(function(err)
		warn(err)
	end)
end

OOP.Format_Time = function(s)
	return Promise.new(function(resolve,_,_)
		if s >= 0 and s < 60 then
			resolve(('%02is'):format(s % 60))
		elseif s > 59 and s < 3599 then
			resolve(('%02im %02is'):format((s / 60) % 60, s % 60))
		elseif s > 3599 and s < 86399 then
			resolve(('%02ih %02im %02is'):format((s / 3600) %24, (s / 60) % 60, s % 60))
		elseif s > 86399 then
			resolve(('%02id %02ih %02im %02is'):format(s / 86400, (s / 3600) % 24, (s / 60) % 60, s % 60))
		end
	end):catch(function(err)
		warn(err)
	end)
end

OOP.Check_No_Full = function(Player)
	return Promise.new(function(resolve,_,_)
		if Player then
			local PlayerGui = Player:WaitForChild('PlayerGui',999)
			local UI = PlayerGui:WaitForChild('Ui',999)
			local Pet_System = UI:WaitForChild('Center_UI_Frame'):WaitForChild('Pets',999)
			local Frame = Pet_System:WaitForChild('Frame',999)
			if #Frame:GetChildren() - 1 < Player.Stats.Pet_Space.Value then
				resolve(true)
			else
				resolve(false)
			end
		end
	end):catch(function(err)
		warn(err)
	end)
end

OOP.Create_Folder = function(Player,Check)
	return Promise.new(function(resolve,_,_)
		if Player then
			if Check then
				if _workspace.Pets_Service:FindFirstChild(Player.Name) then
					_workspace.Pets_Service:FindFirstChild(Player.Name).Parent = nil
				end
				resolve()
			else
				local Folder = Instance.new("Folder")
				Folder.Parent = _workspace.Pets_Service
				Folder.Name = Player.Name
				resolve()
			end
		end
		resolve()
	end):catch(function(err)
		warn(err)
	end)
end

OOP.Clear_Folder = function(Player)
	OOP.Create_Folder(Player,true)
end

OOP.Chest = function(Player)
	return Promise.new(function(resolve,_,_)
		if Player then
			if not Debounce_2[Player.Name] then
				Debounce_2[Player.Name] = true
				coroutine.wrap(function()
					task.wait(0.8)
					Debounce_2[Player.Name] = nil
				end)()
				local Stats = Player:WaitForChild('Stats')
				if Stats then
					if Player.Stats.Chest_Time.Value == 0 then
						local ASD = math.random(250,1250)
						Player.Stats.Chest_Time.Value = os.time()		
						Player.Stats.Coins.Value += ASD
						Player.Total_Stats.Total_Coins.Value += ASD
						Event_2:FireClient(Player)
					else
						if os.time() - Player.Stats.Chest_Time.Value >= 3600 then
							local ASD = math.random(1500,75000)
							Player.Stats.Chest_Time.Value = os.time()
							Player.Stats.Coins.Value += ASD
							Player.Total_Stats.Total_Coins.Value +=ASD
							Event_2:FireClient(Player)
						else
							Replicated_Storage.Remotes.Client_Menssage:FireClient(Player,'You Need to Wait or Buy Respawn Chest!')
						end
					end
				end	
			end
			resolve()
		else
			resolve()
		end
	end):catch(function(err)
		warn(err)
	end)
end

Call_Server.OnServerInvoke = function(Player,Signal,Text)
	return Promise.new(function(resolve,_,_)
		if Player then
			if Signal == 'Rebirths' then
				if not Debounce[Player.Name] then
					Debounce[Player.Name] = true
					coroutine.wrap(function()
						task.wait(0.5)
						Debounce[Player.Name] = nil
					end)()
					if Player.Stats.Coins.Value >= math.floor(15000 * Player.Stats.Multi.Value) then
						Player.Stats.Coins.Value = 0
						Player.Stats.Gems.Value += (400 + Player.Boosts.Pet_Gems.Value) * Player.Boosts.x2UP_Gems.Value * Player.Boosts.x2_Gems.Value * Player.Boosts.xB_Gems.Value * Player.Stats.Stats.Value * Player.Stats.Aura.Value * 2
						Player.Total_Stats.Total_Gems.Value += (400 + Player.Boosts.Pet_Gems.Value) * Player.Boosts.x2UP_Gems.Value * Player.Boosts.x2_Gems.Value * Player.Boosts.xB_Gems.Value * Player.Stats.Stats.Value * Player.Stats.Aura.Value* 2
						Player.Total_Stats.Total_Rebirths.Value += 1 * Player.Stats.Stats.Value * Player.Stats.Rebirth_Bos.Value * Player.Stats.Rebir.Value
						Player.Stats.Rebirths.Value += 1 * Player.Stats.Stats.Value * Player.Stats.Rebirth_Bos.Value * Player.Stats.Rebir.Value
						Player.Stats.Pets.Value = 0
						Player.Stats.Multi.Value *= 1.10
						Player.Stats.Range.Value = 8
						Player.Stats.Tool_Power.Value = 1
						for _,Values in Player.RGA:GetChildren() do
							Values.Value = false
						end
						Player.RGA.RG_1.Value = true	
						resolve(true)
					else
						resolve(false)
					end
				else
					resolve(false)
				end
			elseif Signal == 'Codes' then
				if Codes[string.upper(Text)] then
					local Table = Codes[string.upper(Text)]
					if Player.CD[Table.Data].Value == 'false' then
						if Table.Type == 'Boosts' then
							local TimeText = 'x2_%s_Time'
							Player.Boosts[TimeText:format(Table.Type_)].Value += 60 * Table.Get * Player.Boosts.x2_Boost_P.Value
							Player.CD[Table.Data].Value = 'true'
						elseif Table.Type == 'Pets' then
							OOP.Create_Pet(Player,Table.Type_)
							Player.CD[Table.Data].Value = 'true'
						elseif Table.Type == 'Boosts2' then
							Player.Boosts['Auto_Sell_Time'].Value += 60 * Table.Get * Player.Boosts.x2_Boost_P.Value
							Player.CD[Table.Data].Value = 'true'
						elseif Table.Type == 'Rebirth_' then
							Player.Stats.Multi.Value = 1
							Player.CD[Table.Data].Value = 'true'
						else
							Player.Stats[Table.Type].Value += Table.Get
							Player.Total_Stats['Total_'..Table.Type].Value += Table.Get
							Player.CD[Table.Data].Value = 'true'
						end
						resolve({true,Table.Result})
					else
						resolve({nil,'This Code Has Been Already Redeemed!'})
					end
				else
					resolve({nil,'This Code Does Not Exist!'})
				end
			elseif Signal == 'Ultimate_Rebirths' then
				if Player then
					if Player.Stats.Unlc.Value == 1 then
						if not Debounce[Player.Name] then
							Debounce[Player.Name] = true
							coroutine.wrap(function()
								task.wait(0.5)
								Debounce[Player.Name] = nil
							end)()
							if Text <= Player.Stats.Limit.Value then
								if Player.Stats.Coins.Value >= math.floor(40000 * Text * Player.Stats.Multi.Value) then
									Player.Stats.Coins.Value = 0
									Player.Stats.Gems.Value += (3000 + Player.Boosts.Pet_Gems.Value) * Player.Boosts.x2UP_Gems.Value * Player.Boosts.x2_Gems.Value * Player.Boosts.xB_Gems.Value * Player.Stats.Stats.Value * Player.Stats.Aura.Value * Text * 2
									Player.Total_Stats.Total_Gems.Value += (3000 + Player.Boosts.Pet_Gems.Value) * Player.Boosts.x2UP_Gems.Value * Player.Boosts.x2_Gems.Value * Player.Boosts.xB_Gems.Value * Player.Stats.Stats.Value * Player.Stats.Aura.Value* Text * 2
									Player.Total_Stats.Total_Rebirths.Value += 1 * Text * Player.Stats.Stats.Value * Player.Stats.Rebirth_Bos.Value * Player.Stats.Rebir.Value
									Player.Stats.Rebirths.Value += 1 * Text * Player.Stats.Stats.Value * Player.Stats.Rebirth_Bos.Value * Player.Stats.Rebir.Value
									Player.Stats.Pets.Value = 0
									Player.Stats.Multi.Value *= (1.90)
									Player.Stats.Range.Value = 8
									Player.Stats.Tool_Power.Value = 1
									for _,Values in Player.RGA:GetChildren() do
										Values.Value = false
									end
									Player.RGA.RG_1.Value = true	
									resolve(true)
								else
									resolve(false)
								end	
							else
								resolve(false)
							end	
						else
							resolve(false)
						end
					else
						resolve(false)
					end
				end
			else	
				resolve({nil,'[SYSTEM] Error, Try Again'})
			end
		end
	end):catch(function(err)
		warn(err)
	end)
end

OOP.Random_Pet = function(Player,Egg,No_Cost)
	return Promise.new(function(resolve,_,_)
		if Player then
			if No_Cost then
				local Pet = Egg.Pets[Eggs_Service.ChooseChance(Egg.Name)["_values"][1]]
				List[1] = Egg.EGG
				List[#List+1] = Pet.Name
				OOP.Create_Pet(Player,Pet.Name)
				resolve(true)
			else
				if OOP.Check_No_Full(Player)["_values"][1] == true then
					if Player.Stats[Egg.Type.Value].Value >= Egg.Cost.Value then
						Player.Stats[Egg.Type.Value].Value -= Egg.Cost.Value
						local Pet = Egg.Pets[Eggs_Service.ChooseChance(Egg.Name)["_values"][1]]
						List[1] = Egg.EGG
						List[#List+1] = Pet.Name
						OOP.Create_Pet(Player,Pet.Name)
						resolve(true)
					else
						Replicated_Storage.Remotes.Client_Menssage:FireClient(Player,('You Need More %s'):format(Egg.Type.Value))
						resolve(false)
					end
				else
					Replicated_Storage.Remotes.Client_Menssage:FireClient(Player,'Pet Inventory Full!')
					resolve(false)
				end
			end
		end
	end):catch(function(err)
		warn(err)
	end)
end

OOP.Format = function(val)
	return Promise.new(function(resolve,_,_)
		local suffixes =  {'K','M','B','T','qd','Qn','sx','Sp','`O','N','de','UD','DD','tdD','qdD','QnD','sxD','SpD','OcD','NvD','Vgn','UVg','DVg','TVg','qtV','QnV','SeV','SPG','OVG','NVG','TGN','UTG','DTG','tsTG','qtTG','QnTG','ssTG','SpTG','OcTG','NoAG','UnAG','DuAG','TeAG','QdAG','QnAG','SxAG','SpAG','OcAG','NvAG','CT'}
		local powers = {}
		for i = 1, #suffixes do
			table.insert(powers, 1000^i)
		end
		local ab = math.abs(val)
		if ab < 1000 then
			resolve(tostring(val))
		end
		local p = math.min(math.floor(math.log10(ab)/3), #suffixes)
		local num = math.floor(ab/powers[p]*100)/100
		resolve((tostring(num*math.sign(val))..suffixes[p]))
	end):catch(function(err)
		warn(err)
	end)
end

OOP.Set_Value = function(Player,Data,Data2)
	return Promise.new(function(resolve,_,_)
		if Player then
			if Data.Value > 0 then
				Data2.Value = 2
			else
				Data2.Value = 1
			end
		end
		resolve()
	end):catch(function(err)
		warn(err)
	end)
end

OOP.Time_Of = function(Player)
	return Promise.new(function(resolve,_,_)
		if Player then
			coroutine.wrap(function()
				if Player then
					while true do
						Player.Total_Stats.Time_Played.Value += 1	
						OOP.Set_Value(Player,Player.Boosts.x2_Coins_Time,Player.Boosts.x2_Coins)
						OOP.Set_Value(Player,Player.Boosts.x2_Pets_Time,Player.Boosts.x2_Pets)
						OOP.Set_Value(Player,Player.Boosts.x2_Gems_Time,Player.Boosts.x2_Gems)
						if Player.Boosts.x2_Gems_Time.Value > 0 then
							Player.Boosts.x2_Gems_Time.Value -= 1
						end
						if Player.Boosts.x2_Coins_Time.Value > 0 then
							Player.Boosts.x2_Coins_Time.Value -= 1
						end
						if Player.Boosts.Auto_Sell_Time.Value > 0 then
							coroutine.wrap(function()
								OOP.Sell_System_2(Player)
							end)()
							Player.Boosts.Auto_Sell_Time.Value -= 1
						end
						if Player.Boosts.x2_Pets_Time.Value > 0 then
							Player.Boosts.x2_Pets_Time.Value -= 1
						end
						task.wait(1)
					end
				end
			end)()
		end
		resolve()
	end):catch(function(err)
		warn(err)
	end)
end

OOP.Magnet_System = function(Player,Pet)
	return Promise.new(function(resolve,_,_)
		if Player and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Pet then
			if Player:DistanceFromCharacter(Pet.Position) <= Player.Stats.Range.Value * 1.9 then
				for _, v in _workspace.Points_Collect:GetChildren() do
					if Player:DistanceFromCharacter(v.A_Position.Value) <= 100 then
						if Player.AREAS[v.Name].Value == 'true' then
							if not Pet:FindFirstChild(Player.Name) then
								--Player.Stats.Tool_Power.Value if needed
								local Boost = Pet:GetAttribute("Pets") * Player.Stats.Stats.Value * Player.Boosts.x2UP_Pets.Value * Player.Boosts.x2_Pets.Value * Player.Boosts.Pet_Pets.Value * _workspace.Areas[v.Name].Boost.Value * Player.Boosts.xB_Pets.Value
								local NewDebounce = Instance.new("BoolValue")
								NewDebounce.Name = Player.Name
								NewDebounce.Parent = Pet
								Player.Stats.Pets.Value += Boost
								Player.Total_Stats.Total_Pets.Value += Boost
								coroutine.wrap(function()
									task.wait(Player.Stats.Respawn_Time.Value + 1)
									Debris:AddItem(NewDebounce,0)
								end)()
							end
						end
					end	
				end
			end
		end
		resolve()
	end):catch(function(err)
		warn(err)
	end)
end

OOP.Set_Character_Speed = function(Player)
	return Promise.new(function(resolve,_,_)
		if Player then
			local Character = Player.Character or Player.CharacterAdded:wait()
			Character.Humanoid.WalkSpeed = Player.Stats.Speed.Value
			Player.Stats.Speed.Changed:Connect(function()
				Character.Humanoid.WalkSpeed = Player.Stats.Speed.Value
			end)
			Player.CharacterAdded:Connect(function(Char)
				Char:WaitForChild('Humanoid',9999)
				Char.Humanoid.WalkSpeed = Player.Stats.Speed.Value
			end)
		end
		resolve()
	end):catch(function(err)
		warn(err)
	end)
end

OOP.Set_Bagde = function(Player)
	return Promise.new(function(resolve,_,_)
		if not Bagde_Service:UserHasBadgeAsync(Player.UserId,2146657502) then
			Bagde_Service:AwardBadge(Player.UserId,2146657502)
		end
		resolve()
	end):catch(function(err)
		warn(err)
	end)
end

OOP.Engine = function(Player,Data)
	return Promise.new(function(resolve,_,_)
		if Player then
			Player.Boosts.Pet_Coins.Value = 1
			Player.Boosts.Pet_Pets.Value = 1
			Player.Boosts.Pet_Gems.Value = 0
			if Player.Stats.Reste.Value == 'false' then
				Player.Stats.Reste.Value = 'true'
				Player.Stats.Multi.Value = 1
			end
			
			Player.leaderstats['💰Coins'].Value = OOP.Format(Player.Stats.Coins.Value)["_values"][1]
			Player.leaderstats['🐾Pets'].Value = OOP.Format(Player.Stats.Pets.Value)["_values"][1]
			Player.leaderstats['💎Gems'].Value = OOP.Format(Player.Stats.Gems.Value)["_values"][1]
			Player.leaderstats['♻Rebirths'].Value = OOP.Format(Player.Stats.Rebirths.Value)["_values"][1]
			Player.Stats.Rebirths.Changed:Connect(function()
				Player.leaderstats['♻Rebirths'].Value = OOP.Format(Player.Stats.Rebirths.Value)["_values"][1]
			end)
			Player.Stats.Coins.Changed:Connect(function()
				Player.leaderstats['💰Coins'].Value = OOP.Format(Player.Stats.Coins.Value)["_values"][1]
			end)
			Player.Stats.Pets.Changed:Connect(function()
				Player.leaderstats['🐾Pets'].Value = OOP.Format(Player.Stats.Pets.Value)["_values"][1]
			end)
			Player.Stats.Gems.Changed:Connect(function()
				Player.leaderstats['💎Gems'].Value = OOP.Format(Player.Stats.Gems.Value)["_values"][1]
			end)	
			OOP.Create_Folder(Player)
			Replicated_Storage.Remotes.Client_Event:FireClient(Player)
			OOP.Check_Game_Pass(Player)
			OOP.Pet_System_Create(Player,Data)
			OOP.Set_Character_Speed(Player)
			OOP.Time_Of(Player)
			OOP.Set_Bagde(Player)
		end
		resolve()
	end):catch(function(err)
		warn(err)
	end)
end

OOP.Create_Pet = function(Player,Pet)
	return Promise.new(function(resolve,_,_)
		if Player then
			local PlayerGui = Player:WaitForChild('PlayerGui',999)
			local UI = PlayerGui:WaitForChild('Ui',999)
			local Pet_System = UI:WaitForChild('Center_UI_Frame'):WaitForChild('Pets',999)
			local Frame = Pet_System:WaitForChild('Frame',999)
			local Template_ = script:WaitForChild("Template_Pet",999)
			if Template_ then
				local Pet_Template = Template_:Clone()
				local Pet_Model = Replicated_Storage.Pets[tostring(Pet)]
				Pet_Template.LayoutOrder = -math.floor(Pets_Info[tostring(Pet)]["Coins"])
				Pet_Template.Pet_Name.Value = Pet
				Pet_Template.Frame.Texto.Text = Pet
				Pet_Template.Frame.Level.Text = ('LVL [1]')
				Pet_Template.Name = Pet	
				Pet_Template.Parent = Frame
				coroutine.wrap(function()
					task.wait(0.1)
					Pet_Model:Clone().Parent = Pet_Template.Frame.Frame
				end)()
			end
		end
		resolve()
	end):catch(function(err)
		warn(err)
	end)
end

OOP.Pet_System_Create = function(Player,Data)
	return Promise.new(function(resolve,_,_)
		if Player then
			local PlayerGui = Player:WaitForChild('PlayerGui',999)
			local UI = PlayerGui:WaitForChild('Ui',999)
			local Pet_System = UI:WaitForChild('Center_UI_Frame'):WaitForChild('Pets',999)
			local Frame = Pet_System:WaitForChild('Frame',999)
			local Template_ = script:WaitForChild("Template_Pet", 999)
			if Template_  then
				if next(Data) ~= nil then
					for _,Pet in Data do
						local Pet_Template = Template_:Clone()
						local Pet_Model = Replicated_Storage.Pets[tostring(Pet.Nome)]
						Pet_Template.LayoutOrder = -math.floor(Pets_Info[tostring(Pet.Nome)]["Coins"])
						Pet_Template.Boost.Value = Pet.Boost
						Pet_Template.Cost.Value = Pet.Cost
						Pet_Template.Level.Value = Pet.Level
						Pet_Template.Life.Value = Pet.Life
						Pet_Template.Pet_Name.Value = Pet.Nome
						Pet_Template.Frame.Texto.Text = Pet.Nome
						Pet_Template.Frame.Level.Text = ('LVL [%s]'):format(Pet.Level)
						Pet_Template.Name = Pet.Nome				
						Pet_Template.Parent = Frame
						coroutine.wrap(function()
							task.wait(0.1)
							if Pet_Template then
								if Template_:FindFirstChild('Frame') then
									if Template_:FindFirstChild('Frame'):FindFirstChild('Frame')  then
										Pet_Model:Clone().Parent = Pet_Template.Frame.Frame
									end
								end
							end
						end)()
					end
				end
			end
		end
		resolve()
	end):catch(function(err)
		warn(err)
	end)
end

OOP.Sell_System_2 = function(Player)
	return Promise.new(function(resolve,_,_)
		if Player and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
			if Player.Stats.Pets.Value > 0 then
				if Player.Stats.Rebirths.Value == 0 then
					Player.Stats.Coins.Value += Player.Stats.Pets.Value * Player.Stats.Stats.Value * Player.Boosts.x2UP_Coins.Value * Player.Boosts.x2_Coins.Value * Player.Boosts.Pet_Coins.Value * Player.Boosts.xB_Coins.Value * 3
					Player.Total_Stats.Total_Coins.Value += Player.Stats.Pets.Value * Player.Stats.Stats.Value* Player.Boosts.x2UP_Coins.Value * Player.Boosts.x2_Coins.Value * Player.Boosts.Pet_Coins.Value * Player.Boosts.xB_Coins.Value *3
					Player.Stats.Pets.Value = 0
				else
					Player.Stats.Coins.Value += Player.Stats.Pets.Value * (math.round(math.sqrt(Player.Stats.Rebirths.Value)*100)/100) * Player.Stats.Stats.Value * Player.Boosts.x2UP_Coins.Value * Player.Boosts.x2_Coins.Value * Player.Boosts.Pet_Coins.Value * Player.Boosts.xB_Coins.Value * 3
					Player.Total_Stats.Total_Coins.Value += Player.Stats.Pets.Value * (math.round(math.sqrt(Player.Stats.Rebirths.Value)*100)/100) * Player.Stats.Stats.Value* Player.Boosts.x2UP_Coins.Value * Player.Boosts.x2_Coins.Value * Player.Boosts.Pet_Coins.Value * Player.Boosts.xB_Coins.Value *3
					Player.Stats.Pets.Value = 0
				end
			end
		end
		resolve()
	end):catch(function(err)
		warn(err)
	end)
end

OOP.Sell_System = function(Player,P)
	return Promise.new(function(resolve,_,_)
		if Player and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
			local Character = Player.Character
			if Player:DistanceFromCharacter(Vector3.new(P.Position.X,Character.HumanoidRootPart.Position.Y,P.Position.Z)) then
				if Player.Stats.Pets.Value > 0 then
					if Player.Stats.Rebirths.Value == 0 then
						Player.Stats.Coins.Value += Player.Stats.Pets.Value * Player.Stats.Stats.Value * Player.Boosts.x2UP_Coins.Value * Player.Boosts.x2_Coins.Value * Player.Boosts.Pet_Coins.Value * Player.Boosts.xB_Coins.Value * P.Boost.Value
						Player.Total_Stats.Total_Coins.Value += Player.Stats.Pets.Value * Player.Stats.Stats.Value* Player.Boosts.x2UP_Coins.Value * Player.Boosts.x2_Coins.Value * Player.Boosts.Pet_Coins.Value * Player.Boosts.xB_Coins.Value * P.Boost.Value
						Player.Stats.Pets.Value = 0
					else
						Player.Stats.Coins.Value += Player.Stats.Pets.Value * (math.round(math.sqrt(Player.Stats.Rebirths.Value)*100)/100) * Player.Stats.Stats.Value * Player.Boosts.x2UP_Coins.Value * Player.Boosts.x2_Coins.Value * Player.Boosts.Pet_Coins.Value * Player.Boosts.xB_Coins.Value * P.Boost.Value
						Player.Total_Stats.Total_Coins.Value += Player.Stats.Pets.Value * (math.round(math.sqrt(Player.Stats.Rebirths.Value)*100)/100) * Player.Stats.Stats.Value* Player.Boosts.x2UP_Coins.Value * Player.Boosts.x2_Coins.Value * Player.Boosts.Pet_Coins.Value * Player.Boosts.xB_Coins.Value * P.Boost.Value
						Player.Stats.Pets.Value = 0
					end
				end
			end
		end
		resolve()
	end):catch(function(err)
		warn(err)
	end)
end

local Debounce_Pet = {}
Replicated_Storage.Remotes.Buy_Pet.OnServerEvent:Connect(function(Player,_,Data)
	Promise.new(function(resolve,_,_)
		if Player then
			if not Debounce_Pet[Player.Name] then
				if not Debounce_Pet[Player.Name] then
					Debounce_Pet[Player.Name] = true
					Debounce_Pet[Player.Name] = true
					if Data[1].Type.Value == 'Robux' then
						Market_Place_Service:PromptProductPurchase(Player,Data[1].ID.Value)
					else
						if Data[2] == 1 then
							if Player.Stats[Data[1].Type.Value].Value >= Data[1].Cost.Value then
								if OOP.Check_No_Full(Player)["_values"][1] == true then
									OOP.Random_Pet(Player,Data[1])
									Replicated_Storage.Remotes.Egg_Animation:FireClient(Player,List)
								else
									Replicated_Storage.Remotes.Client_Menssage:FireClient(Player,'Pet Inventory Full!')
									Debounce_Pet[Player.Name] = nil
									resolve()
								end
							else
								Replicated_Storage.Remotes.Client_Menssage:FireClient(Player,('You Need More %s'):format(Data[1].Type.Value))
								Debounce_Pet[Player.Name] = nil
								resolve()
							end			
							List = {}
						elseif Data[2] == 3 then
							if Player.GM.OpenEggs.Value == true then
								if Player.Stats[Data[1].Type.Value].Value >= Data[1].Cost.Value * 3 then
									if OOP.Check_No_Full(Player)["_values"][1] == true then
										for _ = 1,3 do
											OOP.Random_Pet(Player,Data[1])
										end
										Replicated_Storage.Remotes.Egg_Animation:FireClient(Player,List)
										List = {}
									else
										Replicated_Storage.Remotes.Client_Menssage:FireClient(Player,'Pet Inventory Full!')
										Debounce_Pet[Player.Name] = nil
										resolve()
									end
								else
									Replicated_Storage.Remotes.Client_Menssage:FireClient(Player,('You Need More %s'):format(Data[1].Type.Value))
									Debounce_Pet[Player.Name] = nil
									resolve()
								end		
							else
								Replicated_Storage.Remotes.Client_Menssage:FireClient(Player,'You Need Gamepass To Buy Triple Eggs!')
								Debounce_Pet[Player.Name] = nil
								resolve()
							end
						end
					end
					task.wait(5.2)
					Debounce_Pet[Player.Name] = nil
				end		
			else
				resolve()
			end
		end
		resolve()
	end):catch(function(err)
		warn(err)
	end)
end)

Client_Event_.OnServerEvent:Connect(function(Player,Signal,Data)
	Promise.new(function(resolve,_,_)
		if Player then
			if Signal == 'Settings' then 
				if Player.Settings[Data].Value == 'true' then
					Player.Settings[Data].Value = 'false'
				else
					Player.Settings[Data].Value = 'true'
				end
			elseif Signal == 'Robux_Shop_Product' then
				if Data == 1826183019  then
					if (os.time() - Player.Stats.Chest_Time.Value) >= 3600 or Player.Stats.Chest_Time.Value == 0 then
						Replicated_Storage.Remotes.Client_Menssage:FireClient(Player,'Redeem The Chest First Before Buying A Respawn!')
						resolve()
					else
						Market_Place_Service:PromptProductPurchase(Player,Data)
						resolve()
					end
				else
					Market_Place_Service:PromptProductPurchase(Player,Data)
					resolve()
				end
			elseif Signal == 'Robux_Shop_GamePass' then
				Market_Place_Service:PromptGamePassPurchase(Player,Data)
				resolve()
			end
		end
		resolve()
	end):catch(function(err)
		warn(err)
	end)
end)

Event_.Event:Connect(function(Player,Signal_List,Pet)
	Promise.new(function(resolve,_,_)
		if Player then
			if Signal_List then
				if Signal_List == 0 then
					OOP.Engine(Player,Pet)
				elseif Signal_List == 1 then
					OOP.Magnet_System(Player,Pet)
				elseif Signal_List == 2 then
					OOP.Sell_System(Player,Pet)
				elseif Signal_List == 3 then
					OOP.Chest(Player)
				elseif Signal_List == 4 then
					OOP.Sell_System_2(Player)
				elseif Signal_List == 9 then
					OOP.Chest2_Event(Player)
				else
					warn('Signal not found, please resubmit')
				end	
			else
				warn('Waiting for signal, not found, result is nil, please try again with a signal')
			end
		end
		resolve()
	end):catch(function(err)
		warn(err)
	end)
end)

Replicated_Storage.Remotes.Add_Pet.Event:Connect(function(Player,Pet,Animation,ID)
	Promise.new(function(resolve,_,_)
		if Player then
			if Animation == true then
				if ID then
					if ID == 1826187382 then
						OOP.Random_Pet(Player,_workspace.Eggs_Service["Robux Egg 3"],true)
						Replicated_Storage.Remotes.Egg_Animation:FireClient(Player,List)
						List = {}
					elseif ID == 1826187947 then
						OOP.Random_Pet(Player,_workspace.Eggs_Service["Robux Egg 2"],true)
						Replicated_Storage.Remotes.Egg_Animation:FireClient(Player,List)
						List = {}		
					elseif ID == 1826187810 then
						OOP.Random_Pet(Player,_workspace.Eggs_Service["Robux Egg 1"],true)
						Replicated_Storage.Remotes.Egg_Animation:FireClient(Player,List)
						List = {}	
						--
					elseif ID == 1826188100 then
						OOP.Random_Pet(Player,_workspace.Eggs_Service["Beach Robux Egg"],true)
						Replicated_Storage.Remotes.Egg_Animation:FireClient(Player,List)
						List = {}
					elseif ID == 1826188457 then
						OOP.Random_Pet(Player,_workspace.Eggs_Service["Mine Robux Egg"],true)
						Replicated_Storage.Remotes.Egg_Animation:FireClient(Player,List)
						List = {}
					elseif ID == 1826189643 then
						OOP.Random_Pet(Player,_workspace.Eggs_Service["Snow Robux Egg"],true)
						Replicated_Storage.Remotes.Egg_Animation:FireClient(Player,List)
						List = {}
					elseif ID == 1826189757 then
						OOP.Random_Pet(Player,_workspace.Eggs_Service["Ice Robux Egg"],true)
						Replicated_Storage.Remotes.Egg_Animation:FireClient(Player,List)
						List = {}
					elseif ID == 1826189902 then
						OOP.Random_Pet(Player,_workspace.Eggs_Service["Western Robux Egg"],true)
						Replicated_Storage.Remotes.Egg_Animation:FireClient(Player,List)
						List = {}
					elseif ID == 1826187179 then
						OOP.Random_Pet(Player,_workspace.Eggs_Service["Toilet Robux Egg"],true)
						Replicated_Storage.Remotes.Egg_Animation:FireClient(Player,List)
						List = {}
					elseif ID == 1826187611 then
						OOP.Random_Pet(Player,_workspace.Eggs_Service["Skibi Dop Egg"],true)
						Replicated_Storage.Remotes.Egg_Animation:FireClient(Player,List)
						List = {}
					end
				end
			else
				OOP.Create_Pet(Player,Pet)
			end
			resolve()
		end
		resolve()
	end):catch(function(err)
		warn(err)
	end)
end)

Aura_Event.Event:Connect(function(Player,_,Char)
	Promise.new(function(resolve,_,_)
		if Player then
			if Char then
				OOP.Load_Aura(Char)
			end
		end
		resolve()
	end):catch(function(err)
		warn(err)
	end)
end)

Replicated_Storage.Remotes.Shop_Robux.Event:Connect(function(Player,Id)
	OOP.Check_Game_Pass(Player,Id)
end)

Players.PlayerAdded:Connect(function(Player)
	Player.CharacterAdded:Connect(function(Char)
		Promise.new(function(resolve,_,_)
			local Check = Char:WaitForChild('Humanoid',9999)
			local Check_2 = Player:WaitForChild('Stats',9999)
			local Check_3 = Player:WaitForChild('PETS',9999)
			if Check and Check_2 and Check_3 then 
				task.wait(1) -- buffer
			end
			for _,v in require(Replicated_Storage.Modules.Auras) do
				if v.Stats == Player.Stats.Aura.Value then
					OOP.Load_Aura(Char)
				end
			end
			resolve()
		end):catch(function(err)
			warn(err)
		end)
	end)
end)

Players.PlayerRemoving:Connect(function(Player)
	OOP.Clear_Folder(Player)
end)
