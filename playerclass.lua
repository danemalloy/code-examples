local RPS = game:GetService('ReplicatedStorage')
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")
local MarketService = game:GetService("MarketplaceService")


local util = RPS.TS:WaitForChild('cross-server-util')
local utilevents = RPS["cross-server-util-events"]

local boatdata = require(util:WaitForChild('boatdata'))
local dailyrewards = require(script:WaitForChild('dailyrewardsdata'))

local newdata = require(script:WaitForChild('newdata'))
local cashhandler = require(script:WaitForChild('cashhandler'))
local island = require(script:WaitForChild('islanddata'))
local levelHandler = require(script:WaitForChild("levelhandler"))
local boatdatasaving = require(script.Parent.BoatClass:WaitForChild("boatdatasaving"))
local placementData = require(script.Parent.BoatClass:WaitForChild("placementdata"))

local classes = game:GetService('ServerScriptService').TS

local boatClass = require(classes:WaitForChild('BoatClass'))

local PlayerClass = {}
PlayerClass.__index = PlayerClass;

--[[
	util:
	
	self:Fire(funcKey, ...) -> Fires information down to the client which should be handled through the listener module
		
		[funcKey] : funcKey
		[...] : argsToPass
]]

local Levels = "[100,200,300,400,500,600,700,800,900,1000,1100,1200,1300,1400,1500,1600,1700,1800,1900,2000,2100,2200,2300,2400,2500,2600,2700,2800,2900,3000,3100,3200,3300,3400,3500,3600,3700,3800,3900,4000,4100,4200,4300,4400,4500,4600,4700,4800,4900,5000,5100,5200,5300,5400,5500,5600,5700,5800,5900,6000,6100,6200,6300,6400,6500,6600,6700,6800,6900,7000,7100,7200,7300,7400,7500,7600,7700,7800,7900,8000,8100,8200,8300,8400,8500,8600,8700,8800,8900,9000,9100,9200,9300,9400,9500,9600,9700,9800,9900,10000]"
Levels = HttpService:JSONDecode(Levels)

function PlayerClass.new(player, data)
	local self
	if not data then
		self = newdata
	else
		self = data
	end
	
	self.player = player
	
	self.event = utilevents.Replicate
	self.bindable = utilevents.Send
	
	self.connections = {}
	self.boats = {}
	
	-- Settings
	self.DAILY_REWARD_TIME = 24 -- hours
	
	
	return setmetatable(self, PlayerClass)
end

function PlayerClass:GetCash()
	return self.Cash
end

-- # Relative cash and multiplier purchase update methods
function PlayerClass:AddCash(amount)
	self.Cash += self.subclasses.cashhandler:Calculate(amount)
	self.cash_instance.Value = self.Cash
	
	return true
end

local  function GetXPForLevel(Level)
	return 60 + Level * 10
end


function PlayerClass:AddXP(amount)
	self.XP += amount
	
	if self.XP >= GetXPForLevel(self.Level) then
		repeat
			wait()
			self.XP -= GetXPForLevel(self.Level)
			self.level_instance.Value += 1
		until self.XP < GetXPForLevel(self.Level)
	end
	
	self.xp_instance.Value = self.XP
	return true
end


function PlayerClass:RemoveCash(amount)
	self.Cash -= amount
	self.cash_instance.Value = self.Cash

	return true
end

