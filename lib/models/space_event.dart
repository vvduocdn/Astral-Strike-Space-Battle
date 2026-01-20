import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Dynamic space events that create unique challenges
enum SpaceEventType {
  blackHole, // Pulls player toward center
  solarStorm, // Disables shields and adds visual effects
  asteroidField, // Spawn multiple asteroids to dodge
  wormhole, // Teleports player randomly
  nebula, // Reduces visibility
  magneticField, // Affects bullet trajectory
  debris, // Floating obstacles
  radiationZone, // Constant damage over time
}

class SpaceEventConfig {
  final SpaceEventType type;
  final String name;
  final String description;
  final double duration; // seconds
  final double spawnChance; // 0.0 - 1.0
  final Color effectColor;

  const SpaceEventConfig({
    required this.type,
    required this.name,
    required this.description,
    required this.duration,
    required this.spawnChance,
    required this.effectColor,
  });

  static const Map<SpaceEventType, SpaceEventConfig> configs = {
    SpaceEventType.blackHole: SpaceEventConfig(
      type: SpaceEventType.blackHole,
      name: 'Black Hole',
      description: 'Gravitational pull detected!',
      duration: 10.0,
      spawnChance: 0.15,
      effectColor: Color(0xFF9D00FF),
    ),
    SpaceEventType.solarStorm: SpaceEventConfig(
      type: SpaceEventType.solarStorm,
      name: 'Solar Storm',
      description: 'Shield systems offline!',
      duration: 8.0,
      spawnChance: 0.2,
      effectColor: Color(0xFFFF6B00),
    ),
    SpaceEventType.asteroidField: SpaceEventConfig(
      type: SpaceEventType.asteroidField,
      name: 'Asteroid Field',
      description: 'Navigate carefully!',
      duration: 12.0,
      spawnChance: 0.25,
      effectColor: Color(0xFF888888),
    ),
    SpaceEventType.wormhole: SpaceEventConfig(
      type: SpaceEventType.wormhole,
      name: 'Wormhole',
      description: 'Space-time distortion!',
      duration: 5.0,
      spawnChance: 0.1,
      effectColor: Color(0xFF00FFFF),
    ),
    SpaceEventType.nebula: SpaceEventConfig(
      type: SpaceEventType.nebula,
      name: 'Nebula Cloud',
      description: 'Visibility reduced!',
      duration: 15.0,
      spawnChance: 0.2,
      effectColor: Color(0xFFFF00FF),
    ),
    SpaceEventType.magneticField: SpaceEventConfig(
      type: SpaceEventType.magneticField,
      name: 'Magnetic Field',
      description: 'Weapons malfunction!',
      duration: 10.0,
      spawnChance: 0.15,
      effectColor: Color(0xFF00AAFF),
    ),
    SpaceEventType.debris: SpaceEventConfig(
      type: SpaceEventType.debris,
      name: 'Space Debris',
      description: 'Collision warning!',
      duration: 12.0,
      spawnChance: 0.2,
      effectColor: Color(0xFFAAAAAA),
    ),
    SpaceEventType.radiationZone: SpaceEventConfig(
      type: SpaceEventType.radiationZone,
      name: 'Radiation Zone',
      description: 'Hull taking damage!',
      duration: 8.0,
      spawnChance: 0.15,
      effectColor: Color(0xFF00FF00),
    ),
  };

  static SpaceEventConfig getConfig(SpaceEventType type) {
    return configs[type]!;
  }
}

class ActiveSpaceEvent {
  final SpaceEventType type;
  final SpaceEventConfig config;
  double remainingTime;
  Vector2? centerPosition; // For black holes, wormholes
  bool isActive;

  ActiveSpaceEvent({
    required this.type,
    required this.config,
    required this.remainingTime,
    this.centerPosition,
    this.isActive = true,
  });

  void update(double dt) {
    if (isActive) {
      remainingTime -= dt;
      if (remainingTime <= 0) {
        isActive = false;
      }
    }
  }

  double get progress => remainingTime / config.duration;
}
