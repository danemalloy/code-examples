local HTTP = game:GetService("HttpService")
local RPS = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local util = ServerScriptService:WaitForChild('Util')

local darainStore = require(util:WaitForChild("darainStore"))
local DS = darainStore.new('player-bans-v0.0.0')

local moderation = {
	authorized = {
		group = {
			"255",
			"254",
			"253",
			"252",
			"251"
		};
		id = {
			1672561194,
			567576529 -- dane
		}
	}
}

moderation.__index = moderation

function moderation.new()
	local self = {}
	self.players = {}
	self.serverBans = {}
	self.cmd = require(script:WaitForChild("cmd"))
	
	return setmetatable(self, moderation)
end 

function moderation:updatePlayerTracking(player)
	if self.players[player] then self.players[player] = nil end
	self.players[player] = tick()
	self:checkBan(player)
end

function moderation:checkBan(player)
	if not player then return end
	local key = player.UserId
	local data = DS:GetData(key .. "-banList")
	if data and data.Temp then
		print(data)
		local expiration = DateTime.fromIsoDate(data.Date)
		local currentDate = DateTime.now()
		local localTime = expiration:ToLocalTime()
		
		if expiration.UnixTimestamp > currentDate.UnixTimestamp then
			print("player is still temp banned")
			player:Kick(
				"You are banned. Expires " .. localTime.Month .. "/" .. localTime.Day .. "/" .. localTime.Year .. ":".. data.Reason
			)
		else
			moderation:clearBan(player)
		end
	elseif data and data.Perm then
		print(data)
		print("player is perma banned")
		player:Kick("You are banned. Expires never: " .. data.Reason)
	end
	
	if table.find(self.serverBans, key) then print("player is server banned") player:Kick("You are banned from this server. Please rejoin") end
end

function moderation:clearBan(player)
	if not player then return end
	local key = player.UserId
	if not key then key = game:GetService("Players"):GetUserIdFromNameAsync(player) end
	DS:SetData(key .. "-banList", {data = false})
	
	print("ban cleared")
end

function moderation:printBans(player)
	if not player then return end
	local key = player.UserId
	if not key then key = game:GetService("Players"):GetUserIdFromNameAsync(player) end
	
	print(DS:GetData(key .. "-banList"))
end

function moderation:setBan(UserId, data)
	if not UserId then return end
	DS:SetData(UserId .. "-banList", data)
end

return moderation
