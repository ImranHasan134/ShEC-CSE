import 'package:flutter/material.dart';

class GithubPainter extends CustomPainter {
  final Color color;
  GithubPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = Path();
    final w = size.width;
    final h = size.height;
    
    path.moveTo(w * 0.5, 0);
    path.cubicTo(w * 0.22, 0, 0, h * 0.22, 0, h * 0.5);
    path.cubicTo(0, h * 0.72, w * 0.14, h * 0.91, w * 0.34, h * 0.98);
    path.cubicTo(w * 0.37, h * 0.98, w * 0.38, h * 0.97, w * 0.38, h * 0.95);
    path.lineTo(w * 0.38, h * 0.83);
    path.cubicTo(w * 0.24, h * 0.86, w * 0.21, h * 0.77, w * 0.21, h * 0.77);
    path.cubicTo(w * 0.19, h * 0.71, w * 0.16, h * 0.69, w * 0.16, h * 0.69);
    path.cubicTo(w * 0.11, h * 0.66, w * 0.16, h * 0.66, w * 0.16, h * 0.66);
    path.cubicTo(w * 0.21, h * 0.66, w * 0.24, h * 0.71, w * 0.24, h * 0.71);
    path.cubicTo(w * 0.28, h * 0.78, w * 0.35, h * 0.76, w * 0.38, h * 0.75);
    path.cubicTo(w * 0.39, h * 0.71, w * 0.41, h * 0.68, w * 0.42, h * 0.66);
    path.cubicTo(w * 0.31, h * 0.65, w * 0.19, h * 0.60, w * 0.19, h * 0.41);
    path.cubicTo(w * 0.19, h * 0.35, w * 0.21, h * 0.31, w * 0.24, h * 0.27);
    path.cubicTo(w * 0.23, h * 0.26, w * 0.21, h * 0.20, w * 0.25, h * 0.12);
    path.cubicTo(w * 0.25, h * 0.12, w * 0.29, h * 0.10, w * 0.38, h * 0.17);
    path.cubicTo(w * 0.42, h * 0.16, w * 0.46, h * 0.15, w * 0.50, h * 0.15);
    path.cubicTo(w * 0.54, h * 0.15, w * 0.58, h * 0.16, w * 0.58, h * 0.17);
    path.cubicTo(w * 0.71, h * 0.10, w * 0.75, h * 0.12, w * 0.75, h * 0.12);
    path.cubicTo(w * 0.79, h * 0.20, w * 0.77, h * 0.26, w * 0.76, h * 0.27);
    path.cubicTo(w * 0.79, h * 0.31, w * 0.81, h * 0.35, w * 0.81, h * 0.41);
    path.cubicTo(w * 0.81, h * 0.60, w * 0.69, h * 0.65, w * 0.58, h * 0.66);
    path.cubicTo(w * 0.60, h * 0.68, w * 0.62, h * 0.71, w * 0.62, h * 0.76);
    path.lineTo(w * 0.62, h * 0.95);
    path.cubicTo(w * 0.62, h * 0.97, w * 0.63, h * 0.98, w * 0.66, h * 0.98);
    path.cubicTo(w * 0.86, h * 0.91, w * 1.00, h * 0.72, w * 1.00, h * 0.50);
    path.cubicTo(w * 1.00, h * 0.22, w * 0.78, 0, w * 0.50, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LinkedInPainter extends CustomPainter {
  final Color color;
  LinkedInPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(w * 0.2),
    );
    canvas.drawRRect(rect, paint);

    final textPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCircle(center: Offset(w * 0.29, h * 0.26), radius: w * 0.06),
      textPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.23, h * 0.38, w * 0.12, h * 0.42),
      textPaint,
    );

    final nPath = Path();
    nPath.moveTo(w * 0.44, h * 0.38);
    nPath.lineTo(w * 0.55, h * 0.38);
    nPath.lineTo(w * 0.55, h * 0.45);
    nPath.cubicTo(
      w * 0.60, h * 0.36,
      w * 0.74, h * 0.36,
      w * 0.74, h * 0.52,
    );
    nPath.lineTo(w * 0.74, h * 0.8);
    nPath.lineTo(w * 0.63, h * 0.8);
    nPath.lineTo(w * 0.63, h * 0.55);
    nPath.cubicTo(
      w * 0.63, h * 0.48,
      w * 0.59, h * 0.48,
      w * 0.55, h * 0.52,
    );
    nPath.lineTo(w * 0.55, h * 0.8);
    nPath.lineTo(w * 0.44, h * 0.8);
    nPath.close();

    canvas.drawPath(nPath, textPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HUDCornerPainter extends CustomPainter {
  final Color color;
  HUDCornerPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;
    const len = 12.0;
    const offset = 1.0;

    canvas.drawLine(const Offset(offset, offset + len), const Offset(offset, offset), paint);
    canvas.drawLine(const Offset(offset, offset), const Offset(offset + len, offset), paint);

    canvas.drawLine(Offset(w - offset - len, offset), Offset(w - offset, offset), paint);
    canvas.drawLine(Offset(w - offset, offset), Offset(w - offset, offset + len), paint);

    canvas.drawLine(Offset(offset, h - offset - len), Offset(offset, h - offset), paint);
    canvas.drawLine(Offset(offset, h - offset), Offset(offset + len, h - offset), paint);

    canvas.drawLine(Offset(w - offset - len, h - offset), Offset(w - offset, h - offset), paint);
    canvas.drawLine(Offset(w - offset, h - offset - len), Offset(w - offset, h - offset), paint);

    final dotPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w - 8, 8), 2.0, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ScanlinePainter extends CustomPainter {
  final double progress;
  final Color color;

  ScanlinePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final y = h * progress;

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          color.withOpacity(0.04),
          color.withOpacity(0.18),
          color.withOpacity(0.04),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, y - 25, w, 50));

    canvas.drawRect(Rect.fromLTWH(0, y - 25, w, 50), paint);

    final linePaint = Paint()
      ..color = color.withOpacity(0.4)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, y), Offset(w, y), linePaint);
  }

  @override
  bool shouldRepaint(covariant ScanlinePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class RadarRingPainter extends CustomPainter {
  final Color color;
  RadarRingPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.35)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;
    final radius = w / 2;

    canvas.drawCircle(Offset(radius, radius), radius - 2, paint);

    final notchPaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.addArc(
      Rect.fromCircle(center: Offset(radius, radius), radius: radius - 2),
      0,
      0.6,
    );
    path.addArc(
      Rect.fromCircle(center: Offset(radius, radius), radius: radius - 2),
      2.09,
      0.6,
    );
    path.addArc(
      Rect.fromCircle(center: Offset(radius, radius), radius: radius - 2),
      4.18,
      0.6,
    );
    canvas.drawPath(path, notchPaint);

    final finePaint = Paint()
      ..color = color.withOpacity(0.12)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(radius, radius), radius + 2, finePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
