#include <a_samp>
#pragma dynamic 32768

#if !defined INVALID_PICKUP
    #define INVALID_PICKUP 0
#endif
#define PICKUP_TELEPORT_COOLDOWN 4000

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
#define DIALOG_HOUSE_CAPTCHA 1091
#define DIALOG_ORG_INVITE 1092
#define DIALOG_ADMIN_SPEC 1200
#define DIALOG_ADMIN_SPEC_INPUT 1201
#define VX_HOUSE_COUNT 12
#define DIALOG_GPS_PUBLIC 1013
#define DIALOG_GPS_ORGS 1014
#define DIALOG_GPS_JOBS 1015
#define DIALOG_GPS_GANGS 1016
#define DIALOG_GPS_WORKS 1027
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
new gHunger[MAX_PLAYERS];
new gThirst[MAX_PLAYERS];
new gEnergy[MAX_PLAYERS];
new gLastRestTick[MAX_PLAYERS];
new gRepairKits[MAX_PLAYERS];
new gSimCards[MAX_PLAYERS];
new gLockpicks[MAX_PLAYERS];
new gMarketPickup;
new bool:gCarjackPursuitNotified[MAX_PLAYERS];
new gPhoneSmsTarget[MAX_PLAYERS];
new gCurrentHouse[MAX_PLAYERS];
new gHousePending[MAX_PLAYERS];
new gHouseCaptchaA[MAX_PLAYERS];
new gHouseCaptchaB[MAX_PLAYERS];
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
new gAdminMuteUntil[MAX_PLAYERS];
new gAdminMuteReason[MAX_PLAYERS][96];
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
new gVXAccountSkin[MAX_PLAYERS]; // Civilian appearance, independent from job and uniform.
#define VX_CLOTHES_LOCATIONS 3
#define VX_CLOTHES_COUNT 12
new gVXClothesPickup[VX_CLOTHES_LOCATIONS];
new gVXClothesPreview[MAX_PLAYERS];
new gVXClothesBefore[MAX_PLAYERS];
new const Float:gVXClothesPos[VX_CLOTHES_LOCATIONS][3] =
{
    {2244.4,-1665.1,15.4}, // Los Santos: Binco
    {-1694.1,951.1,24.9}, // San Fierro: clothing storefront
    {2090.4,2224.2,10.8} // Las Venturas: clothing storefront
};
new const gVXClothesModel[VX_CLOTHES_COUNT] = {7,14,20,23,46,48,56,60,93,188,193,240};
new const gVXClothesPrice[VX_CLOTHES_COUNT] = {35000,50000,65000,85000,110000,140000,180000,220000,270000,330000,400000,500000};
new const gVXClothesLabel[VX_CLOTHES_COUNT][32] =
{
    "���������", "������������", "����������", "������������",
    "���������", "�������", "��������", "���������",
    "�������", "������", "��������", "�������"
};
new gFaction[MAX_PLAYERS];
new gFactionRank[MAX_PLAYERS];
new gOrgInviteFrom[MAX_PLAYERS];
new bool:gPoliceCivilianSkin[MAX_PLAYERS];
new gGang[MAX_PLAYERS];
new gSpawnPreference[MAX_PLAYERS]; // 0 = �� �������, 1 = �����������, 2 = ������
new gRentalVehicle[MAX_PLAYERS];
new gBaseScooter = INVALID_VEHICLE_ID;
new bool:gPendingScooterChoice[MAX_PLAYERS];
new gFactionVehicle[MAX_PLAYERS];
new gFleetVehicle[8][FLEET_TIERS];
// Slot 69 is reserved for the player's own faction garage route.
#define VX_GARAGE_MAP_ICON 69
new bool:gVXGarageRoute[MAX_PLAYERS];
new bool:gVXFleetAnchored[MAX_VEHICLES];
new Float:gVXFleetAnchorX[MAX_VEHICLES];
new Float:gVXFleetAnchorY[MAX_VEHICLES];
new Float:gVXFleetAnchorZ[MAX_VEHICLES];
new Float:gVXFleetAnchorA[MAX_VEHICLES];
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
#define VX_MARKET_COUNT 31
#define VX_GAS_COUNT 20
#define VX_MARKET_INTERIOR 17
#define VX_MARKET_WORLD 5500
#define VX_MARKET_ENTRY_X (-23.5)
#define VX_MARKET_ENTRY_Y (-187.5)
#define VX_MARKET_ENTRY_Z (1003.5469)
#define VX_MARKET_ENTRY_A (180.0)
#define VX_MARKET_COUNTER_X (-23.8)
#define VX_MARKET_COUNTER_Y (-189.0)
#define VX_MARKET_COUNTER_Z (1003.5469)
#define VX_MARKET_EXIT_X (-25.8845)
#define VX_MARKET_EXIT_Y (-185.8689)
#define VX_MARKET_EXIT_Z (1003.5469)
#define VX_MARKET_ICON_SLOTS 20
#define VX_GAS_ICON_SLOTS 10
#define VX_FIRE_STATION_X (1775.5)
#define VX_FIRE_STATION_Y (-1702.5)
#define VX_FIRE_STATION_Z (13.5)
#define VX_FIRE_CALL_COUNT 4
new gMarketPickups[VX_MARKET_COUNT];
new gGasStationPickup[VX_GAS_COUNT];
new gHousePickup[VX_HOUSE_COUNT + 1];
new Text3D:gVXHouseLabel[VX_HOUSE_COUNT + 1];
new bool:gVXHouseLabelCreated[VX_HOUSE_COUNT + 1];
new gMarketInteriorCounterPickup;
new gMarketInteriorExitPickup;
new bool:gMarketInside[MAX_PLAYERS];
new Float:gMarketReturnPos[MAX_PLAYERS][4];
new gFireCallIndex[MAX_PLAYERS];
new Float:gVXMarketPos[VX_MARKET_COUNT][3] = {
    {1833.0000, -1842.0000, 13.3000},
    {1351.2000, -1759.2000, 13.5000},
    {2424.0000, -1742.0000, 13.5500},
    {1000.6000, -919.4000, 42.3000},
    {-1804.0000, 945.5000, 24.8000},
    {-2420.5000, 969.1000, 45.3000},
    {-1725.0000, 1354.0000, 7.2000},
    {2187.0000, 2465.0000, 10.8000},
    {2639.0000, 1676.0000, 10.8000},
    {2160.0000, 943.0000, 10.8000},
    {660.0000, -575.0000, 16.3000},
    {1065.0, -1204.0, 17.8},
    {2097.0, -1215.0, 23.9},
    {2424.0, -1229.0, 25.3},
    {2790.0, -1424.0, 16.3},
    {1318.0, -898.0, 39.6},
    {1182.0, -920.0, 43.1},
    {1019.0, -1318.0, 13.5},
    {2159.0, -1678.0, 15.1},
    {2327.0, -1645.0, 14.8},
    {1645.0, -1051.0, 23.9},
    {2760.0, -1818.0, 11.8},
    {-1987.0, -493.0, 35.2},
    {-2433.0, 754.0, 35.2},
    {-2507.0, 1228.0, 37.4},
    {-1633.0, 1177.0, 7.2},
    {-1950.0, 298.0, 35.5},
    {2545.0, 2084.0, 10.8},
    {2840.0, 1295.0, 10.8},
    {1700.0, 1348.0, 10.8},
    {2405.0, 1124.0, 10.8}
};
// Pickup points aligned to existing GTA:SA petrol-pump placements (not guessed street coordinates).
// Several large forecourts have multiple pumps; those entries still sit on their real pump pads.
new Float:gVXGasPos[VX_GAS_COUNT][3] = {
    {1941.66, -1778.45, 14.1406}, // Idlewood, Los Santos
    {655.66, -571.21, 15.3594},    // Dillimore / Red County
    {603.48, 1707.23, 6.1797},     // Montgomery
    {1378.96, 461.04, 19.3281},    // Red County
    {-1477.66, 1859.73, 31.8203},  // Tierra Robada
    {-1329.20, 2669.28, 49.4531},  // Bone County
    {-1610.62, -2721.00, 47.9297}, // Southern rural station
    {-2246.70, -2559.71, 31.0625}, // Angel Pine / Whetstone
    {-1685.97, 409.64, 6.3828},    // San Fierro / Easter Basin
    {-2410.80, 970.85, 44.4844},   // Juniper Hollow, San Fierro
    {2114.91, 925.51, 11.2578},    // Las Venturas east
    {2634.64, 1100.95, 11.2500},   // Come-A-Lot
    {2141.67, 2753.32, 11.2734},   // Las Venturas / desert road
    {2196.90, 2480.33, 11.3125},   // Redsands West
    {1590.35, 2193.71, 11.3125},   // Spinybed
    {624.05, 1677.60, 6.1797},     // Montgomery, second pump pad
    {655.66, -558.93, 15.3594},    // Dillimore, second pump pad
    {-1464.94, 1860.56, 31.8203},  // Tierra Robada, second pump pad
    {-1328.59, 2674.71, 49.4531},  // Bone County, second pump pad
    {2109.05, 914.72, 11.2578}     // Las Venturas east, second pump pad
};
new Float:gVXFireCallPos[VX_FIRE_CALL_COUNT][3] = {
    {2055.0, -1410.0, 17.2},
    {1215.0, -1321.0, 13.6},
    {1860.0, -1350.0, 13.5},
    {2425.0, -1685.0, 13.4}
};

// VEXORIUM HUD RU 2.2 - cache initialization / compact layout / legacy fonts.
// Source encoding: Windows-1251 (no UTF-8 BOM).
// Native SA-MP 0.3.7 player textdraws; no additional include or server plugin.
#define VEX_HUD_UPDATE_MS (500)
#define VEX_HUD_MAX_ITEMS (104)
#define VEX_HUD_TEXT_SIZE (64)
#define VEX_HUD_FONT_COUNT (9)
#define VEX_HUD_DEFAULT_FONT (6)
#define VEX_HUD_SETTINGS_REVISION (5)
#define DIALOG_VEX_HUD_FONT (1090)
#define VEX_HUD_BG (0x101921C8)
#define VEX_HUD_HEAD (0x172932D8)
#define VEX_HUD_ACCENT (0x58E3BAFF)
#define VEX_HUD_WHITE (0xEDF5F8FF)
#define VEX_HUD_MUTED (0x9AABB7FF)
#define VEX_HUD_TRACK (0x31404AFF)
#define VEX_HUD_HEALTH (0xF07482FF)
#define VEX_HUD_ARMOUR (0x83BFF4FF)
#define VEX_HUD_WARNING (0xFFBD69FF)

enum E_VEX_HUD_VALUE
{
    VHV_NAME, VHV_ID, VHV_HEALTH, VHV_ARMOUR, VHV_CASH, VHV_BANK,
    VHV_LEVEL, VHV_XP, VHV_FACTION, VHV_AMMO, VHV_WANTED,
    VHV_SPEED, VHV_FUEL, VHV_ENGINE, VHV_LOCK, VHV_BODY,
    VHV_NAV_MARKET, VHV_NAV_FUEL, VHV_NAV_DIRECTION, VHV_WEAPON,
    VHV_COUNT
};
enum E_VEX_HUD_BAR { VHB_HEALTH, VHB_ARMOUR, VHB_XP, VHB_FUEL, VHB_SPEED, VHB_COUNT };

new PlayerText:gVexHud[MAX_PLAYERS][VEX_HUD_MAX_ITEMS];
new PlayerText:gVexHudValue[MAX_PLAYERS][VHV_COUNT];
new PlayerText:gVexHudBar[MAX_PLAYERS][VHB_COUNT];
new PlayerText:gVexHudToastBg[MAX_PLAYERS];
new PlayerText:gVexHudToastAccent[MAX_PLAYERS];
new PlayerText:gVexHudToastTitle[MAX_PLAYERS];
new PlayerText:gVexHudToastBody[MAX_PLAYERS];
new gVexHudToastTimer[MAX_PLAYERS], gVexHudToastSerial[MAX_PLAYERS];
new gVexHudCount[MAX_PLAYERS], gVexHudMainCount[MAX_PLAYERS];
new gVexHudCache[MAX_PLAYERS][VHV_COUNT][VEX_HUD_TEXT_SIZE];
new gVexHudBarPercent[MAX_PLAYERS][VHB_COUNT];
new gVexHudBarColor[MAX_PLAYERS][VHB_COUNT];
new bool:gHudCreated[MAX_PLAYERS], bool:gVexHudBuildFailed[MAX_PLAYERS];
new bool:gVexHudMainShown[MAX_PLAYERS], bool:gVexHudCarShown[MAX_PLAYERS];
new bool:gVexHudEnabled[MAX_PLAYERS];
new gVexHudFont[MAX_PLAYERS];
new PlayerText:gVexNavCells[MAX_PLAYERS][9];
new gVexNavCache[MAX_PLAYERS][9];
new gHudTimer[MAX_PLAYERS];

/*
 * Glyph mapping attribution (MIT License)
 * Copyright (c) 2016 Sergei Marochkin
 * Source: https://github.com/ziggi/rustext/blob/master/src/converter.cpp
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

// Upper-case CP1251 A..YA (0xC0..0xDF) -> GTA font character bytes.
// Profiles 0..4 retain their previous indices. 5 is raw CP1251.
// Profile 6: legacy ASCII Cyrillic (rustext Unknown3, V=F, R=YA, U=YU).
// Profiles 7 and 8: rustext Unknown2 and Unknown1.
// Glyph data: ziggi/rustext/src/converter.cpp (MIT; notice above).
new const gVexHudGlyph[VEX_HUD_FONT_COUNT][32] =
{
    {65,128,139,130,131,69,132,136,133,134,75,135,77,72,79,140,80,67,143,89,129,88,137,141,142,138,144,145,146,147,148,149},
    {65,129,139,136,131,69,132,133,134,135,75,138,77,141,79,140,80,67,84,89,144,88,145,130,142,146,147,148,149,143,128,173},
    {65,128,129,130,131,69,132,136,133,134,75,135,77,72,79,140,80,67,143,150,139,88,137,141,142,138,144,145,146,147,148,149},
    {65,128,66,141,130,69,131,147,132,133,75,134,77,72,79,135,80,67,84,136,129,88,138,139,140,137,142,143,144,145,146,173},
    {65,133,66,134,128,69,132,51,129,173,75,130,77,72,79,146,80,67,84,147,142,88,148,52,144,144,136,131,136,135,145,149},
    {192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223},
    {65,54,66,70,68,69,71,51,78,78,75,76,77,72,79,90,80,67,84,89,86,88,81,52,87,87,74,83,74,51,85,82},
    {65,128,129,130,131,69,149,138,139,140,75,132,77,72,79,150,80,67,84,137,142,88,134,135,141,136,143,144,145,146,147,148},
    {65,128,129,130,131,69,132,136,133,134,75,135,77,72,79,140,80,67,143,89,129,88,137,141,142,138,144,145,146,147,148,149}
};
new const Float:gVexHudBarWidth[VHB_COUNT] = {62.0, 56.0, 130.0, 50.0, 76.0};
new const Float:gVexHudBarHeight[VHB_COUNT] = {4.0, 4.0, 2.5, 3.0, 3.0};
new gPoliceGarageDoorPickup;
new gPoliceEntrancePickup;
new gPoliceStashPickup;
new gFBIStashPickup;
new gGangStashPickup[5];
new gPoliceGarageReturnPickup;
new gPoliceExitPickup;
new gPoliceHallGaragePickup;
new gLastPickupTick[MAX_PLAYERS];
new gLastTeleportTick[MAX_PLAYERS];
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
// Player taxi dispatch: passengers request a pickup; on-duty taxi drivers accept and complete fares.
new gTaxiOrderTarget[MAX_PLAYERS];       // passenger ID currently assigned to this driver
new gTaxiOrderDriver[MAX_PLAYERS];       // driver ID currently assigned to this passenger
new bool:gTaxiRequestActive[MAX_PLAYERS];
new bool:gTaxiAtPickup[MAX_PLAYERS];
new Float:gTaxiPickupPos[MAX_PLAYERS][3];
new bool:gSpawnMenuShown[MAX_PLAYERS];
new bool:gIsJailed[MAX_PLAYERS];
new gWantedLevel[MAX_PLAYERS];
new bool:gHandcuffed[MAX_PLAYERS];
new gCuffOfficer[MAX_PLAYERS];
new bool:gTaserStunned[MAX_PLAYERS];
new gPursuitTarget[MAX_PLAYERS];
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
#define DIALOG_CLOTHES 1041
#define DIALOG_CLOTHES_CONFIRM 1042
#define DIALOG_GPS_TRANSPORT 1043
#define DIALOG_GPS_SHOPS 1044
#define DIALOG_GPS_HOUSING 1045
#define DIALOG_GPS_MEDICAL 1046
new gJailTimer[MAX_PLAYERS];
new gPassword[MAX_PLAYERS][65];
new gName[MAX_PLAYERS][MAX_PLAYER_NAME + 1];

// VEXORIUM systems update. Requires SA-MP 0.3.7 R2+ or open.mp.
#define VX_FIRST_DIALOG 12000
#define VX_INV 12000
#define VX_ITEM 12001
#define VX_BANK 12002
#define VX_BANK_INPUT 12003
#define VX_PHONE 12004
#define VX_SMS_NUMBER 12005
#define VX_SMS_BODY 12006
#define VX_REPORTS 12007
#define VX_TABLET 12008
#define VX_CONTACTS 12009
#define VX_FAMILY 12010
#define VX_BUSINESSES 12011
#define VX_BIZ 12012
#define VX_CALL_NUMBER 12013
#define VX_LOG 12014
#define VX_MAX_LIST 60
#define VX_BEDS 12
#define VX_HOSPITAL_WORLD 103
#define VX_HOSPITAL_SECONDS 120
#define VX_WARD_X (2000.0)
#define VX_WARD_Y (1997.0)
#define VX_WARD_Z (1001.0)
#define VX_WARD_EXIT_X (2000.0)
#define VX_WARD_EXIT_Y (1985.4)
#define VX_WARD_LOAD_MS (1800)
#define VX_LOBBY_X (2054.0)
#define VX_LOBBY_Y (1993.0)
#define VX_LOBBY_Z (1001.0)
#define VX_LOBBY_EXIT_X (2054.0)
#define VX_LOBBY_EXIT_Y (1989.7)
#define VX_LOBBY_CERT_X (2054.0)
#define VX_LOBBY_CERT_Y (2000.5)
#define VX_LOBBY_WARD_X (2067.0)
#define VX_LOBBY_WARD_Y (1997.0)
#define VX_WARD_LOBBY_X (2017.0)
#define VX_WARD_LOBBY_Y (1996.0)
#define VX_CERT_PRICE (1000)
#define VX_CERT_DAYS (7)
#define VX_WANTED_SECONDS 1800
#define VX_ITEM_LIMIT 100
#define VX_WEIGHT_LIMIT 30000
#define VX_MAX_DROPS 100
#define VX_FAMILY_PRICE 100000
#define VX_INVALID -1
new gVXTimer, gVXLastTick;
new bool:gVXCarjackCharged[MAX_PLAYERS];
new gVXSpecLastVehicle[MAX_PLAYERS], gVXSpecLastState[MAX_PLAYERS], gVXSpecLastWorld[MAX_PLAYERS], gVXSpecLastInterior[MAX_PLAYERS];
new bool:gVXDBError;
new gVXPhone[MAX_PLAYERS], bool:gVXPhoneOn[MAX_PLAYERS];
new gVXCall[MAX_PLAYERS], bool:gVXCallActive[MAX_PLAYERS], gVXCallAt[MAX_PLAYERS];
new gVXNumberInput[MAX_PLAYERS], gVXLastSMS[MAX_PLAYERS], gVXLastCall[MAX_PLAYERS];
new gVXFamily[MAX_PLAYERS], gVXFamilyRank[MAX_PLAYERS];
new gVXInvite[MAX_PLAYERS], gVXInviteAt[MAX_PLAYERS];
new gVXWantedAt[MAX_PLAYERS];
new bool:gVXHospital[MAX_PLAYERS], gVXTreatment[MAX_PLAYERS], gVXBed[MAX_PLAYERS];
new gVXBedOwner[VX_BEDS], gVXBedPickup[VX_BEDS];
new gVXBedObject[VX_BEDS];
new Text3D:gVXBedLabel[VX_BEDS];
new gVXWardTimer[MAX_PLAYERS], gVXWardSequence[MAX_PLAYERS];
new gVXWardNotice[MAX_PLAYERS];
new gVXHospitalGaragePickup;
new gVXLobbyWardPickup, gVXWardLobbyPickup, gVXMedCertPickup;
forward VX_HospitalOutsideReady(playerid, session);
new gVXDeathTimer[MAX_PLAYERS], gVXLastHeal[MAX_PLAYERS];
new gVXMedCall[MAX_PLAYERS], gVXMedAssigned[MAX_PLAYERS], gVXLastMedCall[MAX_PLAYERS];
new bool:gVXMedDuty[MAX_PLAYERS];
new gVXReportId[MAX_PLAYERS], gVXReportOwner[MAX_PLAYERS], gVXReportAt[MAX_PLAYERS];
new gVXSpec[MAX_PLAYERS], bool:gVXRestore[MAX_PLAYERS];
new gVXSpecAction[MAX_PLAYERS];
new Float:gVXSpecPos[MAX_PLAYERS][4], Float:gVXSpecHP[MAX_PLAYERS], Float:gVXSpecArmour[MAX_PLAYERS];
new gVXSpecInterior[MAX_PLAYERS], gVXSpecWorld[MAX_PLAYERS], gVXSpecSkin[MAX_PLAYERS];
new gVXSpecWeapons[MAX_PLAYERS][13], gVXSpecAmmo[MAX_PLAYERS][13];
new gVXSelectedItem[MAX_PLAYERS], gVXBankAction[MAX_PLAYERS];
new gVXList[MAX_PLAYERS][VX_MAX_LIST], gVXListCount[MAX_PLAYERS];
new gVXSelectedBiz[MAX_PLAYERS], gVXExpectedDialog[MAX_PLAYERS];
new gVXSession[MAX_PLAYERS], gVXListSession[MAX_PLAYERS][VX_MAX_LIST];
new gVXDropItem[VX_MAX_DROPS], gVXDropQty[VX_MAX_DROPS], gVXDropExpiry[VX_MAX_DROPS];
new gVXDropWorld[VX_MAX_DROPS], gVXDropInterior[VX_MAX_DROPS], gVXDropPickup[VX_MAX_DROPS];
new Float:gVXDropPos[VX_MAX_DROPS][3];
new Text3D:gVXDropLabel[VX_MAX_DROPS];
new const gVXItemName[6][24] = {"�������", "���", "����", "�����������", "SIM-�����", "�������"};
new const gVXItemWeight[6] = {1000,500,500,2000,10,100};
new const Float:gVXBedPos[VX_BEDS][3] = {
 {1987.0,1988.0,1001.0},{1992.0,1988.0,1001.0},{1997.0,1988.0,1001.0},
 {2002.0,1988.0,1001.0},{2007.0,1988.0,1001.0},{2012.0,1988.0,1001.0},
 {1987.0,2008.0,1001.0},{1992.0,2008.0,1001.0},{1997.0,2008.0,1001.0},
 {2002.0,2008.0,1001.0},{2007.0,2008.0,1001.0},{2012.0,2008.0,1001.0}
};
new const Float:gVXBizPos[5][3] = {{1833.0,-1842.0,13.3},{1457.0,-1137.0,23.9},{1940.0,-1772.0,13.4},{1315.3,-897.6,39.6},{2105.0,-1806.5,13.6}};

// ================= VEXORIUM RP EXPANSION 1.0 =================
// Legacy Pawn 3.2 syntax, native SA-MP + SQLite only.
#define RP_JAIL_DEFAULT (30 * 60)
#define RP_JAIL_MAX (120 * 60)
#define RP_JAIL_WORLD (220)
#define RP_LAWYER_JOB (6)
#define RP_LAWYER_FEE (1000)
#define RP_LAWYER_PERCENT (20)
#define RP_LAWYER_MAX_CUT (10 * 60)
#define RP_INJ_BLEED (1)
#define RP_INJ_FRACTURE (2)
#define RP_MED_PAY (750)
#define RP_MED_PAY_COOLDOWN (600)
#define RP_REGISTER_PRICE (2500)
#define RP_INSURE_PRICE (2000)
#define RP_INSURE_DAYS (7)
#define RP_INSPECT_PRICE (1000)
#define RP_INSPECT_DAYS (3)
#define RP_RECOVER_PRICE (5000)
#define RP_INSURED_RECOVER_PRICE (1000)
#define RP_PRISON_X (2750.0)
#define RP_PRISON_Y (-2400.0)
#define RP_PRISON_Z (13.6)
#define RP_CAMERA_COUNT (3)
new bool:gRPLoaded[MAX_PLAYERS];
new gRPJailLeft[MAX_PLAYERS], gRPJailOriginal[MAX_PLAYERS];
new gRPSentence[MAX_PLAYERS], gRPJailSource[MAX_PLAYERS];
new bool:gRPJailReduced[MAX_PLAYERS];
new gRPJailReason[MAX_PLAYERS][97];
new gRPLawOffer[MAX_PLAYERS], gRPLawSession[MAX_PLAYERS];
new gRPLawSentence[MAX_PLAYERS], gRPLawUntil[MAX_PLAYERS];
new gRPInjury[MAX_PLAYERS], gRPNextMedPay[MAX_PLAYERS], gRPBleedAt[MAX_PLAYERS];
new gRPStretcherBy[MAX_PLAYERS], gRPStretcherObject[MAX_PLAYERS];
new gRPOpDoctor[MAX_PLAYERS], gRPOpSession[MAX_PLAYERS], gRPOpUntil[MAX_PLAYERS];
new gRPTaserUntil[MAX_PLAYERS];
new Float:gRPCarKm[MAX_PLAYERS], Float:gRPCarHealth[MAX_PLAYERS];
new Float:gRPCarLastPos[MAX_PLAYERS][3], bool:gRPCarPosKnown[MAX_PLAYERS];
new gRPCarFuel[MAX_PLAYERS], bool:gRPCarRegistered[MAX_PLAYERS];
new gRPCarInsured[MAX_PLAYERS], gRPCarInspected[MAX_PLAYERS];
new bool:gRPCarBroken[MAX_PLAYERS];
new gRPCarPlate[MAX_PLAYERS][12];
new gRPPrisonIn, gRPPrisonOut;
new gRPNextSave, gRPNextCamera[MAX_PLAYERS][RP_CAMERA_COUNT];
new const Float:gRPCameras[RP_CAMERA_COUNT][3] = {
    {1535.0,-1730.0,13.5}, {1184.0,-1320.0,13.5}, {1940.0,-1771.0,13.4}
};
new const gRPCameraLimit[RP_CAMERA_COUNT] = {90,60,90};

forward VX_Tick();
forward VX_VehicleSpeedTick();
forward VX_CuffFollowTick();
forward VX_AdminDelayedKick(playerid);
forward VX_NeedsPulse();
forward VX_DeathSpawn(playerid, session);
forward VX_WardReady(playerid, session, sequence);


forward SavePlayer(playerid);
forward PayDay();
forward UnstunPlayer(playerid);
forward ReleaseJailedPlayer(playerid);
forward RespawnFactionVehicle(vehicleid);
forward RefreshVexHud(playerid);
forward UpdateVexHud(playerid);
forward VX_HideHudToast(playerid, serial);
forward FinishFBIEnter(playerid);
forward InterviewAnnouncement();
forward PvpRespawn(playerid);
forward RefreshCarjackPursuits();
forward RefreshNearbyMapVisibility();
forward VX_SecureDisplayFleet();

stock Float:VX_FloatMin(Float:a,Float:b) { return a < b ? a : b; }

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
        case FACTION_CITYHALL: format(output, size, "�����");
        case FACTION_POLICE: format(output, size, "�������");
        case FACTION_HOSPITAL: format(output, size, "����");
        case FACTION_ARMY: format(output, size, "�����");
        case FACTION_NAVY: format(output, size, "���");
        case FACTION_AIRFORCE: format(output, size, "���");
        case FACTION_FBI: format(output, size, "FBI");
        default: format(output, size, "��� �������");
    }
    return 1;
}

stock GetFactionRankName(faction, rank, output[], size)
{
    if (rank < 1 || rank > 10) { format(output, size, "��� �����"); return 1; }
    if (faction == FACTION_CITYHALL)
    {
        switch (rank)
        {
            case 1: format(output, size, "�����");
            case 2: format(output, size, "���������");
            case 3: format(output, size, "��������");
            case 4: format(output, size, "����������");
            case 5: format(output, size, "��������� ������");
            case 6: format(output, size, "����������� �����");
            case 7: format(output, size, "��������");
            case 8: format(output, size, "����������� ����");
            case 9: format(output, size, "����-���");
            case 10: format(output, size, "���");
        }
    }
    else if (faction == FACTION_POLICE)
    {
        switch (rank)
        {
            case 1: format(output, size, "�����");
            case 2: format(output, size, "�������");
            case 3: format(output, size, "�������");
            case 4: format(output, size, "��������");
            case 5: format(output, size, "���������");
            case 6: format(output, size, "���������");
            case 7: format(output, size, "�������");
            case 8: format(output, size, "�����");
            case 9: format(output, size, "���������");
            case 10: format(output, size, "��������� �������");
        }
    }
    else if (faction == FACTION_HOSPITAL)
    {
        switch (rank)
        {
            case 1: format(output, size, "������");
            case 2: format(output, size, "�������/���������");
            case 3: format(output, size, "��������");
            case 4: format(output, size, "����������� ������");
            case 5: format(output, size, "����");
            case 6: format(output, size, "������");
            case 7: format(output, size, "���������� ����������");
            case 8: format(output, size, "����������� ���������");
            case 9: format(output, size, "��������");
            case 10: format(output, size, "������� ���������������");
        }
    }
    else if (faction == FACTION_ARMY || faction == FACTION_NAVY || faction == FACTION_AIRFORCE || faction == FACTION_FBI)
    {
        switch (rank)
        {
            case 1: format(output, size, "������");
            case 2: format(output, size, "�������");
            case 3: format(output, size, "��������");
            case 4: format(output, size, "������� �������");
            case 5: format(output, size, "�������");
            case 6: format(output, size, "��������");
            case 7: format(output, size, "���������");
            case 8: format(output, size, "���������");
            case 9: format(output, size, "���������");
            case 10: format(output, size, "�����������");
        }
    }
    else format(output, size, "��� �����");
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
    // � ����������� SA-MP 0.3.7 ��� native ��� ������� ��������� ��������� HUD.
    // ��������� ����������� ��������, ����� �������� ��������������.
    #pragma unused playerid
    return 1;
}

stock VexHudClamp(value, minimum, maximum)
{
    if (value < minimum) return minimum;
    if (value > maximum) return maximum;
    return value;
}

stock VexHudEncode(playerid, const text[], output[], size)
{
    if (size < 1) return 0;
    new profile = VexHudClamp(gVexHudFont[playerid], 0, VEX_HUD_FONT_COUNT - 1);
    new i;
    for (i = 0; text[i] != '\0' && i < size - 1; i++)
    {
        new code = text[i] & 0xFF;
        if (profile != 5)
        {
            // All HUD labels use capitals; latin letters and ~g~ codes stay intact.
            if (code >= 0xE0 && code <= 0xFF) code -= 0x20;
            if (code == 0xA8 || code == 0xB8) code = 0xC5; // YO -> E fallback.
            if (code >= 0xC0 && code <= 0xDF) code = gVexHudGlyph[profile][code - 0xC0];
        }
        output[i] = code;
    }
    output[i] = '\0';
    return 1;
}

stock VexHudFormatMoney(amount, output[], size)
{
    if (size < 1) return 0;
    new digits[16], grouped[24], len, n;
    format(digits, sizeof digits, "%d", amount);
    len = strlen(digits);
    for (new i = 0; i < len && n < sizeof grouped - 1; i++)
    {
        grouped[n++] = digits[i];
        if (digits[i] != '-' && i < len - 1 && (len - i - 1) % 3 == 0 && n < sizeof grouped - 1)
            grouped[n++] = ' ';
    }
    grouped[n] = '\0';
    format(output, size, "%s", grouped);
    return 1;
}

stock GetHudFactionName(playerid, output[], size)
{
    if (gFaction[playerid] == FACTION_NONE && gGang[playerid] >= 1 && gGang[playerid] <= 4)
    {
        switch (gGang[playerid])
        {
            case 1: format(output, size, "����");
            case 2: format(output, size, "������");
            case 3: format(output, size, "�����");
            case 4: format(output, size, "������");
        }
        return 1;
    }
    switch (gFaction[playerid])
    {
        case FACTION_CITYHALL: format(output, size, "�����");
        case FACTION_POLICE: format(output, size, "�������");
        case FACTION_HOSPITAL: format(output, size, "����");
        case FACTION_ARMY: format(output, size, "�����");
        case FACTION_NAVY: format(output, size, "���");
        case FACTION_AIRFORCE: format(output, size, "���");
        case FACTION_FBI: format(output, size, "���");
        default: format(output, size, "���������");
    }
    return 1;
}

stock PlayerText:VexHudNew(playerid, Float:x, Float:y, const text[])
{
    if (gVexHudCount[playerid] >= VEX_HUD_MAX_ITEMS)
    {
        gVexHudBuildFailed[playerid] = true;
        return PlayerText:INVALID_TEXT_DRAW;
    }
    // Compatibility with the non-const text[] in older a_samp.inc files.
    // 128 matches the largest creation buffer in VexHudText.
    new nativeText[128];
    format(nativeText, sizeof nativeText, "%s", text);
    new PlayerText:td = CreatePlayerTextDraw(playerid, x, y, nativeText);
    if (td == PlayerText:INVALID_TEXT_DRAW)
    {
        gVexHudBuildFailed[playerid] = true;
        return td;
    }
    gVexHud[playerid][gVexHudCount[playerid]++] = td;
    PlayerTextDrawSetSelectable(playerid, td, 0);
    return td;
}

stock PlayerText:VexHudRect(playerid, Float:x, Float:y, Float:w, Float:h, color)
{
    // Stock GTA texture, not a custom asset. Font 4 uses exact width/height.
    new PlayerText:td = VexHudNew(playerid, x, y, "LD_SPAC:white");
    if (td == PlayerText:INVALID_TEXT_DRAW) return td;
    PlayerTextDrawFont(playerid, td, 4);
    PlayerTextDrawTextSize(playerid, td, w, h);
    PlayerTextDrawColor(playerid, td, color);
    PlayerTextDrawSetShadow(playerid, td, 0);
    PlayerTextDrawSetOutline(playerid, td, 0);
    PlayerTextDrawBackgroundColor(playerid, td, 0x00000000);
    return td;
}

stock PlayerText:VexHudText(playerid, Float:x, Float:y, const text[], Float:sx, Float:sy, color, align = 1, font = 1)
{
    new encoded[128];
    VexHudEncode(playerid, text, encoded, sizeof encoded);
    new PlayerText:td = VexHudNew(playerid, x, y, encoded);
    if (td == PlayerText:INVALID_TEXT_DRAW) return td;
    PlayerTextDrawFont(playerid, td, font);
    PlayerTextDrawLetterSize(playerid, td, sx, sy);
    PlayerTextDrawColor(playerid, td, color);
    PlayerTextDrawAlignment(playerid, td, align);
    PlayerTextDrawSetProportional(playerid, td, 1);
    PlayerTextDrawSetShadow(playerid, td, 0);
    PlayerTextDrawSetOutline(playerid, td, 0);
    PlayerTextDrawBackgroundColor(playerid, td, 0x00000000);
    PlayerTextDrawUseBox(playerid, td, 0);
    // Right-aligned text wraps toward the left, not toward its own origin.
    if (align == 3) PlayerTextDrawTextSize(playerid, td, 478.0, 0.0);
    else PlayerTextDrawTextSize(playerid, td, 626.0, 0.0);
    return td;
}

// Store handles through variable indices: Pawn 3.2.3664 can incorrectly
// override the PlayerText tag when an enum constant directly indexes an array.
stock PlayerText:VX_HudToastRect(playerid, Float:x, Float:y, Float:w, Float:h, color)
{
    new PlayerText:td = CreatePlayerTextDraw(playerid, x, y, "LD_SPAC:white");
    if (td == PlayerText:INVALID_TEXT_DRAW) return td;
    PlayerTextDrawFont(playerid, td, 4);
    PlayerTextDrawTextSize(playerid, td, w, h);
    PlayerTextDrawColor(playerid, td, color);
    PlayerTextDrawSetShadow(playerid, td, 0);
    PlayerTextDrawSetOutline(playerid, td, 0);
    PlayerTextDrawBackgroundColor(playerid, td, 0x00000000);
    PlayerTextDrawSetSelectable(playerid, td, 0);
    return td;
}

stock PlayerText:VX_HudToastText(playerid, Float:x, Float:y, const text[], Float:sx, Float:sy, color)
{
    new encoded[128];
    VexHudEncode(playerid, text, encoded, sizeof encoded);
    new PlayerText:td = CreatePlayerTextDraw(playerid, x, y, encoded);
    if (td == PlayerText:INVALID_TEXT_DRAW) return td;
    PlayerTextDrawFont(playerid, td, 1);
    PlayerTextDrawLetterSize(playerid, td, sx, sy);
    PlayerTextDrawColor(playerid, td, color);
    PlayerTextDrawAlignment(playerid, td, 1);
    PlayerTextDrawSetProportional(playerid, td, 1);
    PlayerTextDrawSetShadow(playerid, td, 0);
    PlayerTextDrawSetOutline(playerid, td, 0);
    PlayerTextDrawBackgroundColor(playerid, td, 0x00000000);
    PlayerTextDrawUseBox(playerid, td, 0);
    PlayerTextDrawTextSize(playerid, td, 630.0, 0.0);
    PlayerTextDrawSetSelectable(playerid, td, 0);
    return td;
}

stock VX_CreateHudToast(playerid)
{
    gVexHudToastBg[playerid] = PlayerText:INVALID_TEXT_DRAW;
    gVexHudToastAccent[playerid] = PlayerText:INVALID_TEXT_DRAW;
    gVexHudToastTitle[playerid] = PlayerText:INVALID_TEXT_DRAW;
    gVexHudToastBody[playerid] = PlayerText:INVALID_TEXT_DRAW;

    // Notification card sits below the player card, away from the radar and crosshair.
    gVexHudToastBg[playerid] = VX_HudToastRect(playerid, 453.0, 184.0, 183.0, 44.0, 0x0A111EFF);
    gVexHudToastAccent[playerid] = VX_HudToastRect(playerid, 453.0, 184.0, 183.0, 1.5, VEX_HUD_ACCENT);
    gVexHudToastTitle[playerid] = VX_HudToastText(playerid, 465.0, 190.0, "VEXORIUM", 0.145, 0.80, VEX_HUD_ACCENT);
    gVexHudToastBody[playerid] = VX_HudToastText(playerid, 465.0, 207.0, "", 0.155, 0.90, VEX_HUD_WHITE);
    if (gVexHudToastBg[playerid] == PlayerText:INVALID_TEXT_DRAW
        || gVexHudToastAccent[playerid] == PlayerText:INVALID_TEXT_DRAW
        || gVexHudToastTitle[playerid] == PlayerText:INVALID_TEXT_DRAW
        || gVexHudToastBody[playerid] == PlayerText:INVALID_TEXT_DRAW) return 0;

    PlayerTextDrawHide(playerid, gVexHudToastBg[playerid]);
    PlayerTextDrawHide(playerid, gVexHudToastAccent[playerid]);
    PlayerTextDrawHide(playerid, gVexHudToastTitle[playerid]);
    PlayerTextDrawHide(playerid, gVexHudToastBody[playerid]);
    return 1;
}

stock VX_HideHudToastNow(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS) return 0;
    if (gVexHudToastTimer[playerid])
    {
        KillTimer(gVexHudToastTimer[playerid]);
        gVexHudToastTimer[playerid] = 0;
    }
    gVexHudToastSerial[playerid]++;
    if (gVexHudToastBg[playerid] != PlayerText:INVALID_TEXT_DRAW) PlayerTextDrawHide(playerid, gVexHudToastBg[playerid]);
    if (gVexHudToastAccent[playerid] != PlayerText:INVALID_TEXT_DRAW) PlayerTextDrawHide(playerid, gVexHudToastAccent[playerid]);
    if (gVexHudToastTitle[playerid] != PlayerText:INVALID_TEXT_DRAW) PlayerTextDrawHide(playerid, gVexHudToastTitle[playerid]);
    if (gVexHudToastBody[playerid] != PlayerText:INVALID_TEXT_DRAW) PlayerTextDrawHide(playerid, gVexHudToastBody[playerid]);
    return 1;
}

stock VX_Notify(playerid, const title[], const message[], color = VEX_HUD_ACCENT)
{
    if (!IsPlayerConnected(playerid) || !gLogged[playerid] || !gVexHudEnabled[playerid]) return 0;
    if (!gHudCreated[playerid] && !UpdateVexHud(playerid)) return 0;
    if (gVexHudToastBg[playerid] == PlayerText:INVALID_TEXT_DRAW) return 0;

    new titleText[40], bodyText[64], encoded[128];
    format(titleText, sizeof titleText, "%s", title);
    format(bodyText, sizeof bodyText, "%s", message);
    if (strlen(titleText) > 22) titleText[22] = '\0';
    if (strlen(bodyText) > 34) bodyText[34] = '\0';

    VexHudEncode(playerid, titleText, encoded, sizeof encoded);
    PlayerTextDrawSetString(playerid, gVexHudToastTitle[playerid], encoded);
    VexHudEncode(playerid, bodyText, encoded, sizeof encoded);
    PlayerTextDrawSetString(playerid, gVexHudToastBody[playerid], encoded);
    PlayerTextDrawColor(playerid, gVexHudToastTitle[playerid], color);
    PlayerTextDrawColor(playerid, gVexHudToastAccent[playerid], color);

    if (gVexHudToastTimer[playerid]) KillTimer(gVexHudToastTimer[playerid]);
    gVexHudToastSerial[playerid]++;
    if (gVexHudToastSerial[playerid] < 1) gVexHudToastSerial[playerid] = 1;
    gVexHudToastTimer[playerid] = SetTimerEx("VX_HideHudToast", 4200, false, "ii", playerid, gVexHudToastSerial[playerid]);

    PlayerTextDrawShow(playerid, gVexHudToastBg[playerid]);
    PlayerTextDrawShow(playerid, gVexHudToastAccent[playerid]);
    PlayerTextDrawShow(playerid, gVexHudToastTitle[playerid]);
    PlayerTextDrawShow(playerid, gVexHudToastBody[playerid]);
    return 1;
}

public VX_HideHudToast(playerid, serial)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || serial != gVexHudToastSerial[playerid]) return 0;
    gVexHudToastTimer[playerid] = 0;
    if (!IsPlayerConnected(playerid)) return 1;
    if (gVexHudToastBg[playerid] != PlayerText:INVALID_TEXT_DRAW) PlayerTextDrawHide(playerid, gVexHudToastBg[playerid]);
    if (gVexHudToastAccent[playerid] != PlayerText:INVALID_TEXT_DRAW) PlayerTextDrawHide(playerid, gVexHudToastAccent[playerid]);
    if (gVexHudToastTitle[playerid] != PlayerText:INVALID_TEXT_DRAW) PlayerTextDrawHide(playerid, gVexHudToastTitle[playerid]);
    if (gVexHudToastBody[playerid] != PlayerText:INVALID_TEXT_DRAW) PlayerTextDrawHide(playerid, gVexHudToastBody[playerid]);
    return 1;
}

stock VexHudStoreValue(playerid, E_VEX_HUD_VALUE:item, PlayerText:td)
{
    gVexHudValue[playerid][item] = td;
    return 1;
}

stock VexHudStoreBar(playerid, E_VEX_HUD_BAR:bar, PlayerText:td)
{
    gVexHudBar[playerid][bar] = td;
    return 1;
}

stock VexHudSetValue(playerid, E_VEX_HUD_VALUE:item, const text[])
{
    if (!gHudCreated[playerid]) return 0;
    // SA-MP's legacy strcmp can report equality for an empty string.
    // Check initialization and equal lengths BEFORE comparing cached contents.
    if (gVexHudCache[playerid][item][0] != '\0'
        && strlen(gVexHudCache[playerid][item]) == strlen(text)
        && !strcmp(gVexHudCache[playerid][item], text, false)) return 1;
    new encoded[VEX_HUD_TEXT_SIZE];
    VexHudEncode(playerid, text, encoded, sizeof encoded);
    PlayerTextDrawSetString(playerid, gVexHudValue[playerid][item], encoded);
    format(gVexHudCache[playerid][item], VEX_HUD_TEXT_SIZE, "%s", text);
    return 1;
}

stock VexHudSetBar(playerid, E_VEX_HUD_BAR:bar, percent, color)
{
    if (!gHudCreated[playerid]) return 0;
    percent = VexHudClamp(percent, 0, 100);
    if (!percent) color = 0x00000000;
    if (gVexHudBarPercent[playerid][bar] == percent && gVexHudBarColor[playerid][bar] == color) return 1;
    new Float:width = gVexHudBarWidth[bar] * float(percent) / 100.0;
    if (width < 0.1) width = 0.1; // Never send a negative/invalid sprite size.
    PlayerTextDrawTextSize(playerid, gVexHudBar[playerid][bar], width, gVexHudBarHeight[bar]);
    PlayerTextDrawColor(playerid, gVexHudBar[playerid][bar], color);
    gVexHudBarPercent[playerid][bar] = percent;
    gVexHudBarColor[playerid][bar] = color;
    // Geometry changes require re-showing that bar, not the entire interface.
    if (((bar == VHB_FUEL || bar == VHB_SPEED) && gVexHudCarShown[playerid])
        || ((bar != VHB_FUEL && bar != VHB_SPEED) && gVexHudMainShown[playerid]))
        PlayerTextDrawShow(playerid, gVexHudBar[playerid][bar]);
    return 1;
}

stock HideVexHud(playerid)
{
    VX_HideHudToastNow(playerid);
    if (gVexHudMainShown[playerid] || gVexHudCarShown[playerid])
        for (new i = 0; i < gVexHudCount[playerid]; i++)
            PlayerTextDrawHide(playerid, gVexHud[playerid][i]);
    gVexHudMainShown[playerid] = false;
    gVexHudCarShown[playerid] = false;
    return 1;
}

stock DestroyVexHud(playerid)
{
    VX_HideHudToastNow(playerid);
    if (gVexHudToastBg[playerid] != PlayerText:INVALID_TEXT_DRAW) PlayerTextDrawDestroy(playerid, gVexHudToastBg[playerid]);
    if (gVexHudToastAccent[playerid] != PlayerText:INVALID_TEXT_DRAW) PlayerTextDrawDestroy(playerid, gVexHudToastAccent[playerid]);
    if (gVexHudToastTitle[playerid] != PlayerText:INVALID_TEXT_DRAW) PlayerTextDrawDestroy(playerid, gVexHudToastTitle[playerid]);
    if (gVexHudToastBody[playerid] != PlayerText:INVALID_TEXT_DRAW) PlayerTextDrawDestroy(playerid, gVexHudToastBody[playerid]);
    gVexHudToastBg[playerid] = PlayerText:INVALID_TEXT_DRAW;
    gVexHudToastAccent[playerid] = PlayerText:INVALID_TEXT_DRAW;
    gVexHudToastTitle[playerid] = PlayerText:INVALID_TEXT_DRAW;
    gVexHudToastBody[playerid] = PlayerText:INVALID_TEXT_DRAW;
    for (new i = 0; i < gVexHudCount[playerid]; i++)
    {
        PlayerTextDrawDestroy(playerid, gVexHud[playerid][i]);
        gVexHud[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
    }
    gVexHudCount[playerid] = 0;
    gVexHudMainCount[playerid] = 0;
    gHudCreated[playerid] = false;
    gVexHudMainShown[playerid] = false;
    gVexHudCarShown[playerid] = false;
    return 1;
}

stock CreateVexHud(playerid)
{
    if (gHudCreated[playerid]) return 1;
    if (!IsPlayerConnected(playerid) || IsPlayerNPC(playerid) || gVexHudBuildFailed[playerid]) return 0;
    gVexHudCount[playerid] = 0;
    gVexHudMainShown[playerid] = false;
    gVexHudCarShown[playerid] = false;
    for (new i = 0; i < _:VHV_COUNT; i++) gVexHudCache[playerid][E_VEX_HUD_VALUE:i][0] = '\0';
    for (new i = 0; i < _:VHB_COUNT; i++)
    {
        gVexHudBarPercent[playerid][E_VEX_HUD_BAR:i] = -1;
        gVexHudBarColor[playerid][E_VEX_HUD_BAR:i] = 0;
    }

    // Premium dark player card: opaque enough to cover GTA stock counters cleanly.
    // The brighter header and thin teal rails establish a consistent VEXORIUM theme.
    VexHudRect(playerid, 465.0, 5.0, 171.0, 174.0, 0x0A111EFF);
    VexHudRect(playerid, 465.0, 5.0, 171.0, 26.0, 0x142536FF);
    VexHudRect(playerid, 465.0, 5.0, 171.0, 1.8, VEX_HUD_ACCENT);
    VexHudRect(playerid, 465.0, 7.0, 2.0, 172.0, VEX_HUD_ACCENT);
    VexHudText(playerid, 486.0, 13.0, "vexorium", 0.310, 1.50, VEX_HUD_ACCENT, 1, 1);
    VexHudStoreValue(playerid, VHV_ID, VexHudText(playerid, 616.0, 16.0, "_", 0.150, 0.90, VEX_HUD_MUTED, 3, 3));
    VexHudStoreValue(playerid, VHV_NAME, VexHudText(playerid, 486.0, 30.0, "_", 0.170, 0.90, VEX_HUD_WHITE, 1, 1));
    VexHudRect(playerid, 486.0, 43.0, 130.0, 0.7, 0xFFFFFF18);
    VexHudText(playerid, 486.0, 47.0, "��������", 0.140, 0.85, VEX_HUD_MUTED, 1, 1);
    VexHudText(playerid, 560.0, 47.0, "�����", 0.140, 0.85, VEX_HUD_MUTED, 1, 1);
    VexHudStoreValue(playerid, VHV_HEALTH, VexHudText(playerid, 548.0, 45.0, "_", 0.185, 1.00, VEX_HUD_WHITE, 3, 3));
    VexHudStoreValue(playerid, VHV_ARMOUR, VexHudText(playerid, 616.0, 45.0, "_", 0.185, 1.00, VEX_HUD_WHITE, 3, 3));
    VexHudRect(playerid, 486.0, 59.0, 62.0, 4.0, VEX_HUD_TRACK);
    VexHudRect(playerid, 560.0, 59.0, 56.0, 4.0, VEX_HUD_TRACK);
    VexHudStoreBar(playerid, VHB_HEALTH, VexHudRect(playerid, 486.0, 59.0, 62.0, 4.0, VEX_HUD_HEALTH));
    VexHudStoreBar(playerid, VHB_ARMOUR, VexHudRect(playerid, 560.0, 59.0, 56.0, 4.0, VEX_HUD_ARMOUR));
    VexHudRect(playerid, 482.0, 65.0, 138.0, 16.0, 0x111D2AFF);
    VexHudRect(playerid, 482.0, 81.0, 138.0, 16.0, 0x0D1925FF);
    VexHudText(playerid, 486.0, 69.0, "��������", 0.155, 0.90, VEX_HUD_MUTED, 1, 1);
    VexHudStoreValue(playerid, VHV_CASH, VexHudText(playerid, 616.0, 67.0, "_", 0.195, 1.10, VEX_HUD_ACCENT, 3, 3));
    VexHudText(playerid, 486.0, 85.0, "����", 0.155, 0.90, VEX_HUD_MUTED, 1, 1);
    VexHudStoreValue(playerid, VHV_BANK, VexHudText(playerid, 616.0, 83.0, "_", 0.185, 1.00, VEX_HUD_WHITE, 3, 3));
    VexHudRect(playerid, 486.0, 97.0, 130.0, 0.7, 0xFFFFFF18);
    VexHudText(playerid, 486.0, 103.0, "�������", 0.145, 0.85, VEX_HUD_MUTED, 1, 1);
    VexHudStoreValue(playerid, VHV_LEVEL, VexHudText(playerid, 548.0, 101.0, "_", 0.195, 1.05, VEX_HUD_WHITE, 3, 3));
    VexHudStoreValue(playerid, VHV_XP, VexHudText(playerid, 616.0, 103.0, "_", 0.125, 0.85, VEX_HUD_MUTED, 3, 3));
    VexHudRect(playerid, 486.0, 117.0, 130.0, 2.0, VEX_HUD_TRACK);
    VexHudStoreBar(playerid, VHB_XP, VexHudRect(playerid, 486.0, 117.0, 130.0, 2.0, VEX_HUD_ACCENT));
    VexHudText(playerid, 486.0, 125.0, "�����������", 0.130, 0.85, VEX_HUD_MUTED, 1, 1);
    VexHudStoreValue(playerid, VHV_FACTION, VexHudText(playerid, 616.0, 123.0, "_", 0.170, 0.95, VEX_HUD_WHITE, 3, 1));
    VexHudText(playerid, 486.0, 141.0, "������", 0.135, 0.80, VEX_HUD_MUTED, 1, 1);
    VexHudStoreValue(playerid, VHV_WANTED, VexHudText(playerid, 544.0, 139.0, "_", 0.160, 0.90, VEX_HUD_WARNING, 3, 3));
    VexHudText(playerid, 558.0, 141.0, "�������", 0.130, 0.80, VEX_HUD_MUTED, 1, 1);
    VexHudStoreValue(playerid, VHV_AMMO, VexHudText(playerid, 616.0, 139.0, "_", 0.150, 0.90, VEX_HUD_WHITE, 3, 3));

    VexHudText(playerid, 486.0, 155.0, "������", 0.135, 0.80, VEX_HUD_MUTED);
    VexHudStoreValue(playerid, VHV_WEAPON,
        VexHudText(playerid, 616.0, 153.0, "_", 0.135, 0.85, VEX_HUD_WHITE, 3, 1));

    // VEX NAV 3.0: preserve the real GTA radar and add a compact navigation header.
    // SA-MP 0.3.7 cannot replace the native radar with a custom live road map.
    VexHudRect(playerid, 5.0, 271.0, 150.0, 33.0, 0x0B1624F0);
    VexHudRect(playerid, 5.0, 271.0, 150.0, 1.5, VEX_HUD_ACCENT);
    VexHudRect(playerid, 5.0, 302.5, 150.0, 1.0, 0x58E3BA90);
    VexHudText(playerid, 12.0, 276.0, "VEX NAV", 0.205, 1.00, VEX_HUD_ACCENT);
    VexHudText(playerid, 143.0, 276.0, "N", 0.160, 0.90, VEX_HUD_WHITE, 3, 1);
    VexHudRect(playerid, 12.0, 289.0, 136.0, 0.6, 0xFFFFFF25);
    VexHudStoreValue(playerid, VHV_NAV_MARKET,
        VexHudText(playerid, 12.0, 293.0, "MARKET --", 0.115, 0.75, VEX_HUD_ACCENT));
    VexHudStoreValue(playerid, VHV_NAV_FUEL,
        VexHudText(playerid, 91.0, 293.0, "GAS --", 0.115, 0.75, VEX_HUD_WARNING));
    VexHudStoreValue(playerid, VHV_NAV_DIRECTION,
        VexHudText(playerid, 143.0, 293.0, "N", 0.125, 0.75, VEX_HUD_WHITE, 3, 1));
    // Thin edge accents frame the original live radar without hiding its map.
    VexHudRect(playerid, 4.0, 306.0, 1.0, 130.0, 0x58E3BA80);
    VexHudRect(playerid, 155.0, 306.0, 1.0, 130.0, 0x58E3BA80);
    VexHudRect(playerid, 5.0, 436.0, 150.0, 1.0, 0x58E3BA80);
    gVexHudMainCount[playerid] = gVexHudCount[playerid];

    // VEX DRIVE card: a clear live speed readout, speed-limit gauge, fuel and vehicle state.
    VexHudRect(playerid, 472.0, 358.0, 164.0, 80.0, 0x0A111EFF);
    VexHudRect(playerid, 472.0, 358.0, 164.0, 21.0, 0x142536FF);
    VexHudRect(playerid, 472.0, 358.0, 164.0, 1.8, VEX_HUD_ACCENT);
    VexHudRect(playerid, 472.0, 358.0, 2.0, 80.0, VEX_HUD_ACCENT);
    VexHudText(playerid, 483.0, 363.0, "VEX DRIVE", 0.175, 0.95, VEX_HUD_ACCENT, 1, 1);
    VexHudStoreValue(playerid, VHV_SPEED, VexHudText(playerid, 483.0, 381.0, "_", 0.430, 2.00, VEX_HUD_WHITE, 1, 1));
    VexHudText(playerid, 540.0, 394.0, "��/�", 0.125, 0.75, VEX_HUD_MUTED, 1, 1);
    VexHudText(playerid, 574.0, 380.0, "�������", 0.125, 0.75, VEX_HUD_MUTED, 1, 1);
    VexHudStoreValue(playerid, VHV_FUEL, VexHudText(playerid, 624.0, 389.0, "_", 0.190, 1.05, VEX_HUD_WHITE, 3, 3));
    VexHudRect(playerid, 574.0, 405.0, 50.0, 3.0, VEX_HUD_TRACK);
    VexHudStoreBar(playerid, VHB_FUEL, VexHudRect(playerid, 574.0, 405.0, 50.0, 3.0, VEX_HUD_ACCENT));
    VexHudRect(playerid, 483.0, 405.0, 76.0, 3.0, VEX_HUD_TRACK);
    VexHudStoreBar(playerid, VHB_SPEED, VexHudRect(playerid, 483.0, 405.0, 76.0, 3.0, VEX_HUD_ACCENT));
    VexHudStoreValue(playerid, VHV_ENGINE, VexHudText(playerid, 483.0, 414.0, "_", 0.135, 0.80, VEX_HUD_WHITE, 1, 1));
    VexHudStoreValue(playerid, VHV_LOCK, VexHudText(playerid, 624.0, 414.0, "_", 0.125, 0.75, VEX_HUD_MUTED, 3, 1));
    VexHudText(playerid, 483.0, 429.0, "�����", 0.130, 0.75, VEX_HUD_MUTED, 1, 1);
    VexHudStoreValue(playerid, VHV_BODY, VexHudText(playerid, 536.0, 427.0, "_", 0.155, 0.85, VEX_HUD_WHITE, 3, 3));
    if (!VX_CreateHudToast(playerid)) gVexHudBuildFailed[playerid] = true;

    if (gVexHudBuildFailed[playerid])
    {
        DestroyVexHud(playerid);
        printf("[VEXORIUM HUD] Creation failed for player %d; check textdraw limits.", playerid);
        SendClientMessage(playerid, COLOR_RED, "[HUD] �� ������� ������� ���������. ��������� server_log.txt.");
        return 0;
    }
    gHudCreated[playerid] = true;
    return 1;
}

// Local north-up diagram, not a road map. Markers are visible within 450 m.
stock VexNavSetCell(playerid, cell, code)
{
    // Retained for compatibility with UpdateVexNav; no fake grid is drawn.
    #pragma unused playerid, cell, code
    return 1;
}

stock VexNavCell(Float:dx, Float:dy)
{
    new column = 1, row = 1;
    if (dx < -65.0) column = 0;
    else if (dx > 65.0) column = 2;
    if (dy > 65.0) row = 0;
    else if (dy < -65.0) row = 2;
    return row * 3 + column;
}

stock UpdateVexNav(playerid)
{
    if (!gHudCreated[playerid]) return 0;
    new cells[9];
    cells[4] = 4;
    if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0)
    {
        VexHudSetValue(playerid, VHV_NAV_MARKET, "� ���������");
        VexHudSetValue(playerid, VHV_NAV_FUEL, "");
    }
    else
    {
        new Float:x, Float:y, Float:z, Float:bestM = 450.1, Float:bestA = 450.1;
        GetPlayerPos(playerid, x, y, z);
        for (new m = 0; m < VX_MARKET_COUNT; m++)
        {
            new Float:dx = gVXMarketPos[m][0] - x;
            new Float:dy = gVXMarketPos[m][1] - y;
            new Float:dist = floatsqroot(dx*dx+dy*dy);
            if (dist < bestM) bestM = dist;
            if (dist <= 450.0)
            {
                new idx = VexNavCell(dx, dy);
                if (idx != 4) cells[idx] = cells[idx] == 2 ? 3 : 1;
            }
        }
        for (new a = 0; a < VX_GAS_COUNT; a++)
        {
            new Float:dx = gVXGasPos[a][0] - x;
            new Float:dy = gVXGasPos[a][1] - y;
            new Float:dist = floatsqroot(dx*dx+dy*dy);
            if (dist < bestA) bestA = dist;
            if (dist <= 450.0)
            {
                new idx = VexNavCell(dx, dy);
                if (idx != 4) cells[idx] = cells[idx] == 1 ? 3 : 2;
            }
        }
        new label[64];
        if (bestM > 450.0) format(label, sizeof label, "�������: ���");
        else format(label, sizeof label, "�������: %d �", floatround(bestM));
        VexHudSetValue(playerid, VHV_NAV_MARKET, label);
        if (bestA > 450.0) format(label, sizeof label, "���: ���");
        else format(label, sizeof label, "���: %d �", floatround(bestA));
        VexHudSetValue(playerid, VHV_NAV_FUEL, label);
    }
    new Float:angle;
    GetPlayerFacingAngle(playerid, angle);
    if (angle >= 315.0 || angle < 45.0) VexHudSetValue(playerid, VHV_NAV_DIRECTION, "�");
    else if (angle < 135.0) VexHudSetValue(playerid, VHV_NAV_DIRECTION, "�");
    else if (angle < 225.0) VexHudSetValue(playerid, VHV_NAV_DIRECTION, "�");
    else VexHudSetValue(playerid, VHV_NAV_DIRECTION, "�");
    for (new c = 0; c < 9; c++) VexNavSetCell(playerid, c, cells[c]);
    return 1;
}

stock UpdateVexHud(playerid)
{
    if (!IsPlayerConnected(playerid) || IsPlayerNPC(playerid)) return 0;
    if (!gLogged[playerid] || !gVexHudEnabled[playerid]) return HideVexHud(playerid);
    if (!gHudCreated[playerid] && !CreateVexHud(playerid)) return 0;
    UpdateVexNav(playerid);

    new text[VEX_HUD_TEXT_SIZE], Float:health, Float:armour;
    format(text, sizeof text, "%s", gName[playerid]);
    for (new i = 0; text[i] != '\0'; i++)
        if (text[i] == '~' || text[i] == '{' || text[i] == '}' || text[i] < 32) text[i] = '_';
    if (strlen(text) > 20)
    {
        text[17] = '.'; text[18] = '.'; text[19] = '.'; text[20] = '\0';
    }
    if (gVexHudFont[playerid] == 6)
        for (new i = 0; text[i] != '\0'; i++)
            if (text[i] >= 'A' && text[i] <= 'Z') text[i] += ('a' - 'A');
    VexHudSetValue(playerid, VHV_NAME, text);
    format(text, sizeof text, "#%d", playerid);
    VexHudSetValue(playerid, VHV_ID, text);

    GetPlayerHealth(playerid, health);
    GetPlayerArmour(playerid, armour);
    new hp = VexHudClamp(floatround(health), 0, 9999);
    new ap = VexHudClamp(floatround(armour), 0, 9999);
    if (GetPlayerState(playerid) == PLAYER_STATE_WASTED) hp = 0;
    format(text, sizeof text, "%d", hp); VexHudSetValue(playerid, VHV_HEALTH, text);
    format(text, sizeof text, "%d", ap); VexHudSetValue(playerid, VHV_ARMOUR, text);
    VexHudSetBar(playerid, VHB_HEALTH, hp, hp <= 25 ? 0xFF465FFF : VEX_HUD_HEALTH);
    VexHudSetBar(playerid, VHB_ARMOUR, ap, VEX_HUD_ARMOUR);

    VexHudFormatMoney(gMoney[playerid], text, sizeof text); VexHudSetValue(playerid, VHV_CASH, text);
    VexHudFormatMoney(gBankMoney[playerid], text, sizeof text); VexHudSetValue(playerid, VHV_BANK, text);
    new level = VexHudClamp(gLevel[playerid], 1, 1000);
    format(text, sizeof text, "%d", level); VexHudSetValue(playerid, VHV_LEVEL, text);
    if (level >= 1000)
    {
        VexHudSetValue(playerid, VHV_XP, "100%");
        VexHudSetBar(playerid, VHB_XP, 100, VEX_HUD_ACCENT);
    }
    else
    {
        new floorxp = GetExperienceForLevel(level);
        new needed = GetExperienceForLevel(level + 1) - floorxp;
        if (needed < 1) needed = 1;
        new earned = VexHudClamp(gExperience[playerid] - floorxp, 0, needed);
        format(text, sizeof text, "%d/%d", earned, needed);
        VexHudSetValue(playerid, VHV_XP, text);
        VexHudSetBar(playerid, VHB_XP, earned * 100 / needed, VEX_HUD_ACCENT);
    }
    GetHudFactionName(playerid, text, sizeof text); VexHudSetValue(playerid, VHV_FACTION, text);
    new weapon = GetPlayerWeapon(playerid);
    if ((weapon >= 22 && weapon <= 38) || (weapon >= 16 && weapon <= 18) || weapon == 39 || (weapon >= 41 && weapon <= 43))
        format(text, sizeof text, "%d", GetPlayerAmmo(playerid));
    else format(text, sizeof text, "--");
    VexHudSetValue(playerid, VHV_AMMO, text);
    switch (weapon)
    {
        case 0: format(text, sizeof text, "������");
        case 3: format(text, sizeof text, "�������");
        case 22: format(text, sizeof text, "��������");
        case 23: format(text, sizeof text, "������");
        case 24: format(text, sizeof text, "DESERT EAGLE");
        case 25, 26, 27: format(text, sizeof text, "��������");
        case 28, 29, 32: format(text, sizeof text, "��������-����̨�");
        case 30: format(text, sizeof text, "��-47");
        case 31: format(text, sizeof text, "M4");
        case 33, 34: format(text, sizeof text, "��������");
        default: format(text, sizeof text, "ID %d", weapon);
    }
    VexHudSetValue(playerid, VHV_WEAPON, text);
    format(text, sizeof text, "%d/6", VexHudClamp(gWantedLevel[playerid], 0, 6));
    VexHudSetValue(playerid, VHV_WANTED, text);

    if (!gVexHudMainShown[playerid])
    {
        for (new i = 0; i < gVexHudMainCount[playerid]; i++) PlayerTextDrawShow(playerid, gVexHud[playerid][i]);
        gVexHudMainShown[playerid] = true;
    }
    new playerState = GetPlayerState(playerid), vehicleid = GetPlayerVehicleID(playerid);
    new bool:inVehicle = ((playerState == PLAYER_STATE_DRIVER || playerState == PLAYER_STATE_PASSENGER) && vehicleid > 0 && vehicleid < MAX_VEHICLES);
    if (inVehicle && GetVehicleModel(vehicleid) == 0) inVehicle = false;
    if (!inVehicle)
    {
        if (gVexHudCarShown[playerid])
            for (new i = gVexHudMainCount[playerid]; i < gVexHudCount[playerid]; i++) PlayerTextDrawHide(playerid, gVexHud[playerid][i]);
        gVexHudCarShown[playerid] = false;
        return 1;
    }

    new Float:vx, Float:vy, Float:vz, Float:condition;
    GetVehicleVelocity(vehicleid, vx, vy, vz);
    new Float:speedScale = VX_VehicleSpeedScale(vehicleid);
    new speed = VexHudClamp(floatround(floatsqroot(vx * vx + vy * vy + vz * vz) * speedScale), 0, 999);
    format(text, sizeof text, "%03d", speed); VexHudSetValue(playerid, VHV_SPEED, text);
    new speedGaugeMax = VX_VehicleSpeedLimitKmh(vehicleid);
    if (speedGaugeMax <= 0) speedGaugeMax = 250;
    new speedGaugePercent = VexHudClamp(speed * 100 / speedGaugeMax, 0, 100);
    new speedGaugeColor = (speedGaugePercent >= 90) ? VEX_HUD_WARNING : VEX_HUD_ACCENT;
    VexHudSetBar(playerid, VHB_SPEED, speedGaugePercent, speedGaugeColor);
    new fuel = VexHudClamp(gVehicleFuel[vehicleid], 0, 100);
    if (fuel <= 15) format(text, sizeof text, "~r~%d%%", fuel);
    else format(text, sizeof text, "%d%%", fuel);
    VexHudSetValue(playerid, VHV_FUEL, text);
    VexHudSetBar(playerid, VHB_FUEL, fuel, fuel <= 15 ? 0xFF465FFF : VEX_HUD_ACCENT);
    new engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
    if (engine == VEHICLE_PARAMS_ON) VexHudSetValue(playerid, VHV_ENGINE, "~g~����: ���");
    else if (engine == VEHICLE_PARAMS_OFF) VexHudSetValue(playerid, VHV_ENGINE, "~r~����: ����");
    else VexHudSetValue(playerid, VHV_ENGINE, "����: --");
    if (doors == VEHICLE_PARAMS_ON) VexHudSetValue(playerid, VHV_LOCK, "�������");
    else if (doors == VEHICLE_PARAMS_OFF) VexHudSetValue(playerid, VHV_LOCK, "�������");
    else VexHudSetValue(playerid, VHV_LOCK, "�����: --");
    GetVehicleHealth(vehicleid, condition);
    format(text, sizeof text, "%d%%", VexHudClamp(floatround(condition / 10.0), 0, 100));
    VexHudSetValue(playerid, VHV_BODY, text);
    if (!gVexHudCarShown[playerid])
    {
        for (new i = gVexHudMainCount[playerid]; i < gVexHudCount[playerid]; i++) PlayerTextDrawShow(playerid, gVexHud[playerid][i]);
        gVexHudCarShown[playerid] = true;
    }
    return 1;
}

public RefreshVexHud(playerid)
{
    return UpdateVexHud(playerid);
}

stock ShowVexHud(playerid)
{
    // Preserve /hud off across spawns, paydays and other game callbacks.
    return UpdateVexHud(playerid);
}

stock LoadVexHudSettings(playerid)
{
    if (gDatabase == DB:0 || !gLogged[playerid]) return 0;
    new query[192];
    format(query, sizeof query, "SELECT hud_font,hud_visible,hud_revision FROM accounts WHERE name='%q'", gName[playerid]);
    new DBResult:result = db_query(gDatabase, query);
    if (!result) return 0;
    new bool:migrate = false;
    if (db_num_rows(result))
    {
        gVexHudFont[playerid] = VEX_HUD_DEFAULT_FONT; // Russian HUD profile for every login
        gVexHudEnabled[playerid] = (db_get_field_int(result, 1) != 0);
        if (db_get_field_int(result, 2) < VEX_HUD_SETTINGS_REVISION)
        {
            // Old default (SanLtd) did not match the reported client screenshot.
            // Other explicit profiles are preserved; later choices are untouched.
            gVexHudFont[playerid] = VEX_HUD_DEFAULT_FONT;
            migrate = true;
        }
    }
    db_free_result(result);
    if (migrate) SaveVexHudSettings(playerid);
    return 1;
}

stock SaveVexHudSettings(playerid)
{
    if (gDatabase == DB:0 || !gLogged[playerid]) return 0;
    new query[192];
    format(query, sizeof query, "UPDATE accounts SET hud_font=%d,hud_visible=%d,hud_revision=%d WHERE name='%q'", gVexHudFont[playerid], _:gVexHudEnabled[playerid], VEX_HUD_SETTINGS_REVISION, gName[playerid]);
    new DBResult:result = db_query(gDatabase, query);
    if (!result)
    {
        SendClientMessage(playerid, COLOR_YELLOW, "[HUD] ��������� ��������� �� ������: �� ������� ��������� � � ����.");
        return 0;
    }
    db_free_result(result);
    return 1;
}

stock ShowVexHudFonts(playerid)
{
    SendClientMessage(playerid, COLOR_YELLOW, "[HUD] ������� ������ ��������� � ������������� GTA. ��� ������� ������� ������� ��������� �� ��������.");
    return ShowPlayerDialog(playerid, DIALOG_VEX_HUD_FONT, DIALOG_STYLE_LIST,
        "VEXORIUM | ������� ����� HUD", "1. SanLtd\n2. 1�\n3. RUS / Rush\n4. Community\n5. MG\n6. ������ CP1251 / rustext\n7. ASCII / Unknown3 - �������\n8. Unknown2\n9. Unknown1", "�������", "�������");
}

stock SetVexHudFont(playerid, profile)
{
    if (!gLogged[playerid] || profile < 0 || profile >= VEX_HUD_FONT_COUNT) return 0;
    DestroyVexHud(playerid);
    gVexHudFont[playerid] = profile;
    gVexHudBuildFailed[playerid] = false;
    ShowVexHud(playerid);
    SaveVexHudSettings(playerid);
    SendClientMessage(playerid, COLOR_GREEN, "[HUD] ����� ��������. �������� �����? �������� ������ � /hudfont.");
    return 1;
}

stock IsNearGasStation(playerid)
{
    if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0) return 0;
    for (new g = 0; g < VX_GAS_COUNT; g++)
        if (IsPlayerInRangeOfPoint(playerid, 20.0, gVXGasPos[g][0], gVXGasPos[g][1], gVXGasPos[g][2])) return 1;
    return 0;
}

stock GiveCash(playerid, amount)
{
    if (amount <= 0 || gMoney[playerid] > MAX_MONEY - amount) return 0;
    gMoney[playerid] += amount;
    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid, gMoney[playerid]);
    UpdateVexHud(playerid);
    new toastText[48];
    format(toastText, sizeof toastText, "+%d ���. ���������", amount);
    VX_Notify(playerid, "���������", toastText, VEX_HUD_ACCENT);
    return 1;
}

stock TakeCash(playerid, amount)
{
    if (amount <= 0 || gMoney[playerid] < amount) return 0;
    gMoney[playerid] -= amount;
    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid, gMoney[playerid]);
    UpdateVexHud(playerid);
    new toastText[48];
    format(toastText, sizeof toastText, "-%d ���. ���������", amount);
    VX_Notify(playerid, "������", toastText, VEX_HUD_WARNING);
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
    // Stock GTA:SA skins; uniform tier is determined by the actual faction rank.
    if(rank<1)rank=1;
    if(rank>10)rank=10;
    switch(faction)
    {
        case FACTION_CITYHALL:
        {
            switch(rank)
            {
                case 1,2: return 150; // office employees
                case 3,4: return 147;
                case 5,6: return 148;
                case 7,8: return 187;
                case 9: return 189;
                case 10: return 295;
            }
        }
        case FACTION_POLICE:
        {
            switch(rank)
            {
                case 1: return 280;
                case 2: return 281;
                case 3: return 282;
                case 4: return 283;
                case 5: return 284;
                case 6: return 285;
                case 7: return 288;
                case 8: return 306;
                case 9: return 307;
                case 10: return 294;
            }
        }
        case FACTION_HOSPITAL:
        {
            switch(rank)
            {
                case 1: return 274;
                case 2: return 275;
                case 3: return 276;
                case 4: return 70;
                case 5: return 71;
                case 6: return 72;
                case 7: return 73;
                case 8: return 274;
                case 9: return 276;
                case 10: return 70;
            }
        }
        case FACTION_ARMY:
        {
            if(rank>=9)return 62;
            if(rank>=6)return 287;
            return 179;
        }
        case FACTION_NAVY:
        {
            if(rank>=9)return 62;
            if(rank>=6)return 61;
            return 287;
        }
        case FACTION_AIRFORCE:
        {
            if(rank>=9)return 62;
            if(rank>=6)return 61;
            return 287;
        }
        case FACTION_FBI:
        {
            if(rank>=9)return 286;
            if(rank>=8)return 166;
            if(rank>=5 && rank<=7)return 285; // VEXORIUM tactical FBI skin for ranks 5-7.
            if(rank>=2)return 164;
            return 163;
        }
    }
    return 23; // never return CJ skin (0)
}

// Work outfit is derived from the saved job, never from GetPlayerSkin after death.
stock VX_WorkSkin(job)
{
    switch (job)
    {
        case 1: return 255; // taxi
        case 2: return 133; // truck driver
        case 3: return 253; // bus driver
        case 4: return 27;  // miner
        case 5: return 29;  // car thief
        case 6: return 17;  // lawyer
        case 7: return 277; // firefighter uniform
    }
    return 0;
}

// ====================== VEXORIUM | ������� ������ ======================
stock VX_ClothesNear(playerid)
{
    if (GetPlayerVirtualWorld(playerid) != 0 || GetPlayerInterior(playerid) != 0) return 0;
    for (new i=0; i<VX_CLOTHES_LOCATIONS; i++)
        if (IsPlayerInRangeOfPoint(playerid, 6.0, gVXClothesPos[i][0],
            gVXClothesPos[i][1], gVXClothesPos[i][2])) return 1;
    return 0;
}
stock VX_ClothesUniform(playerid)
{
    if (gFaction[playerid] < FACTION_CITYHALL || gFaction[playerid] > FACTION_FBI || gFactionRank[playerid] < 1) return 0;
    // Check the skin actually worn, not just faction membership.
    return GetPlayerSkin(playerid) == GetFactionSkin(gFaction[playerid],gFactionRank[playerid]);
}
stock VX_ClothesCanUse(playerid)
{
    if (!gLogged[playerid] || !gRPLoaded[playerid] || gVXHospital[playerid] || gIsJailed[playerid]
        || gHandcuffed[playerid] || gTaserStunned[playerid] || IsPlayerInAnyVehicle(playerid)) return 0;
    if (!VX_ClothesNear(playerid)) return 0;
    if (VX_ClothesUniform(playerid)) return 0;
    return 1;
}
stock VX_ClothesCancel(playerid)
{
    if (gVXClothesPreview[playerid] >= 0)
    {
        SetPlayerSkin(playerid, gVXClothesBefore[playerid]);
        gVXClothesPreview[playerid]=-1;
    }
    return 1;
}
stock VX_ClothesOpen(playerid)
{
    if (!gLogged[playerid] || !gRPLoaded[playerid]) return 1;
    if (gVXClothesPreview[playerid]>=0) VX_ClothesCancel(playerid);
    if (!VX_ClothesNear(playerid)) return SendClientMessage(playerid,COLOR_YELLOW,"[������] ��������� � �������� ������. ������: /clothesgps."),1;
    if (gFaction[playerid]>=FACTION_CITYHALL && gFaction[playerid]<=FACTION_FBI && gFactionRank[playerid]>0 && VX_ClothesUniform(playerid))
        return SendClientMessage(playerid,COLOR_RED,"[������] � ��������� ����� �������� ������ ������. ������� ����� � ����������."),1;
    if (!VX_ClothesCanUse(playerid)) return SendClientMessage(playerid,COLOR_RED,"[������] ������ ������� ����������."),1;
    new body[850],line[72];
    format(body,sizeof body,"�����\t����\t����\n");
    for(new i=0;i<VX_CLOTHES_COUNT;i++)
    {
        format(line,sizeof line,"%s\t%d\t%d ���.\n",gVXClothesLabel[i],gVXClothesModel[i],gVXClothesPrice[i]);
        strcat(body,line);
    }
    ShowPlayerDialog(playerid,DIALOG_CLOTHES,DIALOG_STYLE_TABLIST_HEADERS,"VEXORIUM | ������� ������",body,"���������","�������");
    return 1;
}
stock VX_ClothesLoad(playerid, legacySkin)
{
    new query[192];
    format(query,sizeof query,"SELECT skin FROM vx_clothing WHERE name='%q'",gName[playerid]);
    new DBResult:r=db_query(gDatabase,query);
    if(r && db_num_rows(r))
    {
        new skin=db_get_field_int(r,0);
        if(skin>=1 && skin<=311) gVXAccountSkin[playerid]=skin;
        else gVXAccountSkin[playerid]=23;
        db_free_result(r);
        return 1;
    }
    if(r)db_free_result(r);
    // Migration: never mistake a government uniform or job skin for civilian clothing.
    new fallback=legacySkin;
    if (fallback<1 || fallback>311 || (gFaction[playerid]>=FACTION_CITYHALL && gFaction[playerid]<=FACTION_FBI && gFactionRank[playerid]>0 && fallback==GetFactionSkin(gFaction[playerid],gFactionRank[playerid])) ||
        (VX_WorkSkin(gJob[playerid])>0 && fallback==VX_WorkSkin(gJob[playerid]))) fallback=23;
    gVXAccountSkin[playerid]=fallback;
    format(query,sizeof query,"INSERT OR IGNORE INTO vx_clothing(name,skin) VALUES('%q',%d)",gName[playerid],fallback);
    r=db_query(gDatabase,query);if(r)db_free_result(r);
    return 1;
}
stock VX_ClothesBuy(playerid,index)
{
    if(index<0 || index>=VX_CLOTHES_COUNT || !VX_ClothesCanUse(playerid)) return 0;
    new price=gVXClothesPrice[index], skin=gVXClothesModel[index];
    if(gMoney[playerid]<price) return SendClientMessage(playerid,COLOR_RED,"[������] ������������ ��������."),0;
    // Atomic purchase: write account balance and civilian skin together.
    new query[192];
    if(!VX_Begin()) return SendClientMessage(playerid,COLOR_RED,"[������] ���� ������ ����������."),0;
    format(query,sizeof query,"UPDATE accounts SET money=%d WHERE name='%q'",gMoney[playerid]-price,gName[playerid]);
    if(!VX_SQL(query))
    {
        VX_SQL("ROLLBACK");
        return SendClientMessage(playerid,COLOR_RED,"[������] ������ ��������."),0;
    }
    format(query,sizeof query,"INSERT OR REPLACE INTO vx_clothing(name,skin) VALUES('%q',%d)",gName[playerid],skin);
    if(!VX_SQL(query))
    {
        VX_SQL("ROLLBACK");
        return SendClientMessage(playerid,COLOR_RED,"[������] ������� ��������."),0;
    }
    if(!VX_Commit())return SendClientMessage(playerid,COLOR_RED,"[������] �� ������� ��������� �������."),0;
    gMoney[playerid]-=price;
    ResetPlayerMoney(playerid);GivePlayerMoney(playerid,gMoney[playerid]);
    gVXAccountSkin[playerid]=skin;
    gVXClothesPreview[playerid]=-1;
    SetPlayerSkin(playerid,skin);
    UpdateVexHud(playerid);
    new msg[128];format(msg,sizeof msg,"[������] ������ ����� �%s� �� %d ���. ���� %d ��������.",gVXClothesLabel[index],price,skin);
    SendClientMessage(playerid,COLOR_GREEN,msg);
    VX_Notify(playerid, "�������", "����� ����� ��������", VEX_HUD_ACCENT);
    return 1;
}

stock VX_RespawnSkin(playerid)
{
    if (gFaction[playerid] >= FACTION_CITYHALL &&
        gFaction[playerid] <= FACTION_FBI && gFactionRank[playerid] > 0)
        return GetFactionSkin(gFaction[playerid], gFactionRank[playerid]);

    new jobSkin = VX_WorkSkin(gJob[playerid]);
    if (jobSkin > 0) return jobSkin;

    new skin = gVXAccountSkin[playerid];
    if (skin < 1 || skin > 311) skin = 23;
    return skin;
}

stock SpawnLoggedPlayer(playerid, Float:x, Float:y, Float:z, Float:a, skin)
{
    #pragma unused skin
    // Civilian outfit is loaded independently from vx_clothing; never replace it with a uniform.
    if (gVXAccountSkin[playerid] < 1 || gVXAccountSkin[playerid] > 311) gVXAccountSkin[playerid] = 23;
    SetSpawnInfo(playerid, 0, VX_RespawnSkin(playerid), x, y, z, a, 0, 0, 0, 0, 0, 0);
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
    if(gIsJailed[playerid]) return RP_JailPosition(playerid);
    if(gVXHospital[playerid]) return VX_EnterHospital(playerid);
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
        SendClientMessage(playerid, COLOR_GREEN, "�� ��������� �� ���� ����� �����.");
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
                return VX_EnterHospital(playerid);
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
        SendClientMessage(playerid, COLOR_GREEN, "�� ��������� � ���������� ����� �����������.");
    }
    else
    {
        SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
        SetPlayerPos(playerid, 1753.5, -1894.2, 13.6); SetPlayerFacingAngle(playerid, 90.0);
        SendClientMessage(playerid, COLOR_GREEN, "�� ��������� � ������� ���-������.");
    }
    SetCameraBehindPlayer(playerid);
    return 1;
}

stock ShowSpawnMenu(playerid)
{
    if (!gLogged[playerid]) return 0;
    if (gFaction[playerid] >= FACTION_CITYHALL && gFaction[playerid] <= FACTION_FBI)
        ShowPlayerDialog(playerid, DIALOG_SPAWN, DIALOG_STYLE_LIST, "VEXORIUM RP | ����� ���������", "��������� � ����� �����������\n��������� ���� / ������", "�������", "�������");
    else
        ShowPlayerDialog(playerid, DIALOG_SPAWN, DIALOG_STYLE_LIST, "VEXORIUM RP | ����� �������", "��������� ���� / ������\n���������� � �������: /rent", "���������", "�������");
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
    SendClientMessage(playerid, COLOR_BLUE, "========== ������� ����������� ==========");
    if (gFaction[playerid] == FACTION_POLICE)
    {
        SendClientMessage(playerid, COLOR_BLUE, "/showpass [ID] � ��������� �������");
        SendClientMessage(playerid, COLOR_BLUE, "/search [ID] � �������� ����� ����� � �������");
        SendClientMessage(playerid, COLOR_BLUE, "/ticket [ID] [�����] [�������] � �������� ����� (�� 2 �����)");
        SendClientMessage(playerid, COLOR_BLUE, "/arrest [ID] [�������] [�������] � ��������� ������ (�� 2 �����)");
        SendClientMessage(playerid, COLOR_BLUE, "/release [ID] � ���������� �� ��� (� 5 �����)");
        SendClientMessage(playerid, COLOR_BLUE, "/wanted [ID] [0-6] [�������] (� 3 �����), /cuff [ID] � /uncuff [ID] (�� 2 �����), /pursuit [ID]");
        SendClientMessage(playerid, COLOR_BLUE, "/sobescr � ������������� (� 9 �����)");
        SendClientMessage(playerid, COLOR_BLUE, "/org � ���� �������; /duty � ���������� � �����");
    }
    else if (gFaction[playerid] == FACTION_CITYHALL)
    {
        SendClientMessage(playerid, COLOR_BLUE, "/org � ���� ����� � ����������� �����������");
        SendClientMessage(playerid, COLOR_BLUE, "/licgive [ID] [auto/weapon/boat/air] � ������ ��������");
        SendClientMessage(playerid, COLOR_BLUE, "/sobescr � �������� ������������� (� 9 �����)");
        SendClientMessage(playerid, COLOR_BLUE, "��� ��������� ������� ����������� ������� � ���� �����.");
    }
    else
    {
        SendClientMessage(playerid, COLOR_BLUE, "/org � ������� ���� ����� �����������");
        SendClientMessage(playerid, COLOR_BLUE, "/sobescr � �������� ������������� (� 9 �����)");
        SendClientMessage(playerid, COLOR_BLUE, "/duty � ���������� � �����; ������� ����������� � ����� � �����");
    }
    SendClientMessage(playerid, COLOR_BLUE, "========================================");
    return 1;
}

stock ShowPoliceMenu(playerid)
{
    if (GetPlayerInterior(playerid) != 6 || GetPlayerVirtualWorld(playerid) != 0)
        return SendClientMessage(playerid, COLOR_YELLOW, "������� ������� � ������ �������: ��������� � ����� � ����������� /enterpd."), 1;
    ShowPlayerDialog(playerid, DIALOG_POLICE_MENU, DIALOG_STYLE_LIST,
        "VEXORIUM RP | ������� LSPD",
        "���� �������\n������� ����������\n������� �������\n���\n���������� (������ ������)\n����� � ������\n����� �� �������",
        "�������", "�������");
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

stock VX_CarjackReward(model)
{
    switch (model)
    {
        case 400: return 110000; // Landstalker - SUV
        case 401: return 75000;  // Bravura - compact
        case 410: return 65000;  // Manana - low-end classic
        case 426: return 95000;  // Premier - sedan
        case 436: return 80000;  // Previon - coupe
        case 489: return 125000; // Rancher - off-road SUV
    }
    return 65000;
}

stock StartCarjack(playerid)
{
    if (gLevel[playerid] < 3) return SendClientMessage(playerid, COLOR_RED, "��� ������ ������������� ����� 3 �������."), 0;
    if (gFaction[playerid] != FACTION_NONE) return SendClientMessage(playerid, COLOR_RED, "���������� ��������������� ����������� �� ����� �������� ��������������."), 0;
    if (gWorkStage[playerid] > 0 || gCarjackActive[playerid]) return SendClientMessage(playerid, COLOR_YELLOW, "������� ��������� ��� �������� ������� ������."), 0;
    if (IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_YELLOW, "������� �� ���������� ����� ������� ���������."), 0;
    if (gLockpicks[playerid] < 1) return SendClientMessage(playerid, COLOR_RED, "[MARKET] Dlya raboty avtougonschikom nuzhna otmychka. Kupite ee v zdanii marketa ili cherez /shop."), 0;

    // Open-air street/parking locations. Hospital and dealership-front positions are excluded.
    // Fixed exterior Z values keep the code compatible with stock SA-MP 0.3.7.
    new Float:spots[10][4] = {
        {1652.0, -2242.0, 13.5, 90.0},
        {1813.0, -1857.0, 13.5, 90.0},
        {2045.2, -1905.4, 13.5, 90.0},
        {1812.5, -1729.3, 13.5, 270.0},
        {1432.0, -1775.0, 13.5, 0.0},
        {1003.2, -929.5, 42.3, 90.0},
        {2488.2, -1668.4, 13.3, 270.0},
        {1688.4, -2001.3, 13.5, 0.0},
        {470.0, -1730.0, 10.5, 90.0},
        {2103.0, -1802.0, 13.5, 0.0}
    };
    new models[6] = {400, 401, 410, 426, 436, 489};
    new model = models[random(sizeof(models))];
    new startIndex = random(sizeof(spots));
    new idx = -1;
    new vehicleid = INVALID_VEHICLE_ID;
    new Float:spawnX, Float:spawnY, Float:spawnZ, Float:spawnA;

    // Try every candidate in random order, skipping locations blocked by another vehicle.
    // This avoids cars stacking on top of one another and avoids failing just because one bay is occupied.
    for (new attempt = 0; attempt < sizeof(spots); attempt++)
    {
        new candidate = (startIndex + attempt) % sizeof(spots);
        new Float:candidateZ = spots[candidate][2];
        new bool:occupied = false;
        for (new other = 1; other < MAX_VEHICLES; other++)
        {
            if (GetVehicleModel(other) == 0) continue;
            new Float:ox, Float:oy, Float:oz;
            GetVehiclePos(other, ox, oy, oz);
            new Float:dx = ox - spots[candidate][0];
            new Float:dy = oy - spots[candidate][1];
            new Float:dz = oz - candidateZ;
            if (floatsqroot(dx * dx + dy * dy + dz * dz) < 8.0)
            {
                occupied = true;
                break;
            }
        }
        if (occupied) continue;

        spawnX = spots[candidate][0];
        spawnY = spots[candidate][1];
        spawnZ = candidateZ + 0.35;
        spawnA = spots[candidate][3];
        vehicleid = CreateVehicle(model, spawnX, spawnY, spawnZ, spawnA, -1, -1, -1);
        if (vehicleid != INVALID_VEHICLE_ID && GetVehicleModel(vehicleid) != 0)
        {
            idx = candidate;
            break;
        }
        vehicleid = INVALID_VEHICLE_ID;
    }
    if (vehicleid == INVALID_VEHICLE_ID || GetVehicleModel(vehicleid) == 0 || idx < 0)
        return SendClientMessage(playerid, COLOR_RED, "�� ������� ���������� ����� ��� ������. ���������� ���� �����."), 0;

    // Explicitly keep the spawned target in the exterior world/interior.
    SetVehicleVirtualWorld(vehicleid, 0);
    LinkVehicleToInterior(vehicleid, 0);
    gLockpicks[playerid]--;
    SavePlayer(playerid);
    gVXCarjackCharged[playerid] = false;
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
    SetPlayerCheckpoint(playerid, spawnX, spawnY, spawnZ, 5.0);
    SetPlayerMapIcon(playerid, 48, spawnX, spawnY, spawnZ, 55, 0, MAPICON_LOCAL);
    gGpsActive[playerid] = false;
    SendClientMessage(playerid, COLOR_GREEN, "�������� �����! �� ������ �������� ��������� ������. ��������� � ��� � ������� /hack.");
    return 1;
}

stock AnnounceCarjack(playerid)
{
    new msg[160];
    format(msg, sizeof msg, "[���������] ����������� ����� ����������! ������������: /accept | ����������: /cancel.");
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
            SendClientMessage(officer, COLOR_YELLOW, "[LSPD/FBI] No active pursuit target.");
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
            format(pursuitText, sizeof pursuitText, "~r~POLICE PURSUIT!~n~~w~Distance: ~y~%.0f m", nearest);
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

stock VX_GPSNearestMarket(playerid, &Float:outX, &Float:outY, &Float:outZ)
{
    new Float:best = 999999.0;
    new found = 0;
    for (new i = 0; i < VX_MARKET_COUNT; i++)
    {
        new Float:dist = GetPlayerDistanceFromPoint(playerid, gVXMarketPos[i][0], gVXMarketPos[i][1], gVXMarketPos[i][2]);
        if (dist < best)
        {
            best = dist; found = 1;
            outX = gVXMarketPos[i][0]; outY = gVXMarketPos[i][1]; outZ = gVXMarketPos[i][2];
        }
    }
    return found;
}
stock VX_GPSNearestGas(playerid, &Float:outX, &Float:outY, &Float:outZ)
{
    new Float:best = 999999.0;
    new found = 0;
    for (new i = 0; i < VX_GAS_COUNT; i++)
    {
        new Float:dist = GetPlayerDistanceFromPoint(playerid, gVXGasPos[i][0], gVXGasPos[i][1], gVXGasPos[i][2]);
        if (dist < best)
        {
            best = dist; found = 1;
            outX = gVXGasPos[i][0]; outY = gVXGasPos[i][1]; outZ = gVXGasPos[i][2];
        }
    }
    return found;
}
stock VX_GPSNearestClothes(playerid, &Float:outX, &Float:outY, &Float:outZ)
{
    new Float:best = 999999.0;
    new found = 0;
    for (new i = 0; i < VX_CLOTHES_LOCATIONS; i++)
    {
        new Float:dist = GetPlayerDistanceFromPoint(playerid, gVXClothesPos[i][0], gVXClothesPos[i][1], gVXClothesPos[i][2]);
        if (dist < best)
        {
            best = dist; found = 1;
            outX = gVXClothesPos[i][0]; outY = gVXClothesPos[i][1]; outZ = gVXClothesPos[i][2];
        }
    }
    return found;
}
// mode 0 = nearest unowned house; mode 1 = this player's owned house.
stock VX_GPSFindHouse(playerid, mode, &Float:outX, &Float:outY, &Float:outZ)
{
    new DBResult:r = db_query(gDatabase, "SELECT owner,x,y,z FROM houses");
    if (!r) return 0;
    new owner[MAX_PLAYER_NAME + 1];
    new Float:px, Float:py, Float:pz, Float:best = 999999.0;
    new found = 0;
    GetPlayerPos(playerid, px, py, pz);
    for (new row = 0; row < db_num_rows(r); row++)
    {
        owner[0] = '\0';
        db_get_field(r, 0, owner, sizeof owner);
        if (mode == 1)
        {
            if (strcmp(owner, gName[playerid], true) != 0) { db_next_row(r); continue; }
        }
        else if (owner[0] != '\0') { db_next_row(r); continue; }
        new Float:hx = db_get_field_float(r, 1);
        new Float:hy = db_get_field_float(r, 2);
        new Float:hz = db_get_field_float(r, 3);
        new Float:dx = px - hx, Float:dy = py - hy, Float:dz = pz - hz;
        new Float:dist = floatsqroot(dx * dx + dy * dy + dz * dz);
        if (dist < best)
        {
            best = dist; found = 1;
            outX = hx; outY = hy; outZ = hz;
        }
        db_next_row(r);
    }
    db_free_result(r);
    return found;
}
stock VX_TaxiOnDuty(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) || !gLogged[playerid] || !gRPLoaded[playerid]) return 0;
    if (gJob[playerid] != 1 || gWorkStage[playerid] <= 0 || gTaxiOrderTarget[playerid] != INVALID_PLAYER_ID) return 0;
    new v = gWorkVehicle[playerid];
    if (v <= 0 || v >= MAX_VEHICLES || GetVehicleModel(v) != 420) return 0;
    if (GetPlayerState(playerid) != PLAYER_STATE_DRIVER || GetPlayerVehicleID(playerid) != v) return 0;
    if (gHandcuffed[playerid] || gTaserStunned[playerid] || gIsJailed[playerid]) return 0;
    return 1;
}
stock VX_TaxiResumeWork(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return 0;
    if (gWorkStage[playerid] <= 0 || gJob[playerid] != 1 || gWorkVehicle[playerid] <= 0 || GetVehicleModel(gWorkVehicle[playerid]) != 420) return 0;
    if (gWorkStage[playerid] <= 2) SetPlayerCheckpoint(playerid, 1182.0, -1323.0, 13.6, 5.0);
    else SetPlayerCheckpoint(playerid, 1685.0, -2333.0, 13.5, 5.0);
    return 1;
}
stock VX_TaxiClearDriver(driverid, const passengerMessage[], bool:resumeShift)
{
    if (driverid < 0 || driverid >= MAX_PLAYERS) return 0;
    new targetid = gTaxiOrderTarget[driverid];
    if (targetid >= 0 && targetid < MAX_PLAYERS)
    {
        if (IsPlayerConnected(targetid))
        {
            if (gTaxiOrderDriver[targetid] == driverid) gTaxiOrderDriver[targetid] = INVALID_PLAYER_ID;
            gTaxiRequestActive[targetid] = false;
            if (passengerMessage[0] != '\0') SendClientMessage(targetid, COLOR_YELLOW, passengerMessage);
        }
    }
    gTaxiOrderTarget[driverid] = INVALID_PLAYER_ID;
    gTaxiAtPickup[driverid] = false;
    if (IsPlayerConnected(driverid))
    {
        RemovePlayerMapIcon(driverid, 47);
        DisablePlayerCheckpoint(driverid);
        if (resumeShift) VX_TaxiResumeWork(driverid);
    }
    return 1;
}
stock VX_TaxiCancelForPlayer(playerid, const reason[], bool:resumeShift)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS) return 0;
    if (gTaxiOrderTarget[playerid] != INVALID_PLAYER_ID)
        return VX_TaxiClearDriver(playerid, reason, resumeShift);
    new driverid = gTaxiOrderDriver[playerid];
    if (driverid >= 0 && driverid < MAX_PLAYERS && IsPlayerConnected(driverid) && gTaxiOrderTarget[driverid] == playerid)
    {
        SendClientMessage(driverid, COLOR_YELLOW, "[�����] �������� ������� �����.");
        VX_TaxiClearDriver(driverid, "[�����] ������� ��������.", resumeShift);
    }
    gTaxiOrderDriver[playerid] = INVALID_PLAYER_ID;
    gTaxiRequestActive[playerid] = false;
    return 1;
}
stock VX_TaxiDisconnect(playerid)
{
    new passenger = gTaxiOrderTarget[playerid];
    if (passenger >= 0 && passenger < MAX_PLAYERS)
    {
        if (IsPlayerConnected(passenger))
        {
            gTaxiOrderDriver[passenger] = INVALID_PLAYER_ID;
            gTaxiRequestActive[passenger] = false;
            SendClientMessage(passenger, COLOR_YELLOW, "[�����] �������� ����������. ����� �������.");
        }
    }
    gTaxiOrderTarget[playerid] = INVALID_PLAYER_ID;
    gTaxiAtPickup[playerid] = false;
    new driver = gTaxiOrderDriver[playerid];
    if (driver >= 0 && driver < MAX_PLAYERS && IsPlayerConnected(driver) && gTaxiOrderTarget[driver] == playerid)
    {
        SendClientMessage(driver, COLOR_YELLOW, "[�����] �������� ����������. ����� �������.");
        VX_TaxiClearDriver(driver, "", true);
    }
    gTaxiOrderDriver[playerid] = INVALID_PLAYER_ID;
    gTaxiRequestActive[playerid] = false;
    return 1;
}

stock ShowGPS(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_GPS, DIALOG_STYLE_LIST, "VEXORIUM RP | GPS",
        "[1] ������������ �����\n[2] ����������� � ������\n[3] ������ ��� ��������\n[4] �� ������\n[5] ����������� �����������\n[6] ��������� � ���\n[7] �������� � ������\n[8] ������������\n[9] �������� � ��������", "�������", "�������");
    return 1;
}
stock StartWorkRoute(playerid)
{
    if (!((gJob[playerid] >= 1 && gJob[playerid] <= 4) || gJob[playerid] == 7))
        return SendClientMessage(playerid, COLOR_YELLOW, "[VEXORIUM] ��� ������ �� ���������� ������� /work. �������� �����, �������������, �������, ����� ��� �������� ������."), 0;
    if (gWorkStage[playerid] > 0)
        return SendClientMessage(playerid, COLOR_YELLOW, "[VEXORIUM] �� ��� �� �����. ����������� /stopwork ��� ������."), 0;
    if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0)
        return SendClientMessage(playerid, COLOR_YELLOW, "������� ����� ����� � ������������� �� �����."), 0;
    new Float:employerX, Float:employerY, Float:employerZ;
    switch (gJob[playerid])
    {
        case 1: { employerX = 1479.0; employerY = -1739.0; employerZ = 13.5; }
        case 2: { employerX = 2195.0; employerY = -2254.0; employerZ = 13.5; }
        case 3: { employerX = 1810.0; employerY = -1900.0; employerZ = 13.4; }
        case 7: { employerX = VX_FIRE_STATION_X; employerY = VX_FIRE_STATION_Y; employerZ = VX_FIRE_STATION_Z; }
        default: { employerX = 820.0; employerY = 856.0; employerZ = 12.0; }
    }
    if (GetPlayerDistanceFromPoint(playerid, employerX, employerY, employerZ) > 25.0)
        return SendClientMessage(playerid, COLOR_YELLOW, "��������� � NPC-���������� ����� ������ � ������� /work."), 0;
    if (IsPlayerInAnyVehicle(playerid))
        return SendClientMessage(playerid, COLOR_YELLOW, "������� �� ���������� ����� ������� �����."), 0;
    if (gWorkVehicle[playerid] != INVALID_VEHICLE_ID && GetVehicleModel(gWorkVehicle[playerid]) != 0)
        DestroyVehicle(gWorkVehicle[playerid]);
    gWorkVehicle[playerid] = INVALID_VEHICLE_ID;
    if (gJob[playerid] == 1 || gJob[playerid] == 2 || gJob[playerid] == 3 || gJob[playerid] == 7)
    {
        new model = (gJob[playerid] == 1) ? 420 : ((gJob[playerid] == 2) ? 403 : ((gJob[playerid] == 3) ? 431 : 407));
        new Float:vx = employerX + 5.0, Float:vy = employerY + 2.0;
        if (gJob[playerid] == 7) { vx = VX_FIRE_STATION_X + 7.0; vy = VX_FIRE_STATION_Y - 2.0; }
        gWorkVehicle[playerid] = CreateVehicle(model, vx, vy, employerZ + 0.3, 90.0, 6, 6, -1);
        if (gWorkVehicle[playerid] == INVALID_VEHICLE_ID)
            return SendClientMessage(playerid, COLOR_RED, "�� ������� ������ ������� ���������. ���������� ����� � ���������."), 0;
        gVehicleFuel[gWorkVehicle[playerid]] = 100;
        PutPlayerInVehicle(playerid, gWorkVehicle[playerid], 0);
    }
    gWorkStage[playerid] = 1;
    gGpsActive[playerid] = false;
    if (gJob[playerid] == 1) SetPlayerCheckpoint(playerid, 1182.0, -1323.0, 13.6, 5.0);
    else if (gJob[playerid] == 2) SetPlayerCheckpoint(playerid, 2445.0, -2110.0, 13.5, 7.0);
    else if (gJob[playerid] == 3) SetPlayerCheckpoint(playerid, 1090.0, -1750.0, 13.4, 6.0);
    else if (gJob[playerid] == 7)
    {
        gFireCallIndex[playerid] = random(VX_FIRE_CALL_COUNT);
        SetPlayerCheckpoint(playerid, gVXFireCallPos[gFireCallIndex[playerid]][0],
            gVXFireCallPos[gFireCallIndex[playerid]][1], gVXFireCallPos[gFireCallIndex[playerid]][2], 7.0);
        SendClientMessage(playerid, COLOR_ORANGE, "[�������� ������] ������� �����. ���������� �� �������� ������ �� ����������� ������.");
    }
    else SetPlayerCheckpoint(playerid, 838.0, 870.0, 12.0, 7.0);
    if (gJob[playerid] != 7) SendClientMessage(playerid, COLOR_GREEN, "[VEXORIUM] ����� ��������! ������� ��������� �����, �������� �� ������� ��������.");
    if (gJob[playerid] == 1) SendClientMessage(playerid, COLOR_YELLOW, "[�����] �� ����� ���������� ������ �������� /taxiaccept ID, ���������� ������� � /taxidone. ������ � /taxicancel.");
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
        case FACTION_FBI: { x = 1642.0; y = -2248.0; z = 13.5; }
        default: { x = 1753.5; y = -1894.2; z = 13.6; }
    }
    return 1;
}

stock GetOrgGarage(faction, &Float:x, &Float:y, &Float:z)
{
    // ����� ���������� �������� �� ������� � ������ � ������.
    // ��� ���������� ������ ��������� ����� � ���� ������, � �� ������ ������.
    switch (faction)
    {
        case FACTION_CITYHALL: { x = 1462.4062; y = -1741.2448; z = 13.5468; }
        case FACTION_POLICE: { x = 1579.0; y = -1719.0; z = 13.5; }
        case FACTION_HOSPITAL: { x = 1192.1529; y = -1335.5710; z = 13.3984; }
        case FACTION_ARMY: { x = 404.5; y = 2488.8; z = 16.5; }
        case FACTION_NAVY: { x = -1420.0; y = 508.0; z = 18.0; }
        case FACTION_AIRFORCE: { x = 1924.5002; y = -2604.4042; z = 13.5468; }
        case FACTION_FBI: { x = 1668.0; y = -2258.0; z = 13.5; }
        default: { x = 1753.5; y = -1894.2; z = 13.6; }
    }
    return 1;
}

stock IsInOwnOrgInterior(playerid)
{
    if(gFaction[playerid]==FACTION_HOSPITAL) return GetPlayerInterior(playerid)==0 && GetPlayerVirtualWorld(playerid)==VX_HOSPITAL_WORLD;
    if (gFaction[playerid] == FACTION_POLICE)
        return GetPlayerInterior(playerid) == 6 && GetPlayerVirtualWorld(playerid) == 0;
    if (gFaction[playerid] == FACTION_FBI)
        return GetPlayerInterior(playerid) == 6 && GetPlayerVirtualWorld(playerid) == 100 + FACTION_FBI;
    return GetPlayerInterior(playerid) == 3 && GetPlayerVirtualWorld(playerid) == 100 + gFaction[playerid];
}

stock ShowOrgMenu(playerid)
{
    SendClientMessage(playerid, COLOR_YELLOW, "���������� ������������: /orgmembers, /orginvite ID (���� 8+), /orgrank ID ����, /orgkick ID � /orgfund.");
    if(gFaction[playerid]==FACTION_HOSPITAL) return VX_Show(playerid,VX_LOG,DIALOG_STYLE_MSGBOX,"���� | ���������","/mduty - ������ ��� ��������� �����\n/mcalls - ������ ������\n/maccept ID - ������� �����\n/heal ID - �������� ��������\n/hgarage - ����� ������ ������\n/ward - ����� � ������\n/lobby - ��������� � ����\n/exit - ����� �� ��������","��","�������");
    new factionName[32], title[64];
    GetFactionName(gFaction[playerid], factionName, sizeof factionName);
    format(title, sizeof title, "%s | ���� �����������", factionName);
    ShowPlayerDialog(playerid, DIALOG_ORG_MENU, DIALOG_STYLE_LIST, title,
        "������� ����\n������� �����������\n������� �������� / ����������\n����� � ������\n�������� ������", "�������", "�������");
    return 1;
}

stock EnterOrgInteriorForFaction(playerid, faction)
{
    if(faction==FACTION_HOSPITAL)
    {
        if(GetPlayerVirtualWorld(playerid)==0 && GetPlayerInterior(playerid)==0 && IsPlayerInRangeOfPoint(playerid,5.0,1176.7,-1322.5,13.5)) VX_EnterHospital(playerid);
        return 1;
    }
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
        SendClientMessage(playerid, COLOR_GREEN, "�� ����� � ������� LSPD. ����� ����� ����� ������ ������.");
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
        SendClientMessage(playerid, COLOR_GREEN, "FBI: �� ����� � ����. ����� ����� � ������.");
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
    SendClientMessage(playerid, COLOR_GREEN, "�� ����� � ������ �����������. ������� ������ ������, ����� ��������� �� �����.");
    // ����� ����� ����� ����� � ������, �� ���� ���������� �������� ������ ����������� ���� �����������.
    if (gFaction[playerid] == faction && gFactionRank[playerid] >= 1)
    {
        ShowOrgMenu(playerid);
        ShowFactionCommands(playerid);
    }
    return 1;
}

stock EnterOrgInterior(playerid)
{
    SendClientMessage(playerid, COLOR_YELLOW, "���� � ������ �������� ����� ������� � ������. ��������� � ������� ������ �����������.");
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
        x = 1574.0 + (float(tier) * 5.2); y = -1719.0; z = 13.5; a = 90.0;
    }
    if (faction == FACTION_HOSPITAL)
    {
        x = 1192.1529 + (float(tier) - 2.0) * 4.0; y = -1335.5710; z = 13.3984; a = 180.89;
    }
    if (faction == FACTION_NAVY)
    {
        switch (tier)
        {
            case 0: { x = -1410.0; y = 492.0; z = 7.2; a = 90.0; }
            case 1: { x = -1402.0; y = 492.0; z = 7.2; a = 90.0; }
            case 2: { x = -1394.0; y = 492.0; z = 7.2; a = 90.0; }
            case 3: { x = -1386.0; y = 492.0; z = 7.2; a = 90.0; }
            case 4: { x = -1378.0; y = 492.0; z = 7.2; a = 90.0; }
        }
    }
    if (faction == FACTION_AIRFORCE)
    {
        x = 1924.5002 + (float(tier) - 2.0) * 4.0; y = -2604.4042; z = 13.5468; a = 88.40;
    }

    // FBI: restore the original separate parking slots; tier 2 stays on the helicopter pad.
    if (faction == FACTION_FBI)
    {
        switch (tier)
        {
            case 0: { x = 1652.0; y = -2258.0; z = 13.5; a = 90.0; }
            case 1: { x = 1660.0; y = -2258.0; z = 13.5; a = 90.0; }
            case 2: { x = 1668.0; y = -2280.0; z = 13.5; a = 90.0; }
            case 3: { x = 1676.0; y = -2258.0; z = 13.5; a = 90.0; }
            case 4: { x = 1684.0; y = -2258.0; z = 13.5; a = 90.0; }
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

    // LSPD display fleet restored to the original coordinates from the uploaded mod.
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

    // FBI fleet is placed on the open Los Santos airport apron, not at the old coastal/desert coordinates.
    // This avoids spawning service vehicles in water or inside the terrain.
    if (faction == FACTION_FBI)
    {
        switch (tier)
        {
            case 0: { x = 1652.0; y = -2242.0; z = 13.5; a = 90.0; }
            case 1: { x = 1660.0; y = -2242.0; z = 13.5; a = 90.0; }
            case 2: { x = 1668.0; y = -2242.0; z = 13.5; a = 90.0; }
            case 3: { x = 1676.0; y = -2242.0; z = 13.5; a = 90.0; }
            case 4: { x = 1684.0; y = -2242.0; z = 13.5; a = 90.0; }
        }
    }

    // Navy: use the paved Easter Basin dock apron for ground vehicles; no vehicle is placed in open water.
    if (faction == FACTION_NAVY)
    {
        switch (tier)
        {
            case 0: { x = -1410.0; y = 492.0; z = 7.2; a = 90.0; }
            case 1: { x = -1402.0; y = 492.0; z = 7.2; a = 90.0; }
            case 2: { x = -1394.0; y = 492.0; z = 7.2; a = 90.0; }
            case 3: { x = -1386.0; y = 492.0; z = 7.2; a = 90.0; }
            case 4: { x = -1378.0; y = 492.0; z = 7.2; a = 90.0; }
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
    // FBI display vehicles use the original, separately spaced parking slots.
    if (faction == FACTION_FBI)
    {
        switch (tier)
        {
            case 0: { x = 1652.0; y = -2258.0; z = 13.5; a = 90.0; }
            case 1: { x = 1660.0; y = -2258.0; z = 13.5; a = 90.0; }
            case 2: { x = 1668.0; y = -2280.0; z = 13.5; a = 90.0; }
            case 3: { x = 1676.0; y = -2258.0; z = 13.5; a = 90.0; }
            case 4: { x = 1684.0; y = -2258.0; z = 13.5; a = 90.0; }
        }
    }
    return 1;
}

// The exhibition fleet is scenery / showroom stock and cannot be driven.
stock VX_IsDisplayFleetVehicle(vehicleid)
{
    if(vehicleid <= 0 || vehicleid >= MAX_VEHICLES || !gVXFleetAnchored[vehicleid]) return 0;
    if(!GetVehicleModel(vehicleid)) return 0;
    new faction=gVehicleFaction[vehicleid],tier=gVehicleTier[vehicleid];
    return faction>=1 && faction<=7 && tier>=0 && tier<FLEET_TIERS
        && gFleetVehicle[faction][tier]==vehicleid
        && gFactionVehicleOwner[vehicleid]==INVALID_PLAYER_ID;
}

stock VX_ResetDisplayFleet(vehicleid)
{
    if(!VX_IsDisplayFleetVehicle(vehicleid)) return 0;
    SetVehicleVelocity(vehicleid,0.0,0.0,0.0);
    SetVehiclePos(vehicleid,gVXFleetAnchorX[vehicleid],gVXFleetAnchorY[vehicleid],gVXFleetAnchorZ[vehicleid]);
    SetVehicleZAngle(vehicleid,gVXFleetAnchorA[vehicleid]);
    RepairVehicle(vehicleid);
    SetVehicleHealth(vehicleid,100000.0);
    SetVehicleParamsEx(vehicleid,0,0,0,1,0,0,0);
    return 1;
}

public VX_SecureDisplayFleet()
{
    for(new faction=1;faction<=7;faction++)
    {
        for(new tier=0;tier<FLEET_TIERS;tier++)
        {
            new vehicleid=gFleetVehicle[faction][tier];
            if(!VX_IsDisplayFleetVehicle(vehicleid)) continue;
            // Never force-stop a vehicle during traffic nearby; this can cause
            // abrupt impacts and make an issued car seem to brake to zero.
            new bool:trafficNearby=false;
            for(new p=0;p<MAX_PLAYERS;p++)
            {
                if(!IsPlayerConnected(p) || GetPlayerVirtualWorld(p)!=0
                    || GetPlayerInterior(p)!=0 || GetPlayerState(p)!=PLAYER_STATE_DRIVER) continue;
                if(GetPlayerDistanceFromPoint(p,gVXFleetAnchorX[vehicleid],
                    gVXFleetAnchorY[vehicleid],gVXFleetAnchorZ[vehicleid])<35.0)
                { trafficNearby=true; break; }
            }
            if(trafficNearby) continue;
            new Float:x,Float:y,Float:z,Float:a;
            GetVehiclePos(vehicleid,x,y,z);
            GetVehicleZAngle(vehicleid,a);
            new Float:dx=x-gVXFleetAnchorX[vehicleid];
            new Float:dy=y-gVXFleetAnchorY[vehicleid];
            new Float:dz=z-gVXFleetAnchorZ[vehicleid];
            if(dx*dx+dy*dy+dz*dz > 0.16 || floatabs(a-gVXFleetAnchorA[vehicleid]) > 4.0)
            {
                SetVehiclePos(vehicleid,gVXFleetAnchorX[vehicleid],gVXFleetAnchorY[vehicleid],gVXFleetAnchorZ[vehicleid]);
                SetVehicleZAngle(vehicleid,gVXFleetAnchorA[vehicleid]);
            }
            RepairVehicle(vehicleid);
            SetVehicleHealth(vehicleid,100000.0);
            SetVehicleParamsEx(vehicleid,0,0,0,1,0,0,0);
        }
    }
    return 1;
}

forward VX_StartIssuedCar(playerid,vehicleid);
public VX_StartIssuedCar(playerid,vehicleid)
{
    if(playerid<0 || playerid>=MAX_PLAYERS || !IsPlayerConnected(playerid)) return 1;
    if(vehicleid<=0 || vehicleid>=MAX_VEHICLES || !GetVehicleModel(vehicleid)) return 1;
    if(gFactionVehicle[playerid]!=vehicleid || gFactionVehicleOwner[vehicleid]!=playerid
        || VX_IsDisplayFleetVehicle(vehicleid)) return 1;
    if(GetPlayerState(playerid)!=PLAYER_STATE_DRIVER || GetPlayerVehicleID(playerid)!=vehicleid) return 1;
    new engine,lights,alarm,doors,bonnet,boot,objective;
    GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
    SetVehicleParamsEx(vehicleid,VEHICLE_PARAMS_ON,lights,alarm,doors,bonnet,boot,objective);
    // Explicitly release any previous garage/interior control lock.
    TogglePlayerControllable(playerid,true);
    gVXFleetAnchored[vehicleid]=false;
    SetVehicleParamsForPlayer(vehicleid,playerid,0,0);
    UpdateVexHud(playerid);
    SendClientMessage(playerid,COLOR_GREEN,"[�����] ��������� �������. ��������� ������ �������� ��� ��������.");
    return 1;
}

stock VX_GarageClearance(model)
{
    if(model==553 || model==520 || model==432) return 17;
    if(model==417 || model==487 || model==497) return 13;
    if(model==430 || model==446 || model==433 || model==427 || model==528) return 9;
    return 9;
}

stock VX_GetGarageSpawnZ(model, Float:referenceZ, &Float:spawnZ)
{
    // SA-MP 0.3.7 has no GetGroundZFor3DCoord native. Use the configured spawn height
    // and keep boats on the water surface; unsafe points are rejected by clearance checks.
    if (model == 430 || model == 446)
    {
        spawnZ = 0.5;
        return 1;
    }
    spawnZ = referenceZ + 0.35;
    return 1;
}

stock VX_IsGarageSlotClear(Float:x,Float:y,Float:z,Float:radius)
{
    new Float:radiusSq=radius*radius;
    for(new v=1;v<MAX_VEHICLES;v++)
    {
        if(!GetVehicleModel(v) || GetVehicleVirtualWorld(v)!=0) continue;
        new Float:vx,Float:vy,Float:vz;
        GetVehiclePos(v,vx,vy,vz);
        new Float:dx=vx-x,Float:dy=vy-y,Float:dz=vz-z;
        new Float:otherRadius=float(VX_GarageClearance(GetVehicleModel(v)));
        new Float:separation=(radius+otherRadius)*0.75;
        // Larger vehicles need a larger safe gap; ignore other floors.
        if(dx*dx+dy*dy < separation*separation && floatabs(dz)<7.0) return 0;
    }
    for(new p=0;p<MAX_PLAYERS;p++)
    {
        if(!IsPlayerConnected(p) || GetPlayerVirtualWorld(p)!=0 || GetPlayerInterior(p)!=0) continue;
        new Float:px,Float:py,Float:pz;
        GetPlayerPos(p,px,py,pz);
        new Float:dx=px-x,Float:dy=py-y;
        if(dx*dx+dy*dy < radiusSq && floatabs(pz-z)<5.0) return 0;
    }
    return 1;
}

stock VX_FindFreeGarageSpawn(faction,tier,model,&Float:x,&Float:y,&Float:z,&Float:a)
{
    GetFactionVehicleSpawn(faction,tier,x,y,z,a);
    new Float:radius=float(VX_GarageClearance(model));
    new Float:baseX=x,Float:baseY=y,Float:baseZ=z,Float:surfaceZ;
    if(VX_GetGarageSpawnZ(model,baseZ,surfaceZ))
    {
        z=surfaceZ;
        if(VX_IsGarageSlotClear(x,y,z,radius+3.0)) return 1;
    }
    // Candidate slots on a broad parking grid. Never stack two service vehicles or choose a point
    // whose ground height disagrees with the expected exterior parking surface.
    // If no safe point exists, refuse the request instead of spawning in a wall/underground.
    for(new ring=1;ring<=4;ring++)
    {
        new Float:step=radius+3.5;
        for(new ox=-ring;ox<=ring;ox++)
        {
            for(new oy=-ring;oy<=ring;oy++)
            {
                if(ox!=-ring && ox!=ring && oy!=-ring && oy!=ring) continue;
                new Float:cx=baseX+float(ox)*step;
                new Float:cy=baseY+float(oy)*step;
                // Limit relocation to the garage's immediate area (52 metres).
                new Float:ddx=cx-baseX,Float:ddy=cy-baseY;
                if(ddx*ddx+ddy*ddy>2704.0) continue;
                new Float:candidateZ;
                if(!VX_GetGarageSpawnZ(model,baseZ,candidateZ)) continue;
                if(!VX_IsGarageSlotClear(cx,cy,candidateZ,radius+3.0)) continue;
                x=cx;y=cy;z=candidateZ;
                return 1;
            }
        }
    }
    return 0;
}

stock VX_GarageRouteClear(playerid)
{
    gVXGarageRoute[playerid]=false;
    RemovePlayerMapIcon(playerid,VX_GARAGE_MAP_ICON);
    return 1;
}

stock VX_GarageRoute(playerid)
{
    new Float:x,Float:y,Float:z;
    GetOrgGarage(gFaction[playerid],x,y,z);
    if(gFaction[playerid]==FACTION_POLICE) { x=1579.0;y=-1719.0;z=13.5; }
    SetPlayerMapIcon(playerid,VX_GARAGE_MAP_ICON,x,y,z,0,0x33CC66FF,MAPICON_GLOBAL);
    gVXGarageRoute[playerid]=true;
    SendClientMessage(playerid,COLOR_GREEN,"[�����] ����� ����������� ������� �� �����. ��������� � ����� � ��������� /garage.");
    if(GetPlayerInterior(playerid)!=0 || GetPlayerVirtualWorld(playerid)!=0)
        SendClientMessage(playerid,COLOR_YELLOW,"[�����] ������� ������� �� ������ ����������� ����� /orggarage.");
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
                gVXFleetAnchored[vid] = true;
                gVXFleetAnchorX[vid]=x;gVXFleetAnchorY[vid]=y;
                gVXFleetAnchorZ[vid]=z;gVXFleetAnchorA[vid]=a;
                gVehicleReturnTimer[vid] = 0;
                gVehicleFuel[vid] = 100;
                gFuelLastX[vid] = 0.0; gFuelLastY[vid] = 0.0; gFuelLastZ[vid] = 0.0;
                SetVehicleVirtualWorld(vid, 0);
                // Every display vehicle gets its own /garage hint, including helicopters and other special vehicles.
                new hintText[128];
                format(hintText, sizeof(hintText), "{33CC66}��������\n{FFFFFF}��������� � ��������� /garage");
                Create3DTextLabel(hintText, COLOR_WHITE, x, y, z + 1.15, 18.0, 0, 1);
                // Locked parking-slot vehicle; employees must use /garage to get their own copy.
                new eng, lit, alm, doors, bonnet, boot, obj;
                GetVehicleParamsEx(vid, eng, lit, alm, doors, bonnet, boot, obj);
                SetVehicleParamsEx(vid, 0, 0, 0, 1, bonnet, boot, obj);
                SetVehicleHealth(vid,100000.0);
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
    if(VX_IsDisplayFleetVehicle(vehicleid)) return 0;
    if (gVehicleReturnTimer[vehicleid]) KillTimer(gVehicleReturnTimer[vehicleid]);
    gVehicleReturnTimer[vehicleid] = SetTimerEx("RespawnFactionVehicle", FLEET_RETURN_MS, false, "i", vehicleid);
    return 1;
}

public RespawnFactionVehicle(vehicleid)
{
    if (vehicleid < 1 || vehicleid >= MAX_VEHICLES || gVehicleFaction[vehicleid] < 1) return 1;
    gVehicleReturnTimer[vehicleid] = 0;
    if(VX_IsDisplayFleetVehicle(vehicleid)) return VX_ResetDisplayFleet(vehicleid);
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
    // ������� ������ GTA:SA, ���������� ������� ������.
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
    ShowPlayerDialog(playerid, DIALOG_GANG_WEAPONS, DIALOG_STYLE_LIST, "��������� ����� �����", "�������� 9�� � �����/��������\n�������� Desert Eagle � �����/��������\n�������� � �����/��������\nMP5 � �����/��������\nAK-47 � �����/��������\nM4 � �����/��������", "�������", "�����");
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
    new names[4][24] = {"���� �����", "������", "��� ������ �����", "������� �������"};
    for (new i = 0; i < 4; i++)
    {
        CreatePickup(1275, 23, x[i], y[i], z[i], 0);
        new label[160];
        format(label, sizeof label, "{FFD700}%s | ����\n{FFFFFF}�������� � �����: /gang\n����� � ������ �������� ����� ������", names[i]);
        gGangStashPickup[i + 1] = CreatePickup(1275, 23, x[i] + 1.5, y[i] + 1.5, z[i], 0);
        Create3DTextLabel("{00FF99}��������� ����� �����\n{FFFFFF}���������: ������, ������, ����������", COLOR_WHITE, x[i] + 1.5, y[i] + 1.5, z[i] + 1.0, 18.0, 0, 1);
        Create3DTextLabel("{33CCFF}����� �����\n{FFFFFF}����� ������, ���������� � ������", COLOR_WHITE, x[i] + 1.5, y[i] + 1.5, z[i] + 1.6, 18.0, 0, 1);
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

        // SA-MP 0.3.7 supports map icon IDs 0..99. Reuse a local pool for nearby stores.
        new marketIconCount = 0;
        if (GetPlayerInterior(viewer) == 0 && GetPlayerVirtualWorld(viewer) == 0)
        {
            for (new m = 0; m < VX_MARKET_COUNT && marketIconCount < VX_MARKET_ICON_SLOTS; m++)
            {
                if (IsPlayerInRangeOfPoint(viewer, 180.0, gVXMarketPos[m][0], gVXMarketPos[m][1], gVXMarketPos[m][2]))
                {
                    SetPlayerMapIcon(viewer, 70 + marketIconCount, gVXMarketPos[m][0], gVXMarketPos[m][1], gVXMarketPos[m][2], 50, 0, MAPICON_LOCAL);
                    marketIconCount++;
                }
            }
        }
        for (new mi = marketIconCount; mi < VX_MARKET_ICON_SLOTS; mi++) RemovePlayerMapIcon(viewer, 70 + mi);

        // Fuel icons occupy 90..99, never colliding with the store icon pool.
        new gasIconCount = 0;
        if (GetPlayerInterior(viewer) == 0 && GetPlayerVirtualWorld(viewer) == 0)
        {
            for (new g = 0; g < VX_GAS_COUNT && gasIconCount < VX_GAS_ICON_SLOTS; g++)
            {
                if (IsPlayerInRangeOfPoint(viewer, 180.0, gVXGasPos[g][0], gVXGasPos[g][1], gVXGasPos[g][2]))
                {
                    SetPlayerMapIcon(viewer, 90 + gasIconCount, gVXGasPos[g][0], gVXGasPos[g][1], gVXGasPos[g][2], 0, 0xFFD700FF, MAPICON_LOCAL);
                    gasIconCount++;
                }
            }
        }
        for (new gi = gasIconCount; gi < VX_GAS_ICON_SLOTS; gi++) RemovePlayerMapIcon(viewer, 90 + gi);
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
    print("[VEXORIUM HUD 3.0] Player card refresh, VEX DRIVE speed gauge and timed notifications loaded.");
    print("[VEXORIUM HUD RU 3.0] Native textdraw HUD; /hudfont; toast notifications; CP1251 source.");
    SetGameModeText("VEXORIUM RP | ������� RolePlay");
    // NPC-��������� �� �������� ������� �������� (SA-MP 0.3.7+).
    CreateActor(16, 820.0, 856.0, 12.0, 90.0);
    Create3DTextLabel("{FFD700}������������: �����\n{FFFFFF}/job � ������� ������, /work � ������ �����", COLOR_WHITE, 820.0, 856.0, 13.0, 15.0, 0, 1);
    CreateActor(155, 2195.0, -2254.0, 13.5, 180.0);
    Create3DTextLabel("{FFD700}��������� ��������������\n{FFFFFF}/job � ������� ������, /work � ������ �������", COLOR_WHITE, 2195.0, -2254.0, 14.5, 15.0, 0, 1);
    CreateActor(17, 1810.0, -1900.0, 13.4, 0.0);
    Create3DTextLabel("{FFD700}��������� ���������\n{FFFFFF}/job � ������� ������, /work � ������ �������", COLOR_WHITE, 1810.0, -1900.0, 14.4, 15.0, 0, 1);
    CreateActor(61, 1479.0, -1739.0, 13.5, 90.0);
    Create3DTextLabel("{FFD700}��������� �����\n{FFFFFF}/job � ������� ������, /work � ������ �������", COLOR_WHITE, 1479.0, -1739.0, 14.5, 15.0, 0, 1);
    CreateActor(277, 1771.5, -1706.0, 13.5, 90.0);
    Create3DTextLabel("{FF5555}�������� ����� VEXORIUM\n{FFFFFF}/job � ���������� ��������\n/work � ������ �����", COLOR_WHITE, VX_FIRE_STATION_X, VX_FIRE_STATION_Y, VX_FIRE_STATION_Z + 1.3, 22.0, 0, 0);
    ShowPlayerMarkers(0); // �� ���������� ����� ������� �� ���������; ����� ������������� ���������
    ShowNameTags(1);
    UsePlayerPedAnims();
    DisableInteriorEnterExits(); // ��������� ����������� ������� ����� GTA:SA; ����� VEXORIUM ��������� ��������.
    Create3DTextLabel("{33CC66}LSPD | ����������� �������\n{FFFFFF}/enterpd � �����", COLOR_WHITE, 1540.8, -1675.5, 14.3, 25.0, 0, 1);
    Create3DTextLabel("{FFD700}�����\n{FFFFFF}������� ����� ������ | /orggarage", COLOR_WHITE, 1477.0, -1771.9234, 19.5, 18.0, 0, 1);
    CreateActor(17, -2026.8, -96.5, 35.2, 180.0);
    Create3DTextLabel("{3399FF}VEXORIUM | ���������\n{FFFFFF}��������� � ����������� � ������� Y", COLOR_WHITE, -2026.8, -96.5, 36.2, 18.0, 0, 1);
    Create3DTextLabel("{33CC66}���� | ������� ����\n{FFFFFF}������� ����� ������ � �����",COLOR_WHITE,1176.7,-1322.5,14.6,17.0,0,1);
    CreateActor(274, 1178.2, -1321.1, 13.5, 180.0);
    // Hospital heart market: pickup model 1240, full health for $500.
    gHospitalMarketPickup = CreatePickup(1240, 1, 1180.2, -1322.5, 13.5, 0);
    Create3DTextLabel("{FF4444}<3 ������ �������� <3\n{FFFFFF}������ �������������� ��������\n{33CC66}����: $500\n{FFD700}��������� � ������", COLOR_WHITE, 1180.2, -1322.5, 14.3, 12.0, 0, 1);
    Create3DTextLabel("{33CC66}���� �����\n{FFFFFF}/enterorg � �����", COLOR_WHITE, 404.5, 2488.8, 17.5, 22.0, 0, 1);
    Create3DTextLabel("{33CC66}���� ���\n{FFFFFF}/enterorg � �����", COLOR_WHITE, -1380.0, 508.0, 19.0, 22.0, 0, 1);
    Create3DTextLabel("{33CC66}���� ���\n{FFFFFF}/enterorg � �����", COLOR_WHITE, 1940.0, -2620.0, 14.8, 22.0, 0, 1);
    // ����������� ������� �����/������ VEXORIUM ������ ����������� ������ GTA:SA.
    for (new f = 1; f <= 7; f++) { gOrgEnterPickup[f] = INVALID_PICKUP; gOrgExitPickup[f] = INVALID_PICKUP; gLockerPickup[f] = INVALID_PICKUP; }
    gOrgEnterPickup[FACTION_CITYHALL] = CreatePickup(1239, 1, 1477.0, -1771.9234, 18.7957, 0);
    gLicenseMarketPickup = CreatePickup(1239, 1, 362.4587, 174.0056, 1008.3828, 101);
    // Interior-only 3D label removed: use the exterior entrance marker instead.
    gPassportPickup = CreatePickup(1274, 1, 358.8, 174.0056, 1008.3828, 101);
    // Interior-only 3D label removed: use the exterior entrance marker instead.
    // Hospital entrance is created once in VX_InitHospitalEntrances().
    gOrgEnterPickup[FACTION_ARMY] = CreatePickup(1239, 1, 404.5, 2488.8, 17.5, 0);
    gOrgEnterPickup[FACTION_NAVY] = CreatePickup(1239, 1, -1380.0, 508.0, 19.0, 0);
    gOrgEnterPickup[FACTION_AIRFORCE] = CreatePickup(1239, 1, 1940.0, -2620.0, 14.8, 0);
    // One FBI street entrance marker. Positive X is the actual FBI building location;
    // negative X would place the marker in a different part of the map.
    gOrgEnterPickup[FACTION_FBI] = CreatePickup(1239, 1, 1642.0, -2248.0, 13.5, 0);
    gFBIBuildingEnterPickup = gOrgEnterPickup[FACTION_FBI];
    Create3DTextLabel("{3399FF}FBI | ����\n{FFFFFF}��������� 2 ������� � �����", COLOR_WHITE, 1642.0, -2248.0, 14.6, 25.0, 0, 1);
    gPoliceExitPickup = CreatePickup(1239, 1, 246.3213, 62.5062, 1003.6406, 0);
    // Interior-only 3D label removed: use the exterior entrance marker instead.
    for (new f = 1; f <= 7; f++)
    {
        if (f == FACTION_POLICE) continue;
        if (f == FACTION_CITYHALL) gOrgExitPickup[f] = CreatePickup(1239, 1, 388.8, 173.7, 1008.4, 100 + f);
        else if (f == FACTION_FBI)
        {
            gOrgExitPickup[f] = CreatePickup(1239, 1, 246.8183, 62.3222, 1003.6406, 100 + f);
            Create3DTextLabel("{3399FF}FBI | EXIT TO STREET", COLOR_WHITE, 246.8183, 62.3222, 1004.5, 12.0, 100 + f, 1);
        }
        else gOrgExitPickup[f] = CreatePickup(1239, 1, 2496.0, -1688.0, 1014.7, 100 + f);
    }
    // Interior-only 3D label removed: use the exterior entrance marker instead.
    Create3DTextLabel("{FFD700}������ �������� ��� ��������\n{FFFFFF}������ �� Faggio � �������� ������ (250 ���.)", COLOR_WHITE, 1764.0, -1898.0, 14.0, 20.0, 0, 1);
    // ����� �� ��������� LSPD � ��������� � �������� ����� �������.
    gPoliceEntrancePickup = CreatePickup(1239, 1, 1553.4399, -1675.5238, 16.1953, 0);
    Create3DTextLabel("{39D98A}VEXORIUM | ���� � LSPD\n{FFFFFF}��������� � �������", COLOR_WHITE, 1553.4399, -1675.5238, 16.95, 8.0, 0, 0);
    // One entrance marker inside LSPD: step on it to enter the garage.
    gPoliceGarageDoorPickup = CreatePickup(1239, 1, 246.7147, 87.2885, 1003.6406, 0);
    gPoliceHallGaragePickup = INVALID_PICKUP;
    // Interior-only 3D label removed: use the exterior entrance marker instead.
    gPoliceGarageReturnPickup = CreatePickup(1239, 1, 1568.4843, -1690.4116, 5.8906, 0);
    // Interior-only 3D label removed: use the exterior entrance marker instead.
    Create3DTextLabel("{33CC66}����� � ������� LSPD\n{FFFFFF}��������� � �������", COLOR_WHITE, 1568.4843, -1690.4116, 6.8, 7.0, 0, 0);
    // ������� ����������: ������� ���������� �������� LSPD, ��������� ������� � ���� ����������� ���.
    gLockerPickup[FACTION_POLICE] = CreatePickup(1275, 1, 255.3, 77.4, 1003.6, 0);
    Create3DTextLabel("{33CC66}LSPD | ����������\n{FFFFFF}������� ����� / ����������� ������", COLOR_WHITE, 255.3, 77.4, 1004.5, 8.0, 0, 1);
    gPoliceStashPickup = CreatePickup(1275, 1, 258.52, 76.8268, 1003.6406, 0);
    // FBI storage marker: Interior 6, virtual world 107.
    gFBIStashPickup = CreatePickup(1275, 1, 258.5231, 76.3146, 1003.6406, 107);
    Create3DTextLabel("{3399FF}FBI | ��������� �����\n{FFFFFF}������ � ����������", COLOR_WHITE, 258.5231, 76.3146, 1004.5, 8.0, 107, 1);
    Create3DTextLabel("{33CC66}LSPD | �����\n{FFFFFF}��������� ���������� ����������", COLOR_WHITE, 258.52, 76.8268, 1004.5, 8.0, 0, 1);
    // Interior-only 3D label removed: use the exterior entrance marker instead.
    gLockerPickup[FACTION_CITYHALL] = CreatePickup(1275, 1, 391.0, 173.7, 1008.4, 100 + FACTION_CITYHALL);
    gLockerPickup[FACTION_HOSPITAL] = CreatePickup(1275, 1, 2504.0, -1692.0, 1014.7, 100 + FACTION_HOSPITAL);
    gLockerPickup[FACTION_ARMY] = CreatePickup(1275, 1, 2504.0, -1692.0, 1014.7, 100 + FACTION_ARMY);
    gLockerPickup[FACTION_NAVY] = CreatePickup(1275, 1, 2504.0, -1692.0, 1014.7, 100 + FACTION_NAVY);
    gLockerPickup[FACTION_AIRFORCE] = CreatePickup(1275, 1, 2504.0, -1692.0, 1014.7, 100 + FACTION_AIRFORCE);
    gLockerPickup[FACTION_FBI] = CreatePickup(1275, 1, 255.3, 77.4, 1003.6410, 100 + FACTION_FBI);
    Create3DTextLabel("{3399FF}FBI | ����������\n{FFFFFF}����� �� �����", COLOR_WHITE, 255.3, 77.4, 1004.5, 10.0, 100 + FACTION_FBI, 1);
    // Interior-only 3D label removed: use the exterior entrance marker instead.
    // Interior-only 3D label removed: use the exterior entrance marker instead.
    // ��������� � ��� VEXORIUM RP: ���� ������� ������ ����������� �������� ����� GTA.
    gCarDealerPickup = CreatePickup(1239, 1, 2131.0, -1150.0, 24.1, 0);
    gAccessoryShopPickup = CreatePickup(1239, 1, 1457.0, -1137.0, 23.9, 0);
    Create3DTextLabel("{39D98A}VEXORIUM | ������� �����������\n{FFFFFF}�����, ���� � �����\n/shopacc - ������� �������", COLOR_WHITE, 1457.0, -1137.0, 25.0, 18.0, 0, 1);
    Create3DTextLabel("{39D98A}VEXORIUM | ���������\n{FFFFFF}/carshop � ������ ������", COLOR_WHITE, 2131.0, -1150.0, 25.1, 18.0, 0, 1);
    // Small world pickups; map icons are streamed only near the player.
    for (new m = 0; m < VX_MARKET_COUNT; m++)
    {
        gMarketPickups[m] = CreatePickup(1239, 1, gVXMarketPos[m][0], gVXMarketPos[m][1], gVXMarketPos[m][2], 0);
        Create3DTextLabel("{33CC66}VEXORIUM | �������\n{FFFFFF}/shop - �������", COLOR_WHITE,
            gVXMarketPos[m][0], gVXMarketPos[m][1], gVXMarketPos[m][2]+1.0, 12.0, 0, 1);
    }
    gMarketPickup = gMarketPickups[0];
    // Shared stock 24/7 interior (interior 4), isolated from the street by virtual world 5500.
    gMarketInteriorCounterPickup = CreatePickup(1239, 1, VX_MARKET_COUNTER_X, VX_MARKET_COUNTER_Y, VX_MARKET_COUNTER_Z, VX_MARKET_WORLD);
    gMarketInteriorExitPickup = CreatePickup(1239, 1, VX_MARKET_EXIT_X, VX_MARKET_EXIT_Y, VX_MARKET_EXIT_Z, VX_MARKET_WORLD);
    Create3DTextLabel("{33CC66}VEXORIUM | �����\n{FFFFFF}��������� � ������� ��� ����������� /shop", COLOR_WHITE,
        VX_MARKET_COUNTER_X, VX_MARKET_COUNTER_Y, VX_MARKET_COUNTER_Z + 0.8, 10.0, VX_MARKET_WORLD, 0);
    Create3DTextLabel("{FFD700}����� �� ��������\n{FFFFFF}��������� �� �����", COLOR_WHITE,
        VX_MARKET_EXIT_X, VX_MARKET_EXIT_Y, VX_MARKET_EXIT_Z + 0.8, 10.0, VX_MARKET_WORLD, 0);
    // �������� ������ � ��� �������, � ���������� ��������� � �����.
    for(new cs=0;cs<VX_CLOTHES_LOCATIONS;cs++)
    {
        gVXClothesPickup[cs]=CreatePickup(1275,1,gVXClothesPos[cs][0],gVXClothesPos[cs][1],gVXClothesPos[cs][2],0);
        Create3DTextLabel("{EBA6FF}VEXORIUM | ������\n{FFFFFF}/clothes - �������� � �������",COLOR_WHITE,
            gVXClothesPos[cs][0],gVXClothesPos[cs][1],gVXClothesPos[cs][2]+1.0,13.0,0,1);
    }

    for (new g = 0; g < VX_GAS_COUNT; g++)
    {
        gGasStationPickup[g] = CreatePickup(1650, 1, gVXGasPos[g][0], gVXGasPos[g][1], gVXGasPos[g][2], 0);
        Create3DTextLabel("{FFD700}VEXORIUM | ���\n{FFFFFF}/fuel - ��������", COLOR_WHITE,
            gVXGasPos[g][0], gVXGasPos[g][1], gVXGasPos[g][2]+1.0, 12.0, 0, 1);
    }
    SpawnBaseScooter();
    for (new f = 0; f < 8; f++) for (new t = 0; t < FLEET_TIERS; t++) gFleetVehicle[f][t] = INVALID_VEHICLE_ID;
    for (new v = 0; v < MAX_VEHICLES; v++) { gVehicleFaction[v] = 0; gVehicleTier[v] = 0; gVehicleReturnTimer[v] = 0; gVehicleFuel[v] = 100; gFuelLastX[v] = 0.0; gFuelLastY[v] = 0.0; gFuelLastZ[v] = 0.0; gPersonalVehicleOwner[v] = INVALID_PLAYER_ID; gCarjackVehicleOwner[v] = INVALID_PLAYER_ID; }
    SpawnFactionFleet();
    SetTimer("VX_SecureDisplayFleet",1500,true);
    SpawnGangBases();
    EnableStuntBonusForAll(0);
    gDatabase = db_open("vexorium.db");
    if (gDatabase == DB:0)
    {
        print("[VEXORIUM] ERROR: SQLite database could not be opened!");
        return 1;
    }
    VX_SQL("CREATE TABLE IF NOT EXISTS accounts (name TEXT PRIMARY KEY, password TEXT NOT NULL, money INTEGER DEFAULT 5000, level INTEGER DEFAULT 1, kills INTEGER DEFAULT 0, deaths INTEGER DEFAULT 0, skin INTEGER DEFAULT 23, x REAL DEFAULT 1685.0, y REAL DEFAULT -2333.0, z REAL DEFAULT 13.5, angle REAL DEFAULT 0.0)");
    EnsureColumn("accounts", "hud_font", "INTEGER DEFAULT 0");
    EnsureColumn("accounts", "hud_visible", "INTEGER DEFAULT 1");
    EnsureColumn("accounts", "hud_revision", "INTEGER DEFAULT 0");
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
    VX_SQL("CREATE TABLE IF NOT EXISTS bank_accounts (name TEXT PRIMARY KEY, balance INTEGER NOT NULL DEFAULT 0)");
    VX_SQL("CREATE TABLE IF NOT EXISTS vx_needs (name TEXT PRIMARY KEY, hunger INTEGER NOT NULL DEFAULT 100, thirst INTEGER NOT NULL DEFAULT 100, energy INTEGER NOT NULL DEFAULT 100)");
    VX_SQL("CREATE TABLE IF NOT EXISTS vx_contracts (id INTEGER PRIMARY KEY AUTOINCREMENT, payer TEXT NOT NULL, payee TEXT NOT NULL, amount INTEGER NOT NULL, purpose TEXT NOT NULL, status INTEGER NOT NULL DEFAULT 0, created INTEGER NOT NULL)");
    VX_SQL("CREATE INDEX IF NOT EXISTS vx_contracts_payee_status ON vx_contracts(payee,status,id)");
    VX_SQL("CREATE INDEX IF NOT EXISTS vx_contracts_payer_status ON vx_contracts(payer,status,id)");
    VX_SQL("CREATE TABLE IF NOT EXISTS org_finance_log (id INTEGER PRIMARY KEY AUTOINCREMENT, faction_id INTEGER NOT NULL, actor TEXT NOT NULL, target TEXT NOT NULL DEFAULT '', action TEXT NOT NULL, amount INTEGER NOT NULL, created INTEGER NOT NULL)");
    VX_SQL("CREATE TABLE IF NOT EXISTS police_records (name TEXT PRIMARY KEY, wanted INTEGER NOT NULL DEFAULT 0)");
    VX_SQL("CREATE TABLE IF NOT EXISTS houses (id INTEGER PRIMARY KEY, owner TEXT NOT NULL DEFAULT '', price INTEGER NOT NULL, x REAL NOT NULL, y REAL NOT NULL, z REAL NOT NULL)");
    VX_SQL("INSERT OR IGNORE INTO houses (id,owner,price,x,y,z) VALUES (1,'',250000,2495.0,-1692.0,14.8)");
    VX_SQL("INSERT OR IGNORE INTO houses (id,owner,price,x,y,z) VALUES (2,'',350000,2468.0,-1698.0,13.5)");
    VX_SQL("INSERT OR IGNORE INTO houses (id,owner,price,x,y,z) VALUES (3,'',500000,2421.0,-1220.0,25.5)");
    VX_SQL("INSERT OR IGNORE INTO houses (id,owner,price,x,y,z) VALUES (4,'',300000,2524.5000,-1679.1000,15.5000)");
    VX_SQL("INSERT OR IGNORE INTO houses (id,owner,price,x,y,z) VALUES (5,'',420000,2400.6000,-1715.4000,14.0000)");
    VX_SQL("INSERT OR IGNORE INTO houses (id,owner,price,x,y,z) VALUES (6,'',270000,2367.3000,-1674.2000,13.9000)");
    VX_SQL("INSERT OR IGNORE INTO houses (id,owner,price,x,y,z) VALUES (7,'',650000,2232.4000,-1159.8000,25.9000)");
    VX_SQL("INSERT OR IGNORE INTO houses (id,owner,price,x,y,z) VALUES (8,'',550000,2287.2000,-1105.4000,38.9000)");
    VX_SQL("INSERT OR IGNORE INTO houses (id,owner,price,x,y,z) VALUES (9,'',380000,2014.7000,-1732.0000,14.0000)");
    VX_SQL("INSERT OR IGNORE INTO houses (id,owner,price,x,y,z) VALUES (10,'',320000,2068.2000,-1731.8000,13.9000)");
    VX_SQL("INSERT OR IGNORE INTO houses (id,owner,price,x,y,z) VALUES (11,'',760000,1298.5000,-798.1000,84.1000)");
    VX_SQL("INSERT OR IGNORE INTO houses (id,owner,price,x,y,z) VALUES (12,'',900000,1352.2000,-625.8000,109.1000)");
    // Owned/unowned property markers and labels. The marker is also the owner-only entry point.
    for (new hi = 0; hi <= VX_HOUSE_COUNT; hi++)
    {
        gHousePickup[hi] = INVALID_PICKUP;
        gVXHouseLabelCreated[hi] = false;
    }
    new DBResult:rpHouseLabels = db_query(gDatabase, "SELECT id,owner,price,x,y,z FROM houses");
    if (rpHouseLabels)
    {
        for (new hi = 0; hi < db_num_rows(rpHouseLabels); hi++)
        {
            new hid = db_get_field_int(rpHouseLabels, 0);
            if (hid >= 1 && hid <= VX_HOUSE_COUNT)
            {
                new houseOwner[MAX_PLAYER_NAME + 1], ownerLabel[MAX_PLAYER_NAME + 1], houseLabel[192];
                houseOwner[0] = '\0';
                db_get_field(rpHouseLabels, 1, houseOwner, sizeof houseOwner);
                if (houseOwner[0]) format(ownerLabel, sizeof ownerLabel, "%s", houseOwner);
                else format(ownerLabel, sizeof ownerLabel, "����");
                format(houseLabel, sizeof houseLabel,
                    "{66CCFF}��� #%d\n{FFFFFF}��������: %s\n����: %d ���.\n{33CC66}/housebuy /houseenter",
                    hid, ownerLabel, db_get_field_int(rpHouseLabels, 2));
                new Float:hx = db_get_field_float(rpHouseLabels, 3);
                new Float:hy = db_get_field_float(rpHouseLabels, 4);
                new Float:hz = db_get_field_float(rpHouseLabels, 5);
                gHousePickup[hid] = CreatePickup(1273, 1, hx, hy, hz, 0);
                gVXHouseLabel[hid] = Create3DTextLabel(houseLabel, COLOR_WHITE, hx, hy, hz + 1.0, 18.0, 0, 1);
                gVXHouseLabelCreated[hid] = true;
            }
            db_next_row(rpHouseLabels);
        }
        db_free_result(rpHouseLabels);
    }
    VX_SQL("CREATE TABLE IF NOT EXISTS gang_stashes (gang_id INTEGER PRIMARY KEY, money INTEGER DEFAULT 0)");
    VX_SQL("CREATE TABLE IF NOT EXISTS gang_weapon_stash (gang_id INTEGER NOT NULL, weapon_id INTEGER NOT NULL, ammo INTEGER DEFAULT 0, PRIMARY KEY(gang_id,weapon_id))");
    VX_SQL("CREATE TABLE IF NOT EXISTS org_stashes (faction_id INTEGER PRIMARY KEY, money INTEGER DEFAULT 0, materials INTEGER DEFAULT 0, ammo INTEGER DEFAULT 0, armour INTEGER DEFAULT 0)");
    for (new faction = 1; faction <= 7; faction++) { new orgInit[160]; format(orgInit, sizeof orgInit, "INSERT OR IGNORE INTO org_stashes (faction_id,money,materials,ammo,armour) VALUES (%d,0,1000,5000,100)", faction); new DBResult:orgRes = db_query(gDatabase, orgInit); if (orgRes) db_free_result(orgRes); }
    VX_SQL("INSERT OR IGNORE INTO gang_stashes (gang_id,money) VALUES (1,0)");
    VX_SQL("INSERT OR IGNORE INTO gang_stashes (gang_id,money) VALUES (2,0)");
    VX_SQL("INSERT OR IGNORE INTO gang_stashes (gang_id,money) VALUES (3,0)");
    VX_SQL("INSERT OR IGNORE INTO gang_stashes (gang_id,money) VALUES (4,0)");
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
    SetTimer("VX_NeedsPulse", 300000, true);
    VX_Init();
    if(!RP_Init()) print("[VEXORIUM RP] CRITICAL: persistence initialization failed.");
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
        format(factionName, sizeof factionName, "������� LSPD");

    format(msg, sizeof msg, "�������� ������������� � ����������� - %s.", factionName);
    SendClientMessageToAll(COLOR_BLUE, msg);
    SendClientMessageToAll(COLOR_BLUE, "����� ������ ������������� ��� ����� ����� ��� ���� �������, 4 ���, �������� �� ���� � �� ������.");
    format(msg, sizeof msg, "������ �� �������������: /gps -> ����������� -> %s.", factionName);
    SendClientMessageToAll(COLOR_BLUE, msg);
    SendClientMessageToAll(COLOR_BLUE, "�� ��� ���!");
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
        new salary = 2200;
        switch (gJob[playerid]) { case 1: salary = 4000; case 2: salary = 5500; case 3: salary = 4600; case 4: salary = 6500; case 6: salary = 3300; case 7: salary = 7500; }
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
        format(msg, sizeof msg, "[PayDay] �������: %d ���. | ����: +%d (����� %d/%d).", salary, multiplier, gExperience[playerid], GetExperienceForLevel(gLevel[playerid] + 1));
        SendClientMessage(playerid, COLOR_GREEN, msg);
        new paydayToast[64];
        format(paydayToast, sizeof paydayToast, "+%d ���. | +%d XP", salary, multiplier);
        VX_Notify(playerid, "PAYDAY", paydayToast, VEX_HUD_ACCENT);
        if (gLevel[playerid] > oldLevel)
        {
            format(msg, sizeof msg, "[VEXORIUM] �����������! ��� ������� ������� �� %d!", gLevel[playerid]);
            SendClientMessage(playerid, COLOR_YELLOW, msg);
            VX_Notify(playerid, "����� �������", "����������� � ����������!", VEX_HUD_WARNING);
            RefreshVexHud(playerid);
        }
        SavePlayer(playerid);
    }
    return 1;
}

public OnGameModeExit()
{
    if (gVXTimer) KillTimer(gVXTimer);
    for(new p=0;p<MAX_PLAYERS;p++) if(gVXDeathTimer[p]) KillTimer(gVXDeathTimer[p]);
    for(new d=0;d<VX_MAX_DROPS;d++) VX_ClearDrop(d);
    for (new playerid = 0; playerid < MAX_PLAYERS; playerid++)
    {
        VX_CancelWardLoad(playerid);
        if (gHudTimer[playerid]) { KillTimer(gHudTimer[playerid]); gHudTimer[playerid] = 0; }
        DestroyVexHud(playerid);
    }

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
        SetPlayerColor(playerid, 0x101010FF); // FBI � ������ ��� � ���� ������ �� �����
    else if (gLogged[playerid] && gFaction[playerid] == FACTION_POLICE && gFactionRank[playerid] > 0)
        SetPlayerColor(playerid, 0x3399FFFF); // LSPD � �����
    else
        SetPlayerColor(playerid, 0xFFFFFFFF); // ����������� � ��������� ������� � �����
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
    if(gIsJailed[playerid]) { gPvpActive[playerid]=false; return RP_JailPosition(playerid); }
    if(gVXHospital[playerid]) { gPvpActive[playerid]=false; return VX_EnterHospital(playerid); }
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
    format(msg, sizeof msg, "[VEXORIUM | PvP] %s ������� �� ������ 5:%d! ����� ���������.", gName[winnerid], gPvpScore[loserid]);
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
            SendClientMessage(playerid, COLOR_YELLOW, "[PvP] ����� ������������. ��������� ������, ��� ������ 5 �����.");
        }
    }
    return 1;
}

public OnPlayerConnect(playerid)
{
    VX_Connect(playerid);
    RP_Reset(playerid);
    gFBIPendingEnter[playerid] = false;
    gLastTeleportTick[playerid] = 0;
    gMarketInside[playerid] = false;
    gMarketReturnPos[playerid][0] = 0.0;
    gMarketReturnPos[playerid][1] = 0.0;
    gMarketReturnPos[playerid][2] = 0.0;
    gMarketReturnPos[playerid][3] = 0.0;
    gFireCallIndex[playerid] = -1;
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
    gTaxiOrderTarget[playerid] = INVALID_PLAYER_ID;
    gTaxiOrderDriver[playerid] = INVALID_PLAYER_ID;
    gTaxiRequestActive[playerid] = false;
    gTaxiAtPickup[playerid] = false;
    gTaxiPickupPos[playerid][0] = 0.0; gTaxiPickupPos[playerid][1] = 0.0; gTaxiPickupPos[playerid][2] = 0.0;
    gCurrentHouse[playerid] = 0;
    gHousePending[playerid] = 0;
    gHouseCaptchaA[playerid] = 0;
    gHouseCaptchaB[playerid] = 0;
    gBankMoney[playerid] = 0;
    gMedkits[playerid] = 1; gFood[playerid] = 2; gWater[playerid] = 2;
    gHunger[playerid] = 100; gThirst[playerid] = 100; gEnergy[playerid] = 100; gLastRestTick[playerid] = 0;
    gRepairKits[playerid] = 0; gSimCards[playerid] = 0; gLockpicks[playerid] = 0;
    gCarjackPursuitNotified[playerid] = false;
    gPhoneSmsTarget[playerid] = INVALID_PLAYER_ID; gWantedLevel[playerid] = 0;
    gHandcuffed[playerid] = false; gCuffOfficer[playerid] = INVALID_PLAYER_ID; gTaserStunned[playerid] = false;
    gPursuitTarget[playerid] = INVALID_PLAYER_ID;
    gCarjackActive[playerid] = false; gCarjackUnlocked[playerid] = false; gCarjackVehicle[playerid] = INVALID_VEHICLE_ID; gCarjackDestination[playerid] = 0; gCarjackPending[playerid] = 0;
    gDrivingTestStage[playerid] = 0; gDrivingTestVehicle[playerid] = INVALID_VEHICLE_ID; gDrivingExamPassed[playerid] = 0;
    SetPlayerColor(playerid, 0xFFFFFFFF);
    HideVexDefaultHud(playerid);
    // Map blips are updated in RefreshNearbyMapVisibility instead of shown worldwide.
    gLastTaserTick[playerid] = 0;
    GetPlayerName(playerid, gName[playerid], MAX_PLAYER_NAME + 1);
    gOwnedCarModel[playerid] = 0;
    gAccessoryModel[playerid] = 0;
    gOwnedCarVehicle[playerid] = INVALID_VEHICLE_ID;
    // Reset state before starting the one HUD timer for this connection.
    gLogged[playerid] = false;
    gAdmin[playerid] = 0;
    if (gHudTimer[playerid]) KillTimer(gHudTimer[playerid]);
    gHudTimer[playerid] = 0;
    gVexHudToastBg[playerid] = PlayerText:INVALID_TEXT_DRAW;
    gVexHudToastAccent[playerid] = PlayerText:INVALID_TEXT_DRAW;
    gVexHudToastTitle[playerid] = PlayerText:INVALID_TEXT_DRAW;
    gVexHudToastBody[playerid] = PlayerText:INVALID_TEXT_DRAW;
    gVexHudToastTimer[playerid] = 0;
    gVexHudToastSerial[playerid] = 0;
    DestroyVexHud(playerid);
    gGang[playerid] = 0; // New accounts must not inherit the previous occupant's gang.
    gVexHudEnabled[playerid] = true;
    gVexHudFont[playerid] = VEX_HUD_DEFAULT_FONT;
    gVexHudBuildFailed[playerid] = false;
    // Do not show stale character data or HUD text over the login dialog.
    if (!IsPlayerNPC(playerid))
        gHudTimer[playerid] = SetTimerEx("RefreshVexHud", VEX_HUD_UPDATE_MS, true, "i", playerid);
    gJob[playerid] = 0;
    gVXAccountSkin[playerid] = 23;
    gVXClothesPreview[playerid]=-1;
    gVXClothesBefore[playerid]=23;
    gPoliceCivilianSkin[playerid]=false;
    gFaction[playerid] = 0;
    gFactionRank[playerid] = 0;
    gOrgInviteFrom[playerid] = INVALID_PLAYER_ID;
    gSpawnPreference[playerid] = 0;
    gRentalVehicle[playerid] = INVALID_VEHICLE_ID;
    gPendingScooterChoice[playerid] = false;
    gFactionVehicle[playerid] = INVALID_VEHICLE_ID;
    gVXGarageRoute[playerid]=false;
    RemovePlayerMapIcon(playerid,VX_GARAGE_MAP_ICON);
    gWorkStage[playerid] = 0;
    gWorkVehicle[playerid] = INVALID_VEHICLE_ID;
    gGpsActive[playerid] = false;
    VX_GarageRouteClear(playerid);
    gSpawnMenuShown[playerid] = false;
    gIsJailed[playerid] = false;
    gJailTimer[playerid] = 0;
    TogglePlayerSpectating(playerid, true);
    if (gDatabase == DB:0)
    {
        SendClientMessage(playerid, COLOR_RED, "[VEXORIUM] ������ ���� ������. ���������� �����.");
        Kick(playerid);
        return 1;
    }
    new query[512];
    format(query, sizeof query, "SELECT name FROM accounts WHERE name='%q'", gName[playerid]);
    new DBResult:connectResult = db_query(gDatabase, query);
    if (connectResult && db_num_rows(connectResult))
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "VEXORIUM | ����� ����������", "================================\n             V E X O R I U M\n          ����� �Ĩ� ����\n\n������� ������. ����� ���� ������.\n������ ����� �� ����� �����.\n\n����� ����� ��� ����� �� ������.", "�����", "�����");
    else
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "VEXORIUM | �������� ��������", "================================\n             V E X O R I U M\n       ���� ������� ����������\n\n����� ������� �� ������.\n�������� ������ �� 4 �� 64 ��������.\n������� ���: �� ����������� ��� ��������� �����.\n\n����� ������� ��� �����������.", "�������", "�����");
    if (connectResult) db_free_result(connectResult);
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    gHousePending[playerid] = 0;

    VX_TaxiDisconnect(playerid);
    gOrgInviteFrom[playerid] = INVALID_PLAYER_ID;
    RP_Disconnect(playerid);
    VX_Disconnect(playerid);
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
            SendClientMessage(opponent, COLOR_GREEN, "[PvP] �������� ����� � �������. �� �������� �����.");
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
    if (gLogged[playerid]) { SavePlayer(playerid); VX_NeedsSave(playerid); }
    gLogged[playerid] = false;
    gHandcuffed[playerid] = false; gCuffOfficer[playerid] = INVALID_PLAYER_ID; gTaserStunned[playerid] = false;
    gWantedLevel[playerid] = 0;
    gPursuitTarget[playerid] = INVALID_PLAYER_ID;
    gWorkStage[playerid] = 0;
    gGpsActive[playerid] = false;
    VX_GarageRouteClear(playerid);
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
    if (gLogged[playerid])
    {
        gVXClothesPreview[playerid]=-1;
        // SA-MP may return the CJ skin after death. Always apply the saved role.
        SetPlayerSkin(playerid, VX_RespawnSkin(playerid));
        ShowVexHud(playerid);
    }
    if (gLogged[playerid] && gAccessoryModel[playerid] > 0) SetPlayerAttachedObject(playerid, 0, gAccessoryModel[playerid], 2, 0.10, 0.02, 0.00, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
    if (!gLogged[playerid])
    {
        TogglePlayerSpectating(playerid, true);
        return 1;
    }
    if(gIsJailed[playerid]) return RP_JailPosition(playerid);
    if(VX_RestoreSpec(playerid)) return 1;
    if(!gPvpActive[playerid] && !gPvpRestorePending[playerid] && !gVXHospital[playerid])
    {
        // Do not clear weapons on respawn: officers can keep previously issued equipment.
        if(gFaction[playerid]==FACTION_POLICE && gFactionRank[playerid]>=1)
            GivePlayerWeapon(playerid,3,1);
        else if(gFaction[playerid]==FACTION_FBI && gFactionRank[playerid]>=1)
            GivePlayerWeapon(playerid,23,10);
    }
    if(gVXHospital[playerid] && !gIsJailed[playerid])
    {
        VX_FreeBed(playerid);TogglePlayerControllable(playerid,true);return VX_EnterHospital(playerid);
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

    // ���� ����� ��� �������, ��������� ��� ��� ������ � ����� ������.
    if (gSpawnPreference[playerid] == 1 || gSpawnPreference[playerid] == 2)
        ApplySavedSpawn(playerid);
    else
        ShowSpawnMenu(playerid);
    return 1;
}

stock IsPlayerInGreenZone(playerid)
{
    if(GetPlayerVirtualWorld(playerid)==VX_HOSPITAL_WORLD) return 1;
    // ���������� ��������� (�������, �����, �������� � ������ ���������) � ���������� ����.
    if (!IsPlayerConnected(playerid)) return 0;
    return (GetPlayerInterior(playerid) != 0);
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
    if (weaponid == 23 && VX_Officer(issuerid) && RP_Free(issuerid) && !IsPlayerInGreenZone(playerid) && (issuerid == INVALID_PLAYER_ID || !IsPlayerInGreenZone(issuerid)))
    {
        new Float:health;
        GetPlayerHealth(playerid, health);
        SetPlayerHealth(playerid, VX_FloatMin(100.0,health));
    }
    if (IsPlayerInGreenZone(playerid) || (issuerid != INVALID_PLAYER_ID && IsPlayerInGreenZone(issuerid)))
    {
        new Float:health;
        GetPlayerHealth(playerid, health);
        SetPlayerHealth(playerid, VX_FloatMin(100.0,health));
        if (issuerid != INVALID_PLAYER_ID)
            SendClientMessage(issuerid, COLOR_GREEN, "[GREEN ZONE] ������ ������ ������ �������� ����.");
        SendClientMessage(playerid, COLOR_GREEN, "[GREEN ZONE] �� ���������� � ���������� ����.");
        return 0;
    }
    RP_OnDamage(playerid,issuerid,amount,weaponid,bodypart);
    return 1;
}

public OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart)
{
    #pragma unused amount
    #pragma unused bodypart
    if (IsPlayerInGreenZone(playerid) || IsPlayerInGreenZone(damagedid)) return 1;
    // USP with silencer (weapon 23) acts as a non-lethal taser. 15-second cooldown per shooter.
    if (weaponid == 23 && (gFaction[playerid]==FACTION_FBI || gFaction[playerid]==FACTION_POLICE) && VX_Officer(playerid) && RP_Free(playerid) && IsPlayerConnected(damagedid) && !gHandcuffed[damagedid] && !gTaserStunned[damagedid])
    {
        new taserTick = GetTickCount();
        if (gLastTaserTick[playerid] != 0 && taserTick - gLastTaserTick[playerid] < 15000)
        {
            SendClientMessage(playerid, COLOR_YELLOW, "[������] �����������: ��������� 15 ������.");
            return 1;
        }
        gLastTaserTick[playerid] = taserTick;
        gTaserStunned[damagedid] = true;
        ClearAnimations(damagedid);
        ApplyAnimation(damagedid, "CRACK", "crckdeth2", 4.1, 1, 0, 0, 1, 10000, 1);
        SetPlayerDrunkLevel(damagedid, 50000);
        TogglePlayerControllable(damagedid, 0);
        SendClientMessage(damagedid, COLOR_RED, "�� ������ �� �������! �� ��������� �� 10 ������.");
        SendClientMessage(playerid, COLOR_GREEN, "�� ������ � ������ �������� USP.");
        gRPTaserUntil[damagedid]=gettime()+10;
    }
    return 1;
}

// Bullet hits also damage vehicle health (SA-MP 0.3.7 / 0.3z callback).
public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
    #pragma unused fX
    #pragma unused fY
    #pragma unused fZ

    // Hit type 2 is a vehicle. Ignore invalid hits and shooting from safe zones.
    if(hittype != 2 || hitid <= 0 || hitid >= MAX_VEHICLES) return 1;
    if(!IsPlayerConnected(playerid) || IsPlayerInGreenZone(playerid)) return 1;
    if(!GetVehicleModel(hitid) || VX_IsDisplayFleetVehicle(hitid)) return 1;
    if(GetVehicleVirtualWorld(hitid) != GetPlayerVirtualWorld(playerid)) return 1;

    new Float:health;
    GetVehicleHealth(hitid, health);
    // Showroom/display vehicles use 100000 health intentionally; never alter them.
    if(health <= 0.0 || health > 1000.0) return 1;

    new Float:damage = 8.0;
    switch(weaponid)
    {
        case 22: damage = 9.0;   // Colt 45
        case 23: damage = 7.0;   // Silenced pistol
        case 24: damage = 16.0;  // Desert Eagle
        case 25: damage = 20.0;  // Shotgun
        case 26: damage = 22.0;  // Sawed-off
        case 27: damage = 28.0;  // Combat shotgun
        case 28, 32: damage = 6.0; // Micro SMG / Tec-9
        case 29: damage = 8.0;   // MP5
        case 30: damage = 12.0;  // AK-47
        case 31: damage = 11.0;  // M4
        case 33: damage = 22.0;  // Rifle
        case 34: damage = 30.0;  // Sniper rifle
        default: damage = 8.0;
    }

    health -= damage;
    if(health < 0.0) health = 0.0;
    SetVehicleHealth(hitid, health);
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
    return VX_DeathSpawn(playerid,gVXSession[playerid]);
}

public OnPlayerDeath(playerid, killerid, reason)
{
    VX_TaxiCancelForPlayer(playerid, "[�����] ����� �������: ������� ��������.", false);
    RP_DropStretcher(playerid);
    gRPOpDoctor[playerid]=INVALID_PLAYER_ID; gRPOpUntil[playerid]=0;
    gRPTaserUntil[playerid]=0;
    if (gPvpActive[playerid])
    {
        new opponent = gPvpOpponent[playerid];
        if (opponent != INVALID_PLAYER_ID && IsPlayerConnected(opponent) && gPvpActive[opponent] && killerid == opponent)
        {
            gPvpScore[opponent]++;
            new scoreMsg[128];
            format(scoreMsg, sizeof scoreMsg, "[PvP] ����: %s %d : %d %s", gName[opponent], gPvpScore[opponent], gPvpScore[playerid], gName[playerid]);
            SendClientMessage(opponent, COLOR_GREEN, scoreMsg);
            SendClientMessage(playerid, COLOR_YELLOW, scoreMsg);
            if (gPvpScore[opponent] >= 5) { FinishPvp(opponent, playerid); return 1; }
        }
        SetTimerEx("PvpRespawn", 1000, false, "i", playerid);
        return 1;
    }
    VX_DeathStart(playerid);
    if (gLogged[playerid])
    {
        gDeaths[playerid]++;
        SavePlayer(playerid);
    }
    if (killerid != INVALID_PLAYER_ID && killerid != playerid && gLogged[killerid])
    {
        gKills[killerid]++;
        // No civilian kill reward in RP. PvP duel rules are handled above.
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
    if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0 || !IsPlayerInRangeOfPoint(playerid, 4.0, 1642.0, -2248.0, 13.5))
    {
        SendClientMessage(playerid, COLOR_YELLOW, "[FBI] ���� �������. ������ � ������� 2 �������.");
        return 1;
    }
    EnterOrgInteriorForFaction(playerid, FACTION_FBI);
    return 1;
}

stock VX_IsTeleportMarkerPickup(pickupid)
{
    if (pickupid == gPoliceEntrancePickup || pickupid == gPoliceExitPickup ||
        pickupid == gPoliceHallGaragePickup || pickupid == gPoliceGarageDoorPickup ||
        pickupid == gPoliceGarageReturnPickup || pickupid == gRPPrisonIn || pickupid == gRPPrisonOut ||
        pickupid == gVXLobbyWardPickup || pickupid == gVXWardLobbyPickup ||
        pickupid == gMarketInteriorExitPickup)
        return 1;
    for (new market = 0; market < VX_MARKET_COUNT; market++)
        if (pickupid == gMarketPickups[market]) return 1;
    for (new house = 1; house <= VX_HOUSE_COUNT; house++)
        if (gHousePickup[house] != INVALID_PICKUP && pickupid == gHousePickup[house]) return 1;
    for (new faction = 1; faction <= 7; faction++)
    {
        if (pickupid == gOrgEnterPickup[faction] || pickupid == gOrgExitPickup[faction]) return 1;
    }
    if (pickupid == gFBIBuildingEnterPickup) return 1;
    return 0;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
    if(!gLogged[playerid] || !gRPLoaded[playerid]) return 1;
    if(gIsJailed[playerid] || gHandcuffed[playerid] || gTaserStunned[playerid]
        || gRPStretcherBy[playerid]!=INVALID_PLAYER_ID) return 1;
    if (VX_IsTeleportMarkerPickup(pickupid))
    {
        new teleportTick = GetTickCount();
        if (gLastTeleportTick[playerid] != 0 && teleportTick - gLastTeleportTick[playerid] < PICKUP_TELEPORT_COOLDOWN)
        {
            SendClientMessage(playerid, COLOR_YELLOW, "[VEXORIUM] ��������� 4 ������� ����� ��������� ���������.");
            return 1;
        }
        gLastTeleportTick[playerid] = teleportTick;
    }
    if(RP_Pickup(playerid,pickupid)) return 1;
    if(VX_HospitalPickup(playerid,pickupid)) return 1;
    for (new hid = 1; hid <= VX_HOUSE_COUNT; hid++)
    {
        if (gHousePickup[hid] == INVALID_PICKUP || pickupid != gHousePickup[hid]) continue;
        if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0) return 1;
        return VX_HouseEnterID(playerid, hid);
    }
    for(new cs=0;cs<VX_CLOTHES_LOCATIONS;cs++)
        if(pickupid==gVXClothesPickup[cs])return VX_ClothesOpen(playerid);
    if(!gLogged[playerid]) return 1;
    if (gGang[playerid] >= 1 && gGang[playerid] <= 4 && pickupid == gGangStashPickup[gGang[playerid]])
    {
        new Float:bx, Float:by, Float:bz;
        GetGangBase(gGang[playerid], bx, by, bz);
        if (GetPlayerInterior(playerid) == 0 && GetPlayerVirtualWorld(playerid) == 0 && GetPlayerDistanceFromPoint(playerid, bx, by, bz) <= 12.0)
            ShowPlayerDialog(playerid, DIALOG_GANG_STASH, DIALOG_STYLE_LIST, "����� �����", "�������� ������\n����� ������\n������ ������\n������ � �������\n�������� ����������", "�������", "�������");
        else SendClientMessage(playerid, COLOR_RED, "����� �������� ������ �� ���� ����� �����.");
        return 1;
    }
    if (!gLogged[playerid]) return 1;
    // Ignore pickup callbacks for a short period after one interaction; prevents teleport loops.
    new tick = GetTickCount();
    if (pickupid != gLicenseMarketPickup && pickupid != gPassportPickup && pickupid != gHospitalMarketPickup &&
        pickupid != gMarketInteriorCounterPickup && gLastPickupTick[playerid] != 0 &&
        tick - gLastPickupTick[playerid] < PICKUP_TELEPORT_COOLDOWN) return 1;
    gLastPickupTick[playerid] = tick;
    if(gVXHospital[playerid]) return 1;
    if (pickupid == gHospitalMarketPickup)
    {
        if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0 || !IsPlayerInRangeOfPoint(playerid, 3.0, 1180.2, -1322.5, 13.5)) return 1;
        new Float:currentHealth;
        GetPlayerHealth(playerid, currentHealth);
        if (currentHealth >= 99.9)
            return SendClientMessage(playerid, COLOR_YELLOW, "[����] � ��� ��� ������ ��������."), 1;
        if (!TakeCash(playerid, 500))
            return SendClientMessage(playerid, COLOR_RED, "[����] ������� ����� $500. ������������ ��������."), 1;
        SetPlayerHealth(playerid, 100.0);
        SavePlayer(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "[����] �������-������ ������� �� $500. �������� �������������!");
        return 1;
    }
    if (pickupid == gLicenseMarketPickup)
    {
        // Do not reopen the license dialog while the player remains inside the marker.
        if (gLicenseMarketLocked[playerid]) return 1;
        gLicenseMarketLocked[playerid] = true;
        ShowPlayerDialog(playerid, DIALOG_LICENSE_MARKET, DIALOG_STYLE_LIST, "VEXORIUM RP | ����� ��������", "�������� �� ������ � 30 000 ���.\n�������� �� ����� � 20 000 ���.\n�������� �� ������ � 40 000 ���.\n������������ ����� � ����� ��������", "�������", "�������");
        return 1;
    }
    if (pickupid == gPassportPickup)
    {
        if (gHasPassport[playerid]) return SendClientMessage(playerid, COLOR_GREEN, "� ��� ��� ���� �������."), 1;
        ShowPlayerDialog(playerid, DIALOG_PASSPORT, DIALOG_STYLE_MSGBOX, "VEXORIUM RP | ���������� ��������", "��� ���������� �� ������ � ������� � ��������� ������� ���������� �������� �������.\n\n���������� ����������. �������� �������?", "��������", "������");
        return 1;
    }
    if (pickupid == gMarketInteriorExitPickup)
    {
        if (!gMarketInside[playerid] || GetPlayerInterior(playerid) != VX_MARKET_INTERIOR ||
            GetPlayerVirtualWorld(playerid) != VX_MARKET_WORLD ||
            !IsPlayerInRangeOfPoint(playerid, 5.0, VX_MARKET_EXIT_X, VX_MARKET_EXIT_Y, VX_MARKET_EXIT_Z)) return 1;
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        SetPlayerPos(playerid, gMarketReturnPos[playerid][0], gMarketReturnPos[playerid][1], gMarketReturnPos[playerid][2]);
        SetPlayerFacingAngle(playerid, gMarketReturnPos[playerid][3]);
        SetCameraBehindPlayer(playerid);
        gMarketInside[playerid] = false;
        SendClientMessage(playerid, COLOR_GREEN, "[������] �� ����� �� �������� � ��������� � �������� �����.");
        return 1;
    }
    if (pickupid == gMarketInteriorCounterPickup)
    {
        if (GetPlayerInterior(playerid) != VX_MARKET_INTERIOR || GetPlayerVirtualWorld(playerid) != VX_MARKET_WORLD ||
            !gMarketInside[playerid] || !IsPlayerInRangeOfPoint(playerid, 3.5, VX_MARKET_COUNTER_X, VX_MARKET_COUNTER_Y, VX_MARKET_COUNTER_Z)) return 1;
        new shopItems[420];
        format(shopItems, sizeof shopItems, "������� - 1 000 ���.\n��� - 250 ���.\n���� - 200 ���.\n�����: ��� + ���� - 400 ���.");
        strcat(shopItems, "\n��������� �������� - 2 500 ���.\nSIM-����� - 1 500 ���.");
        strcat(shopItems, "\n������� ��� ��������� - 7 500 ���.");
        return 1;
    }
    for (new m = 0; m < VX_MARKET_COUNT; m++)
    {
        if (pickupid != gMarketPickups[m]) continue;
        if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0) return 1;
        if (!IsPlayerInRangeOfPoint(playerid, 4.0, gVXMarketPos[m][0], gVXMarketPos[m][1], gVXMarketPos[m][2])) return 1;
        if (IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_YELLOW, "[������] ������� �� ����������, ����� ����� � �������."), 1;
        GetPlayerPos(playerid, gMarketReturnPos[playerid][0], gMarketReturnPos[playerid][1], gMarketReturnPos[playerid][2]);
        GetPlayerFacingAngle(playerid, gMarketReturnPos[playerid][3]);
        gMarketInside[playerid] = true;
        SetPlayerInterior(playerid, VX_MARKET_INTERIOR);
        SetPlayerVirtualWorld(playerid, VX_MARKET_WORLD);
        SetPlayerPos(playerid, VX_MARKET_ENTRY_X, VX_MARKET_ENTRY_Y, VX_MARKET_ENTRY_Z);
        SetPlayerFacingAngle(playerid, VX_MARKET_ENTRY_A);
        SetCameraBehindPlayer(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "[������] ����� ���������� � ������� 24/7. ��������� � ����� ��� ����������� /shop. ����� � � ������� �����.");
        return 1;
    }
    if (pickupid == gCarDealerPickup)
    {
        SendClientMessage(playerid, COLOR_GREEN, "��������� VEXORIUM: ��������� ����� � ����������� /carshop.");
        return 1;
    }
    if (pickupid == gAccessoryShopPickup)
    {
        SendClientMessage(playerid, COLOR_GREEN, "[����������] ����������� /shopacc, ����� ������� �������.");
        return 1;
    }
    for (new gas = 0; gas < VX_GAS_COUNT; gas++)
    {
        if (pickupid == gGasStationPickup[gas])
        {
            SendClientMessage(playerid, COLOR_YELLOW, "��� VEXORIUM: ������������ ����� � �������� � ����������� /fuel.");
            return 1;
        }
    }
    if (pickupid == gFBIStashPickup && IsInOwnOrgInterior(playerid))
    {
        if (gFaction[playerid] != FACTION_FBI || gFactionRank[playerid] < 1)
            return SendClientMessage(playerid, COLOR_RED, "����� FBI �������� ������ ����������� FBI."), 1;
        ShowPlayerDialog(playerid, DIALOG_POLICE_STASH, DIALOG_STYLE_LIST, "FBI | ��������� �����", "������ USP (30 ��������)\n�������� � ������� (60)\nMP5 � ������� (120)\n��-47 � ������� (120)\n�4 � ������� (120)\n�������� (20)\n����������", "�����", "�������");
        return 1;
    }
    if (pickupid == gPoliceStashPickup && IsInPoliceStation(playerid))
    {
        if (gFaction[playerid] != FACTION_POLICE || gFactionRank[playerid] < 1)
            return SendClientMessage(playerid, COLOR_RED, "����� �������� ������ ����������� LSPD."), 1;
        ShowPlayerDialog(playerid, DIALOG_POLICE_STASH, DIALOG_STYLE_LIST, "LSPD | ��������� �����", "�������\nM4 � ������� (�� 100)\n�������� � ������� (�� 100)\n����������", "�����", "�������");
        return 1;
    }
    if (pickupid == gPoliceEntrancePickup && GetPlayerInterior(playerid) == 0 && GetPlayerVirtualWorld(playerid) == 0)
    {
        if (!IsNearPoliceEntrance(playerid)) return 1;
        SetPlayerInterior(playerid, 6); SetPlayerVirtualWorld(playerid, 0);
        SetPlayerPos(playerid, 246.3213, 62.5062, 1003.6406); SetPlayerFacingAngle(playerid, 14.87); SetCameraBehindPlayer(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "�� ����� � ������� LSPD. ���� �����������: /org.");
        ShowFactionCommands(playerid);
        return 1;
    }
    if (pickupid == gPoliceHallGaragePickup && GetPlayerInterior(playerid) == 6 && GetPlayerVirtualWorld(playerid) == 0)
    {
        if (gFaction[playerid] != FACTION_POLICE)
            return SendClientMessage(playerid, COLOR_RED, "����� � ����� LSPD �������� ������ �������."), 1;
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        SetPlayerPos(playerid, 1568.4843, -1690.4116, 5.8906);
        SetPlayerFacingAngle(playerid, 181.71);
        SetCameraBehindPlayer(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "�� ����� �� LSPD � ������ VEXORIUM.");
        return 1;
    }
    if (pickupid == gPoliceExitPickup && GetPlayerInterior(playerid) == 6 && GetPlayerVirtualWorld(playerid) == 0)
    {
        SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
        SetPlayerPos(playerid, 1547.0, -1678.8352, 14.9453); SetPlayerFacingAngle(playerid, 270.41); SetCameraBehindPlayer(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "�� ����� �� ������� LSPD.");
        return 1;
    }
    if (pickupid == gOrgEnterPickup[FACTION_FBI] || pickupid == gFBIBuildingEnterPickup)
    {
        if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0) return 1;
        if (!IsPlayerInRangeOfPoint(playerid, 4.0, 1642.0, -2248.0, 13.5)) return 1;
        if (gFBIPendingEnter[playerid]) return 1;
        gFBIPendingEnter[playerid] = true;
        gFBIEnterTimer[playerid] = SetTimerEx("FinishFBIEnter", 2000, false, "i", playerid);
        SendClientMessage(playerid, COLOR_YELLOW, "[FBI] ��������� 2 ������� � ������� �����.");
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
                SetPlayerPos(playerid, 1642.0, -2251.0, 13.5);
            else
                SetPlayerPos(playerid, ox + 1.5, oy, oz);
            SetPlayerFacingAngle(playerid, (faction == FACTION_CITYHALL) ? 180.91 : ((faction == FACTION_FBI) ? 310.92 : 180.0)); SetCameraBehindPlayer(playerid);
            SendClientMessage(playerid, COLOR_GREEN, "�� ����� �� ����� �����������.");
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
        SendClientMessage(playerid, COLOR_GREEN, "�� ����� ����� ����� ������� � ��������� LSPD.");
        return 1;
    }
    if (pickupid == gPoliceGarageReturnPickup && GetPlayerInterior(playerid) == 0 && GetPlayerVirtualWorld(playerid) == 0 && gFaction[playerid] == FACTION_POLICE)
    {
        SetPlayerInterior(playerid, 6);
        SetPlayerVirtualWorld(playerid, 0);
        SetPlayerPos(playerid, 246.7147, 87.2885, 1003.6406);
        SetPlayerFacingAngle(playerid, 14.87);
        SetCameraBehindPlayer(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "�� ����� � ������� ����� ����� ���������.");
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
    new uniformSkin=GetFactionSkin(gFaction[playerid], gFactionRank[playerid]);
    if(GetPlayerSkin(playerid)==uniformSkin)
    {
        if(gFaction[playerid]==FACTION_HOSPITAL && gVXMedDuty[playerid])
            return SendClientMessage(playerid,COLOR_YELLOW,"[����] ������� ��������� �����: /mduty."),1;
        SetPlayerSkin(playerid,gVXAccountSkin[playerid]);
        gPoliceCivilianSkin[playerid]=(gFaction[playerid]==FACTION_POLICE);
        SendClientMessage(playerid,COLOR_GREEN,"[�����������] �� ����� �����. ������ ����� �������� ����������� ������.");
    }
    else
    {
        SetPlayerSkin(playerid,uniformSkin);
        gPoliceCivilianSkin[playerid]=false;
        SendClientMessage(playerid,COLOR_GREEN,"[�����������] �� ������ ��������� ����� �� �����.");
    }
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
        TogglePlayerControllable(playerid, 0);
        if (GetPlayerSpecialAction(playerid) != 24)
        {
            SetPlayerSpecialAction(playerid, 24);
        }
    }
    // Only our own garage marker is removed on arrival. Jobs keep their checkpoints.
    if(gVXGarageRoute[playerid] && gLogged[playerid] && GetPlayerInterior(playerid)==0
        && GetPlayerVirtualWorld(playerid)==0)
    {
        new Float:gx,Float:gy,Float:gz;
        GetOrgGarage(gFaction[playerid],gx,gy,gz);
        if(gFaction[playerid]==FACTION_POLICE) { gx=1568.4843;gy=-1690.4116;gz=5.8906; }
        if(IsPlayerInRangeOfPoint(playerid,9.0,gx,gy,gz))
        {
            VX_GarageRouteClear(playerid);
            SendClientMessage(playerid,COLOR_GREEN,"[�����] �� ����� ������. ����������� /garage ��� ������ ����������.");
        }
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
    if(nDown && !gNEngineWasDown[playerid] && gLogged[playerid]
        && GetPlayerState(playerid)==PLAYER_STATE_DRIVER)
    {
        new driven=GetPlayerVehicleID(playerid);
        new Float:svx,Float:svy,Float:svz;
        if(driven>0 && driven<MAX_VEHICLES) GetVehicleVelocity(driven,svx,svy,svz);
        // Accidental N presses must not shut down an engine at 46 km/h.
        new speedKm=floatround(floatsqroot(svx*svx+svy*svy+svz*svz)*180.0);
        new e,l,al,d,b,t,o;
        if(driven>0 && driven<MAX_VEHICLES)
        {
            GetVehicleParamsEx(driven,e,l,al,d,b,t,o);
            if(e!=VEHICLE_PARAMS_ON || speedKm<=3) RP_Engine(playerid);
            else SendClientMessage(playerid,COLOR_YELLOW,
                "[���������] ��������� ����� ��������� ������ ����� ������ ���������.");
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
        if (observedWeapon > 0) format(actionText, sizeof actionText, "* %s ������ ������.", gName[playerid]);
        else if (gLastObservedWeapon[playerid] > 0) format(actionText, sizeof actionText, "* %s ����� ������.", gName[playerid]);
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
                new deliveredModel = (deliveredVehicle != INVALID_VEHICLE_ID) ? GetVehicleModel(deliveredVehicle) : 0;
                new deliveredReward = VX_CarjackReward(deliveredModel);
                RemovePlayerFromVehicle(playerid);
                if (deliveredVehicle != INVALID_VEHICLE_ID && GetVehicleModel(deliveredVehicle) != 0) { gCarjackVehicleOwner[deliveredVehicle] = INVALID_PLAYER_ID; DestroyVehicle(deliveredVehicle); }
                gCarjackVehicle[playerid] = INVALID_VEHICLE_ID;
                gCarjackActive[playerid] = false; gCarjackUnlocked[playerid] = false; gWorkStage[playerid] = 0;
                DisablePlayerCheckpoint(playerid);
                RemovePlayerMapIcon(playerid, 48);
                new deliveredMessage[160];
                format(deliveredMessage, sizeof deliveredMessage, "������ ����� �� ���� ����������� �����������! ��������� %d ������.", deliveredReward);
                if (GiveCash(playerid, deliveredReward)) SendClientMessage(playerid, COLOR_GREEN, deliveredMessage);
                else SendClientMessage(playerid, COLOR_RED, "������ �����, �� ������ ������ ��������� � ������� �� ���������.");
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
            SendClientMessage(playerid, COLOR_RED, "������ ����������. ������� �� ��� � ����������� /fuel.");
        }
    }
    return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(gIsJailed[playerid] && (newstate==PLAYER_STATE_DRIVER || newstate==PLAYER_STATE_PASSENGER))
        return RP_JailPosition(playerid);
    if((gHandcuffed[playerid] || gTaserStunned[playerid] || gRPStretcherBy[playerid]!=INVALID_PLAYER_ID)
        && newstate==PLAYER_STATE_DRIVER) { RemovePlayerFromVehicle(playerid); return 1; }
    if(newstate==PLAYER_STATE_DRIVER)
    {
        new rpVehicle=GetPlayerVehicleID(playerid),rpOwner=RP_VehicleOwner(rpVehicle);
        if(rpOwner!=INVALID_PLAYER_ID && !RP_HasKeys(playerid,rpVehicle))
        {
            RemovePlayerFromVehicle(playerid);
            return RP_Message(playerid,"��� ������ �� ����� ������� ����������.");
        }
    }
    if(gVXHospital[playerid] && (newstate==PLAYER_STATE_DRIVER || newstate==PLAYER_STATE_PASSENGER)) { RemovePlayerFromVehicle(playerid);return 1; }
    UpdateVexHud(playerid);
    // Standard SA-MP has no SetPlayerCanDoDriveBy native; drive-by is controlled by the client.
    if (newstate == PLAYER_STATE_DRIVER)
    {
        if (gLogged[playerid])
        {
            new enterText[128];
            format(enterText, sizeof enterText, "* %s ��� �� ���� ����������.", gName[playerid]);
            SendLocalMessage(playerid, COLOR_PINK, enterText, 20.0);
        }
        new enteredVehicle = GetPlayerVehicleID(playerid);
        if (gCarjackActive[playerid] && gCarjackUnlocked[playerid] && enteredVehicle == gCarjackVehicle[playerid])
        {
            new Float:bx, Float:by, Float:bz;
            GetGangBase(gCarjackDestination[playerid], bx, by, bz);
            gWorkStage[playerid] = 11;
            SetPlayerCheckpoint(playerid, bx, by, bz, 10.0);
            SendClientMessage(playerid, COLOR_GREEN, "�� �� ���� �������� ������. ��������� � �� ���� ����� ����������� �����������.");
        }
        if (enteredVehicle > 0 && enteredVehicle < MAX_VEHICLES)
        {
            new engine, lights, alarm, doors, bonnet, boot, objective;
            GetVehicleParamsEx(enteredVehicle, engine, lights, alarm, doors, bonnet, boot, objective);
            SetVehicleParamsEx(enteredVehicle, VEHICLE_PARAMS_OFF, lights, alarm, doors, bonnet, boot, objective);
            new engineHint[96];
            format(engineHint, sizeof engineHint, "������� N, ����� ������� ���������. �������: %d �.", gVehicleFuel[enteredVehicle]);
            SendClientMessage(playerid, COLOR_YELLOW, engineHint);
        }
        if (enteredVehicle > 0 && enteredVehicle < MAX_VEHICLES && gVehicleFaction[enteredVehicle] > 0)
        {
            if (gFactionVehicleOwner[enteredVehicle] == INVALID_PLAYER_ID || gFactionVehicleOwner[enteredVehicle] != playerid)
            {
                RemovePlayerFromVehicle(playerid);
                SendClientMessage(playerid, COLOR_YELLOW, "���� ��������� ������. ����������� /garage, ����� ����� ��������� ������.");
                return 1;
            }
            if (!gLogged[playerid] || gFaction[playerid] != gVehicleFaction[enteredVehicle] || gFactionRank[playerid] < (gVehicleTier[enteredVehicle] * 2 + 1))
            {
                RemovePlayerFromVehicle(playerid);
                SendClientMessage(playerid, COLOR_RED, "���� ��������� ��������� ���������� ����� ������� ��� �����.");
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
                SendClientMessage(playerid, COLOR_RED, "������ ������� � �������, ����� ��� ��������� �����������.");
                return 1;
            }
            if (testVehicle == gDrivingTestVehicle[playerid] && gDrivingTestStage[playerid] > 0) { /* Driving exam vehicle is allowed. */ }
            else if (isScooterOrBicycle) { /* Scooter and bicycles are allowed without a license. */ }
            else if (isBoat)
            {
                if (!gLicenseBoat[playerid])
                {
                    RemovePlayerFromVehicle(playerid);
                    SendClientMessage(playerid, COLOR_RED, "� ��� ��� �������� �� ���������� ������. �������� � � �����.");
                    return 1;
                }
            }
            else if (isAircraft)
            {
                if (!gLicenseAir[playerid])
                {
                    RemovePlayerFromVehicle(playerid);
                    SendClientMessage(playerid, COLOR_RED, "� ��� ��� �������� �� ���������� ��������� �����������. �������� � � �����.");
                    return 1;
                }
            }
            else if (!gLicenseDriver[playerid])
            {
                RemovePlayerFromVehicle(playerid);
                SendClientMessage(playerid, COLOR_RED, "� ��� ��� ������������� ��������. ��������� � ��������� � ������ �������.");
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
                SendClientMessage(playerid, COLOR_RED, "������ �������� ������ ����������� �������� ��� �����������.");
            else if (gLevel[playerid] > 3)
                SendClientMessage(playerid, COLOR_RED, "������ �������� ������ ������� 1�3 ������.");
            else
                SendClientMessage(playerid, COLOR_RED, "������� ������� � �������, ����� ���������� ������.");
            return 1;
        }
        if (!gPendingScooterChoice[playerid])
        {
            gPendingScooterChoice[playerid] = true;
            ShowPlayerDialog(playerid, DIALOG_RENT_SCOOTER, DIALOG_STYLE_MSGBOX,
                "VEXORIUM RP | ������ �������",
                "�� ���� �� Faggio.\n���������� ��� �� 250 ������?\n����� ������ ����� ������ �������� �� ����.\n������������ ������ ������������ � �������, ������ ����� ������� �� ������.",
                "����������", "�� �����");
        }
    }
    if(newstate==PLAYER_STATE_DRIVER && gCarjackActive[playerid] && gCarjackUnlocked[playerid] && GetPlayerVehicleID(playerid)==gCarjackVehicle[playerid] && !gVXCarjackCharged[playerid])
    {
        gVXCarjackCharged[playerid]=true;
        VX_AddWanted(playerid);
        AnnounceCarjack(playerid);
        SendClientMessage(playerid,COLOR_RED,"[������] ���� ����������: +1 ������. ������ 30 ����� ��������� ���� ������.");
    }
    return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
    if (gLogged[playerid])
    {
        new exitText[128];
        format(exitText, sizeof exitText, "* %s ����� �� ����������.", gName[playerid]);
        SendLocalMessage(playerid, COLOR_PINK, exitText, 20.0);
    }
    if (vehicleid > 0 && vehicleid < MAX_VEHICLES && gVehicleFaction[vehicleid] > 0)
        StartFleetVehicleReturn(vehicleid);
    return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
    if(VX_IsDisplayFleetVehicle(vehicleid))
    {
        SetVehicleToRespawn(vehicleid);
        VX_ResetDisplayFleet(vehicleid);
        return 1;
    }
    if(RP_OnCarDeath(vehicleid)) return 1;
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
        // ������ ���������� ������� ����������� � ��������� � ������������ � ����� ������.
        SetVehicleToRespawn(vehicleid);
        gVehicleFuel[vehicleid] = 100;
        gFuelLastX[vehicleid] = 0.0; gFuelLastY[vehicleid] = 0.0; gFuelLastZ[vehicleid] = 0.0;
    }
    return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
    if(gIsJailed[playerid] || gHandcuffed[playerid] || gTaserStunned[playerid]
        || gRPStretcherBy[playerid]!=INVALID_PLAYER_ID) return 1;
    if (!gLogged[playerid]) return 1;
    if (gDrivingTestStage[playerid] > 0)
    {
        if (!IsPlayerInAnyVehicle(playerid) || GetPlayerVehicleID(playerid) != gDrivingTestVehicle[playerid] || GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
        {
            DisablePlayerCheckpoint(playerid);
            gDrivingTestStage[playerid] = 0;
            if (gDrivingTestVehicle[playerid] != INVALID_VEHICLE_ID) DestroyVehicle(gDrivingTestVehicle[playerid]);
            gDrivingTestVehicle[playerid] = INVALID_VEHICLE_ID;
            SendClientMessage(playerid, COLOR_RED, "[���������] ������� �����: ����� ������ � ������� ������." );
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
                SendClientMessage(playerid, COLOR_RED, "[���������] �� ������� ����� ��� ������ �������. �������� �� �������.");
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
            SendClientMessage(playerid, COLOR_GREEN, "[���������] ������� ����! ������ ��������: $15000.");
            SendClientMessage(playerid, COLOR_YELLOW, "������� � ����� � ��������� � ����� ��������, ����� �������� ������������ �����.");
            return 1;
        }
        switch (gDrivingTestStage[playerid])
        {
            case 2: SetPlayerCheckpoint(playerid, -2337.8027, 448.6180, 33.5087, 5.0);
            case 3: SetPlayerCheckpoint(playerid, -2300.4072, 509.8988, 34.6583, 5.0);
            case 4: SetPlayerCheckpoint(playerid, -2000.8323, 471.5700, 35.0156, 5.0);
            case 5: SetPlayerCheckpoint(playerid, -2028.8990, -71.3546, 35.1718, 5.0);
        }
        SendClientMessage(playerid, COLOR_BLUE, "[���������] ����������� ����� ��������. �������� � ���������." );
        return 1;
    }
    if (gTaxiOrderTarget[playerid] != INVALID_PLAYER_ID)
    {
        new taxiPassenger = gTaxiOrderTarget[playerid];
        if (taxiPassenger < 0 || taxiPassenger >= MAX_PLAYERS || !IsPlayerConnected(taxiPassenger)
            || !gLogged[taxiPassenger] || gTaxiOrderDriver[taxiPassenger] != playerid)
        {
            VX_TaxiClearDriver(playerid, "[�����] ����� �������: �������� ����������.", true);
            return 1;
        }
        if (!gTaxiAtPickup[playerid])
        {
            if (GetPlayerDistanceFromPoint(taxiPassenger, gTaxiPickupPos[taxiPassenger][0], gTaxiPickupPos[taxiPassenger][1], gTaxiPickupPos[taxiPassenger][2]) > 30.0)
            {
                VX_TaxiClearDriver(playerid, "[�����] ����� �������: �������� ������� ����� ������.", true);
                SendClientMessage(playerid, COLOR_YELLOW, "[�����] ��������� ��� �� ����� ������. ������� ����� ������������.");
                return 1;
            }
            new taxiVehicle = gWorkVehicle[playerid];
            if (GetPlayerState(playerid) != PLAYER_STATE_DRIVER || taxiVehicle <= 0 || GetPlayerVehicleID(playerid) != taxiVehicle)
            {
                VX_TaxiClearDriver(playerid, "[�����] ����� �������: �������� ������� ������� ������.", true);
                SendClientMessage(playerid, COLOR_YELLOW, "[�����] ����� ������� � ����� ���������� �� ���� �����.");
                return 1;
            }
            DisablePlayerCheckpoint(playerid);
            gTaxiAtPickup[playerid] = true;
            RemovePlayerMapIcon(playerid, 47);
            SetPlayerMapIcon(playerid, 47, gTaxiPickupPos[taxiPassenger][0], gTaxiPickupPos[taxiPassenger][1],
                gTaxiPickupPos[taxiPassenger][2], 0, COLOR_YELLOW, MAPICON_LOCAL);
            SendClientMessage(playerid, COLOR_GREEN, "[�����] �� �� �����. ���������, ���� �������� ����� � ������. ��������� �����: /taxidone.");
            SendClientMessage(taxiPassenger, COLOR_GREEN, "[�����] ������ �������! ������ �� ������������ ����� � �������� �������� ����� ����������.");
            return 1;
        }
        return 1;
    }
    if (gGpsActive[playerid])
    {
        DisablePlayerCheckpoint(playerid);
        gGpsActive[playerid] = false;
        SendClientMessage(playerid, COLOR_GREEN, "[VEXORIUM GPS] �� ������� � ����� ����������.");
        return 1;
    }
    if (gCarjackActive[playerid] && gWorkStage[playerid] == 10)
    {
        if (!gCarjackUnlocked[playerid])
        {
            SendClientMessage(playerid, COLOR_YELLOW, "�� ����� ������. ��������� � ��� � ����������� /hack.");
            return 1;
        }
        if (!IsPlayerInAnyVehicle(playerid) || GetPlayerVehicleID(playerid) != gCarjackVehicle[playerid] || GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
        {
            SendClientMessage(playerid, COLOR_YELLOW, "������� ������ �� ���� �������� ������.");
            return 1;
        }
        new Float:bx, Float:by, Float:bz;
        GetGangBase(gCarjackDestination[playerid], bx, by, bz);
        SetPlayerCheckpoint(playerid, bx, by, bz, 10.0);
        gWorkStage[playerid] = 11;
        SendClientMessage(playerid, COLOR_GREEN, "������ ������ �� ���������� ���� ����������� �����������.");
        return 1;
    }
    if (gCarjackActive[playerid] && gWorkStage[playerid] == 11)
    {
        if (!IsPlayerInAnyVehicle(playerid) || GetPlayerVehicleID(playerid) != gCarjackVehicle[playerid] || GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
            return SendClientMessage(playerid, COLOR_RED, "����� ����� �������� ������, �� ������ ���� �� � ����."), 1;
        new Float:bx, Float:by, Float:bz;
        GetGangBase(gCarjackDestination[playerid], bx, by, bz);
        if (GetPlayerDistanceFromPoint(playerid, bx, by, bz) > 18.0)
            return SendClientMessage(playerid, COLOR_YELLOW, "��������� ����� � ���� �����, ���������� �� �����."), 1;
        new stolenVehicle = gCarjackVehicle[playerid];
        new stolenModel = (stolenVehicle != INVALID_VEHICLE_ID) ? GetVehicleModel(stolenVehicle) : 0;
        new stolenReward = VX_CarjackReward(stolenModel);
        RemovePlayerFromVehicle(playerid);
        if (stolenVehicle != INVALID_VEHICLE_ID && GetVehicleModel(stolenVehicle) != 0) { gCarjackVehicleOwner[stolenVehicle] = INVALID_PLAYER_ID; DestroyVehicle(stolenVehicle); }
        gCarjackVehicle[playerid] = INVALID_VEHICLE_ID;
        gCarjackActive[playerid] = false; gCarjackUnlocked[playerid] = false; gWorkStage[playerid] = 0;
        DisablePlayerCheckpoint(playerid);
        RemovePlayerMapIcon(playerid, 48);
        new stolenRewardMessage[144];
        format(stolenRewardMessage, sizeof stolenRewardMessage, "���� ��������! �� �������� %d ������.", stolenReward);
        if (GiveCash(playerid, stolenReward)) SendClientMessage(playerid, COLOR_GREEN, stolenRewardMessage);
        else SendClientMessage(playerid, COLOR_RED, "������ �����, �� �� ������� ��������� ������ ��-�� ������ �������.");
        SavePlayer(playerid);
        return 1;
    }
    if (gWorkStage[playerid] > 0)
    {
        if (((gJob[playerid] >= 1 && gJob[playerid] <= 3) || gJob[playerid] == 7) && (gWorkVehicle[playerid] == INVALID_VEHICLE_ID || !IsPlayerInAnyVehicle(playerid) || GetPlayerVehicleID(playerid) != gWorkVehicle[playerid]))
        {
            SendClientMessage(playerid, COLOR_RED, "��� ����������� ������� ����� ����� ���������� � �������� ������� ����������.");
            return 1;
        }
        gWorkStage[playerid]++;
        if (gWorkStage[playerid] >= 4)
        {
            new reward = (gJob[playerid] == 1) ? 4200 : ((gJob[playerid] == 2) ? 6000 : ((gJob[playerid] == 3) ? 5000 : ((gJob[playerid] == 7) ? 7500 : 7000)));
            if (GiveCash(playerid, reward))
            {
                SendClientMessage(playerid, COLOR_GREEN, "[VEXORIUM] ������� ��������! �������� ���������.");
                new msg[96];
                format(msg, sizeof msg, "[VEXORIUM] �� ���������� %d ������.", reward);
                SendClientMessage(playerid, COLOR_GREEN, msg);
            }
            else SendClientMessage(playerid, COLOR_RED, "[VEXORIUM] �� ������� ��������� ��������: ��������� ����� �����.");
            gWorkStage[playerid] = 0;
            gFireCallIndex[playerid] = -1;
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
        else if (gJob[playerid] == 7)
        {
            if (gWorkStage[playerid] == 2)
            {
                new nextFireCall = random(VX_FIRE_CALL_COUNT);
                if (nextFireCall == gFireCallIndex[playerid]) nextFireCall = (nextFireCall + 1) % VX_FIRE_CALL_COUNT;
                gFireCallIndex[playerid] = nextFireCall;
                SetPlayerCheckpoint(playerid, gVXFireCallPos[nextFireCall][0],
                    gVXFireCallPos[nextFireCall][1], gVXFireCallPos[nextFireCall][2], 7.0);
                SendClientMessage(playerid, COLOR_ORANGE, "[�������� ������] ������ ����� ������. ����������� �������� �� ������.");
            }
            else
            {
                SetPlayerCheckpoint(playerid, VX_FIRE_STATION_X, VX_FIRE_STATION_Y, VX_FIRE_STATION_Z, 8.0);
                SendClientMessage(playerid, COLOR_ORANGE, "[�������� ������] ������ ����������. ������������� �� ���� ��� ���������� �����.");
            }
        }
        else
        {
            if (gWorkStage[playerid] == 2) SetPlayerCheckpoint(playerid, 838.0, 870.0, 12.0, 7.0);
            else SetPlayerCheckpoint(playerid, 852.0, 850.0, 12.0, 7.0);
        }
        SendClientMessage(playerid, COLOR_BLUE, "[VEXORIUM] ����������� ����� ��������. �������� � ��������� �������.");
        return 1;
    }
    return 1;
}

stock ShowMainMenu(playerid)
{
    new menuText[512];
    menuText[0] = '\0';
    strcat(menuText, "{33CC66}�������� � ��������\n");
    strcat(menuText, "{FFFFFF}��� ������� � ����������\n");
    strcat(menuText, "����� ���������\n");
    strcat(menuText, "{66CCFF}����� � ���������\n");
    strcat(menuText, "GPS � �����\n");
    strcat(menuText, "������ � ���������\n");
    strcat(menuText, "����������� � ������\n");
    strcat(menuText, "{FFD700}����������\n");
    strcat(menuText, "������� �������\n");
    strcat(menuText, "������ ������\n");
    strcat(menuText, "{FFCC66}��������� � ��������\n");
    strcat(menuText, "{FFFFFF}��� ���������\n");
    strcat(menuText, "{66CCFF}������� � �����\n");
    strcat(menuText, "������� ���������\n");
    ShowPlayerDialog(playerid, DIALOG_MAIN_MENU, DIALOG_STYLE_LIST,
        "{33CC66}VEXORIUM RP {FFFFFF}| ����� ������", menuText,
        "�������", "�������");
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
    if(gIsJailed[playerid] || gHandcuffed[playerid] || gTaserStunned[playerid]
        || gRPStretcherBy[playerid]!=INVALID_PLAYER_ID) return 1;
    if(gVXHospital[playerid] || gVXSpec[playerid]!=INVALID_PLAYER_ID) return 1;
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
    SendClientMessage(playerid, COLOR_GREEN, "[VEXORIUM] ������������ �� ����� ���������.");
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if(VX_Valid(playerid) && GetPlayerVirtualWorld(playerid)==VX_HOSPITAL_WORLD
        && !gIsJailed[playerid] && !gHandcuffed[playerid] && !gTaserStunned[playerid]
        && (newkeys & KEY_WALK) && !(oldkeys & KEY_WALK))
    {
        if(VX_InsideLobby(playerid))
        {
            if(IsPlayerInRangeOfPoint(playerid,3.0,VX_LOBBY_EXIT_X,VX_LOBBY_EXIT_Y,VX_LOBBY_Z)) return VX_HospitalExit(playerid);
            if(IsPlayerInRangeOfPoint(playerid,3.0,VX_LOBBY_WARD_X,VX_LOBBY_WARD_Y,VX_LOBBY_Z)) return VX_EnterWard(playerid);
            if(IsPlayerInRangeOfPoint(playerid,3.0,VX_LOBBY_CERT_X,VX_LOBBY_CERT_Y,VX_LOBBY_Z)) return VX_MedCertificate(playerid);
        }
        if(VX_InsideWard(playerid))
        {
            if(IsPlayerInRangeOfPoint(playerid,3.0,VX_WARD_LOBBY_X,VX_WARD_LOBBY_Y,VX_WARD_Z))return VX_ReturnLobby(playerid);
            if(gVXHospital[playerid])return VX_OccupyBed(playerid);
        }
    }
    if(gIsJailed[playerid] || gHandcuffed[playerid] || gTaserStunned[playerid]
        || gRPStretcherBy[playerid]!=INVALID_PLAYER_ID) return 1;
    if(!gLogged[playerid] || gVXHospital[playerid] || gVXSpec[playerid]!=INVALID_PLAYER_ID) return 1;
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
                SendClientMessage(playerid, COLOR_RED, "[PvP] ����������� ��� ���������������.");
                return 1;
            }
            if (gPvpActive[playerid] || gPvpActive[challenger]) return SendClientMessage(playerid, COLOR_RED, "[PvP] ���� �� ������� ��� ��������� � �����."), 1;
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
            SendClientMessage(playerid, COLOR_GREEN, "[PvP] �� ������� �����! ������ Desert Eagle, �� 5 �����.");
            SendClientMessage(challenger, COLOR_GREEN, "[PvP] �������� ������ �����! ������ Desert Eagle, �� 5 �����.");
            return 1;
        }
        if (gLogged[playerid] && GetPlayerInterior(playerid) == 0 && GetPlayerVirtualWorld(playerid) == 0 && IsPlayerInRangeOfPoint(playerid, 3.5, -2026.8, -96.5, 35.2))
        {
            if (gLicenseDriver[playerid]) SendClientMessage(playerid, COLOR_GREEN, "� ��� ��� ���� ������������ ��������." );
            else if (gDrivingTestStage[playerid] > 0) SendClientMessage(playerid, COLOR_YELLOW, "�� ��� ����� �������. �������� �� ����������� ������." );
            else ShowPlayerDialog(playerid, DIALOG_AUTOSCHOOL, DIALOG_STYLE_MSGBOX, "��������� | ����������", "������������! ���������� ������� ���������� � ������ �������?\n������� �������� �� ������� ���-������.\n������ 15000 ���. ������ ����� �������� �����.", "������", "������");
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

stock VX_RefreshHouseLabel(hid)
{
    if (hid < 1 || hid > VX_HOUSE_COUNT || gDatabase == DB:0) return 0;
    new query[128], houseOwner[MAX_PLAYER_NAME + 1], ownerLabel[MAX_PLAYER_NAME + 1], label[192];
    format(query, sizeof query, "SELECT owner,price,x,y,z FROM houses WHERE id=%d", hid);
    new DBResult:hr = db_query(gDatabase, query);
    if (!hr || !db_num_rows(hr)) { if (hr) db_free_result(hr); return 0; }
    houseOwner[0] = '\0';
    db_get_field(hr, 0, houseOwner, sizeof houseOwner);
    if (houseOwner[0]) format(ownerLabel, sizeof ownerLabel, "%s", houseOwner);
    else format(ownerLabel, sizeof ownerLabel, "����");
    new price = db_get_field_int(hr, 1);
    new Float:hx = db_get_field_float(hr, 2), Float:hy = db_get_field_float(hr, 3), Float:hz = db_get_field_float(hr, 4);
    db_free_result(hr);
    if (gVXHouseLabelCreated[hid]) Delete3DTextLabel(gVXHouseLabel[hid]);
    format(label, sizeof label, "{66CCFF}��� #%d\n{FFFFFF}��������: %s\n����: %d ���.\n{33CC66}/housebuy /houseenter", hid, ownerLabel, price);
    gVXHouseLabel[hid] = Create3DTextLabel(label, COLOR_WHITE, hx, hy, hz + 1.0, 18.0, 0, 1);
    gVXHouseLabelCreated[hid] = true;
    if (gHousePickup[hid] == INVALID_PICKUP) gHousePickup[hid] = CreatePickup(1273, 1, hx, hy, hz, 0);
    return 1;
}

stock VX_HouseEnterID(playerid, hid)
{
    if (hid < 1 || hid > VX_HOUSE_COUNT) return 0;
    new query[128], owner[MAX_PLAYER_NAME + 1];
    format(query, sizeof query, "SELECT owner FROM houses WHERE id=%d", hid);
    new DBResult:hr = db_query(gDatabase, query);
    owner[0] = '\0';
    if (!hr || !db_num_rows(hr)) { if (hr) db_free_result(hr); return SendClientMessage(playerid, COLOR_RED, "�� ������� ����� ���."), 1; }
    db_get_field(hr, 0, owner, sizeof owner);
    db_free_result(hr);
    if (!owner[0]) return SendClientMessage(playerid, COLOR_YELLOW, "��������: ����. ������� ������ ��� ����� /housebuy."), 1;
    if (strcmp(owner, gName[playerid], true)) return SendClientMessage(playerid, COLOR_RED, "����� ����� ������ �������� ����."), 1;
    gCurrentHouse[playerid] = hid;
    SetPlayerInterior(playerid, 1);
    SetPlayerVirtualWorld(playerid, hid);
    SetPlayerPos(playerid, 223.0, 1287.0, 1082.1);
    SetPlayerFacingAngle(playerid, 0.0);
    SetCameraBehindPlayer(playerid);
    return SendClientMessage(playerid, COLOR_GREEN, "�� ����� � ���. ��� ������ ����������� /houseexit."), 1;
}

stock VX_HouseCompletePurchase(playerid, hid)
{
    if (!VX_Valid(playerid) || hid < 1 || hid > VX_HOUSE_COUNT) { gHousePending[playerid] = 0; return 1; }
    new query[256], owner[MAX_PLAYER_NAME + 1], price = 0;
    format(query, sizeof query, "SELECT owner,price,x,y,z FROM houses WHERE id=%d", hid);
    new DBResult:hr = db_query(gDatabase, query);
    if (!hr || !db_num_rows(hr)) { if (hr) db_free_result(hr); gHousePending[playerid] = 0; return SendClientMessage(playerid, COLOR_RED, "��� �� ������."), 1; }
    owner[0] = '\0'; db_get_field(hr, 0, owner, sizeof owner); price = db_get_field_int(hr, 1);
    new Float:hx = db_get_field_float(hr, 2), Float:hy = db_get_field_float(hr, 3), Float:hz = db_get_field_float(hr, 4);
    db_free_result(hr);
    if (owner[0]) { gHousePending[playerid] = 0; return SendClientMessage(playerid, COLOR_RED, "���� ��� ��� ������."), 1; }
    if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0 || !IsPlayerInRangeOfPoint(playerid, 5.0, hx, hy, hz))
    { gHousePending[playerid] = 0; return SendClientMessage(playerid, COLOR_RED, "������� ��������: ��������� � ����."), 1; }
    if (gMoney[playerid] < price) { gHousePending[playerid] = 0; return SendClientMessage(playerid, COLOR_RED, "������������ �����."), 1; }
    format(query, sizeof query, "SELECT id FROM houses WHERE owner='%q' LIMIT 1", gName[playerid]);
    new DBResult:owned = db_query(gDatabase, query);
    if (!owned || db_num_rows(owned) > 0)
    { if (owned) db_free_result(owned); gHousePending[playerid] = 0; return SendClientMessage(playerid, COLOR_RED, "����� ������� ������ ����� �����."), 1; }
    db_free_result(owned);
    format(query, sizeof query, "UPDATE houses SET owner='%q' WHERE id=%d AND owner=''", gName[playerid], hid);
    new DBResult:buy = db_query(gDatabase, query);
    if (!buy) { gHousePending[playerid] = 0; return SendClientMessage(playerid, COLOR_RED, "������ ���������� �������."), 1; }
    db_free_result(buy);
    format(query, sizeof query, "SELECT owner FROM houses WHERE id=%d", hid);
    buy = db_query(gDatabase, query);
    owner[0] = '\0'; if (buy && db_num_rows(buy)) db_get_field(buy, 0, owner, sizeof owner); if (buy) db_free_result(buy);
    if (strcmp(owner, gName[playerid], true)) { gHousePending[playerid] = 0; return SendClientMessage(playerid, COLOR_RED, "�� ������� ����������� �������."), 1; }
    gMoney[playerid] -= price;
    SavePlayer(playerid);
    gHousePending[playerid] = 0;
    VX_RefreshHouseLabel(hid);
    return SendClientMessage(playerid, COLOR_GREEN, "�����������! �� ������ ���. ��������: ��."), 1;
}

stock VX_FindDealerSpawn(playerid, &Float:spawnX, &Float:spawnY, &Float:spawnZ, &Float:spawnA)
{
    new Float:px, Float:py, Float:pz, Float:pa;
    GetPlayerPos(playerid, px, py, pz);
    GetPlayerFacingAngle(playerid, pa);
    for (new ring = 0; ring < 4; ring++)
    {
        new Float:dist = 7.0 + float(ring) * 3.0;
        // Search the full circle around the showroom instead of only the direction the buyer faces.
        for (new side = -4; side <= 4; side++)
        {
            new Float:ang = pa + float(side) * 45.0;
            new Float:cx = px + (dist * floatsin(-ang, degrees));
            new Float:cy = py + (dist * floatcos(-ang, degrees));
            new Float:cz = pz + 0.35;
            new bool:blocked = false;
            for (new v = 1; v < MAX_VEHICLES; v++)
            {
                if (!GetVehicleModel(v) || GetVehicleVirtualWorld(v) != 0) continue;
                new Float:vx, Float:vy, Float:vz; GetVehiclePos(v, vx, vy, vz);
                new Float:dx = vx - cx, Float:dy = vy - cy;
                if (dx * dx + dy * dy < 36.0 && floatabs(vz - cz) < 4.0) { blocked = true; break; }
            }
            if (blocked) continue;
            for (new p = 0; p < MAX_PLAYERS; p++)
            {
                if (p == playerid || !IsPlayerConnected(p) || GetPlayerVirtualWorld(p) != 0 || GetPlayerInterior(p) != 0) continue;
                new Float:qx, Float:qy, Float:qz; GetPlayerPos(p, qx, qy, qz);
                new Float:dx = qx - cx, Float:dy = qy - cy;
                if (dx * dx + dy * dy < 16.0 && floatabs(qz - cz) < 4.0) { blocked = true; break; }
            }
            if (blocked) continue;
            spawnX = cx; spawnY = cy; spawnZ = cz; spawnA = pa;
            return 1;
        }
    }
    return 0;
}

stock GetFactionVehicleSpeedLimitKmh(faction, tier)
{
    // LSPD: first road vehicle 200 km/h, then +5 km/h by /garage tier.
    // Tier 4 is the heavy Enforcer and keeps its default handling.
    if (faction == FACTION_POLICE)
    {
        switch (tier)
        {
            case 0: return 200;
            case 1: return 205;
            case 2: return 210;
            case 3: return 215;
        }
        return 0;
    }
    // FBI: keep the helicopter (tier 2) and heavy Enforcer untouched.
    if (faction == FACTION_FBI)
    {
        switch (tier)
        {
            case 0: return 200;
            case 1: return 205;
            case 3: return 215;
        }
    }
    return 0;
}

stock Float:VX_VehicleSpeedScale(vehicleid)
{
    // Model 596 is the first LSPD cruiser. Use a dedicated scale so it can reach
    // 200 on the HUD; VX_VehicleSpeedLimitKmh applies the same 200 cap.
    if (vehicleid > 0 && vehicleid < MAX_VEHICLES && GetVehicleModel(vehicleid) == 596) return 270.0;
    return 180.0;
}

stock VX_VehicleSpeedLimitKmh(vehicleid)
{
    if (vehicleid <= 0 || vehicleid >= MAX_VEHICLES || !GetVehicleModel(vehicleid)) return 0;
    new model = GetVehicleModel(vehicleid);
    // The model-level fallback is intentional: don't let missing fleet metadata
    // disable the 200 km/h cap on the first LSPD cruiser.
    if (model == 596) return 200;
    if (gPersonalVehicleOwner[vehicleid] != INVALID_PLAYER_ID)
    {
        new owner = gPersonalVehicleOwner[vehicleid];
        if (owner >= 0 && owner < MAX_PLAYERS && IsPlayerConnected(owner) && gOwnedCarVehicle[owner] == vehicleid)
        {
            switch (model)
            {
                case 401: return 90;
                case 404: return 95;
                case 436: return 100;
                case 445: return 105;
                case 451: return 110;
                case 560: return 200;
            }
        }
    }
    if ((gVehicleFaction[vehicleid] == FACTION_POLICE || gVehicleFaction[vehicleid] == FACTION_FBI)
        && !gVXFleetAnchored[vehicleid] && gFactionVehicleOwner[vehicleid] != INVALID_PLAYER_ID)
    {
        // Limit only the listed road cars/motorcycles. Heavy vehicles and aircraft are not changed.
        if (model == 596 || model == 599 || model == 523 || model == 490 || model == 528)
            return GetFactionVehicleSpeedLimitKmh(gVehicleFaction[vehicleid], gVehicleTier[vehicleid]);
    }
    return 0;
}

stock VX_ApplyVehicleSpeedLimit(playerid)
{
    if (!IsPlayerConnected(playerid) || GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return 0;
    new vehicleid = GetPlayerVehicleID(playerid);
    new limit = VX_VehicleSpeedLimitKmh(vehicleid);
    if (limit <= 0) return 0;

    new Float:vx, Float:vy, Float:vz;
    GetVehicleVelocity(vehicleid, vx, vy, vz);
    // Use the same scale as the HUD. The first LSPD cruiser uses 270 and is capped
    // at 200 km/h, rather than topping out near 175 because of the default scale.
    new Float:speedScale = VX_VehicleSpeedScale(vehicleid);
    new Float:speed = floatsqroot(vx * vx + vy * vy + vz * vz) * speedScale;
    if (speed > float(limit))
    {
        new Float:scale = float(limit) / speed;
        SetVehicleVelocity(vehicleid, vx * scale, vy * scale, vz * scale);
        return 1;
    }

    // Stock GTA SA handling can prevent some models (especially service SUVs) from
    // reaching the configured cap. While the driver is accelerating with the engine on,
    // add a small forward impulse near the top end. This lets the cap be attainable
    // without changing heavy vehicles, aircraft, pedestrians, or vehicles without a limit.
    new keys, updown, leftright;
    GetPlayerKeys(playerid, keys, updown, leftright);
    // Vehicle throttle is often reported as a negative updown axis value, not KEY_SPRINT.
    // Accept either signal so the speed assist actually engages while W is held.
    #pragma unused leftright
    if (!(keys & KEY_SPRINT) && updown >= 0) return 1;
    if (speed < float(limit) * 0.68) return 1;

    new engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
    if (engine != VEHICLE_PARAMS_ON) return 1;

    // If the car is moving backwards, don't push it forward while reversing.
    new Float:angle;
    GetVehicleZAngle(vehicleid, angle);
    new Float:forwardX = -floatsin(angle, degrees);
    new Float:forwardY = floatcos(angle, degrees);
    if (speed > 18.0 && (vx * forwardX + vy * forwardY) < 0.0) return 1;

    new Float:boost = (speed >= float(limit) * 0.85) ? 0.055 : 0.025;
    SetVehicleVelocity(vehicleid, vx + forwardX * boost, vy + forwardY * boost, vz);
    return 1;
}

public VX_VehicleSpeedTick()
{
    for (new playerid = 0; playerid < MAX_PLAYERS; playerid++)
    {
        if (!IsPlayerConnected(playerid) || !gLogged[playerid]) continue;
        VX_ApplyVehicleSpeedLimit(playerid);
    }
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    if(!gLogged[playerid]) return SendClientMessage(playerid,COLOR_RED,"������� ������� � �������."),1;
    if(!gRPLoaded[playerid]) return RP_Message(playerid,"������ RP �� ���������. ����������� ��� ���������� � �������������.");
    if(RP_CommandGuard(playerid,cmdtext)) return 1;
    if(RP_Command(playerid,cmdtext)) return 1;
    if(VX_Command(playerid,cmdtext)) return 1;
    if (CommandMatch(cmdtext, "/taxiaccept"))
    {
        new params[32], token[16], targetid;
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, token, sizeof token)) return SendClientMessage(playerid, COLOR_YELLOW, "�������������: /taxiaccept ID ���������"), 1;
        targetid = strval(token);
        if (!VX_TaxiOnDuty(playerid)) return SendClientMessage(playerid, COLOR_RED, "[�����] ������� ���������� ��������� (/job), ������� �� ����� (/work) � ����������� �� ���� ��������� �����."), 1;
        if (targetid < 0 || targetid >= MAX_PLAYERS || targetid == playerid || !IsPlayerConnected(targetid) || !gLogged[targetid])
            return SendClientMessage(playerid, COLOR_RED, "[�����] ����� �� ������."), 1;
        if (!gTaxiRequestActive[targetid] || gTaxiOrderDriver[targetid] != INVALID_PLAYER_ID)
            return SendClientMessage(playerid, COLOR_YELLOW, "[�����] � ����� ������ ��� ���������� ������."), 1;
        if (GetPlayerInterior(targetid) != 0 || GetPlayerVirtualWorld(targetid) != 0)
            return SendClientMessage(playerid, COLOR_YELLOW, "[�����] ����� �� ��������� ����������. ��������� ��������� ����� �� �����."), 1;
        gTaxiRequestActive[targetid] = false;
        gTaxiOrderTarget[playerid] = targetid;
        gTaxiOrderDriver[targetid] = playerid;
        gTaxiAtPickup[playerid] = false;
        gGpsActive[playerid] = false;
        SetPlayerCheckpoint(playerid, gTaxiPickupPos[targetid][0], gTaxiPickupPos[targetid][1], gTaxiPickupPos[targetid][2], 6.0);
        SetPlayerMapIcon(playerid, 47, gTaxiPickupPos[targetid][0], gTaxiPickupPos[targetid][1], gTaxiPickupPos[targetid][2], 0, COLOR_YELLOW, MAPICON_LOCAL);
        new orderMessage[128];
        format(orderMessage, sizeof orderMessage, "[�����] �������� %s ������ ����� � ���� � ���.", gName[playerid]);
        SendClientMessage(targetid, COLOR_GREEN, orderMessage);
        format(orderMessage, sizeof orderMessage, "[�����] ����� ������ %s ������. �������� � ����� �������.", gName[targetid]);
        SendClientMessage(playerid, COLOR_GREEN, orderMessage);
        return 1;
    }
    if (CommandMatch(cmdtext, "/taxidone"))
    {
        new targetid = gTaxiOrderTarget[playerid];
        if (targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid) || !gTaxiAtPickup[playerid])
            return SendClientMessage(playerid, COLOR_YELLOW, "[�����] ��� �������� �������. ������: /taxiaccept ID."), 1;
        new vehicleid = gWorkVehicle[playerid];
        if (vehicleid <= 0 || vehicleid >= MAX_VEHICLES || GetVehicleModel(vehicleid) != 420
            || GetPlayerState(playerid) != PLAYER_STATE_DRIVER || GetPlayerVehicleID(playerid) != vehicleid)
            return SendClientMessage(playerid, COLOR_RED, "[�����] �� ������ ���� �� ���� ��������� �����."), 1;
        if (!IsPlayerInVehicle(targetid, vehicleid) || GetPlayerVehicleSeat(targetid) < 1)
            return SendClientMessage(playerid, COLOR_YELLOW, "[�����] �������� ������ ���������� � ����� ����� �� ������������ �����."), 1;
        new Float:px, Float:py, Float:pz;
        GetPlayerPos(targetid, px, py, pz);
        new Float:dx = px - gTaxiPickupPos[targetid][0];
        new Float:dy = py - gTaxiPickupPos[targetid][1];
        new Float:dz = pz - gTaxiPickupPos[targetid][2];
        new Float:distance = floatsqroot(dx * dx + dy * dy + dz * dz);
        new fare = floatround(250.0 + distance * 45.0);
        if (fare < 250) fare = 250;
        if (fare > 12000) fare = 12000;
        if (gMoney[playerid] > MAX_MONEY - fare)
            return SendClientMessage(playerid, COLOR_RED, "[�����] ��� ������ ������ ������, ������ �� ����� ��������� ������."), 1;
        if (gMoney[targetid] < fare)
        {
            new paymentMessage[128];
            format(paymentMessage, sizeof paymentMessage, "[�����] ������� ����� %d ���. � ��������� ������������ ��������.", fare);
            SendClientMessage(playerid, COLOR_RED, paymentMessage);
            format(paymentMessage, sizeof paymentMessage, "[�����] ������ �������: %d ���. ��������� �������� ��� ������������ � ���������.", fare);
            SendClientMessage(targetid, COLOR_YELLOW, paymentMessage);
            return 1;
        }
        TakeCash(targetid, fare);
        GiveCash(playerid, fare);
        SavePlayer(targetid); SavePlayer(playerid);
        new fareMessage[128];
        format(fareMessage, sizeof fareMessage, "[�����] ������� ���������. � ��������� �������� %d ���.", fare);
        SendClientMessage(playerid, COLOR_GREEN, fareMessage);
        format(fareMessage, sizeof fareMessage, "[�����] ������� ��������: %d ���. ������� �� �������!", fare);
        SendClientMessage(targetid, COLOR_GREEN, fareMessage);
        VX_TaxiClearDriver(playerid, "[�����] ������� ���������.", true);
        return 1;
    }
    if (CommandMatch(cmdtext, "/taxicancel"))
    {
        if (gTaxiOrderTarget[playerid] != INVALID_PLAYER_ID)
        {
            VX_TaxiClearDriver(playerid, "[�����] �������� ������� �����.", true);
            SendClientMessage(playerid, COLOR_YELLOW, "[�����] �� �������� �����. ������� ������� ������������.");
            return 1;
        }
        if (gTaxiRequestActive[playerid] || gTaxiOrderDriver[playerid] != INVALID_PLAYER_ID)
        {
            VX_TaxiCancelForPlayer(playerid, "[�����] �������� ������� �����.", true);
            return SendClientMessage(playerid, COLOR_YELLOW, "[�����] ��� ����� �������."), 1;
        }
        return SendClientMessage(playerid, COLOR_YELLOW, "[�����] � ��� ��� ��������� ������."), 1;
    }
    if (CommandMatch(cmdtext, "/taxi"))
    {
        if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0)
            return SendClientMessage(playerid, COLOR_YELLOW, "[�����] ������� ������ ����� � �����. ������� �� ���������."), 1;
        if (gTaxiRequestActive[playerid] || gTaxiOrderDriver[playerid] != INVALID_PLAYER_ID)
            return SendClientMessage(playerid, COLOR_YELLOW, "[�����] ����� ��� ������. ������: /taxicancel."), 1;
        new Float:px, Float:py, Float:pz;
        GetPlayerPos(playerid, px, py, pz);
        new drivers = 0;
        for (new d = 0; d < MAX_PLAYERS; d++) if (VX_TaxiOnDuty(d)) drivers++;
        if (drivers == 0) return SendClientMessage(playerid, COLOR_YELLOW, "[�����] ������ ��� ��������� ��������� �� �����. ���������� �����."), 1;
        gTaxiPickupPos[playerid][0] = px; gTaxiPickupPos[playerid][1] = py; gTaxiPickupPos[playerid][2] = pz;
        gTaxiRequestActive[playerid] = true;
        new dispatchMessage[144];
        format(dispatchMessage, sizeof dispatchMessage, "[�����] ����� ����� �� %s (ID %d). �������: /taxiaccept %d", gName[playerid], playerid, playerid);
        for (new d = 0; d < MAX_PLAYERS; d++) if (VX_TaxiOnDuty(d)) SendClientMessage(d, COLOR_YELLOW, dispatchMessage);
        SendClientMessage(playerid, COLOR_GREEN, "[�����] ����� ��������� ���������. �������� ������; ������ � /taxicancel.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/hud"))
    {
        if (!gLogged[playerid]) return SendClientMessage(playerid, COLOR_RED, "������� ������� � �������."), 1;
        gVexHudEnabled[playerid] = !gVexHudEnabled[playerid];
        if (gVexHudEnabled[playerid])
        {
            gVexHudBuildFailed[playerid] = false;
            if (ShowVexHud(playerid)) SendClientMessage(playerid, COLOR_GREEN, "[HUD] ��������� �������. ������� �����: /hudfont.");
        }
        else
        {
            HideVexHud(playerid);
            SendClientMessage(playerid, COLOR_YELLOW, "[HUD] ��������� �����. ��������: /hud.");
        }
        SaveVexHudSettings(playerid);
        return 1;
    }
    if (CommandMatch(cmdtext, "/hudfont"))
    {
        if (!gLogged[playerid]) return SendClientMessage(playerid, COLOR_RED, "������� ������� � �������."), 1;
        new params[32];
        GetParams(cmdtext, params, sizeof params);
        if (!strlen(params)) return ShowVexHudFonts(playerid);
        if (strlen(params) != 1 || params[0] < '1' || params[0] > '9')
            return SendClientMessage(playerid, COLOR_YELLOW, "[HUD] ������� /hudfont ��� /hudfont [1-9]."), 1;
        return SetVexHudFont(playerid, params[0] - '1');
    }

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
        SendClientMessage(playerid, COLOR_YELLOW, "������� /coor �������� ����. ������ [COOR] ����� ����� � chatlog.txt ������� SA-MP.");
        return 1;
    }
    if (!strcmp(cmdtext, "/spawn", true)) return ShowSpawnMenu(playerid), 1;
    if (CommandMatch(cmdtext, "/hub") || CommandMatch(cmdtext, "/menu")) return ShowMainMenu(playerid), 1;
    if (!gLogged[playerid])
    {
        SendClientMessage(playerid, COLOR_RED, "������� ������� � �������.");
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
        format(greeting, sizeof greeting, "������� �����! � %s %s, ��� ��� ���������.", rankName, gName[playerid]);
        format(action, sizeof action, "%s �������: %s", gName[playerid], greeting);
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
            return SendClientMessage(playerid, COLOR_YELLOW, "�������������: /pvp [ID ������]"), 1;
        targetid = strval(token);
        if (targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid) || !gLogged[targetid])
            return SendClientMessage(playerid, COLOR_RED, "����� � ����� ID �� ������."), 1;
        if (targetid == playerid) return SendClientMessage(playerid, COLOR_RED, "������ ������� �� ����� ������ ����."), 1;
        if (gPvpActive[playerid] || gPvpActive[targetid] || gPvpRequestTarget[playerid] != INVALID_PLAYER_ID || gPvpPendingFrom[playerid] != INVALID_PLAYER_ID || gPvpRequestTarget[targetid] != INVALID_PLAYER_ID || gPvpPendingFrom[targetid] != INVALID_PLAYER_ID)
            return SendClientMessage(playerid, COLOR_RED, "���� �� ������� ��� ��������� � ����� ��� ������� �����������."), 1;
        if (GetPlayerInterior(playerid) != GetPlayerInterior(targetid) || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(targetid))
            return SendClientMessage(playerid, COLOR_RED, "�� ������ ���������� ����� � ����� ���������."), 1;
        new Float:tx, Float:ty, Float:tz;
        GetPlayerPos(targetid, tx, ty, tz);
        if (!IsPlayerInRangeOfPoint(playerid, 5.0, tx, ty, tz))
            return SendClientMessage(playerid, COLOR_RED, "��������� � ������ ����� ��� �� 5 ������."), 1;
        if (IsPlayerInAnyVehicle(playerid) || IsPlayerInAnyVehicle(targetid))
            return SendClientMessage(playerid, COLOR_RED, "��� ������ �� ����� ��� ������ ������ ����� �� ����������."), 1;
        gPvpRequestTarget[playerid] = targetid;
        gPvpPendingFrom[targetid] = playerid;
        new pvpMsg[144];
        format(pvpMsg, sizeof pvpMsg, "[PvP] %s �������� ��� �� �����! ������� Y, ����� �������. ������ �� 5 �������, ������ � ������ Desert Eagle.", gName[playerid]);
        SendClientMessage(targetid, COLOR_ORANGE, pvpMsg);
        format(pvpMsg, sizeof pvpMsg, "[PvP] ����������� ���������� ������ %s. �� ������ ������ Y.", gName[targetid]);
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
    if (CommandMatch(cmdtext, "/paydayall") || CommandMatch(cmdtext, "/payday"))
    {
        if (gAdmin[playerid] < 5)
            return SendClientMessage(playerid, COLOR_RED, "������ ��������."), 1;
        SendClientMessageToAll(COLOR_BLUE, "[VEXORIUM] ����������� PayDay! ������� ��������� ���� ������� ������.");
        PayDay();
        SendClientMessage(playerid, COLOR_GREEN, "PayDay ����� ���� �������, ����������� ������.");
        return 1;
    }
    if (gIsJailed[playerid] && strcmp(cmdtext, "/stats", true) != 0 && strcmp(cmdtext, "/help", true) != 0)
    {
        SendClientMessage(playerid, COLOR_RED, "�� � ��� � �� ������ ������������ ��� �������.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/orgmembers"))
    {
        if (gFaction[playerid] == FACTION_NONE) return SendClientMessage(playerid, COLOR_RED, "�� �� �������� � �����������."), 1;
        new factionName[32], line[128], count = 0;
        GetFactionName(gFaction[playerid], factionName, sizeof factionName);
        format(line, sizeof line, "[%s] ���������� ������:", factionName);
        SendClientMessage(playerid, COLOR_YELLOW, line);
        for (new member = 0; member < MAX_PLAYERS; member++)
        {
            if (!IsPlayerConnected(member) || !gLogged[member] || gFaction[member] != gFaction[playerid]) continue;
            format(line, sizeof line, "%s | ID %d | ���� %d", gName[member], member, gFactionRank[member]);
            SendClientMessage(playerid, COLOR_WHITE, line);
            count++;
        }
        if (!count) SendClientMessage(playerid, COLOR_YELLOW, "��� ����������� ������.");
        SendClientMessage(playerid, COLOR_YELLOW, "����������: /orginvite ID, /orgrank ID ����, /orgkick ID, /orgfund.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/orginvite"))
    {
        new params[40], token[16], targetid;
        GetParams(cmdtext, params, sizeof params);
        if (gFaction[playerid] == FACTION_NONE || gFactionRank[playerid] < 8 || !IsInOwnOrgInterior(playerid))
            return SendClientMessage(playerid, COLOR_RED, "��������� ����������� ����� ����������� ����� 8+ � �����."), 1;
        if (!GetToken(params, 0, token, sizeof token)) return SendClientMessage(playerid, COLOR_YELLOW, "�������������: /orginvite ID"), 1;
        targetid = strval(token);
        if (targetid < 0 || targetid >= MAX_PLAYERS || targetid == playerid || !IsPlayerConnected(targetid) || !gLogged[targetid])
            return SendClientMessage(playerid, COLOR_RED, "����� �� ������."), 1;
        if (gFaction[targetid] != FACTION_NONE) return SendClientMessage(playerid, COLOR_RED, "����� ��� ������� � �����������."), 1;
        if (!VX_Near(playerid, targetid, 8.0)) return SendClientMessage(playerid, COLOR_RED, "������������ ����� ������ ������ �����."), 1;
        gOrgInviteFrom[targetid] = playerid;
        new title[96], body[256], factionName[32];
        GetFactionName(gFaction[playerid], factionName, sizeof factionName);
        format(title, sizeof title, "VEXORIUM | ����������� � %s", factionName);
        format(body, sizeof body, "��������� %s ���������� ��� � ����������� %s.\n������� �����������?", gName[playerid], factionName);
        ShowPlayerDialog(targetid, DIALOG_ORG_INVITE, DIALOG_STYLE_MSGBOX, title, body, "�������", "����������");
        SendClientMessage(playerid, COLOR_GREEN, "����������� ����������. ����� ������� ������.");
        SendClientMessage(targetid, COLOR_YELLOW, "���������� ������������: /orgmembers � /orgfund.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/orgrank"))
    {
        new params[48], idText[16], rankText[16], targetid, newRank;
        GetParams(cmdtext, params, sizeof params);
        if (gFaction[playerid] == FACTION_NONE || gFactionRank[playerid] < 9 || !IsInOwnOrgInterior(playerid))
            return SendClientMessage(playerid, COLOR_RED, "�������� � �������� ����� ����� ����������� ����� 9+ � �����."), 1;
        if (!GetToken(params, 0, idText, sizeof idText) || !GetToken(params, 1, rankText, sizeof rankText))
            return SendClientMessage(playerid, COLOR_YELLOW, "�������������: /orgrank ID ����"), 1;
        targetid = strval(idText); newRank = strval(rankText);
        if (targetid < 0 || targetid >= MAX_PLAYERS || targetid == playerid || !IsPlayerConnected(targetid) || !gLogged[targetid])
            return SendClientMessage(playerid, COLOR_RED, "����� �� ������."), 1;
        if (gFaction[targetid] != gFaction[playerid] || gFactionRank[targetid] >= gFactionRank[playerid] || newRank < 1 || newRank >= gFactionRank[playerid] || newRank > 10)
            return SendClientMessage(playerid, COLOR_RED, "������ ������ ���� ��� ����� ����������� ��� ��������� ���� ����/������ ������."), 1;
        gFactionRank[targetid] = newRank;
        SetPlayerSkin(targetid, VX_RespawnSkin(targetid));
        SavePlayer(targetid);
        new m[128]; format(m, sizeof m, "���� ���������� %s ������� �� %d.", gName[targetid], newRank); SendClientMessage(playerid, COLOR_GREEN, m);
        format(m, sizeof m, "��� ���� � ����������� ������� �� %d.", newRank); SendClientMessage(targetid, COLOR_YELLOW, m);
        return 1;
    }
    if (CommandMatch(cmdtext, "/orgkick"))
    {
        new params[32], token[16], targetid;
        GetParams(cmdtext, params, sizeof params);
        if (gFaction[playerid] == FACTION_NONE || gFactionRank[playerid] < 9 || !IsInOwnOrgInterior(playerid))
            return SendClientMessage(playerid, COLOR_RED, "��������� ����� ����������� ����� 9+ � �����."), 1;
        if (!GetToken(params, 0, token, sizeof token)) return SendClientMessage(playerid, COLOR_YELLOW, "�������������: /orgkick ID"), 1;
        targetid = strval(token);
        if (targetid < 0 || targetid >= MAX_PLAYERS || targetid == playerid || !IsPlayerConnected(targetid) || !gLogged[targetid])
            return SendClientMessage(playerid, COLOR_RED, "����� �� ������."), 1;
        if (gFaction[targetid] != gFaction[playerid] || gFactionRank[targetid] >= gFactionRank[playerid])
            return SendClientMessage(playerid, COLOR_RED, "����� ������� ������ ���������� ����� ����������� � ������ ���� ������."), 1;
        gFaction[targetid] = FACTION_NONE; gFactionRank[targetid] = 0; gPoliceCivilianSkin[targetid] = false;
        SetPlayerSkin(targetid, (gVXAccountSkin[targetid] > 0) ? gVXAccountSkin[targetid] : 23);
        SavePlayer(targetid); UpdatePlayerRoleColor(targetid);
        SendClientMessage(playerid, COLOR_GREEN, "��������� ������ �� �����������.");
        SendClientMessage(targetid, COLOR_RED, "�� ������� �� ����������� � ������������.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/orgfund"))
    {
        new params[96], action[20], amountText[20], targetText[16], amount = 0, targetid = INVALID_PLAYER_ID;
        GetParams(cmdtext, params, sizeof params);
        if (gFaction[playerid] == FACTION_NONE || !IsInOwnOrgInterior(playerid))
            return SendClientMessage(playerid, COLOR_RED, "������� �������� ����������� � ����� ����� �����������."), 1;
        if (!GetToken(params, 0, action, sizeof action) || !strcmp(action, "info", true))
        {
            new query[160], DBResult:fr, balance = 0, msg[192], factionName[32];
            format(query, sizeof query, "SELECT money FROM org_stashes WHERE faction_id=%d", gFaction[playerid]);
            fr = db_query(gDatabase, query); if (fr && db_num_rows(fr)) balance = db_get_field_int(fr, 0); if (fr) db_free_result(fr);
            GetFactionName(gFaction[playerid], factionName, sizeof factionName);
            format(msg, sizeof msg, "[%s] ����� �����������: %d ���.", factionName, balance); SendClientMessage(playerid, COLOR_YELLOW, msg);
            SendClientMessage(playerid, COLOR_WHITE, "/orgfund deposit ����� | /orgfund withdraw ����� (���� 8+) | /orgfund pay ID ����� (���� 9+) | /orgfund history");
            return 1;
        }
        if (!strcmp(action, "history", true))
        {
            new query[192], actor[MAX_PLAYER_NAME + 1], target[MAX_PLAYER_NAME + 1], kind[20], line[160], DBResult:fr;
            format(query, sizeof query, "SELECT actor,target,action,amount FROM org_finance_log WHERE faction_id=%d ORDER BY id DESC LIMIT 10", gFaction[playerid]);
            fr = db_query(gDatabase, query);
            if (!fr || !db_num_rows(fr)) { if (fr) db_free_result(fr); return SendClientMessage(playerid, COLOR_YELLOW, "������� �������� ���� �����."), 1; }
            for (new i = 0; i < db_num_rows(fr); i++)
            {
                db_get_field(fr, 0, actor, sizeof actor); db_get_field(fr, 1, target, sizeof target); db_get_field(fr, 2, kind, sizeof kind);
                format(line, sizeof line, "%s: %d ���. | %s -> %s", kind, db_get_field_int(fr, 3), actor, target);
                SendClientMessage(playerid, COLOR_WHITE, line); db_next_row(fr);
            }
            db_free_result(fr); return 1;
        }
        if (!strcmp(action, "deposit", true))
        {
            if (!GetToken(params, 1, amountText, sizeof amountText) || !VX_Number(amountText, amount, MAX_MONEY) || amount < 1 || amount > gMoney[playerid])
                return SendClientMessage(playerid, COLOR_RED, "�������������: /orgfund deposit �����. ��������� ����� � ��������."), 1;
            if (VX_OrgBalance(gFaction[playerid]) > MAX_MONEY - amount)
                return SendClientMessage(playerid, COLOR_RED, "� ����� ��������� ������������ ������. ������ ������ ����� �����."), 1;
            new query[256], cash = gMoney[playerid] - amount;
            if (!VX_Begin()) return VX_Error(playerid);
            format(query, sizeof query, "UPDATE accounts SET money=%d WHERE name='%q'", cash, gName[playerid]); VX_SQL(query);
            format(query, sizeof query, "UPDATE org_stashes SET money=money+%d WHERE faction_id=%d", amount, gFaction[playerid]); VX_SQL(query);
            format(query, sizeof query, "INSERT INTO org_finance_log(faction_id,actor,target,action,amount,created) VALUES(%d,'%q','', 'deposit',%d,%d)", gFaction[playerid], gName[playerid], amount, gettime()); VX_SQL(query);
            if (!VX_Commit()) return VX_Error(playerid);
            VX_MoneySync(playerid, cash, gBankMoney[playerid]); SendClientMessage(playerid, COLOR_GREEN, "����� ����� � ����� �����������."); return 1;
        }
        if (!strcmp(action, "withdraw", true))
        {
            if (gFactionRank[playerid] < 8) return SendClientMessage(playerid, COLOR_RED, "������� ������ �� ����� ����� ������ ����������� ����� 8+."), 1;
            if (!GetToken(params, 1, amountText, sizeof amountText) || !VX_Number(amountText, amount, MAX_MONEY) || amount < 1 || gMoney[playerid] > MAX_MONEY - amount)
                return SendClientMessage(playerid, COLOR_RED, "�������������: /orgfund withdraw �����. ��������� �����."), 1;
            new query[256], DBResult:fr, balance = 0, cash = gMoney[playerid] + amount;
            format(query, sizeof query, "SELECT money FROM org_stashes WHERE faction_id=%d", gFaction[playerid]); fr = db_query(gDatabase, query);
            if (fr && db_num_rows(fr)) balance = db_get_field_int(fr, 0); if (fr) db_free_result(fr);
            if (balance < amount) return SendClientMessage(playerid, COLOR_RED, "� ����� ����������� ������������ �������."), 1;
            if (!VX_Begin()) return VX_Error(playerid);
            format(query, sizeof query, "UPDATE org_stashes SET money=money-%d WHERE faction_id=%d AND money >= %d", amount, gFaction[playerid], amount); VX_SQL(query);
            format(query, sizeof query, "UPDATE accounts SET money=%d WHERE name='%q'", cash, gName[playerid]); VX_SQL(query);
            format(query, sizeof query, "INSERT INTO org_finance_log(faction_id,actor,target,action,amount,created) VALUES(%d,'%q','', 'withdraw',%d,%d)", gFaction[playerid], gName[playerid], amount, gettime()); VX_SQL(query);
            if (!VX_Commit()) return VX_Error(playerid);
            VX_MoneySync(playerid, cash, gBankMoney[playerid]); SendClientMessage(playerid, COLOR_GREEN, "������ ������ �� ����� �����������."); return 1;
        }
        if (!strcmp(action, "pay", true))
        {
            if (gFactionRank[playerid] < 9) return SendClientMessage(playerid, COLOR_RED, "����������� ������ ����� ������ ����������� ����� 9+."), 1;
            if (!GetToken(params, 1, targetText, sizeof targetText) || !GetToken(params, 2, amountText, sizeof amountText) || !VX_Number(amountText, amount, MAX_MONEY) || amount < 1)
                return SendClientMessage(playerid, COLOR_YELLOW, "�������������: /orgfund pay ID �����"), 1;
            targetid = strval(targetText);
            if (targetid < 0 || targetid >= MAX_PLAYERS || targetid == playerid || !IsPlayerConnected(targetid) || !gLogged[targetid] || gFaction[targetid] != gFaction[playerid])
                return SendClientMessage(playerid, COLOR_RED, "���������� ������ ���� ������ � �������� � ����� �����������."), 1;
            if (gFactionRank[targetid] >= gFactionRank[playerid] || gMoney[targetid] > MAX_MONEY - amount)
                return SendClientMessage(playerid, COLOR_RED, "������ ������� ���������� � ������/������ ������ ��� ��������� ����� ��������."), 1;
            new query[256], DBResult:fr, balance = 0, targetCash = gMoney[targetid] + amount;
            format(query, sizeof query, "SELECT money FROM org_stashes WHERE faction_id=%d", gFaction[playerid]); fr = db_query(gDatabase, query);
            if (fr && db_num_rows(fr)) balance = db_get_field_int(fr, 0); if (fr) db_free_result(fr);
            if (balance < amount) return SendClientMessage(playerid, COLOR_RED, "� ����� ����������� ������������ �������."), 1;
            if (!VX_Begin()) return VX_Error(playerid);
            format(query, sizeof query, "UPDATE org_stashes SET money=money-%d WHERE faction_id=%d AND money >= %d", amount, gFaction[playerid], amount); VX_SQL(query);
            format(query, sizeof query, "UPDATE accounts SET money=%d WHERE name='%q'", targetCash, gName[targetid]); VX_SQL(query);
            format(query, sizeof query, "INSERT INTO org_finance_log(faction_id,actor,target,action,amount,created) VALUES(%d,'%q','%q','pay',%d,%d)", gFaction[playerid], gName[playerid], gName[targetid], amount, gettime()); VX_SQL(query);
            if (!VX_Commit()) return VX_Error(playerid);
            VX_MoneySync(targetid, targetCash, gBankMoney[targetid]);
            new payMsg[128]; format(payMsg, sizeof payMsg, "����������� ��������� ��� ������: %d ���.", amount); SendClientMessage(targetid, COLOR_GREEN, payMsg);
            SendClientMessage(playerid, COLOR_GREEN, "������ ��������� �� ����� �����������."); return 1;
        }
        return SendClientMessage(playerid, COLOR_YELLOW, "�������: /orgfund, /orgfund deposit, withdraw, pay, history."), 1;
    }
    if (CommandMatch(cmdtext, "/contract"))
    {
        new params[160], idText[16], amountText[20], rawPurpose[96], purpose[80], targetid, amount = 0;
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, idText, sizeof idText) || !GetToken(params, 1, amountText, sizeof amountText))
            return SendClientMessage(playerid, COLOR_YELLOW, "�������������: /contract ID ����� ��������"), 1;
        targetid = strval(idText);
        if (targetid < 0 || targetid >= MAX_PLAYERS || targetid == playerid || !IsPlayerConnected(targetid) || !gLogged[targetid])
            return SendClientMessage(playerid, COLOR_RED, "����� �� ������."), 1;
        if (!VX_Near(playerid, targetid, 4.0)) return SendClientMessage(playerid, COLOR_RED, "��� ���������� �������� ��������� � ������ ����� (�� 4 ������)."), 1;
        if (!VX_Number(amountText, amount, 10000000) || amount < 1) return SendClientMessage(playerid, COLOR_RED, "����� �������� ������ ���� �� 1 �� 10000000 ���."), 1;
        VX_GetTailAfterTokens(params, 2, rawPurpose, sizeof rawPurpose);
        VX_CleanText(rawPurpose, purpose, sizeof purpose);
        if (!strlen(purpose)) return SendClientMessage(playerid, COLOR_YELLOW, "�������� ���������� ��������, ��������: ������ �������."), 1;
        return VX_ContractCreate(playerid, targetid, amount, purpose);
    }
    if (CommandMatch(cmdtext, "/contracts")) return VX_ContractList(playerid);
    if (CommandMatch(cmdtext, "/contractaccept") || CommandMatch(cmdtext, "/contractreject") || CommandMatch(cmdtext, "/contractcancel"))
    {
        new params[32], token[16], contractId;
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, token, sizeof token) || !VX_Number(token, contractId, 2000000000) || contractId < 1)
            return SendClientMessage(playerid, COLOR_YELLOW, "�������������: /contractaccept ID, /contractreject ID ��� /contractcancel ID"), 1;
        if (CommandMatch(cmdtext, "/contractaccept")) return VX_ContractResolve(playerid, contractId, 1);
        if (CommandMatch(cmdtext, "/contractreject")) return VX_ContractResolve(playerid, contractId, 2);
        return VX_ContractResolve(playerid, contractId, 3);
    }
    if (CommandMatch(cmdtext, "/needs"))
    {
        new msg[192];
        format(msg, sizeof msg, "[���������] �������: %d/100 | ����: %d/100 | �������: %d/100", gHunger[playerid], gThirst[playerid], gEnergy[playerid]);
        SendClientMessage(playerid, COLOR_YELLOW, msg);
        SendClientMessage(playerid, COLOR_WHITE, "��� � ���� � ��������� ��������������� ����������. � ���� ���� ����������� /rest.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/rest"))
    {
        if (gCurrentHouse[playerid] < 1 || GetPlayerInterior(playerid) != 1 || GetPlayerVirtualWorld(playerid) != gCurrentHouse[playerid])
            return SendClientMessage(playerid, COLOR_RED, "��������� ����� ������ � ����������� ����."), 1;
        if (gLastRestTick[playerid] && gettime() - gLastRestTick[playerid] < 60)
            return SendClientMessage(playerid, COLOR_YELLOW, "�� ������� ��������. ���������� ����� ������."), 1;
        gLastRestTick[playerid] = gettime();
        gEnergy[playerid] = VexHudClamp(gEnergy[playerid] + 35, 0, 100);
        ApplyAnimation(playerid, "BEACH", "ParkSit_M_loop", 4.1, 0, 0, 0, 0, 5000, 1);
        VX_NeedsSave(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "�� ������� ���������. ������� ������������� �� 35 �������.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/pass") || CommandMatch(cmdtext, "/passport") || CommandMatch(cmdtext, "/pasport") || CommandMatch(cmdtext, "/docs") || CommandMatch(cmdtext, "/mydocs"))
    {
        new factionName[32], doc[192], passportStatus[8], driverStatus[8], weaponStatus[8], boatStatus[8], airStatus[8];
        GetFactionName(gFaction[playerid], factionName, sizeof factionName);
        format(doc, sizeof doc, "[%s] ID: %d | �������: %d | �����������: %s", gName[playerid], playerid, gLevel[playerid], factionName);
        SendClientMessage(playerid, COLOR_YELLOW, doc);
        if (gHasPassport[playerid]) format(passportStatus, sizeof passportStatus, "����"); else format(passportStatus, sizeof passportStatus, "���");
        if (gLicenseDriver[playerid]) format(driverStatus, sizeof driverStatus, "����"); else format(driverStatus, sizeof driverStatus, "���");
        format(doc, sizeof doc, "�������: %s | ������������ �����: %s", passportStatus, driverStatus);
        SendClientMessage(playerid, COLOR_BLUE, doc);
        if (gLicenseWeapon[playerid]) format(weaponStatus, sizeof weaponStatus, "����"); else format(weaponStatus, sizeof weaponStatus, "���");
        if (gLicenseBoat[playerid]) format(boatStatus, sizeof boatStatus, "����"); else format(boatStatus, sizeof boatStatus, "���");
        if (gLicenseAir[playerid]) format(airStatus, sizeof airStatus, "����"); else format(airStatus, sizeof airStatus, "���");
        format(doc, sizeof doc, "��������: ������ %s | ����� %s | ������ %s", weaponStatus, boatStatus, airStatus);
        SendClientMessage(playerid, COLOR_BLUE, doc);
        SendClientMessage(playerid, COLOR_YELLOW, "�������� �������: �����. ���������: ��������� /autoschool. ������� /showdocs ID ���������� ��������� ����� �������� ������.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/showdocs"))
    {
        new params[48], token[16], targetid, factionName[32], doc[192], passportStatus[8], driverStatus[8];
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, token, sizeof token)) return SendClientMessage(playerid, COLOR_YELLOW, "�������������: /showdocs ID"), 1;
        targetid = strval(token);
        if (targetid < 0 || targetid >= MAX_PLAYERS || targetid == playerid || !IsPlayerConnected(targetid) || !gLogged[targetid])
            return SendClientMessage(playerid, COLOR_RED, "����� �� ������."), 1;
        if (!VX_Near(playerid, targetid, 4.0)) return SendClientMessage(playerid, COLOR_RED, "����� ������ ������ ����� (�� 4 ������)."), 1;
        GetFactionName(gFaction[playerid], factionName, sizeof factionName);
        format(doc, sizeof doc, "[���������] %s | ID: %d | ��.: %d | %s", gName[playerid], playerid, gLevel[playerid], factionName);
        SendClientMessage(targetid, COLOR_YELLOW, doc);
        if (gHasPassport[playerid]) format(passportStatus, sizeof passportStatus, "����"); else format(passportStatus, sizeof passportStatus, "���");
        if (gLicenseDriver[playerid]) format(driverStatus, sizeof driverStatus, "����"); else format(driverStatus, sizeof driverStatus, "���");
        format(doc, sizeof doc, "�������: %s | ������������ �����: %s", passportStatus, driverStatus);
        SendClientMessage(targetid, COLOR_BLUE, doc);
        format(doc, sizeof doc, "%s ������� ��� ���������.", gName[playerid]);
        SendClientMessage(targetid, COLOR_YELLOW, doc);
        SendClientMessage(playerid, COLOR_GREEN, "�� �������� ��������� ������.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/showpass") || CommandMatch(cmdtext, "/checkpass"))
    {
        new params[64], token[24], targetid, factionName[32], doc[192];
        if (gFaction[playerid] != FACTION_POLICE || gFactionRank[playerid] < 1)
            return SendClientMessage(playerid, COLOR_RED, "����������� ������� ����� ������ ��������� �������."), 1;
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, token, sizeof token))
            return SendClientMessage(playerid, COLOR_YELLOW, "�������������: /showpass [ID]"), 1;
        targetid = strval(token);
        if (targetid < 0 || targetid >= MAX_PLAYERS || targetid == playerid || !IsPlayerConnected(targetid) || !gLogged[targetid])
            return SendClientMessage(playerid, COLOR_RED, "����� �� ������."), 1;
        new Float:px, Float:py, Float:pz;
        GetPlayerPos(playerid, px, py, pz);
        if (GetPlayerInterior(playerid) != GetPlayerInterior(targetid) || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(targetid) || !IsPlayerInRangeOfPoint(targetid, 4.0, px, py, pz))
            return SendClientMessage(playerid, COLOR_RED, "����� ������ ���������� ����� � ���� (�� 4 ������)."), 1;
        GetFactionName(gFaction[targetid], factionName, sizeof factionName);
        format(doc, sizeof doc, "[�������] %s | ID: %d | �������: %d | �����������: %s", gName[targetid], targetid, gLevel[targetid], factionName);
        SendClientMessage(playerid, COLOR_BLUE, doc);
        format(doc, sizeof doc, "��������� ������� %s �������� ��� �������.", gName[playerid]);
        SendClientMessage(targetid, COLOR_YELLOW, doc);
        return 1;
    }
    if (CommandMatch(cmdtext, "/lic") || CommandMatch(cmdtext, "/licenses") || CommandMatch(cmdtext, "/licences"))
    {
        if (gLicenseDriver[playerid]) SendClientMessage(playerid, COLOR_BLUE, "[��������] ����: ����");
        else SendClientMessage(playerid, COLOR_BLUE, "[��������] ����: ���");
        if (gLicenseWeapon[playerid]) SendClientMessage(playerid, COLOR_BLUE, "[��������] ������: ����");
        else SendClientMessage(playerid, COLOR_BLUE, "[��������] ������: ���");
        if (gLicenseBoat[playerid]) SendClientMessage(playerid, COLOR_BLUE, "�����: ����");
        else SendClientMessage(playerid, COLOR_BLUE, "�����: ���");
        if (gLicenseAir[playerid]) SendClientMessage(playerid, COLOR_BLUE, "������: ����");
        else SendClientMessage(playerid, COLOR_BLUE, "������: ���");
        SendClientMessage(playerid, COLOR_YELLOW, "������� ����-��������: ��������� /autoschool. ��������� �������� � � ����� ����� /licbuy.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/autoschool"))
    {
        if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0 || !IsPlayerInRangeOfPoint(playerid, 4.0, -2026.8, -96.5, 35.2))
            return SendClientMessage(playerid, COLOR_YELLOW, "��������� � ����������� ��������� � ���-������."), 1;
        if (gLicenseDriver[playerid]) return SendClientMessage(playerid, COLOR_GREEN, "� ��� ��� ���� ������������ �����."), 1;
        ShowPlayerDialog(playerid, DIALOG_AUTOSCHOOL, DIALOG_STYLE_MSGBOX, "VEXORIUM | ���������", "��������� ������� ���������� � �������� ������� �� 6 ����������� �����.\n��������� ��������: 15000 ������ ����� �������� �����.", "������", "������");
        return 1;
    }
    if (CommandMatch(cmdtext, "/licadmin"))
    {
        if (gAdmin[playerid] < 1) return SendClientMessage(playerid, COLOR_RED, "������� �������� ������ ���������������."), 1;
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
        SendClientMessage(playerid, COLOR_GREEN, "�������� ������ ������ ��������� � ���������." );
        return 1;
    }
    if (CommandMatch(cmdtext, "/licbuy"))
    {
        new params[32], token[16], price, licenseType;
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, token, sizeof token))
            return SendClientMessage(playerid, COLOR_YELLOW, "�������������: /licbuy auto|weapon|boat|air"), 1;
        if (!strcmp(token, "auto", true))
        {
            if (GetPlayerInterior(playerid) != 3 || GetPlayerVirtualWorld(playerid) != 101 || !IsPlayerInRangeOfPoint(playerid, 5.0, 362.4587, 174.0056, 1008.3828))
                return SendClientMessage(playerid, COLOR_RED, "��������� � ������ �������� � �����."), 1;
            if (gLicenseDriver[playerid]) return SendClientMessage(playerid, COLOR_GREEN, "� ��� ��� ���� ������������ �����."), 1;
            if (!gDrivingExamPassed[playerid]) return SendClientMessage(playerid, COLOR_RED, "������� ������ ������� � ���������."), 1;
            gLicenseDriver[playerid] = 1;
            gDrivingExamPassed[playerid] = 0;
            SavePlayer(playerid);
            SendClientMessage(playerid, COLOR_GREEN, "������������ ����� ������ ���������: ������ ��� �������� � �������.");
            return 1;
        }
        else if (!strcmp(token, "weapon", true))
        {
            if (GetPlayerInterior(playerid) != 3 || GetPlayerVirtualWorld(playerid) != 101 || !IsPlayerInRangeOfPoint(playerid, 5.0, 392.0, 175.0, 1008.4)) return SendClientMessage(playerid, COLOR_RED, "�������� �������� � �����. ��������� � ������ �����."), 1;
            licenseType = 2; price = 30000;
            if (gLicenseWeapon[playerid]) return SendClientMessage(playerid, COLOR_GREEN, "� ��� ��� ���� �������� �� ������."), 1;
        }
        else if (!strcmp(token, "boat", true))
        {
            if (GetPlayerInterior(playerid) != 3 || GetPlayerVirtualWorld(playerid) != 101 || !IsPlayerInRangeOfPoint(playerid, 5.0, 392.0, 175.0, 1008.4)) return SendClientMessage(playerid, COLOR_RED, "�������� �������� � �����. ��������� � ������ �����."), 1;
            licenseType = 3; price = 20000;
            if (gLicenseBoat[playerid]) return SendClientMessage(playerid, COLOR_GREEN, "� ��� ��� ���� �������� �� �����."), 1;
        }
        else if (!strcmp(token, "air", true))
        {
            if (GetPlayerInterior(playerid) != 3 || GetPlayerVirtualWorld(playerid) != 101 || !IsPlayerInRangeOfPoint(playerid, 5.0, 392.0, 175.0, 1008.4)) return SendClientMessage(playerid, COLOR_RED, "�������� �������� � �����. ��������� � ������ �����."), 1;
            licenseType = 4; price = 40000;
            if (gLicenseAir[playerid]) return SendClientMessage(playerid, COLOR_GREEN, "� ��� ��� ���� �������� �� ������."), 1;
        }
        else return SendClientMessage(playerid, COLOR_YELLOW, "���� ��������: auto, weapon, boat, air."), 1;
        if (gMoney[playerid] < price) return SendClientMessage(playerid, COLOR_RED, "������������ �������� ��� ������� ��������."), 1;
        gMoney[playerid] -= price;
        if (licenseType == 1) gLicenseDriver[playerid] = 1;
        else if (licenseType == 2) gLicenseWeapon[playerid] = 1;
        else if (licenseType == 3) gLicenseBoat[playerid] = 1;
        else if (licenseType == 4) gLicenseAir[playerid] = 1;
        ResetPlayerMoney(playerid); GivePlayerMoney(playerid, gMoney[playerid]);
        SavePlayer(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "�����������! �������� ������ � ��������� � ����� ��������.");
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
            return SendClientMessage(playerid, COLOR_RED, "�������� �������� �� ������� ����� ������ ���������� �����."), 1;
        new params[64], idToken[16], typeToken[16], targetid, price, licenseType;
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, idToken, sizeof idToken) || !GetToken(params, 1, typeToken, sizeof typeToken))
            return SendClientMessage(playerid, COLOR_YELLOW, "�������������: /licgive [ID] auto|weapon|boat|air"), 1;
        targetid = strval(idToken);
        if (targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid) || !gLogged[targetid]) return SendClientMessage(playerid, COLOR_RED, "����� �� ������ ��� �� �����������."), 1;
        new Float:tx, Float:ty, Float:tz;
        GetPlayerPos(playerid, tx, ty, tz);
        if (GetPlayerInterior(playerid) != GetPlayerInterior(targetid) || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(targetid) || !IsPlayerInRangeOfPoint(targetid, 4.0, tx, ty, tz)) return SendClientMessage(playerid, COLOR_RED, "����� ������ ���������� ����� � ���� (�� 4 ������)."), 1;
        if (!strcmp(typeToken, "auto", true)) { licenseType = 1; price = 10000; if (gLicenseDriver[targetid]) return SendClientMessage(playerid, COLOR_RED, "� ������ ��� ���� �������� �� ����."), 1; }
        else if (!strcmp(typeToken, "weapon", true)) { licenseType = 2; price = 20000; if (gLicenseWeapon[targetid]) return SendClientMessage(playerid, COLOR_RED, "� ������ ��� ���� �������� �� ������."), 1; }
        else if (!strcmp(typeToken, "boat", true)) { licenseType = 3; price = 12000; if (gLicenseBoat[targetid]) return SendClientMessage(playerid, COLOR_RED, "� ������ ��� ���� �������� �� �����."), 1; }
        else if (!strcmp(typeToken, "air", true)) { licenseType = 4; price = 25000; if (gLicenseAir[targetid]) return SendClientMessage(playerid, COLOR_RED, "� ������ ��� ���� �������� �� ������."), 1; }
        else return SendClientMessage(playerid, COLOR_YELLOW, "���� ��������: auto, weapon, boat, air."), 1;
        if (gMoney[targetid] < price) return SendClientMessage(playerid, COLOR_RED, "� ������ ������������ ��������."), 1;
        gMoney[targetid] -= price;
        if (licenseType == 1) gLicenseDriver[targetid] = 1;
        else if (licenseType == 2) gLicenseWeapon[targetid] = 1;
        else if (licenseType == 3) gLicenseBoat[targetid] = 1;
        else if (licenseType == 4) gLicenseAir[targetid] = 1;
        ResetPlayerMoney(targetid); GivePlayerMoney(targetid, gMoney[targetid]);
        SavePlayer(targetid);
        SendClientMessage(targetid, COLOR_GREEN, "��������� ����� ����� ��� �������� �� �������� ����.");
        SendClientMessage(playerid, COLOR_GREEN, "�������� ��������� �� �������� ���� � ���������.");
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
    if (!strcmp(cmdtext, "/mm", true) || !strcmp(cmdtext, "/menu", true) || !strcmp(cmdtext, "/����", true))
    {
        ShowMainMenu(playerid);
        return 1;
    }
    if (!strcmp(cmdtext, "/help", true) || !strcmp(cmdtext, "/������", true))
    {
        new helpText[2048];
        helpText[0] = '\0';
        strcat(helpText, "/hud - ��������/������ HUD\n/hudfont - ������� ����� HUD\n");
        strcat(helpText, "/mm � ������� ���� �������\n/gps � GPS �� ������\n");
        strcat(helpText, "/job � ������� ������ (�����/������������/�������/�����)\n");
        strcat(helpText, "/work � ������ ������� �������\n/stopwork � �������� �������\n/inv � ���������\n/balance � ������\n");
        strcat(helpText, "/pay [ID] [�����] � �������� ������\n/stats � ����������\n/leaders � ������ �����������\n");
        strcat(helpText, "/enterpd � ����� � �������, /org � ���� �����������, /exitpd � �����\n������ ������ � ���������� � ����� �� �����\n/arrest [ID] [�������] [�������], /release [ID]\n");
        strcat(helpText, "/me [��������] � RP-��������\n/do [��������] � RP-��������\n/n [�����] � OOC-��� �����\n");
        strcat(helpText, "/r [�����] � ����� �������\n/rn [�����] � OOC-��� �������\n/rules � ������� �������\n/save � ��������� ��������\n");
        strcat(helpText, "�������: /showpass [ID] � ��������� �������, /search [ID] � RP-����� �����\n");
        strcat(helpText, "/carshop � ���������, /mycar � ������ ������, /fuel � ��������\n");
        strcat(helpText, "/docs � ���� ���������, /showdocs [ID] � �������� �� ������ �����\n");
        strcat(helpText, "/autoschool � ������ ������� ����� � ������������; /licbuy auto � �������� ����� ����� �����\n");
        strcat(helpText, "/needs � �������, ���� � �������; /rest � ������������ ������� � ���� ����\n");
        strcat(helpText, "/orgmembers � ���������� ������, /orginvite ID � ������� ���������� (���� 8+)\n");
        strcat(helpText, "/orgrank ID ����, /orgkick ID � ���������� ������������ (���� 9+)\n");
        strcat(helpText, "/orgfund � �����, /orgfund deposit �����, withdraw �����, pay ID �����, history\n");
        strcat(helpText, "/contract ID ����� �������� � ������� � �������; /contracts � ������ ���������\n");
        strcat(helpText, "/contractaccept ID, /contractreject ID, /contractcancel ID � ���������� ����������\n\n");
        strcat(helpText, "��������������: /gps (��������), /tp [ID], /gethere [ID], /tpcar [ID],\n");
        strcat(helpText, "/setadmin [ID] [�������], /setmoney [ID] [�����],\n");
        strcat(helpText, "/setfaction [ID] [0-6] [���� 0-10], /uniform [ID] [1-3], /kick [ID] �������, /ban [ID] ������ �������, /a [�����]");
        strcat(helpText, "\n/adminhelp � ������� � ������ �������������, /spec ID � ���������� � ���� ��������");
        ShowPlayerDialog(playerid, DIALOG_HELP, DIALOG_STYLE_MSGBOX, "VEXORIUM RP | �������", helpText, "�������", "");
        return 1;
    }
    if (CommandMatch(cmdtext, "/me"))
    {
        new params[128], msg[192]; GetParams(cmdtext, params, sizeof params);
        if (!strlen(params)) return SendClientMessage(playerid, COLOR_YELLOW, "�������������: /me [��������]"), 1;
        format(msg, sizeof msg, "* %s %s", gName[playerid], params);
        SendLocalMessage(playerid, COLOR_PINK, msg, 20.0); return 1;
    }
    if (CommandMatch(cmdtext, "/do"))
    {
        new params[128], msg[192]; GetParams(cmdtext, params, sizeof params);
        if (!strlen(params)) return SendClientMessage(playerid, COLOR_YELLOW, "�������������: /do [��������]"), 1;
        format(msg, sizeof msg, "* %s (( %s ))", params, gName[playerid]);
        SendLocalMessage(playerid, COLOR_BLUE, msg, 20.0); return 1;
    }
    if (CommandMatch(cmdtext, "/try"))
    {
        new params[128], msg[192]; GetParams(cmdtext, params, sizeof params);
        if (!strlen(params)) return SendClientMessage(playerid, COLOR_YELLOW, "�������������: /try [��������]"), 1;
        if (random(2) == 0) format(msg, sizeof msg, "* %s %s | �������", gName[playerid], params);
        else format(msg, sizeof msg, "* %s %s | ��������", gName[playerid], params);
        SendLocalMessage(playerid, COLOR_ORANGE, msg, 20.0);
        return 1;
    }
    if (CommandMatch(cmdtext, "/n") || CommandMatch(cmdtext, "/b"))
    {
        new params[128], msg[192]; GetParams(cmdtext, params, sizeof params);
        if (!strlen(params)) return SendClientMessage(playerid, COLOR_YELLOW, "�������������: /n [�����]"), 1;
        format(msg, sizeof msg, "(( %s: %s ))", gName[playerid], params);
        SendLocalMessage(playerid, COLOR_WHITE, msg, 20.0); return 1;
    }
    if (CommandMatch(cmdtext, "/r") || CommandMatch(cmdtext, "/f"))
    {
        new params[128], msg[192]; GetParams(cmdtext, params, sizeof params);
        if (gFaction[playerid] == FACTION_NONE) return SendClientMessage(playerid, COLOR_RED, "�� �� �������� � �����������."), 1;
        if (!strlen(params)) return SendClientMessage(playerid, COLOR_YELLOW, "�������������: /r [��������� �������]"), 1;
        format(msg, sizeof msg, "[�����] %s: %s", gName[playerid], params);
        for (new i = 0; i < MAX_PLAYERS; i++) if (IsPlayerConnected(i) && gLogged[i] && gFaction[i] == gFaction[playerid]) SendClientMessage(i, COLOR_BLUE, msg);
        return 1;
    }
    if (CommandMatch(cmdtext, "/rn"))
    {
        new params[128], msg[192]; GetParams(cmdtext, params, sizeof params);
        if (gFaction[playerid] == FACTION_NONE) return SendClientMessage(playerid, COLOR_RED, "�� �� �������� � �����������."), 1;
        if (!strlen(params)) return SendClientMessage(playerid, COLOR_YELLOW, "�������������: /rn [OOC ��������� �������]"), 1;
        format(msg, sizeof msg, "(( [������� OOC] %s: %s ))", gName[playerid], params);
        for (new i = 0; i < MAX_PLAYERS; i++) if (IsPlayerConnected(i) && gLogged[i] && gFaction[i] == gFaction[playerid]) SendClientMessage(i, COLOR_WHITE, msg);
        return 1;
    }
    if (CommandMatch(cmdtext, "/rent") || CommandMatch(cmdtext, "/rentscooter"))
    {
        if (!gLogged[playerid]) return SendClientMessage(playerid, COLOR_RED, "������� ������� � �������."), 1;
        if (gLevel[playerid] > 3) return SendClientMessage(playerid, COLOR_RED, "������ ������� �������� ������ ������� 1�3 ������."), 1;
        if (gFaction[playerid] != FACTION_NONE) return SendClientMessage(playerid, COLOR_YELLOW, "������ �� ��������� ���� �������� �������� ��� �����������."), 1;
        if (!IsPlayerInRangeOfPoint(playerid, 20.0, 1764.0, -1898.0, 13.2))
            return SendClientMessage(playerid, COLOR_YELLOW, "��������� � ������� �� ���� �������� � �������."), 1;
        if (gRentalVehicle[playerid] != INVALID_VEHICLE_ID)
            return SendClientMessage(playerid, COLOR_YELLOW, "� ��� ��� ���� ������������ ������."), 1;
        if (gBaseScooter != INVALID_VEHICLE_ID)
            return SendClientMessage(playerid, COLOR_YELLOW, "������ �� ������ � ������� � �������� ����������� ������."), 1;
        SpawnBaseScooter();
        return SendClientMessage(playerid, COLOR_GREEN, "������ ����� �������� �� ����. ������ �� ����, ����� ����������."), 1;
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
            return SendClientMessage(playerid, COLOR_RED, "�� �� �������� � �����������."), 1;
        if (!IsInOwnOrgInterior(playerid))
            return SendClientMessage(playerid, COLOR_YELLOW, "������� ������� ����� ������ � ����� ������ �����, ����� ������� /org."), 1;
        if (gFaction[playerid] == FACTION_POLICE) ShowPoliceMenu(playerid);
        else ShowOrgMenu(playerid);
        return 1;
    }
    if (CommandMatch(cmdtext, "/exitorg"))
    {
        if (gFaction[playerid] == FACTION_NONE || !IsInOwnOrgInterior(playerid))
            return SendClientMessage(playerid, COLOR_RED, "�� �� ���������� � ����� ����� �����������."), 1;
        new Float:x, Float:y, Float:z;
        GetOrgExterior(gFaction[playerid], x, y, z);
        SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
        if (gFaction[playerid] == FACTION_FBI)
        {
            SetPlayerPos(playerid, 1642.0, -2251.0, 13.5);
            SetPlayerFacingAngle(playerid, 310.92);
        }
        else
        {
            SetPlayerPos(playerid, x + 2.0, y, z);
            SetPlayerFacingAngle(playerid, 90.0);
        }
        SetCameraBehindPlayer(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "�� ����� �� ������ �����������.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/orggarage"))
    {
        if (gFaction[playerid] == FACTION_NONE || gFactionRank[playerid] < 1)
            return SendClientMessage(playerid, COLOR_RED, "�� �� �������� � �����������."), 1;
        if (!IsInOwnOrgInterior(playerid))
            return SendClientMessage(playerid, COLOR_YELLOW, "������� �������� ������� ����� ����� �����������."), 1;
        new Float:x, Float:y, Float:z;
        GetOrgGarage(gFaction[playerid], x, y, z);
        SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
        SetPlayerPos(playerid, x - 1.5, y - 2.5, z); SetPlayerFacingAngle(playerid, 90.0);
        SetCameraBehindPlayer(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "�� ����� � ��������� ����� �����������. ����������� /garage ��� ���������� ����������.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/formation") || CommandMatch(cmdtext, "/formup"))
    {
        if (gFaction[playerid] == FACTION_NONE || gFactionRank[playerid] < 6)
            return SendClientMessage(playerid, COLOR_RED, "���������� ����� �������� ��������� ����������� � 6-�� �����."), 1;
        if (!IsInOwnOrgInterior(playerid))
            return SendClientMessage(playerid, COLOR_YELLOW, "��������� ���������� ����� �� ����� ����� �����������."), 1;
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
            SendClientMessage(i, COLOR_YELLOW, "��� ���������. �������� ������������ �����������.");
        }
        format(msg, sizeof msg, "[����������] %s: ���������� ���������. ����������� �������: %d.", factionName, count + 1);
        SendClientMessage(playerid, COLOR_GREEN, msg);
        return 1;
    }
    if (CommandMatch(cmdtext, "/garage"))
    {
        if (gFaction[playerid] == FACTION_NONE || gFactionRank[playerid] < 1)
            return SendClientMessage(playerid, COLOR_RED, "�� �� �������� � �����������."), 1;
        new Float:gx, Float:gy, Float:gz, menu[512], line[80], factionName[32], dialogTitle[64];
        GetOrgGarage(gFaction[playerid], gx, gy, gz);
        if (gFaction[playerid] == FACTION_POLICE)
        {
            if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0 ||
                !IsPlayerInRangeOfPoint(playerid, 10.0, 1579.0, -1719.0, 13.5))
                return VX_GarageRoute(playerid);
        }
        else if(GetPlayerInterior(playerid)!=0 || GetPlayerVirtualWorld(playerid)!=0
            || !IsPlayerInRangeOfPoint(playerid, 10.0, gx, gy, gz))
            return VX_GarageRoute(playerid);
        VX_GarageRouteClear(playerid);
        if (IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_YELLOW, "������� ������� �� �������� ����������."), 1;
        GetFactionName(gFaction[playerid], factionName, sizeof factionName);
        menu[0] = '\0';
        format(dialogTitle, sizeof dialogTitle, "%s | ���� %d", factionName, gFactionRank[playerid]);
        new count = 0, modelName[48];
        for (new tier = 0; tier < 5; tier++)
        {
            if (gFactionRank[playerid] < (tier * 2 + 1)) continue;
            GetFactionVehicleInfo(gFaction[playerid], tier, modelName, sizeof modelName);
            new listedSpeed = GetFactionVehicleSpeedLimitKmh(gFaction[playerid], tier);
            if (listedSpeed > 0)
                format(line, sizeof line, "%s - %d km/h\n", modelName, listedSpeed);
            else
                format(line, sizeof line, "%s\n", modelName);
            strcat(menu, line, sizeof menu);
            count++;
        }
        if (count == 0) return SendClientMessage(playerid, COLOR_RED, "� ��� ��������� ����� ��� ���������."), 1;
        ShowPlayerDialog(playerid, DIALOG_FACTION_GARAGE, DIALOG_STYLE_LIST, dialogTitle, menu, "�������", "�������");
        return 1;
    }
    if (CommandMatch(cmdtext, "/shopacc"))
    {
        // Phone-style accessories app: available anywhere, no Los Santos location check.
        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
        new shopText[512];
        shopText[0] = '\0';
        strcat(shopText, "�������� | ������ ���� - 1 500 ���.\n");
        strcat(shopText, "�������� | ������� ����� - 2 500 ���.\n");
        strcat(shopText, "�������� | �����-���� - 3 500 ���.\n");
        strcat(shopText, "����� | ���������� ����� - 7 500 ���.\n");
        strcat(shopText, "����� | ��������� ����� - 9 000 ���.\n");
        strcat(shopText, "������� | ������� ���� - 15 000 ���.\n");
        strcat(shopText, "������� | ������������ ����� - 22 000 ���.\n");
        strcat(shopText, "����� | ��������� ����� - 35 000 ���.\n");
        strcat(shopText, "����� | ������������� ����� - 55 000 ���.\n");
        strcat(shopText, "VIP | ����������� ��������� - 85 000 ���.\n");
        strcat(shopText, "�������� /inv, ����� ������ ��� �����");
        ShowPlayerDialog(playerid, DIALOG_SHOP_ACC, DIALOG_STYLE_LIST, "VEXORIUM | ������� �����������", shopText, "�������", "�������");
        return 1;
    }
    if (CommandMatch(cmdtext, "/carshop"))
    {
        if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0 || !IsPlayerInRangeOfPoint(playerid, 18.0, 2131.0, -1150.0, 24.1))
            return SendClientMessage(playerid, COLOR_YELLOW, "��������� � ���������� VEXORIUM � ������ Market, ���-������."), 1;
        ShowPlayerDialog(playerid, DIALOG_CAR_DEALER, DIALOG_STYLE_LIST, "VEXORIUM RP | ���������",
            "Bravura � 75 000 ���. | 90 ��/�\nPerennial � 125 000 ���. | 95 ��/�\nPrevion � 175 000 ���. | 100 ��/�\nAdmiral � 225 000 ���. | 105 ��/�\nTurismo � 275 000 ���. | 110 ��/�\nSultan � 1 000 000 ���. | 200 ��/�", "������", "������");
        return 1;
    }
    if (CommandMatch(cmdtext, "/fuel"))
    {
        if (!IsPlayerInAnyVehicle(playerid) || GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
            return SendClientMessage(playerid, COLOR_YELLOW, "������ �� ���� � ������������ ����� � �������� ���."), 1;
        if (!IsNearGasStation(playerid)) return SendClientMessage(playerid, COLOR_YELLOW, "��������� � ����� �� ��� VEXORIUM � ������������ � �������."), 1;
        new vehicleid = GetPlayerVehicleID(playerid);
        if (gVehicleFuel[vehicleid] >= 100) return SendClientMessage(playerid, COLOR_YELLOW, "��� ��� ������."), 1;
        if (!TakeCash(playerid, 300)) return SendClientMessage(playerid, COLOR_RED, "�������� �� ������� ���� ����� 300 ������. ������������ �����."), 1;
        gVehicleFuel[vehicleid] = 100;
        gFuelLastX[vehicleid] = 0.0; gFuelLastY[vehicleid] = 0.0; gFuelLastZ[vehicleid] = 0.0;
        new engine, lights, alarm, doors, bonnet, boot, objective;
        GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
        SetVehicleParamsEx(vehicleid, 1, lights, alarm, doors, bonnet, boot, objective);
        UpdateVexHud(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "�� ��������� ��� �� 100% �� 300 ������.");
        return 1;
    }
    if (!strcmp(cmdtext, "/leaders", true))
    {
        new query[256], rowName[MAX_PLAYER_NAME + 1], factionName[32], line[128], found = 0;
        SendClientMessage(playerid, COLOR_YELLOW, "===== ������ ����������� VEXORIUM RP =====");
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
        if (!found) SendClientMessage(playerid, COLOR_WHITE, "������ ������ ����������� �� ���������.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/fullsklads") || CommandMatch(cmdtext, "/fullstocks"))
    {
        if (!IsOwner(playerid) && gAdmin[playerid] < 4) return SendClientMessage(playerid, COLOR_RED, "������� �������� ��������������� 4-�� ������ � ����."), 1;
        new DBResult:fillResult;
        for (new stockGang = 1; stockGang <= 4; stockGang++) { new initGang[128]; format(initGang, sizeof initGang, "INSERT OR IGNORE INTO gang_stashes (gang_id,money) VALUES (%d,0)", stockGang); fillResult = db_query(gDatabase, initGang); if (fillResult) db_free_result(fillResult); }
        for (new stockFaction = 1; stockFaction <= 7; stockFaction++) { new initFaction[160]; format(initFaction, sizeof initFaction, "INSERT OR IGNORE INTO org_stashes (faction_id,money,materials,ammo,armour) VALUES (%d,0,0,0,0)", stockFaction); fillResult = db_query(gDatabase, initFaction); if (fillResult) db_free_result(fillResult); }
        fillResult = db_query(gDatabase, "UPDATE gang_stashes SET money=1000000"); if (fillResult) db_free_result(fillResult);
        fillResult = db_query(gDatabase, "UPDATE gang_weapon_stash SET ammo=5000"); if (fillResult) db_free_result(fillResult);
        fillResult = db_query(gDatabase, "UPDATE org_stashes SET money=1000000, materials=10000, ammo=10000, armour=500"); if (fillResult) db_free_result(fillResult);
        SendClientMessage(playerid, COLOR_GREEN, "[VEXORIUM] ������ ���������: 4 ����� � 6 �����������. ������/������� � ������ ���������.");
        for (new i = 0; i < MAX_PLAYERS; i++) if (IsPlayerConnected(i) && gLogged[i] && gAdmin[i] >= 1 && i != playerid) SendClientMessage(i, COLOR_ORANGE, "[�����] ������ ���� ���� � ����������� ���� ���������.");
        return 1;
    }
    if (!strcmp(cmdtext, "/rules", true))
    {
        ShowPlayerDialog(playerid, DIALOG_HELP, DIALOG_STYLE_MSGBOX, "VEXORIUM RP | �������", "1. ���������� ������� RolePlay.\n2. �� ����������� ���� � ��������� ���������.\n3. �� ����������� ������� � �������������.\n4. �� ��������������� ��������� � ������.\n5. �������� ������������� � �������� ������ �������.", "�������", "");
        return 1;
    }
    if (!strcmp(cmdtext, "/gang", true))
    {
        ShowPlayerDialog(playerid, DIALOG_GANG, DIALOG_STYLE_LIST, "VEXORIUM | ������� �����", "Grove Street Families\nBallas\nLos Santos Vagos\nVarrios Los Aztecas\n�������� �����", "�������", "�������");
        return 1;
    }
    if (!strcmp(cmdtext, "/gangskin", true) || !strcmp(cmdtext, "/gangclothes", true))
    {
        if (gGang[playerid] < 1 || gGang[playerid] > 4) return SendClientMessage(playerid, COLOR_RED, "�� �� �������� � �����."), 1;
        new Float:bx, Float:by, Float:bz;
        GetGangBase(gGang[playerid], bx, by, bz);
        if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0 || GetPlayerDistanceFromPoint(playerid, bx, by, bz) > 18.0)
            return SendClientMessage(playerid, COLOR_RED, "������������� ����� ������ � �������� ������ �� ���� �����."), 1;
        ShowPlayerDialog(playerid, DIALOG_GANG_SKIN, DIALOG_STYLE_LIST, "������� ������ �����", "������ �������\n������ ���������\n������ ��������\n������ ��������\n������ ��������\n������ ������", "������", "�������");
        return 1;
    }
    if (CommandMatch(cmdtext, "/orgstash"))
    {
        if (gFaction[playerid] < 1 || gFaction[playerid] > 6 || gFactionRank[playerid] < 1)
            return SendClientMessage(playerid, COLOR_RED, "����� �������� ������ ����������� �����������."), 1;
        if (gFaction[playerid] == FACTION_POLICE)
        {
            if (!IsInPoliceStation(playerid) || GetPlayerDistanceFromPoint(playerid, 258.52, 76.8268, 1003.6406) > 5.0)
                return SendClientMessage(playerid, COLOR_RED, "��������� � ���������� ������ ������ ������� LSPD."), 1;
            ShowPlayerDialog(playerid, DIALOG_POLICE_STASH, DIALOG_STYLE_LIST, "LSPD | ��������� �����", "�������\nM4 � ������� (�� 100)\n�������� � ������� (�� 100)\n����������", "�����", "�������");
            return 1;
        }
        if (GetPlayerInterior(playerid) == 0 || !IsInOwnOrgInterior(playerid))
            return SendClientMessage(playerid, COLOR_RED, "�������� ����� ������ ����� ����� �����������."), 1;
        ShowPlayerDialog(playerid, DIALOG_ORG_STASH, DIALOG_STYLE_LIST, "����� �����������", "����� M4 (�� 100 ��������)\n����� �������� (�� 100 ��������)\n�������� ����������\n���������� ������", "�������", "�������");
        return 1;
    }
    if (!strcmp(cmdtext, "/gangstash", true))
    {
        if (gGang[playerid] < 1 || gGang[playerid] > 4)
            return SendClientMessage(playerid, COLOR_RED, "�� �� �������� � �����."), 1;
        new Float:bx, Float:by, Float:bz;
        GetGangBase(gGang[playerid], bx, by, bz);
        if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0 || GetPlayerDistanceFromPoint(playerid, bx, by, bz) > 12.0)
            return SendClientMessage(playerid, COLOR_RED, "����� �������� ������ �� ���� ����� �����."), 1;
        ShowPlayerDialog(playerid, DIALOG_GANG_STASH, DIALOG_STYLE_LIST, "����� �����", "�������� ������\n����� ������\n������ ������\n������ � �������", "�������", "�������");
        return 1;
    }
    if (!strcmp(cmdtext, "/gps", true))
    {
        ShowGPS(playerid);
        return 1;
    }
    if (!strcmp(cmdtext, "/job", true) || !strcmp(cmdtext, "/������", true))
    {
        if (!gHasPassport[playerid]) return SendClientMessage(playerid, COLOR_RED, "��� ���������� �� ������ ������� �������� ������� � �����."), 1;
        new jobText[640];
        strcat(jobText,"������� � �� 3500 ���. �� �������\n������������ � �� 5000 ���. �� �������\n",sizeof jobText);
        strcat(jobText,"�������� �������� � �� 4200 ���. �� �������\n����� � �� 6000 ���. �� �����\n",sizeof jobText);
        strcat(jobText,"����������� � �� 100000 ���. �� ������ (� 3 ������)\n",sizeof jobText);
        strcat(jobText,"������� � 1000 ���. �� ���� (� 3 ������, ��� �������)\n",sizeof jobText);
        strcat(jobText,"�������� � �� 6500 ���. �� �����",sizeof jobText);
        ShowPlayerDialog(playerid,DIALOG_JOB,DIALOG_STYLE_LIST,"VEXORIUM RP | ������",jobText,"�������","�������");
        return 1;
    }
    if (!strcmp(cmdtext, "/work", true) || !strcmp(cmdtext, "/��������", true))
    {
        if (!gHasPassport[playerid]) return SendClientMessage(playerid, COLOR_RED, "��� ������ ����� �������. �������� ��� � �����."), 1;
        if (gJob[playerid] == 5) return StartCarjack(playerid);
        return StartWorkRoute(playerid);
    }
    if (CommandMatch(cmdtext, "/hack"))
    {
        if (!gCarjackActive[playerid] || gWorkStage[playerid] != 10 || gCarjackUnlocked[playerid])
            return SendClientMessage(playerid, COLOR_YELLOW, "������ ��� ������ ����������."), 1;
        if (gCarjackVehicle[playerid] == INVALID_VEHICLE_ID || GetVehicleModel(gCarjackVehicle[playerid]) == 0)
            return SendClientMessage(playerid, COLOR_RED, "������-���� �������. �������� ������ ����� /stopwork."), 1;
        new Float:x, Float:y, Float:z;
        GetVehiclePos(gCarjackVehicle[playerid], x, y, z);
        if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0 || GetPlayerDistanceFromPoint(playerid, x, y, z) > 5.0)
            return SendClientMessage(playerid, COLOR_YELLOW, "��������� � ������ �� ������ 5 ������."), 1;
        ShowPlayerDialog(playerid, DIALOG_CARJACK_HACK, DIALOG_STYLE_LIST, "VEXORIUM | ����� �����", "������� ������\n����� ������\n������ ������\nƸ���� ������", "����������", "������");
        SendClientMessage(playerid, COLOR_YELLOW, "����-����: �������� ���������� ������. ������ ������� ������� � ����� ����������� �����.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/accept"))
    {
        if (gFaction[playerid] != FACTION_POLICE && gFaction[playerid] != FACTION_FBI)
            return SendClientMessage(playerid, COLOR_RED, "������� ������������� ����� ������ ������� � FBI."), 1;
        if (gCarjackPending[playerid] <= 0) return SendClientMessage(playerid, COLOR_YELLOW, "��� ��������� ������ �� ��������."), 1;
        new target = gCarjackPending[playerid] - 1;
        if (!IsPlayerConnected(target) || !gCarjackActive[target]) { gCarjackPending[playerid] = 0; return SendClientMessage(playerid, COLOR_RED, "����� ��� ��������."), 1; }
        gCarjackPending[playerid] = 0;
        gPursuitTarget[playerid] = target;
        new Float:x, Float:y, Float:z;
        if (IsPlayerInAnyVehicle(target)) GetVehiclePos(GetPlayerVehicleID(target), x, y, z);
        else GetPlayerPos(target, x, y, z);
        SetPlayerMapIcon(playerid, 49, x, y, z, 0, 0, MAPICON_GLOBAL);
        SetPlayerCheckpoint(playerid, x, y, z, 8.0);
        RefreshCarjackPursuits();
        SendClientMessage(playerid, COLOR_GREEN, "�� ������� �����. �� ������ �������� ��������� �������������� ������������.");
        SendClientMessage(target, COLOR_RED, "�������/FBI ������� ����� � ������ �������������!");
        return 1;
    }
    if (CommandMatch(cmdtext, "/cancel"))
    {
        if (gFaction[playerid] != FACTION_POLICE && gFaction[playerid] != FACTION_FBI)
            return SendClientMessage(playerid, COLOR_RED, "�������� ����� ����� ������ ������� � FBI."), 1;
        if (gCarjackPending[playerid] <= 0) return SendClientMessage(playerid, COLOR_YELLOW, "��� ��������� ������."), 1;
        gCarjackPending[playerid] = 0;
        SendClientMessage(playerid, COLOR_YELLOW, "�� ���������� �� ������������� ������������.");
        return 1;
    }
    if (!strcmp(cmdtext, "/stopwork", true))
    {
        if (gTaxiOrderTarget[playerid] != INVALID_PLAYER_ID)
            VX_TaxiClearDriver(playerid, "[�����] ����� �������: �������� �������� �����.", false);
        if (gTaxiOrderDriver[playerid] != INVALID_PLAYER_ID)
            VX_TaxiCancelForPlayer(playerid, "[�����] ����� �������: �������� �������� ��������������.", false);
        if (gWorkStage[playerid] == 0) SendClientMessage(playerid, COLOR_YELLOW, "[VEXORIUM] �� ������ �� ���������� ������.");
        else
        {
            gWorkStage[playerid] = 0;
            gFireCallIndex[playerid] = -1;
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
            SendClientMessage(playerid, COLOR_ORANGE, "[VEXORIUM] ������� ������� �������, ������� ��������� ���������.");
        }
        return 1;
    }
    if (CommandMatch(cmdtext, "/inv") || CommandMatch(cmdtext, "/inventory") || CommandMatch(cmdtext, "/���������"))
    {
        new text[320];
        format(text, sizeof text, "VEXORIUM RP | ���������\n�������: %d\n���: %d\n����: %d\n",
            gMedkits[playerid], gFood[playerid], gWater[playerid]);
        new invMore[180];
        format(invMore, sizeof invMore, "������������: %d\nSIM-�����: %d\n�������: %d\n",
            gRepairKits[playerid], gSimCards[playerid], gLockpicks[playerid]);
        strcat(text, invMore, sizeof text);
        format(invMore, sizeof invMore, "/repairkit - ������ ������, /usesim - SIM-�����, /work - ������.");
        strcat(text, invMore, sizeof text);
        ShowPlayerDialog(playerid, DIALOG_ITEM_INVENTORY, DIALOG_STYLE_LIST, "VEXORIUM | ���������", "������������ �������\n������ ���\n������ ����\n������� �����������\n������ ���������\n����� ���������", "�������", "�������");
        SendClientMessage(playerid, COLOR_YELLOW, text);
        return 1;
    }
    if (CommandMatch(cmdtext, "/phone") || CommandMatch(cmdtext, "/telefon"))
    {
        ShowPlayerDialog(playerid, DIALOG_PHONE, DIALOG_STYLE_LIST, "VEXORIUM | �������", "��������� SMS\n�������� ����� �� ����� (GPS)\n������� �������\n������� ������ ������\n��� ID � �����\n������� �����", "�������", "�������");
        return 1;
    }
    if (CommandMatch(cmdtext, "/repairkit"))
    {
        if (gRepairKits[playerid] < 1) return SendClientMessage(playerid, COLOR_RED, "[�����������] � ��� ��� ������������. ������ ��� � /shop."), 1;
        if (!IsPlayerInAnyVehicle(playerid) || GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendClientMessage(playerid, COLOR_YELLOW, "[�����������] ������ �� ���� ������."), 1;
        new repairVehicle = GetPlayerVehicleID(playerid); RepairVehicle(repairVehicle); SetVehicleHealth(repairVehicle, 1000.0);
        gRepairKits[playerid]--; SavePlayer(playerid);
        return SendClientMessage(playerid, COLOR_GREEN, "[�����������] ������ ���������������. ����������� �����������."), 1;
    }
    if (CommandMatch(cmdtext, "/usesim"))
    {
        if (gSimCards[playerid] < 1) return SendClientMessage(playerid, COLOR_RED, "[INV] Net SIM-karty. Kupite ee v /shop."), 1;
        gSimCards[playerid]--; SavePlayer(playerid);
        return SendClientMessage(playerid, COLOR_GREEN, "[PHONE] SIM-karta aktivirovana."), 1;
    }
    if (CommandMatch(cmdtext,"/clothes") || CommandMatch(cmdtext,"/clothesshop"))
        return VX_ClothesOpen(playerid);
    if (CommandMatch(cmdtext,"/clothesgps"))
    {
        new Float:dist,Float:nearest=999999.0,closest=0;
        for(new cs=0;cs<VX_CLOTHES_LOCATIONS;cs++)
        {
            dist=GetPlayerDistanceFromPoint(playerid,gVXClothesPos[cs][0],gVXClothesPos[cs][1],gVXClothesPos[cs][2]);
            if(dist<nearest){nearest=dist;closest=cs;}
        }
        SetPlayerCheckpoint(playerid,gVXClothesPos[closest][0],gVXClothesPos[closest][1],gVXClothesPos[closest][2],3.0);
        SendClientMessage(playerid,COLOR_GREEN,"[������] ������� � ���������� �������� ����������. /clothes - �������.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/shop") || CommandMatch(cmdtext, "/store"))
    {
        if (!gMarketInside[playerid] || GetPlayerVirtualWorld(playerid) != VX_MARKET_WORLD ||
            GetPlayerInterior(playerid) != VX_MARKET_INTERIOR ||
            !IsPlayerInRangeOfPoint(playerid, 3.5, VX_MARKET_COUNTER_X, VX_MARKET_COUNTER_Y, VX_MARKET_COUNTER_Z))
            return SendClientMessage(playerid, COLOR_YELLOW, "[������] ������� ����� ������ �������� � ��������� � �����."), 1;
        new shopItems[512];
        format(shopItems, sizeof shopItems, "������� �������� - 1 200 ���.\n��� - 250 ���.\n���� - 180 ���.");
        strcat(shopItems, "\n�����: ��� + ���� - 350 ���.");
        strcat(shopItems, "\n��������� �������� - 3 000 ���.");
        strcat(shopItems, "\nSIM-����� - 1 500 ���.");
        strcat(shopItems, "\n������� ��� ��������� - 8 000 ���.");
        ShowPlayerDialog(playerid, DIALOG_SHOP, DIALOG_STYLE_LIST, "VEXORIUM | ������ 24/7", shopItems, "������", "�������");
        return 1;
    }
    if (!strcmp(cmdtext, "/balance", true) || !strcmp(cmdtext, "/������", true))
    {
        new msg[96];
        format(msg, sizeof msg, "[VEXORIUM] �� ����� �����: %d ������.", gMoney[playerid]);
        SendClientMessage(playerid, COLOR_GREEN, msg);
        return 1;
    }
    if (!strcmp(cmdtext, "/stats", true) || !strcmp(cmdtext, "/����������", true))
    {
        new text[640], needsLine[192], passportStatus[8], driverStatus[8];
        new jobName[32], factionName[32], factionRankName[48];
        if (gJob[playerid] == 1) format(jobName, sizeof jobName, "�������");
        else if (gJob[playerid] == 2) format(jobName, sizeof jobName, "������������");
        else if (gJob[playerid] == 3) format(jobName, sizeof jobName, "����������");
        else if (gJob[playerid] == 4) format(jobName, sizeof jobName, "�����");
        else if (gJob[playerid] == 5) format(jobName, sizeof jobName, "�����������");
        else if (gJob[playerid] == 6) format(jobName, sizeof jobName, "�������");
        else if (gJob[playerid] == 7) format(jobName, sizeof jobName, "��������");
        else format(jobName, sizeof jobName, "���");
        GetFactionName(gFaction[playerid], factionName, sizeof factionName);
        GetFactionRankName(gFaction[playerid], gFactionRank[playerid], factionRankName, sizeof factionRankName);
        format(text, sizeof text, "���: %s\n�������: %d\n������: %d ���.\n�������: %d\n�������: %d\n������: %s\n�������: %s\n����: %s (%d)\n�����: %d\n�����-�������: %d", gName[playerid], gLevel[playerid], gMoney[playerid], gKills[playerid], gDeaths[playerid], jobName, factionName, factionRankName, gFactionRank[playerid], gGang[playerid], gAdmin[playerid]);
        if (gHasPassport[playerid]) format(passportStatus, sizeof passportStatus, "����"); else format(passportStatus, sizeof passportStatus, "���");
        if (gLicenseDriver[playerid]) format(driverStatus, sizeof driverStatus, "����"); else format(driverStatus, sizeof driverStatus, "���");
        format(needsLine, sizeof needsLine, "\n�������: %d/100 | ����: %d/100 | �������: %d/100\n�������: %s | ������������ �����: %s", gHunger[playerid], gThirst[playerid], gEnergy[playerid], passportStatus, driverStatus);
        strcat(text, needsLine);
        ShowPlayerDialog(playerid, DIALOG_HELP, DIALOG_STYLE_MSGBOX, "VEXORIUM RP | ����������", text, "�������", "");
        return 1;
    }
    if (!strcmp(cmdtext, "/save", true))
    {
        SavePlayer(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "[VEXORIUM] �������� ��������.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/pay"))
    {
        new params[96], token[32], token2[32], targetid, amount, msg[128];
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, token, sizeof token) || !GetToken(params, 1, token2, sizeof token2))
            return SendClientMessage(playerid, COLOR_YELLOW, "�������������: /pay [ID] [�����]"), 1;
        targetid = strval(token); amount = strval(token2);
        if (targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid) || !gLogged[targetid]) return SendClientMessage(playerid, COLOR_RED, "����� �� ������ ��� �� ����� � �������."), 1;
        if (targetid == playerid || amount <= 0 || amount > 10000000) return SendClientMessage(playerid, COLOR_RED, "������� ������� ������ � ����� �� 1 �� 10000000."), 1;
        if (!TakeCash(playerid, amount)) return SendClientMessage(playerid, COLOR_RED, "������������ �����."), 1;
        if (!GiveCash(targetid, amount)) { GiveCash(playerid, amount); return SendClientMessage(playerid, COLOR_RED, "� ���������� ��������� ����� �����."), 1; }
        format(msg, sizeof msg, "�� �������� %s %d ������.", gName[targetid], amount); SendClientMessage(playerid, COLOR_GREEN, msg);
        format(msg, sizeof msg, "%s ������� ��� %d ������.", gName[playerid], amount); SendClientMessage(targetid, COLOR_GREEN, msg);
        SavePlayer(playerid); SavePlayer(targetid);
        return 1;
    }
    if (CommandMatch(cmdtext, "/tp") || CommandMatch(cmdtext, "/goto"))
    {
        new params[64], token[32], targetid;
        if (gAdmin[playerid] < 1) return SendClientMessage(playerid, COLOR_RED, "������������ ����."), 1;
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, token, sizeof token)) return SendClientMessage(playerid, COLOR_YELLOW, "�������������: /tp [ID ������]"), 1;
        targetid = strval(token);
        if (targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid) || !gLogged[targetid]) return SendClientMessage(playerid, COLOR_RED, "����� �� ������ ��� �� ����� � �������."), 1;
        new Float:x, Float:y, Float:z;
        GetPlayerPos(targetid, x, y, z);
        if (IsPlayerInAnyVehicle(playerid)) SetVehiclePos(GetPlayerVehicleID(playerid), x + 2.0, y, z);
        else SetPlayerPos(playerid, x + 1.0, y, z);
        SetPlayerInterior(playerid, GetPlayerInterior(targetid));
        SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(targetid));
        SendClientMessage(playerid, COLOR_GREEN, "[VEXORIUM] �� ��������������� � ������.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/gethere"))
    {
        new params[64], token[32], targetid;
        if (gAdmin[playerid] < 1) return SendClientMessage(playerid, COLOR_RED, "������������ ����."), 1;
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, token, sizeof token)) return SendClientMessage(playerid, COLOR_YELLOW, "�������������: /gethere [ID ������]"), 1;
        targetid = strval(token);
        if (targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid) || !gLogged[targetid]) return SendClientMessage(playerid, COLOR_RED, "����� �� ������ ��� �� ����� � �������."), 1;
        new Float:x, Float:y, Float:z;
        GetPlayerPos(playerid, x, y, z);
        SetPlayerInterior(targetid, GetPlayerInterior(playerid));
        SetPlayerVirtualWorld(targetid, GetPlayerVirtualWorld(playerid));
        if (IsPlayerInAnyVehicle(targetid)) SetVehiclePos(GetPlayerVehicleID(targetid), x + 2.0, y, z);
        else SetPlayerPos(targetid, x + 1.0, y, z);
        SendClientMessage(targetid, COLOR_ORANGE, "[VEXORIUM] ������������� �������������� ��� � ����.");
        SendClientMessage(playerid, COLOR_GREEN, "[VEXORIUM] ����� �������������� � ���.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/tpcar"))
    {
        new params[64], token[32], targetid;
        if (gAdmin[playerid] < 1) return SendClientMessage(playerid, COLOR_RED, "������������ ����."), 1;
        if (!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_YELLOW, "������� ������ � ���������."), 1;
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, token, sizeof token)) return SendClientMessage(playerid, COLOR_YELLOW, "�������������: /tpcar [ID ������]"), 1;
        targetid = strval(token);
        if (targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid) || !gLogged[targetid]) return SendClientMessage(playerid, COLOR_RED, "����� �� ������ ��� �� ����� � �������."), 1;
        new Float:x, Float:y, Float:z;
        GetPlayerPos(targetid, x, y, z);
        SetVehiclePos(GetPlayerVehicleID(playerid), x + 3.0, y, z);
        SetPlayerInterior(playerid, GetPlayerInterior(targetid));
        SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(targetid));
        SendClientMessage(playerid, COLOR_GREEN, "[VEXORIUM] ��� ��������� �������������� � ������.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/setadmin"))
    {
        new params[96], token[32], token2[32], targetid, level;
        if (!IsOwner(playerid)) return SendClientMessage(playerid, COLOR_RED, "������������ ����."), 1;
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, token, sizeof token) || !GetToken(params, 1, token2, sizeof token2)) return SendClientMessage(playerid, COLOR_YELLOW, "�������������: /setadmin [ID] [0-4]"), 1;
        targetid = strval(token); level = strval(token2);
        if (targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid) || !gLogged[targetid] || level < 0 || level > 4) return SendClientMessage(playerid, COLOR_RED, "�������� ID ��� ������� 0-4."), 1;
        gAdmin[targetid] = level;
        new query[160];
        format(query, sizeof query, "UPDATE accounts SET admin=%d WHERE name='%q'", level, gName[targetid]);
        gResult = db_query(gDatabase, query); if (gResult) db_free_result(gResult);
        SendClientMessage(targetid, COLOR_GREEN, "[VEXORIUM] ��� ������� �������������� �������.");
        SendClientMessage(playerid, COLOR_GREEN, "[VEXORIUM] ������� �������������� �������.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/setmoney"))
    {
        new params[96], token[32], token2[32], targetid, amount, query[160];
        if (gAdmin[playerid] < 5) return SendClientMessage(playerid, COLOR_RED, "������������ ����."), 1;
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, token, sizeof token) || !GetToken(params, 1, token2, sizeof token2)) return SendClientMessage(playerid, COLOR_YELLOW, "�������������: /setmoney [ID] [�����]"), 1;
        targetid = strval(token); amount = strval(token2);
        if (targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid) || !gLogged[targetid] || amount < 0 || amount > MAX_MONEY) return SendClientMessage(playerid, COLOR_RED, "�������� ID ��� �����."), 1;
        gMoney[targetid] = amount; ResetPlayerMoney(targetid); GivePlayerMoney(targetid, amount);
        format(query, sizeof query, "UPDATE accounts SET money=%d WHERE name='%q'", amount, gName[targetid]);
        gResult = db_query(gDatabase, query); if (gResult) db_free_result(gResult);
        SendClientMessage(targetid, COLOR_GREEN, "[VEXORIUM] ������������� ������� ��� ������.");
        SendClientMessage(playerid, COLOR_GREEN, "[VEXORIUM] ������ ������ �������.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/setfaction"))
    {
        new params[96], tok1[24], tok2[24], tok3[24], targetid, faction, rank, query[192], msg[160], factionName[32], rankName[48];
        if (gAdmin[playerid] < 3) return SendClientMessage(playerid, COLOR_RED, "������� �������� � 3-�� ������ ��������������."), 1;
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, tok1, sizeof tok1) || !GetToken(params, 1, tok2, sizeof tok2) || !GetToken(params, 2, tok3, sizeof tok3)) return SendClientMessage(playerid, COLOR_YELLOW, "�������������: /setfaction [ID] [0-6] [���� 0-10]"), 1;
        targetid = strval(tok1); faction = strval(tok2); rank = strval(tok3);
        if (targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid) || !gLogged[targetid] || faction < 0 || faction > 7 || rank < 0 || rank > 10 || (faction == 0 && rank != 0) || (faction > 0 && rank < 1)) return SendClientMessage(playerid, COLOR_RED, "�������� ID, ������� ��� ����."), 1;
        gFaction[targetid] = faction; gFactionRank[targetid] = rank;
        UpdatePlayerRoleColor(targetid);
        UpdateVexHud(targetid);
        new rankSkin = 23;
        if (faction >= FACTION_CITYHALL && faction <= FACTION_FBI) rankSkin = GetFactionSkin(faction, rank);
        SetPlayerSkin(targetid, rankSkin);
        format(query, sizeof query, "UPDATE accounts SET faction=%d,faction_rank=%d,skin=%d WHERE name='%q'", faction, rank, rankSkin, gName[targetid]);
        gResult = db_query(gDatabase, query); if (gResult) db_free_result(gResult);
        GetFactionName(faction, factionName, sizeof factionName); GetFactionRankName(faction, rank, rankName, sizeof rankName);
        format(msg, sizeof msg, "���� �������: %s. ����: %s (%d).", factionName, rankName, rank); SendClientMessage(targetid, COLOR_GREEN, msg);
        SendClientMessage(playerid, COLOR_GREEN, "������� � ���� ������ ���������.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/uniform"))
    {
        new params[64], tok1[24], tok2[24], targetid, faction, skin, query[192], msg[128];
        if (gAdmin[playerid] < 3) return SendClientMessage(playerid, COLOR_RED, "������� �������� � 3-�� ������ ��������������."), 1;
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, tok1, sizeof tok1) || !GetToken(params, 1, tok2, sizeof tok2)) return SendClientMessage(playerid, COLOR_YELLOW, "�������������: /uniform [ID] [1=�����, 2=�������, 3=��������, 4=�����, 5=���, 6=���]"), 1;
        targetid = strval(tok1); faction = strval(tok2);
        if (targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid) || !gLogged[targetid] || faction < 1 || faction > 7) return SendClientMessage(playerid, COLOR_RED, "�������� ID ��� ��� �����."), 1;
        if (gFaction[targetid] != faction) { gFaction[targetid] = faction; gFactionRank[targetid] = 1; }
        else if (gFactionRank[targetid] < 1) gFactionRank[targetid] = 1;
        UpdatePlayerRoleColor(targetid);
        skin = GetFactionSkin(faction, gFactionRank[targetid]);
        SetPlayerSkin(targetid, skin);
        format(query, sizeof query, "UPDATE accounts SET skin=%d,faction=%d,faction_rank=%d WHERE name='%q'", skin, gFaction[targetid], gFactionRank[targetid], gName[targetid]);
        gResult = db_query(gDatabase, query); if (gResult) db_free_result(gResult);
        new factionName[32];
        GetFactionName(faction, factionName, sizeof factionName);
        format(msg, sizeof msg, "������������� ����� ��� �����: %s (���� %d).", factionName, skin);
        SendClientMessage(targetid, COLOR_GREEN, msg); SendClientMessage(playerid, COLOR_GREEN, "����� �� ������ ����� ������ � ���������.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/enterpd") || CommandMatch(cmdtext, "/policeenter"))
    {
        SendClientMessage(playerid, COLOR_YELLOW, "���� � ������� ������ ����� ������ � �����. ������� �� �������������.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/exitpd") || (!strcmp(cmdtext, "/exit", true) && IsInPoliceStation(playerid)))
    {
        if (!IsInPoliceStation(playerid)) return SendClientMessage(playerid, COLOR_YELLOW, "�� �� � ����������� �������."), 1;
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        SetPlayerPos(playerid, 1547.0, -1678.8352, 14.9453);
        SetPlayerFacingAngle(playerid, 270.41);
        SetCameraBehindPlayer(playerid);
        return 1;
    }
    if (CommandMatch(cmdtext, "/duty"))
    {
        return SendClientMessage(playerid, COLOR_YELLOW, "������������ ������ �������� ����� ������ ���������� ������ �����. �������� �� ������ ������."), 1;
    }
    if (CommandMatch(cmdtext, "/policetablet") || CommandMatch(cmdtext, "/kpp"))
    {
        if (gFaction[playerid] != FACTION_POLICE || gFactionRank[playerid] < 1)
            return SendClientMessage(playerid, COLOR_RED, "����������� ������� �������� ������ ����������� �������."), 1;
        ShowPlayerDialog(playerid, DIALOG_POLICE_TABLET, DIALOG_STYLE_LIST,
            "VEXORIUM | ����������� �������",
            "������ ������� � ��������������\n�������� � ������: /wanted [ID] [0-6] [�������]\n���������: /cuff [ID] /uncuff [ID]\n��������� ������: /pursuit [ID]",
            "�������", "�������");
        return 1;
    }
    if (CommandMatch(cmdtext, "/sobescr"))
    {
        if (gFaction[playerid] < FACTION_CITYHALL || gFaction[playerid] > FACTION_FBI || gFactionRank[playerid] < 9)
            return SendClientMessage(playerid, COLOR_RED, "������� � 9 ����� � ����� ����������� ��� ����, ����� ��������� �������������."), 1;
        if (gInterviewActive || gInterviewTimer != 0)
            return SendClientMessage(playerid, COLOR_RED, "������������� ��� ���. ��������� ��� ���������."), 1;
        gInterviewActive = true;
        gInterviewFaction = gFaction[playerid];
        InterviewAnnouncement();
        gInterviewTimer = SetTimer("InterviewAnnouncement", 900000, true);
        return 1;
    }
    if (CommandMatch(cmdtext, "/sobesstop"))
    {
        if (gFaction[playerid] < FACTION_CITYHALL || gFaction[playerid] > FACTION_FBI || gFactionRank[playerid] < 9)
            return SendClientMessage(playerid, COLOR_RED, "����� 9-� ���� � ����� ����������� ��� ����, ����� ���������� �������������."), 1;
        if (!gInterviewActive || gInterviewFaction != gFaction[playerid])
            return SendClientMessage(playerid, COLOR_RED, "� ����� ����������� ������ ��� ������������ �������������."), 1;
        if (gInterviewTimer != 0) KillTimer(gInterviewTimer);
        gInterviewTimer = 0;
        gInterviewActive = false;
        SendClientMessageToAll(COLOR_BLUE, "������������� ��������." );
        return 1;
    }
    if (CommandMatch(cmdtext, "/pdocs") || CommandMatch(cmdtext, "/policedocs") || CommandMatch(cmdtext, "/udost"))
    {
        if (gFaction[playerid] != FACTION_POLICE || gFactionRank[playerid] < 1)
            return SendClientMessage(playerid, COLOR_RED, "�� ������ ������� ����� ������������ ������ ���������� �������."), 1;
        new params[32], token[16], targetid;
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, token, sizeof token))
            return SendClientMessage(playerid, COLOR_YELLOW, "�������������: /pdocs [ID]"), 1;
        targetid = strval(token);
        if (targetid < 0 || targetid >= MAX_PLAYERS || targetid == playerid || !IsPlayerConnected(targetid) || !gLogged[targetid])
            return SendClientMessage(playerid, COLOR_RED, "����� �� ������."), 1;
        if (GetPlayerInterior(playerid) != GetPlayerInterior(targetid) || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(targetid))
            return SendClientMessage(playerid, COLOR_RED, "�� ������ ���������� � ����� �����."), 1;
        new Float:tx, Float:ty, Float:tz;
        GetPlayerPos(targetid, tx, ty, tz);
        if (!IsPlayerInRangeOfPoint(playerid, 4.0, tx, ty, tz))
            return SendClientMessage(playerid, COLOR_RED, "��������� � ���������� �� ���������� �� ����� 4 ������."), 1;
        new rankName[32], doc[192], action[144];
        GetFactionRankName(FACTION_POLICE, gFactionRank[playerid], rankName, sizeof rankName);
        format(doc, sizeof doc, "[���������� ���������] ������: %s | ���������: %s | ID: %d | �����: LSPD", rankName, gName[playerid], playerid);
        SendClientMessage(targetid, COLOR_BLUE, doc);
        SendClientMessage(playerid, COLOR_GREEN, "�� ���������� ���������� ���������.");
        format(action, sizeof action, "* %s ����������� ���� ���������� ���������.", gName[playerid]);
        new Float:px, Float:py, Float:pz; GetPlayerPos(playerid, px, py, pz);
        for (new i = 0; i < MAX_PLAYERS; i++)
            if (IsPlayerConnected(i) && GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid) && GetPlayerInterior(i) == GetPlayerInterior(playerid) && IsPlayerInRangeOfPoint(i, 10.0, px, py, pz)) SendClientMessage(i, COLOR_YELLOW, action);
        return 1;
    }
    if (CommandMatch(cmdtext, "/pursuit"))
    {
        if ((gFaction[playerid] != FACTION_POLICE && gFaction[playerid] != FACTION_FBI) || gFactionRank[playerid] < 2) return SendClientMessage(playerid, COLOR_RED, "��������� �������� LSPD/FBI �� 2-�� �����."), 1;
        new params[32], token[24], targetid; GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, token, sizeof token)) return SendClientMessage(playerid, COLOR_YELLOW, "�������������: /pursuit [ID]"), 1;
        targetid = strval(token);
        if (targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid) || !gLogged[targetid] || targetid == playerid) return SendClientMessage(playerid, COLOR_RED, "����� �� ������."), 1;
        if (gWantedLevel[targetid] < 1) return SendClientMessage(playerid, COLOR_YELLOW, "� ������ ��� ��������� �������."), 1;
        new Float:x, Float:y, Float:z;
        if (IsPlayerInAnyVehicle(targetid)) GetVehiclePos(GetPlayerVehicleID(targetid), x, y, z);
        else GetPlayerPos(targetid, x, y, z);
        gPursuitTarget[playerid] = targetid;
        SetPlayerMapIcon(playerid, 49, x, y, z, 0, 0, MAPICON_GLOBAL);
        SetPlayerCheckpoint(playerid, x, y, z, 8.0);
        new msg[128]; format(msg, sizeof msg, "������ ������������� %s. ����� ���������� ��� ��������� ��������������; ��������� /pursuit [ID] ��� ����������.", gName[targetid]); SendClientMessage(playerid, COLOR_GREEN, msg);
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
        format(bankMsg, sizeof bankMsg, "[����] ��������: %d ���. | �� �����: %d ���. | /deposit [�����] /withdraw [�����] /transfer [ID] [�����]", gMoney[playerid], gBankMoney[playerid]);
        SendClientMessage(playerid, COLOR_GREEN, bankMsg);
        return 1;
    }
    if (CommandMatch(cmdtext, "/deposit") || CommandMatch(cmdtext, "/withdraw"))
    {
        new params[64], token[24], amount;
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, token, sizeof token)) return SendClientMessage(playerid, COLOR_YELLOW, "�������������: /deposit [�����] ��� /withdraw [�����]"), 1;
        amount = strval(token);
        if (amount <= 0 || amount > MAX_MONEY) return SendClientMessage(playerid, COLOR_RED, "����� ������ ���� �������������."), 1;
        if (CommandMatch(cmdtext, "/deposit"))
        {
            if (gMoney[playerid] < amount) return SendClientMessage(playerid, COLOR_RED, "������������ ��������."), 1;
            if (gBankMoney[playerid] > MAX_MONEY - amount) return SendClientMessage(playerid, COLOR_RED, "�������� ����� ����������� �����."), 1;
            gMoney[playerid] -= amount; gBankMoney[playerid] += amount;
        }
        else
        {
            if (gBankMoney[playerid] < amount) return SendClientMessage(playerid, COLOR_RED, "������������ ����� �� ���������� �����."), 1;
            if (gMoney[playerid] > MAX_MONEY - amount) return SendClientMessage(playerid, COLOR_RED, "�������� ����� ��������."), 1;
            gBankMoney[playerid] -= amount; gMoney[playerid] += amount;
        }
        new bankSave[192];
        format(bankSave, sizeof bankSave, "INSERT OR REPLACE INTO bank_accounts (name,balance) VALUES ('%q',%d)", gName[playerid], gBankMoney[playerid]);
        new DBResult:bs = db_query(gDatabase, bankSave); if (bs) db_free_result(bs);
        SavePlayer(playerid);
        return SendClientMessage(playerid, COLOR_GREEN, "�������� ���������. ������ ����� ��������."), 1;
    }
    if (CommandMatch(cmdtext, "/transfer"))
    {
        new params[64], tok1[24], tok2[24], targetid, amount;
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, tok1, sizeof tok1) || !GetToken(params, 1, tok2, sizeof tok2)) return SendClientMessage(playerid, COLOR_YELLOW, "�������������: /transfer [ID] [�����]"), 1;
        targetid = strval(tok1); amount = strval(tok2);
        if (targetid < 0 || targetid >= MAX_PLAYERS || targetid == playerid || !IsPlayerConnected(targetid) || !gLogged[targetid]) return SendClientMessage(playerid, COLOR_RED, "���������� �� ������."), 1;
        if (amount <= 0 || amount > MAX_MONEY) return SendClientMessage(playerid, COLOR_RED, "������������ �����."), 1;
        if (gBankMoney[playerid] < amount) return SendClientMessage(playerid, COLOR_RED, "������������ ����� �� ���������� �����."), 1;
        if (gBankMoney[targetid] > MAX_MONEY - amount) return SendClientMessage(playerid, COLOR_RED, "� ���������� ��������� ����� �����."), 1;
        gBankMoney[playerid] -= amount; gBankMoney[targetid] += amount;
        new bankSave[192];
        format(bankSave, sizeof bankSave, "INSERT OR REPLACE INTO bank_accounts (name,balance) VALUES ('%q',%d)", gName[playerid], gBankMoney[playerid]);
        new DBResult:bs = db_query(gDatabase, bankSave); if (bs) db_free_result(bs);
        format(bankSave, sizeof bankSave, "INSERT OR REPLACE INTO bank_accounts (name,balance) VALUES ('%q',%d)", gName[targetid], gBankMoney[targetid]);
        bs = db_query(gDatabase, bankSave); if (bs) db_free_result(bs);
        new transferMsg[128]; format(transferMsg, sizeof transferMsg, "��� �������� %d ���. �� %s.", amount, gName[playerid]); SendClientMessage(targetid, COLOR_GREEN, transferMsg);
        format(transferMsg, sizeof transferMsg, "������� %d ���. ������ %s ��������.", amount, gName[targetid]); SendClientMessage(playerid, COLOR_GREEN, transferMsg);
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
                    if (!owner[0]) format(msg, sizeof msg, "��� #%d | ��������: ���� | ����: %d ���. | /housebuy", hid, price);
                    else format(msg, sizeof msg, "��� #%d ����������� %s.", hid, owner);
                    SendClientMessage(playerid, COLOR_YELLOW, msg); found = 1; break;
                }
                db_next_row(hr);
            }
            db_free_result(hr);
        }
        if (!found) SendClientMessage(playerid, COLOR_YELLOW, "������� � ������ �� ����� � ����� /house. ���� �������� ������������ � ���-�������.");
        return 1;
    }
    if (CommandMatch(cmdtext, "/housebuy"))
    {
        new Float:px, Float:py, Float:pz, DBResult:hr, row, hid = 0, price = 0, Float:hx, Float:hy, Float:hz, owner[MAX_PLAYER_NAME + 1];
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
        if (!hid) return SendClientMessage(playerid, COLOR_RED, "������� � ����, ������� ������ ������."), 1;
        if (owner[0]) return SendClientMessage(playerid, COLOR_RED, "���� ��� ��� ����������� ������."), 1;
        new ownedQuery[160];
        format(ownedQuery,sizeof ownedQuery,"SELECT id FROM houses WHERE owner='%q' LIMIT 1",gName[playerid]);
        new DBResult:ownedHouse=db_query(gDatabase,ownedQuery);
        if (!ownedHouse) return SendClientMessage(playerid,COLOR_RED,"������ ���� ������."),1;
        new alreadyOwns=(db_num_rows(ownedHouse)>0);
        db_free_result(ownedHouse);
        if (alreadyOwns) return SendClientMessage(playerid,COLOR_RED,"����� ������� ������ ����� �����."),1;
        if (gMoney[playerid] < price) return SendClientMessage(playerid, COLOR_RED, "������������ �������� ��� ������� ����."), 1;
        gHousePending[playerid] = hid;
        gHouseCaptchaA[playerid] = random(8) + 2;
        gHouseCaptchaB[playerid] = random(8) + 2;
        new captchaText[192];
        format(captchaText, sizeof captchaText,
            "��� #%d ����� %d ���.\n��� ������������� ������� ������ ������:\n%d + %d = ?",
            hid, price, gHouseCaptchaA[playerid], gHouseCaptchaB[playerid]);
        ShowPlayerDialog(playerid, DIALOG_HOUSE_CAPTCHA, DIALOG_STYLE_INPUT, "VEXORIUM | ������� ����", captchaText, "����������", "������");
        return 1;
    }
    if (CommandMatch(cmdtext, "/houseenter"))
    {
        new DBResult:hr, hid, owner[MAX_PLAYER_NAME + 1], Float:hx, Float:hy, Float:hz, found = 0;
        if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0) return SendClientMessage(playerid, COLOR_RED, "�� ��� ���������� ������ ������."), 1;
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
        if (!found) return SendClientMessage(playerid, COLOR_RED, "������� � ������ ����."), 1;
        return VX_HouseEnterID(playerid, hid);
    }
    if (CommandMatch(cmdtext, "/houseexit"))
    {
        if (!gCurrentHouse[playerid] || GetPlayerInterior(playerid) == 0) return SendClientMessage(playerid, COLOR_RED, "�� �� ���������� � ����."), 1;
        new query[128], DBResult:hr; format(query, sizeof query, "SELECT x,y,z FROM houses WHERE id=%d", gCurrentHouse[playerid]); hr = db_query(gDatabase, query);
        if (hr && db_num_rows(hr)) { SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0); SetPlayerPos(playerid, db_get_field_float(hr, 0), db_get_field_float(hr, 1), db_get_field_float(hr, 2) + 1.0); SetPlayerFacingAngle(playerid, 180.0); SetCameraBehindPlayer(playerid); }
        if (hr) db_free_result(hr); gCurrentHouse[playerid] = 0;
        return SendClientMessage(playerid, COLOR_GREEN, "�� ����� �� ����."), 1;
    }
    if (CommandMatch(cmdtext, "/kick"))
    {
        new params[192], token[24], reason[128], targetid;
        if (gAdmin[playerid] < 2) return SendClientMessage(playerid, COLOR_RED, "��� �������� �� 2 ������ �������������."), 1;
        GetParams(cmdtext, params, sizeof params);
        if (!GetToken(params, 0, token, sizeof token)) return SendClientMessage(playerid, COLOR_YELLOW, "�������������: /kick ID �������"), 1;
        targetid = strval(token);GetParams(params,reason,sizeof reason);
        if (!VX_Valid(targetid)) return SendClientMessage(playerid, COLOR_RED, "����� �� ������ ��� �� ����� � �������."), 1;
        if (!strlen(reason)) format(reason,sizeof reason,"��������� ������ �������");
        VX_AdminKickTarget(playerid,targetid,reason);
        return 1;
    }
    if (CommandMatch(cmdtext, "/ban"))
    {
        new params[192], token[24], minutesToken[24], reason[128], targetid, minutes;
        if (gAdmin[playerid] < 3) return SendClientMessage(playerid,COLOR_RED,"��� �������� � 3 ������ �������������."),1;
        GetParams(cmdtext,params,sizeof params);
        if(!GetToken(params,0,token,sizeof token) || !GetToken(params,1,minutesToken,sizeof minutesToken))
            return SendClientMessage(playerid,COLOR_YELLOW,"�������������: /ban ID ������ ������� (0 = ��������)."),1;
        targetid=strval(token);minutes=strval(minutesToken);
        GetParams(params,reason,sizeof reason);GetParams(reason,reason,sizeof reason);
        if(!VX_Valid(targetid) || minutes<0 || minutes>525600 || strlen(reason)<3)
            return SendClientMessage(playerid,COLOR_YELLOW,"������: /ban ID ������ �������. ���� 0 ��� 1-525600 �����."),1;
        VX_AdminBanTarget(playerid,targetid,minutes,reason);return 1;
    }
    if (CommandMatch(cmdtext, "/unban"))
    {
        new params[96], token[32], query[192];
        if(gAdmin[playerid]<3) return SendClientMessage(playerid,COLOR_RED,"������ �������� � 3 ������ �������������."),1;
        GetParams(cmdtext,params,sizeof params);
        if(!GetToken(params,0,token,sizeof token)) return SendClientMessage(playerid,COLOR_YELLOW,"�������������: /unban ���_������"),1;
        format(query,sizeof query,"DELETE FROM vx_admin_bans WHERE name='%q' COLLATE NOCASE",token);
        if(!VX_SQL(query)) return SendClientMessage(playerid,COLOR_RED,"������ ���� ������ ��� �������."),1;
        SendClientMessage(playerid,COLOR_GREEN,"������ ���� �������, ����� ������ ����� ��� ��������� �����������.");return 1;
    }
    if (CommandMatch(cmdtext, "/warn"))
    {
        new params[192],token[24],reason[128],targetid;
        if(gAdmin[playerid]<2) return SendClientMessage(playerid,COLOR_RED,"�������������� �������� �� 2 ������ �������������."),1;
        GetParams(cmdtext,params,sizeof params);
        if(!GetToken(params,0,token,sizeof token)) return SendClientMessage(playerid,COLOR_YELLOW,"�������������: /warn ID �������"),1;
        targetid=strval(token);GetParams(params,reason,sizeof reason);GetParams(reason,reason,sizeof reason);
        if(!VX_Valid(targetid) || strlen(reason)<3) return SendClientMessage(playerid,COLOR_YELLOW,"�������������: /warn ID �������"),1;
        VX_AdminWarnTarget(playerid,targetid,reason);return 1;
    }
    if (CommandMatch(cmdtext, "/mute"))
    {
        new params[192],token[24],minutesToken[24],reason[128],targetid,minutes;
        if(gAdmin[playerid]<2) return SendClientMessage(playerid,COLOR_RED,"��� �������� �� 2 ������ �������������."),1;
        GetParams(cmdtext,params,sizeof params);
        if(!GetToken(params,0,token,sizeof token) || !GetToken(params,1,minutesToken,sizeof minutesToken))
            return SendClientMessage(playerid,COLOR_YELLOW,"�������������: /mute ID ������ �������"),1;
        targetid=strval(token);minutes=strval(minutesToken);GetParams(params,reason,sizeof reason);GetParams(reason,reason,sizeof reason);
        if(!VX_Valid(targetid) || minutes<1 || minutes>1440 || strlen(reason)<3 || !VX_AdminCanAct(playerid,targetid,2))
            return SendClientMessage(playerid,COLOR_YELLOW,"������: /mute ID 1-1440 �������; ������ ������ �������/�������� ��������������."),1;
        gAdminMuteUntil[targetid]=gettime()+minutes*60;format(gAdminMuteReason[targetid],96,"%s",reason);
        new muteMsg[180];format(muteMsg,sizeof muteMsg,"[MUTE] %s ������� ��� �� %d ���. �������: %s",gName[targetid],minutes,reason);
        SendClientMessageToAll(COLOR_ORANGE,muteMsg);return 1;
    }
    if (CommandMatch(cmdtext, "/unmute"))
    {
        new params[48],token[24],targetid;
        if(gAdmin[playerid]<2) return SendClientMessage(playerid,COLOR_RED,"����� ��� ����� ������������� �� 2 ������."),1;
        GetParams(cmdtext,params,sizeof params);
        if(!GetToken(params,0,token,sizeof token)) return SendClientMessage(playerid,COLOR_YELLOW,"�������������: /unmute ID"),1;
        targetid=strval(token);
        if(!VX_Valid(targetid)) return SendClientMessage(playerid,COLOR_RED,"����� �� ������."),1;
        if(!VX_AdminCanAct(playerid,targetid,2)) return SendClientMessage(playerid,COLOR_RED,"������ ����� ��� � �������/�������� ��������������."),1;
        gAdminMuteUntil[targetid]=0;gAdminMuteReason[targetid][0]='\0';
        SendClientMessage(targetid,COLOR_GREEN,"������������� ���� � ��� ���.");SendClientMessage(playerid,COLOR_GREEN,"��� ����.");return 1;
    }
    if (CommandMatch(cmdtext, "/goto"))
    {
        new params[48],token[24],targetid;Float:x,Float:y,Float:z;
        if(gAdmin[playerid]<1) return SendClientMessage(playerid,COLOR_RED,"������������ �������� �������������."),1;
        if(gVXSpec[playerid]!=INVALID_PLAYER_ID) return SendClientMessage(playerid,COLOR_YELLOW,"������� ��������� /specoff."),1;
        GetParams(cmdtext,params,sizeof params);
        if(!GetToken(params,0,token,sizeof token)) return SendClientMessage(playerid,COLOR_YELLOW,"�������������: /goto ID"),1;
        targetid=strval(token);if(!VX_Valid(targetid) || targetid==playerid) return SendClientMessage(playerid,COLOR_RED,"����� �� ������."),1;
        GetPlayerPos(targetid,x,y,z);SetPlayerInterior(playerid,GetPlayerInterior(targetid));SetPlayerVirtualWorld(playerid,GetPlayerVirtualWorld(targetid));
        SetPlayerPos(playerid,x+1.0,y,z);SetPlayerFacingAngle(playerid,180.0);SetCameraBehindPlayer(playerid);
        SendClientMessage(playerid,COLOR_GREEN,"�� ��������������� � ������.");return 1;
    }
    if (CommandMatch(cmdtext, "/gethere"))
    {
        new params[48],token[24],targetid;Float:x,Float:y,Float:z;
        if(gAdmin[playerid]<3) return SendClientMessage(playerid,COLOR_RED,"/gethere �������� � 3 ������ �������������."),1;
        GetParams(cmdtext,params,sizeof params);
        if(!GetToken(params,0,token,sizeof token)) return SendClientMessage(playerid,COLOR_YELLOW,"�������������: /gethere ID"),1;
        targetid=strval(token);if(!VX_AdminCanAct(playerid,targetid,3)) return SendClientMessage(playerid,COLOR_RED,"������ ����������� ����� ������."),1;
        if(gIsJailed[targetid] || gHandcuffed[targetid] || gVXHospital[targetid]) return SendClientMessage(playerid,COLOR_RED,"������ ����������� ������ � ������, ���������� ��� ��������."),1;
        GetPlayerPos(playerid,x,y,z);SetPlayerInterior(targetid,GetPlayerInterior(playerid));SetPlayerVirtualWorld(targetid,GetPlayerVirtualWorld(playerid));
        SetPlayerPos(targetid,x+1.0,y,z);SetPlayerFacingAngle(targetid,180.0);SetCameraBehindPlayer(targetid);
        SendClientMessage(targetid,COLOR_YELLOW,"������������� ���������� ��� � ����.");SendClientMessage(playerid,COLOR_GREEN,"����� ��������� � ���.");return 1;
    }
    if (CommandMatch(cmdtext, "/setadmin"))
    {
        new params[48],token[24],levelToken[16],targetid,level,query[192];
        if(!IsOwner(playerid)) return SendClientMessage(playerid,COLOR_RED,"��������� ������������� ����� ������ �������� �������."),1;
        GetParams(cmdtext,params,sizeof params);
        if(!GetToken(params,0,token,sizeof token) || !GetToken(params,1,levelToken,sizeof levelToken))
            return SendClientMessage(playerid,COLOR_YELLOW,"�������������: /setadmin ID [0-4]"),1;
        targetid=strval(token);level=strval(levelToken);
        if(!VX_Valid(targetid) || IsOwner(targetid) || level<0 || level>4)
            return SendClientMessage(playerid,COLOR_RED,"������� ��������� ������ (�� ���������) � ������� 0-4."),1;
        gAdmin[targetid]=level;format(query,sizeof query,"UPDATE accounts SET admin=%d WHERE name='%q'",level,gName[targetid]);
        if(!VX_SQL(query)) return SendClientMessage(playerid,COLOR_RED,"�� ������� ��������� ������� �������������."),1;
        format(query,sizeof query,"��� ������� ������������� ������� �� %d.",level);SendClientMessage(targetid,COLOR_ORANGE,query);
        SendClientMessage(playerid,COLOR_GREEN,"������� ������������� ��������.");return 1;
    }
    if (CommandMatch(cmdtext, "/adminhelp"))
    {
        new body[1200];body[0]='\0';
        strcat(body,"������� 1: /a /reports /rtake /reply /rclose /spec /specmenu /specoff /goto\n",sizeof body);
        strcat(body,"������� 2: /kick /jail /jailtime /unjail /warn /mute /unmute\n",sizeof body);
        strcat(body,"������� 3: /ban /unban /gethere; � /spec ���� ���, ���, ���, ��� � ��������������\n",sizeof body);
        strcat(body,"��������: /setadmin ID [0-4], /setlevel ID [1-1000], /payday, /myadminlevel 5\n\n",sizeof body);
        strcat(body,"���� ����: 0 = ��������. ���� ����������� ����� ����������� �������.",sizeof body);
        return ShowPlayerDialog(playerid,DIALOG_HELP,DIALOG_STYLE_MSGBOX,"VEXORIUM | ������� �������������",body,"��","");
    }
    if (CommandMatch(cmdtext, "/a"))
    {
        new params[128], msg[160];
        if (gAdmin[playerid] < 1) return SendClientMessage(playerid, COLOR_RED, "������������ ����."), 1;
        GetParams(cmdtext, params, sizeof params);
        if (!strlen(params)) return SendClientMessage(playerid, COLOR_YELLOW, "�������������: /a [���������]"), 1;
        format(msg, sizeof msg, "[�����-���] %s: %s", gName[playerid], params);
        for (new i = 0; i < MAX_PLAYERS; i++) if (IsPlayerConnected(i) && gLogged[i] && gAdmin[i] > 0) SendClientMessage(i, COLOR_ORANGE, msg);
        return 1;
    }
    SendClientMessage(playerid, COLOR_YELLOW, "����������� �������. �������� /help.");
    return 1;
}

stock cmdtext_licbuy(playerid, const type[])
{
    new price, licenseType;
    // Driver license is granted here after the completed exam.
    if (!strcmp(type, "auto", true))
    {
        if (GetPlayerInterior(playerid) != 3 || GetPlayerVirtualWorld(playerid) != 101 || !IsPlayerInRangeOfPoint(playerid, 8.0, 362.4587, 174.0056, 1008.3828))
            return SendClientMessage(playerid, COLOR_RED, "��������� � ������ �������� � �����."), 1;
        if (gLicenseDriver[playerid])
            return SendClientMessage(playerid, COLOR_GREEN, "� ��� ��� ���� ������������ �����."), 1;
        if (!gDrivingExamPassed[playerid])
            return SendClientMessage(playerid, COLOR_RED, "������� ������ ������� � ���������."), 1;
        gLicenseDriver[playerid] = 1;
        gDrivingExamPassed[playerid] = 0;
        SavePlayer(playerid);
        return SendClientMessage(playerid, COLOR_GREEN, "������������ ����� ������! ������ ��� �������� � �������."), 1;
    }
    if (!strcmp(type, "weapon", true)) { licenseType = 2; price = 30000; if (gLicenseWeapon[playerid]) return SendClientMessage(playerid, COLOR_GREEN, "� ��� ��� ���� �������� �� ������."), 1; }
    else if (!strcmp(type, "boat", true)) { licenseType = 3; price = 20000; if (gLicenseBoat[playerid]) return SendClientMessage(playerid, COLOR_GREEN, "� ��� ��� ���� �������� �� �����."), 1; }
    else if (!strcmp(type, "air", true)) { licenseType = 4; price = 40000; if (gLicenseAir[playerid]) return SendClientMessage(playerid, COLOR_GREEN, "� ��� ��� ���� �������� �� ������."), 1; }
    else return 1;
    if (gMoney[playerid] < price) return SendClientMessage(playerid, COLOR_RED, "������������ ����� ��� ������� ��������."), 1;
    gMoney[playerid] -= price; GivePlayerMoney(playerid, -price);
    if (licenseType == 2) gLicenseWeapon[playerid] = 1;
    else if (licenseType == 3) gLicenseBoat[playerid] = 1;
    else gLicenseAir[playerid] = 1;
    SavePlayer(playerid);
    SendClientMessage(playerid, COLOR_GREEN, "�����������! �������� ������� �����������.");
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(!gLogged[playerid] && dialogid!=DIALOG_LOGIN && dialogid!=DIALOG_REGISTER) return 1;
    if(gLogged[playerid] && (dialogid==DIALOG_LOGIN || dialogid==DIALOG_REGISTER)) return 1;
    if(gLogged[playerid] && !gRPLoaded[playerid]) return 1;
    if(!gLogged[playerid] && (dialogid==DIALOG_LOGIN || dialogid==DIALOG_REGISTER)
        && VX_CheckBanBeforeAuth(playerid)) return 1;
    if (dialogid == DIALOG_ADMIN_SPEC)
    {
        if(!response) return 1;
        new targetid=gVXSpec[playerid];
        if(!VX_Admin(playerid) || !VX_Valid(targetid))
            return SendClientMessage(playerid,COLOR_RED,"���������� ��������� ��� ���� �����������."),1;
        switch(listitem)
        {
            case 0:
            {
                if(gAdmin[playerid]<3) return SendClientMessage(playerid,COLOR_RED,"��� �������� � 3 ������ �������������."),1;
                gVXSpecAction[playerid]=1;
                return VX_Show(playerid,DIALOG_ADMIN_SPEC_INPUT,DIALOG_STYLE_INPUT,"VEXORIUM | ��� ������","������� ������ � �������. 0 = ��������.\n������: 60 ����","��������","�����");
            }
            case 1:
            {
                if(gAdmin[playerid]<2) return SendClientMessage(playerid,COLOR_RED,"��� �������� �� 2 ������ �������������."),1;
                gVXSpecAction[playerid]=2;
                return VX_Show(playerid,DIALOG_ADMIN_SPEC_INPUT,DIALOG_STYLE_INPUT,"VEXORIUM | ��� ������","������� ������� ����������:","�������","�����");
            }
            case 2:
            {
                if(gAdmin[playerid]<2) return SendClientMessage(playerid,COLOR_RED,"��� �������� �� 2 ������ �������������."),1;
                gVXSpecAction[playerid]=3;
                return VX_Show(playerid,DIALOG_ADMIN_SPEC_INPUT,DIALOG_STYLE_INPUT,"VEXORIUM | �������� � ���","������� ������� ����������:","��������","�����");
            }
            case 3:
            {
                if(gAdmin[playerid]<2) return SendClientMessage(playerid,COLOR_RED,"������������ �������� �� 2 ������ �������������."),1;
                if(!gIsJailed[targetid]) return SendClientMessage(playerid,COLOR_YELLOW,"����� �� ��������� � ���."),1;
                RP_Release(targetid,playerid,"Admin release from spec panel");
                return VX_ShowSpecActions(playerid);
            }
            case 4:
            {
                if(gAdmin[playerid]<2) return SendClientMessage(playerid,COLOR_RED,"�������������� �������� �� 2 ������ �������������."),1;
                gVXSpecAction[playerid]=4;
                return VX_Show(playerid,DIALOG_ADMIN_SPEC_INPUT,DIALOG_STYLE_INPUT,"VEXORIUM | ��������������","������� ������� ��������������:","������","�����");
            }
            case 5:
            {
                if(gAdmin[playerid]<2 || !VX_AdminCanAct(playerid,targetid,2))
                    return SendClientMessage(playerid,COLOR_RED,"��� ������� 2 �������; ������ ������ ����, ��������� ��� �������������� �������/�������� ������."),1;
                gVXSpecAction[playerid]=5;
                return VX_Show(playerid,DIALOG_ADMIN_SPEC_INPUT,DIALOG_STYLE_INPUT,"VEXORIUM | ��� ������","������� ������ � �������. ������: 10 ����","������ ���","�����");
            }
            case 6:
            {
                new Float:hp,Float:armour,info[256];
                GetPlayerHealth(targetid,hp);GetPlayerArmour(targetid,armour);
                format(info,sizeof info,"����: %s [%d]\n������� ���������: %d\n�����-�������: %d\n��������: %.1f | �����: %.1f\n������: %d / 6\n���: %d | ��������: %d",
                    gName[targetid],targetid,gLevel[targetid],gAdmin[targetid],hp,armour,gWantedLevel[targetid],GetPlayerVirtualWorld(targetid),GetPlayerInterior(targetid));
                SendClientMessage(playerid,COLOR_ORANGE,info);
                return VX_ShowSpecActions(playerid);
            }
            case 7: return VX_StopSpec(playerid);
        }
        return VX_ShowSpecActions(playerid);
    }
    if (dialogid == DIALOG_ADMIN_SPEC_INPUT)
    {
        if(!response) { gVXSpecAction[playerid]=0; return VX_ShowSpecActions(playerid); }
        new targetid=gVXSpec[playerid];
        if(!VX_Admin(playerid) || !VX_Valid(targetid)) return 1;
        new clean[120],token[24],rest[128],minutes=0;
        VX_CleanText(inputtext,clean,sizeof clean);
        if(gVXSpecAction[playerid]==1)
        {
            GetToken(clean,0,token,sizeof token);minutes=strval(token);GetParams(clean,rest,sizeof rest);
            if(!token[0] || minutes<0 || minutes>525600 || strlen(rest)<3)
                return VX_Show(playerid,DIALOG_ADMIN_SPEC_INPUT,DIALOG_STYLE_INPUT,"VEXORIUM | ��� ������","������: ������ �������. 0 = ��������.","��������","�����");
            VX_AdminBanTarget(playerid,targetid,minutes,rest);
            gVXSpecAction[playerid]=0;return 1;
        }
        if(gVXSpecAction[playerid]==5)
        {
            new muteMinutesToken[24], muteReason[96];
            GetToken(clean,0,muteMinutesToken,sizeof muteMinutesToken);
            minutes=strval(muteMinutesToken);
            GetParams(clean,muteReason,sizeof muteReason);
            if(minutes<1 || minutes>1440 || strlen(muteReason)<3 || !VX_AdminCanAct(playerid,targetid,2))
                return VX_Show(playerid,DIALOG_ADMIN_SPEC_INPUT,DIALOG_STYLE_INPUT,"VEXORIUM | ��� ������","������: ������ �������. ���� 1-1440 �����.","������ ���","�����");
            gAdminMuteUntil[targetid]=gettime()+minutes*60;
            format(gAdminMuteReason[targetid],96,"%s",muteReason);
            new muteMessage[180];
            format(muteMessage,sizeof muteMessage,"[MUTE] %s ������� ��� �� %d ���. �������: %s",gName[targetid],minutes,muteReason);
            SendClientMessageToAll(COLOR_ORANGE,muteMessage);
            SendClientMessage(targetid,COLOR_RED,"������������� ����� ��� ���.");
            gVXSpecAction[playerid]=0;
            return VX_ShowSpecActions(playerid);
        }
        if(strlen(clean)<3) return SendClientMessage(playerid,COLOR_YELLOW,"������� ������� �� ������ 3 ��������."),VX_ShowSpecActions(playerid);
        if(gVXSpecAction[playerid]==2) { VX_AdminKickTarget(playerid,targetid,clean); gVXSpecAction[playerid]=0; return 1; }
        if(gVXSpecAction[playerid]==3)
        {
            if(gAdmin[playerid]<2) return SendClientMessage(playerid,COLOR_RED,"������������ ����."),1;
            RP_StartJail(playerid,targetid,RP_JAIL_DEFAULT,clean,1);gVXSpecAction[playerid]=0;
            if(VX_Valid(targetid)) return VX_ShowSpecActions(playerid);
            return 1;
        }
        if(gVXSpecAction[playerid]==4) { VX_AdminWarnTarget(playerid,targetid,clean);gVXSpecAction[playerid]=0;return VX_ShowSpecActions(playerid); }
        gVXSpecAction[playerid]=0;return VX_ShowSpecActions(playerid);
    }
    if (dialogid == DIALOG_HOUSE_CAPTCHA)
    {
        new hid = gHousePending[playerid];
        if (!response || hid < 1 || hid > VX_HOUSE_COUNT)
        {
            gHousePending[playerid] = 0;
            return SendClientMessage(playerid, COLOR_YELLOW, "������ ���� ��������."), 1;
        }
        if (strval(inputtext) != gHouseCaptchaA[playerid] + gHouseCaptchaB[playerid])
        {
            gHousePending[playerid] = 0;
            return SendClientMessage(playerid, COLOR_RED, "�������� �����. ���������� ������ ��� ��� ���."), 1;
        }
        return VX_HouseCompletePurchase(playerid, hid);
    }
    if (dialogid == DIALOG_ORG_INVITE)
    {
        new inviter = gOrgInviteFrom[playerid];
        gOrgInviteFrom[playerid] = INVALID_PLAYER_ID;
        if (!response) return SendClientMessage(playerid, COLOR_YELLOW, "�� ���������� �� ����������� � �����������."), 1;
        if (inviter < 0 || inviter >= MAX_PLAYERS || !IsPlayerConnected(inviter) || !gLogged[inviter] || gFaction[inviter] == FACTION_NONE || gFactionRank[inviter] < 8 || gFaction[playerid] != FACTION_NONE || !VX_Near(playerid, inviter, 8.0) || !IsInOwnOrgInterior(inviter))
            return SendClientMessage(playerid, COLOR_RED, "����������� ��������. ��������� ����������� ��������� �����."), 1;
        gFaction[playerid] = gFaction[inviter]; gFactionRank[playerid] = 1;
        SetPlayerSkin(playerid, VX_RespawnSkin(playerid)); SavePlayer(playerid); UpdatePlayerRoleColor(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "�� ������� � �����������. ����������� /org � /orgmembers.");
        SendClientMessage(inviter, COLOR_GREEN, "����� ������ ����������� � �����������.");
        return 1;
    }
    if(dialogid==DIALOG_CLOTHES || dialogid==DIALOG_CLOTHES_CONFIRM)
    {
        if(!response)
        {
            VX_ClothesCancel(playerid);
            return 1;
        }
        if(dialogid==DIALOG_CLOTHES)
        {
            if(listitem<0 || listitem>=VX_CLOTHES_COUNT || !VX_ClothesCanUse(playerid))
                return SendClientMessage(playerid,COLOR_RED,"[������] �������� ����������. ��������� ������������ � �����."),1;
            gVXClothesBefore[playerid]=GetPlayerSkin(playerid);
            gVXClothesPreview[playerid]=listitem;
            SetPlayerSkin(playerid,gVXClothesModel[listitem]);
            new confirm[160];
            format(confirm,sizeof confirm,"�����: %s\n����: %d\n����: %d ���.\n\n������ ���� ��������?",
                gVXClothesLabel[listitem],gVXClothesModel[listitem],gVXClothesPrice[listitem]);
            ShowPlayerDialog(playerid,DIALOG_CLOTHES_CONFIRM,DIALOG_STYLE_MSGBOX,"VEXORIUM | ��������",confirm,"������","������");
            return 1;
        }
        new index=gVXClothesPreview[playerid];
        if(index<0 || index>=VX_CLOTHES_COUNT)return 1;
        if(!VX_ClothesNear(playerid) || !VX_ClothesCanUse(playerid))
        {
            VX_ClothesCancel(playerid);
            return SendClientMessage(playerid,COLOR_RED,"[������] ������� ��������: ������� ������� ��� ������ �����."),1;
        }
        if(!VX_ClothesBuy(playerid,index))VX_ClothesCancel(playerid);
        return 1;
    }
    if(RP_DialogGuard(playerid,dialogid)) return 1;
    if(VX_Dialog(playerid,dialogid,response,listitem,inputtext)) return 1;
    if(gVXHospital[playerid] && dialogid!=DIALOG_VEX_HUD_FONT) return 1;
    if(dialogid==DIALOG_ITEM_INVENTORY) return VX_ShowInventory(playerid);
    if(dialogid==DIALOG_PHONE) return VX_ShowPhone(playerid);
    if(dialogid==DIALOG_PHONE_SMS_TARGET || dialogid==DIALOG_PHONE_SMS_TEXT) return 1;
    if(dialogid==DIALOG_POLICE_TABLET) return VX_Tablet(playerid);
    if(dialogid==DIALOG_ORG_MENU && gFaction[playerid]==FACTION_HOSPITAL) return ShowOrgMenu(playerid);
    if(dialogid==DIALOG_FACTION_GARAGE && gFaction[playerid]==FACTION_HOSPITAL && !VX_Medic(playerid)) return 1;
    if (dialogid == DIALOG_VEX_HUD_FONT)
    {
        if (!response || !gLogged[playerid]) return 1;
        if (listitem >= 0 && listitem < VEX_HUD_FONT_COUNT) SetVexHudFont(playerid, listitem);
        return 1;
    }

    if (dialogid == DIALOG_ITEM_INVENTORY)
    {
        if (!response) return 1;
        if (listitem == 0)
        {
            if (gMedkits[playerid] < 1) return SendClientMessage(playerid, COLOR_RED, "[INV] � ��� ��� �������."), 1;
            new Float:hp; GetPlayerHealth(playerid, hp);
            if (hp >= 100.0) return SendClientMessage(playerid, COLOR_YELLOW, "[INV] �������� ������������� �� 100%."), 1;
            gMedkits[playerid]--; SetPlayerHealth(playerid, 100.0); SavePlayer(playerid); SendClientMessage(playerid, COLOR_GREEN, "[INV] �� ������������ �������. �������� �������������." );
            new medText[128]; format(medText, sizeof medText, "* %s ������ ������� � ��������� ����.", gName[playerid]); SendLocalMessage(playerid, COLOR_PINK, medText, 20.0);
        }
        else if (listitem == 1)
        {
            if (gFood[playerid] < 1) return SendClientMessage(playerid, COLOR_RED, "[INV] � ��� ��� ���."), 1;
            new Float:hp; GetPlayerHealth(playerid, hp); if (hp < 95.0) SetPlayerHealth(playerid, hp + 5.0); gFood[playerid]--; SavePlayer(playerid); SendClientMessage(playerid, COLOR_GREEN, "[INV] �� �����. ��� ������������." );
            new foodText[128]; format(foodText, sizeof foodText, "* %s ������ ��� � ����� ����.", gName[playerid]); SendLocalMessage(playerid, COLOR_PINK, foodText, 20.0);
        }
        else if (listitem == 2)
        {
            if (gWater[playerid] < 1) return SendClientMessage(playerid, COLOR_RED, "[INV] � ��� ��� ����."), 1;
            gWater[playerid]--; SavePlayer(playerid); SendClientMessage(playerid, COLOR_GREEN, "[INV] �� ������ ����." );
            new waterText[128]; format(waterText, sizeof waterText, "* %s ������ ������� ���� � ������ ��������� �������.", gName[playerid]); SendLocalMessage(playerid, COLOR_PINK, waterText, 20.0);
        }
        else if (listitem == 3)
        {
            SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
            new shopText[512];
            shopText[0] = '\0';
            strcat(shopText, "�������� | ������ ���� - 1 500 ���.\n");
            strcat(shopText, "�������� | ������� ����� - 2 500 ���.\n");
            strcat(shopText, "�������� | �����-���� - 3 500 ���.\n");
            strcat(shopText, "����� | ���������� ����� - 7 500 ���.\n");
            strcat(shopText, "����� | ��������� ����� - 9 000 ���.\n");
            strcat(shopText, "������� | ������� ���� - 15 000 ���.\n");
            strcat(shopText, "������� | ������������ ����� - 22 000 ���.\n");
            strcat(shopText, "����� | ��������� ����� - 35 000 ���.\n");
            strcat(shopText, "����� | ������������� ����� - 55 000 ���.\n");
            strcat(shopText, "VIP | ����������� ��������� - 85 000 ���.\n");
            strcat(shopText, "�������� /inv, ����� ������ ��� �����");
            ShowPlayerDialog(playerid, DIALOG_SHOP_ACC, DIALOG_STYLE_LIST, "VEXORIUM | ������� �����������", shopText, "�������", "�������");
        }
        else if (listitem == 4)
        {
            if (gAccessoryModel[playerid] <= 0) return SendClientMessage(playerid, COLOR_YELLOW, "[���������] � ��� ��� ����������. ������ ��� ����� /shopacc."), 1;
            if (IsPlayerAttachedObjectSlotUsed(playerid, 0)) RemovePlayerAttachedObject(playerid, 0);
            if (!SetPlayerAttachedObject(playerid, 0, gAccessoryModel[playerid], 2, 0.10, 0.02, 0.00, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0)) return SendClientMessage(playerid, COLOR_RED, "[���������] �� ������� ������ ���������."), 1;
            new accText[128]; format(accText, sizeof accText, "* %s ����� ���������.", gName[playerid]); SendLocalMessage(playerid, COLOR_PINK, accText, 20.0);
            SendClientMessage(playerid, COLOR_GREEN, "[���������] ��������� �����.");
        }
        else if (listitem == 5)
        {
            if (IsPlayerAttachedObjectSlotUsed(playerid, 0)) RemovePlayerAttachedObject(playerid, 0);
            new accText[128]; format(accText, sizeof accText, "* %s ���� ���������.", gName[playerid]); SendLocalMessage(playerid, COLOR_PINK, accText, 20.0);
            SendClientMessage(playerid, COLOR_GREEN, "[���������] ��������� ���� � ������� � ���������.");
        }
        return 1;
    }
    if (dialogid == DIALOG_PHONE)
    {
        if (!response) return 1;
        if (listitem == 0) ShowPlayerDialog(playerid, DIALOG_PHONE_SMS_TARGET, DIALOG_STYLE_INPUT, "VEXORIUM | SMS", "������� ID ������, �������� ����� ���������� SMS:", "�����", "������");
        else if (listitem == 1) OnPlayerCommandText(playerid, "/gps");
        else if (listitem == 2)
        {
            new Float:cx, Float:cy, Float:cz, dispatch[160]; GetPlayerPos(playerid, cx, cy, cz);
            format(dispatch, sizeof dispatch, "[112] ����� �������: %s (ID %d), ���������� %.1f, %.1f, %.1f", gName[playerid], playerid, cx, cy, cz);
            for (new i = 0; i < MAX_PLAYERS; i++) if (IsPlayerConnected(i) && gLogged[i] && gFaction[i] == FACTION_POLICE) SendClientMessage(i, COLOR_YELLOW, dispatch);
            SendClientMessage(playerid, COLOR_GREEN, "[112] ����� ��������� ����������� �������." );
        }
        else if (listitem == 3)
        {
            new Float:cx, Float:cy, Float:cz, dispatch[160]; GetPlayerPos(playerid, cx, cy, cz);
            format(dispatch, sizeof dispatch, "[103] ����� ������: %s (ID %d), ���������� %.1f, %.1f, %.1f", gName[playerid], playerid, cx, cy, cz);
            for (new i = 0; i < MAX_PLAYERS; i++) if (IsPlayerConnected(i) && gLogged[i] && gFaction[i] == FACTION_HOSPITAL) SendClientMessage(i, COLOR_YELLOW, dispatch);
            SendClientMessage(playerid, COLOR_GREEN, "[103] ����� ��������� ����������� ��������." );
        }
        else if (listitem == 5) OnPlayerCommandText(playerid, "/taxi");
        else { new msg[96]; format(msg, sizeof msg, "[VEXORIUM] ��� ID: %d. ��������� ��� �������.", playerid); SendClientMessage(playerid, COLOR_GREEN, msg); }
        return 1;
    }
    if (dialogid == DIALOG_PHONE_SMS_TARGET)
    {
        if (!response) return 1;
        new targetid = strval(inputtext);
        if (targetid < 0 || targetid >= MAX_PLAYERS || targetid == playerid || !IsPlayerConnected(targetid) || !gLogged[targetid]) return SendClientMessage(playerid, COLOR_RED, "[SMS] ����� �� ������."), 1;
        gPhoneSmsTarget[playerid] = targetid;
        ShowPlayerDialog(playerid, DIALOG_PHONE_SMS_TEXT, DIALOG_STYLE_INPUT, "VEXORIUM | SMS", "�������� ����� SMS (�� 120 ��������):", "���������", "������");
        return 1;
    }
    if (dialogid == DIALOG_PHONE_SMS_TEXT)
    {
        if (!response) return 1;
        new targetid = gPhoneSmsTarget[playerid], msg[160], outgoing[192];
        if (targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid) || !gLogged[targetid]) return SendClientMessage(playerid, COLOR_RED, "[SMS] ����� ����������."), 1;
        if (strlen(inputtext) < 1) return SendClientMessage(playerid, COLOR_RED, "[SMS] ������ ��������� ������ ���������."), 1;
        format(outgoing, sizeof outgoing, "[SMS] �� %s: %s", gName[playerid], inputtext); SendClientMessage(targetid, COLOR_YELLOW, outgoing);
        format(msg, sizeof msg, "[SMS] �� ��������� %s: %s", gName[targetid], inputtext); SendClientMessage(playerid, COLOR_GREEN, msg); gPhoneSmsTarget[playerid] = INVALID_PLAYER_ID;
        return 1;
    }
    if (dialogid == DIALOG_SHOP_ACC)
    {
        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
        if (!response) return 1;
        if (listitem == 10)
        {
            ShowPlayerDialog(playerid, DIALOG_ITEM_INVENTORY, DIALOG_STYLE_LIST, "VEXORIUM | ���������", "������������ �������\n������ ���\n������ ����\n������� �����������\n������ ���������\n����� ���������", "�������", "�������");
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
        if (gMoney[playerid] < price) return SendClientMessage(playerid, COLOR_RED, "[����������] ������������ ����� ��� �������."), 1;
        if (!TakeCash(playerid, price)) return SendClientMessage(playerid, COLOR_RED, "[����������] �� ������� �������� ������."), 1;
        gAccessoryModel[playerid] = model;
        new buyAccText[144]; format(buyAccText, sizeof buyAccText, "* %s bought an accessory.", gName[playerid]); SendLocalMessage(playerid, COLOR_PINK, buyAccText, 20.0);
        SavePlayer(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "[����������] ������� ���������. �������� /inv � �������� ���������.");
        return 1;
    }
    if (dialogid == DIALOG_SHOP)
    {
        if (!response) return 1;
        if (!gMarketInside[playerid] || GetPlayerVirtualWorld(playerid) != VX_MARKET_WORLD ||
            GetPlayerInterior(playerid) != VX_MARKET_INTERIOR ||
            !IsPlayerInRangeOfPoint(playerid, 3.5, VX_MARKET_COUNTER_X, VX_MARKET_COUNTER_Y, VX_MARKET_COUNTER_Z))
            return SendClientMessage(playerid, COLOR_RED, "��� ������� ��������� � ����� ������ ������� 24/7."), 1;
        new item = listitem < 3 ? listitem : listitem - 1;
        if(listitem==3)
        {
            if(!VX_CanCarry(playerid,1,1) || !VX_CanCarry(playerid,2,1) || VX_Weight(playerid)>VX_WEIGHT_LIMIT-1000) return SendClientMessage(playerid,COLOR_RED,"��������� ��������."),1;
        }
        else if(listitem<0 || listitem>6 || !VX_CanCarry(playerid,item,1)) return SendClientMessage(playerid,COLOR_RED,"��������� �������� ��� ������ �������� �������."),1;
        new price = 0;
        if (listitem == 0) price = 1200; else if (listitem == 1) price = 250; else if (listitem == 2) price = 180; else if (listitem == 3) price = 350; else if (listitem == 4) price = 3000; else if (listitem == 5) price = 1500; else if (listitem == 6) price = 8000; else return 1;
        if (gMoney[playerid] < price) return SendClientMessage(playerid, COLOR_RED, "[SHOP] ������������ �����."), 1;
        if (listitem == 0) gMedkits[playerid]++;
        else if (listitem == 1) gFood[playerid]++;
        else if (listitem == 2) gWater[playerid]++;
        else if (listitem == 3) { gFood[playerid]++; gWater[playerid]++; }
        else if (listitem == 4) gRepairKits[playerid]++;
        else if (listitem == 5) gSimCards[playerid]++;
        else if (listitem == 6) gLockpicks[playerid]++;
        gMoney[playerid] -= price; GivePlayerMoney(playerid, -price); SavePlayer(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "[SHOP] ������ �������. �������� ��������� � ���������." );
        return 1;
    }
    if (dialogid == DIALOG_LICENSE_MARKET)
    {
        if (!response) return 1;
        if (GetPlayerInterior(playerid) != 3 || GetPlayerVirtualWorld(playerid) != 101 || !IsPlayerInRangeOfPoint(playerid, 5.0, 362.4587, 174.0056, 1008.3828))
            return SendClientMessage(playerid, COLOR_RED, "��������� � ������ �������� � �����."), 1;
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
            return SendClientMessage(playerid, COLOR_RED, "��������� � ������ ���������� �������� � �����."), 1;
        if (gHasPassport[playerid]) return SendClientMessage(playerid, COLOR_GREEN, "� ��� ��� ���� �������."), 1;
        gHasPassport[playerid] = 1;
        new passportQuery[160];
        format(passportQuery, sizeof passportQuery, "UPDATE accounts SET has_passport=1 WHERE name='%q'", gName[playerid]);
        new DBResult:passportRes = db_query(gDatabase, passportQuery); if (passportRes) db_free_result(passportRes);
        SendClientMessage(playerid, COLOR_GREEN, "������� ������� ��������! ������ ��� �������� ���������� �� ������ � ��������� ������.");
        return 1;
    }
    if (dialogid == DIALOG_AUTOSCHOOL)
    {
        if (!response) return SendClientMessage(playerid, COLOR_YELLOW, "������� �������."), 1;
        if (!gLogged[playerid] || GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0 || !IsPlayerInRangeOfPoint(playerid, 4.0, -2026.8, -96.5, 35.2))
            return SendClientMessage(playerid, COLOR_RED, "��������� � ����������� ��������� ��� ���."), 1;
        if (gLicenseDriver[playerid]) return SendClientMessage(playerid, COLOR_GREEN, "� ��� ��� ���� ������������ ��������."), 1;
        if (gDrivingTestStage[playerid] > 0) return SendClientMessage(playerid, COLOR_YELLOW, "�� ��� ��������� �������."), 1;
        if (IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_RED, "������� �� ���������� ����� ������� ��������."), 1;
        // Park the exam vehicle on the open roadside outside the school, not at the entrance/building.
        gDrivingTestVehicle[playerid] = CreateVehicle(405, -2039.5, -100.0, 35.2, 270.0, 1, 1, 600);
        if (gDrivingTestVehicle[playerid] == INVALID_VEHICLE_ID) return SendClientMessage(playerid, COLOR_RED, "�� ������� ������� ������� ������. ���������� �����."), 1;
        gDrivingTestStage[playerid] = 1;
        PutPlayerInVehicle(playerid, gDrivingTestVehicle[playerid], 0);
        DisablePlayerCheckpoint(playerid);
        SetPlayerCheckpoint(playerid, -2232.5854, 69.5824, 35.1718, 5.0);
        SendClientMessage(playerid, COLOR_GREEN, "������� ������ ����������. �������� �� ������� ������, �� ������� ������." );
        return 1;
    }
    if (dialogid == DIALOG_POLICE_TABLET) return 1;
    if (dialogid == DIALOG_POLICE_STASH)
    {
        if (!response) return 1;
        if (gFaction[playerid] == FACTION_FBI)
        {
            if (gFactionRank[playerid] < 1 || !IsInOwnOrgInterior(playerid) || GetPlayerDistanceFromPoint(playerid, 258.5231, 76.3146, 1003.6406) > 4.0)
                return SendClientMessage(playerid, COLOR_RED, "FBI: ��������� � ������� ���������� ������."), 1;
            switch (listitem)
            {
                case 0: { GivePlayerWeapon(playerid, 23, 30); SendClientMessage(playerid, COLOR_GREEN, "������ USP ����� (30 ��������)."); }
                case 1: { GivePlayerWeapon(playerid, 25, 60); SendClientMessage(playerid, COLOR_GREEN, "�� �������� �������� � 60 ��������."); }
                case 2: { GivePlayerWeapon(playerid, 29, 120); SendClientMessage(playerid, COLOR_GREEN, "�� �������� MP5 � 120 ��������."); }
                case 3: { GivePlayerWeapon(playerid, 30, 120); SendClientMessage(playerid, COLOR_GREEN, "�� �������� ��-47 � 120 ��������."); }
                case 4: { GivePlayerWeapon(playerid, 31, 120); SendClientMessage(playerid, COLOR_GREEN, "�� �������� �4 � 120 ��������."); }
                case 5: { GivePlayerWeapon(playerid, 33, 20); SendClientMessage(playerid, COLOR_GREEN, "�� �������� �������� � 20 ��������."); }
                case 6: { SetPlayerArmour(playerid, 100.0); SendClientMessage(playerid, COLOR_GREEN, "�� �������� ����������."); }
            }
            return 1;
        }
        else if (gFaction[playerid] != FACTION_POLICE || !IsInPoliceStation(playerid) || GetPlayerDistanceFromPoint(playerid, 258.52, 76.8268, 1003.6406) > 4.0)
            return SendClientMessage(playerid, COLOR_RED, "�� ������ ���������� � ������ LSPD."), 1;
        switch (listitem)
        {
            case 0: { GivePlayerWeapon(playerid, 3, 1); SendClientMessage(playerid, COLOR_GREEN, "[�������] ������ �������."); }
            case 1: { GivePlayerWeapon(playerid, 31, 100); SendClientMessage(playerid, COLOR_GREEN, "�� �������� M4 � 100 �������� �������� �� ���� ���������."); }
            case 2: { GivePlayerWeapon(playerid, 22, 100); SendClientMessage(playerid, COLOR_GREEN, "�� �������� �������� � 100 �������� �������� �� ���� ���������."); }
            case 3: { SetPlayerArmour(playerid, 100.0); SendClientMessage(playerid, COLOR_GREEN, "�� �������� ����������."); }
        }
        return 1;
    }
    if (dialogid == DIALOG_ORG_STASH)
    {
        if (!response) return 1;
        if (gFaction[playerid] < 1 || gFaction[playerid] > 6 || gFaction[playerid] == FACTION_POLICE || gFactionRank[playerid] < 1 || !IsInOwnOrgInterior(playerid))
            return SendClientMessage(playerid, COLOR_RED, "������ � ������ ����������� �������."), 1;
        new query[192], stockAmmo = 0, stockArmour = 0;
        format(query, sizeof query, "SELECT ammo,armour FROM org_stashes WHERE faction_id=%d", gFaction[playerid]);
        new DBResult:orgStock = db_query(gDatabase, query);
        if (orgStock && db_num_rows(orgStock)) { stockAmmo = db_get_field_int(orgStock, 0); stockArmour = db_get_field_int(orgStock, 1); }
        if (orgStock) db_free_result(orgStock);
        if (listitem == 0 || listitem == 1)
        {
            new ammoTake = (stockAmmo > 100) ? 100 : stockAmmo;
            if (ammoTake <= 0) return SendClientMessage(playerid, COLOR_RED, "�� ������ ��� ��������."), 1;
            new weaponid = (listitem == 0) ? 31 : 22;
            GivePlayerWeapon(playerid, weaponid, ammoTake);
            format(query, sizeof query, "UPDATE org_stashes SET ammo=MAX(0,ammo-%d) WHERE faction_id=%d", ammoTake, gFaction[playerid]);
            orgStock = db_query(gDatabase, query); if (orgStock) db_free_result(orgStock);
            new msg[112]; format(msg, sizeof msg, "�� �������� ������ � %d �������� �� ������ �����������.", ammoTake); SendClientMessage(playerid, COLOR_GREEN, msg);
        }
        else if (listitem == 2)
        {
            if (stockArmour < 1) return SendClientMessage(playerid, COLOR_RED, "�� ������ ����������� �����������."), 1;
            SetPlayerArmour(playerid, 100.0);
            format(query, sizeof query, "UPDATE org_stashes SET armour=MAX(0,armour-1) WHERE faction_id=%d", gFaction[playerid]);
            orgStock = db_query(gDatabase, query); if (orgStock) db_free_result(orgStock);
            SendClientMessage(playerid, COLOR_GREEN, "�� �������� ����������. ����� ������ �� ������.");
        }
        else if (listitem == 3)
        {
            new msg[192];
            format(query, sizeof query, "SELECT money,materials,ammo,armour FROM org_stashes WHERE faction_id=%d", gFaction[playerid]);
            orgStock = db_query(gDatabase, query);
            if (orgStock && db_num_rows(orgStock)) format(msg, sizeof msg, "������: %d ���.\n���������: %d\n�������: %d\n�����������: %d", db_get_field_int(orgStock,0), db_get_field_int(orgStock,1), db_get_field_int(orgStock,2), db_get_field_int(orgStock,3));
            else format(msg, sizeof msg, "�� ������� ��������� ������ ������.");
            if (orgStock) db_free_result(orgStock);
            ShowPlayerDialog(playerid, DIALOG_HELP, DIALOG_STYLE_MSGBOX, "����� �����������", msg, "�������", "");
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
            return SendClientMessage(playerid, COLOR_RED, "�� ������ ���������� �� ���� ����� �����."), 1;
        if (listitem == 0) ShowPlayerDialog(playerid, DIALOG_GANG_DEPOSIT, DIALOG_STYLE_INPUT, "����� ����� | ������", "������� �����, ������� ������ �������� �� �����:", "������", "�����");
        else if (listitem == 1) ShowPlayerDialog(playerid, DIALOG_GANG_WITHDRAW, DIALOG_STYLE_INPUT, "����� ����� | �����", "������� �����, ������� ������ ����� �� ������:", "�����", "�����");
        else if (listitem == 2)
        {
            new msg[96]; format(msg, sizeof msg, "�� ������ �����: %d ���.", GetGangStashMoney(gGang[playerid]));
            SendClientMessage(playerid, COLOR_GREEN, msg);
        }
        else if (listitem == 3) ShowGangWeaponMenu(playerid);
        else if (listitem == 4)
        {
            SetPlayerArmour(playerid, 100.0);
            SendClientMessage(playerid, COLOR_GREEN, "�� �������� ���������� �� ������ �����.");
        }
        return 1;
    }
    if (dialogid == DIALOG_GANG_DEPOSIT || dialogid == DIALOG_GANG_WITHDRAW)
    {
        if (!response) { ShowPlayerDialog(playerid, DIALOG_GANG_STASH, DIALOG_STYLE_LIST, "����� �����", "�������� ������\n����� ������\n������ ������\n������ � �������", "�������", "�������"); return 1; }
        if (gGang[playerid] < 1 || gGang[playerid] > 4) return 1;
        new Float:bx, Float:by, Float:bz;
        GetGangBase(gGang[playerid], bx, by, bz);
        if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0 || GetPlayerDistanceFromPoint(playerid, bx, by, bz) > 12.0)
            return SendClientMessage(playerid, COLOR_RED, "�� ������ ���������� �� ���� ����� �����."), 1;
        new amount = strval(inputtext), stash = GetGangStashMoney(gGang[playerid]), query[160];
        if (amount < 1 || amount > 1000000000) return SendClientMessage(playerid, COLOR_RED, "������� ���������� ����� �� 1 �� 1 000 000 000."), 1;
        if (dialogid == DIALOG_GANG_DEPOSIT)
        {
            if (gMoney[playerid] < amount) return SendClientMessage(playerid, COLOR_RED, "� ��� ������������ �����."), 1;
            gMoney[playerid] -= amount; GivePlayerMoney(playerid, -amount); SetGangStashMoney(gGang[playerid], stash + amount); SavePlayer(playerid);
            SendClientMessage(playerid, COLOR_GREEN, "������ ������� �� ����� ����� �����.");
        }
        else
        {
            if (stash < amount) return SendClientMessage(playerid, COLOR_RED, "�� ������ ������������ �����."), 1;
            gMoney[playerid] += amount; GivePlayerMoney(playerid, amount); SetGangStashMoney(gGang[playerid], stash - amount); SavePlayer(playerid);
            SendClientMessage(playerid, COLOR_GREEN, "������ ����� �� ������ �����.");
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
            return SendClientMessage(playerid, COLOR_RED, "�� ������ �� �������� ������."), 1;
        SetPlayerSkin(playerid, GetGangSkin(gGang[playerid], listitem + 1));
        gVXAccountSkin[playerid] = GetPlayerSkin(playerid);
        SavePlayer(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "�� ����������� � ������ ����� �����. ���� ��������.");
        return 1;
    }
    if (dialogid == DIALOG_GANG_WEAPONS)
    {
        if (!response) { ShowPlayerDialog(playerid, DIALOG_GANG_STASH, DIALOG_STYLE_LIST, "����� �����", "�������� ������\n����� ������\n������ ������\n������ � �������", "�������", "�������"); return 1; }
        if (gGang[playerid] < 1 || gGang[playerid] > 4) return 1;
        if (listitem < 0 || listitem > 6) return 1;
        new Float:weaponBaseX, Float:weaponBaseY, Float:weaponBaseZ;
        GetGangBase(gGang[playerid], weaponBaseX, weaponBaseY, weaponBaseZ);
        if (GetPlayerDistanceFromPoint(playerid, weaponBaseX, weaponBaseY, weaponBaseZ) > 12.0 || GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0)
            return SendClientMessage(playerid, COLOR_RED, "��������� ����� �������� ������ �� ���� ����� �����."), 1;
        new weaponIds[6] = {22,24,25,29,30,31};
        new weaponNames[6][24] = {"�������� 9��", "Desert Eagle", "��������", "MP5", "AK-47", "M4"};
        new weaponid = weaponIds[listitem];
        new ammo = GetGangWeaponAmmo(gGang[playerid], weaponid);
        new msg[144];
        format(msg, sizeof msg, "%s\n�� ������: %d ��������", weaponNames[listitem], ammo);
        ShowPlayerDialog(playerid, DIALOG_GANG_WEAPON_ACTION, DIALOG_STYLE_LIST, msg, "����� �� ������\n�������� �� �����", "�������", "�����");
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
            return SendClientMessage(playerid, COLOR_RED, "��������� ����� �������� ������ �� ���� ����� �����."), 1;
        new weaponid = GetPVarInt(playerid, "GangStashWeapon");
        if (!GangWeaponAllowed(weaponid)) return 1;
        new storedAmmo = GetGangWeaponAmmo(gGang[playerid], weaponid);
        if (listitem == 0)
        {
            if (storedAmmo < 1) return SendClientMessage(playerid, COLOR_RED, "������ ������ ��� �������� ������ ��� �� ������."), 1;
            new ammoTake = (storedAmmo > 100) ? 100 : storedAmmo;
            GivePlayerWeapon(playerid, weaponid, ammoTake);
            SetGangWeaponAmmo(gGang[playerid], weaponid, storedAmmo - ammoTake);
            new takeMsg[128]; format(takeMsg, sizeof takeMsg, "�� �������� ������ � %d ��������. ����� � 100 �� ���� ���������.", ammoTake);
            SendClientMessage(playerid, COLOR_GREEN, takeMsg);
        }
        else
        {
            new currentWeapon = GetPlayerWeapon(playerid);
            new ammo = GetPlayerAmmo(playerid);
            if (currentWeapon != weaponid || ammo < 1) return SendClientMessage(playerid, COLOR_RED, "�������� � ���� ��������� ������ � ���������, ����� ����� �������� �����."), 1;
            SetPlayerAmmo(playerid, weaponid, 0);
            SetGangWeaponAmmo(gGang[playerid], weaponid, storedAmmo + ammo);
            SendClientMessage(playerid, COLOR_GREEN, "������ � ������� ����� �� ����� ����� �����.");
        }
        DeletePVar(playerid, "GangStashWeapon");
        return ShowGangWeaponMenu(playerid);
    }

    if (dialogid == DIALOG_GANG)
    {
        if (!response) return 1;
        if (gFaction[playerid] != FACTION_NONE) return SendClientMessage(playerid, COLOR_RED, "������� ������� �� ��������������� �����������."), 1;
        if (listitem == 4)
        {
            if (gGang[playerid] == 0) return SendClientMessage(playerid, COLOR_YELLOW, "�� �� �������� � �����."), 1;
            gGang[playerid] = 0;
            SetPlayerSkin(playerid, 23);
            if (gAccessoryModel[playerid] > 0) SetPlayerAttachedObject(playerid, 0, gAccessoryModel[playerid], 2, 0.10, 0.02, 0.00, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
            new civText[128];
            format(civText, sizeof civText, "* %s changed into civilian clothes.", gName[playerid]);
            SendLocalMessage(playerid, COLOR_PINK, civText, 20.0);
            SavePlayer(playerid);
            SendClientMessage(playerid, COLOR_GREEN, "�� �������� �����. �� ������� ����������� ������.");
            return 1;
        }
        new Float:gangJoinX[4] = {2495.0, 2000.0, 2769.0, 1840.0};
        new Float:gangJoinY[4] = {-1687.0, -1114.0, -1628.0, -2035.0};
        new Float:gangJoinZ[4] = {13.5, 25.0, 10.9, 13.5};
        if (listitem < 0 || listitem > 3) return 1;
        if (GetPlayerDistanceFromPoint(playerid, gangJoinX[listitem], gangJoinY[listitem], gangJoinZ[listitem]) > 80.0)
            return SendClientMessage(playerid, COLOR_RED, "��� ���������� ���������� �� ���� ��������� �����. ���������� �������� ����� /gps."), 1;
        if (gGang[playerid] != 0) return SendClientMessage(playerid, COLOR_RED, "�� ��� � �����. ������� �������� � ����� /gang."), 1;
        gGang[playerid] = listitem + 1; SetPlayerSkin(playerid, GetGangSkin(gGang[playerid], 1)); if (gAccessoryModel[playerid] > 0) SetPlayerAttachedObject(playerid, 0, gAccessoryModel[playerid], 2, 0.10, 0.02, 0.00, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0); new gangJoinText[128]; format(gangJoinText, sizeof gangJoinText, "* %s ����� ������ �����.", gName[playerid]); SendLocalMessage(playerid, COLOR_PINK, gangJoinText, 20.0); SavePlayer(playerid);
        new gangName[32];
        switch (gGang[playerid]) { case 1: gangName = "Grove Street"; case 2: gangName = "Ballas"; case 3: gangName = "Los Santos Vagos"; case 4: gangName = "Varrios Aztecas"; }
        new msg[96]; format(msg, sizeof msg, "�� �������� � ����� %s! ��� ����: �������.", gangName);
        SendClientMessage(playerid, COLOR_GREEN, msg); return 1;
    }

    if (dialogid == DIALOG_RENT_SCOOTER)
    {
        gPendingScooterChoice[playerid] = false;
        if (!response)
        {
            if (IsPlayerInAnyVehicle(playerid) && GetPlayerVehicleID(playerid) == gBaseScooter)
                RemovePlayerFromVehicle(playerid);
            SendClientMessage(playerid, COLOR_YELLOW, "�� ���������� �� ������. ������ ������� �� ��������� ����.");
            return 1;
        }
        if (!gLogged[playerid] || gFaction[playerid] != FACTION_NONE || gLevel[playerid] > 3)
        {
            if (IsPlayerInAnyVehicle(playerid) && GetPlayerVehicleID(playerid) == gBaseScooter) RemovePlayerFromVehicle(playerid);
            if (gLevel[playerid] > 3)
                return SendClientMessage(playerid, COLOR_RED, "������ �������� ������ ������� 1�3 ������."), 1;
            return SendClientMessage(playerid, COLOR_RED, "������ �������� ������ ����������� ��� �����������."), 1;
        }
        if (gRentalVehicle[playerid] != INVALID_VEHICLE_ID)
            return SendClientMessage(playerid, COLOR_YELLOW, "� ��� ��� ���� ������������ ������."), 1;
        if (gMoney[playerid] < RENT_SCOOTER_PRICE)
        {
            if (IsPlayerInAnyVehicle(playerid) && GetPlayerVehicleID(playerid) == gBaseScooter) RemovePlayerFromVehicle(playerid);
            return SendClientMessage(playerid, COLOR_RED, "��� ������ ����� 250 ������. ������ ������� �� ����."), 1;
        }
        if (gBaseScooter == INVALID_VEHICLE_ID || !IsPlayerInAnyVehicle(playerid) || GetPlayerVehicleID(playerid) != gBaseScooter)
            return SendClientMessage(playerid, COLOR_RED, "������ ��� ����������. ���������� ����� �� ���������."), 1;
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
        SendClientMessage(playerid, COLOR_GREEN, "�� ���������� Faggio �� 250 ������. �� ���������� � ������� ��������� ���� � ����� ��������!");
        SendClientMessage(playerid, COLOR_GREEN, "�� ���� ��� �������� ����� ������ ��� ���������� �������.");
        return 1;
    }

    if (dialogid == DIALOG_CAR_DEALER)
    {
        if(!response) return 1;
        if(GetPlayerInterior(playerid)!=0 || GetPlayerVirtualWorld(playerid)!=0
            || !IsPlayerInRangeOfPoint(playerid,18.0,2131.0,-1150.0,24.1))
            return RP_Message(playerid,"�� ������ �� ����������.");
        new model,price;
        switch(listitem)
        {
            case 0: { model=401; price=75000; }
            case 1: { model=404; price=125000; }
            case 2: { model=436; price=175000; }
            case 3: { model=445; price=225000; }
            case 4: { model=451; price=275000; }
            case 5: { model=560; price=1000000; }
            default: return 1;
        }
        return RP_BuyCar(playerid,model,price);
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
            ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "VEXORIUM | �������� ��������", "================================\n             V E X O R I U M\n\n������ ������ ��������� 4-64 �������.\n����� ������ ��� ���.\n��������� ������, ������� ������� ���������.", "�������", "�����");
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
        // New accounts start with exactly 5,000 cash.
        gMoney[playerid] = 5000; gLevel[playerid] = 1; gExperience[playerid] = 0; gKills[playerid] = 0; gDeaths[playerid] = 0; gJob[playerid] = 0; gFaction[playerid] = 0; gFactionRank[playerid] = 0; gOwnedCarModel[playerid] = 0; gSpawnPreference[playerid] = 0;
        gAdmin[playerid] = IsOwner(playerid) ? 5 : 0;
        gLogged[playerid] = true;
        VX_Load(playerid);
        VX_NeedsLoad(playerid);
        VX_ContractNotify(playerid);
        if(!RP_Load(playerid))
        {
            SendClientMessage(playerid,COLOR_RED,"�� ������� ��������� RP-������. ���� ������� �� ��������� ������ ������.");
            gLogged[playerid]=false;
            Kick(playerid); return 1;
        }
        LoadVexHudSettings(playerid);
        VX_ClothesLoad(playerid,23);
        SendClientMessage(playerid, COLOR_WHITE, "[HUD] ����������: /hud. ��������� ������� ����: /hudfont.");
        if (gAccessoryModel[playerid] > 0) SetPlayerAttachedObject(playerid, 0, gAccessoryModel[playerid], 2, 0.10, 0.02, 0.00, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
        SetPlayerScore(playerid, gLevel[playerid]);
        SpawnLoggedPlayer(playerid, 1685.0, -2333.0, 13.5, 0.0, 23);
        SendClientMessage(playerid, COLOR_GREEN, "����� ���������� �� VEXORIUM RP! ��� ��������� 5000 ������.");
        SendClientMessage(playerid, COLOR_WHITE, "������� /help ��� ������ ������.");
        if (gAdmin[playerid] == 5) SendClientMessage(playerid, COLOR_ORANGE, "[VEXORIUM] ��� �������� ������� ��������� ������� (5).");
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
        if (!authResult) { printf("[VEXORIUM AUTH ERROR] SQLite query failed for %s", gName[playerid]); SendClientMessage(playerid, COLOR_RED, "������ ���� ������ ��� �����. �������� �����."); return 1; }
        if (!db_num_rows(authResult)) { db_free_result(authResult); printf("[VEXORIUM AUTH ERROR] Account row not found for %s", gName[playerid]); Kick(playerid); return 1; }
        new stored[65];
        db_get_field(authResult, 0, stored, sizeof stored);
        if (strcmp(stored, inputtext, false) != 0)
        {
            db_free_result(authResult);
            ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "VEXORIUM | ����� ����������", "================================\n             V E X O R I U M\n\n�������� ������.\n������� ���� � �������� ��� ���.\n������ ������������ � ��������.", "�����", "�����");
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
        gVXAccountSkin[playerid] = (skin >= 1 && skin <= 311) ? skin : 23;
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
        VX_Load(playerid);
        VX_NeedsLoad(playerid);
        VX_ContractNotify(playerid);
        if(!RP_Load(playerid))
        {
            SendClientMessage(playerid,COLOR_RED,"�� ������� ��������� RP-������. ���� ������� �� ��������� ������ ������.");
            gLogged[playerid]=false;
            Kick(playerid); return 1;
        }
        LoadVexHudSettings(playerid);
        VX_ClothesLoad(playerid,skin);
        SendClientMessage(playerid, COLOR_WHITE, "[HUD] ����������: /hud. ��������� ������� ����: /hudfont.");
        if (gAccessoryModel[playerid] > 0) SetPlayerAttachedObject(playerid, 0, gAccessoryModel[playerid], 2, 0.10, 0.02, 0.00, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
        SetPlayerScore(playerid, gLevel[playerid]);
        UpdatePlayerRoleColor(playerid);
        SpawnLoggedPlayer(playerid, x, y, z, a, skin);
        new welcome[144];
        format(welcome, sizeof welcome, "  ����� ����������, %s!", gName[playerid]);
        SendClientMessage(playerid, COLOR_GREEN, "========================================");
        SendClientMessage(playerid, COLOR_GREEN, "  VEXORIUM RP | ���� ������� ����������");
        SendClientMessage(playerid, COLOR_WHITE, welcome);
        SendClientMessage(playerid, COLOR_WHITE, "  ����� ������: /hub | ���������: /inv | �������: /phone");
        SendClientMessage(playerid, COLOR_GREEN, "========================================");
        if (gAdmin[playerid] == 5) SendClientMessage(playerid, COLOR_ORANGE, "[VEXORIUM] � ��� ������� ��������� ������� (5).");
        return 1;
    }
    if (dialogid == DIALOG_FACTION_GARAGE)
    {
        if (!response) return 1;
        if (gFaction[playerid] == FACTION_NONE || gFactionRank[playerid] < 1)
            return SendClientMessage(playerid, COLOR_RED, "�� �� �������� � �����������."), 1;
        if (listitem < 0 || listitem > 4 || gFactionRank[playerid] < (listitem * 2 + 1))
            return SendClientMessage(playerid, COLOR_RED, "��������� �� �������� �� ����� �����."), 1;
        new Float:gx, Float:gy, Float:gz;
        GetOrgGarage(gFaction[playerid], gx, gy, gz);
        if (gFaction[playerid] == FACTION_POLICE)
        {
            if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0 ||
                !IsPlayerInRangeOfPoint(playerid, 10.0, 1579.0, -1719.0, 13.5)) return SendClientMessage(playerid, COLOR_RED, "�� ��� �� � ������."), 1;
        }
        else if (GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0 ||
                 !IsPlayerInRangeOfPoint(playerid, 10.0, gx, gy, gz)) return SendClientMessage(playerid, COLOR_RED, "�� ��� �� � ������."), 1;
        if (IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_YELLOW, "������� ������� �� �������� ����������."), 1;
        // The locked parking-slot vehicle remains available for the next employee.
        // Check the delivery bay BEFORE retiring the previous vehicle.
        new Float:sx,Float:sy,Float:sz,Float:sa;
        new model=GetFactionVehicleModel(gFaction[playerid],listitem);
        if(!VX_FindFreeGarageSpawn(gFaction[playerid],listitem,model,sx,sy,sz,sa))
            return SendClientMessage(playerid,COLOR_YELLOW,"[�����] ��� ���������� ����� ��� ����������. ���������� �����."),1;
        if (gFactionVehicle[playerid] != INVALID_VEHICLE_ID && GetVehicleModel(gFactionVehicle[playerid]) != 0)
        {
            if (IsFleetVehicleOccupied(gFactionVehicle[playerid]))
                return SendClientMessage(playerid, COLOR_YELLOW, "������� ������� ���� ��������� ������."), 1;
            new oldFactionVehicle = gFactionVehicle[playerid];
            if (gVehicleReturnTimer[oldFactionVehicle]) { KillTimer(gVehicleReturnTimer[oldFactionVehicle]); gVehicleReturnTimer[oldFactionVehicle] = 0; }
            gVXFleetAnchored[oldFactionVehicle]=false;
            gVehicleFaction[oldFactionVehicle] = 0;
            gVehicleTier[oldFactionVehicle] = 0;
            gFactionVehicleOwner[oldFactionVehicle] = INVALID_PLAYER_ID;
            DestroyVehicle(oldFactionVehicle);
            gFactionVehicle[playerid] = INVALID_VEHICLE_ID;
        }
        new vehicleid = CreateVehicle(model, sx, sy, sz, sa, 1, 1, 180);
        if (vehicleid == INVALID_VEHICLE_ID || GetVehicleModel(vehicleid) == 0)
            return SendClientMessage(playerid, COLOR_RED, "�� ������� ������ ������. ���������� ��� ���."), 1;
        gFactionVehicle[playerid] = vehicleid;
        gVXFleetAnchored[vehicleid]=false;
        gVehicleFaction[vehicleid] = gFaction[playerid];
        gVehicleTier[vehicleid] = listitem;
        gFactionVehicleOwner[vehicleid] = playerid;
        gVehicleReturnTimer[vehicleid] = 0;
        gVehicleFuel[vehicleid] = 100;
        gFuelLastX[vehicleid] = 0.0; gFuelLastY[vehicleid] = 0.0; gFuelLastZ[vehicleid] = 0.0;
        SetVehicleVirtualWorld(vehicleid, 0);
        // Issued cars are not showroom vehicles: keep them unlocked and mobile.
        SetVehicleParamsEx(vehicleid,VEHICLE_PARAMS_ON,0,0,0,0,0,0);
        for (new p = 0; p < MAX_PLAYERS; p++)
            if (IsPlayerConnected(p)) SetVehicleParamsForPlayer(vehicleid,p,0,0);
        PutPlayerInVehicle(playerid, vehicleid, 0);
        TogglePlayerControllable(playerid,true);
        // OnPlayerStateChange switches the ignition off on entry; re-enable afterwards.
        SetTimerEx("VX_StartIssuedCar",850,false,"ii",playerid,vehicleid);
        new factionName[32], vehicleName[48], garageMsg[160];
        GetFactionName(gFaction[playerid], factionName, sizeof factionName);
        GetFactionVehicleInfo(gFaction[playerid], listitem, vehicleName, sizeof vehicleName);
        format(garageMsg, sizeof garageMsg, "�������� %s: �� ������� %s. � ������� ���������� ���� ������.", factionName, vehicleName);
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
        if (!IsInPoliceStation(playerid)) return SendClientMessage(playerid, COLOR_RED, "�� ����� �� �������."), 1;
        switch (listitem)
        {
            case 0: { SetPlayerPos(playerid, 246.4, 63.9, 1003.6); SetPlayerFacingAngle(playerid, 180.0); }
            case 1: { SetPlayerPos(playerid, 251.4, 68.0, 1003.6); SetPlayerFacingAngle(playerid, 90.0); }
            case 2: { SetPlayerPos(playerid, 253.8, 72.2, 1003.6); SetPlayerFacingAngle(playerid, 0.0); }
            case 3: { SetPlayerPos(playerid, 264.4, 77.5, 1001.0); SetPlayerFacingAngle(playerid, 90.0); }
            case 4:
            {
                if (gFaction[playerid] != FACTION_POLICE || gFactionRank[playerid] < 1)
                    return SendClientMessage(playerid, COLOR_RED, "���������� ������������� ������ ��� ����������� �������."), 1;
                SetPlayerPos(playerid, 255.3, 77.4, 1003.6);
                SetPlayerFacingAngle(playerid, 180.0);
                SendClientMessage(playerid, COLOR_GREEN, "�� � ����������. �������� �� ������ ������, ����� ����������� �� �����.");
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
                SendClientMessage(playerid, COLOR_GREEN, "�� ����� � ������ LSPD. ����������� /garage ��� ������ ������.");
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
            return SendClientMessage(playerid, COLOR_RED, "�� �������� ���� �����������."), 1;
        switch (listitem)
        {
            case 0: { if (gFaction[playerid] == FACTION_FBI) SetPlayerPos(playerid, 246.4510, 65.5860, 1003.6410); else SetPlayerPos(playerid, 2496.0, -1692.0, 1014.7); SendClientMessage(playerid, COLOR_GREEN, "������� ���� �����."); }
            case 1: { if (gFaction[playerid] == FACTION_FBI) SetPlayerPos(playerid, 249.0, 70.0, 1003.6410); else SetPlayerPos(playerid, 2491.0, -1687.0, 1014.7); SendClientMessage(playerid, COLOR_GREEN, "������� ����������� �����������."); }
            case 2: { if (gFaction[playerid] == FACTION_FBI) SetPlayerPos(playerid, 252.0, 75.0, 1003.6410); else SetPlayerPos(playerid, 2501.0, -1687.0, 1014.7); SendClientMessage(playerid, COLOR_GREEN, "������� ��������. ������������ ����� ������������ /formation."); }
            case 3:
            {
                new Float:x, Float:y, Float:z;
                GetOrgGarage(gFaction[playerid], x, y, z);
                SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
                SetPlayerPos(playerid, x - 1.5, y - 2.5, z); SetPlayerFacingAngle(playerid, 90.0);
                SetCameraBehindPlayer(playerid);
                SendClientMessage(playerid, COLOR_GREEN, "�� ����� � ���������. ����������� /garage ��� ���������� ����������.");
                return 1;
            }
            case 4:
            {
                new Float:x, Float:y, Float:z;
                GetOrgExterior(gFaction[playerid], x, y, z);
                SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
                if (gFaction[playerid] == FACTION_FBI)
                {
                    // The door point is next to the building collision; exit farther out toward the open parking area.
                    SetPlayerPos(playerid, 1642.0, -2251.0, 13.5);
                    SetPlayerFacingAngle(playerid, 310.92);
                }
                else
                {
                    SetPlayerPos(playerid, x + 2.0, y, z);
                    SetPlayerFacingAngle(playerid, 90.0);
                }
                SetCameraBehindPlayer(playerid);
                SendClientMessage(playerid, COLOR_GREEN, "�� ����� �� ������ �����������.");
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
        SendClientMessage(playerid, COLOR_YELLOW, "����� ��������� ���������. �� ������ ���������� ����� ��� ��������� ������ � ����� ������. �������� ����� ����� ����� /spawn.");
        return 1;
    }
    if (dialogid == DIALOG_GPS)
    {
        if (!response) return 1;
        if (gWorkStage[playerid] > 0) return SendClientMessage(playerid, COLOR_YELLOW, "������� ������� ��� ������ ������� ������� �������."), 1;
        if (listitem == 0)
            ShowPlayerDialog(playerid, DIALOG_GPS_PUBLIC, DIALOG_STYLE_LIST, "VEXORIUM RP | ������������ �����", "�����\n����\n����\n����������\n����� ������\n���������", "�������", "�����");
        else if (listitem == 1)
            ShowPlayerDialog(playerid, DIALOG_GPS_ORGS, DIALOG_STYLE_LIST, "VEXORIUM RP | �����������", "�����\n������� LSPD\n����\n�����\n���\n���\nFBI � ����������� ����", "�������", "�����");
        else if (listitem == 2)
            ShowPlayerDialog(playerid, DIALOG_GPS_JOBS, DIALOG_STYLE_LIST, "VEXORIUM RP | ������ ��� ��������", "�����\n�������\n�������\n�������\n�������� ��������", "�������", "�����");
        else if (listitem == 3)
            ShowPlayerDialog(playerid, DIALOG_GPS_WORKS, DIALOG_STYLE_LIST, "VEXORIUM RP | �� ������", "��������\n�������\n������������\n�������� ��������\n�����", "�������", "�����");
        else if (listitem == 4)
            ShowPlayerDialog(playerid, DIALOG_GPS_GANGS, DIALOG_STYLE_LIST, "VEXORIUM RP | ����������� �����������", "Grove Street\nBallas\nLos Santos Vagos\nVarrios Los Aztecas\n��������", "�������", "�����");
        else if (listitem == 5)
            ShowPlayerDialog(playerid, DIALOG_GPS_TRANSPORT, DIALOG_STYLE_LIST, "VEXORIUM RP | ��������� � ���", "��������� / ��� ������\n��������� ���\n����������\n���������", "�������", "�����");
        else if (listitem == 6)
            ShowPlayerDialog(playerid, DIALOG_GPS_SHOPS, DIALOG_STYLE_LIST, "VEXORIUM RP | ��������", "��������� ������ 24/7\n��������� ������� ������\n����� � ��������", "�������", "�����");
        else if (listitem == 7)
            ShowPlayerDialog(playerid, DIALOG_GPS_HOUSING, DIALOG_STYLE_LIST, "VEXORIUM RP | ������������", "��������� ��������� ���\n��� ���", "�������", "�����");
        else if (listitem == 8)
            ShowPlayerDialog(playerid, DIALOG_GPS_MEDICAL, DIALOG_STYLE_LIST, "VEXORIUM RP | ��������", "���� � ������� ����\n������ � ��������\n��������� ������ ������", "�������", "�����");
        return 1;
    }
    if (dialogid == DIALOG_GPS_PUBLIC || dialogid == DIALOG_GPS_ORGS || dialogid == DIALOG_GPS_JOBS || dialogid == DIALOG_GPS_GANGS || dialogid == DIALOG_GPS_WORKS
        || dialogid == DIALOG_GPS_TRANSPORT || dialogid == DIALOG_GPS_SHOPS || dialogid == DIALOG_GPS_HOUSING || dialogid == DIALOG_GPS_MEDICAL)
    {
        if (!response) { ShowGPS(playerid); return 1; }
        if (gWorkStage[playerid] > 0) return SendClientMessage(playerid, COLOR_YELLOW, "������� ������� ��� ������ ������� ������� �������."), 1;
        new Float:x, Float:y, Float:z;
        if (dialogid == DIALOG_GPS_PUBLIC)
        {
            switch (listitem)
            {
                case 0: { x = 1481.0; y = -1771.0; z = 18.8; }
                case 1: { x = 1191.0; y = -1307.0; z = 12.1; }
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
                case 2: { x = 1191.0; y = -1307.0; z = 12.1; }
                case 3: { x = 2750.0; y = -2450.0; z = 13.6; }
                case 4: { x = 213.0; y = 1900.0; z = 17.6; }
                case 5: { x = 1685.0; y = -2333.0; z = 13.5; }
                case 6: { x = 1668.0; y = -2258.0; z = 13.5; } // FBI garage
                default: return 1;
            }
        }
        else if (dialogid == DIALOG_GPS_GANGS)
        {
            if (listitem == 4)
            {
                if (!gCarjackActive[playerid] || gCarjackVehicle[playerid] == INVALID_VEHICLE_ID || GetVehicleModel(gCarjackVehicle[playerid]) == 0)
                    return SendClientMessage(playerid, COLOR_YELLOW, "[VEXORIUM] ��������� ������������ � ������ ����� /job, ����� /work."), 1;
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
        else if (dialogid == DIALOG_GPS_WORKS)
        {
            switch (listitem)
            {
                case 0: { x = VX_FIRE_STATION_X; y = VX_FIRE_STATION_Y; z = VX_FIRE_STATION_Z; } // �������� ����� � Commerce
                case 1: { x = 1479.0; y = -1739.0; z = 13.5; } // �����
                case 2: { x = 2195.0; y = -2254.0; z = 13.5; } // ������������
                case 3: { x = 1810.0; y = -1900.0; z = 13.4; } // ���������� ����
                case 4: { x = 820.0; y = 856.0; z = 12.0; } // �����
                default: return 1;
            }
        }
        else if (dialogid == DIALOG_GPS_TRANSPORT)
        {
            switch (listitem)
            {
                case 0:
                {
                    new personalCar = gOwnedCarVehicle[playerid];
                    if (personalCar > 0 && personalCar < MAX_VEHICLES && GetVehicleModel(personalCar) != 0)
                        GetVehiclePos(personalCar, x, y, z);
                    else { x = 2131.0; y = -1150.0; z = 24.1; }
                }
                case 1: if (!VX_GPSNearestGas(playerid, x, y, z)) return SendClientMessage(playerid, COLOR_RED, "��� �� �������."), 1;
                case 2: { x = 1940.0; y = -1772.0; z = 13.4; }
                case 3: { x = -2026.8; y = -96.5; z = 35.2; }
                default: return 1;
            }
        }
        else if (dialogid == DIALOG_GPS_SHOPS)
        {
            switch (listitem)
            {
                case 0: if (!VX_GPSNearestMarket(playerid, x, y, z)) return SendClientMessage(playerid, COLOR_RED, "������� �� �������."), 1;
                case 1: if (!VX_GPSNearestClothes(playerid, x, y, z)) return SendClientMessage(playerid, COLOR_RED, "�������� ������ �� �������."), 1;
                case 2: { x = 1481.0; y = -1771.0; z = 18.8; }
                default: return 1;
            }
        }
        else if (dialogid == DIALOG_GPS_HOUSING)
        {
            if (listitem == 0)
            {
                if (!VX_GPSFindHouse(playerid, 0, x, y, z))
                    return SendClientMessage(playerid, COLOR_YELLOW, "��������� ����� ������ ���."), 1;
            }
            else if (listitem == 1)
            {
                if (!VX_GPSFindHouse(playerid, 1, x, y, z))
                    return SendClientMessage(playerid, COLOR_YELLOW, "� ��� ���� ��� ����. �������� ��������� ��������� ��� � ��������� � ��������."), 1;
            }
            else return 1;
        }
        else if (dialogid == DIALOG_GPS_MEDICAL)
        {
            switch (listitem)
            {
                case 0: { x = 1191.0; y = -1307.0; z = 12.1; }
                case 1: { x = 1180.2; y = -1322.5; z = 13.5; }
                case 2: { x = 1178.0; y = -1323.0; z = 14.1; }
                default: return 1;
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
        SendClientMessage(playerid, COLOR_GREEN, "[VEXORIUM GPS] ������� ������� �� ������. GPS �� ������������� � ������ � �������.");
        return 1;
    }
    if (dialogid == DIALOG_CARJACK_HACK)
    {
        if (!response) return 1;
        if (!gCarjackActive[playerid] || gCarjackVehicle[playerid] == INVALID_VEHICLE_ID || GetVehicleModel(gCarjackVehicle[playerid]) == 0) return 1;
        new Float:x, Float:y, Float:z;
        GetVehiclePos(gCarjackVehicle[playerid], x, y, z);
        if (GetPlayerDistanceFromPoint(playerid, x, y, z) > 5.0) return SendClientMessage(playerid, COLOR_RED, "�� ������ ������� ������ �� ������."), 1;
        if (listitem != gCarjackCode[playerid])
        {
            SendClientMessage(playerid, COLOR_RED, "�������� ������! ����� �� ������. ���������� /hack ��� ���.");
            return 1;
        }
        gCarjackUnlocked[playerid] = true;
        SetVehicleParamsEx(gCarjackVehicle[playerid], 0, 0, 0, 0, 0, 0, 0);
        SetVehicleParamsForPlayer(gCarjackVehicle[playerid], playerid, 0, 0);
        DisablePlayerCheckpoint(playerid);
        // Dispatcher notification is sent when the thief actually starts driving.
        SendClientMessage(playerid, COLOR_GREEN, "����� ������! �������� �� ���� � ��������� ������ �� ���� ����� �����. �� ����� ���������� 100000 ������.");
        return 1;
    }
    if (dialogid == DIALOG_JOB)
    {
        if (!response) return 1;
        if(!RP_Free(playerid) || !gHasPassport[playerid]) return RP_Message(playerid,"��� ������ ����� �������.");
        if(listitem==5 && (gLevel[playerid]<3 || gFaction[playerid]!=FACTION_NONE))
            return RP_Message(playerid,"�������: 3 ������� � ���������� �������� �� �������.");
        if (gWorkStage[playerid] > 0) return SendClientMessage(playerid, COLOR_RED, "������� ��������� ������� �������."), 1;
        if (listitem < 0 || listitem > 6) return 1;
        if (listitem == 4 && gLevel[playerid] < 3) return SendClientMessage(playerid, COLOR_RED, "����������� �������� � 3 ������."), 1;
        gJob[playerid] = listitem + 1;
        // Put the uniform on immediately and persist it for the next login.
        SetPlayerSkin(playerid, VX_RespawnSkin(playerid));
        SavePlayer(playerid);
        if (listitem == 0) SendClientMessage(playerid, COLOR_GREEN, "�� ���������� ���������. ������� /work, ����� ������ �������.");
        else if (listitem == 1) SendClientMessage(playerid, COLOR_GREEN, "�� ���������� ��������������. ������� /work, ����� ������ �������.");
        else if (listitem == 2) SendClientMessage(playerid, COLOR_GREEN, "�� ���������� ��������� ��������. ������� /work, ����� ������ �������.");
        else if (listitem == 3) SendClientMessage(playerid, COLOR_GREEN, "�� ���������� �������. ���������� �� ����� � ������� /work, ����� ������ ������.");
        else if(listitem==4) SendClientMessage(playerid, COLOR_GREEN, "�� ���������� �������������. � 3 ������ ����������� /work, ����� ����� ��������� ������.");
        else if(listitem==6) SendClientMessage(playerid, COLOR_GREEN, "�� ���������� ��������. ������� /work � �������� �����.");
        else RP_Message(playerid,"�� ���������� ���������. /lawyer /clients /prison /defend ID.");
        return 1;
    }
    return 0;
}


public ReleaseJailedPlayer(playerid)
{
    // Compatibility entrypoint. No player-id-only release timers are created.
    if(!VX_Valid(playerid) || !gIsJailed[playerid] || gRPJailLeft[playerid]>0) return 1;
    return RP_Release(playerid,INVALID_PLAYER_ID,"Sentence served");
}

public SavePlayer(playerid)
{
    if (!gLogged[playerid] || gDatabase == DB:0) return 0;
    VX_Save(playerid);
    RP_SaveState(playerid);
    RP_SaveCar(playerid);
    new Float:x, Float:y, Float:z, Float:a, query[1024];
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    format(query, sizeof query,
        "UPDATE accounts SET money=%d,level=%d,experience=%d,kills=%d,deaths=%d,skin=%d,x=%f,y=%f,z=%f,angle=%f,job=%d,admin=%d,faction=%d,faction_rank=%d,spawnpref=%d,gang=%d,license_driver=%d,license_weapon=%d,license_boat=%d,license_air=%d,has_passport=%d,medkits=%d,food=%d,water=%d,accessory=%d,repairkits=%d,simcards=%d,lockpicks=%d WHERE name='%q'",
        gMoney[playerid], gLevel[playerid], gExperience[playerid], gKills[playerid], gDeaths[playerid],
        gVXAccountSkin[playerid], x, y, z, a, gJob[playerid], gAdmin[playerid], gFaction[playerid],
        gFactionRank[playerid], gSpawnPreference[playerid], gGang[playerid], gLicenseDriver[playerid],
        gLicenseWeapon[playerid], gLicenseBoat[playerid], gLicenseAir[playerid], gHasPassport[playerid], gMedkits[playerid], gFood[playerid], gWater[playerid], gAccessoryModel[playerid], gRepairKits[playerid], gSimCards[playerid], gLockpicks[playerid], gName[playerid]);
    gResult = db_query(gDatabase, query);
    if (gResult) db_free_result(gResult);
    return 1;
}



// ================= VEXORIUM: persistent roleplay systems =================
stock VX_SQL(const query[])
{
    // Legacy a_sampdb declares query[] without const. Pass a mutable copy.
    new sqlText[2048];
    if (strlen(query) >= sizeof sqlText)
    {
        gVXDBError = true;
        print("[VEXORIUM UPDATE] SQL query exceeds the compatibility buffer.");
        return 0;
    }
    format(sqlText, sizeof sqlText, "%s", query);
    new DBResult:r = db_query(gDatabase, sqlText);
    if (!r) { gVXDBError = true; print("[VEXORIUM UPDATE] SQLite operation failed."); return 0; }
    db_free_result(r);
    return 1;
}
stock VX_Begin()
{
    gVXDBError = false;
    return VX_SQL("BEGIN IMMEDIATE TRANSACTION");
}
stock VX_Commit()
{
    if (gVXDBError) { VX_SQL("ROLLBACK"); return 0; }
    if (!VX_SQL("COMMIT")) { VX_SQL("ROLLBACK"); return 0; }
    return 1;
}
stock VX_Error(playerid)
{
    SendClientMessage(playerid, COLOR_RED, "������ ���� ������. �������� ��������. ���������� � ��������������.");
    return 1;
}
stock VX_Number(const text[], &value, maximum = MAX_MONEY)
{
    value = 0;
    new len = strlen(text);
    if (len == 0 || len > 10) return 0;
    for (new i = 0; i < len; i++)
    {
        if (text[i] < '0' || text[i] > '9') return 0;
        new digit = text[i] - '0';
        if (value > (maximum - digit) / 10 || digit > maximum) return 0;
        value = value * 10 + digit;
    }
    return value <= maximum;
}
stock VX_Valid(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && IsPlayerConnected(playerid) && gLogged[playerid];
}
stock VX_Near(playerid, targetid, Float:range = 4.0)
{
    if (!VX_Valid(targetid) || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(targetid) || GetPlayerInterior(playerid) != GetPlayerInterior(targetid)) return 0;
    new Float:x, Float:y, Float:z;
    GetPlayerPos(targetid,x,y,z);
    return IsPlayerInRangeOfPoint(playerid,range,x,y,z);
}
stock VX_Admin(playerid)
{
    return VX_Valid(playerid) && (gAdmin[playerid] >= 1 || IsPlayerAdmin(playerid));
}
stock VX_AdminCanAct(adminid,targetid,requiredLevel)
{
    if(!VX_Admin(adminid) || gAdmin[adminid]<requiredLevel) return 0;
    if(!VX_Valid(targetid) || targetid==adminid) return 0;
    if(IsOwner(targetid)) return 0;
    if(!IsOwner(adminid) && !IsPlayerAdmin(adminid) && gAdmin[targetid]>=gAdmin[adminid]) return 0;
    return 1;
}
stock VX_ShowSpecActions(playerid)
{
    new targetid=gVXSpec[playerid];
    if(!VX_Admin(playerid) || !VX_Valid(targetid) || targetid==playerid)
        return SendClientMessage(playerid,COLOR_RED,"������� �������� /spec ID."),1;
    new title[128],body[384];
    format(title,sizeof title,"VEXORIUM | %s [%d]",gName[targetid],targetid);
    format(body,sizeof body,"�������� � 3 �������+\n������� � 2 �������+\n�������� � ��� � 2 �������+\n���������� �� ��� � 2 �������+\n������ �������������� � 2 �������+\n��� � 2 �������+\n���������� �� ������\n��������� ����������");
    return VX_Show(playerid,DIALOG_ADMIN_SPEC,DIALOG_STYLE_LIST,title,body,"��������","�������");
}
stock VX_AdminDelayedKick(playerid)
{
    if(IsPlayerConnected(playerid)) Kick(playerid);
    return 1;
}
stock VX_AdminBanTarget(adminid,targetid,minutes,const rawReason[])
{
    if(!VX_AdminCanAct(adminid,targetid,3))
        return SendClientMessage(adminid,COLOR_RED,"��� ������� 3 �������; ������ ������ ����, ��������� ��� �������������� �������/����� �������� ������."),1;
    new reason[120],query[512],message[192],expires=0;
    VX_CleanText(rawReason,reason,sizeof reason);
    if(strlen(reason)<3) return SendClientMessage(adminid,COLOR_YELLOW,"������� ������� ���� (������� 3 �������)."),1;
    if(minutes<0 || minutes>525600) return SendClientMessage(adminid,COLOR_RED,"���� ����: 0 (��������) ��� 1-525600 �����."),1;
    if(minutes>0) expires=gettime()+minutes*60;
    format(query,sizeof query,"INSERT OR REPLACE INTO vx_admin_bans(name,reason,admin,expires,created) VALUES('%q','%q','%q',%d,%d)",gName[targetid],reason,gName[adminid],expires,gettime());
    if(!VX_SQL(query)) return SendClientMessage(adminid,COLOR_RED,"�� ������� ��������� ��� � ���� ������."),1;
    if(minutes==0) format(message,sizeof message,"[BAN] %s ������� ��������. �������: %s",gName[targetid],reason);
    else format(message,sizeof message,"[BAN] %s ������� �� %d ���. �������: %s",gName[targetid],minutes,reason);
    SendClientMessageToAll(COLOR_ORANGE,message);
    SendClientMessage(targetid,COLOR_RED,"�� ������������� �� VEXORIUM RP. ��� ��������� ����� ��� ����� ��������.");
    SendClientMessage(adminid,COLOR_GREEN,"��� �������� � ���� � ����� ����������� ����� ����������.");
    SetTimerEx("VX_AdminDelayedKick",300,false,"i",targetid);
    return 1;
}
stock VX_AdminKickTarget(adminid,targetid,const rawReason[])
{
    if(!VX_AdminCanAct(adminid,targetid,2))
        return SendClientMessage(adminid,COLOR_RED,"��� ������� 2 �������; ������ ������� ����, ��������� ��� �������������� �������/����� �������� ������."),1;
    new reason[120],message[192];VX_CleanText(rawReason,reason,sizeof reason);
    if(!strlen(reason)) format(reason,sizeof reason,"��������� ������ �������");
    format(message,sizeof message,"[KICK] %s �������� ��������������� %s. �������: %s",gName[targetid],gName[adminid],reason);
    SendClientMessageToAll(COLOR_ORANGE,message);
    SendClientMessage(targetid,COLOR_RED,"�� ��������� ���������������. �������: �������� ��������� �������.");
    SetTimerEx("VX_AdminDelayedKick",300,false,"i",targetid);
    SendClientMessage(adminid,COLOR_GREEN,"����� ����� ��������.");
    return 1;
}
stock VX_AdminWarnTarget(adminid,targetid,const rawReason[])
{
    if(!VX_AdminCanAct(adminid,targetid,2))
        return SendClientMessage(adminid,COLOR_RED,"�������������� ������� 2 ������� � �� ����� ���� ������ �������/�������� ��������������."),1;
    new reason[120],query[384],message[192];VX_CleanText(rawReason,reason,sizeof reason);
    if(strlen(reason)<3) return SendClientMessage(adminid,COLOR_YELLOW,"������� ������� ��������������."),1;
    format(query,sizeof query,"INSERT INTO vx_admin_warns(name,admin,reason,created) VALUES('%q','%q','%q',%d)",gName[targetid],gName[adminid],reason,gettime());
    if(!VX_SQL(query)) return SendClientMessage(adminid,COLOR_RED,"�� ������� ��������� ��������������."),1;
    format(message,sizeof message,"[WARN] %s ������� �������������� �� %s. �������: %s",gName[targetid],gName[adminid],reason);
    SendClientMessageToAll(COLOR_ORANGE,message);
    return 1;
}
stock VX_CheckBanBeforeAuth(playerid)
{
    if(!IsPlayerConnected(playerid) || !gName[playerid][0]) return 0;
    new query[256],reason[120],adminName[MAX_PLAYER_NAME+1],expires=0;
    format(query,sizeof query,"SELECT reason,admin,expires FROM vx_admin_bans WHERE name='%q' COLLATE NOCASE LIMIT 1",gName[playerid]);
    new DBResult:r=db_query(gDatabase,query);
    if(!r) return 0;
    if(!db_num_rows(r)) { db_free_result(r); return 0; }
    db_get_field(r,0,reason,sizeof reason);db_get_field(r,1,adminName,sizeof adminName);expires=db_get_field_int(r,2);
    db_free_result(r);
    if(expires>0 && expires<=gettime())
    {
        format(query,sizeof query,"DELETE FROM vx_admin_bans WHERE name='%q' COLLATE NOCASE",gName[playerid]);
        VX_SQL(query);return 0;
    }
    new message[220];
    if(expires==0) format(message,sizeof message,"������ ��������: ���������� ���. �������: %s | �������������: %s",reason,adminName);
    else format(message,sizeof message,"������ ��������: ��� ��� %d ���. �������: %s | �������������: %s",(expires-gettime()+59)/60,reason,adminName);
    SendClientMessage(playerid,COLOR_RED,message);
    SetTimerEx("VX_AdminDelayedKick",300,false,"i",playerid);
    return 1;
}
stock VX_Officer(playerid)
{
    return VX_Valid(playerid) && (gFaction[playerid] == FACTION_POLICE || gFaction[playerid] == FACTION_FBI) && gFactionRank[playerid] >= 1;
}
stock VX_Medic(playerid)
{
    return VX_Valid(playerid) && gFaction[playerid] == FACTION_HOSPITAL && gFactionRank[playerid] >= 1 && gVXMedDuty[playerid];
}
stock VX_CleanText(const input[], output[], size)
{
    new n = 0;
    for (new i = 0; input[i] && n < size - 1; i++)
    {
        if (input[i] < 32 || input[i] == '{' || input[i] == '}' || input[i] == '~') continue;
        output[n++] = input[i];
    }
    output[n] = '\0';
    return n;
}
stock VX_Show(playerid, dialogid, style, const title[], const body[], const button[] = "�������", const cancel[] = "�������")
{
    // Legacy a_samp declares these strings without const.
    new dialogTitle[144], dialogBody[4096], dialogButton[32], dialogCancel[32];
    if (strlen(title) >= sizeof dialogTitle || strlen(body) >= sizeof dialogBody ||
        strlen(button) >= sizeof dialogButton || strlen(cancel) >= sizeof dialogCancel)
    {
        print("[VEXORIUM UPDATE] Dialog exceeds the compatibility buffer.");
        return 0;
    }
    format(dialogTitle, sizeof dialogTitle, "%s", title);
    format(dialogBody, sizeof dialogBody, "%s", body);
    format(dialogButton, sizeof dialogButton, "%s", button);
    format(dialogCancel, sizeof dialogCancel, "%s", cancel);
    gVXExpectedDialog[playerid] = dialogid;
    return ShowPlayerDialog(playerid,dialogid,style,dialogTitle,dialogBody,dialogButton,dialogCancel);
}
stock VX_Init()
{
    VX_SQL("CREATE TABLE IF NOT EXISTS vx_players (name TEXT PRIMARY KEY, phone INTEGER UNIQUE NOT NULL, phone_on INTEGER NOT NULL DEFAULT 1, wanted_at INTEGER NOT NULL DEFAULT 0, hospital INTEGER NOT NULL DEFAULT 0, treatment INTEGER NOT NULL DEFAULT 120)");
    VX_SQL("CREATE TABLE IF NOT EXISTS vx_banklog (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, peer TEXT NOT NULL DEFAULT '', amount INTEGER NOT NULL, kind TEXT NOT NULL, created INTEGER NOT NULL)");
    VX_SQL("CREATE INDEX IF NOT EXISTS vx_banklog_name ON vx_banklog(name,id)");
    VX_SQL("CREATE TABLE IF NOT EXISTS vx_sms (id INTEGER PRIMARY KEY AUTOINCREMENT, sender INTEGER NOT NULL, recipient INTEGER NOT NULL, body TEXT NOT NULL, created INTEGER NOT NULL)");
    VX_SQL("CREATE TABLE IF NOT EXISTS vx_medcert (name TEXT PRIMARY KEY, valid_until INTEGER NOT NULL DEFAULT 0)");
    VX_SQL("CREATE TABLE IF NOT EXISTS vx_clothing (name TEXT PRIMARY KEY, skin INTEGER NOT NULL DEFAULT 23)");
    VX_SQL("CREATE INDEX IF NOT EXISTS vx_sms_recipient ON vx_sms(recipient,id)");
    VX_SQL("CREATE TABLE IF NOT EXISTS vx_contacts (owner TEXT NOT NULL, number INTEGER NOT NULL, label TEXT NOT NULL, PRIMARY KEY(owner,number))");
    VX_SQL("CREATE TABLE IF NOT EXISTS vx_families (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT UNIQUE NOT NULL COLLATE NOCASE, owner TEXT UNIQUE NOT NULL, balance INTEGER NOT NULL DEFAULT 0)");
    VX_SQL("CREATE TABLE IF NOT EXISTS vx_family_members (name TEXT PRIMARY KEY, family INTEGER NOT NULL, rank INTEGER NOT NULL DEFAULT 1)");
    VX_SQL("CREATE TABLE IF NOT EXISTS vx_businesses (id INTEGER PRIMARY KEY, name TEXT NOT NULL, owner TEXT NOT NULL DEFAULT '', price INTEGER NOT NULL, till INTEGER NOT NULL DEFAULT 0, stock INTEGER NOT NULL DEFAULT 100, unitprice INTEGER NOT NULL DEFAULT 250)");
    VX_SQL("INSERT OR IGNORE INTO vx_businesses(id,name,price,unitprice) VALUES(1,'Market 24/7',250000,250)");
    VX_SQL("INSERT OR IGNORE INTO vx_businesses(id,name,price,unitprice) VALUES(2,'Vexorium Cafe',350000,400)");
    VX_SQL("INSERT OR IGNORE INTO vx_businesses(id,name,price,unitprice) VALUES(3,'Auto service',500000,2000)");
    VX_SQL("INSERT OR IGNORE INTO vx_businesses(id,name,price,unitprice) VALUES(4,'Mini-market',300000,250)");
    VX_SQL("INSERT OR IGNORE INTO vx_businesses(id,name,price,unitprice) VALUES(5,'Pizzeria',400000,400)");
    VX_SQL("CREATE TABLE IF NOT EXISTS vx_admin_bans (name TEXT PRIMARY KEY COLLATE NOCASE, reason TEXT NOT NULL, admin TEXT NOT NULL, expires INTEGER NOT NULL DEFAULT 0, created INTEGER NOT NULL)");
    VX_SQL("CREATE TABLE IF NOT EXISTS vx_admin_warns (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, admin TEXT NOT NULL, reason TEXT NOT NULL, created INTEGER NOT NULL)");
    VX_SQL("CREATE INDEX IF NOT EXISTS vx_admin_warns_name ON vx_admin_warns(name,id)");
    VX_SQL("CREATE TABLE IF NOT EXISTS vx_reports (id INTEGER PRIMARY KEY AUTOINCREMENT, player TEXT NOT NULL, message TEXT NOT NULL, admin TEXT NOT NULL DEFAULT '', status INTEGER NOT NULL DEFAULT 0, created INTEGER NOT NULL, updated INTEGER NOT NULL)");
    VX_SQL("CREATE INDEX IF NOT EXISTS vx_reports_status ON vx_reports(status,player)");
    VX_SQL("CREATE TABLE IF NOT EXISTS vx_report_messages(id INTEGER PRIMARY KEY AUTOINCREMENT, report INTEGER NOT NULL, author TEXT NOT NULL, body TEXT NOT NULL, created INTEGER NOT NULL)");
    VX_SQL("UPDATE vx_reports SET status=0,admin='' WHERE status=1");
    VX_BuildWard();
    if(gLockerPickup[FACTION_HOSPITAL]!=INVALID_PICKUP)DestroyPickup(gLockerPickup[FACTION_HOSPITAL]);
    gLockerPickup[FACTION_HOSPITAL]=CreatePickup(1275,1,2005.0,1997.0,1001.0,VX_HOSPITAL_WORLD);
    if (gOrgEnterPickup[FACTION_HOSPITAL] != INVALID_PICKUP) DestroyPickup(gOrgEnterPickup[FACTION_HOSPITAL]);
    if (gOrgExitPickup[FACTION_HOSPITAL] != INVALID_PICKUP) DestroyPickup(gOrgExitPickup[FACTION_HOSPITAL]);
    gOrgEnterPickup[FACTION_HOSPITAL] = CreatePickup(1239,1,1176.7,-1322.5,13.5,0);
    gOrgExitPickup[FACTION_HOSPITAL] = CreatePickup(1239,1,VX_LOBBY_EXIT_X,VX_LOBBY_EXIT_Y,VX_LOBBY_Z,VX_HOSPITAL_WORLD);
    gVXLobbyWardPickup = CreatePickup(1239,1,VX_LOBBY_WARD_X,VX_LOBBY_WARD_Y,VX_LOBBY_Z,VX_HOSPITAL_WORLD);
    gVXWardLobbyPickup = CreatePickup(1239,1,VX_WARD_LOBBY_X,VX_WARD_LOBBY_Y,VX_WARD_Z,VX_HOSPITAL_WORLD);
    gVXMedCertPickup = CreatePickup(1239,1,VX_LOBBY_CERT_X,VX_LOBBY_CERT_Y,VX_LOBBY_Z,VX_HOSPITAL_WORLD);
    gVXHospitalGaragePickup = CreatePickup(1239,1,1192.1529,-1335.5710,13.3984,0);
    Create3DTextLabel("{66CCFF}���� | ����� ������ ������\n{FFFFFF}/hgarage | /mduty",COLOR_WHITE,1192.1529,-1335.5710,14.4,15.0,0,1);
    Create3DTextLabel("{66CCFF}���� | ����\n���������, �����, ������ ������",COLOR_WHITE,1176.7,-1322.5,15.0,20.0,0,1);
    // Removed duplicate /biz 3D labels that overlapped normal shop markers.
    gVXLastTick = gettime();
    gVXTimer = SetTimer("VX_Tick",1000,true);
    SetTimer("VX_VehicleSpeedTick",200,true);
    SetTimer("VX_CuffFollowTick",250,true);
    print("[VEXORIUM UPDATE] Bank, inventory, phone, families, businesses, reports and ���� initialized.");
    return 1;
}
stock VX_Connect(playerid)
{
    VX_CancelWardLoad(playerid);
    gVXWardNotice[playerid]=0;
    gVXSession[playerid]++;
    gVXCarjackCharged[playerid]=false;
    if(gVXDeathTimer[playerid]) KillTimer(gVXDeathTimer[playerid]);
    gVXDeathTimer[playerid]=0;
    gVXPhone[playerid]=0;gVXPhoneOn[playerid]=true;
    gVXCall[playerid]=INVALID_PLAYER_ID;gVXCallActive[playerid]=false;gVXCallAt[playerid]=0;
    gVXNumberInput[playerid]=0;gVXLastSMS[playerid]=0;gVXLastCall[playerid]=0;
    gVXFamily[playerid]=0;gVXFamilyRank[playerid]=0;gVXInvite[playerid]=0;gVXInviteAt[playerid]=0;
    gVXWantedAt[playerid]=0;gVXHospital[playerid]=false;gVXTreatment[playerid]=VX_HOSPITAL_SECONDS;gVXBed[playerid]=-1;
    gVXMedCall[playerid]=0;gVXMedAssigned[playerid]=INVALID_PLAYER_ID;gVXLastMedCall[playerid]=0;gVXMedDuty[playerid]=false;gVXLastHeal[playerid]=0;
    gVXReportId[playerid]=0;gVXReportOwner[playerid]=INVALID_PLAYER_ID;gVXReportAt[playerid]=0;
    gVXSpec[playerid]=INVALID_PLAYER_ID;gVXRestore[playerid]=false;gVXSpecAction[playerid]=0;
    gAdminMuteUntil[playerid]=0;gAdminMuteReason[playerid][0]='\0';
    gVXExpectedDialog[playerid]=-1;gVXSelectedItem[playerid]=-1;gVXListCount[playerid]=0;gVXSelectedBiz[playerid]=0;
    return 1;
}
stock VX_LoadFamily(playerid)
{
    gVXFamily[playerid]=0;gVXFamilyRank[playerid]=0;
    new q[192];format(q,sizeof q,"SELECT m.family,m.rank FROM vx_family_members m JOIN vx_families f ON f.id=m.family WHERE m.name='%q'",gName[playerid]);
    new DBResult:r=db_query(gDatabase,q);
    if(r && db_num_rows(r)){gVXFamily[playerid]=db_get_field_int(r,0);gVXFamilyRank[playerid]=db_get_field_int(r,1);}
    if(r)db_free_result(r);
    return 1;
}
stock VX_Load(playerid)
{
    new q[512];
    format(q,sizeof q,"INSERT OR IGNORE INTO vx_players(name,phone) SELECT '%q',COALESCE(MAX(phone),99999)+1 FROM vx_players",gName[playerid]);
    if(!VX_SQL(q))return VX_Error(playerid);
    format(q,sizeof q,"SELECT phone,phone_on,wanted_at,hospital,treatment FROM vx_players WHERE name='%q'",gName[playerid]);
    new DBResult:r=db_query(gDatabase,q);
    if(r && db_num_rows(r))
    {
        gVXPhone[playerid]=db_get_field_int(r,0);gVXPhoneOn[playerid]=(db_get_field_int(r,1)!=0);
        gVXWantedAt[playerid]=db_get_field_int(r,2);gVXHospital[playerid]=(db_get_field_int(r,3)!=0);
        gVXTreatment[playerid]=VexHudClamp(db_get_field_int(r,4),1,VX_HOSPITAL_SECONDS);
    }
    if(r)db_free_result(r);
    format(q,sizeof q,"SELECT wanted FROM police_records WHERE name='%q'",gName[playerid]);
    r=db_query(gDatabase,q);
    if(r && db_num_rows(r))gWantedLevel[playerid]=VexHudClamp(db_get_field_int(r,0),0,6);
    if(r)db_free_result(r);
    if(gWantedLevel[playerid]>0 && gVXWantedAt[playerid]<=0)gVXWantedAt[playerid]=gettime()+VX_WANTED_SECONDS;
    VX_DecayWanted(playerid);
    SetPlayerWantedLevel(playerid,gWantedLevel[playerid]);
    VX_LoadFamily(playerid);
    format(q,sizeof q,"SELECT id,created FROM vx_reports WHERE player='%q' AND status<2 ORDER BY id DESC LIMIT 1",gName[playerid]);
    r=db_query(gDatabase,q);
    if(r && db_num_rows(r)){gVXReportId[playerid]=db_get_field_int(r,0);gVXReportAt[playerid]=db_get_field_int(r,1);}
    if(r)db_free_result(r);
    SendClientMessage(playerid,COLOR_BLUE,"VEXORIUM: /inv /bank /phone /family /businesses /report /rphelp");
    return 1;
}
stock VX_Save(playerid)
{
    if(!gLogged[playerid] || !gVXPhone[playerid])return 0;
    new q[512];
    format(q,sizeof q,"UPDATE vx_players SET phone_on=%d,wanted_at=%d,hospital=%d,treatment=%d WHERE name='%q'",gVXPhoneOn[playerid],gVXWantedAt[playerid],gVXHospital[playerid],gVXTreatment[playerid],gName[playerid]);
    VX_SQL(q);
    format(q,sizeof q,"INSERT OR REPLACE INTO police_records(name,wanted) VALUES('%q',%d)",gName[playerid],gWantedLevel[playerid]);VX_SQL(q);
    return 1;
}
stock VX_MoneySQL(playerid,cash,bank)
{
    new q[256];format(q,sizeof q,"UPDATE accounts SET money=%d WHERE name='%q'",cash,gName[playerid]);VX_SQL(q);
    format(q,sizeof q,"INSERT OR REPLACE INTO bank_accounts(name,balance) VALUES('%q',%d)",gName[playerid],bank);VX_SQL(q);
    return !gVXDBError;
}
stock VX_MoneySync(playerid,cash,bank)
{
    gMoney[playerid]=cash;gBankMoney[playerid]=bank;
    ResetPlayerMoney(playerid);GivePlayerMoney(playerid,cash);UpdateVexHud(playerid);
    return 1;
}
stock VX_NeedsSave(playerid)
{
    if (!VX_Valid(playerid)) return 0;
    new q[256];
    format(q, sizeof q, "INSERT OR REPLACE INTO vx_needs(name,hunger,thirst,energy) VALUES('%q',%d,%d,%d)", gName[playerid], gHunger[playerid], gThirst[playerid], gEnergy[playerid]);
    return VX_SQL(q);
}
stock VX_NeedsLoad(playerid)
{
    if (!VX_Valid(playerid)) return 0;
    new q[192];
    format(q, sizeof q, "INSERT OR IGNORE INTO vx_needs(name,hunger,thirst,energy) VALUES('%q',100,100,100)", gName[playerid]);
    VX_SQL(q);
    format(q, sizeof q, "SELECT hunger,thirst,energy FROM vx_needs WHERE name='%q'", gName[playerid]);
    new DBResult:r = db_query(gDatabase, q);
    if (r && db_num_rows(r))
    {
        gHunger[playerid] = VexHudClamp(db_get_field_int(r, 0), 0, 100);
        gThirst[playerid] = VexHudClamp(db_get_field_int(r, 1), 0, 100);
        gEnergy[playerid] = VexHudClamp(db_get_field_int(r, 2), 0, 100);
    }
    if (r) db_free_result(r);
    return 1;
}
public VX_NeedsPulse()
{
    for (new playerid = 0; playerid < MAX_PLAYERS; playerid++)
    {
        if (!IsPlayerConnected(playerid) || !gLogged[playerid]) continue;
        if (gHunger[playerid] > 0) gHunger[playerid] = VexHudClamp(gHunger[playerid] - 2, 0, 100);
        if (gThirst[playerid] > 0) gThirst[playerid] = VexHudClamp(gThirst[playerid] - 3, 0, 100);
        if (gEnergy[playerid] > 0) gEnergy[playerid] = VexHudClamp(gEnergy[playerid] - 1, 0, 100);
        new Float:hp; GetPlayerHealth(playerid, hp);
        if (gThirst[playerid] == 0) SetPlayerHealth(playerid, (hp > 5.0) ? hp - 3.0 : 1.0);
        else if (gHunger[playerid] == 0) SetPlayerHealth(playerid, (hp > 5.0) ? hp - 1.0 : 1.0);
        if (gThirst[playerid] <= 15) SendClientMessage(playerid, COLOR_RED, "�� ������ ������ ����! ������ ���� � ������� ��� ����������� � �� ���������.");
        else if (gHunger[playerid] <= 15) SendClientMessage(playerid, COLOR_YELLOW, "�� �������. ������ ��� � ������� ��� ����������� � �� ���������.");
        if (gEnergy[playerid] <= 15) SendClientMessage(playerid, COLOR_YELLOW, "�� ������. ��������� � ����������� ���� �������� /rest.");
        VX_NeedsSave(playerid);
    }
    return 1;
}
stock VX_GetTailAfterTokens(const input[], skipTokens, output[], size)
{
    new i = 0, current = 0, length = strlen(input);
    while (i < length && current < skipTokens)
    {
        while (i < length && input[i] <= ' ') i++;
        while (i < length && input[i] > ' ') i++;
        current++;
    }
    while (i < length && input[i] <= ' ') i++;
    if (i >= length) { output[0] = '\0'; return 0; }
    strmid(output, input, i, length, size);
    return strlen(output);
}
stock VX_ContractNotify(playerid)
{
    new q[256], payer[MAX_PLAYER_NAME + 1], purpose[72], msg[192];
    format(q, sizeof q, "SELECT id,payer,amount,purpose FROM vx_contracts WHERE payee='%q' AND status=0 ORDER BY id DESC LIMIT 5", gName[playerid]);
    new DBResult:r = db_query(gDatabase, q);
    if (r)
    {
        for (new i = 0; i < db_num_rows(r); i++)
        {
            db_get_field(r, 1, payer, sizeof payer); db_get_field(r, 3, purpose, sizeof purpose);
            format(msg, sizeof msg, "[�������] #%d �� %s: %d ���. � %s. �������: /contractaccept %d", db_get_field_int(r, 0), payer, db_get_field_int(r, 2), purpose, db_get_field_int(r, 0));
            SendClientMessage(playerid, COLOR_YELLOW, msg); db_next_row(r);
        }
        db_free_result(r);
    }
    return 1;
}
stock VX_ContractCreate(playerid, targetid, amount, const purpose[])
{
    if (!VX_Valid(playerid) || !VX_Valid(targetid) || amount < 1 || amount > 10000000 || amount > gMoney[playerid])
        return SendClientMessage(playerid, COLOR_RED, "������������ �������� ��� �������� ����� ��������."), 1;
    if (strlen(purpose) < 2) return SendClientMessage(playerid, COLOR_RED, "������� ���������� ��������."), 1;
    new query[512], cash = gMoney[playerid] - amount;
    if (!VX_Begin()) return VX_Error(playerid);
    format(query, sizeof query, "UPDATE accounts SET money=%d WHERE name='%q'", cash, gName[playerid]); VX_SQL(query);
    format(query, sizeof query, "INSERT INTO vx_contracts(payer,payee,amount,purpose,status,created) VALUES('%q','%q',%d,'%q',0,%d)", gName[playerid], gName[targetid], amount, purpose, gettime()); VX_SQL(query);
    if (!VX_Commit()) return VX_Error(playerid);
    VX_MoneySync(playerid, cash, gBankMoney[playerid]);
    new DBResult:r = db_query(gDatabase, "SELECT last_insert_rowid()");
    new contractId = 0; if (r && db_num_rows(r)) contractId = db_get_field_int(r, 0); if (r) db_free_result(r);
    new msg[192];
    format(msg, sizeof msg, "������� #%d ������: %d ���. ����������: %s. ������ ������������ �� ������� ������ �������.", contractId, amount, purpose);
    SendClientMessage(playerid, COLOR_GREEN, msg);
    VX_Notify(playerid, "������� ������", "�������� ������������ �� ������", VEX_HUD_ACCENT);
    format(msg, sizeof msg, "����� %s ���������� ������� #%d �� %d ���. ����������: %s. �������: /contractaccept %d, �����: /contractreject %d", gName[playerid], contractId, amount, purpose, contractId, contractId);
    SendClientMessage(targetid, COLOR_YELLOW, msg);
    VX_Notify(targetid, "����� �������", "�������� ������: /contracts", VEX_HUD_WARNING);
    return 1;
}
stock VX_ContractList(playerid)
{
    new q[256], payer[MAX_PLAYER_NAME + 1], payee[MAX_PLAYER_NAME + 1], purpose[72], line[192];
    format(q, sizeof q, "SELECT id,payer,payee,amount,purpose FROM vx_contracts WHERE status=0 AND (payer='%q' OR payee='%q') ORDER BY id DESC LIMIT 10", gName[playerid], gName[playerid]);
    new DBResult:r = db_query(gDatabase, q);
    if (!r || !db_num_rows(r)) { if (r) db_free_result(r); return SendClientMessage(playerid, COLOR_YELLOW, "�������� ��������� ���."), 1; }
    SendClientMessage(playerid, COLOR_YELLOW, "�������� �������� (0 � ��������, /contractaccept ID, /contractreject ID, /contractcancel ID):");
    for (new i = 0; i < db_num_rows(r); i++)
    {
        db_get_field(r, 1, payer, sizeof payer); db_get_field(r, 2, payee, sizeof payee); db_get_field(r, 4, purpose, sizeof purpose);
        format(line, sizeof line, "#%d | %s -> %s | %d ���. | %s", db_get_field_int(r, 0), payer, payee, db_get_field_int(r, 3), purpose);
        SendClientMessage(playerid, COLOR_WHITE, line); db_next_row(r);
    }
    db_free_result(r); return 1;
}
stock VX_ContractResolve(playerid, contractId, action)
{
    new q[256], payer[MAX_PLAYER_NAME + 1], payee[MAX_PLAYER_NAME + 1], purpose[72], amount, status;
    format(q, sizeof q, "SELECT payer,payee,amount,purpose,status FROM vx_contracts WHERE id=%d", contractId);
    new DBResult:r = db_query(gDatabase, q);
    if (!r || !db_num_rows(r)) { if (r) db_free_result(r); return SendClientMessage(playerid, COLOR_RED, "������� �� ������."), 1; }
    db_get_field(r, 0, payer, sizeof payer); db_get_field(r, 1, payee, sizeof payee); amount = db_get_field_int(r, 2); db_get_field(r, 3, purpose, sizeof purpose); status = db_get_field_int(r, 4); db_free_result(r);
    if (status != 0) return SendClientMessage(playerid, COLOR_YELLOW, "���� ������� ��� ������."), 1;
    if (action == 1)
    {
        if (strcmp(payee, gName[playerid], true) != 0) return SendClientMessage(playerid, COLOR_RED, "������� ������� ����� ������ ��������� ����������."), 1;
        if (gMoney[playerid] > MAX_MONEY - amount) return SendClientMessage(playerid, COLOR_RED, "���������� ����� ��� �����: �������� ����� ��������."), 1;
        new cash = gMoney[playerid] + amount;
        if (!VX_Begin()) return VX_Error(playerid);
        format(q, sizeof q, "UPDATE vx_contracts SET status=1 WHERE id=%d AND status=0", contractId); VX_SQL(q);
        format(q, sizeof q, "UPDATE accounts SET money=%d WHERE name='%q'", cash, gName[playerid]); VX_SQL(q);
        if (!VX_Commit()) return VX_Error(playerid);
        VX_MoneySync(playerid, cash, gBankMoney[playerid]);
        new other = INVALID_PLAYER_ID;
        for (new i = 0; i < MAX_PLAYERS; i++) if (IsPlayerConnected(i) && gLogged[i] && !strcmp(gName[i], payer, true)) { other = i; break; }
        if (other != INVALID_PLAYER_ID) SendClientMessage(other, COLOR_GREEN, "������ ������� ������� �������. ������ ����������� ����������.");
        SendClientMessage(playerid, COLOR_GREEN, "�� ������� �������. �������� ����������� �� ��� ���� ��������."); return 1;
    }
    if (action == 2 && strcmp(payee, gName[playerid], true) != 0) return SendClientMessage(playerid, COLOR_RED, "��������� ������� ����� ������ ��������� ����������."), 1;
    if (action == 3 && strcmp(payer, gName[playerid], true) != 0) return SendClientMessage(playerid, COLOR_RED, "�������� ������� ����� ������ ����� �����������."), 1;
    new payerid = INVALID_PLAYER_ID, payerCash = 0;
    for (new i = 0; i < MAX_PLAYERS; i++) if (IsPlayerConnected(i) && gLogged[i] && !strcmp(gName[i], payer, true)) { payerid = i; break; }
    if (payerid != INVALID_PLAYER_ID) payerCash = gMoney[payerid];
    else
    {
        format(q, sizeof q, "SELECT money FROM accounts WHERE name='%q'", payer);
        r = db_query(gDatabase, q);
        if (!r || !db_num_rows(r)) { if (r) db_free_result(r); return SendClientMessage(playerid, COLOR_RED, "�� ������� ����� ���� ������ ��������."), 1; }
        payerCash = db_get_field_int(r, 0); db_free_result(r);
    }
    if (payerCash > MAX_MONEY - amount) return SendClientMessage(playerid, COLOR_RED, "������ �������� ����� ���������� ����� ��� �������� �������."), 1;
    new refunded = payerCash + amount, newStatus = (action == 2) ? 2 : 3;
    if (!VX_Begin()) return VX_Error(playerid);
    format(q, sizeof q, "UPDATE vx_contracts SET status=%d WHERE id=%d AND status=0", newStatus, contractId); VX_SQL(q);
    format(q, sizeof q, "UPDATE accounts SET money=%d WHERE name='%q'", refunded, payer); VX_SQL(q);
    if (!VX_Commit()) return VX_Error(playerid);
    if (payerid != INVALID_PLAYER_ID) VX_MoneySync(payerid, refunded, gBankMoney[payerid]);
    if (action == 2) SendClientMessage(playerid, COLOR_YELLOW, "������� ��������. ������ ���������� ������.");
    else SendClientMessage(playerid, COLOR_YELLOW, "������� �������. ������ ����������.");
    if (payerid != INVALID_PLAYER_ID && payerid != playerid) SendClientMessage(payerid, COLOR_GREEN, "�������� �� �������� ���������� ���������.");
    return 1;
}
stock VX_OrgBalance(faction)
{
    new q[128], balance = 0;
    format(q, sizeof q, "SELECT money FROM org_stashes WHERE faction_id=%d", faction);
    new DBResult:r = db_query(gDatabase, q);
    if (r && db_num_rows(r)) balance = db_get_field_int(r, 0);
    if (r) db_free_result(r);
    return balance;
}

stock VX_BankLog(playerid,const kind[],amount,const peer[]="")
{
    new q[384];format(q,sizeof q,"INSERT INTO vx_banklog(name,peer,amount,kind,created) VALUES('%q','%q',%d,'%q',%d)",gName[playerid],peer,amount,kind,gettime());
    return VX_SQL(q);
}
stock VX_BankOperation(playerid,action,amount,targetid=INVALID_PLAYER_ID)
{
    if(amount<=0 || amount>MAX_MONEY)return SendClientMessage(playerid,COLOR_RED,"������������ �����."),1;
    new cash=gMoney[playerid], bank=gBankMoney[playerid];
    if(action==0)
    {
        if(cash<amount || bank>MAX_MONEY-amount)return SendClientMessage(playerid,COLOR_RED,"������������ �������� ��� ��������� ����� �����."),1;
        cash-=amount;bank+=amount;
    }
    else if(action==1)
    {
        if(bank<amount || cash>MAX_MONEY-amount)return SendClientMessage(playerid,COLOR_RED,"������������ ����� �� ����� ��� ��������� ����� ��������."),1;
        bank-=amount;cash+=amount;
    }
    else
    {
        if(!VX_Valid(targetid) || targetid==playerid)return SendClientMessage(playerid,COLOR_RED,"���������� �� ������."),1;
        if(bank<amount || gBankMoney[targetid]>MAX_MONEY-amount)return SendClientMessage(playerid,COLOR_RED,"������������ ����� ��� ��������� ����� ����� ����������."),1;
        bank-=amount;
    }
    if(!VX_Begin())return VX_Error(playerid);
    VX_MoneySQL(playerid,cash,bank);
    if(action==2)
    {
        VX_MoneySQL(targetid,gMoney[targetid],gBankMoney[targetid]+amount);
        VX_BankLog(playerid,"transfer_out",-amount,gName[targetid]);VX_BankLog(targetid,"transfer_in",amount,gName[playerid]);
    }
    else if(action==0)VX_BankLog(playerid,"deposit",amount);else VX_BankLog(playerid,"withdraw",-amount);
    if(!VX_Commit())return VX_Error(playerid);
    VX_MoneySync(playerid,cash,bank);
    if(action==2)
    {
        VX_MoneySync(targetid,gMoney[targetid],gBankMoney[targetid]+amount);
        new m[144];format(m,sizeof m,"[BANK] %s transferred %d to your account.",gName[playerid],amount);SendClientMessage(targetid,COLOR_GREEN,m);
    }
    SendClientMessage(playerid,COLOR_GREEN,"[����] �������� ��������� � ���������.");
    return VX_ShowBank(playerid);
}
stock VX_ShowBank(playerid)
{
    new title[100];format(title,sizeof title,"VEXORIUM | ����: %d | Cash: %d",gBankMoney[playerid],gMoney[playerid]);
    return VX_Show(playerid,VX_BANK,DIALOG_STYLE_LIST,title,"�������� ��������\n����� ��������\n��������� ������\n������� ��������");
}
stock VX_BankHistory(playerid)
{
    new q[256],body[3000],row[160],kind[32],peer[25];
    format(q,sizeof q,"SELECT amount,kind,peer,created FROM vx_banklog WHERE name='%q' ORDER BY id DESC LIMIT 15",gName[playerid]);
    new DBResult:r=db_query(gDatabase,q);
    strcat(body,"Amount\tOperation\tCounterparty\n");
    if(r)for(new i=0;i<db_num_rows(r);i++)
    {
        db_get_field(r,1,kind,sizeof kind);db_get_field(r,2,peer,sizeof peer);
        format(row,sizeof row,"%d\t%s\t%s\n",db_get_field_int(r,0),kind,peer);strcat(body,row);db_next_row(r);
    }
    if(r)db_free_result(r);
    return VX_Show(playerid,VX_LOG,DIALOG_STYLE_TABLIST_HEADERS,"������� �����",body,"OK","�������");
}
stock VX_ItemCount(playerid,item)
{
    switch(item){case 0:return gMedkits[playerid];case 1:return gFood[playerid];case 2:return gWater[playerid];case 3:return gRepairKits[playerid];case 4:return gSimCards[playerid];case 5:return gLockpicks[playerid];}
    return 0;
}
stock VX_SetItem(playerid,item,amount)
{
    switch(item){case 0:gMedkits[playerid]=amount;case 1:gFood[playerid]=amount;case 2:gWater[playerid]=amount;case 3:gRepairKits[playerid]=amount;case 4:gSimCards[playerid]=amount;case 5:gLockpicks[playerid]=amount;}
    return 1;
}
stock VX_Weight(playerid)
{
    new weight=0;for(new i=0;i<6;i++)weight+=VX_ItemCount(playerid,i)*gVXItemWeight[i];return weight;
}
stock VX_CanCarry(playerid,item,amount)
{
    return item>=0 && item<6 && amount>0 && amount<=VX_ITEM_LIMIT && VX_ItemCount(playerid,item)<=VX_ITEM_LIMIT-amount && VX_Weight(playerid)<=VX_WEIGHT_LIMIT-gVXItemWeight[item]*amount;
}
stock VX_ItemsSQL(playerid)
{
    new q[320];format(q,sizeof q,"UPDATE accounts SET medkits=%d,food=%d,water=%d,repairkits=%d,simcards=%d,lockpicks=%d WHERE name='%q'",gMedkits[playerid],gFood[playerid],gWater[playerid],gRepairKits[playerid],gSimCards[playerid],gLockpicks[playerid],gName[playerid]);return VX_SQL(q);
}
stock VX_ShowInventory(playerid)
{
    new body[1024],row[96],title[96];
    format(title,sizeof title,"��������� | %.1f / 30 kg",float(VX_Weight(playerid))/1000.0);
    strcat(body,"Slot\tItem\tQuantity\tWeight\n");
    for(new i=0;i<6;i++){format(row,sizeof row,"%d\t%s\t%d\t%.2f kg\n",i+1,gVXItemName[i],VX_ItemCount(playerid,i),float(VX_ItemCount(playerid,i)*gVXItemWeight[i])/1000.0);strcat(body,row);}
    strcat(body,"7\t������ / ����� ���������\t1\t-\n8\tPhone\t1\t-\n9\t������� ������� �����\t-\t-\n");
    return VX_Show(playerid,VX_INV,DIALOG_STYLE_TABLIST_HEADERS,title,body);
}
stock VX_UseItem(playerid,item)
{
    if(item<0 || item>=6 || VX_ItemCount(playerid,item)<1)return SendClientMessage(playerid,COLOR_RED,"� ��� ��� ����� ��������."),1;
    if(gVXHospital[playerid])return SendClientMessage(playerid,COLOR_RED,"������� ��������� ������� � ����."),1;
    if(item==5)return SendClientMessage(playerid,COLOR_YELLOW,"�������s are used by the car theft job: /work and /hack."),1;
    if(item==3)return OnPlayerCommandText(playerid,"/repairkit");
    new Float:hp;GetPlayerHealth(playerid,hp);
    if(item==0 && hp>=100.0 && !(gRPInjury[playerid] & RP_INJ_BLEED))return SendClientMessage(playerid,COLOR_YELLOW,"� ��� ��� ������ ��������."),1;
    if(item==1 && gHunger[playerid]>=100 && hp>=100.0)return SendClientMessage(playerid,COLOR_YELLOW,"� ��� ��� ������� ������."),1;
    if(item==2 && gThirst[playerid]>=100 && hp>=100.0)return SendClientMessage(playerid,COLOR_YELLOW,"� ��� ��� �����."),1;
    new old=VX_ItemCount(playerid,item);
    if(!VX_Begin())return VX_Error(playerid);
    VX_SetItem(playerid,item,old-1);VX_ItemsSQL(playerid);
    if(!VX_Commit()){VX_SetItem(playerid,item,old);return VX_Error(playerid);}
    switch(item)
    {
        case 0:
        {
            gRPInjury[playerid] &= ~RP_INJ_BLEED; RP_SaveState(playerid);
            SetPlayerHealth(playerid,100.0);
        }
        case 1:
        {
            gHunger[playerid] = VexHudClamp(gHunger[playerid] + 35, 0, 100);
            SetPlayerHealth(playerid, VX_FloatMin(100.0, hp + 2.0));
            VX_NeedsSave(playerid);
            SendClientMessage(playerid, COLOR_GREEN, "�� �����. ������� �������������.");
        }
        case 2:
        {
            gThirst[playerid] = VexHudClamp(gThirst[playerid] + 40, 0, 100);
            SetPlayerHealth(playerid, VX_FloatMin(100.0, hp + 1.0));
            VX_NeedsSave(playerid);
            SendClientMessage(playerid, COLOR_GREEN, "�� ������ ����. ����� �������.");
        }
        case 4:{gVXPhoneOn[playerid]=true;VX_Save(playerid);SendClientMessage(playerid,COLOR_GREEN,"SIM activated. Your permanent number is shown in /phone.");}
    }
    return VX_ShowInventory(playerid);
}
stock VX_GiveItem(playerid,targetid,item,amount)
{
    if(targetid==playerid || !VX_Near(playerid,targetid))return SendClientMessage(playerid,COLOR_RED,"��������� � ���������� �� ���������� �� 4 ������."),1;
    if(item<0 || item>=6 || amount<=0 || amount>VX_ItemCount(playerid,item) || !VX_CanCarry(targetid,item,amount))return SendClientMessage(playerid,COLOR_RED,"�������� ������� / ���������� ��� ��������� ���������� ��������."),1;
    new a=VX_ItemCount(playerid,item),b=VX_ItemCount(targetid,item);
    if(!VX_Begin())return VX_Error(playerid);
    VX_SetItem(playerid,item,a-amount);VX_SetItem(targetid,item,b+amount);
    VX_ItemsSQL(playerid);VX_ItemsSQL(targetid);
    if(!VX_Commit()){VX_SetItem(playerid,item,a);VX_SetItem(targetid,item,b);return VX_Error(playerid);}
    new m[144];format(m,sizeof m,"[INV] %s -> %s: %s x%d",gName[playerid],gName[targetid],gVXItemName[item],amount);
    SendClientMessage(playerid,COLOR_GREEN,m);SendClientMessage(targetid,COLOR_GREEN,m);return 1;
}
stock VX_ClearDrop(index)
{
    if(!gVXDropQty[index])return 0;
    DestroyPickup(gVXDropPickup[index]);Delete3DTextLabel(gVXDropLabel[index]);gVXDropQty[index]=0;return 1;
}
stock VX_Drop(playerid,item,amount)
{
    if(item<0 || item>=6 || amount<=0 || amount>VX_ItemCount(playerid,item))return SendClientMessage(playerid,COLOR_RED,"�������� ������� ��� ����������."),1;
    new d=-1;for(new i=0;i<VX_MAX_DROPS;i++)if(!gVXDropQty[i]){d=i;break;}
    if(d<0)return SendClientMessage(playerid,COLOR_RED,"Ground item limit reached."),1;
    GetPlayerPos(playerid,gVXDropPos[d][0],gVXDropPos[d][1],gVXDropPos[d][2]);
    gVXDropWorld[d]=GetPlayerVirtualWorld(playerid);gVXDropInterior[d]=GetPlayerInterior(playerid);
    new pickup=CreatePickup(1279,1,gVXDropPos[d][0],gVXDropPos[d][1],gVXDropPos[d][2],gVXDropWorld[d]);
    if(pickup==-1)return SendClientMessage(playerid,COLOR_RED,"Could not create ground item."),1;
    new old=VX_ItemCount(playerid,item);
    if(!VX_Begin()){DestroyPickup(pickup);return VX_Error(playerid);}
    VX_SetItem(playerid,item,old-amount);VX_ItemsSQL(playerid);
    if(!VX_Commit()){VX_SetItem(playerid,item,old);DestroyPickup(pickup);return VX_Error(playerid);}
    gVXDropPickup[d]=pickup;gVXDropItem[d]=item;gVXDropQty[d]=amount;gVXDropExpiry[d]=gettime()+600;
    new m[120];format(m,sizeof m,"%s x%d\n/pickup | disappears in 10 minutes",gVXItemName[item],amount);
    gVXDropLabel[d]=Create3DTextLabel(m,COLOR_YELLOW,gVXDropPos[d][0],gVXDropPos[d][1],gVXDropPos[d][2]+0.5,8.0,gVXDropWorld[d],1);
    SendClientMessage(playerid,COLOR_YELLOW,"������� ��������. �� �������� ����� 10 ����� ��� ����� ����������� �������.");return 1;
}
stock VX_PickupItem(playerid)
{
    for(new d=0;d<VX_MAX_DROPS;d++)
    {
        if(!gVXDropQty[d] || gVXDropWorld[d]!=GetPlayerVirtualWorld(playerid) || gVXDropInterior[d]!=GetPlayerInterior(playerid))continue;
        if(!IsPlayerInRangeOfPoint(playerid,2.0,gVXDropPos[d][0],gVXDropPos[d][1],gVXDropPos[d][2]))continue;
        new item=gVXDropItem[d],amount=gVXDropQty[d],old=VX_ItemCount(playerid,item);
        if(!VX_CanCarry(playerid,item,amount))return SendClientMessage(playerid,COLOR_RED,"��� ��������� ��������."),1;
        if(!VX_Begin())return VX_Error(playerid);
        VX_SetItem(playerid,item,old+amount);VX_ItemsSQL(playerid);
        if(!VX_Commit()){VX_SetItem(playerid,item,old);return VX_Error(playerid);}
        VX_ClearDrop(d);return VX_ShowInventory(playerid);
    }
    return SendClientMessage(playerid,COLOR_YELLOW,"����� ��� ����������� ���������."),1;
}
stock VX_ShowPhone(playerid)
{
    new title[96], phoneStatus[8];
    if (gVXPhoneOn[playerid]) format(phoneStatus,sizeof phoneStatus,"���");
    else format(phoneStatus,sizeof phoneStatus,"����");
    format(title,sizeof title,"VEXORIUM | ������� %d | %s",gVXPhone[playerid],phoneStatus);
    return VX_Show(playerid,VX_PHONE,DIALOG_STYLE_LIST,title,"��������� �� ������\n��������� SMS\n�������� SMS (��������� 15)\nContacts\nBank\nGPS\n������� ������: 103\n������� �������: 112\n�������� / ���������\n�������� / ��������� ������\n������� �����");
}
stock VX_FindPhone(number)
{
    for(new i=0;i<MAX_PLAYERS;i++)if(VX_Valid(i) && gVXPhone[i]==number)return i;
    return INVALID_PLAYER_ID;
}
stock VX_Hangup(playerid)
{
    new other=gVXCall[playerid];
    gVXCall[playerid]=INVALID_PLAYER_ID;gVXCallActive[playerid]=false;gVXCallAt[playerid]=0;
    if(VX_Valid(playerid)){SetPlayerSpecialAction(playerid,SPECIAL_ACTION_STOPUSECELLPHONE);SendClientMessage(playerid,COLOR_YELLOW,"[�������] ������ ��������.");}
    if(VX_Valid(other) && gVXCall[other]==playerid)
    {
        gVXCall[other]=INVALID_PLAYER_ID;gVXCallActive[other]=false;gVXCallAt[other]=0;
        SetPlayerSpecialAction(other,SPECIAL_ACTION_STOPUSECELLPHONE);SendClientMessage(other,COLOR_YELLOW,"[�������] ������ ��������.");
    }
    return 1;
}
stock VX_Call(playerid,number)
{
    if(number==103)return VX_MedRequest(playerid);
    if(number==112)
    {
        if(gettime()-gVXLastCall[playerid]<30)return SendClientMessage(playerid,COLOR_RED,"Wait 30 seconds before calling again."),1;
        gVXLastCall[playerid]=gettime();
        new Float:x,Float:y,Float:z,m[144];GetPlayerPos(playerid,x,y,z);
        format(m,sizeof m,"[112] %s [%d] requests police. Position: %.0f %.0f %.0f; world %d",gName[playerid],playerid,x,y,z,GetPlayerVirtualWorld(playerid));
        for(new i=0;i<MAX_PLAYERS;i++)if(VX_Officer(i))SendClientMessage(i,COLOR_BLUE,m);
        return SendClientMessage(playerid,COLOR_GREEN,"[112] Police have been notified."),1;
    }
    if(!gVXPhoneOn[playerid])return SendClientMessage(playerid,COLOR_RED,"��� ������� ��������."),1;
    if(gettime()-gVXLastCall[playerid]<5)return SendClientMessage(playerid,COLOR_YELLOW,"��������� ������ �������� ����� 5 ������."),1;
    new t=VX_FindPhone(number);
    if(!VX_Valid(t) || t==playerid || !gVXPhoneOn[t])return SendClientMessage(playerid,COLOR_RED,"������� ����������."),1;
    if(gVXCall[playerid]!=INVALID_PLAYER_ID || gVXCall[t]!=INVALID_PLAYER_ID)return SendClientMessage(playerid,COLOR_RED,"����� ������. ��������� ������: /hangup."),1;
    gVXLastCall[playerid]=gettime();gVXCall[playerid]=t;gVXCall[t]=playerid;
    gVXCallAt[playerid]=gettime();gVXCallAt[t]=0;
    new m[128];format(m,sizeof m,"[PHONE] Incoming call from %d (%s). /answer or /hangup",gVXPhone[playerid],gName[playerid]);
    SendClientMessage(t,COLOR_YELLOW,m);SendClientMessage(playerid,COLOR_GREEN,"[�������] �����... �������� ������ ��������.");PlayerPlaySound(t,1085,0.0,0.0,0.0);return 1;
}
stock VX_Answer(playerid)
{
    new t=gVXCall[playerid];
    if(!VX_Valid(t) || gVXCall[t]!=playerid || gVXCallAt[playerid]!=0 || gVXCallActive[playerid])return SendClientMessage(playerid,COLOR_RED,"��������� ������ ���."),1;
    gVXCallActive[playerid]=true;gVXCallActive[t]=true;
    SetPlayerSpecialAction(playerid,SPECIAL_ACTION_USECELLPHONE);SetPlayerSpecialAction(t,SPECIAL_ACTION_USECELLPHONE);
    SendClientMessage(playerid,COLOR_GREEN,"[�������] ���������� �����������. ������ � ���. ���������: /hangup.");
    SendClientMessage(t,COLOR_GREEN,"[�������] ���������� �����������. ������ � ���. ���������: /hangup.");return 1;
}
stock VX_SendSMS(playerid,number,const text[])
{
    if(!gVXPhoneOn[playerid])return SendClientMessage(playerid,COLOR_RED,"��� ������� ��������."),1;
    if(gettime()-gVXLastSMS[playerid]<3)return SendClientMessage(playerid,COLOR_RED,"��������� 3 ������� ����� ��������� SMS."),1;
    new body[121];VX_CleanText(text,body,sizeof body);
    if(!strlen(body))return SendClientMessage(playerid,COLOR_RED,"������� ��������� �� 1 �� 120 ��������."),1;
    new q[600];format(q,sizeof q,"SELECT name FROM vx_players WHERE phone=%d",number);
    new DBResult:r=db_query(gDatabase,q);new found=(r && db_num_rows(r)>0);if(r)db_free_result(r);
    if(!found || number==gVXPhone[playerid])return SendClientMessage(playerid,COLOR_RED,"����� �� ������ ��� ����������� ���."),1;
    format(q,sizeof q,"INSERT INTO vx_sms(sender,recipient,body,created) VALUES(%d,%d,'%q',%d)",gVXPhone[playerid],number,body,gettime());
    if(!VX_SQL(q))return VX_Error(playerid);
    gVXLastSMS[playerid]=gettime();
    new target=VX_FindPhone(number),m[144];
    if(VX_Valid(target) && gVXPhoneOn[target]){format(m,sizeof m,"[SMS %d] %.115s",gVXPhone[playerid],body);SendClientMessage(target,COLOR_YELLOW,m);}
    SendClientMessage(playerid,COLOR_GREEN,"SMS ��������� �� �������� ����������, ���� ���� �� �� � ����.");return 1;
}
stock VX_Inbox(playerid)
{
    new q[240],body[3600],row[200],text[121];
    format(q,sizeof q,"SELECT sender,body FROM vx_sms WHERE recipient=%d ORDER BY id DESC LIMIT 15",gVXPhone[playerid]);
    new DBResult:r=db_query(gDatabase,q);
    strcat(body,"From\tMessage\n");
    if(r)for(new i=0;i<db_num_rows(r);i++){db_get_field(r,1,text,sizeof text);format(row,sizeof row,"%d\t%s\n",db_get_field_int(r,0),text);strcat(body,row);db_next_row(r);}
    if(r)db_free_result(r);
    return VX_Show(playerid,VX_LOG,DIALOG_STYLE_TABLIST_HEADERS,"������� | ��������",body,"OK","�������");
}
stock VX_Contacts(playerid)
{
    new q[256],body[2200],row[96],label[33];
    gVXListCount[playerid]=0;
    format(q,sizeof q,"SELECT number,label FROM vx_contacts WHERE owner='%q' ORDER BY label LIMIT 20",gName[playerid]);
    new DBResult:r=db_query(gDatabase,q);strcat(body,"Name\tNumber\n");
    if(r)for(new i=0;i<db_num_rows(r) && i<20;i++)
    {
        db_get_field(r,1,label,sizeof label);new number=db_get_field_int(r,0);
        gVXList[playerid][gVXListCount[playerid]++]=number;
        format(row,sizeof row,"%s\t%d\n",label,number);strcat(body,row);db_next_row(r);
    }
    if(r)db_free_result(r);
    if(!gVXListCount[playerid])return SendClientMessage(playerid,COLOR_YELLOW,"No contacts. /contactadd [number] [name]"),1;
    return VX_Show(playerid,VX_CONTACTS,DIALOG_STYLE_TABLIST_HEADERS,"�������� | �������� ��� ������",body,"���������","�������");
}
stock VX_Report(playerid,const text[])
{
    if(gVXReportId[playerid])return SendClientMessage(playerid,COLOR_YELLOW,"� ��� ��� ���� �������� ���������. ��������� ��������������."),1;
    if(gettime()-gVXReportAt[playerid]<60)return SendClientMessage(playerid,COLOR_YELLOW,"����� ��������� ����� ��������� ����� 60 ������."),1;
    new message[121];VX_CleanText(text,message,sizeof message);
    if(strlen(message)<4)return SendClientMessage(playerid,COLOR_YELLOW,"Usage: /report [message, 4-120 characters]"),1;
    new q[512];format(q,sizeof q,"INSERT INTO vx_reports(player,message,status,created,updated) VALUES('%q','%q',0,%d,%d)",gName[playerid],message,gettime(),gettime());
    if(!VX_SQL(q))return VX_Error(playerid);
    new DBResult:r=db_query(gDatabase,"SELECT last_insert_rowid()");
    if(r && db_num_rows(r))gVXReportId[playerid]=db_get_field_int(r,0);if(r)db_free_result(r);
    gVXReportAt[playerid]=gettime();gVXReportOwner[playerid]=INVALID_PLAYER_ID;
    new m[144];format(m,sizeof m,"[REPORT #%d] %s [%d]: %.72s",gVXReportId[playerid],gName[playerid],playerid,message);
    for(new i=0;i<MAX_PLAYERS;i++)if(VX_Admin(i))SendClientMessage(i,COLOR_ORANGE,m);
    SendClientMessage(playerid,COLOR_GREEN,"��������� ��������� � ���������� �������������.");return 1;
}
stock VX_ReportList(playerid)
{
    if(!VX_Admin(playerid))return SendClientMessage(playerid,COLOR_RED,"�������� ������ ���������������."),1;
    new body[3800],row[150],name[25],message[121];gVXListCount[playerid]=0;
    new DBResult:r=db_query(gDatabase,"SELECT id,player,message,status FROM vx_reports WHERE status<2 ORDER BY id LIMIT 20");
    strcat(body,"Report\tPlayer\tStatus\tMessage\n");
    if(r)for(new i=0;i<db_num_rows(r) && i<20;i++)
    {
        new id=db_get_field_int(r,0),status=db_get_field_int(r,3);db_get_field(r,1,name,sizeof name);db_get_field(r,2,message,sizeof message);
        gVXList[playerid][gVXListCount[playerid]++]=id;
        new reportStatus[16];
        if (status) format(reportStatus,sizeof reportStatus,"� ������");
        else format(reportStatus,sizeof reportStatus,"�������");
        format(row,sizeof row,"%d\t%s\t%s\t%.65s\n",id,name,reportStatus,message);strcat(body,row);db_next_row(r);
    }
    if(r)db_free_result(r);
    if(!gVXListCount[playerid])return SendClientMessage(playerid,COLOR_GREEN,"�������� ��������� ���."),1;
    return VX_Show(playerid,VX_REPORTS,DIALOG_STYLE_TABLIST_HEADERS,"������� | �������� ��� ��������",body,"�������","�������");
}
stock VX_ReportAction(playerid,id,action,const text[]="")
{
    if(!VX_Admin(playerid))return SendClientMessage(playerid,COLOR_RED,"�������� ������ ���������������."),1;
    new q[640],name[25],owner[25],status;
    format(q,sizeof q,"SELECT player,admin,status FROM vx_reports WHERE id=%d",id);
    new DBResult:r=db_query(gDatabase,q);
    if(!r || !db_num_rows(r)){if(r)db_free_result(r);return SendClientMessage(playerid,COLOR_RED,"��������� �� �������."),1;}
    db_get_field(r,0,name,sizeof name);db_get_field(r,1,owner,sizeof owner);status=db_get_field_int(r,2);db_free_result(r);
    if(status>=2)return SendClientMessage(playerid,COLOR_RED,"��� ��������� ��� �������."),1;
    if(strlen(owner) && strcmp(owner,gName[playerid],true)!=0)return SendClientMessage(playerid,COLOR_RED,"��������� ��� ������� ������ ���������������."),1;
    new target=INVALID_PLAYER_ID;for(new i=0;i<MAX_PLAYERS;i++)if(VX_Valid(i) && !strcmp(gName[i],name,true)){target=i;break;}
    if(action==0)
    {
        format(q,sizeof q,"UPDATE vx_reports SET status=1,admin='%q',updated=%d WHERE id=%d AND status<2",gName[playerid],gettime(),id);
        if(!VX_SQL(q))return VX_Error(playerid);
        if(VX_Valid(target)){gVXReportOwner[target]=playerid;SendClientMessage(target,COLOR_GREEN,"������������� ������ ���� ���������.");}
        new m[144];format(m,sizeof m,"Report #%d taken. Player ID: %d. /reply %d [text] | /rclose %d | /spec [ID]",id,target,id,id);SendClientMessage(playerid,COLOR_ORANGE,m);return 1;
    }
    if(!strlen(owner))return SendClientMessage(playerid,COLOR_RED,"Take the report first: /rtake [report number]"),1;
    if(action==1)
    {
        new body[121];VX_CleanText(text,body,sizeof body);if(!strlen(body))return SendClientMessage(playerid,COLOR_YELLOW,"Usage: /reply [report number] [text]"),1;
        format(q,sizeof q,"INSERT INTO vx_report_messages(report,author,body,created) VALUES(%d,'%q','%q',%d)",id,gName[playerid],body,gettime());
        if(!VX_SQL(q))return VX_Error(playerid);
        new m[144];format(m,sizeof m,"[ADMIN #%d] %.114s",id,body);
        if(VX_Valid(target))SendClientMessage(target,COLOR_ORANGE,m);
        SendClientMessage(playerid,COLOR_GREEN,"����� ��������. ������ � ���� ���������� ���������.");return 1;
    }
    format(q,sizeof q,"UPDATE vx_reports SET status=2,updated=%d WHERE id=%d",gettime(),id);if(!VX_SQL(q))return VX_Error(playerid);
    if(VX_Valid(target)){gVXReportId[target]=0;gVXReportOwner[target]=INVALID_PLAYER_ID;SendClientMessage(target,COLOR_GREEN,"���� ��������� �������.");}
    SendClientMessage(playerid,COLOR_GREEN,"��������� ������� � ��������� � ������.");return 1;
}
stock VX_StopSpec(playerid)
{
    if(gVXSpec[playerid]==INVALID_PLAYER_ID)return 1;
    gVXSpec[playerid]=INVALID_PLAYER_ID;gVXRestore[playerid]=true;
    TogglePlayerSpectating(playerid,false);
    return 1;
}
stock VX_RestoreSpec(playerid)
{
    if(!gVXRestore[playerid])return 0;
    gVXRestore[playerid]=false;
    SetPlayerInterior(playerid,gVXSpecInterior[playerid]);SetPlayerVirtualWorld(playerid,gVXSpecWorld[playerid]);
    SetPlayerPos(playerid,gVXSpecPos[playerid][0],gVXSpecPos[playerid][1],gVXSpecPos[playerid][2]);SetPlayerFacingAngle(playerid,gVXSpecPos[playerid][3]);
    SetPlayerSkin(playerid,gVXSpecSkin[playerid]);SetPlayerHealth(playerid,gVXSpecHP[playerid]);SetPlayerArmour(playerid,gVXSpecArmour[playerid]);
    ResetPlayerWeapons(playerid);
    for(new i=0;i<13;i++)if(gVXSpecWeapons[playerid][i]>0 && gVXSpecAmmo[playerid][i]>0)GivePlayerWeapon(playerid,gVXSpecWeapons[playerid][i],gVXSpecAmmo[playerid][i]);
    SetCameraBehindPlayer(playerid);return 1;
}
stock VX_StartSpec(playerid,targetid)
{
    if(!VX_Admin(playerid))return SendClientMessage(playerid,COLOR_RED,"�������� ������ ���������������."),1;
    if(!VX_Valid(targetid) || targetid==playerid || gVXSpec[targetid]!=INVALID_PLAYER_ID || GetPlayerState(targetid)==PLAYER_STATE_SPECTATING)return SendClientMessage(playerid,COLOR_RED,"���������� ��������� �� ���� �������."),1;
    if(gVXHospital[playerid] || gPvpActive[playerid] || gIsJailed[playerid] || gHandcuffed[playerid])return SendClientMessage(playerid,COLOR_RED,"������ �������� ���������� �� ����� �������, ������ ��� �����."),1;
    if(gVXSpec[playerid]==INVALID_PLAYER_ID)
    {
        GetPlayerPos(playerid,gVXSpecPos[playerid][0],gVXSpecPos[playerid][1],gVXSpecPos[playerid][2]);GetPlayerFacingAngle(playerid,gVXSpecPos[playerid][3]);
        gVXSpecWorld[playerid]=GetPlayerVirtualWorld(playerid);gVXSpecInterior[playerid]=GetPlayerInterior(playerid);gVXSpecSkin[playerid]=GetPlayerSkin(playerid);
        GetPlayerHealth(playerid,gVXSpecHP[playerid]);GetPlayerArmour(playerid,gVXSpecArmour[playerid]);
        for(new i=0;i<13;i++)GetPlayerWeaponData(playerid,i,gVXSpecWeapons[playerid][i],gVXSpecAmmo[playerid][i]);
    }
    gVXSpecLastState[playerid]=-1;
    gVXSpec[playerid]=targetid;
    TogglePlayerSpectating(playerid,true);
    VX_SpecView(playerid);
    SendClientMessage(playerid,COLOR_ORANGE,"���������� ��������. ���� �������� ����������� �����; ��������: /specmenu. �����: /specoff.");
    VX_ShowSpecActions(playerid);
    return 1;
}
stock VX_SpecView(playerid)
{
    new t=gVXSpec[playerid];if(!VX_Valid(t))return VX_StopSpec(playerid);
    new v=GetPlayerVehicleID(t),targetState=GetPlayerState(t),world=GetPlayerVirtualWorld(t),interior=GetPlayerInterior(t);
    if(gVXSpecLastState[playerid]==targetState && gVXSpecLastVehicle[playerid]==v && gVXSpecLastWorld[playerid]==world && gVXSpecLastInterior[playerid]==interior) return 1;
    gVXSpecLastState[playerid]=targetState;gVXSpecLastVehicle[playerid]=v;gVXSpecLastWorld[playerid]=world;gVXSpecLastInterior[playerid]=interior;
    SetPlayerInterior(playerid,interior);SetPlayerVirtualWorld(playerid,world);
    if(IsPlayerInAnyVehicle(t))PlayerSpectateVehicle(playerid,v);else PlayerSpectatePlayer(playerid,t);
    return 1;
}
stock VX_SetWanted(playerid,level)
{
    gWantedLevel[playerid]=VexHudClamp(level,0,6);
    gVXWantedAt[playerid]=gWantedLevel[playerid]>0?gettime()+VX_WANTED_SECONDS:0;
    SetPlayerWantedLevel(playerid,gWantedLevel[playerid]);VX_Save(playerid);UpdateVexHud(playerid);return 1;
}
stock VX_DecayWanted(playerid)
{
    if(gWantedLevel[playerid]<=0){gVXWantedAt[playerid]=0;return 0;}
    if(gVXWantedAt[playerid]<=0)gVXWantedAt[playerid]=gettime()+VX_WANTED_SECONDS;
    new changed=0;
    while(gWantedLevel[playerid]>0 && gettime()>=gVXWantedAt[playerid])
    {
        gWantedLevel[playerid]--;gVXWantedAt[playerid]+=VX_WANTED_SECONDS;changed=1;
    }
    if(!gWantedLevel[playerid])gVXWantedAt[playerid]=0;
    if(changed){SetPlayerWantedLevel(playerid,gWantedLevel[playerid]);VX_Save(playerid);SendClientMessage(playerid,COLOR_GREEN,"[������] ������ 30 �����. ������� ������� ��������.");}
    return changed;
}
stock VX_Tablet(playerid)
{
    if(!VX_Officer(playerid))return SendClientMessage(playerid,COLOR_RED,"�������� ����������� ������� � FBI."),1;
    RP_Message(playerid,"�������: /case ID, /fines ID, /vcheck ID, /camlogs. /rphelp � �������.");
    new body[4000],row[128];gVXListCount[playerid]=0;
    strcat(body,"ID\tSuspect\tStars\tNext removal\n");
    for(new i=0;i<MAX_PLAYERS && gVXListCount[playerid]<40;i++)if(VX_Valid(i) && gWantedLevel[i]>0)
    {
        new n=gVXListCount[playerid]++;gVXList[playerid][n]=i;gVXListSession[playerid][n]=gVXSession[i];
        format(row,sizeof row,"%d\t%s\t%d / 6\t%d min\n",i,gName[i],gWantedLevel[i],(gVXWantedAt[i]-gettime()+59)/60);strcat(body,row);
    }
    if(!gVXListCount[playerid])return SendClientMessage(playerid,COLOR_GREEN,"������� � ������� ������ ��� � ����."),1;
    return VX_Show(playerid,VX_TABLET,DIALOG_STYLE_TABLIST_HEADERS,"������� / FBI | ������",body,"������������","�������");
}
stock VX_Track(playerid,targetid)
{
    if(!VX_Officer(playerid))return SendClientMessage(playerid,COLOR_RED,"�������� ����������� ������� � FBI."),1;
    if(!VX_Valid(targetid) || !gWantedLevel[targetid])return SendClientMessage(playerid,COLOR_RED,"����� �� � ���� ��� ������ �� ��������� � �������."),1;
    if(gWorkStage[playerid]>0 || gDrivingTestStage[playerid]>0)return SendClientMessage(playerid,COLOR_RED,"Finish your job or driving test first."),1;
    gPursuitTarget[playerid]=targetid;gGpsActive[playerid]=false;RefreshCarjackPursuits();
    new m[144];format(m,sizeof m,"[TABLET] %s | Wanted %d/6 | Interior %d | World %d | /stoptrack",gName[targetid],gWantedLevel[targetid],GetPlayerInterior(targetid),GetPlayerVirtualWorld(targetid));
    SendClientMessage(playerid,COLOR_BLUE,m);return 1;
}
stock VX_InsideLobby(playerid)
{
    if(GetPlayerVirtualWorld(playerid)!=VX_HOSPITAL_WORLD || GetPlayerInterior(playerid)!=0) return 0;
    new Float:x,Float:y,Float:z;GetPlayerPos(playerid,x,y,z);
    return x>2042.5 && x<2074.5 && y>1986.7 && y<2007.0 && z>999.0 && z<1005.0;
}
stock VX_InsideWard(playerid)
{
    if(GetPlayerVirtualWorld(playerid)!=VX_HOSPITAL_WORLD || GetPlayerInterior(playerid)!=0) return 0;
    new Float:x,Float:y,Float:z;GetPlayerPos(playerid,x,y,z);
    return x>1979.5 && x<2022.0 && y>1982.9 && y<2012.4 && z>999.0 && z<1005.0;
}
stock VX_EnterLobby(playerid)
{
    if(!VX_Valid(playerid) || gIsJailed[playerid]) return 0;
    if(gVXHospital[playerid]) return VX_EnterHospital(playerid);
    VX_CancelWardLoad(playerid);
    if(IsPlayerInAnyVehicle(playerid)) RemovePlayerFromVehicle(playerid);
    ClearAnimations(playerid);
    SetPlayerSpecialAction(playerid,SPECIAL_ACTION_NONE);
    SetPlayerInterior(playerid,0);
    SetPlayerVirtualWorld(playerid,VX_HOSPITAL_WORLD);
    SetPlayerPos(playerid,VX_LOBBY_X,VX_LOBBY_Y,VX_LOBBY_Z);
    SetPlayerFacingAngle(playerid,0.0);
    SetCameraBehindPlayer(playerid);
    TogglePlayerControllable(playerid,false);
    gLastPickupTick[playerid]=GetTickCount();
    gVXWardTimer[playerid]=SetTimerEx("VX_WardReady",VX_WARD_LOAD_MS,false,"iii",playerid,gVXSession[playerid],gVXWardSequence[playerid]);
    if(!gVXWardTimer[playerid])TogglePlayerControllable(playerid,true);
    SendClientMessage(playerid,COLOR_BLUE,"[����] ������� ������������: /medcert. ������ ��������� ����� � ������: /ward. �����: /exit.");
    return 1;
}
stock VX_EnterWard(playerid)
{
    if(!VX_Valid(playerid) || GetPlayerVirtualWorld(playerid)!=VX_HOSPITAL_WORLD) return 0;
    if(gFaction[playerid]!=FACTION_HOSPITAL || gFactionRank[playerid]<1)
        return SendClientMessage(playerid,COLOR_RED,"[����] ������ � ������ ������ ����������� ����. ��������� ���������� ��� ��������������."),1;
    if(!VX_InsideLobby(playerid)) return SendClientMessage(playerid,COLOR_YELLOW,"[����] ��������� � ����� ������ � �����."),1;
    ClearAnimations(playerid);
    SetPlayerPos(playerid,VX_WARD_LOBBY_X,VX_WARD_LOBBY_Y,VX_WARD_Z);
    SetPlayerFacingAngle(playerid,270.0);SetCameraBehindPlayer(playerid);
    gLastPickupTick[playerid]=GetTickCount();
    SendClientMessage(playerid,COLOR_GREEN,"[����] �� ����� � ���������. �����: /lobby ��� ������ � �����.");
    return 1;
}
stock VX_ReturnLobby(playerid)
{
    if(!VX_Valid(playerid) || !VX_InsideWard(playerid))return 0;
    if(gVXHospital[playerid])return SendClientMessage(playerid,COLOR_RED,"[����] ������� ��������� ������� �� �����."),1;
    VX_FreeBed(playerid);ClearAnimations(playerid);
    TogglePlayerControllable(playerid,true);
    SetPlayerPos(playerid,VX_LOBBY_WARD_X-2.0,VX_LOBBY_WARD_Y,VX_LOBBY_Z);
    SetPlayerFacingAngle(playerid,270.0);SetCameraBehindPlayer(playerid);
    gLastPickupTick[playerid]=GetTickCount();
    SendClientMessage(playerid,COLOR_GREEN,"[����] �� ��������� � ����. �����: /exit.");
    return 1;
}
stock VX_MedCertificate(playerid)
{
    if(!VX_Valid(playerid) || !VX_InsideLobby(playerid)
        || !IsPlayerInRangeOfPoint(playerid,4.0,VX_LOBBY_CERT_X,VX_LOBBY_CERT_Y,VX_LOBBY_Z))
        return SendClientMessage(playerid,COLOR_YELLOW,"[����] ��������� � ������ ������������."),1;
    new q[256],DBResult:r,until=0;
    format(q,sizeof q,"SELECT valid_until FROM vx_medcert WHERE name='%q'",gName[playerid]);
    r=db_query(gDatabase,q);
    if(!r)return VX_Error(playerid);
    if(db_num_rows(r))until=db_get_field_int(r,0);
    db_free_result(r);
    if(until>gettime())
    {
        new text[120];format(text,sizeof text,"[����] ���� ������� ������������� ��� %d ��.",(until-gettime()+86399)/86400);
        SendClientMessage(playerid,COLOR_GREEN,text);return 1;
    }
    if(gMoney[playerid]<VX_CERT_PRICE)return SendClientMessage(playerid,COLOR_RED,"[����] ���������� ����� 1000 $. ������������ ��������."),1;
    new cash=gMoney[playerid]-VX_CERT_PRICE;
    if(!VX_Begin())return VX_Error(playerid);
    format(q,sizeof q,"INSERT OR REPLACE INTO vx_medcert(name,valid_until) VALUES('%q',%d)",gName[playerid],gettime()+VX_CERT_DAYS*86400);
    VX_SQL(q);VX_MoneySQL(playerid,cash,gBankMoney[playerid]);
    if(!VX_Commit())return VX_Error(playerid);
    VX_MoneySync(playerid,cash,gBankMoney[playerid]);
    SendClientMessage(playerid,COLOR_GREEN,"[����] ����������� ������� ��������� �� 7 ����. ���������: 1000 $.");
    return 1;
}
public VX_HospitalOutsideReady(playerid,session)
{
    if(!VX_Valid(playerid) || session!=gVXSession[playerid])return 0;
    if(GetPlayerVirtualWorld(playerid)!=0 || GetPlayerInterior(playerid)!=0)return 0;
    new Float:x,Float:y,Float:z;GetPlayerPos(playerid,x,y,z);
    if(z<12.5 && x>1140.0 && x<1210.0 && y> -1360.0 && y< -1280.0)
        SetPlayerPos(playerid,1178.5,-1326.5,13.7);
    if(!gHandcuffed[playerid] && !gTaserStunned[playerid])TogglePlayerControllable(playerid,true);
    SetCameraBehindPlayer(playerid);
    return 1;
}
stock VX_EnterHospital(playerid)
{
    if(!VX_Valid(playerid) || gIsJailed[playerid]) return 0;
    if(!gVXHospital[playerid])return VX_EnterLobby(playerid);
    VX_CancelWardLoad(playerid);
    VX_FreeBed(playerid);
    if(IsPlayerInAnyVehicle(playerid)) RemovePlayerFromVehicle(playerid);
    ClearAnimations(playerid);
    SetPlayerSpecialAction(playerid,SPECIAL_ACTION_NONE);
    SetPlayerInterior(playerid,0);
    SetPlayerVirtualWorld(playerid,VX_HOSPITAL_WORLD);
    SetPlayerPos(playerid,VX_WARD_X,VX_WARD_Y,VX_WARD_Z);
    SetPlayerFacingAngle(playerid,180.0);
    SetCameraBehindPlayer(playerid);
    TogglePlayerControllable(playerid,false);
    gLastPickupTick[playerid]=GetTickCount();
    gVXWardTimer[playerid]=SetTimerEx("VX_WardReady",VX_WARD_LOAD_MS,false,"iii",
        playerid,gVXSession[playerid],gVXWardSequence[playerid]);
    if(!gVXWardTimer[playerid]) TogglePlayerControllable(playerid,true);
    if(gVXHospital[playerid])
    {
        ResetPlayerWeapons(playerid); SetPlayerHealth(playerid,30.0); SetPlayerArmour(playerid,0.0);
        SendClientMessage(playerid,COLOR_YELLOW,"[����] ������� ��������� �����: /bed ��� ALT. ����� �������: /exit.");
    }
    else SendClientMessage(playerid,COLOR_BLUE,"[����] ���������. /lobby - ����, /exit - �����.");
    return 1;
}

stock VX_HospitalExit(playerid)
{
    if(!VX_Valid(playerid)) return 0;
    if(GetPlayerVirtualWorld(playerid)!=VX_HOSPITAL_WORLD || GetPlayerInterior(playerid)!=0)
        return RP_Message(playerid,"�� �� � ������ ����.");
    if(gVXHospital[playerid])
    {
        if(gVXBed[playerid]<0) return RP_Message(playerid,"[����] ����� ������� ������� �����: /bed ��� ALT. /hospitalinfo - ����������.");
        new msg[144];
        format(msg,sizeof msg,"[����] �� ������� %d ���. %d ���. ����� ������� ����� ���������.",gVXTreatment[playerid]/60,gVXTreatment[playerid]%60);
        return RP_Message(playerid,msg);
    }
    if(gIsJailed[playerid] || gHandcuffed[playerid] || gTaserStunned[playerid]) return 1;
    // The command works anywhere in this ward after discharge, including a fallen player.
    VX_CancelWardLoad(playerid); VX_FreeBed(playerid);
    ClearAnimations(playerid); TogglePlayerControllable(playerid,true);
    SetPlayerSpecialAction(playerid,SPECIAL_ACTION_NONE);
    SetPlayerInterior(playerid,0);SetPlayerVirtualWorld(playerid,0);
    // Exit onto the exterior pavement, not into the hospital collision mesh.
    SetPlayerPos(playerid,1178.5,-1326.5,13.7); SetPlayerFacingAngle(playerid,180.0);
    TogglePlayerControllable(playerid,false);
    SetTimerEx("VX_HospitalOutsideReady",1800,false,"ii",playerid,gVXSession[playerid]);
    SetCameraBehindPlayer(playerid);
    gLastPickupTick[playerid]=GetTickCount();
    SendClientMessage(playerid,COLOR_GREEN,"[����] �� ����� �� ��������.");
    return 1;
}

stock VX_FreeBed(playerid)
{
    new bed=gVXBed[playerid];
    if(bed>=0 && bed<VX_BEDS && gVXBedOwner[bed]==playerid)
    {
        gVXBedOwner[bed]=INVALID_PLAYER_ID;
        VX_UpdateBedLabel(bed);
    }
    gVXBed[playerid]=-1;
    return 1;
}

stock VX_OccupyBed(playerid)
{
    if(gVXWardTimer[playerid]) return RP_Message(playerid,"[����] ��������� �����������. ���������� ��������� �������������.");
    if(!gVXHospital[playerid] || !VX_InsideWard(playerid))return SendClientMessage(playerid,COLOR_RED,"[����] ��� ������� ����� ���������� � ������."),1;
    if(gVXBed[playerid]>=0)return SendClientMessage(playerid,COLOR_YELLOW,"������� ��� ���. ����������� �� �����."),1;
    for(new b=0;b<VX_BEDS;b++)
    {
        if(!IsPlayerInRangeOfPoint(playerid,3.0,gVXBedPos[b][0],gVXBedPos[b][1],gVXBedPos[b][2]))continue;
        if(gVXBedOwner[b]!=INVALID_PLAYER_ID)continue;
        gVXBedOwner[b]=playerid;gVXBed[playerid]=b;VX_UpdateBedLabel(b);
        SetPlayerPos(playerid,gVXBedPos[b][0],gVXBedPos[b][1],gVXBedPos[b][2]+0.25);SetPlayerFacingAngle(playerid,90.0);
        // GTA:SA BEACH bather is a lying/rest animation, rather than a knocked-down combat pose.
        ApplyAnimation(playerid,"BEACH","bather",4.1,1,0,0,1,0,1);TogglePlayerControllable(playerid,false);
        new m[144];format(m,sizeof m,"[����] ����� %d. �������: %d ���. ���������: /hospitalinfo.",b+1,gVXTreatment[playerid]);SendClientMessage(playerid,COLOR_BLUE,m);
        VX_Save(playerid);return 1;
    }
    return SendClientMessage(playerid,COLOR_YELLOW,"[����] ��������� � ��������� ����� �� 3 ����� � ������� /bed."),1;
}
stock VX_DeathStart(playerid)
{
    VX_CancelWardLoad(playerid);
    if(!gLogged[playerid])return 0;
    VX_Hangup(playerid);VX_FreeBed(playerid);VX_MedCancel(playerid);
    if(!gIsJailed[playerid]){gVXHospital[playerid]=true;gVXTreatment[playerid]=VX_HOSPITAL_SECONDS;}
    gHandcuffed[playerid]=false;gCuffOfficer[playerid]=INVALID_PLAYER_ID;gTaserStunned[playerid]=false;TogglePlayerControllable(playerid,true);
    gWorkStage[playerid]=0;gGpsActive[playerid]=false;DisablePlayerCheckpoint(playerid);
    if(gWorkVehicle[playerid]!=INVALID_VEHICLE_ID && GetVehicleModel(gWorkVehicle[playerid]))DestroyVehicle(gWorkVehicle[playerid]);
    gWorkVehicle[playerid]=INVALID_VEHICLE_ID;
    if(gCarjackActive[playerid])
    {
        new v=gCarjackVehicle[playerid];
        if(v>0 && v<MAX_VEHICLES && GetVehicleModel(v)){gCarjackVehicleOwner[v]=INVALID_PLAYER_ID;DestroyVehicle(v);}
        gCarjackActive[playerid]=false;gCarjackUnlocked[playerid]=false;gCarjackVehicle[playerid]=INVALID_VEHICLE_ID;
        RemovePlayerMapIcon(playerid,48);
    }
    if(gDrivingTestVehicle[playerid]!=INVALID_VEHICLE_ID && GetVehicleModel(gDrivingTestVehicle[playerid]))DestroyVehicle(gDrivingTestVehicle[playerid]);
    gDrivingTestVehicle[playerid]=INVALID_VEHICLE_ID;gDrivingTestStage[playerid]=0;
    VX_Save(playerid);
    if(gVXDeathTimer[playerid])KillTimer(gVXDeathTimer[playerid]);
    gVXDeathTimer[playerid]=SetTimerEx("VX_DeathSpawn",3000,false,"ii",playerid,gVXSession[playerid]);
    return 1;
}
public VX_DeathSpawn(playerid,session)
{
    if(!VX_Valid(playerid) || gVXSession[playerid]!=session)return 0;
    gVXDeathTimer[playerid]=0;
    SetSpawnInfo(playerid,0,VX_RespawnSkin(playerid),2000.0,1997.0,1001.0,0.0,0,0,0,0,0,0);
    SpawnPlayer(playerid);return 1;
}
stock VX_MedRequest(playerid)
{
    if(gVXHospital[playerid])return SendClientMessage(playerid,COLOR_YELLOW,"�� ��� � ����. ������� �����: /bed."),1;
    if(gVXMedCall[playerid])return SendClientMessage(playerid,COLOR_YELLOW,"��� ����� ������ ��� ���������������."),1;
    if(gettime()-gVXLastMedCall[playerid]<60)return SendClientMessage(playerid,COLOR_RED,"Wait 60 seconds before calling again."),1;
    gVXMedCall[playerid]=1;gVXMedAssigned[playerid]=INVALID_PLAYER_ID;gVXLastMedCall[playerid]=gettime();
    new m[144];format(m,sizeof m,"[���� 103] Emergency call: %s [%d]. Accept: /maccept %d",gName[playerid],playerid,playerid);
    for(new i=0;i<MAX_PLAYERS;i++)if(VX_Medic(i))SendClientMessage(i,COLOR_BLUE,m);
    SendClientMessage(playerid,COLOR_GREEN,"[103] ����� ������ ���������������. ��������: /medcancel.");return 1;
}
stock VX_MedCancel(playerid)
{
    new medic=gVXMedAssigned[playerid];
    if(VX_Valid(medic)){RemovePlayerMapIcon(medic,57);DisablePlayerCheckpoint(medic);SendClientMessage(medic,COLOR_YELLOW,"[103] ����������� ����� ��������.");}
    gVXMedCall[playerid]=0;gVXMedAssigned[playerid]=INVALID_PLAYER_ID;return 1;
}
stock VX_MedAccept(playerid,targetid)
{
    if(!VX_Medic(playerid))return SendClientMessage(playerid,COLOR_RED,"���� staff on duty only. /mduty"),1;
    if(!VX_Valid(targetid) || targetid==playerid || gVXMedCall[targetid]!=1)return SendClientMessage(playerid,COLOR_RED,"����� ���������� ��� ��� ������."),1;
    if(gWorkStage[playerid]>0 || gDrivingTestStage[playerid]>0)return SendClientMessage(playerid,COLOR_RED,"Finish your current route first."),1;
    for(new i=0;i<MAX_PLAYERS;i++)if(gVXMedCall[i]==2 && gVXMedAssigned[i]==playerid)return SendClientMessage(playerid,COLOR_YELLOW,"������� ��������� ������� �����."),1;
    gVXMedCall[targetid]=2;gVXMedAssigned[targetid]=playerid;gGpsActive[playerid]=false;
    new Float:x,Float:y,Float:z,m[144];GetPlayerPos(targetid,x,y,z);SetPlayerCheckpoint(playerid,x,y,z,4.0);
    format(m,sizeof m,"[103] %s is coming to help you.",gName[playerid]);SendClientMessage(targetid,COLOR_GREEN,m);
    format(m,sizeof m,"[����] Call accepted: %s, interior %d, world %d. /heal %d",gName[targetid],GetPlayerInterior(targetid),GetPlayerVirtualWorld(targetid),targetid);
    SendClientMessage(playerid,COLOR_BLUE,m);return 1;
}
stock VX_Heal(playerid,targetid)
{
    return RP_MedTreat(playerid,targetid,2);
}
stock VX_HospitalPickup(playerid,pickupid)
{
    if(pickupid==gOrgExitPickup[FACTION_HOSPITAL])
    {
        if(VX_InsideLobby(playerid)
            && IsPlayerInRangeOfPoint(playerid,3.0,VX_LOBBY_EXIT_X,VX_LOBBY_EXIT_Y,VX_LOBBY_Z)
            && gettime()>=gVXWardNotice[playerid])
        {
            gVXWardNotice[playerid]=gettime()+4;
            VX_HospitalExit(playerid);
        }
        return 1;
    }
    if(pickupid==gVXLobbyWardPickup)
    {
        if(VX_InsideLobby(playerid) && GetTickCount()-gLastPickupTick[playerid]>=2000)
            VX_EnterWard(playerid);
        return 1;
    }
    if(pickupid==gVXWardLobbyPickup)
    {
        if(VX_InsideWard(playerid) && GetTickCount()-gLastPickupTick[playerid]>=2000)
            VX_ReturnLobby(playerid);
        return 1;
    }
    if(pickupid==gVXMedCertPickup)
    {
        if(VX_InsideLobby(playerid) && GetTickCount()-gLastPickupTick[playerid]>=1500)
        {
            gLastPickupTick[playerid]=GetTickCount();
            SendClientMessage(playerid,COLOR_BLUE,"[����] �������� ���������� �� 7 ����: /medcert (1000 $).");
        }
        return 1;
    }
    if(pickupid==gOrgEnterPickup[FACTION_HOSPITAL])
    {
        if(GetPlayerVirtualWorld(playerid)==0 && GetPlayerInterior(playerid)==0
            && IsPlayerInRangeOfPoint(playerid,3.0,1176.7,-1322.5,13.5)
            && (gLastPickupTick[playerid]==0 || GetTickCount()-gLastPickupTick[playerid]>=2000))
            VX_EnterHospital(playerid);
        return 1;
    }
    if(pickupid==gLockerPickup[FACTION_HOSPITAL])
    {
        if(GetPlayerVirtualWorld(playerid)==VX_HOSPITAL_WORLD && gettime()>=gVXWardNotice[playerid])
        {
            gVXWardNotice[playerid]=gettime()+4;
            OnPlayerCommandText(playerid,"/mduty");
        }
        return 1;
    }
    if(pickupid==gVXHospitalGaragePickup)
    {
        if(GetPlayerVirtualWorld(playerid)==0 && GetPlayerInterior(playerid)==0
            && IsPlayerInRangeOfPoint(playerid,4.0,1192.1529,-1335.5710,13.3984)
            && gettime()>=gVXWardNotice[playerid])
        {
            gVXWardNotice[playerid]=gettime()+4;
            OnPlayerCommandText(playerid,"/hgarage");
        }
        return 1;
    }
    for(new bed=0;bed<VX_BEDS;bed++) if(pickupid==gVXBedPickup[bed])
    {
        if(GetPlayerVirtualWorld(playerid)==VX_HOSPITAL_WORLD && gettime()>=gVXWardNotice[playerid])
        {
            gVXWardNotice[playerid]=gettime()+4;
            SendClientMessage(playerid,COLOR_BLUE,"[����] ������� ��������� �����: /bed ��� ALT. ����� �������: /exit.");
        }
        return 1;
    }
    return 0;
}

stock VX_ShowFamily(playerid)
{
    VX_LoadFamily(playerid);
    if(!gVXFamily[playerid])return SendClientMessage(playerid,COLOR_YELLOW,"No family. /fcreate [name] costs 100000. /faccept accepts an invitation."),1;
    new q[256],name[41],owner[25],body[2800],row[96];
    format(q,sizeof q,"SELECT name,owner,balance FROM vx_families WHERE id=%d",gVXFamily[playerid]);new DBResult:r=db_query(gDatabase,q);
    if(r && db_num_rows(r))
    {
        db_get_field(r,0,name,sizeof name);db_get_field(r,1,owner,sizeof owner);
        format(body,sizeof body,"%s | ��������: %s | �����: %d\n/fc [text] | /finvite [ID] | /fleave\n/frank [ID] [1-3] | /fkick [ID]\n/fdeposit [amount] | /fwithdraw [amount]\n\nMembers:\n",name,owner,db_get_field_int(r,2));
    }
    if(r)db_free_result(r);
    format(q,sizeof q,"SELECT name,rank FROM vx_family_members WHERE family=%d ORDER BY rank DESC,name LIMIT 30",gVXFamily[playerid]);r=db_query(gDatabase,q);
    if(r)for(new i=0;i<db_num_rows(r);i++){db_get_field(r,0,owner,sizeof owner);format(row,sizeof row,"%s - rank %d\n",owner,db_get_field_int(r,1));strcat(body,row);db_next_row(r);}
    if(r)db_free_result(r);
    return VX_Show(playerid,VX_FAMILY,DIALOG_STYLE_MSGBOX,"VEXORIUM | �����",body,"OK","�������");
}
stock VX_CreateFamily(playerid,const text[])
{
    VX_LoadFamily(playerid);if(gVXFamily[playerid])return SendClientMessage(playerid,COLOR_RED,"Leave your current family first."),1;
    new name[41];VX_CleanText(text,name,sizeof name);if(strlen(name)<3)return SendClientMessage(playerid,COLOR_YELLOW,"Usage: /fcreate [name, 3-40 characters]"),1;
    if(gMoney[playerid]<VX_FAMILY_PRICE)return SendClientMessage(playerid,COLOR_RED,"�������� ����� ����� 100000 ������."),1;
    if(!VX_Begin())return VX_Error(playerid);
    new q[400];format(q,sizeof q,"INSERT INTO vx_families(name,owner) VALUES('%q','%q')",name,gName[playerid]);VX_SQL(q);
    format(q,sizeof q,"INSERT INTO vx_family_members(name,family,rank) SELECT '%q',id,4 FROM vx_families WHERE owner='%q'",gName[playerid],gName[playerid]);VX_SQL(q);
    VX_MoneySQL(playerid,gMoney[playerid]-VX_FAMILY_PRICE,gBankMoney[playerid]);
    if(!VX_Commit())return SendClientMessage(playerid,COLOR_RED,"����� �� �������: ��������, �������� ������. ������ �� �������."),1;
    VX_MoneySync(playerid,gMoney[playerid]-VX_FAMILY_PRICE,gBankMoney[playerid]);VX_LoadFamily(playerid);return VX_ShowFamily(playerid);
}
stock VX_FamilyInvite(playerid,targetid)
{
    VX_LoadFamily(playerid);
    if(!gVXFamily[playerid] || gVXFamilyRank[playerid]<3)return SendClientMessage(playerid,COLOR_RED,"�������� ����������� ��� ������ �����."),1;
    if(!VX_Near(playerid,targetid) || targetid==playerid)return SendClientMessage(playerid,COLOR_RED,"Stand near the invitee."),1;
    VX_LoadFamily(targetid);if(gVXFamily[targetid])return SendClientMessage(playerid,COLOR_RED,"����� ��� ������� � �����."),1;
    gVXInvite[targetid]=gVXFamily[playerid];gVXInviteAt[targetid]=gettime()+60;
    new m[144];format(m,sizeof m,"[FAMILY] %s invites you to family #%d. /faccept within 60 seconds.",gName[playerid],gVXFamily[playerid]);SendClientMessage(targetid,COLOR_YELLOW,m);
    SendClientMessage(playerid,COLOR_GREEN,"����������� ����������.");return 1;
}
stock VX_FamilyAccept(playerid)
{
    VX_LoadFamily(playerid);
    if(gVXFamily[playerid] || !gVXInvite[playerid] || gettime()>gVXInviteAt[playerid])return SendClientMessage(playerid,COLOR_RED,"No valid invitation or you are already in a family."),1;
    new q[320];format(q,sizeof q,"INSERT INTO vx_family_members(name,family,rank) SELECT '%q',id,1 FROM vx_families WHERE id=%d",gName[playerid],gVXInvite[playerid]);
    if(!VX_SQL(q))return VX_Error(playerid);
    gVXInvite[playerid]=0;VX_LoadFamily(playerid);return VX_ShowFamily(playerid);
}
stock VX_FamilyMoney(playerid,amount,bool:withdraw)
{
    VX_LoadFamily(playerid);
    if(!gVXFamily[playerid] || amount<=0 || (withdraw && gVXFamilyRank[playerid]<3))return SendClientMessage(playerid,COLOR_RED,"Invalid amount or insufficient family permissions."),1;
    new q[256];format(q,sizeof q,"SELECT balance FROM vx_families WHERE id=%d",gVXFamily[playerid]);new DBResult:r=db_query(gDatabase,q);
    if(!r || !db_num_rows(r)){if(r)db_free_result(r);return VX_Error(playerid);}
    new balance=db_get_field_int(r,0),cash=gMoney[playerid];db_free_result(r);
    if(withdraw){if(balance<amount || cash>MAX_MONEY-amount)return SendClientMessage(playerid,COLOR_RED,"Insufficient funds or cash limit."),1;balance-=amount;cash+=amount;}
    else{if(cash<amount || balance>MAX_MONEY-amount)return SendClientMessage(playerid,COLOR_RED,"Insufficient funds or treasury limit."),1;balance+=amount;cash-=amount;}
    if(!VX_Begin())return VX_Error(playerid);
    format(q,sizeof q,"UPDATE vx_families SET balance=%d WHERE id=%d",balance,gVXFamily[playerid]);VX_SQL(q);VX_MoneySQL(playerid,cash,gBankMoney[playerid]);
    if (withdraw) VX_BankLog(playerid,"family_withdraw",amount);
    else VX_BankLog(playerid,"family_deposit",-amount);
    if(!VX_Commit())return VX_Error(playerid);
    VX_MoneySync(playerid,cash,gBankMoney[playerid]);return VX_ShowFamily(playerid);
}
stock VX_FamilyRank(playerid,targetid,rank)
{
    VX_LoadFamily(playerid);if(!VX_Valid(targetid))return SendClientMessage(playerid,COLOR_RED,"Player not found."),1;VX_LoadFamily(targetid);
    if(gVXFamilyRank[playerid]!=4 || !gVXFamily[playerid] || gVXFamily[playerid]!=gVXFamily[targetid] || targetid==playerid || rank<0 || rank>3)return SendClientMessage(playerid,COLOR_RED,"Only the leader can change another member's rank (1-3) or remove them."),1;
    new q[256];
    if(rank==0)format(q,sizeof q,"DELETE FROM vx_family_members WHERE name='%q' AND family=%d",gName[targetid],gVXFamily[playerid]);
    else format(q,sizeof q,"UPDATE vx_family_members SET rank=%d WHERE name='%q' AND family=%d",rank,gName[targetid],gVXFamily[playerid]);
    if(!VX_SQL(q))return VX_Error(playerid);
    VX_LoadFamily(targetid);SendClientMessage(targetid,COLOR_YELLOW,"���� �������� ��� ���� � ����� ��������.");return VX_ShowFamily(playerid);
}
stock VX_FamilyLeave(playerid)
{
    VX_LoadFamily(playerid);if(!gVXFamily[playerid])return 1;
    if(gVXFamilyRank[playerid]==4)return SendClientMessage(playerid,COLOR_YELLOW,"Leader: withdraw treasury funds, then use /fdisband CONFIRM."),1;
    new q[200];format(q,sizeof q,"DELETE FROM vx_family_members WHERE name='%q'",gName[playerid]);if(!VX_SQL(q))return VX_Error(playerid);
    VX_LoadFamily(playerid);SendClientMessage(playerid,COLOR_YELLOW,"�� ����� �� �����.");return 1;
}
stock VX_BizList(playerid)
{
    new q[128],body[1600],row[160],name[33],owner[25];
    format(q,sizeof q,"SELECT id,name,owner,price FROM vx_businesses ORDER BY id LIMIT 5");new DBResult:r=db_query(gDatabase,q);
    strcat(body,"ID\tBusiness\tOwner\tPrice\n");gVXListCount[playerid]=0;
    if(r)for(new i=0;i<db_num_rows(r) && i<5;i++)
    {
        new id=db_get_field_int(r,0);db_get_field(r,1,name,sizeof name);db_get_field(r,2,owner,sizeof owner);
        if (!strlen(owner)) format(owner,sizeof owner,"��������");
        gVXList[playerid][gVXListCount[playerid]++]=id;format(row,sizeof row,"%d\t%s\t%s\t%d\n",id,name,owner,db_get_field_int(r,3));strcat(body,row);db_next_row(r);
    }
    if(r)db_free_result(r);return VX_Show(playerid,VX_BUSINESSES,DIALOG_STYLE_TABLIST_HEADERS,"VEXORIUM | �������",body,"�������","�������");
}
stock VX_ShowBiz(playerid,id)
{
    if(id<1 || id>5)return SendClientMessage(playerid,COLOR_YELLOW,"Usage: /biz [1-5] or /businesses"),1;
    new q[192],title[128],name[33],owner[25],body[700];format(q,sizeof q,"SELECT name,owner,price,till,stock,unitprice FROM vx_businesses WHERE id=%d",id);new DBResult:r=db_query(gDatabase,q);
    if(!r || !db_num_rows(r)){if(r)db_free_result(r);return VX_Error(playerid);}
    db_get_field(r,0,name,sizeof name);db_get_field(r,1,owner,sizeof owner);
    if (!strlen(owner)) format(owner,sizeof owner,"��������");
    format(title,sizeof title,"%s | ��������: %s",name,owner);
    format(body,sizeof body,"������ ������: %d\n������ ����� / ������: %d\n������� �������: %d\n�������� 50 ������: 5000\n������� ������ �� 70% ����\n�������� ����: /bizprice %d [100-10000]\nGPS � ������� | �������: %d",db_get_field_int(r,2),db_get_field_int(r,5),db_get_field_int(r,3),id,db_get_field_int(r,4));
    db_free_result(r);gVXSelectedBiz[playerid]=id;return VX_Show(playerid,VX_BIZ,DIALOG_STYLE_LIST,title,body);
}
stock VX_BizAction(playerid,id,action,priceInput=0)
{
    if(id<1 || id>5)return 1;
    if(GetPlayerVirtualWorld(playerid)!=0 || GetPlayerInterior(playerid)!=0 || !IsPlayerInRangeOfPoint(playerid,12.0,gVXBizPos[id-1][0],gVXBizPos[id-1][1],gVXBizPos[id-1][2]))return SendClientMessage(playerid,COLOR_RED,"��������� � �������, ��������� /gps."),1;
    new q[400],owner[25];format(q,sizeof q,"SELECT owner,price,till,stock,unitprice FROM vx_businesses WHERE id=%d",id);new DBResult:r=db_query(gDatabase,q);
    if(!r || !db_num_rows(r)){if(r)db_free_result(r);return VX_Error(playerid);}
    db_get_field(r,0,owner,sizeof owner);new price=db_get_field_int(r,1),till=db_get_field_int(r,2),stockCount=db_get_field_int(r,3),unitprice=db_get_field_int(r,4);db_free_result(r);
    new cash=gMoney[playerid],delta=0,item=-1,oldItem=0;
    if(action>=2 && strcmp(owner,gName[playerid],true))return SendClientMessage(playerid,COLOR_RED,"��� �������� �������� ������ ��������� �������."),1;
    if(action==0)
    {
        if(strlen(owner) || cash<price)return SendClientMessage(playerid,COLOR_RED,"������ ����� ��� � ��� ������������ �����."),1;
        format(q,sizeof q,"SELECT id FROM vx_businesses WHERE owner='%q'",gName[playerid]);r=db_query(gDatabase,q);new owned=(r && db_num_rows(r)>0);if(r)db_free_result(r);
        if(owned)return SendClientMessage(playerid,COLOR_RED,"����� ����� ������� ������ ����� ��������."),1;
        cash-=price;format(owner,sizeof owner,"%s",gName[playerid]);
    }
    else if(action==1)
    {
        if(cash<unitprice || stockCount<1 || till>MAX_MONEY-unitprice)return SendClientMessage(playerid,COLOR_RED,"������������ �����, ��� ������ ��� ����� �����������."),1;
        if(id==1 || id==4)item=1;else if(id==2 || id==5)item=2;
        if(item>=0 && !VX_CanCarry(playerid,item,1))return SendClientMessage(playerid,COLOR_RED,"��������� ��������."),1;
        if(id==3 && (!IsPlayerInAnyVehicle(playerid) || GetPlayerState(playerid)!=PLAYER_STATE_DRIVER))return SendClientMessage(playerid,COLOR_RED,"��� ������� ������ �� ���� ������ ����������."),1;
        cash-=unitprice;till+=unitprice;stockCount--;delta=1;
    }
    else if(action==2){if(till<=0 || cash>MAX_MONEY-till)return SendClientMessage(playerid,COLOR_RED,"����� ����� ��� ��������� �������� �����."),1;cash+=till;till=0;}
    else if(action==3){if(cash<5000 || stockCount>950)return SendClientMessage(playerid,COLOR_RED,"����� 5000 $. ������������ ����� � 1000 ��."),1;cash-=5000;stockCount+=50;}
    else if(action==4)
    {
        if(till>0)return SendClientMessage(playerid,COLOR_YELLOW,"����� �������� �������� ������� �� �����."),1;
        new refund=price/10*7;if(cash>MAX_MONEY-refund)return 1;cash+=refund;owner[0]='\0';
    }
    else if(action==5){if(priceInput<100 || priceInput>10000)return SendClientMessage(playerid,COLOR_RED,"���� ������ ���� �� 100 �� 10000 $."),1;unitprice=priceInput;}
    else return 1;
    if(!VX_Begin())return VX_Error(playerid);
    format(q,sizeof q,"UPDATE vx_businesses SET owner='%q',till=%d,stock=%d,unitprice=%d WHERE id=%d",owner,till,stockCount,unitprice,id);VX_SQL(q);
    VX_MoneySQL(playerid,cash,gBankMoney[playerid]);VX_BankLog(playerid,"business",cash-gMoney[playerid]);
    if(item>=0 && delta){oldItem=VX_ItemCount(playerid,item);VX_SetItem(playerid,item,oldItem+1);VX_ItemsSQL(playerid);}
    if(!VX_Commit()){if(item>=0 && delta)VX_SetItem(playerid,item,oldItem);return VX_Error(playerid);}
    VX_MoneySync(playerid,cash,gBankMoney[playerid]);
    if(id==3 && action==1){RepairVehicle(GetPlayerVehicleID(playerid));SetVehicleHealth(GetPlayerVehicleID(playerid),1000.0);}
    SendClientMessage(playerid,COLOR_GREEN,"�������� � �������� ���������.");return VX_ShowBiz(playerid,id);
}
stock VX_Command(playerid,const cmdtext[])
{
    if(!gLogged[playerid])return 0;
    new cmd[32],params[160],a[32],b[32],c[32],n=-1,n2=-1,n3=-1;
    GetToken(cmdtext,0,cmd,sizeof cmd);GetParams(cmdtext,params,sizeof params);
    GetToken(params,0,a,sizeof a);GetToken(params,1,b,sizeof b);GetToken(params,2,c,sizeof c);
    if(!VX_Number(a,n))n=-1;if(!VX_Number(b,n2))n2=-1;if(!VX_Number(c,n3))n3=-1;
    if(gVXHospital[playerid] && strcmp(cmd,"/me",true) && strcmp(cmd,"/do",true)
        && strcmp(cmd,"/try",true) && strcmp(cmd,"/n",true) && strcmp(cmd,"/b",true))
    {
        if(strcmp(cmd,"/bed",true) && strcmp(cmd,"/report",true) && strcmp(cmd,"/phone",true) && strcmp(cmd,"/sms",true) && strcmp(cmd,"/call",true) && strcmp(cmd,"/answer",true) && strcmp(cmd,"/hangup",true) && strcmp(cmd,"/hospitexit",true) && strcmp(cmd,"/systems",true) && strcmp(cmd,"/help",true) && strcmp(cmd,"/hud",true) && strcmp(cmd,"/hudfont",true))
            return SendClientMessage(playerid,COLOR_RED,"[����] ������� ��������� �������. ��������: /bed /phone /report."),1;
    }
    if(!strcmp(cmd,"/medcert",true))return VX_MedCertificate(playerid);
    if(!strcmp(cmd,"/ward",true))return VX_EnterWard(playerid);
    if(!strcmp(cmd,"/lobby",true))return VX_ReturnLobby(playerid);
    if(!strcmp(cmd,"/systems",true))
    {
        new systemsText[1024];
        systemsText[0] = 0;
        strcat(systemsText,"/inv - ���������; /giveitem ID ���� ����������; /dropitem ���� ����������\n",sizeof systemsText);
        strcat(systemsText,"/bank - ����, ����������, ������, �������� � �������\n",sizeof systemsText);
        strcat(systemsText,"/phone - ������, SMS, ��������; /contactadd ����� ���\n",sizeof systemsText);
        strcat(systemsText,"/family - �����, ����� � �����; /fcreate ���\n",sizeof systemsText);
        strcat(systemsText,"/businesses - �������, ������ � ����������\n",sizeof systemsText);
        strcat(systemsText,"/report ����� - ��������� � �������������\n",sizeof systemsText);
        strcat(systemsText,"/reports /rtake number /reply number text /rclose number\n",sizeof systemsText);
        strcat(systemsText,"/spec ID /specoff - ������ �������������\n",sizeof systemsText);
        strcat(systemsText,"/103 /mduty /mcalls /maccept ID /heal ID /hgarage\n",sizeof systemsText);
        strcat(systemsText,"/taxi - �����; /taxiaccept ID - ������� �����; /taxidone - ���������; /taxicancel - ��������\n",sizeof systemsText);
        strcat(systemsText,"/bed - ������ �����; /exit - ����� �� ����\n",sizeof systemsText);
        strcat(systemsText,"/tablet - ������� �������/FBI; /wanted ID 0-6\n",sizeof systemsText);
        strcat(systemsText,"/wantedlist - ���� ������������\n",sizeof systemsText);
        strcat(systemsText,"/rphelp - �������, ����, ���������, ������ � �������",sizeof systemsText);
        return VX_Show(playerid,VX_LOG,DIALOG_STYLE_MSGBOX,"VEXORIUM | �������",systemsText,"OK","�������");
    }
    if(!strcmp(cmd,"/inv",true) || !strcmp(cmd,"/inventory",true) || !strcmp(cmd,"/���������",true))return VX_ShowInventory(playerid);
    if(!strcmp(cmd,"/giveitem",true))return VX_GiveItem(playerid,n,n2-1,n3);
    if(!strcmp(cmd,"/dropitem",true))return VX_Drop(playerid,n-1,n2);
    if(!strcmp(cmd,"/pickup",true))return VX_PickupItem(playerid);
    if(!strcmp(cmd,"/usesim",true))return VX_UseItem(playerid,4);
    if(!strcmp(cmd,"/bank",true))return VX_ShowBank(playerid);
    if(!strcmp(cmd,"/deposit",true))return VX_BankOperation(playerid,0,n);
    if(!strcmp(cmd,"/withdraw",true))return VX_BankOperation(playerid,1,n);
    if(!strcmp(cmd,"/transfer",true))return VX_BankOperation(playerid,2,n2,n);
    if(!strcmp(cmd,"/bankhistory",true))return VX_BankHistory(playerid);
    if(!strcmp(cmd,"/phone",true) || !strcmp(cmd,"/telefon",true))return VX_ShowPhone(playerid);
    if(!strcmp(cmd,"/call",true))return VX_Call(playerid,n);
    if(!strcmp(cmd,"/answer",true))return VX_Answer(playerid);
    if(!strcmp(cmd,"/hangup",true))return VX_Hangup(playerid);
    if(!strcmp(cmd,"/sms",true))
    {
        new text[128];GetParams(params,text,sizeof text);return VX_SendSMS(playerid,n,text);
    }
    if(!strcmp(cmd,"/contactadd",true))
    {
        new label[33],raw[128],q[400];GetParams(params,raw,sizeof raw);VX_CleanText(raw,label,sizeof label);
        if(n<100000 || !strlen(label))return SendClientMessage(playerid,COLOR_YELLOW,"Usage: /contactadd [phone number] [name]"),1;
        format(q,sizeof q,"SELECT COUNT(*) FROM vx_contacts WHERE owner='%q'",gName[playerid]);new DBResult:r=db_query(gDatabase,q);
        new count=0;if(r && db_num_rows(r))count=db_get_field_int(r,0);if(r)db_free_result(r);
        if(count>=20)return SendClientMessage(playerid,COLOR_RED,"Contact limit: 20. /contactdel [number]"),1;
        format(q,sizeof q,"INSERT OR REPLACE INTO vx_contacts(owner,number,label) VALUES('%q',%d,'%q')",gName[playerid],n,label);
        if(!VX_SQL(q))return VX_Error(playerid);return VX_Contacts(playerid);
    }
    if(!strcmp(cmd,"/contactdel",true))
    {
        if(n<0)return SendClientMessage(playerid,COLOR_YELLOW,"Usage: /contactdel [number]"),1;
        new q[240];format(q,sizeof q,"DELETE FROM vx_contacts WHERE owner='%q' AND number=%d",gName[playerid],n);if(!VX_SQL(q))return VX_Error(playerid);return VX_Contacts(playerid);
    }
    if(!strcmp(cmd,"/contacts",true))return VX_Contacts(playerid);
    if(!strcmp(cmd,"/report",true))return VX_Report(playerid,params);
    if(!strcmp(cmd,"/reports",true))return VX_ReportList(playerid);
    if(!strcmp(cmd,"/rtake",true))return VX_ReportAction(playerid,n,0);
    if(!strcmp(cmd,"/rclose",true))return VX_ReportAction(playerid,n,2);
    if(!strcmp(cmd,"/reply",true))
    {
        new text[128];GetParams(params,text,sizeof text);return VX_ReportAction(playerid,n,1,text);
    }
    if(!strcmp(cmd,"/spec",true))return VX_StartSpec(playerid,n);
    if(!strcmp(cmd,"/specmenu",true))return VX_ShowSpecActions(playerid);
    if(!strcmp(cmd,"/specoff",true))return VX_StopSpec(playerid);
    if(!strcmp(cmd,"/tablet",true) || !strcmp(cmd,"/policetablet",true) || !strcmp(cmd,"/kpp",true))return VX_Tablet(playerid);
    if(!strcmp(cmd,"/wantedlist",true))
    {
        if(!VX_Officer(playerid))return SendClientMessage(playerid,COLOR_RED,"Police / FBI only."),1;
        new body[3000],row[100],name[25];
        new DBResult:r=db_query(gDatabase,"SELECT p.name,p.wanted,v.wanted_at FROM police_records p LEFT JOIN vx_players v ON v.name=p.name WHERE p.wanted>0 ORDER BY p.wanted DESC LIMIT 30");
        strcat(body,"Player\tStars (adjusted for elapsed time)\n");
        if(r)for(new i=0;i<db_num_rows(r);i++)
        {
            db_get_field(r,0,name,sizeof name);new stars=db_get_field_int(r,1),due=db_get_field_int(r,2);
            if(due>0 && gettime()>=due)stars=max(0,stars-1-(gettime()-due)/VX_WANTED_SECONDS);
            if(stars>0){format(row,sizeof row,"%s\t%d\n",name,stars);strcat(body,row);}db_next_row(r);
        }
        if(r)db_free_result(r);return VX_Show(playerid,VX_LOG,DIALOG_STYLE_TABLIST_HEADERS,"������� / FBI | ��� ������",body,"OK","�������");
    }
    if(!strcmp(cmd,"/wanted",true))
    {
        if(!VX_Officer(playerid) || gFactionRank[playerid]<3)return SendClientMessage(playerid,COLOR_RED,"��������� 3-� ���� ������� ��� FBI."),1;
        if(!VX_Valid(n) || n==playerid || n2<0 || n2>6)return SendClientMessage(playerid,COLOR_YELLOW,"Usage: /wanted [player ID] [0-6]"),1;
        VX_SetWanted(n,n2);new m[144];format(m,sizeof m,"[WANTED] %s set your wanted level to %d/6. One star is removed every 30 minutes.",gName[playerid],n2);SendClientMessage(n,COLOR_RED,m);
        SendClientMessage(playerid,COLOR_GREEN,"������ � ������� ���������.");return 1;
    }
    if(!strcmp(cmd,"/pursuit",true))return VX_Track(playerid,n);
    if(!strcmp(cmd,"/stoptrack",true))
    {
        gPursuitTarget[playerid]=INVALID_PLAYER_ID;RemovePlayerMapIcon(playerid,49);DisablePlayerCheckpoint(playerid);return 1;
    }
    if(!strcmp(cmd,"/103",true) || !strcmp(cmd,"/medcall",true))return VX_MedRequest(playerid);
    if(!strcmp(cmd,"/112",true))return VX_Call(playerid,112);
    if(!strcmp(cmd,"/medcancel",true))return VX_MedCancel(playerid);
    if(!strcmp(cmd,"/bed",true))return VX_OccupyBed(playerid);
    if(!strcmp(cmd,"/hospitexit",true))return VX_HospitalExit(playerid);
    if(!strcmp(cmd,"/hgarage",true))
    {
        if(!VX_Medic(playerid))return SendClientMessage(playerid,COLOR_RED,"���� employees on duty only: /mduty"),1;
        return OnPlayerCommandText(playerid,"/garage");
    }
    if(!strcmp(cmd,"/mduty",true))
    {
        if(gFaction[playerid]!=FACTION_HOSPITAL || gFactionRank[playerid]<1)return SendClientMessage(playerid,COLOR_RED,"�������� ������ ����������� ����."),1;
        if(GetPlayerVirtualWorld(playerid)!=VX_HOSPITAL_WORLD && !(GetPlayerVirtualWorld(playerid)==0 && GetPlayerInterior(playerid)==0 && IsPlayerInRangeOfPoint(playerid,30.0,1192.1529,-1335.5710,13.3984)))return SendClientMessage(playerid,COLOR_YELLOW,"Start/end duty in ���� or at its garage."),1;
        gVXMedDuty[playerid]=!gVXMedDuty[playerid];
        if(gVXMedDuty[playerid]){SetPlayerSkin(playerid,GetFactionSkin(FACTION_HOSPITAL,gFactionRank[playerid]));SendClientMessage(playerid,COLOR_GREEN,"���� duty started. /mcalls /maccept ID /heal ID /hgarage");}
        else
        {
            for(new i=0;i<MAX_PLAYERS;i++)if(gVXMedCall[i]==2 && gVXMedAssigned[i]==playerid){gVXMedCall[i]=1;gVXMedAssigned[i]=INVALID_PLAYER_ID;if(VX_Valid(i))SendClientMessage(i,COLOR_YELLOW,"Your doctor went off duty; your call is waiting again.");}
            RemovePlayerMapIcon(playerid,57);DisablePlayerCheckpoint(playerid);SendClientMessage(playerid,COLOR_YELLOW,"���� duty ended.");
        }
        return 1;
    }
    if(!strcmp(cmd,"/mcalls",true))
    {
        if(!VX_Medic(playerid))return SendClientMessage(playerid,COLOR_RED,"���� on-duty staff only."),1;
        new m[144],count=0,callStatus[16];
        for(new i=0;i<MAX_PLAYERS;i++) if(VX_Valid(i) && gVXMedCall[i])
        {
            if (gVXMedCall[i]==1) format(callStatus,sizeof callStatus,"�������");
            else format(callStatus,sizeof callStatus,"� ������");
            format(m,sizeof m,"[103] %s [%d] | %s | /maccept %d",gName[i],i,callStatus,i);
            SendClientMessage(playerid,COLOR_BLUE,m);count++;
        }
        if(!count)SendClientMessage(playerid,COLOR_GREEN,"�������� ����������� ������� ���.");return 1;
    }
    if(!strcmp(cmd,"/maccept",true))return VX_MedAccept(playerid,n);
    if(!strcmp(cmd,"/heal",true))return VX_Heal(playerid,n);
    if(!strcmp(cmd,"/mclose",true))
    {
        if(!VX_Medic(playerid) || !VX_Valid(n) || gVXMedAssigned[n]!=playerid || !VX_Near(playerid,n,5.0))return SendClientMessage(playerid,COLOR_RED,"��������� � �������� ��������� ������."),1;
        return VX_MedCancel(n);
    }
    if(!strcmp(cmd,"/family",true))return VX_ShowFamily(playerid);
    if(!strcmp(cmd,"/fcreate",true))return VX_CreateFamily(playerid,params);
    if(!strcmp(cmd,"/finvite",true))return VX_FamilyInvite(playerid,n);
    if(!strcmp(cmd,"/faccept",true))return VX_FamilyAccept(playerid);
    if(!strcmp(cmd,"/fleave",true))return VX_FamilyLeave(playerid);
    if(!strcmp(cmd,"/frank",true))return VX_FamilyRank(playerid,n,n2);
    if(!strcmp(cmd,"/fkick",true))return VX_FamilyRank(playerid,n,0);
    if(!strcmp(cmd,"/fdeposit",true))return VX_FamilyMoney(playerid,n,false);
    if(!strcmp(cmd,"/fwithdraw",true))return VX_FamilyMoney(playerid,n,true);
    if(!strcmp(cmd,"/fc",true))
    {
        VX_LoadFamily(playerid);if(!gVXFamily[playerid])return SendClientMessage(playerid,COLOR_RED,"Join a family first."),1;
        new text[101],m[144];VX_CleanText(params,text,sizeof text);if(!strlen(text))return SendClientMessage(playerid,COLOR_YELLOW,"Usage: /fc [text]"),1;
        format(m,sizeof m,"[FAMILY] %s: %s",gName[playerid],text);
        for(new i=0;i<MAX_PLAYERS;i++)if(VX_Valid(i) && gVXFamily[i]==gVXFamily[playerid])SendClientMessage(i,COLOR_BLUE,m);return 1;
    }
    if(!strcmp(cmd,"/fdisband",true))
    {
        VX_LoadFamily(playerid);if(gVXFamilyRank[playerid]!=4 || strcmp(params,"CONFIRM",false))return SendClientMessage(playerid,COLOR_YELLOW,"Leader only. Irreversible: /fdisband CONFIRM. Withdraw treasury first."),1;
        new id=gVXFamily[playerid],q[200];format(q,sizeof q,"SELECT balance FROM vx_families WHERE id=%d",id);new DBResult:r=db_query(gDatabase,q);
        new balance=1;if(r && db_num_rows(r))balance=db_get_field_int(r,0);if(r)db_free_result(r);
        if(balance>0)return SendClientMessage(playerid,COLOR_YELLOW,"Withdraw all treasury funds first."),1;
        if(!VX_Begin())return VX_Error(playerid);
        format(q,sizeof q,"DELETE FROM vx_family_members WHERE family=%d",id);VX_SQL(q);format(q,sizeof q,"DELETE FROM vx_families WHERE id=%d",id);VX_SQL(q);
        if(!VX_Commit())return VX_Error(playerid);
        for(new i=0;i<MAX_PLAYERS;i++)if(VX_Valid(i) && gVXFamily[i]==id){VX_LoadFamily(i);SendClientMessage(i,COLOR_YELLOW,"����� ��������� ���� �����.");}
        return 1;
    }
    if(!strcmp(cmd,"/businesses",true))return VX_BizList(playerid);
    if(!strcmp(cmd,"/biz",true))return VX_ShowBiz(playerid,n);
    if(!strcmp(cmd,"/bizprice",true))return VX_BizAction(playerid,n,5,n2);
    return 0;
}
stock VX_Dialog(playerid,dialogid,response,listitem,const inputtext[])
{
    if(dialogid<VX_FIRST_DIALOG || dialogid>VX_LOG)return 0;
    if(!gLogged[playerid] || gVXExpectedDialog[playerid]!=dialogid)return 1;
    gVXExpectedDialog[playerid]=-1;
    if(!response)return 1;
    if(gVXHospital[playerid] && dialogid!=VX_PHONE && dialogid!=VX_SMS_NUMBER && dialogid!=VX_SMS_BODY && dialogid!=VX_CALL_NUMBER && dialogid!=VX_CONTACTS && dialogid!=VX_LOG)return SendClientMessage(playerid,COLOR_RED,"������� ��������� ������� � ����."),1;
    new n=-1;if(!VX_Number(inputtext,n))n=-1;
    switch(dialogid)
    {
        case VX_INV:
        {
            if(listitem>=0 && listitem<6)
            {
                gVXSelectedItem[playerid]=listitem;
                VX_Show(playerid,VX_ITEM,DIALOG_STYLE_LIST,gVXItemName[listitem],"������������\nTransfer: /giveitem ID slot amount\nDrop: /dropitem slot amount");
            }
            else if(listitem==6)
            {
                if(gAccessoryModel[playerid]<=0)return SendClientMessage(playerid,COLOR_YELLOW,"No accessory owned. /shopacc"),1;
                if(IsPlayerAttachedObjectSlotUsed(playerid,0))RemovePlayerAttachedObject(playerid,0);
                else SetPlayerAttachedObject(playerid,0,gAccessoryModel[playerid],2,0.10,0.02,0.0,0.0,0.0,0.0,1.0,1.0,1.0);
            }
            else if(listitem==7)VX_ShowPhone(playerid);else if(listitem==8)VX_PickupItem(playerid);
        }
        case VX_ITEM:
        {
            if(listitem==0)VX_UseItem(playerid,gVXSelectedItem[playerid]);
            else if(listitem==1 || listitem==2)
            {
                new m[144];format(m,sizeof m,"/giveitem [ID] %d [quantity] | /dropitem %d [quantity]",gVXSelectedItem[playerid]+1,gVXSelectedItem[playerid]+1);SendClientMessage(playerid,COLOR_YELLOW,m);
            }
        }
        case VX_BANK:
        {
            if(listitem>=0 && listitem<3)
            {
                gVXBankAction[playerid]=listitem;
                if (listitem==2)
                    VX_Show(playerid,VX_BANK_INPUT,DIALOG_STYLE_INPUT,"���������� ��������","������� ID ���������� � ����� ����� ������:","�����������","������");
                else
                    VX_Show(playerid,VX_BANK_INPUT,DIALOG_STYLE_INPUT,"���������� ��������","������� ������������� �����:","�����������","������");
            }
            else if(listitem==3)VX_BankHistory(playerid);
        }
        case VX_BANK_INPUT:
        {
            if(gVXBankAction[playerid]==2)
            {
                new a[24],b[24],target=-1,amount=-1;GetToken(inputtext,0,a,sizeof a);GetToken(inputtext,1,b,sizeof b);
                if(!VX_Number(a,target) || !VX_Number(b,amount))return SendClientMessage(playerid,COLOR_RED,"������� ID ������ � ����� ����� ������."),1;
                VX_BankOperation(playerid,2,amount,target);
            }
            else VX_BankOperation(playerid,gVXBankAction[playerid],n);
        }
        case VX_PHONE:
        {
            switch(listitem)
            {
                case 0:VX_Show(playerid,VX_CALL_NUMBER,DIALOG_STYLE_INPUT,"������� | ������","������� ����� ��������, 103 ��� 112:","���������","������");
                case 1:VX_Show(playerid,VX_SMS_NUMBER,DIALOG_STYLE_INPUT,"������� | SMS","������� ����� �������� ����������, � �� ID ������:","�����","������");
                case 2:VX_Inbox(playerid);
                case 3:VX_Contacts(playerid);
                case 4:VX_ShowBank(playerid);
                case 5:OnPlayerCommandText(playerid,"/gps");
                case 6:VX_MedRequest(playerid);
                case 7:VX_Call(playerid,112);
                case 8:{gVXPhoneOn[playerid]=!gVXPhoneOn[playerid];if(!gVXPhoneOn[playerid])VX_Hangup(playerid);VX_Save(playerid);VX_ShowPhone(playerid);}
                case 9:{if(gVXCallActive[playerid])VX_Hangup(playerid);else VX_Answer(playerid);}
                case 10:OnPlayerCommandText(playerid,"/taxi");
            }
        }
        case VX_SMS_NUMBER:
        {
            if(n<100000)return SendClientMessage(playerid,COLOR_RED,"������������ ����� ��������."),1;
            gVXNumberInput[playerid]=n;VX_Show(playerid,VX_SMS_BODY,DIALOG_STYLE_INPUT,"������� | SMS","����� ���������, �� 1 �� 120 ��������:","���������","������");
        }
        case VX_SMS_BODY:VX_SendSMS(playerid,gVXNumberInput[playerid],inputtext);
        case VX_CALL_NUMBER:VX_Call(playerid,n);
        case VX_CONTACTS:{if(listitem>=0 && listitem<gVXListCount[playerid])VX_Call(playerid,gVXList[playerid][listitem]);}
        case VX_REPORTS:{if(listitem>=0 && listitem<gVXListCount[playerid])VX_ReportAction(playerid,gVXList[playerid][listitem],0);}
        case VX_TABLET:
        {
            if(listitem<0 || listitem>=gVXListCount[playerid])return 1;
            new target=gVXList[playerid][listitem];
            if(!VX_Valid(target) || gVXListSession[playerid][listitem]!=gVXSession[target])return SendClientMessage(playerid,COLOR_RED,"������ ���������. �������� /tablet ������."),1;
            VX_Track(playerid,target);
        }
        case VX_BUSINESSES:{if(listitem>=0 && listitem<gVXListCount[playerid])VX_ShowBiz(playerid,gVXList[playerid][listitem]);}
        case VX_BIZ:
        {
            new id=gVXSelectedBiz[playerid];if(id<1 || id>5)return 1;
            if(listitem==6)
            {
                if(gWorkStage[playerid]>0 || gDrivingTestStage[playerid]>0 || gPursuitTarget[playerid]!=INVALID_PLAYER_ID)return SendClientMessage(playerid,COLOR_RED,"Finish your active route first."),1;
                gGpsActive[playerid]=true;SetPlayerCheckpoint(playerid,gVXBizPos[id-1][0],gVXBizPos[id-1][1],gVXBizPos[id-1][2],5.0);
            }
            else if(listitem==5)SendClientMessage(playerid,COLOR_YELLOW,"Use /bizprice [business ID] [100-10000].");
            else if(listitem>=0 && listitem<=4)VX_BizAction(playerid,id,listitem);
        }
    }
    return 1;
}
stock VX_Disconnect(playerid)
{
    VX_CancelWardLoad(playerid);
    if(gVXDeathTimer[playerid])KillTimer(gVXDeathTimer[playerid]);gVXDeathTimer[playerid]=0;
    if(gLogged[playerid])VX_Save(playerid);
    VX_FreeBed(playerid);VX_Hangup(playerid);VX_MedCancel(playerid);
    if(gLogged[playerid])
    {
        new q[256];format(q,sizeof q,"UPDATE vx_reports SET status=0,admin='' WHERE admin='%q' AND status=1",gName[playerid]);VX_SQL(q);
    }
    for(new i=0;i<MAX_PLAYERS;i++)
    {
        if(gVXSpec[i]==playerid && VX_Valid(i))VX_StopSpec(i);
        if(gVXReportOwner[i]==playerid)gVXReportOwner[i]=INVALID_PLAYER_ID;
        if(gVXMedAssigned[i]==playerid)
        {
            gVXMedAssigned[i]=INVALID_PLAYER_ID;if(gVXMedCall[i])gVXMedCall[i]=1;
            if(VX_Valid(i))SendClientMessage(i,COLOR_YELLOW,"Your doctor disconnected. The call is waiting again.");
        }
    }
    gVXMedDuty[playerid]=false;gVXSpec[playerid]=INVALID_PLAYER_ID;return 1;
}
public VX_CuffFollowTick()
{
    for (new suspect = 0; suspect < MAX_PLAYERS; suspect++)
    {
        if (!IsPlayerConnected(suspect) || !gLogged[suspect] || !gHandcuffed[suspect]) continue;
        if (IsPlayerInAnyVehicle(suspect)) continue;

        new officer = gCuffOfficer[suspect];
        if (officer < 0 || officer >= MAX_PLAYERS || !IsPlayerConnected(officer) || !gLogged[officer])
        {
            gCuffOfficer[suspect] = INVALID_PLAYER_ID;
            continue;
        }

        new Float:ox, Float:oy, Float:oz, Float:angle;
        new Float:sx, Float:sy, Float:sz;
        GetPlayerPos(officer, ox, oy, oz);
        GetPlayerPos(suspect, sx, sy, sz);
        GetPlayerFacingAngle(officer, angle);
        new bool:worldChanged = (GetPlayerInterior(suspect) != GetPlayerInterior(officer)
            || GetPlayerVirtualWorld(suspect) != GetPlayerVirtualWorld(officer));

        if (GetPlayerInterior(suspect) != GetPlayerInterior(officer))
            SetPlayerInterior(suspect, GetPlayerInterior(officer));
        if (GetPlayerVirtualWorld(suspect) != GetPlayerVirtualWorld(officer))
            SetPlayerVirtualWorld(suspect, GetPlayerVirtualWorld(officer));

        if (IsPlayerInAnyVehicle(officer))
        {
            // If the officer drives off before loading the suspect, keep the suspect near the car.
            if (worldChanged || GetPlayerDistanceFromPoint(suspect, ox, oy, oz) > 3.0)
            {
                new Float:carFollowX = ox + floatsin(-angle, degrees) * -1.5;
                new Float:carFollowY = oy + floatcos(-angle, degrees) * -1.5;
                SetPlayerPos(suspect, carFollowX, carFollowY, oz + 0.3);
                SetPlayerFacingAngle(suspect, angle);
            }
        }
        else
        {
            new Float:dx = sx - ox;
            new Float:dy = sy - oy;
            if (worldChanged || dx * dx + dy * dy > 0.25 || floatabs(sz - oz) > 1.0)
            {
                new Float:followX = ox + floatsin(-angle, degrees) * -0.8;
                new Float:followY = oy + floatcos(-angle, degrees) * -0.8;
                SetPlayerPos(suspect, followX, followY, oz);
                SetPlayerFacingAngle(suspect, angle);
            }
        }
        if (GetPlayerSpecialAction(suspect) != 24) SetPlayerSpecialAction(suspect, 24);
        TogglePlayerControllable(suspect, false);
    }
    return 1;
}

public VX_Tick()
{
    new now=gettime(),elapsed=VexHudClamp(now-gVXLastTick,0,5);gVXLastTick=now;
    static lastSave;
    RP_Tick(elapsed,now);
    for(new p=0;p<MAX_PLAYERS;p++)
    {
        if(!VX_Valid(p))continue;
        VX_DecayWanted(p);
        VX_WardSafety(p);
        if(gVXSpec[p]!=INVALID_PLAYER_ID)
        {
            if(!VX_Admin(p) || !VX_Valid(gVXSpec[p]))VX_StopSpec(p);
            else VX_SpecView(p);
        }
        if(gVXCall[p]!=INVALID_PLAYER_ID && !gVXCallActive[p] && gVXCallAt[p]>0 && now-gVXCallAt[p]>=30)VX_Hangup(p);
        if(gVXHospital[p] && GetPlayerState(p)!=PLAYER_STATE_WASTED && GetPlayerState(p)!=PLAYER_STATE_NONE && !gIsJailed[p])
        {
            if(GetPlayerVirtualWorld(p)!=VX_HOSPITAL_WORLD || GetPlayerInterior(p)!=0 || !IsPlayerInRangeOfPoint(p,30.0,2000.0,1997.0,1001.0))
            {
                VX_FreeBed(p);TogglePlayerControllable(p,true);VX_EnterHospital(p);
            }
            new bed=gVXBed[p];
            if(bed>=0 && bed<VX_BEDS && gVXBedOwner[bed]==p)
            {
                if(!IsPlayerInRangeOfPoint(p,2.0,gVXBedPos[bed][0],gVXBedPos[bed][1],gVXBedPos[bed][2]))SetPlayerPos(p,gVXBedPos[bed][0],gVXBedPos[bed][1],gVXBedPos[bed][2]+0.25);
                TogglePlayerControllable(p,false);gVXTreatment[p]=max(0,gVXTreatment[p]-elapsed);
                // Reapply the lying pose while the patient is receiving treatment.
                if(elapsed>0 && gVXTreatment[p]>0 && gVXTreatment[p]%15==0)
                    ApplyAnimation(p,"BEACH","bather",4.1,1,0,0,1,0,1);
                if(gVXTreatment[p]<=0)
                {
                    if(!RP_Discharge(p)) { gVXTreatment[p]=1; continue; }
                    VX_FreeBed(p);ClearAnimations(p);TogglePlayerControllable(p,true);SetPlayerHealth(p,100.0);
                    SetPlayerSpecialAction(p,SPECIAL_ACTION_NONE);
                    SetPlayerPos(p,VX_WARD_EXIT_X,VX_WARD_EXIT_Y+4.0,VX_WARD_Z);
                    SetPlayerFacingAngle(p,180.0); SetCameraBehindPlayer(p);
                    SendClientMessage(p,COLOR_GREEN,"[����] �� ��������. /lobby - ����, /exit - ����� �� �����.");
                }
                else if(elapsed>0 && gVXTreatment[p]%30==0){new m[96];format(m,sizeof m,"[����] �������� �������: %d ���.",gVXTreatment[p]);SendClientMessage(p,COLOR_BLUE,m);}
            }
        }
        if(gVXMedCall[p]==2)
        {
            new medic=gVXMedAssigned[p];
            if(!VX_Medic(medic)){gVXMedCall[p]=1;gVXMedAssigned[p]=INVALID_PLAYER_ID;}
            else
            {
                new Float:x,Float:y,Float:z;GetPlayerPos(p,x,y,z);SetPlayerMapIcon(medic,57,x,y,z,22,0,MAPICON_GLOBAL);
                if(GetPlayerVirtualWorld(p)==GetPlayerVirtualWorld(medic) && GetPlayerInterior(p)==GetPlayerInterior(medic))SetPlayerCheckpoint(medic,x,y,z,4.0);
            }
        }
        if(now-lastSave>=30)VX_Save(p);
    }
    if(now-lastSave>=30)lastSave=now;
    for(new d=0;d<VX_MAX_DROPS;d++)if(gVXDropQty[d] && now>=gVXDropExpiry[d])VX_ClearDrop(d);
    return 1;
}
public OnPlayerText(playerid,text[])
{
    if(!gLogged[playerid])return 0;
    if(gAdminMuteUntil[playerid]>gettime())
    {
        new left=(gAdminMuteUntil[playerid]-gettime()+59)/60,message[160];
        format(message,sizeof message,"�� �� ������ ������ � ��� ��� %d ���. �������: %s",left,gAdminMuteReason[playerid]);
        SendClientMessage(playerid,COLOR_RED,message);return 0;
    }
    if(gAdminMuteUntil[playerid]!=0 && gAdminMuteUntil[playerid]<=gettime())
    { gAdminMuteUntil[playerid]=0;gAdminMuteReason[playerid][0]='\0';SendClientMessage(playerid,COLOR_GREEN,"���� ���� ����."); }
    new t=gVXCall[playerid];
    if(gVXCallActive[playerid] && VX_Valid(t) && gVXCall[t]==playerid && gVXCallActive[t])
    {
        new clean[105],m[144];VX_CleanText(text,clean,sizeof clean);format(m,sizeof m,"[PHONE] %s: %s",gName[playerid],clean);
        SendClientMessage(playerid,COLOR_BLUE,m);SendClientMessage(t,COLOR_BLUE,m);return 0;
    }
    new clean[105],message[144];
    VX_CleanText(text,clean,sizeof clean);
    format(message,sizeof message,"%s �������: %s",gName[playerid],clean);
    SendLocalMessage(playerid,COLOR_WHITE,message,20.0);
    return 0;
}

stock VX_AddWanted(playerid)
{
    VX_DecayWanted(playerid);
    gWantedLevel[playerid]=min(gWantedLevel[playerid]+1,6);
    if(gVXWantedAt[playerid]<=0)gVXWantedAt[playerid]=gettime()+VX_WANTED_SECONDS;
    SetPlayerWantedLevel(playerid,gWantedLevel[playerid]);VX_Save(playerid);UpdateVexHud(playerid);return 1;
}


// ================= RP persistence and audit =================
stock RP_Reset(playerid)
{
    gRPLoaded[playerid] = false;
    gRPJailLeft[playerid] = 0; gRPJailOriginal[playerid] = 0;
    gRPSentence[playerid] = 0; gRPJailSource[playerid] = 0;
    gRPJailReduced[playerid] = false; gRPJailReason[playerid][0] = 0;
    gRPLawOffer[playerid] = INVALID_PLAYER_ID; gRPLawUntil[playerid] = 0;
    gRPLawSession[playerid] = 0; gRPLawSentence[playerid] = 0;
    gRPInjury[playerid] = 0; gRPNextMedPay[playerid] = 0; gRPBleedAt[playerid] = 0;
    gRPStretcherBy[playerid] = INVALID_PLAYER_ID;
    gRPStretcherObject[playerid] = INVALID_OBJECT_ID;
    gRPOpDoctor[playerid] = INVALID_PLAYER_ID; gRPOpUntil[playerid] = 0;
    gRPOpSession[playerid] = 0; gRPTaserUntil[playerid] = 0;
    gRPCarKm[playerid] = 0.0; gRPCarHealth[playerid] = 1000.0;
    gRPCarFuel[playerid] = 100; gRPCarRegistered[playerid] = false;
    gRPCarInsured[playerid] = 0; gRPCarInspected[playerid] = 0;
    gRPCarBroken[playerid] = false; gRPCarPosKnown[playerid] = false;
    gRPCarPlate[playerid][0] = 0;
    for(new c=0;c<RP_CAMERA_COUNT;c++) gRPNextCamera[playerid][c] = 0;
    return 1;
}
stock RP_Init()
{
    new q[768];
    strcat(q,"CREATE TABLE IF NOT EXISTS rp_state(name TEXT PRIMARY KEY,");
    strcat(q,"jail_left INTEGER NOT NULL DEFAULT 0,jail_original INTEGER NOT NULL DEFAULT 0,");
    strcat(q,"sentence INTEGER NOT NULL DEFAULT 0,reduced INTEGER NOT NULL DEFAULT 0,");
    strcat(q,"source INTEGER NOT NULL DEFAULT 0,reason TEXT NOT NULL DEFAULT '',");
    strcat(q,"injury INTEGER NOT NULL DEFAULT 0,next_med_pay INTEGER NOT NULL DEFAULT 0)");
    if(!VX_SQL(q)) return 0;
    q[0]=0;
    strcat(q,"CREATE TABLE IF NOT EXISTS rp_vehicles(owner TEXT PRIMARY KEY,model INTEGER NOT NULL,");
    strcat(q,"km REAL NOT NULL DEFAULT 0,health REAL NOT NULL DEFAULT 1000,fuel INTEGER NOT NULL DEFAULT 100,");
    strcat(q,"registered INTEGER NOT NULL DEFAULT 0,insured INTEGER NOT NULL DEFAULT 0,");
    strcat(q,"inspected INTEGER NOT NULL DEFAULT 0,broken INTEGER NOT NULL DEFAULT 0,plate TEXT NOT NULL)");
    if(!VX_SQL(q)) return 0;
    if(!VX_SQL("CREATE TABLE IF NOT EXISTS rp_keys(owner TEXT NOT NULL,guest TEXT NOT NULL,PRIMARY KEY(owner,guest))")) return 0;
    q[0]=0;
    strcat(q,"CREATE TABLE IF NOT EXISTS rp_audit(id INTEGER PRIMARY KEY AUTOINCREMENT,");
    strcat(q,"subject TEXT NOT NULL,actor TEXT NOT NULL,kind TEXT NOT NULL,detail TEXT NOT NULL,created INTEGER NOT NULL)");
    if(!VX_SQL(q)) return 0;
    if(!VX_SQL("CREATE INDEX IF NOT EXISTS rp_audit_subject ON rp_audit(subject,id)")) return 0;
    q[0]=0;
    strcat(q,"CREATE TABLE IF NOT EXISTS rp_fines(id INTEGER PRIMARY KEY AUTOINCREMENT,");
    strcat(q,"subject TEXT NOT NULL,officer TEXT NOT NULL,amount INTEGER NOT NULL,");
    strcat(q,"reason TEXT NOT NULL,paid INTEGER NOT NULL DEFAULT 0,created INTEGER NOT NULL)");
    if(!VX_SQL(q)) return 0;
    if(!VX_SQL("CREATE INDEX IF NOT EXISTS rp_fines_subject ON rp_fines(subject,paid)")) return 0;
    RP_Map();
    print("[VEXORIUM RP] Police, medical, vehicle, prison and lawyer modules initialized.");
    return 1;
}
stock RP_Audit(targetid, actorid, const kind[], const detail[])
{
    new actor[MAX_PLAYER_NAME+1], q[1024];
    if(actorid>=0 && actorid<MAX_PLAYERS && gName[actorid][0])
        format(actor,sizeof actor,"%s",gName[actorid]);
    else format(actor,sizeof actor,"SYSTEM");
    format(q,sizeof q,
        "INSERT INTO rp_audit(subject,actor,kind,detail,created) VALUES('%q','%q','%q','%q',%d)",
        gName[targetid],actor,kind,detail,gettime());
    return VX_SQL(q);
}
stock RP_SaveState(playerid)
{
    if(!gRPLoaded[playerid]) return 0;
    new q[384];
    format(q,sizeof q,
        "UPDATE rp_state SET jail_left=%d,injury=%d,next_med_pay=%d WHERE name='%q'",
        gRPJailLeft[playerid],gRPInjury[playerid],gRPNextMedPay[playerid],gName[playerid]);
    return VX_SQL(q);
}
stock RP_Load(playerid)
{
    new q[256];
    format(q,sizeof q,"INSERT OR IGNORE INTO rp_state(name) VALUES('%q')",gName[playerid]);
    if(!VX_SQL(q)) return 0;
    format(q,sizeof q,
        "SELECT jail_left,jail_original,sentence,reduced,source,reason,injury,next_med_pay FROM rp_state WHERE name='%q'",
        gName[playerid]);
    new DBResult:r=db_query(gDatabase,q);
    if(!r) return 0;
    if(!db_num_rows(r)) { db_free_result(r); return 0; }
    gRPJailLeft[playerid]=VexHudClamp(db_get_field_int(r,0),0,RP_JAIL_MAX);
    gRPJailOriginal[playerid]=VexHudClamp(db_get_field_int(r,1),0,RP_JAIL_MAX);
    gRPSentence[playerid]=db_get_field_int(r,2);
    gRPJailReduced[playerid]=(db_get_field_int(r,3)!=0);
    gRPJailSource[playerid]=db_get_field_int(r,4);
    db_get_field(r,5,gRPJailReason[playerid],97);
    gRPInjury[playerid]=db_get_field_int(r,6) & (RP_INJ_BLEED | RP_INJ_FRACTURE);
    gRPNextMedPay[playerid]=db_get_field_int(r,7);
    db_free_result(r);
    gIsJailed[playerid]=(gRPJailLeft[playerid]>0);
    if(gIsJailed[playerid]) gVXHospital[playerid]=false;
    gRPLoaded[playerid]=true;
    gRPBleedAt[playerid]=gettime()+15;
    if(!RP_LoadCar(playerid)) { gRPLoaded[playerid]=false; return 0; }
    return 1;
}
stock RP_Message(playerid, const message[])
{
    new text[144]; format(text,sizeof text,"%s",message);
    SendClientMessage(playerid,COLOR_YELLOW,text);
    return 1;
}
stock RP_Living(playerid)
{
    if(!VX_Valid(playerid) || !gRPLoaded[playerid]) return 0;
    new playerState=GetPlayerState(playerid),Float:health;
    GetPlayerHealth(playerid,health);
    if(health<=0.0) return 0;
    return playerState!=PLAYER_STATE_NONE && playerState!=PLAYER_STATE_WASTED
        && playerState!=PLAYER_STATE_SPECTATING;
}
stock RP_Free(playerid)
{
    return RP_Living(playerid) && !gIsJailed[playerid] && !gVXHospital[playerid]
        && !gHandcuffed[playerid] && !gTaserStunned[playerid] && !gPvpActive[playerid]
        && gRPStretcherBy[playerid]==INVALID_PLAYER_ID;
}
stock RP_CommandGuard(playerid,const cmdtext[])
{
    new cmd[40],needle[44],allowed[384];
    GetToken(cmdtext,0,cmd,sizeof cmd);
    format(needle,sizeof needle," %s ",cmd);
    if(gIsJailed[playerid] || gHandcuffed[playerid] || gTaserStunned[playerid])
    {
        strcat(allowed," /jailinfo /acceptlawyer /declinelawyer /report /phone /sms /call /answer /hangup ");
        strcat(allowed,"/me /do /try /n /b /help /systems /rphelp /hud /hudfont /fines /payfine /health /medcard ");
        if(strfind(allowed,needle,true)==-1)
            return RP_Message(playerid,"������� ��������� ����������. �������� /jailinfo, RP-���, ������� � /report.");
    }
    if(gVXHospital[playerid] || gRPStretcherBy[playerid]!=INVALID_PLAYER_ID)
    {
        allowed[0]=0;
        strcat(allowed," /bed /medrefuse /health /medcard /report /phone /sms /call /answer /hangup ");
        strcat(allowed,"/me /do /try /n /b /help /systems /rphelp /hud /hudfont /hospitexit /exit /hospitalinfo ");
        if(strfind(allowed,needle,true)==-1)
            return RP_Message(playerid,"������� ��������� �������. /health /bed /medrefuse /report.");
    }
    return 0;
}
stock RP_DialogGuard(playerid,dialogid)
{
    if(!gIsJailed[playerid] && !gHandcuffed[playerid] && !gTaserStunned[playerid]
        && gRPStretcherBy[playerid]==INVALID_PLAYER_ID) return 0;
    switch(dialogid)
    {
        case VX_PHONE,VX_SMS_NUMBER,VX_SMS_BODY,VX_CALL_NUMBER,VX_CONTACTS,VX_LOG,DIALOG_VEX_HUD_FONT: return 0;
    }
    gVXExpectedDialog[playerid]=-1;
    return 1;
}
// ================= Prison map, custody and lawyer =================
stock RP_Map()
{
    // Small native-object exterior at Ocean Docks. Coordinates are configurable above.
    // An existing GTA police/cell interior is reused in a separate virtual world.
    for(new x=0;x<2;x++)
    {
        CreateObject(19379,RP_PRISON_X-5.2+x*10.4,RP_PRISON_Y,RP_PRISON_Z-1.1,0.0,90.0,0.0,180.0);
        CreateObject(19379,RP_PRISON_X-5.2+x*10.4,RP_PRISON_Y,RP_PRISON_Z+5.0,0.0,90.0,0.0,180.0);
        CreateObject(19379,RP_PRISON_X-4.8+x*9.6,RP_PRISON_Y+4.8,RP_PRISON_Z,0.0,0.0,90.0,180.0);
    }
    CreateObject(19379,RP_PRISON_X-10.4,RP_PRISON_Y,RP_PRISON_Z,0.0,0.0,0.0,180.0);
    CreateObject(19379,RP_PRISON_X+10.4,RP_PRISON_Y,RP_PRISON_Z,0.0,0.0,0.0,180.0);
    // Front wall sections leave a central entrance.
    CreateObject(19379,RP_PRISON_X-6.3,RP_PRISON_Y-4.8,RP_PRISON_Z,0.0,0.0,90.0,180.0);
    CreateObject(19379,RP_PRISON_X+6.3,RP_PRISON_Y-4.8,RP_PRISON_Z,0.0,0.0,90.0,180.0);
    gRPPrisonIn=CreatePickup(1239,1,RP_PRISON_X,RP_PRISON_Y-6.5,RP_PRISON_Z,0);
    gRPPrisonOut=CreatePickup(1239,1,246.8,62.3,1003.64,RP_JAIL_WORLD);
    Create3DTextLabel("{FFD700}VEXORIUM | ������\n{FFFFFF}/prisonenter | /jailinfo",
        COLOR_WHITE,RP_PRISON_X,RP_PRISON_Y-6.5,RP_PRISON_Z+1.2,25.0,0,1);
    Create3DTextLabel("{FFD700}�����\n{FFFFFF}/prisonexit",
        COLOR_WHITE,246.8,62.3,1004.5,12.0,RP_JAIL_WORLD,1);
    Create3DTextLabel("{66CCFF}������� ��������\n{FFFFFF}/clients | /defend ID",
        COLOR_WHITE,246.8,67.0,1004.5,12.0,RP_JAIL_WORLD,1);
    for(new c=0;c<RP_CAMERA_COUNT;c++)
    {
        new label[96];
        format(label,sizeof label,"{FFD700}������ %d\n{FFFFFF}�����������: %d ��/�",c+1,gRPCameraLimit[c]);
        Create3DTextLabel(label,COLOR_WHITE,gRPCameras[c][0],gRPCameras[c][1],
            gRPCameras[c][2]+3.0,35.0,0,1);
    }
    return 1;
}
stock RP_AtPrisonGate(playerid)
{
    return GetPlayerInterior(playerid)==0 && GetPlayerVirtualWorld(playerid)==0
        && IsPlayerInRangeOfPoint(playerid,16.0,RP_PRISON_X,RP_PRISON_Y-6.5,RP_PRISON_Z);
}
stock RP_AtLawDesk(playerid)
{
    return GetPlayerInterior(playerid)==6 && GetPlayerVirtualWorld(playerid)==RP_JAIL_WORLD
        && IsPlayerInRangeOfPoint(playerid,6.0,246.8,67.0,1003.64);
}
stock RP_PrisonEnter(playerid)
{
    if(!RP_Free(playerid) || !RP_AtPrisonGate(playerid))
        return RP_Message(playerid,"��������� � ����� ������. �������: /prison.");
    if(IsPlayerInAnyVehicle(playerid)) return RP_Message(playerid,"������� �� ����������.");
    SetPlayerInterior(playerid,6); SetPlayerVirtualWorld(playerid,RP_JAIL_WORLD);
    SetPlayerPos(playerid,246.8,67.0,1003.64); SetPlayerFacingAngle(playerid,0.0);
    SetCameraBehindPlayer(playerid); gLastPickupTick[playerid]=GetTickCount();
    return RP_Message(playerid,"������� ������. ��������: /clients /defend ID. �����: /prisonexit.");
}
stock RP_PrisonExit(playerid)
{
    if(gIsJailed[playerid]) return RP_Message(playerid,"�� �� ������ ����� �� ��������� �����. /jailinfo.");
    if(GetPlayerVirtualWorld(playerid)!=RP_JAIL_WORLD || GetPlayerInterior(playerid)!=6
        || !IsPlayerInRangeOfPoint(playerid,4.0,246.8,62.3,1003.64)) return RP_Message(playerid,"��������� � ������.");
    SetPlayerInterior(playerid,0); SetPlayerVirtualWorld(playerid,0);
    SetPlayerPos(playerid,RP_PRISON_X,RP_PRISON_Y-10.0,RP_PRISON_Z);
    SetCameraBehindPlayer(playerid); gLastPickupTick[playerid]=GetTickCount();
    return 1;
}
stock RP_Pickup(playerid,pickupid)
{
    if(pickupid==gRPPrisonIn) { RP_PrisonEnter(playerid); return 1; }
    if(pickupid==gRPPrisonOut) { RP_PrisonExit(playerid); return 1; }
    return 0;
}
stock RP_JailPosition(playerid)
{
    if(!gIsJailed[playerid]) return 0;
    if(IsPlayerInAnyVehicle(playerid)) RemovePlayerFromVehicle(playerid);
    SetPlayerInterior(playerid,6); SetPlayerVirtualWorld(playerid,RP_JAIL_WORLD);
    SetPlayerPos(playerid,264.4,77.5,1001.0); SetPlayerFacingAngle(playerid,90.0);
    SetPlayerSpecialAction(playerid,SPECIAL_ACTION_NONE); ClearAnimations(playerid);
    ResetPlayerWeapons(playerid); SetPlayerArmour(playerid,0.0);
    SetPlayerHealth(playerid,100.0); TogglePlayerControllable(playerid,true);
    SetCameraBehindPlayer(playerid);
    return 1;
}
stock RP_CancelActivities(playerid)
{
    VX_CancelWardLoad(playerid);
    RP_DropStretcher(playerid);
    for(new p=0;p<MAX_PLAYERS;p++)
    {
        if(gRPStretcherBy[p]==playerid) RP_DropStretcher(p);
        if(gRPOpDoctor[p]==playerid) { gRPOpDoctor[p]=INVALID_PLAYER_ID; gRPOpUntil[p]=0; }
    }
    gRPOpDoctor[playerid]=INVALID_PLAYER_ID; gRPOpUntil[playerid]=0;
    gRPTaserUntil[playerid]=0; gHandcuffed[playerid]=false; gCuffOfficer[playerid]=INVALID_PLAYER_ID; gTaserStunned[playerid]=false;
    SetPlayerDrunkLevel(playerid,0);
    VX_FreeBed(playerid); VX_Hangup(playerid); VX_MedCancel(playerid);
    gVXMedDuty[playerid]=false; gVXHospital[playerid]=false;
    gVXTreatment[playerid]=VX_HOSPITAL_SECONDS;
    gVXExpectedDialog[playerid]=-1;
    // Close any stale purchase/teleport dialog.
    ShowPlayerDialog(playerid,-1,DIALOG_STYLE_MSGBOX,"","","","");
    if(gVXDeathTimer[playerid]) KillTimer(gVXDeathTimer[playerid]);
    gVXDeathTimer[playerid]=0;
    if(gFBIEnterTimer[playerid]) KillTimer(gFBIEnterTimer[playerid]);
    gFBIEnterTimer[playerid]=0; gFBIPendingEnter[playerid]=false;
    gFBIEditActive[playerid]=false; gFBIEditMoveObject[playerid]=false;
    if(gFBIEditObject[playerid]!=INVALID_OBJECT_ID) DestroyObject(gFBIEditObject[playerid]);
    gFBIEditObject[playerid]=INVALID_OBJECT_ID;
    if(gWorkVehicle[playerid]!=INVALID_VEHICLE_ID) DestroyVehicle(gWorkVehicle[playerid]);
    gWorkVehicle[playerid]=INVALID_VEHICLE_ID; gWorkStage[playerid]=0;
    new v=gCarjackVehicle[playerid];
    if(v>0 && v<MAX_VEHICLES && GetVehicleModel(v))
    { gCarjackVehicleOwner[v]=INVALID_PLAYER_ID; DestroyVehicle(v); }
    gCarjackVehicle[playerid]=INVALID_VEHICLE_ID;
    gCarjackActive[playerid]=false; gCarjackUnlocked[playerid]=false;
    if(gDrivingTestVehicle[playerid]!=INVALID_VEHICLE_ID) DestroyVehicle(gDrivingTestVehicle[playerid]);
    gDrivingTestVehicle[playerid]=INVALID_VEHICLE_ID; gDrivingTestStage[playerid]=0;
    gGpsActive[playerid]=false; gPursuitTarget[playerid]=INVALID_PLAYER_ID;
    DisablePlayerCheckpoint(playerid);
    RemovePlayerMapIcon(playerid,48); RemovePlayerMapIcon(playerid,49); RemovePlayerMapIcon(playerid,57);
    if(gPvpActive[playerid])
    {
        new opponent=gPvpOpponent[playerid];
        gPvpActive[playerid]=false; gPvpOpponent[playerid]=INVALID_PLAYER_ID;
        gPvpRestorePending[playerid]=false;
        if(VX_Valid(opponent))
        {
            gPvpActive[opponent]=false; gPvpOpponent[opponent]=INVALID_PLAYER_ID;
            gPvpRestorePending[opponent]=true; SpawnPlayer(opponent);
        }
    }
    gPvpPendingFrom[playerid]=INVALID_PLAYER_ID; gPvpRequestTarget[playerid]=INVALID_PLAYER_ID;
    gVXRestore[playerid]=false;
    if(gVXSpec[playerid]!=INVALID_PLAYER_ID)
    { gVXSpec[playerid]=INVALID_PLAYER_ID; TogglePlayerSpectating(playerid,false); }
    return 1;
}
stock RP_StartJail(actorid,targetid,seconds,const rawReason[],source)
{
    if(!VX_Valid(targetid) || !gRPLoaded[targetid] || actorid==targetid)
        return RP_Message(actorid,"������� ID ������� ��������������� ������.");
    if(gIsJailed[targetid]) return RP_Message(actorid,"����� ��� �������� ����.");
    if(seconds<60 || seconds>RP_JAIL_MAX) return RP_Message(actorid,"����: �� 60 �� 7200 ������.");
    new reason[97],q[512],detail[144];
    VX_CleanText(rawReason,reason,sizeof reason);
    if(strlen(reason)<3) return RP_Message(actorid,"������� �������� ������� (3-96 ��������).");
    if(source==1)
    {
        if(!VX_Admin(actorid)) return RP_Message(actorid,"������� �������� ������ �������������.");
        if(gAdmin[targetid]>gAdmin[actorid] && !IsPlayerAdmin(actorid))
            return RP_Message(actorid,"������ ��������� �������������� ����� �������� ������.");
    }
    else
    {
        if(!RP_Free(actorid) || !VX_Officer(actorid) || gFactionRank[actorid]<2)
            return RP_Message(actorid,"����� �������� �������/FBI �� 2 �����.");
        if(seconds>1800 || !gHandcuffed[targetid] || gWantedLevel[targetid]<1
            || !VX_Near(actorid,targetid,6.0))
            return RP_Message(actorid,"����� ������, ��������� � ��������� �� 6 �. ���� �������: �� 1800 ������.");
        if(!RP_AtPrisonGate(actorid) && !IsNearPoliceEntrance(actorid)
            && !(GetPlayerInterior(actorid)==6 && GetPlayerVirtualWorld(actorid)==0))
            return RP_Message(actorid,"��������� ������������ � ������� ��� �� ����� ������.");
    }
    if(!VX_Begin()) return VX_Error(actorid);
    format(q,sizeof q,
        "UPDATE rp_state SET jail_left=%d,jail_original=%d,sentence=sentence+1,reduced=0,source=%d,reason='%q' WHERE name='%q'",
        seconds,seconds,source,reason,gName[targetid]);
    VX_SQL(q);
    format(detail,sizeof detail,"%d sec: %s",seconds,reason);
    RP_Audit(targetid,actorid,"JAIL",detail);
    if(!VX_Commit()) return VX_Error(actorid);
    gRPJailLeft[targetid]=seconds; gRPJailOriginal[targetid]=seconds;
    gRPSentence[targetid]++; gRPJailReduced[targetid]=false;
    gRPJailSource[targetid]=source;
    format(gRPJailReason[targetid],97,"%s",reason);
    gIsJailed[targetid]=true; gRPLawOffer[targetid]=INVALID_PLAYER_ID;
    if(gJailTimer[targetid]) KillTimer(gJailTimer[targetid]);
    gJailTimer[targetid]=0;
    RP_CancelActivities(targetid);
    VX_SetWanted(targetid,0);
    if(GetPlayerState(targetid)==PLAYER_STATE_WASTED) SpawnPlayer(targetid);
    RP_JailPosition(targetid); SavePlayer(targetid);
    format(detail,sizeof detail,"[������] %s �������� �� %d ���. �������: %s",
        gName[targetid],(seconds+59)/60,reason);
    SendClientMessage(actorid,COLOR_GREEN,detail);
    SendClientMessage(targetid,COLOR_RED,detail);
    return RP_Message(targetid,"���� ��� ������ � ����. /jailinfo. ������� ����� ���� ��� ��������� ��� �� 20%.");
}
stock RP_Release(playerid,actorid,const reason[])
{
    if(!gIsJailed[playerid] || !gRPLoaded[playerid]) return 0;
    new q[192];
    if(!VX_Begin()) return 0;
    format(q,sizeof q,"UPDATE rp_state SET jail_left=0 WHERE name='%q'",gName[playerid]);
    VX_SQL(q); RP_Audit(playerid,actorid,"RELEASE",reason);
    if(!VX_Commit()) return 0;
    gRPJailLeft[playerid]=0; gIsJailed[playerid]=false;
    gRPLawOffer[playerid]=INVALID_PLAYER_ID;
    if(gJailTimer[playerid]) KillTimer(gJailTimer[playerid]);
    gJailTimer[playerid]=0;
    SetPlayerInterior(playerid,0); SetPlayerVirtualWorld(playerid,0);
    SetPlayerPos(playerid,RP_PRISON_X,RP_PRISON_Y-10.0,RP_PRISON_Z);
    SetPlayerSpecialAction(playerid,SPECIAL_ACTION_NONE);
    ClearAnimations(playerid); TogglePlayerControllable(playerid,true);
    SetCameraBehindPlayer(playerid);
    RP_Message(playerid,"�� ����������� �� ������. ������������� � �������� �����.");
    SavePlayer(playerid);
    return 1;
}
stock RP_JailInfo(playerid)
{
    if(!gIsJailed[playerid]) return RP_Message(playerid,"�� �� ��������� ����. /prison � ������� � ������.");
    new body[512],help[96];
    if(gRPJailReduced[playerid]) format(help,sizeof help,"������ �������� ��� ������������.");
    else format(help,sizeof help,"�������: ���� ��� -20%% ��������������� �����, �� ����� 10 �����.");
    format(body,sizeof body,
        "��������: %d ���. %d ���.\n�������������: %d ���.\n�������: %s\n\n%s\n���� ��� ������ � ����.",
        gRPJailLeft[playerid]/60,gRPJailLeft[playerid]%60,gRPJailOriginal[playerid]/60,
        gRPJailReason[playerid],help);
    return VX_Show(playerid,VX_LOG,DIALOG_STYLE_MSGBOX,"VEXORIUM | ����������",body,"OK","�������");
}
stock RP_Clients(playerid)
{
    if((gJob[playerid]!=RP_LAWYER_JOB && !VX_Officer(playerid) && !VX_Admin(playerid)) || !RP_Free(playerid))
        return RP_Message(playerid,"������ �������� ���������, �������/FBI � �������������.");
    new body[3500],row[176],flag[16];
    strcat(body,"ID\t�����������\t�������\t�������\n");
    for(new p=0;p<MAX_PLAYERS;p++) if(VX_Valid(p) && gIsJailed[p])
    {
        if(gRPJailReduced[p]) format(flag,sizeof flag,"�����������");
        else format(flag,sizeof flag,"��������");
        format(row,sizeof row,"%d\t%s\t%d ���.\t%s\n",p,gName[p],(gRPJailLeft[p]+59)/60,flag);
        if(strlen(body)+strlen(row)<sizeof body-1) strcat(body,row,sizeof body);
    }
    return VX_Show(playerid,VX_LOG,DIALOG_STYLE_TABLIST_HEADERS,"������ | ����������� � ����",body,"OK","�������");
}
stock RP_LawOffer(playerid,targetid)
{
    if(!RP_Free(playerid) || gJob[playerid]!=RP_LAWYER_JOB || gFaction[playerid]!=FACTION_NONE || !RP_AtLawDesk(playerid))
        return RP_Message(playerid,"������� ������ ���������� � ������ ������� ������.");
    if(!VX_Valid(targetid) || targetid==playerid || !gIsJailed[targetid] || gRPJailReduced[targetid])
        return RP_Message(playerid,"����������� ���������� ��� ��� ����������� ������ ��������.");
    if(gRPJailLeft[targetid]<=60) return RP_Message(playerid,"�� ������������ �������� �� ������ ������.");
    if(gRPLawOffer[targetid]!=INVALID_PLAYER_ID && gettime()<gRPLawUntil[targetid])
        return RP_Message(playerid,"����������� ��� ������������� ����������� ��������.");
    gRPLawOffer[targetid]=playerid; gRPLawSession[targetid]=gVXSession[playerid];
    gRPLawSentence[targetid]=gRPSentence[targetid]; gRPLawUntil[targetid]=gettime()+60;
    new m[144];
    format(m,sizeof m,"[�������] %s ���������� ��������� ���� �� %d ���. /acceptlawyer ��� /declinelawyer (60 ���.)",
        gName[playerid],RP_LAWYER_FEE);
    SendClientMessage(targetid,COLOR_BLUE,m);
    return RP_Message(playerid,"����������� ����������. ������ � ���������� � ������ ����� �������� ������������.");
}
stock RP_LawAccept(playerid)
{
    new lawyer=gRPLawOffer[playerid];
    if(!gIsJailed[playerid] || gRPJailReduced[playerid] || !VX_Valid(lawyer)
        || gVXSession[lawyer]!=gRPLawSession[playerid] || gettime()>gRPLawUntil[playerid]
        || gRPLawSentence[playerid]!=gRPSentence[playerid])
        return RP_Message(playerid,"����������� �������� ���������������.");
    if(!RP_Free(lawyer) || gJob[lawyer]!=RP_LAWYER_JOB || gFaction[lawyer]!=FACTION_NONE || !RP_AtLawDesk(lawyer))
        return RP_Message(playerid,"������� ������ ���������� � ������� ������.");
    if(gMoney[playerid]<RP_LAWYER_FEE || gMoney[lawyer]>MAX_MONEY-RP_LAWYER_FEE)
        return RP_Message(playerid,"������������ �������� ��� ������ ��� ��������� ����� ����� ��������.");
    new cut=min(gRPJailOriginal[playerid]*RP_LAWYER_PERCENT/100,RP_LAWYER_MAX_CUT);
    cut=min(cut,gRPJailLeft[playerid]-60);
    if(cut<=0) return RP_Message(playerid,"�� ������������ �������� �� ������ ������.");
    new q[256],m[144],left=gRPJailLeft[playerid]-cut;
    if(!VX_Begin()) return VX_Error(playerid);
    VX_MoneySQL(playerid,gMoney[playerid]-RP_LAWYER_FEE,gBankMoney[playerid]);
    VX_MoneySQL(lawyer,gMoney[lawyer]+RP_LAWYER_FEE,gBankMoney[lawyer]);
    format(q,sizeof q,"UPDATE rp_state SET jail_left=%d,reduced=1 WHERE name='%q'",left,gName[playerid]);
    VX_SQL(q);
    format(m,sizeof m,"Sentence %d; reduction %d sec; fee %d",gRPSentence[playerid],cut,RP_LAWYER_FEE);
    RP_Audit(playerid,lawyer,"LAWYER",m);
    if(!VX_Commit()) return VX_Error(playerid);
    VX_MoneySync(playerid,gMoney[playerid]-RP_LAWYER_FEE,gBankMoney[playerid]);
    VX_MoneySync(lawyer,gMoney[lawyer]+RP_LAWYER_FEE,gBankMoney[lawyer]);
    gRPJailLeft[playerid]=left; gRPJailReduced[playerid]=true;
    gRPLawOffer[playerid]=INVALID_PLAYER_ID;
    format(m,sizeof m,"[�������] ���� �������� �� %d ���. ��������: %d ���. %d ���.",cut,left/60,left%60);
    SendClientMessage(playerid,COLOR_GREEN,m); SendClientMessage(lawyer,COLOR_GREEN,m);
    return 1;
}

// ================= Police/FBI: detention, evidence, fines and dossiers =================
stock RP_Cuff(playerid,targetid,bool:remove)
{
    if(!RP_Free(playerid) || !VX_Officer(playerid) || gFactionRank[playerid]<2)
        return RP_Message(playerid,"��������� �������� �������/FBI �� 2 �����.");
    if(!RP_Living(targetid) || targetid==playerid || !VX_Near(playerid,targetid,3.0)
        || gIsJailed[targetid] || gVXHospital[targetid] || gPvpActive[targetid])
        return RP_Message(playerid,"����� ����� ����� �����, �� � ��������, ������ ��� PvP.");
    if(IsPlayerInAnyVehicle(targetid)) return RP_Message(playerid,"����� ������ ����� �� ����������.");
    if(remove)
    {
        if(!gHandcuffed[targetid]) return RP_Message(playerid,"�� ������ ��� ����������.");
        ApplyAnimation(playerid, "POLICE", "CopTraf_Away", 4.1, 0, 0, 0, 0, 900, 1);
        gHandcuffed[targetid]=false;
        gCuffOfficer[targetid]=INVALID_PLAYER_ID;
        if(!gTaserStunned[targetid]) TogglePlayerControllable(targetid,true);
        ClearAnimations(targetid); SetPlayerSpecialAction(targetid,SPECIAL_ACTION_NONE);
        RP_Audit(targetid,playerid,"UNCUFF","Handcuffs removed");
        RP_Message(targetid,"��������� ���� � ��� ���������.");
        return RP_Message(playerid,"��������� �����.");
    }
    if(gHandcuffed[targetid]) return RP_Message(playerid,"����� ��� � ����������.");
    if(!gWantedLevel[targetid] && !gTaserStunned[targetid]
        && GetPlayerSpecialAction(targetid)!=SPECIAL_ACTION_HANDSUP)
        return RP_Message(playerid,"����� ���������: ������, ��������� ��� �������� ���� ������ (/handsup).");
    RP_DropStretcher(targetid);
    ApplyAnimation(playerid, "POLICE", "CopTraf_Stop", 4.1, 0, 0, 0, 0, 900, 1);
    gHandcuffed[targetid]=true;
    gCuffOfficer[targetid]=playerid;
    ClearAnimations(targetid); SetPlayerSpecialAction(targetid,24);
    TogglePlayerControllable(targetid,false);
    RP_Audit(targetid,playerid,"CUFF","Handcuffs applied");
    RP_Message(targetid,"�� ��� ������ ���������. /report �������� ��� ����������.");
    return RP_Message(playerid,"��������� ������. /search ID, /putincar ID, /arrest ID ������� �������.");
}
stock RP_Search(playerid,targetid)
{
    if(!RP_Free(playerid) || !VX_Officer(playerid)) return RP_Message(playerid,"�������� �������/FBI.");
    if(!RP_Living(targetid) || targetid==playerid || !VX_Near(playerid,targetid,3.0))
        return RP_Message(playerid,"����� ������ ���������� �����, �� 3 ������.");
    if(!gHandcuffed[targetid] && GetPlayerSpecialAction(targetid)!=SPECIAL_ACTION_HANDSUP)
        return RP_Message(playerid,"��� ������ ����� ��������� ��� ����������� �������� ����.");
    new body[1800],row[128],weapon,ammo,name[32];
    format(body,sizeof body,"�����: %s [%d]\n��������: %d ���.\n�������� �� ������: %d\n\n��������:\n",
        gName[targetid],targetid,gMoney[targetid],gLicenseWeapon[targetid]);
    for(new i=0;i<6;i++)
    {
        format(row,sizeof row,"%s: %d\n",gVXItemName[i],VX_ItemCount(targetid,i));
        strcat(body,row,sizeof body);
    }
    strcat(body,"\n������:\n",sizeof body);
    for(new slot=0;slot<13;slot++)
    {
        GetPlayerWeaponData(targetid,slot,weapon,ammo);
        if(weapon>0 && ammo>0)
        {
            GetWeaponName(weapon,name,sizeof name);
            format(row,sizeof row,"%s (%d): %d ��������\n",name,weapon,ammo);
            strcat(body,row,sizeof body);
        }
    }
    RP_Audit(targetid,playerid,"SEARCH","Inventory and weapons inspected");
    RP_Message(targetid,"��������� ����� �����. ��� ����� �� ��������� ������ ��� ��������.");
    return VX_Show(playerid,VX_LOG,DIALOG_STYLE_MSGBOX,"������� / FBI | �����",body,"OK","�������");
}
stock RP_Seize(playerid,targetid,const item[],const rawReason[])
{
    if(!RP_Free(playerid) || !VX_Officer(playerid) || gFactionRank[playerid]<2)
        return RP_Message(playerid,"������� �������� �������/FBI �� 2 �����.");
    if(!RP_Living(targetid) || targetid==playerid || !VX_Near(playerid,targetid,3.0)
        || !gHandcuffed[targetid]) return RP_Message(playerid,"����������� ������ ���� ����� � � ����������.");
    new reason[81],detail[256],row[28],weapon,ammo,old=gLockpicks[targetid];
    VX_CleanText(rawReason,reason,sizeof reason);
    if(strlen(reason)<3) return RP_Message(playerid,"�������������: /seize ID weapons|lockpicks �������.");
    if(strcmp(item,"weapons",true) && strcmp(item,"lockpicks",true))
        return RP_Message(playerid,"����� ������ weapons (������) ��� lockpicks (�������).");
    format(detail,sizeof detail,"%s; %s; ",item,reason);
    if(!strcmp(item,"weapons",true))
    {
        new count=0;
        for(new slot=0;slot<13;slot++)
        {
            GetPlayerWeaponData(targetid,slot,weapon,ammo);
            if(weapon>0 && ammo>0)
            {
                count++; format(row,sizeof row,"%d:%d ",weapon,ammo);
                if(strlen(detail)+strlen(row)<sizeof detail-1) strcat(detail,row,sizeof detail);
            }
        }
        if(!count) return RP_Message(playerid,"������ �� �������.");
    }
    else
    {
        if(old<1) return RP_Message(playerid,"������� ���.");
        format(row,sizeof row,"amount=%d",old); strcat(detail,row,sizeof detail);
    }
    if(!VX_Begin()) return VX_Error(playerid);
    if(!strcmp(item,"lockpicks",true)) { gLockpicks[targetid]=0; VX_ItemsSQL(targetid); }
    RP_Audit(targetid,playerid,"SEIZE",detail);
    if(!VX_Commit()) { gLockpicks[targetid]=old; return VX_Error(playerid); }
    if(!strcmp(item,"weapons",true)) ResetPlayerWeapons(targetid);
    RP_Message(targetid,"�������� ������ � ������� ��������� � ����. /report � ����� � ��������������.");
    return RP_Message(playerid,"������� �������� � ����. �������� �� �������� ����������.");
}
stock RP_Wanted(playerid,targetid,stars,const rawReason[])
{
    if(!RP_Free(playerid) || !VX_Officer(playerid) || gFactionRank[playerid]<3)
        return RP_Message(playerid,"������ �������� �������/FBI � 3 �����.");
    if(!VX_Valid(targetid) || targetid==playerid || stars<0 || stars>6 || gIsJailed[targetid])
        return RP_Message(playerid,"�������������: /wanted ID 0-6 �������. ����������� ��� �������� ���������.");
    new reason[97];
    VX_CleanText(rawReason,reason,sizeof reason);
    if(strlen(reason)<3) return RP_Message(playerid,"������� ��������� ��������� �������.");
    if(!RP_Audit(targetid,playerid,"WANTED",reason)) return VX_Error(playerid);
    VX_SetWanted(targetid,stars);
    new m[144]; format(m,sizeof m,"[������] %d/6. ���������: %s",stars,reason);
    SendClientMessage(targetid,COLOR_RED,m);
    return RP_Message(playerid,"������������ � ������� ��������. /tablet /case ID.");
}
stock RP_Ticket(playerid,targetid,amount,const rawReason[])
{
    if(!RP_Free(playerid) || !VX_Officer(playerid) || gFactionRank[playerid]<2)
        return RP_Message(playerid,"������ �������� �������/FBI �� 2 �����.");
    if(!RP_Living(targetid) || targetid==playerid || !VX_Near(playerid,targetid,5.0)
        || amount<100 || amount>50000) return RP_Message(playerid,"/ticket ID �����(100-50000) �������. ����� � �����.");
    new reason[97],q[512],m[144];
    VX_CleanText(rawReason,reason,sizeof reason);
    if(strlen(reason)<3) return RP_Message(playerid,"������� ��������� ������.");
    if(!VX_Begin()) return VX_Error(playerid);
    format(q,sizeof q,
        "INSERT INTO rp_fines(subject,officer,amount,reason,created) VALUES('%q','%q',%d,'%q',%d)",
        gName[targetid],gName[playerid],amount,reason,gettime());
    VX_SQL(q); RP_Audit(targetid,playerid,"FINE",reason);
    if(!VX_Commit()) return VX_Error(playerid);
    format(m,sizeof m,"[�����] %d ���. ���������: %s. /fines � ������, /payfine ����� � ������.",amount,reason);
    SendClientMessage(targetid,COLOR_ORANGE,m);
    return RP_Message(playerid,"�������� ��������. ������ �� ���������� ����������.");
}
stock RP_Fines(playerid,targetid)
{
    if(!VX_Valid(targetid)) return RP_Message(playerid,"����� �� ������.");
    if(playerid!=targetid && !VX_Officer(playerid) && !VX_Admin(playerid))
        return RP_Message(playerid,"�������� ����� ������� �������� �����������.");
    new q[256],body[3500],row[192],reason[97],officer[25],count=0;
    format(q,sizeof q,"SELECT id,amount,officer,reason FROM rp_fines WHERE subject='%q' AND paid=0 ORDER BY id DESC LIMIT 20",gName[targetid]);
    new DBResult:r=db_query(gDatabase,q);
    strcat(body,"�����\t�����\t���������\t�������\n",sizeof body);
    if(r) for(new i=0;i<db_num_rows(r);i++)
    {
        db_get_field(r,2,officer,sizeof officer); db_get_field(r,3,reason,sizeof reason);
        format(row,sizeof row,"%d\t%d\t%s\t%s\n",db_get_field_int(r,0),db_get_field_int(r,1),officer,reason);
        if(strlen(body)+strlen(row)<sizeof body-1) { strcat(body,row,sizeof body); count++; }
        db_next_row(r);
    }
    if(r) db_free_result(r);
    if(!count) return RP_Message(playerid,"������������ ������� ���.");
    return VX_Show(playerid,VX_LOG,DIALOG_STYLE_TABLIST_HEADERS,"������ | /payfine �����",body,"OK","�������");
}
stock RP_PayFine(playerid,id)
{
    if(id<1) return RP_Message(playerid,"/payfine �����. ����� ������ � /fines.");
    if(!VX_Begin()) return VX_Error(playerid);
    new q[256],amount=0;
    format(q,sizeof q,"SELECT amount FROM rp_fines WHERE id=%d AND subject='%q' AND paid=0",id,gName[playerid]);
    new DBResult:r=db_query(gDatabase,q);
    if(r && db_num_rows(r)) amount=db_get_field_int(r,0);
    if(r) db_free_result(r);
    if(amount<1 || gBankMoney[playerid]<amount)
    {
        VX_SQL("ROLLBACK");
        return RP_Message(playerid,"����� �� ������, ��� ������� ��� �� ������� ����� �� ���������� �����.");
    }
    VX_MoneySQL(playerid,gMoney[playerid],gBankMoney[playerid]-amount);
    format(q,sizeof q,"UPDATE rp_fines SET paid=1 WHERE id=%d AND subject='%q'",id,gName[playerid]);
    VX_SQL(q); VX_BankLog(playerid,"fine",-amount);
    if(!VX_Commit()) return VX_Error(playerid);
    VX_MoneySync(playerid,gMoney[playerid],gBankMoney[playerid]-amount);
    return RP_Message(playerid,"����� ������� � ����������� �����.");
}
stock RP_History(playerid,targetid,bool:medical)
{
    if(!VX_Valid(targetid)) return RP_Message(playerid,"����� �� ������.");
    if(medical)
    {
        if(playerid!=targetid && !VX_Medic(playerid) && !VX_Admin(playerid))
            return RP_Message(playerid,"�������� �������� ��������, ������� �� ����� � �������������.");
    }
    else if(!VX_Officer(playerid) && !VX_Admin(playerid))
        return RP_Message(playerid,"����� �������� �������/FBI � �������������.");
    new q[320],body[3500],row[320],kind[24],detail[193],actor[25];
    if(medical) format(q,sizeof q,
        "SELECT kind,actor,detail,created FROM rp_audit WHERE subject='%q' AND kind LIKE 'MED_%%' ORDER BY id DESC LIMIT 12",
        gName[targetid]);
    else format(q,sizeof q,
        "SELECT kind,actor,detail,created FROM rp_audit WHERE subject='%q' AND kind NOT LIKE 'MED_%%' ORDER BY id DESC LIMIT 12",
        gName[targetid]);
    new DBResult:r=db_query(gDatabase,q);
    format(body,sizeof body,"�����: %s [%d]\n��������� ������:\n\n",gName[targetid],targetid);
    if(r) for(new i=0;i<db_num_rows(r);i++)
    {
        db_get_field(r,0,kind,sizeof kind); db_get_field(r,1,actor,sizeof actor);
        db_get_field(r,2,detail,sizeof detail);
        format(row,sizeof row,"[%s] %s | %d ���. �����\n%s\n\n",
            kind,actor,max(0,(gettime()-db_get_field_int(r,3))/60),detail);
        if(strlen(body)+strlen(row)<sizeof body-1) strcat(body,row,sizeof body);
        db_next_row(r);
    }
    if(r) db_free_result(r);
    return VX_Show(playerid,VX_LOG,DIALOG_STYLE_MSGBOX,"VEXORIUM | �������� ������",body,"OK","�������");
}
stock RP_CameraLogs(playerid)
{
    if(!VX_Officer(playerid) && !VX_Admin(playerid)) return RP_Message(playerid,"�������� �������/FBI � �������������.");
    new body[3500],row[240],name[25],detail[144];
    new DBResult:r=db_query(gDatabase,
        "SELECT subject,detail,created FROM rp_audit WHERE kind='CAMERA' ORDER BY id DESC LIMIT 15");
    strcat(body,"������ ��������� ���������� ��������. ��� ������, �� ���������������.\n\n",sizeof body);
    if(r) for(new i=0;i<db_num_rows(r);i++)
    {
        db_get_field(r,0,name,sizeof name); db_get_field(r,1,detail,sizeof detail);
        format(row,sizeof row,"%s | %d ���. �����\n%s\n\n",name,max(0,(gettime()-db_get_field_int(r,2))/60),detail);
        if(strlen(body)+strlen(row)<sizeof body-1) strcat(body,row,sizeof body);
        db_next_row(r);
    }
    if(r) db_free_result(r);
    return VX_Show(playerid,VX_LOG,DIALOG_STYLE_MSGBOX,"������� | ������ �������� �����",body,"OK","�������");
}

// ================= BCRB: persistent injuries, treatment and patient transport =================
stock RP_Diagnose(playerid,targetid)
{
    if(!RP_Living(targetid)) return RP_Message(playerid,"������� �� ������.");
    if(playerid!=targetid && (!VX_Medic(playerid) || !RP_Free(playerid)
        || !VX_Near(playerid,targetid,4.0))) return RP_Message(playerid,"����� �� ����� ������ ���������� ����� � ���������.");
    new body[512],bleed[24],fracture[24],Float:hp;
    GetPlayerHealth(targetid,hp);
    if(gRPInjury[targetid] & RP_INJ_BLEED) format(bleed,sizeof bleed,"����");
    else format(bleed,sizeof bleed,"���");
    if(gRPInjury[targetid] & RP_INJ_FRACTURE) format(fracture,sizeof fracture,"����");
    else format(fracture,sizeof fracture,"���");
    format(body,sizeof body,
        "�������: %s\n��������: %.0f\n������������: %s\n�������: %s\n\n����: /103\n�����: /bandage ID, /splint ID, /heal ID\n�������� �� �����: /operation ID\n��������: /medcard ID",
        gName[targetid],hp,bleed,fracture);
    return VX_Show(playerid,VX_LOG,DIALOG_STYLE_MSGBOX,"���� | ��������� ��������",body,"OK","�������");
}
stock RP_OnDamage(playerid,issuerid,Float:amount,weaponid,bodypart)
{
    if(!RP_Living(playerid) || gIsJailed[playerid] || gVXHospital[playerid]
        || gPvpActive[playerid] || (weaponid==23 && VX_Officer(issuerid)) || amount<15.0) return 0;
    new injury=gRPInjury[playerid],Float:armour;
    GetPlayerArmour(playerid,armour);
    if(weaponid>=22 && weaponid<=34 && amount>armour)
        gRPInjury[playerid] |= RP_INJ_BLEED;
    if((weaponid==54 || weaponid==49 || bodypart==7 || bodypart==8) && amount>=25.0
        && amount>armour) gRPInjury[playerid] |= RP_INJ_FRACTURE;
    if(injury!=gRPInjury[playerid])
    {
        gRPBleedAt[playerid]=gettime()+15; RP_SaveState(playerid);
        RP_Audit(playerid,INVALID_PLAYER_ID,"MED_INJURY","New injury; see patient condition");
        RP_Message(playerid,"�� �������� ������. /health � ���������, /103 � ������. ������� ������������� �����.");
    }
    return 1;
}
stock RP_MedFinish(doctor,patient,newInjury,const detail[])
{
    new oldInjury=gRPInjury[patient],oldPay=gRPNextMedPay[patient],pay=0;
    if(gVXMedAssigned[patient]==doctor && gettime()>=oldPay && gBankMoney[doctor]<=MAX_MONEY-RP_MED_PAY)
        pay=RP_MED_PAY;
    if(!VX_Begin()) return 0;
    gRPInjury[patient]=newInjury;
    if(pay) gRPNextMedPay[patient]=gettime()+RP_MED_PAY_COOLDOWN;
    RP_SaveState(patient);
    if(pay)
    {
        VX_MoneySQL(doctor,gMoney[doctor],gBankMoney[doctor]+pay);
        VX_BankLog(doctor,"medical",pay,gName[patient]);
    }
    RP_Audit(patient,doctor,"MED_TREATMENT",detail);
    if(!VX_Commit())
    {
        gRPInjury[patient]=oldInjury; gRPNextMedPay[patient]=oldPay;
        return 0;
    }
    if(pay)
    {
        VX_MoneySync(doctor,gMoney[doctor],gBankMoney[doctor]+pay);
        RP_Message(doctor,"�������� ����� ��������. �������������� 750 ���. ��������� � ����.");
    }
    if(gVXMedAssigned[patient]==doctor) VX_MedCancel(patient);
    return 1;
}
stock RP_MedTreat(playerid,targetid,kind)
{
    if(!RP_Free(playerid) || !VX_Medic(playerid)) return RP_Message(playerid,"�������� ����������� ���� �� �����.");
    if(!RP_Living(targetid) || targetid==playerid || !VX_Near(playerid,targetid,4.0)
        || gIsJailed[targetid] || gPvpActive[targetid] || gHandcuffed[targetid])
        return RP_Message(playerid,"����� ����� ������� �����, �� � PvP � �� ��� �������.");
    if(gVXHospital[targetid] && gVXBed[targetid]<0) return RP_Message(playerid,"������� ������ ������ �����: /bed.");
    if(gRPOpDoctor[targetid]!=INVALID_PLAYER_ID) return RP_Message(playerid,"������� ��� �� ��������.");
    if(gettime()-gVXLastHeal[playerid]<10) return RP_Message(playerid,"����� ����������� ������ ������ 10 ������.");
    if(gMedkits[playerid]<1) return RP_Message(playerid,"��� ��������� ����� ������� � ��������� ������.");
    new injury=gRPInjury[targetid],Float:hp,detail[96];
    GetPlayerHealth(targetid,hp);
    switch(kind)
    {
        case 0:
        {
            if(!(injury & RP_INJ_BLEED)) return RP_Message(playerid,"� �������� ��� ������������.");
            injury &= ~RP_INJ_BLEED; format(detail,sizeof detail,"Bleeding stopped");
        }
        case 1:
        {
            if(!(injury & RP_INJ_FRACTURE)) return RP_Message(playerid,"������� �� ���������.");
            injury &= ~RP_INJ_FRACTURE; format(detail,sizeof detail,"Fracture treated");
        }
        case 2:
        {
            if(injury & RP_INJ_FRACTURE) return RP_Message(playerid,"������� ����������� �������: /splint ID, ���� �������� � ����.");
            if(hp>=100.0 && !injury && !gVXHospital[targetid]) return RP_Message(playerid,"������� ������.");
            injury=0; format(detail,sizeof detail,"Medical treatment");
        }
        case 3:
        {
            if(gFactionRank[playerid]<3 || !gVXHospital[targetid] || gVXBed[targetid]<0)
                return RP_Message(playerid,"��������: ����� � 3 �����, ������� �� ����� � ����.");
            for(new p=0;p<MAX_PLAYERS;p++) if(gRPOpDoctor[p]==playerid)
                return RP_Message(playerid,"������� ��������� ������� ��������.");
            format(detail,sizeof detail,"Operation started");
        }
        default: return 1;
    }
    // Supplies are consumed once. An interrupted operation still uses its kit.
    if(!VX_Begin()) return VX_Error(playerid);
    gMedkits[playerid]--; VX_ItemsSQL(playerid);
    RP_Audit(targetid,playerid,"MED_PROCEDURE",detail);
    if(!VX_Commit()) { gMedkits[playerid]++; return VX_Error(playerid); }
    gVXLastHeal[playerid]=gettime();
    if(kind==3)
    {
        gRPOpDoctor[targetid]=playerid; gRPOpSession[targetid]=gVXSession[playerid];
        gRPOpUntil[targetid]=gettime()+30;
        gVXTreatment[targetid]=max(gVXTreatment[targetid],45);
        VX_Save(targetid);
        RP_Message(targetid,"�������� ��������. ����������� �� ����� 30 ������.");
        return RP_Message(playerid,"�������� ��������. ����������� ����� � ��������� 30 ������.");
    }
    if(!RP_MedFinish(playerid,targetid,injury,detail)) return VX_Error(playerid);
    if(kind==2)
    {
        if(gVXHospital[targetid]) gVXTreatment[targetid]=min(gVXTreatment[targetid],20);
        else SetPlayerHealth(targetid,100.0);
    }
    else SetPlayerHealth(targetid,VX_FloatMin(100.0,hp+15.0));
    VX_Save(targetid);
    RP_Message(targetid,"����������� ��������� ���������. ���������: /health.");
    return RP_Message(playerid,"��������� �������� � ��������.");
}
stock RP_DropStretcher(patient)
{
    if(patient<0 || patient>=MAX_PLAYERS) return 0;
    if(gRPStretcherObject[patient]!=INVALID_OBJECT_ID)
        DestroyObject(gRPStretcherObject[patient]);
    gRPStretcherObject[patient]=INVALID_OBJECT_ID;
    gRPStretcherBy[patient]=INVALID_PLAYER_ID;
    if(VX_Valid(patient) && !gHandcuffed[patient] && !gTaserStunned[patient] && gVXBed[patient]<0)
    {
        ClearAnimations(patient); TogglePlayerControllable(patient,true);
    }
    return 1;
}
stock RP_Stretcher(playerid,targetid)
{
    if(!RP_Free(playerid) || !VX_Medic(playerid) || IsPlayerInAnyVehicle(playerid))
        return RP_Message(playerid,"������� �������� ������ �� �����, ��� ����������.");
    if(!RP_Free(targetid) || targetid==playerid || !VX_Near(playerid,targetid,3.0)
        || IsPlayerInAnyVehicle(targetid)) return RP_Message(playerid,"������� ������ ���������� ����� � ��� ����������.");
    new Float:hp; GetPlayerHealth(targetid,hp);
    if(!gRPInjury[targetid] && hp>=50.0) return RP_Message(playerid,"������� ����� ������ �������������� ��� ������ ���������.");
    for(new p=0;p<MAX_PLAYERS;p++) if(gRPStretcherBy[p]==playerid)
        return RP_Message(playerid,"�� ��� ���������� ��������. /unstretcher.");
    new Float:x,Float:y,Float:z; GetPlayerPos(targetid,x,y,z);
    new objectid=CreateObject(1997,x,y,z-1.0,0.0,0.0,0.0,50.0);
    if(objectid==INVALID_OBJECT_ID) return RP_Message(playerid,"�� ������� ������� �������: ��������� ����� ��������.");
    gRPStretcherObject[targetid]=objectid; gRPStretcherBy[targetid]=playerid;
    TogglePlayerControllable(targetid,false);
    ApplyAnimation(targetid,"CRACK","crckidle2",4.1,1,0,0,1,0,1);
    RP_Message(targetid,"����� ������ ��� �� �������. ����� �� ���������: /medrefuse.");
    return RP_Message(playerid,"���������� �������� ������. /loadpatient ID � � ������, /unstretcher � ����� � �������.");
}
stock RP_LoadPatient(playerid,targetid)
{
    if(!RP_Free(playerid) || !VX_Medic(playerid) || !RP_Living(targetid) || targetid==playerid
        || !VX_Near(playerid,targetid,5.0) || gIsJailed[targetid] || gHandcuffed[targetid]
        || gVXHospital[targetid] || gPvpActive[targetid])
        return RP_Message(playerid,"����� ����� ���� � ������� �����, �� ��� �������.");
    new Float:hp; GetPlayerHealth(targetid,hp);
    if(hp>=50.0 && !gRPInjury[targetid]) return RP_Message(playerid,"������� �� ��������� � �������������� ���������.");
    if(IsPlayerInAnyVehicle(targetid)) return RP_Message(playerid,"������� ��� � ����������.");
    new vehicleid=gFactionVehicle[playerid];
    if(vehicleid<=0 || vehicleid>=MAX_VEHICLES || GetVehicleModel(vehicleid)!=416
        || gVehicleFaction[vehicleid]!=FACTION_HOSPITAL || GetVehicleVirtualWorld(vehicleid)!=GetPlayerVirtualWorld(playerid))
        return RP_Message(playerid,"�������� ������ ��������� ������ (Ambulance) � ������ ����.");
    new Float:x,Float:y,Float:z;
    GetVehiclePos(vehicleid,x,y,z);
    if(!IsPlayerInRangeOfPoint(playerid,6.0,x,y,z)) return RP_Message(playerid,"��������� ������ �����.");
    new seat=-1;
    for(new s=1;s<=3;s++)
    {
        new occupied=0;
        for(new p=0;p<MAX_PLAYERS;p++)
            if(IsPlayerConnected(p) && IsPlayerInVehicle(p,vehicleid) && GetPlayerVehicleSeat(p)==s) occupied=1;
        if(!occupied) { seat=s; break; }
    }
    if(seat==-1) return RP_Message(playerid,"� ������ ��� ��������� ����.");
    RP_DropStretcher(targetid);
    PutPlayerInVehicle(targetid,vehicleid,seat);
    RP_Message(targetid,"�� �������� � ������ ������. ����� �������� ��� � ����.");
    return RP_Message(playerid,"� ����� ���� ����������� /hospitalize ID.");
}
stock RP_Hospitalize(playerid,targetid)
{
    if(!RP_Free(playerid) || !VX_Medic(playerid) || !RP_Living(targetid) || targetid==playerid
        || !VX_Near(playerid,targetid,6.0) || gIsJailed[targetid] || gHandcuffed[targetid]
        || gVXHospital[targetid] || gPvpActive[targetid])
        return RP_Message(playerid,"����� ����� ���� � ������� �����, �� ��� �������.");
    if(GetPlayerInterior(playerid)!=0 || GetPlayerVirtualWorld(playerid)!=0
        || !IsPlayerInRangeOfPoint(playerid,25.0,1176.7,-1322.5,13.5))
        return RP_Message(playerid,"������� ��������� �������� �� ����� ����.");
    new Float:hp; GetPlayerHealth(targetid,hp);
    if(!gRPInjury[targetid] && hp>=50.0) return RP_Message(playerid,"��� ��������� ��� ������������ ��������������.");
    if(!RP_MedFinish(playerid,targetid,gRPInjury[targetid],"��������������")) return VX_Error(playerid);
    RP_CancelActivities(targetid);
    gVXHospital[targetid]=true; gVXTreatment[targetid]=VX_HOSPITAL_SECONDS;
    VX_Save(targetid); VX_EnterHospital(targetid);
    return RP_Message(playerid,"������� ������ � ���������. ��� ������� ��� ����� ������ �����.");
}
stock RP_Discharge(playerid)
{
    new oldInjury=gRPInjury[playerid],oldTreatment=gVXTreatment[playerid];
    if(!VX_Begin()) return 0;
    gRPInjury[playerid]=0; gVXHospital[playerid]=false;
    gVXTreatment[playerid]=VX_HOSPITAL_SECONDS;
    RP_SaveState(playerid); VX_Save(playerid);
    RP_Audit(playerid,INVALID_PLAYER_ID,"MED_DISCHARGE","Inpatient treatment completed");
    if(!VX_Commit())
    {
        gRPInjury[playerid]=oldInjury; gVXHospital[playerid]=true;
        gVXTreatment[playerid]=oldTreatment;
        return 0;
    }
    gRPOpDoctor[playerid]=INVALID_PLAYER_ID; gRPOpUntil[playerid]=0;
    return 1;
}

stock RP_VehicleOwner(vehicleid)
{
    if(vehicleid<=0 || vehicleid>=MAX_VEHICLES || !GetVehicleModel(vehicleid)) return INVALID_PLAYER_ID;
    new owner=gPersonalVehicleOwner[vehicleid];
    if(!VX_Valid(owner) || !gRPLoaded[owner] || gOwnedCarVehicle[owner]!=vehicleid) return INVALID_PLAYER_ID;
    return owner;
}
stock RP_LoadCar(playerid)
{
    if(gOwnedCarModel[playerid]==0) return 1;
    new q[320];
    format(gRPCarPlate[playerid],12,"VX%06d",gVXPhone[playerid]);
    format(q,sizeof q,"INSERT OR IGNORE INTO rp_vehicles(owner,model,plate) VALUES('%q',%d,'%q')",
        gName[playerid],gOwnedCarModel[playerid],gRPCarPlate[playerid]);
    if(!VX_SQL(q)) return 0;
    format(q,sizeof q,
        "SELECT model,km,health,fuel,registered,insured,inspected,broken,plate FROM rp_vehicles WHERE owner='%q'",
        gName[playerid]);
    new DBResult:r=db_query(gDatabase,q);
    if(!r) return 0;
    if(!db_num_rows(r)) { db_free_result(r); return 0; }
    new model=db_get_field_int(r,0);
    if(model==gOwnedCarModel[playerid])
    {
        gRPCarKm[playerid]=db_get_field_float(r,1);
        if(gRPCarKm[playerid]<0.0) gRPCarKm[playerid]=0.0;
        gRPCarHealth[playerid]=VX_FloatMin(1000.0,db_get_field_float(r,2));
        if(gRPCarHealth[playerid]<250.0) gRPCarHealth[playerid]=250.0;
        gRPCarFuel[playerid]=VexHudClamp(db_get_field_int(r,3),0,100);
        gRPCarRegistered[playerid]=(db_get_field_int(r,4)!=0);
        gRPCarInsured[playerid]=db_get_field_int(r,5); gRPCarInspected[playerid]=db_get_field_int(r,6);
        gRPCarBroken[playerid]=(db_get_field_int(r,7)!=0);
        db_get_field(r,8,gRPCarPlate[playerid],12);
    }
    db_free_result(r);
    if(model!=gOwnedCarModel[playerid])
    {
        format(q,sizeof q,"DELETE FROM rp_keys WHERE owner='%q'",gName[playerid]); VX_SQL(q);
        return RP_SaveCar(playerid,false);
    }
    return 1;
}
stock RP_SaveCar(playerid,bool:sample=true)
{
    if(!gRPLoaded[playerid] || !gOwnedCarModel[playerid]) return 1;
    new v=gOwnedCarVehicle[playerid];
    if(sample && !gRPCarBroken[playerid] && RP_VehicleOwner(v)==playerid)
    {
        GetVehicleHealth(v,gRPCarHealth[playerid]);
        if(gRPCarHealth[playerid]>1000.0) gRPCarHealth[playerid]=1000.0;
        if(gRPCarHealth[playerid]<250.0) gRPCarHealth[playerid]=250.0;
        gRPCarFuel[playerid]=VexHudClamp(gVehicleFuel[v],0,100);
    }
    new q[512];
    format(q,sizeof q,
        "INSERT OR REPLACE INTO rp_vehicles(owner,model,km,health,fuel,registered,insured,inspected,broken,plate) VALUES('%q',%d,%f,%f,%d,%d,%d,%d,%d,'%q')",
        gName[playerid],gOwnedCarModel[playerid],gRPCarKm[playerid],gRPCarHealth[playerid],
        gRPCarFuel[playerid],gRPCarRegistered[playerid],gRPCarInsured[playerid],
        gRPCarInspected[playerid],gRPCarBroken[playerid],gRPCarPlate[playerid]);
    return VX_SQL(q);
}
stock RP_ConfigCar(playerid,vehicleid)
{
    if(vehicleid<=0 || vehicleid>=MAX_VEHICLES) return 0;
    if(gVehicleReturnTimer[vehicleid]) KillTimer(gVehicleReturnTimer[vehicleid]);
    gVehicleReturnTimer[vehicleid]=0;
    gVehicleFaction[vehicleid]=0; gVehicleTier[vehicleid]=0;
    gFactionVehicleOwner[vehicleid]=INVALID_PLAYER_ID;
    gCarjackVehicleOwner[vehicleid]=INVALID_PLAYER_ID;
    gPersonalVehicleOwner[vehicleid]=playerid; gOwnedCarVehicle[playerid]=vehicleid;
    gVehicleFuel[vehicleid]=gRPCarFuel[playerid];
    gFuelLastX[vehicleid]=0.0; gFuelLastY[vehicleid]=0.0; gFuelLastZ[vehicleid]=0.0;
    gRPCarPosKnown[playerid]=false;
    SetVehicleHealth(vehicleid,gRPCarHealth[playerid]);
    if(gRPCarRegistered[playerid]) SetVehicleNumberPlate(vehicleid,gRPCarPlate[playerid]);
    else SetVehicleNumberPlate(vehicleid,"TRANSIT");
    SetVehicleParamsEx(vehicleid,0,0,0,0,0,0,0);
    return 1;
}
stock RP_HasKeys(playerid,vehicleid)
{
    new owner=RP_VehicleOwner(vehicleid);
    if(owner==INVALID_PLAYER_ID)
    {
        if(vehicleid<=0 || vehicleid>=MAX_VEHICLES) return 0;
        if(gVehicleFaction[vehicleid]>0) return gFactionVehicleOwner[vehicleid]==playerid;
        if(gCarjackVehicleOwner[vehicleid]!=INVALID_PLAYER_ID)
            return gCarjackVehicle[playerid]==vehicleid && gCarjackUnlocked[playerid];
        return GetPlayerVehicleID(playerid)==vehicleid || gRentalVehicle[playerid]==vehicleid
            || gWorkVehicle[playerid]==vehicleid || gDrivingTestVehicle[playerid]==vehicleid;
    }
    if(owner==playerid) return 1;
    new q[192],found=0;
    format(q,sizeof q,"SELECT 1 FROM rp_keys WHERE owner='%q' AND guest='%q'",gName[owner],gName[playerid]);
    new DBResult:r=db_query(gDatabase,q);
    if(r) { found=(db_num_rows(r)>0); db_free_result(r); }
    return found;
}

stock RP_RevokeDrivers(owner)
{
    new v=gOwnedCarVehicle[owner];
    if(RP_VehicleOwner(v)!=owner) return 0;
    for(new p=0;p<MAX_PLAYERS;p++)
    {
        if(!VX_Valid(p) || GetPlayerState(p)!=PLAYER_STATE_DRIVER || GetPlayerVehicleID(p)!=v) continue;
        if(RP_HasKeys(p,v)) continue;
        new e,l,a,d,b,t,o; GetVehicleParamsEx(v,e,l,a,d,b,t,o);
        SetVehicleParamsEx(v,0,l,a,d,b,t,o);
        RemovePlayerFromVehicle(p); RP_Message(p,"����� �������� ����������.");
    }
    return 1;
}

stock RP_Key(playerid,targetid,action)
{
    if(!RP_Free(playerid) || !gOwnedCarModel[playerid]) return RP_Message(playerid,"� ��� ��� ������� ����������.");
    new q[256];
    if(action==2)
    {
        format(q,sizeof q,"DELETE FROM rp_keys WHERE owner='%q'",gName[playerid]);
        if(!VX_SQL(q)) return VX_Error(playerid);
        RP_RevokeDrivers(playerid);
        return RP_Message(playerid,"��� �������� ����� ��������, ������� ����� ������� ��� ����.");
    }
    if(!VX_Valid(targetid) || targetid==playerid) return RP_Message(playerid,"������� ID ������� ������.");
    if(action==0 && !VX_Near(playerid,targetid,3.0)) return RP_Message(playerid,"��������� ����� ������ ����� � ����.");
    if(action==0) format(q,sizeof q,"INSERT OR IGNORE INTO rp_keys(owner,guest) VALUES('%q','%q')",
        gName[playerid],gName[targetid]);
    else format(q,sizeof q,"DELETE FROM rp_keys WHERE owner='%q' AND guest='%q'",gName[playerid],gName[targetid]);
    if(!VX_SQL(q)) return VX_Error(playerid);
    if(action==0) RP_Message(targetid,"��� ������ ����� �� ������� ����������. ����� ��������� ������� ������ � ������� ���������.");
    else { RP_RevokeDrivers(playerid); RP_Message(targetid,"�������� ������� ���� �����."); }
    return RP_Message(playerid,"������ � ���������� ������� � ��������.");
}
stock RP_Engine(playerid)
{
    if(!RP_Free(playerid) || GetPlayerState(playerid)!=PLAYER_STATE_DRIVER)
        return RP_Message(playerid,"������� ������ �� ����.");
    new v=GetPlayerVehicleID(playerid),e,l,a,d,b,t,o,Float:hp;
    if(v<=0 || v>=MAX_VEHICLES || !GetVehicleModel(v)) return 1;
    GetVehicleParamsEx(v,e,l,a,d,b,t,o);
    if(e==VEHICLE_PARAMS_ON)
    {
        SetVehicleParamsEx(v,0,l,a,d,b,t,o);
        VX_Notify(playerid, "VEX DRIVE", "��������� ��������", VEX_HUD_WARNING);
        return RP_Message(playerid,"��������� ��������.");
    }
    if(!RP_HasKeys(playerid,v)) return RP_Message(playerid,"� ��� ��� ������ �� ���� ������.");
    if(gVehicleFuel[v]<=0) return RP_Message(playerid,"��� �������. /fuel �� ���.");
    GetVehicleHealth(v,hp);
    if(hp<350.0) return RP_Message(playerid,"��������� ������� ��������. ����� ������.");
    SetVehicleParamsEx(v,1,l,a,d,b,t,o); UpdateVexHud(playerid);
    VX_Notify(playerid, "VEX DRIVE", "��������� ������", VEX_HUD_ACCENT);
    return RP_Message(playerid,"��������� ������.");
}
stock RP_Lock(playerid)
{
    if(!RP_Free(playerid)) return RP_Message(playerid,"������ ������ ������������ �������.");
    new v=GetPlayerVehicleID(playerid);
    if(!v)
    {
        new Float:x,Float:y,Float:z,Float:distance,Float:best=6.0;
        for(new candidate=1;candidate<MAX_VEHICLES;candidate++)
        {
            if(!GetVehicleModel(candidate) || GetVehicleVirtualWorld(candidate)!=GetPlayerVirtualWorld(playerid)) continue;
            GetVehiclePos(candidate,x,y,z); distance=GetPlayerDistanceFromPoint(playerid,x,y,z);
            if(distance<=best && RP_HasKeys(playerid,candidate)) { v=candidate; best=distance; }
        }
    }
    if(v<=0 || v>=MAX_VEHICLES || !GetVehicleModel(v)
        || GetVehicleVirtualWorld(v)!=GetPlayerVirtualWorld(playerid)) return RP_Message(playerid,"������ �� ������� �����.");
    new Float:x,Float:y,Float:z; GetVehiclePos(v,x,y,z);
    if(!IsPlayerInRangeOfPoint(playerid,6.0,x,y,z)) return RP_Message(playerid,"��������� � ������ �� 6 ������.");
    if(!RP_HasKeys(playerid,v)) return RP_Message(playerid,"��� ������. �������� ����� ������ ��: /givekey ID.");
    new e,l,a,d,b,t,o; GetVehicleParamsEx(v,e,l,a,d,b,t,o);
    if(d==VEHICLE_PARAMS_ON) { SetVehicleParamsEx(v,e,l,a,0,b,t,o); RP_Message(playerid,"������ �������."); }
    else { SetVehicleParamsEx(v,e,l,a,1,b,t,o); RP_Message(playerid,"������ �������."); }
    return 1;
}
stock RP_SpawnCar(playerid)
{
    if(!RP_Free(playerid) || !gOwnedCarModel[playerid]) return RP_Message(playerid,"� ��� ��� ���������� ������� ����������.");
    if(GetPlayerInterior(playerid)!=0 || GetPlayerVirtualWorld(playerid)!=0
        || !IsPlayerInRangeOfPoint(playerid,35.0,2131.0,-1150.0,24.1) || IsPlayerInAnyVehicle(playerid))
        return RP_Message(playerid,"��������� ������ � ����������.");
    if(RP_VehicleOwner(gOwnedCarVehicle[playerid])==playerid) return RP_Message(playerid,"���� ������ ��� ��������� � ����.");
    new fee=0;
    if(gRPCarBroken[playerid])
    {
        fee=RP_RECOVER_PRICE;
        if(gRPCarInsured[playerid]>gettime()) fee=RP_INSURED_RECOVER_PRICE;
    }
    if(gMoney[playerid]<fee) return RP_Message(playerid,"��� �������������� ����� 5000 ���. ����������� �������� �� ���������: 1000 ���.");
    new Float:spawnX, Float:spawnY, Float:spawnZ, Float:spawnA;
    if (!VX_FindDealerSpawn(playerid, spawnX, spawnY, spawnZ, spawnA))
        return RP_Message(playerid,"��� ���������� ����� ��� ������. ��������� ������ � ����������� ��� ���.");
    new v=CreateVehicle(gOwnedCarModel[playerid],spawnX,spawnY,spawnZ,spawnA,1,1,300);
    if(v==INVALID_VEHICLE_ID || v==0) return RP_Message(playerid,"��� ��������� ������ ����������. ������ �� �������.");
    if(fee)
    {
        new Float:oldHealth=gRPCarHealth[playerid];
        if(!VX_Begin()) { DestroyVehicle(v); return VX_Error(playerid); }
        gRPCarBroken[playerid]=false; gRPCarHealth[playerid]=1000.0;
        RP_SaveCar(playerid,false);
        VX_MoneySQL(playerid,gMoney[playerid]-fee,gBankMoney[playerid]);
        if(!VX_Commit())
        {
            gRPCarBroken[playerid]=true; gRPCarHealth[playerid]=oldHealth;
            DestroyVehicle(v); return VX_Error(playerid);
        }
        VX_MoneySync(playerid,gMoney[playerid]-fee,gBankMoney[playerid]);
    }
    SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
    SetVehicleVirtualWorld(v, 0); LinkVehicleToInterior(v, 0);
    RP_ConfigCar(playerid,v); PutPlayerInVehicle(playerid,v,0);
    return RP_Message(playerid,"������ ������. /carinfo � ������, ��������� � ���������. /engine ��� N � ���������.");
}
stock RP_BuyCar(playerid,model,price)
{
    if(!RP_Free(playerid) || gMoney[playerid]<price || IsPlayerInAnyVehicle(playerid))
        return RP_Message(playerid,"������� ������ ���������� ��� �� ������� �����.");
    new oldVehicle=gOwnedCarVehicle[playerid];
    if(RP_VehicleOwner(oldVehicle)==playerid && IsFleetVehicleOccupied(oldVehicle))
        return RP_Message(playerid,"������� ���������� ���������� ������.");
    new Float:spawnX, Float:spawnY, Float:spawnZ, Float:spawnA;
    if (!VX_FindDealerSpawn(playerid, spawnX, spawnY, spawnZ, spawnA))
        return RP_Message(playerid,"��� ���������� ����� ��� ������. ��������� ������ � ���������� ��� ���.");
    new v=CreateVehicle(model,spawnX,spawnY,spawnZ,spawnA,1,1,300);
    if(v==INVALID_VEHICLE_ID || v==0) return RP_Message(playerid,"�� ������� ������� ������. ������ �� �������.");
    new q[320],plate[12];
    format(plate,sizeof plate,"VX%06d",gVXPhone[playerid]);
    if(!VX_Begin()) { DestroyVehicle(v); return VX_Error(playerid); }
    VX_MoneySQL(playerid,gMoney[playerid]-price,gBankMoney[playerid]);
    format(q,sizeof q,"UPDATE accounts SET ownedcar=%d WHERE name='%q'",model,gName[playerid]); VX_SQL(q);
    format(q,sizeof q,"INSERT OR REPLACE INTO rp_vehicles(owner,model,plate) VALUES('%q',%d,'%q')",
        gName[playerid],model,plate); VX_SQL(q);
    format(q,sizeof q,"DELETE FROM rp_keys WHERE owner='%q'",gName[playerid]); VX_SQL(q);
    if(!VX_Commit()) { DestroyVehicle(v); return VX_Error(playerid); }
    if(RP_VehicleOwner(oldVehicle)==playerid)
    { gPersonalVehicleOwner[oldVehicle]=INVALID_PLAYER_ID; DestroyVehicle(oldVehicle); }
    gOwnedCarModel[playerid]=model;
    gRPCarKm[playerid]=0.0; gRPCarHealth[playerid]=1000.0; gRPCarFuel[playerid]=100;
    gRPCarRegistered[playerid]=false; gRPCarBroken[playerid]=false;
    gRPCarInsured[playerid]=0; gRPCarInspected[playerid]=0;
    format(gRPCarPlate[playerid],12,"%s",plate);
    VX_MoneySync(playerid,gMoney[playerid]-price,gBankMoney[playerid]);
    SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
    SetVehicleVirtualWorld(v, 0); LinkVehicleToInterior(v, 0);
    RP_ConfigCar(playerid,v); PutPlayerInVehicle(playerid,v,0);
    return RP_Message(playerid,"���������� ������. ��������������� ��� � �����: /vreg. /carinfo � ���������.");
}
stock RP_CarInfo(playerid,owner)
{
    if(!VX_Valid(owner) || !gOwnedCarModel[owner]) return RP_Message(playerid,"������ ���������� �� ������.");
    if(owner!=playerid && !VX_Officer(playerid) && !VX_Admin(playerid))
        return RP_Message(playerid,"����� ��������� �������� �������/FBI � �������������.");
    RP_SaveCar(owner);
    new body[640],plate[24],insured[40],inspected[40],status[48];
    if(gRPCarRegistered[owner]) format(plate,sizeof plate,"%s",gRPCarPlate[owner]);
    else format(plate,sizeof plate,"�� ���������������");
    if(gRPCarInsured[owner]>gettime()) format(insured,sizeof insured,"��� %d �.",(gRPCarInsured[owner]-gettime()+3599)/3600);
    else format(insured,sizeof insured,"��� / �������");
    if(gRPCarInspected[owner]>gettime()) format(inspected,sizeof inspected,"��� %d �.",(gRPCarInspected[owner]-gettime()+3599)/3600);
    else format(inspected,sizeof inspected,"��� / ����");
    if(gRPCarBroken[owner]) format(status,sizeof status,"���������: /mycar ��� �������");
    else format(status,sizeof status,"� ������������");
    format(body,sizeof body,
        "��������: %s\n������: %d\n�����: %s\n������: %.2f ��\n���������: %.0f / 1000\n�������: %d �.\n���������: %s\n���������: %s\n������: %s",
        gName[owner],gOwnedCarModel[owner],plate,gRPCarKm[owner],gRPCarHealth[owner],
        gRPCarFuel[owner],insured,inspected,status);
    return VX_Show(playerid,VX_LOG,DIALOG_STYLE_MSGBOX,"VEXORIUM | ��������� ����������",body,"OK","�������");
}
stock RP_CarDocument(playerid,action)
{
    if(!RP_Free(playerid) || !gOwnedCarModel[playerid] || gRPCarBroken[playerid])
        return RP_Message(playerid,"����� ������ ����������, �� ������������.");
    new fee=0,oldIns=gRPCarInsured[playerid],oldCheck=gRPCarInspected[playerid];
    new bool:oldReg=gRPCarRegistered[playerid];
    if(action<2)
    {
        if(GetPlayerInterior(playerid)!=3 || GetPlayerVirtualWorld(playerid)!=101
            || !IsPlayerInRangeOfPoint(playerid,12.0,362.4587,174.0056,1008.3828))
            return RP_Message(playerid,"��������� ����������� � ������ �������� � �����.");
        if(!gHasPassport[playerid]) return RP_Message(playerid,"������� �������� �������.");
        if(action==0)
        {
            if(gRPCarRegistered[playerid]) return RP_Message(playerid,"���������� ��� ���������������.");
            fee=RP_REGISTER_PRICE;
        }
        else
        {
            if(!gRPCarRegistered[playerid]) return RP_Message(playerid,"������� ��������������� ����������: /vreg.");
            if(gRPCarInsured[playerid]>gettime()) return RP_Message(playerid,"��������� ��� ���������.");
            fee=RP_INSURE_PRICE;
        }
    }
    else
    {
        new v=gOwnedCarVehicle[playerid],Float:hp;
        if(!gRPCarRegistered[playerid] || RP_VehicleOwner(v)!=playerid || GetPlayerVehicleID(playerid)!=v
            || GetPlayerInterior(playerid)!=0 || GetPlayerVirtualWorld(playerid)!=0
            || !IsPlayerInRangeOfPoint(playerid,18.0,1940.0,-1772.0,13.4))
            return RP_Message(playerid,"��������� ������������������ ������ ������ � �����������: /biz 3.");
        GetVehicleHealth(v,hp);
        if(hp<900.0) return RP_Message(playerid,"��� ���������� �������������� ������ �� ��������� 900/1000.");
        if(gRPCarInspected[playerid]>gettime()) return RP_Message(playerid,"��������� ��� ���������.");
        fee=RP_INSPECT_PRICE;
    }
    if(gMoney[playerid]<fee) return RP_Message(playerid,"������������ ��������. ����������� 2500, ��������� 2000, ��������� 1000 ���.");
    if(!VX_Begin()) return VX_Error(playerid);
    if(action==0) gRPCarRegistered[playerid]=true;
    if(action==1) gRPCarInsured[playerid]=gettime()+RP_INSURE_DAYS*86400;
    if(action==2) gRPCarInspected[playerid]=gettime()+RP_INSPECT_DAYS*86400;
    RP_SaveCar(playerid);
    VX_MoneySQL(playerid,gMoney[playerid]-fee,gBankMoney[playerid]);
    if(!VX_Commit())
    {
        gRPCarRegistered[playerid]=oldReg; gRPCarInsured[playerid]=oldIns; gRPCarInspected[playerid]=oldCheck;
        return VX_Error(playerid);
    }
    VX_MoneySync(playerid,gMoney[playerid]-fee,gBankMoney[playerid]);
    if(action==0 && RP_VehicleOwner(gOwnedCarVehicle[playerid])==playerid)
        SetVehicleNumberPlate(gOwnedCarVehicle[playerid],gRPCarPlate[playerid]);
    RP_Message(playerid,"�������� ��������. ����� �� ������ ��������� ����� ��������� �������� ������ � �������.");
    return RP_CarInfo(playerid,playerid);
}
stock RP_OnCarDeath(vehicleid)
{
    new owner=RP_VehicleOwner(vehicleid);
    if(owner==INVALID_PLAYER_ID) return 0;
    gRPCarBroken[owner]=true; gRPCarHealth[owner]=250.0;
    gRPCarFuel[owner]=VexHudClamp(gVehicleFuel[vehicleid],0,100);
    RP_SaveCar(owner,false);
    gPersonalVehicleOwner[vehicleid]=INVALID_PLAYER_ID;
    gOwnedCarVehicle[owner]=INVALID_VEHICLE_ID; gRPCarPosKnown[owner]=false;
    DestroyVehicle(vehicleid);
    RP_Message(owner,"���������� ���������. /mycar � ����������: ������ 5000 ���., �� ���������� 1000 ���.");
    return 1;
}
public OnVehicleSpawn(vehicleid)
{
    if(VX_IsDisplayFleetVehicle(vehicleid)) return VX_ResetDisplayFleet(vehicleid);
    new owner=RP_VehicleOwner(vehicleid);
    if(owner!=INVALID_PLAYER_ID) RP_ConfigCar(owner,vehicleid);
    return 1;
}

stock RP_PutInCar(playerid,targetid)
{
    if(!RP_Free(playerid) || !VX_Officer(playerid) || gFactionRank[playerid]<2)
        return RP_Message(playerid,"�������� �������/FBI �� 2 �����.");
    if(!RP_Living(targetid) || !gHandcuffed[targetid] || !VX_Near(playerid,targetid,4.0)
        || IsPlayerInAnyVehicle(targetid)) return RP_Message(playerid,"����������� � ���������� ������ ���� ����� � ��� ����������.");
    new v=gFactionVehicle[playerid];
    if(v<=0 || v>=MAX_VEHICLES || !GetVehicleModel(v) || gFactionVehicleOwner[v]!=playerid
        || GetVehicleVirtualWorld(v)!=GetPlayerVirtualWorld(playerid))
        return RP_Message(playerid,"�������� ��������� ��������� � ���� ������.");
    new Float:x,Float:y,Float:z; GetVehiclePos(v,x,y,z);
    if(!IsPlayerInRangeOfPoint(playerid,6.0,x,y,z)) return RP_Message(playerid,"��������� ��������� ��������� �����.");
    new seats=1,model=GetVehicleModel(v),seat=-1;
    if(model==490 || (model>=596 && model<=599) || model==560 || model==445 || model==426) seats=3;
    for(new s=1;s<=seats;s++)
    {
        new occupied=0;
        for(new p=0;p<MAX_PLAYERS;p++)
            if(IsPlayerConnected(p) && IsPlayerInVehicle(p,v) && GetPlayerVehicleSeat(p)==s) occupied=1;
        if(!occupied) { seat=s; break; }
    }
    if(seat<0) return RP_Message(playerid,"��� ���������� ������������� �����.");
    TogglePlayerControllable(targetid,true);
    if(!PutPlayerInVehicle(targetid,v,seat))
    {
        TogglePlayerControllable(targetid,false);
        return RP_Message(playerid,"�� ������� �������� ������������.");
    }
    TogglePlayerControllable(targetid,false);
    RP_Audit(targetid,playerid,"TRANSPORT","Suspect placed in service vehicle");
    return RP_Message(playerid,"����������� � ��������� ������. ��������� ��� � ������ ��� � �������.");
}

stock RP_PullOut(playerid,targetid)
{
    if(!RP_Free(playerid) || !VX_Officer(playerid) || gFactionRank[playerid]<2
        || IsPlayerInAnyVehicle(playerid))
        return RP_Message(playerid,"������� �� ����������. ������: �������/FBI �� 2 �����.");
    if(!RP_Living(targetid) || !gHandcuffed[targetid] || !IsPlayerInAnyVehicle(targetid)
        || !VX_Near(playerid,targetid,6.0))
        return RP_Message(playerid,"����� ����������� � ���������� � ������ �����.");
    new Float:x,Float:y,Float:z;
    GetPlayerPos(playerid,x,y,z);
    TogglePlayerControllable(targetid,true);
    RemovePlayerFromVehicle(targetid);
    SetPlayerPos(targetid,x+1.0,y,z);
    ClearAnimations(targetid); SetPlayerSpecialAction(targetid,24);
    TogglePlayerControllable(targetid,false);
    RP_Audit(targetid,playerid,"TRANSPORT","Suspect removed from vehicle");
    return RP_Message(playerid,"����������� ������� �� ������. /uncuff ID - ����� ���������.");
}

stock RP_Help(playerid)
{
    new body[2400];
    strcat(body,"����: /medcert - ���������� (����)\n/ward - ������ (������ ����������)\n/lobby - ����� � ����\n/bed - ���� �� �����\n/exit - ����� �� ��������\n/hospitalinfo - �������\n\n",sizeof body);
    strcat(body,"������� / FBI\n",sizeof body);
    strcat(body,"/tablet /case ID /camlogs /vcheck ID\n/cuff ID /uncuff ID /search ID\n",sizeof body);
    strcat(body,"/seize ID weapons|lockpicks �������\n/ticket ID ����� ������� /fines /payfine �����\n",sizeof body);
    strcat(body,"/wanted ID 0-6 ������� /putincar ID /pullout ID\n/arrest ID ������� ������� (60-1800)\n\n",sizeof body);
    strcat(body,"����\n/health /diagnose ID /medcard [ID]\n/bandage ID /splint ID /heal ID /operation ID\n",sizeof body);
    strcat(body,"/stretcher ID /unstretcher /loadpatient ID /hospitalize ID\n/medrefuse � ���������� �� �������\n\n",sizeof body);
    strcat(body,"����������\n/carinfo /mycar /engine /lock\n/givekey ID /revokekey ID /resetkeys\n",sizeof body);
    strcat(body,"/vreg � 2500 ���., �����\n/insurance � 2000 ���., 7 ����, �����\n/inspection � 1000 ���., 3 ���, ����������\n\n",sizeof body);
    strcat(body,"������ � �������\n/prison � ������� /prisonenter /prisonexit\n/jailinfo /clients /defend ID\n",sizeof body);
    strcat(body,"/acceptlawyer /declinelawyer\n/job � ������ �������� (�������, 3 �������, ��� �������)\n\n",sizeof body);
    strcat(body,"�������������\n/jail ID ������� � 30 ����� RP-������\n/jailtime ID ������ ������� (1-120)\n/unjail ID\n",sizeof body);
    strcat(body,"\n��� ����� � ����������: 20 ������. /b � ��������� OOC.\n",sizeof body);
    return VX_Show(playerid,VX_LOG,DIALOG_STYLE_MSGBOX,"VEXORIUM | RP-����������",body,"OK","�������");
}
stock RP_Command(playerid,const cmdtext[])
{
    new cmd[32],params[192],a[32],b[32],tail[192],reason[160],n=-1,n2=-1;
    GetToken(cmdtext,0,cmd,sizeof cmd); GetParams(cmdtext,params,sizeof params);
    GetToken(params,0,a,sizeof a); GetToken(params,1,b,sizeof b);
    GetParams(params,tail,sizeof tail); GetParams(tail,reason,sizeof reason);
    if(!VX_Number(a,n)) n=-1;
    if(!VX_Number(b,n2)) n2=-1;
    // RP animations: these do not override mandatory hospital treatment.
    if(!strcmp(cmd,"/anim",true) || !strcmp(cmd,"/animations",true))
    {
        SendClientMessage(playerid,COLOR_BLUE,"[RP] /sit /wave /salute /lean /dance /smoke /talk /handsup /stopanim");
        return 1;
    }
    if(!strcmp(cmd,"/stopanim",true))
    {
        if(gVXBed[playerid]>=0 || gRPStretcherBy[playerid]!=INVALID_PLAYER_ID || gHandcuffed[playerid] || gTaserStunned[playerid] || gIsJailed[playerid])
            return RP_Message(playerid,"������ ������ ��������� ��������.");
        ClearAnimations(playerid);
        SetPlayerSpecialAction(playerid,SPECIAL_ACTION_NONE);
        return 1;
    }
    if(!strcmp(cmd,"/sit",true) || !strcmp(cmd,"/wave",true) || !strcmp(cmd,"/salute",true)
        || !strcmp(cmd,"/lean",true) || !strcmp(cmd,"/dance",true) || !strcmp(cmd,"/smoke",true)
        || !strcmp(cmd,"/talk",true))
    {
        if(gVXBed[playerid]>=0 || gVXHospital[playerid] || gIsJailed[playerid] || gHandcuffed[playerid]
            || gTaserStunned[playerid] || gRPStretcherBy[playerid]!=INVALID_PLAYER_ID
            || IsPlayerInAnyVehicle(playerid) || GetPlayerState(playerid)!=PLAYER_STATE_ONFOOT)
            return RP_Message(playerid,"��� �������� ������ ����������.");
        ClearAnimations(playerid);
        if(!strcmp(cmd,"/sit",true)) ApplyAnimation(playerid,"PED","SEAT_down",4.1,0,0,0,1,0,1);
        else if(!strcmp(cmd,"/wave",true)) ApplyAnimation(playerid,"ON_LOOKERS","wave_loop",4.1,0,0,0,0,0,1);
        else if(!strcmp(cmd,"/salute",true)) ApplyAnimation(playerid,"ON_LOOKERS","Pointup_loop",4.1,0,0,0,0,0,1);
        else if(!strcmp(cmd,"/lean",true)) ApplyAnimation(playerid,"GANGS","leanIDLE",4.1,1,0,0,0,0,1);
        else if(!strcmp(cmd,"/dance",true)) ApplyAnimation(playerid,"DANCING","dnce_M_a",4.1,1,0,0,0,0,1);
        else if(!strcmp(cmd,"/smoke",true)) ApplyAnimation(playerid,"SMOKING","M_smkstnd_loop",4.1,1,0,0,0,0,1);
        else ApplyAnimation(playerid,"PED","IDLE_CHAT",4.1,1,0,0,0,0,1);
        SendClientMessage(playerid,COLOR_GREEN,"[RP] �������� ��������. ����������: /stopanim.");
        return 1;
    }
    if(!strcmp(cmd,"/hospitalinfo",true)) return VX_WardInfo(playerid);
    if(!strcmp(cmd,"/hospitexit",true)) return VX_HospitalExit(playerid);
    if(!strcmp(cmd,"/exit",true) && GetPlayerVirtualWorld(playerid)==VX_HOSPITAL_WORLD)
        return VX_HospitalExit(playerid);
    if(!strcmp(cmd,"/rphelp",true)) return RP_Help(playerid);
    if(!strcmp(cmd,"/jail",true))
    {
        if(gAdmin[playerid]<2) return RP_Message(playerid,"/jail �������� �� 2 ������ �������������.");
        return RP_StartJail(playerid,n,RP_JAIL_DEFAULT,tail,1);
    }
    if(!strcmp(cmd,"/jailtime",true))
    {
        if(gAdmin[playerid]<2) return RP_Message(playerid,"/jailtime �������� �� 2 ������ �������������.");
        if(n2<1 || n2>120) return RP_Message(playerid,"/jailtime ID ������(1-120) �������.");
        return RP_StartJail(playerid,n,n2*60,reason,1);
    }
    if(!strcmp(cmd,"/arrest",true)) return RP_StartJail(playerid,n,n2,reason,2);
    if(!strcmp(cmd,"/unjail",true) || !strcmp(cmd,"/release",true))
    {
        if(!VX_Valid(n) || !gIsJailed[n]) return RP_Message(playerid,"����� �� �������� ����.");
        if(!VX_Admin(playerid))
        {
            if(!strcmp(cmd,"/unjail",true) || !RP_Free(playerid) || !VX_Officer(playerid)
                || gFactionRank[playerid]<5 || gRPJailSource[n]==1)
                return RP_Message(playerid,"����� �������������. ����� ����������� ����� ����� ����� �������/FBI � 5 �����.");
        }
        if(!RP_Release(n,playerid,"Early release")) return VX_Error(playerid);
        return RP_Message(playerid,"����� ���������; �������� �������� � ������.");
    }
    if(!strcmp(cmd,"/jailinfo",true)) return RP_JailInfo(playerid);
    if(!strcmp(cmd,"/prison",true))
    {
        if(gWorkStage[playerid] || gDrivingTestStage[playerid]) return RP_Message(playerid,"������� ��������� ������� �������.");
        SetPlayerCheckpoint(playerid,RP_PRISON_X,RP_PRISON_Y-6.5,RP_PRISON_Z,4.0); gGpsActive[playerid]=true;
        return RP_Message(playerid,"������ �������� �� �����. ������ ��������� ������� ��������.");
    }
    if(!strcmp(cmd,"/prisonenter",true)) return RP_PrisonEnter(playerid);
    if(!strcmp(cmd,"/prisonexit",true)) return RP_PrisonExit(playerid);
    if(!strcmp(cmd,"/clients",true)) return RP_Clients(playerid);
    if(!strcmp(cmd,"/defend",true)) return RP_LawOffer(playerid,n);
    if(!strcmp(cmd,"/acceptlawyer",true)) return RP_LawAccept(playerid);
    if(!strcmp(cmd,"/declinelawyer",true))
    { gRPLawOffer[playerid]=INVALID_PLAYER_ID; return RP_Message(playerid,"����������� �������� ���������."); }
    if(!strcmp(cmd,"/lawyer",true) || ((!strcmp(cmd,"/work",true) || !strcmp(cmd,"/��������",true)) && gJob[playerid]==RP_LAWYER_JOB))
        return RP_Message(playerid,"�������: /clients, ������� /prison, /defend ID. ������� 1000 ���.; ���������� ���� ��� �� 20%.");
    if(!strcmp(cmd,"/handsup",true))
    {
        if(!RP_Free(playerid) || IsPlayerInAnyVehicle(playerid)) return RP_Message(playerid,"������� ������� �� ����������.");
        SetPlayerSpecialAction(playerid,SPECIAL_ACTION_HANDSUP); return 1;
    }
    if(!strcmp(cmd,"/handsdown",true))
    { if(RP_Free(playerid)) SetPlayerSpecialAction(playerid,SPECIAL_ACTION_NONE); return 1; }
    if(!strcmp(cmd,"/cuff",true)) return RP_Cuff(playerid,n,false);
    if(!strcmp(cmd,"/uncuff",true)) return RP_Cuff(playerid,n,true);
    if(!strcmp(cmd,"/search",true) || !strcmp(cmd,"/obysk",true)) return RP_Search(playerid,n);
    if(!strcmp(cmd,"/seize",true)) return RP_Seize(playerid,n,b,reason);
    if(!strcmp(cmd,"/wanted",true)) return RP_Wanted(playerid,n,n2,reason);
    if(!strcmp(cmd,"/clearwanted",true)) return RP_Wanted(playerid,n,0,tail);
    if(!strcmp(cmd,"/ticket",true) || !strcmp(cmd,"/fine",true)) return RP_Ticket(playerid,n,n2,reason);
    if(!strcmp(cmd,"/fines",true))
    { if(!strlen(params)) n=playerid; return RP_Fines(playerid,n); }
    if(!strcmp(cmd,"/payfine",true)) return RP_PayFine(playerid,n);
    if(!strcmp(cmd,"/case",true)) return RP_History(playerid,n,false);
    if(!strcmp(cmd,"/camlogs",true)) return RP_CameraLogs(playerid);
    if(!strcmp(cmd,"/putincar",true) || !strcmp(cmd,"/loadsuspect",true)) return RP_PutInCar(playerid,n);
    if(!strcmp(cmd,"/pullout",true) || !strcmp(cmd,"/eject",true)) return RP_PullOut(playerid,n);
    if(!strcmp(cmd,"/health",true)) return RP_Diagnose(playerid,playerid);
    if(!strcmp(cmd,"/diagnose",true)) return RP_Diagnose(playerid,n);
    if(!strcmp(cmd,"/medcard",true))
    { if(!strlen(params)) n=playerid; return RP_History(playerid,n,true); }
    if(!strcmp(cmd,"/bandage",true)) return RP_MedTreat(playerid,n,0);
    if(!strcmp(cmd,"/splint",true)) return RP_MedTreat(playerid,n,1);
    if(!strcmp(cmd,"/heal",true)) return RP_MedTreat(playerid,n,2);
    if(!strcmp(cmd,"/operation",true)) return RP_MedTreat(playerid,n,3);
    if(!strcmp(cmd,"/stretcher",true)) return RP_Stretcher(playerid,n);
    if(!strcmp(cmd,"/unstretcher",true))
    {
        for(new p=0;p<MAX_PLAYERS;p++) if(gRPStretcherBy[p]==playerid) RP_DropStretcher(p);
        return RP_Message(playerid,"������� ������.");
    }
    if(!strcmp(cmd,"/medrefuse",true))
    {
        RP_DropStretcher(playerid);
        return RP_Message(playerid,"��������� ����������. ������������ ������� ����� ������ �� ����������.");
    }
    if(!strcmp(cmd,"/loadpatient",true)) return RP_LoadPatient(playerid,n);
    if(!strcmp(cmd,"/hospitalize",true)) return RP_Hospitalize(playerid,n);
    if(!strcmp(cmd,"/carinfo",true)) return RP_CarInfo(playerid,playerid);
    if(!strcmp(cmd,"/vcheck",true)) return RP_CarInfo(playerid,n);
    if(!strcmp(cmd,"/vreg",true)) return RP_CarDocument(playerid,0);
    if(!strcmp(cmd,"/insurance",true)) return RP_CarDocument(playerid,1);
    if(!strcmp(cmd,"/inspection",true)) return RP_CarDocument(playerid,2);
    if(!strcmp(cmd,"/givekey",true)) return RP_Key(playerid,n,0);
    if(!strcmp(cmd,"/revokekey",true)) return RP_Key(playerid,n,1);
    if(!strcmp(cmd,"/resetkeys",true)) return RP_Key(playerid,n,2);
    if(!strcmp(cmd,"/engine",true)) return RP_Engine(playerid);
    if(!strcmp(cmd,"/lock",true) || !strcmp(cmd,"/carlock",true)) return RP_Lock(playerid);
    if(!strcmp(cmd,"/mycar",true)) return RP_SpawnCar(playerid);
    return 0;
}
// ================= Lifecycle and one-second processing =================
stock RP_Disconnect(playerid)
{
    if(gRPLoaded[playerid]) { RP_SaveState(playerid); RP_SaveCar(playerid); }
    RP_DropStretcher(playerid);
    gRPOpDoctor[playerid]=INVALID_PLAYER_ID; gRPOpUntil[playerid]=0;
    for(new p=0;p<MAX_PLAYERS;p++)
    {
        if(gRPStretcherBy[p]==playerid) RP_DropStretcher(p);
        if(gRPOpDoctor[p]==playerid)
        { gRPOpDoctor[p]=INVALID_PLAYER_ID; gRPOpUntil[p]=0; }
        if(gRPLawOffer[p]==playerid) gRPLawOffer[p]=INVALID_PLAYER_ID;
    }
    return 1;
}
stock RP_CarTick(playerid)
{
    new v=gOwnedCarVehicle[playerid];
    if(RP_VehicleOwner(v)!=playerid || gRPCarBroken[playerid]) return 0;
    new Float:x,Float:y,Float:z,Float:hp,e,l,a,d,b,t,o;
    GetVehiclePos(v,x,y,z); GetVehicleParamsEx(v,e,l,a,d,b,t,o); GetVehicleHealth(v,hp);
    if(gRPCarPosKnown[playerid] && e==VEHICLE_PARAMS_ON)
    {
        new Float:dx=x-gRPCarLastPos[playerid][0],Float:dy=y-gRPCarLastPos[playerid][1];
        new Float:dz=z-gRPCarLastPos[playerid][2];
        new Float:distance=floatsqroot(dx*dx+dy*dy+dz*dz);
        // Ignore teleports. Mileage measures motion while the engine is running.
        if(distance>0.1 && distance<=120.0)
        {
            gRPCarKm[playerid]+=distance/1000.0;
            if(hp>350.0)
            {
                hp-=distance/3000.0;
                if(hp<350.0) hp=350.0;
                SetVehicleHealth(v,hp);
            }
        }
    }
    gRPCarLastPos[playerid][0]=x; gRPCarLastPos[playerid][1]=y; gRPCarLastPos[playerid][2]=z;
    gRPCarPosKnown[playerid]=true; gRPCarHealth[playerid]=hp;
    gRPCarFuel[playerid]=VexHudClamp(gVehicleFuel[v],0,100);
    return 1;
}
stock RP_CameraTick(playerid,now)
{
    if(!RP_Free(playerid) || GetPlayerState(playerid)!=PLAYER_STATE_DRIVER
        || GetPlayerInterior(playerid)!=0 || GetPlayerVirtualWorld(playerid)!=0) return 0;
    new v=GetPlayerVehicleID(playerid),Float:x,Float:y,Float:z;
    if(v<=0 || v>=MAX_VEHICLES) return 0;
    GetVehicleVelocity(v,x,y,z);
    new speed=floatround(floatsqroot(x*x+y*y+z*z)*180.0);
    for(new c=0;c<RP_CAMERA_COUNT;c++)
    {
        if(now<gRPNextCamera[playerid][c] || speed<=gRPCameraLimit[c]+10) continue;
        if(!IsPlayerInRangeOfPoint(playerid,40.0,gRPCameras[c][0],gRPCameras[c][1],gRPCameras[c][2])) continue;
        new plate[24],owner=RP_VehicleOwner(v),detail[144];
        if(owner!=INVALID_PLAYER_ID && gRPCarRegistered[owner]) format(plate,sizeof plate,"%s",gRPCarPlate[owner]);
        else format(plate,sizeof plate,"NO REGISTRATION");
        format(detail,sizeof detail,"Camera %d | %s | model %d | %d km/h, limit %d",
            c+1,plate,GetVehicleModel(v),speed,gRPCameraLimit[c]);
        if(RP_Audit(playerid,INVALID_PLAYER_ID,"CAMERA",detail))
            RP_Message(playerid,"������ ������������� ���������� ��������. ������ �������� �������/FBI.");
        gRPNextCamera[playerid][c]=now+120;
    }
    return 1;
}
stock RP_Tick(elapsed,now)
{
    for(new p=0;p<MAX_PLAYERS;p++)
    {
        if(!VX_Valid(p) || !gRPLoaded[p]) continue;
        if(gIsJailed[p])
        {
            if(RP_Living(p))
            {
                if(GetPlayerInterior(p)!=6 || GetPlayerVirtualWorld(p)!=RP_JAIL_WORLD
                    || !IsPlayerInRangeOfPoint(p,6.0,264.4,77.5,1001.0)) RP_JailPosition(p);
                ResetPlayerWeapons(p);
                gRPJailLeft[p]=max(0,gRPJailLeft[p]-elapsed);
            }
            if(gRPJailLeft[p]<=0) RP_Release(p,INVALID_PLAYER_ID,"Sentence served");
        }
        if(gTaserStunned[p] && gRPTaserUntil[p]>0 && now<gRPTaserUntil[p] && !IsPlayerInAnyVehicle(p))
        {
            ApplyAnimation(p,"CRACK","crckdeth2",4.1,1,0,0,1,10000,1);
        }
        if(gTaserStunned[p] && gRPTaserUntil[p]>0 && now>=gRPTaserUntil[p])
        {
            gRPTaserUntil[p]=0; gTaserStunned[p]=false; SetPlayerDrunkLevel(p,0);
            if(!gHandcuffed[p] && gVXBed[p]<0 && gRPStretcherBy[p]==INVALID_PLAYER_ID)
            { ClearAnimations(p); TogglePlayerControllable(p,true); }
        }
        if(gRPLawOffer[p]!=INVALID_PLAYER_ID && now>gRPLawUntil[p]) gRPLawOffer[p]=INVALID_PLAYER_ID;
        if(RP_Free(p) && !IsPlayerInGreenZone(p))
        {
            if((gRPInjury[p] & RP_INJ_BLEED) && now>=gRPBleedAt[p])
            {
                new Float:hp; GetPlayerHealth(p,hp);
                if(hp>5.0) { hp-=2.0; if(hp<5.0) hp=5.0; }
                SetPlayerHealth(p,hp); gRPBleedAt[p]=now+15;
            }
        }
        new doctor=gRPStretcherBy[p];
        if(doctor!=INVALID_PLAYER_ID)
        {
            if(!RP_Free(doctor) || !VX_Medic(doctor) || IsPlayerInAnyVehicle(doctor)
                || !RP_Living(p) || !VX_Near(doctor,p,8.0)) RP_DropStretcher(p);
            else
            {
                new Float:x,Float:y,Float:z;
                GetPlayerPos(doctor,x,y,z);
                SetObjectPos(gRPStretcherObject[p],x+1.2,y,z-1.0);
                SetPlayerPos(p,x+1.2,y,z+0.1); TogglePlayerControllable(p,false);
            }
        }
        doctor=gRPOpDoctor[p];
        if(doctor!=INVALID_PLAYER_ID)
        {
            if(!RP_Free(doctor) || !VX_Medic(doctor) || gVXSession[doctor]!=gRPOpSession[p]
                || !gVXHospital[p] || gVXBed[p]<0 || !VX_Near(doctor,p,4.0))
            {
                gRPOpDoctor[p]=INVALID_PLAYER_ID; gRPOpUntil[p]=0;
                RP_Message(p,"�������� ��������: ���� ������ ��� �������� ���� ��������.");
            }
            else if(now>=gRPOpUntil[p] && RP_MedFinish(doctor,p,0,"�������� ���������"))
            {
                gRPOpDoctor[p]=INVALID_PLAYER_ID; gRPOpUntil[p]=0;
                gVXTreatment[p]=min(gVXTreatment[p],10); VX_Save(p);
                RP_Message(doctor,"�������� ��������� � �������� � ��������.");
                RP_Message(p,"�������� ���������. �� ��������� ���������� �������� �� ������ 10 ������.");
            }
        }
        RP_CarTick(p); RP_CameraTick(p,now);
        if(now>=gRPNextSave) { RP_SaveState(p); RP_SaveCar(p); }
    }
    if(now>=gRPNextSave) gRPNextSave=now+10;
    return 1;
}


// ================= Finished BCRB ward and reliable exits =================
stock VX_BuildWard()
{
    // Floor top is ~1000; standing player Z is 1001. Native 19379 floor/roof tiles.
    // A closed shell with a central aisle, two bed rows, staff desk and a south exit.
    for(new x=0;x<4;x++) for(new y=0;y<3;y++)
    {
        CreateObject(19379,1985.0+x*10.5,1988.0+y*9.6,999.9,0.0,90.0,0.0,100.0);
        CreateObject(19379,1985.0+x*10.5,1988.0+y*9.6,1003.6,0.0,90.0,0.0,100.0);
    }
    // 19355 panels are ~3.5 m high. A slight overlap prevents seams.
    for(new x=0;x<14;x++)
    {
        new Float:wallX=1981.25+x*3.0;
        CreateObject(19355,wallX,1983.25,1001.75,0.0,0.0,90.0,100.0);
        CreateObject(19355,wallX,2012.0,1001.75,0.0,0.0,90.0,100.0);
    }
    for(new y=0;y<10;y++)
    {
        new Float:wallY=1984.6+y*2.9;
        CreateObject(19355,1979.8,wallY,1001.75,0.0,0.0,0.0,100.0);
        CreateObject(19355,2021.7,wallY,1001.75,0.0,0.0,0.0,100.0);
    }
    for(new bed=0;bed<VX_BEDS;bed++)
    {
        gVXBedOwner[bed]=INVALID_PLAYER_ID;
        gVXBedObject[bed]=CreateObject(1997,gVXBedPos[bed][0],gVXBedPos[bed][1],1000.0,0.0,0.0,0.0,80.0);
        gVXBedPickup[bed]=CreatePickup(1239,1,gVXBedPos[bed][0]+1.5,gVXBedPos[bed][1],1001.0,VX_HOSPITAL_WORLD);
        gVXBedLabel[bed]=Create3DTextLabel("����",COLOR_WHITE,gVXBedPos[bed][0],gVXBedPos[bed][1],1002.0,15.0,VX_HOSPITAL_WORLD,0);
        VX_UpdateBedLabel(bed);
        CreateObject(2146,gVXBedPos[bed][0]-1.5,gVXBedPos[bed][1],1000.0,0.0,0.0,0.0,80.0);
    }
    // The ward has a staffed return door. Patients must finish treatment first.
    CreateObject(1491,2018.5,1996.0,1000.0,0.0,0.0,90.0,80.0);
    CreateObject(2165,2005.0,1994.0,1000.0,0.0,0.0,180.0,80.0);
    CreateObject(1720,2005.0,1995.5,1000.0,0.0,0.0,180.0,80.0);
    for(new c=0;c<4;c++) CreateObject(1720,2017.0,1994.0+c*1.5,1000.0,0.0,0.0,90.0,80.0);
    CreateObject(1808,2018.0,2002.0,1000.0,0.0,0.0,90.0,80.0);
    Create3DTextLabel("{33CC66}� ���� ����\n{FFFFFF}/lobby ��� ALT � �����",COLOR_GREEN,
        VX_WARD_LOBBY_X,VX_WARD_LOBBY_Y,1002.0,16.0,VX_HOSPITAL_WORLD,0);
    Create3DTextLabel("{66CCFF}���� | ���������\n{FFFFFF}/bed - ������ �����\n/exit - ����� ����� �������",COLOR_WHITE,
        VX_WARD_X,1998.5,1002.5,28.0,VX_HOSPITAL_WORLD,0);
    Create3DTextLabel("{66CCFF}���� ���������\n{FFFFFF}/hospitalinfo",COLOR_WHITE,
        2005.0,1994.0,1002.0,12.0,VX_HOSPITAL_WORLD,0);
    Create3DTextLabel("{66CCFF}���� ������������\n/mduty /mcalls /rphelp",COLOR_WHITE,
        2005.0,1997.0,1002.2,12.0,VX_HOSPITAL_WORLD,0);
    // Separate modelled reception and waiting room, same hospital virtual world.
    // Each 19379 tile is 10.5 by 9.6 metres; no empty floor below the player.
    for(new ix=0;ix<3;ix++)for(new iy=0;iy<2;iy++)
    {
        CreateObject(19379,2048.0+ix*10.5,1992.0+iy*9.6,999.9,0.0,90.0,0.0,100.0);
        CreateObject(19379,2048.0+ix*10.5,1992.0+iy*9.6,1003.6,0.0,90.0,0.0,100.0);
    }
    for(new w=0;w<11;w++)
    {
        new Float:wx=2043.5+w*3.0;
        CreateObject(19355,wx,1987.2,1001.75,0.0,0.0,90.0,100.0);
        CreateObject(19355,wx,2006.35,1001.75,0.0,0.0,90.0,100.0);
    }
    for(new w=0;w<7;w++)
    {
        new Float:wy=1988.2+w*2.9;
        CreateObject(19355,2042.75,wy,1001.75,0.0,0.0,0.0,100.0);
        CreateObject(19355,2074.25,wy,1001.75,0.0,0.0,0.0,100.0);
    }
    // Reception desk and office furnishing.
    CreateObject(2165,2054.0,2002.1,1000.0,0.0,0.0,180.0,80.0);
    CreateObject(2190,2053.0,2001.9,1000.95,0.0,0.0,140.0,80.0);
    CreateObject(1720,2054.0,2003.5,1000.0,0.0,0.0,180.0,80.0);
    CreateObject(1808,2069.8,2003.8,1000.0,0.0,0.0,180.0,80.0);
    CreateObject(638,2047.0,2003.9,1000.0,0.0,0.0,90.0,80.0);
    for(new chair=0;chair<6;chair++)
        CreateObject(1720,2046.8+chair*2.1,1998.0,1000.0,0.0,0.0,90.0,80.0);
    // BCRB decorative upgrade: wall finishes, examination area and waiting room.
    // All furniture is inside the existing hospital virtual world.
    // A central passage (Y=1994..1997) remains clear for navigation.
    for(new panel=0;panel<8;panel++)
    {
        // Decorative wall strips, mounted slightly in front of the original shell.
        CreateObject(19355,2045.0+panel*3.45,1987.45,1001.7,0.0,0.0,90.0,80.0);
        CreateObject(19355,2045.0+panel*3.45,2006.05,1001.7,0.0,0.0,90.0,80.0);
    }
    // Reception: filing cabinets, computer, counter and visitor seating.
    CreateObject(2164,2057.2,2004.8,1000.0,0.0,0.0,180.0,80.0);
    CreateObject(2164,2059.2,2004.8,1000.0,0.0,0.0,180.0,80.0);
    CreateObject(2190,2055.5,2001.9,1000.95,0.0,0.0,150.0,80.0);
    CreateObject(1714,2054.4,2004.4,1000.0,0.0,0.0,0.0,80.0);
    CreateObject(1720,2048.2,1999.8,1000.0,0.0,0.0,180.0,80.0);
    CreateObject(1720,2050.0,1999.8,1000.0,0.0,0.0,180.0,80.0);
    CreateObject(1720,2051.8,1999.8,1000.0,0.0,0.0,180.0,80.0);
    CreateObject(638,2063.8,2004.3,1000.0,0.0,0.0,90.0,80.0);
    CreateObject(638,2045.2,1991.0,1000.0,0.0,0.0,90.0,80.0);
    // Medical examination station in the far corner of the reception.
    CreateObject(1997,2067.5,2002.0,1000.0,0.0,0.0,90.0,80.0);
    CreateObject(2146,2066.0,2002.0,1000.0,0.0,0.0,0.0,80.0);
    CreateObject(1808,2071.3,2004.0,1000.0,0.0,0.0,180.0,80.0);
    // Ward: medical equipment and screens by the nurse's station.
    CreateObject(2164,2008.0,1992.5,1000.0,0.0,0.0,180.0,80.0);
    CreateObject(2190,2005.6,1994.0,1000.95,0.0,0.0,180.0,80.0);
    CreateObject(638,2013.0,1992.8,1000.0,0.0,0.0,90.0,80.0);
    CreateObject(1808,2009.8,1993.0,1000.0,0.0,0.0,180.0,80.0);
    // The staff-only door is placed on the RIGHT side of the reception hall.
    CreateObject(1491,2069.0,1997.0,1000.0,0.0,0.0,90.0,80.0);
    CreateObject(1491,2054.0,1988.4,1000.0,0.0,0.0,0.0,80.0);
    Create3DTextLabel("{33CC66}����� �� �����\n{FFFFFF}/exit ��� ALT",COLOR_WHITE,
        VX_LOBBY_EXIT_X,VX_LOBBY_EXIT_Y,1002.0,16.0,VX_HOSPITAL_WORLD,0);
    Create3DTextLabel("{66CCFF}���� | ������������\n{FFFFFF}���������� �� 7 ����: 1000 $\n/medcert ��� ALT",COLOR_WHITE,
        VX_LOBBY_CERT_X,VX_LOBBY_CERT_Y,1002.2,18.0,VX_HOSPITAL_WORLD,0);
    Create3DTextLabel("{FF9900}������ | ��������� ����\n{FFFFFF}������ ���������� ����\n/ward ��� ALT",COLOR_WHITE,
        VX_LOBBY_WARD_X,VX_LOBBY_WARD_Y,1002.5,16.0,VX_HOSPITAL_WORLD,0);
    Create3DTextLabel("{66CCFF}���� | ��Ȩ���� ����\n{FFFFFF}������� ������������, ������ ����� � ������",COLOR_WHITE,
        VX_LOBBY_X,VX_LOBBY_Y,1002.5,14.0,VX_HOSPITAL_WORLD,0);
    return 1;
}
stock VX_UpdateBedLabel(bed)
{
    if(bed<0 || bed>=VX_BEDS) return 0;
    new text[144],owner=gVXBedOwner[bed];
    if(owner>=0 && owner<MAX_PLAYERS && VX_Valid(owner))
        format(text,sizeof text,"{FF9900}����� %d | ������\n{FFFFFF}%s",bed+1,gName[owner]);
    else format(text,sizeof text,"{33CC66}����� %d | ��������\n{FFFFFF}/bed ��� ALT",bed+1);
    Update3DTextLabelText(gVXBedLabel[bed],COLOR_WHITE,text);
    return 1;
}
stock VX_CancelWardLoad(playerid)
{
    if(gVXWardTimer[playerid]) KillTimer(gVXWardTimer[playerid]);
    gVXWardTimer[playerid]=0;
    gVXWardSequence[playerid]++;
    return 1;
}
public VX_WardReady(playerid,session,sequence)
{
    if(!VX_Valid(playerid) || gVXSession[playerid]!=session || gVXWardSequence[playerid]!=sequence) return 0;
    gVXWardTimer[playerid]=0;
    if(GetPlayerVirtualWorld(playerid)!=VX_HOSPITAL_WORLD || GetPlayerInterior(playerid)!=0
        || gIsJailed[playerid] || gVXSpec[playerid]!=INVALID_PLAYER_ID
        || GetPlayerState(playerid)==PLAYER_STATE_WASTED) return 0;
    if(gVXBed[playerid]<0)
    {
        if(VX_InsideLobby(playerid))
            SetPlayerPos(playerid,VX_LOBBY_X,VX_LOBBY_Y,VX_LOBBY_Z);
        else SetPlayerPos(playerid,VX_WARD_X,VX_WARD_Y,VX_WARD_Z);
        if(!gHandcuffed[playerid] && !gTaserStunned[playerid]
            && gRPStretcherBy[playerid]==INVALID_PLAYER_ID) TogglePlayerControllable(playerid,true);
        SetCameraBehindPlayer(playerid);
    }
    return 1;
}
stock VX_WardSafety(playerid)
{
    if(GetPlayerVirtualWorld(playerid)!=VX_HOSPITAL_WORLD || GetPlayerInterior(playerid)!=0
        || gVXWardTimer[playerid] || gIsJailed[playerid] || !RP_Living(playerid)) return 0;
    new Float:x,Float:y,Float:z;
    GetPlayerPos(playerid,x,y,z);
    if(VX_InsideWard(playerid) || VX_InsideLobby(playerid))return 1;
    if(gVXHospital[playerid])return VX_EnterHospital(playerid);
    return VX_EnterLobby(playerid);
}
stock VX_WardInfo(playerid)
{
    if(GetPlayerVirtualWorld(playerid)!=VX_HOSPITAL_WORLD)
        return RP_Message(playerid,"�� �� � ������ ����.");
    new freeBeds=0,left=0,status[128],body[700];
    for(new bed=0;bed<VX_BEDS;bed++) if(gVXBedOwner[bed]==INVALID_PLAYER_ID) freeBeds++;
    if(gVXHospital[playerid])
    {
        left=gVXTreatment[playerid];
        format(status,sizeof status,"��������� �������. ��������� � �����: /bed ��� ALT.");
    }
    else format(status,sizeof status,"������������ ������� �� ���������. ����� ������.");
    format(body,sizeof body,"%s\n\n��������: %d ���. %d ���.\n��������� ����: %d �� %d.\n\n/exit ��� /hospitexit - ����� ����� �������.\n/hospitalinfo - ��� ����.",status,left/60,left%60,freeBeds,VX_BEDS);
    return VX_Show(playerid,VX_LOG,DIALOG_STYLE_MSGBOX,"���� | ���������",body,"OK","");
}
