/*
    Function: fn_spawnVehicles

    Description:
        Spawns civilian vehicles with drivers around a squad leader within the spawn radius.
        Vehicles will drive around the area on roads when possible and despawn when out of range.

    Parameters:
        _player - The squad leader object to spawn vehicles around

    Returns:
        Array of spawned civilian vehicles
*/

params ["_player"];

private _spawnedVehicles = [];
private _playerPos = getPosATL _player;

// Calculate how many vehicles to spawn
private _numVehicles = floor (CIV_MIN_VEHICLES + random (CIV_MAX_VEHICLES - CIV_MIN_VEHICLES));

if (CIV_DEBUG_MODE) then {
    systemChat format ["[CIV] Attempting to spawn %1 vehicles around squad leader %2", _numVehicles, name _player];
};

for "_i" from 1 to _numVehicles do {
    // Check spawn chance
    if (random 1 > CIV_VEHICLE_SPAWN_CHANCE) then { continue; };

    // Try to find a road position first
    private _nearRoads = _playerPos nearRoads CIV_SPAWN_RADIUS;
    private _spawnPos = [];

    if (count _nearRoads > 0) then {
        // Spawn on a random nearby road
        private _road = selectRandom _nearRoads;
        _spawnPos = getPosATL _road;
    } else {
        // No roads nearby, find a safe position
        _spawnPos = [_playerPos, 50, CIV_SPAWN_RADIUS, 5, 0, 0.3, 0, [], [_playerPos, _playerPos]] call BIS_fnc_findSafePos;
    };

    // Ensure spawn position is valid
    if (_spawnPos isEqualTo [0,0,0]) then { continue; };

    // Select random vehicle class
    private _vehClass = selectRandom CIV_VEHICLE_CLASSES;

    // Spawn the vehicle
    private _vehicle = createVehicle [_vehClass, _spawnPos, [], 0, "NONE"];

    if (!isNull _vehicle) then {
        // Set vehicle in correct position and direction
        _vehicle setPosATL _spawnPos;
        private _dir = random 360;
        _vehicle setDir _dir;

        // Create civilian group for driver
        private _civGroup = createGroup civilian;

        // Select random civilian class for driver
        private _driverClass = selectRandom CIV_UNIT_CLASSES;

        // Create driver
        private _driver = _civGroup createUnit [_driverClass, _spawnPos, [], 0, "FORM"];

        if (!isNull _driver) then {
            // Put driver in vehicle
            _driver moveInDriver _vehicle;
            _driver assignAsDriver _vehicle;

            // Set driver behavior
            _driver setBehaviour CIV_BEHAVIOR_MODE;
            _driver setCombatMode CIV_COMBAT_MODE;
            _driver setSpeedMode CIV_SPEED_MODE;
            _driver allowFleeing 1;

            // Disable AI features
            _driver disableAI "AUTOTARGET";
            _driver disableAI "TARGET";

            // Remove weapons from driver
            removeAllWeapons _driver;
            removeAllItems _driver;

            // Limit vehicle speed
            _vehicle limitSpeed CIV_VEHICLE_SPEED_LIMIT;

            // Store reference data
            _vehicle setVariable ["CIV_spawnedBy", _player, false];
            _vehicle setVariable ["CIV_type", "vehicle", false];
            _vehicle setVariable ["CIV_spawnTime", time, false];
            _vehicle setVariable ["CIV_driver", _driver, false];

            // Create driving waypoints
            [_driver, _spawnPos, _vehicle] call CIV_fnc_addVehicleWaypoints;

            // Add to spawned vehicles array
            _spawnedVehicles pushBack _vehicle;

            if (CIV_DEBUG_MODE) then {
                systemChat format ["[CIV] Spawned vehicle %1 at %2", _vehClass, _spawnPos];
            };
        } else {
            // Failed to create driver, delete vehicle
            deleteVehicle _vehicle;
        };
    };
};

if (CIV_DEBUG_MODE) then {
    systemChat format ["[CIV] Successfully spawned %1 vehicles", count _spawnedVehicles];
};

_spawnedVehicles
