/*
    Function: fn_addVehicleWaypoints

    Description:
        Adds random waypoints to a civilian vehicle driver to make them drive around.
        Prefers road positions when available.

    Parameters:
        _driver - The civilian driver unit
        _centerPos - The center position for waypoint generation
        _vehicle - The vehicle being driven

    Returns:
        None
*/

params ["_driver", "_centerPos", "_vehicle"];

private _group = group _driver;

// Find nearby roads for waypoint generation
private _nearRoads = _centerPos nearRoads (CIV_WAYPOINT_RADIUS * 2);

if (count _nearRoads > 5) then {
    // Use road-based waypoints
    for "_i" from 1 to CIV_WAYPOINT_COUNT do {
        private _road = selectRandom _nearRoads;
        private _wpPos = getPosATL _road;

        private _wp = _group addWaypoint [_wpPos, 0];
        _wp setWaypointType "MOVE";
        _wp setWaypointSpeed CIV_SPEED_MODE;
        _wp setWaypointBehaviour CIV_BEHAVIOR_MODE;
        _wp setWaypointCompletionRadius 15;
    };
} else {
    // No roads nearby, use random positions
    for "_i" from 1 to CIV_WAYPOINT_COUNT do {
        private _angle = random 360;
        private _distance = 50 + random CIV_WAYPOINT_RADIUS;
        private _wpPos = [
            (_centerPos select 0) + (_distance * cos _angle),
            (_centerPos select 1) + (_distance * sin _angle),
            0
        ];

        private _wp = _group addWaypoint [_wpPos, 0];
        _wp setWaypointType "MOVE";
        _wp setWaypointSpeed CIV_SPEED_MODE;
        _wp setWaypointBehaviour CIV_BEHAVIOR_MODE;
        _wp setWaypointCompletionRadius 20;
    };
};

// Add cycle waypoint to loop
private _wpCycle = _group addWaypoint [_centerPos, 0];
_wpCycle setWaypointType "CYCLE";

if (CIV_DEBUG_MODE) then {
    systemChat format ["[CIV] Added %1 vehicle waypoints", CIV_WAYPOINT_COUNT];
};
