import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../ambient_settings.dart';

class AuroraBlobsPainter extends CustomPainter {
  final double animationValue;
  final AmbientColors colors;
  final String style;
  final bool auroraEnabled;
  final bool isDark;
  final double speedFactor;

  AuroraBlobsPainter({
    required this.animationValue,
    required this.colors,
    required this.style,
    required this.auroraEnabled,
    required this.isDark,
    required this.speedFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Background base color determination based on style settings
    Color baseBg = colors.baseBackground;
    
    if (style == 'cyberpunk' && auroraEnabled) {
      baseBg = const Color(0xFF07050A); // Extremely deep dark cyber void
    } else if (style == 'cosmic' && auroraEnabled) {
      baseBg = const Color(0xFF020107); // Absolute starry void black
    } else if (style == 'ocean' && auroraEnabled) {
      baseBg = const Color(0xFF040A12); // Deep abyssal ocean blue-black
    } else if (style == 'autumn' && auroraEnabled) {
      baseBg = const Color(0xFF0F0A06); // Deep rich forest bark brown-black
    }
    
    paint.color = baseBg;
    canvas.drawRect(Offset.zero & size, paint);

    // Dynamic style blobs driven by speed factor
    final double speededAnim = animationValue * speedFactor;

    if (auroraEnabled) {
      if (style == 'cyberpunk') {
        // Draw Magenta and Cyan glowing cyber-blobs
        final Color cyberColor1 = const Color(0xFFFF007F).withValues(alpha: isDark ? 0.22 : 0.36); // Neon Pink
        final Color cyberColor2 = const Color(0xFF00ADB5).withValues(alpha: isDark ? 0.22 : 0.36); // Neon Cyan

        final double angle1 = speededAnim * 2 * math.pi;
        final double dx1 = size.width * 0.3 + math.cos(angle1) * size.width * 0.22;
        final double dy1 = size.height * 0.3 + math.sin(angle1) * size.height * 0.12;
        paint.shader = RadialGradient(colors: [cyberColor1, cyberColor1.withValues(alpha: 0.0)]).createShader(Rect.fromCircle(center: Offset(dx1, dy1), radius: size.width * 0.75));
        canvas.drawCircle(Offset(dx1, dy1), size.width * 0.75, paint);

        final double angle2 = (speededAnim + 0.5) * 2 * math.pi;
        final double dx2 = size.width * 0.7 + math.sin(angle2) * size.width * 0.22;
        final double dy2 = size.height * 0.7 + math.cos(angle2) * size.height * 0.12;
        paint.shader = RadialGradient(colors: [cyberColor2, cyberColor2.withValues(alpha: 0.0)]).createShader(Rect.fromCircle(center: Offset(dx2, dy2), radius: size.width * 0.8));
        canvas.drawCircle(Offset(dx2, dy2), size.width * 0.8, paint);
        
      } else if (style == 'cosmic') {
        // Cosmic Nebula Circles (glowing deep violet & blue spaces)
        final Color spacePurple = const Color(0xFF7B2CBF).withValues(alpha: isDark ? 0.20 : 0.32);
        final Color spaceIndigo = const Color(0xFF3C096C).withValues(alpha: isDark ? 0.22 : 0.35);
        final Color spacePink = const Color(0xFFE0AAFF).withValues(alpha: isDark ? 0.12 : 0.22);

        final double angle1 = speededAnim * 2 * math.pi;
        final double dx1 = size.width * 0.5 + math.cos(angle1 * 0.5) * size.width * 0.25;
        final double dy1 = size.height * 0.4 + math.sin(angle1 * 0.5) * size.height * 0.15;
        paint.shader = RadialGradient(colors: [spacePurple, spacePurple.withValues(alpha: 0.0)]).createShader(Rect.fromCircle(center: Offset(dx1, dy1), radius: size.width * 0.85));
        canvas.drawCircle(Offset(dx1, dy1), size.width * 0.85, paint);

        final double angle2 = (speededAnim + 0.3) * 2 * math.pi;
        final double dx2 = size.width * 0.4 + math.sin(angle2) * size.width * 0.22;
        final double dy2 = size.height * 0.7 + math.cos(angle2) * size.height * 0.12;
        paint.shader = RadialGradient(colors: [spaceIndigo, spaceIndigo.withValues(alpha: 0.0)]).createShader(Rect.fromCircle(center: Offset(dx2, dy2), radius: size.width * 0.95));
        canvas.drawCircle(Offset(dx2, dy2), size.width * 0.95, paint);

        final double angle3 = (speededAnim + 0.6) * 2 * math.pi;
        final double dx3 = size.width * 0.6 + math.cos(angle3) * size.width * 0.22;
        final double dy3 = size.height * 0.5 + math.sin(angle3) * size.height * 0.12;
        paint.shader = RadialGradient(colors: [spacePink, spacePink.withValues(alpha: 0.0)]).createShader(Rect.fromCircle(center: Offset(dx3, dy3), radius: size.width * 0.7));
        canvas.drawCircle(Offset(dx3, dy3), size.width * 0.7, paint);

      } else if (style == 'ocean') {
        // Ocean calmness (teal, sky blue and marine green horizontal waves)
        final Color oceanTeal = const Color(0xFF00ADB5).withValues(alpha: isDark ? 0.20 : 0.32);
        final Color oceanBlue = const Color(0xFF1F4068).withValues(alpha: isDark ? 0.22 : 0.35);
        final Color oceanGreen = const Color(0xFF2E8B57).withValues(alpha: isDark ? 0.12 : 0.22);

        final double shift1 = math.sin(speededAnim * 2 * math.pi) * size.height * 0.08;
        paint.shader = RadialGradient(colors: [oceanTeal, oceanTeal.withValues(alpha: 0.0)]).createShader(Rect.fromCircle(center: Offset(size.width * 0.3, size.height * 0.3 + shift1), radius: size.width * 0.9));
        canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.3 + shift1), size.width * 0.9, paint);

        final double shift2 = math.cos((speededAnim + 0.5) * 2 * math.pi) * size.height * 0.08;
        paint.shader = RadialGradient(colors: [oceanBlue, oceanBlue.withValues(alpha: 0.0)]).createShader(Rect.fromCircle(center: Offset(size.width * 0.7, size.height * 0.7 + shift2), radius: size.width * 0.95));
        canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.7 + shift2), size.width * 0.95, paint);

