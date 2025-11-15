/*
    Function: fn_spawnCivilians

    Description:
        Spawns civilian units around a squad leader within the spawn radius.
        Civilians will randomly patrol the area and despawn when out of range.

    Parameters:
        _player - The squad leader object to spawn civilians around

    Returns:
        Array of spawned civilian units
*/

params ["_player"];

private _spawnedUnits = [];
private _playerPos = getPosATL _player;
private _allPlayers = allPlayers; // Get all players for LOS check

// Calculate how many civilians to spawn
private _numCivs = floor (CIV_MIN_CIVILIANS + random (CIV_MAX_CIVILIANS - CIV_MIN_CIVILIANS));

if (CIV_DEBUG_MODE) then {
    systemChat format ["[CIV] Attempting to spawn %1 civilians around squad leader %2", _numCivs, name _player];
};

for "_i" from 1 to _numCivs do {
    // Check spawn chance
    if (random 1 > CIV_SPAWN_CHANCE) then { continue; };

    // Find a random position within spawn radius (minimum distance to prevent spawning on top of players)
    private _spawnPos = [_playerPos, CIV_MIN_SPAWN_DISTANCE, CIV_SPAWN_RADIUS, 3, 0, 0.3, 0, [], [_playerPos, _playerPos]] call BIS_fnc_findSafePos;

    // Ensure spawn position is valid
    if (_spawnPos isEqualTo [0,0,0]) then { continue; };

    // Check if spawn position is visible to any player (LOS check)
    // Returns true if visible (block spawn), false if not visible (allow spawn)
    private _isVisible = [_spawnPos, _allPlayers] call CIV_fnc_checkSpawnLOS;
    if (_isVisible) then { continue; }; // Skip this spawn if players can see it

    // Create civilian group
    private _civGroup = createGroup civilian;

    // Select random civilian class
    private _civClass = selectRandom CIV_UNIT_CLASSES;

    // Spawn the civilian
    private _civ = _civGroup createUnit [_civClass, _spawnPos, [], 0, "FORM"];

    if (!isNull _civ) then {
        // Set civilian behavior
        _civ setBehaviour CIV_BEHAVIOR_MODE;
        _civ setCombatMode CIV_COMBAT_MODE;
        _civ setSpeedMode CIV_SPEED_MODE;

        // Disable AI features that aren't needed
        _civ disableAI "AUTOTARGET";
        _civ disableAI "TARGET";
        _civ allowFleeing 1;

        // Remove weapons to make them proper civilians
        removeAllWeapons _civ;
        removeAllItems _civ;

        // Store reference data on the unit
        _civ setVariable ["CIV_spawnedBy", _player, false];
        _civ setVariable ["CIV_type", "pedestrian", false];
        _civ setVariable ["CIV_spawnTime", time, false];

        // Create random waypoints for the civilian
        [_civ, _spawnPos] call CIV_fnc_addWaypoints;

        // Add to spawned units array
        _spawnedUnits pushBack _civ;

        if (CIV_DEBUG_MODE) then {
            systemChat format ["[CIV] Spawned civilian %1 at %2", _civClass, _spawnPos];
        };
    };
};

if (CIV_DEBUG_MODE) then {
    systemChat format ["[CIV] Successfully spawned %1 civilians", count _spawnedUnits];
};

_spawnedUnits
