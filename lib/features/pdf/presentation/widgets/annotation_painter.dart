import 'package:flutter/material.dart';

class DrawnLine {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  const DrawnLine({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });
}

class TextAnnotation {
  final String id;
  final Offset position;
  final String text;
  final Color color;
  final double fontSize;

  const TextAnnotation({
    required this.id,
    required this.position,
    required this.text,
    required this.color,
    required this.fontSize,
  });

  TextAnnotation copyWith({
    Offset? position,
    String? text,
    Color? color,
    double? fontSize,
  }) {
    return TextAnnotation(
      id: id,
      position: position ?? this.position,
      text: text ?? this.text,
      color: color ?? this.color,
      fontSize: fontSize ?? this.fontSize,
    );
  }
}

class AnnotationPainter extends CustomPainter {
  final List<DrawnLine> lines;
  final DrawnLine? currentLine;
  final List<TextAnnotation> textAnnotations;

  const AnnotationPainter({
    required this.lines,
    this.currentLine,
    required this.textAnnotations,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Paint Completed Lines
    for (final line in lines) {
      _drawLine(canvas, line);
    }

    // 2. Paint Active Current Line
    if (currentLine != null) {
      _drawLine(canvas, currentLine!);
    }

    // 3. Paint Text Annotations
    for (final annotation in textAnnotations) {
      _drawText(canvas, annotation);
    }
  }

  void _drawLine(Canvas canvas, DrawnLine line) {
    if (line.points.isEmpty) return;

    final paint = Paint()
      ..color = line.color
      ..strokeWidth = line.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (line.points.length == 1) {
      canvas.drawCircle(line.points.first, line.strokeWidth / 2, paint);
      return;
    }

    final path = Path();
    path.moveTo(line.points.first.dx, line.points.first.dy);
    for (int i = 1; i < line.points.length; i++) {
      path.lineTo(line.points[i].dx, line.points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  void _drawText(Canvas canvas, TextAnnotation annotation) {
    final textStyle = TextStyle(
      color: annotation.color,
      fontSize: annotation.fontSize,
      fontWeight: FontWeight.bold,
      shadows: const [
        Shadow(
          blurRadius: 2.0,
          color: Colors.black38,
          offset: Offset(1, 1),
        ),
      ],
    );

    final textSpan = TextSpan(
      text: annotation.text,
      style: textStyle,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, annotation.position);
  }

  @override
  bool shouldRepaint(covariant AnnotationPainter oldDelegate) {
    return true;
  }
}
