#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>
#include <xVip>

#undef REQUIRE_PLUGIN
#include <updater>

#define UPDATE_URL "https://raw.githubusercontent.com/maxijabase/xVip_roundend_immunity/main/updatefile.txt"

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = {
	name = "xVip - Humiliation Immunity", 
	author = "ampere", 
	description = "Grants immunity to VIP players during humiliation period", 
	version = "1.0", 
	url = "https://github.com/maxijabase"
};

public void OnPluginStart() {
	HookEvent("teamplay_round_start", Event_RoundStart);
	HookEvent("teamplay_round_win", Event_RoundWin);
}

public void Updater_OnLoaded()
{
	Updater_AddPlugin(UPDATE_URL);
}

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast) {
	return Plugin_Continue;
}

public Action Event_RoundWin(Event event, const char[] name, bool dontBroadcast) {
	int winningTeam = event.GetInt("team");
	GrantImmunity(winningTeam);
	return Plugin_Continue;
}

void GrantImmunity(int winningTeam) {
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsClientInGame(i) || !IsPlayerAlive(i)) {
			continue;
		}
			
		if (!xVip_IsVip(i) || GetClientTeam(i) == winningTeam) {
			continue;
		}
			
		TF2_AddCondition(i, TFCond_UberchargedHidden, TFCondDuration_Infinite);
		TF2_AddCondition(i, TFCond_ImmuneToPushback, TFCondDuration_Infinite);
	}
}