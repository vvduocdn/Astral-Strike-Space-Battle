import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../models/player_data.dart';
import '../space_shooter_game.dart';
import '../managers/audio_manager.dart';
import 'bullet.dart';
import 'particle_effects.dart';

class AnimatedPlayer extends PositionComponent
    with HasGameReference<SpaceShooterGame>, CollisionCallbacks {
  final PlayerData playerData;

  int health = GameConstants.playerMaxHealth;
  int lives = GameConstants.playerStartLives;

  bool hasShield = false;
  double shieldTimer = 0;
  double _shieldPulse = 0;

  bool hasSpeedBoost = false;
  double speedBoostTimer = 0;

  int weaponLevel = 1;
  bool hasTempWeaponUpgrade = false;
  double tempWeaponTimer = 0;

  double _invincibleTimer = 0;
  bool get isInvincible => _invincibleTimer > 0;

  // Animation
  double _engineFlicker = 0;
  double _tiltAngle = 0;
  double _targetTilt = 0;

  // Trail effect
  final List<Vector2> _trailPositions = [];
  static const int _maxTrailLength = 8;

  AnimatedPlayer({
    required Vector2 position,
    required this.playerData,
  }) : super(
          position: position,
          size: Vector2(GameConstants.playerWidth, GameConstants.playerHeight),
          anchor: Anchor.center,
        ) {
    health = playerData.maxHealth;
    weaponLevel = playerData.weaponLevels[playerData.currentWeapon] ?? 1;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  // Ship color schemes
  static const List<ShipDesign> shipDesigns = [
    ShipDesign(
      name: 'Fighter',
      primaryColor: Color(0xFF4a7a9a),
      secondaryColor: Color(0xFF2a5070),
      accentColor: Color(0xFF00DDFF),
      engineColor: Color(0xFFFF6600),
    ),
    ShipDesign(
      name: 'Stealth',
      primaryColor: Color(0xFF3a3a5a),
      secondaryColor: Color(0xFF1a1a3a),
      accentColor: Color(0xFFAA00FF),
      engineColor: Color(0xFF9900FF),
    ),
    ShipDesign(
      name: 'Bomber',
      primaryColor: Color(0xFF8a4a4a),
      secondaryColor: Color(0xFF5a2a2a),
      accentColor: Color(0xFFFF4400),
      engineColor: Color(0xFFFF2200),
    ),
    ShipDesign(
      name: 'Scout',
      primaryColor: Color(0xFF4a8a4a),
      secondaryColor: Color(0xFF2a5a2a),
      accentColor: Color(0xFF00FF66),
      engineColor: Color(0xFF66FF00),
    ),
    ShipDesign(
      name: 'Elite',
      primaryColor: Color(0xFFAA8844),
      secondaryColor: Color(0xFF886622),
      accentColor: Color(0xFFFFDD00),
      engineColor: Color(0xFFFFAA00),
    ),
  ];

  ShipDesign get currentDesign => shipDesigns[playerData.currentShipIndex.clamp(0, shipDesigns.length - 1)];

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(_tiltAngle * 0.3);
    canvas.translate(-size.x / 2, -size.y / 2);

    _drawTrail(canvas);

    final alpha = isInvincible ? 150 : 255;
    final design = currentDesign;

    // Draw ship based on design index
    switch (playerData.currentShipIndex) {
      case 1:
        _drawStealthShip(canvas, alpha, design);
        break;
      case 2:
        _drawBomberShip(canvas, alpha, design);
        break;
      case 3:
        _drawScoutShip(canvas, alpha, design);
        break;
      case 4:
        _drawEliteShip(canvas, alpha, design);
        break;
      default:
        _drawFighterShip(canvas, alpha, design);
    }

    _drawEngineGlow(canvas);

    if (hasShield) {
      _drawShield(canvas);
    }

    canvas.restore();
  }

  // === SHIP 0: FIGHTER (Default) ===
  void _drawFighterShip(Canvas canvas, int alpha, ShipDesign design) {
    _drawWings(canvas, alpha);
    _drawEnginePods(canvas, alpha);
    _drawMainBody(canvas, alpha);
    _drawCockpit(canvas, alpha);
    _drawWeaponMounts(canvas, alpha);
    _drawBodyDetails(canvas, alpha);
    _drawNeonLights(canvas);
  }

  // === SHIP 1: STEALTH ===
  void _drawStealthShip(Canvas canvas, int alpha, ShipDesign design) {
    final primary = design.primaryColor.withAlpha(alpha);
    final secondary = design.secondaryColor.withAlpha(alpha);
    final accent = design.accentColor.withAlpha(alpha);

    // Angular stealth body
    final bodyPath = Path();
    bodyPath.moveTo(size.x * 0.5, 0);
    bodyPath.lineTo(size.x * 0.85, size.y * 0.5);
    bodyPath.lineTo(size.x * 0.7, size.y * 0.9);
    bodyPath.lineTo(size.x * 0.5, size.y * 0.75);
    bodyPath.lineTo(size.x * 0.3, size.y * 0.9);
    bodyPath.lineTo(size.x * 0.15, size.y * 0.5);
    bodyPath.close();

    final gradient = ui.Gradient.linear(
      Offset(size.x * 0.3, 0),
      Offset(size.x * 0.7, size.y),
      [primary, secondary],
    );
    canvas.drawPath(bodyPath, Paint()..shader = gradient);

    // Stealth panels
    canvas.drawPath(
      bodyPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = accent.withAlpha(alpha ~/ 3),
    );

    // Sharp wings
    final leftWing = Path();
    leftWing.moveTo(size.x * 0.35, size.y * 0.4);
    leftWing.lineTo(0, size.y * 0.7);
    leftWing.lineTo(size.x * 0.2, size.y * 0.8);
    leftWing.lineTo(size.x * 0.35, size.y * 0.6);
    leftWing.close();
    canvas.drawPath(leftWing, Paint()..color = secondary);

    final rightWing = Path();
    rightWing.moveTo(size.x * 0.65, size.y * 0.4);
    rightWing.lineTo(size.x, size.y * 0.7);
    rightWing.lineTo(size.x * 0.8, size.y * 0.8);
    rightWing.lineTo(size.x * 0.65, size.y * 0.6);
    rightWing.close();
    canvas.drawPath(rightWing, Paint()..color = secondary);

    // Cockpit slit
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(size.x * 0.5, size.y * 0.3), width: size.x * 0.08, height: size.y * 0.2),
        const Radius.circular(4),
      ),
      Paint()..color = accent,
    );

    // Neon edges
    final neonPaint = Paint()
      ..color = accent.withAlpha((150 * (0.7 + math.sin(_engineFlicker * 8) * 0.3)).toInt())
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawLine(Offset(size.x * 0.5, size.y * 0.05), Offset(size.x * 0.15, size.y * 0.5), neonPaint);
    canvas.drawLine(Offset(size.x * 0.5, size.y * 0.05), Offset(size.x * 0.85, size.y * 0.5), neonPaint);
  }

  // === SHIP 2: BOMBER ===
  void _drawBomberShip(Canvas canvas, int alpha, ShipDesign design) {
    final primary = design.primaryColor.withAlpha(alpha);
    final secondary = design.secondaryColor.withAlpha(alpha);
    final accent = design.accentColor.withAlpha(alpha);

    // Heavy body
    final bodyPath = Path();
    bodyPath.moveTo(size.x * 0.5, size.y * 0.05);
    bodyPath.quadraticBezierTo(size.x * 0.7, size.y * 0.1, size.x * 0.7, size.y * 0.3);
    bodyPath.lineTo(size.x * 0.65, size.y * 0.8);
    bodyPath.lineTo(size.x * 0.35, size.y * 0.8);
    bodyPath.lineTo(size.x * 0.3, size.y * 0.3);
    bodyPath.quadraticBezierTo(size.x * 0.3, size.y * 0.1, size.x * 0.5, size.y * 0.05);
    bodyPath.close();

    final gradient = ui.Gradient.linear(
      Offset(size.x * 0.3, 0),
      Offset(size.x * 0.7, size.y),
      [primary, secondary],
    );
    canvas.drawPath(bodyPath, Paint()..shader = gradient);

    // Armor plates
    canvas.drawRect(
      Rect.fromLTWH(size.x * 0.35, size.y * 0.4, size.x * 0.3, size.y * 0.35),
      Paint()..color = secondary,
    );

    // Side pods
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(size.x * 0.15, size.y * 0.55), width: size.x * 0.2, height: size.y * 0.4),
        const Radius.circular(6),
      ),
      Paint()..color = primary,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(size.x * 0.85, size.y * 0.55), width: size.x * 0.2, height: size.y * 0.4),
        const Radius.circular(6),
      ),
      Paint()..color = primary,
    );

    // Cockpit
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.x * 0.5, size.y * 0.25), width: size.x * 0.2, height: size.y * 0.15),
      Paint()..color = accent,
    );

    // Warning stripes
    final stripePaint = Paint()..color = Colors.yellow.withAlpha(alpha ~/ 2);
    for (int i = 0; i < 3; i++) {
      canvas.drawRect(
        Rect.fromLTWH(size.x * 0.38, size.y * 0.5 + i * 8, size.x * 0.24, 3),
        stripePaint,
      );
    }
  }

  // === SHIP 3: SCOUT ===
  void _drawScoutShip(Canvas canvas, int alpha, ShipDesign design) {
    final primary = design.primaryColor.withAlpha(alpha);
    final secondary = design.secondaryColor.withAlpha(alpha);
    final accent = design.accentColor.withAlpha(alpha);

    // Sleek needle body
    final bodyPath = Path();
    bodyPath.moveTo(size.x * 0.5, 0);
    bodyPath.quadraticBezierTo(size.x * 0.6, size.y * 0.15, size.x * 0.58, size.y * 0.4);
    bodyPath.lineTo(size.x * 0.55, size.y * 0.85);
    bodyPath.lineTo(size.x * 0.45, size.y * 0.85);
    bodyPath.lineTo(size.x * 0.42, size.y * 0.4);
    bodyPath.quadraticBezierTo(size.x * 0.4, size.y * 0.15, size.x * 0.5, 0);
    bodyPath.close();

    final gradient = ui.Gradient.linear(
      Offset(size.x * 0.4, 0),
      Offset(size.x * 0.6, size.y),
      [primary, secondary],
    );
    canvas.drawPath(bodyPath, Paint()..shader = gradient);

    // Swept wings
    final leftWing = Path();
    leftWing.moveTo(size.x * 0.42, size.y * 0.35);
    leftWing.lineTo(0, size.y * 0.6);
    leftWing.lineTo(size.x * 0.05, size.y * 0.75);
    leftWing.lineTo(size.x * 0.35, size.y * 0.7);
    leftWing.close();

    final wingGradient = ui.Gradient.linear(
      Offset(0, size.y * 0.5),
      Offset(size.x * 0.4, size.y * 0.7),
      [secondary, primary],
    );
    canvas.drawPath(leftWing, Paint()..shader = wingGradient);

    final rightWing = Path();
    rightWing.moveTo(size.x * 0.58, size.y * 0.35);
    rightWing.lineTo(size.x, size.y * 0.6);
    rightWing.lineTo(size.x * 0.95, size.y * 0.75);
    rightWing.lineTo(size.x * 0.65, size.y * 0.7);
    rightWing.close();
    canvas.drawPath(rightWing, Paint()..shader = wingGradient);

    // Cockpit bubble
    final cockpitGradient = ui.Gradient.radial(
      Offset(size.x * 0.5, size.y * 0.22),
      size.x * 0.1,
      [Colors.white.withAlpha(alpha), accent],
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.x * 0.5, size.y * 0.25), width: size.x * 0.15, height: size.y * 0.12),
      Paint()..shader = cockpitGradient,
    );

    // Speed lines
    final linePaint = Paint()
      ..color = accent.withAlpha((180 * (0.7 + math.sin(_engineFlicker * 10) * 0.3)).toInt())
      ..strokeWidth = 2;
    canvas.drawLine(Offset(size.x * 0.1, size.y * 0.65), Offset(size.x * 0.1, size.y * 0.5), linePaint);
    canvas.drawLine(Offset(size.x * 0.9, size.y * 0.65), Offset(size.x * 0.9, size.y * 0.5), linePaint);
  }

  // === SHIP 4: ELITE ===
  void _drawEliteShip(Canvas canvas, int alpha, ShipDesign design) {
    final primary = design.primaryColor.withAlpha(alpha);
    final secondary = design.secondaryColor.withAlpha(alpha);
    final accent = design.accentColor.withAlpha(alpha);

    // Royal body shape
    final bodyPath = Path();
    bodyPath.moveTo(size.x * 0.5, 0);
    bodyPath.quadraticBezierTo(size.x * 0.65, size.y * 0.1, size.x * 0.62, size.y * 0.35);
    bodyPath.lineTo(size.x * 0.7, size.y * 0.5);
    bodyPath.lineTo(size.x * 0.6, size.y * 0.85);
    bodyPath.lineTo(size.x * 0.4, size.y * 0.85);
    bodyPath.lineTo(size.x * 0.3, size.y * 0.5);
    bodyPath.lineTo(size.x * 0.38, size.y * 0.35);
    bodyPath.quadraticBezierTo(size.x * 0.35, size.y * 0.1, size.x * 0.5, 0);
    bodyPath.close();

    // Gold gradient
    final gradient = ui.Gradient.linear(
      Offset(size.x * 0.3, 0),
      Offset(size.x * 0.7, size.y),
      [accent, primary, secondary],
      [0.0, 0.5, 1.0],
    );
    canvas.drawPath(bodyPath, Paint()..shader = gradient);

    // Crown wings
    final leftWing = Path();
    leftWing.moveTo(size.x * 0.3, size.y * 0.4);
    leftWing.lineTo(0, size.y * 0.35);
    leftWing.lineTo(size.x * 0.05, size.y * 0.65);
    leftWing.lineTo(size.x * 0.25, size.y * 0.75);
    leftWing.close();
    canvas.drawPath(leftWing, Paint()..color = primary);

    final rightWing = Path();
    rightWing.moveTo(size.x * 0.7, size.y * 0.4);
    rightWing.lineTo(size.x, size.y * 0.35);
    rightWing.lineTo(size.x * 0.95, size.y * 0.65);
    rightWing.lineTo(size.x * 0.75, size.y * 0.75);
    rightWing.close();
    canvas.drawPath(rightWing, Paint()..color = primary);

    // Royal cockpit
    final cockpitGradient = ui.Gradient.radial(
      Offset(size.x * 0.5, size.y * 0.28),
      size.x * 0.12,
      [Colors.white.withAlpha(alpha), accent, const Color(0xFF442200).withAlpha(alpha)],
      [0.0, 0.5, 1.0],
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.x * 0.5, size.y * 0.3), width: size.x * 0.2, height: size.y * 0.18),
      Paint()..shader = cockpitGradient,
    );

    // Crown jewels (glowing orbs)
    final jewelPaint = Paint()
      ..color = accent
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(size.x * 0.5, size.y * 0.08), 4, jewelPaint);
    canvas.drawCircle(Offset(size.x * 0.08, size.y * 0.4), 3, jewelPaint);
    canvas.drawCircle(Offset(size.x * 0.92, size.y * 0.4), 3, jewelPaint);

    // Gold trim
    canvas.drawPath(
      bodyPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = accent.withAlpha(alpha ~/ 2),
    );
  }

  void _drawWings(Canvas canvas, int alpha) {
    // Left wing
    final leftWingPath = Path();
    leftWingPath.moveTo(size.x * 0.35, size.y * 0.4);
    leftWingPath.lineTo(size.x * 0.05, size.y * 0.55);
    leftWingPath.lineTo(size.x * 0.0, size.y * 0.7);
    leftWingPath.lineTo(size.x * 0.15, size.y * 0.65);
    leftWingPath.lineTo(size.x * 0.25, size.y * 0.85);
    leftWingPath.lineTo(size.x * 0.35, size.y * 0.7);
    leftWingPath.close();

    final wingGradient = ui.Gradient.linear(
      Offset(0, size.y * 0.4),
      Offset(size.x * 0.35, size.y * 0.7),
      [
        const Color(0xFF1a3a5c).withAlpha(alpha),
        const Color(0xFF0d2035).withAlpha(alpha),
      ],
    );

    canvas.drawPath(leftWingPath, Paint()..shader = wingGradient);

    // Wing edge highlight
    canvas.drawPath(
      leftWingPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = GameColors.primary.withAlpha(alpha ~/ 2),
    );

    // Right wing (mirror)
    final rightWingPath = Path();
    rightWingPath.moveTo(size.x * 0.65, size.y * 0.4);
    rightWingPath.lineTo(size.x * 0.95, size.y * 0.55);
    rightWingPath.lineTo(size.x * 1.0, size.y * 0.7);
    rightWingPath.lineTo(size.x * 0.85, size.y * 0.65);
    rightWingPath.lineTo(size.x * 0.75, size.y * 0.85);
    rightWingPath.lineTo(size.x * 0.65, size.y * 0.7);
    rightWingPath.close();

    canvas.drawPath(rightWingPath, Paint()..shader = wingGradient);
    canvas.drawPath(
      rightWingPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = GameColors.primary.withAlpha(alpha ~/ 2),
    );
  }

  void _drawEnginePods(Canvas canvas, int alpha) {
    final podPaint = Paint()..color = const Color(0xFF2a4a6a).withAlpha(alpha);
    final podHighlight = Paint()..color = const Color(0xFF3a6a8a).withAlpha(alpha);

    // Left engine pod
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.x * 0.28, size.y * 0.75),
          width: size.x * 0.12,
          height: size.y * 0.25,
        ),
        const Radius.circular(4),
      ),
      podPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.x * 0.28, size.y * 0.7),
          width: size.x * 0.06,
          height: size.y * 0.1,
        ),
        const Radius.circular(2),
      ),
      podHighlight,
    );

    // Right engine pod
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.x * 0.72, size.y * 0.75),
          width: size.x * 0.12,
          height: size.y * 0.25,
        ),
        const Radius.circular(4),
      ),
      podPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.x * 0.72, size.y * 0.7),
          width: size.x * 0.06,
          height: size.y * 0.1,
        ),
        const Radius.circular(2),
      ),
      podHighlight,
    );
  }

  void _drawMainBody(Canvas canvas, int alpha) {
    // Main fuselage gradient
    final bodyGradient = ui.Gradient.linear(
      Offset(size.x * 0.3, 0),
      Offset(size.x * 0.7, size.y),
      [
        const Color(0xFF4a7a9a).withAlpha(alpha),
        const Color(0xFF2a5070).withAlpha(alpha),
        const Color(0xFF1a3050).withAlpha(alpha),
      ],
      [0.0, 0.5, 1.0],
    );

    final bodyPath = Path();
    // Streamlined nose
    bodyPath.moveTo(size.x * 0.5, 0);
    bodyPath.quadraticBezierTo(size.x * 0.58, size.y * 0.05, size.x * 0.6, size.y * 0.15);
    bodyPath.lineTo(size.x * 0.65, size.y * 0.35);
    bodyPath.lineTo(size.x * 0.62, size.y * 0.6);
    bodyPath.lineTo(size.x * 0.58, size.y * 0.8);
    bodyPath.lineTo(size.x * 0.5, size.y * 0.85);
    bodyPath.lineTo(size.x * 0.42, size.y * 0.8);
    bodyPath.lineTo(size.x * 0.38, size.y * 0.6);
    bodyPath.lineTo(size.x * 0.35, size.y * 0.35);
    bodyPath.lineTo(size.x * 0.4, size.y * 0.15);
    bodyPath.quadraticBezierTo(size.x * 0.42, size.y * 0.05, size.x * 0.5, 0);
    bodyPath.close();

    canvas.drawPath(bodyPath, Paint()..shader = bodyGradient);

    // Body highlight (top reflection)
    final highlightPath = Path();
    highlightPath.moveTo(size.x * 0.5, size.y * 0.02);
    highlightPath.quadraticBezierTo(size.x * 0.55, size.y * 0.08, size.x * 0.55, size.y * 0.2);
    highlightPath.lineTo(size.x * 0.5, size.y * 0.25);
    highlightPath.lineTo(size.x * 0.45, size.y * 0.2);
    highlightPath.quadraticBezierTo(size.x * 0.45, size.y * 0.08, size.x * 0.5, size.y * 0.02);
    highlightPath.close();

    canvas.drawPath(
      highlightPath,
      Paint()..color = Colors.white.withAlpha(alpha ~/ 4),
    );
  }

  void _drawCockpit(Canvas canvas, int alpha) {
    // Cockpit frame
    final frameGradient = ui.Gradient.linear(
      Offset(size.x * 0.4, size.y * 0.2),
      Offset(size.x * 0.6, size.y * 0.45),
      [
        const Color(0xFF1a2a3a).withAlpha(alpha),
        const Color(0xFF0a1520).withAlpha(alpha),
      ],
    );

    final framePath = Path();
    framePath.moveTo(size.x * 0.5, size.y * 0.18);
    framePath.quadraticBezierTo(size.x * 0.58, size.y * 0.22, size.x * 0.58, size.y * 0.32);
    framePath.quadraticBezierTo(size.x * 0.56, size.y * 0.42, size.x * 0.5, size.y * 0.45);
    framePath.quadraticBezierTo(size.x * 0.44, size.y * 0.42, size.x * 0.42, size.y * 0.32);
    framePath.quadraticBezierTo(size.x * 0.42, size.y * 0.22, size.x * 0.5, size.y * 0.18);
    framePath.close();

    canvas.drawPath(framePath, Paint()..shader = frameGradient);

    // Cockpit glass with glow
    final glassGradient = ui.Gradient.radial(
      Offset(size.x * 0.5, size.y * 0.28),
      size.x * 0.12,
      [
        Colors.cyan.shade300.withAlpha(alpha),
        GameColors.accent.withAlpha(alpha),
        const Color(0xFF004466).withAlpha(alpha),
      ],
      [0.0, 0.5, 1.0],
    );

    final glassPath = Path();
    glassPath.moveTo(size.x * 0.5, size.y * 0.22);
    glassPath.quadraticBezierTo(size.x * 0.55, size.y * 0.25, size.x * 0.55, size.y * 0.32);
    glassPath.quadraticBezierTo(size.x * 0.53, size.y * 0.38, size.x * 0.5, size.y * 0.4);
    glassPath.quadraticBezierTo(size.x * 0.47, size.y * 0.38, size.x * 0.45, size.y * 0.32);
    glassPath.quadraticBezierTo(size.x * 0.45, size.y * 0.25, size.x * 0.5, size.y * 0.22);
    glassPath.close();

    canvas.drawPath(glassPath, Paint()..shader = glassGradient);

    // Cockpit reflection
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x * 0.48, size.y * 0.27),
        width: size.x * 0.06,
        height: size.y * 0.04,
      ),
      Paint()..color = Colors.white.withAlpha(alpha ~/ 3),
    );
  }

  void _drawWeaponMounts(Canvas canvas, int alpha) {
    final mountPaint = Paint()..color = const Color(0xFF3a3a4a).withAlpha(alpha);

    // Left weapon mount
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * 0.18, size.y * 0.45, size.x * 0.08, size.y * 0.2),
        const Radius.circular(2),
      ),
      mountPaint,
    );

    // Right weapon mount
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * 0.74, size.y * 0.45, size.x * 0.08, size.y * 0.2),
        const Radius.circular(2),
      ),
      mountPaint,
    );

    // Cannon tips
    final cannonPaint = Paint()..color = const Color(0xFF5a5a6a).withAlpha(alpha);
    canvas.drawCircle(Offset(size.x * 0.22, size.y * 0.45), 3, cannonPaint);
    canvas.drawCircle(Offset(size.x * 0.78, size.y * 0.45), 3, cannonPaint);
  }

  void _drawBodyDetails(Canvas canvas, int alpha) {
    final linePaint = Paint()
      ..color = const Color(0xFF5a8aaa).withAlpha(alpha ~/ 2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Panel lines on body
    canvas.drawLine(
      Offset(size.x * 0.42, size.y * 0.5),
      Offset(size.x * 0.42, size.y * 0.75),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.x * 0.58, size.y * 0.5),
      Offset(size.x * 0.58, size.y * 0.75),
      linePaint,
    );

    // Cross panel
    canvas.drawLine(
      Offset(size.x * 0.4, size.y * 0.55),
      Offset(size.x * 0.6, size.y * 0.55),
      linePaint,
    );

    // Vents
    final ventPaint = Paint()..color = const Color(0xFF1a2a3a).withAlpha(alpha);
    for (int i = 0; i < 3; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          size.x * 0.44,
          size.y * 0.6 + i * 6,
          size.x * 0.12,
          2,
        ),
        ventPaint,
      );
    }
  }

  void _drawNeonLights(Canvas canvas) {
    final flickerIntensity = 0.7 + math.sin(_engineFlicker * 8) * 0.3;
    final neonAlpha = (180 * flickerIntensity).toInt();

    // Wing tip lights
    final neonPaint = Paint()
      ..color = GameColors.primary.withAlpha(neonAlpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(Offset(size.x * 0.05, size.y * 0.6), 3, neonPaint);
    canvas.drawCircle(Offset(size.x * 0.95, size.y * 0.6), 3, neonPaint);

    // Engine pod lights
    final engineNeon = Paint()
      ..color = GameColors.secondary.withAlpha(neonAlpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawCircle(Offset(size.x * 0.28, size.y * 0.65), 2, engineNeon);
    canvas.drawCircle(Offset(size.x * 0.72, size.y * 0.65), 2, engineNeon);

    // Cockpit glow edge
    final cockpitGlow = Paint()
      ..color = Colors.cyan.withAlpha(neonAlpha ~/ 2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final glowPath = Path();
    glowPath.moveTo(size.x * 0.5, size.y * 0.2);
    glowPath.quadraticBezierTo(size.x * 0.56, size.y * 0.24, size.x * 0.56, size.y * 0.32);
    glowPath.quadraticBezierTo(size.x * 0.54, size.y * 0.4, size.x * 0.5, size.y * 0.42);

    canvas.drawPath(glowPath, cockpitGlow);
  }

  void _drawTrail(Canvas canvas) {
    if (_trailPositions.isEmpty) return;

    for (int i = 0; i < _trailPositions.length; i++) {
      final alpha = (i / _trailPositions.length) * 0.3;
      final trailSize = (i / _trailPositions.length) * 0.5;

      final offset = _trailPositions[i] - position;

      final trailPaint = Paint()
        ..color = GameColors.primary.withAlpha((alpha * 255).toInt())
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      canvas.drawCircle(
        Offset(size.x / 2 + offset.x, size.y / 2 + offset.y),
        size.x * 0.15 * trailSize,
        trailPaint,
      );
    }
  }

  void _drawEngineGlow(Canvas canvas) {
    final flickerIntensity = 0.7 + math.sin(_engineFlicker * 15) * 0.3;

    // Left engine pod flame
    _drawSingleEngine(canvas, size.x * 0.28, flickerIntensity, yOffset: size.y * 0.88);
    // Right engine pod flame
    _drawSingleEngine(canvas, size.x * 0.72, flickerIntensity, yOffset: size.y * 0.88);

    // Center main engine
    _drawSingleEngine(canvas, size.x * 0.5, flickerIntensity * 0.8, yOffset: size.y * 0.85);

    // Speed boost extra flames
    if (hasSpeedBoost) {
      _drawSingleEngine(canvas, size.x * 0.28, flickerIntensity * 1.3, isBoost: true, yOffset: size.y * 0.88);
      _drawSingleEngine(canvas, size.x * 0.72, flickerIntensity * 1.3, isBoost: true, yOffset: size.y * 0.88);
      _drawSingleEngine(canvas, size.x * 0.5, flickerIntensity * 1.5, isBoost: true, yOffset: size.y * 0.85);
    }
  }

  void _drawSingleEngine(Canvas canvas, double x, double intensity,
      {bool isBoost = false, double? yOffset}) {
    final flameHeight = (isBoost ? 30 : 18) * intensity;
    final flameWidth = isBoost ? 14 : 10;
    final baseY = yOffset ?? size.y;

    // Outer flame glow
    final outerPaint = Paint()
      ..color = GameColors.secondary.withAlpha((180 * intensity).toInt())
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x, baseY + flameHeight / 2),
        width: flameWidth.toDouble(),
        height: flameHeight,
      ),
      outerPaint,
    );

    // Middle flame
    final middlePaint = Paint()
      ..color = Colors.orange.withAlpha((200 * intensity).toInt())
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x, baseY + flameHeight / 3),
        width: flameWidth * 0.7,
        height: flameHeight * 0.7,
      ),
      middlePaint,
    );

    // Inner flame core
    final innerPaint = Paint()
      ..color = Colors.white.withAlpha((240 * intensity).toInt())
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x, baseY + flameHeight / 4),
        width: flameWidth * 0.4,
        height: flameHeight * 0.5,
      ),
      innerPaint,
    );
  }

  void _drawShield(Canvas canvas) {
    final pulseSize = 1.0 + math.sin(_shieldPulse * 4) * 0.1;

    // Outer shield
    final shieldPaint = Paint()
      ..color = GameColors.shield.withAlpha(50)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y / 2),
        width: size.x * 1.5 * pulseSize,
        height: size.y * 1.4 * pulseSize,
      ),
      shieldPaint,
    );

    // Shield border
    final borderPaint = Paint()
      ..color = GameColors.shield.withAlpha(150)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y / 2),
        width: size.x * 1.5 * pulseSize,
        height: size.y * 1.4 * pulseSize,
      ),
      borderPaint,
    );

    // Hexagon pattern
    _drawHexPattern(canvas, pulseSize);
  }

  void _drawHexPattern(Canvas canvas, double scale) {
    final patternPaint = Paint()
      ..color = GameColors.shield.withAlpha(30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3 + _shieldPulse;
      final x = size.x / 2 + math.cos(angle) * size.x * 0.5 * scale;
      final y = size.y / 2 + math.sin(angle) * size.y * 0.45 * scale;

      canvas.drawCircle(Offset(x, y), 5, patternPaint);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update animations
    _engineFlicker += dt;
    _shieldPulse += dt;

    // Smooth tilt
    _tiltAngle += (_targetTilt - _tiltAngle) * 5 * dt;
    _targetTilt *= 0.95; // Decay

    // Update trail
    _updateTrail();

    // Update invincibility
    if (_invincibleTimer > 0) {
      _invincibleTimer -= dt;
    }

    // Update shield
    if (hasShield) {
      shieldTimer -= dt;
      if (shieldTimer <= 0) {
        hasShield = false;
      }
    }

    // Update speed boost
    if (hasSpeedBoost) {
      speedBoostTimer -= dt;
      if (speedBoostTimer <= 0) {
        hasSpeedBoost = false;
      }
    }

    // Update temp weapon
    if (hasTempWeaponUpgrade) {
      tempWeaponTimer -= dt;
      if (tempWeaponTimer <= 0) {
        hasTempWeaponUpgrade = false;
      }
    }
  }

  void _updateTrail() {
    _trailPositions.insert(0, position.clone());
    if (_trailPositions.length > _maxTrailLength) {
      _trailPositions.removeLast();
    }
  }

  void move(Vector2 delta) {
    // Apply speed multiplier
    double speedMult = playerData.speedMultiplier;
    if (hasSpeedBoost) speedMult *= 1.5;

    // Set tilt based on horizontal movement
    _targetTilt = (delta.x / 10).clamp(-1.0, 1.0);

    position.x += delta.x * speedMult;
    position.y += delta.y * speedMult;

    // Clamp to screen bounds
    position.x =
        position.x.clamp(size.x / 2, GameConstants.gameWidth - size.x / 2);
    position.y = position.y.clamp(
      GameConstants.gameHeight * 0.3,
      GameConstants.gameHeight - size.y / 2,
    );
  }

  List<Bullet> shoot() {
    AudioManager().playShoot();

    final bullets = <Bullet>[];
    final currentWeaponLevel =
        hasTempWeaponUpgrade ? weaponLevel + 2 : weaponLevel;

    switch (playerData.currentWeapon) {
      case WeaponType.laser:
        bullets.add(_createBullet(0, currentWeaponLevel));
        if (currentWeaponLevel >= 3) {
          bullets.add(_createBullet(-15, currentWeaponLevel));
          bullets.add(_createBullet(15, currentWeaponLevel));
        }
        break;

      case WeaponType.spread:
        bullets.add(_createBullet(0, currentWeaponLevel));
        bullets.add(_createBullet(-20, currentWeaponLevel, angle: -0.3));
        bullets.add(_createBullet(20, currentWeaponLevel, angle: 0.3));
        if (currentWeaponLevel >= 2) {
          bullets.add(_createBullet(-35, currentWeaponLevel, angle: -0.5));
          bullets.add(_createBullet(35, currentWeaponLevel, angle: 0.5));
        }
        break;

      case WeaponType.missile:
        bullets.add(_createBullet(0, currentWeaponLevel, isMissile: true));
        if (currentWeaponLevel >= 2) {
          bullets.add(_createBullet(-20, currentWeaponLevel, isMissile: true));
          bullets.add(_createBullet(20, currentWeaponLevel, isMissile: true));
        }
        break;

      case WeaponType.plasma:
        bullets.add(_createBullet(0, currentWeaponLevel, isPiercing: true));
        break;

      case WeaponType.thunder:
        bullets.add(_createBullet(0, currentWeaponLevel, isThunder: true));
        break;
    }

    // Add muzzle flash
    game.world.add(MuzzleFlash(position: Vector2(position.x, position.y - size.y / 2)));

    return bullets;
  }

  Bullet _createBullet(
    double offsetX,
    int level, {
    double angle = 0,
    bool isMissile = false,
    bool isPiercing = false,
    bool isThunder = false,
  }) {
    return Bullet(
      position: Vector2(position.x + offsetX, position.y - size.y / 2),
      damage: 10 + (level * 5),
      angle: angle,
      isMissile: isMissile,
      isPiercing: isPiercing,
      isThunder: isThunder,
      weaponType: playerData.currentWeapon,
    );
  }

  void takeDamage(int damage) {
    if (isInvincible) return;

    if (hasShield) {
      hasShield = false;
      shieldTimer = 0;
      _invincibleTimer = 0.5;
      AudioManager().playHit();
      return;
    }

    health -= damage;
    _invincibleTimer = 1.0;
    AudioManager().playHit();

    // Add hit effect
    game.world.add(HitFlash(position: position.clone()));
  }

  void heal(int amount) {
    health = (health + amount).clamp(0, playerData.maxHealth);
    AudioManager().playPowerUp();
  }

  void activateShield(double duration) {
    hasShield = true;
    shieldTimer = duration;
    AudioManager().playPowerUp();
  }

  void activateSpeedBoost(double duration) {
    hasSpeedBoost = true;
    speedBoostTimer = duration;
    AudioManager().playPowerUp();
  }

  void upgradeWeaponTemporary() {
    hasTempWeaponUpgrade = true;
    tempWeaponTimer = 10.0;
    AudioManager().playPowerUp();
  }

  void respawn() {
    position = Vector2(
      GameConstants.gameWidth / 2,
      GameConstants.gameHeight - 100,
    );
    health = playerData.maxHealth;
    _invincibleTimer = 3.0;
    hasShield = false;
    hasSpeedBoost = false;
    hasTempWeaponUpgrade = false;
    _trailPositions.clear();
  }

  void reset() {
    lives = GameConstants.playerStartLives;
    respawn();
  }
}

// Ship design data class
class ShipDesign {
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color engineColor;

  const ShipDesign({
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.engineColor,
  });
}
