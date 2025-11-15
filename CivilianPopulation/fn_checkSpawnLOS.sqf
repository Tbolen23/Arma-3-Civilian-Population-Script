/*
    Function: fn_checkSpawnLOS

    Description:
        Hybrid line of sight check to prevent civilians spawning in player's view.
        Uses a two-stage approach for performance:
        1. Fast FOV (Field of View) check using vector math
        2. Expensive visibility check only if position is within FOV

        This prevents the immersion-breaking experience of civilians "popping in"
        while maintaining good performance.

    Parameters:
        _spawnPos - Position to check [x,y,z]
        _allPlayers - Array of all player objects to check against

    Returns:
        Boolean - true if position is visible to any player (block spawn), false if safe to spawn

    Performance:
        - FOV check: ~0.001ms per player (cheap vector math)
        - LOS check: ~0.1ms per player (only when in FOV)
        - Total impact: minimal, most positions fail FOV check
*/

params ["_spawnPos", "_allPlayers"];

// If LOS checking is disabled, always allow spawn
if (!CIV_ENABLE_LOS_CHECK) exitWith { false };

// Check each player's line of sight
{
    private _player = _x;

    // Skip if player is in a vehicle (different camera angles, complex to check)
    if (vehicle _player != _player) then { continue; };

    // Get player's eye position (where they're looking from)
    private _eyePos = eyePos _player;

    // Get player's looking direction
    private _playerDir = getDirVisual _player;

    // Calculate vector from player to spawn position
    private _toSpawn = _spawnPos vectorDiff _eyePos;
    private _distance = vectorMagnitude _toSpawn;

    // Skip if spawn is too far to see clearly (optimization)
    if (_distance > 200) then { continue; };

    // Normalize the vector (make it length 1 for direction comparison)
    private _toSpawnNorm = vectorNormalized _toSpawn;

    // Create player's forward direction vector
    private _playerDirVec = [sin _playerDir, cos _playerDir, 0];

    // ===== STAGE 1: FAST FOV CHECK =====
    // Calculate angle between player's look direction and spawn position
    // Using dot product: if > cos(FOV/2), position is within FOV cone
    private _dotProduct = _playerDirVec vectorDotProduct _toSpawnNorm;
    private _fovThreshold = cos ((CIV_FOV_ANGLE / 2));

    // If NOT in FOV, this position is safe (skip expensive LOS check)
    if (_dotProduct < _fovThreshold) then { continue; };

    // ===== STAGE 2: EXPENSIVE VISIBILITY CHECK =====
    // Position is in FOV, now check if there's actual line of sight
    // This checks if terrain/buildings block the view

    // Cast a ray from player's eyes to spawn position
    private _intersections = lineIntersectsSurfaces [
        _eyePos,                    // Start: player's eye position
        _spawnPos,                  // End: spawn position
        _player,                    // Ignore: the player object itself
        objNull,                    // Ignore: nothing else
        true,                       // Sort by distance
        1,                          // Max results: we only need to know if there's ANY obstruction
        "GEOM",                     // Check geometry
        "NONE"                      // Ignore fire geometry
    ];

    // If there are NO intersections, spawn position is fully visible - BLOCK SPAWN
    if (count _intersections == 0) exitWith {
        if (CIV_DEBUG_MODE) then {
            systemChat format ["[CIV LOS] Blocked spawn at %1 - visible to %2", _spawnPos, name _player];
        };
        true // Return true = position is visible, block spawn
    };

    // If there ARE intersections, something blocks the view - ALLOW SPAWN
    // (terrain, building, etc. between player and spawn point)

} forEach _allPlayers;

// If we get here, position is not visible to any player - safe to spawn
false // Return false = position is not visible, allow spawn
