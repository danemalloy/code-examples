/* eslint-disable roblox-ts/no-array-pairs */
/* eslint-disable roblox-ts/lua-truthiness */

// written by dane1up

// imports
import profileService from "@rbxts/rbx-profileservice-plus";
import { Profile } from "@rbxts/rbx-profileservice-plus/out/globals";
import { template } from "./dataTemplate";
import { doLeaderstats } from "./doLeaderstats";
import { PlayerDataType } from "server/serverInterfaces";

// settings
const _DATA_KEY = "Testing_v1.0.1";
const _DATA_TEMPLATE = template;
const _PROFILE_STORE = profileService.GetProfileStore(_DATA_KEY, _DATA_TEMPLATE);
const _PROFILES = new Map<Player, Profile<PlayerDataType>>();

// class
export class DaneStoreService {
	onPlayerAdded(player: Player) {
		const profile = _PROFILE_STORE.LoadProfile(`player_${player.UserId}`, "ForceLoad");

		if (!player.IsDescendantOf(game)) {
			profile?.Release();
			return;
		}

		if (profile === undefined) {
			player.Kick("Failed to load data! Please rejoin or try again later.");
			return;
		}
		profile.AddUserId(player.UserId);
		profile.Reconcile();

		_PROFILES.set(player, profile as unknown as Profile<PlayerDataType>);

		doLeaderstats(player, _PROFILES.get(player) as unknown as Profile<PlayerDataType>);
	}

	onPlayerRemoving(player: Player) {
		const profile = _PROFILES.get(player);
		if (profile === undefined) {
			return;
		}

		profile.Release();
		_PROFILES.delete(player);
	}

	async getProfile(player: Player) {
		return _PROFILES.get(player);
	}
}
