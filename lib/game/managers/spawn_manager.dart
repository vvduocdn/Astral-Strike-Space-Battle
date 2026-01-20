import 'dart:math' as math;
import 'package:flame/components.dart';
import '../../utils/constants.dart';
import '../space_shooter_game.dart';
import '../components/animated_enemy.dart';

class SpawnManager {
  final SpaceShooterGame game;

  double _spawnTimer = 0;
  double _spawnInterval = 2.0;
  int _waveCount = 0;

  final math.Random _random = math.Random();

  SpawnManager({required this.game});

  void update(double dt) {
    if (game.gameState != GameState.playing) return;
    if (game.isBossLevel && game.bossSpawned) return;

    _spawnTimer += dt;

    // Adjust spawn rate based on level
    _spawnInterval = (2.0 - game.currentLevel * 0.05).clamp(0.5, 2.0);

    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      _spawnWave();
    }
  }

  void _spawnWave() {
    _waveCount++;

    // Determine wave type
    if (_waveCount % 5 == 0) {
      _spawnFormation();
    } else {
      _spawnRandom();
    }
  }

  void _spawnRandom() {
    final count = 1 + _random.nextInt(2 + game.currentLevel ~/ 5);

    for (int i = 0; i < count; i++) {
      final type = _getRandomEnemyType();
      final x = 50 + _random.nextDouble() * (GameConstants.gameWidth - 100);

      game.world.add(AnimatedEnemy(
        position: Vector2(x, -50 - i * 60),
        type: type,
        level: game.currentLevel,
      ));
    }
  }

  void _spawnFormation() {
    final formationType = _random.nextInt(3);

    switch (formationType) {
      case 0: // V formation
        _spawnVFormation();
        break;
      case 1: // Line formation
        _spawnLineFormation();
        break;
      case 2: // Diamond formation
        _spawnDiamondFormation();
        break;
    }
  }

  void _spawnVFormation() {
    final type = _getRandomEnemyType();
    final centerX = GameConstants.gameWidth / 2;

    for (int i = 0; i < 5; i++) {
      final offsetX = (i - 2) * 50.0;
      final offsetY = (i - 2).abs() * 40.0;

      game.world.add(AnimatedEnemy(
        position: Vector2(centerX + offsetX, -50 - offsetY),
        type: type,
        level: game.currentLevel,
      ));
    }
  }

  void _spawnLineFormation() {
    final type = _getRandomEnemyType();
    final count = 4 + _random.nextInt(3);
    final spacing = (GameConstants.gameWidth - 100) / (count - 1);

    for (int i = 0; i < count; i++) {
      game.world.add(AnimatedEnemy(
        position: Vector2(50 + i * spacing, -50),
        type: type,
        level: game.currentLevel,
      ));
    }
  }

  void _spawnDiamondFormation() {
    final type = _getRandomEnemyType();
    final centerX = GameConstants.gameWidth / 2;

    final positions = [
      Vector2(centerX, -50),
      Vector2(centerX - 50, -100),
      Vector2(centerX + 50, -100),
      Vector2(centerX, -150),
    ];

    for (final pos in positions) {
      game.world.add(AnimatedEnemy(
        position: pos,
        type: type,
        level: game.currentLevel,
      ));
    }
  }

  EnemyType _getRandomEnemyType() {
    final level = game.currentLevel;
    final availableTypes = <EnemyType>[];

    // Basic always available
    availableTypes.add(EnemyType.basic);
    availableTypes.add(EnemyType.basic); // Higher chance

    // Unlock more types as level increases
    if (level >= 2) {
      availableTypes.add(EnemyType.fast);
    }
    if (level >= 4) {
      availableTypes.add(EnemyType.zigzag);
    }
    if (level >= 6) {
      availableTypes.add(EnemyType.shooter);
    }
    if (level >= 8) {
      availableTypes.add(EnemyType.tank);
    }

    return availableTypes[_random.nextInt(availableTypes.length)];
  }

  void reset() {
    _spawnTimer = 0;
    _waveCount = 0;
  }
}
