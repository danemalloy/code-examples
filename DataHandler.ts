// written by dane1up

//imports
import { Service, OnStart, OnInit } from "@flamework/core";
import { Players } from "@rbxts/services";
import ProfileService from "@rbxts/rbx-profileservice-plus";
import { Profile } from "@rbxts/rbx-profileservice-plus/out/globals";
import { PLAYER_DATA_TEMPLATE } from "./template";
import { PlayerDataType } from "server/types/data";

// settings
const DATA_KEY = "Testing_v1.0.0";
let PROFILE_STORE = ProfileService.GetProfileStore(DATA_KEY, PLAYER_DATA_TEMPLATE);
const PROFILES = new Map<Player, Profile<PlayerDataType>>();

@Service({})
export class DaneStoreService implements OnStart, OnInit {
	onInit() {
		PROFILE_STORE = PROFILE_STORE.Mock;
	}

	onStart() {
		Players.PlayerAdded.Connect((player: Player) => {
			this.onPlayerAdded(player);
		});
		Players.PlayerRemoving.Connect((player: Player) => {
			this.onPlayerRemoving(player);
		});
	}

	onPlayerAdded(player: Player) {
		const userId = player.UserId;
		const profile = PROFILE_STORE.LoadProfile("player_" + userId);

		if (!profile) {
			player.Kick("Error loading data profile. Please try again.");
			return;
		}

		if (!player.IsDescendantOf(game)) {
			profile?.Release();
			return;
		}

		profile.AddUserId(userId);
		profile.Reconcile();

		PROFILES.set(player, profile as Profile<PlayerDataType>);

		this.makeLS(player);
	}

	onPlayerRemoving(player: Player) {
		const profile = PROFILES.get(player);

		if (!profile) {
			return;
		}

		profile.Release();
		PROFILES.delete(player);
	}

	makeLS(player: Player) {
		const profile = PROFILES.get(player);

		if (!profile) {
			warn("cannot make leaderstats, player has no profile");
			return;
		}

		const leaderstats = new Instance("Folder");
		leaderstats.Name = "leaderstats";
		leaderstats.Parent = player;

		for (const [STAT_NAME, STAT_VALUE] of pairs(profile.Data.Stats)) {
			const value = new Instance("StringValue");
			value.Name = STAT_NAME;
			value.Value = tostring(STAT_VALUE);
			value.Parent = leaderstats;
		}
	}

	async getProfile(player: Player) {
		return PROFILES.get(player);
	}
}
