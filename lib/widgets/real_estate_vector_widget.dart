import 'package:flutter/material.dart';

class RealEstateSkylineWidget extends StatelessWidget {
  final double height;
  final Color color;

  const RealEstateSkylineWidget({
    super.key,
    this.height = 140,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _RealEstateSkylinePainter(color: color),
      ),
    );
  }
}

class _RealEstateSkylinePainter extends CustomPainter {
  final Color color;

  _RealEstateSkylinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final windowPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    final path = Path();
    path.moveTo(0, h);

    // House 1 (Left suburban house with pitched roof)
    path.lineTo(0, h * 0.7);
    path.lineTo(w * 0.05, h * 0.55);
    path.lineTo(w * 0.10, h * 0.7);
    path.lineTo(w * 0.10, h);

    // Tree 1
    canvas.drawCircle(Offset(w * 0.13, h * 0.65), h * 0.12, fillPaint);
    canvas.drawRect(
      Rect.fromLTWH(w * 0.125, h * 0.75, w * 0.01, h * 0.25),
      fillPaint,
    );

    // Building 1 (Mid-rise apartment)
    path.moveTo(w * 0.15, h);
    path.lineTo(w * 0.15, h * 0.4);
    path.lineTo(w * 0.28, h * 0.4);
    path.lineTo(w * 0.28, h);

    // Building 2 (Tall Central Skyscraper)
    path.moveTo(w * 0.30, h);
    path.lineTo(w * 0.30, h * 0.15);
    path.lineTo(w * 0.32, h * 0.08); // Tower Spire Top
    path.lineTo(w * 0.48, h * 0.08);
    path.lineTo(w * 0.50, h * 0.15);
    path.lineTo(w * 0.50, h);

    // Building 3 (Commercial Block)
    path.moveTo(w * 0.52, h);
    path.lineTo(w * 0.52, h * 0.32);
    path.lineTo(w * 0.68, h * 0.32);
    path.lineTo(w * 0.68, h);

    // House 2 (Right suburban home)
    path.moveTo(w * 0.70, h);
    path.lineTo(w * 0.70, h * 0.62);
    path.lineTo(w * 0.78, h * 0.48);
    path.lineTo(w * 0.86, h * 0.62);
    path.lineTo(w * 0.86, h);

    // Tree 2
    canvas.drawCircle(Offset(w * 0.90, h * 0.68), h * 0.10, fillPaint);
    canvas.drawRect(
      Rect.fromLTWH(w * 0.895, h * 0.75, w * 0.01, h * 0.25),
      fillPaint,
    );

    // House 3 (Far right)
    path.moveTo(w * 0.92, h);
    path.lineTo(w * 0.92, h * 0.72);
    path.lineTo(w * 0.96, h * 0.60);
    path.lineTo(w * 1.00, h * 0.72);
    path.lineTo(w * 1.00, h);

    canvas.drawPath(path, fillPaint);

    // Windows Detail Overlays
    // Central Skyscraper Windows Matrix
    for (double y = h * 0.20; y < h * 0.9; y += h * 0.08) {
      for (double x = w * 0.34; x < w * 0.46; x += w * 0.04) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, w * 0.025, h * 0.045),
            const Radius.circular(1),
          ),
          windowPaint,
        );
      }
    }

    // Mid-rise Windows
    for (double y = h * 0.45; y < h * 0.9; y += h * 0.10) {
      for (double x = w * 0.18; x < w * 0.26; x += w * 0.035) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, w * 0.022, h * 0.05),
            const Radius.circular(1),
          ),
          windowPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
