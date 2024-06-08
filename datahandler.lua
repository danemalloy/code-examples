-- written by dane1up

local Replicated = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Run = game:GetService("RunService")

local profileService = require(script.Parent.Parent.ServerLibraries.ProfileService)
local datastoreKey = "Testing_v0.0.2"
local template = require(script.Parent.ProfileTemplate)
local profileStore = profileService.GetProfileStore(datastoreKey, template)

local shared = Replicated.SharedModules

local formatModule = require(shared.FormatModule)

local DataManager = {
    ["DataCache"] = {}
}

local makeLS = function(player: Player, playerData: {any})
    if not playerData then return end
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    for statName, statValue in playerData["Leaderstats"] do
        local statValueLS = Instance.new("StringValue")
        statValueLS.Name = tostring(statName)
        statValueLS.Value = statValue
        statValueLS.Parent = leaderstats

        Run.Heartbeat:Connect(function()
            statValueLS.Value = formatModule.FormatCompact(playerData["PlayerStats"][statName ~= "🏋️‍♂️Strength" and string.sub(tostring(statName), 5) or "Strength"])
        end)
    end
end

local PlayerAdded = function(player: Player)
    if DataManager["DataCache"][player] then return end

    local playerProfile = profileStore:LoadProfileAsync("player_"..player.UserId)
    if not playerProfile then
        player:Kick("Error loading data profile! Please rejoin!")
        return
    end

    playerProfile:AddUserId(player.UserId)
    playerProfile:Reconcile()

    playerProfile:ListenToRelease(function()
        DataManager["DataCache"][player] = nil
        player:Kick("Profile released.")
    end)

    if player:IsDescendantOf(Players) then
        DataManager["DataCache"][player] = playerProfile
        task.wait()
        makeLS(player, playerProfile["Data"])
    else
        playerProfile:Release()
    end
end

for _, player: Player in Players:GetPlayers() do
    PlayerAdded(player)
end

Players.PlayerAdded:Connect(PlayerAdded)

return DataManager
