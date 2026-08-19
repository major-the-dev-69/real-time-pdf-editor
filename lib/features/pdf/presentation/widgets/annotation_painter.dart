import 'package:flutter/material.dart';

class DrawnLine {
  final String id;
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final int pageNumber;

  const DrawnLine({
    this.id = '',
    required this.points,
    required this.color,
    required this.strokeWidth,
    this.pageNumber = 1,
  });

  DrawnLine copyWith({
    String? id,
    List<Offset>? points,
    Color? color,
    double? strokeWidth,
    int? pageNumber,
  }) {
    return DrawnLine(
      id: id ?? this.id,
      points: points ?? this.points,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      pageNumber: pageNumber ?? this.pageNumber,
    );
  }
}

class TextAnnotation {
  final String id;
  final Offset position;
  final String text;
  final Color color;
  final double fontSize;
  final int pageNumber;

  const TextAnnotation({
    required this.id,
    required this.position,
    required this.text,
    required this.color,
    required this.fontSize,
    this.pageNumber = 1,
  });

  TextAnnotation copyWith({
    String? id,
    Offset? position,
    String? text,
    Color? color,
    double? fontSize,
    int? pageNumber,
  }) {
    return TextAnnotation(
      id: id ?? this.id,
      position: position ?? this.position,
      text: text ?? this.text,
      color: color ?? this.color,
      fontSize: fontSize ?? this.fontSize,
      pageNumber: pageNumber ?? this.pageNumber,
    );
  }
}

class CrossAnnotation {
  final String id;
  final Offset position;
  final double size;
  final Color color;
  final int pageNumber;

  const CrossAnnotation({
    required this.id,
    required this.position,
    required this.size,
    required this.color,
    this.pageNumber = 1,
  });

  CrossAnnotation copyWith({
    String? id,
    Offset? position,
    double? size,
    Color? color,
    int? pageNumber,
  }) {
    return CrossAnnotation(
      id: id ?? this.id,
      position: position ?? this.position,
      size: size ?? this.size,
      color: color ?? this.color,
      pageNumber: pageNumber ?? this.pageNumber,
    );
  }
}

class AnnotationPainter extends CustomPainter {
  final List<DrawnLine> lines;
  final DrawnLine? currentLine;
  final List<TextAnnotation> textAnnotations;
  final List<CrossAnnotation> crossAnnotations;
  final int currentPage;

  const AnnotationPainter({
    required this.lines,
    this.currentLine,
    required this.textAnnotations,
    this.crossAnnotations = const [],
    this.currentPage = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Paint Completed Lines for current page
    for (final line in lines) {
      if (line.pageNumber == currentPage || line.pageNumber <= 0) {
        _drawLine(canvas, line);
      }
    }

    // 2. Paint Active Current Line
    if (currentLine != null) {
      _drawLine(canvas, currentLine!);
    }

    // 3. Paint Text Annotations for current page
    for (final annotation in textAnnotations) {
      if (annotation.pageNumber == currentPage || annotation.pageNumber <= 0) {
        _drawText(canvas, annotation);
      }
    }

    // 4. Paint Cross Annotations for current page
    for (final cross in crossAnnotations) {
      if (cross.pageNumber == currentPage || cross.pageNumber <= 0) {
        _drawCross(canvas, cross);
      }
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

  void _drawCross(Canvas canvas, CrossAnnotation cross) {
    final half = cross.size / 2;
    final paint = Paint()
      ..color = cross.color
      ..strokeWidth = (cross.size / 6).clamp(2.0, 5.0)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = cross.position;
    // Top-left to bottom-right
    canvas.drawLine(
      Offset(center.dx - half, center.dy - half),
      Offset(center.dx + half, center.dy + half),
      paint,
    );
    // Bottom-left to top-right
    canvas.drawLine(
      Offset(center.dx - half, center.dy + half),
      Offset(center.dx + half, center.dy - half),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant AnnotationPainter oldDelegate) {
    return true;
  }
}
