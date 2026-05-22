import 'package:flutter/material.dart';
import 'contributor_painters.dart';

class TechRadarAvatar extends StatefulWidget {
  final String imagePath;
  final String name;
  final Color themeColor;
  final double radius;

  const TechRadarAvatar({
    super.key,
    required this.imagePath,
    required this.name,
    required this.themeColor,
    this.radius = 36,
  });

  @override
  State<TechRadarAvatar> createState() => _TechRadarAvatarState();
}

class _TechRadarAvatarState extends State<TechRadarAvatar> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationController.value * 2 * 3.141592653589793,
              child: CustomPaint(
                size: Size((widget.radius + 6) * 2, (widget.radius + 6) * 2),
                painter: RadarRingPainter(widget.themeColor),
              ),
            );
          },
        ),
        CircleAvatar(
          radius: widget.radius,
          backgroundColor: colors.surface,
          child: CircleAvatar(
            radius: widget.radius - 2,
            backgroundImage: widget.imagePath.isNotEmpty && widget.imagePath.startsWith('http')
                ? NetworkImage(widget.imagePath)
                : null,
            child: (widget.imagePath.isEmpty || !widget.imagePath.startsWith('http'))
                ? Text(
                    widget.name.isNotEmpty ? widget.name[0].toUpperCase() : 'C',
                    style: TextStyle(
                      fontSize: widget.radius * 0.7,
                      fontWeight: FontWeight.bold,
                      color: widget.themeColor,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
