// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

/// Generate app icon PNG file using the `image` package
/// Run with: dart run tool/generate_icon.dart
void main() {
  print('Generating Astral Strike app icon...');

  const size = 1024;
  final image = img.Image(width: size, height: size);

  // Draw the icon
  drawAstralStrikeIcon(image);

  // Save to file
  final pngBytes = img.encodePng(image);
  final file = File('assets/icon/app_icon.png');
  file.writeAsBytesSync(pngBytes);

  print('Icon saved to: assets/icon/app_icon.png');
  print('Size: ${pngBytes.length} bytes');
  print('Done! Now run: dart run flutter_launcher_icons');
}

void drawAstralStrikeIcon(img.Image image) {
  final size = image.width;
  final centerX = size ~/ 2;
  final centerY = size ~/ 2;

  // Background - dark space gradient
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final t = (x + y) / (size * 2);
      final r = _lerp(10, 27, t).toInt();
      final g = _lerp(10, 38, t).toInt();
      final b = _lerp(26, 59, t).toInt();
      image.setPixel(x, y, img.ColorRgba8(r, g, b, 255));
    }
  }

  // Draw stars
  _drawStars(image, size);

  // Draw nebula effects
  _drawNebula(image, size);

  // Draw energy ring
  _drawEnergyRing(image, centerX, centerY, size);

  // Draw center glow
  _drawCenterGlow(image, centerX, centerY, size);

  // Draw spaceship
  _drawSpaceship(image, centerX, centerY, size);
}

double _lerp(double a, double b, double t) => a + (b - a) * t;

void _drawStars(img.Image image, int size) {
  final random = math.Random(42);
  for (int i = 0; i < 80; i++) {
    final x = random.nextInt(size);
    final y = random.nextInt(size);
    final radius = random.nextInt(3) + 1;
    final brightness = 100 + random.nextInt(155);

    _drawCircle(image, x, y, radius, img.ColorRgba8(brightness, brightness, brightness, brightness));
  }
}

void _drawNebula(img.Image image, int size) {
  // Purple nebula (top right)
  _drawGradientCircle(
    image,
    (size * 0.75).toInt(),
    (size * 0.25).toInt(),
    (size * 0.35).toInt(),
    img.ColorRgba8(123, 44, 191, 100),
  );

  // Cyan nebula (bottom left)
  _drawGradientCircle(
    image,
    (size * 0.25).toInt(),
    (size * 0.75).toInt(),
    (size * 0.3).toInt(),
    img.ColorRgba8(0, 212, 255, 80),
  );

  // Orange nebula (bottom right)
  _drawGradientCircle(
    image,
    (size * 0.8).toInt(),
    (size * 0.8).toInt(),
    (size * 0.2).toInt(),
    img.ColorRgba8(255, 107, 53, 60),
  );
}

void _drawGradientCircle(img.Image image, int cx, int cy, int radius, img.Color color) {
  final c = color as img.ColorRgba8;
  final r = c.r.toInt();
  final g = c.g.toInt();
  final b = c.b.toInt();
  final a = c.a.toInt();

  for (int dy = -radius; dy <= radius; dy++) {
    for (int dx = -radius; dx <= radius; dx++) {
      final dist = math.sqrt(dx * dx + dy * dy);
      if (dist <= radius) {
        final x = cx + dx;
        final y = cy + dy;
        if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
          final factor = 1.0 - (dist / radius);
          final alpha = (a * factor * factor).toInt().clamp(0, 255);
          if (alpha > 0) {
            _blendPixel(image, x, y, img.ColorRgba8(r, g, b, alpha));
          }
        }
      }
    }
  }
}

void _drawEnergyRing(img.Image image, int centerX, int centerY, int size) {
  final radius = (size * 0.35).toInt();
  final ringWidth = (size * 0.015).toInt();

  // Outer glow
  _drawGradientCircle(image, centerX, centerY, radius + 30, img.ColorRgba8(0, 212, 255, 60));

  // Ring segments
  for (int i = 0; i < 12; i++) {
    final startAngle = (i * math.pi / 6) - math.pi / 2;
    final endAngle = startAngle + math.pi / 9;
    final alpha = (100 + (i % 3) * 50).clamp(0, 255);

    _drawArc(image, centerX, centerY, radius, startAngle, endAngle, ringWidth,
        img.ColorRgba8(0, 212, 255, alpha));
  }

  // Inner ring
  _drawRing(image, centerX, centerY, radius - 15, 2, img.ColorRgba8(0, 212, 255, 80));
}

