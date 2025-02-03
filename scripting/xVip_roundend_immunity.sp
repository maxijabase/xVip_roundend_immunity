#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>
#include <xVip>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = {
	name = "xVip - Humiliation Immunity", 
	author = "ampere", 
	description = "Grants immunity to VIP players during humiliation period", 
	version = "1.0", 
	url = "https://github.com/maxijabase"
};

bool g_bIsHumiliationPeriod = false;

public void OnPluginStart() {
	HookEvent("teamplay_round_start", Event_RoundStart);
	HookEvent("teamplay_round_win", Event_RoundWin);
	RegAdminCmd("sm_roundend", Command_RoundEnd, ADMFLAG_ROOT, "Test VIP humiliation immunity");
	RegAdminCmd("sm_endround", Command_RoundEnd, ADMFLAG_ROOT, "Test VIP humiliation immunity");
}

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast) {
	g_bIsHumiliationPeriod = false;
	return Plugin_Continue;
}

public Action Event_RoundWin(Event event, const char[] name, bool dontBroadcast) {
	g_bIsHumiliationPeriod = true;
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

public void OnClientDisconnect(int client) {
	if (g_bIsHumiliationPeriod && xVip_IsVip(client)) {
		TF2_RemoveCondition(client, TFCond_UberchargedCanteen);
	}
}

public Action Command_RoundEnd(int client, int args) {
	
	if (client == 0) {
		ReplyToCommand(client, "[SM] This command cannot be used from the server console.");
		return Plugin_Handled;
	}

	if (args < 1) {
		ReplyToCommand(client, "[SM] Usage: !roundend <win|lose>");
		return Plugin_Handled;
	}

	char arg[8];
	GetCmdArg(1, arg, sizeof(arg));

	int iEnt = FindEntityByClassname(-1, "game_round_win");
	
	if (iEnt < 1) {
		iEnt = CreateEntityByName("game_round_win");
		if (!IsValidEntity(iEnt)) {
			ReplyToCommand(client, "[SM] Failed to create game_round_win entity!");
			return Plugin_Handled;
		}
		DispatchSpawn(iEnt);
	}

	int clientTeam = GetClientTeam(client);
	int winningTeam;

	if (strcmp(arg, "win", false) == 0) {
		winningTeam = clientTeam;
	}
	else if (strcmp(arg, "lose", false) == 0) {
		// If client is on RED (2), set winner to BLU (3), and vice versa
		winningTeam = (clientTeam == 2) ? 3 : 2;
	}
	else {
		ReplyToCommand(client, "[SM] Invalid argument. Use 'win' or 'lose'.");
		return Plugin_Handled;
	}

	if (winningTeam == 1) {
		winningTeam = 0;
	}

	SetVariantInt(winningTeam);
	AcceptEntityInput(iEnt, "SetTeam");
	AcceptEntityInput(iEnt, "RoundWin");
	
	return Plugin_Handled;
}
