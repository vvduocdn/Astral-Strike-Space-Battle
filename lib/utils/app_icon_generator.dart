import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Widget to preview and generate the app icon design
/// Run this screen, take a screenshot, and use it as your app icon
class AppIconGenerator extends StatelessWidget {
  final double size;

  const AppIconGenerator({super.key, this.size = 1024});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        title: const Text('App Icon Preview'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon preview at different sizes
            const Text(
              'App Icon Preview',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 32),

            // Main icon - 512px preview
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyan.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(100)),
                child: SizedBox(
                  width: 512,
                  height: 512,
                  child: AstralStrikeIcon(),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Smaller previews
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPreview(180, 'iOS'),
                const SizedBox(width: 16),
                _buildPreview(144, 'Android'),
                const SizedBox(width: 16),
                _buildPreview(60, 'Small'),
              ],
            ),

            const SizedBox(height: 32),
            const Text(
              'Take a screenshot of the large icon above\nand use it as your app icon',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(double size, String label) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.2),
          child: SizedBox(
            width: size,
            height: size,
            child: const AstralStrikeIcon(),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

/// The actual app icon design
class AstralStrikeIcon extends StatelessWidget {
  const AstralStrikeIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0a0a1a),
            Color(0xFF0D1B2A),
            Color(0xFF1B263B),
            Color(0xFF0a0a1a),
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Stars background
          const _StarsBackground(),

          // Nebula effect
          const _NebulaEffect(),

          // Main spaceship
          const Center(
            child: _Spaceship(),
          ),

          // Energy ring
          const Center(
            child: _EnergyRing(),
          ),

          // Glow effects
          const _GlowEffects(),
        ],
      ),
    );
  }
}

class _StarsBackground extends StatelessWidget {
  const _StarsBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StarsPainter(),
      size: Size.infinite,
    );
  }
}

class _StarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final random = 42; // Fixed seed for consistent stars

    for (int i = 0; i < 50; i++) {
      final x = ((random * (i + 1) * 7) % size.width.toInt()).toDouble();
      final y = ((random * (i + 3) * 13) % size.height.toInt()).toDouble();
      final radius = (i % 3) * 0.8 + 0.5;
      final opacity = 0.3 + (i % 5) * 0.15;

      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NebulaEffect extends StatelessWidget {
  const _NebulaEffect();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _NebulaPainter(),
      ),
    );
  }
}

class _NebulaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Purple nebula
    final purplePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF7B2CBF).withOpacity(0.3),
          const Color(0xFF7B2CBF).withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(size.width * 0.7, size.height * 0.3), radius: size.width * 0.4));
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.3), size.width * 0.4, purplePaint);

    // Cyan nebula
    final cyanPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00D4FF).withOpacity(0.2),
          const Color(0xFF00D4FF).withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(size.width * 0.3, size.height * 0.7), radius: size.width * 0.35));
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.7), size.width * 0.35, cyanPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Spaceship extends StatelessWidget {
  const _Spaceship();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SpaceshipPainter(),
      size: const Size(200, 200),
    );
  }
}

