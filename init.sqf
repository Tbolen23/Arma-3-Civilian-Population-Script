/*
    Arma 3 Urban Civilian Population Script

    Description:
        Dynamically spawns and manages civilian pedestrians and vehicles around players
        in urban environments. Civilians spawn within 300m and despawn beyond that range
        to prevent server lag.

    Usage:
        1. Place this script folder in your mission directory
        2. Add the following to your mission's init.sqf:
           execVM "Arma-3-Civilian-Population-Script\init.sqf";
        3. Adjust settings in config.sqf as needed

    Features:
        - Dynamic civilian spawning within 300m radius of players
        - Random number of pedestrians and vehicles
        - Civilians patrol randomly around spawn area
        - Automatic despawning when out of range
        - Fully configurable via config.sqf

    Author: tbolen23
    Version: 1.0
*/

// Wait for mission to start
if (!isServer) exitWith {};

// Load configuration
call compile preprocessFileLineNumbers "Arma-3-Civilian-Population-Script\config.sqf";

// Initialize global variables
if (isNil "CIV_active") then {
    CIV_active = true;
    CIV_spawnedUnits = [];
    CIV_spawnedVehicles = [];
};

// Compile functions
CIV_fnc_spawnCivilians = compile preprocessFileLineNumbers "Arma-3-Civilian-Population-Script\fn_spawnCivilians.sqf";
CIV_fnc_spawnVehicles = compile preprocessFileLineNumbers "Arma-3-Civilian-Population-Script\fn_spawnVehicles.sqf";
CIV_fnc_addWaypoints = compile preprocessFileLineNumbers "Arma-3-Civilian-Population-Script\fn_addWaypoints.sqf";
CIV_fnc_addVehicleWaypoints = compile preprocessFileLineNumbers "Arma-3-Civilian-Population-Script\fn_addVehicleWaypoints.sqf";
CIV_fnc_cleanupCivilians = compile preprocessFileLineNumbers "Arma-3-Civilian-Population-Script\fn_cleanupCivilians.sqf";

// Initialization message
diag_log "==========================================================";
diag_log "Urban Civilian Population Script Initialized";
diag_log format ["Spawn Radius: %1m | Despawn Radius: %2m", CIV_SPAWN_RADIUS, CIV_DESPAWN_RADIUS];
diag_log format ["Civilians: %1-%2 | Vehicles: %3-%4", CIV_MIN_CIVILIANS, CIV_MAX_CIVILIANS, CIV_MIN_VEHICLES, CIV_MAX_VEHICLES];
diag_log "==========================================================";

if (CIV_DEBUG_MODE) then {
    systemChat "[CIV] Urban Civilian Population Script Active";
};

// Main spawn loop
[{
    // Exit if script is disabled
    if (!CIV_active) exitWith {};

    // Get all players
    private _allPlayers = allPlayers;

    if (count _allPlayers == 0) exitWith {};

    // Process each player
    {
        private _player = _x;

        // Count existing civilians near this player
        private _nearCivs = allUnits select {
            (_x getVariable ["CIV_type", ""]) == "pedestrian" &&
            (_x distance _player) < CIV_SPAWN_RADIUS
        };

        private _nearVehicles = vehicles select {
            (_x getVariable ["CIV_type", ""]) == "vehicle" &&
            (_x distance _player) < CIV_SPAWN_RADIUS
        };

        private _currentCivCount = count _nearCivs;
        private _currentVehCount = count _nearVehicles;

        // Spawn civilians if below minimum
        if (_currentCivCount < CIV_MIN_CIVILIANS) then {
            private _spawned = [_player] call CIV_fnc_spawnCivilians;
            CIV_spawnedUnits append _spawned;
        };

        // Spawn vehicles if below minimum
        if (_currentVehCount < CIV_MIN_VEHICLES) then {
            private _spawned = [_player] call CIV_fnc_spawnVehicles;
            CIV_spawnedVehicles append _spawned;
        };

    } forEach _allPlayers;

    // Cleanup civilians that are out of range
    call CIV_fnc_cleanupCivilians;

}, CIV_UPDATE_INTERVAL, []] call CBA_fnc_addPerFrameHandler;

// Alternative loop if CBA is not available
if (isNil "CBA_fnc_addPerFrameHandler") then {
    [] spawn {
        while {CIV_active} do {
            // Get all players
            private _allPlayers = allPlayers;

            if (count _allPlayers > 0) then {
                // Process each player
                {
                    private _player = _x;

                    // Count existing civilians near this player
                    private _nearCivs = allUnits select {
                        (_x getVariable ["CIV_type", ""]) == "pedestrian" &&
                        (_x distance _player) < CIV_SPAWN_RADIUS
                    };

                    private _nearVehicles = vehicles select {
                        (_x getVariable ["CIV_type", ""]) == "vehicle" &&
                        (_x distance _player) < CIV_SPAWN_RADIUS
                    };

                    private _currentCivCount = count _nearCivs;
                    private _currentVehCount = count _nearVehicles;

                    // Spawn civilians if below minimum
                    if (_currentCivCount < CIV_MIN_CIVILIANS) then {
                        private _spawned = [_player] call CIV_fnc_spawnCivilians;
                        CIV_spawnedUnits append _spawned;
                    };

                    // Spawn vehicles if below minimum
                    if (_currentVehCount < CIV_MIN_VEHICLES) then {
                        private _spawned = [_player] call CIV_fnc_spawnVehicles;
                        CIV_spawnedVehicles append _spawned;
                    };

                } forEach _allPlayers;

                // Cleanup civilians that are out of range
                call CIV_fnc_cleanupCivilians;
            };

            sleep CIV_UPDATE_INTERVAL;
        };
    };
};

// Cleanup on mission end
addMissionEventHandler ["Ended", {
    CIV_active = false;

    // Delete all spawned civilians
    {
        deleteVehicle _x;
    } forEach CIV_spawnedUnits;

    // Delete all spawned vehicles and drivers
    {
        private _driver = _x getVariable ["CIV_driver", objNull];
        if (!isNull _driver) then {
            deleteVehicle _driver;
        };
        deleteVehicle _x;
    } forEach CIV_spawnedVehicles;

    if (CIV_DEBUG_MODE) then {
        systemChat "[CIV] Civilian population script terminated";
    };
}];
