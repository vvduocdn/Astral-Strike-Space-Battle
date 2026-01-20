import 'dart:math' as math;
import 'package:flame/components.dart';
import '../../models/space_event.dart';
import '../components/space_events.dart';
import '../../utils/constants.dart';

class SpaceEventManager {
  final dynamic game; // SpaceShooterGame reference

  ActiveSpaceEvent? _currentEvent;
  double _timeSinceLastEvent = 0;
  final double _minTimeBetweenEvents = 15.0; // seconds
  final double _maxTimeBetweenEvents = 30.0;
  double _nextEventTime = 20.0;

  List<String>? _allowedEvents; // For mission-specific events
  bool _eventsEnabled = false;

  // Visual components
  BlackHole? _blackHole;
  NebulaOverlay? _nebulaOverlay;
  SolarStormEffect? _solarStormEffect;
  RadiationZoneEffect? _radiationZoneEffect;

  // Asteroid/debris spawn tracking
  double _asteroidSpawnTimer = 0;
  double _debrisSpawnTimer = 0;

  SpaceEventManager({required this.game});

  void enableEvents({List<String>? allowedEvents}) {
    _eventsEnabled = true;
    _allowedEvents = allowedEvents;
  }

  void disableEvents() {
    _eventsEnabled = false;
    _clearCurrentEvent();
  }

  bool get hasActiveEvent => _currentEvent?.isActive ?? false;
  ActiveSpaceEvent? get currentEvent => _currentEvent;

  void update(double dt) {
    if (!_eventsEnabled) return;

    // Update current event
    if (_currentEvent != null) {
      _currentEvent!.update(dt);

      // Handle event-specific updates
      _updateEventEffects(dt);

      if (!_currentEvent!.isActive) {
        _clearCurrentEvent();
      }
    } else {
      // Check if it's time to spawn a new event
      _timeSinceLastEvent += dt;

      if (_timeSinceLastEvent >= _nextEventTime) {
        _spawnRandomEvent();
        _timeSinceLastEvent = 0;
        _nextEventTime = _minTimeBetweenEvents +
            math.Random().nextDouble() *
                (_maxTimeBetweenEvents - _minTimeBetweenEvents);
      }
    }
  }

  void _updateEventEffects(double dt) {
    if (_currentEvent == null) return;

    switch (_currentEvent!.type) {
      case SpaceEventType.blackHole:
        _updateBlackHole(dt);
        break;
      case SpaceEventType.asteroidField:
        _updateAsteroidField(dt);
        break;
      case SpaceEventType.debris:
        _updateDebris(dt);
        break;
      case SpaceEventType.wormhole:
        _updateWormhole(dt);
        break;
      case SpaceEventType.radiationZone:
        _updateRadiationZone(dt);
        break;
      default:
        break;
    }
  }

  void _spawnRandomEvent() {
    List<SpaceEventType> availableEvents;

    if (_allowedEvents != null && _allowedEvents!.isNotEmpty) {
      // Use mission-specific events
      availableEvents = _allowedEvents!
          .map((name) => _getEventTypeFromName(name))
          .where((type) => type != null)
          .cast<SpaceEventType>()
          .toList();
    } else {
      // Use all events
      availableEvents = SpaceEventType.values;
    }

    if (availableEvents.isEmpty) return;

    // Pick random event
    final randomIndex = math.Random().nextInt(availableEvents.length);
    final eventType = availableEvents[randomIndex];

    _startEvent(eventType);
  }

  SpaceEventType? _getEventTypeFromName(String name) {
    switch (name.toLowerCase()) {
      case 'blackhole':
        return SpaceEventType.blackHole;
      case 'solarstorm':
        return SpaceEventType.solarStorm;
      case 'asteroidfield':
        return SpaceEventType.asteroidField;
      case 'wormhole':
        return SpaceEventType.wormhole;
      case 'nebula':
        return SpaceEventType.nebula;
      case 'magneticfield':
        return SpaceEventType.magneticField;
      case 'debris':
        return SpaceEventType.debris;
      case 'radiationzone':
        return SpaceEventType.radiationZone;
      default:
        return null;
    }
  }

  void _startEvent(SpaceEventType type) {
    final config = SpaceEventConfig.getConfig(type);

    _currentEvent = ActiveSpaceEvent(
      type: type,
      config: config,
      remainingTime: config.duration,
      centerPosition: _getRandomPosition(),
    );

    _addVisualEffects(type);
  }

  void _addVisualEffects(SpaceEventType type) {
    switch (type) {
      case SpaceEventType.blackHole:
        final center = _currentEvent!.centerPosition!;
        _blackHole = BlackHole(center: center);
        game.world.add(_blackHole);
        break;

      case SpaceEventType.solarStorm:
        _solarStormEffect = SolarStormEffect();
        game.world.add(_solarStormEffect);
        break;

      case SpaceEventType.nebula:
        _nebulaOverlay = NebulaOverlay(
          nebulaColor: _currentEvent!.config.effectColor,
        );
        game.world.add(_nebulaOverlay);
        break;

      case SpaceEventType.wormhole:
        final center = _currentEvent!.centerPosition!;
        final wormhole = Wormhole(center: center);
        game.world.add(wormhole);
        break;

      case SpaceEventType.radiationZone:
        _radiationZoneEffect = RadiationZoneEffect();
        game.world.add(_radiationZoneEffect);
        break;

      default:
        break;
    }
  }