class _SpaceshipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Ship body gradient
    final bodyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF00D4FF),
        const Color(0xFF0088AA),
        const Color(0xFF004455),
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Main body
    final bodyPaint = Paint()
      ..shader = bodyGradient
      ..style = PaintingStyle.fill;

    final bodyPath = Path();
    // Nose
    bodyPath.moveTo(centerX, centerY - 80);
    // Right side
    bodyPath.quadraticBezierTo(centerX + 15, centerY - 50, centerX + 25, centerY - 20);
    bodyPath.lineTo(centerX + 30, centerY + 20);
    // Right wing
    bodyPath.lineTo(centerX + 70, centerY + 50);
    bodyPath.lineTo(centerX + 65, centerY + 60);
    bodyPath.lineTo(centerX + 25, centerY + 40);
    // Bottom
    bodyPath.lineTo(centerX + 15, centerY + 60);
    bodyPath.lineTo(centerX, centerY + 50);
    // Left side (mirror)
    bodyPath.lineTo(centerX - 15, centerY + 60);
    bodyPath.lineTo(centerX - 25, centerY + 40);
    bodyPath.lineTo(centerX - 65, centerY + 60);
    bodyPath.lineTo(centerX - 70, centerY + 50);
    bodyPath.lineTo(centerX - 30, centerY + 20);
    bodyPath.lineTo(centerX - 25, centerY - 20);
    bodyPath.quadraticBezierTo(centerX - 15, centerY - 50, centerX, centerY - 80);
    bodyPath.close();

    canvas.drawPath(bodyPath, bodyPaint);

    // Cockpit
    final cockpitGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF00FFFF),
        const Color(0xFF00D4FF),
        const Color(0xFF0088AA),
      ],
    ).createShader(Rect.fromLTWH(centerX - 15, centerY - 50, 30, 50));

    final cockpitPaint = Paint()
      ..shader = cockpitGradient
      ..style = PaintingStyle.fill;

    final cockpitPath = Path();
    cockpitPath.moveTo(centerX, centerY - 60);
    cockpitPath.quadraticBezierTo(centerX + 12, centerY - 40, centerX + 10, centerY - 10);
    cockpitPath.lineTo(centerX - 10, centerY - 10);
    cockpitPath.quadraticBezierTo(centerX - 12, centerY - 40, centerX, centerY - 60);
    cockpitPath.close();

    canvas.drawPath(cockpitPath, cockpitPaint);

    // Engine glow
    final engineGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFF6B35),
          const Color(0xFFFF6B35).withOpacity(0.5),
          const Color(0xFFFF6B35).withOpacity(0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(centerX, centerY + 70), radius: 30));

    canvas.drawCircle(Offset(centerX, centerY + 65), 25, engineGlow);

    // Engine flames
    final flamePaint = Paint()
      ..color = const Color(0xFFFFAA00)
      ..style = PaintingStyle.fill;

    final flamePath = Path();
    flamePath.moveTo(centerX - 10, centerY + 55);
    flamePath.quadraticBezierTo(centerX, centerY + 90, centerX + 10, centerY + 55);
    flamePath.close();
    canvas.drawPath(flamePath, flamePaint);

    // Highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final highlightPath = Path();
    highlightPath.moveTo(centerX - 5, centerY - 70);
    highlightPath.quadraticBezierTo(centerX - 20, centerY - 30, centerX - 22, centerY + 10);
    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EnergyRing extends StatelessWidget {
  const _EnergyRing();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _EnergyRingPainter(),
      size: const Size(300, 300),
    );
  }
}

class _EnergyRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;

    // Outer ring glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00D4FF).withOpacity(0),
          const Color(0xFF00D4FF).withOpacity(0.1),
          const Color(0xFF00D4FF).withOpacity(0.3),
          const Color(0xFF00D4FF).withOpacity(0.1),
          const Color(0xFF00D4FF).withOpacity(0),
        ],
        stops: const [0.7, 0.8, 0.85, 0.9, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius + 20));

    canvas.drawCircle(center, radius + 20, glowPaint);

    // Ring segments
    final ringPaint = Paint()
      ..color = const Color(0xFF00D4FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 8; i++) {
      final startAngle = (i * math.pi / 4) - math.pi / 2;
      final sweepAngle = math.pi / 6;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        ringPaint..color = const Color(0xFF00D4FF).withOpacity(0.5 + (i % 2) * 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GlowEffects extends StatelessWidget {
  const _GlowEffects();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GlowPainter(),
      size: Size.infinite,
    );
  }
}

class _GlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Central glow behind ship
    final centerGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00D4FF).withOpacity(0.4),
          const Color(0xFF00D4FF).withOpacity(0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.25));

    canvas.drawCircle(center, size.width * 0.25, centerGlow);

    // Top highlight
    final topGlow = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.center,
        colors: [
          const Color(0xFF00D4FF).withOpacity(0.2),
          const Color(0xFF00D4FF).withOpacity(0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height / 2));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height / 2), topGlow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
