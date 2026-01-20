import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class StarBackground extends PositionComponent {
  final List<_Star> _stars = [];
  final List<_Nebula> _nebulae = [];

  StarBackground()
      : super(
          position: Vector2.zero(),
          size: Vector2(GameConstants.gameWidth, GameConstants.gameHeight),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final random = math.Random();

    // Create stars in multiple layers
    for (int layer = 0; layer < 3; layer++) {
      final starCount = 50 + layer * 30;
      final speed = 20.0 + layer * 30.0;
      final maxSize = 1.0 + layer * 0.5;

      for (int i = 0; i < starCount; i++) {
        _stars.add(_Star(
          position: Vector2(
            random.nextDouble() * GameConstants.gameWidth,
            random.nextDouble() * GameConstants.gameHeight,
          ),
          size: 0.5 + random.nextDouble() * maxSize,
          speed: speed + random.nextDouble() * 20,
          twinkleSpeed: 2 + random.nextDouble() * 3,
          twinkleOffset: random.nextDouble() * math.pi * 2,
          color: _randomStarColor(random),
        ));
      }
    }

    // Create nebulae
    for (int i = 0; i < 3; i++) {
      _nebulae.add(_Nebula(
        position: Vector2(
          random.nextDouble() * GameConstants.gameWidth,
          random.nextDouble() * GameConstants.gameHeight,
        ),
        size: 150 + random.nextDouble() * 100,
        color: _randomNebulaColor(random),
        speed: 5 + random.nextDouble() * 10,
      ));
    }
  }

  Color _randomStarColor(math.Random random) {
    final colors = [
      Colors.white,
      Colors.white,
      Colors.white,
      Colors.blue.shade200,
      Colors.yellow.shade100,
      Colors.red.shade100,
    ];
    return colors[random.nextInt(colors.length)];
  }

  Color _randomNebulaColor(math.Random random) {
    final colors = [
      GameColors.accent.withOpacity(0.1),
      GameColors.primary.withOpacity(0.08),
      Colors.purple.withOpacity(0.1),
      Colors.blue.withOpacity(0.08),
    ];
    return colors[random.nextInt(colors.length)];
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw gradient background
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0a0a1a),
          GameColors.background,
          Color(0xFF0d1525),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), bgPaint);

    // Draw nebulae
    for (final nebula in _nebulae) {
      final paint = Paint()
        ..color = nebula.color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, nebula.size * 0.5);

      canvas.drawCircle(
        Offset(nebula.position.x, nebula.position.y),
        nebula.size,
        paint,
      );
    }

    // Draw stars
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    for (final star in _stars) {
      final twinkle = 0.5 + 0.5 * math.sin(time * star.twinkleSpeed + star.twinkleOffset);
      final paint = Paint()
        ..color = star.color.withOpacity(0.3 + twinkle * 0.7);

      canvas.drawCircle(
        Offset(star.position.x, star.position.y),
        star.size,
        paint,
      );

      // Glow for larger stars
      if (star.size > 1.5) {
        final glowPaint = Paint()
          ..color = star.color.withOpacity(0.1 + twinkle * 0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

        canvas.drawCircle(
          Offset(star.position.x, star.position.y),
          star.size * 2,
          glowPaint,
        );
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move stars (parallax effect)
    for (final star in _stars) {
      star.position.y += star.speed * dt;
      if (star.position.y > GameConstants.gameHeight) {
        star.position.y = 0;
        star.position.x = math.Random().nextDouble() * GameConstants.gameWidth;
      }
    }

    // Move nebulae slowly
    for (final nebula in _nebulae) {
      nebula.position.y += nebula.speed * dt;
      if (nebula.position.y > GameConstants.gameHeight + nebula.size) {
        nebula.position.y = -nebula.size;
        nebula.position.x = math.Random().nextDouble() * GameConstants.gameWidth;
      }
    }
  }

  @override
  int get priority => -100; // Render behind everything
}

class _Star {
  Vector2 position;
  double size;
  double speed;
  double twinkleSpeed;
  double twinkleOffset;
  Color color;

  _Star({
    required this.position,
    required this.size,
    required this.speed,
    required this.twinkleSpeed,
    required this.twinkleOffset,
    required this.color,
  });
}

class _Nebula {
  Vector2 position;
  double size;
  Color color;
  double speed;

  _Nebula({
    required this.position,
    required this.size,
    required this.color,
    required this.speed,
  });
}