  void _updateBlackHole(double dt) {
    if (_blackHole == null) return;

    // Apply pull force to player
    final pullForce = _blackHole!.getPullForce(game.player.position);
    game.player.position.add(pullForce);
  }

  void _updateAsteroidField(double dt) {
    _asteroidSpawnTimer += dt;

    if (_asteroidSpawnTimer >= 1.5) {
      // Spawn asteroid every 1.5 seconds
      _spawnAsteroid();
      _asteroidSpawnTimer = 0;
    }
  }

  void _updateDebris(double dt) {
    _debrisSpawnTimer += dt;

    if (_debrisSpawnTimer >= 1.0) {
      // Spawn debris every second
      _spawnDebris();
      _debrisSpawnTimer = 0;
    }
  }

  void _updateWormhole(double dt) {
    // Random teleportation chance
    if (math.Random().nextDouble() < 0.02) {
      // 2% chance per frame
      _teleportPlayer();
    }
  }

  void _updateRadiationZone(double dt) {
    // Apply constant damage to player
    if (math.Random().nextDouble() < 0.05) {
      // 5% chance per frame for small damage
      game.onPlayerHit(2);
    }
  }

  void _spawnAsteroid() {
    final random = math.Random();

    // Spawn from top or sides
    Vector2 position;
    Vector2 velocity;

    if (random.nextBool()) {
      // From top
      position = Vector2(
        random.nextDouble() * GameConstants.gameWidth,
        -30,
      );
      velocity = Vector2(
        (random.nextDouble() - 0.5) * 50,
        100 + random.nextDouble() * 100,
      );
    } else {
      // From side
      position = Vector2(
        random.nextBool() ? -30 : GameConstants.gameWidth + 30,
        random.nextDouble() * GameConstants.gameHeight * 0.5,
      );
      velocity = Vector2(
        position.x < 0 ? 100 : -100,
        50 + random.nextDouble() * 100,
      );
    }

    final asteroid = Asteroid(position: position, velocity: velocity);
    game.world.add(asteroid);
  }

  void _spawnDebris() {
    final random = math.Random();

    final position = Vector2(
      random.nextDouble() * GameConstants.gameWidth,
      -20,
    );

    final velocity = Vector2(
      (random.nextDouble() - 0.5) * 80,
      80 + random.nextDouble() * 80,
    );

    final debris = SpaceDebris(position: position, velocity: velocity);
    game.world.add(debris);
  }

  void _teleportPlayer() {
    final random = math.Random();
    final newX = 50 + random.nextDouble() * (GameConstants.gameWidth - 100);
    final newY = 100 + random.nextDouble() * (GameConstants.gameHeight - 200);

    game.player.position = Vector2(newX, newY);
  }

  Vector2 _getRandomPosition() {
    final random = math.Random();
    return Vector2(
      50 + random.nextDouble() * (GameConstants.gameWidth - 100),
      100 + random.nextDouble() * 300,
    );
  }

  void _clearCurrentEvent() {
    if (_currentEvent == null) return;

    // Remove visual effects
    _blackHole?.removeFromParent();
    _blackHole = null;

    if (_nebulaOverlay != null) {
      _nebulaOverlay!.fadeOut();
      Future.delayed(const Duration(seconds: 1), () {
        _nebulaOverlay?.removeFromParent();
        _nebulaOverlay = null;
      });
    }

    _solarStormEffect?.removeFromParent();
    _solarStormEffect = null;

    _radiationZoneEffect?.removeFromParent();
    _radiationZoneEffect = null;

    // Remove asteroids and debris
    game.world.children.whereType<Asteroid>().forEach((a) => a.removeFromParent());
    game.world.children.whereType<SpaceDebris>().forEach((d) => d.removeFromParent());
    game.world.children.whereType<Wormhole>().forEach((w) => w.removeFromParent());

    _currentEvent = null;
    _asteroidSpawnTimer = 0;
    _debrisSpawnTimer = 0;
  }

  // Special effect checks for gameplay
  bool isShieldDisabled() {
    return _currentEvent?.type == SpaceEventType.solarStorm &&
        _currentEvent!.isActive;
  }

  bool hasReducedVisibility() {
    return _currentEvent?.type == SpaceEventType.nebula &&
        _currentEvent!.isActive;
  }

  bool hasMagneticInterference() {
    return _currentEvent?.type == SpaceEventType.magneticField &&
        _currentEvent!.isActive;
  }

  // Handle collision with space hazards
  bool checkAsteroidCollision(Vector2 position, double radius) {
    for (final asteroid in game.world.children.whereType<Asteroid>()) {
      final distance = (asteroid.position - position).length;
      if (distance < radius + asteroid.size.x / 2) {
        asteroid.removeFromParent();
        return true; // Collision detected
      }
    }
    return false;
  }

  bool checkDebrisCollision(Vector2 position, double radius) {
    for (final debris in game.world.children.whereType<SpaceDebris>()) {
      final distance = (debris.position - position).length;
      if (distance < radius + debris.size.x / 2) {
        debris.removeFromParent();
        return true; // Collision detected
      }
    }
    return false;
  }

  void reset() {
    _clearCurrentEvent();
    _timeSinceLastEvent = 0;
    _nextEventTime = 20.0;
  }
}
