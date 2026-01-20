import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../managers/audio_manager.dart';

class AnimatedExplosion extends PositionComponent {
  final bool isLarge;
  final bool isBoss;

  double _timer = 0;
  final double _duration;
  final List<_ExplosionParticle> _particles = [];
  final List<_ExplosionRing> _rings = [];
  final List<_Debris> _debris = [];
  final List<_Spark> _sparks = [];

  final math.Random _random = math.Random();

  AnimatedExplosion({
    required Vector2 position,
    this.isLarge = false,
    this.isBoss = false,
  })  : _duration = isBoss ? 1.5 : (isLarge ? 0.8 : 0.5),
        super(
          position: position,
          size: Vector2.all(isBoss ? 200 : (isLarge ? 120 : 80)),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    AudioManager().playExplosion();

    final particleCount = isBoss ? 40 : (isLarge ? 25 : 15);
    final ringCount = isBoss ? 4 : (isLarge ? 3 : 2);
    final debrisCount = isBoss ? 15 : (isLarge ? 10 : 5);
    final sparkCount = isBoss ? 30 : (isLarge ? 20 : 12);

    // Create particles
    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * math.pi * 2 +
          _random.nextDouble() * 0.5;
      final speed = (isBoss ? 200 : (isLarge ? 150 : 100)) +
          _random.nextDouble() * 100;

      _particles.add(_ExplosionParticle(
        velocity: Vector2(math.cos(angle), math.sin(angle)) * speed,
        size: (isBoss ? 10 : (isLarge ? 7 : 4)) + _random.nextDouble() * 5,
        color: _randomExplosionColor(),
        decay: 0.3 + _random.nextDouble() * 0.4,
      ));
    }

    // Create rings
    for (int i = 0; i < ringCount; i++) {
      _rings.add(_ExplosionRing(
        delay: i * 0.1,
        maxRadius: size.x * 0.4 + i * 20,
        duration: 0.4 + i * 0.1,
        color: i == 0 ? Colors.white : _randomExplosionColor(),
      ));
    }

    // Create debris
    for (int i = 0; i < debrisCount; i++) {
      final angle = _random.nextDouble() * math.pi * 2;
      final speed = 80 + _random.nextDouble() * 120;

      _debris.add(_Debris(
        position: Vector2.zero(),
        velocity: Vector2(math.cos(angle), math.sin(angle)) * speed,
        rotation: _random.nextDouble() * math.pi * 2,
        rotationSpeed: (_random.nextDouble() - 0.5) * 10,
        size: 3 + _random.nextDouble() * 5,
        color: Colors.grey.shade600,
      ));
    }

