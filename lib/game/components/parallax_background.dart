import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class ParallaxBackground extends PositionComponent {
  final List<_StarLayer> _starLayers = [];
  final List<_Planet> _planets = [];
  final List<_ShootingStar> _shootingStars = [];
  final List<_SpaceDust> _spaceDust = [];

  double _time = 0;
  final math.Random _random = math.Random();

  ParallaxBackground()
      : super(
          position: Vector2.zero(),
          size: Vector2(GameConstants.gameWidth, GameConstants.gameHeight),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Create star layers with different parallax speeds
    _starLayers.add(_StarLayer(
      starCount: 60,
      speed: 15,
      maxSize: 1.0,
      screenSize: size,
    ));
    _starLayers.add(_StarLayer(
      starCount: 40,
      speed: 30,
      maxSize: 1.5,
      screenSize: size,
    ));
    _starLayers.add(_StarLayer(
      starCount: 30,
      speed: 50,
      maxSize: 2.0,
      screenSize: size,
    ));
    _starLayers.add(_StarLayer(
      starCount: 15,
      speed: 80,
      maxSize: 3.0,
      screenSize: size,
      hasGlow: true,
    ));

    // Add some planets in the far background
    for (int i = 0; i < 2; i++) {
      _planets.add(_Planet(
        position: Vector2(
          _random.nextDouble() * size.x,
          _random.nextDouble() * size.y,
        ),
        radius: 30 + _random.nextDouble() * 50,
        color: _randomPlanetColor(),
        speed: 5 + _random.nextDouble() * 10,
        screenSize: size,
      ));
    }

    // Initialize space dust
    for (int i = 0; i < 100; i++) {
      _spaceDust.add(_SpaceDust(
        position: Vector2(
          _random.nextDouble() * size.x,
          _random.nextDouble() * size.y,
        ),
        speed: 20 + _random.nextDouble() * 40,
        size: 0.5 + _random.nextDouble(),
        screenSize: size,
      ));
    }
  }

  Color _randomPlanetColor() {
    final colors = [
      const Color(0xFF4A1942),
      const Color(0xFF2E4057),
      const Color(0xFF1E3D59),
      const Color(0xFF3D1308),
      const Color(0xFF1A472A),
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw gradient background
    _drawGradientBackground(canvas);

    // Draw nebula effects
    _drawNebulae(canvas);

    // Draw planets (far background)
    for (final planet in _planets) {
      _drawPlanet(canvas, planet);
    }

    // Draw space dust
    for (final dust in _spaceDust) {
      _drawSpaceDust(canvas, dust);
    }

    // Draw star layers
    for (final layer in _starLayers) {
      _drawStarLayer(canvas, layer);
    }

    // Draw shooting stars
    for (final star in _shootingStars) {
      _drawShootingStar(canvas, star);
    }
  }

  void _drawGradientBackground(Canvas canvas) {
    final gradient = ui.Gradient.linear(
      Offset.zero,
      Offset(0, size.y),
      [
        const Color(0xFF05050F),
        const Color(0xFF0A0A1A),
        const Color(0xFF0D1B2A),
        const Color(0xFF0A1628),
      ],
      [0.0, 0.3, 0.7, 1.0],
    );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..shader = gradient,
    );
  }

  void _drawNebulae(Canvas canvas) {
    // Purple nebula
    _drawNebula(
      canvas,
      Offset(size.x * 0.3, size.y * 0.2),
      150,
      GameColors.accent.withAlpha(15),
    );

    // Blue nebula
    _drawNebula(
      canvas,
      Offset(size.x * 0.7, size.y * 0.6),
      120,
      GameColors.primary.withAlpha(12),
    );

    // Orange nebula (dynamic position)
    final nebulaX = size.x * 0.5 + math.sin(_time * 0.1) * 50;
    final nebulaY = size.y * 0.8 + math.cos(_time * 0.15) * 30;
    _drawNebula(
      canvas,
      Offset(nebulaX, nebulaY),
      100,
      GameColors.secondary.withAlpha(10),
    );
  }

  void _drawNebula(Canvas canvas, Offset center, double radius, Color color) {
    final gradient = ui.Gradient.radial(
      center,
      radius,
      [
        color,
        color.withAlpha(0),
      ],
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = gradient
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30),
    );
  }

  void _drawPlanet(Canvas canvas, _Planet planet) {
    // Planet shadow
    final shadowGradient = ui.Gradient.linear(
      Offset(planet.position.x - planet.radius, planet.position.y),
      Offset(planet.position.x + planet.radius, planet.position.y),
      [
        planet.color,
        planet.color.withAlpha(50),
      ],
    );

    canvas.drawCircle(
      Offset(planet.position.x, planet.position.y),
      planet.radius,
      Paint()..shader = shadowGradient,
    );

    // Planet ring (for some planets)
    if (planet.radius > 40) {
      final ringPaint = Paint()
        ..color = planet.color.withAlpha(80)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(planet.position.x, planet.position.y),
          width: planet.radius * 2.5,
          height: planet.radius * 0.6,
        ),
        ringPaint,
      );
    }

    // Atmosphere glow
    final glowPaint = Paint()
      ..color = planet.color.withAlpha(30)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawCircle(
      Offset(planet.position.x, planet.position.y),
      planet.radius * 1.2,
      glowPaint,
    );
  }

  void _drawSpaceDust(Canvas canvas, _SpaceDust dust) {
    final alpha = (0.3 + math.sin(_time * 2 + dust.position.x) * 0.2)
        .clamp(0.1, 0.5);

    final paint = Paint()
      ..color = Colors.white.withAlpha((alpha * 255).toInt());

    canvas.drawCircle(
      Offset(dust.position.x, dust.position.y),
      dust.size,
      paint,
    );
  }

  void _drawStarLayer(Canvas canvas, _StarLayer layer) {
    for (final star in layer.stars) {
      final twinkle = 0.5 +
          0.5 * math.sin(_time * star.twinkleSpeed + star.twinkleOffset);

      final paint = Paint()
        ..color = star.color.withAlpha((twinkle * 255).toInt());

      canvas.drawCircle(
        Offset(star.position.x, star.position.y),
        star.size,
        paint,
      );

      // Glow for larger stars
      if (layer.hasGlow && star.size > 1.5) {
        final glowPaint = Paint()
          ..color = star.color.withAlpha((twinkle * 100).toInt())
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

        canvas.drawCircle(
          Offset(star.position.x, star.position.y),
          star.size * 2.5,
          glowPaint,
        );

        // Cross sparkle for bright stars
        if (star.size > 2.0) {
          _drawSparkle(canvas, star, twinkle);
        }
      }
    }
  }

  void _drawSparkle(Canvas canvas, _Star star, double intensity) {
    final sparklePaint = Paint()
      ..color = Colors.white.withAlpha((intensity * 150).toInt())
      ..strokeWidth = 1;

    final length = star.size * 3;
    final center = Offset(star.position.x, star.position.y);

    canvas.drawLine(
      Offset(center.dx - length, center.dy),
      Offset(center.dx + length, center.dy),
      sparklePaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - length),
      Offset(center.dx, center.dy + length),
      sparklePaint,
    );
  }

  void _drawShootingStar(Canvas canvas, _ShootingStar star) {
    final progress = star.progress;
    if (progress >= 1.0) return;

    final alpha = (1 - progress) * 0.8;
    final length = star.length * (1 - progress * 0.5);

    final currentPos = Offset(
      star.startX + star.directionX * star.distance * progress,
      star.startY + star.directionY * star.distance * progress,
    );

    final gradient = ui.Gradient.linear(
      currentPos,
      Offset(
        currentPos.dx - star.directionX * length,
        currentPos.dy - star.directionY * length,
      ),
      [
        Colors.white.withAlpha((alpha * 255).toInt()),
        Colors.white.withAlpha(0),
      ],
    );

    final paint = Paint()
      ..shader = gradient
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      currentPos,
      Offset(
        currentPos.dx - star.directionX * length,
        currentPos.dy - star.directionY * length,
      ),
      paint,
    );

    // Head glow
    canvas.drawCircle(
      currentPos,
      3,
      Paint()
        ..color = Colors.white.withAlpha((alpha * 255).toInt())
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;

    // Update star layers
    for (final layer in _starLayers) {
      layer.update(dt);
    }

    // Update planets
    for (final planet in _planets) {
      planet.position.y += planet.speed * dt;
      if (planet.position.y > size.y + planet.radius * 2) {
        planet.position.y = -planet.radius * 2;
        planet.position.x = _random.nextDouble() * size.x;
      }
    }

    // Update space dust
    for (final dust in _spaceDust) {
      dust.position.y += dust.speed * dt;
      if (dust.position.y > size.y) {
        dust.position.y = 0;
        dust.position.x = _random.nextDouble() * size.x;
      }
    }

    // Update shooting stars
    for (final star in _shootingStars) {
      star.timer += dt;
    }
    _shootingStars.removeWhere((s) => s.progress >= 1.0);

    // Occasionally spawn shooting stars
    if (_random.nextDouble() < 0.002) {
      _spawnShootingStar();
    }
  }

  void _spawnShootingStar() {
    final startX = _random.nextDouble() * size.x;
    final angle = math.pi / 4 + _random.nextDouble() * math.pi / 4;

    _shootingStars.add(_ShootingStar(
      startX: startX,
      startY: 0,
      directionX: math.cos(angle),
      directionY: math.sin(angle),
      distance: 200 + _random.nextDouble() * 200,
      length: 30 + _random.nextDouble() * 50,
      duration: 0.5 + _random.nextDouble() * 0.5,
    ));
  }

  @override
  int get priority => -100;
}