        final double shift3 = math.sin((speededAnim + 0.25) * 2 * math.pi) * size.height * 0.06;
        paint.shader = RadialGradient(colors: [oceanGreen, oceanGreen.withValues(alpha: 0.0)]).createShader(Rect.fromCircle(center: Offset(size.width * 0.2, size.height * 0.65 + shift3), radius: size.width * 0.75));
        canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.65 + shift3), size.width * 0.75, paint);

      } else if (style == 'autumn') {
        // Warm mahogany, amber and copper shades
        final Color autumnAmber = const Color(0xFFFFB300).withValues(alpha: isDark ? 0.20 : 0.32);
        final Color autumnCopper = const Color(0xFFD35400).withValues(alpha: isDark ? 0.22 : 0.35);
        final Color autumnRed = const Color(0xFFC0392B).withValues(alpha: isDark ? 0.12 : 0.22);

        final double angle1 = speededAnim * 2 * math.pi;
        final double dx1 = size.width * 0.3 + math.cos(angle1) * size.width * 0.22;
        final double dy1 = size.height * 0.35 + math.sin(angle1) * size.height * 0.10;
        paint.shader = RadialGradient(colors: [autumnAmber, autumnAmber.withValues(alpha: 0.0)]).createShader(Rect.fromCircle(center: Offset(dx1, dy1), radius: size.width * 0.8));
        canvas.drawCircle(Offset(dx1, dy1), size.width * 0.8, paint);

        final double angle2 = (speededAnim + 0.4) * 2 * math.pi;
        final double dx2 = size.width * 0.7 + math.sin(angle2) * size.width * 0.22;
        final double dy2 = size.height * 0.65 + math.cos(angle2) * size.height * 0.10;
        paint.shader = RadialGradient(colors: [autumnCopper, autumnCopper.withValues(alpha: 0.0)]).createShader(Rect.fromCircle(center: Offset(dx2, dy2), radius: size.width * 0.9));
        canvas.drawCircle(Offset(dx2, dy2), size.width * 0.9, paint);

        final double angle3 = (speededAnim + 0.7) * 2 * math.pi;
        final double dx3 = size.width * 0.4 + math.cos(angle3 * 1.2) * size.width * 0.15;
        final double dy3 = size.height * 0.5 + math.sin(angle3 * 1.2) * size.height * 0.12;
        paint.shader = RadialGradient(colors: [autumnRed, autumnRed.withValues(alpha: 0.0)]).createShader(Rect.fromCircle(center: Offset(dx3, dy3), radius: size.width * 0.75));
        canvas.drawCircle(Offset(dx3, dy3), size.width * 0.75, paint);

      } else {
        // DEFAULT TIME-BASED AURORA
        final double angle1 = speededAnim * 2 * math.pi;
        final double dx1 = size.width * 0.25 + math.cos(angle1) * size.width * 0.22;
        final double dy1 = size.height * 0.25 + math.sin(angle1) * size.height * 0.12;
        final double radius1 = size.width * 0.75;

        paint.shader = RadialGradient(
          colors: [colors.color1, colors.color1.withValues(alpha: 0.0)],
        ).createShader(Rect.fromCircle(center: Offset(dx1, dy1), radius: radius1));
        canvas.drawCircle(Offset(dx1, dy1), radius1, paint);

        final double angle2 = (speededAnim + 0.33) * 2 * math.pi;
        final double dx2 = size.width * 0.75 + math.sin(angle2) * size.width * 0.22;
        final double dy2 = size.height * 0.75 + math.cos(angle2) * size.height * 0.12;
        final double radius2 = size.width * 0.8;

        paint.shader = RadialGradient(
          colors: [colors.color2, colors.color2.withValues(alpha: 0.0)],
        ).createShader(Rect.fromCircle(center: Offset(dx2, dy2), radius: radius2));
        canvas.drawCircle(Offset(dx2, dy2), radius2, paint);

        final double angle3 = (speededAnim + 0.66) * 2 * math.pi;
        final double dx3 = size.width * 0.30 + math.cos(angle3 * 1.5) * size.width * 0.15;
        final double dy3 = size.height * 0.50 + math.sin(angle3 * 1.5) * size.height * 0.15;
        final double radius3 = size.width * 0.7;

        paint.shader = RadialGradient(
          colors: [colors.color3, colors.color3.withValues(alpha: 0.0)],
        ).createShader(Rect.fromCircle(center: Offset(dx3, dy3), radius: radius3));
        canvas.drawCircle(Offset(dx3, dy3), radius3, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant AuroraBlobsPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.colors != colors ||
        oldDelegate.style != style ||
        oldDelegate.auroraEnabled != auroraEnabled ||
        oldDelegate.isDark != isDark ||
        oldDelegate.speedFactor != speedFactor;
  }
}
