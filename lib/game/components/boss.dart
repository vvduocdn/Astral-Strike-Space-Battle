import 'dart:math' as math;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../space_shooter_game.dart';
import 'bullet.dart';
import 'explosion.dart';
import 'animated_player.dart';

class Boss extends PositionComponent with HasGameRef<SpaceShooterGame>, CollisionCallbacks {
  final int bossType;
  final int level;

  int health = 500;
  int maxHealth = 500;
  int points = 1000;
  int coins = 100;

  double _shootTimer = 0;
  double _movementTimer = 0;
  double _phaseTimer = 0;
  int _attackPhase = 0;

  bool _hasEntered = false;
  final double _entryY = 100;

  Boss({
    required Vector2 position,
    required this.bossType,
    required this.level,
  }) : super(
          position: position,
          size: Vector2(GameConstants.bossWidth, GameConstants.bossHeight),
          anchor: Anchor.center,
        ) {
    // Balanced boss health for 50 levels:
    // Level 5: ~350 HP, Level 25: ~700 HP, Level 50: ~1100 HP
    maxHealth = 250 + (level * 15) + (bossType * 30);
    health = maxHealth;
    points = 1000 + (bossType * 300);
    coins = 100 + (bossType * 30);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  Color get bossColor {
    switch (bossType % 10) {
      case 0:
        return Colors.red.shade700;
      case 1:
        return Colors.purple.shade700;
      case 2:
        return Colors.teal.shade700;
      case 3:
        return Colors.orange.shade900;
      case 4:
        return Colors.blue.shade800;
      case 5:
        return Colors.green.shade700;
      case 6:
        return Colors.pink.shade600;
      case 7:
        return Colors.cyan.shade700;
      case 8:
        return Colors.amber.shade800;
      case 9:
      default:
        return Colors.indigo.shade600;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..color = bossColor;

    // Draw large boss ship
    final path = Path();
    // Main body
    path.moveTo(size.x / 2, size.y * 0.9); // Nose
    path.lineTo(size.x, size.y * 0.3); // Right
    path.lineTo(size.x * 0.85, size.y * 0.15);
    path.lineTo(size.x * 0.7, 0);
    path.lineTo(size.x * 0.3, 0);
    path.lineTo(size.x * 0.15, size.y * 0.15);
    path.lineTo(0, size.y * 0.3); // Left
    path.close();
    canvas.drawPath(path, paint);

    // Core
    final corePaint = Paint()
      ..color = Colors.red.shade400
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(
      Offset(size.x / 2, size.y * 0.4),
      size.x * 0.15,
      corePaint,
    );

    // Wings
    final wingPaint = Paint()..color = bossColor.withOpacity(0.8);
    canvas.drawRect(
      Rect.fromLTWH(size.x * -0.2, size.y * 0.2, size.x * 0.3, size.y * 0.3),
      wingPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.x * 0.9, size.y * 0.2, size.x * 0.3, size.y * 0.3),
      wingPaint,
    );

    // Cannons
    final cannonPaint = Paint()..color = Colors.grey.shade800;
    canvas.drawCircle(Offset(size.x * 0.25, size.y * 0.7), 10, cannonPaint);
    canvas.drawCircle(Offset(size.x * 0.75, size.y * 0.7), 10, cannonPaint);
    canvas.drawCircle(Offset(size.x * 0.5, size.y * 0.85), 12, cannonPaint);

    // Health bar
    final healthBarWidth = size.x * 0.8;
    final healthPercent = health / maxHealth;

    canvas.drawRect(
      Rect.fromLTWH(
        size.x * 0.1,
        -20,
        healthBarWidth,
        10,
      ),
      Paint()..color = Colors.grey.shade900,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        size.x * 0.1,
        -20,
        healthBarWidth * healthPercent,
        10,
      ),
      Paint()
        ..color = healthPercent > 0.5
            ? Colors.green
            : healthPercent > 0.25
                ? Colors.orange
                : Colors.red,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Entry animation
    if (!_hasEntered) {
      position.y += 80 * dt;
      if (position.y >= _entryY) {
        position.y = _entryY;
        _hasEntered = true;
      }
      return;
    }

    _movementTimer += dt;
    _shootTimer += dt;
    _phaseTimer += dt;

    // Change attack phase periodically
    if (_phaseTimer > 5.0) {
      _phaseTimer = 0;
      _attackPhase = (_attackPhase + 1) % 3;
    }

    // Movement
    position.x = GameConstants.gameWidth / 2 +
        math.sin(_movementTimer * 1.5) * (GameConstants.gameWidth * 0.3);

    // Attack patterns based on phase
    switch (_attackPhase) {
      case 0: // Single shot
        if (_shootTimer >= 0.8) {
          _shootTimer = 0;
          _shootSingle();
        }
        break;
      case 1: // Spread shot
        if (_shootTimer >= 1.5) {
          _shootTimer = 0;
          _shootSpread();
        }
        break;
      case 2: // Rapid fire
        if (_shootTimer >= 0.3) {
          _shootTimer = 0;
          _shootRapid();
        }
        break;
    }

    // Enrage at low health
    if (health < maxHealth * 0.3) {
      if (_shootTimer >= 0.2) {
        _shootTimer = 0;
        _shootSpread();
      }
    }
  }

  void _shootSingle() {
    gameRef.world.add(EnemyBullet(
      position: Vector2(position.x, position.y + size.y / 2),
      damage: 20,
    ));
  }

  void _shootSpread() {
    for (int i = -2; i <= 2; i++) {
      gameRef.world.add(EnemyBullet(
        position: Vector2(position.x + i * 20, position.y + size.y / 2),
        damage: 15,
        angle: i * 0.15,
      ));
    }
  }

  void _shootRapid() {
    gameRef.world.add(EnemyBullet(
      position: Vector2(position.x - 30, position.y + size.y / 2),
      damage: 10,
    ));
    gameRef.world.add(EnemyBullet(
      position: Vector2(position.x + 30, position.y + size.y / 2),
      damage: 10,
    ));
  }

  void takeDamage(int damage) {
    health -= damage;
    if (health <= 0) {
      die();
    }
  }

  void die() {
    // Multiple explosions for boss
    for (int i = 0; i < 5; i++) {
      final offset = Vector2(
        (math.Random().nextDouble() - 0.5) * size.x,
        (math.Random().nextDouble() - 0.5) * size.y,
      );
      gameRef.world.add(Explosion(
        position: position + offset,
        isLarge: true,
      ));
    }

    gameRef.onEnemyKilled(points, coins, enemyType: null); // Boss is not a regular enemy type
    gameRef.onBossDefeated();
    removeFromParent();
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);

    if (other is AnimatedPlayer) {
      gameRef.onPlayerHit(30);
    }
  }
}