class _StarLayer {
  final List<_Star> stars = [];
  final double speed;
  final Vector2 screenSize;
  final bool hasGlow;

  _StarLayer({
    required int starCount,
    required this.speed,
    required double maxSize,
    required this.screenSize,
    this.hasGlow = false,
  }) {
    final random = math.Random();
    for (int i = 0; i < starCount; i++) {
      stars.add(_Star(
        position: Vector2(
          random.nextDouble() * screenSize.x,
          random.nextDouble() * screenSize.y,
        ),
        size: 0.5 + random.nextDouble() * maxSize,
        twinkleSpeed: 1 + random.nextDouble() * 3,
        twinkleOffset: random.nextDouble() * math.pi * 2,
        color: _randomStarColor(random),
      ));
    }
  }

  Color _randomStarColor(math.Random random) {
    final colors = [
      Colors.white,
      Colors.white,
      Colors.white,
      Colors.blue.shade100,
      Colors.yellow.shade100,
      Colors.red.shade100,
      Colors.cyan.shade100,
    ];
    return colors[random.nextInt(colors.length)];
  }

  void update(double dt) {
    final random = math.Random();
    for (final star in stars) {
      star.position.y += speed * dt;
      if (star.position.y > screenSize.y) {
        star.position.y = 0;
        star.position.x = random.nextDouble() * screenSize.x;
      }
    }
  }
}

class _Star {
  Vector2 position;
  double size;
  double twinkleSpeed;
  double twinkleOffset;
  Color color;

  _Star({
    required this.position,
    required this.size,
    required this.twinkleSpeed,
    required this.twinkleOffset,
    required this.color,
  });
}

class _Planet {
  Vector2 position;
  double radius;
  Color color;
  double speed;
  Vector2 screenSize;

  _Planet({
    required this.position,
    required this.radius,
    required this.color,
    required this.speed,
    required this.screenSize,
  });
}

class _SpaceDust {
  Vector2 position;
  double speed;
  double size;
  Vector2 screenSize;

  _SpaceDust({
    required this.position,
    required this.speed,
    required this.size,
    required this.screenSize,
  });
}

class _ShootingStar {
  double startX;
  double startY;
  double directionX;
  double directionY;
  double distance;
  double length;
  double duration;
  double timer = 0;

  _ShootingStar({
    required this.startX,
    required this.startY,
    required this.directionX,
    required this.directionY,
    required this.distance,
    required this.length,
    required this.duration,
  });

  double get progress => (timer / duration).clamp(0.0, 1.0);
}
