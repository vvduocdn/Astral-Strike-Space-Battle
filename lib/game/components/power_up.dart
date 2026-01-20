import 'dart:math' as math;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../space_shooter_game.dart';
import 'animated_player.dart';

class PowerUp extends PositionComponent with HasGameRef<SpaceShooterGame>, CollisionCallbacks {
  final PowerUpType type;

  double _bobTimer = 0;
  double _glowTimer = 0;
  double _spawnDelay = 0.5; // Delay before can be collected
  bool _canCollect = false;

  PowerUp({
    required Vector2 position,
    required this.type,
  }) : super(
          position: position,
          size: Vector2.all(GameConstants.powerUpSize),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox());
  }

  Color get color {
    switch (type) {
      case PowerUpType.health:
        return GameColors.health;
      case PowerUpType.shield:
        return GameColors.shield;
      case PowerUpType.weaponUpgrade:
        return GameColors.primary;
      case PowerUpType.speedBoost:
        return GameColors.warning;
      case PowerUpType.scoreMultiplier:
        return GameColors.coin;
      case PowerUpType.bomb:
        return GameColors.danger;
    }
  }

  IconData get icon {
    switch (type) {
      case PowerUpType.health:
        return Icons.favorite;
      case PowerUpType.shield:
        return Icons.shield;
      case PowerUpType.weaponUpgrade:
        return Icons.bolt;
      case PowerUpType.speedBoost:
        return Icons.speed;
      case PowerUpType.scoreMultiplier:
        return Icons.stars;
      case PowerUpType.bomb:
        return Icons.brightness_7;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final glowIntensity = 0.3 + math.sin(_glowTimer * 5) * 0.2;

    // Outer glow
    final glowPaint = Paint()
      ..color = color.withOpacity(glowIntensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2 + 5,
      glowPaint,
    );

    // Main circle
    final paint = Paint()..color = color;
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2 - 2,
      paint,
    );

    // Inner highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.5);
    canvas.drawCircle(
      Offset(size.x / 2 - 5, size.y / 2 - 5),
      size.x / 6,
      highlightPaint,
    );

    // Draw icon symbol
    _drawSymbol(canvas);
  }

  void _drawSymbol(Canvas canvas) {
    final symbolPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.x / 2, size.y / 2);

    switch (type) {
      case PowerUpType.health:
        // Plus sign
        canvas.drawLine(
          Offset(center.dx - 8, center.dy),
          Offset(center.dx + 8, center.dy),
          symbolPaint,
        );
        canvas.drawLine(
          Offset(center.dx, center.dy - 8),
          Offset(center.dx, center.dy + 8),
          symbolPaint,
        );
        break;

      case PowerUpType.shield:
        // Shield shape
        final path = Path();
        path.moveTo(center.dx, center.dy - 10);
        path.lineTo(center.dx + 10, center.dy - 5);
        path.lineTo(center.dx + 10, center.dy + 5);
        path.lineTo(center.dx, center.dy + 12);
        path.lineTo(center.dx - 10, center.dy + 5);
        path.lineTo(center.dx - 10, center.dy - 5);
        path.close();
        canvas.drawPath(path, symbolPaint);
        break;

      case PowerUpType.weaponUpgrade:
        // Lightning bolt
        final path = Path();
        path.moveTo(center.dx + 5, center.dy - 10);
        path.lineTo(center.dx - 2, center.dy);
        path.lineTo(center.dx + 2, center.dy);
        path.lineTo(center.dx - 5, center.dy + 10);
        path.lineTo(center.dx + 2, center.dy);
        path.lineTo(center.dx - 2, center.dy);
        path.close();
        canvas.drawPath(path, symbolPaint..style = PaintingStyle.fill);
        break;

      case PowerUpType.speedBoost:
        // Arrow
        canvas.drawLine(
          Offset(center.dx - 8, center.dy),
          Offset(center.dx + 8, center.dy),
          symbolPaint,
        );
        canvas.drawLine(
          Offset(center.dx + 3, center.dy - 5),
          Offset(center.dx + 8, center.dy),
          symbolPaint,
        );
        canvas.drawLine(
          Offset(center.dx + 3, center.dy + 5),
          Offset(center.dx + 8, center.dy),
          symbolPaint,
        );
        break;

      case PowerUpType.scoreMultiplier:
        // Star shape
        final path = Path();
        for (int i = 0; i < 5; i++) {
          final angle = (i * 72 - 90) * math.pi / 180;
          final innerAngle = ((i * 72) + 36 - 90) * math.pi / 180;
          if (i == 0) {
            path.moveTo(
              center.dx + math.cos(angle) * 10,
              center.dy + math.sin(angle) * 10,
            );
          } else {
            path.lineTo(
              center.dx + math.cos(angle) * 10,
              center.dy + math.sin(angle) * 10,
            );
          }
          path.lineTo(
            center.dx + math.cos(innerAngle) * 5,
            center.dy + math.sin(innerAngle) * 5,
          );
        }
        path.close();
        canvas.drawPath(path, symbolPaint..style = PaintingStyle.fill);
        break;

      case PowerUpType.bomb:
        // Explosion symbol
        canvas.drawCircle(center, 6, symbolPaint);
        for (int i = 0; i < 8; i++) {
          final angle = i * math.pi / 4;
          canvas.drawLine(
            Offset(
              center.dx + math.cos(angle) * 6,
              center.dy + math.sin(angle) * 6,
            ),
            Offset(
              center.dx + math.cos(angle) * 10,
              center.dy + math.sin(angle) * 10,
            ),
            symbolPaint,
          );
        }
        break;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update spawn delay
    if (!_canCollect) {
      _spawnDelay -= dt;
      if (_spawnDelay <= 0) {
        _canCollect = true;
      }
    }

    _bobTimer += dt;
    _glowTimer += dt;

    // Bob up and down
    position.y += GameConstants.powerUpSpeed * dt;
    position.x += math.sin(_bobTimer * 4) * 30 * dt;

    // Remove if off screen
    if (position.y > GameConstants.gameHeight + 50) {
      removeFromParent();
    }
  }

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    super.onCollision(points, other);

    // Only collect after spawn delay
    if (!_canCollect) return;

    if (other is AnimatedPlayer) {
      gameRef.collectPowerUp(type);
      removeFromParent();
    }
  }
}
