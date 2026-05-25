import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Settings-driven global ValueNotifiers for real-time live updates from any screen
final ValueNotifier<double> ambientAnimationSpeed = ValueNotifier(1.0); // Ranges from 0.2x to 3.0x
final ValueNotifier<int> ambientSparkleDensity = ValueNotifier(65); // Ranges from 10 to 150 particles
final ValueNotifier<bool> ambientBackgroundEnabled = ValueNotifier(true); // Toggle to completely turn off the ambient background

class AmbientSettings {
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      ambientAnimationSpeed.value = prefs.getDouble('ambient_animation_speed') ?? 1.0;
      ambientSparkleDensity.value = prefs.getInt('ambient_sparkle_density') ?? 65;
      ambientBackgroundEnabled.value = prefs.getBool('ambient_background_enabled') ?? true;
    } catch (e) {
      debugPrint('Error loading ambient background settings: $e');
    }

    // Attach listener callbacks to persist state dynamically
    ambientAnimationSpeed.addListener(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('ambient_animation_speed', ambientAnimationSpeed.value);
    });
    ambientSparkleDensity.addListener(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('ambient_sparkle_density', ambientSparkleDensity.value);
    });
    ambientBackgroundEnabled.addListener(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('ambient_background_enabled', ambientBackgroundEnabled.value);
    });
  }
}

enum TimePeriod { morning, afternoon, evening, night }

class AmbientColors {
  final Color color1;
  final Color color2;
  final Color color3;
  final Color baseBackground;
  final Color sparkleColor;

  AmbientColors({
    required this.color1,
    required this.color2,
    required this.color3,
    required this.baseBackground,
    required this.sparkleColor,
  });
}

class Particle {
  double x;
  double y;
  double speed;
  double size;
  double opacity;
  final double randomOffset;

  Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
    required this.randomOffset,
  });
}

class AmbientTimeBackground extends StatefulWidget {
  final Widget child;
  final bool useSafeArea;

  const AmbientTimeBackground({
    super.key,
    required this.child,
    this.useSafeArea = false,
  });

  @override
  State<AmbientTimeBackground> createState() => _AmbientTimeBackgroundState();
}

