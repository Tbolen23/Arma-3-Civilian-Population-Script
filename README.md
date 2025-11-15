# Arma 3 Urban Civilian Population Script

A dynamic civilian population system for Arma 3 that spawns pedestrians and vehicles around player squads in urban environments. Perfect for creating realistic city atmospheres with a mix of civilians and combatants.

## Features

- **Squad-Based Spawning**: Civilians and vehicles spawn within 300m radius of each player squad
- **Safe Distance Spawning**: Minimum 25m spawn distance prevents civilians from appearing right next to players
- **Random Population**: Configurable random number of civilians (5-15) and vehicles (2-6) per squad
- **Smart Patrolling**: Civilians walk randomly, vehicles drive on roads when available
- **Automatic Cleanup**: Despawns civilians outside 350m radius to prevent server lag
- **Fully Configurable**: Adjust all parameters in `config.sqf`
- **Performance Optimized**: Regular cleanup cycles prevent entity buildup, squad-based spawning reduces overhead
- **CBA Compatible**: Uses CBA functions if available, falls back to vanilla if not

## Installation

### Quick Start

1. Copy the `CivilianPopulation` folder to your mission directory
2. Add this line to your mission's `init.sqf`:
   ```sqf
   execVM "CivilianPopulation\init.sqf";
   ```
3. (Optional) Edit `CivilianPopulation\config.sqf` to customize settings

That's it! The script will automatically start spawning civilians when the mission begins.

## Configuration

Edit `CivilianPopulation\config.sqf` to customize the civilian population system:

### General Settings
```sqf
CIV_SPAWN_RADIUS = 300;        // Spawn radius around squads (meters)
CIV_MIN_SPAWN_DISTANCE = 25;   // Minimum spawn distance from players (meters)
CIV_DESPAWN_RADIUS = 350;      // Despawn radius (meters)
CIV_UPDATE_INTERVAL = 10;      // Update frequency (seconds)
```

### Civilian Settings
```sqf
CIV_MIN_CIVILIANS = 5;         // Minimum civilians per squad
CIV_MAX_CIVILIANS = 15;        // Maximum civilians per squad
CIV_SPAWN_CHANCE = 0.7;        // Spawn probability (0-1)
```

### Vehicle Settings
```sqf
CIV_MIN_VEHICLES = 2;          // Minimum vehicles per squad
CIV_MAX_VEHICLES = 6;          // Maximum vehicles per squad
CIV_VEHICLE_SPAWN_CHANCE = 0.5; // Spawn probability (0-1)
CIV_VEHICLE_SPEED_LIMIT = 50;  // Speed limit (km/h)
```

### Debug Mode
```sqf
CIV_DEBUG_MODE = true;         // Enable debug messages
CIV_DEBUG_MARKERS = true;      // Show debug markers
```

## File Structure

```
YourMission.Map/
├── mission.sqm
├── init.sqf                      # Your mission's init file
├── README.md                     # Project documentation
├── LICENSE                       # MIT License
└── CivilianPopulation/          # Civilian population script folder
    ├── init.sqf                 # Main initialization script
    ├── config.sqf               # Configuration file
    ├── fn_spawnCivilians.sqf    # Civilian spawning logic
    ├── fn_spawnVehicles.sqf     # Vehicle spawning logic
    ├── fn_addWaypoints.sqf      # Pedestrian waypoint system
    ├── fn_addVehicleWaypoints.sqf # Vehicle waypoint system
    └── fn_cleanupCivilians.sqf  # Despawn/cleanup logic
```

## How It Works

1. **Initialization**: The script loads configuration and compiles all functions
2. **Spawn Loop**: Every 10 seconds (configurable), the script:
   - Identifies all player squads/groups
   - Checks each squad leader's position
   - Counts nearby civilians and vehicles for each squad
   - Spawns new ones if below minimum threshold
   - Assigns random patrol waypoints
3. **Cleanup Loop**: Simultaneously removes civilians/vehicles beyond despawn radius from any player
4. **Mission End**: All spawned entities are cleaned up automatically

**Squad System**: Civilians spawn around squad leaders (one set per squad), making it more performance-friendly than per-player spawning. Solo players count as a squad of one.

## Customization Examples

