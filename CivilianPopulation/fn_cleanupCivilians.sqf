/*
    Function: fn_cleanupCivilians

    Description:
        Removes civilian units and vehicles that are outside the despawn radius from all players.
        This prevents server lag by cleaning up distant civilians.
        Note: Checks distance from all players (not just squad leaders) to ensure
        civilians remain visible to any player within range.

    Parameters:
        None (checks all players and despawns civilians out of range)

    Returns:
        Number of units/vehicles cleaned up
*/

private _cleanupCount = 0;
private _allPlayers = allPlayers;

// Get all civilian units and vehicles
private _allCivs = allUnits select {_x getVariable ["CIV_type", ""] in ["pedestrian", "vehicle"]};
private _allCivVehicles = vehicles select {_x getVariable ["CIV_type", ""] == "vehicle"};

// Check each civilian unit
{
    private _civ = _x;
    private _civType = _civ getVariable ["CIV_type", ""];
    private _shouldDelete = true;

    // Check distance to all players
    {
        private _player = _x;
        private _distance = _civ distance _player;

        if (_distance < CIV_DESPAWN_RADIUS) then {
            _shouldDelete = false;
        };
    } forEach _allPlayers;

    // Delete if out of range from all players
    if (_shouldDelete && !isNull _civ) then {
        private _group = group _civ;

        if (CIV_DEBUG_MODE) then {
            systemChat format ["[CIV] Despawning civilian unit %1", _civ];
        };

        deleteVehicle _civ;

        // Delete empty group
        if (count units _group == 0) then {
            deleteGroup _group;
        };

        _cleanupCount = _cleanupCount + 1;
    };
} forEach _allCivs;

// Check each civilian vehicle
{
    private _vehicle = _x;
    private _shouldDelete = true;

    // Check distance to all players
    {
        private _player = _x;
        private _distance = _vehicle distance _player;

        if (_distance < CIV_DESPAWN_RADIUS) then {
            _shouldDelete = false;
        };
    } forEach _allPlayers;

    // Delete if out of range from all players
    if (_shouldDelete && !isNull _vehicle) then {
        private _driver = _vehicle getVariable ["CIV_driver", objNull];
        private _group = group _driver;

        if (CIV_DEBUG_MODE) then {
            systemChat format ["[CIV] Despawning civilian vehicle %1", _vehicle];
        };

        // Delete driver first
        if (!isNull _driver) then {
            deleteVehicle _driver;
        };

        // Delete vehicle
        deleteVehicle _vehicle;

        // Delete empty group
        if (!isNull _group && count units _group == 0) then {
            deleteGroup _group;
        };

        _cleanupCount = _cleanupCount + 1;
    };
} forEach _allCivVehicles;

if (CIV_DEBUG_MODE && _cleanupCount > 0) then {
    systemChat format ["[CIV] Cleaned up %1 civilian entities", _cleanupCount];
};

_cleanupCount
