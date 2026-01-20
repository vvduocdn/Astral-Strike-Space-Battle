import 'dart:math' as math;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../space_shooter_game.dart';
import 'animated_enemy.dart';
import 'boss.dart';
import 'animated_player.dart';

class Bullet extends PositionComponent with HasGameRef<SpaceShooterGame>, CollisionCallbacks {
  final int damage;
  final double angle;
  final bool isMissile;
  final bool isPiercing;
  final bool isThunder;
  final WeaponType weaponType;
  final bool isEnemyBullet;

  Vector2 velocity = Vector2.zero();
  AnimatedEnemy? _missileTarget;

  Bullet({
    required Vector2 position,
    this.damage = 10,
    this.angle = 0,
    this.isMissile = false,
    this.isPiercing = false,
    this.isThunder = false,
    this.weaponType = WeaponType.laser,
    this.isEnemyBullet = false,
  }) : super(
          position: position,
          size: Vector2(
            isThunder ? 4 : GameConstants.bulletWidth,
            isThunder ? 30 : GameConstants.bulletHeight,
          ),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox(isSolid: true));

    final speed = isEnemyBullet
        ? GameConstants.bulletSpeed * 0.6
        : GameConstants.bulletSpeed;

    if (isEnemyBullet) {
      velocity = Vector2(0, speed);
    } else {
      velocity = Vector2(
        math.sin(angle) * speed,
        -math.cos(angle) * speed,
      );
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (isEnemyBullet) {
      _drawEnemyBullet(canvas);
    } else if (isMissile) {
      _drawMissile(canvas);
    } else if (isThunder) {
      _drawThunderBolt(canvas);
    } else if (isPiercing) {
      _drawPlasmaBolt(canvas);
    } else {
      _drawLaserBullet(canvas);
    }
  }