### High-Density Urban Area
```sqf
CIV_MIN_CIVILIANS = 10;
CIV_MAX_CIVILIANS = 25;
CIV_MIN_VEHICLES = 5;
CIV_MAX_VEHICLES = 12;
```

### Low-Density Suburb
```sqf
CIV_MIN_CIVILIANS = 3;
CIV_MAX_CIVILIANS = 8;
CIV_MIN_VEHICLES = 1;
CIV_MAX_VEHICLES = 4;
```

### Performance Mode (Large Multiplayer)
```sqf
CIV_MIN_CIVILIANS = 3;
CIV_MAX_CIVILIANS = 8;
CIV_MIN_VEHICLES = 1;
CIV_MAX_VEHICLES = 3;
CIV_UPDATE_INTERVAL = 15;
CIV_DESPAWN_RADIUS = 320;
```

## Adding Custom Units/Vehicles

### Custom Civilian Units
Edit the `CIV_UNIT_CLASSES` array in `config.sqf`:
```sqf
CIV_UNIT_CLASSES = [
    "C_man_1",
    "YourModClass_civilian_1",
    "YourModClass_civilian_2"
];
```

### Custom Vehicles
Edit the `CIV_VEHICLE_CLASSES` array in `config.sqf`:
```sqf
CIV_VEHICLE_CLASSES = [
    "C_Hatchback_01_F",
    "YourModClass_car_1",
    "YourModClass_truck_1"
];
```

## Performance Considerations

- **Spawn Radius**: Smaller radius = better performance
- **Max Civilians/Vehicles**: Lower numbers = better performance
- **Update Interval**: Higher interval = better performance (but less responsive)
- **Despawn Radius**: Should be 50-100m larger than spawn radius for smooth transitions

## Troubleshooting

### Civilians Not Spawning
- Check that `CIV_DEBUG_MODE = true` to see debug messages
- Verify script is running: Check RPT log for initialization message
- Ensure there are valid spawn positions (not in water, buildings, etc.)

### Too Many Civilians
- Reduce `CIV_MAX_CIVILIANS` and `CIV_MAX_VEHICLES` in config
- Decrease `CIV_SPAWN_CHANCE` and `CIV_VEHICLE_SPAWN_CHANCE`

### Server Lag
- Reduce maximum civilians/vehicles
- Increase `CIV_UPDATE_INTERVAL`
- Decrease `CIV_SPAWN_RADIUS`
- Ensure `CIV_DESPAWN_RADIUS` is working (check with debug mode)

### Civilians Getting Stuck
- Increase `CIV_WAYPOINT_RADIUS` for more movement
- Check map for obstacles blocking waypoints
- Enable debug mode to see waypoint assignments

## Compatibility

- **Arma 3**: Version 1.00 and above
- **Mods**: Compatible with most mods
- **CBA**: Optional but recommended for better performance
- **Multiplayer**: Fully compatible (server-side only)
- **Dedicated Servers**: Fully supported

## Advanced Features

### Manual Control

Stop the script:
```sqf
CIV_active = false;
```

Restart the script:
```sqf
CIV_active = true;
```

Clean up all civilians immediately:
```sqf
call CIV_fnc_cleanupCivilians;
```

### Integration with Other Scripts

The script stores data on spawned units that can be queried:
```sqf
// Check if a unit is a spawned civilian
_isCivilian = _unit getVariable ["CIV_type", ""] == "pedestrian";

// Get the player who triggered spawn
_spawnedBy = _unit getVariable ["CIV_spawnedBy", objNull];

// Get spawn time
_spawnTime = _unit getVariable ["CIV_spawnTime", 0];
```

## Credits

Created by tbolen23 for dynamic urban mission environments in Arma 3.

## License

Free to use and modify for any Arma 3 mission or mod. Attribution appreciated but not required.

## Version History

### v1.1 (2025-11-15)
- Changed to squad-based spawning system (spawns around squads instead of individual players)
- Improved performance by reducing spawn calculations
- Solo players automatically treated as a squad of one
- Updated documentation to reflect squad-based system

### v1.0 (2025-11-15)
- Initial release
- Dynamic civilian and vehicle spawning
- Automatic despawn system
- Configurable parameters
- CBA compatibility
