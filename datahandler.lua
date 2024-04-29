-- written by dane1up
-- Services:
local Players = game:GetService("Players")
local DatastoreService = game:GetService("DataStoreService")
local ServerStorage = game:GetService("ServerStorage")
local Run = game:GetService("RunService")
local ProfileService = require(script.ProfileService)
local RobaseService = require(script.RobaseService)
local Compressor  = require(script.Compressor)

-- Database:
local Firebase = DatastoreService:GetDataStore("Firebase")
local ProfileTemplate = require(script.ProfileTemplate)

-- DO NOT TOUCH
local Robase = RobaseService.new(
	Firebase:GetAsync("URL"),
	Firebase:GetAsync("AUTH")
)

local Backups = Robase:GetRobase()

-- Functions:
local Datastore = {}
Datastore.__index = Datastore

function Datastore:PlayerAdded(Player: Player)
	if not Player then warn("No player") return end
	local Profile = self.ProfileStore:LoadProfileAsync("plr-" .. Player.UserId)

	if Profile == nil then Player:Kick("Error loading your datastore profile. Please rejoin.") return end

	Profile:AddUserId(Player.UserId)
	Profile:Reconcile() -- this is for when we add new data to the template to fill in missing data
	Profile:ListenToRelease(function()
		self._Profiles[Player] = nil
		Player:Kick("Profile released")
	end)

	if Player:IsDescendantOf(Players) == true then
		self._Profiles[Player] = Profile
		print("player data loaded | ")
		-- profile successfully loaded :D
	else
		-- player left before data was loaded
		Profile:Release()
	end
end

function Datastore:PlayerRemoving(Player: Player)
	if not Player then warn("No player") return end
	if self._Profiles[Player] then
		local PlayerProfile = self._Profiles[Player]

		if not Run:IsStudio() then
			local ToSave = {
				["c"] = Compressor.Encode(PlayerProfile["Data"]["Coins"]);
				["g"] = Compressor.Encode(PlayerProfile["Data"]["Gems"]);
				["s"] = Compressor.Encode(PlayerProfile["Data"]["Spins"]);
				["x"] = Compressor.Encode(PlayerProfile["Data"]["XP"]);
				["p"] = Compressor.Encode(PlayerProfile["Data"]["Prestige"]);
				["k"] = Compressor.ConvertData(PlayerProfile["Data"]["Weapons"]["OwnedKnives"], "Weapons");
				["g2"] = Compressor.ConvertData(PlayerProfile["Data"]["Weapons"]["OwnedGuns"], "Weapons");
				["r"] = Compressor.ConvertData( PlayerProfile["Data"]["Radios"]["Owned"], "Radios") or {};
				["p2"] = Compressor.ConvertData(PlayerProfile["Data"]["Perks"]["Owned"], "Perks") or {};
				["e"] = Compressor.ConvertData(PlayerProfile["Data"]["Effects"]["Owned"], "Effects") or {};
				["e2"] = Compressor.ConvertData(PlayerProfile["Data"]["Emotes"]["Owned"], "Emotes") or {};
				["t"] = Compressor.ConvertData(PlayerProfile["Data"]["Toys"]["Owned"], "Toys") or {};
				["p3"] = Compressor.ConvertData(PlayerProfile["Data"]["Pets"]["Owned"], "Pets") or {};
				["o"] = Compressor.ConvertData(PlayerProfile["Data"]["Outfits"]["Owned"], "Outfits") or {};
				["s2"] = Compressor.ConvertData(PlayerProfile["Data"]["Stats"]["Owned"], "Stats") or {};
			}

			Backups:SetAsync(tostring(Player.UserId), ToSave, "PUT")
		end

		PlayerProfile:Release()
		self._Profiles[Player] = nil
	end
end

-- Profile related functions
function Datastore:GetPlayerProfile(Player: Player)
	if not Player then warn("No player") return end
	if not self._Profiles[Player]["Data"] then warn("No data for player: " .. Player.Name) return end
	return self._Profiles[Player]["Data"]
end

function Datastore:IsPlayerProfile(Player: Player)
	if not Player then warn("No player") return false end
	if not self._Profiles[Player] or not self._Profiles[Player]["Data"] then return false end
	return true
end

function Datastore:WipeProfile(Player: Player)
	if not Player then warn("No player") return end
	self.ProfileStore:WipeProfileAsync("plr-" .. Player.UserId)
end

-- Data related functions
function Datastore:GetPlayerDataAt(Player: Player, DataName: string)
	if not Player then warn("No player") return end
	if not self._Profiles[Player]["Data"][DataName] then warn("No data found at reference: " .. DataName) return end
	return self._Profiles[Player]["Data"][DataName]
end

function Datastore:UpdateDataAt(Player: Player, DataName: string, Value: number)
	if not Player then warn("No player") return end
	if not self._Profiles[Player]["Data"][DataName] then warn("No data found at reference: " .. DataName) return end
	self._Profiles[Player]["Data"][DataName] = Value
end

function Datastore:Equip(Player: Player, Type: string, ItemName: string)
	if not Player then warn("No player") return end
	if not self._Profiles[Player]["Data"] then warn("No player profile") return end
	if Type == "Gun" then
		self._Profiles[Player]["Data"]["Weapons"]["Equipped"]["Gun"] = ItemName
	elseif Type == "Knife" then
		self._Profiles[Player]["Data"]["Weapons"]["Equipped"]["Knife"] = ItemName
	end
end

function Datastore:GetEquipped(Player: Player, Type: string)
	if not Player then warn("No player") return end
	if not self._Profiles[Player] or not self._Profiles[Player]["Data"][Type]["Equipped"] then warn("Could not get type " .. Type .. " for player " .. Player.Name) return end
	return self._Profiles[Player]["Data"][Type]["Equipped"]
end

function Datastore:GetEquippedWeapon(Player: Player, Type: string)
	if not Player then warn("No player") return end
	if not self._Profiles[Player] or not self._Profiles[Player]["Data"]["Weapons"]["Equipped"][Type] then warn("Could not get type " .. Type .. " for player " .. Player.Name) return end
	return self._Profiles[Player]["Data"]["Weapons"]["Equipped"][Type]
end

function Datastore:IsVIP(Player:Player)
	if not Player then warn("No player") return end
	if not self._Profiles[Player]["Data"] then warn("No data found for player") return end
	return self._Profiles[Player]["Data"]["IsVIP"]
end

-- initializer
Datastore.new = function(DatastoreName)
	local self = setmetatable({}, Datastore)

	self.ProfileStore = ProfileService.GetProfileStore(
		DatastoreName,
		ProfileTemplate
	)

	self._Profiles = {} -- this table is never to be referenced outside of this script

	return self
end

return Datastore