void _drawArc(img.Image image, int cx, int cy, int radius, double startAngle,
    double endAngle, int width, img.Color color) {
  for (double angle = startAngle; angle <= endAngle; angle += 0.01) {
    for (int w = -width; w <= width; w++) {
      final r = radius + w;
      final x = cx + (r * math.cos(angle)).toInt();
      final y = cy + (r * math.sin(angle)).toInt();
      if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
        _blendPixel(image, x, y, color);
      }
    }
  }
}

void _drawRing(img.Image image, int cx, int cy, int radius, int width, img.Color color) {
  for (double angle = 0; angle < math.pi * 2; angle += 0.005) {
    for (int w = -width; w <= width; w++) {
      final r = radius + w;
      final x = cx + (r * math.cos(angle)).toInt();
      final y = cy + (r * math.sin(angle)).toInt();
      if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
        _blendPixel(image, x, y, color);
      }
    }
  }
}

void _drawCenterGlow(img.Image image, int centerX, int centerY, int size) {
  final radius = (size * 0.2).toInt();
  _drawGradientCircle(image, centerX, centerY, radius, img.ColorRgba8(0, 212, 255, 120));
}

void _drawSpaceship(img.Image image, int centerX, int centerY, int size) {
  final scale = size / 512.0;

  // Ship body points
  final List<List<int>> bodyPoints = [
    [centerX, (centerY - 95 * scale).toInt()], // Nose
    [(centerX + 28 * scale).toInt(), (centerY - 25 * scale).toInt()],
    [(centerX + 35 * scale).toInt(), (centerY + 25 * scale).toInt()],
    [(centerX + 85 * scale).toInt(), (centerY + 55 * scale).toInt()], // Right wing tip
    [(centerX + 80 * scale).toInt(), (centerY + 70 * scale).toInt()],
    [(centerX + 30 * scale).toInt(), (centerY + 45 * scale).toInt()],
    [(centerX + 18 * scale).toInt(), (centerY + 70 * scale).toInt()],
    [centerX, (centerY + 55 * scale).toInt()], // Bottom center
    [(centerX - 18 * scale).toInt(), (centerY + 70 * scale).toInt()],
    [(centerX - 30 * scale).toInt(), (centerY + 45 * scale).toInt()],
    [(centerX - 80 * scale).toInt(), (centerY + 70 * scale).toInt()],
    [(centerX - 85 * scale).toInt(), (centerY + 55 * scale).toInt()], // Left wing tip
    [(centerX - 35 * scale).toInt(), (centerY + 25 * scale).toInt()],
    [(centerX - 28 * scale).toInt(), (centerY - 25 * scale).toInt()],
  ];

  // Draw ship body with gradient
  _fillPolygonGradient(image, bodyPoints, centerY - 95 * scale, centerY + 70 * scale,
      [img.ColorRgba8(0, 255, 255, 255), img.ColorRgba8(0, 136, 187, 255), img.ColorRgba8(0, 85, 119, 255)]);

  // Cockpit
  final cockpitPoints = [
    [centerX, (centerY - 75 * scale).toInt()],
    [(centerX + 12 * scale).toInt(), (centerY - 15 * scale).toInt()],
    [(centerX - 12 * scale).toInt(), (centerY - 15 * scale).toInt()],
  ];
  _fillPolygonGradient(image, cockpitPoints, centerY - 75 * scale, centerY - 15 * scale,
      [img.ColorRgba8(255, 255, 255, 230), img.ColorRgba8(0, 255, 255, 255), img.ColorRgba8(0, 170, 221, 255)]);

  // Engine glow
  _drawGradientCircle(image, centerX, (centerY + 75 * scale).toInt(), (35 * scale).toInt(),
      img.ColorRgba8(255, 170, 0, 200));

  // Engine flame
  final flamePoints = [
    [(centerX - 12 * scale).toInt(), (centerY + 65 * scale).toInt()],
    [centerX, (centerY + 110 * scale).toInt()],
    [(centerX + 12 * scale).toInt(), (centerY + 65 * scale).toInt()],
  ];
  _fillPolygonGradient(image, flamePoints, centerY + 65 * scale, centerY + 110 * scale,
      [img.ColorRgba8(255, 255, 255, 255), img.ColorRgba8(255, 221, 0, 255), img.ColorRgba8(255, 136, 0, 100)]);
}

