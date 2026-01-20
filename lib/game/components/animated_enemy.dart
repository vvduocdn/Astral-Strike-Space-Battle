import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../space_shooter_game.dart';
import 'bullet.dart';
import 'animated_explosion.dart';
import 'animated_player.dart';

class AnimatedEnemy extends PositionComponent
    with HasGameReference<SpaceShooterGame>, CollisionCallbacks {
  final EnemyType type;
  final int level;

  int health = 20;
  int points = 100;
  int coins = 5;
  double speed = GameConstants.enemySpeed;

  double _shootTimer = 0;
  double _shootInterval = 2.0;
  double _movementTimer = 0;
  double _zigzagDirection = 1;

  // Animation
  double _enginePulse = 0;
  double _damageFlash = 0;
  double _wobble = 0;

  AnimatedEnemy({
    required Vector2 position,
    required this.type,
    this.level = 1,
  }) : super(
          position: position,
          size: Vector2(GameConstants.enemyWidth, GameConstants.enemyHeight),
          anchor: Anchor.center,
        ) {
    _initializeStats();
  }

  void _initializeStats() {
    switch (type) {
      case EnemyType.basic:
        health = 20 + (level * 5);
        speed = GameConstants.enemySpeed;
        points = 100;
        coins = 5;
        break;
      case EnemyType.fast:
        health = 15 + (level * 3);
        speed = GameConstants.enemySpeed * 1.8;
        points = 150;
        coins = 8;
        break;
      case EnemyType.tank:
        health = 50 + (level * 10);
        speed = GameConstants.enemySpeed * 0.6;
        points = 200;
        coins = 15;
        size = Vector2(
            GameConstants.enemyWidth * 1.3, GameConstants.enemyHeight * 1.3);
        break;
      case EnemyType.shooter:
        health = 25 + (level * 5);
        speed = GameConstants.enemySpeed * 0.8;
        points = 180;
        coins = 10;
        _shootInterval = 1.5 - (level * 0.1).clamp(0, 0.8);
        break;
      case EnemyType.zigzag:
        health = 18 + (level * 4);
        speed = GameConstants.enemySpeed * 1.2;
        points = 130;
        coins = 7;
        break;
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  Color get _baseColor {
    switch (type) {
      case EnemyType.basic:
        return GameColors.danger;
      case EnemyType.fast:
        return GameColors.warning;
      case EnemyType.tank:
        return Colors.grey.shade600;
      case EnemyType.shooter:
        return GameColors.accent;
      case EnemyType.zigzag:
        return Colors.green.shade400;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Apply damage flash
    final flashColor = _damageFlash > 0 ? Colors.white : _baseColor;

    // Draw based on enemy type
    switch (type) {
      case EnemyType.basic:
        _drawBasicEnemy(canvas, flashColor);
        break;
      case EnemyType.fast:
        _drawFastEnemy(canvas, flashColor);
        break;
      case EnemyType.tank:
        _drawTankEnemy(canvas, flashColor);
        break;
      case EnemyType.shooter:
        _drawShooterEnemy(canvas, flashColor);
        break;
      case EnemyType.zigzag:
        _drawZigzagEnemy(canvas, flashColor);
        break;
    }
  }

  void _drawBasicEnemy(Canvas canvas, Color color) {
    // Apply wobble
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(math.sin(_wobble * 3) * 0.1);
    canvas.translate(-size.x / 2, -size.y / 2);

    // Body gradient
    final gradient = ui.Gradient.linear(
      Offset(size.x / 2, 0),
      Offset(size.x / 2, size.y),
      [color, color.withAlpha(180)],
    );

    final paint = Paint()..shader = gradient;

    // Ship body
    final path = Path();
    path.moveTo(size.x / 2, size.y);
    path.quadraticBezierTo(size.x * 0.9, size.y * 0.6, size.x * 0.85, size.y * 0.2);
    path.lineTo(size.x * 0.6, 0);
    path.lineTo(size.x * 0.4, 0);
    path.lineTo(size.x * 0.15, size.y * 0.2);
    path.quadraticBezierTo(size.x * 0.1, size.y * 0.6, size.x / 2, size.y);
    path.close();

    canvas.drawPath(path, paint);

    // Cockpit
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y * 0.55),
        width: size.x * 0.25,
        height: size.y * 0.2,
      ),
      Paint()..color = Colors.red.shade900,
    );

    // Engine glow
    _drawEnemyEngine(canvas, size.x / 2, -5);

    canvas.restore();
  }

  void _drawFastEnemy(Canvas canvas, Color color) {
    // Sleek fast design
    final paint = Paint()..color = color;

    final path = Path();
    path.moveTo(size.x / 2, size.y);
    path.lineTo(size.x * 0.95, size.y * 0.3);
    path.lineTo(size.x * 0.7, size.y * 0.15);
    path.lineTo(size.x / 2, 0);
    path.lineTo(size.x * 0.3, size.y * 0.15);
    path.lineTo(size.x * 0.05, size.y * 0.3);
    path.close();

    canvas.drawPath(path, paint);

    // Speed lines
    final linePaint = Paint()
      ..color = color.withAlpha(100)
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(size.x * 0.3, -10),
      Offset(size.x * 0.3, -25),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.x * 0.7, -10),
      Offset(size.x * 0.7, -25),
      linePaint,
    );

    // Double engines
    _drawEnemyEngine(canvas, size.x * 0.35, -5, small: true);
    _drawEnemyEngine(canvas, size.x * 0.65, -5, small: true);
  }

  void _drawTankEnemy(Canvas canvas, Color color) {
    // Heavy armored design
    final paint = Paint()..color = color;

    // Main body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * 0.1, size.y * 0.1, size.x * 0.8, size.y * 0.8),
        const Radius.circular(8),
      ),
      paint,
    );

    // Armor plates
    final armorPaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRect(
      Rect.fromLTWH(size.x * 0.2, size.y * 0.2, size.x * 0.6, size.y * 0.6),
      armorPaint,
    );

    // Front plate
    canvas.drawRect(
      Rect.fromLTWH(size.x * 0.3, size.y * 0.7, size.x * 0.4, size.y * 0.2),
      Paint()..color = Colors.grey.shade700,
    );

    // Health indicator
    final healthPercent = health / (50 + level * 10);
    canvas.drawRect(
      Rect.fromLTWH(size.x * 0.15, size.y * 0.05, size.x * 0.7 * healthPercent, 4),
      Paint()..color = healthPercent > 0.5 ? Colors.green : Colors.red,
    );
  }

  void _drawShooterEnemy(Canvas canvas, Color color) {
    final paint = Paint()..color = color;

    // Main body
    final path = Path();
    path.moveTo(size.x / 2, size.y * 0.9);
    path.lineTo(size.x * 0.85, size.y * 0.4);
    path.lineTo(size.x * 0.7, size.y * 0.2);
    path.lineTo(size.x / 2, 0);
    path.lineTo(size.x * 0.3, size.y * 0.2);
    path.lineTo(size.x * 0.15, size.y * 0.4);
    path.close();

    canvas.drawPath(path, paint);

    // Cannons
    final cannonPaint = Paint()..color = Colors.grey.shade800;

    // Left cannon
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * 0.1, size.y * 0.6, 8, 20),
        const Radius.circular(2),
      ),
      cannonPaint,
    );

    // Right cannon
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * 0.8, size.y * 0.6, 8, 20),
        const Radius.circular(2),
      ),
      cannonPaint,
    );

    // Cannon glow when about to shoot
    if (_shootTimer > _shootInterval * 0.8) {
      final glowPaint = Paint()
        ..color = GameColors.danger.withAlpha(150)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      canvas.drawCircle(Offset(size.x * 0.14, size.y * 0.85), 5, glowPaint);
      canvas.drawCircle(Offset(size.x * 0.84, size.y * 0.85), 5, glowPaint);
    }
  }

  void _drawZigzagEnemy(Canvas canvas, Color color) {
    // Apply zigzag rotation
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(_zigzagDirection * 0.2);
    canvas.translate(-size.x / 2, -size.y / 2);

    final paint = Paint()..color = color;

    // Angular design
    final path = Path();
    path.moveTo(size.x / 2, size.y);
    path.lineTo(size.x * 0.9, size.y * 0.5);
    path.lineTo(size.x * 0.75, size.y * 0.3);
    path.lineTo(size.x * 0.6, size.y * 0.4);
    path.lineTo(size.x / 2, 0);
    path.lineTo(size.x * 0.4, size.y * 0.4);
    path.lineTo(size.x * 0.25, size.y * 0.3);
    path.lineTo(size.x * 0.1, size.y * 0.5);
    path.close();

    canvas.drawPath(path, paint);

    // Direction indicator
    final indicatorPaint = Paint()
      ..color = Colors.white.withAlpha(150)
      ..strokeWidth = 2;

    if (_zigzagDirection > 0) {
      canvas.drawLine(
        Offset(size.x * 0.7, size.y * 0.5),
        Offset(size.x * 0.85, size.y * 0.5),
        indicatorPaint,
      );
    } else {
      canvas.drawLine(
        Offset(size.x * 0.3, size.y * 0.5),
        Offset(size.x * 0.15, size.y * 0.5),
        indicatorPaint,
      );
    }

    canvas.restore();
  }

  void _drawEnemyEngine(Canvas canvas, double x, double y, {bool small = false}) {
    final flameSize = (small ? 8 : 12) * (0.8 + math.sin(_enginePulse * 10) * 0.2);

    final outerPaint = Paint()
      ..color = Colors.cyan.withAlpha(180)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x, y),
        width: flameSize,
        height: flameSize * 1.5,
      ),
      outerPaint,
    );

    final innerPaint = Paint()
      ..color = Colors.white.withAlpha(200)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x, y),
        width: flameSize * 0.4,
        height: flameSize * 0.8,
      ),
      innerPaint,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    _movementTimer += dt;
    _enginePulse += dt;
    _wobble += dt;

    // Damage flash decay
    if (_damageFlash > 0) {
      _damageFlash -= dt * 5;
    }

    // Movement patterns
    switch (type) {
      case EnemyType.basic:
      case EnemyType.tank:
        position.y += speed * dt;
        break;
      case EnemyType.fast:
        position.y += speed * dt;
        position.x += math.sin(_movementTimer * 3) * 50 * dt;
        break;
      case EnemyType.shooter:
        position.y += speed * dt;
        if (position.y > GameConstants.gameHeight * 0.2 &&
            position.y < GameConstants.gameHeight * 0.4) {
          position.y -= speed * dt * 0.8;
        }
        break;
      case EnemyType.zigzag:
        position.y += speed * dt;
        position.x += _zigzagDirection * speed * dt;
        if (position.x <= size.x / 2 ||
            position.x >= GameConstants.gameWidth - size.x / 2) {
          _zigzagDirection *= -1;
        }
        break;
    }

    // Shooting
    if (type == EnemyType.shooter) {
      _shootTimer += dt;
      if (_shootTimer >= _shootInterval) {
        _shootTimer = 0;
        _shoot();
      }
    }

    // Remove if off screen
    if (position.y > GameConstants.gameHeight + 50) {
      removeFromParent();
    }

    // Clamp X position
    position.x =
        position.x.clamp(size.x / 2, GameConstants.gameWidth - size.x / 2);
  }

  void _shoot() {
    game.world.add(EnemyBullet(
      position: Vector2(position.x, position.y + size.y / 2),
      damage: 10 + level * 2,
    ));
  }

  void takeDamage(int damage) {
    health -= damage;
    _damageFlash = 1.0;

    if (health <= 0) {
      die();
    }
  }

  void die() {
    game.world.add(AnimatedExplosion(
      position: position.clone(),
      isLarge: type == EnemyType.tank,
    ));
    game.onEnemyKilled(points, coins, enemyType: type);
    game.spawnPowerUp(position.clone());
    removeFromParent();
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is AnimatedPlayer) {
      game.onPlayerHit(20);
      die();
    }
  }
}
