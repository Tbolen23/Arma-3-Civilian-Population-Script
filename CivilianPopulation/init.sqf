/*
    Arma 3 Urban Civilian Population Script

    Description:
        Dynamically spawns and manages civilian pedestrians and vehicles around player squads
        in urban environments. Civilians spawn within 300m and despawn beyond that range
        to prevent server lag. Squad-based spawning improves performance.

    Usage:
        1. Place the CivilianPopulation folder in your mission directory
        2. Add the following to your mission's init.sqf:
           execVM "CivilianPopulation\init.sqf";
        3. Adjust settings in config.sqf as needed

    Features:
        - Squad-based civilian spawning within 300m radius
        - Random number of pedestrians and vehicles per squad
        - Civilians patrol randomly around spawn area
        - Automatic despawning when out of range
        - Fully configurable via config.sqf

    Author: tbolen23
    Version: 1.1
*/

// Wait for mission to start
if (!isServer) exitWith {};

// Get script directory for relative paths
private _scriptDir = str([] call {_thisScript}) select [0, count(str([] call {_thisScript})) - 8];

// Load configuration
call compile preprocessFileLineNumbers (_scriptDir + "config.sqf");

// Initialize global variables
if (isNil "CIV_active") then {
    CIV_active = true;
    CIV_spawnedUnits = [];
    CIV_spawnedVehicles = [];
};

// Compile functions
CIV_fnc_spawnCivilians = compile preprocessFileLineNumbers (_scriptDir + "fn_spawnCivilians.sqf");
CIV_fnc_spawnVehicles = compile preprocessFileLineNumbers (_scriptDir + "fn_spawnVehicles.sqf");
CIV_fnc_addWaypoints = compile preprocessFileLineNumbers (_scriptDir + "fn_addWaypoints.sqf");
CIV_fnc_addVehicleWaypoints = compile preprocessFileLineNumbers (_scriptDir + "fn_addVehicleWaypoints.sqf");
CIV_fnc_cleanupCivilians = compile preprocessFileLineNumbers (_scriptDir + "fn_cleanupCivilians.sqf");
CIV_fnc_checkSpawnLOS = compile preprocessFileLineNumbers (_scriptDir + "fn_checkSpawnLOS.sqf");

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

    // Get all player groups
    private _allPlayers = allPlayers;
    if (count _allPlayers == 0) exitWith {};

    private _playerGroups = [];
    {
        private _group = group _x;
        if (!(_group in _playerGroups)) then {
            _playerGroups pushBack _group;
        };
    } forEach _allPlayers;

    // Process each squad
    {
        private _squad = _x;
        private _squadLeader = leader _squad;

        // Skip if squad leader is null or dead
        if (isNull _squadLeader || !alive _squadLeader) then { continue; };

        private _squadPos = getPosATL _squadLeader;

        // Count existing civilians near this squad
        private _nearCivs = allUnits select {
            (_x getVariable ["CIV_type", ""]) == "pedestrian" &&
            (_x distance _squadPos) < CIV_SPAWN_RADIUS
        };

        private _nearVehicles = vehicles select {
            (_x getVariable ["CIV_type", ""]) == "vehicle" &&
            (_x distance _squadPos) < CIV_SPAWN_RADIUS
        };

        private _currentCivCount = count _nearCivs;
        private _currentVehCount = count _nearVehicles;

        // Spawn civilians if below minimum
        if (_currentCivCount < CIV_MIN_CIVILIANS) then {
            private _spawned = [_squadLeader] call CIV_fnc_spawnCivilians;
            CIV_spawnedUnits append _spawned;
        };

        // Spawn vehicles if below minimum
        if (_currentVehCount < CIV_MIN_VEHICLES) then {
            private _spawned = [_squadLeader] call CIV_fnc_spawnVehicles;
            CIV_spawnedVehicles append _spawned;
        };

    } forEach _playerGroups;

    // Cleanup civilians that are out of range
    call CIV_fnc_cleanupCivilians;

}, CIV_UPDATE_INTERVAL, []] call CBA_fnc_addPerFrameHandler;

// Alternative loop if CBA is not available
if (isNil "CBA_fnc_addPerFrameHandler") then {
    [] spawn {
        while {CIV_active} do {
            // Get all player groups
            private _allPlayers = allPlayers;

            if (count _allPlayers > 0) then {
                private _playerGroups = [];
                {
                    private _group = group _x;
                    if (!(_group in _playerGroups)) then {
                        _playerGroups pushBack _group;
                    };
                } forEach _allPlayers;

                // Process each squad
                {
                    private _squad = _x;
                    private _squadLeader = leader _squad;

                    // Skip if squad leader is null or dead
                    if (isNull _squadLeader || !alive _squadLeader) then { continue; };

                    private _squadPos = getPosATL _squadLeader;

                    // Count existing civilians near this squad
                    private _nearCivs = allUnits select {
                        (_x getVariable ["CIV_type", ""]) == "pedestrian" &&
                        (_x distance _squadPos) < CIV_SPAWN_RADIUS
                    };

                    private _nearVehicles = vehicles select {
                        (_x getVariable ["CIV_type", ""]) == "vehicle" &&
                        (_x distance _squadPos) < CIV_SPAWN_RADIUS
                    };

                    private _currentCivCount = count _nearCivs;
                    private _currentVehCount = count _nearVehicles;

                    // Spawn civilians if below minimum
                    if (_currentCivCount < CIV_MIN_CIVILIANS) then {
                        private _spawned = [_squadLeader] call CIV_fnc_spawnCivilians;
                        CIV_spawnedUnits append _spawned;
                    };

                    // Spawn vehicles if below minimum
                    if (_currentVehCount < CIV_MIN_VEHICLES) then {
                        private _spawned = [_squadLeader] call CIV_fnc_spawnVehicles;
                        CIV_spawnedVehicles append _spawned;
                    };

                } forEach _playerGroups;

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
