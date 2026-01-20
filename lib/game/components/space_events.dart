import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';

/// Black Hole - pulls player toward center
class BlackHole extends PositionComponent with HasGameRef {
  final Vector2 center;
  final double pullStrength = 50.0;
  final double maxRadius = 150.0;
  double rotation = 0;

  BlackHole({required this.center})
      : super(
          position: center,
          size: Vector2.all(120),
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);
    rotation += dt * 2;
  }

  Vector2 getPullForce(Vector2 targetPosition) {
    final direction = center - targetPosition;
    final distance = direction.length;

    if (distance < maxRadius && distance > 0) {
      final strength = pullStrength * (1 - distance / maxRadius);
      return direction.normalized() * strength * 0.016; // ~60fps
    }
    return Vector2.zero();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..style = PaintingStyle.stroke;

    // Draw multiple rotating rings
    for (int i = 0; i < 3; i++) {
      final radius = (size.x / 2) * (0.3 + i * 0.35);
      final opacity = 0.6 - i * 0.2;

      paint
        ..color = const Color(0xFF9D00FF).withOpacity(opacity)
        ..strokeWidth = 2.0;

      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        radius,
        paint,
      );
    }

    // Draw center core
    final corePaint = Paint()
      ..color = const Color(0xFF9D00FF)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      10,
      corePaint,
    );
  }
}

/// Asteroid - damaging obstacle
class Asteroid extends PositionComponent with HasGameRef {
  final Vector2 velocity;
  final double rotationSpeed;
  double rotation = 0;
  final int damage = 20;

  Asteroid({
    required Vector2 position,
    required this.velocity,
  })  : rotationSpeed = (math.Random().nextDouble() - 0.5) * 4,
        super(
          position: position,
          size: Vector2.all(40 + math.Random().nextDouble() * 20),
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    rotation += rotationSpeed * dt;

    // Remove if off screen
    if (position.y > GameConstants.gameHeight + 50 ||
        position.y < -50 ||
        position.x > GameConstants.gameWidth + 50 ||
        position.x < -50) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(rotation);

    final paint = Paint()
      ..color = const Color(0xFF888888)
      ..style = PaintingStyle.fill;

    // Draw irregular polygon
    final path = Path();
    final sides = 6;
    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * math.pi / sides) + rotation;
      final radius = size.x / 2 * (0.8 + math.Random().nextDouble() * 0.4);
      final x = math.cos(angle) * radius;
      final y = math.sin(angle) * radius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);

    // Add edge highlight
    paint
      ..color = const Color(0xFFAAAAAA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, paint);

    canvas.restore();
  }
}

/// Space Debris - smaller floating obstacles
class SpaceDebris extends PositionComponent with HasGameRef {
  final Vector2 velocity;
  final double rotationSpeed;
  double rotation = 0;
  final int damage = 10;

  SpaceDebris({
    required Vector2 position,
    required this.velocity,
  })  : rotationSpeed = (math.Random().nextDouble() - 0.5) * 6,
        super(
          position: position,
          size: Vector2.all(20 + math.Random().nextDouble() * 15),
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    rotation += rotationSpeed * dt;

    if (position.y > GameConstants.gameHeight + 50 || position.y < -50) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(rotation);

    final paint = Paint()
      ..color = const Color(0xFF666666)
      ..style = PaintingStyle.fill;

    // Draw rectangle
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: size.x,
        height: size.y,
      ),
      paint,
    );

    canvas.restore();
  }
}

/// Wormhole effect - visual portal
class Wormhole extends PositionComponent with HasGameRef {
  final Vector2 center;
  double animationTime = 0;

  Wormhole({required this.center})
      : super(
          position: center,
          size: Vector2.all(100),
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);
    animationTime += dt * 3;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..style = PaintingStyle.stroke;

    // Draw rotating spiral
    for (int i = 0; i < 5; i++) {
      final radius = (size.x / 2) * (0.2 + i * 0.2);
      final opacity = 0.8 - i * 0.15;

      paint
        ..color = const Color(0xFF00FFFF).withOpacity(opacity)
        ..strokeWidth = 3.0;

      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        radius,
        paint,
      );
    }

    // Center glow
    final centerPaint = Paint()
      ..color = const Color(0xFF00FFFF).withOpacity(0.5)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      15,
      centerPaint,
    );
  }
}

/// Nebula overlay - reduces visibility
class NebulaOverlay extends PositionComponent with HasGameRef {
  double opacity = 0.0;
  double targetOpacity = 0.6;
  final Color nebulaColor;

  NebulaOverlay({required this.nebulaColor})
      : super(
          position: Vector2.zero(),
          size: Vector2(GameConstants.gameWidth, GameConstants.gameHeight),
        );

  @override
  void update(double dt) {
    super.update(dt);

    // Fade in/out
    if (opacity < targetOpacity) {
      opacity = math.min(opacity + dt * 0.5, targetOpacity);
    }
  }

  void fadeOut() {
    targetOpacity = 0.0;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (opacity > 0) {
      final paint = Paint()
        ..color = nebulaColor.withOpacity(opacity * 0.3)
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y),
        paint,
      );

      // Add some "cloud" effects
      final cloudPaint = Paint()
        ..color = nebulaColor.withOpacity(opacity * 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

      for (int i = 0; i < 5; i++) {
        canvas.drawCircle(
          Offset(
            (i * 100 + 50) % size.x,
            (i * 150 + 100) % size.y,
          ),
          60,
          cloudPaint,
        );
      }
    }
  }
}

/// Visual effect for solar storm
class SolarStormEffect extends PositionComponent with HasGameRef {
  double animationTime = 0;

  SolarStormEffect()
      : super(
          position: Vector2.zero(),
          size: Vector2(GameConstants.gameWidth, GameConstants.gameHeight),
        );

  @override
  void update(double dt) {
    super.update(dt);
    animationTime += dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()
      ..color = const Color(0xFFFF6B00).withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // Pulsating effect
    final pulse = (math.sin(animationTime * 4) + 1) / 2;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      paint..color = Color(0xFFFF6B00).withOpacity(0.1 * pulse),
    );

    // Lightning-like streaks
    final streakPaint = Paint()
      ..color = const Color(0xFFFF6B00).withOpacity(0.4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 3; i++) {
      final x = (i * size.x / 3) + (animationTime * 50) % (size.x / 3);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + 30, size.y),
        streakPaint,
      );
    }
  }
}

/// Radiation zone visual effect
class RadiationZoneEffect extends PositionComponent with HasGameRef {
  double animationTime = 0;

  RadiationZoneEffect()
      : super(
          position: Vector2.zero(),
          size: Vector2(GameConstants.gameWidth, GameConstants.gameHeight),
        );

  @override
  void update(double dt) {
    super.update(dt);
    animationTime += dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final pulse = (math.sin(animationTime * 3) + 1) / 2;

    final paint = Paint()
      ..color = const Color(0xFF00FF00).withOpacity(0.15 * pulse)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      paint,
    );

    // Radiation symbol particles
    final particlePaint = Paint()
      ..color = const Color(0xFF00FF00).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final offset = (animationTime * 20 + i * 30) % size.y;
      canvas.drawCircle(
        Offset((i * 50) % size.x, offset),
        4,
        particlePaint,
      );
    }
  }
}
