import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';

// Muzzle flash when shooting
class MuzzleFlash extends PositionComponent {
  double _timer = 0;
  final double _duration = 0.1;

  MuzzleFlash({required Vector2 position})
      : super(
          position: position,
          size: Vector2.all(30),
          anchor: Anchor.center,
        );

  @override
  void render(Canvas canvas) {
    final progress = _timer / _duration;
    final alpha = (1 - progress).clamp(0.0, 1.0);
    final scale = 1 + progress * 0.5;

    final paint = Paint()
      ..color = Colors.white.withAlpha((alpha * 255).toInt())
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x * 0.3 * scale,
      paint,
    );

    final innerPaint = Paint()
      ..color = GameColors.primary.withAlpha((alpha * 200).toInt())
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x * 0.15 * scale,
      innerPaint,
    );
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

// Hit flash effect
class HitFlash extends PositionComponent {
  double _timer = 0;
  final double _duration = 0.2;
  final List<_HitParticle> _particles = [];

  HitFlash({required Vector2 position})
      : super(
          position: position,
          size: Vector2.all(60),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    final random = math.Random();
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      _particles.add(_HitParticle(
        angle: angle,
        speed: 50 + random.nextDouble() * 50,
        size: 3 + random.nextDouble() * 3,
      ));
    }
  }

  @override
  void render(Canvas canvas) {
    final progress = _timer / _duration;
    final alpha = (1 - progress).clamp(0.0, 1.0);

    for (final particle in _particles) {
      final distance = particle.speed * progress;
      final x = size.x / 2 + math.cos(particle.angle) * distance;
      final y = size.y / 2 + math.sin(particle.angle) * distance;

      final paint = Paint()
        ..color = GameColors.danger.withAlpha((alpha * 255).toInt())
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(Offset(x, y), particle.size * (1 - progress), paint);
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

class _HitParticle {
  final double angle;
  final double speed;
  final double size;

  _HitParticle({
    required this.angle,
    required this.speed,
    required this.size,
  });
}

// Spark trail for bullets
class SparkTrail extends PositionComponent {
  final Color color;
  double _timer = 0;
  final double _duration = 0.3;
  final List<Vector2> _positions = [];

  SparkTrail({
    required Vector2 position,
    required this.color,
  }) : super(
          position: position,
          size: Vector2.all(20),
          anchor: Anchor.center,
        );

  void addPosition(Vector2 pos) {
    _positions.insert(0, pos.clone());
    if (_positions.length > 5) {
      _positions.removeLast();
    }
  }

  @override
  void render(Canvas canvas) {
    for (int i = 0; i < _positions.length; i++) {
      final alpha = (1 - i / _positions.length) * 0.5;
      final trailSize = (1 - i / _positions.length) * 3;

      final offset = _positions[i] - position;

      final paint = Paint()
        ..color = color.withAlpha((alpha * 255).toInt())
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(
        Offset(size.x / 2 + offset.x, size.y / 2 + offset.y),
        trailSize,
        paint,
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;
    if (_timer >= _duration && _positions.isEmpty) {
      removeFromParent();
    }
  }
}

// Coin collect effect
class CoinCollectEffect extends PositionComponent {
  double _timer = 0;
  final double _duration = 0.5;
  final int amount;

  CoinCollectEffect({
    required Vector2 position,
    required this.amount,
  }) : super(
          position: position,
          size: Vector2(60, 30),
          anchor: Anchor.center,
        );

  @override
  void render(Canvas canvas) {
    final progress = _timer / _duration;
    final alpha = (1 - progress).clamp(0.0, 1.0);
    final yOffset = -progress * 30;

    final textPainter = TextPainter(
      text: TextSpan(
        text: '+$amount',
        style: TextStyle(
          color: GameColors.coin.withAlpha((alpha * 255).toInt()),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.x - textPainter.width) / 2,
        (size.y - textPainter.height) / 2 + yOffset,
      ),
    );
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

// Engine exhaust particles
class EngineExhaust extends PositionComponent {
  final List<_ExhaustParticle> _particles = [];
  final math.Random _random = math.Random();
  double _spawnTimer = 0;

  EngineExhaust() : super(size: Vector2.all(50), anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);

    _spawnTimer += dt;
    if (_spawnTimer >= 0.02) {
      _spawnTimer = 0;
      _particles.add(_ExhaustParticle(
        position: Vector2(
          size.x / 2 + (_random.nextDouble() - 0.5) * 10,
          size.y / 2,
        ),
        velocity: Vector2(
          (_random.nextDouble() - 0.5) * 20,
          30 + _random.nextDouble() * 20,
        ),
        size: 2 + _random.nextDouble() * 3,
        lifetime: 0.3 + _random.nextDouble() * 0.2,
      ));
    }

    for (final particle in _particles) {
      particle.update(dt);
    }

    _particles.removeWhere((p) => p.isDead);
  }

  @override
  void render(Canvas canvas) {
    for (final particle in _particles) {
      final alpha = (1 - particle.progress).clamp(0.0, 1.0);
      final particleSize = particle.size * (1 - particle.progress * 0.5);

      final paint = Paint()
        ..color = Color.lerp(
          Colors.white,
          GameColors.secondary,
          particle.progress,
        )!
            .withAlpha((alpha * 200).toInt())
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(
        Offset(particle.position.x, particle.position.y),
        particleSize,
        paint,
      );
    }
  }
}

class _ExhaustParticle {
  Vector2 position;
  Vector2 velocity;
  double size;
  double lifetime;
  double _timer = 0;

  _ExhaustParticle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.lifetime,
  });

  void update(double dt) {
    _timer += dt;
    position += velocity * dt;
  }

  double get progress => (_timer / lifetime).clamp(0.0, 1.0);
  bool get isDead => _timer >= lifetime;
}

// Power-up collect burst
class PowerUpBurst extends PositionComponent {
  final Color color;
  double _timer = 0;
  final double _duration = 0.4;
  final List<_BurstRing> _rings = [];

  PowerUpBurst({
    required Vector2 position,
    required this.color,
  }) : super(
          position: position,
          size: Vector2.all(100),
          anchor: Anchor.center,
        ) {
    _rings.add(_BurstRing(delay: 0));
    _rings.add(_BurstRing(delay: 0.1));
  }

  @override
  void render(Canvas canvas) {
    for (final ring in _rings) {
      final ringProgress = ((_timer - ring.delay) / 0.3).clamp(0.0, 1.0);
      if (ringProgress <= 0) continue;

      final alpha = (1 - ringProgress).clamp(0.0, 1.0);
      final ringSize = size.x * 0.2 + ringProgress * size.x * 0.4;

      final paint = Paint()
        ..color = color.withAlpha((alpha * 200).toInt())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * (1 - ringProgress);

      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        ringSize,
        paint,
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

class _BurstRing {
  final double delay;
  _BurstRing({required this.delay});
}

// Screen shake component (add to camera)
class ScreenShake extends Component {
  double _intensity = 0;
  double _duration = 0;
  double _timer = 0;
  final math.Random _random = math.Random();
  Vector2 _offset = Vector2.zero();

  void shake(double intensity, double duration) {
    _intensity = intensity;
    _duration = duration;
    _timer = 0;
  }

  Vector2 get offset => _offset;

  @override
  void update(double dt) {
    if (_timer < _duration) {
      _timer += dt;
      final progress = 1 - (_timer / _duration);
      final currentIntensity = _intensity * progress;

      _offset = Vector2(
        (_random.nextDouble() - 0.5) * 2 * currentIntensity,
        (_random.nextDouble() - 0.5) * 2 * currentIntensity,
      );
    } else {
      _offset = Vector2.zero();
    }
  }
}

// Warp speed effect (for level transitions)
class WarpEffect extends PositionComponent {
  final List<_WarpLine> _lines = [];
  final math.Random _random = math.Random();
  double _timer = 0;

  WarpEffect()
      : super(
          size: Vector2(GameConstants.gameWidth, GameConstants.gameHeight),
        );

  @override
  Future<void> onLoad() async {
    for (int i = 0; i < 50; i++) {
      _lines.add(_WarpLine(
        x: _random.nextDouble() * size.x,
        y: _random.nextDouble() * size.y,
        length: 20 + _random.nextDouble() * 80,
        speed: 500 + _random.nextDouble() * 500,
      ));
    }
  }

  @override
  void render(Canvas canvas) {
    final alpha = (_timer * 2).clamp(0.0, 1.0);

    for (final line in _lines) {
      final paint = Paint()
        ..color = Colors.white.withAlpha((alpha * 150).toInt())
        ..strokeWidth = 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawLine(
        Offset(line.x, line.y),
        Offset(line.x, line.y + line.length),
        paint,
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;

    for (final line in _lines) {
      line.y += line.speed * dt;
      if (line.y > size.y) {
        line.y = -line.length;
        line.x = _random.nextDouble() * size.x;
      }
    }

    if (_timer >= 2.0) {
      removeFromParent();
    }
  }
}

class _WarpLine {
  double x;
  double y;
  double length;
  double speed;

  _WarpLine({
    required this.x,
    required this.y,
    required this.length,
    required this.speed,
  });
}
