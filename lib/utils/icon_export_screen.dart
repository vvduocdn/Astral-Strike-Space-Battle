import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Standalone screen to export the icon
/// Navigate to this screen and take a screenshot of just the icon
class IconExportScreen extends StatelessWidget {
  const IconExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Full screen icon for screenshot
    return const Scaffold(
      body: Center(
        child: SizedBox(
          width: 1024,
          height: 1024,
          child: AstralStrikeIconClean(),
        ),
      ),
    );
  }
}

/// Clean icon without any extra UI - perfect for export
class AstralStrikeIconClean extends StatelessWidget {
  const AstralStrikeIconClean({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D1B2A),
            Color(0xFF1B263B),
            Color(0xFF0D1B2A),
          ],
        ),
      ),
      child: CustomPaint(
        painter: AstralStrikeIconPainter(),
        size: Size.infinite,
      ),
    );
  }
}

class AstralStrikeIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = size.width / 512; // Base scale

    // Background gradient
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF0a0a1a),
          Color(0xFF0D1B2A),
          Color(0xFF1B263B),
          Color(0xFF0D1B2A),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Draw stars
    _drawStars(canvas, size);

    // Draw nebula effects
    _drawNebula(canvas, size);

    // Draw energy ring
    _drawEnergyRing(canvas, size, centerX, centerY, scale);

    // Draw center glow
    _drawCenterGlow(canvas, centerX, centerY, scale);

    // Draw spaceship
    _drawSpaceship(canvas, centerX, centerY, scale);
  }

  void _drawStars(Canvas canvas, Size size) {
    final paint = Paint();
    const seed = 42;

    for (int i = 0; i < 60; i++) {
      final x = ((seed * (i + 1) * 7) % size.width.toInt()).toDouble();
      final y = ((seed * (i + 3) * 13) % size.height.toInt()).toDouble();
      final radius = (i % 3) * 1.0 + 0.8;
      final opacity = 0.3 + (i % 5) * 0.15;

      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  void _drawNebula(Canvas canvas, Size size) {
    // Purple nebula
    final purplePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF7B2CBF).withOpacity(0.4),
          const Color(0xFF7B2CBF).withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(
          center: Offset(size.width * 0.75, size.height * 0.25),
          radius: size.width * 0.35));
    canvas.drawCircle(
        Offset(size.width * 0.75, size.height * 0.25), size.width * 0.35, purplePaint);

    // Cyan nebula
    final cyanPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00D4FF).withOpacity(0.25),
          const Color(0xFF00D4FF).withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(
          center: Offset(size.width * 0.25, size.height * 0.75),
          radius: size.width * 0.3));
    canvas.drawCircle(
        Offset(size.width * 0.25, size.height * 0.75), size.width * 0.3, cyanPaint);

    // Orange nebula (bottom right)
    final orangePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFF6B35).withOpacity(0.2),
          const Color(0xFFFF6B35).withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(
          center: Offset(size.width * 0.8, size.height * 0.8),
          radius: size.width * 0.25));
    canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.8), size.width * 0.25, orangePaint);
  }

  void _drawEnergyRing(Canvas canvas, Size size, double centerX, double centerY, double scale) {
    final radius = 180 * scale;

    // Outer glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00D4FF).withOpacity(0),
          const Color(0xFF00D4FF).withOpacity(0.15),
          const Color(0xFF00D4FF).withOpacity(0.4),
          const Color(0xFF00D4FF).withOpacity(0.15),
          const Color(0xFF00D4FF).withOpacity(0),
        ],
        stops: const [0.65, 0.75, 0.82, 0.89, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(centerX, centerY), radius: radius + 25 * scale));

    canvas.drawCircle(Offset(centerX, centerY), radius + 25 * scale, glowPaint);

    // Ring segments
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * scale
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 12; i++) {
      final startAngle = (i * math.pi / 6) - math.pi / 2;
      final sweepAngle = math.pi / 9;
      final opacity = 0.4 + (i % 3) * 0.3;

      ringPaint.color = const Color(0xFF00D4FF).withOpacity(opacity);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
        startAngle,
        sweepAngle,
        false,
        ringPaint,
      );
    }

    // Inner thin ring
    final innerRingPaint = Paint()
      ..color = const Color(0xFF00D4FF).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * scale;
    canvas.drawCircle(Offset(centerX, centerY), radius - 15 * scale, innerRingPaint);
  }

  void _drawCenterGlow(Canvas canvas, double centerX, double centerY, double scale) {
    final centerGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00D4FF).withOpacity(0.5),
          const Color(0xFF00D4FF).withOpacity(0.2),
          const Color(0xFF00D4FF).withOpacity(0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(centerX, centerY), radius: 100 * scale));

    canvas.drawCircle(Offset(centerX, centerY), 100 * scale, centerGlow);
  }

  void _drawSpaceship(Canvas canvas, double centerX, double centerY, double scale) {
    // Ship body gradient
    final bodyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF00FFFF),
        const Color(0xFF00D4FF),
        const Color(0xFF0088BB),
        const Color(0xFF005577),
      ],
    ).createShader(Rect.fromLTWH(
        centerX - 80 * scale, centerY - 100 * scale, 160 * scale, 200 * scale));

    final bodyPaint = Paint()
      ..shader = bodyGradient
      ..style = PaintingStyle.fill;

    // Main body path
    final bodyPath = Path();

    // Nose (top)
    bodyPath.moveTo(centerX, centerY - 95 * scale);

    // Right side curve
    bodyPath.quadraticBezierTo(
        centerX + 18 * scale, centerY - 60 * scale,
        centerX + 28 * scale, centerY - 25 * scale);
    bodyPath.lineTo(centerX + 35 * scale, centerY + 25 * scale);

    // Right wing
    bodyPath.lineTo(centerX + 85 * scale, centerY + 55 * scale);
    bodyPath.lineTo(centerX + 80 * scale, centerY + 70 * scale);
    bodyPath.lineTo(centerX + 30 * scale, centerY + 45 * scale);

    // Bottom right
    bodyPath.lineTo(centerX + 18 * scale, centerY + 70 * scale);
    bodyPath.lineTo(centerX, centerY + 55 * scale);

    // Bottom left (mirror)
    bodyPath.lineTo(centerX - 18 * scale, centerY + 70 * scale);
    bodyPath.lineTo(centerX - 30 * scale, centerY + 45 * scale);

    // Left wing
    bodyPath.lineTo(centerX - 80 * scale, centerY + 70 * scale);
    bodyPath.lineTo(centerX - 85 * scale, centerY + 55 * scale);
    bodyPath.lineTo(centerX - 35 * scale, centerY + 25 * scale);

    // Left side curve
    bodyPath.lineTo(centerX - 28 * scale, centerY - 25 * scale);
    bodyPath.quadraticBezierTo(
        centerX - 18 * scale, centerY - 60 * scale,
        centerX, centerY - 95 * scale);

    bodyPath.close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Wing accents
    final wingAccentPaint = Paint()
      ..color = const Color(0xFF00AACC)
      ..style = PaintingStyle.fill;

    // Right wing accent
    final rightWingPath = Path();
    rightWingPath.moveTo(centerX + 40 * scale, centerY + 30 * scale);
    rightWingPath.lineTo(centerX + 80 * scale, centerY + 55 * scale);
    rightWingPath.lineTo(centerX + 75 * scale, centerY + 65 * scale);
    rightWingPath.lineTo(centerX + 35 * scale, centerY + 42 * scale);
    rightWingPath.close();
    canvas.drawPath(rightWingPath, wingAccentPaint);

    // Left wing accent
    final leftWingPath = Path();
    leftWingPath.moveTo(centerX - 40 * scale, centerY + 30 * scale);
    leftWingPath.lineTo(centerX - 80 * scale, centerY + 55 * scale);
    leftWingPath.lineTo(centerX - 75 * scale, centerY + 65 * scale);
    leftWingPath.lineTo(centerX - 35 * scale, centerY + 42 * scale);
    leftWingPath.close();
    canvas.drawPath(leftWingPath, wingAccentPaint);

    // Cockpit
    final cockpitGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withOpacity(0.9),
        const Color(0xFF00FFFF),
        const Color(0xFF00AADD),
      ],
    ).createShader(Rect.fromLTWH(
        centerX - 15 * scale, centerY - 70 * scale, 30 * scale, 60 * scale));

    final cockpitPaint = Paint()
      ..shader = cockpitGradient
      ..style = PaintingStyle.fill;

    final cockpitPath = Path();
    cockpitPath.moveTo(centerX, centerY - 75 * scale);
    cockpitPath.quadraticBezierTo(
        centerX + 14 * scale, centerY - 50 * scale,
        centerX + 12 * scale, centerY - 15 * scale);
    cockpitPath.lineTo(centerX - 12 * scale, centerY - 15 * scale);
    cockpitPath.quadraticBezierTo(
        centerX - 14 * scale, centerY - 50 * scale,
        centerX, centerY - 75 * scale);
    cockpitPath.close();

    canvas.drawPath(cockpitPath, cockpitPaint);

    // Cockpit highlight
    final cockpitHighlight = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * scale;

    final highlightPath = Path();
    highlightPath.moveTo(centerX - 6 * scale, centerY - 65 * scale);
    highlightPath.quadraticBezierTo(
        centerX - 10 * scale, centerY - 45 * scale,
        centerX - 8 * scale, centerY - 25 * scale);
    canvas.drawPath(highlightPath, cockpitHighlight);

    // Engine glow
    final engineGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFFFFF),
          const Color(0xFFFFAA00),
          const Color(0xFFFF6B35),
          const Color(0xFFFF6B35).withOpacity(0),
        ],
        stops: const [0.0, 0.2, 0.5, 1.0],
      ).createShader(Rect.fromCircle(
          center: Offset(centerX, centerY + 80 * scale), radius: 40 * scale));

    canvas.drawCircle(Offset(centerX, centerY + 75 * scale), 35 * scale, engineGlow);

    // Engine flames
    final flamePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFFFFFFF),
          const Color(0xFFFFDD00),
          const Color(0xFFFF8800),
          const Color(0xFFFF4400).withOpacity(0),
        ],
      ).createShader(Rect.fromLTWH(
          centerX - 15 * scale, centerY + 60 * scale, 30 * scale, 50 * scale));

    final flamePath = Path();
    flamePath.moveTo(centerX - 12 * scale, centerY + 65 * scale);
    flamePath.quadraticBezierTo(
        centerX, centerY + 110 * scale,
        centerX + 12 * scale, centerY + 65 * scale);
    flamePath.close();
    canvas.drawPath(flamePath, flamePaint);

    // Body highlight
    final bodyHighlight = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * scale;

    final bodyHighlightPath = Path();
    bodyHighlightPath.moveTo(centerX - 8 * scale, centerY - 85 * scale);
    bodyHighlightPath.quadraticBezierTo(
        centerX - 22 * scale, centerY - 40 * scale,
        centerX - 28 * scale, centerY + 10 * scale);
    canvas.drawPath(bodyHighlightPath, bodyHighlight);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