    // Create sparks
    for (int i = 0; i < sparkCount; i++) {
      final angle = _random.nextDouble() * math.pi * 2;
      final speed = 100 + _random.nextDouble() * 200;

      _sparks.add(_Spark(
        position: Vector2.zero(),
        velocity: Vector2(math.cos(angle), math.sin(angle)) * speed,
        length: 5 + _random.nextDouble() * 10,
        color: _random.nextBool() ? Colors.yellow : Colors.orange,
      ));
    }
  }

  Color _randomExplosionColor() {
    final colors = [
      GameColors.secondary,
      GameColors.warning,
      Colors.orange,
      Colors.red,
      Colors.yellow,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final progress = (_timer / _duration).clamp(0.0, 1.0);

    // Draw rings
    for (final ring in _rings) {
      _drawRing(canvas, ring, progress);
    }

    // Draw core flash (early in explosion)
    if (progress < 0.3) {
      _drawCoreFlash(canvas, progress);
    }

    // Draw particles
    for (final particle in _particles) {
      _drawParticle(canvas, particle, progress);
    }

    // Draw sparks
    for (final spark in _sparks) {
      _drawSpark(canvas, spark, progress);
    }

    // Draw debris
    for (final debris in _debris) {
      _drawDebris(canvas, debris, progress);
    }

    // Draw smoke (later in explosion)
    if (progress > 0.3) {
      _drawSmoke(canvas, progress);
    }
  }

  void _drawCoreFlash(Canvas canvas, double progress) {
    final flashProgress = progress / 0.3;
    final alpha = (1 - flashProgress).clamp(0.0, 1.0);
    final flashSize = size.x * 0.3 * (1 + flashProgress * 0.5);

    // Outer glow
    final gradient = ui.Gradient.radial(
      Offset(size.x / 2, size.y / 2),
      flashSize,
      [
        Colors.white.withAlpha((alpha * 255).toInt()),
        Colors.yellow.withAlpha((alpha * 150).toInt()),
        Colors.orange.withAlpha((alpha * 100).toInt()),
        Colors.transparent,
      ],
      [0.0, 0.3, 0.6, 1.0],
    );

    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      flashSize,
      Paint()
        ..shader = gradient
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Inner core
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      flashSize * 0.3,
      Paint()
        ..color = Colors.white.withAlpha((alpha * 255).toInt())
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
  }

  void _drawRing(Canvas canvas, _ExplosionRing ring, double overallProgress) {
    final ringProgress =
        ((overallProgress * _duration - ring.delay) / ring.duration)
            .clamp(0.0, 1.0);

    if (ringProgress <= 0 || ringProgress >= 1) return;

    final alpha = (1 - ringProgress).clamp(0.0, 1.0);
    final radius = ring.maxRadius * ringProgress;
    final strokeWidth = 4 * (1 - ringProgress);

    final paint = Paint()
      ..color = ring.color.withAlpha((alpha * 200).toInt())
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 * (1 - ringProgress));

    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      radius,
      paint,
    );
  }

  void _drawParticle(
      Canvas canvas, _ExplosionParticle particle, double progress) {
    final particleProgress = (progress / particle.decay).clamp(0.0, 1.0);
    if (particleProgress >= 1) return;

    final alpha = (1 - particleProgress).clamp(0.0, 1.0);
    final currentSize = particle.size * (1 - particleProgress * 0.5);

    final pos = Offset(
      size.x / 2 + particle.velocity.x * progress * 0.5,
      size.y / 2 + particle.velocity.y * progress * 0.5,
    );

    final paint = Paint()
      ..color = particle.color.withAlpha((alpha * 255).toInt())
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, currentSize * 0.5);

    canvas.drawCircle(pos, currentSize, paint);
  }

  void _drawSpark(Canvas canvas, _Spark spark, double progress) {
    if (progress > 0.5) return;

    final sparkProgress = progress / 0.5;
    final alpha = (1 - sparkProgress).clamp(0.0, 1.0);

    final startPos = Offset(
      size.x / 2 + spark.velocity.x * progress * 0.3,
      size.y / 2 + spark.velocity.y * progress * 0.3,
    );

    final endPos = Offset(
      startPos.dx + spark.velocity.normalized().x * spark.length,
      startPos.dy + spark.velocity.normalized().y * spark.length,
    );

    final gradient = ui.Gradient.linear(
      startPos,
      endPos,
      [
        spark.color.withAlpha((alpha * 255).toInt()),
        spark.color.withAlpha(0),
      ],
    );

    canvas.drawLine(
      startPos,
      endPos,
      Paint()
        ..shader = gradient
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawDebris(Canvas canvas, _Debris debris, double progress) {
    if (progress < 0.1) return;

    final debrisProgress = ((progress - 0.1) / 0.9).clamp(0.0, 1.0);
    final alpha = (1 - debrisProgress).clamp(0.0, 1.0);

    final pos = Offset(
      size.x / 2 + debris.velocity.x * debrisProgress * 0.8,
      size.y / 2 +
          debris.velocity.y * debrisProgress * 0.8 +
          debrisProgress * debrisProgress * 50, // Gravity
    );

    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(debris.rotation + debris.rotationSpeed * debrisProgress);

    final paint = Paint()..color = debris.color.withAlpha((alpha * 255).toInt());

    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: debris.size, height: debris.size * 0.6),
      paint,
    );

    canvas.restore();
  }

  void _drawSmoke(Canvas canvas, double progress) {
    final smokeProgress = ((progress - 0.3) / 0.7).clamp(0.0, 1.0);
    final alpha = (0.3 * (1 - smokeProgress)).clamp(0.0, 0.3);
    final smokeSize = size.x * 0.4 * (1 + smokeProgress);

    for (int i = 0; i < 3; i++) {
      final offset = Offset(
        size.x / 2 + math.sin(smokeProgress * 5 + i) * 10,
        size.y / 2 - smokeProgress * 30 + i * 10,
      );

      canvas.drawCircle(
        offset,
        smokeSize * (1 - i * 0.2),
        Paint()
          ..color = Colors.grey.withAlpha((alpha * 255 * (1 - i * 0.3)).toInt())
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
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

class _ExplosionParticle {
  Vector2 velocity;
  double size;
  Color color;
  double decay;

  _ExplosionParticle({
    required this.velocity,
    required this.size,
    required this.color,
    required this.decay,
  });
}

class _ExplosionRing {
  double delay;
  double maxRadius;
  double duration;
  Color color;

  _ExplosionRing({
    required this.delay,
    required this.maxRadius,
    required this.duration,
    required this.color,
  });
}

class _Debris {
  Vector2 position;
  Vector2 velocity;
  double rotation;
  double rotationSpeed;
  double size;
  Color color;

  _Debris({
    required this.position,
    required this.velocity,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
    required this.color,
  });
}

class _Spark {
  Vector2 position;
  Vector2 velocity;
  double length;
  Color color;

  _Spark({
    required this.position,
    required this.velocity,
    required this.length,
    required this.color,
  });
}