class _AmbientTimeBackgroundState extends State<AmbientTimeBackground> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final List<Particle> _particles = [];
  final math.Random _random = math.Random();
  TimePeriod _timePeriod = TimePeriod.night;

  @override
  void initState() {
    super.initState();
    
    // 12-second continuous looping duration for highly visible yet smooth flow
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _updateTimePeriod();

    // Pre-initialize exactly 150 high-density sparkles to support sliders seamlessly without allocations
    for (int i = 0; i < 150; i++) {
      _particles.add(
        Particle(
          x: _random.nextDouble() * 500, // Safe starting width
          y: _random.nextDouble() * 1000, // Safe starting height
          speed: 0.3 + _random.nextDouble() * 0.7, // Drifting speeds
          size: 1.2 + _random.nextDouble() * 2.8, // Sparkle sizes
          opacity: 0.2 + _random.nextDouble() * 0.6, // Base opacities
          randomOffset: _random.nextDouble() * 2 * math.pi,
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateTimePeriod() {
    final hour = DateTime.now().hour;
    TimePeriod currentPeriod;
    if (hour >= 5 && hour < 12) {
      currentPeriod = TimePeriod.morning;
    } else if (hour >= 12 && hour < 17) {
      currentPeriod = TimePeriod.afternoon;
    } else if (hour >= 17 && hour < 21) {
      currentPeriod = TimePeriod.evening;
    } else {
      currentPeriod = TimePeriod.night;
    }

    if (currentPeriod != _timePeriod) {
      setState(() {
        _timePeriod = currentPeriod;
      });
    }
  }

  AmbientColors _getColors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    // Enhanced opacities for Light theme (0.45 - 0.65) to prevent colors from washing out on white Scaffolds.
    // Sparkle colors dynamically shift to colored motes in Light theme so they contrast cleanly.
    switch (_timePeriod) {
      case TimePeriod.morning:
        return AmbientColors(
          color1: primary.withValues(alpha: isDark ? 0.30 : 0.65),
          color2: const Color(0xFFFFB300).withValues(alpha: isDark ? 0.25 : 0.60), // Amber
          color3: const Color(0xFFFF7043).withValues(alpha: isDark ? 0.20 : 0.50), // Peach/Coral
          baseBackground: Theme.of(context).scaffoldBackgroundColor,
          sparkleColor: isDark ? Colors.white : const Color(0xFFFFB300),
        );
      case TimePeriod.afternoon:
        return AmbientColors(
          color1: primary.withValues(alpha: isDark ? 0.30 : 0.65),
          color2: const Color(0xFF00ADB5).withValues(alpha: isDark ? 0.25 : 0.60), // Teal
          color3: const Color(0xFF42A5F5).withValues(alpha: isDark ? 0.20 : 0.50), // Sky Blue
          baseBackground: Theme.of(context).scaffoldBackgroundColor,
          sparkleColor: isDark ? Colors.white : const Color(0xFF00ADB5),
        );
      case TimePeriod.evening:
        return AmbientColors(
          color1: primary.withValues(alpha: isDark ? 0.30 : 0.65),
          color2: const Color(0xFFAB47BC).withValues(alpha: isDark ? 0.25 : 0.60), // Muted Purple
          color3: const Color(0xFFEC407A).withValues(alpha: isDark ? 0.20 : 0.50), // Rose/Sunset
          baseBackground: Theme.of(context).scaffoldBackgroundColor,
          sparkleColor: isDark ? Colors.white : const Color(0xFFEC407A),
        );
      case TimePeriod.night:
        return AmbientColors(
          color1: primary.withValues(alpha: isDark ? 0.25 : 0.60),
          color2: const Color(0xFF3F51B5).withValues(alpha: isDark ? 0.20 : 0.50), // Indigo
          color3: const Color(0xFF1A237E).withValues(alpha: isDark ? 0.15 : 0.45), // Midnight Space Blue
          baseBackground: Theme.of(context).scaffoldBackgroundColor,
          sparkleColor: isDark ? Colors.white : const Color(0xFF3F51B5),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    _updateTimePeriod(); // Ensure time context is updated on active rebuilds
    final colors = _getColors(context);

    // ListenableBuilder merges animation tickers with user preferences to enable live adjustments on the fly
    return ListenableBuilder(
      listenable: Listenable.merge([
        _animationController,
        ambientAnimationSpeed,
        ambientSparkleDensity,
        ambientBackgroundEnabled,
      ]),
      builder: (context, _) {
        final speedFactor = ambientAnimationSpeed.value;
        final densityCount = ambientSparkleDensity.value;
        final isEnabled = ambientBackgroundEnabled.value;

        if (!isEnabled) {
          return Container(
            color: colors.baseBackground,
            child: widget.useSafeArea ? SafeArea(child: widget.child) : widget.child,
          );
        }

        return Stack(
          children: [
            // 1. Slow Aurora Mesh Blobs
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: AuroraBlobsPainter(
                    animationValue: _animationController.value,
                    colors: colors,
                  ),
                ),
              ),
            ),
            // 2. High-Performance Gaussian Soft Blur
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
                child: Container(color: Colors.transparent),
              ),
            ),
            // 3. Crisp, High-Density Sparkles floating over the blurred backdrop
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: SparklesPainter(
                    animationValue: _animationController.value,
                    particles: _particles,
                    sparkleColor: colors.sparkleColor,
                    speedFactor: speedFactor,
                    density: densityCount,
                  ),
                ),
              ),
            ),
            // 4. Child Content Layer
            Positioned.fill(
              child: widget.useSafeArea ? SafeArea(child: widget.child) : widget.child,
            ),
          ],
        );
      },
    );
  }
}

