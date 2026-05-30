import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../ambient_settings.dart';

class WallpaperAndPatternPainter extends CustomPainter {
  final AmbientColors colors;
  final Color primaryColor;
  final String pattern;
  final String wallpaper;
  final bool isDark;
  final double density;
  final double animationValue;

  WallpaperAndPatternPainter({
    required this.colors,
    required this.primaryColor,
    required this.pattern,
    required this.wallpaper,
    required this.isDark,
    required this.density,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double paintAlphaMultiplier = isDark ? 1.0 : 0.8;

    // 1. Draw static background wallpapers (with boosted legibility)
    if (wallpaper != 'none') {
      if (wallpaper == 'starry') {
        final linePaint = Paint()
          ..color = isDark 
              ? Colors.white.withValues(alpha: 0.35) 
              : primaryColor.withValues(alpha: 0.26)
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke;
        
        // Draw constellation linkages
        canvas.drawLine(Offset(size.width * 0.15, size.height * 0.2), Offset(size.width * 0.35, size.height * 0.15), linePaint);
        canvas.drawLine(Offset(size.width * 0.35, size.height * 0.15), Offset(size.width * 0.45, size.height * 0.3), linePaint);
        canvas.drawLine(Offset(size.width * 0.45, size.height * 0.3), Offset(size.width * 0.25, size.height * 0.35), linePaint);
        canvas.drawLine(Offset(size.width * 0.25, size.height * 0.35), Offset(size.width * 0.15, size.height * 0.2), linePaint);
        
        canvas.drawLine(Offset(size.width * 0.65, size.height * 0.6), Offset(size.width * 0.8, size.height * 0.55), linePaint);
        canvas.drawLine(Offset(size.width * 0.8, size.height * 0.55), Offset(size.width * 0.9, size.height * 0.72), linePaint);
        canvas.drawLine(Offset(size.width * 0.9, size.height * 0.72), Offset(size.width * 0.7, size.height * 0.78), linePaint);
        canvas.drawLine(Offset(size.width * 0.7, size.height * 0.78), Offset(size.width * 0.65, size.height * 0.6), linePaint);

        // Star bodies with actual circular glows
        final starPaint = Paint()..color = isDark ? Colors.white.withValues(alpha: 0.75) : primaryColor.withValues(alpha: 0.60);
        canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.2), 3.5, starPaint);
        canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.15), 4.2, starPaint);
        canvas.drawCircle(Offset(size.width * 0.45, size.height * 0.3), 3.0, starPaint);
        canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.35), 3.5, starPaint);
        canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.6), 4.0, starPaint);
        canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.55), 3.0, starPaint);
        canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.72), 4.5, starPaint);
        canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.78), 3.5, starPaint);

        // EXTRA density starry constellations
        if (density > 1.2) {
          canvas.drawLine(Offset(size.width * 0.1, size.height * 0.5), Offset(size.width * 0.3, size.height * 0.48), linePaint);
          canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.5), 3.0, starPaint);
          canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.48), 3.5, starPaint);
        }
        if (density > 1.6) {
          canvas.drawLine(Offset(size.width * 0.5, size.height * 0.8), Offset(size.width * 0.7, size.height * 0.82), linePaint);
          canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.8), 3.0, starPaint);
          canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.82), 3.5, starPaint);
        }

      } else if (wallpaper == 'geometric') {
        final shapePaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = (isDark ? colors.color1 : primaryColor).withValues(alpha: isDark ? 0.28 : 0.20);
        
        // Boosted overlapping circles and geometric bounds
        canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.28), size.width * 0.38 * density, shapePaint);
        shapePaint.color = (isDark ? colors.color2 : primaryColor).withValues(alpha: isDark ? 0.24 : 0.18);
        canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.72), size.width * 0.42 * density, shapePaint);
        
        shapePaint.color = (isDark ? colors.color3 : primaryColor).withValues(alpha: isDark ? 0.20 : 0.14);
        final Path diamond = Path()
          ..moveTo(size.width * 0.5, size.height * (0.42 - 0.20 * density))
          ..lineTo(size.width * (0.5 + 0.28 * density), size.height * 0.42)
          ..lineTo(size.width * 0.5, size.height * (0.42 + 0.20 * density))
          ..lineTo(size.width * (0.5 - 0.28 * density), size.height * 0.42)
          ..close();
        canvas.drawPath(diamond, shapePaint);

      } else if (wallpaper == 'wave') {
        final wavePaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5; // Thickened waves
        
        final int waveCount = (3 * density).round().clamp(1, 6);
        for (int i = 0; i < waveCount; i++) {
          wavePaint.color = (i % 3 == 0 
              ? colors.color1 
              : i % 3 == 1 
                  ? colors.color2 
                  : colors.color3).withValues(alpha: isDark ? 0.35 : 0.25);
          final Path path = Path();
          final double startY = size.height * (0.2 + i * (0.6 / waveCount));
          path.moveTo(0, startY);
          for (double x = 0; x <= size.width; x += 10) {
            final double y = startY + math.sin(x / 45 + i) * 16;
            path.lineTo(x, y);
          }
          canvas.drawPath(path, wavePaint);
        }

      } else if (wallpaper == 'tech_grid') {
        final gridPaint = Paint()
          ..color = (isDark ? colors.color1 : primaryColor).withValues(alpha: isDark ? 0.24 : 0.16)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;

        // Blueprint Grid
        final double spacing = 48.0 / density;
        for (double x = 0; x < size.width; x += spacing) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
        }
        for (double y = 0; y < size.height; y += spacing) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
        }

        // Tech crosshairs/dots
        final markPaint = Paint()
          ..color = (isDark ? colors.color2 : primaryColor).withValues(alpha: isDark ? 0.35 : 0.24)
          ..style = PaintingStyle.fill;
        
        for (double x = 0; x < size.width; x += spacing * 2) {
          for (double y = 0; y < size.height; y += spacing * 2) {
            canvas.drawCircle(Offset(x, y), 2.5, markPaint);
          }
        }
      }
    }

    // 2. Draw static background patterns
    if (pattern != 'none') {
      final patternPaint = Paint()
        ..color = (isDark ? Colors.white : primaryColor).withValues(alpha: isDark ? 0.22 * paintAlphaMultiplier : 0.16 * paintAlphaMultiplier)
        ..style = PaintingStyle.stroke;

      if (pattern == 'dots') {
        patternPaint.style = PaintingStyle.fill;
        final double spacing = 24.0 / density;
        for (double x = spacing / 2; x < size.width; x += spacing) {
          for (double y = spacing / 2; y < size.height; y += spacing) {
            canvas.drawCircle(Offset(x, y), 2.0, patternPaint); // Slightly larger dots
          }
        }
      } else if (pattern == 'grid') {
        patternPaint.strokeWidth = 1.0;
        final double spacing = 32.0 / density;
        for (double x = 0; x < size.width; x += spacing) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), patternPaint);
        }
        for (double y = 0; y < size.height; y += spacing) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), patternPaint);
        }
      } else if (pattern == 'waves') {
        patternPaint.strokeWidth = 1.4;
        final double spacing = 40.0 / density;
        for (double y = spacing; y < size.height; y += spacing) {
          final Path path = Path();
          path.moveTo(0, y);
          for (double x = 0; x < size.width; x += 12) {
            path.lineTo(x, y + math.sin(x / 30) * 4);
          }
          canvas.drawPath(path, patternPaint);
        }
      } else if (pattern == 'stripes') {
        patternPaint.strokeWidth = 1.5;
        final double spacing = 45.0 / density;
        for (double i = -size.height; i < size.width; i += spacing) {
          canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), patternPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant WallpaperAndPatternPainter oldDelegate) {
    return oldDelegate.colors != colors ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.pattern != pattern ||
        oldDelegate.wallpaper != wallpaper ||
        oldDelegate.isDark != isDark ||
        oldDelegate.density != density ||
        oldDelegate.animationValue != animationValue;
  }
}
