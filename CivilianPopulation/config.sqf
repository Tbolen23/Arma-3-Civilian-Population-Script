/*
    Arma 3 Urban Civilian Population Script - Configuration

    This file contains all configuration options for the civilian population system.
    Edit these values to customize the civilian and vehicle spawning behavior.
*/

// ===== GENERAL SETTINGS =====
CIV_SPAWN_RADIUS = 300;              // Radius around squads where civilians spawn (meters)
CIV_DESPAWN_RADIUS = 350;            // Radius at which civilians despawn (meters)
CIV_UPDATE_INTERVAL = 10;            // How often to check spawn/despawn (seconds)

// ===== CIVILIAN SETTINGS =====
CIV_MIN_CIVILIANS = 5;               // Minimum number of civilians per squad
CIV_MAX_CIVILIANS = 15;              // Maximum number of civilians per squad
CIV_SPAWN_CHANCE = 0.7;              // Chance (0-1) that a civilian will spawn each check
CIV_WAYPOINT_RADIUS = 150;           // How far civilians will walk from spawn point
CIV_WAYPOINT_COUNT = 3;              // Number of waypoints per civilian

// Civilian unit classes (randomly selected)
CIV_UNIT_CLASSES = [
    "C_man_1",
    "C_man_polo_1_F",
    "C_man_polo_2_F",
    "C_man_polo_3_F",
    "C_man_polo_4_F",
    "C_man_polo_5_F",
    "C_man_polo_6_F",
    "C_man_p_fugitive_F",
    "C_man_1_1_F",
    "C_man_1_2_F",
    "C_man_1_3_F",
    "C_Man_casual_1_F",
    "C_Man_casual_2_F",
    "C_Man_casual_3_F",
    "C_man_sport_1_F",
    "C_man_sport_2_F",
    "C_man_sport_3_F"
];

// ===== VEHICLE SETTINGS =====
CIV_MIN_VEHICLES = 2;                // Minimum number of vehicles per squad
CIV_MAX_VEHICLES = 6;                // Maximum number of vehicles per squad
CIV_VEHICLE_SPAWN_CHANCE = 0.5;      // Chance (0-1) that a vehicle will spawn each check
CIV_VEHICLE_SPEED_LIMIT = 50;        // Speed limit for civilian vehicles (km/h)

// Civilian vehicle classes (randomly selected)
CIV_VEHICLE_CLASSES = [
    "C_Hatchback_01_F",
    "C_Hatchback_01_sport_F",
    "C_Offroad_02_unarmed_F",
    "C_SUV_01_F",
    "C_Van_01_transport_F",
    "C_Van_01_box_F",
    "C_Truck_02_transport_F",
    "C_Truck_02_covered_F"
];

// ===== BEHAVIOR SETTINGS =====
CIV_BEHAVIOR_MODE = "SAFE";          // Behavior mode: "SAFE", "AWARE", "COMBAT"
CIV_COMBAT_MODE = "BLUE";            // Combat mode: "BLUE" (never fire), "GREEN" (hold fire), "YELLOW" (fire at will)
CIV_FORMATION = "COLUMN";            // Formation for groups
CIV_SPEED_MODE = "LIMITED";          // Speed mode: "LIMITED", "NORMAL", "FULL"

// ===== DEBUG SETTINGS =====
CIV_DEBUG_MODE = false;              // Enable debug messages
CIV_DEBUG_MARKERS = false;           // Show debug markers on map
