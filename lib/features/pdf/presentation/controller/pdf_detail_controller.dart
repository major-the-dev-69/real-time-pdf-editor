import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../model/pdf_document_model.dart';
import '../widgets/annotation_painter.dart';

enum AnnotationMode { view, draw, text, erase }

class PdfDetailController extends GetxController {
  final pdfDocument = Rxn<PdfDocumentModel>();
  final isDownloading = false.obs;
  final downloadProgress = 0.0.obs;

  // Syncfusion PDF Controller
  late PdfViewerController pdfViewerController;

  // Page tracking
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final isLoaded = false.obs;

  // Active Annotation Mode
  final activeMode = AnnotationMode.view.obs;

  // Drawing Customisation
  final selectedColor = Rx<Color>(Colors.red);
  final selectedStrokeWidth = 4.0.obs;
  final selectedFontSize = 18.0.obs;

  // Color Palette choices
  final availableColors = const <Color>[
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.amber,
    Colors.purple,
    Colors.orange,
    Colors.black,
    Colors.white,
  ];

  // Annotation Collections
  final lines = <DrawnLine>[].obs;
  final currentLine = Rxn<DrawnLine>();
  final textAnnotations = <TextAnnotation>[].obs;

  @override
  void onInit() {
    super.onInit();
    pdfViewerController = PdfViewerController();

    final args = Get.arguments;
    if (args is PdfDocumentModel) {
      pdfDocument.value = args;
    }
  }

  @override
  void onClose() {
    pdfViewerController.dispose();
    super.onClose();
  }

  void setPdfDocument(PdfDocumentModel document) {
    pdfDocument.value = document;
  }

  void setMode(AnnotationMode mode) {
    activeMode.value = mode;
  }

  void setColor(Color color) {
    selectedColor.value = color;
  }

  void setStrokeWidth(double width) {
    selectedStrokeWidth.value = width;
  }

  void setFontSize(double size) {
    selectedFontSize.value = size;
  }

  // Drawing Gesture Handlers
  void startLine(Offset position) {
    if (activeMode.value == AnnotationMode.draw) {
      currentLine.value = DrawnLine(
        points: [position],
        color: selectedColor.value,
        strokeWidth: selectedStrokeWidth.value,
      );
    } else if (activeMode.value == AnnotationMode.erase) {
      eraseNear(position);
    }
  }

  void updateLine(Offset position) {
    if (activeMode.value == AnnotationMode.draw && currentLine.value != null) {
      final updatedPoints = List<Offset>.from(currentLine.value!.points)
        ..add(position);
      currentLine.value = DrawnLine(
        points: updatedPoints,
        color: selectedColor.value,
        strokeWidth: selectedStrokeWidth.value,
      );
    } else if (activeMode.value == AnnotationMode.erase) {
      eraseNear(position);
    }
  }

  void endLine() {
    if (activeMode.value == AnnotationMode.draw && currentLine.value != null) {
      lines.add(currentLine.value!);
      currentLine.value = null;
    }
  }

  // Add Text Annotation
  void addTextAnnotation(String text, Offset position) {
    if (text.trim().isEmpty) return;
    textAnnotations.add(
      TextAnnotation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        position: position,
        text: text,
        color: selectedColor.value,
        fontSize: selectedFontSize.value,
      ),
    );
  }

  // Erase annotations near touch point
  void eraseNear(Offset point) {
    const threshold = 25.0;
    lines.removeWhere((line) {
      return line.points.any((p) => (p - point).distance < threshold);
    });
    textAnnotations.removeWhere((t) {
      return (t.position - point).distance < threshold;
    });
  }

  // Undo last action
  void undo() {
    if (lines.isNotEmpty) {
      lines.removeLast();
    } else if (textAnnotations.isNotEmpty) {
      textAnnotations.removeLast();
    }
  }

  // Clear all annotations
  void clearAllAnnotations() {
    lines.clear();
    currentLine.value = null;
    textAnnotations.clear();
  }

  void downloadPdf() {
    isDownloading.value = true;
    downloadProgress.value = 0.1;

    Future.delayed(const Duration(milliseconds: 300), () {
      downloadProgress.value = 0.5;
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      downloadProgress.value = 1.0;
      isDownloading.value = false;
      Get.snackbar(
        'Success',
        '${pdfDocument.value?.title ?? "PDF"} downloaded successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    });
  }

  void sharePdf() {
    Get.snackbar(
      'Share PDF',
      'Sharing ${pdfDocument.value?.title ?? "Document"}...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