void _fillPolygonGradient(img.Image image, List<List<int>> points, double topY, double bottomY, List<img.ColorRgba8> colors) {
  // Find bounding box
  int minX = points[0][0], maxX = points[0][0];
  int minY = points[0][1], maxY = points[0][1];

  for (final p in points) {
    if (p[0] < minX) minX = p[0];
    if (p[0] > maxX) maxX = p[0];
    if (p[1] < minY) minY = p[1];
    if (p[1] > maxY) maxY = p[1];
  }

  // Scanline fill
  for (int y = minY; y <= maxY; y++) {
    final intersections = <int>[];

    for (int i = 0; i < points.length; i++) {
      final p1 = points[i];
      final p2 = points[(i + 1) % points.length];

      if ((p1[1] <= y && p2[1] > y) || (p2[1] <= y && p1[1] > y)) {
        final x = p1[0] + (y - p1[1]) * (p2[0] - p1[0]) / (p2[1] - p1[1]);
        intersections.add(x.toInt());
      }
    }

    intersections.sort();

    for (int i = 0; i < intersections.length - 1; i += 2) {
      for (int x = intersections[i]; x <= intersections[i + 1]; x++) {
        if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
          final t = ((y - topY) / (bottomY - topY)).clamp(0.0, 1.0);
          final color = _lerpColor(colors, t);
          _blendPixel(image, x, y, color);
        }
      }
    }
  }
}

img.ColorRgba8 _lerpColor(List<img.ColorRgba8> colors, double t) {
  if (colors.length == 1) return colors[0];

  final segment = t * (colors.length - 1);
  final index = segment.floor().clamp(0, colors.length - 2);
  final localT = segment - index;

  final c1 = colors[index];
  final c2 = colors[index + 1];

  return img.ColorRgba8(
    _lerp(c1.r.toDouble(), c2.r.toDouble(), localT).toInt(),
    _lerp(c1.g.toDouble(), c2.g.toDouble(), localT).toInt(),
    _lerp(c1.b.toDouble(), c2.b.toDouble(), localT).toInt(),
    _lerp(c1.a.toDouble(), c2.a.toDouble(), localT).toInt(),
  );
}

void _drawCircle(img.Image image, int cx, int cy, int radius, img.Color color) {
  for (int dy = -radius; dy <= radius; dy++) {
    for (int dx = -radius; dx <= radius; dx++) {
      if (dx * dx + dy * dy <= radius * radius) {
        final x = cx + dx;
        final y = cy + dy;
        if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
          _blendPixel(image, x, y, color);
        }
      }
    }
  }
}

void _blendPixel(img.Image image, int x, int y, img.Color srcColor) {
  final src = srcColor as img.ColorRgba8;
  final dst = image.getPixel(x, y);

  final srcA = src.a / 255.0;
  final dstA = dst.a / 255.0;
  final outA = srcA + dstA * (1 - srcA);

  if (outA == 0) return;

  final outR = ((src.r * srcA + dst.r * dstA * (1 - srcA)) / outA).toInt().clamp(0, 255);
  final outG = ((src.g * srcA + dst.g * dstA * (1 - srcA)) / outA).toInt().clamp(0, 255);
  final outB = ((src.b * srcA + dst.b * dstA * (1 - srcA)) / outA).toInt().clamp(0, 255);

  image.setPixel(x, y, img.ColorRgba8(outR, outG, outB, (outA * 255).toInt()));
}
