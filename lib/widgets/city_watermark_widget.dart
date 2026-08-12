import 'package:flutter/material.dart';

class CitySkylineWatermarkWidget extends StatelessWidget {
  final double height;
  final Color color;
  final double strokeWidth;

  const CitySkylineWatermarkWidget({
    super.key,
    this.height = 160,
    this.color = const Color(0xFFD84315),
    this.strokeWidth = 1.2,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _CityWatermarkPainter(
          color: color,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _CityWatermarkPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _CityWatermarkPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    final path = Path();
    path.moveTo(0, h);

    // Left TV / Spire Needle Tower
    path.lineTo(w * 0.06, h);
    path.lineTo(w * 0.06, h * 0.40);
    path.lineTo(w * 0.05, h * 0.38);
    path.lineTo(w * 0.07, h * 0.35); // Disk
    path.lineTo(w * 0.06, h * 0.32);
    path.lineTo(w * 0.06, h * 0.10); // Needle tip
    path.lineTo(w * 0.065, h * 0.32);
    path.lineTo(w * 0.07, h * 0.40);
    path.lineTo(w * 0.07, h);

    // Building 1 (Modern Angular Tower)
    path.moveTo(w * 0.10, h);
    path.lineTo(w * 0.10, h * 0.30);
    path.lineTo(w * 0.16, h * 0.20); // Slanted roof
    path.lineTo(w * 0.20, h * 0.30);
    path.lineTo(w * 0.20, h);

    // Building 2 (Mid-rise with Grid Windows)
    path.moveTo(w * 0.22, h);
    path.lineTo(w * 0.22, h * 0.42);
    path.lineTo(w * 0.32, h * 0.42);
    path.lineTo(w * 0.32, h);

    // Central High-rise Skyscraper 1
    path.moveTo(w * 0.34, h);
    path.lineTo(w * 0.34, h * 0.12);
    path.lineTo(w * 0.44, h * 0.05); // Pyramid Top
    path.lineTo(w * 0.50, h * 0.12);
    path.lineTo(w * 0.50, h);

    // High-rise Skyscraper 2
    path.moveTo(w * 0.52, h);
    path.lineTo(w * 0.52, h * 0.18);
    path.lineTo(w * 0.62, h * 0.18);
    path.lineTo(w * 0.62, h);

    // Modern Curved/Stepped Tower
    path.moveTo(w * 0.64, h);
    path.lineTo(w * 0.64, h * 0.28);
    path.lineTo(w * 0.72, h * 0.22);
    path.lineTo(w * 0.76, h * 0.35);
    path.lineTo(w * 0.76, h);

    // Right Building Complex
    path.moveTo(w * 0.78, h);
    path.lineTo(w * 0.78, h * 0.38);
    path.lineTo(w * 0.86, h * 0.28);
    path.lineTo(w * 0.94, h * 0.38);
    path.lineTo(w * 0.94, h);

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Flying Birds in the Sky
    _drawBird(canvas, Offset(w * 0.18, h * 0.15), strokePaint);
    _drawBird(canvas, Offset(w * 0.24, h * 0.10), strokePaint);
    _drawBird(canvas, Offset(w * 0.30, h * 0.18), strokePaint);
    _drawBird(canvas, Offset(w * 0.68, h * 0.12), strokePaint);
    _drawBird(canvas, Offset(w * 0.74, h * 0.08), strokePaint);
    _drawBird(canvas, Offset(w * 0.80, h * 0.14), strokePaint);
  }

  void _drawBird(Canvas canvas, Offset pos, Paint paint) {
    final birdPath = Path();
    birdPath.moveTo(pos.dx - 8, pos.dy + 3);
    birdPath.quadraticBezierTo(
      pos.dx - 4,
      pos.dy - 5,
      pos.dx,
      pos.dy,
    );
    birdPath.quadraticBezierTo(
      pos.dx + 4,
      pos.dy - 5,
      pos.dx + 8,
      pos.dy + 3,
    );
    canvas.drawPath(birdPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
