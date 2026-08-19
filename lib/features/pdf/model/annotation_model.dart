import 'package:flutter/material.dart';

class AnnotationModel {
  final String id;
  final String pdfId;
  final int pageNumber;
  final String type;
  final Map<String, dynamic> payload;
  final bool isUndone;
  final String createdAt;

  AnnotationModel({
    required this.id,
    this.pdfId = '',
    required this.pageNumber,
    required this.type,
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

    return AnnotationModel(
      id: json['uuid']?.toString() ?? json['id']?.toString() ?? '',
      pdfId: json['pdf_id']?.toString() ?? json['pdf_uuid']?.toString() ?? '',
      pageNumber:
          (json['page_number'] as num?)?.toInt() ?? json['page_number'] ?? 1,
      type: json['type']?.toString() ?? 'pencil',
      payload: parsedPayload,
      isUndone: undoneBool,
      createdAt:
          json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'page_number': pageNumber, 'type': type, 'payload': payload};
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

  static Map<String, dynamic> createPencilPayload(
    List<Offset> points,
    Color color,
    double strokeWidth,
  ) {
    return {
      'points': points
          .map((p) => {'x': p.dx.roundToDouble(), 'y': p.dy.roundToDouble()})
          .toList(),
      'color': colorToHex(color),
      'strokeWidth': strokeWidth.roundToDouble(),
    };
  }

  static Map<String, dynamic> createTextPayload(
    String text,
    Offset position,
    double fontSize,
    Color color,
  ) {
    return {
      'text': text,
      'x': position.dx.roundToDouble(),
      'y': position.dy.roundToDouble(),
      'fontSize': fontSize.roundToDouble(),
      'color': colorToHex(color),
    };
  }

  static Map<String, dynamic> createCrossPayload(
    Offset position,
    double size,
    Color color,
  ) {
    return {
      'x': position.dx.roundToDouble(),
      'y': position.dy.roundToDouble(),
      'size': size.roundToDouble(),
      'color': colorToHex(color),
    };
  }
}
