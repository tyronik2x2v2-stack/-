#!/usr/bin/env python3
"""Byte-preserving VEXORIUM repair. Source is kept in Windows-1251."""
from __future__ import annotations

import pathlib
import subprocess
import sys

BASE_COMMIT = "68685eaa2894e685553cb01ffd592881dbf34f8c"
SOURCE_PATH = "vexorium.pwn"


def replace_once(data: bytes, old: bytes, new: bytes, label: str, expected: int = 1) -> bytes:
    count = data.count(old)
    if count != expected:
        raise RuntimeError(f"{label}: expected {expected} occurrence(s), found {count}")
    return data.replace(old, new)


def main() -> None:
    source = subprocess.check_output(["git", "show", f"{BASE_COMMIT}:{SOURCE_PATH}"])
    initial_lines = source.count(b"\n") + 1
    if initial_lines != 12595:
        raise RuntimeError(f"Unexpected baseline line count: {initial_lines}")

    # Add the forward declaration and per-player anti-cheat state.
    source = replace_once(
        source,
        b"new gLockpicks[MAX_PLAYERS];",
        b"new gLockpicks[MAX_PLAYERS];\n"
        b"new gVXACSpeedStrikes[MAX_PLAYERS];\n"
        b"new gVXACLastAlert[MAX_PLAYERS];\n"
        b"forward Float:VX_VehicleSpeedScale(vehicleid);",
        "anti-cheat state and speed-scale forward",
    )

    # The two admin commands used a tag as a statement instead of declaring Float variables.
    source = replace_once(
        source,
        b"new params[48],token[24],targetid;Float:x,Float:y,Float:z;",
        b"new params[48],token[24],targetid; new Float:x,Float:y,Float:z;",
        "Float declarations",
        expected=2,
    )

    # Remove genuinely unused values that caused compiler warnings.
    source = replace_once(source, b"new gMarketPickup;\n", b"", "unused market pickup variable")
    source = replace_once(source, b"    gMarketPickup = gMarketPickups[0];\n", b"", "unused market pickup assignment")
    source = replace_once(
        source, b"new PlayerText:gVexNavCells[MAX_PLAYERS][9];\n", b"", "unused navigation cells"
    )
    source = replace_once(source, b"new gVexNavCache[MAX_PLAYERS][9];\n", b"", "unused navigation cache")

    # Reformat the wanted-record loop and keep its existing CP1251 dialog title untouched.
    start_marker = b"        if(r)for(new i=0;i<db_num_rows(r);i++)"
    end_marker = b"        if(r)db_free_result(r);return VX_Show("
    start = source.find(start_marker)
    end = source.find(end_marker, start + len(start_marker))
    if start < 0 or end < 0:
        raise RuntimeError("Could not locate wanted-record indentation block")
    line_end = source.find(b"\n", end)
    if line_end < 0:
        raise RuntimeError("Wanted-record return line was not terminated")
    return_line = source[end:line_end]
    return_index = return_line.find(b"return VX_Show(")
    if return_index < 0:
        raise RuntimeError("Could not preserve wanted-record dialog return")
    return_statement = return_line[return_index:]
    formatted_loop = (
        b"        if (r)\n"
        b"        {\n"
        b"            for (new i = 0; i < db_num_rows(r); i++)\n"
        b"            {\n"
        b"                db_get_field(r, 0, name, sizeof name);\n"
        b"                new stars = db_get_field_int(r, 1);\n"
        b"                new due = db_get_field_int(r, 2);\n"
        b"                if (due > 0 && gettime() >= due)\n"
        b"                    stars = max(0, stars - 1 - (gettime() - due) / VX_WANTED_SECONDS);\n"
        b"                if (stars > 0)\n"
        b"                {\n"
        b"                    format(row, sizeof row, \"%s\\t%d\\n\", name, stars);\n"
        b"                    strcat(body, row);\n"
        b"                }\n"
        b"                db_next_row(r);\n"
        b"            }\n"
        b"            db_free_result(r);\n"
        b"        }\n"
        b"        " + return_statement + b"\n"
    )
    source = source[:start] + formatted_loop + source[line_end + 1 :]

    # Split the two SQL statements so Pawn's indentation checker sees the intended block.
    old_car_sql = (
        b'    format(q,sizeof q,"INSERT OR REPLACE INTO rp_vehicles(owner,model,plate) VALUES(\\'%q\\',%d,\\'%q\\')",\n'
        b"        gName[playerid],model,plate); VX_SQL(q);\n"
        b'    format(q,sizeof q,"DELETE FROM rp_keys WHERE owner=\\'%q\\'",gName[playerid]); VX_SQL(q);\n'
    )
    new_car_sql = (
        b'    format(q, sizeof q, "INSERT OR REPLACE INTO rp_vehicles(owner,model,plate) VALUES(\\'%q\\',%d,\\'%q\\')", gName[playerid], model, plate);\n'
        b"    VX_SQL(q);\n"
        b'    format(q, sizeof q, "DELETE FROM rp_keys WHERE owner=\\'%q\\'", gName[playerid]);\n'
        b"    VX_SQL(q);\n"
    )
    source = replace_once(source, old_car_sql, new_car_sql, "vehicle SQL indentation")

    # A pair of real open.mp NPCs, not CreateActor decorations.
    npc_function = (
        b"stock VX_CreateServerNPCs()\n"
        b"{\n"
        b'    new npc1 = NPC_Create("VEX_NPC_01");\n'
        b"    if (NPC_IsValid(npc1))\n"
        b"    {\n"
        b"        NPC_Spawn(npc1);\n"
        b"        NPC_SetSkin(npc1, 17);\n"
        b"        NPC_SetPos(npc1, 1812.0, -1890.0, 13.4);\n"
        b"        NPC_SetFacingAngle(npc1, 90.0);\n"
        b'        print("[VEXORIUM NPC] VEX_NPC_01 spawned.");\n'
        b"    }\n"
        b"    else print(\"[VEXORIUM NPC] Failed to create VEX_NPC_01.\");\n"
        b"\n"
        b'    new npc2 = NPC_Create("VEX_NPC_02");\n'
        b"    if (NPC_IsValid(npc2))\n"
        b"    {\n"
        b"        NPC_Spawn(npc2);\n"
        b"        NPC_SetSkin(npc2, 61);\n"
        b"        NPC_SetPos(npc2, 1817.0, -1890.0, 13.4);\n"
        b"        NPC_SetFacingAngle(npc2, 270.0);\n"
        b'        print("[VEXORIUM NPC] VEX_NPC_02 spawned.");\n'
        b"    }\n"
        b'    else print("[VEXORIUM NPC] Failed to create VEX_NPC_02.");\n'
        b"    return 1;\n"
        b"}\n\n"
    )
    source = replace_once(
        source,
        b"public OnGameModeInit()\n{\n",
        npc_function + b"public OnGameModeInit()\n{\n    VX_CreateServerNPCs();\n",
        "NPC function and initialization",
    )

    # Conservative server-side checks: correct impossible health/armour and log repeated speed anomalies.
    anti_cheat = (
        b"stock VX_ACReport(playerid, const reason[])\n"
        b"{\n"
        b"    new now = gettime();\n"
        b"    if (gVXACLastAlert[playerid] > 0 && now - gVXACLastAlert[playerid] < 10) return 0;\n"
        b"    gVXACLastAlert[playerid] = now;\n"
        b"    new playerName[MAX_PLAYER_NAME + 1], message[160];\n"
        b"    GetPlayerName(playerid, playerName, sizeof playerName);\n"
        b'    format(message, sizeof message, "[VEX AC] %s (ID %d): %s", playerName, playerid, reason);\n'
        b"    print(message);\n"
        b"    for (new admin = 0; admin < MAX_PLAYERS; admin++)\n"
        b"    {\n"
        b"        if (IsPlayerConnected(admin) && gAdmin[admin] > 0)\n"
        b"            SendClientMessage(admin, COLOR_RED, message);\n"
        b"    }\n"
        b"    return 1;\n"
        b"}\n\n"
        b"stock VX_AntiCheatCheck(playerid)\n"
        b"{\n"
        b"    if (!gLogged[playerid] || !gRPLoaded[playerid] || gAdmin[playerid] > 0 || IsPlayerNPC(playerid))\n"
        b"        return 0;\n"
        b"\n"
        b"    new Float:health, Float:armour;\n"
        b"    GetPlayerHealth(playerid, health);\n"
        b"    GetPlayerArmour(playerid, armour);\n"
        b"    if (health > 100.5)\n"
        b"    {\n"
        b"        SetPlayerHealth(playerid, 100.0);\n"
        b'        VX_ACReport(playerid, "health value exceeded 100");\n'
        b"    }\n"
        b"    if (armour > 100.5)\n"
        b"    {\n"
        b"        SetPlayerArmour(playerid, 100.0);\n"
        b'        VX_ACReport(playerid, "armour value exceeded 100");\n'
        b"    }\n"
        b"\n"
        b"    if (GetPlayerState(playerid) != PLAYER_STATE_ONFOOT || gIsJailed[playerid]\n"
        b"        || gHandcuffed[playerid] || gTaserStunned[playerid] || gVXHospital[playerid]\n"
        b"        || gVXSpec[playerid] != INVALID_PLAYER_ID || gFBIEditActive[playerid]\n"
        b"        || gPvpActive[playerid] || gPvpRestorePending[playerid])\n"
        b"    {\n"
        b"        gVXACSpeedStrikes[playerid] = 0;\n"
        b"        return 1;\n"
        b"    }\n"
        b"\n"
        b"    new Float:velX, Float:velY, Float:velZ;\n"
        b"    GetPlayerVelocity(playerid, velX, velY, velZ);\n"
        b"    new Float:horizontalSpeed = floatsqroot(velX * velX + velY * velY);\n"
        b"    if (horizontalSpeed > 0.65)\n"
        b"    {\n"
        b"        if (gVXACSpeedStrikes[playerid] < 4) gVXACSpeedStrikes[playerid]++;\n"
        b"    }\n"
        b"    else if (gVXACSpeedStrikes[playerid] > 0)\n"
        b"    {\n"
        b"        gVXACSpeedStrikes[playerid]--;\n"
        b"    }\n"
        b"    if (gVXACSpeedStrikes[playerid] >= 4)\n"
        b"    {\n"
        b"        gVXACSpeedStrikes[playerid] = 0;\n"
        b'        VX_ACReport(playerid, "repeated abnormal on-foot movement speed");\n'
        b"    }\n"
        b"    return 1;\n"
        b"}\n\n"
    )
    source = replace_once(
        source,
        b"public VX_Tick()\n{\n",
        anti_cheat + b"public VX_Tick()\n{\n",
        "anti-cheat functions",
    )

    # Reset the anti-cheat counters with each connection session.
    source = replace_once(
        source,
        b"    RP_Reset(playerid);\n    gFBIPendingEnter[playerid] = false;",
        b"    RP_Reset(playerid);\n"
        b"    gVXACSpeedStrikes[playerid] = 0;\n"
        b"    gVXACLastAlert[playerid] = 0;\n"
        b"    gFBIPendingEnter[playerid] = false;",
        "anti-cheat connect reset",
    )
    source = replace_once(
        source,
        b"public OnPlayerDisconnect(playerid, reason)\n{\n    gHousePending[playerid] = 0;",
        b"public OnPlayerDisconnect(playerid, reason)\n{\n"
        b"    gHousePending[playerid] = 0;\n"
        b"    gVXACSpeedStrikes[playerid] = 0;\n"
        b"    gVXACLastAlert[playerid] = 0;",
        "anti-cheat disconnect reset",
    )
    source = replace_once(
        source,
        b"        if(!VX_Valid(p))continue;\n        VX_DecayWanted(p);",
        b"        if(!VX_Valid(p))continue;\n"
        b"        VX_AntiCheatCheck(p);\n"
        b"        VX_DecayWanted(p);",
        "anti-cheat tick",
    )

    if source.count(b"new params[48],token[24],targetid;Float:x,Float:y,Float:z;"):
        raise RuntimeError("A broken Float declaration remains")
    for marker, label in [
        (b"forward Float:VX_VehicleSpeedScale(vehicleid);", "speed forward"),
        (b"NPC_Create(\"VEX_NPC_01\")", "first NPC"),
        (b"NPC_Create(\"VEX_NPC_02\")", "second NPC"),
        (b"stock VX_AntiCheatCheck(playerid)", "anti-cheat"),
        (b"VX_AntiCheatCheck(p);", "anti-cheat tick"),
    ]:
        if source.count(marker) != 1:
            raise RuntimeError(f"Validation failed: {label}")
    if b"\xef\xbf\xbd" in source:
        raise RuntimeError("The source contains UTF-8 replacement characters")
    # The file must remain valid Windows-1251 and keep all original high-byte text.
    source.decode("cp1251")

    pathlib.Path(SOURCE_PATH).write_bytes(source)
    print(f"Patched {SOURCE_PATH}: {source.count(bytes([10])) + 1} lines, CP1251 bytes preserved.")
    print("Added: /goto and /gethere fixes, anti-cheat checks, two open.mp NPCs.")
    print("Reminder: set max_bots to 2 in the server config.json.")


if __name__ == "__main__":
    main()
