#include <a_samp>

#if !defined INVALID_PICKUP
    #define INVALID_PICKUP 0
#endif
#define PICKUP_TELEPORT_COOLDOWN 5000

#define COLOR_WHITE 0xFFFFFFFF
#define COLOR_GREEN 0x33CC66FF
#define COLOR_RED 0xFF4444FF
#define COLOR_YELLOW 0xFFD700FF
#define COLOR_BLUE 0x66CCFFFF
#define COLOR_ORANGE 0xFF9900FF
#define COLOR_PINK 0xFF66CCFF

#define DIALOG_REGISTER 1000
#define DIALOG_LOGIN 1001
#define DIALOG_HELP 1002
#define DIALOG_GPS 1003
#define DIALOG_JOB 1004
#define DIALOG_ADMIN_GPS 1005
#define DIALOG_SPAWN 1006
#define DIALOG_MAIN_MENU 1007
#define DIALOG_POLICE_MENU 1008
#define DIALOG_ORG_MENU 1009
#define DIALOG_FACTION_GARAGE 1010
#define DIALOG_RENT_SCOOTER 1011
#define DIALOG_AUTOSCHOOL 1026
#define DIALOG_CAR_DEALER 1012
#define DIALOG_GPS_PUBLIC 1013
#define DIALOG_GPS_ORGS 1014
#define DIALOG_GPS_JOBS 1015
#define DIALOG_GPS_GANGS 1016
#define DIALOG_GANG 1017
#define DIALOG_GANG_STASH 1018
#define DIALOG_GANG_DEPOSIT 1019
#define DIALOG_GANG_WITHDRAW 1020
#define DIALOG_GANG_SKIN 1021
#define DIALOG_GANG_WEAPONS 1022
#define DIALOG_GANG_WEAPON_ACTION 1023
#define DIALOG_POLICE_STASH 1024
#define DIALOG_ORG_STASH 1025
#define FACTION_NONE 0
#define FACTION_CITYHALL 1
#define FACTION_POLICE 2
#define FACTION_HOSPITAL 3
#define FACTION_ARMY 4
#define FACTION_NAVY 5
#define FACTION_AIRFORCE 6
#define FACTION_FBI 7
#define RENT_SCOOTER_PRICE 250
#define FLEET_TIERS 5
#define FLEET_RETURN_MS 180000

#define OWNER_NAME "Stanislav_Belkin"
#define MAX_MONEY 2000000000

new DB:gDatabase;
new DBResult:gResult;
new bool:gLogged[MAX_PLAYERS];
new bool:gNEngineWasDown[MAX_PLAYERS];
new gMoney[MAX_PLAYERS];
new gBankMoney[MAX_PLAYERS];
new gMedkits[MAX_PLAYERS];
new gFood[MAX_PLAYERS];
new gWater[MAX_PLAYERS];
new gRepairKits[MAX_PLAYERS];
new gSimCards[MAX_PLAYERS];
new gLockpicks[MAX_PLAYERS];
new gMarketPickup;
new bool:gCarjackPursuitNotified[MAX_PLAYERS];
new gPhoneSmsTarget[MAX_PLAYERS];
new gCurrentHouse[MAX_PLAYERS];
new gLevel[MAX_PLAYERS];
new gExperience[MAX_PLAYERS];
new gLicenseDriver[MAX_PLAYERS];
new gLicenseWeapon[MAX_PLAYERS];
new gLicenseBoat[MAX_PLAYERS];
new gLicenseAir[MAX_PLAYERS];
new gDrivingTestStage[MAX_PLAYERS];
new gDrivingTestVehicle[MAX_PLAYERS];
new gDrivingExamPassed[MAX_PLAYERS];
new gDeaths[MAX_PLAYERS];
new gKills[MAX_PLAYERS];
new gAdmin[MAX_PLAYERS];
new gFBIEditObject[MAX_PLAYERS];
new bool:gFBIEditActive[MAX_PLAYERS];
new bool:gFBIEditMoveObject[MAX_PLAYERS];
new Float:gFBIEditX[MAX_PLAYERS];
new Float:gFBIEditY[MAX_PLAYERS];
new Float:gFBIEditZ[MAX_PLAYERS];
new Float:gFBIEditRX[MAX_PLAYERS];
new Float:gFBIEditRY[MAX_PLAYERS];
new Float:gFBIEditRZ[MAX_PLAYERS];
new Float:gFBIEditorCamX[MAX_PLAYERS];
new Float:gFBIEditorCamY[MAX_PLAYERS];
new Float:gFBIEditorCamZ[MAX_PLAYERS];
new gJob[MAX_PLAYERS];
new gFaction[MAX_PLAYERS];
new gFactionRank[MAX_PLAYERS];
new bool:gPoliceCivilianSkin[MAX_PLAYERS];
new gGang[MAX_PLAYERS];
new gSpawnPreference[MAX_PLAYERS]; // 0 = не выбрано, 1 = организация, 2 = вокзал
new gRentalVehicle[MAX_PLAYERS];
new gBaseScooter = INVALID_VEHICLE_ID;
new bool:gPendingScooterChoice[MAX_PLAYERS];
new gFactionVehicle[MAX_PLAYERS];
new gFleetVehicle[8][FLEET_TIERS];
new gVehicleFaction[MAX_VEHICLES];
new gVehicleTier[MAX_VEHICLES];
new gFactionVehicleOwner[MAX_VEHICLES]; // INVALID_PLAYER_ID for locked garage slots, playerid for issued vehicles
new gVehicleReturnTimer[MAX_VEHICLES];
new gVehicleFuel[MAX_VEHICLES];
new Float:gFuelLastX[MAX_VEHICLES];
new Float:gFuelLastY[MAX_VEHICLES];
new Float:gFuelLastZ[MAX_VEHICLES];
new gOwnedCarModel[MAX_PLAYERS];
new gOwnedCarVehicle[MAX_PLAYERS];
new gPersonalVehicleOwner[MAX_VEHICLES];
new gCarDealerPickup;
new gAccessoryShopPickup;
new gAccessoryModel[MAX_PLAYERS];
new gLastObservedWeapon[MAX_PLAYERS];
new gLicenseMarketPickup;
new gPassportPickup;
new gHospitalMarketPickup;
new gHasPassport[MAX_PLAYERS];
new gGasStationPickup[5];
new PlayerText:gHudTitle[MAX_PLAYERS];
new PlayerText:gHudInfo[MAX_PLAYERS];
new bool:gHudCreated[MAX_PLAYERS];
new gHudTimer[MAX_PLAYERS];
new gPoliceGarageDoorPickup;
new gPoliceEntrancePickup;
new gPoliceStashPickup;
new gFBIStashPickup;
new gGangStashPickup[5];
new gPoliceGarageReturnPickup;
new gPoliceExitPickup;
new gPoliceHallGaragePickup;
new gLastPickupTick[MAX_PLAYERS];
new gLastTaserTick[MAX_PLAYERS];
new bool:gLicenseMarketLocked[MAX_PLAYERS];
new gOrgEnterPickup[8];
new gFBIBuildingEnterPickup;
new bool:gFBIPendingEnter[MAX_PLAYERS];
new gFBIEnterTimer[MAX_PLAYERS];
new gOrgExitPickup[8];
new gLockerPickup[8];
new gWorkStage[MAX_PLAYERS];
new gWorkVehicle[MAX_PLAYERS];
new bool:gGpsActive[MAX_PLAYERS];
new bool:gSpawnMenuShown[MAX_PLAYERS];
new bool:gIsJailed[MAX_PLAYERS];
new gWantedLevel[MAX_PLAYERS];
new bool:gHandcuffed[MAX_PLAYERS];
new gCuffOfficer[MAX_PLAYERS];
new gHandcuffObject[MAX_PLAYERS];
new bool:gTaserStunned[MAX_PLAYERS];
new gPursuitTarget[MAX_PLAYERS];
new gMedicPending[MAX_PLAYERS];
new bool:gNeedsMedicalHelp[MAX_PLAYERS];
new gDeathSkin[MAX_PLAYERS];
new gDeathTimer[MAX_PLAYERS];
new Float:gDeathX[MAX_PLAYERS], Float:gDeathY[MAX_PLAYERS], Float:gDeathZ[MAX_PLAYERS];
new bool:gCarjackActive[MAX_PLAYERS];
new bool:gCarjackUnlocked[MAX_PLAYERS];
new gCarjackVehicle[MAX_PLAYERS];
new gCarjackCode[MAX_PLAYERS];
new gCarjackDestination[MAX_PLAYERS];
new gCarjackPending[MAX_PLAYERS];
new gCarjackVehicleOwner[MAX_VEHICLES];
new bool:gInterviewActive;
new gInterviewTimer;
new gInterviewFaction;
// PvP duel state: invitations, score, arena and saved loadout/return position.
new gPvpPendingFrom[MAX_PLAYERS];
new gPvpRequestTarget[MAX_PLAYERS];
new gPvpOpponent[MAX_PLAYERS];
new gPvpScore[MAX_PLAYERS];
new gPvpArenaWorld[MAX_PLAYERS];
new bool:gPvpActive[MAX_PLAYERS];
new bool:gPvpRestorePending[MAX_PLAYERS];
new Float:gPvpOldX[MAX_PLAYERS], Float:gPvpOldY[MAX_PLAYERS], Float:gPvpOldZ[MAX_PLAYERS], Float:gPvpOldA[MAX_PLAYERS];
new gPvpOldInterior[MAX_PLAYERS], gPvpOldWorld[MAX_PLAYERS];
new gPvpOldWeapon[MAX_PLAYERS][13], gPvpOldAmmo[MAX_PLAYERS][13];
#define DIALOG_POLICE_TABLET 1030
#define DIALOG_LICENSE_MARKET 1031
#define DIALOG_PASSPORT 1032
#define DIALOG_ITEM_INVENTORY 1033
#define DIALOG_PHONE 1034
#define DIALOG_PHONE_SMS_TARGET 1035
#define DIALOG_PHONE_SMS_TEXT 1036
#define DIALOG_SHOP 1037
#define DIALOG_SHOP_ACC 1038
#define DIALOG_CARJACK_HACK 1040
new gJailTimer[MAX_PLAYERS];
new gPassword[MAX_PLAYERS][65];
new gName[MAX_PLAYERS][MAX_PLAYER_NAME + 1];

forward SavePlayer(playerid);
forward PayDay();
forward UnstunPlayer(playerid);
forward ReleaseJailedPlayer(playerid);
forward RespawnFactionVehicle(vehicleid);
forward RefreshVexHud(playerid);
forward FinishFBIEnter(playerid);
forward InterviewAnnouncement();
forward PvpRespawn(playerid);
forward RefreshCarjackPursuits();
forward RefreshNearbyMapVisibility();

stock EnsureColumn(const table[], const column[], const definition[])
{
    new query[192], field[64], found = 0;
    format(query, sizeof query, "PRAGMA table_info(%s)", table);
    new DBResult:result = db_query(gDatabase, query);
    if (result)
    {
        for (new row = 0; row < db_num_rows(result); row++)
        {
            db_get_field(result, 1, field, sizeof field);
            if (!strcmp(field, column, true)) found = 1;
            db_next_row(result);
        }
        db_free_result(result);
    }
    if (!found)
    {
        format(query, sizeof query, "ALTER TABLE %s ADD COLUMN %s %s", table, column, definition);
        result = db_query(gDatabase, query);
        if (result) db_free_result(result);
    }
    return 1;
}

stock IsOwner(playerid)
{
    return !strcmp(gName[playerid], OWNER_NAME, true);
}

stock GetFactionName(faction, output[], size)
{
    switch (faction)
    {
        case FACTION_CITYHALL: format(output, size, "Мэрия");
        case FACTION_POLICE: format(output, size, "Полиция");
        case FACTION_HOSPITAL: format(output, size, "Больница");
        case FACTION_ARMY: format(output, size, "Армия");
        case FACTION_NAVY: format(output, size, "ВМФ");
        case FACTION_AIRFORCE: format(output, size, "ВВС");
        case FACTION_FBI: format(output, size, "FBI");
        default: format(output, size, "Нет фракции");
    }
    return 1;
}

stock GetFactionRankName(faction, rank, output[], size)
{
    if (rank < 1 || rank > 10) { format(output, size, "Нет ранга"); return 1; }
    if (faction == FACTION_CITYHALL)
    {
        switch (rank)
        {
            case 1: format(output, size, "Стажёр");
            case 2: format(output, size, "Секретарь");
            case 3: format(output, size, "Помощник");
            case 4: format(output, size, "Специалист");
            case 5: format(output, size, "Начальник отдела");
            case 6: format(output, size, "Заместитель главы");
            case 7: format(output, size, "Советник");
            case 8: format(output, size, "Заместитель мэра");
            case 9: format(output, size, "Вице-мэр");
            case 10: format(output, size, "Мэр");
        }
    }
    else if (faction == FACTION_POLICE)
    {
        switch (rank)
        {
            case 1: format(output, size, "Кадет");
            case 2: format(output, size, "Рядовой");
            case 3: format(output, size, "Сержант");
            case 4: format(output, size, "Старшина");
            case 5: format(output, size, "Прапорщик");
            case 6: format(output, size, "Лейтенант");
            case 7: format(output, size, "Капитан");
            case 8: format(output, size, "Майор");
            case 9: format(output, size, "Полковник");
            case 10: format(output, size, "Начальник полиции");
        }
    }
    else if (faction == FACTION_HOSPITAL)
    {
        switch (rank)
        {
            case 1: format(output, size, "Интерн");
            case 2: format(output, size, "Медбрат/медсестра");
            case 3: format(output, size, "Фельдшер");
            case 4: format(output, size, "Медицинский техник");
            case 5: format(output, size, "Врач");
            case 6: format(output, size, "Хирург");
            case 7: format(output, size, "Заведующий отделением");
            case 8: format(output, size, "Заместитель главврача");
            case 9: format(output, size, "Главврач");
            case 10: format(output, size, "Министр здравоохранения");
        }
    }
    else if (faction == FACTION_ARMY || faction == FACTION_NAVY || faction == FACTION_AIRFORCE || faction == FACTION_FBI)
    {
        switch (rank)
        {
            case 1: format(output, size, "Рекрут");
            case 2: format(output, size, "Рядовой");
            case 3: format(output, size, "Ефрейтор");
            case 4: format(output, size, "Младший сержант");
            case 5: format(output, size, "Сержант");
            case 6: format(output, size, "Старшина");
            case 7: format(output, size, "Прапорщик");
            case 8: format(output, size, "Лейтенант");
            case 9: format(output, size, "Полковник");
            case 10: format(output, size, "Командующий");
        }
    }
    else format(output, size, "Нет ранга");
    return 1;
}

stock CommandMatch(const cmdtext[], const command[])
{
    new len = strlen(command);
    if (strcmp(cmdtext, command, true, len) != 0) return 0;
    return (cmdtext[len] == '\0' || cmdtext[len] == ' ');
}

stock HideVexDefaultHud(playerid)
{
    // В стандартном SA-MP 0.3.7 нет native для скрытия отдельных элементов HUD.
    // Оставляем совместимую заглушку, чтобы исходник компилировался.
    #pragma unused playerid
    return 1;
}

stock GetHudFactionName(playerid, output[], size)
{
    switch (gFaction[playerid])
    {
        case FACTION_CITYHALL: format(output, size, "\xcc\xfd\xf0\xe8\xff");
        case FACTION_POLICE: format(output, size, "\xcf\xee\xeb\xe8\xf6\xe8\xff");
        case FACTION_HOSPITAL: format(output, size, "\xcc\xe5\xe4\xe8\xf6\xe8\xed\xe0");
        case FACTION_ARMY: format(output, size, "\xc0\xf0\xec\xe8\xff");
        case FACTION_NAVY: format(output, size, "\xd4\xeb\xee\xf2");
        case FACTION_AIRFORCE: format(output, size, "\xc2\xc2\xd1");
        case FACTION_FBI: format(output, size, "FBI");
        default: format(output, size, "\xc3\xf0\xe0\xe6\xe4\xe0\xed\xf1\xea\xe8\xe9");
    }
    return 1;
}

stock CreateVexHud(playerid)
{
    if (gHudCreated[playerid]) return 1;

    gHudTitle[playerid] = CreatePlayerTextDraw(playerid, 620.0, 22.0, "~r~VEXORIUM ~w~RP");
    PlayerTextDrawFont(playerid, gHudTitle[playerid], 2);
    PlayerTextDrawLetterSize(playerid, gHudTitle[playerid], 0.32, 1.25);
    PlayerTextDrawColor(playerid, gHudTitle[playerid], 0xFFFFFFFF);
    PlayerTextDrawSetProportional(playerid, gHudTitle[playerid], 1);
    PlayerTextDrawAlignment(playerid, gHudTitle[playerid], 3);
    PlayerTextDrawSetOutline(playerid, gHudTitle[playerid], 1);
    PlayerTextDrawSetShadow(playerid, gHudTitle[playerid], 0);
    PlayerTextDrawUseBox(playerid, gHudTitle[playerid], 1);
    PlayerTextDrawBoxColor(playerid, gHudTitle[playerid], 0x07110FFF);
    PlayerTextDrawTextSize(playerid, gHudTitle[playerid], 620.0, 0.0);

    gHudInfo[playerid] = CreatePlayerTextDraw(playerid, 620.0, 43.0, "");
    PlayerTextDrawFont(playerid, gHudInfo[playerid], 1);
    PlayerTextDrawLetterSize(playerid, gHudInfo[playerid], 0.20, 0.95);
    PlayerTextDrawColor(playerid, gHudInfo[playerid], 0xF0F7F4FF);
    PlayerTextDrawSetProportional(playerid, gHudInfo[playerid], 1);
    PlayerTextDrawAlignment(playerid, gHudInfo[playerid], 3);
    PlayerTextDrawSetOutline(playerid, gHudInfo[playerid], 1);
    PlayerTextDrawSetShadow(playerid, gHudInfo[playerid], 0);
    PlayerTextDrawUseBox(playerid, gHudInfo[playerid], 1);
    PlayerTextDrawBoxColor(playerid, gHudInfo[playerid], 0x07110FF0);
    PlayerTextDrawTextSize(playerid, gHudInfo[playerid], 620.0, 0.0);

    gHudCreated[playerid] = true;
    return 1;
}

stock UpdateVexHud(playerid)
{
    if (!gHudCreated[playerid]) return 0;
    new factionName[32], info[192];
    GetHudFactionName(playerid, factionName, sizeof factionName);
    new weaponid = GetPlayerWeapon(playerid), ammo = GetPlayerAmmo(playerid);
    new Float:health, Float:armour;
    GetPlayerHealth(playerid, health);
    GetPlayerArmour(playerid, armour);
    if (IsPlayerInAnyVehicle(playerid))
    {
        new vehicleid = GetPlayerVehicleID(playerid);
        format(info, sizeof info, "~r~\xd1\xd2\xc0\xd2\xd3\xd1 \xc8\xc3\xd0\xce\xca\xc0~w~~n~\xd3\xf0\xee\xe2\xe5\xed\xfc: %d | %s~n~\xc4\xe5\xed\xfc\xe3\xe8: $%d~n~\xc7\xe4\xee\xf0\xee\xe2\xfc\xe5: %.0f | \xc1\xf0\xee\xed\xff: %.0f~n~\xc3\xee\xeb\xee\xe4: %d | \xc6\xe0\xe6\xe4\xe0: %d~n~\xce\xf0\xf3\xe6\xe8\xe5: %d:%d | \xd2\xee\xef\xeb\xe8\xe2\xee: %d L", gLevel[playerid], factionName, gMoney[playerid], health, armour, gFood[playerid], gWater[playerid], weaponid, ammo, gVehicleFuel[vehicleid]);
    }
    else
    {
        format(info, sizeof info, "~r~\xd1\xd2\xc0\xd2\xd3\xd1 \xc8\xc3\xd0\xce\xca\xc0~w~~n~\xd3\xf0\xee\xe2\xe5\xed\xfc: %d | %s~n~\xc4\xe5\xed\xfc\xe3\xe8: $%d~n~\xc7\xe4\xee\xf0\xee\xe2\xfc\xe5: %.0f | \xc1\xf0\xee\xed\xff: %.0f~n~\xc3\xee\xeb\xee\xe4: %d | \xc6\xe0\xe6\xe4\xe0: %d~n~\xce\xf0\xf3\xe6\xe8\xe5: %d:%d", gLevel[playerid], factionName, gMoney[playerid], health, armour, gFood[playerid], gWater[playerid], weaponid, ammo);
    }
    PlayerTextDrawSetString(playerid, gHudInfo[playerid], info);
    return 1;
}

public RefreshVexHud(playerid)
{
    if (!IsPlayerConnected(playerid)) return 1;
    if (!gHudCreated[playerid]) CreateVexHud(playerid);
    if (gLogged[playerid]) UpdateVexHud(playerid);
    else PlayerTextDrawSetString(playerid, gHudInfo[playerid], "\xc0\xca\xca\xc0\xd3\xcd\xd2 | \xc2\xce\xc9\xc4\xc8\xd2\xc5 \xc8\xcb\xc8 \xc7\xc0\xd0\xc5\xc3\xc8\xd1\xd2\xd0\xc8\xd0\xd3\xc9\xd2\xc5\xd1\xdc");
    PlayerTextDrawShow(playerid, gHudTitle[playerid]);
    PlayerTextDrawShow(playerid, gHudInfo[playerid]);
    return 1;
}

stock ShowVexHud(playerid)
{
    if (!gHudCreated[playerid]) CreateVexHud(playerid);
    UpdateVexHud(playerid);
    PlayerTextDrawShow(playerid, gHudTitle[playerid]);
    PlayerTextDrawShow(playerid, gHudInfo[playerid]);
    return 1;
}

stock DestroyVexHud(playerid)
{
    if (!gHudCreated[playerid]) return 1;
    PlayerTextDrawDestroy(playerid, gHudTitle[playerid]);
    PlayerTextDrawDestroy(playerid, gHudInfo[playerid]);
    gHudCreated[playerid] = false;
    return 1;
}

stock IsNearGasStation(playerid)
{
    if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0) return 0;
    if (IsPlayerInRangeOfPoint(playerid, 20.0, 1004.0, -939.3, 42.2)) return 1;
    if (IsPlayerInRangeOfPoint(playerid, 20.0, 1940.0, -1772.0, 13.4)) return 1;
    if (IsPlayerInRangeOfPoint(playerid, 20.0, -2025.0, 156.0, 28.9)) return 1;
    if (IsPlayerInRangeOfPoint(playerid, 20.0, 2115.0, 920.0, 10.8)) return 1;
    if (IsPlayerInRangeOfPoint(playerid, 20.0, -1605.0, -2714.0, 48.5)) return 1;
    return 0;
}

stock GiveCash(playerid, amount)
{
    if (amount <= 0 || gMoney[playerid] > MAX_MONEY - amount) return 0;
    gMoney[playerid] += amount;
    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid, gMoney[playerid]);
    UpdateVexHud(playerid);
    return 1;
}

stock TakeCash(playerid, amount)
{
    if (amount <= 0 || gMoney[playerid] < amount) return 0;
    gMoney[playerid] -= amount;
    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid, gMoney[playerid]);
    UpdateVexHud(playerid);
    return 1;
}

stock GetParams(const cmdtext[], params[], size)
{
    new i = 0;
    while (cmdtext[i] && cmdtext[i] != ' ') i++;
    while (cmdtext[i] == ' ') i++;
    strmid(params, cmdtext, i, strlen(cmdtext), size);
    return 1;
}

stock GetToken(const input[], tokenIndex, output[], outputSize)
{
    new i, current = 0, start, length = strlen(input);
    output[0] = '\0';
    while (i < length)
    {
        while (i < length && input[i] <= ' ') i++;
        if (i >= length) break;
        start = i;
        while (i < length && input[i] > ' ') i++;
        if (current == tokenIndex)
        {
            strmid(output, input, start, i, outputSize);
            return 1;
        }
        current++;
    }
    return 0;
}

stock GetFactionSkin(faction, rank)
{
    if (rank < 1) rank = 1;
    if (rank > 10) rank = 10;
    switch (faction)
    {
        case FACTION_CITYHALL:
        {
            switch (rank)
            {
                case 1: return 147;
                case 2: return 148;
                case 3: return 150;
                case 4: return 151;
                case 5: return 153;
                case 6: return 154;
                case 7: return 155;
                case 8: return 156;
                case 9: return 157;
                case 10: return 165;
            }
        }
        case FACTION_POLICE:
        {
            switch (rank)
            {
                case 1: return 280;
                case 2: return 281;
                case 3: return 282;
                case 4: return 283;
                case 5: return 284;
                case 6: return 285;
                case 7: return 286;
                case 8: return 287;
                case 9: return 288;
                case 10: return 294;
            }
        }
        case FACTION_HOSPITAL:
        {
            switch (rank)
            {
                case 1: return 274;
                case 2: return 275;
                case 3: return 276;
                case 4: return 70;
                case 5: return 71;
                case 6: return 72;
                case 7: return 73;
                case 8: return 75;
                case 9: return 76;
                case 10: return 77;
            }
        }
        case FACTION_ARMY:
        {
            // Rank-based military uniform.
            if (rank >= 7) return 287;
            return 179;
        }
        case FACTION_NAVY:
        {
            // В стандартной GTA:SA нет отдельного полноценного скина ВМФ;
            // используем ближайшие штатные военные/офицерские модели.
            if (rank >= 7) return 62;
            return 287;
        }
        case FACTION_AIRFORCE:
        {
            // Пилот и старший офицер из штатных моделей GTA:SA.
            if (rank >= 7) return 62;
            return 61;
        }
        case FACTION_FBI:
        {
            // FBI wardrobe: agent, senior agent, supervisor and command uniforms.
            if (rank >= 9) return 286;
            if (rank >= 7) return 166;
            if (rank >= 4) return 165;
            if (rank >= 2) return 164;
            return 163;
        }
    }
    return 23;
}

stock SpawnLoggedPlayer(playerid, Float:x, Float:y, Float:z, Float:a, skin)
{
    // Preserve the player's saved skin on login; do not force the faction uniform.
    if (skin < 0 || skin > 311) skin = 23;
    SetSpawnInfo(playerid, 0, skin, x, y, z, a, 0, 0, 0, 0, 0, 0);
    TogglePlayerSpectating(playerid, false);
    SpawnPlayer(playerid);
    HideVexDefaultHud(playerid);
    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid, gMoney[playerid]);
    ShowVexHud(playerid);
    return 1;
}

stock ApplySavedSpawn(playerid)
{
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);

    // Gang spawn applies only to players who are not members of a government organization.
    // Organization membership has priority to prevent police/medics/military spawning at gang bases.
    if (gFaction[playerid] == FACTION_NONE && gGang[playerid] >= 1 && gGang[playerid] <= 4)
    {
        new Float:bx, Float:by, Float:bz;
        GetGangBase(gGang[playerid], bx, by, bz);
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        SetPlayerPos(playerid, bx, by, bz + 0.5);
        switch (gGang[playerid])
        {
            case 1: SetPlayerFacingAngle(playerid, 90.0);  // Grove Street
            case 2: SetPlayerFacingAngle(playerid, 180.0); // Ballas
            case 3: SetPlayerFacingAngle(playerid, 270.0); // Los Santos Vagos
            case 4: SetPlayerFacingAngle(playerid, 0.0);   // Varrios Aztecas
        }
        SetCameraBehindPlayer(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "You spawned at your gang base.");
        return 1;
    }

    if (gFaction[playerid] >= FACTION_CITYHALL && gFaction[playerid] <= FACTION_FBI && gFactionRank[playerid] >= 1)
    {
        // Spawn organization members in their locker room, in the faction's own world.
        switch (gFaction[playerid])
        {
            case FACTION_CITYHALL:
            {
                SetPlayerInterior(playerid, 3); SetPlayerVirtualWorld(playerid, 100 + FACTION_CITYHALL);
                SetPlayerPos(playerid, 391.0, 173.7, 1008.4); SetPlayerFacingAngle(playerid, 180.0);
            }
            case FACTION_POLICE:
            {
                SetPlayerInterior(playerid, 6); SetPlayerVirtualWorld(playerid, 0);
                SetPlayerPos(playerid, 255.3, 77.4, 1003.6); SetPlayerFacingAngle(playerid, 180.0);
                // Keep the outfit chosen by the player across login/spawn.
            }
            case FACTION_HOSPITAL:
            {
                SetPlayerInterior(playerid, 3); SetPlayerVirtualWorld(playerid, 100 + FACTION_HOSPITAL);
                SetPlayerPos(playerid, 2504.0, -1692.0, 1014.7); SetPlayerFacingAngle(playerid, 180.0);
            }
            case FACTION_ARMY:
            {
                SetPlayerInterior(playerid, 3); SetPlayerVirtualWorld(playerid, 100 + FACTION_ARMY);
                SetPlayerPos(playerid, 2504.0, -1692.0, 1014.7); SetPlayerFacingAngle(playerid, 180.0);
            }
            case FACTION_NAVY:
            {
                SetPlayerInterior(playerid, 3); SetPlayerVirtualWorld(playerid, 100 + FACTION_NAVY);
                SetPlayerPos(playerid, 2504.0, -1692.0, 1014.7); SetPlayerFacingAngle(playerid, 180.0);
            }
            case FACTION_AIRFORCE:
            {
                SetPlayerInterior(playerid, 3); SetPlayerVirtualWorld(playerid, 100 + FACTION_AIRFORCE);
                SetPlayerPos(playerid, 2504.0, -1692.0, 1014.7); SetPlayerFacingAngle(playerid, 180.0);
            }
            case FACTION_FBI:
            {
                // FBI spawn is placed directly at the requested interior exit marker.
                SetPlayerInterior(playerid, 6); SetPlayerVirtualWorld(playerid, 100 + FACTION_FBI);
                SetPlayerPos(playerid, 246.8183, 62.3222, 1003.6406); SetPlayerFacingAngle(playerid, 176.26);
            }
        }
        SetCameraBehindPlayer(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "Вы появились в раздевалке своей организации.");
    }
    else
    {
        SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
        SetPlayerPos(playerid, 1753.5, -1894.2, 13.6); SetPlayerFacingAngle(playerid, 90.0);
        SendClientMessage(playerid, COLOR_GREEN, "Вы появились у вокзала Лос-Сантос.");
    }
    SetCameraBehindPlayer(playerid);
    return 1;
}

stock ShowSpawnMenu(playerid)
{
    if (!gLogged[playerid]) return 0;
    if (gFaction[playerid] >= FACTION_CITYHALL && gFaction[playerid] <= FACTION_FBI)
        ShowPlayerDialog(playerid, DIALOG_SPAWN, DIALOG_STYLE_LIST, "VEXORIUM RP | Место появления", "Появиться в своей организации\nСтартовая зона / вокзал", "Выбрать", "Закрыть");
    else
        ShowPlayerDialog(playerid, DIALOG_SPAWN, DIALOG_STYLE_LIST, "VEXORIUM RP | Старт новичка", "Стартовая зона / вокзал\nИнформация о скутере: /rent", "Появиться", "Закрыть");
    gSpawnMenuShown[playerid] = true;
    return 1;
}

stock SendLocalMessage(playerid, color, const message[], Float:range)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (IsPlayerConnected(i) && gLogged[i] && GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid) && GetPlayerInterior(i) == GetPlayerInterior(playerid) && IsPlayerInRangeOfPoint(i, range, x, y, z))
            SendClientMessage(i, color, message);
    }
    return 1;
}

stock ShowFactionCommands(playerid)
{
    if (!gLogged[playerid]) return 0;
    SendClientMessage(playerid, COLOR_BLUE, "========== КОМАНДЫ ОРГАНИЗАЦИИ ==========");
    if (gFaction[playerid] == FACTION_POLICE)
    {
        SendClientMessage(playerid, COLOR_BLUE, "/showpass [ID] — проверить паспорт");
        SendClientMessage(playerid, COLOR_BLUE, "/search [ID] — провести обыск рядом с игроком");
        SendClientMessage(playerid, COLOR_BLUE, "/fine [ID] [сумма] — выписать штраф (со 2 ранга)");
        SendClientMessage(playerid, COLOR_BLUE, "/arrest [ID] [секунды] — задержать игрока (со 2 ранга)");
        SendClientMessage(playerid, COLOR_BLUE, "/release [ID] — освободить из КПЗ (с 3 ранга)");
        SendClientMessage(playerid, COLOR_BLUE, "/wanted [ID] [0-6] (с 3 ранга), /cuff [ID] и /uncuff [ID] (со 2 ранга), /pursuit [ID]");
        SendClientMessage(playerid, COLOR_BLUE, "/sobescr — собеседование (с 9 ранга)");
        SendClientMessage(playerid, COLOR_BLUE, "/org — меню участка; /duty — информация о форме");
    }
    else if (gFaction[playerid] == FACTION_CITYHALL)
    {
        SendClientMessage(playerid, COLOR_BLUE, "/org — меню мэрии и возможности организации");
        SendClientMessage(playerid, COLOR_BLUE, "/licgive [ID] [auto/weapon/boat/air] — выдать лицензию");
        SendClientMessage(playerid, COLOR_BLUE, "/sobescr — объявить собеседование (с 9 ранга)");
        SendClientMessage(playerid, COLOR_BLUE, "Для остальных функций используйте маркеры и меню мэрии.");
    }
    else
    {
        SendClientMessage(playerid, COLOR_BLUE, "/org — открыть меню своей организации");
        SendClientMessage(playerid, COLOR_BLUE, "/sobescr — объявить собеседование (с 9 ранга)");
        SendClientMessage(playerid, COLOR_BLUE, "/duty — информация о форме; маркеры организации — склад и гараж");
    }
    SendClientMessage(playerid, COLOR_BLUE, "========================================");
    return 1;
}

stock ShowPoliceMenu(playerid)
{
    if (GetPlayerInterior(playerid) != 6 || GetPlayerVirtualWorld(playerid) != 0)
        return SendClientMessage(playerid, COLOR_YELLOW, "Сначала войдите в здание полиции: подойдите к входу и используйте /enterpd."), 1;
    ShowPlayerDialog(playerid, DIALOG_POLICE_MENU, DIALOG_STYLE_LIST,
        "VEXORIUM RP | Участок LSPD",
        "Холл участка\nКабинет начальника\nКомната допроса\nКПЗ\nРаздевалка (маркер одежды)\nВыйти к гаражу\nВыйти из участка",
        "Открыть", "Закрыть");
    return 1;
}

stock IsNearPoliceEntrance(playerid)
{
    return GetPlayerInterior(playerid) == 0 && GetPlayerVirtualWorld(playerid) == 0 && IsPlayerInRangeOfPoint(playerid, 4.0, 1553.4399, -1675.5238, 16.1953);
}

stock IsInPoliceStation(playerid)
{
    return GetPlayerInterior(playerid) == 6 && GetPlayerVirtualWorld(playerid) == 0;
}

stock StartCarjack(playerid)
{
    if (gLevel[playerid] < 3) return SendClientMessage(playerid, COLOR_RED, "Для работы автоугонщиком нужен 3 уровень."), 0;
    if (gFaction[playerid] != FACTION_NONE) return SendClientMessage(playerid, COLOR_RED, "Сотрудники государственных организаций не могут работать автоугонщиками."), 0;
    if (gWorkStage[playerid] > 0 || gCarjackActive[playerid]) return SendClientMessage(playerid, COLOR_YELLOW, "Сначала завершите или отмените текущую работу."), 0;
    if (IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_YELLOW, "Выйдите из транспорта перед началом автоугона."), 0;
    if (gLockpicks[playerid] < 1) return SendClientMessage(playerid, COLOR_RED, "[MARKET] Dlya raboty avtougonschikom nuzhna otmychka. Kupite ee v zdanii marketa ili cherez /shop."), 0;
    new Float:spots[8][4] = {
        {2045.2, -1905.4, 13.5, 90.0}, {1173.8, -1327.2, 13.6, 180.0},
        {1812.5, -1729.3, 13.5, 270.0}, {1412.7, -1024.8, 23.8, 0.0},
        {2145.4, -1145.2, 24.0, 180.0}, {1003.2, -929.5, 42.3, 90.0},
        {2488.2, -1668.4, 13.3, 270.0}, {1688.4, -2001.3, 13.5, 0.0}
    };
    new idx = random(sizeof(spots));
    new models[6] = {400, 401, 410, 426, 436, 489};
    new model = models[random(sizeof(models))];
    new vehicleid = CreateVehicle(model, spots[idx][0], spots[idx][1], spots[idx][2], spots[idx][3], -1, -1, -1);
    if (vehicleid == INVALID_VEHICLE_ID || GetVehicleModel(vehicleid) == 0)
        return SendClientMessage(playerid, COLOR_RED, "Не удалось создать цель автоугона. Попробуйте ещё раз."), 0;
    gLockpicks[playerid]--;
    SavePlayer(playerid);
    gCarjackActive[playerid] = true;
    gCarjackUnlocked[playerid] = false;
    gCarjackCode[playerid] = random(4);
    gCarjackVehicle[playerid] = vehicleid;
    gCarjackVehicleOwner[vehicleid] = playerid;
    gCarjackDestination[playerid] = 1 + random(4);
    gCarjackPending[playerid] = 0;
    gCarjackPursuitNotified[playerid] = false;
    gWorkStage[playerid] = 10;
    SetVehicleParamsForPlayer(vehicleid, playerid, 0, 1);
    SetVehicleParamsEx(vehicleid, 0, 0, 0, 1, 0, 0, 0);
    SetPlayerCheckpoint(playerid, spots[idx][0], spots[idx][1], spots[idx][2], 5.0);
    SetPlayerMapIcon(playerid, 48, spots[idx][0], spots[idx][1], spots[idx][2], 55, 0, MAPICON_LOCAL);
    gGpsActive[playerid] = false;
    SendClientMessage(playerid, COLOR_GREEN, "Автоугон начат! На радаре отмечена случайная машина. Подъедьте к ней и введите /hack.");
    return 1;
}

stock AnnounceCarjack(playerid)
{
    new msg[160];
    format(msg, sizeof msg, "[ДИСПЕТЧЕР] Неизвестный угнал автомобиль! Преследовать: /accept | Отказаться: /cancel.");
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (!IsPlayerConnected(i) || !gLogged[i]) continue;
        if (gFaction[i] == FACTION_POLICE || gFaction[i] == FACTION_FBI)
        {
            SendClientMessage(i, COLOR_RED, msg);
            gCarjackPending[i] = playerid + 1;
        }
    }
    return 1;
}

public RefreshCarjackPursuits()
{
    for (new officer = 0; officer < MAX_PLAYERS; officer++)
    {
        if (!IsPlayerConnected(officer) || !gLogged[officer]) continue;
        new target = gPursuitTarget[officer];
        if (target == INVALID_PLAYER_ID || target < 0 || target >= MAX_PLAYERS) continue;

        if (!IsPlayerConnected(target) || !gLogged[target] || (!gCarjackActive[target] && gWantedLevel[target] < 1))
        {
            gPursuitTarget[officer] = INVALID_PLAYER_ID;
            RemovePlayerMapIcon(officer, 49);
            DisablePlayerCheckpoint(officer);
            SendClientMessage(officer, COLOR_YELLOW, "[LSPD/FBI] \\xcd\\xe5\\xf2 \\xe0\\xea\\xf2\\xe8\\xe2\\xed\\xee\\xe9 \\xf6\\xe5\\xeb\\xe8 \\xef\\xf0\\xe5\\xf1\\xeb\\xe5\\xe4\\xee\\xe2\\xe0\\xed\\xe8\\xff.");
            continue;
        }

        new Float:x, Float:y, Float:z;
        if (IsPlayerInAnyVehicle(target))
            GetVehiclePos(GetPlayerVehicleID(target), x, y, z);
        else
            GetPlayerPos(target, x, y, z);

        // Force-refresh the marker every 5 seconds; remove/re-add avoids stale coordinates.
        RemovePlayerMapIcon(officer, 49);
        SetPlayerMapIcon(officer, 49, x, y, z, 0, 0, MAPICON_GLOBAL);
        SetPlayerCheckpoint(officer, x, y, z, 8.0);
    }
    for (new suspect = 0; suspect < MAX_PLAYERS; suspect++)
    {
        if (!IsPlayerConnected(suspect) || !gLogged[suspect] || !gCarjackActive[suspect]) continue;
        new Float:sx, Float:sy, Float:sz;
        if (IsPlayerInAnyVehicle(suspect)) GetVehiclePos(GetPlayerVehicleID(suspect), sx, sy, sz); else GetPlayerPos(suspect, sx, sy, sz);
        new Float:nearest = 1000000.0; new pursuerCount = 0;
        for (new cop = 0; cop < MAX_PLAYERS; cop++)
        {
            if (!IsPlayerConnected(cop) || !gLogged[cop] || gPursuitTarget[cop] != suspect) continue;
            if (gFaction[cop] != FACTION_POLICE && gFaction[cop] != FACTION_FBI) continue;
            new Float:cx, Float:cy, Float:cz;
            if (IsPlayerInAnyVehicle(cop)) GetVehiclePos(GetPlayerVehicleID(cop), cx, cy, cz); else GetPlayerPos(cop, cx, cy, cz);
            new Float:dx = cx - sx, Float:dy = cy - sy, Float:dz = cz - sz;
            new Float:distance = floatsqroot(dx * dx + dy * dy + dz * dz);
            if (distance < nearest) nearest = distance;
            pursuerCount++;
        }
        if (pursuerCount > 0)
        {
            new pursuitText[128];
            format(pursuitText, sizeof pursuitText, "~r~\xc7\xe0 \xe2\xe0\xec\xe8 \xef\xf0\xe5\xf1\xeb\xe5\xe4\xee\xe2\xe0\xed\xe8\xe5!~n~~w~\xc4\xee \xfd\xea\xe8\xef\xe0\xe6\xe0: ~y~%.0f \xec", nearest);
            GameTextForPlayer(suspect, pursuitText, 4500, 3);
            if (!gCarjackPursuitNotified[suspect])
            {
                SendClientMessage(suspect, COLOR_RED, "[LSPD/FBI] Za vami nachali presledovanie! Rasstoyanie do ekipazha obnovlyaetsya.");
                gCarjackPursuitNotified[suspect] = true;
            }
        }
        else gCarjackPursuitNotified[suspect] = false;
    }
    return 1;
}
stock GetGangBaseByIndex(index, &Float:x, &Float:y, &Float:z)
{
    return GetGangBase(index, x, y, z);
}

stock ShowGPS(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_GPS, DIALOG_STYLE_LIST, "VEXORIUM RP | GPS",
        "[1] Общественные места\n[2] Организации и службы\n[3] Работы для новичков\n[4] Нелегальные организации", "Открыть", "Закрыть");
    return 1;
}
stock StartWorkRoute(playerid)
{
    if (gJob[playerid] < 1 || gJob[playerid] > 4)
        return SendClientMessage(playerid, COLOR_YELLOW, "[VEXORIUM] Сначала выберите работу: /job."), 0;
    if (gWorkStage[playerid] > 0)
        return SendClientMessage(playerid, COLOR_YELLOW, "[VEXORIUM] Вы уже на смене. Используйте /stopwork для отмены."), 0;
    if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0)
        return SendClientMessage(playerid, COLOR_YELLOW, "Начните смену рядом с работодателем на улице."), 0;
    new Float:employerX, Float:employerY, Float:employerZ;
    switch (gJob[playerid])
    {
        case 1: { employerX = 1479.0; employerY = -1739.0; employerZ = 13.5; }
        case 2: { employerX = 2195.0; employerY = -2254.0; employerZ = 13.5; }
        case 3: { employerX = 1810.0; employerY = -1900.0; employerZ = 13.4; }
        default: { employerX = 820.0; employerY = 856.0; employerZ = 12.0; }
    }
    if (GetPlayerDistanceFromPoint(playerid, employerX, employerY, employerZ) > 25.0)
        return SendClientMessage(playerid, COLOR_YELLOW, "Подойдите к NPC-диспетчеру своей работы и введите /work."), 0;
    if (IsPlayerInAnyVehicle(playerid))
        return SendClientMessage(playerid, COLOR_YELLOW, "Выйдите из транспорта перед началом смены."), 0;
    if (gWorkVehicle[playerid] != INVALID_VEHICLE_ID && GetVehicleModel(gWorkVehicle[playerid]) != 0)
        DestroyVehicle(gWorkVehicle[playerid]);
    gWorkVehicle[playerid] = INVALID_VEHICLE_ID;
    if (gJob[playerid] == 1 || gJob[playerid] == 2 || gJob[playerid] == 3)
    {
        new model = (gJob[playerid] == 1) ? 420 : ((gJob[playerid] == 2) ? 403 : 431);
        new Float:vx = employerX + 5.0, Float:vy = employerY + 2.0;
        gWorkVehicle[playerid] = CreateVehicle(model, vx, vy, employerZ + 0.3, 90.0, 6, 6, -1);
        if (gWorkVehicle[playerid] == INVALID_VEHICLE_ID)
            return SendClientMessage(playerid, COLOR_RED, "Не удалось выдать рабочий транспорт. Освободите место и повторите."), 0;
        gVehicleFuel[gWorkVehicle[playerid]] = 100;
        PutPlayerInVehicle(playerid, gWorkVehicle[playerid], 0);
    }
    gWorkStage[playerid] = 1;
    gGpsActive[playerid] = false;
    if (gJob[playerid] == 1) SetPlayerCheckpoint(playerid, 1182.0, -1323.0, 13.6, 5.0);
    else if (gJob[playerid] == 2) SetPlayerCheckpoint(playerid, 2445.0, -2110.0, 13.5, 7.0);
    else if (gJob[playerid] == 3) SetPlayerCheckpoint(playerid, 1090.0, -1750.0, 13.4, 6.0);
    else SetPlayerCheckpoint(playerid, 838.0, 870.0, 12.0, 7.0);
    SendClientMessage(playerid, COLOR_GREEN, "[VEXORIUM] Смена началась! Рабочий транспорт выдан, следуйте по красным отметкам.");
    return 1;
}


stock GetOrgExterior(faction, &Float:x, &Float:y, &Float:z)
{
    switch (faction)
    {
        case FACTION_CITYHALL: { x = 1477.0; y = -1771.9234; z = 18.7957; }
        case FACTION_POLICE: { x = 1540.8; y = -1675.5; z = 13.55; }
        case FACTION_HOSPITAL: { x = 1191.0; y = -1307.0; z = 12.1; }
        case FACTION_ARMY: { x = 404.5; y = 2488.8; z = 16.5; }
        case FACTION_NAVY: { x = -1380.0; y = 508.0; z = 18.0; }
        case FACTION_AIRFORCE: { x = 1940.0; y = -2620.0; z = 13.5; }
        case FACTION_FBI: { x = -2281.9553; y = 2288.3784; z = 4.9739; }
        default: { x = 1753.5; y = -1894.2; z = 13.6; }
    }
    return 1;
}

stock GetOrgGarage(faction, &Float:x, &Float:y, &Float:z)
{
    // Точки автопарков отделены от спавнов и входов в здания.
    // Все выдаваемые машины создаются рядом с этой точкой, а не поверх игрока.
    switch (faction)
    {
        case FACTION_CITYHALL: { x = 1462.4062; y = -1741.2448; z = 13.5468; }
        case FACTION_POLICE: { x = 1602.0622; y = -1691.8668; z = 5.8906; }
        case FACTION_HOSPITAL: { x = 1192.1529; y = -1335.5710; z = 13.3984; }
        case FACTION_ARMY: { x = 404.5; y = 2488.8; z = 16.5; }
        case FACTION_NAVY: { x = -1397.5173; y = 469.4958; z = 7.1875; }
        case FACTION_AIRFORCE: { x = 1924.5002; y = -2604.4042; z = 13.5468; }
        case FACTION_FBI: { x = -2252.2521; y = 2312.0034; z = 4.9421; }
        default: { x = 1753.5; y = -1894.2; z = 13.6; }
    }
    return 1;
}

stock IsInOwnOrgInterior(playerid)
{
    if (gFaction[playerid] == FACTION_POLICE)
        return GetPlayerInterior(playerid) == 6 && GetPlayerVirtualWorld(playerid) == 0;
    if (gFaction[playerid] == FACTION_FBI)
        return GetPlayerInterior(playerid) == 6 && GetPlayerVirtualWorld(playerid) == 100 + FACTION_FBI;
    return GetPlayerInterior(playerid) == 3 && GetPlayerVirtualWorld(playerid) == 100 + gFaction[playerid];
}

stock ShowOrgMenu(playerid)
{
    new factionName[32], title[64];
    GetFactionName(gFaction[playerid], factionName, sizeof factionName);
    format(title, sizeof title, "%s | Штаб организации", factionName);
    ShowPlayerDialog(playerid, DIALOG_ORG_MENU, DIALOG_STYLE_LIST, title,
        "Главный холл\nКабинет руководства\nКомната собраний / построение\nВыйти к гаражу\nПокинуть здание", "Выбрать", "Закрыть");
    return 1;
}

stock EnterOrgInteriorForFaction(playerid, faction)
{
    if (faction < 1 || faction > 7) return 1;
    if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0) return 1;
    new Float:x, Float:y, Float:z;
    GetOrgExterior(faction, x, y, z);
    if (faction == FACTION_POLICE)
    {
        SetPlayerInterior(playerid, 6);
        SetPlayerVirtualWorld(playerid, 0);
        SetPlayerPos(playerid, 251.0, 67.0, 1003.6);
        SetPlayerFacingAngle(playerid, 180.0);
        SetCameraBehindPlayer(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "Вы вошли в участок LSPD. Выйти можно через маркер выхода.");
        if (gFaction[playerid] == FACTION_POLICE && gFactionRank[playerid] >= 1) ShowFactionCommands(playerid);
        return 1;
    }
    if (faction == FACTION_FBI)
    {
        // Reuse the police station interior (ID 6) in a separate FBI virtual world.
        SetPlayerInterior(playerid, 6);
        SetPlayerVirtualWorld(playerid, 100 + FACTION_FBI);
        SetPlayerPos(playerid, 246.4510, 65.5860, 1003.6410);
        SetPlayerFacingAngle(playerid, 180.0);
        SetCameraBehindPlayer(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "FBI: \xc2\xfb \xe2\xee\xf8\xeb\xe8 \xe2 \xf8\xf2\xe0\xe1. \xc2\xfb\xf5\xee\xe4 \xf0\xff\xe4\xee\xec \xf1 \xe2\xf5\xee\xe4\xee\xec.");
        if (gFaction[playerid] == FACTION_FBI && gFactionRank[playerid] >= 1) ShowOrgMenu(playerid);
        return 1;
    }
    SetPlayerInterior(playerid, 3);
    SetPlayerVirtualWorld(playerid, 100 + faction);
    if (faction == FACTION_CITYHALL)
    {
        // City Hall interior, not CJ house coordinates.
        SetPlayerPos(playerid, 386.4, 173.7, 1008.4);
        SetPlayerFacingAngle(playerid, 0.0);
    }
    else
    {
        SetPlayerPos(playerid, 2496.0, -1692.0, 1014.7);
        SetPlayerFacingAngle(playerid, 180.0);
    }
    SetCameraBehindPlayer(playerid);
    SendClientMessage(playerid, COLOR_GREEN, "Вы вошли в здание организации. Найдите маркер выхода, чтобы вернуться на улицу.");
    // Любой игрок может войти в здание, но меню управления доступно только сотрудникам этой организации.
    if (gFaction[playerid] == faction && gFactionRank[playerid] >= 1)
    {
        ShowOrgMenu(playerid);
        ShowFactionCommands(playerid);
    }
    return 1;
}

stock EnterOrgInterior(playerid)
{
    SendClientMessage(playerid, COLOR_YELLOW, "Вход в здания доступен через маркеры у дверей. Подойдите к маркеру нужной организации.");
    return 1;
}

stock GetFactionVehicleSpawn(faction, tier, &Float:x, &Float:y, &Float:z, &Float:a)
{
    new Float:gx, Float:gy, Float:gz;
    GetOrgGarage(faction, gx, gy, gz);
    a = 90.0;
    // Default layout remains in place for factions whose coordinates were not changed (for example, Army).
    x = gx + ((tier % 2) == 0 ? -5.5 : 5.5);
    y = gy + ((tier / 2) - 1) * 7.0;
    z = gz;

    // Vehicles spawn around each faction's configured point, with spacing by selected model.
    // The center coordinates below are supplied by the server owner; tier offsets prevent overlap.
    if (faction == FACTION_CITYHALL)
    {
        x = 1462.4062 + (float(tier) - 2.0) * 4.0; y = -1741.2448; z = 13.5468; a = 70.61;
    }
    if (faction == FACTION_POLICE)
    {
        x = 1602.0622 + (float(tier) - 2.0) * 4.0; y = -1691.8668; z = 5.8906; a = 93.37;
    }
    if (faction == FACTION_HOSPITAL)
    {
        x = 1192.1529 + (float(tier) - 2.0) * 4.0; y = -1335.5710; z = 13.3984; a = 180.89;
    }
    if (faction == FACTION_NAVY)
    {
        x = -1397.5173 + (float(tier) - 2.0) * 4.0; y = 469.4958; z = 7.1875; a = 175.54;
    }
    if (faction == FACTION_AIRFORCE)
    {
        x = 1924.5002 + (float(tier) - 2.0) * 4.0; y = -2604.4042; z = 13.5468; a = 88.40;
    }

    // FBI parking: four car slots at the exact supplied street coordinates; tier 2 is the helicopter.
    if (faction == FACTION_FBI)
    {
        switch (tier)
        {
            case 0: { x = -2252.4357; y = 2285.0981; z = 4.9520; a = 181.31; }
            case 1: { x = -2251.5017; y = 2294.2263; z = 4.8566; a = 272.84; }
            case 2: { x = -2227.0739; y = 2327.6262; z = 7.7276; a = 76.50; }
            case 3: { x = -2271.4221; y = 2300.4868; z = 4.9478; a = 273.34; }
            case 4: { x = -2271.0200; y = 2288.3764; z = 4.3842; a = 272.84; }
        }
    }
    return 1;
}

stock GetFactionFleetDisplaySpawn(faction, tier, &Float:x, &Float:y, &Float:z, &Float:a)
{
    new Float:gx, Float:gy, Float:gz;
    GetOrgGarage(faction, gx, gy, gz);
    // Restore the original display fleet's base points; these are separate from /garage delivery points.
    if (faction == FACTION_CITYHALL) { gx = 1504.0; gy = -1712.0; gz = 13.5; }
    if (faction == FACTION_ARMY) { gx = 404.5; gy = 2488.8; gz = 16.5; }
    a = 90.0;

    // Ground vehicles use a two-column, three-row parking layout with enough space between vehicles.
    x = gx + ((tier % 2) == 0 ? -5.5 : 5.5);
    y = gy + ((tier / 2) - 1) * 7.0;
    z = gz;

    // LSPD: five separated vehicle slots inside the garage area supplied by the user.
    if (faction == FACTION_POLICE)
    {
        switch (tier)
        {
            case 0: { x = 1578.9284; y = -1708.1907; z = 5.8906; a = 16.89; }
            case 1: { x = 1583.9284; y = -1706.6907; z = 5.8906; a = 16.89; }
            case 2: { x = 1588.9284; y = -1705.1907; z = 5.8906; a = 16.89; }
            case 3: { x = 1577.4284; y = -1713.1907; z = 5.8906; a = 16.89; }
            case 4: { x = 1582.4284; y = -1711.6907; z = 5.8906; a = 16.89; }
        }
    }

    // Hospital fleet: dedicated outdoor parking slots, away from the building collision.
    if (faction == FACTION_HOSPITAL)
    {
        switch (tier)
        {
            case 0: { x = 1185.5; y = -1320.0; z = 13.2; a = 0.0; }
            case 1: { x = 1192.5; y = -1320.0; z = 13.2; a = 0.0; }
            case 2: { x = 1185.5; y = -1312.0; z = 13.2; a = 0.0; }
            case 3: { x = 1192.5; y = -1312.0; z = 13.2; a = 0.0; }
            case 4: { x = 1189.0; y = -1304.0; z = 13.2; a = 0.0; }
        }
    }

    // Navy: cars and helicopter stand on the aircraft-carrier deck; boats spawn separately in open water.
    if (faction == FACTION_NAVY)
    {
        switch (tier)
        {
            case 0: { x = -1450.0; y = 508.0; z = 18.0; a = 90.0; }
            case 1: { x = -1430.0; y = 508.0; z = 18.0; a = 90.0; }
            case 2: { x = -1420.0; y = 535.0; z = 0.5; a = 90.0; }
            case 3: { x = -1400.0; y = 535.0; z = 0.5; a = 90.0; }
            case 4: { x = -1380.0; y = 508.0; z = 18.0; a = 90.0; }
        }
    }

    // Air-force vehicles use spaced slots on the flat Los Santos Airport runway.
    if (faction == FACTION_AIRFORCE)
    {
        x = 1920.0 + (float(tier) * 20.0);
        y = -2620.0;
        z = 13.5;
        a = 90.0;
    }
    // FBI motor pool: place the visible fleet beside FBI headquarters, not at the airport.
    // Separate display slots from /garage delivery points so cars do not overlap.
    if (faction == FACTION_FBI)
    {
        switch (tier)
        {
            case 0: { x = -2252.4357; y = 2285.0981; z = 4.9520; a = 181.31; }
            case 1: { x = -2251.5017; y = 2294.2263; z = 4.8566; a = 272.84; }
            case 2: { x = -2227.0739; y = 2327.6262; z = 7.7276; a = 76.50; }
            case 3: { x = -2271.4221; y = 2300.4868; z = 4.9478; a = 273.34; }
            case 4: { x = -2271.0200; y = 2288.3764; z = 4.3842; a = 272.84; }
        }
    }
    return 1;
}

stock SpawnFactionFleet()
{
    for (new f = 1; f <= 7; f++)
    {
        for (new t = 0; t < FLEET_TIERS; t++)
        {
            new Float:x, Float:y, Float:z, Float:a, model;
            GetFactionFleetDisplaySpawn(f, t, x, y, z, a);
            model = GetFactionVehicleModel(f, t);
            gFleetVehicle[f][t] = CreateVehicle(model, x, y, z, a, 1, 1, 180);
            if (gFleetVehicle[f][t] != INVALID_VEHICLE_ID)
            {
                new vid = gFleetVehicle[f][t];
                gVehicleFaction[vid] = f;
                gVehicleTier[vid] = t;
                gFactionVehicleOwner[vid] = INVALID_PLAYER_ID;
                gVehicleReturnTimer[vid] = 0;
                gVehicleFuel[vid] = 100;
                gFuelLastX[vid] = 0.0; gFuelLastY[vid] = 0.0; gFuelLastZ[vid] = 0.0;
                SetVehicleVirtualWorld(vid, 0);
                // Every display vehicle gets its own /garage hint, including helicopters and other special vehicles.
                new hintText[128];
                format(hintText, sizeof(hintText), "{33CC66}Автопарк\n{FFFFFF}Подойдите и пропишите /garage");
                Create3DTextLabel(hintText, COLOR_WHITE, x, y, z + 1.15, 18.0, 0, 1);
                // Locked parking-slot vehicle; employees must use /garage to get their own copy.
                new eng, lit, alm, doors, bonnet, boot, obj;
                GetVehicleParamsEx(vid, eng, lit, alm, doors, bonnet, boot, obj);
                SetVehicleParamsEx(vid, eng, lit, alm, 1, bonnet, boot, obj);
                for (new p = 0; p < MAX_PLAYERS; p++)
                    if (IsPlayerConnected(p)) SetVehicleParamsForPlayer(vid, p, 0, 1);
            }
        }
    }
    return 1;
}

stock IsFleetVehicleOccupied(vehicleid)
{
    for (new i = 0; i < MAX_PLAYERS; i++)
        if (IsPlayerConnected(i) && IsPlayerInAnyVehicle(i) && GetPlayerVehicleID(i) == vehicleid) return 1;
    return 0;
}

stock StartFleetVehicleReturn(vehicleid)
{
    if (vehicleid < 1 || vehicleid >= MAX_VEHICLES || gVehicleFaction[vehicleid] < 1) return 0;
    if (gVehicleReturnTimer[vehicleid]) KillTimer(gVehicleReturnTimer[vehicleid]);
    gVehicleReturnTimer[vehicleid] = SetTimerEx("RespawnFactionVehicle", FLEET_RETURN_MS, false, "i", vehicleid);
    return 1;
}

public RespawnFactionVehicle(vehicleid)
{
    if (vehicleid < 1 || vehicleid >= MAX_VEHICLES || gVehicleFaction[vehicleid] < 1) return 1;
    gVehicleReturnTimer[vehicleid] = 0;
    if (IsFleetVehicleOccupied(vehicleid)) return StartFleetVehicleReturn(vehicleid);
    SetVehicleToRespawn(vehicleid);
    gVehicleFuel[vehicleid] = 100; gFuelLastX[vehicleid] = 0.0; gFuelLastY[vehicleid] = 0.0; gFuelLastZ[vehicleid] = 0.0;
    return 1;
}

stock SpawnBaseScooter()
{
    if (gBaseScooter != INVALID_VEHICLE_ID) DestroyVehicle(gBaseScooter);
    gBaseScooter = CreateVehicle(462, 1764.0, -1898.0, 13.5, 90.0, 1, 1, 0);
    if (gBaseScooter != INVALID_VEHICLE_ID) { gVehicleFuel[gBaseScooter] = 100; gFuelLastX[gBaseScooter] = 0.0; gFuelLastY[gBaseScooter] = 0.0; gFuelLastZ[gBaseScooter] = 0.0; }
    return 1;
}

stock GetGangBase(gang, &Float:x, &Float:y, &Float:z)
{
    switch (gang)
    {
        case 1: { x = 2495.0; y = -1687.0; z = 13.5; }
        case 2: { x = 2000.0; y = -1114.0; z = 25.0; }
        case 3: { x = 2769.0; y = -1628.0; z = 10.9; }
        case 4: { x = 1840.0; y = -2035.0; z = 13.5; }
        default: { x = 0.0; y = 0.0; z = 0.0; return 0; }
    }
    return 1;
}

stock GetGangStashMoney(gang)
{
    new query[128];
    format(query, sizeof query, "SELECT money FROM gang_stashes WHERE gang_id=%d", gang);
    new DBResult:r = db_query(gDatabase, query);
    new amount = 0;
    if (r && db_num_rows(r)) amount = db_get_field_int(r, 0);
    if (r) db_free_result(r);
    return amount;
}

stock SetGangStashMoney(gang, amount)
{
    new query[160];
    format(query, sizeof query, "UPDATE gang_stashes SET money=%d WHERE gang_id=%d", amount, gang);
    new DBResult:r = db_query(gDatabase, query);
    if (r) db_free_result(r);
    return 1;
}

stock GetGangSkin(gang, rank)
{
    // Штатные модели GTA:SA, подходящие уличным бандам.
    if (rank < 1) rank = 1;
    if (rank > 6) rank = 6;
    switch (gang)
    {
        case 1: { switch (rank) { case 1: return 105; case 2: return 106; case 3: return 107; case 4: return 269; case 5: return 270; case 6: return 271; } }
        case 2: { switch (rank) { case 1: return 102; case 2: return 103; case 3: return 104; case 4: return 102; case 5: return 103; case 6: return 104; } }
        case 3: { switch (rank) { case 1: return 108; case 2: return 109; case 3: return 110; case 4: return 108; case 5: return 109; case 6: return 110; } }
        case 4: { switch (rank) { case 1: return 114; case 2: return 115; case 3: return 116; case 4: return 114; case 5: return 115; case 6: return 116; } }
    }
    return 23;
}

stock GangWeaponAllowed(weaponid)
{
    return (weaponid == 22 || weaponid == 24 || weaponid == 25 || weaponid == 29 || weaponid == 30 || weaponid == 31);
}

stock GetGangWeaponAmmo(gang, weaponid)
{
    new query[160], amount = 0;
    format(query, sizeof query, "SELECT ammo FROM gang_weapon_stash WHERE gang_id=%d AND weapon_id=%d", gang, weaponid);
    new DBResult:r = db_query(gDatabase, query);
    if (r && db_num_rows(r)) amount = db_get_field_int(r, 0);
    if (r) db_free_result(r);
    return amount;
}

stock SetGangWeaponAmmo(gang, weaponid, amount)
{
    new query[192];
    if (amount < 0) amount = 0;
    format(query, sizeof query, "INSERT OR REPLACE INTO gang_weapon_stash (gang_id,weapon_id,ammo) VALUES (%d,%d,%d)", gang, weaponid, amount);
    new DBResult:r = db_query(gDatabase, query);
    if (r) db_free_result(r);
    return 1;
}

stock ShowGangWeaponMenu(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_GANG_WEAPONS, DIALOG_STYLE_LIST, "Оружейный склад банды", "Пистолет 9мм — взять/положить\nПистолет Desert Eagle — взять/положить\nДробовик — взять/положить\nMP5 — взять/положить\nAK-47 — взять/положить\nM4 — взять/положить", "Выбрать", "Назад");
    return 1;
}

stock SpawnGangBases()
{
    // Turf markers, stash point and gang vehicles. Each gang has a distinct colour.
    new Float:x[4] = {2495.0, 2000.0, 2769.0, 1840.0};
    new Float:y[4] = {-1687.0, -1114.0, -1628.0, -2035.0};
    new Float:z[4] = {13.5, 25.0, 10.9, 13.5};
    new colour1[4] = {86, 140, 255, 0};
    new colour2[4] = {86, 0, 255, 200};
    new models[4][4] = {{567, 492, 536, 482}, {567, 517, 535, 474}, {567, 546, 566, 463}, {567, 510, 551, 468}};
    new Float:dx[4] = {5.0, 0.0, -5.0, 0.0};
    new Float:dy[4] = {0.0, 5.0, 0.0, -5.0};
    new Float:angles[4] = {90.0, 180.0, 270.0, 0.0};
    new names[4][24] = {"\xc3\xf0\xf3\xe2 \xd1\xf2\xf0\xe8\xf2", "\xc1\xe0\xeb\xeb\xe0\xf1", "\xcb\xee\xf1 \xd1\xe0\xed\xf2\xee\xf1 \xc2\xe0\xe3\xee\xf1", "\xc2\xe0\xf0\xf0\xe8\xee\xf1 \xc0\xf6\xf2\xe5\xea\xe0\xf1"};
    for (new i = 0; i < 4; i++)
    {
        CreatePickup(1275, 23, x[i], y[i], z[i], 0);
        new label[160];
        format(label, sizeof label, "{FFD700}%s | \xc1\xc0\xc7\xc0\n{FFFFFF}\xc2\xf1\xf2\xf3\xef\xe8\xf2\xfc \xe2 \xe1\xe0\xed\xe4\xf3: /gang\n\xd1\xea\xeb\xe0\xe4 \xe8 \xee\xe4\xe5\xe6\xe4\xe0 \xe4\xee\xf1\xf2\xf3\xef\xed\xfb \xf7\xe5\xf0\xe5\xe7 \xec\xe0\xf0\xea\xe5\xf0", names[i]);
        gGangStashPickup[i + 1] = CreatePickup(1275, 23, x[i] + 1.5, y[i] + 1.5, z[i], 0);
        Create3DTextLabel("{00FF99}\xce\xd0\xd3\xc6\xc5\xc9\xcd\xdb\xc9 \xd1\xca\xcb\xc0\xc4 \xc1\xc0\xcd\xc4\xdb\n{FFFFFF}\xd1\xee\xf1\xf2\xee\xff\xed\xe8\xe5: \xe4\xe5\xed\xfc\xe3\xe8, \xee\xf0\xf3\xe6\xe8\xe5, \xe1\xf0\xee\xed\xe5\xe6\xe8\xeb\xe5\xf2", COLOR_WHITE, x[i] + 1.5, y[i] + 1.5, z[i] + 1.0, 18.0, 0, 1);
        Create3DTextLabel("{33CCFF}\xd1\xca\xcb\xc0\xc4 \xc1\xc0\xcd\xc4\xdb\n{FFFFFF}\xc2\xe7\xff\xf2\xfc \xee\xf0\xf3\xe6\xe8\xe5, \xe1\xf0\xee\xed\xe5\xe6\xe8\xeb\xe5\xf2 \xe8 \xe4\xe5\xed\xfc\xe3\xe8", COLOR_WHITE, x[i] + 1.5, y[i] + 1.5, z[i] + 1.6, 18.0, 0, 1);
        Create3DTextLabel(label, COLOR_WHITE, x[i], y[i], z[i] + 1.0, 25.0, 0, 1);
        for (new j = 0; j < 4; j++)
        {
            new model = models[i][j];
            new vehicle = CreateVehicle(model, x[i] + dx[j], y[i] + dy[j], z[i] + 0.3, angles[j], colour1[i], colour2[i], -1);
            if (vehicle != INVALID_VEHICLE_ID) SetVehicleVirtualWorld(vehicle, 0);
        }
    }
    return 1;
}

public RefreshNearbyMapVisibility()
{
    new Float:targetX, Float:targetY, Float:targetZ;
    for (new viewer = 0; viewer < MAX_PLAYERS; viewer++)
    {
        if (!IsPlayerConnected(viewer) || !gLogged[viewer]) continue;
        // Police-station icon appears only when the player is within 250 metres.
        if (GetPlayerInterior(viewer) == 0 && GetPlayerVirtualWorld(viewer) == 0 &&
            GetPlayerDistanceFromPoint(viewer, 1540.8, -1675.5, 13.55) <= 100.0)
        {
            SetPlayerMapIcon(viewer, 60, 1540.8, -1675.5, 13.55, 30, 0, MAPICON_LOCAL);
        }
        else RemovePlayerMapIcon(viewer, 60);

        // Hide player radar markers beyond 250 metres, and for different interiors/worlds.
        for (new target = 0; target < MAX_PLAYERS; target++)
        {
            if (target == viewer || !IsPlayerConnected(target) || !gLogged[target]) continue;
            if (GetPlayerInterior(viewer) != GetPlayerInterior(target) ||
                GetPlayerVirtualWorld(viewer) != GetPlayerVirtualWorld(target))
            {
                SetPlayerMarkerForPlayer(viewer, target, (GetPlayerColor(target) & 0xFFFFFF00));
                continue;
            }
            GetPlayerPos(target, targetX, targetY, targetZ);
            if (GetPlayerDistanceFromPoint(viewer, targetX, targetY, targetZ) <= 100.0)
                SetPlayerMarkerForPlayer(viewer, target, (GetPlayerColor(target) & 0xFFFFFF00) | 0xFF);
            else
                SetPlayerMarkerForPlayer(viewer, target, (GetPlayerColor(target) & 0xFFFFFF00));
        }
    }
    return 1;
}

public OnGameModeInit()
{
    // New FBI HQ building (model 3980), placed about 5m ahead of the supplied player position.
    CreateObject(3980, 2254.9, 2293.5, 4.8202, 0.0, 0.0, 156.87, 300.0);
    SetGameModeText("VEXORIUM RP | Русский RolePlay");
    // NPC-помощники на основных работах новичков (SA-MP 0.3.7+).
    CreateActor(16, 820.0, 856.0, 12.0, 90.0);
    Create3DTextLabel("{FFD700}Работодатель: шахта\n{FFFFFF}/job — выбрать работу, /work — начать смену", COLOR_WHITE, 820.0, 856.0, 13.0, 15.0, 0, 1);
    CreateActor(155, 2195.0, -2254.0, 13.5, 180.0);
    Create3DTextLabel("{FFD700}Диспетчер грузоперевозок\n{FFFFFF}/job — выбрать работу, /work — начать маршрут", COLOR_WHITE, 2195.0, -2254.0, 14.5, 15.0, 0, 1);
    CreateActor(17, 1810.0, -1900.0, 13.4, 0.0);
    Create3DTextLabel("{FFD700}Диспетчер автобусов\n{FFFFFF}/job — выбрать работу, /work — начать маршрут", COLOR_WHITE, 1810.0, -1900.0, 14.4, 15.0, 0, 1);
    CreateActor(61, 1479.0, -1739.0, 13.5, 90.0);
    Create3DTextLabel("{FFD700}Диспетчер такси\n{FFFFFF}/job — выбрать работу, /work — начать маршрут", COLOR_WHITE, 1479.0, -1739.0, 14.5, 15.0, 0, 1);
    ShowPlayerMarkers(0); // \xCD\xE5 \xEF\xEE\xEA\xE0\xE7\xFB\xE2\xE0\xE5\xEC \xEC\xE5\xF2\xEA\xE8 \xE8\xE3\xF0\xEE\xEA\xEE\xE2 \xED\xE0 \xEC\xE8\xED\xE8\xEA\xF0\xE0\xF2\xE5; \xEC\xE5\xF2\xEA\xE0 \xEF\xF0\xE5\xF1\xEB\xE5\xE4\xEE\xE2\xE0\xED\xE8\xFF \xEE\xF2\xE4\xE5\xEB\xFC\xED\xE0\xFF
    ShowNameTags(1);
    UsePlayerPedAnims();
    DisableInteriorEnterExits(); // Отключаем стандартные маркеры входа GTA:SA; входы VEXORIUM создаются отдельно.
    Create3DTextLabel("{33CC66}LSPD | Полицейский участок\n{FFFFFF}/enterpd — войти", COLOR_WHITE, 1540.8, -1675.5, 14.3, 25.0, 0, 1);
    Create3DTextLabel("{FFD700}CITY HALL\n{FFFFFF}Use the entrance marker | /orggarage", COLOR_WHITE, 1477.0, -1771.9234, 19.5, 18.0, 0, 1);
    CreateActor(17, -2026.8, -96.5, 35.2, 180.0);
    Create3DTextLabel("{3399FF}VEXORIUM | Автошкола\n{FFFFFF}Подойдите к инструктору и нажмите Y", COLOR_WHITE, -2026.8, -96.5, 36.2, 18.0, 0, 1);
    Create3DTextLabel("{33CC66}Штаб больницы\n{FFFFFF}/enterorg — войти", COLOR_WHITE, 1176.7, -1322.5, 12.8, 18.0, 0, 1);
    Create3DTextLabel("{33CC66}VEXORIUM | БОЛЬНИЦА LS\n{FFFFFF}РЕГИСТРАТУРА | ЛЕЧЕНИЕ ПОСЛЕ СМЕРТИ: Y", COLOR_WHITE, 1176.7, -1322.5, 14.2, 22.0, 0, 1);
    CreateActor(274, 1178.2, -1321.1, 13.5, 180.0);
    // Hospital heart market: pickup model 1240, full health for $500.
    gHospitalMarketPickup = CreatePickup(1240, 1, 1180.2, -1322.5, 13.5, 0);
    Create3DTextLabel("{FF4444}<3 АПТЕКА БОЛЬНИЦЫ <3\n{FFFFFF}Полное восстановление здоровья\n{33CC66}Цена: $500\n{FFD700}Подойдите к сердцу", COLOR_WHITE, 1180.2, -1322.5, 14.3, 12.0, 0, 1);
    Create3DTextLabel("{33CC66}Штаб армии\n{FFFFFF}/enterorg — войти", COLOR_WHITE, 404.5, 2488.8, 17.5, 22.0, 0, 1);
    Create3DTextLabel("{33CC66}Штаб ВМФ\n{FFFFFF}/enterorg — войти", COLOR_WHITE, -1380.0, 508.0, 19.0, 22.0, 0, 1);
    Create3DTextLabel("{33CC66}Штаб ВВС\n{FFFFFF}/enterorg — войти", COLOR_WHITE, 1940.0, -2620.0, 14.8, 22.0, 0, 1);
    // Собственные маркеры входа/выхода VEXORIUM вместо стандартных входов GTA:SA.
    for (new f = 1; f <= 7; f++) { gOrgEnterPickup[f] = INVALID_PICKUP; gOrgExitPickup[f] = INVALID_PICKUP; gLockerPickup[f] = INVALID_PICKUP; }
    gOrgEnterPickup[FACTION_CITYHALL] = CreatePickup(1318, 1, 1477.0, -1771.9234, 18.7957, 0);
    gLicenseMarketPickup = CreatePickup(1239, 1, 362.4587, 174.0056, 1008.3828, 101);
    // Interior-only 3D label removed: use the exterior entrance marker instead.
    gPassportPickup = CreatePickup(1274, 1, 358.8, 174.0056, 1008.3828, 101);
    // Interior-only 3D label removed: use the exterior entrance marker instead.
    gOrgEnterPickup[FACTION_HOSPITAL] = CreatePickup(1318, 1, 1176.7, -1322.5, 12.8, 0);
    gOrgEnterPickup[FACTION_ARMY] = CreatePickup(1318, 1, 404.5, 2488.8, 17.5, 0);
    gOrgEnterPickup[FACTION_NAVY] = CreatePickup(1318, 1, -1380.0, 508.0, 19.0, 0);
    gOrgEnterPickup[FACTION_AIRFORCE] = CreatePickup(1318, 1, 1940.0, -2620.0, 14.8, 0);
    // One FBI street entrance marker. Positive X is the actual FBI building location;
    // negative X would place the marker in a different part of the map.
    gOrgEnterPickup[FACTION_FBI] = CreatePickup(1318, 1, -2281.9553, 2288.3784, 4.9739, 0);
    gFBIBuildingEnterPickup = gOrgEnterPickup[FACTION_FBI];
    Create3DTextLabel("{3399FF}FBI | ENTRANCE\n{FFFFFF}Stay here 2 seconds to enter", COLOR_WHITE, -2281.9553, 2288.3784, 5.9, 25.0, 0, 1);
    gPoliceExitPickup = CreatePickup(1318, 1, 246.3213, 62.5062, 1003.6406, 0);
    // Interior-only 3D label removed: use the exterior entrance marker instead.
    for (new f = 1; f <= 7; f++)
    {
        if (f == FACTION_POLICE) continue;
        if (f == FACTION_CITYHALL) gOrgExitPickup[f] = CreatePickup(1318, 1, 388.8, 173.7, 1008.4, 100 + f);
        else if (f == FACTION_FBI)
        {
            gOrgExitPickup[f] = CreatePickup(1318, 1, 246.8183, 62.3222, 1003.6406, 100 + f);
            Create3DTextLabel("{3399FF}FBI | EXIT TO STREET", COLOR_WHITE, 246.8183, 62.3222, 1004.5, 12.0, 100 + f, 1);
        }
        else gOrgExitPickup[f] = CreatePickup(1318, 1, 2496.0, -1688.0, 1014.7, 100 + f);
    }
    // Interior-only 3D label removed: use the exterior entrance marker instead.
    Create3DTextLabel("{FFD700}Аренда скутеров для новичков\n{FFFFFF}Сядьте на Faggio и выберите аренду (250 руб.)", COLOR_WHITE, 1764.0, -1898.0, 14.0, 20.0, 0, 1);
    // Дверь из интерьера LSPD к автопарку и обратная дверь снаружи.
    gPoliceEntrancePickup = CreatePickup(1318, 1, 1553.4399, -1675.5238, 16.1953, 0);
    Create3DTextLabel("{39D98A}VEXORIUM | Вход в LSPD\n{FFFFFF}Подойдите к маркеру", COLOR_WHITE, 1553.4399, -1675.5238, 16.95, 8.0, 0, 0);
    // One entrance marker inside LSPD: step on it to enter the garage.
    gPoliceGarageDoorPickup = CreatePickup(1318, 1, 246.7147, 87.2885, 1003.6406, 0);
    gPoliceHallGaragePickup = INVALID_PICKUP;
    // Interior-only 3D label removed: use the exterior entrance marker instead.
    gPoliceGarageReturnPickup = CreatePickup(1318, 1, 1568.4843, -1690.4116, 5.8906, 0);
    // Interior-only 3D label removed: use the exterior entrance marker instead.
    Create3DTextLabel("{33CC66}Дверь в участок LSPD\n{FFFFFF}Подойдите к маркеру", COLOR_WHITE, 1568.4843, -1690.4116, 6.8, 7.0, 0, 0);
    // Маркеры раздевалок: полиция использует интерьер LSPD, остальные фракции — свой виртуальный мир.
    gLockerPickup[FACTION_POLICE] = CreatePickup(1275, 1, 255.3, 77.4, 1003.6, 0);
    Create3DTextLabel("{33CC66}LSPD | РАЗДЕВАЛКА\n{FFFFFF}Сменить форму / гражданскую одежду", COLOR_WHITE, 255.3, 77.4, 1004.5, 8.0, 0, 1);
    gPoliceStashPickup = CreatePickup(1275, 1, 258.52, 76.8268, 1003.6406, 0);
    // FBI storage marker: Interior 6, virtual world 107.
    gFBIStashPickup = CreatePickup(1275, 1, 258.5231, 76.3146, 1003.6406, 107);
    Create3DTextLabel("{3399FF}FBI | ОРУЖЕЙНЫЙ СКЛАД\n{FFFFFF}Оружие и снаряжение", COLOR_WHITE, 258.5231, 76.3146, 1004.5, 8.0, 107, 1);
    Create3DTextLabel("{33CC66}LSPD | СКЛАД\n{FFFFFF}Получение служебного снаряжения", COLOR_WHITE, 258.52, 76.8268, 1004.5, 8.0, 0, 1);
    // Interior-only 3D label removed: use the exterior entrance marker instead.
    gLockerPickup[FACTION_CITYHALL] = CreatePickup(1275, 1, 391.0, 173.7, 1008.4, 100 + FACTION_CITYHALL);
    gLockerPickup[FACTION_HOSPITAL] = CreatePickup(1275, 1, 2504.0, -1692.0, 1014.7, 100 + FACTION_HOSPITAL);
    gLockerPickup[FACTION_ARMY] = CreatePickup(1275, 1, 2504.0, -1692.0, 1014.7, 100 + FACTION_ARMY);
    gLockerPickup[FACTION_NAVY] = CreatePickup(1275, 1, 2504.0, -1692.0, 1014.7, 100 + FACTION_NAVY);
    gLockerPickup[FACTION_AIRFORCE] = CreatePickup(1275, 1, 2504.0, -1692.0, 1014.7, 100 + FACTION_AIRFORCE);
    gLockerPickup[FACTION_FBI] = CreatePickup(1275, 1, 255.3, 77.4, 1003.6410, 100 + FACTION_FBI);
    Create3DTextLabel("{3399FF}FBI | \xd0\xc0\xc7\xc4\xc5\xc2\xc0\xcb\xca\xc0\n{FFFFFF}\xd4\xee\xf0\xec\xe0 \xef\xee \xf0\xe0\xed\xe3\xf3", COLOR_WHITE, 255.3, 77.4, 1004.5, 10.0, 100 + FACTION_FBI, 1);
    // Interior-only 3D label removed: use the exterior entrance marker instead.
    // Interior-only 3D label removed: use the exterior entrance marker instead.
    // Автосалон и АЗС VEXORIUM RP: свои маркеры вместо стандартных маркеров входа GTA.
    gCarDealerPickup = CreatePickup(1239, 1, 2131.0, -1150.0, 24.1, 0);
    gAccessoryShopPickup = CreatePickup(1275, 1, 1457.0, -1137.0, 23.9, 0);
    Create3DTextLabel("{39D98A}VEXORIUM | МАГАЗИН АКСЕССУАРОВ\n{FFFFFF}Шляпы, очки и маски\n/shopacc - открыть магазин", COLOR_WHITE, 1457.0, -1137.0, 25.0, 18.0, 0, 1);
    Create3DTextLabel("{39D98A}VEXORIUM | Автосалон\n{FFFFFF}/carshop — купить машину", COLOR_WHITE, 2131.0, -1150.0, 25.1, 18.0, 0, 1);
    // Convenience store building with a visible shopping pickup.
    gMarketPickup = CreatePickup(1274, 1, 1833.0, -1842.0, 13.3, 0);
    Create3DTextLabel("{33CC66}VEXORIUM | \xcc\xc0\xc3\xc0\xc7\xc8\xcd\n{FFFFFF}\xc0\xef\xf2\xe5\xf7\xea\xe0, \xe5\xe4\xe0, \xe2\xee\xe4\xe0, SIM, \xee\xf2\xec\xfb\xf7\xea\xe0\n\xce\xf2\xea\xf0\xfb\xf2\xfc: /shop | \xe7\xed\xe0\xf7\xee\xea \xed\xe0 \xea\xe0\xf0\xf2\xe5", COLOR_WHITE, 1833.0, -1842.0, 14.3, 30.0, 0, 1);
    gGasStationPickup[0] = CreatePickup(1650, 1, 1004.0, -939.3, 42.2, 0);
    gGasStationPickup[1] = CreatePickup(1650, 1, 1940.0, -1772.0, 13.4, 0);
    gGasStationPickup[2] = CreatePickup(1650, 1, -2025.0, 156.0, 28.9, 0);
    gGasStationPickup[3] = CreatePickup(1650, 1, 2115.0, 920.0, 10.8, 0);
    gGasStationPickup[4] = CreatePickup(1650, 1, -1605.0, -2714.0, 48.5, 0);
    Create3DTextLabel("{FFD700}VEXORIUM | АЗС\n{FFFFFF}В машине используйте /fuel", COLOR_WHITE, 1004.0, -939.3, 43.2, 12.0, 0, 1);
    Create3DTextLabel("{FFD700}VEXORIUM | АЗС\n{FFFFFF}В машине используйте /fuel", COLOR_WHITE, 1940.0, -1772.0, 14.4, 12.0, 0, 1);
    Create3DTextLabel("{FFD700}VEXORIUM | АЗС\n{FFFFFF}В машине используйте /fuel", COLOR_WHITE, -2025.0, 156.0, 29.9, 12.0, 0, 1);
    Create3DTextLabel("{FFD700}VEXORIUM | АЗС\n{FFFFFF}В машине используйте /fuel", COLOR_WHITE, 2115.0, 920.0, 11.8, 12.0, 0, 1);
    Create3DTextLabel("{FFD700}VEXORIUM | АЗС\n{FFFFFF}В машине используйте /fuel", COLOR_WHITE, -1605.0, -2714.0, 49.5, 12.0, 0, 1);
    SpawnBaseScooter();
    for (new f = 0; f < 8; f++) for (new t = 0; t < FLEET_TIERS; t++) gFleetVehicle[f][t] = INVALID_VEHICLE_ID;
    for (new v = 0; v < MAX_VEHICLES; v++) { gVehicleFaction[v] = 0; gVehicleTier[v] = 0; gVehicleReturnTimer[v] = 0; gVehicleFuel[v] = 100; gFuelLastX[v] = 0.0; gFuelLastY[v] = 0.0; gFuelLastZ[v] = 0.0; gPersonalVehicleOwner[v] = INVALID_PLAYER_ID; gCarjackVehicleOwner[v] = INVALID_PLAYER_ID; }
    SpawnFactionFleet();
    SpawnGangBases();
    EnableStuntBonusForAll(0);
    gDatabase = db_open("vexorium.db");
    if (gDatabase == DB:0)
    {
        print("[VEXORIUM] ERROR: SQLite database could not be opened!");
        return 1;
    }
    db_query(gDatabase, "CREATE TABLE IF NOT EXISTS accounts (name TEXT PRIMARY KEY, password TEXT NOT NULL, money INTEGER DEFAULT 5000, level INTEGER DEFAULT 1, kills INTEGER DEFAULT 0, deaths INTEGER DEFAULT 0, skin INTEGER DEFAULT 23, x REAL DEFAULT 1685.0, y REAL DEFAULT -2333.0, z REAL DEFAULT 13.5, angle REAL DEFAULT 0.0)");
    EnsureColumn("accounts", "job", "INTEGER DEFAULT 0");
    EnsureColumn("accounts", "admin", "INTEGER DEFAULT 0");
    EnsureColumn("accounts", "faction", "INTEGER DEFAULT 0");
    EnsureColumn("accounts", "faction_rank", "INTEGER DEFAULT 0");
    EnsureColumn("accounts", "ownedcar", "INTEGER DEFAULT 0");
    EnsureColumn("accounts", "spawnpref", "INTEGER DEFAULT 0");
    EnsureColumn("accounts", "gang", "INTEGER DEFAULT 0");
    EnsureColumn("accounts", "experience", "INTEGER DEFAULT 0");
    EnsureColumn("accounts", "license_driver", "INTEGER DEFAULT 0");
    EnsureColumn("accounts", "license_weapon", "INTEGER DEFAULT 0");
    EnsureColumn("accounts", "license_boat", "INTEGER DEFAULT 0");
    EnsureColumn("accounts", "license_air", "INTEGER DEFAULT 0");
    EnsureColumn("accounts", "has_passport", "INTEGER DEFAULT 0");
    EnsureColumn("accounts", "medkits", "INTEGER DEFAULT 1");
    EnsureColumn("accounts", "food", "INTEGER DEFAULT 2");
    EnsureColumn("accounts", "water", "INTEGER DEFAULT 2");
    EnsureColumn("accounts", "repairkits", "INTEGER DEFAULT 0");
    EnsureColumn("accounts", "simcards", "INTEGER DEFAULT 0");
    EnsureColumn("accounts", "lockpicks", "INTEGER DEFAULT 0");
    EnsureColumn("accounts", "accessory", "INTEGER DEFAULT 0");
    db_query(gDatabase, "CREATE TABLE IF NOT EXISTS bank_accounts (name TEXT PRIMARY KEY, balance INTEGER NOT NULL DEFAULT 0)");
    db_query(gDatabase, "CREATE TABLE IF NOT EXISTS police_records (name TEXT PRIMARY KEY, wanted INTEGER NOT NULL DEFAULT 0)");
    db_query(gDatabase, "CREATE TABLE IF NOT EXISTS houses (id INTEGER PRIMARY KEY, owner TEXT NOT NULL DEFAULT '', price INTEGER NOT NULL, x REAL NOT NULL, y REAL NOT NULL, z REAL NOT NULL)");
    db_query(gDatabase, "INSERT OR IGNORE INTO houses (id,owner,price,x,y,z) VALUES (1,'',250000,2495.0,-1692.0,14.8)");
    db_query(gDatabase, "INSERT OR IGNORE INTO houses (id,owner,price,x,y,z) VALUES (2,'',350000,2468.0,-1698.0,13.5)");
    db_query(gDatabase, "INSERT OR IGNORE INTO houses (id,owner,price,x,y,z) VALUES (3,'',500000,2421.0,-1220.0,25.5)");
    db_query(gDatabase, "CREATE TABLE IF NOT EXISTS gang_stashes (gang_id INTEGER PRIMARY KEY, money INTEGER DEFAULT 0)");
    db_query(gDatabase, "CREATE TABLE IF NOT EXISTS gang_weapon_stash (gang_id INTEGER NOT NULL, weapon_id INTEGER NOT NULL, ammo INTEGER DEFAULT 0, PRIMARY KEY(gang_id,weapon_id))");
    db_query(gDatabase, "CREATE TABLE IF NOT EXISTS org_stashes (faction_id INTEGER PRIMARY KEY, money INTEGER DEFAULT 0, materials INTEGER DEFAULT 0, ammo INTEGER DEFAULT 0, armour INTEGER DEFAULT 0)");
    for (new faction = 1; faction <= 7; faction++) { new orgInit[160]; format(orgInit, sizeof orgInit, "INSERT OR IGNORE INTO org_stashes (faction_id,money,materials,ammo,armour) VALUES (%d,0,1000,5000,100)", faction); new DBResult:orgRes = db_query(gDatabase, orgInit); if (orgRes) db_free_result(orgRes); }
    db_query(gDatabase, "INSERT OR IGNORE INTO gang_stashes (gang_id,money) VALUES (1,0)");
    db_query(gDatabase, "INSERT OR IGNORE INTO gang_stashes (gang_id,money) VALUES (2,0)");
    db_query(gDatabase, "INSERT OR IGNORE INTO gang_stashes (gang_id,money) VALUES (3,0)");
    db_query(gDatabase, "INSERT OR IGNORE INTO gang_stashes (gang_id,money) VALUES (4,0)");
    for (new gang = 1; gang <= 4; gang++)
    {
        new weaponIds[6] = {22,24,25,29,30,31};
        new weaponAmmo[6] = {120,60,40,120,120,120};
        for (new wi = 0; wi < 6; wi++)
        {
            new initQuery[160];
            format(initQuery, sizeof initQuery, "INSERT OR IGNORE INTO gang_weapon_stash (gang_id,weapon_id,ammo) VALUES (%d,%d,%d)", gang, weaponIds[wi], weaponAmmo[wi]);
            new DBResult:initResult = db_query(gDatabase, initQuery); if (initResult) db_free_result(initResult);
        }
    }
    print("[VEXORIUM RP] SQLite accounts ready.");
    print("[VEXORIUM RP] GPS, jobs, mining, 6 factions, rank uniforms and admin commands loaded.");
    SetTimer("PayDay", 40 * 60 * 1000, true);
    SetTimer("RefreshCarjackPursuits", 5000, true);
    SetTimer("RefreshNearbyMapVisibility", 1000, true);
    return 1;
}

stock GetWeekdayMondayFirst(day, month, year)
{
    new m = month, y = year;
    if (m < 3) { m += 12; y--; }
    new h = (day + (13 * (m + 1)) / 5 + y + y / 4 - y / 100 + y / 400) % 7;
    return (h + 5) % 7 + 1;
}

public InterviewAnnouncement()
{
    if (!gInterviewActive) return 0;
    new factionName[32], msg[192];
    GetFactionName(gInterviewFaction, factionName, sizeof factionName);
    if (gInterviewFaction == FACTION_POLICE)
        format(factionName, sizeof factionName, "Полиция LSPD");

    format(msg, sizeof msg, "Началось собеседование в организацию - %s.", factionName);
    SendClientMessageToAll(COLOR_BLUE, msg);
    SendClientMessageToAll(COLOR_BLUE, "Чтобы пройти собеседование вам нужно иметь при себе паспорт, 4 лвл, лицензию на авто и на оружие.");
    format(msg, sizeof msg, "Прийти на собеседование: /gps -> Организации -> %s.", factionName);
    SendClientMessageToAll(COLOR_BLUE, msg);
    SendClientMessageToAll(COLOR_BLUE, "Мы вас ждём!");
    return 1;
}

stock GetExperienceForLevel(level)
{
    if (level <= 1) return 0;
    if (level == 2) return 6;
    if (level == 3) return 12;
    if (level == 4) return 16;
    return level * 4;
}

public PayDay()
{
    new day, month, year;
    getdate(year, month, day);
    new weekday = GetWeekdayMondayFirst(day, month, year), multiplier = 1;
    if (weekday >= 1 && weekday <= 3) multiplier = 2;
    else if (weekday >= 5 && weekday <= 7) multiplier = 3;
    for (new playerid = 0; playerid < MAX_PLAYERS; playerid++)
    {
        if (!IsPlayerConnected(playerid) || !gLogged[playerid]) continue;
        new salary = 1000;
        switch (gJob[playerid]) { case 1: salary = 2500; case 2: salary = 3500; case 3: salary = 3000; case 4: salary = 4500; }
        if (gMoney[playerid] > MAX_MONEY - salary) salary = MAX_MONEY - gMoney[playerid];
        if (salary < 0) salary = 0;
        gMoney[playerid] += salary;
        GivePlayerMoney(playerid, salary);
        gExperience[playerid] += multiplier;
        new oldLevel = gLevel[playerid];
        while (gLevel[playerid] < 1000 && gExperience[playerid] >= GetExperienceForLevel(gLevel[playerid] + 1))
        {
            gLevel[playerid]++;
        }
        SetPlayerScore(playerid, gLevel[playerid]);
        new msg[192];
        format(msg, sizeof msg, "[PayDay] Выплата: %d руб. | Опыт: +%d (всего %d/%d).", salary, multiplier, gExperience[playerid], GetExperienceForLevel(gLevel[playerid] + 1));
        SendClientMessage(playerid, COLOR_GREEN, msg);
        if (gLevel[playerid] > oldLevel)
        {
            format(msg, sizeof msg, "[VEXORIUM] Поздравляем! Ваш уровень повышен до %d!", gLevel[playerid]);
            SendClientMessage(playerid, COLOR_YELLOW, msg);
            RefreshVexHud(playerid);
        }
        SavePlayer(playerid);
    }
    return 1;
}

public OnGameModeExit()
{
    for (new v = 0; v < MAX_VEHICLES; v++) if (gVehicleReturnTimer[v]) KillTimer(gVehicleReturnTimer[v]);
    for (new i = 0; i < MAX_PLAYERS; i++)
        if (IsPlayerConnected(i) && gLogged[i]) SavePlayer(i);
    if (gDatabase != DB:0) db_close(gDatabase);
    return 1;
}

stock UpdatePlayerRoleColor(playerid)
{
    if (!IsPlayerConnected(playerid)) return 0;
    if (gLogged[playerid] && gFaction[playerid] == FACTION_FBI && gFactionRank[playerid] > 0)
        SetPlayerColor(playerid, 0x101010FF); // FBI — чёрный ник и цвет игрока на карте
    else if (gLogged[playerid] && gFaction[playerid] == FACTION_POLICE && gFactionRank[playerid] > 0)
        SetPlayerColor(playerid, 0x3399FFFF); // LSPD — синий
    else
        SetPlayerColor(playerid, 0xFFFFFFFF); // Гражданские и остальные фракции — белый
    return 1;
}

stock SavePvpLoadout(playerid)
{
    for (new slot = 0; slot < 13; slot++) GetPlayerWeaponData(playerid, slot, gPvpOldWeapon[playerid][slot], gPvpOldAmmo[playerid][slot]);
    GetPlayerPos(playerid, gPvpOldX[playerid], gPvpOldY[playerid], gPvpOldZ[playerid]);
    GetPlayerFacingAngle(playerid, gPvpOldA[playerid]);
    gPvpOldInterior[playerid] = GetPlayerInterior(playerid);
    gPvpOldWorld[playerid] = GetPlayerVirtualWorld(playerid);
    return 1;
}

stock RestorePvpPlayer(playerid)
{
    SetPlayerInterior(playerid, gPvpOldInterior[playerid]);
    SetPlayerVirtualWorld(playerid, gPvpOldWorld[playerid]);
    SetPlayerPos(playerid, gPvpOldX[playerid], gPvpOldY[playerid], gPvpOldZ[playerid]);
    SetPlayerFacingAngle(playerid, gPvpOldA[playerid]);
    SetCameraBehindPlayer(playerid);
    ResetPlayerWeapons(playerid);
    for (new slot = 0; slot < 13; slot++)
        if (gPvpOldWeapon[playerid][slot] > 0 && gPvpOldAmmo[playerid][slot] > 0)
            GivePlayerWeapon(playerid, gPvpOldWeapon[playerid][slot], gPvpOldAmmo[playerid][slot]);
    SetPlayerHealth(playerid, 100.0);
    SetPlayerArmour(playerid, 0.0);
    gPvpRestorePending[playerid] = false;
    gPvpOpponent[playerid] = INVALID_PLAYER_ID;
    gPvpScore[playerid] = 0;
    return 1;
}

stock PutPlayerInPvpArena(playerid, side)
{
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, gPvpArenaWorld[playerid]);
    if (side == 0) { SetPlayerPos(playerid, 1650.0, -2400.0, 13.5); SetPlayerFacingAngle(playerid, 90.0); }
    else { SetPlayerPos(playerid, 1660.0, -2400.0, 13.5); SetPlayerFacingAngle(playerid, 270.0); }
    SetCameraBehindPlayer(playerid);
    SetPlayerHealth(playerid, 100.0);
    SetPlayerArmour(playerid, 0.0);
    ResetPlayerWeapons(playerid);
    GivePlayerWeapon(playerid, 24, 100);
    return 1;
}

stock FinishPvp(winnerid, loserid)
{
    new msg[144];
    format(msg, sizeof msg, "[VEXORIUM | PvP] %s победил со счётом 5:%d! Дуэль завершена.", gName[winnerid], gPvpScore[loserid]);
    if (IsPlayerConnected(winnerid)) SendClientMessage(winnerid, COLOR_GREEN, msg);
    if (IsPlayerConnected(loserid)) SendClientMessage(loserid, COLOR_RED, msg);
    if (IsPlayerConnected(winnerid)) { gPvpActive[winnerid] = false; gPvpRestorePending[winnerid] = true; gPvpOpponent[winnerid] = INVALID_PLAYER_ID; SpawnPlayer(winnerid); }
    if (IsPlayerConnected(loserid)) { gPvpActive[loserid] = false; gPvpRestorePending[loserid] = true; gPvpOpponent[loserid] = INVALID_PLAYER_ID; SpawnPlayer(loserid); }
    return 1;
}

public PvpRespawn(playerid)
{
    if (IsPlayerConnected(playerid) && gPvpActive[playerid])
    {
        new opponent = gPvpOpponent[playerid];
        if (opponent != INVALID_PLAYER_ID && IsPlayerConnected(opponent) && gPvpActive[opponent])
        {
            SpawnPlayer(playerid);
            SendClientMessage(playerid, COLOR_YELLOW, "[PvP] Раунд продолжается. Побеждает первый, кто наберёт 5 побед.");
        }
    }
    return 1;
}

public OnPlayerConnect(playerid)
{
    gFBIPendingEnter[playerid] = false;
    gFBIEnterTimer[playerid] = 0;
    gFBIEditObject[playerid] = INVALID_OBJECT_ID;
    gFBIEditActive[playerid] = false;
    gFBIEditMoveObject[playerid] = false;
    gFBIEditorCamX[playerid] = 0.0;
    gFBIEditorCamY[playerid] = 0.0;
    gFBIEditorCamZ[playerid] = 0.0;
    gLastObservedWeapon[playerid] = 0;
    gPvpPendingFrom[playerid] = INVALID_PLAYER_ID;
    gPvpRequestTarget[playerid] = INVALID_PLAYER_ID;
    gPvpOpponent[playerid] = INVALID_PLAYER_ID;
    gPvpScore[playerid] = 0;
    gPvpActive[playerid] = false;
    gPvpRestorePending[playerid] = false;
    gPvpArenaWorld[playerid] = 0;
    gCurrentHouse[playerid] = 0;
    gBankMoney[playerid] = 0;
    gMedkits[playerid] = 1;
    gFood[playerid] = 2;
    gWater[playerid] = 2;
    gRepairKits[playerid] = 0;
    gSimCards[playerid] = 0;
    gLockpicks[playerid] = 0;
    gCarjackPursuitNotified[playerid] = false;
    gPhoneSmsTarget[playerid] = INVALID_PLAYER_ID;
    gWantedLevel[playerid] = 0;
    gHandcuffed[playerid] = false;
    gCuffOfficer[playerid] = INVALID_PLAYER_ID;
    gHandcuffObject[playerid] = INVALID_OBJECT_ID;
    gTaserStunned[playerid] = false;
    gPursuitTarget[playerid] = INVALID_PLAYER_ID;
    gMedicPending[playerid] = 0;
    gNeedsMedicalHelp[playerid] = false;
    gDeathTimer[playerid] = 0;
    gDeathSkin[playerid] = 23;
    gDeathX[playerid] = 1176.7; gDeathY[playerid] = -1322.5; gDeathZ[playerid] = 13.5;
    gCarjackActive[playerid] = false; gCarjackUnlocked[playerid] = false; gCarjackVehicle[playerid] = INVALID_VEHICLE_ID; gCarjackDestination[playerid] = 0; gCarjackPending[playerid] = 0;
    gDrivingTestStage[playerid] = 0; gDrivingTestVehicle[playerid] = INVALID_VEHICLE_ID; gDrivingExamPassed[playerid] = 0;
    SetPlayerColor(playerid, 0xFFFFFFFF);
    HideVexDefaultHud(playerid);
    SetPlayerMapIcon(playerid, 20, 1488.0, -1750.0, 13.5, 55, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 22, 1176.7, -1322.5, 12.1, 55, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 23, 404.5, 2488.8, 16.5, 55, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 24, -1430.0, 508.0, 18.0, 55, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 25, 1960.0, -2620.0, 13.5, 55, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 30, 1477.0, -1771.9234, 18.7957, 19, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 32, 1176.7, -1322.5, 12.1, 22, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 33, 404.5, 2488.8, 16.5, 19, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 34, -1380.0, 508.0, 18.0, 19, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 35, 1940.0, -2620.0, 13.5, 19, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 40, 2131.0, -1150.0, 24.1, 55, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 41, 1004.0, -939.3, 42.2, 55, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 42, 1940.0, -1772.0, 13.4, 55, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 43, -2025.0, 156.0, 28.9, 55, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 44, 2115.0, 920.0, 10.8, 55, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 45, -1605.0, -2714.0, 48.5, 55, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 46, 1833.0, -1842.0, 13.3, 55, 0, MAPICON_GLOBAL); // Main market
    SetPlayerMapIcon(playerid, 47, 1457.0, -1137.0, 23.9, 55, 0, MAPICON_GLOBAL); // Accessories shop
    SetPlayerMapIcon(playerid, 51, 2497.5, -1688.5, 13.5, 6, 0, MAPICON_GLOBAL); // Grove Street warehouse
    SetPlayerMapIcon(playerid, 52, 2002.5, -1115.5, 25.0, 6, 0, MAPICON_GLOBAL); // Ballas warehouse
    SetPlayerMapIcon(playerid, 53, 2771.5, -1629.5, 10.9, 6, 0, MAPICON_GLOBAL); // Vagos warehouse
    SetPlayerMapIcon(playerid, 54, 1842.5, -2036.5, 13.5, 6, 0, MAPICON_GLOBAL); // Aztecas warehouse
    gLastTaserTick[playerid] = 0;
    gCuffOfficer[playerid] = INVALID_PLAYER_ID;
    gHandcuffObject[playerid] = INVALID_OBJECT_ID;
    SetPlayerMapIcon(playerid, 50, 2131.0, -1150.0, 24.1, 55, 0, MAPICON_GLOBAL); // Car dealership
    GetPlayerName(playerid, gName[playerid], MAX_PLAYER_NAME + 1);
    gOwnedCarModel[playerid] = 0;
    gAccessoryModel[playerid] = 0;
    gOwnedCarVehicle[playerid] = INVALID_VEHICLE_ID;
    // Создаём и сразу показываем собственный HUD при подключении.
    // Это также позволяет проверить, что сервер действительно загрузил этот AMX.
    // Reset player state before showing the custom HUD.
    gLogged[playerid] = false;
    gAdmin[playerid] = 0;
    gHudTimer[playerid] = 0;
    CreateVexHud(playerid);
    PlayerTextDrawSetString(playerid, gHudInfo[playerid], "\xc0\xca\xca\xc0\xd3\xcd\xd2 | \xc2\xce\xc9\xc4\xc8\xd2\xc5 \xc8\xcb\xc8 \xc7\xc0\xd0\xc5\xc3\xc8\xd1\xd2\xd0\xc8\xd0\xd3\xc9\xd2\xc5\xd1\xdc");
    PlayerTextDrawShow(playerid, gHudTitle[playerid]);
    PlayerTextDrawShow(playerid, gHudInfo[playerid]);
    if (gHudTimer[playerid]) KillTimer(gHudTimer[playerid]);
    gHudTimer[playerid] = SetTimerEx("RefreshVexHud", 1000, true, "i", playerid);
    gJob[playerid] = 0;
    gFaction[playerid] = 0;
    gFactionRank[playerid] = 0;
    gSpawnPreference[playerid] = 0;
    gRentalVehicle[playerid] = INVALID_VEHICLE_ID;
    gPendingScooterChoice[playerid] = false;
    gFactionVehicle[playerid] = INVALID_VEHICLE_ID;
    gWorkStage[playerid] = 0;
    gWorkVehicle[playerid] = INVALID_VEHICLE_ID;
    gGpsActive[playerid] = false;
    gSpawnMenuShown[playerid] = false;
    gIsJailed[playerid] = false;
    gJailTimer[playerid] = 0;
    SetPlayerMapIcon(playerid, 21, 1764.0, -1898.0, 13.5, 55, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 22, 1477.0, -1771.9234, 18.7957, 55, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 23, 1176.7, -1322.5, 12.1, 55, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 24, 404.5, 2488.8, 16.5, 55, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 25, -1380.0, 508.0, 18.0, 55, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 26, 1940.0, -2620.0, 13.5, 55, 0, MAPICON_LOCAL);
    TogglePlayerSpectating(playerid, true);
    if (gDatabase == DB:0)
    {
        SendClientMessage(playerid, COLOR_RED, "[VEXORIUM] Ошибка базы данных. Попробуйте позже.");
        Kick(playerid);
        return 1;
    }
    new query[512];
    format(query, sizeof query, "SELECT name FROM accounts WHERE name='%q'", gName[playerid]);
    new DBResult:connectResult = db_query(gDatabase, query);
    if (connectResult && db_num_rows(connectResult))
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "VEXORIUM | ДОБРО ПОЖАЛОВАТЬ", "================================\n             V E X O R I U M\n          ГОРОД ЖДЁТ ТЕБЯ\n\nАккаунт найден. Введи свой пароль.\nПароль скрыт во время ввода.\n\nНажми ВОЙТИ для входа на сервер.", "ВОЙТИ", "ВЫХОД");
    else
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "VEXORIUM | СОЗДАНИЕ АККАУНТА", "================================\n             V E X O R I U M\n       ТВОЯ ИСТОРИЯ НАЧИНАЕТСЯ\n\nНовый аккаунт не найден.\nПридумай пароль от 4 до 64 символов.\nЗапомни его: он понадобится при следующем входе.\n\nНажми СОЗДАТЬ для регистрации.", "СОЗДАТЬ", "ВЫХОД");
    if (connectResult) db_free_result(connectResult);
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    if (gHandcuffObject[playerid] != INVALID_OBJECT_ID) { DestroyObject(gHandcuffObject[playerid]); gHandcuffObject[playerid] = INVALID_OBJECT_ID; }
    if (gCuffOfficer[playerid] != INVALID_PLAYER_ID && IsPlayerConnected(gCuffOfficer[playerid])) gCuffOfficer[playerid] = INVALID_PLAYER_ID;
    if (gFBIEnterTimer[playerid]) { KillTimer(gFBIEnterTimer[playerid]); gFBIEnterTimer[playerid] = 0; }
    gFBIPendingEnter[playerid] = false;
    if (gPvpPendingFrom[playerid] != INVALID_PLAYER_ID && IsPlayerConnected(gPvpPendingFrom[playerid]))
        gPvpRequestTarget[gPvpPendingFrom[playerid]] = INVALID_PLAYER_ID;
    if (gPvpRequestTarget[playerid] != INVALID_PLAYER_ID && IsPlayerConnected(gPvpRequestTarget[playerid]))
        gPvpPendingFrom[gPvpRequestTarget[playerid]] = INVALID_PLAYER_ID;
    if (gPvpActive[playerid])
    {
        new opponent = gPvpOpponent[playerid];
        if (opponent != INVALID_PLAYER_ID && IsPlayerConnected(opponent))
        {
            gPvpActive[opponent] = false;
            gPvpOpponent[opponent] = INVALID_PLAYER_ID;
            gPvpRestorePending[opponent] = true;
            SendClientMessage(opponent, COLOR_GREEN, "[PvP] Соперник вышел с сервера. Вы выиграли дуэль.");
            SpawnPlayer(opponent);
        }
    }
    if (gDrivingTestVehicle[playerid] != INVALID_VEHICLE_ID)
    {
        DestroyVehicle(gDrivingTestVehicle[playerid]);
        gDrivingTestVehicle[playerid] = INVALID_VEHICLE_ID;
        gDrivingTestStage[playerid] = 0;
    }
    if (gJailTimer[playerid]) { KillTimer(gJailTimer[playerid]); gJailTimer[playerid] = 0; }
    if (gRentalVehicle[playerid] != INVALID_VEHICLE_ID) { DestroyVehicle(gRentalVehicle[playerid]); gRentalVehicle[playerid] = INVALID_VEHICLE_ID; }
    if (gOwnedCarVehicle[playerid] != INVALID_VEHICLE_ID && GetVehicleModel(gOwnedCarVehicle[playerid]) != 0) { gPersonalVehicleOwner[gOwnedCarVehicle[playerid]] = INVALID_PLAYER_ID; DestroyVehicle(gOwnedCarVehicle[playerid]); }
    gOwnedCarVehicle[playerid] = INVALID_VEHICLE_ID;
    if (gHudTimer[playerid]) { KillTimer(gHudTimer[playerid]); gHudTimer[playerid] = 0; }
    DestroyVexHud(playerid);
    gPendingScooterChoice[playerid] = false;
    if (gBaseScooter == INVALID_VEHICLE_ID) SpawnBaseScooter();
    if (gFactionVehicle[playerid] != INVALID_VEHICLE_ID)
    {
        new factionVehicle = gFactionVehicle[playerid];
        if (factionVehicle > 0 && factionVehicle < MAX_VEHICLES && GetVehicleModel(factionVehicle) != 0)
        {
            if (gVehicleReturnTimer[factionVehicle]) { KillTimer(gVehicleReturnTimer[factionVehicle]); gVehicleReturnTimer[factionVehicle] = 0; }
            gVehicleFaction[factionVehicle] = 0;
            gVehicleTier[factionVehicle] = 0;
            gFactionVehicleOwner[factionVehicle] = INVALID_PLAYER_ID;
            DestroyVehicle(factionVehicle);
        }
        gFactionVehicle[playerid] = INVALID_VEHICLE_ID;
    }
    if (gWorkVehicle[playerid] != INVALID_VEHICLE_ID && GetVehicleModel(gWorkVehicle[playerid]) != 0) DestroyVehicle(gWorkVehicle[playerid]);
    gWorkVehicle[playerid] = INVALID_VEHICLE_ID;
    if (gLogged[playerid]) SavePlayer(playerid);
    gLogged[playerid] = false;
    gHandcuffed[playerid] = false; gCuffOfficer[playerid] = INVALID_PLAYER_ID; gHandcuffObject[playerid] = INVALID_OBJECT_ID; gTaserStunned[playerid] = false;
    gWantedLevel[playerid] = 0;
    gPursuitTarget[playerid] = INVALID_PLAYER_ID;
    gWorkStage[playerid] = 0;
    gGpsActive[playerid] = false;
    gSpawnMenuShown[playerid] = false;
    if (gFBIEditObject[playerid] != INVALID_OBJECT_ID)
    {
        DestroyObject(gFBIEditObject[playerid]);
        gFBIEditObject[playerid] = INVALID_OBJECT_ID;
    }
    if (gFBIEditActive[playerid])
    {
        SetCameraBehindPlayer(playerid);
        TogglePlayerControllable(playerid, 1);
    }
    gFBIEditActive[playerid] = false;
    return 1;
}

public OnPlayerSpawn(playerid)
{
    HideVexDefaultHud(playerid);
    UpdatePlayerRoleColor(playerid);
    if (gLogged[playerid]) ShowVexHud(playerid);
    if (gLogged[playerid]) gDeathSkin[playerid] = GetPlayerSkin(playerid);
    if (gLogged[playerid] && gAccessoryModel[playerid] > 0) SetPlayerAttachedObject(playerid, 0, gAccessoryModel[playerid], 2, 0.10, 0.02, 0.00, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
    if (!gLogged[playerid])
    {
        TogglePlayerSpectating(playerid, true);
        return 1;
    }
    if (gPvpActive[playerid])
    {
        PutPlayerInPvpArena(playerid, playerid < gPvpOpponent[playerid] ? 0 : 1);
        return 1;
    }
    if (gPvpRestorePending[playerid])
    {
        RestorePvpPlayer(playerid);
        return 1;
    }
    if (gIsJailed[playerid])
    {
        SetPlayerInterior(playerid, 6);
        SetPlayerVirtualWorld(playerid, 0);
        SetPlayerPos(playerid, 264.4, 77.5, 1001.0);
        SetPlayerFacingAngle(playerid, 90.0);
        SetCameraBehindPlayer(playerid);
        SendClientMessage(playerid, COLOR_RED, "Вы в КПЗ. Дождитесь окончания срока заключения.");
        return 1;
    }
    // Если место уже выбрано, сохраняем его для входов и после смерти.
    if (gSpawnPreference[playerid] == 1 || gSpawnPreference[playerid] == 2)
        ApplySavedSpawn(playerid);
    else
        ShowSpawnMenu(playerid);
    return 1;
}

stock IsPlayerInGreenZone(playerid)
{
    // Внутренние помещения (участок, мэрия, больница и другие интерьеры) — безопасная зона.
    if (!IsPlayerConnected(playerid)) return 0;
    return (GetPlayerInterior(playerid) != 0);
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
    #pragma unused bodypart
    if (weaponid == 23 && !IsPlayerInGreenZone(playerid) && (issuerid == INVALID_PLAYER_ID || !IsPlayerInGreenZone(issuerid)))
    {
        new Float:health;
        GetPlayerHealth(playerid, health);
        SetPlayerHealth(playerid, health + amount);
    }
    if (IsPlayerInGreenZone(playerid) || (issuerid != INVALID_PLAYER_ID && IsPlayerInGreenZone(issuerid)))
    {
        new Float:health;
        GetPlayerHealth(playerid, health);
        SetPlayerHealth(playerid, health + amount);
        if (issuerid != INVALID_PLAYER_ID)
            SendClientMessage(issuerid, COLOR_GREEN, "[GREEN ZONE] Внутри зданий нельзя наносить урон.");
        SendClientMessage(playerid, COLOR_GREEN, "[GREEN ZONE] Вы находитесь в безопасной зоне.");
        return 0;
    }
    return 1;
}

public OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart)
{
    #pragma unused amount
    #pragma unused bodypart
    if (IsPlayerInGreenZone(playerid) || IsPlayerInGreenZone(damagedid)) return 1;
    // LSPD baton (weapon 3) and FBI USP taser (weapon 23) knock a suspect down.
    if ((weaponid == 3 || weaponid == 23) && IsPlayerConnected(damagedid) && !gHandcuffed[damagedid] && !gTaserStunned[damagedid])
    {
        if (weaponid == 23)
        {
            new taserTick = GetTickCount();
            if (gLastTaserTick[playerid] != 0 && taserTick - gLastTaserTick[playerid] < 15000)
            {
                SendClientMessage(playerid, COLOR_YELLOW, "[\xd2\xc0\xc9\xc7\xc5\xd0] \xcf\xe5\xf0\xe5\xe7\xe0\xf0\xff\xe4\xea\xe0: \xef\xee\xe4\xee\xe6\xe4\xe8\xf2\xe5 15 \xf1\xe5\xea\xf3\xed\xe4.");
                return 1;
            }
            gLastTaserTick[playerid] = taserTick;
        }
        gTaserStunned[damagedid] = true;
        ClearAnimations(damagedid);
        SetPlayerSpecialAction(damagedid, SPECIAL_ACTION_NONE);
        TogglePlayerControllable(damagedid, 1);
        // One-shot fall animation; keep the player down and unable to move afterward.
        ApplyAnimation(damagedid, "PED", "KO_shot_front", 4.1, 0, 0, 0, 1, 0);
        SetPlayerDrunkLevel(damagedid, 50000);
        TogglePlayerControllable(damagedid, 0);
        if (weaponid == 23)
        {
            SendClientMessage(damagedid, COLOR_RED, "\xc2\xfb \xef\xee\xef\xe0\xeb\xe8 \xef\xee \xf2\xe0\xe9\xe7\xe5\xf0\xf3! \xc2\xfb \xee\xf2\xea\xeb\xfe\xf7\xe5\xed\xfb \xed\xe0 10 \xf1\xe5\xea\xf3\xed\xe4.");
            SendClientMessage(playerid, COLOR_GREEN, "\xc2\xfb \xef\xee\xef\xe0\xeb\xe8 \xe2 \xe8\xe3\xf0\xee\xea\xe0 \xf2\xe0\xe9\xe7\xe5\xf0\xee\xec USP.");
        }
        else
        {
            SendClientMessage(damagedid, COLOR_RED, "\xc2\xe0\xf1 \xee\xe3\xeb\xf3\xf8\xe8\xeb\xe8 \xe4\xf3\xe1\xe8\xed\xea\xee\xe9! \xc2\xfb \xed\xe5 \xec\xee\xe6\xe5\xf2\xe5 \xe4\xe2\xe8\xe3\xe0\xf2\xfc\xf1\xff 10 \xf1\xe5\xea\xf3\xed\xe4.");
            SendClientMessage(playerid, COLOR_GREEN, "\xc2\xfb \xee\xe3\xeb\xf3\xf8\xe8\xeb\xe8 \xe8\xe3\xf0\xee\xea\xe0 \xe4\xf3\xe1\xe8\xed\xea\xee\xe9.");
        }
        SetTimerEx("UnstunPlayer", 10000, false, "i", damagedid);
    }
    return 1;
}

public UnstunPlayer(playerid)
{
    if (IsPlayerConnected(playerid))
    {
        gTaserStunned[playerid] = false;
        SetPlayerDrunkLevel(playerid, 0);
        if (!gHandcuffed[playerid])
        {
            ClearAnimations(playerid);
            TogglePlayerControllable(playerid, 1);
        }
    }
    return 1;
}

forward VexRespawnAfterDeath(playerid);

public VexRespawnAfterDeath(playerid)
{
    if (!IsPlayerConnected(playerid) || !gLogged[playerid] || !gNeedsMedicalHelp[playerid]) return 0;
    gDeathTimer[playerid] = 0;
    new skin = gDeathSkin[playerid];
    if (skin < 0 || skin > 311) skin = 23;
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    SetSpawnInfo(playerid, 0, skin, 1176.7, -1322.5, 13.5, 0.0, 0, 0, 0, 0, 0, 0);
    gSpawnPreference[playerid] = 3;
    SpawnPlayer(playerid);
    SetPlayerSkin(playerid, skin);
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerPos(playerid, 1176.7, -1322.5, 13.5);
    SetPlayerFacingAngle(playerid, 0.0);
    SetCameraBehindPlayer(playerid);
    gNeedsMedicalHelp[playerid] = false;
    SendClientMessage(playerid, COLOR_GREEN, "[VEXORIUM] You woke up at the hospital.");
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    if (gPvpActive[playerid])
    {
        new opponent = gPvpOpponent[playerid];
        if (opponent != INVALID_PLAYER_ID && IsPlayerConnected(opponent) && gPvpActive[opponent] && killerid == opponent)
        {
            gPvpScore[opponent]++;
            new scoreMsg[128];
            format(scoreMsg, sizeof scoreMsg, "[PvP] Счёт: %s %d : %d %s", gName[opponent], gPvpScore[opponent], gPvpScore[playerid], gName[playerid]);
            SendClientMessage(opponent, COLOR_GREEN, scoreMsg);
            SendClientMessage(playerid, COLOR_YELLOW, scoreMsg);
            if (gPvpScore[opponent] >= 5) { FinishPvp(opponent, playerid); return 1; }
        }
        SetTimerEx("PvpRespawn", 1000, false, "i", playerid);
        return 1;
    }
    SendClientMessage(playerid, COLOR_YELLOW, "[VEXORIUM] Вы без сознания. Ожидайте помощи медиков.");
    gNeedsMedicalHelp[playerid] = true;
    gDeathSkin[playerid] = GetPlayerSkin(playerid);
    if (gDeathSkin[playerid] < 0 || gDeathSkin[playerid] > 311) gDeathSkin[playerid] = 23;
    GetPlayerPos(playerid, gDeathX[playerid], gDeathY[playerid], gDeathZ[playerid]);
    for (new medic = 0; medic < MAX_PLAYERS; medic++)
    {
        if (!IsPlayerConnected(medic) || !gLogged[medic] || gFaction[medic] != FACTION_HOSPITAL) continue;
        gMedicPending[medic] = playerid + 1;
        SendClientMessage(medic, COLOR_RED, "[HOSPITAL] Emergency call: player unconscious. Accept: /accept, decline: /cancel.");
    }
    if (gDeathTimer[playerid]) KillTimer(gDeathTimer[playerid]);
    gDeathTimer[playerid] = SetTimerEx("VexRespawnAfterDeath", 60000, false, "i", playerid);
    if (gLogged[playerid])
    {
        gDeaths[playerid]++;
        SavePlayer(playerid);
    }
    if (killerid != INVALID_PLAYER_ID && killerid != playerid && gLogged[killerid])
    {
        gKills[killerid]++;
        if (GiveCash(killerid, 500))
            SendClientMessage(killerid, COLOR_GREEN, "[VEXORIUM] За победу начислено 500 рублей.");
        SavePlayer(killerid);
    }
    return 1;
}

public FinishFBIEnter(playerid)
{
    gFBIEnterTimer[playerid] = 0;
    if (!IsPlayerConnected(playerid) || !gFBIPendingEnter[playerid]) return 1;
    gFBIPendingEnter[playerid] = false;
    if (!gLogged[playerid]) return 1;
    if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0 || !IsPlayerInRangeOfPoint(playerid, 4.0, -2281.9553, 2288.3784, 4.9739))
    {
        SendClientMessage(playerid, COLOR_YELLOW, "FBI: Entry cancelled - stay by the marker for 2 seconds.");
        return 1;
    }
    EnterOrgInteriorForFaction(playerid, FACTION_FBI);
    return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
    if (gGang[playerid] >= 1 && gGang[playerid] <= 4 && pickupid == gGangStashPickup[gGang[playerid]])
    {
        new Float:bx, Float:by, Float:bz;
        GetGangBase(gGang[playerid], bx, by, bz);
        if (GetPlayerInterior(playerid) == 0 && GetPlayerVirtualWorld(playerid) == 0 && GetPlayerDistanceFromPoint(playerid, bx, by, bz) <= 12.0)
            ShowPlayerDialog(playerid, DIALOG_GANG_STASH, DIALOG_STYLE_LIST, "\xd1\xea\xeb\xe0\xe4 \xe1\xe0\xed\xe4\xfb", "\xcf\xee\xeb\xee\xe6\xe8\xf2\xfc \xe4\xe5\xed\xfc\xe3\xe8\n\xd1\xed\xff\xf2\xfc \xe4\xe5\xed\xfc\xe3\xe8\n\xc1\xe0\xeb\xe0\xed\xf1 \xf1\xea\xeb\xe0\xe4\xe0\n\xce\xf0\xf3\xe6\xe8\xe5 \xe8 \xef\xe0\xf2\xf0\xee\xed\xfb\n\xcf\xee\xeb\xf3\xf7\xe8\xf2\xfc \xe1\xf0\xee\xed\xe5\xe6\xe8\xeb\xe5\xf2", "\xc2\xfb\xe1\xf0\xe0\xf2\xfc", "\xc7\xe0\xea\xf0\xfb\xf2\xfc");
        else SendClientMessage(playerid, COLOR_RED, "\xd1\xea\xeb\xe0\xe4 \xe4\xee\xf1\xf2\xf3\xef\xe5\xed \xf2\xee\xeb\xfc\xea\xee \xed\xe0 \xe1\xe0\xe7\xe5 \xe2\xe0\xf8\xe5\xe9 \xe1\xe0\xed\xe4\xfb.");
        return 1;
    }
    if (!gLogged[playerid]) return 1;
    // Ignore pickup callbacks for a short period after one interaction; prevents teleport loops.
    new tick = GetTickCount();
    if (pickupid != gLicenseMarketPickup && pickupid != gPassportPickup && pickupid != gHospitalMarketPickup && gLastPickupTick[playerid] != 0 && tick - gLastPickupTick[playerid] < PICKUP_TELEPORT_COOLDOWN) return 1;
    gLastPickupTick[playerid] = tick;
    if (pickupid == gHospitalMarketPickup)
    {
        if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0 || !IsPlayerInRangeOfPoint(playerid, 3.0, 1180.2, -1322.5, 13.5)) return 1;
        new Float:currentHealth;
        GetPlayerHealth(playerid, currentHealth);
        if (currentHealth >= 99.9)
            return SendClientMessage(playerid, COLOR_YELLOW, "[БОЛЬНИЦА] У вас уже полное здоровье."), 1;
        if (!TakeCash(playerid, 500))
            return SendClientMessage(playerid, COLOR_RED, "[БОЛЬНИЦА] Аптечка стоит $500. Недостаточно наличных."), 1;
        SetPlayerHealth(playerid, 100.0);
        SavePlayer(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "[БОЛЬНИЦА] Аптечка-сердце куплена за $500. Здоровье восстановлено!");
        return 1;
    }
    if (pickupid == gLicenseMarketPickup)
    {
        // Do not reopen the license dialog while the player remains inside the marker.
        if (gLicenseMarketLocked[playerid]) return 1;
        gLicenseMarketLocked[playerid] = true;
        ShowPlayerDialog(playerid, DIALOG_LICENSE_MARKET, DIALOG_STYLE_LIST, "VEXORIUM RP | Рынок лицензий", "Лицензия на оружие — 30 000 руб.\nЛицензия на лодку — 20 000 руб.\nЛицензия на самолёт — 40 000 руб.\nВодительские права — после экзамена", "Выбрать", "Закрыть");
        return 1;
    }
    if (pickupid == gPassportPickup)
    {
        if (gHasPassport[playerid]) return SendClientMessage(playerid, COLOR_GREEN, "У вас уже есть паспорт."), 1;
        ShowPlayerDialog(playerid, DIALOG_PASSPORT, DIALOG_STYLE_MSGBOX, "VEXORIUM RP | Оформление паспорта", "Для устройства на работу и доступа к городским услугам необходимо оформить паспорт.\n\nОформление бесплатное. Получить паспорт?", "Получить", "Отмена");
        return 1;
    }
    if (pickupid == gMarketPickup)
    {
        if (GetPlayerInterior(playerid) != 0) return 1;
        if (GetPlayerVirtualWorld(playerid) != 0) return 1;
        if (!IsPlayerInRangeOfPoint(playerid, 4.0, 1833.0, -1842.0, 13.3)) return 1;
        new shopItems[420];
        format(shopItems, sizeof shopItems, "\xc0\xef\xf2\xe5\xf7\xea\xe0 - 750 \xf0\xf3\xe1.\n\xc5\xe4\xe0 - 150 \xf0\xf3\xe1.\n\xc2\xee\xe4\xe0 - 100 \xf0\xf3\xe1.\n\xc1\xf3\xea\xe5\xf2: \xe5\xe4\xe0 + \xe2\xee\xe4\xe0 - 200 \xf0\xf3\xe1.");
        strcat(shopItems, "\n\xd0\xe5\xec\xee\xed\xf2\xed\xfb\xe9 \xea\xee\xec\xef\xeb\xe5\xea\xf2 - 2 000 \xf0\xf3\xe1.\nSIM-\xea\xe0\xf0\xf2\xe0 - 1 000 \xf0\xf3\xe1.");
        strcat(shopItems, "\n\xce\xf2\xec\xfb\xf7\xea\xe0 \xe4\xeb\xff \xe0\xe2\xf2\xee\xf3\xe3\xee\xed\xe0 - 5 000 \xf0\xf3\xe1.");
        ShowPlayerDialog(playerid, DIALOG_SHOP, DIALOG_STYLE_LIST, "VEXORIUM | \xcc\xc0\xc3\xc0\xc7\xc8\xcd", shopItems, "\xca\xf3\xef\xe8\xf2\xfc", "\xc7\xe0\xea\xf0\xfb\xf2\xfc");
        return 1;
    }
    if (pickupid == gCarDealerPickup)
    {
        SendClientMessage(playerid, COLOR_GREEN, "Автосалон VEXORIUM: подойдите ближе и используйте /carshop.");
        return 1;
    }
    if (pickupid == gAccessoryShopPickup)
    {
        SendClientMessage(playerid, COLOR_GREEN, "[АКСЕССУАРЫ] Используйте /shopacc, чтобы открыть магазин.");
        return 1;
    }
    for (new gas = 0; gas < 5; gas++)
    {
        if (pickupid == gGasStationPickup[gas])
        {
            SendClientMessage(playerid, COLOR_YELLOW, "АЗС VEXORIUM: остановитесь рядом с колонкой и используйте /fuel.");
            return 1;
        }
    }
    if (pickupid == gFBIStashPickup && IsInOwnOrgInterior(playerid))
    {
        if (gFaction[playerid] != FACTION_FBI || gFactionRank[playerid] < 1)
            return SendClientMessage(playerid, COLOR_RED, "\xd1\xea\xeb\xe0\xe4 FBI \xe4\xee\xf1\xf2\xf3\xef\xe5\xed \xf2\xee\xeb\xfc\xea\xee \xf1\xee\xf2\xf0\xf3\xe4\xed\xe8\xea\xe0\xec FBI."), 1;
        ShowPlayerDialog(playerid, DIALOG_POLICE_STASH, DIALOG_STYLE_LIST, "FBI | Оружейный склад", "\xd2\xe0\xe9\xe7\xe5\xf0 USP (30 \xef\xe0\xf2\xf0\xee\xed\xee\xe2)\nДробовик и патроны (60)\nMP5 и патроны (120)\nАК-47 и патроны (120)\nМ4 и патроны (120)\nВинтовка (20)\nБронежилет", "Взять", "Закрыть");
        return 1;
    }
    if (pickupid == gPoliceStashPickup && IsInPoliceStation(playerid))
    {
        if (gFaction[playerid] != FACTION_POLICE || gFactionRank[playerid] < 1)
            return SendClientMessage(playerid, COLOR_RED, "Склад доступен только сотрудникам LSPD."), 1;
        ShowPlayerDialog(playerid, DIALOG_POLICE_STASH, DIALOG_STYLE_LIST, "LSPD | Оружейный склад", "\xc4\xf3\xe1\xe8\xed\xea\xe0 (1)\nM4 и патроны (до 100)\nПистолет и патроны (до 100)\nБронежилет", "Взять", "Закрыть");
        return 1;
    }
    if (pickupid == gPoliceEntrancePickup && GetPlayerInterior(playerid) == 0 && GetPlayerVirtualWorld(playerid) == 0)
    {
        if (!IsNearPoliceEntrance(playerid)) return 1;
        SetPlayerInterior(playerid, 6); SetPlayerVirtualWorld(playerid, 0);
        SetPlayerPos(playerid, 246.3213, 62.5062, 1003.6406); SetPlayerFacingAngle(playerid, 14.87); SetCameraBehindPlayer(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "Вы вошли в участок LSPD. Меню организации: /org.");
        ShowFactionCommands(playerid);
        return 1;
    }
    if (pickupid == gPoliceHallGaragePickup && GetPlayerInterior(playerid) == 6 && GetPlayerVirtualWorld(playerid) == 0)
    {
        if (gFaction[playerid] != FACTION_POLICE)
            return SendClientMessage(playerid, COLOR_RED, "Выход в гараж LSPD доступен только полиции."), 1;
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        SetPlayerPos(playerid, 1568.4843, -1690.4116, 5.8906);
        SetPlayerFacingAngle(playerid, 181.71);
        SetCameraBehindPlayer(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "Вы вышли из LSPD к гаражу VEXORIUM.");
        return 1;
    }
    if (pickupid == gPoliceExitPickup && GetPlayerInterior(playerid) == 6 && GetPlayerVirtualWorld(playerid) == 0)
    {
        SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
        SetPlayerPos(playerid, 1547.0, -1678.8352, 14.9453); SetPlayerFacingAngle(playerid, 270.41); SetCameraBehindPlayer(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "Вы вышли из участка LSPD.");
        return 1;
    }
    if (pickupid == gOrgEnterPickup[FACTION_FBI] || pickupid == gFBIBuildingEnterPickup)
    {
        if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0) return 1;
        if (!IsPlayerInRangeOfPoint(playerid, 4.0, -2281.9553, 2288.3784, 4.9739)) return 1;
        if (gFBIPendingEnter[playerid]) return 1;
        gFBIPendingEnter[playerid] = true;
        gFBIEnterTimer[playerid] = SetTimerEx("FinishFBIEnter", 2000, false, "i", playerid);
        SendClientMessage(playerid, COLOR_YELLOW, "FBI: Wait 2 seconds at the marker to enter headquarters.");
        return 1;
    }
    for (new faction = 1; faction <= 7; faction++)
    {
        if (pickupid == gOrgEnterPickup[faction])
        {
            EnterOrgInteriorForFaction(playerid, faction);
            return 1;
        }
        if (faction != FACTION_POLICE && pickupid == gOrgExitPickup[faction])
        {
            if (GetPlayerVirtualWorld(playerid) != 100 + faction) return 1;
            new Float:ox, Float:oy, Float:oz;
            GetOrgExterior(faction, ox, oy, oz);
            SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
            if (faction == FACTION_FBI)
                SetPlayerPos(playerid, -2281.9553, 2288.3784, 4.9739);
            else
                SetPlayerPos(playerid, ox + 1.5, oy, oz);
            SetPlayerFacingAngle(playerid, (faction == FACTION_CITYHALL) ? 180.91 : ((faction == FACTION_FBI) ? 272.67 : 180.0)); SetCameraBehindPlayer(playerid);
            SendClientMessage(playerid, COLOR_GREEN, "Вы вышли из штаба организации.");
            return 1;
        }
    }
    if (pickupid == gPoliceGarageDoorPickup && IsInPoliceStation(playerid) && gFaction[playerid] == FACTION_POLICE)
    {
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        SetPlayerPos(playerid, 1568.4843, -1690.4116, 5.8906);
        SetPlayerFacingAngle(playerid, 181.71);
        SetCameraBehindPlayer(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "Вы вышли через дверь участка к автопарку LSPD.");
        return 1;
    }
    if (pickupid == gPoliceGarageReturnPickup && GetPlayerInterior(playerid) == 0 && GetPlayerVirtualWorld(playerid) == 0 && gFaction[playerid] == FACTION_POLICE)
    {
        SetPlayerInterior(playerid, 6);
        SetPlayerVirtualWorld(playerid, 0);
        SetPlayerPos(playerid, 246.7147, 87.2885, 1003.6406);
        SetPlayerFacingAngle(playerid, 14.87);
        SetCameraBehindPlayer(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "Вы вошли в участок через дверь автопарка.");
        return 1;
    }
    if (gFaction[playerid] < FACTION_CITYHALL || gFaction[playerid] > FACTION_FBI || gFactionRank[playerid] < 1)
        return 1;
    if (pickupid != gLockerPickup[gFaction[playerid]]) return 1;
    if (gFaction[playerid] == FACTION_POLICE)
    {
        if (!IsInPoliceStation(playerid)) return 1;
    }
    else if (!IsInOwnOrgInterior(playerid)) return 1;
    if (gFaction[playerid] == FACTION_POLICE)
    {
        if (!gPoliceCivilianSkin[playerid])
        {
            SetPlayerSkin(playerid, 23);
            gPoliceCivilianSkin[playerid] = true;
            SendClientMessage(playerid, COLOR_GREEN, "LSPD: Вы переоделись в гражданскую одежду. Вернитесь к раздевалке, чтобы надеть форму.");
        }
        else
        {
            SetPlayerSkin(playerid, GetFactionSkin(gFaction[playerid], gFactionRank[playerid]));
            gPoliceCivilianSkin[playerid] = false;
            SendClientMessage(playerid, COLOR_GREEN, "LSPD: Вы снова надели служебную форму.");
        }
        return 1;
    }
    new skin = GetFactionSkin(gFaction[playerid], gFactionRank[playerid]);
    SetPlayerSkin(playerid, skin);
    SavePlayer(playerid);
    SendClientMessage(playerid, COLOR_GREEN, "Вы переоделись в форму своей организации согласно рангу.");
    return 1;
}

public OnPlayerUpdate(playerid)
{
    if (gTaserStunned[playerid] && !IsPlayerInAnyVehicle(playerid))
    {
        TogglePlayerControllable(playerid, 0);
    }
    if (gHandcuffed[playerid] && !gTaserStunned[playerid] && !IsPlayerInAnyVehicle(playerid))
    {
        new officer = gCuffOfficer[playerid];
        if (officer != INVALID_PLAYER_ID && IsPlayerConnected(officer) && GetPlayerInterior(playerid) == GetPlayerInterior(officer) && GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(officer))
        {
            new Float:ox, Float:oy, Float:oz;
            GetPlayerPos(officer, ox, oy, oz);
            if (GetPlayerDistanceFromPoint(playerid, ox, oy, oz) > 10.0)
            {
                new Float:ang; GetPlayerFacingAngle(officer, ang);
                SetPlayerPos(playerid, ox - (1.2 * floatsin(-ang, degrees)), oy - (1.2 * floatcos(-ang, degrees)), oz);
                SetPlayerFacingAngle(playerid, ang);
            }
        }
        TogglePlayerControllable(playerid, 1);
        if (GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_CUFFED)
            SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CUFFED);
    }
    // Poll the N key in OnPlayerUpdate so engine toggling does not depend on ALT controls.
    new keys, updown, leftright;
    GetPlayerKeys(playerid, keys, updown, leftright);
    if (gFBIEditActive[playerid] && gFBIEditObject[playerid] != INVALID_OBJECT_ID)
    {
        if (gFBIEditMoveObject[playerid])
        {
            // Smooth continuous movement while a direction is held. No sprint/jump/crouch movement.
            // SA-MP exposes directional controls, not the physical key used for them.
            new bool:editorMoved = false;
            new Float:step = 0.08;
            if (leftright < 0) { gFBIEditX[playerid] -= step; editorMoved = true; }
            else if (leftright > 0) { gFBIEditX[playerid] += step; editorMoved = true; }
            if (updown < 0) { gFBIEditY[playerid] -= step; editorMoved = true; }
            else if (updown > 0) { gFBIEditY[playerid] += step; editorMoved = true; }
            if (editorMoved) UpdateFBIEditorObject(playerid);
        }
        else
        {
            // Free-flying camera. Hold sprint to travel much faster across the map.
            new Float:camX, Float:camY, Float:camZ, Float:frontX, Float:frontY, Float:frontZ;
            new Float:camSpeed = 1.00;
            if (keys & KEY_SPRINT) camSpeed = 3.00;
            GetPlayerCameraPos(playerid, camX, camY, camZ);
            GetPlayerCameraFrontVector(playerid, frontX, frontY, frontZ);
            new bool:cameraMoved = false;
            if (updown > 0) { camX += frontX * camSpeed; camY += frontY * camSpeed; camZ += frontZ * camSpeed; cameraMoved = true; }
            else if (updown < 0) { camX -= frontX * camSpeed; camY -= frontY * camSpeed; camZ -= frontZ * camSpeed; cameraMoved = true; }
            if (leftright > 0) { camX += frontY * camSpeed; camY -= frontX * camSpeed; cameraMoved = true; }
            else if (leftright < 0) { camX -= frontY * camSpeed; camY += frontX * camSpeed; cameraMoved = true; }
            if (keys & KEY_JUMP) { camZ += camSpeed; cameraMoved = true; }
            if (keys & KEY_CROUCH) { camZ -= camSpeed; cameraMoved = true; }
            if (cameraMoved)
            {
                SetPlayerCameraPos(playerid, camX, camY, camZ);
                SetPlayerCameraLookAt(playerid, camX + frontX * 10.0, camY + frontY * 10.0, camZ + frontZ * 10.0, CAMERA_CUT);
            }
        }
        return 1;
    }

    new bool:nDown = ((keys & KEY_NO) != 0);
    if (nDown && !gNEngineWasDown[playerid] && gLogged[playerid] &&
        IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
        new vehicleid = GetPlayerVehicleID(playerid);
        if (vehicleid > 0 && vehicleid < MAX_VEHICLES)
        {
            new engine, lights, alarm, doors, bonnet, boot, objective;
            GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
            if (engine == VEHICLE_PARAMS_ON)
            {
                SetVehicleParamsEx(vehicleid, VEHICLE_PARAMS_OFF, lights, alarm, doors, bonnet, boot, objective);
                new stopText[128];
                format(stopText, sizeof stopText, "* %s \xe7\xe0\xe3\xeb\xf3\xf8\xe8\xeb \xe4\xe2\xe8\xe3\xe0\xf2\xe5\xeb\xfc.", gName[playerid]);
                SendLocalMessage(playerid, COLOR_PINK, stopText, 20.0);
                SendClientMessage(playerid, COLOR_YELLOW, "\xc4\xe2\xe8\xe3\xe0\xf2\xe5\xeb\xfc \xe2\xfb\xea\xeb\xfe\xf7\xe5\xed.");
            }
            else if (gVehicleFuel[vehicleid] <= 0)
            {
                SendClientMessage(playerid, COLOR_RED, "\xcd\xe5\xf2 \xf2\xee\xef\xeb\xe8\xe2\xe0. \xc7\xe0\xef\xf0\xe0\xe2\xfc\xf2\xe5\xf1\xfc \xed\xe0 \xc0\xc7\xd1 \xea\xee\xec\xe0\xed\xe4\xee\xe9 /fuel.");
            }
            else
            {
                SetVehicleParamsEx(vehicleid, VEHICLE_PARAMS_ON, lights, alarm, doors, bonnet, boot, objective);
                new startText[128];
                format(startText, sizeof startText, "* %s \xef\xee\xe2\xe5\xf0\xed\xf3\xeb \xea\xeb\xfe\xf7 \xe7\xe0\xe6\xe8\xe3\xe0\xed\xe8\xff - \xe4\xe2\xe8\xe3\xe0\xf2\xe5\xeb\xfc \xe7\xe0\xe2\xe5\xeb\xf1\xff.", gName[playerid]);
                SendLocalMessage(playerid, COLOR_PINK, startText, 20.0);
                SendClientMessage(playerid, COLOR_GREEN, "\xc4\xe2\xe8\xe3\xe0\xf2\xe5\xeb\xfc \xe7\xe0\xe2\xe5\xeb\xf1\xff.");
            }
            UpdateVexHud(playerid);
        }
    }
    gNEngineWasDown[playerid] = nDown;
    // The lock is released only after leaving the market area, so closing the dialog
    // while standing on the pickup cannot spam the license window again.
    if (gLicenseMarketLocked[playerid] &&
        (GetPlayerInterior(playerid) != 3 || GetPlayerVirtualWorld(playerid) != 101 ||
         !IsPlayerInRangeOfPoint(playerid, 6.0, 362.4587, 174.0056, 1008.3828)))
    {
        gLicenseMarketLocked[playerid] = false;
    }
    if (!gLogged[playerid])
    {
        gLastObservedWeapon[playerid] = GetPlayerWeapon(playerid);
        return 1;
    }
    new observedWeapon = GetPlayerWeapon(playerid);
    if (observedWeapon != gLastObservedWeapon[playerid])
    {
        new actionText[128];
        if (observedWeapon > 0) format(actionText, sizeof actionText, "* %s достал оружие.", gName[playerid]);
        else if (gLastObservedWeapon[playerid] > 0) format(actionText, sizeof actionText, "* %s убрал оружие.", gName[playerid]);
        if (observedWeapon > 0 || gLastObservedWeapon[playerid] > 0) SendLocalMessage(playerid, COLOR_PINK, actionText, 20.0);
        gLastObservedWeapon[playerid] = observedWeapon;
    }
    if (gCarjackActive[playerid] && gWorkStage[playerid] == 11 && IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER && GetPlayerVehicleID(playerid) == gCarjackVehicle[playerid])
    {
        new Float:cx, Float:cy, Float:cz;
        GetPlayerPos(playerid, cx, cy, cz);
        for (new gangIndex = 1; gangIndex <= 4; gangIndex++)
        {
            new Float:bx, Float:by, Float:bz;
            GetGangBase(gangIndex, bx, by, bz);
            if (GetPlayerDistanceFromPoint(playerid, bx, by, bz) <= 12.0)
            {
                new deliveredVehicle = gCarjackVehicle[playerid];
                RemovePlayerFromVehicle(playerid);
                if (deliveredVehicle != INVALID_VEHICLE_ID && GetVehicleModel(deliveredVehicle) != 0) { gCarjackVehicleOwner[deliveredVehicle] = INVALID_PLAYER_ID; DestroyVehicle(deliveredVehicle); }
                gCarjackVehicle[playerid] = INVALID_VEHICLE_ID;
                gCarjackActive[playerid] = false; gCarjackUnlocked[playerid] = false; gWorkStage[playerid] = 0;
                DisablePlayerCheckpoint(playerid);
                RemovePlayerMapIcon(playerid, 48);
                if (GiveCash(playerid, 100000)) SendClientMessage(playerid, COLOR_GREEN, "Машина сдана на базе нелегальной организации! Начислено 100000 рублей.");
                else SendClientMessage(playerid, COLOR_RED, "Машина сдана, но баланс достиг максимума — награда не начислена.");
                SavePlayer(playerid);
                return 1;
            }
        }
    }
    if (GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return 1;
    new vehicleid = GetPlayerVehicleID(playerid);
    if (vehicleid <= 0 || vehicleid >= MAX_VEHICLES) return 1;
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    if (gFuelLastX[vehicleid] == 0.0 && gFuelLastY[vehicleid] == 0.0)
    {
        gFuelLastX[vehicleid] = x; gFuelLastY[vehicleid] = y; gFuelLastZ[vehicleid] = z;
        return 1;
    }
    if (GetPlayerDistanceFromPoint(playerid, gFuelLastX[vehicleid], gFuelLastY[vehicleid], gFuelLastZ[vehicleid]) >= 120.0)
    {
        gFuelLastX[vehicleid] = x; gFuelLastY[vehicleid] = y; gFuelLastZ[vehicleid] = z;
        if (gVehicleFuel[vehicleid] > 0) gVehicleFuel[vehicleid]--;
        UpdateVexHud(playerid);
        if (gVehicleFuel[vehicleid] == 0)
        {
            new engine, lights, alarm, doors, bonnet, boot, objective;
            GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
            SetVehicleParamsEx(vehicleid, 0, lights, alarm, doors, bonnet, boot, objective);
            SendClientMessage(playerid, COLOR_RED, "Бензин закончился. Доедьте до АЗС и используйте /fuel.");
        }
    }
    return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    UpdateVexHud(playerid);
    // Standard SA-MP has no SetPlayerCanDoDriveBy native; drive-by is controlled by the client.
    if (newstate == PLAYER_STATE_DRIVER)
    {
        if (gLogged[playerid])
        {
            new enterText[128];
            format(enterText, sizeof enterText, "* %s сел за руль автомобиля.", gName[playerid]);
            SendLocalMessage(playerid, COLOR_PINK, enterText, 20.0);
        }
        new enteredVehicle = GetPlayerVehicleID(playerid);
        if (gCarjackActive[playerid] && gCarjackUnlocked[playerid] && enteredVehicle == gCarjackVehicle[playerid])
        {
            new Float:bx, Float:by, Float:bz;
            GetGangBase(gCarjackDestination[playerid], bx, by, bz);
            gWorkStage[playerid] = 11;
            SetPlayerCheckpoint(playerid, bx, by, bz, 10.0);
            SendClientMessage(playerid, COLOR_GREEN, "Вы за рулём угнанной машины. Доставьте её на базу любой нелегальной организации.");
        }
        if (enteredVehicle > 0 && enteredVehicle < MAX_VEHICLES)
        {
            new engine, lights, alarm, doors, bonnet, boot, objective;
            GetVehicleParamsEx(enteredVehicle, engine, lights, alarm, doors, bonnet, boot, objective);
            SetVehicleParamsEx(enteredVehicle, VEHICLE_PARAMS_OFF, lights, alarm, doors, bonnet, boot, objective);
            new engineHint[96];
            format(engineHint, sizeof engineHint, "Нажмите N, чтобы завести двигатель. Топливо: %d л.", gVehicleFuel[enteredVehicle]);
            SendClientMessage(playerid, COLOR_YELLOW, engineHint);
        }
        if (enteredVehicle > 0 && enteredVehicle < MAX_VEHICLES && gVehicleFaction[enteredVehicle] > 0)
        {
            if (gFactionVehicleOwner[enteredVehicle] == INVALID_PLAYER_ID || gFactionVehicleOwner[enteredVehicle] != playerid)
            {
                RemovePlayerFromVehicle(playerid);
                SendClientMessage(playerid, COLOR_YELLOW, "\xDD\xF2\xEE\xF2 \xF2\xF0\xE0\xED\xF1\xEF\xEE\xF0\xF2 \xE7\xE0\xEA\xF0\xFB\xF2. \xC8\xF1\xEF\xEE\xEB\xFC\xE7\xF3\xE9\xF2\xE5 /garage, \xF7\xF2\xEE\xE1\xFB \xE2\xE7\xFF\xF2\xFC \xF1\xEB\xF3\xE6\xE5\xE1\xED\xF3\xFE \xEC\xE0\xF8\xE8\xED\xF3.");
                return 1;
            }
            if (!gLogged[playerid] || gFaction[playerid] != gVehicleFaction[enteredVehicle] || gFactionRank[playerid] < (gVehicleTier[enteredVehicle] * 2 + 1))
            {
                RemovePlayerFromVehicle(playerid);
                SendClientMessage(playerid, COLOR_RED, "Этот служебный транспорт недоступен вашей фракции или рангу.");
                return 1;
            }
            if (gVehicleReturnTimer[enteredVehicle]) { KillTimer(gVehicleReturnTimer[enteredVehicle]); gVehicleReturnTimer[enteredVehicle] = 0; }
        }
    }
    if (oldstate == PLAYER_STATE_DRIVER && newstate != PLAYER_STATE_DRIVER)
    {
        new exitedVehicle = GetPlayerVehicleID(playerid);
        // Some SA-MP builds return vehicle id 0 after exit; use the tracked personal fleet vehicle as fallback.
        if (exitedVehicle > 0 && exitedVehicle < MAX_VEHICLES && gVehicleFaction[exitedVehicle] > 0) StartFleetVehicleReturn(exitedVehicle);
    }
    // LICENSE CHECK: only scooters and bicycles are allowed without a driving license.
    if (newstate == PLAYER_STATE_DRIVER)
    {
        new testVehicle = GetPlayerVehicleID(playerid);
        if (testVehicle > 0 && testVehicle < MAX_VEHICLES)
        {
            new model = GetVehicleModel(testVehicle);
            new bool:isBoat = (model == 430 || model == 446 || model == 452 || model == 453 || model == 454 || model == 472 || model == 473 || model == 484 || model == 493 || model == 539 || model == 595);
            new bool:isAircraft = (model == 417 || model == 425 || model == 447 || model == 460 || model == 469 || model == 476 || model == 487 || model == 488 || model == 497 || model == 511 || model == 512 || model == 513 || model == 520 || model == 548 || model == 553 || model == 563 || model == 577 || model == 592 || model == 593);
            new bool:isScooterOrBicycle = (model == 462 || model == 481 || model == 509 || model == 510);
            if (!gLogged[playerid])
            {
                RemovePlayerFromVehicle(playerid);
                SendClientMessage(playerid, COLOR_RED, "Раздел войдите в аккаунт, перде чем управлять транспортом.");
                return 1;
            }
            if (testVehicle == gDrivingTestVehicle[playerid] && gDrivingTestStage[playerid] > 0) { /* Driving exam vehicle is allowed. */ }
            else if (isScooterOrBicycle) { /* Scooter and bicycles are allowed without a license. */ }
            else if (isBoat)
            {
                if (!gLicenseBoat[playerid])
                {
                    RemovePlayerFromVehicle(playerid);
                    SendClientMessage(playerid, COLOR_RED, "У вас нет лицензии на управление лодкой. Получите её в мэрии.");
                    return 1;
                }
            }
            else if (isAircraft)
            {
                if (!gLicenseAir[playerid])
                {
                    RemovePlayerFromVehicle(playerid);
                    SendClientMessage(playerid, COLOR_RED, "У вас нет лицензии на управление воздушным транспортом. Получите её в мэрии.");
                    return 1;
                }
            }
            else if (!gLicenseDriver[playerid])
            {
                RemovePlayerFromVehicle(playerid);
                SendClientMessage(playerid, COLOR_RED, "У вас нет автомобильной лицензии. Подойдите в автошколу и сдайте экзамен.");
                return 1;
            }
        }
    }
    if (newstate == PLAYER_STATE_DRIVER && gBaseScooter != INVALID_VEHICLE_ID &&
        GetPlayerVehicleID(playerid) == gBaseScooter)
    {
        // The display scooter is not usable until the player accepts the rental.
        if (!gLogged[playerid] || gFaction[playerid] != FACTION_NONE || gLevel[playerid] > 3 ||
            gRentalVehicle[playerid] != INVALID_VEHICLE_ID)
        {
            RemovePlayerFromVehicle(playerid);
            if (gFaction[playerid] != FACTION_NONE)
                SendClientMessage(playerid, COLOR_RED, "Скутер доступен только гражданским новичкам без организации.");
            else if (gLevel[playerid] > 3)
                SendClientMessage(playerid, COLOR_RED, "Скутер доступен только игрокам 1–3 уровня.");
            else
                SendClientMessage(playerid, COLOR_RED, "Сначала войдите в аккаунт, чтобы арендовать скутер.");
            return 1;
        }
        if (!gPendingScooterChoice[playerid])
        {
            gPendingScooterChoice[playerid] = true;
            ShowPlayerDialog(playerid, DIALOG_RENT_SCOOTER, DIALOG_STYLE_MSGBOX,
                "VEXORIUM RP | Аренда скутера",
                "Вы сели на Faggio.\nАрендовать его за 250 рублей?\nПосле аренды новый скутер появится на базе.\nАрендованный скутер переместится к воротам, откуда можно выехать на дорогу.",
                "Арендовать", "Не брать");
        }
    }
    return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
    if (gLogged[playerid])
    {
        new exitText[128];
        format(exitText, sizeof exitText, "* %s вышел из автомобиля.", gName[playerid]);
        SendLocalMessage(playerid, COLOR_PINK, exitText, 20.0);
    }
    if (vehicleid > 0 && vehicleid < MAX_VEHICLES && gVehicleFaction[vehicleid] > 0)
        StartFleetVehicleReturn(vehicleid);
    return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
    if (vehicleid > 0 && vehicleid < MAX_VEHICLES && gCarjackVehicleOwner[vehicleid] != INVALID_PLAYER_ID)
    {
        new thief = gCarjackVehicleOwner[vehicleid]; gCarjackVehicleOwner[vehicleid] = INVALID_PLAYER_ID;
        if (thief >= 0 && thief < MAX_PLAYERS && IsPlayerConnected(thief))
        {
            gCarjackActive[thief] = false; gCarjackUnlocked[thief] = false; gCarjackVehicle[thief] = INVALID_VEHICLE_ID; gWorkStage[thief] = 0;
            gCarjackPursuitNotified[thief] = false; RemovePlayerMapIcon(thief, 48); DisablePlayerCheckpoint(thief);
            SendClientMessage(thief, COLOR_RED, "[AVTOUGON] Ugonnaya mashina vzorvalas. Rabota zavershena bez nagrady.");
        }
        for (new cop = 0; cop < MAX_PLAYERS; cop++) if (IsPlayerConnected(cop) && gPursuitTarget[cop] == thief)
        {
            gPursuitTarget[cop] = INVALID_PLAYER_ID; RemovePlayerMapIcon(cop, 49); DisablePlayerCheckpoint(cop);
            SendClientMessage(cop, COLOR_YELLOW, "[LSPD/FBI] Ugonnaya mashina unichtozhena; presledovanie zaversheno.");
        }
        DestroyVehicle(vehicleid); return 1;
    }
    if (vehicleid > 0 && vehicleid < MAX_VEHICLES && gVehicleFaction[vehicleid] > 0)
    {
        if (gVehicleReturnTimer[vehicleid]) KillTimer(gVehicleReturnTimer[vehicleid]);
        gVehicleReturnTimer[vehicleid] = 0; gVehicleFaction[vehicleid] = 0; gVehicleTier[vehicleid] = 0;
        gFactionVehicleOwner[vehicleid] = INVALID_PLAYER_ID; gVehicleFuel[vehicleid] = 0; DestroyVehicle(vehicleid); return 1;
    }
    if (vehicleid > 0 && vehicleid < MAX_VEHICLES && gPersonalVehicleOwner[vehicleid] != INVALID_PLAYER_ID)
    {
        // Личный автомобиль остаётся привязанным к владельцу и возвращается к точке выдачи.
        SetVehicleToRespawn(vehicleid);
        gVehicleFuel[vehicleid] = 100;
        gFuelLastX[vehicleid] = 0.0; gFuelLastY[vehicleid] = 0.0; gFuelLastZ[vehicleid] = 0.0;
    }
    return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
    if (!gLogged[playerid]) return 1;
    if (gDrivingTestStage[playerid] > 0)
    {
        if (!IsPlayerInAnyVehicle(playerid) || GetPlayerVehicleID(playerid) != gDrivingTestVehicle[playerid] || GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
        {
            DisablePlayerCheckpoint(playerid);
            gDrivingTestStage[playerid] = 0;
            if (gDrivingTestVehicle[playerid] != INVALID_VEHICLE_ID) DestroyVehicle(gDrivingTestVehicle[playerid]);
            gDrivingTestVehicle[playerid] = INVALID_VEHICLE_ID;
            SendClientMessage(playerid, COLOR_RED, "[АВТОШКОЛА] Экзамен прван: нужно водить в учебной машине." );
            return 1;
        }
        DisablePlayerCheckpoint(playerid);
        gDrivingTestStage[playerid]++;
        if (gDrivingTestStage[playerid] >= 6)
        {
            DisablePlayerCheckpoint(playerid);
            if (gMoney[playerid] < 15000)
            {
                gDrivingTestStage[playerid] = 0;
                RemovePlayerFromVehicle(playerid);
                if (gDrivingTestVehicle[playerid] != INVALID_VEHICLE_ID) DestroyVehicle(gDrivingTestVehicle[playerid]);
                gDrivingTestVehicle[playerid] = INVALID_VEHICLE_ID;
                SendClientMessage(playerid, COLOR_RED, "[АВТОШКОЛА] Не хватило денег для оплаты заездов. Вождение не зачтено.");
                return 1;
            }
            gMoney[playerid] -= 15000;
            gDrivingExamPassed[playerid] = 1;
            ResetPlayerMoney(playerid);
            GivePlayerMoney(playerid, gMoney[playerid]);
            SavePlayer(playerid);
            RemovePlayerFromVehicle(playerid);
            if (gDrivingTestVehicle[playerid] != INVALID_VEHICLE_ID) DestroyVehicle(gDrivingTestVehicle[playerid]);
            gDrivingTestVehicle[playerid] = INVALID_VEHICLE_ID;
            gDrivingTestStage[playerid] = 0;
            SetPlayerInterior(playerid, 0);
            SetPlayerVirtualWorld(playerid, 0);
            SetPlayerPos(playerid, 1481.0, -1771.9, 18.8);
            SetPlayerFacingAngle(playerid, 180.0);
            SetCameraBehindPlayer(playerid);
            SendClientMessage(playerid, COLOR_GREEN, "[Автошкола] Экзамен сдан! Оплата маршрута: $15000.");
            SendClientMessage(playerid, COLOR_YELLOW, "Войдите в мэрию и подойдите к рынку лицензий, чтобы получить водительские права.");
            return 1;
        }
        switch (gDrivingTestStage[playerid])
        {
            case 2: SetPlayerCheckpoint(playerid, -2337.8027, 448.6180, 33.5087, 5.0);
            case 3: SetPlayerCheckpoint(playerid, -2300.4072, 509.8988, 34.6583, 5.0);
            case 4: SetPlayerCheckpoint(playerid, -2000.8323, 471.5700, 35.0156, 5.0);
            case 5: SetPlayerCheckpoint(playerid, -2028.8990, -71.3546, 35.1718, 5.0);
        }
        SendClientMessage(playerid, COLOR_BLUE, "[АВТОШКОЛА] Контрольная точка пройдена. Следуйте к следующей." );
        return 1;
    }
    if (gGpsActive[playerid])
    {
        DisablePlayerCheckpoint(playerid);
        gGpsActive[playerid] = false;
        SendClientMessage(playerid, COLOR_GREEN, "[VEXORIUM GPS] Вы прибыли в пункт назначения.");
        return 1;
    }
    if (gCarjackActive[playerid] && gWorkStage[playerid] == 10)
    {
        if (!gCarjackUnlocked[playerid])
        {
            SendClientMessage(playerid, COLOR_YELLOW, "Вы нашли машину. Подойдите к ней и используйте /hack.");
            return 1;
        }
        if (!IsPlayerInAnyVehicle(playerid) || GetPlayerVehicleID(playerid) != gCarjackVehicle[playerid] || GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
        {
            SendClientMessage(playerid, COLOR_YELLOW, "Сначала сядьте за руль угнанной машины.");
            return 1;
        }
        new Float:bx, Float:by, Float:bz;
        GetGangBase(gCarjackDestination[playerid], bx, by, bz);
        SetPlayerCheckpoint(playerid, bx, by, bz, 10.0);
        gWorkStage[playerid] = 11;
        SendClientMessage(playerid, COLOR_GREEN, "Везите машину на отмеченную базу нелегальной организации.");
        return 1;
    }
    if (gCarjackActive[playerid] && gWorkStage[playerid] == 11)
    {
        if (!IsPlayerInAnyVehicle(playerid) || GetPlayerVehicleID(playerid) != gCarjackVehicle[playerid] || GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
            return SendClientMessage(playerid, COLOR_RED, "Чтобы сдать угнанную машину, вы должны быть за её рулём."), 1;
        new Float:bx, Float:by, Float:bz;
        GetGangBase(gCarjackDestination[playerid], bx, by, bz);
        if (GetPlayerDistanceFromPoint(playerid, bx, by, bz) > 18.0)
            return SendClientMessage(playerid, COLOR_YELLOW, "Подъедьте ближе к базе банды, отмеченной на карте."), 1;
        new stolenVehicle = gCarjackVehicle[playerid];
        RemovePlayerFromVehicle(playerid);
        if (stolenVehicle != INVALID_VEHICLE_ID && GetVehicleModel(stolenVehicle) != 0) { gCarjackVehicleOwner[stolenVehicle] = INVALID_PLAYER_ID; DestroyVehicle(stolenVehicle); }
        gCarjackVehicle[playerid] = INVALID_VEHICLE_ID;
        gCarjackActive[playerid] = false; gCarjackUnlocked[playerid] = false; gWorkStage[playerid] = 0;
        DisablePlayerCheckpoint(playerid);
        RemovePlayerMapIcon(playerid, 48);
        if (GiveCash(playerid, 100000)) SendClientMessage(playerid, COLOR_GREEN, "Угон завершён! Вы получили 100000 рублей.");
        else SendClientMessage(playerid, COLOR_RED, "Машина сдана, но не удалось начислить деньги из-за лимита баланса.");
        SavePlayer(playerid);
        return 1;
    }
    if (gWorkStage[playerid] > 0)
    {
        if (gJob[playerid] >= 1 && gJob[playerid] <= 3 && (gWorkVehicle[playerid] == INVALID_VEHICLE_ID || !IsPlayerInAnyVehicle(playerid) || GetPlayerVehicleID(playerid) != gWorkVehicle[playerid]))
        {
            SendClientMessage(playerid, COLOR_RED, "Для прохождения рабочих точек нужно находиться в выданном рабочем транспорте.");
            return 1;
        }
        gWorkStage[playerid]++;
        if (gWorkStage[playerid] >= 4)
        {
            new reward = (gJob[playerid] == 1) ? 3500 : ((gJob[playerid] == 2) ? 5000 : ((gJob[playerid] == 3) ? 4200 : 6000));
            if (GiveCash(playerid, reward))
            {
                SendClientMessage(playerid, COLOR_GREEN, "[VEXORIUM] Маршрут завершён! Зарплата начислена.");
                new msg[96];
                format(msg, sizeof msg, "[VEXORIUM] Вы заработали %d рублей.", reward);
                SendClientMessage(playerid, COLOR_GREEN, msg);
            }
            else SendClientMessage(playerid, COLOR_RED, "[VEXORIUM] Не удалось начислить зарплату: достигнут лимит денег.");
            gWorkStage[playerid] = 0;
            if (gCarjackActive[playerid])
            {
                if (gCarjackVehicle[playerid] != INVALID_VEHICLE_ID && GetVehicleModel(gCarjackVehicle[playerid]) != 0) { gCarjackVehicleOwner[gCarjackVehicle[playerid]] = INVALID_PLAYER_ID; DestroyVehicle(gCarjackVehicle[playerid]); }
                gCarjackActive[playerid] = false; gCarjackUnlocked[playerid] = false; gCarjackVehicle[playerid] = INVALID_VEHICLE_ID;
            }
            DisablePlayerCheckpoint(playerid);
            if (gWorkVehicle[playerid] != INVALID_VEHICLE_ID && GetVehicleModel(gWorkVehicle[playerid]) != 0)
            {
                if (IsPlayerInAnyVehicle(playerid) && GetPlayerVehicleID(playerid) == gWorkVehicle[playerid]) RemovePlayerFromVehicle(playerid);
                DestroyVehicle(gWorkVehicle[playerid]);
            }
            gWorkVehicle[playerid] = INVALID_VEHICLE_ID;
            SavePlayer(playerid);
            return 1;
        }
        if (gJob[playerid] == 1)
        {
            if (gWorkStage[playerid] == 2) SetPlayerCheckpoint(playerid, 1182.0, -1323.0, 13.6, 5.0);
            else SetPlayerCheckpoint(playerid, 1685.0, -2333.0, 13.5, 5.0);
        }
        else if (gJob[playerid] == 2)
        {
            if (gWorkStage[playerid] == 2) SetPlayerCheckpoint(playerid, 2445.0, -2110.0, 13.5, 7.0);
            else SetPlayerCheckpoint(playerid, 1685.0, -2333.0, 13.5, 7.0);
        }
        else if (gJob[playerid] == 3)
        {
            if (gWorkStage[playerid] == 2) SetPlayerCheckpoint(playerid, 1090.0, -1750.0, 13.4, 6.0);
            else SetPlayerCheckpoint(playerid, 1685.0, -2333.0, 13.5, 6.0);
        }
        else
        {
            if (gWorkStage[playerid] == 2) SetPlayerCheckpoint(playerid, 838.0, 870.0, 12.0, 7.0);
            else SetPlayerCheckpoint(playerid, 852.0, 850.0, 12.0, 7.0);
        }
        SendClientMessage(playerid, COLOR_BLUE, "[VEXORIUM] Контрольная точка пройдена. Следуйте к следующей отметке.");
        return 1;
    }
    return 1;
}

stock ShowMainMenu(playerid)
{
    new menuText[512];
    menuText[0] = '\0';
    strcat(menuText, "{33CC66}ПЕРСОНАЖ И ПРОГРЕСС\n");
    strcat(menuText, "{FFFFFF}Мой профиль и статистика\n");
    strcat(menuText, "Место появления\n");
    strcat(menuText, "{66CCFF}ГОРОД И НАВИГАЦИЯ\n");
    strcat(menuText, "GPS и карта\n");
    strcat(menuText, "Работа и заработок\n");
    strcat(menuText, "Организации и лидеры\n");
    strcat(menuText, "{FFD700}ИНФОРМАЦИЯ\n");
    strcat(menuText, "Правила сервера\n");
    strcat(menuText, "Список команд\n");
    strcat(menuText, "{FFCC66}ИНВЕНТАРЬ и предметы\n");
    strcat(menuText, "{FFFFFF}Мой инвентарь\n");
    strcat(menuText, "{66CCFF}ТЕЛЕФОН и связь\n");
    strcat(menuText, "Магазин предметов\n");
    ShowPlayerDialog(playerid, DIALOG_MAIN_MENU, DIALOG_STYLE_LIST,
        "{33CC66}VEXORIUM RP {FFFFFF}| Центр игрока", menuText,
        "Открыть", "Закрыть");
    return 1;
}

stock GetFactionVehicleInfo(faction, tier, name[], size)
{
    switch (faction)
    {
        case FACTION_CITYHALL:
        {
            switch (tier) { case 0: format(name,size,"Staff car (model 405)"); case 1: format(name,size,"Washington (model 421)"); case 2: format(name,size,"Premier (model 426)"); case 3: format(name,size,"Stretch limousine (model 409)"); case 4: format(name,size,"Bulletproof executive (model 560)"); }
        }
        case FACTION_POLICE:
        {
            switch (tier) { case 0: format(name,size,"Police Cruiser (model 596)"); case 1: format(name,size,"Police Ranger (model 599)"); case 2: format(name,size,"HPV-1000 motorcycle (model 523)"); case 3: format(name,size,"FBI Rancher (model 490)"); case 4: format(name,size,"Police transport van (Enforcer, model 427)"); }
        }
        case FACTION_HOSPITAL:
        {
            switch (tier) { case 0: format(name,size,"Ambulance (model 416)"); case 1: format(name,size,"Caddy medical (model 457)"); case 2: format(name,size,"Rancher medical (model 489)"); case 3: format(name,size,"Utility vehicle (model 482)"); case 4: format(name,size,"Landstalker medical (model 400)"); }
        }
        case FACTION_ARMY:
        {
            switch (tier) { case 0: format(name,size,"Patriot (model 470)"); case 1: format(name,size,"Barracks (model 433)"); case 2: format(name,size,"Enforcer (model 427)"); case 3: format(name,size,"Rhino (model 432)"); case 4: format(name,size,"Patriot command (model 470)"); }
        }
        case FACTION_NAVY:
        {
            switch (tier) { case 0: format(name,size,"Patrol SUV (model 470)"); case 1: format(name,size,"Barracks (model 433)"); case 2: format(name,size,"Coast Guard boat (model 430)"); case 3: format(name,size,"Predator boat (model 446)"); case 4: format(name,size,"Leviathan helicopter (model 417)"); }
        }
        case FACTION_AIRFORCE:
        {
            switch (tier) { case 0: format(name,size,"Patrol car (model 470)"); case 1: format(name,size,"Utility helicopter (model 487)"); case 2: format(name,size,"Police Maverick (model 497)"); case 3: format(name,size,"Fighter jet (model 520)"); case 4: format(name,size,"Nevada transport aircraft (model 553)"); }
        }
        case FACTION_FBI:
        {
            switch (tier) { case 0: format(name,size,"FBI Rancher (model 490)"); case 1: format(name,size,"FBI Truck (model 528)"); case 2: format(name,size,"Police Maverick (model 497)"); case 3: format(name,size,"HPV-1000 (model 523)"); case 4: format(name,size,"Enforcer (model 427)"); }
        }
        default: format(name,size,"Service vehicle");
    }
    return 1;
}

stock GetFactionVehicleModel(faction, tier)
{
    switch (faction)
    {
        case FACTION_CITYHALL: { if (tier == 0) return 405; if (tier == 1) return 421; if (tier == 2) return 426; if (tier == 3) return 409; return 560; }
        case FACTION_POLICE: { if (tier == 0) return 596; if (tier == 1) return 599; if (tier == 2) return 523; if (tier == 3) return 490; return 427; }
        case FACTION_HOSPITAL: { if (tier == 0) return 416; if (tier == 1) return 457; if (tier == 2) return 489; if (tier == 3) return 482; return 400; }
        case FACTION_ARMY: { if (tier == 0) return 470; if (tier == 1) return 433; if (tier == 2) return 427; if (tier == 3) return 432; return 470; }
        case FACTION_NAVY: { if (tier == 0) return 470; if (tier == 1) return 433; if (tier == 2) return 430; if (tier == 3) return 446; return 417; }
        case FACTION_AIRFORCE: { if (tier == 0) return 470; if (tier == 1) return 487; if (tier == 2) return 497; if (tier == 3) return 520; return 553; }
        case FACTION_FBI: { if (tier == 0) return 490; if (tier == 1) return 528; if (tier == 2) return 497; if (tier == 3) return 523; return 427; }
    }
    return 400;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
    if (!gLogged[playerid] || gAdmin[playerid] < 1) return 1;
    if (IsPlayerInAnyVehicle(playerid))
    {
        new vehicleid = GetPlayerVehicleID(playerid);
        SetVehiclePos(vehicleid, fX, fY, fZ + 2.0);
        LinkVehicleToInterior(vehicleid, 0);
    }
    else SetPlayerPos(playerid, fX, fY, fZ + 2.0);
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    SetCameraBehindPlayer(playerid);
    SendClientMessage(playerid, COLOR_GREEN, "[VEXORIUM] Teleport po kliku na karte vypolnen.");
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if (gFBIEditActive[playerid] && gFBIEditObject[playerid] != INVALID_OBJECT_ID)
    {
        if ((newkeys & KEY_SPRINT) && !(oldkeys & KEY_SPRINT)) { gFBIEditRZ[playerid] += 5.0; if (gFBIEditRZ[playerid] >= 360.0) gFBIEditRZ[playerid] -= 360.0; UpdateFBIEditorObject(playerid); }
        if ((newkeys & KEY_FIRE) && !(oldkeys & KEY_FIRE)) { gFBIEditRZ[playerid] -= 5.0; if (gFBIEditRZ[playerid] < 0.0) gFBIEditRZ[playerid] += 360.0; UpdateFBIEditorObject(playerid); }
        return 1;
    }
    // Vehicle horn: KEY_SUBMISSION is the GTA:SA horn control.
    if ((newkeys & KEY_SUBMISSION) && !(oldkeys & KEY_SUBMISSION) && IsPlayerInAnyVehicle(playerid))
    {
        if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
        {
            // Play a horn sound for the driver; GTA still handles the normal vehicle horn locally.
            PlayerPlaySound(playerid, 1130, 0.0, 0.0, 0.0);
        }
    }
    if ((newkeys & KEY_YES) && !(oldkeys & KEY_YES))
    {
        if (gPvpPendingFrom[playerid] != INVALID_PLAYER_ID)
        {
            new challenger = gPvpPendingFrom[playerid];
            if (!IsPlayerConnected(challenger) || gPvpRequestTarget[challenger] != playerid)
            {
                gPvpPendingFrom[playerid] = INVALID_PLAYER_ID;
                SendClientMessage(playerid, COLOR_RED, "[PvP] Приглашение уже недействительно.");
                return 1;
            }
            if (gPvpActive[playerid] || gPvpActive[challenger]) return SendClientMessage(playerid, COLOR_RED, "[PvP] Один из игроков уже участвует в дуэли."), 1;
            gPvpPendingFrom[playerid] = INVALID_PLAYER_ID;
            gPvpRequestTarget[challenger] = INVALID_PLAYER_ID;
            gPvpActive[playerid] = true; gPvpActive[challenger] = true;
            gPvpOpponent[playerid] = challenger; gPvpOpponent[challenger] = playerid;
            gPvpScore[playerid] = 0; gPvpScore[challenger] = 0;
            new arenaWorld = 1000 + challenger * MAX_PLAYERS + playerid;
            gPvpArenaWorld[playerid] = arenaWorld; gPvpArenaWorld[challenger] = arenaWorld;
            SavePvpLoadout(playerid); SavePvpLoadout(challenger);
            PutPlayerInPvpArena(challenger, challenger < playerid ? 0 : 1);
            PutPlayerInPvpArena(playerid, playerid < challenger ? 0 : 1);
            SendClientMessage(playerid, COLOR_GREEN, "[PvP] Вы приняли вызов! Только Desert Eagle, до 5 побед.");
            SendClientMessage(challenger, COLOR_GREEN, "[PvP] Соперник принял вызов! Только Desert Eagle, до 5 побед.");
            return 1;
        }
        if (gLogged[playerid] && GetPlayerInterior(playerid) == 0 && GetPlayerVirtualWorld(playerid) == 0 && IsPlayerInRangeOfPoint(playerid, 3.5, -2026.8, -96.5, 35.2))
        {
            if (gLicenseDriver[playerid]) SendClientMessage(playerid, COLOR_GREEN, "У вас уже есть водительская лицензия." );
            else if (gDrivingTestStage[playerid] > 0) SendClientMessage(playerid, COLOR_YELLOW, "Вы уже сдаёте экзамен. Следуйте по контрольным точкам." );
            else ShowPlayerDialog(playerid, DIALOG_AUTOSCHOOL, DIALOG_STYLE_MSGBOX, "Автошкола | Инструктор", "Здравствуйте! Арендовать учебный автомобиль и начать экзамен?\nМаршрут проходит по дорогам Сан-Фиерро.\nОплата 15000 руб. только после успешной сдачи.", "Начать", "Отмена");
        }
    }
    return 1;
}

stock UpdateFBIEditorObject(playerid)
{
    if (!gFBIEditActive[playerid] || gFBIEditObject[playerid] == INVALID_OBJECT_ID) return 0;
    SetObjectPos(gFBIEditObject[playerid], gFBIEditX[playerid], gFBIEditY[playerid], gFBIEditZ[playerid]);
    SetObjectRot(gFBIEditObject[playerid], gFBIEditRX[playerid], gFBIEditRY[playerid], gFBIEditRZ[playerid]);
    return 1;
}

stock StartFBIObjectEditor(playerid, modelid)
{
    if (modelid < 1 || modelid > 20000) return SendClientMessage(playerid, COLOR_RED, "Model ID must be between 1 and 20000."), 0;
    if (gFBIEditActive[playerid] && gFBIEditObject[playerid] != INVALID_OBJECT_ID) DestroyObject(gFBIEditObject[playerid]);
    new Float:px, Float:py, Float:pz, Float:angle;
    GetPlayerPos(playerid, px, py, pz);
    GetPlayerFacingAngle(playerid, angle);
    gFBIEditX[playerid] = px + (3.0 * floatsin(-angle, degrees));
    gFBIEditY[playerid] = py + (3.0 * floatcos(-angle, degrees));
    gFBIEditZ[playerid] = pz;
    gFBIEditRX[playerid] = 0.0; gFBIEditRY[playerid] = 0.0; gFBIEditRZ[playerid] = angle;
    gFBIEditObject[playerid] = CreateObject(modelid, gFBIEditX[playerid], gFBIEditY[playerid], gFBIEditZ[playerid], gFBIEditRX[playerid], gFBIEditRY[playerid], gFBIEditRZ[playerid], 300.0);
    if (gFBIEditObject[playerid] == INVALID_OBJECT_ID) return SendClientMessage(playerid, COLOR_RED, "Could not create object. Check the model ID."), 0;
    gFBIEditActive[playerid] = true;
    TogglePlayerControllable(playerid, 0);
    gFBIEditorCamX[playerid] = gFBIEditX[playerid] - (5.0 * floatsin(-angle, degrees));
    gFBIEditorCamY[playerid] = gFBIEditY[playerid] - (5.0 * floatcos(-angle, degrees));
    gFBIEditorCamZ[playerid] = gFBIEditZ[playerid] + 2.0;
    SetPlayerCameraPos(playerid, gFBIEditorCamX[playerid], gFBIEditorCamY[playerid], gFBIEditorCamZ[playerid]);
    SetPlayerCameraLookAt(playerid, gFBIEditX[playerid], gFBIEditY[playerid], gFBIEditZ[playerid], CAMERA_CUT);
    SendClientMessage(playerid, COLOR_GREEN, "FBI EDITOR: player frozen, free camera enabled.");
    SendClientMessage(playerid, COLOR_YELLOW, "CAMERA: directional controls fly; mouse moves view. SPACE/CROUCH move camera vertically.");
    SendClientMessage(playerid, COLOR_YELLOW, "OBJECT: hold a direction to move smoothly (0.08m/update). SPRINT/FIRE rotate on press; /fbiz changes height.");
    SendClientMessage(playerid, COLOR_YELLOW, "Note: standard SA-MP does not send mouse-wheel input to the server.");
    SendClientMessage(playerid, COLOR_YELLOW, "/fbisave: coordinates | /fbidelete: delete object | /fbistop: delete preview and exit.");
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    if (CommandMatch(cmdtext, "/fbiedit") || strfind(cmdtext, "/fbiedit ", true) == 0)
    {
        if (!gLogged[playerid] || gAdmin[playerid] < 1) return SendClientMessage(playerid, COLOR_RED, "Only admins can use the FBI object editor."), 1;
        new modelid = 19379;
        if (strlen(cmdtext) > 9) modelid = strval(cmdtext[9]);
        return StartFBIObjectEditor(playerid, modelid), 1;
    }
    if (CommandMatch(cmdtext, "/fbisave"))
    {
        if (!gFBIEditActive[playerid]) return SendClientMessage(playerid, COLOR_RED, "Start the editor first: /fbiedit MODEL_ID"), 1;
        new info[220];
        format(info, sizeof info, "FBI OBJECT: model/coords X %.4f Y %.4f Z %.4f | RX %.2f RY %.2f RZ %.2f", gFBIEditX[playerid], gFBIEditY[playerid], gFBIEditZ[playerid], gFBIEditRX[playerid], gFBIEditRY[playerid], gFBIEditRZ[playerid]);
        SendClientMessage(playerid, COLOR_GREEN, info);
        SendClientMessage(playerid, COLOR_YELLOW, "Copy these coordinates from chat to send them to the developer. This command prints coordinates; it does not write to the source file.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/fbimode"))
    {
        if (!gFBIEditActive[playerid]) return SendClientMessage(playerid, COLOR_RED, "Start the editor first: /fbiedit MODEL_ID"), 1;
        gFBIEditMoveObject[playerid] = !gFBIEditMoveObject[playerid];
        if (gFBIEditMoveObject[playerid]) SendClientMessage(playerid, COLOR_GREEN, "OBJECT MODE: WASD moves the object. /fbimode returns to free camera.");
        else SendClientMessage(playerid, COLOR_GREEN, "CAMERA MODE: WASD flies the camera; mouse changes view.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/fbiz") || strfind(cmdtext, "/fbiz ", true) == 0)
    {
        if (!gFBIEditActive[playerid]) return SendClientMessage(playerid, COLOR_RED, "Start the editor first: /fbiedit MODEL_ID"), 1;
        new Float:step = floatstr(cmdtext[6]);
        if (step == 0.0) return SendClientMessage(playerid, COLOR_YELLOW, "Usage: /fbiz 0.1 or /fbiz -0.1"), 1;
        gFBIEditZ[playerid] += step;
        UpdateFBIEditorObject(playerid);
        return 1;
    }
    if (CommandMatch(cmdtext, "/fbidelete"))
    {
        if (gFBIEditObject[playerid] != INVALID_OBJECT_ID) DestroyObject(gFBIEditObject[playerid]);
        gFBIEditObject[playerid] = INVALID_OBJECT_ID;
        if (gFBIEditActive[playerid]) { gFBIEditActive[playerid] = false; SetCameraBehindPlayer(playerid); TogglePlayerControllable(playerid, 1); }
        SendClientMessage(playerid, COLOR_GREEN, "Editor preview object deleted.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/fbistop"))
    {
        if (gFBIEditObject[playerid] != INVALID_OBJECT_ID) DestroyObject(gFBIEditObject[playerid]);
        gFBIEditObject[playerid] = INVALID_OBJECT_ID;
        if (gFBIEditActive[playerid]) { SetCameraBehindPlayer(playerid); TogglePlayerControllable(playerid, 1); }
        gFBIEditActive[playerid] = false;
        SendClientMessage(playerid, COLOR_GREEN, "Editor closed; temporary preview object removed.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/coor"))
    {
        new Float:x, Float:y, Float:z, Float:a, info[192];
        GetPlayerPos(playerid, x, y, z);
        GetPlayerFacingAngle(playerid, a);
        format(info, sizeof info, "[COOR] X: %.4f | Y: %.4f | Z: %.4f | A: %.2f | Interior: %d | VW: %d", x, y, z, a, GetPlayerInterior(playerid), GetPlayerVirtualWorld(playerid));
        SendClientMessage(playerid, COLOR_GREEN, info);
        SendClientMessage(playerid, COLOR_YELLOW, "Команда /coor доступна всем. Строку [COOR] можно найти в chatlog.txt клиента SA-MP.");
        return 1;
    }
    if (!strcmp(cmdtext, "/spawn", true)) return ShowSpawnMenu(playerid), 1;
    if (CommandMatch(cmdtext, "/hub") || CommandMatch(cmdtext, "/menu")) return ShowMainMenu(playerid), 1;
    if (!gLogged[playerid])
    {
        SendClientMessage(playerid, COLOR_RED, "Сначала войдите в аккаунт.");
        return 1;
    }
    // Police roleplay greeting: /heypolice (does not open a menu).
    if (CommandMatch(cmdtext, "/heypolice"))
    {
        if (gFaction[playerid] != FACTION_POLICE || gFactionRank[playerid] < 1)
            return SendClientMessage(playerid, COLOR_RED, "Only LSPD officers can use this command."), 1;
        new rankName[32], greeting[192], action[224];
        new Float:px, Float:py, Float:pz;
        GetFactionRankName(FACTION_POLICE, gFactionRank[playerid], rankName, sizeof rankName);
        format(greeting, sizeof greeting, "Здравия желаю! Я %s %s, вот мои документы.", rankName, gName[playerid]);
        format(action, sizeof action, "%s говорит: %s", gName[playerid], greeting);
        GetPlayerPos(playerid, px, py, pz);
        for (new i = 0; i < MAX_PLAYERS; i++)
        {
            if (IsPlayerConnected(i) && gLogged[i] && GetPlayerInterior(i) == GetPlayerInterior(playerid) && GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid) && IsPlayerInRangeOfPoint(i, 15.0, px, py, pz))
                SendClientMessage(i, COLOR_YELLOW, action);
        }
        return 1;
    }
    if (CommandMatch(cmdtext, "/pvp"))
    {
        new params[32], token[16], targetid;
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, token, sizeof token))
            return SendClientMessage(playerid, COLOR_YELLOW, "Использование: /pvp [ID игрока]"), 1;
        targetid = strval(token);
        if (targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid) || !gLogged[targetid])
            return SendClientMessage(playerid, COLOR_RED, "Игрок с таким ID не найден."), 1;
        if (targetid == playerid) return SendClientMessage(playerid, COLOR_RED, "Нельзя вызвать на дуэль самого себя."), 1;
        if (gPvpActive[playerid] || gPvpActive[targetid] || gPvpRequestTarget[playerid] != INVALID_PLAYER_ID || gPvpPendingFrom[playerid] != INVALID_PLAYER_ID || gPvpRequestTarget[targetid] != INVALID_PLAYER_ID || gPvpPendingFrom[targetid] != INVALID_PLAYER_ID)
            return SendClientMessage(playerid, COLOR_RED, "Один из игроков уже участвует в дуэли или получил приглашение."), 1;
        if (GetPlayerInterior(playerid) != GetPlayerInterior(targetid) || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(targetid))
            return SendClientMessage(playerid, COLOR_RED, "Вы должны находиться рядом в одном измерении."), 1;
        new Float:tx, Float:ty, Float:tz;
        GetPlayerPos(targetid, tx, ty, tz);
        if (!IsPlayerInRangeOfPoint(playerid, 5.0, tx, ty, tz))
            return SendClientMessage(playerid, COLOR_RED, "Подойдите к игроку ближе чем на 5 метров."), 1;
        if (IsPlayerInAnyVehicle(playerid) || IsPlayerInAnyVehicle(targetid))
            return SendClientMessage(playerid, COLOR_RED, "Для вызова на дуэль оба игрока должны выйти из транспорта."), 1;
        gPvpRequestTarget[playerid] = targetid;
        gPvpPendingFrom[targetid] = playerid;
        new pvpMsg[144];
        format(pvpMsg, sizeof pvpMsg, "[PvP] %s вызывает вас на дуэль! Нажмите Y, чтобы принять. Победа до 5 раундов, оружие — только Desert Eagle.", gName[playerid]);
        SendClientMessage(targetid, COLOR_ORANGE, pvpMsg);
        format(pvpMsg, sizeof pvpMsg, "[PvP] Приглашение отправлено игроку %s. Он должен нажать Y.", gName[targetid]);
        SendClientMessage(playerid, COLOR_GREEN, pvpMsg);
        return 1;
    }

    // Owner-only command: set any logged-in player's character level.
    if (CommandMatch(cmdtext, "/setlevel"))
    {
        if (!IsOwner(playerid))
            return SendClientMessage(playerid, COLOR_RED, "Access denied: only the server owner can change character levels."), 1;
        new params[64], token[16], token2[16], targetid, level, levelMessage[144];
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, token, sizeof token) || !GetToken(params, 1, token2, sizeof token2))
            return SendClientMessage(playerid, COLOR_YELLOW, "Usage: /setlevel [ID] [1-1000]"), 1;
        targetid = strval(token);
        level = strval(token2);
        if (targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid) || !gLogged[targetid] || level < 1 || level > 1000)
            return SendClientMessage(playerid, COLOR_RED, "Invalid player ID or level. Use /setlevel [ID] [1-1000]."), 1;
        gLevel[targetid] = level;
        gExperience[targetid] = GetExperienceForLevel(level);
        SetPlayerScore(targetid, level);
        SavePlayer(targetid);
        format(levelMessage, sizeof levelMessage, "[VEXORIUM] Your character level is now %d and has been saved.", level);
        SendClientMessage(targetid, COLOR_GREEN, levelMessage);
        format(levelMessage, sizeof levelMessage, "[VEXORIUM] You set %s's character level to %d.", gName[targetid], level);
        SendClientMessage(playerid, COLOR_GREEN, levelMessage);
        RefreshVexHud(targetid);
        return 1;
    }

    // Owner-only bootstrap command: set your own admin level and persist it.
    if (CommandMatch(cmdtext, "/myadminlevel"))
    {
        if (!IsOwner(playerid))
            return SendClientMessage(playerid, COLOR_RED, "Access denied: owner account only."), 1;
        new params[32], token[16], level, query[160];
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, token, sizeof token))
            return SendClientMessage(playerid, COLOR_YELLOW, "Usage: /myadminlevel [0-5]"), 1;
        level = strval(token);
        if (level < 0 || level > 5)
            return SendClientMessage(playerid, COLOR_RED, "Admin level must be between 0 and 5."), 1;
        gAdmin[playerid] = level;
        format(query, sizeof query, "UPDATE accounts SET admin=%d WHERE name='%q'", level, gName[playerid]);
        new DBResult:adminSave = db_query(gDatabase, query);
        if (adminSave) db_free_result(adminSave);
        format(query, sizeof query, "[VEXORIUM] Your admin level is now %d and has been saved.", level);
        SendClientMessage(playerid, COLOR_GREEN, query);
        return 1;
    }

    // Secret owner-only command: instantly run the normal payday for all logged-in players.
    if (CommandMatch(cmdtext, "/paydayall"))
    {
        if (gAdmin[playerid] < 5)
            return SendClientMessage(playerid, COLOR_RED, "Доступ запрещён."), 1;
        SendClientMessageToAll(COLOR_BLUE, "[VEXORIUM] Внеплановый PayDay! Выплата начислена всем игрокам онлайн.");
        PayDay();
        SendClientMessage(playerid, COLOR_GREEN, "PayDay выдан всем игрокам, находящимся онлайн.");
        return 1;
    }
    if (gIsJailed[playerid] && strcmp(cmdtext, "/stats", true) != 0 && strcmp(cmdtext, "/help", true) != 0)
    {
        SendClientMessage(playerid, COLOR_RED, "Вы в КПЗ и не можете использовать эту команду.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/pass") || CommandMatch(cmdtext, "/passport") || CommandMatch(cmdtext, "/pasport"))
    {
        new factionName[32], doc[256];
        GetFactionName(gFaction[playerid], factionName, sizeof factionName);
        format(doc, sizeof doc, "[PASSPORT] Name: %s | Level: %d | Faction: %s | ID: %d", gName[playerid], gLevel[playerid], factionName, playerid);
        SendClientMessage(playerid, COLOR_YELLOW, doc);
        return 1;
    }
    if (CommandMatch(cmdtext, "/showpass") || CommandMatch(cmdtext, "/checkpass"))
    {
        new params[64], token[24], targetid, factionName[32], doc[192];
        if (gFaction[playerid] != FACTION_POLICE || gFactionRank[playerid] < 1)
            return SendClientMessage(playerid, COLOR_RED, "Запрашивать паспорт может только сотрудник полиции."), 1;
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, token, sizeof token))
            return SendClientMessage(playerid, COLOR_YELLOW, "Использование: /showpass [ID]"), 1;
        targetid = strval(token);
        if (targetid < 0 || targetid >= MAX_PLAYERS || targetid == playerid || !IsPlayerConnected(targetid) || !gLogged[targetid])
            return SendClientMessage(playerid, COLOR_RED, "Игрок не найден."), 1;
        new Float:px, Float:py, Float:pz;
        GetPlayerPos(playerid, px, py, pz);
        if (GetPlayerInterior(playerid) != GetPlayerInterior(targetid) || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(targetid) || !IsPlayerInRangeOfPoint(targetid, 4.0, px, py, pz))
            return SendClientMessage(playerid, COLOR_RED, "Игрок должен находиться рядом с вами (до 4 метров)."), 1;
        GetFactionName(gFaction[targetid], factionName, sizeof factionName);
        format(doc, sizeof doc, "[ПАСПОРТ] %s | ID: %d | Уровень: %d | Организация: %s", gName[targetid], targetid, gLevel[targetid], factionName);
        SendClientMessage(playerid, COLOR_BLUE, doc);
        format(doc, sizeof doc, "Сотрудник полиции %s запросил ваш паспорт.", gName[playerid]);
        SendClientMessage(targetid, COLOR_YELLOW, doc);
        return 1;
    }
    if (CommandMatch(cmdtext, "/search") || CommandMatch(cmdtext, "/obysk"))
    {
        new params[64], token[24], targetid, factionName[32], result[256], weaponid, ammo, weaponCount;
        if (gFaction[playerid] != FACTION_POLICE || gFactionRank[playerid] < 1)
            return SendClientMessage(playerid, COLOR_RED, "Обыск доступен только сотрудникам полиции."), 1;
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, token, sizeof token))
            return SendClientMessage(playerid, COLOR_YELLOW, "Использование: /search [ID]"), 1;
        targetid = strval(token);
        if (targetid < 0 || targetid >= MAX_PLAYERS || targetid == playerid || !IsPlayerConnected(targetid) || !gLogged[targetid])
            return SendClientMessage(playerid, COLOR_RED, "Игрок не найден."), 1;
        new Float:px, Float:py, Float:pz;
        GetPlayerPos(playerid, px, py, pz);
        if (GetPlayerInterior(playerid) != GetPlayerInterior(targetid) || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(targetid) || !IsPlayerInRangeOfPoint(targetid, 3.0, px, py, pz))
            return SendClientMessage(playerid, COLOR_RED, "Для обыска игрок должен быть рядом (до 3 метров)."), 1;
        GetFactionName(gFaction[targetid], factionName, sizeof factionName);
        weaponCount = 0;
        for (new slot = 0; slot < 13; slot++)
        {
            GetPlayerWeaponData(targetid, slot, weaponid, ammo);
            if (weaponid > 0 && ammo > 0) weaponCount++;
        }
        format(result, sizeof result, "[ОБЫСК] %s (ID %d)\nДеньги: %d руб.\nОрганизация: %s\nОружейных слотов с оружием: %d", gName[targetid], targetid, gMoney[targetid], factionName, weaponCount);
        SendClientMessage(playerid, COLOR_BLUE, result);
        format(result, sizeof result, "Сотрудник полиции %s проводит RP-обыск. Предметы и деньги не изымаются автоматически.", gName[playerid]);
        SendClientMessage(targetid, COLOR_YELLOW, result);
        return 1;
    }
    if (CommandMatch(cmdtext, "/lic") || CommandMatch(cmdtext, "/licenses") || CommandMatch(cmdtext, "/licences"))
    {
        if (gLicenseDriver[playerid]) SendClientMessage(playerid, COLOR_BLUE, "[ЛИЦЕНЗИИ] Авто: есть");
        else SendClientMessage(playerid, COLOR_BLUE, "[ЛИЦЕНЗИИ] Авто: нет");
        if (gLicenseWeapon[playerid]) SendClientMessage(playerid, COLOR_BLUE, "[ЛИЦЕНЗИИ] Оружие: есть");
        else SendClientMessage(playerid, COLOR_BLUE, "[ЛИЦЕНЗИИ] Оружие: нет");
        if (gLicenseBoat[playerid]) SendClientMessage(playerid, COLOR_BLUE, "Лодка: есть");
        else SendClientMessage(playerid, COLOR_BLUE, "Лодка: нет");
        if (gLicenseAir[playerid]) SendClientMessage(playerid, COLOR_BLUE, "Самолёт: есть");
        else SendClientMessage(playerid, COLOR_BLUE, "Самолёт: нет");
        SendClientMessage(playerid, COLOR_YELLOW, "Покупка авто-лицензии: автошкола /autoschool. Остальные лицензии — в мэрии через /licbuy.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/autoschool"))
        return SendClientMessage(playerid, COLOR_YELLOW, "Поговорите с инструктором автошколы и нажмите Y."), 1;
    if (CommandMatch(cmdtext, "/licadmin"))
    {
        if (gAdmin[playerid] < 1) return SendClientMessage(playerid, COLOR_RED, "Команда доступна только администраторам."), 1;
        new params[32], token[16];
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, token, sizeof token))
            return SendClientMessage(playerid, COLOR_YELLOW, "Usage: /licadmin auto|weapon|boat|air|all"), 1;
        if (!strcmp(token, "auto", true) || !strcmp(token, "all", true)) gLicenseDriver[playerid] = 1;
        if (!strcmp(token, "weapon", true) || !strcmp(token, "all", true)) gLicenseWeapon[playerid] = 1;
        if (!strcmp(token, "boat", true) || !strcmp(token, "all", true)) gLicenseBoat[playerid] = 1;
        if (!strcmp(token, "air", true) || !strcmp(token, "all", true)) gLicenseAir[playerid] = 1;
        if (strcmp(token, "auto", true) && strcmp(token, "weapon", true) && strcmp(token, "boat", true) && strcmp(token, "air", true) && strcmp(token, "all", true))
            return SendClientMessage(playerid, COLOR_YELLOW, "Types: auto, weapon, boat, air, all."), 1;
        SavePlayer(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "Лицензии выданы вашему персонажу и сохранены." );
        return 1;
    }
    if (CommandMatch(cmdtext, "/licbuy"))
    {
        new params[32], token[16], price, licenseType;
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, token, sizeof token))
            return SendClientMessage(playerid, COLOR_YELLOW, "Использование: /licbuy auto|weapon|boat|air"), 1;
        if (!strcmp(token, "auto", true))
        {
            if (GetPlayerInterior(playerid) != 3 || GetPlayerVirtualWorld(playerid) != 101 || !IsPlayerInRangeOfPoint(playerid, 5.0, 362.4587, 174.0056, 1008.3828))
                return SendClientMessage(playerid, COLOR_RED, "Подойдите к стойке лицензий в мэрии."), 1;
            if (gLicenseDriver[playerid]) return SendClientMessage(playerid, COLOR_GREEN, "У вас уже есть водительские права."), 1;
            if (!gDrivingExamPassed[playerid]) return SendClientMessage(playerid, COLOR_RED, "Сначала сдайте маршрут в автошколе."), 1;
            gLicenseDriver[playerid] = 1;
            gDrivingExamPassed[playerid] = 0;
            SavePlayer(playerid);
            SendClientMessage(playerid, COLOR_GREEN, "Водительские права выданы бесплатно: оплата уже включена в экзамен.");
            return 1;
        }
        else if (!strcmp(token, "weapon", true))
        {
            if (GetPlayerInterior(playerid) != 3 || GetPlayerVirtualWorld(playerid) != 101 || !IsPlayerInRangeOfPoint(playerid, 5.0, 392.0, 175.0, 1008.4)) return SendClientMessage(playerid, COLOR_RED, "Лицензии выдаются в мэрии. Подойдите к зданию мэрии."), 1;
            licenseType = 2; price = 30000;
            if (gLicenseWeapon[playerid]) return SendClientMessage(playerid, COLOR_GREEN, "У вас уже есть лицензия на оружие."), 1;
        }
        else if (!strcmp(token, "boat", true))
        {
            if (GetPlayerInterior(playerid) != 3 || GetPlayerVirtualWorld(playerid) != 101 || !IsPlayerInRangeOfPoint(playerid, 5.0, 392.0, 175.0, 1008.4)) return SendClientMessage(playerid, COLOR_RED, "Лицензии выдаются в мэрии. Подойдите к зданию мэрии."), 1;
            licenseType = 3; price = 20000;
            if (gLicenseBoat[playerid]) return SendClientMessage(playerid, COLOR_GREEN, "У вас уже есть лицензия на лодку."), 1;
        }
        else if (!strcmp(token, "air", true))
        {
            if (GetPlayerInterior(playerid) != 3 || GetPlayerVirtualWorld(playerid) != 101 || !IsPlayerInRangeOfPoint(playerid, 5.0, 392.0, 175.0, 1008.4)) return SendClientMessage(playerid, COLOR_RED, "Лицензии выдаются в мэрии. Подойдите к зданию мэрии."), 1;
            licenseType = 4; price = 40000;
            if (gLicenseAir[playerid]) return SendClientMessage(playerid, COLOR_GREEN, "У вас уже есть лицензия на самолёт."), 1;
        }
        else return SendClientMessage(playerid, COLOR_YELLOW, "Типы лицензий: auto, weapon, boat, air."), 1;
        if (gMoney[playerid] < price) return SendClientMessage(playerid, COLOR_RED, "Недостаточно наличных для покупки лицензии."), 1;
        gMoney[playerid] -= price;
        if (licenseType == 1) gLicenseDriver[playerid] = 1;
        else if (licenseType == 2) gLicenseWeapon[playerid] = 1;
        else if (licenseType == 3) gLicenseBoat[playerid] = 1;
        else if (licenseType == 4) gLicenseAir[playerid] = 1;
        ResetPlayerMoney(playerid); GivePlayerMoney(playerid, gMoney[playerid]);
        SavePlayer(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "Поздравляем! Лицензия выдана и сохранена в вашем аккаунте.");
        RefreshVexHud(playerid);
        return 1;
    }
    if (CommandMatch(cmdtext, "/mylicense"))
    {
        if (gAdmin[playerid] < 1) return SendClientMessage(playerid, COLOR_RED, "Only admins can use this command."), 1;
        new params[32], token[16];
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, token, sizeof token))
            return SendClientMessage(playerid, COLOR_YELLOW, "Usage: /mylicense auto|weapon|boat|air|all"), 1;
        if (!strcmp(token, "auto", true) || !strcmp(token, "all", true)) gLicenseDriver[playerid] = 1;
        if (!strcmp(token, "weapon", true) || !strcmp(token, "all", true)) gLicenseWeapon[playerid] = 1;
        if (!strcmp(token, "boat", true) || !strcmp(token, "all", true)) gLicenseBoat[playerid] = 1;
        if (!strcmp(token, "air", true) || !strcmp(token, "all", true)) gLicenseAir[playerid] = 1;
        if (strcmp(token, "auto", true) && strcmp(token, "weapon", true) && strcmp(token, "boat", true) && strcmp(token, "air", true) && strcmp(token, "all", true))
            return SendClientMessage(playerid, COLOR_YELLOW, "Types: auto, weapon, boat, air, all."), 1;
        SavePlayer(playerid);
        RefreshVexHud(playerid);
        return SendClientMessage(playerid, COLOR_GREEN, "Licenses granted to your character and saved."), 1;
    }
    if (CommandMatch(cmdtext, "/givelicense"))
    {
        if (gAdmin[playerid] < 1) return SendClientMessage(playerid, COLOR_RED, "Only admins can use this command."), 1;
        new params[64], idToken[16], typeToken[16], targetid;
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, idToken, sizeof idToken) || !GetToken(params, 1, typeToken, sizeof typeToken))
            return SendClientMessage(playerid, COLOR_YELLOW, "Usage: /givelicense [ID] auto|weapon|boat|air|all"), 1;
        targetid = strval(idToken);
        if (targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid) || !gLogged[targetid])
            return SendClientMessage(playerid, COLOR_RED, "Player ID not found or player is not logged in."), 1;
        if (strcmp(typeToken, "auto", true) && strcmp(typeToken, "weapon", true) && strcmp(typeToken, "boat", true) && strcmp(typeToken, "air", true) && strcmp(typeToken, "all", true))
            return SendClientMessage(playerid, COLOR_YELLOW, "Types: auto, weapon, boat, air, all."), 1;
        if (!strcmp(typeToken, "auto", true) || !strcmp(typeToken, "all", true)) gLicenseDriver[targetid] = 1;
        if (!strcmp(typeToken, "weapon", true) || !strcmp(typeToken, "all", true)) gLicenseWeapon[targetid] = 1;
        if (!strcmp(typeToken, "boat", true) || !strcmp(typeToken, "all", true)) gLicenseBoat[targetid] = 1;
        if (!strcmp(typeToken, "air", true) || !strcmp(typeToken, "all", true)) gLicenseAir[targetid] = 1;
        SavePlayer(targetid);
        RefreshVexHud(targetid);
        SendClientMessage(targetid, COLOR_GREEN, "An administrator has granted you a license. It has been saved.");
        new licenseMsg[96];
        format(licenseMsg, sizeof licenseMsg, "License type %s granted to %s (ID %d).", typeToken, gName[targetid], targetid);
        SendClientMessage(playerid, COLOR_GREEN, licenseMsg);
        return 1;
    }
    if (CommandMatch(cmdtext, "/licgive"))
    {
        if (gFaction[playerid] != FACTION_CITYHALL || gFactionRank[playerid] < 1)
            return SendClientMessage(playerid, COLOR_RED, "Выдавать лицензии со скидкой могут только сотрудники мэрии."), 1;
        new params[64], idToken[16], typeToken[16], targetid, price, licenseType;
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, idToken, sizeof idToken) || !GetToken(params, 1, typeToken, sizeof typeToken))
            return SendClientMessage(playerid, COLOR_YELLOW, "Использование: /licgive [ID] auto|weapon|boat|air"), 1;
        targetid = strval(idToken);
        if (targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid) || !gLogged[targetid]) return SendClientMessage(playerid, COLOR_RED, "Игрок не найден или не авторизован."), 1;
        new Float:tx, Float:ty, Float:tz;
        GetPlayerPos(playerid, tx, ty, tz);
        if (GetPlayerInterior(playerid) != GetPlayerInterior(targetid) || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(targetid) || !IsPlayerInRangeOfPoint(targetid, 4.0, tx, ty, tz)) return SendClientMessage(playerid, COLOR_RED, "Игрок должен находиться рядом с вами (до 4 метров)."), 1;
        if (!strcmp(typeToken, "auto", true)) { licenseType = 1; price = 10000; if (gLicenseDriver[targetid]) return SendClientMessage(playerid, COLOR_RED, "У игрока уже есть лицензия на авто."), 1; }
        else if (!strcmp(typeToken, "weapon", true)) { licenseType = 2; price = 20000; if (gLicenseWeapon[targetid]) return SendClientMessage(playerid, COLOR_RED, "У игрока уже есть лицензия на оружие."), 1; }
        else if (!strcmp(typeToken, "boat", true)) { licenseType = 3; price = 12000; if (gLicenseBoat[targetid]) return SendClientMessage(playerid, COLOR_RED, "У игрока уже есть лицензия на лодку."), 1; }
        else if (!strcmp(typeToken, "air", true)) { licenseType = 4; price = 25000; if (gLicenseAir[targetid]) return SendClientMessage(playerid, COLOR_RED, "У игрока уже есть лицензия на самолёт."), 1; }
        else return SendClientMessage(playerid, COLOR_YELLOW, "Типы лицензий: auto, weapon, boat, air."), 1;
        if (gMoney[targetid] < price) return SendClientMessage(playerid, COLOR_RED, "У игрока недостаточно наличных."), 1;
        gMoney[targetid] -= price;
        if (licenseType == 1) gLicenseDriver[targetid] = 1;
        else if (licenseType == 2) gLicenseWeapon[targetid] = 1;
        else if (licenseType == 3) gLicenseBoat[targetid] = 1;
        else if (licenseType == 4) gLicenseAir[targetid] = 1;
        ResetPlayerMoney(targetid); GivePlayerMoney(targetid, gMoney[targetid]);
        SavePlayer(targetid);
        SendClientMessage(targetid, COLOR_GREEN, "Сотрудник мэрии выдал вам лицензию по льготной цене.");
        SendClientMessage(playerid, COLOR_GREEN, "Лицензия оформлена по льготной цене и сохранена.");
        RefreshVexHud(targetid);
        return 1;
    }
    if (CommandMatch(cmdtext, "/wbook") || CommandMatch(cmdtext, "/workbook") || CommandMatch(cmdtext, "/trudovaya"))
    {
        new factionName[32], doc[256];
        GetFactionName(gFaction[playerid], factionName, sizeof factionName);
        format(doc, sizeof doc, "[WORK BOOK] %s | Job ID: %d | Organization: %s | Rank: %d", gName[playerid], gJob[playerid], factionName, gFactionRank[playerid]);
        SendClientMessage(playerid, COLOR_YELLOW, doc);
        SendClientMessage(playerid, COLOR_ORANGE, "Employment history is not stored in this build; this shows current character data.");
        return 1;
    }
    if (!strcmp(cmdtext, "/mm", true) || !strcmp(cmdtext, "/menu", true) || !strcmp(cmdtext, "/меню", true))
    {
        ShowMainMenu(playerid);
        return 1;
    }
    if (!strcmp(cmdtext, "/help", true) || !strcmp(cmdtext, "/помощь", true))
    {
        new helpText[1024];
        helpText[0] = '\0';
        strcat(helpText, "/mm — главное меню сервера\n/gps — GPS по городу\n");
        strcat(helpText, "/job — выбрать работу (такси/дальнобойщик/автобус/шахта)\n");
        strcat(helpText, "/work — начать рабочий маршрут\n/stopwork — отменить маршрут\n/inv — инвентарь\n/balance — баланс\n");
        strcat(helpText, "/pay [ID] [сумма] — передать деньги\n/stats — статистика\n/leaders — лидеры организаций\n");
        strcat(helpText, "/enterpd — войти в участок, /org — меню организации, /exitpd — выйти\nМаркер одежды в раздевалке — форма по рангу\n/arrest [ID] [секунды], /release [ID]\n");
        strcat(helpText, "/me [действие] — RP-действие\n/do [описание] — RP-описание\n/n [текст] — OOC-чат рядом\n");
        strcat(helpText, "/r [текст] — рация фракции\n/rn [текст] — OOC-чат фракции\n/rules — правила сервера\n/save — сохранить прогресс\n");
        strcat(helpText, "Полиция: /showpass [ID] — запросить паспорт, /search [ID] — RP-обыск рядом\n");
        strcat(helpText, "/carshop — автосалон, /mycar — личная машина, /fuel — заправка\n\n");
        strcat(helpText, "Администраторы: /gps (телепорт), /tp [ID], /gethere [ID], /tpcar [ID],\n");
        strcat(helpText, "/setadmin [ID] [уровень], /setmoney [ID] [сумма],\n");
        strcat(helpText, "/setfaction [ID] [0-6] [ранг 0-10], /uniform [ID] [1-3], /kick [ID], /a [текст]");
        ShowPlayerDialog(playerid, DIALOG_HELP, DIALOG_STYLE_MSGBOX, "VEXORIUM RP | Команды", helpText, "Понятно", "");
        return 1;
    }
    if (CommandMatch(cmdtext, "/me"))
    {
        new params[128], msg[192]; GetParams(cmdtext, params, sizeof params);
        if (!strlen(params)) return SendClientMessage(playerid, COLOR_YELLOW, "Использование: /me [действие]"), 1;
        format(msg, sizeof msg, "* %s %s", gName[playerid], params);
        SendLocalMessage(playerid, COLOR_PINK, msg, 20.0); return 1;
    }
    if (CommandMatch(cmdtext, "/do"))
    {
        new params[128], msg[192]; GetParams(cmdtext, params, sizeof params);
        if (!strlen(params)) return SendClientMessage(playerid, COLOR_YELLOW, "Использование: /do [описание]"), 1;
        format(msg, sizeof msg, "* %s (( %s ))", params, gName[playerid]);
        SendLocalMessage(playerid, COLOR_BLUE, msg, 20.0); return 1;
    }
    if (CommandMatch(cmdtext, "/try"))
    {
        new params[128], msg[192]; GetParams(cmdtext, params, sizeof params);
        if (!strlen(params)) return SendClientMessage(playerid, COLOR_YELLOW, "Использование: /try [действие]"), 1;
        if (random(2) == 0) format(msg, sizeof msg, "* %s %s | Успешно", gName[playerid], params);
        else format(msg, sizeof msg, "* %s %s | Неудачно", gName[playerid], params);
        SendLocalMessage(playerid, COLOR_ORANGE, msg, 20.0);
        return 1;
    }
    if (CommandMatch(cmdtext, "/n") || CommandMatch(cmdtext, "/b"))
    {
        new params[128], msg[192]; GetParams(cmdtext, params, sizeof params);
        if (!strlen(params)) return SendClientMessage(playerid, COLOR_YELLOW, "Использование: /n [текст]"), 1;
        format(msg, sizeof msg, "(( %s: %s ))", gName[playerid], params);
        SendLocalMessage(playerid, COLOR_WHITE, msg, 20.0); return 1;
    }
    if (CommandMatch(cmdtext, "/r") || CommandMatch(cmdtext, "/f"))
    {
        new params[128], msg[192]; GetParams(cmdtext, params, sizeof params);
        if (gFaction[playerid] == FACTION_NONE) return SendClientMessage(playerid, COLOR_RED, "Вы не состоите в организации."), 1;
        if (!strlen(params)) return SendClientMessage(playerid, COLOR_YELLOW, "Использование: /r [сообщение фракции]"), 1;
        format(msg, sizeof msg, "[РАЦИЯ] %s: %s", gName[playerid], params);
        for (new i = 0; i < MAX_PLAYERS; i++) if (IsPlayerConnected(i) && gLogged[i] && gFaction[i] == gFaction[playerid]) SendClientMessage(i, COLOR_BLUE, msg);
        return 1;
    }
    if (CommandMatch(cmdtext, "/rn"))
    {
        new params[128], msg[192]; GetParams(cmdtext, params, sizeof params);
        if (gFaction[playerid] == FACTION_NONE) return SendClientMessage(playerid, COLOR_RED, "Вы не состоите в организации."), 1;
        if (!strlen(params)) return SendClientMessage(playerid, COLOR_YELLOW, "Использование: /rn [OOC сообщение фракции]"), 1;
        format(msg, sizeof msg, "(( [ФРАКЦИЯ OOC] %s: %s ))", gName[playerid], params);
        for (new i = 0; i < MAX_PLAYERS; i++) if (IsPlayerConnected(i) && gLogged[i] && gFaction[i] == gFaction[playerid]) SendClientMessage(i, COLOR_WHITE, msg);
        return 1;
    }
    if (CommandMatch(cmdtext, "/rent") || CommandMatch(cmdtext, "/rentscooter"))
    {
        if (!gLogged[playerid]) return SendClientMessage(playerid, COLOR_RED, "Сначала войдите в аккаунт."), 1;
        if (gLevel[playerid] > 3) return SendClientMessage(playerid, COLOR_RED, "Аренда скутера доступна только игрокам 1–3 уровня."), 1;
        if (gFaction[playerid] != FACTION_NONE) return SendClientMessage(playerid, COLOR_YELLOW, "Скутер на стартовой базе доступен новичкам без организации."), 1;
        if (!IsPlayerInRangeOfPoint(playerid, 20.0, 1764.0, -1898.0, 13.2))
            return SendClientMessage(playerid, COLOR_YELLOW, "Подойдите к скутеру на базе новичков у вокзала."), 1;
        if (gRentalVehicle[playerid] != INVALID_VEHICLE_ID)
            return SendClientMessage(playerid, COLOR_YELLOW, "У вас уже есть арендованный скутер."), 1;
        if (gBaseScooter != INVALID_VEHICLE_ID)
            return SendClientMessage(playerid, COLOR_YELLOW, "Сядьте на скутер у вокзала — появится предложение аренды."), 1;
        SpawnBaseScooter();
        return SendClientMessage(playerid, COLOR_GREEN, "Скутер снова появился на базе. Сядьте на него, чтобы арендовать."), 1;
    }
    if (CommandMatch(cmdtext, "/enterorg") || CommandMatch(cmdtext, "/orgenter") || CommandMatch(cmdtext, "/enterlog"))
    {
        EnterOrgInterior(playerid);
        return 1;
    }
    // Police quick menu: replaces the old /hipolice command.
    if (CommandMatch(cmdtext, "/police") || CommandMatch(cmdtext, "/pd"))
    {
        if (gFaction[playerid] != FACTION_POLICE || gFactionRank[playerid] < 1)
            return SendClientMessage(playerid, COLOR_RED, "Access denied: LSPD officers only."), 1;
        ShowPoliceMenu(playerid);
        return 1;
    }
    if (CommandMatch(cmdtext, "/org") || CommandMatch(cmdtext, "/orgmenu"))
    {
        if (gFaction[playerid] == FACTION_NONE || gFactionRank[playerid] < 1)
            return SendClientMessage(playerid, COLOR_RED, "Вы не состоите в организации."), 1;
        if (!IsInOwnOrgInterior(playerid))
            return SendClientMessage(playerid, COLOR_YELLOW, "Сначала войдите через маркер у двери своего штаба, затем введите /org."), 1;
        if (gFaction[playerid] == FACTION_POLICE) ShowPoliceMenu(playerid);
        else ShowOrgMenu(playerid);
        return 1;
    }
    if (CommandMatch(cmdtext, "/exitorg"))
    {
        if (gFaction[playerid] == FACTION_NONE || !IsInOwnOrgInterior(playerid))
            return SendClientMessage(playerid, COLOR_RED, "Вы не находитесь в штабе своей организации."), 1;
        new Float:x, Float:y, Float:z;
        GetOrgExterior(gFaction[playerid], x, y, z);
        SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
        SetPlayerPos(playerid, x + 2.0, y, z); SetPlayerFacingAngle(playerid, (gFaction[playerid] == FACTION_FBI) ? 310.92 : 90.0);
        SetCameraBehindPlayer(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "Вы вышли из здания организации.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/orggarage"))
    {
        if (gFaction[playerid] == FACTION_NONE || gFactionRank[playerid] < 1)
            return SendClientMessage(playerid, COLOR_RED, "Вы не состоите в организации."), 1;
        if (!IsInOwnOrgInterior(playerid))
            return SendClientMessage(playerid, COLOR_YELLOW, "Команда доступна изнутри штаба вашей организации."), 1;
        new Float:x, Float:y, Float:z;
        GetOrgGarage(gFaction[playerid], x, y, z);
        SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
        SetPlayerPos(playerid, x - 1.5, y - 2.5, z); SetPlayerFacingAngle(playerid, 90.0);
        SetCameraBehindPlayer(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "Вы вышли к автопарку своей организации. Используйте /garage для служебного транспорта.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/formation") || CommandMatch(cmdtext, "/formup"))
    {
        if (gFaction[playerid] == FACTION_NONE || gFactionRank[playerid] < 6)
            return SendClientMessage(playerid, COLOR_RED, "Построение может объявить сотрудник организации с 6-го ранга."), 1;
        if (!IsInOwnOrgInterior(playerid))
            return SendClientMessage(playerid, COLOR_YELLOW, "Объявлять построение можно из штаба своей организации."), 1;
        new Float:x, Float:y, Float:z, count = 0, factionName[32], msg[144];
        GetPlayerPos(playerid, x, y, z);
        GetFactionName(gFaction[playerid], factionName, sizeof factionName);
        for (new i = 0; i < MAX_PLAYERS; i++)
        {
            if (i == playerid || !IsPlayerConnected(i) || !gLogged[i] || gFaction[i] != gFaction[playerid]) continue;
            if (GetPlayerInterior(i) != GetPlayerInterior(playerid) || GetPlayerVirtualWorld(i) != GetPlayerVirtualWorld(playerid)) continue;
            if (!IsPlayerInRangeOfPoint(i, 35.0, x, y, z)) continue;
            count++;
            SetPlayerPos(i, x + (float(count) * 1.2), y + 2.0, z);
            SetPlayerFacingAngle(i, 180.0);
            SendClientMessage(i, COLOR_YELLOW, "Вас построили. Ожидайте распоряжений руководства.");
        }
        format(msg, sizeof msg, "[Построение] %s: построение объявлено. Сотрудников собрано: %d.", factionName, count + 1);
        SendClientMessage(playerid, COLOR_GREEN, msg);
        return 1;
    }
    if (CommandMatch(cmdtext, "/garage"))
    {
        if (gFaction[playerid] == FACTION_NONE || gFactionRank[playerid] < 1)
            return SendClientMessage(playerid, COLOR_RED, "Вы не состоите в организации."), 1;
        new Float:gx, Float:gy, Float:gz, menu[512], line[80], factionName[32], dialogTitle[64];
        GetOrgGarage(gFaction[playerid], gx, gy, gz);
        if (gFaction[playerid] == FACTION_POLICE)
        {
            if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0 ||
                !IsPlayerInRangeOfPoint(playerid, 10.0, 1568.4843, -1690.4116, 5.8906))
                return SendClientMessage(playerid, COLOR_YELLOW, "\xcf\xee\xe4\xee\xe9\xe4\xe8\xf2\xe5 \xea \xe3\xe0\xf0\xe0\xe6\xf3 \xf1\xe2\xee\xe5\xe9 \xee\xf0\xe3\xe0\xed\xe8\xe7\xe0\xf6\xe8\xe8."), 1;
        }
        else if (!IsPlayerInRangeOfPoint(playerid, 10.0, gx, gy, gz))
            return SendClientMessage(playerid, COLOR_YELLOW, "\xcf\xee\xe4\xee\xe9\xe4\xe8\xf2\xe5 \xea \xe3\xe0\xf0\xe0\xe6\xf3 \xf1\xe2\xee\xe5\xe9 \xee\xf0\xe3\xe0\xed\xe8\xe7\xe0\xf6\xe8\xe8."), 1;
        if (IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_YELLOW, "Сначала выйдите из текущего транспорта."), 1;
        GetFactionName(gFaction[playerid], factionName, sizeof factionName);
        menu[0] = '\0';
        format(dialogTitle, sizeof dialogTitle, "%s | ранг %d", factionName, gFactionRank[playerid]);
        new count = 0, modelName[48];
        for (new tier = 0; tier < 5; tier++)
        {
            if (gFactionRank[playerid] < (tier * 2 + 1)) continue;
            GetFactionVehicleInfo(gFaction[playerid], tier, modelName, sizeof modelName);
            format(line, sizeof line, "%s\n", modelName);
            strcat(menu, line, sizeof menu);
            count++;
        }
        if (count == 0) return SendClientMessage(playerid, COLOR_RED, "У вас нефхатает ранга для автопарка."), 1;
        ShowPlayerDialog(playerid, DIALOG_FACTION_GARAGE, DIALOG_STYLE_LIST, dialogTitle, menu, "Выбрать", "Закрыть");
        return 1;
    }
    if (CommandMatch(cmdtext, "/shopacc"))
    {
        // Phone-style accessories app: available anywhere, no Los Santos location check.
        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
        new shopText[512];
        shopText[0] = '\0';
        strcat(shopText, "КЛАССИКА | Черные очки - 1 500 руб.\n");
        strcat(shopText, "КЛАССИКА | Уличная кепка - 2 500 руб.\n");
        strcat(shopText, "КЛАССИКА | Шапка-бини - 3 500 руб.\n");
        strcat(shopText, "СТИЛЬ | Ковбойская шляпа - 7 500 руб.\n");
        strcat(shopText, "СТИЛЬ | Хоккейная маска - 9 000 руб.\n");
        strcat(shopText, "ПРЕМИУМ | Золотые очки - 15 000 руб.\n");
        strcat(shopText, "ПРЕМИУМ | Дизайнерская кепка - 22 000 руб.\n");
        strcat(shopText, "ЭЛИТА | Роскошная маска - 35 000 руб.\n");
        strcat(shopText, "ЭЛИТА | Бриллиантовый стиль - 55 000 руб.\n");
        strcat(shopText, "VIP | Королевский аксессуар - 85 000 руб.\n");
        strcat(shopText, "Откройте /inv, чтобы надеть или снять");
        ShowPlayerDialog(playerid, DIALOG_SHOP_ACC, DIALOG_STYLE_LIST, "VEXORIUM | Магазин аксессуаров", shopText, "Выбрать", "Закрыть");
        return 1;
    }
    if (CommandMatch(cmdtext, "/lock") || CommandMatch(cmdtext, "/carlock"))
    {
        // Toggle current vehicle when seated; otherwise find the nearest vehicle within 5 metres.
        new lockVehicle = 0;
        if (IsPlayerInAnyVehicle(playerid)) lockVehicle = GetPlayerVehicleID(playerid);
        else
        {
            new Float:distance, Float:bestDistance = 5.0;
            new Float:px, Float:py, Float:pz;
            GetPlayerPos(playerid, px, py, pz);
            for (new v = 1; v < MAX_VEHICLES; v++)
            {
                if (GetVehicleVirtualWorld(v) != GetPlayerVirtualWorld(playerid)) continue;
                new Float:vx, Float:vy, Float:vz;
                GetVehiclePos(v, vx, vy, vz);
                distance = floatsqroot((px-vx)*(px-vx) + (py-vy)*(py-vy) + (pz-vz)*(pz-vz));
                if (distance <= bestDistance) { bestDistance = distance; lockVehicle = v; }
            }
        }
        if (lockVehicle <= 0 || lockVehicle >= MAX_VEHICLES)
            return SendClientMessage(playerid, COLOR_YELLOW, "Рядом нет машины. Подойдите ближе или сядьте в неё."), 1;
        new engine, lights, alarm, doors, bonnet, boot, objective;
        GetVehicleParamsEx(lockVehicle, engine, lights, alarm, doors, bonnet, boot, objective);
        if (doors == VEHICLE_PARAMS_ON)
        {
            SetVehicleParamsEx(lockVehicle, engine, lights, alarm, VEHICLE_PARAMS_OFF, bonnet, boot, objective);
            SendClientMessage(playerid, COLOR_GREEN, "Машина открыта.");
        }
        else
        {
            SetVehicleParamsEx(lockVehicle, engine, lights, alarm, VEHICLE_PARAMS_ON, bonnet, boot, objective);
            SendClientMessage(playerid, COLOR_YELLOW, "Машина заперта.");
        }
        return 1;
    }
    if (CommandMatch(cmdtext, "/engine"))
    {
        if (!IsPlayerInAnyVehicle(playerid) || GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
            return SendClientMessage(playerid, COLOR_YELLOW, "Вы должны сидеть за рулём автомобиля."), 1;
        new vehicleid = GetPlayerVehicleID(playerid);
        if (vehicleid <= 0 || vehicleid >= MAX_VEHICLES) return 1;
        new engine, lights, alarm, doors, bonnet, boot, objective;
        GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
        if (engine == VEHICLE_PARAMS_ON)
        {
            SetVehicleParamsEx(vehicleid, VEHICLE_PARAMS_OFF, lights, alarm, doors, bonnet, boot, objective);
            new stopText[128]; format(stopText, sizeof stopText, "* %s заглушил двигатель.", gName[playerid]);
            SendLocalMessage(playerid, COLOR_PINK, stopText, 20.0);
            SendClientMessage(playerid, COLOR_YELLOW, "Двигатель выключен.");
        }
        else
        {
            if (gVehicleFuel[vehicleid] <= 0) return SendClientMessage(playerid, COLOR_RED, "Нет топлива. Заправьтесь на АЗС командой /fuel."), 1;
            SetVehicleParamsEx(vehicleid, VEHICLE_PARAMS_ON, lights, alarm, doors, bonnet, boot, objective);
            new startText[128]; format(startText, sizeof startText, "* %s повернул ключ зажигания — двигатель завелся.", gName[playerid]);
            SendLocalMessage(playerid, COLOR_PINK, startText, 20.0);
            SendClientMessage(playerid, COLOR_GREEN, "Двигатель завелся.");
        }
        UpdateVexHud(playerid);
        return 1;
    }
    if (CommandMatch(cmdtext, "/carshop"))
    {
        if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0 || !IsPlayerInRangeOfPoint(playerid, 18.0, 2131.0, -1150.0, 24.1))
            return SendClientMessage(playerid, COLOR_YELLOW, "Подойдите к автосалону VEXORIUM в районе Market, Лос-Сантос."), 1;
        ShowPlayerDialog(playerid, DIALOG_CAR_DEALER, DIALOG_STYLE_LIST, "VEXORIUM RP | Автосалон",
            "Bravura — 8 000 руб.\nPerennial — 9 500 руб.\nPrevion — 12 000 руб.\nAdmiral — 18 000 руб.\nTurismo — 45 000 руб.\nSultan — 55 000 руб.", "Купить", "Отмена");
        return 1;
    }
    if (CommandMatch(cmdtext, "/mycar"))
    {
        if (gOwnedCarModel[playerid] == 0) return SendClientMessage(playerid, COLOR_YELLOW, "У вас нет личного автомобиля. Посетите /carshop."), 1;
        if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0 || !IsPlayerInRangeOfPoint(playerid, 35.0, 2131.0, -1150.0, 24.1))
            return SendClientMessage(playerid, COLOR_YELLOW, "Чтобы получить личную машину, подойдите к автосалону."), 1;
        if (IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_YELLOW, "Сначала выйдите из транспорта."), 1;
        if (gOwnedCarVehicle[playerid] != INVALID_VEHICLE_ID && GetVehicleModel(gOwnedCarVehicle[playerid]) != 0)
            return SendClientMessage(playerid, COLOR_GREEN, "Ваш личный автомобиль уже находится в мире."), 1;
        gOwnedCarVehicle[playerid] = CreateVehicle(gOwnedCarModel[playerid], 2137.0, -1155.0, 24.5, 90.0, 1, 1, 300);
        if (gOwnedCarVehicle[playerid] == INVALID_VEHICLE_ID) return SendClientMessage(playerid, COLOR_RED, "Не удалось создать автомобиль."), 1;
        new vid = gOwnedCarVehicle[playerid];
        gPersonalVehicleOwner[vid] = playerid; gVehicleFuel[vid] = 100; gFuelLastX[vid] = 0.0; gFuelLastY[vid] = 0.0; gFuelLastZ[vid] = 0.0;
        PutPlayerInVehicle(playerid, vid, 0);
        SendClientMessage(playerid, COLOR_GREEN, "Ваш личный автомобиль доставлен к автосалону.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/fuel"))
    {
        if (!IsPlayerInAnyVehicle(playerid) || GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
            return SendClientMessage(playerid, COLOR_YELLOW, "Сядьте за руль и остановитесь рядом с колонкой АЗС."), 1;
        if (!IsNearGasStation(playerid)) return SendClientMessage(playerid, COLOR_YELLOW, "Подъедьте к одной из АЗС VEXORIUM и остановитесь у колонки."), 1;
        new vehicleid = GetPlayerVehicleID(playerid);
        if (gVehicleFuel[vehicleid] >= 100) return SendClientMessage(playerid, COLOR_YELLOW, "Бак уже полный."), 1;
        if (!TakeCash(playerid, 300)) return SendClientMessage(playerid, COLOR_RED, "Заправка до полного бака стоит 300 рублей. Недостаточно денег."), 1;
        gVehicleFuel[vehicleid] = 100;
        gFuelLastX[vehicleid] = 0.0; gFuelLastY[vehicleid] = 0.0; gFuelLastZ[vehicleid] = 0.0;
        new engine, lights, alarm, doors, bonnet, boot, objective;
        GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
        SetVehicleParamsEx(vehicleid, 1, lights, alarm, doors, bonnet, boot, objective);
        UpdateVexHud(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "Вы заправили бак до 100% за 300 рублей.");
        return 1;
    }
    if (!strcmp(cmdtext, "/leaders", true))
    {
        new query[256], rowName[MAX_PLAYER_NAME + 1], factionName[32], line[128], found = 0;
        SendClientMessage(playerid, COLOR_YELLOW, "===== Лидеры организаций VEXORIUM RP =====");
        format(query, sizeof query, "SELECT name,faction FROM accounts WHERE faction BETWEEN 1 AND 7 AND faction_rank >= 10 ORDER BY faction");
        new DBResult:leaders = db_query(gDatabase, query);
        if (leaders)
        {
            for (new row = 0; row < db_num_rows(leaders); row++)
            {
                db_get_field(leaders, 0, rowName, sizeof rowName);
                new faction = db_get_field_int(leaders, 1);
                GetFactionName(faction, factionName, sizeof factionName);
                format(line, sizeof line, "%s: %s", factionName, rowName);
                SendClientMessage(playerid, COLOR_WHITE, line); found++;
                db_next_row(leaders);
            }
            db_free_result(leaders);
        }
        if (!found) SendClientMessage(playerid, COLOR_WHITE, "Сейчас лидеры организаций не назначены.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/fullsklads") || CommandMatch(cmdtext, "/fullstocks"))
    {
        if (!IsOwner(playerid) && gAdmin[playerid] < 4) return SendClientMessage(playerid, COLOR_RED, "Команда доступна администраторам 4-го уровня и выше."), 1;
        new DBResult:fillResult;
        for (new stockGang = 1; stockGang <= 4; stockGang++) { new initGang[128]; format(initGang, sizeof initGang, "INSERT OR IGNORE INTO gang_stashes (gang_id,money) VALUES (%d,0)", stockGang); fillResult = db_query(gDatabase, initGang); if (fillResult) db_free_result(fillResult); }
        for (new stockFaction = 1; stockFaction <= 7; stockFaction++) { new initFaction[160]; format(initFaction, sizeof initFaction, "INSERT OR IGNORE INTO org_stashes (faction_id,money,materials,ammo,armour) VALUES (%d,0,0,0,0)", stockFaction); fillResult = db_query(gDatabase, initFaction); if (fillResult) db_free_result(fillResult); }
        fillResult = db_query(gDatabase, "UPDATE gang_stashes SET money=1000000"); if (fillResult) db_free_result(fillResult);
        fillResult = db_query(gDatabase, "UPDATE gang_weapon_stash SET ammo=5000"); if (fillResult) db_free_result(fillResult);
        fillResult = db_query(gDatabase, "UPDATE org_stashes SET money=1000000, materials=10000, ammo=10000, armour=500"); if (fillResult) db_free_result(fillResult);
        SendClientMessage(playerid, COLOR_GREEN, "[VEXORIUM] Склады пополнены: 4 банды и 6 организаций. Оружие/патроны и запасы обновлены.");
        for (new i = 0; i < MAX_PLAYERS; i++) if (IsPlayerConnected(i) && gLogged[i] && gAdmin[i] >= 1 && i != playerid) SendClientMessage(i, COLOR_ORANGE, "[АДМИН] Склады всех банд и организаций были пополнены.");
        return 1;
    }
    if (!strcmp(cmdtext, "/rules", true))
    {
        ShowPlayerDialog(playerid, DIALOG_HELP, DIALOG_STYLE_MSGBOX, "VEXORIUM RP | Правила", "1. Соблюдайте правила RolePlay.\n2. Не используйте читы и сторонние программы.\n3. Не оскорбляйте игроков и администрацию.\n4. Не злоупотребляйте командами и багами.\n5. Слушайте администрацию и уважайте других игроков.", "Понятно", "");
        return 1;
    }
    if (!strcmp(cmdtext, "/gang", true))
    {
        ShowPlayerDialog(playerid, DIALOG_GANG, DIALOG_STYLE_LIST, "VEXORIUM | Уличные банды", "Grove Street Families\nBallas\nLos Santos Vagos\nVarrios Los Aztecas\nПокинуть банду", "Выбрать", "Закрыть");
        return 1;
    }
    if (!strcmp(cmdtext, "/gangskin", true) || !strcmp(cmdtext, "/gangclothes", true))
    {
        if (gGang[playerid] < 1 || gGang[playerid] > 4) return SendClientMessage(playerid, COLOR_RED, "Вы не состоите в банде."), 1;
        new Float:bx, Float:by, Float:bz;
        GetGangBase(gGang[playerid], bx, by, bz);
        if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0 || GetPlayerDistanceFromPoint(playerid, bx, by, bz) > 18.0)
            return SendClientMessage(playerid, COLOR_RED, "Переодеваться можно только в магазине одежды на базе банды."), 1;
        ShowPlayerDialog(playerid, DIALOG_GANG_SKIN, DIALOG_STYLE_LIST, "Магазин одежды банды", "Одежда новичка\nОдежда участника\nОдежда опытного\nОдежда старшего\nОдежда ветерана\nОдежда лидера", "Надеть", "Закрыть");
        return 1;
    }
    if (CommandMatch(cmdtext, "/orgstash"))
    {
        if (gFaction[playerid] < 1 || gFaction[playerid] > 6 || gFactionRank[playerid] < 1)
            return SendClientMessage(playerid, COLOR_RED, "Склад доступен только сотрудникам организации."), 1;
        if (gFaction[playerid] == FACTION_POLICE)
        {
            if (!IsInPoliceStation(playerid) || GetPlayerDistanceFromPoint(playerid, 258.52, 76.8268, 1003.6406) > 5.0)
                return SendClientMessage(playerid, COLOR_RED, "Подойдите к оружейному складу внутри участка LSPD."), 1;
            ShowPlayerDialog(playerid, DIALOG_POLICE_STASH, DIALOG_STYLE_LIST, "LSPD | Оружейный склад", "\xc4\xf3\xe1\xe8\xed\xea\xe0 (1)\nM4 и патроны (до 100)\nПистолет и патроны (до 100)\nБронежилет", "Взять", "Закрыть");
            return 1;
        }
        if (GetPlayerInterior(playerid) == 0 || !IsInOwnOrgInterior(playerid))
            return SendClientMessage(playerid, COLOR_RED, "Откройте склад внутри штаба своей организации."), 1;
        ShowPlayerDialog(playerid, DIALOG_ORG_STASH, DIALOG_STYLE_LIST, "Склад организации", "Взять M4 (до 100 патронов)\nВзять пистолет (до 100 патронов)\nПолучить бронежилет\nПосмотреть запасы", "Выбрать", "Закрыть");
        return 1;
    }
    if (!strcmp(cmdtext, "/gangstash", true))
    {
        if (gGang[playerid] < 1 || gGang[playerid] > 4)
            return SendClientMessage(playerid, COLOR_RED, "Вы не состоите в банде."), 1;
        new Float:bx, Float:by, Float:bz;
        GetGangBase(gGang[playerid], bx, by, bz);
        if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0 || GetPlayerDistanceFromPoint(playerid, bx, by, bz) > 12.0)
            return SendClientMessage(playerid, COLOR_RED, "Склад доступен только на базе вашей банды."), 1;
        ShowPlayerDialog(playerid, DIALOG_GANG_STASH, DIALOG_STYLE_LIST, "Склад банды", "Положить деньги\nСнять деньги\nБаланс склада\nОружие и патроны", "Выбрать", "Закрыть");
        return 1;
    }
    if (!strcmp(cmdtext, "/gps", true))
    {
        ShowGPS(playerid);
        return 1;
    }
    if (!strcmp(cmdtext, "/job", true) || !strcmp(cmdtext, "/работа", true))
    {
        if (!gHasPassport[playerid]) return SendClientMessage(playerid, COLOR_RED, "Для устройства на работу сначала получите паспорт в мэрии."), 1;
        ShowPlayerDialog(playerid, DIALOG_JOB, DIALOG_STYLE_LIST, "VEXORIUM RP | Работа",
            "Таксист — до 3500 руб. за маршрут\nДальнобойщик — до 5000 руб. за маршрут\nВодитель автобуса — до 4200 руб. за маршрут\nШахтёр — до 6000 руб. за смену\nАвтоугонщик — от 100000 руб. за машину (с 3 уровня)", "Выбрать", "Закрыть");
        return 1;
    }
    if (!strcmp(cmdtext, "/work", true) || !strcmp(cmdtext, "/работать", true))
    {
        if (!gHasPassport[playerid]) return SendClientMessage(playerid, COLOR_RED, "Для работы нужен паспорт. Получите его в мэрии."), 1;
        if (gJob[playerid] == 5) return StartCarjack(playerid);
        return StartWorkRoute(playerid);
    }
    if (CommandMatch(cmdtext, "/hack"))
    {
        if (!gCarjackActive[playerid] || gWorkStage[playerid] != 10 || gCarjackUnlocked[playerid])
            return SendClientMessage(playerid, COLOR_YELLOW, "Сейчас вам нечего взламывать."), 1;
        if (gCarjackVehicle[playerid] == INVALID_VEHICLE_ID || GetVehicleModel(gCarjackVehicle[playerid]) == 0)
            return SendClientMessage(playerid, COLOR_RED, "Машина-цель пропала. Отмените работу через /stopwork."), 1;
        new Float:x, Float:y, Float:z;
        GetVehiclePos(gCarjackVehicle[playerid], x, y, z);
        if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0 || GetPlayerDistanceFromPoint(playerid, x, y, z) > 5.0)
            return SendClientMessage(playerid, COLOR_YELLOW, "Подойдите к машине не дальше 5 метров."), 1;
        ShowPlayerDialog(playerid, DIALOG_CARJACK_HACK, DIALOG_STYLE_LIST, "VEXORIUM | Взлом замка", "Красный провод\nСиний провод\nЗелёный провод\nЖёлтый провод", "Подключить", "Отмена");
        SendClientMessage(playerid, COLOR_YELLOW, "Мини-игра: выберите правильный провод. Ошибка сбросит попытку — можно попробовать снова.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/accept"))
    {
        if (gFaction[playerid] == FACTION_HOSPITAL)
        {
            if (gMedicPending[playerid] <= 0)
                return SendClientMessage(playerid, COLOR_YELLOW, "No active hospital calls."), 1;
            new patient = gMedicPending[playerid] - 1;
            if (!IsPlayerConnected(patient) || !gNeedsMedicalHelp[patient])
            {
                gMedicPending[playerid] = 0;
                return SendClientMessage(playerid, COLOR_YELLOW, "Call is finished or player unavailable."), 1;
            }
            gMedicPending[playerid] = 0;
            if (gDeathTimer[patient]) { KillTimer(gDeathTimer[patient]); gDeathTimer[patient] = 0; }
            SetPlayerInterior(patient, 0);
            SetPlayerVirtualWorld(patient, 0);
            new skin = gDeathSkin[patient];
            if (skin < 0 || skin > 311) skin = 23;
            SetSpawnInfo(patient, 0, skin, gDeathX[patient], gDeathY[patient], gDeathZ[patient] + 0.5, 0.0, 0, 0, 0, 0, 0, 0);
            SpawnPlayer(patient);
            SetPlayerSkin(patient, skin);
            SetPlayerInterior(patient, 0);
            SetPlayerVirtualWorld(patient, 0);
            SetPlayerPos(patient, gDeathX[patient], gDeathY[patient], gDeathZ[patient] + 0.5);
            SetPlayerHealth(patient, 50.0);
            SetCameraBehindPlayer(patient);
            gNeedsMedicalHelp[patient] = false;
            SendClientMessage(patient, COLOR_GREEN, "Medic helped you. You regained consciousness.");
            SendClientMessage(playerid, COLOR_GREEN, "Call accepted: patient has been helped.");
            return 1;
        }
        if (gFaction[playerid] != FACTION_POLICE && gFaction[playerid] != FACTION_FBI)
            return SendClientMessage(playerid, COLOR_RED, "Принять преследование могут только полиция и FBI."), 1;
        if (gCarjackPending[playerid] <= 0) return SendClientMessage(playerid, COLOR_YELLOW, "Нет активного вызова на автоугон."), 1;
        new target = gCarjackPending[playerid] - 1;
        if (!IsPlayerConnected(target) || !gCarjackActive[target]) { gCarjackPending[playerid] = 0; return SendClientMessage(playerid, COLOR_RED, "Вызов уже завершён."), 1; }
        gCarjackPending[playerid] = 0;
        gPursuitTarget[playerid] = target;
        new Float:x, Float:y, Float:z;
        if (IsPlayerInAnyVehicle(target)) GetVehiclePos(GetPlayerVehicleID(target), x, y, z);
        else GetPlayerPos(target, x, y, z);
        SetPlayerMapIcon(playerid, 49, x, y, z, 0, 0, MAPICON_GLOBAL);
        SetPlayerCheckpoint(playerid, x, y, z, 8.0);
        RefreshCarjackPursuits();
        SendClientMessage(playerid, COLOR_GREEN, "Вы приняли вызов. На радаре отмечено последнее местоположение автоугонщика.");
        SendClientMessage(target, COLOR_RED, "Полиция/FBI приняли вызов и начали преследование!");
        return 1;
    }
    if (CommandMatch(cmdtext, "/cancel"))
    {
        if (gFaction[playerid] == FACTION_HOSPITAL)
        {
            if (gMedicPending[playerid] <= 0) return SendClientMessage(playerid, COLOR_YELLOW, "No active calls."), 1;
            gMedicPending[playerid] = 0;
            SendClientMessage(playerid, COLOR_YELLOW, "Hospital call declined.");
            return 1;
        }
        if (gFaction[playerid] != FACTION_POLICE && gFaction[playerid] != FACTION_FBI)
            return SendClientMessage(playerid, COLOR_RED, "Отменить вызов могут только полиция и FBI."), 1;
        if (gCarjackPending[playerid] <= 0) return SendClientMessage(playerid, COLOR_YELLOW, "Нет активного вызова."), 1;
        gCarjackPending[playerid] = 0;
        SendClientMessage(playerid, COLOR_YELLOW, "Вы отказались от преследования автоугонщика.");
        return 1;
    }
    if (!strcmp(cmdtext, "/stopwork", true))
    {
        if (gWorkStage[playerid] == 0) SendClientMessage(playerid, COLOR_YELLOW, "[VEXORIUM] Вы сейчас не выполняете работу.");
        else
        {
            gWorkStage[playerid] = 0;
            if (gCarjackActive[playerid])
            {
                if (gCarjackVehicle[playerid] != INVALID_VEHICLE_ID && GetVehicleModel(gCarjackVehicle[playerid]) != 0) DestroyVehicle(gCarjackVehicle[playerid]);
                gCarjackVehicle[playerid] = INVALID_VEHICLE_ID;
                gCarjackActive[playerid] = false;
                gCarjackUnlocked[playerid] = false;
                RemovePlayerMapIcon(playerid, 48);
            }
            DisablePlayerCheckpoint(playerid);
            if (gWorkVehicle[playerid] != INVALID_VEHICLE_ID && GetVehicleModel(gWorkVehicle[playerid]) != 0)
            {
                if (IsPlayerInAnyVehicle(playerid) && GetPlayerVehicleID(playerid) == gWorkVehicle[playerid]) RemovePlayerFromVehicle(playerid);
                DestroyVehicle(gWorkVehicle[playerid]);
            }
            gWorkVehicle[playerid] = INVALID_VEHICLE_ID;
            SendClientMessage(playerid, COLOR_ORANGE, "[VEXORIUM] Рабочий маршрут отменён, рабочий транспорт возвращён.");
        }
        return 1;
    }
    if (CommandMatch(cmdtext, "/inv") || CommandMatch(cmdtext, "/inventory") || CommandMatch(cmdtext, "/инвентарь"))
    {
        new text[256];
        format(text, sizeof text, "VEXORIUM RP INVENTORY\nMedkits: %d\nFood: %d\nWater: %d\nRepair kits: %d\nSIM cards: %d\nLockpicks: %d\nUse /repairkit in a vehicle, /usesim, /work for car theft.", gMedkits[playerid], gFood[playerid], gWater[playerid], gRepairKits[playerid], gSimCards[playerid], gLockpicks[playerid]);
        ShowPlayerDialog(playerid, DIALOG_ITEM_INVENTORY, DIALOG_STYLE_LIST, "VEXORIUM | Инвентарь", "Использовать аптечку\nСъесть еду\nВыпить воду\nМагазин аксессуаров\nНадеть аксессуар\nСнять аксессуар", "Выбрать", "Закрыть");
        SendClientMessage(playerid, COLOR_YELLOW, text);
        return 1;
    }
    if (CommandMatch(cmdtext, "/phone") || CommandMatch(cmdtext, "/telefon"))
    {
        ShowPlayerDialog(playerid, DIALOG_PHONE, DIALOG_STYLE_LIST, "VEXORIUM | Телефон", "Отправить SMS\nСмотреть место на карте (GPS)\nВызвать полицию\nВызвать скорую помощь\nМой ID и номер", "Открыть", "Закрыть");
        return 1;
    }
    if (CommandMatch(cmdtext, "/repairkit"))
    {
        if (gRepairKits[playerid] < 1) return SendClientMessage(playerid, COLOR_RED, "[INV] Net remontnogo komplekta. Kupite ego v /shop."), 1;
        if (!IsPlayerInAnyVehicle(playerid) || GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendClientMessage(playerid, COLOR_YELLOW, "[INV] Nuzhno sidet za rulem mashiny."), 1;
        new repairVehicle = GetPlayerVehicleID(playerid); RepairVehicle(repairVehicle); SetVehicleHealth(repairVehicle, 1000.0);
        gRepairKits[playerid]--; SavePlayer(playerid);
        return SendClientMessage(playerid, COLOR_GREEN, "[INV] Mashina otremontirovana. Remkomplekt ispolzovan."), 1;
    }
    if (CommandMatch(cmdtext, "/usesim"))
    {
        if (gSimCards[playerid] < 1) return SendClientMessage(playerid, COLOR_RED, "[INV] Net SIM-karty. Kupite ee v /shop."), 1;
        gSimCards[playerid]--; SavePlayer(playerid);
        return SendClientMessage(playerid, COLOR_GREEN, "[PHONE] SIM-karta aktivirovana."), 1;
    }
    if (CommandMatch(cmdtext, "/shop") || CommandMatch(cmdtext, "/store"))
    {
        ShowPlayerDialog(playerid, DIALOG_SHOP, DIALOG_STYLE_LIST, "VEXORIUM | Магазин предметов", "Аптечка здоровья - 750 руб.\nЕда - 150 руб.\nВода - 100 руб.\nБукет: еда + вода - 200 руб.\n\xd0\xe5\xec\xee\xed\xf2\xed\xfb\xe9 \xea\xee\xec\xef\xeb\xe5\xea\xf2 - 2 000 \xf0\xf3\xe1.\nSIM-\xea\xe0\xf0\xf2\xe0 - 1 000 \xf0\xf3\xe1.\n\xce\xf2\xec\xfb\xf7\xea\xe0 \xe4\xeb\xff \xe0\xe2\xf2\xee\xf3\xe3\xee\xed\xe0 - 5 000 \xf0\xf3\xe1.", "Купить", "Закрыть");
        return 1;
    }
    if (!strcmp(cmdtext, "/balance", true) || !strcmp(cmdtext, "/баланс", true))
    {
        new msg[96];
        format(msg, sizeof msg, "[VEXORIUM] На вашем счету: %d рублей.", gMoney[playerid]);
        SendClientMessage(playerid, COLOR_GREEN, msg);
        return 1;
    }
    if (!strcmp(cmdtext, "/stats", true) || !strcmp(cmdtext, "/статистика", true))
    {
        new text[384];
        new jobName[32], factionName[32], factionRankName[48];
        if (gJob[playerid] == 1) format(jobName, sizeof jobName, "Таксист");
        else if (gJob[playerid] == 2) format(jobName, sizeof jobName, "Дальнобойщик");
        else if (gJob[playerid] == 3) format(jobName, sizeof jobName, "Автобусник");
        else if (gJob[playerid] == 4) format(jobName, sizeof jobName, "Шахтёр");
        else format(jobName, sizeof jobName, "Нет");
        GetFactionName(gFaction[playerid], factionName, sizeof factionName);
        GetFactionRankName(gFaction[playerid], gFactionRank[playerid], factionRankName, sizeof factionRankName);
        format(text, sizeof text, "Имя: %s\nУровень: %d\nДеньги: %d руб.\nУбийств: %d\nСмертей: %d\nРабота: %s\nФракция: %s\nРанг: %s (%d)\nБанда: %d\nАдмин-уровень: %d", gName[playerid], gLevel[playerid], gMoney[playerid], gKills[playerid], gDeaths[playerid], jobName, factionName, factionRankName, gFactionRank[playerid], gGang[playerid], gAdmin[playerid]);
        ShowPlayerDialog(playerid, DIALOG_HELP, DIALOG_STYLE_MSGBOX, "VEXORIUM RP | Статистика", text, "Закрыть", "");
        return 1;
    }
    if (!strcmp(cmdtext, "/save", true))
    {
        SavePlayer(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "[VEXORIUM] Прогресс сохранён.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/pay"))
    {
        new params[96], token[32], token2[32], targetid, amount, msg[128];
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, token, sizeof token) || !GetToken(params, 1, token2, sizeof token2))
            return SendClientMessage(playerid, COLOR_YELLOW, "Использование: /pay [ID] [сумма]"), 1;
        targetid = strval(token); amount = strval(token2);
        if (targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid) || !gLogged[targetid]) return SendClientMessage(playerid, COLOR_RED, "Игрок не найден или не вошёл в аккаунт."), 1;
        if (targetid == playerid || amount <= 0 || amount > 10000000) return SendClientMessage(playerid, COLOR_RED, "Укажите другого игрока и сумму от 1 до 10000000."), 1;
        if (!TakeCash(playerid, amount)) return SendClientMessage(playerid, COLOR_RED, "Недостаточно денег."), 1;
        if (!GiveCash(targetid, amount)) { GiveCash(playerid, amount); return SendClientMessage(playerid, COLOR_RED, "У получателя достигнут лимит денег."), 1; }
        format(msg, sizeof msg, "Вы передали %s %d рублей.", gName[targetid], amount); SendClientMessage(playerid, COLOR_GREEN, msg);
        format(msg, sizeof msg, "%s передал вам %d рублей.", gName[playerid], amount); SendClientMessage(targetid, COLOR_GREEN, msg);
        SavePlayer(playerid); SavePlayer(targetid);
        return 1;
    }
    if (CommandMatch(cmdtext, "/tp") || CommandMatch(cmdtext, "/goto"))
    {
        new params[64], token[32], targetid;
        if (gAdmin[playerid] < 1) return SendClientMessage(playerid, COLOR_RED, "Недостаточно прав."), 1;
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, token, sizeof token)) return SendClientMessage(playerid, COLOR_YELLOW, "Использование: /tp [ID игрока]"), 1;
        targetid = strval(token);
        if (targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid) || !gLogged[targetid]) return SendClientMessage(playerid, COLOR_RED, "Игрок не найден или не вошёл в аккаунт."), 1;
        new Float:x, Float:y, Float:z;
        GetPlayerPos(targetid, x, y, z);
        if (IsPlayerInAnyVehicle(playerid)) SetVehiclePos(GetPlayerVehicleID(playerid), x + 2.0, y, z);
        else SetPlayerPos(playerid, x + 1.0, y, z);
        SetPlayerInterior(playerid, GetPlayerInterior(targetid));
        SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(targetid));
        SendClientMessage(playerid, COLOR_GREEN, "[VEXORIUM] Вы телепортированы к игроку.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/gethere"))
    {
        new params[64], token[32], targetid;
        if (gAdmin[playerid] < 1) return SendClientMessage(playerid, COLOR_RED, "Недостаточно прав."), 1;
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, token, sizeof token)) return SendClientMessage(playerid, COLOR_YELLOW, "Использование: /gethere [ID игрока]"), 1;
        targetid = strval(token);
        if (targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid) || !gLogged[targetid]) return SendClientMessage(playerid, COLOR_RED, "Игрок не найден или не вошёл в аккаунт."), 1;
        new Float:x, Float:y, Float:z;
        GetPlayerPos(playerid, x, y, z);
        SetPlayerInterior(targetid, GetPlayerInterior(playerid));
        SetPlayerVirtualWorld(targetid, GetPlayerVirtualWorld(playerid));
        if (IsPlayerInAnyVehicle(targetid)) SetVehiclePos(GetPlayerVehicleID(targetid), x + 2.0, y, z);
        else SetPlayerPos(targetid, x + 1.0, y, z);
        SendClientMessage(targetid, COLOR_ORANGE, "[VEXORIUM] Администратор телепортировал вас к себе.");
        SendClientMessage(playerid, COLOR_GREEN, "[VEXORIUM] Игрок телепортирован к вам.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/tpcar"))
    {
        new params[64], token[32], targetid;
        if (gAdmin[playerid] < 1) return SendClientMessage(playerid, COLOR_RED, "Недостаточно прав."), 1;
        if (!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_YELLOW, "Сначала сядьте в транспорт."), 1;
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, token, sizeof token)) return SendClientMessage(playerid, COLOR_YELLOW, "Использование: /tpcar [ID игрока]"), 1;
        targetid = strval(token);
        if (targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid) || !gLogged[targetid]) return SendClientMessage(playerid, COLOR_RED, "Игрок не найден или не вошёл в аккаунт."), 1;
        new Float:x, Float:y, Float:z;
        GetPlayerPos(targetid, x, y, z);
        SetVehiclePos(GetPlayerVehicleID(playerid), x + 3.0, y, z);
        SetPlayerInterior(playerid, GetPlayerInterior(targetid));
        SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(targetid));
        SendClientMessage(playerid, COLOR_GREEN, "[VEXORIUM] Ваш транспорт телепортирован к игроку.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/setadmin"))
    {
        new params[96], token[32], token2[32], targetid, level;
        if (gAdmin[playerid] < 5) return SendClientMessage(playerid, COLOR_RED, "Недостаточно прав."), 1;
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, token, sizeof token) || !GetToken(params, 1, token2, sizeof token2)) return SendClientMessage(playerid, COLOR_YELLOW, "Использование: /setadmin [ID] [0-5]"), 1;
        targetid = strval(token); level = strval(token2);
        if (targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid) || !gLogged[targetid] || level < 0 || level > 5) return SendClientMessage(playerid, COLOR_RED, "Неверный ID или уровень."), 1;
        gAdmin[targetid] = level;
        new query[160];
        format(query, sizeof query, "UPDATE accounts SET admin=%d WHERE name='%q'", level, gName[targetid]);
        gResult = db_query(gDatabase, query); if (gResult) db_free_result(gResult);
        SendClientMessage(targetid, COLOR_GREEN, "[VEXORIUM] Ваш уровень администратора изменён.");
        SendClientMessage(playerid, COLOR_GREEN, "[VEXORIUM] Уровень администратора изменён.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/setmoney"))
    {
        new params[96], token[32], token2[32], targetid, amount, query[160];
        if (gAdmin[playerid] < 5) return SendClientMessage(playerid, COLOR_RED, "Недостаточно прав."), 1;
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, token, sizeof token) || !GetToken(params, 1, token2, sizeof token2)) return SendClientMessage(playerid, COLOR_YELLOW, "Использование: /setmoney [ID] [сумма]"), 1;
        targetid = strval(token); amount = strval(token2);
        if (targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid) || !gLogged[targetid] || amount < 0 || amount > MAX_MONEY) return SendClientMessage(playerid, COLOR_RED, "Неверный ID или сумма."), 1;
        gMoney[targetid] = amount; ResetPlayerMoney(targetid); GivePlayerMoney(targetid, amount);
        format(query, sizeof query, "UPDATE accounts SET money=%d WHERE name='%q'", amount, gName[targetid]);
        gResult = db_query(gDatabase, query); if (gResult) db_free_result(gResult);
        SendClientMessage(targetid, COLOR_GREEN, "[VEXORIUM] Администратор изменил ваш баланс.");
        SendClientMessage(playerid, COLOR_GREEN, "[VEXORIUM] Баланс игрока изменён.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/setfaction"))
    {
        new params[96], tok1[24], tok2[24], tok3[24], targetid, faction, rank, query[192], msg[160], factionName[32], rankName[48];
        if (gAdmin[playerid] < 3) return SendClientMessage(playerid, COLOR_RED, "Команда доступна с 3-го уровня администратора."), 1;
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, tok1, sizeof tok1) || !GetToken(params, 1, tok2, sizeof tok2) || !GetToken(params, 2, tok3, sizeof tok3)) return SendClientMessage(playerid, COLOR_YELLOW, "Использование: /setfaction [ID] [0-6] [ранг 0-10]"), 1;
        targetid = strval(tok1); faction = strval(tok2); rank = strval(tok3);
        if (targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid) || !gLogged[targetid] || faction < 0 || faction > 7 || rank < 0 || rank > 10 || (faction == 0 && rank != 0) || (faction > 0 && rank < 1)) return SendClientMessage(playerid, COLOR_RED, "Неверный ID, фракция или ранг."), 1;
        gFaction[targetid] = faction; gFactionRank[targetid] = rank;
        UpdatePlayerRoleColor(targetid);
        UpdateVexHud(targetid);
        new rankSkin = 23;
        if (faction >= FACTION_CITYHALL && faction <= FACTION_FBI) rankSkin = GetFactionSkin(faction, rank);
        SetPlayerSkin(targetid, rankSkin);
        format(query, sizeof query, "UPDATE accounts SET faction=%d,faction_rank=%d,skin=%d WHERE name='%q'", faction, rank, rankSkin, gName[targetid]);
        gResult = db_query(gDatabase, query); if (gResult) db_free_result(gResult);
        GetFactionName(faction, factionName, sizeof factionName); GetFactionRankName(faction, rank, rankName, sizeof rankName);
        format(msg, sizeof msg, "Ваша фракция: %s. Ранг: %s (%d).", factionName, rankName, rank); SendClientMessage(targetid, COLOR_GREEN, msg);
        SendClientMessage(playerid, COLOR_GREEN, "Фракция и ранг игрока обновлены.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/uniform"))
    {
        new params[64], tok1[24], tok2[24], targetid, faction, skin, query[192], msg[128];
        if (gAdmin[playerid] < 3) return SendClientMessage(playerid, COLOR_RED, "Команда доступна с 3-го уровня администратора."), 1;
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, tok1, sizeof tok1) || !GetToken(params, 1, tok2, sizeof tok2)) return SendClientMessage(playerid, COLOR_YELLOW, "Использование: /uniform [ID] [1=мэрия, 2=полиция, 3=больница, 4=армия, 5=ВМФ, 6=ВВС]"), 1;
        targetid = strval(tok1); faction = strval(tok2);
        if (targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid) || !gLogged[targetid] || faction < 1 || faction > 7) return SendClientMessage(playerid, COLOR_RED, "Неверный ID или тип формы."), 1;
        if (gFaction[targetid] != faction) { gFaction[targetid] = faction; gFactionRank[targetid] = 1; }
        else if (gFactionRank[targetid] < 1) gFactionRank[targetid] = 1;
        UpdatePlayerRoleColor(targetid);
        skin = GetFactionSkin(faction, gFactionRank[targetid]);
        SetPlayerSkin(targetid, skin);
        format(query, sizeof query, "UPDATE accounts SET skin=%d,faction=%d,faction_rank=%d WHERE name='%q'", skin, gFaction[targetid], gFactionRank[targetid], gName[targetid]);
        gResult = db_query(gDatabase, query); if (gResult) db_free_result(gResult);
        new factionName[32];
        GetFactionName(faction, factionName, sizeof factionName);
        format(msg, sizeof msg, "Администратор выдал вам форму: %s (скин %d).", factionName, skin);
        SendClientMessage(targetid, COLOR_GREEN, msg); SendClientMessage(playerid, COLOR_GREEN, "Форма по вашему рангу выдана и сохранена.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/enterpd") || CommandMatch(cmdtext, "/policeenter"))
    {
        SendClientMessage(playerid, COLOR_YELLOW, "Вход в участок только через маркер у двери. Команда не телепортирует.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/exitpd") || (!strcmp(cmdtext, "/exit", true) && IsInPoliceStation(playerid)))
    {
        if (!IsInPoliceStation(playerid)) return SendClientMessage(playerid, COLOR_YELLOW, "Вы не в полицейском участке."), 1;
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        SetPlayerPos(playerid, 1547.0, -1678.8352, 14.9453);
        SetPlayerFacingAngle(playerid, 270.41);
        SetCameraBehindPlayer(playerid);
        return 1;
    }
    if (CommandMatch(cmdtext, "/duty"))
    {
        return SendClientMessage(playerid, COLOR_YELLOW, "Переодевание теперь доступно через маркер раздевалки внутри штаба. Встаньте на значок одежды."), 1;
    }
    if (CommandMatch(cmdtext, "/fine"))
    {
        new params[96], idToken[16], amountToken[16], targetid, amount, Float:px, Float:py, Float:pz, msg[160];
        if (gFaction[playerid] != FACTION_POLICE || gFactionRank[playerid] < 2)
            return SendClientMessage(playerid, COLOR_RED, "Штрафы может выписывать только сотрудник полиции со 2-го ранга."), 1;
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, idToken, sizeof idToken) || !GetToken(params, 1, amountToken, sizeof amountToken))
            return SendClientMessage(playerid, COLOR_YELLOW, "Использование: /fine [ID] [сумма от 1 до 100000]"), 1;
        targetid = strval(idToken);
        amount = strval(amountToken);
        if (targetid < 0 || targetid >= MAX_PLAYERS || targetid == playerid || !IsPlayerConnected(targetid) || !gLogged[targetid])
            return SendClientMessage(playerid, COLOR_RED, "Игрок не найден или не вошёл в аккаунт."), 1;
        if (amount < 1 || amount > 100000)
            return SendClientMessage(playerid, COLOR_RED, "Сумма штрафа должна быть от 1 до 100000 рублей."), 1;
        GetPlayerPos(playerid, px, py, pz);
        if (GetPlayerInterior(playerid) != GetPlayerInterior(targetid) || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(targetid) || !IsPlayerInRangeOfPoint(targetid, 5.0, px, py, pz))
            return SendClientMessage(playerid, COLOR_RED, "Игрок должен находиться рядом с вами (не дальше 5 метров)."), 1;
        if (gMoney[targetid] < amount)
            return SendClientMessage(playerid, COLOR_RED, "У игрока недостаточно наличных для оплаты штрафа."), 1;
        TakeCash(targetid, amount);
        SavePlayer(targetid);
        format(msg, sizeof msg, "Вы выписали игроку %s (ID %d) штраф на %d рублей.", gName[targetid], targetid, amount);
        SendClientMessage(playerid, COLOR_GREEN, msg);
        format(msg, sizeof msg, "Сотрудник полиции %s выписал вам штраф на %d рублей.", gName[playerid], amount);
        SendClientMessage(targetid, COLOR_RED, msg);
        SendClientMessage(targetid, COLOR_YELLOW, "Если вы не согласны со штрафом, обратитесь к администрации сервера.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/arrest"))
    {
        new params[64], tok1[24], tok2[24], targetid, seconds;
        if (gFaction[playerid] != FACTION_POLICE || gFactionRank[playerid] < 2)
            return SendClientMessage(playerid, COLOR_RED, "Арест доступен сотрудникам полиции со 2-го ранга."), 1;
        if (!IsInPoliceStation(playerid)) return SendClientMessage(playerid, COLOR_YELLOW, "Арест оформляется в участке. Войдите через /enterpd."), 1;
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, tok1, sizeof tok1) || !GetToken(params, 1, tok2, sizeof tok2))
            return SendClientMessage(playerid, COLOR_YELLOW, "Использование: /arrest [ID] [секунды 10-600]"), 1;
        targetid = strval(tok1); seconds = strval(tok2);
        if (targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid) || !gLogged[targetid] || targetid == playerid)
            return SendClientMessage(playerid, COLOR_RED, "Игрок не найден."), 1;
        if (!IsInPoliceStation(targetid))
            return SendClientMessage(playerid, COLOR_RED, "Игрок должен находиться внутри участка."), 1;
        new Float:officerX, Float:officerY, Float:officerZ;
        GetPlayerPos(playerid, officerX, officerY, officerZ);
        if (!IsPlayerInRangeOfPoint(targetid, 4.0, officerX, officerY, officerZ))
            return SendClientMessage(playerid, COLOR_RED, "Подойдите к задерживаемому игроку ближе (до 4 метров)."), 1;
        if (gIsJailed[targetid]) return SendClientMessage(playerid, COLOR_YELLOW, "Игрок уже находится в КПЗ."), 1;
        if (seconds < 10 || seconds > 600) return SendClientMessage(playerid, COLOR_YELLOW, "Срок должен быть от 10 до 600 секунд."), 1;
        gIsJailed[targetid] = true;
        if (IsPlayerInAnyVehicle(targetid)) RemovePlayerFromVehicle(targetid);
        SetPlayerInterior(targetid, 6);
        SetPlayerVirtualWorld(targetid, 0);
        SetPlayerPos(targetid, 264.4, 77.5, 1001.0);
        SetPlayerFacingAngle(targetid, 90.0);
        SetCameraBehindPlayer(targetid);
        gJailTimer[targetid] = SetTimerEx("ReleaseJailedPlayer", seconds * 1000, false, "i", targetid);
        new msg[144];
        format(msg, sizeof msg, "Вы оформили арест игрока %s на %d секунд.", gName[targetid], seconds);
        SendClientMessage(playerid, COLOR_GREEN, msg);
        format(msg, sizeof msg, "Вы задержаны сотрудником полиции. Срок: %d секунд.", seconds);
        SendClientMessage(targetid, COLOR_RED, msg);
        return 1;
    }
    if (CommandMatch(cmdtext, "/release"))
    {
        new params[32], token[24], targetid;
        if (gFaction[playerid] != FACTION_POLICE || gFactionRank[playerid] < 3)
            return SendClientMessage(playerid, COLOR_RED, "Освободить заключённого может полиция с 3-го ранга."), 1;
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, token, sizeof token)) return SendClientMessage(playerid, COLOR_YELLOW, "Использование: /release [ID]"), 1;
        targetid = strval(token);
        if (targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid) || !gIsJailed[targetid])
            return SendClientMessage(playerid, COLOR_RED, "Игрок не найден в КПЗ."), 1;
        if (gJailTimer[targetid]) KillTimer(gJailTimer[targetid]);
        gJailTimer[targetid] = 0;
        gIsJailed[targetid] = false;
        SetPlayerInterior(targetid, 0);
        SetPlayerVirtualWorld(targetid, 0);
        SetPlayerPos(targetid, 1540.8, -1675.5, 13.55);
        SetCameraBehindPlayer(targetid);
        SendClientMessage(targetid, COLOR_GREEN, "Вы освобождены из КПЗ.");
        SendClientMessage(playerid, COLOR_GREEN, "Заключённый освобождён.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/policetablet") || CommandMatch(cmdtext, "/kpp"))
    {
        if (gFaction[playerid] != FACTION_POLICE || gFactionRank[playerid] < 1)
            return SendClientMessage(playerid, COLOR_RED, "Полицейский планшет доступен только сотрудникам Полиции."), 1;
        ShowPlayerDialog(playerid, DIALOG_POLICE_TABLET, DIALOG_STYLE_LIST,
            "VEXORIUM | Полицейский планшет",
            "Список розыска и переследование\nОбъявить в розыск: /wanted [ID] [0-6]\nНаручники: /cuff [ID] /uncuff [ID]\nОтследить игрока: /pursuit [ID]",
            "Выбрать", "Закрыть");
        return 1;
    }
    if (CommandMatch(cmdtext, "/sobescr"))
    {
        if (gFaction[playerid] < FACTION_CITYHALL || gFaction[playerid] > FACTION_FBI || gFactionRank[playerid] < 9)
            return SendClientMessage(playerid, COLOR_RED, "Начиная с 9 ранга в своей организации или выше, чтобы проводить собеседование."), 1;
        if (gInterviewActive || gInterviewTimer != 0)
            return SendClientMessage(playerid, COLOR_RED, "Собеседование уже идёт. Дождитесь его окончания."), 1;
        gInterviewActive = true;
        gInterviewFaction = gFaction[playerid];
        InterviewAnnouncement();
        gInterviewTimer = SetTimer("InterviewAnnouncement", 900000, true);
        return 1;
    }
    if (CommandMatch(cmdtext, "/sobesstop"))
    {
        if (gFaction[playerid] < FACTION_CITYHALL || gFaction[playerid] > FACTION_FBI || gFactionRank[playerid] < 9)
            return SendClientMessage(playerid, COLOR_RED, "Нужен 9-й ранг в своей организации или выше, чтобы остановить собеседование."), 1;
        if (!gInterviewActive || gInterviewFaction != gFaction[playerid])
            return SendClientMessage(playerid, COLOR_RED, "В вашей организации сейчас нет действующего собеседования."), 1;
        if (gInterviewTimer != 0) KillTimer(gInterviewTimer);
        gInterviewTimer = 0;
        gInterviewActive = false;
        SendClientMessageToAll(COLOR_BLUE, "Собеседование отменено." );
        return 1;
    }
    if (CommandMatch(cmdtext, "/pdocs") || CommandMatch(cmdtext, "/policedocs") || CommandMatch(cmdtext, "/udost"))
    {
        if (gFaction[playerid] != FACTION_POLICE || gFactionRank[playerid] < 1)
            return SendClientMessage(playerid, COLOR_RED, "На данную команду могут использовать только сотрудники полиции."), 1;
        new params[32], token[16], targetid;
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, token, sizeof token))
            return SendClientMessage(playerid, COLOR_YELLOW, "Использование: /pdocs [ID]"), 1;
        targetid = strval(token);
        if (targetid < 0 || targetid >= MAX_PLAYERS || targetid == playerid || !IsPlayerConnected(targetid) || !gLogged[targetid])
            return SendClientMessage(playerid, COLOR_RED, "Игрок не найден."), 1;
        if (GetPlayerInterior(playerid) != GetPlayerInterior(targetid) || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(targetid))
            return SendClientMessage(playerid, COLOR_RED, "Вы должны находиться в одном месте."), 1;
        new Float:tx, Float:ty, Float:tz;
        GetPlayerPos(targetid, tx, ty, tz);
        if (!IsPlayerInRangeOfPoint(playerid, 4.0, tx, ty, tz))
            return SendClientMessage(playerid, COLOR_RED, "Подойдите к гражданину на расстояние не более 4 метров."), 1;
        new rankName[32], doc[192], action[144];
        GetFactionRankName(FACTION_POLICE, gFactionRank[playerid], rankName, sizeof rankName);
        format(doc, sizeof doc, "[Полицйские документы] Звание: %s | Сотрудник: %s | ID: %d | Орган: LSPD", rankName, gName[playerid], playerid);
        SendClientMessage(targetid, COLOR_BLUE, doc);
        SendClientMessage(playerid, COLOR_GREEN, "Вы предъявили полицйские документы.");
        format(action, sizeof action, "* %s предъявляет свои полицйские документы.", gName[playerid]);
        new Float:px, Float:py, Float:pz; GetPlayerPos(playerid, px, py, pz);
        for (new i = 0; i < MAX_PLAYERS; i++)
            if (IsPlayerConnected(i) && GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid) && GetPlayerInterior(i) == GetPlayerInterior(playerid) && IsPlayerInRangeOfPoint(i, 10.0, px, py, pz)) SendClientMessage(i, COLOR_YELLOW, action);
        return 1;
    }
    if (CommandMatch(cmdtext, "/wanted"))
    {
        if (gFaction[playerid] != FACTION_POLICE || gFactionRank[playerid] < 3) return SendClientMessage(playerid, COLOR_RED, "Объявлять игроков в розыск можно с 3-го ранга полиции."), 1;
        new params[64], tok1[24], tok2[24], targetid, level, q[160]; GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, tok1, sizeof tok1) || !GetToken(params, 1, tok2, sizeof tok2)) return SendClientMessage(playerid, COLOR_YELLOW, "Использование: /wanted [ID] [0-6]"), 1;
        targetid = strval(tok1); level = strval(tok2);
        if (targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid) || !gLogged[targetid] || targetid == playerid) return SendClientMessage(playerid, COLOR_RED, "Игрок не найден."), 1;
        if (level < 0 || level > 6) return SendClientMessage(playerid, COLOR_RED, "Уровень розыска должен быть от 0 до 6."), 1;
        gWantedLevel[targetid] = level;
        format(q, sizeof q, "INSERT OR REPLACE INTO police_records (name,wanted) VALUES ('%q',%d)", gName[targetid], level);
        new DBResult:wr = db_query(gDatabase, q); if (wr) db_free_result(wr);
        new msg[128];
        if (level > 0) format(msg, sizeof msg, "Вы установили уровень розыска игроку %s.", gName[targetid]);
        else format(msg, sizeof msg, "Вы сняли розыск у игрока %s.", gName[targetid]);
        SendClientMessage(playerid, COLOR_GREEN, msg);
        if (level) { format(msg, sizeof msg, "Вы объявлены в розыск. Уровень: %d/6.", level); SendClientMessage(targetid, COLOR_RED, msg); }
        else SendClientMessage(targetid, COLOR_GREEN, "Розыск с вас снят.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/cuff") || CommandMatch(cmdtext, "/uncuff"))
    {
        if ((gFaction[playerid] != FACTION_POLICE && gFaction[playerid] != FACTION_FBI) || gFactionRank[playerid] < 2) return SendClientMessage(playerid, COLOR_RED, "Handcuffs are available to LSPD/FBI from rank 2."), 1;
        new params[32], token[24], targetid; GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, token, sizeof token)) return SendClientMessage(playerid, COLOR_YELLOW, "Использование: /cuff [ID] или /uncuff [ID]"), 1;
        targetid = strval(token);
        if (targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid) || !gLogged[targetid] || targetid == playerid) return SendClientMessage(playerid, COLOR_RED, "Игрок не найден."), 1;
        new Float:x, Float:y, Float:z; GetPlayerPos(playerid, x, y, z);
        if (GetPlayerInterior(playerid) != GetPlayerInterior(targetid) || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(targetid) || !IsPlayerInRangeOfPoint(targetid, 3.0, x, y, z)) return SendClientMessage(playerid, COLOR_RED, "Подойдите к игроку на расстояние до 3 метров."), 1;
        if (CommandMatch(cmdtext, "/cuff"))
        {
            if (gHandcuffed[targetid]) return SendClientMessage(playerid, COLOR_YELLOW, "Игрок уже в наручниках."), 1;
            // Visible cuffing motion, then hands behind the back and cuff prop.
            ClearAnimations(playerid);
            ApplyAnimation(playerid, "POLICE", "CopTraf_Away", 4.1, 0, 0, 0, 0, 1800);
            gHandcuffed[targetid] = true;
            gCuffOfficer[targetid] = playerid;
            ClearAnimations(targetid);
            SetPlayerSpecialAction(targetid, SPECIAL_ACTION_CUFFED);
            TogglePlayerControllable(targetid, 1);
            if (gHandcuffObject[targetid] != INVALID_OBJECT_ID) DestroyObject(gHandcuffObject[targetid]);
            gHandcuffObject[targetid] = CreateObject(19418, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
            if (gHandcuffObject[targetid] != INVALID_OBJECT_ID) AttachObjectToPlayer(gHandcuffObject[targetid], targetid, 0.04, 0.02, 0.0, 0.0, 0.0, 0.0);
            TogglePlayerControllable(targetid, 1);
            SendClientMessage(targetid, COLOR_RED, "На вас надели наручники. Дождитесь сотрудника полиции."); SendClientMessage(playerid, COLOR_GREEN, "Наручники надеты.");
        }
        else
        {
            if (!gHandcuffed[targetid]) return SendClientMessage(playerid, COLOR_YELLOW, "Игрок не в наручниках."), 1;
            gHandcuffed[targetid] = false;
            gCuffOfficer[targetid] = INVALID_PLAYER_ID;
            TogglePlayerControllable(targetid, 1);
            SetPlayerSpecialAction(targetid, SPECIAL_ACTION_NONE);
            ClearAnimations(targetid);
            ApplyAnimation(playerid, "POLICE", "CopTraf_Come", 4.1, 0, 0, 0, 0, 1800);
            ClearAnimations(targetid);
            if (gHandcuffObject[targetid] != INVALID_OBJECT_ID) { DestroyObject(gHandcuffObject[targetid]); gHandcuffObject[targetid] = INVALID_OBJECT_ID; }
            ClearAnimations(playerid);
            SendClientMessage(targetid, COLOR_GREEN, "С вас сняли наручники."); SendClientMessage(playerid, COLOR_GREEN, "Наручники сняты.");
        }
        return 1;
    }
    if (CommandMatch(cmdtext, "/putincar") || CommandMatch(cmdtext, "/loadsuspect"))
    {
        if ((gFaction[playerid] != FACTION_POLICE && gFaction[playerid] != FACTION_FBI) || gFactionRank[playerid] < 2) return SendClientMessage(playerid, COLOR_RED, "\xcd\xe0\xf0\xf3\xf7\xed\xe8\xea\xe8 \xe4\xee\xf1\xf2\xf3\xef\xed\xfb LSPD/FBI \xf1\xee 2-\xe3\xee \xf0\xe0\xed\xe3\xe0."), 1;
        new params[32], token[24], targetid; GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, token, sizeof token)) return SendClientMessage(playerid, COLOR_YELLOW, "\xc8\xf1\xef\xee\xeb\xfc\xe7\xee\xe2\xe0\xed\xe8\xe5: /putincar [ID]"), 1;
        targetid = strval(token);
        if (targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid) || !gLogged[targetid] || targetid == playerid) return SendClientMessage(playerid, COLOR_RED, "\xc8\xe3\xf0\xee\xea \xed\xe5 \xed\xe0\xe9\xe4\xe5\xed."), 1;
        if (!gHandcuffed[targetid]) return SendClientMessage(playerid, COLOR_RED, "\xd1\xed\xe0\xf7\xe0\xeb\xe0 \xe7\xe0\xf1\xf2\xe5\xe3\xed\xe8\xf2\xe5 \xe8\xe3\xf0\xee\xea\xe0 \xea\xee\xec\xe0\xed\xe4\xee\xe9 /cuff [ID]."), 1;
        if (IsPlayerInAnyVehicle(targetid)) return SendClientMessage(playerid, COLOR_YELLOW, "\xc8\xe3\xf0\xee\xea \xf3\xe6\xe5 \xe2 \xec\xe0\xf8\xe8\xed\xe5."), 1;
        new Float:px, Float:py, Float:pz; GetPlayerPos(playerid, px, py, pz);
        if (GetPlayerInterior(playerid) != GetPlayerInterior(targetid) || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(targetid) || !IsPlayerInRangeOfPoint(targetid, 3.0, px, py, pz)) return SendClientMessage(playerid, COLOR_RED, "\xcf\xee\xe4\xee\xe9\xe4\xe8\xf2\xe5 \xea \xe7\xe0\xe4\xe5\xf0\xe6\xe0\xed\xed\xee\xec\xf3 \xed\xe0 3 \xec\xe5\xf2\xf0\xe0."), 1;
        new vehicleid = INVALID_VEHICLE_ID, seat = -1;
        new Float:vx, Float:vy, Float:vz, Float:dist, Float:bestDist = 99999.0;
        for (new v = 1; v < MAX_VEHICLES; v++)
        {
            // Compatibility with older SA-MP/Pawn includes: model 0 means no vehicle.
            if (GetVehicleModel(v) == 0) continue;
            GetVehiclePos(v, vx, vy, vz);
            if (GetPlayerVirtualWorld(playerid) != GetVehicleVirtualWorld(v)) continue;
            new Float:dx = px - vx, Float:dy = py - vy, Float:dz = pz - vz;
            dist = floatsqroot(dx * dx + dy * dy + dz * dz);
            if (dist <= 6.0 && dist < bestDist) { vehicleid = v; bestDist = dist; }
        }
        if (vehicleid == INVALID_VEHICLE_ID) return SendClientMessage(playerid, COLOR_RED, "\xcf\xee\xf1\xf2\xe0\xe2\xfc\xf2\xe5 \xef\xe0\xf2\xf0\xf3\xeb\xfc\xed\xf3\xfe \xec\xe0\xf8\xe8\xed\xf3 \xf0\xff\xe4\xee\xec (\xe4\xee 6 \xec\xe5\xf2\xf0\xee\xe2)."), 1;
        for (new s = 1; s < 4; s++)
        {
            new bool:occupied = false;
            for (new i = 0; i < MAX_PLAYERS; i++)
            {
                if (i != targetid && IsPlayerConnected(i) && IsPlayerInVehicle(i, vehicleid) && GetPlayerVehicleSeat(i) == s) { occupied = true; break; }
            }
            if (!occupied) { seat = s; break; }
        }
        if (seat == -1) return SendClientMessage(playerid, COLOR_RED, "\xc2 \xef\xe0\xf2\xf0\xf3\xeb\xfc\xed\xee\xec \xe0\xe2\xf2\xee \xed\xe5\xf2 \xf1\xe2\xee\xe1\xee\xe4\xed\xee\xe3\xee \xef\xe0\xf1\xf1\xe0\xe6\xe8\xf0\xf1\xea\xee\xe3\xee \xec\xe5\xf1\xf2\xe0."), 1;
        TogglePlayerControllable(targetid, 1);
        ClearAnimations(targetid);
        PutPlayerInVehicle(targetid, vehicleid, seat);
        SendClientMessage(playerid, COLOR_GREEN, "\xc7\xe0\xe4\xe5\xf0\xe6\xe0\xed\xed\xfb\xe9 \xef\xee\xf1\xe0\xe6\xe5\xed \xe2 \xef\xe0\xf2\xf0\xf3\xeb\xfc\xed\xf3\xfe \xec\xe0\xf8\xe8\xed\xf3." );
        SendClientMessage(targetid, COLOR_RED, "\xc2\xfb \xe4\xee\xf1\xf2\xe0\xe2\xeb\xe5\xed\xfb \xe2 \xef\xee\xeb\xe8\xf6\xe5\xe9\xf1\xea\xf3\xfe \xec\xe0\xf8\xe8\xed\xf3. \xcd\xe5 \xef\xee\xef\xfb\xf2\xe0\xe9\xf2\xe5\xf1\xfc \xe2\xfb\xe9\xf2\xe8." );
        return 1;
    }
    if (CommandMatch(cmdtext, "/pursuit"))
    {
        if ((gFaction[playerid] != FACTION_POLICE && gFaction[playerid] != FACTION_FBI) || gFactionRank[playerid] < 2) return SendClientMessage(playerid, COLOR_RED, "\xcd\xe0\xf0\xf3\xf7\xed\xe8\xea\xe8 \xe4\xee\xf1\xf2\xf3\xef\xed\xfb LSPD/FBI \xf1\xee 2-\xe3\xee \xf0\xe0\xed\xe3\xe0."), 1;
        new params[32], token[24], targetid; GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, token, sizeof token)) return SendClientMessage(playerid, COLOR_YELLOW, "Использование: /pursuit [ID]"), 1;
        targetid = strval(token);
        if (targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid) || !gLogged[targetid] || targetid == playerid) return SendClientMessage(playerid, COLOR_RED, "Игрок не найден."), 1;
        if (gWantedLevel[targetid] < 1) return SendClientMessage(playerid, COLOR_YELLOW, "У игрока нет активного розыска."), 1;
        new Float:x, Float:y, Float:z;
        if (IsPlayerInAnyVehicle(targetid)) GetVehiclePos(GetPlayerVehicleID(targetid), x, y, z);
        else GetPlayerPos(targetid, x, y, z);
        gPursuitTarget[playerid] = targetid;
        SetPlayerMapIcon(playerid, 49, x, y, z, 0, 0, MAPICON_GLOBAL);
        SetPlayerCheckpoint(playerid, x, y, z, 8.0);
        new msg[128]; format(msg, sizeof msg, "Начато преследование %s. Метка показывает его последнее местоположение; повторите /pursuit [ID] для обновления.", gName[targetid]); SendClientMessage(playerid, COLOR_GREEN, msg);
        return 1;
    }
    if (CommandMatch(cmdtext, "/time"))
    {
        new hour, minute, second, year, month, day, timeMessage[128];
        gettime(hour, minute, second);
        getdate(year, month, day);
        format(timeMessage, sizeof timeMessage, "[VEXORIUM RP] Server time: %02d:%02d:%02d | Date: %02d.%02d.%04d", hour, minute, second, day, month, year);
        SendClientMessage(playerid, COLOR_GREEN, timeMessage);
        return 1;
    }
    if (CommandMatch(cmdtext, "/bank"))
    {
        new bankMsg[144];
        format(bankMsg, sizeof bankMsg, "[БАНК] Наличные: %d руб. | На счёте: %d руб. | /deposit [сумма] /withdraw [сумма] /transfer [ID] [сумма]", gMoney[playerid], gBankMoney[playerid]);
        SendClientMessage(playerid, COLOR_GREEN, bankMsg);
        return 1;
    }
    if (CommandMatch(cmdtext, "/deposit") || CommandMatch(cmdtext, "/withdraw"))
    {
        new params[64], token[24], amount;
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, token, sizeof token)) return SendClientMessage(playerid, COLOR_YELLOW, "Использование: /deposit [сумма] или /withdraw [сумма]"), 1;
        amount = strval(token);
        if (amount <= 0 || amount > MAX_MONEY) return SendClientMessage(playerid, COLOR_RED, "Сумма должна быть положительной."), 1;
        if (CommandMatch(cmdtext, "/deposit"))
        {
            if (gMoney[playerid] < amount) return SendClientMessage(playerid, COLOR_RED, "Недостаточно наличных."), 1;
            if (gBankMoney[playerid] > MAX_MONEY - amount) return SendClientMessage(playerid, COLOR_RED, "Превышен лимит банковского счёта."), 1;
            gMoney[playerid] -= amount; gBankMoney[playerid] += amount;
        }
        else
        {
            if (gBankMoney[playerid] < amount) return SendClientMessage(playerid, COLOR_RED, "Недостаточно денег на банковском счёте."), 1;
            if (gMoney[playerid] > MAX_MONEY - amount) return SendClientMessage(playerid, COLOR_RED, "Превышен лимит наличных."), 1;
            gBankMoney[playerid] -= amount; gMoney[playerid] += amount;
        }
        new bankSave[192];
        format(bankSave, sizeof bankSave, "INSERT OR REPLACE INTO bank_accounts (name,balance) VALUES ('%q',%d)", gName[playerid], gBankMoney[playerid]);
        new DBResult:bs = db_query(gDatabase, bankSave); if (bs) db_free_result(bs);
        SavePlayer(playerid);
        return SendClientMessage(playerid, COLOR_GREEN, "Операция выполнена. Баланс банка сохранён."), 1;
    }
    if (CommandMatch(cmdtext, "/transfer"))
    {
        new params[64], tok1[24], tok2[24], targetid, amount;
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, tok1, sizeof tok1) || !GetToken(params, 1, tok2, sizeof tok2)) return SendClientMessage(playerid, COLOR_YELLOW, "Использование: /transfer [ID] [сумма]"), 1;
        targetid = strval(tok1); amount = strval(tok2);
        if (targetid < 0 || targetid >= MAX_PLAYERS || targetid == playerid || !IsPlayerConnected(targetid) || !gLogged[targetid]) return SendClientMessage(playerid, COLOR_RED, "Получатель не найден."), 1;
        if (amount <= 0 || amount > MAX_MONEY) return SendClientMessage(playerid, COLOR_RED, "Некорректная сумма."), 1;
        if (gBankMoney[playerid] < amount) return SendClientMessage(playerid, COLOR_RED, "Недостаточно денег на банковском счёте."), 1;
        if (gBankMoney[targetid] > MAX_MONEY - amount) return SendClientMessage(playerid, COLOR_RED, "У получателя достигнут лимит счёта."), 1;
        gBankMoney[playerid] -= amount; gBankMoney[targetid] += amount;
        new bankSave[192];
        format(bankSave, sizeof bankSave, "INSERT OR REPLACE INTO bank_accounts (name,balance) VALUES ('%q',%d)", gName[playerid], gBankMoney[playerid]);
        new DBResult:bs = db_query(gDatabase, bankSave); if (bs) db_free_result(bs);
        format(bankSave, sizeof bankSave, "INSERT OR REPLACE INTO bank_accounts (name,balance) VALUES ('%q',%d)", gName[targetid], gBankMoney[targetid]);
        bs = db_query(gDatabase, bankSave); if (bs) db_free_result(bs);
        new transferMsg[128]; format(transferMsg, sizeof transferMsg, "Вам перевели %d руб. от %s.", amount, gName[playerid]); SendClientMessage(targetid, COLOR_GREEN, transferMsg);
        format(transferMsg, sizeof transferMsg, "Перевод %d руб. игроку %s выполнен.", amount, gName[targetid]); SendClientMessage(playerid, COLOR_GREEN, transferMsg);
        return 1;
    }
    if (CommandMatch(cmdtext, "/house"))
    {
        new Float:px, Float:py, Float:pz, DBResult:hr, row, hid, Float:hx, Float:hy, Float:hz, owner[ MAX_PLAYER_NAME + 1 ], msg[160], found = 0;
        GetPlayerPos(playerid, px, py, pz);
        hr = db_query(gDatabase, "SELECT id,owner,price,x,y,z FROM houses");
        if (hr)
        {
            for (row = 0; row < db_num_rows(hr); row++)
            {
                hid = db_get_field_int(hr, 0); db_get_field(hr, 1, owner, sizeof owner);
                hx = db_get_field_float(hr, 3); hy = db_get_field_float(hr, 4); hz = db_get_field_float(hr, 5);
                if (GetPlayerInterior(playerid) == 0 && GetPlayerVirtualWorld(playerid) == 0 && IsPlayerInRangeOfPoint(playerid, 5.0, hx, hy, hz))
                {
                    new price = db_get_field_int(hr, 2);
                    if (!owner[0]) format(msg, sizeof msg, "Дом #%d свободен. Цена: %d руб. Покупка: /housebuy", hid, price);
                    else format(msg, sizeof msg, "Дом #%d принадлежит %s.", hid, owner);
                    SendClientMessage(playerid, COLOR_YELLOW, msg); found = 1; break;
                }
                db_next_row(hr);
            }
            db_free_result(hr);
        }
        if (!found) SendClientMessage(playerid, COLOR_YELLOW, "Подойди к одному из домов и введи /house. Дома отмечены координатами в Лос-Сантосе.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/housebuy"))
    {
        new Float:px, Float:py, Float:pz, DBResult:hr, row, hid = 0, price = 0, Float:hx, Float:hy, Float:hz, owner[MAX_PLAYER_NAME + 1], query[256];
        GetPlayerPos(playerid, px, py, pz);
        hr = db_query(gDatabase, "SELECT id,owner,price,x,y,z FROM houses");
        if (hr)
        {
            for (row = 0; row < db_num_rows(hr); row++)
            {
                hx = db_get_field_float(hr, 3); hy = db_get_field_float(hr, 4); hz = db_get_field_float(hr, 5);
                if (GetPlayerInterior(playerid) == 0 && GetPlayerVirtualWorld(playerid) == 0 && IsPlayerInRangeOfPoint(playerid, 5.0, hx, hy, hz))
                { hid = db_get_field_int(hr, 0); db_get_field(hr, 1, owner, sizeof owner); price = db_get_field_int(hr, 2); break; }
                db_next_row(hr);
            }
            db_free_result(hr);
        }
        if (!hid) return SendClientMessage(playerid, COLOR_RED, "Подойди к дому, который хочешь купить."), 1;
        if (owner[0]) return SendClientMessage(playerid, COLOR_RED, "Этот дом уже принадлежит игроку."), 1;
        if (gMoney[playerid] < price) return SendClientMessage(playerid, COLOR_RED, "Недостаточно наличных для покупки дома."), 1;
        format(query, sizeof query, "UPDATE houses SET owner='%q' WHERE id=%d AND owner=''", gName[playerid], hid);
        new DBResult:buyRes = db_query(gDatabase, query); if (buyRes) db_free_result(buyRes);
        format(query, sizeof query, "SELECT owner FROM houses WHERE id=%d", hid);
        buyRes = db_query(gDatabase, query);
        new checkOwner[MAX_PLAYER_NAME + 1]; checkOwner[0] = 0; if (buyRes && db_num_rows(buyRes)) db_get_field(buyRes, 0, checkOwner, sizeof checkOwner); if (buyRes) db_free_result(buyRes);
        if (strcmp(checkOwner, gName[playerid], true)) return SendClientMessage(playerid, COLOR_RED, "Не удалось оформить покупку."), 1;
        gMoney[playerid] -= price; SavePlayer(playerid);
        return SendClientMessage(playerid, COLOR_GREEN, "Поздравляем! Дом куплен и сохранён."), 1;
    }
    if (CommandMatch(cmdtext, "/houseenter"))
    {
        new DBResult:hr, hid, owner[MAX_PLAYER_NAME + 1], Float:hx, Float:hy, Float:hz, found = 0;
        if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0) return SendClientMessage(playerid, COLOR_RED, "Вы уже находитесь внутри здания."), 1;
        GetPlayerPos(playerid, hx, hy, hz); hr = db_query(gDatabase, "SELECT id,owner,x,y,z FROM houses");
        if (hr)
        {
            for (new row = 0; row < db_num_rows(hr); row++)
            {
                if (IsPlayerInRangeOfPoint(playerid, 5.0, db_get_field_float(hr, 2), db_get_field_float(hr, 3), db_get_field_float(hr, 4)))
                {
                    hid = db_get_field_int(hr, 0);
                    db_get_field(hr, 1, owner, sizeof owner);
                    found = 1;
                    break;
                }
                db_next_row(hr);
            }
            db_free_result(hr);
        }
        if (!found) return SendClientMessage(playerid, COLOR_RED, "Подойди к своему дому."), 1;
        if (strcmp(owner, gName[playerid], true)) return SendClientMessage(playerid, COLOR_RED, "Войти может только владелец дома."), 1;
        gCurrentHouse[playerid] = hid; SetPlayerInterior(playerid, 1); SetPlayerVirtualWorld(playerid, hid); SetPlayerPos(playerid, 223.0, 1287.0, 1082.1); SetPlayerFacingAngle(playerid, 0.0); SetCameraBehindPlayer(playerid);
        return SendClientMessage(playerid, COLOR_GREEN, "Вы вошли в дом. Для выхода используйте /houseexit."), 1;
    }
    if (CommandMatch(cmdtext, "/houseexit"))
    {
        if (!gCurrentHouse[playerid] || GetPlayerInterior(playerid) == 0) return SendClientMessage(playerid, COLOR_RED, "Вы не находитесь в доме."), 1;
        new query[128], DBResult:hr; format(query, sizeof query, "SELECT x,y,z FROM houses WHERE id=%d", gCurrentHouse[playerid]); hr = db_query(gDatabase, query);
        if (hr && db_num_rows(hr)) { SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0); SetPlayerPos(playerid, db_get_field_float(hr, 0), db_get_field_float(hr, 1), db_get_field_float(hr, 2) + 1.0); SetPlayerFacingAngle(playerid, 180.0); SetCameraBehindPlayer(playerid); }
        if (hr) db_free_result(hr); gCurrentHouse[playerid] = 0;
        return SendClientMessage(playerid, COLOR_GREEN, "Вы вышли из дома."), 1;
    }
    if (CommandMatch(cmdtext, "/kick"))
    {
        new params[64], token[32], targetid;
        if (gAdmin[playerid] < 2) return SendClientMessage(playerid, COLOR_RED, "Недостаточно прав."), 1;
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, token, sizeof token)) return SendClientMessage(playerid, COLOR_YELLOW, "Использование: /kick [ID]"), 1;
        targetid = strval(token);
        if (targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, "Игрок не найден."), 1;
        SendClientMessage(targetid, COLOR_RED, "Вы были отключены администратором.");
        Kick(targetid);
        SendClientMessage(playerid, COLOR_GREEN, "[VEXORIUM] Игрок отключён.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/a"))
    {
        new params[128], msg[160];
        if (gAdmin[playerid] < 1) return SendClientMessage(playerid, COLOR_RED, "Недостаточно прав."), 1;
        GetParams(cmdtext, params, sizeof params);
        if (!strlen(params)) return SendClientMessage(playerid, COLOR_YELLOW, "Использование: /a [сообщение]"), 1;
        format(msg, sizeof msg, "[Админ-чат] %s: %s", gName[playerid], params);
        for (new i = 0; i < MAX_PLAYERS; i++) if (IsPlayerConnected(i) && gLogged[i] && gAdmin[i] > 0) SendClientMessage(i, COLOR_ORANGE, msg);
        return 1;
    }
    SendClientMessage(playerid, COLOR_YELLOW, "Неизвестная команда. Напишите /help.");
    return 1;
}

stock cmdtext_licbuy(playerid, const type[])
{
    new price, licenseType;
    // Driver license is granted here after the completed exam.
    if (!strcmp(type, "auto", true))
    {
        if (GetPlayerInterior(playerid) != 3 || GetPlayerVirtualWorld(playerid) != 101 || !IsPlayerInRangeOfPoint(playerid, 8.0, 362.4587, 174.0056, 1008.3828))
            return SendClientMessage(playerid, COLOR_RED, "Подойдите к стойке лицензий в мэрии."), 1;
        if (gLicenseDriver[playerid])
            return SendClientMessage(playerid, COLOR_GREEN, "У вас уже есть водительские права."), 1;
        if (!gDrivingExamPassed[playerid])
            return SendClientMessage(playerid, COLOR_RED, "Сначала сдайте маршрут в автошколе."), 1;
        gLicenseDriver[playerid] = 1;
        gDrivingExamPassed[playerid] = 0;
        SavePlayer(playerid);
        return SendClientMessage(playerid, COLOR_GREEN, "Водительские права выданы! Оплата уже включена в экзамен."), 1;
    }
    if (!strcmp(type, "weapon", true)) { licenseType = 2; price = 30000; if (gLicenseWeapon[playerid]) return SendClientMessage(playerid, COLOR_GREEN, "У вас уже есть лицензия на оружие."), 1; }
    else if (!strcmp(type, "boat", true)) { licenseType = 3; price = 20000; if (gLicenseBoat[playerid]) return SendClientMessage(playerid, COLOR_GREEN, "У вас уже есть лицензия на лодку."), 1; }
    else if (!strcmp(type, "air", true)) { licenseType = 4; price = 40000; if (gLicenseAir[playerid]) return SendClientMessage(playerid, COLOR_GREEN, "У вас уже есть лицензия на самолёт."), 1; }
    else return 1;
    if (gMoney[playerid] < price) return SendClientMessage(playerid, COLOR_RED, "Недостаточно денег для покупки лицензии."), 1;
    gMoney[playerid] -= price; GivePlayerMoney(playerid, -price);
    if (licenseType == 2) gLicenseWeapon[playerid] = 1;
    else if (licenseType == 3) gLicenseBoat[playerid] = 1;
    else gLicenseAir[playerid] = 1;
    SavePlayer(playerid);
    SendClientMessage(playerid, COLOR_GREEN, "Поздравляем! Лицензия успешно приобретена.");
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if (dialogid == DIALOG_ITEM_INVENTORY)
    {
        if (!response) return 1;
        if (listitem == 0)
        {
            if (gMedkits[playerid] < 1) return SendClientMessage(playerid, COLOR_RED, "[INV] У вас нет аптечек."), 1;
            new Float:hp; GetPlayerHealth(playerid, hp);
            if (hp >= 100.0) return SendClientMessage(playerid, COLOR_YELLOW, "[INV] Здоровье восстановлено на 100%."), 1;
            gMedkits[playerid]--; SetPlayerHealth(playerid, 100.0); SavePlayer(playerid); SendClientMessage(playerid, COLOR_GREEN, "[INV] Вы использовали аптечку. Здоровье восстановлено." );
            new medText[128]; format(medText, sizeof medText, "* %s достал аптечку и обработал раны.", gName[playerid]); SendLocalMessage(playerid, COLOR_PINK, medText, 20.0);
        }
        else if (listitem == 1)
        {
            if (gFood[playerid] < 1) return SendClientMessage(playerid, COLOR_RED, "[INV] У вас нет еды."), 1;
            new Float:hp; GetPlayerHealth(playerid, hp); if (hp < 95.0) SetPlayerHealth(playerid, hp + 5.0); gFood[playerid]--; SavePlayer(playerid); SendClientMessage(playerid, COLOR_GREEN, "[INV] Вы поели. Еда использована." );
            new foodText[128]; format(foodText, sizeof foodText, "* %s достал еду и начал есть.", gName[playerid]); SendLocalMessage(playerid, COLOR_PINK, foodText, 20.0);
        }
        else if (listitem == 2)
        {
            if (gWater[playerid] < 1) return SendClientMessage(playerid, COLOR_RED, "[INV] У вас нет воды."), 1;
            gWater[playerid]--; SavePlayer(playerid); SendClientMessage(playerid, COLOR_GREEN, "[INV] Вы выпили воду." );
            new waterText[128]; format(waterText, sizeof waterText, "* %s достал бутылку воды и сделал несколько глотков.", gName[playerid]); SendLocalMessage(playerid, COLOR_PINK, waterText, 20.0);
        }
        else if (listitem == 3)
        {
            SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
            new shopText[512];
            shopText[0] = '\0';
            strcat(shopText, "КЛАССИКА | Черные очки - 1 500 руб.\n");
            strcat(shopText, "КЛАССИКА | Уличная кепка - 2 500 руб.\n");
            strcat(shopText, "КЛАССИКА | Шапка-бини - 3 500 руб.\n");
            strcat(shopText, "СТИЛЬ | Ковбойская шляпа - 7 500 руб.\n");
            strcat(shopText, "СТИЛЬ | Хоккейная маска - 9 000 руб.\n");
            strcat(shopText, "ПРЕМИУМ | Золотые очки - 15 000 руб.\n");
            strcat(shopText, "ПРЕМИУМ | Дизайнерская кепка - 22 000 руб.\n");
            strcat(shopText, "ЭЛИТА | Роскошная маска - 35 000 руб.\n");
            strcat(shopText, "ЭЛИТА | Бриллиантовый стиль - 55 000 руб.\n");
            strcat(shopText, "VIP | Королевский аксессуар - 85 000 руб.\n");
            strcat(shopText, "Откройте /inv, чтобы надеть или снять");
            ShowPlayerDialog(playerid, DIALOG_SHOP_ACC, DIALOG_STYLE_LIST, "VEXORIUM | Магазин аксессуаров", shopText, "Выбрать", "Закрыть");
        }
        else if (listitem == 4)
        {
            if (gAccessoryModel[playerid] <= 0) return SendClientMessage(playerid, COLOR_YELLOW, "[ИНВЕНТАРЬ] У вас нет аксессуара. Купите его через /shopacc."), 1;
            if (IsPlayerAttachedObjectSlotUsed(playerid, 0)) RemovePlayerAttachedObject(playerid, 0);
            if (!SetPlayerAttachedObject(playerid, 0, gAccessoryModel[playerid], 2, 0.10, 0.02, 0.00, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0)) return SendClientMessage(playerid, COLOR_RED, "[ИНВЕНТАРЬ] Не удалось надеть аксессуар."), 1;
            new accText[128]; format(accText, sizeof accText, "* %s надел аксессуар.", gName[playerid]); SendLocalMessage(playerid, COLOR_PINK, accText, 20.0);
            SendClientMessage(playerid, COLOR_GREEN, "[ИНВЕНТАРЬ] Аксессуар надет.");
        }
        else if (listitem == 5)
        {
            if (IsPlayerAttachedObjectSlotUsed(playerid, 0)) RemovePlayerAttachedObject(playerid, 0);
            new accText[128]; format(accText, sizeof accText, "* %s снял аксессуар.", gName[playerid]); SendLocalMessage(playerid, COLOR_PINK, accText, 20.0);
            SendClientMessage(playerid, COLOR_GREEN, "[ИНВЕНТАРЬ] Аксессуар снят и остался в инвентаре.");
        }
        return 1;
    }
    if (dialogid == DIALOG_PHONE)
    {
        if (!response) return 1;
        if (listitem == 0) ShowPlayerDialog(playerid, DIALOG_PHONE_SMS_TARGET, DIALOG_STYLE_INPUT, "VEXORIUM | SMS", "Введите ID игрока, которому будет отправлено SMS:", "Далее", "Отмена");
        else if (listitem == 1) OnPlayerCommandText(playerid, "/gps");
        else if (listitem == 2)
        {
            new Float:cx, Float:cy, Float:cz, dispatch[160]; GetPlayerPos(playerid, cx, cy, cz);
            format(dispatch, sizeof dispatch, "[112] Вызов полиции: %s (ID %d), координаты %.1f, %.1f, %.1f", gName[playerid], playerid, cx, cy, cz);
            for (new i = 0; i < MAX_PLAYERS; i++) if (IsPlayerConnected(i) && gLogged[i] && gFaction[i] == FACTION_POLICE) SendClientMessage(i, COLOR_YELLOW, dispatch);
            SendClientMessage(playerid, COLOR_GREEN, "[112] Вызов отправлен сотрудникам полиции." );
        }
        else if (listitem == 3)
        {
            new Float:cx, Float:cy, Float:cz, dispatch[160]; GetPlayerPos(playerid, cx, cy, cz);
            format(dispatch, sizeof dispatch, "[103] Вызов скорой: %s (ID %d), координаты %.1f, %.1f, %.1f", gName[playerid], playerid, cx, cy, cz);
            for (new i = 0; i < MAX_PLAYERS; i++) if (IsPlayerConnected(i) && gLogged[i] && gFaction[i] == FACTION_HOSPITAL) SendClientMessage(i, COLOR_YELLOW, dispatch);
            SendClientMessage(playerid, COLOR_GREEN, "[103] Вызов отправлен сотрудникам больницы." );
        }
        else { new msg[96]; format(msg, sizeof msg, "[VEXORIUM] Ваш ID: %d. Сообщайте его друзьям.", playerid); SendClientMessage(playerid, COLOR_GREEN, msg); }
        return 1;
    }
    if (dialogid == DIALOG_PHONE_SMS_TARGET)
    {
        if (!response) return 1;
        new targetid = strval(inputtext);
        if (targetid < 0 || targetid >= MAX_PLAYERS || targetid == playerid || !IsPlayerConnected(targetid) || !gLogged[targetid]) return SendClientMessage(playerid, COLOR_RED, "[SMS] Игрок не найден."), 1;
        gPhoneSmsTarget[playerid] = targetid;
        ShowPlayerDialog(playerid, DIALOG_PHONE_SMS_TEXT, DIALOG_STYLE_INPUT, "VEXORIUM | SMS", "Напишите текст SMS (до 120 символов):", "Отправить", "Отмена");
        return 1;
    }
    if (dialogid == DIALOG_PHONE_SMS_TEXT)
    {
        if (!response) return 1;
        new targetid = gPhoneSmsTarget[playerid], msg[160], outgoing[192];
        if (targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid) || !gLogged[targetid]) return SendClientMessage(playerid, COLOR_RED, "[SMS] Игрок отключился."), 1;
        if (strlen(inputtext) < 1) return SendClientMessage(playerid, COLOR_RED, "[SMS] Пустое сообщение нельзя отправить."), 1;
        format(outgoing, sizeof outgoing, "[SMS] От %s: %s", gName[playerid], inputtext); SendClientMessage(targetid, COLOR_YELLOW, outgoing);
        format(msg, sizeof msg, "[SMS] Вы отправили %s: %s", gName[targetid], inputtext); SendClientMessage(playerid, COLOR_GREEN, msg); gPhoneSmsTarget[playerid] = INVALID_PLAYER_ID;
        return 1;
    }
    if (dialogid == DIALOG_SHOP_ACC)
    {
        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
        if (!response) return 1;
        if (listitem == 10)
        {
            ShowPlayerDialog(playerid, DIALOG_ITEM_INVENTORY, DIALOG_STYLE_LIST, "VEXORIUM | Инвентарь", "Использовать аптечку\nСъесть еду\nВыпить воду\nМагазин аксессуаров\nНадеть аксессуар\nСнять аксессуар", "Выбрать", "Закрыть");
            return 1;
        }
        new model, price;
        switch (listitem)
        {
            case 0: { model = 19006; price = 1500; }
            case 1: { model = 19007; price = 2500; }
            case 2: { model = 19008; price = 3500; }
            case 3: { model = 19009; price = 7500; }
            case 4: { model = 19010; price = 9000; }
            case 5: { model = 19011; price = 15000; }
            case 6: { model = 19012; price = 22000; }
            case 7: { model = 19013; price = 35000; }
            case 8: { model = 19014; price = 55000; }
            case 9: { model = 19015; price = 85000; }
            default: return 1;
        }
        if (gMoney[playerid] < price) return SendClientMessage(playerid, COLOR_RED, "[АКСЕССУАРЫ] Недостаточно денег для покупки."), 1;
        if (!TakeCash(playerid, price)) return SendClientMessage(playerid, COLOR_RED, "[АКСЕССУАРЫ] Не удалось провести оплату."), 1;
        gAccessoryModel[playerid] = model;
        new buyAccText[144]; format(buyAccText, sizeof buyAccText, "* %s bought an accessory.", gName[playerid]); SendLocalMessage(playerid, COLOR_PINK, buyAccText, 20.0);
        SavePlayer(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "[АКСЕССУАРЫ] Покупка сохранена. Откройте /inv и выберите надевание.");
        return 1;
    }
    if (dialogid == DIALOG_SHOP)
    {
        if (!response) return 1;
        new price = 0;
        if (listitem == 0) price = 750; else if (listitem == 1) price = 150; else if (listitem == 2) price = 100; else if (listitem == 3) price = 200; else if (listitem == 4) price = 2000; else if (listitem == 5) price = 1000; else if (listitem == 6) price = 5000; else return 1;
        if (gMoney[playerid] < price) return SendClientMessage(playerid, COLOR_RED, "[SHOP] Недостаточно денег."), 1;
        if (listitem == 0) gMedkits[playerid]++;
        else if (listitem == 1) gFood[playerid]++;
        else if (listitem == 2) gWater[playerid]++;
        else if (listitem == 3) { gFood[playerid]++; gWater[playerid]++; }
        else if (listitem == 4) gRepairKits[playerid]++;
        else if (listitem == 5) gSimCards[playerid]++;
        else if (listitem == 6) gLockpicks[playerid]++;
        gMoney[playerid] -= price; GivePlayerMoney(playerid, -price); SavePlayer(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "[SHOP] Покупк успешна. Предметы добавлены в инвентарь." );
        return 1;
    }
    if (dialogid == DIALOG_LICENSE_MARKET)
    {
        if (!response) return 1;
        if (GetPlayerInterior(playerid) != 3 || GetPlayerVirtualWorld(playerid) != 101 || !IsPlayerInRangeOfPoint(playerid, 5.0, 362.4587, 174.0056, 1008.3828))
            return SendClientMessage(playerid, COLOR_RED, "Подойдите к стойке лицензий в мэрии."), 1;
        switch (listitem)
        {
            case 0: return cmdtext_licbuy(playerid, "weapon");
            case 1: return cmdtext_licbuy(playerid, "boat");
            case 2: return cmdtext_licbuy(playerid, "air");
            case 3: return cmdtext_licbuy(playerid, "auto");
        }
        return 1;
    }
    if (dialogid == DIALOG_PASSPORT)
    {
        if (!response) return 1;
        if (GetPlayerInterior(playerid) != 3 || GetPlayerVirtualWorld(playerid) != 101 || !IsPlayerInRangeOfPoint(playerid, 5.0, 358.8, 174.0056, 1008.3828))
            return SendClientMessage(playerid, COLOR_RED, "Подойдите к стойке оформления паспорта в мэрии."), 1;
        if (gHasPassport[playerid]) return SendClientMessage(playerid, COLOR_GREEN, "У вас уже есть паспорт."), 1;
        gHasPassport[playerid] = 1;
        new passportQuery[160];
        format(passportQuery, sizeof passportQuery, "UPDATE accounts SET has_passport=1 WHERE name='%q'", gName[playerid]);
        new DBResult:passportRes = db_query(gDatabase, passportQuery); if (passportRes) db_free_result(passportRes);
        SendClientMessage(playerid, COLOR_GREEN, "Паспорт успешно оформлен! Теперь вам доступны устройство на работу и городские услуги.");
        return 1;
    }
    if (dialogid == DIALOG_AUTOSCHOOL)
    {
        if (!response) return SendClientMessage(playerid, COLOR_YELLOW, "Экзамен отменён."), 1;
        if (!gLogged[playerid] || GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0 || !IsPlayerInRangeOfPoint(playerid, 4.0, -2026.8, -96.5, 35.2))
            return SendClientMessage(playerid, COLOR_RED, "Подойдите к инструктору автошколы ещё раз."), 1;
        if (gLicenseDriver[playerid]) return SendClientMessage(playerid, COLOR_GREEN, "У вас уже есть водительская лицензия."), 1;
        if (gDrivingTestStage[playerid] > 0) return SendClientMessage(playerid, COLOR_YELLOW, "Вы уже проходите экзамен."), 1;
        if (IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_RED, "Выйдите из транспорта перед началом экзамена."), 1;
        // Park the exam vehicle on the open roadside outside the school, not at the entrance/building.
        gDrivingTestVehicle[playerid] = CreateVehicle(405, -2039.5, -100.0, 35.2, 270.0, 1, 1, 600);
        if (gDrivingTestVehicle[playerid] == INVALID_VEHICLE_ID) return SendClientMessage(playerid, COLOR_RED, "Не удалось создать учебную машину. Попробуйте позже."), 1;
        gDrivingTestStage[playerid] = 1;
        PutPlayerInVehicle(playerid, gDrivingTestVehicle[playerid], 0);
        DisablePlayerCheckpoint(playerid);
        SetPlayerCheckpoint(playerid, -2232.5854, 69.5824, 35.1718, 5.0);
        SendClientMessage(playerid, COLOR_GREEN, "Учебная машина арендована. Следуйте по красным точкам, не покидая машину." );
        return 1;
    }
    if (dialogid == DIALOG_POLICE_TABLET) return 1;
    if (dialogid == DIALOG_POLICE_STASH)
    {
        if (!response) return 1;
        if (gFaction[playerid] == FACTION_FBI)
        {
            if (gFactionRank[playerid] < 1 || !IsInOwnOrgInterior(playerid) || GetPlayerDistanceFromPoint(playerid, 258.5231, 76.3146, 1003.6406) > 4.0)
                return SendClientMessage(playerid, COLOR_RED, "FBI: Подойдите к маркеру оружейного склада."), 1;
            switch (listitem)
            {
                case 0: { GivePlayerWeapon(playerid, 23, 30); SendClientMessage(playerid, COLOR_GREEN, "\xd2\xe0\xe9\xe7\xe5\xf0 USP \xe2\xfb\xe4\xe0\xed (30 \xef\xe0\xf2\xf0\xee\xed\xee\xe2)."); }
                case 1: { GivePlayerWeapon(playerid, 25, 60); SendClientMessage(playerid, COLOR_GREEN, "Вы получили дробовик и 60 патронов."); }
                case 2: { GivePlayerWeapon(playerid, 29, 120); SendClientMessage(playerid, COLOR_GREEN, "Вы получили MP5 и 120 патронов."); }
                case 3: { GivePlayerWeapon(playerid, 30, 120); SendClientMessage(playerid, COLOR_GREEN, "Вы получили АК-47 и 120 патронов."); }
                case 4: { GivePlayerWeapon(playerid, 31, 120); SendClientMessage(playerid, COLOR_GREEN, "Вы получили М4 и 120 патронов."); }
                case 5: { GivePlayerWeapon(playerid, 33, 20); SendClientMessage(playerid, COLOR_GREEN, "Вы получили винтовку и 20 патронов."); }
                case 6: { SetPlayerArmour(playerid, 100.0); SendClientMessage(playerid, COLOR_GREEN, "Вы получили бронежилет."); }
            }
            return 1;
        }
        else if (gFaction[playerid] != FACTION_POLICE || !IsInPoliceStation(playerid) || GetPlayerDistanceFromPoint(playerid, 258.52, 76.8268, 1003.6406) > 4.0)
            return SendClientMessage(playerid, COLOR_RED, "Вы должны находиться у склада LSPD."), 1;
        switch (listitem)
        {
            case 0: { GivePlayerWeapon(playerid, 3, 1); SendClientMessage(playerid, COLOR_GREEN, "\xd0\xf3\xe1\xe8\xed\xea LSPD \xe2\xfb\xe4\xe0\xed."); }
            case 1: { GivePlayerWeapon(playerid, 31, 100); SendClientMessage(playerid, COLOR_GREEN, "Вы получили M4 и 100 патронов максимум за одно получение."); }
            case 2: { GivePlayerWeapon(playerid, 22, 100); SendClientMessage(playerid, COLOR_GREEN, "Вы получили пистолет и 100 патронов максимум за одно получение."); }
            case 3: { SetPlayerArmour(playerid, 100.0); SendClientMessage(playerid, COLOR_GREEN, "Вы получили бронежилет."); }
        }
        return 1;
    }
    if (dialogid == DIALOG_ORG_STASH)
    {
        if (!response) return 1;
        if (gFaction[playerid] < 1 || gFaction[playerid] > 6 || gFaction[playerid] == FACTION_POLICE || gFactionRank[playerid] < 1 || !IsInOwnOrgInterior(playerid))
            return SendClientMessage(playerid, COLOR_RED, "Доступ к складу организации потерян."), 1;
        new query[192], stockAmmo = 0, stockArmour = 0;
        format(query, sizeof query, "SELECT ammo,armour FROM org_stashes WHERE faction_id=%d", gFaction[playerid]);
        new DBResult:orgStock = db_query(gDatabase, query);
        if (orgStock && db_num_rows(orgStock)) { stockAmmo = db_get_field_int(orgStock, 0); stockArmour = db_get_field_int(orgStock, 1); }
        if (orgStock) db_free_result(orgStock);
        if (listitem == 0 || listitem == 1)
        {
            new ammoTake = (stockAmmo > 100) ? 100 : stockAmmo;
            if (ammoTake <= 0) return SendClientMessage(playerid, COLOR_RED, "На складе нет патронов."), 1;
            new weaponid = (listitem == 0) ? 31 : 22;
            GivePlayerWeapon(playerid, weaponid, ammoTake);
            format(query, sizeof query, "UPDATE org_stashes SET ammo=MAX(0,ammo-%d) WHERE faction_id=%d", ammoTake, gFaction[playerid]);
            orgStock = db_query(gDatabase, query); if (orgStock) db_free_result(orgStock);
            new msg[112]; format(msg, sizeof msg, "Вы получили оружие и %d патронов со склада организации.", ammoTake); SendClientMessage(playerid, COLOR_GREEN, msg);
        }
        else if (listitem == 2)
        {
            if (stockArmour < 1) return SendClientMessage(playerid, COLOR_RED, "На складе закончились бронежилеты."), 1;
            SetPlayerArmour(playerid, 100.0);
            format(query, sizeof query, "UPDATE org_stashes SET armour=MAX(0,armour-1) WHERE faction_id=%d", gFaction[playerid]);
            orgStock = db_query(gDatabase, query); if (orgStock) db_free_result(orgStock);
            SendClientMessage(playerid, COLOR_GREEN, "Вы получили бронежилет. Запас списан со склада.");
        }
        else if (listitem == 3)
        {
            new msg[192];
            format(query, sizeof query, "SELECT money,materials,ammo,armour FROM org_stashes WHERE faction_id=%d", gFaction[playerid]);
            orgStock = db_query(gDatabase, query);
            if (orgStock && db_num_rows(orgStock)) format(msg, sizeof msg, "Деньги: %d руб.\nМатериалы: %d\nПатроны: %d\nБронежилеты: %d", db_get_field_int(orgStock,0), db_get_field_int(orgStock,1), db_get_field_int(orgStock,2), db_get_field_int(orgStock,3));
            else format(msg, sizeof msg, "Не удалось прочитать запасы склада.");
            if (orgStock) db_free_result(orgStock);
            ShowPlayerDialog(playerid, DIALOG_HELP, DIALOG_STYLE_MSGBOX, "Склад организации", msg, "Закрыть", "");
        }
        return 1;
    }
    if (dialogid == DIALOG_GANG_STASH)
    {
        if (!response) return 1;
        if (gGang[playerid] < 1 || gGang[playerid] > 4) return 1;
        new Float:bx, Float:by, Float:bz;
        GetGangBase(gGang[playerid], bx, by, bz);
        if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0 || GetPlayerDistanceFromPoint(playerid, bx, by, bz) > 12.0)
            return SendClientMessage(playerid, COLOR_RED, "Вы должны находиться на базе своей банды."), 1;
        if (listitem == 0) ShowPlayerDialog(playerid, DIALOG_GANG_DEPOSIT, DIALOG_STYLE_INPUT, "Склад банды | Внести", "Введите сумму, которую хотите положить на склад:", "Внести", "Назад");
        else if (listitem == 1) ShowPlayerDialog(playerid, DIALOG_GANG_WITHDRAW, DIALOG_STYLE_INPUT, "Склад банды | Снять", "Введите сумму, которую хотите снять со склада:", "Снять", "Назад");
        else if (listitem == 2)
        {
            new msg[96]; format(msg, sizeof msg, "На складе банды: %d руб.", GetGangStashMoney(gGang[playerid]));
            SendClientMessage(playerid, COLOR_GREEN, msg);
        }
        else if (listitem == 3) ShowGangWeaponMenu(playerid);
        else if (listitem == 4)
        {
            SetPlayerArmour(playerid, 100.0);
            SendClientMessage(playerid, COLOR_GREEN, "\xc2\xfb \xef\xee\xeb\xf3\xf7\xe8\xeb\xe8 \xe1\xf0\xee\xed\xe5\xe6\xe8\xeb\xe5\xf2 \xed\xe0 \xf1\xea\xeb\xe0\xe4\xe5 \xe1\xe0\xed\xe4\xfb.");
        }
        return 1;
    }
    if (dialogid == DIALOG_GANG_DEPOSIT || dialogid == DIALOG_GANG_WITHDRAW)
    {
        if (!response) { ShowPlayerDialog(playerid, DIALOG_GANG_STASH, DIALOG_STYLE_LIST, "Склад банды", "Положить деньги\nСнять деньги\nБаланс склада\nОружие и патроны", "Выбрать", "Закрыть"); return 1; }
        if (gGang[playerid] < 1 || gGang[playerid] > 4) return 1;
        new Float:bx, Float:by, Float:bz;
        GetGangBase(gGang[playerid], bx, by, bz);
        if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0 || GetPlayerDistanceFromPoint(playerid, bx, by, bz) > 12.0)
            return SendClientMessage(playerid, COLOR_RED, "Вы должны находиться на базе своей банды."), 1;
        new amount = strval(inputtext), stash = GetGangStashMoney(gGang[playerid]), query[160];
        if (amount < 1 || amount > 1000000000) return SendClientMessage(playerid, COLOR_RED, "Введите корректную сумму от 1 до 1 000 000 000."), 1;
        if (dialogid == DIALOG_GANG_DEPOSIT)
        {
            if (gMoney[playerid] < amount) return SendClientMessage(playerid, COLOR_RED, "У вас недостаточно денег."), 1;
            gMoney[playerid] -= amount; GivePlayerMoney(playerid, -amount); SetGangStashMoney(gGang[playerid], stash + amount); SavePlayer(playerid);
            SendClientMessage(playerid, COLOR_GREEN, "Деньги внесены на общий склад банды.");
        }
        else
        {
            if (stash < amount) return SendClientMessage(playerid, COLOR_RED, "На складе недостаточно денег."), 1;
            gMoney[playerid] += amount; GivePlayerMoney(playerid, amount); SetGangStashMoney(gGang[playerid], stash - amount); SavePlayer(playerid);
            SendClientMessage(playerid, COLOR_GREEN, "Деньги сняты со склада банды.");
        }
        format(query, sizeof query, "SELECT money FROM gang_stashes WHERE gang_id=%d", gGang[playerid]);
        return 1;
    }
    if (dialogid == DIALOG_GANG_SKIN)
    {
        if (!response) return 1;
        if (gGang[playerid] < 1 || gGang[playerid] > 4) return 1;
        new Float:bx, Float:by, Float:bz;
        GetGangBase(gGang[playerid], bx, by, bz);
        if (GetPlayerDistanceFromPoint(playerid, bx, by, bz) > 18.0 || GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0)
            return SendClientMessage(playerid, COLOR_RED, "Вы отошли от магазина одежды."), 1;
        SetPlayerSkin(playerid, GetGangSkin(gGang[playerid], listitem + 1));
        SavePlayer(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "Вы переоделись в одежду своей банды. Скин сохранён.");
        return 1;
    }
    if (dialogid == DIALOG_GANG_WEAPONS)
    {
        if (!response) { ShowPlayerDialog(playerid, DIALOG_GANG_STASH, DIALOG_STYLE_LIST, "Склад банды", "Положить деньги\nСнять деньги\nБаланс склада\nОружие и патроны", "Выбрать", "Закрыть"); return 1; }
        if (gGang[playerid] < 1 || gGang[playerid] > 4) return 1;
        if (listitem < 0 || listitem > 5) return 1;
        new Float:weaponBaseX, Float:weaponBaseY, Float:weaponBaseZ;
        GetGangBase(gGang[playerid], weaponBaseX, weaponBaseY, weaponBaseZ);
        if (GetPlayerDistanceFromPoint(playerid, weaponBaseX, weaponBaseY, weaponBaseZ) > 12.0 || GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0)
            return SendClientMessage(playerid, COLOR_RED, "Оружейный склад доступен только на базе вашей банды."), 1;
        new weaponIds[6] = {22,24,25,29,30,31};
        new weaponNames[6][24] = {"Пистолет 9мм", "Desert Eagle", "Дробовик", "MP5", "AK-47", "M4"};
        new weaponid = weaponIds[listitem];
        new ammo = GetGangWeaponAmmo(gGang[playerid], weaponid);
        new msg[144];
        format(msg, sizeof msg, "%s\nНа складе: %d патронов", weaponNames[listitem], ammo);
        ShowPlayerDialog(playerid, DIALOG_GANG_WEAPON_ACTION, DIALOG_STYLE_LIST, msg, "Взять со склада\nПоложить на склад", "Выбрать", "Назад");
        // The selected weapon is stored per-player until the action dialog returns.
        SetPVarInt(playerid, "GangStashWeapon", weaponid);
        return 1;
    }
    if (dialogid == DIALOG_GANG_WEAPON_ACTION)
    {
        if (!response) return ShowGangWeaponMenu(playerid);
        if (listitem < 0 || listitem > 1) return 1;
        if (gGang[playerid] < 1 || gGang[playerid] > 4) return 1;
        new Float:bx, Float:by, Float:bz;
        GetGangBase(gGang[playerid], bx, by, bz);
        if (GetPlayerDistanceFromPoint(playerid, bx, by, bz) > 12.0 || GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0)
            return SendClientMessage(playerid, COLOR_RED, "Оружейный склад доступен только на базе вашей банды."), 1;
        new weaponid = GetPVarInt(playerid, "GangStashWeapon");
        if (!GangWeaponAllowed(weaponid)) return 1;
        new storedAmmo = GetGangWeaponAmmo(gGang[playerid], weaponid);
        if (listitem == 0)
        {
            if (storedAmmo < 1) return SendClientMessage(playerid, COLOR_RED, "Такого оружия или патронов сейчас нет на складе."), 1;
            new ammoTake = (storedAmmo > 100) ? 100 : storedAmmo;
            GivePlayerWeapon(playerid, weaponid, ammoTake);
            SetGangWeaponAmmo(gGang[playerid], weaponid, storedAmmo - ammoTake);
            new takeMsg[128]; format(takeMsg, sizeof takeMsg, "Вы получили оружие и %d патронов. Лимит — 100 за одно получение.", ammoTake);
            SendClientMessage(playerid, COLOR_GREEN, takeMsg);
        }
        else
        {
            new currentWeapon = GetPlayerWeapon(playerid);
            new ammo = GetPlayerAmmo(playerid);
            if (currentWeapon != weaponid || ammo < 1) return SendClientMessage(playerid, COLOR_RED, "Возьмите в руки выбранное оружие с патронами, затем снова откройте склад."), 1;
            SetPlayerAmmo(playerid, weaponid, 0);
            SetGangWeaponAmmo(gGang[playerid], weaponid, storedAmmo + ammo);
            SendClientMessage(playerid, COLOR_GREEN, "Оружие и патроны сданы на общий склад банды.");
        }
        DeletePVar(playerid, "GangStashWeapon");
        return ShowGangWeaponMenu(playerid);
    }

    if (dialogid == DIALOG_GANG)
    {
        if (!response) return 1;
        if (gFaction[playerid] != FACTION_NONE) return SendClientMessage(playerid, COLOR_RED, "Сначала выйдите из государственной организации."), 1;
        if (listitem == 4)
        {
            if (gGang[playerid] == 0) return SendClientMessage(playerid, COLOR_YELLOW, "Вы не состоите в банде."), 1;
            gGang[playerid] = 0;
            SetPlayerSkin(playerid, 23);
            if (gAccessoryModel[playerid] > 0) SetPlayerAttachedObject(playerid, 0, gAccessoryModel[playerid], 2, 0.10, 0.02, 0.00, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
            new civText[128];
            format(civText, sizeof civText, "* %s changed into civilian clothes.", gName[playerid]);
            SendLocalMessage(playerid, COLOR_PINK, civText, 20.0);
            SavePlayer(playerid);
            SendClientMessage(playerid, COLOR_GREEN, "\xc2\xfb \xef\xee\xea\xe8\xed\xf3\xeb\xe8 \xe1\xe0\xed\xe4\xf3. \xc2\xfb \xe2\xe5\xf0\xed\xf3\xeb\xe8 \xe3\xf0\xe0\xe6\xe4\xe0\xed\xf1\xea\xf3\xfe \xee\xe4\xe5\xe6\xe4\xf3.");
            return 1;
        }
        new Float:gangJoinX[4] = {2495.0, 2000.0, 2769.0, 1840.0};
        new Float:gangJoinY[4] = {-1687.0, -1114.0, -1628.0, -2035.0};
        new Float:gangJoinZ[4] = {13.5, 25.0, 10.9, 13.5};
        if (listitem < 0 || listitem > 3) return 1;
        if (GetPlayerDistanceFromPoint(playerid, gangJoinX[listitem], gangJoinY[listitem], gangJoinZ[listitem]) > 80.0)
            return SendClientMessage(playerid, COLOR_RED, "Для вступления приезжайте на базу выбранной банды. Координаты доступны через /gps."), 1;
        if (gGang[playerid] != 0) return SendClientMessage(playerid, COLOR_RED, "Вы уже в банде. Сначала покиньте её через /gang."), 1;
        gGang[playerid] = listitem + 1; SetPlayerSkin(playerid, GetGangSkin(gGang[playerid], 1)); if (gAccessoryModel[playerid] > 0) SetPlayerAttachedObject(playerid, 0, gAccessoryModel[playerid], 2, 0.10, 0.02, 0.00, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0); new gangJoinText[128]; format(gangJoinText, sizeof gangJoinText, "* %s put on gang clothes.", gName[playerid]); SendLocalMessage(playerid, COLOR_PINK, gangJoinText, 20.0); SavePlayer(playerid);
        new gangName[32];
        switch (gGang[playerid]) { case 1: gangName = "Grove Street"; case 2: gangName = "Ballas"; case 3: gangName = "Los Santos Vagos"; case 4: gangName = "Varrios Aztecas"; }
        new msg[96]; format(msg, sizeof msg, "Вы вступили в банду %s! Ваш ранг: Новичок.", gangName);
        SendClientMessage(playerid, COLOR_GREEN, msg); return 1;
    }

    if (dialogid == DIALOG_RENT_SCOOTER)
    {
        gPendingScooterChoice[playerid] = false;
        if (!response)
        {
            if (IsPlayerInAnyVehicle(playerid) && GetPlayerVehicleID(playerid) == gBaseScooter)
                RemovePlayerFromVehicle(playerid);
            SendClientMessage(playerid, COLOR_YELLOW, "Вы отказались от аренды. Скутер остался на стартовой базе.");
            return 1;
        }
        if (!gLogged[playerid] || gFaction[playerid] != FACTION_NONE || gLevel[playerid] > 3)
        {
            if (IsPlayerInAnyVehicle(playerid) && GetPlayerVehicleID(playerid) == gBaseScooter) RemovePlayerFromVehicle(playerid);
            if (gLevel[playerid] > 3)
                return SendClientMessage(playerid, COLOR_RED, "Аренда доступна только игрокам 1–3 уровня."), 1;
            return SendClientMessage(playerid, COLOR_RED, "Аренда доступна только гражданским без организации."), 1;
        }
        if (gRentalVehicle[playerid] != INVALID_VEHICLE_ID)
            return SendClientMessage(playerid, COLOR_YELLOW, "У вас уже есть арендованный скутер."), 1;
        if (gMoney[playerid] < RENT_SCOOTER_PRICE)
        {
            if (IsPlayerInAnyVehicle(playerid) && GetPlayerVehicleID(playerid) == gBaseScooter) RemovePlayerFromVehicle(playerid);
            return SendClientMessage(playerid, COLOR_RED, "Для аренды нужно 250 рублей. Скутер остался на базе."), 1;
        }
        if (gBaseScooter == INVALID_VEHICLE_ID || !IsPlayerInAnyVehicle(playerid) || GetPlayerVehicleID(playerid) != gBaseScooter)
            return SendClientMessage(playerid, COLOR_RED, "Скутер уже недоступен. Попробуйте сесть на следующий."), 1;
        new rentedVehicle = gBaseScooter;
        gMoney[playerid] -= RENT_SCOOTER_PRICE;
        ResetPlayerMoney(playerid);
        GivePlayerMoney(playerid, gMoney[playerid]);
        UpdateVexHud(playerid);
        gRentalVehicle[playerid] = rentedVehicle;
        gBaseScooter = INVALID_VEHICLE_ID;
        // Move the rented scooter away from the spawn point, to the road-side exit near the station gates.
        SetVehiclePos(rentedVehicle, 1781.5, -1904.0, 13.5);
        SetVehicleZAngle(rentedVehicle, 90.0);
        SetVehicleVirtualWorld(rentedVehicle, 0);
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        PutPlayerInVehicle(playerid, rentedVehicle, 0);
        SpawnBaseScooter();
        SavePlayer(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "Вы арендовали Faggio за 250 рублей. Вы перемещены к воротам стартовой базы — можно выезжать!");
        SendClientMessage(playerid, COLOR_GREEN, "На базе уже появился новый скутер для следующего новичка.");
        return 1;
    }

    if (dialogid == DIALOG_CAR_DEALER)
    {
        if (!response) return 1;
        if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0 || !IsPlayerInRangeOfPoint(playerid, 18.0, 2131.0, -1150.0, 24.1))
            return SendClientMessage(playerid, COLOR_YELLOW, "Вы отошли от автосалона."), 1;
        if (IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_YELLOW, "Выйдите из транспорта перед покупкой."), 1;
        new model, price;
        switch (listitem)
        {
            case 0: { model = 401; price = 8000; }
            case 1: { model = 404; price = 9500; }
            case 2: { model = 436; price = 12000; }
            case 3: { model = 445; price = 18000; }
            case 4: { model = 451; price = 45000; }
            case 5: { model = 560; price = 55000; }
            default: return 1;
        }
        if (gMoney[playerid] < price) return SendClientMessage(playerid, COLOR_RED, "Недостаточно денег для покупки этого автомобиля."), 1;
        if (gOwnedCarVehicle[playerid] != INVALID_VEHICLE_ID && GetVehicleModel(gOwnedCarVehicle[playerid]) != 0)
        {
            if (IsFleetVehicleOccupied(gOwnedCarVehicle[playerid])) return SendClientMessage(playerid, COLOR_YELLOW, "Сначала освободите свой предыдущий автомобиль."), 1;
            DestroyVehicle(gOwnedCarVehicle[playerid]);
            gOwnedCarVehicle[playerid] = INVALID_VEHICLE_ID;
        }
        if (!TakeCash(playerid, price)) return SendClientMessage(playerid, COLOR_RED, "Не удалось списать оплату."), 1;
        gOwnedCarModel[playerid] = model;
        new query[192];
        format(query, sizeof query, "UPDATE accounts SET ownedcar=%d WHERE name='%q'", model, gName[playerid]);
        gResult = db_query(gDatabase, query); if (gResult) db_free_result(gResult);
        gOwnedCarVehicle[playerid] = CreateVehicle(model, 2137.0, -1155.0, 24.5, 90.0, 1, 1, 300);
        if (gOwnedCarVehicle[playerid] == INVALID_VEHICLE_ID)
        {
            SendClientMessage(playerid, COLOR_RED, "Оплата сохранена, но автомобиль не удалось вывести. Используйте /mycar у автосалона.");
            SavePlayer(playerid);
            return 1;
        }
        new vid = gOwnedCarVehicle[playerid];
        gPersonalVehicleOwner[vid] = playerid; gVehicleFuel[vid] = 100; gFuelLastX[vid] = 0.0; gFuelLastY[vid] = 0.0; gFuelLastZ[vid] = 0.0;
        PutPlayerInVehicle(playerid, vid, 0);
        SavePlayer(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "Поздравляем с покупкой! Автомобиль сохранён за вашим аккаунтом. /mycar — получить его у автосалона.");
        return 1;
    }
    if (dialogid == DIALOG_REGISTER)
    {
        if (!response)
        {
            ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "VEXORIUM | REGISTRATION", "Create a password with 4-64 characters to continue.", "CREATE", "CANCEL");
            return 1;
        }
        if (strlen(inputtext) < 4 || strlen(inputtext) > 64)
        {
            ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "VEXORIUM | СОЗДАНИЕ АККАУНТА", "================================\n             V E X O R I U M\n\nПароль должен содержать 4-64 символа.\nВведи пароль ещё раз.\nИспользуй пароль, который сможешь запомнить.", "СОЗДАТЬ", "ВЫХОД");
            return 1;
        }
        format(gPassword[playerid], 65, "%s", inputtext);
        new query[512];
        format(query, sizeof query, "INSERT INTO accounts (name,password,money,level,kills,deaths,skin,x,y,z,angle,job,admin,faction,faction_rank) VALUES ('%q','%q',5000,1,0,0,23,1685.0,-2333.0,13.5,0.0,0,%d,0,0)", gName[playerid], gPassword[playerid], IsOwner(playerid) ? 5 : 0);
        gResult = db_query(gDatabase, query);
        if (!gResult)
        {
            SendClientMessage(playerid, COLOR_RED, "[VEXORIUM] Database error while creating account. Please reconnect and try again.");
            return 1;
        }
        if (gResult) db_free_result(gResult);
        gMoney[playerid] = 5000; gLevel[playerid] = 1; gExperience[playerid] = 0; gKills[playerid] = 0; gDeaths[playerid] = 0; gJob[playerid] = 0; gFaction[playerid] = 0; gFactionRank[playerid] = 0; gOwnedCarModel[playerid] = 0; gSpawnPreference[playerid] = 0;
        gAdmin[playerid] = IsOwner(playerid) ? 5 : 0;
        gLogged[playerid] = true;
        if (gAccessoryModel[playerid] > 0) SetPlayerAttachedObject(playerid, 0, gAccessoryModel[playerid], 2, 0.10, 0.02, 0.00, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
        SetPlayerScore(playerid, gLevel[playerid]);
        SpawnLoggedPlayer(playerid, 1685.0, -2333.0, 13.5, 0.0, 23);
        SendClientMessage(playerid, COLOR_GREEN, "Добро пожаловать на VEXORIUM RP! Вам начислено 5000 рублей.");
        SendClientMessage(playerid, COLOR_WHITE, "Введите /help для списка команд.");
        if (gAdmin[playerid] == 5) SendClientMessage(playerid, COLOR_ORANGE, "[VEXORIUM] Вам назначен уровень владельца сервера (5).");
        SavePlayer(playerid);
        return 1;
    }
    if (dialogid == DIALOG_LOGIN)
    {
        if (!response)
        {
            ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "VEXORIUM | LOGIN", "Enter your account password to continue.", "LOGIN", "CANCEL");
            return 1;
        }
        new query[512];
        format(query, sizeof query, "SELECT password,money,level,kills,deaths,skin,x,y,z,angle,job,admin,faction,faction_rank,ownedcar,spawnpref,gang,experience,license_driver,license_weapon,license_boat,license_air,has_passport,medkits,food,water,accessory,repairkits,simcards,lockpicks FROM accounts WHERE name='%q'", gName[playerid]);
        new DBResult:authResult = db_query(gDatabase, query);
        if (!authResult) { printf("[VEXORIUM AUTH ERROR] SQLite query failed for %s", gName[playerid]); SendClientMessage(playerid, COLOR_RED, "Ошибка базы данных при входе. Попробуй позже."); return 1; }
        if (!db_num_rows(authResult)) { db_free_result(authResult); printf("[VEXORIUM AUTH ERROR] Account row not found for %s", gName[playerid]); Kick(playerid); return 1; }
        new stored[65];
        db_get_field(authResult, 0, stored, sizeof stored);
        if (strcmp(stored, inputtext, false) != 0)
        {
            db_free_result(authResult);
            ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "VEXORIUM | ДОБРО ПОЖАЛОВАТЬ", "================================\n             V E X O R I U M\n\nНеверный пароль.\nПроверь ввод и попробуй ещё раз.\nПароль чувствителен к регистру.", "ВОЙТИ", "ВЫХОД");
            return 1;
        }
        // Read all account columns before running another SQLite query.
        // Some SQLite builds invalidate an open result after the next query.
        gMoney[playerid] = db_get_field_int(authResult, 1);
        gCurrentHouse[playerid] = 0;
        gLevel[playerid] = db_get_field_int(authResult, 2);
        gKills[playerid] = db_get_field_int(authResult, 3);
        gDeaths[playerid] = db_get_field_int(authResult, 4);
        new skin = db_get_field_int(authResult, 5);
        new Float:x = db_get_field_float(authResult, 6);
        new Float:y = db_get_field_float(authResult, 7);
        new Float:z = db_get_field_float(authResult, 8);
        new Float:a = db_get_field_float(authResult, 9);
        gJob[playerid] = db_get_field_int(authResult, 10);
        gAdmin[playerid] = db_get_field_int(authResult, 11);
        gFaction[playerid] = db_get_field_int(authResult, 12);
        gFactionRank[playerid] = db_get_field_int(authResult, 13);
        // If a police officer saved a non-uniform skin, remember that they are in civilian clothes.
        gPoliceCivilianSkin[playerid] = (gFaction[playerid] == FACTION_POLICE && skin != GetFactionSkin(gFaction[playerid], gFactionRank[playerid]));
        gOwnedCarModel[playerid] = db_get_field_int(authResult, 14);
        gSpawnPreference[playerid] = db_get_field_int(authResult, 15);
        gGang[playerid] = db_get_field_int(authResult, 16);
        gExperience[playerid] = db_get_field_int(authResult, 17);
        gLicenseDriver[playerid] = db_get_field_int(authResult, 18);
        gLicenseWeapon[playerid] = db_get_field_int(authResult, 19);
        gLicenseBoat[playerid] = db_get_field_int(authResult, 20);
        gLicenseAir[playerid] = db_get_field_int(authResult, 21);
        gHasPassport[playerid] = db_get_field_int(authResult, 22);
        gMedkits[playerid] = db_get_field_int(authResult, 23);
        gFood[playerid] = db_get_field_int(authResult, 24);
        gWater[playerid] = db_get_field_int(authResult, 25);
        gAccessoryModel[playerid] = db_get_field_int(authResult, 26);
        gRepairKits[playerid] = db_get_field_int(authResult, 27);
        gSimCards[playerid] = db_get_field_int(authResult, 28);
        gLockpicks[playerid] = db_get_field_int(authResult, 29);
        if (IsOwner(playerid)) gAdmin[playerid] = 5;
        db_free_result(authResult);

        // Bank queries are deliberately run after the account SELECT is freed.
        gBankMoney[playerid] = 0;
        new bankQuery[192];
        format(bankQuery, sizeof bankQuery, "INSERT OR IGNORE INTO bank_accounts (name,balance) VALUES ('%q',0)", gName[playerid]);
        new DBResult:bankInit = db_query(gDatabase, bankQuery);
        if (bankInit) db_free_result(bankInit);
        format(bankQuery, sizeof bankQuery, "SELECT balance FROM bank_accounts WHERE name='%q'", gName[playerid]);
        new DBResult:bankRes = db_query(gDatabase, bankQuery);
        if (bankRes && db_num_rows(bankRes)) gBankMoney[playerid] = db_get_field_int(bankRes, 0);
        if (bankRes) db_free_result(bankRes);
        printf("[VEXORIUM AUTH] Account data loaded for playerid %d (%s).", playerid, gName[playerid]);
        gLogged[playerid] = true;
        if (gAccessoryModel[playerid] > 0) SetPlayerAttachedObject(playerid, 0, gAccessoryModel[playerid], 2, 0.10, 0.02, 0.00, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
        SetPlayerScore(playerid, gLevel[playerid]);
        UpdatePlayerRoleColor(playerid);
        SpawnLoggedPlayer(playerid, x, y, z, a, skin);
        new welcome[144];
        format(welcome, sizeof welcome, "  Добро пожаловать, %s!", gName[playerid]);
        SendClientMessage(playerid, COLOR_GREEN, "========================================");
        SendClientMessage(playerid, COLOR_GREEN, "  VEXORIUM RP | ВАШЕ ИСТОРИЯ НАЧИНАЕТСЯ");
        SendClientMessage(playerid, COLOR_WHITE, welcome);
        SendClientMessage(playerid, COLOR_WHITE, "  Центр игрока: /hub | Инвентарь: /inv | Телефон: /phone");
        SendClientMessage(playerid, COLOR_GREEN, "========================================");
        if (gAdmin[playerid] == 5) SendClientMessage(playerid, COLOR_ORANGE, "[VEXORIUM] У вас уровень владельца сервера (5).");
        return 1;
    }
    if (dialogid == DIALOG_FACTION_GARAGE)
    {
        if (!response) return 1;
        if (gFaction[playerid] == FACTION_NONE || gFactionRank[playerid] < 1)
            return SendClientMessage(playerid, COLOR_RED, "Вы не состоите в организации."), 1;
        if (listitem < 0 || listitem > 4 || gFactionRank[playerid] < (listitem * 2 + 1))
            return SendClientMessage(playerid, COLOR_RED, "Транспорт не доступен на вашем ранге."), 1;
        new Float:gx, Float:gy, Float:gz;
        GetOrgGarage(gFaction[playerid], gx, gy, gz);
        if (gFaction[playerid] == FACTION_POLICE)
        {
            if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0 ||
                !IsPlayerInRangeOfPoint(playerid, 10.0, 1568.4843, -1690.4116, 5.8906)) return SendClientMessage(playerid, COLOR_RED, "Вы уже не у гаража."), 1;
        }
        else if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0 ||
                 !IsPlayerInRangeOfPoint(playerid, 10.0, gx, gy, gz)) return SendClientMessage(playerid, COLOR_RED, "Вы уже не у гаража."), 1;
        if (IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_YELLOW, "Сначала выйдите из текущего транспорта."), 1;
        // Each /garage request creates a separate vehicle for this employee.
        // The locked parking-slot vehicle remains available for the next employee.
        if (gFactionVehicle[playerid] != INVALID_VEHICLE_ID && GetVehicleModel(gFactionVehicle[playerid]) != 0)
        {
            if (IsFleetVehicleOccupied(gFactionVehicle[playerid]))
                return SendClientMessage(playerid, COLOR_YELLOW, "\xD1\xED\xE0\xF7\xE0\xEB\xE0 \xE2\xE5\xF0\xED\xE8\xF2\xE5 \xF1\xE2\xEE\xFE \xF1\xEB\xF3\xE6\xE5\xE1\xED\xF3\xFE \xEC\xE0\xF8\xE8\xED\xF3."), 1;
            new oldFactionVehicle = gFactionVehicle[playerid];
            if (gVehicleReturnTimer[oldFactionVehicle]) { KillTimer(gVehicleReturnTimer[oldFactionVehicle]); gVehicleReturnTimer[oldFactionVehicle] = 0; }
            gVehicleFaction[oldFactionVehicle] = 0;
            gVehicleTier[oldFactionVehicle] = 0;
            gFactionVehicleOwner[oldFactionVehicle] = INVALID_PLAYER_ID;
            DestroyVehicle(oldFactionVehicle);
            gFactionVehicle[playerid] = INVALID_VEHICLE_ID;
        }
        new Float:sx, Float:sy, Float:sz, Float:sa;
        new faction = gFaction[playerid];
        GetFactionVehicleSpawn(faction, listitem, sx, sy, sz, sa);
        new model = GetFactionVehicleModel(faction, listitem);
        new vehicleid = CreateVehicle(model, sx, sy, sz, sa, 1, 1, 180);
        if (vehicleid == INVALID_VEHICLE_ID || GetVehicleModel(vehicleid) == 0)
            return SendClientMessage(playerid, COLOR_RED, "\xCD\xE5 \xF3\xE4\xE0\xEB\xEE\xF1\xFC \xE2\xFB\xE4\xE0\xF2\xFC \xEC\xE0\xF8\xE8\xED\xF3. \xCF\xEE\xEF\xF0\xEE\xE1\xF3\xE9\xF2\xE5 \xE5\xF9\xB8 \xF0\xE0\xE7."), 1;
        gFactionVehicle[playerid] = vehicleid;
        gVehicleFaction[vehicleid] = gFaction[playerid];
        gVehicleTier[vehicleid] = listitem;
        gFactionVehicleOwner[vehicleid] = playerid;
        gVehicleReturnTimer[vehicleid] = 0;
        gVehicleFuel[vehicleid] = 100;
        gFuelLastX[vehicleid] = 0.0; gFuelLastY[vehicleid] = 0.0; gFuelLastZ[vehicleid] = 0.0;
        SetVehicleVirtualWorld(vehicleid, 0);
        for (new p = 0; p < MAX_PLAYERS; p++)
            if (IsPlayerConnected(p)) SetVehicleParamsForPlayer(vehicleid, p, 0, (p == playerid) ? 0 : 1);
        PutPlayerInVehicle(playerid, vehicleid, 0);
        new factionName[32], vehicleName[48], garageMsg[160];
        GetFactionName(gFaction[playerid], factionName, sizeof factionName);
        GetFactionVehicleInfo(gFaction[playerid], listitem, vehicleName, sizeof vehicleName);
        format(garageMsg, sizeof garageMsg, "\xC0\xE2\xF2\xEE\xEF\xE0\xF0\xEA %s: \xE2\xFB \xE7\xE0\xE1\xF0\xE0\xEB\xE8 %s. \xD3 \xEA\xE0\xE6\xE4\xEE\xE3\xEE \xF1\xEE\xF2\xF0\xF3\xE4\xED\xE8\xEA\xE0 \xF1\xE2\xEE\xFF \xEC\xE0\xF8\xE8\xED\xE0.", factionName, vehicleName);
        SendClientMessage(playerid, COLOR_GREEN, garageMsg);
        return 1;
    }
    if (dialogid == DIALOG_MAIN_MENU)
    {
        if (!response) return 1;
        switch (listitem)
        {
            case 1: OnPlayerCommandText(playerid, "/stats");
            case 2: ShowSpawnMenu(playerid);
            case 4: OnPlayerCommandText(playerid, "/gps");
            case 5: OnPlayerCommandText(playerid, "/job");
            case 6: OnPlayerCommandText(playerid, "/leaders");
            case 8: OnPlayerCommandText(playerid, "/rules");
            case 9: OnPlayerCommandText(playerid, "/help");
            case 11: OnPlayerCommandText(playerid, "/inv");
            case 12: OnPlayerCommandText(playerid, "/phone");
            case 13: OnPlayerCommandText(playerid, "/shop");
        }
        return 1;
    }
    if (dialogid == DIALOG_POLICE_MENU)
    {
        if (!response) return 1;
        if (!IsInPoliceStation(playerid)) return SendClientMessage(playerid, COLOR_RED, "Вы вышли из участка."), 1;
        switch (listitem)
        {
            case 0: { SetPlayerPos(playerid, 246.4, 63.9, 1003.6); SetPlayerFacingAngle(playerid, 180.0); }
            case 1: { SetPlayerPos(playerid, 251.4, 68.0, 1003.6); SetPlayerFacingAngle(playerid, 90.0); }
            case 2: { SetPlayerPos(playerid, 253.8, 72.2, 1003.6); SetPlayerFacingAngle(playerid, 0.0); }
            case 3: { SetPlayerPos(playerid, 264.4, 77.5, 1001.0); SetPlayerFacingAngle(playerid, 90.0); }
            case 4:
            {
                if (gFaction[playerid] != FACTION_POLICE || gFactionRank[playerid] < 1)
                    return SendClientMessage(playerid, COLOR_RED, "Раздевалка предназначена только для сотрудников полиции."), 1;
                SetPlayerPos(playerid, 255.3, 77.4, 1003.6);
                SetPlayerFacingAngle(playerid, 180.0);
                SendClientMessage(playerid, COLOR_GREEN, "Вы в раздевалке. Встаньте на маркер одежды, чтобы переодеться по рангу.");
            }
            case 5:
            {
                new Float:gx, Float:gy, Float:gz;
                GetOrgGarage(FACTION_POLICE, gx, gy, gz);
                SetPlayerInterior(playerid, 0);
                SetPlayerVirtualWorld(playerid, 0);
                SetPlayerPos(playerid, 1568.4843, -1690.4116, 5.8906);
                SetPlayerFacingAngle(playerid, 90.0);
                SetCameraBehindPlayer(playerid);
                SendClientMessage(playerid, COLOR_GREEN, "Вы вышли к гаражу LSPD. Используйте /garage для выдачи машины.");
                return 1;
            }
            case 6:
            {
                SetPlayerInterior(playerid, 0);
                SetPlayerVirtualWorld(playerid, 0);
                SetPlayerPos(playerid, 1540.8, -1675.5, 13.55);
                SetPlayerFacingAngle(playerid, 270.0);
                SetCameraBehindPlayer(playerid);
                return 1;
            }
        }
        SetPlayerInterior(playerid, 6);
        SetPlayerVirtualWorld(playerid, 0);
        SetCameraBehindPlayer(playerid);
        return 1;
    }
    if (dialogid == DIALOG_ORG_MENU)
    {
        if (!response) return 1;
        if (gFaction[playerid] == FACTION_NONE || !IsInOwnOrgInterior(playerid))
            return SendClientMessage(playerid, COLOR_RED, "Вы покинули штаб организации."), 1;
        switch (listitem)
        {
            case 0: { if (gFaction[playerid] == FACTION_FBI) SetPlayerPos(playerid, 246.4510, 65.5860, 1003.6410); else SetPlayerPos(playerid, 2496.0, -1692.0, 1014.7); SendClientMessage(playerid, COLOR_GREEN, "Главный холл штаба."); }
            case 1: { if (gFaction[playerid] == FACTION_FBI) SetPlayerPos(playerid, 249.0, 70.0, 1003.6410); else SetPlayerPos(playerid, 2491.0, -1687.0, 1014.7); SendClientMessage(playerid, COLOR_GREEN, "Кабинет руководства организации."); }
            case 2: { if (gFaction[playerid] == FACTION_FBI) SetPlayerPos(playerid, 252.0, 75.0, 1003.6410); else SetPlayerPos(playerid, 2501.0, -1687.0, 1014.7); SendClientMessage(playerid, COLOR_GREEN, "Комната собраний. Руководитель может использовать /formation."); }
            case 3:
            {
                new Float:x, Float:y, Float:z;
                GetOrgGarage(gFaction[playerid], x, y, z);
                SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
                SetPlayerPos(playerid, x - 1.5, y - 2.5, z); SetPlayerFacingAngle(playerid, 90.0);
                SetCameraBehindPlayer(playerid);
                SendClientMessage(playerid, COLOR_GREEN, "Вы вышли к автопарку. Используйте /garage для служебного транспорта.");
                return 1;
            }
            case 4:
            {
                new Float:x, Float:y, Float:z;
                GetOrgExterior(gFaction[playerid], x, y, z);
                SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
                SetPlayerPos(playerid, x + 2.0, y, z); SetPlayerFacingAngle(playerid, (gFaction[playerid] == FACTION_FBI) ? 310.92 : 90.0);
                SetCameraBehindPlayer(playerid);
                SendClientMessage(playerid, COLOR_GREEN, "Вы вышли из здания организации.");
                return 1;
            }
        }
        if (gFaction[playerid] == FACTION_FBI) { SetPlayerInterior(playerid, 6); SetPlayerVirtualWorld(playerid, 100 + FACTION_FBI); }
        else { SetPlayerInterior(playerid, 3); SetPlayerVirtualWorld(playerid, 100 + gFaction[playerid]); }
        SetCameraBehindPlayer(playerid);
        return 1;
    }
    if (dialogid == DIALOG_SPAWN)
    {
        gSpawnMenuShown[playerid] = false;
        if (!response) { ShowSpawnMenu(playerid); return 1; }
        if (gFaction[playerid] >= FACTION_CITYHALL && gFaction[playerid] <= FACTION_FBI)
            gSpawnPreference[playerid] = (listitem == 0) ? 1 : 2;
        else
            gSpawnPreference[playerid] = 2;
        ApplySavedSpawn(playerid);
        SavePlayer(playerid);
        SendClientMessage(playerid, COLOR_YELLOW, "Место появления сохранено. Вы будете появляться здесь при следующих входах и после смерти. Изменить выбор можно через /spawn.");
        return 1;
    }
    if (dialogid == DIALOG_GPS)
    {
        if (!response) return 1;
        if (gWorkStage[playerid] > 0) return SendClientMessage(playerid, COLOR_YELLOW, "Сначала заверши или отмени текущий рабочий маршрут."), 1;
        if (listitem == 0)
            ShowPlayerDialog(playerid, DIALOG_GPS_PUBLIC, DIALOG_STYLE_LIST, "VEXORIUM RP | Общественные места", "Мэрия\nБольница\nБанк\nАвтовокзал\nЦентр города\nАвтошкола", "Маршрут", "Назад");
        else if (listitem == 1)
            ShowPlayerDialog(playerid, DIALOG_GPS_ORGS, DIALOG_STYLE_LIST, "VEXORIUM RP | Организации", "Мэрия\nПолиция LSPD\nБольница\nАрмия\nВМФ\nВВС\nFBI — Федеральное бюро", "Маршрут", "Назад");
        else if (listitem == 2)
            ShowPlayerDialog(playerid, DIALOG_GPS_JOBS, DIALOG_STYLE_LIST, "VEXORIUM RP | Работы для новичков", "Шахта\nРыбалка\nГрузчик\nТаксист\nВодитель автобуса\nАвтоугонщик (с 3 уровня)", "Маршрут", "Назад");
        else if (listitem == 3)
            ShowPlayerDialog(playerid, DIALOG_GPS_GANGS, DIALOG_STYLE_LIST, "VEXORIUM RP | Нелегальные организации", "Grove Street\nBallas\nLos Santos Vagos\nVarrios Los Aztecas\nАвтоугон", "Маршрут", "Назад");
        return 1;
    }
    if (dialogid == DIALOG_GPS_PUBLIC || dialogid == DIALOG_GPS_ORGS || dialogid == DIALOG_GPS_JOBS || dialogid == DIALOG_GPS_GANGS)
    {
        if (!response) { ShowGPS(playerid); return 1; }
        if (gWorkStage[playerid] > 0) return SendClientMessage(playerid, COLOR_YELLOW, "Сначала заверши или отмени текущий рабочий маршрут."), 1;
        new Float:x, Float:y, Float:z;
        if (dialogid == DIALOG_GPS_PUBLIC)
        {
            switch (listitem)
            {
                case 0: { x = 1481.0; y = -1771.0; z = 18.8; }
                case 1: { x = 1178.0; y = -1323.0; z = 14.1; }
                case 2: { x = 1462.0; y = -1010.0; z = 26.8; }
                case 3: { x = 1810.0; y = -1900.0; z = 13.4; }
                case 4: { x = 1481.0; y = -1771.0; z = 18.8; }
                case 5: { x = -2026.8; y = -96.5; z = 35.2; }
                default: return 1;
            }
        }
        else if (dialogid == DIALOG_GPS_ORGS)
        {
            switch (listitem)
            {
                case 0: { x = 1481.0; y = -1771.0; z = 18.8; }
                case 1: { x = 1555.0; y = -1675.0; z = 16.2; }
                case 2: { x = 1178.0; y = -1323.0; z = 14.1; }
                case 3: { x = 2750.0; y = -2450.0; z = 13.6; }
                case 4: { x = 213.0; y = 1900.0; z = 17.6; }
                case 5: { x = 1685.0; y = -2333.0; z = 13.5; }
                case 6: { x = -2252.2521; y = 2312.0034; z = 4.9421; } // FBI garage
                default: return 1;
            }
        }
        else if (dialogid == DIALOG_GPS_GANGS)
        {
            if (listitem == 4)
            {
                if (!gCarjackActive[playerid] || gCarjackVehicle[playerid] == INVALID_VEHICLE_ID || GetVehicleModel(gCarjackVehicle[playerid]) == 0)
                    return SendClientMessage(playerid, COLOR_YELLOW, "[VEXORIUM] \xc7\xe0\xef\xf3\xf1\xf2\xe8\xf2\xe5 \xe0\xe2\xf2\xee\xf3\xe3\xee\xed\xf9\xe8\xea\xe0 \xe2 \xf0\xe0\xe1\xee\xf2\xf3 \xf7\xe5\xf0\xe5\xe7 /job, \xe7\xe0\xf2\xe5\xec /work."), 1;
                if (gWorkStage[playerid] == 11)
                    GetGangBase(gCarjackDestination[playerid], x, y, z);
                else
                    GetVehiclePos(gCarjackVehicle[playerid], x, y, z);
            }
            else
            {
                switch (listitem)
                {
                    case 0: { x = 2495.0; y = -1687.0; z = 13.5; }
                    case 1: { x = 2000.0; y = -1114.0; z = 25.0; }
                    case 2: { x = 2769.0; y = -1628.0; z = 10.9; }
                    case 3: { x = 1840.0; y = -2035.0; z = 13.5; }
                    default: return 1;
                }
            }
        }
        else
        {
            switch (listitem)
            {
                case 0: { x = 820.0; y = 856.0; z = 12.0; }
                case 1: { x = 2195.0; y = -2254.0; z = 13.5; }
                case 2: { x = 1479.0; y = -1739.0; z = 13.5; }
                case 3: { x = 1810.0; y = -1900.0; z = 13.4; }
                case 4: { x = 1685.0; y = -2333.0; z = 13.5; }
                default: return 1;
            }
        }
        SetPlayerCheckpoint(playerid, x, y, z, 5.0);
        gGpsActive[playerid] = true;
        SendClientMessage(playerid, COLOR_GREEN, "[VEXORIUM GPS] Маршрут отмечен на радаре. GPS не телепортирует — следуй к отметке.");
        return 1;
    }
    if (dialogid == DIALOG_CARJACK_HACK)
    {
        if (!response) return 1;
        if (!gCarjackActive[playerid] || gCarjackVehicle[playerid] == INVALID_VEHICLE_ID || GetVehicleModel(gCarjackVehicle[playerid]) == 0) return 1;
        new Float:x, Float:y, Float:z;
        GetVehiclePos(gCarjackVehicle[playerid], x, y, z);
        if (GetPlayerDistanceFromPoint(playerid, x, y, z) > 5.0) return SendClientMessage(playerid, COLOR_RED, "Вы отошли слишком далеко от машины."), 1;
        if (listitem != gCarjackCode[playerid])
        {
            SendClientMessage(playerid, COLOR_RED, "Неверный провод! Замок не открыт. Попробуйте /hack ещё раз.");
            return 1;
        }
        gCarjackUnlocked[playerid] = true;
        SetVehicleParamsEx(gCarjackVehicle[playerid], 0, 0, 0, 0, 0, 0, 0);
        SetVehicleParamsForPlayer(gCarjackVehicle[playerid], playerid, 0, 0);
        DisablePlayerCheckpoint(playerid);
        AnnounceCarjack(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "Замок открыт! Садитесь за руль и доставьте машину на базу любой банды. За сдачу начислится 100000 рублей.");
        return 1;
    }
    if (dialogid == DIALOG_JOB)
    {
        if (!response) return 1;
        if (gWorkStage[playerid] > 0) return SendClientMessage(playerid, COLOR_RED, "Сначала завершите текущий маршрут."), 1;
        if (listitem < 0 || listitem > 4) return 1;
        if (listitem == 4 && gLevel[playerid] < 3) return SendClientMessage(playerid, COLOR_RED, "Автоугонщик доступен с 3 уровня."), 1;
        gJob[playerid] = listitem + 1;
        SavePlayer(playerid);
        if (listitem == 0) SendClientMessage(playerid, COLOR_GREEN, "Вы устроились таксистом. Введите /work, чтобы начать маршрут.");
        else if (listitem == 1) SendClientMessage(playerid, COLOR_GREEN, "Вы устроились дальнобойщиком. Введите /work, чтобы начать маршрут.");
        else if (listitem == 2) SendClientMessage(playerid, COLOR_GREEN, "Вы устроились водителем автобуса. Введите /work, чтобы начать маршрут.");
        else if (listitem == 3) SendClientMessage(playerid, COLOR_GREEN, "Вы устроились шахтёром. Доберитесь до шахты и введите /work, чтобы начать добычу.");
        else SendClientMessage(playerid, COLOR_GREEN, "Вы устроились автоугонщиком. С 3 уровня используйте /work, чтобы найти случайную машину.");
        return 1;
    }
    return 0;
}

public ReleaseJailedPlayer(playerid)
{
    if (!IsPlayerConnected(playerid) || !gIsJailed[playerid]) return 1;
    gJailTimer[playerid] = 0;
    gIsJailed[playerid] = false;
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerPos(playerid, 1540.8, -1675.5, 13.55);
    SetPlayerFacingAngle(playerid, 270.0);
    SetCameraBehindPlayer(playerid);
    SendClientMessage(playerid, COLOR_GREEN, "Срок заключения окончен. Вы освобождены из КПЗ.");
    return 1;
}

public SavePlayer(playerid)
{
    if (!gLogged[playerid] || gDatabase == DB:0) return 0;
    new Float:x, Float:y, Float:z, Float:a, query[1024];
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    format(query, sizeof query,
        "UPDATE accounts SET money=%d,level=%d,experience=%d,kills=%d,deaths=%d,skin=%d,x=%f,y=%f,z=%f,angle=%f,job=%d,admin=%d,faction=%d,faction_rank=%d,spawnpref=%d,gang=%d,license_driver=%d,license_weapon=%d,license_boat=%d,license_air=%d,has_passport=%d,medkits=%d,food=%d,water=%d,accessory=%d,repairkits=%d,simcards=%d,lockpicks=%d WHERE name='%q'",
        gMoney[playerid], gLevel[playerid], gExperience[playerid], gKills[playerid], gDeaths[playerid],
        GetPlayerSkin(playerid), x, y, z, a, gJob[playerid], gAdmin[playerid], gFaction[playerid],
        gFactionRank[playerid], gSpawnPreference[playerid], gGang[playerid], gLicenseDriver[playerid],
        gLicenseWeapon[playerid], gLicenseBoat[playerid], gLicenseAir[playerid], gHasPassport[playerid], gMedkits[playerid], gFood[playerid], gWater[playerid], gAccessoryModel[playerid], gRepairKits[playerid], gSimCards[playerid], gLockpicks[playerid], gName[playerid]);
    gResult = db_query(gDatabase, query);
    if (gResult) db_free_result(gResult);
    return 1;
}
