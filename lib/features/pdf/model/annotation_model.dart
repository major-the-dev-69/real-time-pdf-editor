import 'package:flutter/material.dart';

class AnnotationModel {
  final String id;
  final String pdfId;
  final int pageNumber;
  final String type;
  final double scale;
  final Map<String, dynamic> payload;
  final bool isUndone;
  final String createdAt;

  AnnotationModel({
    required this.id,
    this.pdfId = '',
    required this.pageNumber,
    required this.type,
    this.scale = 1.0,
    required this.payload,
    this.isUndone = false,
    this.createdAt = '',
  });

  factory AnnotationModel.fromJson(Map<String, dynamic> json) {
    final rawPayload = json['payload'];
    Map<String, dynamic> parsedPayload = {};
    if (rawPayload is Map<String, dynamic>) {
      parsedPayload = rawPayload;
    } else if (rawPayload is Map) {
      parsedPayload = Map<String, dynamic>.from(rawPayload);
    }

    final rawUndone = json['is_undone'] ?? json['isUndone'];
    bool undoneBool = false;
    if (rawUndone is bool) {
      undoneBool = rawUndone;
    } else if (rawUndone != null) {
      undoneBool =
          rawUndone.toString() == '1' ||
          rawUndone.toString().toLowerCase() == 'true';
    }

    final rawScale = json['scale'];
    double scaleVal = 1.0;
    if (rawScale is num) {
      scaleVal = rawScale.toDouble();
    } else if (rawScale != null) {
      scaleVal = double.tryParse(rawScale.toString()) ?? 1.0;
    }

    return AnnotationModel(
      id: json['uuid']?.toString() ?? json['id']?.toString() ?? '',
      pdfId: json['pdf_id']?.toString() ?? json['pdf_uuid']?.toString() ?? '',
      pageNumber:
          (json['page_number'] as num?)?.toInt() ?? json['page_number'] ?? 1,
      type: json['type']?.toString() ?? 'draw',
      scale: scaleVal,
      payload: parsedPayload,
      isUndone: undoneBool,
      createdAt:
          json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page_number': pageNumber,
      'type': type,
      'scale': double.parse(scale.toStringAsFixed(2)),
      'payload': payload,
    };
  }

  static String colorToHex(Color color) {
    final r = (color.r * 255).toInt().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255).toInt().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255).toInt().toRadixString(16).padLeft(2, '0');
    return '#$r$g$b'.toUpperCase();
  }

  static Color hexToColor(String? hexStr) {
    if (hexStr == null || hexStr.trim().isEmpty) return Colors.red;
    var cleanHex = hexStr.replaceAll('#', '').trim();
    if (cleanHex.length == 6) {
      cleanHex = 'FF$cleanHex';
    }
    final intVal = int.tryParse(cleanHex, radix: 16);
    return intVal != null ? Color(intVal) : Colors.red;
  }

  static Map<String, dynamic> createDrawPayload(
    List<Offset> points,
    Color color,
    double strokeWidth,
  ) {
    return {
      'points': points
          .map((p) => {
                'x': double.parse(p.dx.toStringAsFixed(2)),
                'y': double.parse(p.dy.toStringAsFixed(2)),
              })
          .toList(),
      'color': colorToHex(color),
      'strokeWidth': strokeWidth.roundToDouble(),
    };
  }

  static Map<String, dynamic> createPencilPayload(
    List<Offset> points,
    Color color,
    double strokeWidth,
  ) => createDrawPayload(points, color, strokeWidth);

  static String fontWeightToString(FontWeight? weight) {
    if (weight == null) return 'normal';
    switch (weight) {
      case FontWeight.w100:
        return '100';
      case FontWeight.w200:
        return '200';
      case FontWeight.w300:
        return '300';
      case FontWeight.w400:
        return '400';
      case FontWeight.w500:
        return '500';
      case FontWeight.w600:
        return '600';
      case FontWeight.w700:
        return '700';
      case FontWeight.w800:
        return '800';
      case FontWeight.w900:
        return '900';
      default:
        return '400';
    }
  }

  static FontWeight stringToFontWeight(dynamic val) {
    if (val == null) return FontWeight.normal;
    final str = val.toString().toLowerCase().trim();
    if (str == 'bold' || str == '700' || str.contains('w700')) {
      return FontWeight.bold;
    }
    if (str == 'normal' ||
        str == '400' ||
        str.contains('w400') ||
        str == 'regular') {
      return FontWeight.normal;
    }
    if (str == '100' || str.contains('w100') || str == 'thin') {
      return FontWeight.w100;
    }
    if (str == '200' || str.contains('w200') || str == 'extralight') {
      return FontWeight.w200;
    }
    if (str == '300' || str.contains('w300') || str == 'light') {
      return FontWeight.w300;
    }
    if (str == '500' || str.contains('w500') || str == 'medium') {
      return FontWeight.w500;
    }
    if (str == '600' || str.contains('w600') || str == 'semibold') {
      return FontWeight.w600;
    }
    if (str == '800' || str.contains('w800') || str == 'extrabold') {
      return FontWeight.w800;
    }
    if (str == '900' || str.contains('w900') || str == 'black') {
      return FontWeight.w900;
    }

    final numVal = int.tryParse(str);
    if (numVal != null) {
      if (numVal <= 150) return FontWeight.w100;
      if (numVal <= 250) return FontWeight.w200;
      if (numVal <= 350) return FontWeight.w300;
      if (numVal <= 450) return FontWeight.w400;
      if (numVal <= 550) return FontWeight.w500;
      if (numVal <= 650) return FontWeight.w600;
      if (numVal <= 750) return FontWeight.w700;
      if (numVal <= 850) return FontWeight.w800;
      return FontWeight.w900;
    }
    return FontWeight.normal;
  }

  static Map<String, dynamic> createTextPayload(
    String text,
    Offset position,
    double fontSize,
    Color color, {
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return {
      'text': text,
      'x': double.parse(position.dx.toStringAsFixed(2)),
      'y': double.parse(position.dy.toStringAsFixed(2)),
      'fontSize': fontSize.roundToDouble(),
      'color': colorToHex(color),
      'fontWeight': fontWeightToString(fontWeight),
    };
  }

  static Map<String, dynamic> createCrossPayload(
    Offset position,
    double size,
    Color color,
  ) {
    return {
      'x': double.parse(position.dx.toStringAsFixed(2)),
      'y': double.parse(position.dy.toStringAsFixed(2)),
      'size': size.roundToDouble(),
      'color': colorToHex(color),
    };
  }
}
