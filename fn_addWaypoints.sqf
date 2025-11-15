/*
    Function: fn_addWaypoints

    Description:
        Adds random waypoints to a civilian unit to make them patrol the area.
        Waypoints are placed within CIV_WAYPOINT_RADIUS of the spawn position.

    Parameters:
        _unit - The civilian unit to add waypoints to
        _centerPos - The center position for waypoint generation

    Returns:
        None
*/

params ["_unit", "_centerPos"];

private _group = group _unit;

// Create random waypoints
for "_i" from 1 to CIV_WAYPOINT_COUNT do {
    // Generate random position within waypoint radius
    private _angle = random 360;
    private _distance = 30 + random CIV_WAYPOINT_RADIUS;
    private _wpPos = [
        (_centerPos select 0) + (_distance * cos _angle),
        (_centerPos select 1) + (_distance * sin _angle),
        0
    ];

    // Add waypoint
    private _wp = _group addWaypoint [_wpPos, 0];
    _wp setWaypointType "MOVE";
    _wp setWaypointSpeed CIV_SPEED_MODE;
    _wp setWaypointBehaviour CIV_BEHAVIOR_MODE;
    _wp setWaypointCompletionRadius 10;

    // Add some variety with random statements
    private _randomAction = selectRandom [
        "",
        "this playMove 'Acts_CivilIdle_1'",
        "this playMove 'Acts_CivilTalking_1'",
        "[this] call BIS_fnc_ambientAnim"
    ];

    if (_randomAction != "") then {
        _wp setWaypointStatements ["true", _randomAction];
    };
};

// Add a cycle waypoint to loop back
private _wpCycle = _group addWaypoint [_centerPos, 0];
_wpCycle setWaypointType "CYCLE";

if (CIV_DEBUG_MODE) then {
    systemChat format ["[CIV] Added %1 waypoints to unit", CIV_WAYPOINT_COUNT];
};