  // Laser bullet - sleek energy beam
  void _drawLaserBullet(Canvas canvas) {
    final Color mainColor;
    final Color glowColor;

    switch (weaponType) {
      case WeaponType.spread:
        mainColor = const Color(0xFFFF6600);
        glowColor = const Color(0xFFFFAA00);
        break;
      default:
        mainColor = const Color(0xFF00DDFF);
        glowColor = const Color(0xFF00FFFF);
    }

    // Outer glow
    final outerGlow = Paint()
      ..color = mainColor.withAlpha(80)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(size.x / 2, size.y / 2), width: size.x + 6, height: size.y + 4),
        const Radius.circular(6),
      ),
      outerGlow,
    );

    // Main body gradient
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [glowColor, mainColor, mainColor.withAlpha(200)],
    ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(4),
      ),
      Paint()..shader = gradient,
    );

    // Core highlight
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(size.x / 2, size.y * 0.3), width: size.x * 0.4, height: size.y * 0.4),
        const Radius.circular(2),
      ),
      Paint()..color = Colors.white.withAlpha(200),
    );

    // Tip glow
    canvas.drawCircle(
      Offset(size.x / 2, 2),
      3,
      Paint()
        ..color = Colors.white
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  // Plasma bolt - glowing energy orb with trail
  void _drawPlasmaBolt(Canvas canvas) {
    final mainColor = const Color(0xFF00FF88);
    final centerX = size.x / 2;
    final centerY = size.y / 2;

    // Outer glow ring
    canvas.drawCircle(
      Offset(centerX, centerY),
      size.x * 0.8,
      Paint()
        ..color = mainColor.withAlpha(60)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Middle glow
    canvas.drawCircle(
      Offset(centerX, centerY),
      size.x * 0.5,
      Paint()
        ..color = mainColor.withAlpha(150)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Core
    final coreGradient = RadialGradient(
      colors: [Colors.white, mainColor, mainColor.withAlpha(0)],
      stops: const [0.0, 0.4, 1.0],
    ).createShader(Rect.fromCircle(center: Offset(centerX, centerY), radius: size.x * 0.5));

    canvas.drawCircle(
      Offset(centerX, centerY),
      size.x * 0.4,
      Paint()..shader = coreGradient,
    );

    // Energy particles
    for (int i = 0; i < 3; i++) {
      final offset = math.sin(DateTime.now().millisecondsSinceEpoch / 100.0 + i) * 3;
      canvas.drawCircle(
        Offset(centerX + offset, centerY + size.y * 0.3 + i * 4),
        2,
        Paint()..color = mainColor.withAlpha(150 - i * 40),
      );
    }
  }

  // Thunder bolt - electric lightning
  void _drawThunderBolt(Canvas canvas) {
    final mainColor = const Color(0xFFFFFF00);
    final centerX = size.x / 2;

    // Electric glow
    canvas.drawRect(
      Rect.fromLTWH(-2, 0, size.x + 4, size.y),
      Paint()
        ..color = mainColor.withAlpha(100)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Lightning zigzag path
    final path = Path();
    path.moveTo(centerX, 0);
    path.lineTo(centerX + 4, size.y * 0.2);
    path.lineTo(centerX - 3, size.y * 0.35);
    path.lineTo(centerX + 5, size.y * 0.5);
    path.lineTo(centerX - 4, size.y * 0.65);
    path.lineTo(centerX + 3, size.y * 0.8);
    path.lineTo(centerX, size.y);

    // Glow
    canvas.drawPath(
      path,
      Paint()
        ..color = mainColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Core
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  // Missile - detailed rocket
  void _drawMissile(Canvas canvas) {
    final mainColor = const Color(0xFFFF4400);
    final centerX = size.x / 2;

    // Missile body
    final bodyPath = Path();
    bodyPath.moveTo(centerX, 0);
    bodyPath.quadraticBezierTo(size.x * 0.8, size.y * 0.1, size.x * 0.75, size.y * 0.3);
    bodyPath.lineTo(size.x * 0.8, size.y * 0.7);
    bodyPath.lineTo(size.x, size.y * 0.9);
    bodyPath.lineTo(size.x * 0.7, size.y * 0.85);
    bodyPath.lineTo(size.x * 0.3, size.y * 0.85);
    bodyPath.lineTo(0, size.y * 0.9);
    bodyPath.lineTo(size.x * 0.2, size.y * 0.7);
    bodyPath.lineTo(size.x * 0.25, size.y * 0.3);
    bodyPath.quadraticBezierTo(size.x * 0.2, size.y * 0.1, centerX, 0);
    bodyPath.close();

    // Body gradient
    final bodyGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [const Color(0xFF666666), const Color(0xFF999999), const Color(0xFF666666)],
    ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));

    canvas.drawPath(bodyPath, Paint()..shader = bodyGradient);

    // Red stripe
    canvas.drawRect(
      Rect.fromLTWH(size.x * 0.35, size.y * 0.2, size.x * 0.3, size.y * 0.5),
      Paint()..color = mainColor,
    );

    // Nose tip
    canvas.drawCircle(
      Offset(centerX, size.y * 0.05),
      3,
      Paint()..color = mainColor,
    );

    // Exhaust flame
    final flameGradient = RadialGradient(
      center: Alignment.topCenter,
      colors: [Colors.white, Colors.yellow, mainColor, mainColor.withAlpha(0)],
      stops: const [0.0, 0.2, 0.5, 1.0],
    ).createShader(Rect.fromCircle(center: Offset(centerX, size.y + 8), radius: 12));

    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX, size.y + 8), width: 10, height: 16),
      Paint()
        ..shader = flameGradient
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  // Enemy bullet - red danger projectile
  void _drawEnemyBullet(Canvas canvas) {
    final mainColor = const Color(0xFFFF2222);
    final centerX = size.x / 2;
    final centerY = size.y / 2;

    // Danger glow
    canvas.drawCircle(
      Offset(centerX, centerY),
      size.x * 0.7,
      Paint()
        ..color = mainColor.withAlpha(80)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Main body
    final gradient = RadialGradient(
      colors: [const Color(0xFFFFAAAA), mainColor, const Color(0xFF880000)],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromCircle(center: Offset(centerX, centerY), radius: size.x * 0.5));

    canvas.drawCircle(
      Offset(centerX, centerY),
      size.x * 0.4,
      Paint()..shader = gradient,
    );

    // Angry core
    canvas.drawCircle(
      Offset(centerX, centerY),
      size.x * 0.15,
      Paint()..color = Colors.white.withAlpha(200),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isMissile && !isEnemyBullet) {
      _updateMissileHoming(dt);
    }

    position += velocity * dt;

    // Remove if off screen
    if (position.y < -50 ||
        position.y > GameConstants.gameHeight + 50 ||
        position.x < -50 ||
        position.x > GameConstants.gameWidth + 50) {
      removeFromParent();
    }
  }

  void _updateMissileHoming(double dt) {
    // Find nearest enemy
    if (_missileTarget == null || _missileTarget!.isRemoved) {
      double minDist = double.infinity;
      for (final component in gameRef.world.children) {
        if (component is AnimatedEnemy) {
          final dist = position.distanceTo(component.position);
          if (dist < minDist) {
            minDist = dist;
            _missileTarget = component;
          }
        }
      }
    }

    if (_missileTarget != null) {
      final direction = (_missileTarget!.position - position).normalized();
      final turnSpeed = 5.0;
      velocity = velocity.normalized() * GameConstants.bulletSpeed;
      velocity += direction * turnSpeed;
      velocity = velocity.normalized() * GameConstants.bulletSpeed;
    }
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);

    if (!isEnemyBullet) {
      if (other is AnimatedEnemy) {
        other.takeDamage(damage);

        // Thunder chain lightning - hit nearby enemies
        if (isThunder) {
          _chainLightning(other.position, other);
        }

        if (!isPiercing && !isThunder) {
          removeFromParent();
        } else if (isThunder) {
          removeFromParent(); // Thunder removes after chaining
        }
      } else if (other is Boss) {
        other.takeDamage(damage);
        if (!isPiercing) {
          removeFromParent();
        }
      }
    } else {
      // Enemy bullet hitting player
      if (other is AnimatedPlayer) {
        gameRef.onPlayerHit(damage);
        removeFromParent();
      }
    }
  }

  /// Chain lightning effect - damages nearby enemies
  void _chainLightning(Vector2 sourcePos, AnimatedEnemy excludeEnemy) {
    const chainRange = 100.0;
    const maxChains = 3;
    int chainCount = 0;

    for (final component in gameRef.world.children) {
      if (component is AnimatedEnemy && component != excludeEnemy && chainCount < maxChains) {
        final dist = sourcePos.distanceTo(component.position);
        if (dist < chainRange) {
          // Deal reduced damage to chained enemies
          component.takeDamage((damage * 0.5).toInt());
          chainCount++;

          // Visual effect - add lightning arc (optional enhancement)
          gameRef.world.add(_LightningArc(
            start: sourcePos,
            end: component.position,
          ));
        }
      }
    }
  }
}

/// Visual lightning arc between enemies
class _LightningArc extends PositionComponent {
  final Vector2 start;
  final Vector2 end;
  double _lifetime = 0.15;

  _LightningArc({required this.start, required this.end});

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFFFFFF00)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final path = Path();
    path.moveTo(start.x, start.y);

    // Create zigzag lightning path
    final dx = end.x - start.x;
    final dy = end.y - start.y;
    final segments = 4;

    for (int i = 1; i <= segments; i++) {
      final t = i / segments;
      final x = start.x + dx * t + (i < segments ? (math.Random().nextDouble() - 0.5) * 20 : 0);
      final y = start.y + dy * t + (i < segments ? (math.Random().nextDouble() - 0.5) * 20 : 0);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);

    // White core
    paint.color = Colors.white;
    paint.strokeWidth = 1;
    paint.maskFilter = null;
    canvas.drawPath(path, paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _lifetime -= dt;
    if (_lifetime <= 0) {
      removeFromParent();
    }
  }
}

class EnemyBullet extends Bullet {
  EnemyBullet({
    required super.position,
    super.damage = 15,
    super.angle = 0,
  }) : super(isEnemyBullet: true);
}