function PlayerClass:LoadUpBoatPercentages()
	local Data = boatdatasaving.LoadData(self.player)
	
	if not Data then return end;
	
	for i,v in pairs(Data) do
		if not v.Progress  then return end
		local percentage = math.round(v.Progress/#placementData[v.Name]*100)
		if percentage < 100 then
			RPS.Remotes.UpdateBoatFrame:FireClient(self.player,v.Name,percentage,"BUILD")
		else
			RPS.Remotes.UpdateBoatFrame:FireClient(self.player,v.Name,percentage,"DRIVE")
		end

	end
end

--Boat related methods
function PlayerClass:SpawnBoat(boatname)
	local boat = boatClass.new(boatname, self)
	local boatsize = boat:GetSize()

	if self.boats[boatsize] then
		self.boats[boatsize]:Destroy()
		self.boats[boatsize] = nil
	end
	self.boats[boatsize] = boat

	local boatspawns = self:GetBoatSpawns()
	boat:Spawn(boatspawns)
end

function PlayerClass:AddBoat(boatName)
	table.insert(self.playerBoats, boatName);
	self:addBoatToLeaderstats(boatName);
	
	return
end


function PlayerClass:DestroyBoat(boatClass)
	local boatsize = boatClass:GetSize();
	
	boatClass:saveData()
	boatClass:setBuildPercentage()
	boatClass:Destroy();
	self.boats[boatsize] = nil;
	
	task.wait(.5) 
end

function PlayerClass:BuildBoat(boatName)
	if not table.find(self.playerBoats, boatName) then return end;
	
	return self:SpawnBoat(boatName)
end

function PlayerClass:PurchasedBundle()
	return self.purchasedBundle;
end

function PlayerClass:PurchaseBoat(boatName)
	local price = boatdata.Cash_Boats[boatName]
	
	-- Check if enough cash
	if self:GetCash() < price then return end;
	
	-- Check if player already owns boat
	if self.playerBoats[boatName] then return end
	
	self:RemoveCash(price)
	
	return self:AddBoat(boatName);
end

function PlayerClass:AddVIPBoats()
	-- Looping through boat data
	for _, boatName in pairs(boatdata.VIP_Boats) do
		if table.find(self.playerBoats, boatName) then continue end;
		
		self:AddBoat(boatName)
	end
	
	return;
end

-- Redeem code and daily reward methods
function PlayerClass:ClaimReward(key)
	local rewardValue = dailyrewards[key]
	game:GetService("ReplicatedStorage").Remotes.CustomSound:FireClient(self.player,"") --Sound For succesful daily reward claim
	if typeof(rewardValue) == 'number' then
		self:AddCash(rewardValue);
	elseif typeof(rewardValue) == 'string' then
		self:AddBoat(rewardValue);
	end
	
	self:dailyRewardClaimed(key);
	
	return;
end

function PlayerClass:ClaimGroupReward()
	if self.GroupReward then return end
	self:AddCash(5000)
end

function PlayerClass:AddNewReward(key)
	if key == nil then return end
	local dailyReward = Instance.new('BoolValue', self.player.DailyRewards);
	dailyReward.Name = key;
	
	return
end

function PlayerClass:NextReward()
	if not self.dailyRewardTime then return end
	
	local claimedRewards = {};
	
	for _, claimed in pairs(self.player:WaitForChild('ClaimedRewards'):GetChildren()) do
		table.insert(claimedRewards, tonumber(claimed.Name));
	end
	
	table.sort(claimedRewards, function(a, b)
		return a > b
	end)
	if not claimedRewards then return end;
	
	local nextRewardKey = claimedRewards[1] + 1
	if (os.time() - self.dailyRewardTime)/3600 < self.DAILY_REWARD_TIME then return end
	
	self:AddNewReward(nextRewardKey);
end

function PlayerClass:ClaimDailyReward(key)
	-- First time player claims a reward
	if not self.dailyRewardTime then
		self.dailyRewardTime = os.time();
		
		self:ClaimReward(key)
		return;
	end
	
	-- Check if elapsed time is greater than 24 hours so they can claim a reward
	local elapsed = os.time() - self.dailyRewardTime
	if elapsed/3600 < self.DAILY_REWARD_TIME then return end;
	
	self:ClaimReward(key);
	
	return;
end


function PlayerClass:RedeemCodeType(codeType, reward)
	local rewardMethods = {
		Cash_Codes = 'AddCash',
		Boat_Codes = 'nil',
	}
	
	self[rewardMethods[codeType]](self, reward);
	return self.event:FireClient(self.player, 'redeemedCode');
end

function PlayerClass:RedeemCode(code, codeType)
	local codes = require(util:WaitForChild('codes'));
	
	if self.redeemedCodes[code] then
		self.event:FireClient(self.player, 'alreadyRedeemed');
		return;
	end
	
	self.redeemedCodes[code] = true;
	
	local reward = codes[codeType][code];
	self:RedeemCodeType(codeType, reward);
	
	return;
end

-- Island related methods
function PlayerClass:SpawnAtIsland()
	return self.subclasses.island:Spawn()
end

function PlayerClass:GetBoatSpawns()
	return self.subclasses.island:GetIslandBoatSpawns()
end

function PlayerClass:GetBoatSpawnButtons()
	return self.subclasses.island:GetIslandBoatSpawnButtons()
end
	-- Save temporary multipliers (timed)
	
function PlayerClass:SaveTempMultipliers()
	-- timed_multipliers : {[productId] = timeLeft}
	--if not self or self.subclasses then return end;
	
	local data = self.subclasses.cashhandler:GetTimedMultipliers()
	if not next(data) then
		self.timed_multipliers = nil
	else
		self.timed_multipliers = data
	end
end

function PlayerClass:ResumeTimedMultipliers()
	return self.subclasses.cashhandler:StartGlobalCountdown()
end

-- Gamepass and product purchase handle method
function PlayerClass:UpdateProductAction(method, productId)
	-- If starterbundle then purchased is true
	if productId == 213437998 then
		self.purchasedBundle = true;
		
		self.Cash += 30000
		self.cash_instance.Value = self.Cash
	end
	
	for _, subclass in pairs(self.subclasses) do
		if not subclass[method] then continue end
		subclass[method](subclass, productId) -- [subclass? : self]
		
	end
	
	return
end

-- ! Initial setup and final removal methods 
function PlayerClass:Setup()	
	self:setup_leaderstats()
	self:setup_subclasses()
	
	self:setup_cashloop()
end

function PlayerClass:SaveAllInternal()
	-- Save existing subclass data
	self:SaveTempMultipliers()
	
	return
end

function PlayerClass:GetDataForSaving()
	local data = {}

	for k, v in pairs(self) do
		data[k] = v
	end

	data.player = nil
	data.subclasses = nil
	data.event = nil
	data.connections = nil	
	data.bindable = nil
	data.cash_instance = nil
	data.leaderstats = nil
	data.boats = nil
	data.xp_instance = nil
	data.level_instance = nil
	data.DAILY_REWARD_TIME = nil
	data.QuickBuild = nil
	data.timer_boost = nil
	
	return data
end

function PlayerClass:Fire(...)
	return self.event:FireClient(self.player, ...)
end

function PlayerClass:Send(...)
	return self.bindable:Fire(...)
end


-- leaderstats creation
function PlayerClass:setup_leaderstats()	
	self.leaderstats = Instance.new('Folder', self.player)
	self.leaderstats.Name = 'leaderstats'
	
	self.cash_instance = Instance.new('IntValue', self.leaderstats)
	self.cash_instance.Name = 'Cash'
	self.cash_instance.Value = self.Cash
	
	self.xp_instance = Instance.new('NumberValue', self.player)
	self.xp_instance.Name = 'XP'
	self.xp_instance.Value = self.XP
		
	self.level_instance = Instance.new('IntValue', self.leaderstats)
	self.level_instance.Name = 'Level'
	self.level_instance.Value = self.Level
	
	self.timer_boost = Instance.new('IntValue', self.player);
	self.timer_boost.Name = 'TimerBoost';
	
	
	self:addBoatsToLeaderstats();
	self:setDailyRewardData();
	
	local oldLvl = self.Level
	
	self.level_instance.Changed:Connect(function(newValue)
		self.Level = newValue
		RPS.Remotes.LevelChanged:FireClient(self.player)
		levelHandler.UpdateOverHeadUI(self.player)
	end)
	
	self.xp_instance.Changed:Connect(function(newValue)
		self.XP = newValue
		RPS.Remotes.LevelChanged:FireClient(self.player)
		levelHandler.UpdateOverHeadUI(self.player)
	end)
	
	local oldLevel = self.level_instance.Value
	self.level_instance.Changed:Connect(function(newLevel)		
		local tempOldLevel = oldLevel
		oldLevel = newLevel

		local Character = self.player.Character

		if Character then	
			for i = 1, (newLevel - tempOldLevel) do
				task.spawn(function()
					local LevelUp = ServerStorage.Assets.LevelUp:Clone()

					LevelUp.Motor6D.Part0 = LevelUp
					LevelUp.Motor6D.Part1 = Character.HumanoidRootPart

					LevelUp.Motor6D.C0 = CFrame.new(0, 2, 0)

					LevelUp.Parent = Character

					local Sound = ServerStorage.Assets.Level_up:Clone()
					Sound.Parent = Character

					Sound:Play()

					Sound.Ended:Connect(function()
						game.Debris:AddItem(Sound, 1)
					end)

					local EmitPoint = LevelUp.EmitPoint

					EmitPoint.Arrow:Emit(1)
					EmitPoint.Shine:Emit(3)
					EmitPoint.Burst:Emit(1)
					EmitPoint.Sparks:Emit(50)
					EmitPoint.Shockwave:Emit(5)
					LevelUp.Lines.Enabled = true
					LevelUp.Sparkles.Enabled = true
					wait(1.5)
					LevelUp.Lines.Enabled = false
					LevelUp.Sparkles.Enabled = false
			
					game.Debris:AddItem(LevelUp, 3)
				end)
				
				task.wait(0.1)
			end
		end
	end)
	
	
end

function PlayerClass:SetQuickBuild(t)
	self.QuickBuild = t
end

function PlayerClass:SetDailyRewardTimer()
	local timer = Instance.new('NumberValue', self.player);
	timer.Name = 'DailyRewardTimer';
	
	timer.Value = self.dailyRewardTime or 0;
end

function PlayerClass:dailyRewardClaimed(key)
	table.remove(self.dailyRewards, table.find(self.dailyRewards, key));
	self.player.DailyRewards[key]:Destroy();
	
	self.player.DailyRewardTimer.Value = os.time();
	
	local claimedReward = Instance.new('BoolValue', self.player.ClaimedRewards);
	claimedReward.Name = key;
	
	table.insert(self.claimedRewards, key);
	
	return;
end


function PlayerClass:setDailyRewardData()
	local dailyRewardsFolder = Instance.new('Folder', self.player);
	dailyRewardsFolder.Name = 'DailyRewards'
	
	local claimedRewardsFolder = Instance.new('Folder', self.player);
	claimedRewardsFolder.Name = 'ClaimedRewards'
	
	self:SetDailyRewardTimer();
	
	for _, claimed in pairs(self.claimedRewards) do
		local claimedReward = Instance.new('BoolValue', claimedRewardsFolder);
		claimedReward.Name = claimed;
	end
	
	self:NextReward();
	
	for _, reward in pairs(self.dailyRewards) do
		if dailyRewardsFolder:FindFirstChild(reward) then continue end;
		
		local dailyReward = Instance.new('BoolValue', dailyRewardsFolder);
		dailyReward.Name = reward;
	end
	
	return;
end

function PlayerClass:addBoatToLeaderstats(boatName)
	local playerBoatInfo = self.player.playerBoats;
	
	local boatValue = Instance.new('StringValue', playerBoatInfo);
	boatValue.Name = boatName;
	
	return;
end

function PlayerClass:addBoatsToLeaderstats()
	local playerBoatInfo = Instance.new('Folder', self.player);
	playerBoatInfo.Name = 'playerBoats';
	
	-- Looping through player boat data
	for _, boat in pairs(self.playerBoats) do
		self:addBoatToLeaderstats(boat);
	end
	
	return;
end

function PlayerClass:GetDefaultCashLoopSettings()
	return self.subclasses.cashhandler:GetSettings()
end

function PlayerClass:setup_cashloop()
	self.cashloop_amount = Instance.new('IntValue', self.player);
	self.cashloop_amount.Name = 'cashloop_amount';
	
	local defaultCash, defaultTime = self:GetDefaultCashLoopSettings()
	
	coroutine.wrap(function()
		while true do
			task.wait(defaultTime)
			if not self.player then break end
			
			self.cashloop_amount.Value = self.subclasses.cashhandler:Calculate(defaultCash);
			self:AddCash(defaultCash)
			levelHandler.UpdateOverHeadUI(self.player)
		end
	end)()
end


-- ! Set up subclasses
function PlayerClass:setup_subclasses()
	self.subclasses = {}
	local subclasses = {
		['cashhandler'] = {constructor = cashhandler.create, arguments = {self.player, self.timed_multipliers}};
		['island'] = {constructor = island.new, arguments = {self.player}}
	}

	for n, subclass_data in pairs(subclasses) do
		local k = subclass_data.constructor(table.unpack(subclass_data.arguments))
		self.subclasses[n] = k
	end
	
	self.subclasses.cashhandler:StartGlobalCountdown()
	
	return
end

function PlayerClass:Destroy()
	-- Destroy subclass information
	self.subclasses.island:Remove()
	
	-- Destroy all connections
	for _, connection in pairs(self.connections) do
		if not connection then continue end
		
		connection:Disconnect()
	end
	
	-- Cleanup
	setmetatable(self, nil)
	table.clear(self)
	table.freeze(self)
	
	return
end

return PlayerClass