class AuroraBlobsPainter extends CustomPainter {
  final double animationValue;
  final AmbientColors colors;

  AuroraBlobsPainter({
    required this.animationValue,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // 1. Paint core scaffold background first
    paint.color = colors.baseBackground;
    canvas.drawRect(Offset.zero & size, paint);

    // 2. Draw Blob 1 (Top-Left moving slowly)
    final double angle1 = animationValue * 2 * math.pi;
    final double dx1 = size.width * 0.25 + math.cos(angle1) * size.width * 0.15;
    final double dy1 = size.height * 0.25 + math.sin(angle1) * size.height * 0.08;
    final double radius1 = size.width * 0.65;

    paint.shader = RadialGradient(
      colors: [colors.color1, colors.color1.withValues(alpha: 0.0)],
    ).createShader(Rect.fromCircle(center: Offset(dx1, dy1), radius: radius1));
    canvas.drawCircle(Offset(dx1, dy1), radius1, paint);

    // 3. Draw Blob 2 (Bottom-Right moving ovally)
    final double angle2 = (animationValue + 0.33) * 2 * math.pi;
    final double dx2 = size.width * 0.75 + math.sin(angle2) * size.width * 0.15;
    final double dy2 = size.height * 0.75 + math.cos(angle2) * size.height * 0.08;
    final double radius2 = size.width * 0.70;

    paint.shader = RadialGradient(
      colors: [colors.color2, colors.color2.withValues(alpha: 0.0)],
    ).createShader(Rect.fromCircle(center: Offset(dx2, dy2), radius: radius2));
    canvas.drawCircle(Offset(dx2, dy2), radius2, paint);

    // 4. Draw Blob 3 (Center-Left drifting)
    final double angle3 = (animationValue + 0.66) * 2 * math.pi;
    final double dx3 = size.width * 0.30 + math.cos(angle3 * 1.5) * size.width * 0.10;
    final double dy3 = size.height * 0.50 + math.sin(angle3 * 1.5) * size.height * 0.10;
    final double radius3 = size.width * 0.60;

    paint.shader = RadialGradient(
      colors: [colors.color3, colors.color3.withValues(alpha: 0.0)],
    ).createShader(Rect.fromCircle(center: Offset(dx3, dy3), radius: radius3));
    canvas.drawCircle(Offset(dx3, dy3), radius3, paint);
  }

  @override
  bool shouldRepaint(covariant AuroraBlobsPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.colors != colors;
  }
}

class SparklesPainter extends CustomPainter {
  final double animationValue;
  final List<Particle> particles;
  final Color sparkleColor;
  final double speedFactor;
  final int density;

  SparklesPainter({
    required this.animationValue,
    required this.particles,
    required this.sparkleColor,
    required this.speedFactor,
    required this.density,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dynamically limit drawing loop to the selected density preference
    final paintCount = math.min(density, particles.length);

    for (int i = 0; i < paintCount; i++) {
      final particle = particles[i];

      // Dynamically adjust starting bounds if they exceed canvas size
      if (particle.x > size.width) {
        particle.x = math.Random().nextDouble() * size.width;
      }
      if (particle.y > size.height) {
        particle.y = math.Random().nextDouble() * size.height;
      }

      // Update position with dynamic speed factor applied
      particle.y -= particle.speed * speedFactor;
      particle.x += math.sin(animationValue * 2 * math.pi + particle.randomOffset) * 0.35;

      // Reset if off-screen
      if (particle.y < -10) {
        particle.y = size.height + 10;
        particle.x = math.Random().nextDouble() * size.width;
      }

      final paint = Paint()
        ..color = sparkleColor.withValues(alpha: particle.opacity * 0.45)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(particle.x, particle.y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SparklesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.particles != particles ||
        oldDelegate.sparkleColor != sparkleColor ||
        oldDelegate.speedFactor != speedFactor ||
        oldDelegate.density != density;
  }
}
