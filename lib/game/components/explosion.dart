import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class Explosion extends PositionComponent {
  final bool isLarge;

  double _timer = 0;
  final double _duration = 0.5;
  final List<_Particle> _particles = [];

  Explosion({
    required Vector2 position,
    this.isLarge = false,
  }) : super(
          position: position,
          size: Vector2.all(isLarge ? 80 : 50),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final random = math.Random();
    final particleCount = isLarge ? 20 : 12;

    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * math.pi * 2;
      final speed = (isLarge ? 150 : 100) + random.nextDouble() * 50;

      _particles.add(_Particle(
        velocity: Vector2(math.cos(angle), math.sin(angle)) * speed,
        size: (isLarge ? 8 : 5) + random.nextDouble() * 5,
        color: _randomExplosionColor(random),
      ));
    }
  }

  Color _randomExplosionColor(math.Random random) {
    final colors = [
      GameColors.secondary,
      GameColors.warning,
      Colors.orange,
      Colors.red,
      Colors.white,
    ];
    return colors[random.nextInt(colors.length)];
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final progress = _timer / _duration;
    final alpha = (1 - progress).clamp(0.0, 1.0);

    for (final particle in _particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 * (1 - progress));

      final pos = Offset(
        size.x / 2 + particle.velocity.x * progress * 0.5,
        size.y / 2 + particle.velocity.y * progress * 0.5,
      );

      canvas.drawCircle(
        pos,
        particle.size * (1 - progress * 0.5),
        paint,
      );
    }

    // Core flash
    if (progress < 0.3) {
      final corePaint = Paint()
        ..color = Colors.white.withOpacity((0.3 - progress) / 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        size.x * 0.4 * (1 - progress),
        corePaint,
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    _timer += dt;
    if (_timer >= _duration) {
      removeFromParent();
    }
  }
}

class _Particle {
  final Vector2 velocity;
  final double size;
  final Color color;

  _Particle({
    required this.velocity,
    required this.size,
    required this.color,
  });
}

/// Full screen flash effect when bomb is used
class BombFlashEffect extends PositionComponent {
  double _timer = 0;
  final double _duration = 0.8;

  BombFlashEffect() : super(
    position: Vector2.zero(),
    size: Vector2(GameConstants.gameWidth, GameConstants.gameHeight),
    priority: 1000, // Render on top
  );

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final progress = _timer / _duration;

    // White flash that fades out
    if (progress < 0.3) {
      final flashAlpha = ((0.3 - progress) / 0.3 * 0.8).clamp(0.0, 1.0);
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()..color = Colors.white.withAlpha((flashAlpha * 255).toInt()),
      );
    }

    // Expanding ring effect
    final ringProgress = progress.clamp(0.0, 1.0);
    final ringRadius = size.x * ringProgress;
    final ringAlpha = ((1 - progress) * 0.6).clamp(0.0, 1.0);

    final ringPaint = Paint()
      ..color = Colors.cyan.withAlpha((ringAlpha * 255).toInt())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20 * (1 - progress)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      ringRadius,
      ringPaint,
    );

    // Second ring (delayed)
    if (progress > 0.1) {
      final ring2Progress = ((progress - 0.1) / 0.9).clamp(0.0, 1.0);
      final ring2Radius = size.x * 0.8 * ring2Progress;
      final ring2Alpha = ((1 - ring2Progress) * 0.4).clamp(0.0, 1.0);

      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        ring2Radius,
        Paint()
          ..color = Colors.orange.withAlpha((ring2Alpha * 255).toInt())
          ..style = PaintingStyle.stroke
          ..strokeWidth = 15 * (1 - ring2Progress)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    _timer += dt;
    if (_timer >= _duration) {
      removeFromParent();
    }
  }
}
