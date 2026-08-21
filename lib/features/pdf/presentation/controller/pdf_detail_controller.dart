import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/helper/logger_helper.dart';
import '../../../../core/network/api_services.dart';
import '../../../../core/network/pusher_service.dart';
import '../../../../widgets/custom_snack_bar.dart';
import '../../model/annotation_model.dart';
import '../../model/pdf_document_model.dart';
import '../widgets/annotation_painter.dart';

enum AnnotationMode { view, draw, text, cross, erase }

class PdfDetailController extends GetxController {
  final pdfDocument = Rxn<PdfDocumentModel>();
  final isDownloading = false.obs;
  final isFetchingDetails = false.obs;
  final isFetchingAnnotations = false.obs;
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
  final selectedCrossSize = 20.0.obs;

  // Color Palette choices
  final availableColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
    Colors.white,
  ];

  // Annotation Collections
  final lines = <DrawnLine>[].obs;
  final currentLine = Rxn<DrawnLine>();
  final textAnnotations = <TextAnnotation>[].obs;
  final crossAnnotations = <CrossAnnotation>[].obs;

  // Redo tracking stack
  final redoStack = <Map<String, dynamic>>[].obs;

  bool get hasUnsavedChanges =>
      lines.isNotEmpty ||
      textAnnotations.isNotEmpty ||
      crossAnnotations.isNotEmpty;

  String currentPusherChannel = '';

  final effectivePdfUrl = ''.obs;
  final isPdfLoadError = false.obs;

  @override
  void onInit() {
    super.onInit();
    pdfViewerController = PdfViewerController();

    ever(pdfDocument, (_) {
      updatePdfUrlFromModel();
    });

    final args = Get.arguments;
    if (args is PdfDocumentModel) {
      pdfDocument.value = args;
      fetchPdfDetails(args.id);
    } else if (args is String && args.isNotEmpty) {
      fetchPdfDetails(args);
    } else if (args is Map<String, dynamic>) {
      final uuid = args['uuid']?.toString() ?? args['id']?.toString() ?? '';
      if (uuid.isNotEmpty) {
        fetchPdfDetails(uuid);
      }
    }
    updatePdfUrlFromModel();
  }

  void updatePdfUrlFromModel() {
    final modelUrl = pdfDocument.value?.pdfUrl.trim() ?? '';
    if (modelUrl.isNotEmpty && (modelUrl.startsWith('https://'))) {
      effectivePdfUrl.value = modelUrl;
      isPdfLoadError.value = false;
    } else {
      effectivePdfUrl.value = '';
      if (pdfDocument.value != null) {
        isPdfLoadError.value = true;
      }
    }
  }

  Future<void> fetchPdfDetails(String pdfUuid) async {
    if (pdfUuid.isEmpty) return;
    isFetchingDetails.value = true;

    try {
      final endpoint = 'pdfs/$pdfUuid';
      final response = await Get.find<ApiServices>().callGetApi(
        endpoint,
        isUserRequired: true,
      );

      if (response.status && response.data != null) {
        final doc = PdfDocumentModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        pdfDocument.value = doc;
        await fetchAnnotations(pdfUuid);
      }
    } catch (e) {
      printMessage("⚠️ Error fetching PDF details: $e");
    } finally {
      isFetchingDetails.value = false;
    }
  }

  Future<void> fetchAnnotations(String pdfUuid) async {
    if (pdfUuid.isEmpty) return;
    isFetchingAnnotations.value = true;

    try {
      final endpoint = 'pdfs/$pdfUuid/annotations';
      final response = await Get.find<ApiServices>().callGetApi(
        endpoint,
        isUserRequired: true,
      );

      if (response.status && response.data != null) {
        dynamic annotationsData = response.data;
        if (annotationsData is Map &&
            annotationsData.containsKey('annotations')) {
          annotationsData = annotationsData['annotations'];
        }
        if (annotationsData is List) {
          final loadedLines = <DrawnLine>[];
          final loadedTexts = <TextAnnotation>[];
          final loadedCrosses = <CrossAnnotation>[];

          for (final item in annotationsData) {
            if (item is Map<String, dynamic>) {
              final annotation = AnnotationModel.fromJson(item);
              final pageNo = annotation.pageNumber;
              final payload = annotation.payload;

              if (annotation.type == 'pencil') {
                final pointsRaw = payload['points'];
                List<Offset> points = [];
                if (pointsRaw is List) {
                  points = pointsRaw.map((pt) {
                    final x = (pt['x'] as num?)?.toDouble() ?? 0.0;
                    final y = (pt['y'] as num?)?.toDouble() ?? 0.0;
                    return Offset(x, y);
                  }).toList();
                }

                final strokeW =
                    (payload['strokeWidth'] as num?)?.toDouble() ?? 3.0;
                final col = AnnotationModel.hexToColor(
                  payload['color']?.toString(),
                );

                loadedLines.add(
                  DrawnLine(
                    id: annotation.id,
                    points: points,
                    color: col,
                    strokeWidth: strokeW,
                    pageNumber: pageNo,
                  ),
                );
              } else if (annotation.type == 'text') {
                final textStr = payload['text']?.toString() ?? '';
                final x = (payload['x'] as num?)?.toDouble() ?? 0.0;
                final y = (payload['y'] as num?)?.toDouble() ?? 0.0;
                final fontS = (payload['fontSize'] as num?)?.toDouble() ?? 18.0;
                final col = AnnotationModel.hexToColor(
                  payload['color']?.toString(),
                );

                loadedTexts.add(
                  TextAnnotation(
                    id: annotation.id,
                    position: Offset(x, y),
                    text: textStr,
                    color: col,
                    fontSize: fontS,
                    pageNumber: pageNo,
                  ),
                );
              } else if (annotation.type == 'cross') {
                final x = (payload['x'] as num?)?.toDouble() ?? 0.0;
                final y = (payload['y'] as num?)?.toDouble() ?? 0.0;
                final sizeVal = (payload['size'] as num?)?.toDouble() ?? 20.0;
                final col = AnnotationModel.hexToColor(
                  payload['color']?.toString(),
                );

                loadedCrosses.add(
                  CrossAnnotation(
                    id: annotation.id,
                    position: Offset(x, y),
                    size: sizeVal,
                    color: col,
                    pageNumber: pageNo,
                  ),
                );
              }
            }
          }

          lines.assignAll(loadedLines);
          textAnnotations.assignAll(loadedTexts);
          crossAnnotations.assignAll(loadedCrosses);

          await setupRealtimePusher(pdfUuid);
        }
      }
    } catch (e) {
      printMessage("⚠️ Error fetching annotations: $e");
    } finally {
      isFetchingAnnotations.value = false;
    }
  }

  Future<void> setupRealtimePusher(String pdfUuid) async {
    if (pdfUuid.isEmpty) return;

    if (currentPusherChannel.isNotEmpty && Get.isRegistered<PusherService>()) {
      await Get.find<PusherService>().unsubscribeFromChannel(
        currentPusherChannel,
        _handlePusherEvent,
      );
    }

    currentPusherChannel = 'pdf.$pdfUuid';
    if (Get.isRegistered<PusherService>()) {
      await Get.find<PusherService>().subscribeToChannel(
        currentPusherChannel,
        _handlePusherEvent,
      );
    }
  }

  void _handlePusherEvent(PusherEvent event) {
    try {
      printMessage(
        "📡 Handling Pusher Event in PdfDetailController: ${event.eventName}",
      );
      dynamic data = event.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      final eventName = event.eventName.toLowerCase();

      if (eventName.contains('created') || eventName.contains('added')) {
        final annData = (data is Map && data.containsKey('annotation'))
            ? data['annotation']
            : data;
        if (annData is Map<String, dynamic>) {
          _addOrUpdateSingleAnnotation(AnnotationModel.fromJson(annData));
        }
      } else if (eventName.contains('updated')) {
        final annData = (data is Map && data.containsKey('annotation'))
            ? data['annotation']
            : data;
        if (annData is Map<String, dynamic>) {
          _addOrUpdateSingleAnnotation(AnnotationModel.fromJson(annData));
        }
      } else if (eventName.contains('deleted') ||
          eventName.contains('removed')) {
        final targetId = (data is Map)
            ? (data['uuid']?.toString() ??
                  data['id']?.toString() ??
                  data['annotation_id']?.toString() ??
                  '')
            : '';
        if (targetId.isNotEmpty) {
          lines.removeWhere((l) => l.id == targetId);
          textAnnotations.removeWhere((t) => t.id == targetId);
          crossAnnotations.removeWhere((c) => c.id == targetId);
        }
      } else if (eventName.contains('clear')) {
        final pageNo = (data is Map)
            ? ((data['page_number'] as num?)?.toInt() ?? 1)
            : 1;
        lines.removeWhere((l) => l.pageNumber == pageNo);
        textAnnotations.removeWhere((t) => t.pageNumber == pageNo);
        crossAnnotations.removeWhere((c) => c.pageNumber == pageNo);
      }
    } catch (e) {
      printMessage("⚠️ Error handling Pusher event: $e");
    }
  }

  void _addOrUpdateSingleAnnotation(AnnotationModel annotation) {
    final pageNo = annotation.pageNumber;
    final payload = annotation.payload;

    if (annotation.type == 'pencil') {
      final pointsRaw = payload['points'];
      List<Offset> points = [];
      if (pointsRaw is List) {
        points = pointsRaw.map((pt) {
          final x = (pt['x'] as num?)?.toDouble() ?? 0.0;
          final y = (pt['y'] as num?)?.toDouble() ?? 0.0;
          return Offset(x, y);
        }).toList();
      }
      final strokeW = (payload['strokeWidth'] as num?)?.toDouble() ?? 3.0;
      final col = AnnotationModel.hexToColor(payload['color']?.toString());

      final newLine = DrawnLine(
        id: annotation.id,
        points: points,
        color: col,
        strokeWidth: strokeW,
        pageNumber: pageNo,
      );

      final idx = lines.indexWhere((l) => l.id == annotation.id);
      if (idx != -1) {
        lines[idx] = newLine;
      } else {
        lines.add(newLine);
      }
    } else if (annotation.type == 'text') {
      final textStr = payload['text']?.toString() ?? '';
      final x = (payload['x'] as num?)?.toDouble() ?? 0.0;
      final y = (payload['y'] as num?)?.toDouble() ?? 0.0;
      final fontS = (payload['fontSize'] as num?)?.toDouble() ?? 18.0;
      final col = AnnotationModel.hexToColor(payload['color']?.toString());

      final newText = TextAnnotation(
        id: annotation.id,
        position: Offset(x, y),
        text: textStr,
        color: col,
        fontSize: fontS,
        pageNumber: pageNo,
      );

      final idx = textAnnotations.indexWhere((t) => t.id == annotation.id);
      if (idx != -1) {
        textAnnotations[idx] = newText;
      } else {
        textAnnotations.add(newText);
      }
    } else if (annotation.type == 'cross') {
      final x = (payload['x'] as num?)?.toDouble() ?? 0.0;
      final y = (payload['y'] as num?)?.toDouble() ?? 0.0;
      final sizeVal = (payload['size'] as num?)?.toDouble() ?? 20.0;
      final col = AnnotationModel.hexToColor(payload['color']?.toString());

      final newCross = CrossAnnotation(
        id: annotation.id,
        position: Offset(x, y),
        size: sizeVal,
        color: col,
        pageNumber: pageNo,
      );

      final idx = crossAnnotations.indexWhere((c) => c.id == annotation.id);
      if (idx != -1) {
        crossAnnotations[idx] = newCross;
      } else {
        crossAnnotations.add(newCross);
      }
    }
  }

  // --- API HELPER METHODS ---

  Future<String?> createAnnotationApi(AnnotationModel item) async {
    final pdfUuid = pdfDocument.value?.id ?? '';
    if (pdfUuid.isEmpty) return null;

    try {
      final endpoint = 'pdfs/$pdfUuid/annotations';
      final response = await Get.find<ApiServices>().callPostApi(
        endpoint,
        req: item.toJson(),
        isUserRequired: true,
      );

      if (response.status && response.data != null) {
        if (response.data is Map) {
          final resMap = response.data as Map;
          return resMap['uuid']?.toString() ?? resMap['id']?.toString();
        }
      }
    } catch (e) {
      printMessage("⚠️ Error creating annotation API: $e");
    }
    return null;
  }

  Future<bool> updateAnnotationApi(
    String annotationUuid,
    AnnotationModel item,
  ) async {
    if (annotationUuid.isEmpty) return false;

    try {
      final endpoint = 'annotations/$annotationUuid';
      final response = await Get.find<ApiServices>().callPutApi(
        endpoint,
        req: item.toJson(),
        isUserRequired: true,
      );
      return response.status;
    } catch (e) {
      printMessage("⚠️ Error updating annotation API: $e");
      return false;
    }
  }

  Future<bool> deleteAnnotationApi(String annotationUuid) async {
    if (annotationUuid.isEmpty) return false;

    try {
      final endpoint = 'annotations/$annotationUuid';
      final response = await Get.find<ApiServices>().callDeleteApi(
        endpoint,
        isUserRequired: true,
      );
      return response.status;
    } catch (e) {
      printMessage("⚠️ Error deleting annotation API: $e");
      return false;
    }
  }

  Future<bool> undoAnnotationApi(String annotationUuid) async {
    if (annotationUuid.isEmpty) return false;

    try {
      final endpoint = 'annotations/$annotationUuid/undo';
      final response = await Get.find<ApiServices>().callPostApi(
        endpoint,
        req: <String, dynamic>{},
        isUserRequired: true,
      );
      return response.status;
    } catch (e) {
      printMessage("⚠️ Error undoing annotation API: $e");
      return false;
    }
  }

  Future<bool> redoAnnotationApi(String annotationUuid) async {
    if (annotationUuid.isEmpty) return false;

    try {
      final endpoint = 'annotations/$annotationUuid/redo';
      final response = await Get.find<ApiServices>().callPostApi(
        endpoint,
        req: <String, dynamic>{},
        isUserRequired: true,
      );
      return response.status;
    } catch (e) {
      printMessage("⚠️ Error redoing annotation API: $e");
      return false;
    }
  }

  Future<bool> clearPageAnnotationsApi(int pageNo) async {
    final pdfUuid = pdfDocument.value?.id ?? '';
    if (pdfUuid.isEmpty) return false;

    try {
      final endpoint = 'pdfs/$pdfUuid/clear-page';
      final response = await Get.find<ApiServices>().callPostApi(
        endpoint,
        req: {'page_number': pageNo},
        isUserRequired: true,
      );
      return response.status;
    } catch (e) {
      printMessage("⚠️ Error clearing page annotations API: $e");
      return false;
    }
  }

  Future<void> deletePdf(String pdfUuid) async {
    if (pdfUuid.isEmpty) return;

    final endpoint = 'pdfs/$pdfUuid';
    final response = await Get.find<ApiServices>().callDeleteApi(
      endpoint,
      isUserRequired: true,
    );

    if (response.status) {
      Get.back(result: true);
      CustomSnackBar.showSuccess(message: response.message);
    } else {
      CustomSnackBar.showError(message: response.message);
    }
  }

  @override
  void onClose() {
    if (currentPusherChannel.isNotEmpty && Get.isRegistered<PusherService>()) {
      Get.find<PusherService>().unsubscribeFromChannel(
        currentPusherChannel,
        _handlePusherEvent,
      );
    }
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

  void setCrossSize(double size) {
    selectedCrossSize.value = size;
  }

  // --- DRAWING GESTURE HANDLERS ---

  void startLine(Offset position) {
    if (activeMode.value == AnnotationMode.draw) {
      currentLine.value = DrawnLine(
        points: [position],
        color: selectedColor.value,
        strokeWidth: selectedStrokeWidth.value,
        pageNumber: currentPage.value,
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
        pageNumber: currentPage.value,
      );
    } else if (activeMode.value == AnnotationMode.erase) {
      eraseNear(position);
    }
  }

  Future<void> endLine() async {
    if (activeMode.value == AnnotationMode.draw && currentLine.value != null) {
      final newCompletedLine = currentLine.value!;
      lines.add(newCompletedLine);
      currentLine.value = null;

      final payload = AnnotationModel.createPencilPayload(
        newCompletedLine.points,
        newCompletedLine.color,
        newCompletedLine.strokeWidth,
      );
      final model = AnnotationModel(
        id: '',
        pdfId: pdfDocument.value?.id ?? '',
        pageNumber: currentPage.value,
        type: 'pencil',
        payload: payload,
      );

      final serverUuid = await createAnnotationApi(model);
      if (serverUuid != null && serverUuid.isNotEmpty) {
        final idx = lines.indexOf(newCompletedLine);
        if (idx != -1) {
          lines[idx] = newCompletedLine.copyWith(id: serverUuid);
        }
      }
    }
  }

  // Add Text Annotation
  Future<void> addTextAnnotation(String text, Offset position) async {
    if (text.trim().isEmpty) return;

    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final textAnn = TextAnnotation(
      id: tempId,
      position: position,
      text: text,
      color: selectedColor.value,
      fontSize: selectedFontSize.value,
      pageNumber: currentPage.value,
    );

    textAnnotations.add(textAnn);

    final payload = AnnotationModel.createTextPayload(
      text,
      position,
      selectedFontSize.value,
      selectedColor.value,
    );
    final model = AnnotationModel(
      id: '',
      pdfId: pdfDocument.value?.id ?? '',
      pageNumber: currentPage.value,
      type: 'text',
      payload: payload,
    );

    final serverUuid = await createAnnotationApi(model);
    if (serverUuid != null && serverUuid.isNotEmpty) {
      final idx = textAnnotations.indexOf(textAnn);
      if (idx != -1) {
        textAnnotations[idx] = textAnn.copyWith(id: serverUuid);
      }
    }
  }

  // Add Cross Annotation
  Future<void> addCrossAnnotation(Offset position) async {
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final crossAnn = CrossAnnotation(
      id: tempId,
      position: position,
      size: selectedCrossSize.value,
      color: selectedColor.value,
      pageNumber: currentPage.value,
    );

    crossAnnotations.add(crossAnn);

    final payload = AnnotationModel.createCrossPayload(
      position,
      selectedCrossSize.value,
      selectedColor.value,
    );
    final model = AnnotationModel(
      id: '',
      pdfId: pdfDocument.value?.id ?? '',
      pageNumber: currentPage.value,
      type: 'cross',
      payload: payload,
    );

    final serverUuid = await createAnnotationApi(model);
    if (serverUuid != null && serverUuid.isNotEmpty) {
      final idx = crossAnnotations.indexOf(crossAnn);
      if (idx != -1) {
        crossAnnotations[idx] = crossAnn.copyWith(id: serverUuid);
      }
    }
  }

  // Erase annotations near touch point
  Future<void> eraseNear(Offset point) async {
    const threshold = 25.0;
    final page = currentPage.value;

    final removedLines = lines.where((line) {
      return (line.pageNumber == page || line.pageNumber <= 0) &&
          line.points.any((p) => (p - point).distance < threshold);
    }).toList();

    for (final line in removedLines) {
      lines.remove(line);
      if (line.id.isNotEmpty) {
        deleteAnnotationApi(line.id);
      }
    }

    final removedTexts = textAnnotations.where((t) {
      return (t.pageNumber == page || t.pageNumber <= 0) &&
          (t.position - point).distance < threshold;
    }).toList();

    for (final t in removedTexts) {
      textAnnotations.remove(t);
      if (t.id.isNotEmpty) {
        deleteAnnotationApi(t.id);
      }
    }

    final removedCrosses = crossAnnotations.where((c) {
      return (c.pageNumber == page || c.pageNumber <= 0) &&
          (c.position - point).distance < threshold;
    }).toList();

    for (final c in removedCrosses) {
      crossAnnotations.remove(c);
      if (c.id.isNotEmpty) {
        deleteAnnotationApi(c.id);
      }
    }
  }

  // Undo last action
  Future<void> undo() async {
    final page = currentPage.value;

    if (lines.any((l) => l.pageNumber == page)) {
      final line = lines.lastWhere((l) => l.pageNumber == page);
      lines.remove(line);
      redoStack.add({'type': 'pencil', 'item': line});
      if (line.id.isNotEmpty) {
        undoAnnotationApi(line.id);
      }
    } else if (textAnnotations.any((t) => t.pageNumber == page)) {
      final txt = textAnnotations.lastWhere((t) => t.pageNumber == page);
      textAnnotations.remove(txt);
      redoStack.add({'type': 'text', 'item': txt});
      if (txt.id.isNotEmpty) {
        undoAnnotationApi(txt.id);
      }
    } else if (crossAnnotations.any((c) => c.pageNumber == page)) {
      final cross = crossAnnotations.lastWhere((c) => c.pageNumber == page);
      crossAnnotations.remove(cross);
      redoStack.add({'type': 'cross', 'item': cross});
      if (cross.id.isNotEmpty) {
        undoAnnotationApi(cross.id);
      }
    }
  }

  // Redo action
  Future<void> redo() async {
    if (redoStack.isEmpty) return;

    final action = redoStack.removeLast();
    final type = action['type']?.toString();
    final item = action['item'];

    if (type == 'pencil' && item is DrawnLine) {
      lines.add(item);
      if (item.id.isNotEmpty) {
        redoAnnotationApi(item.id);
      }
    } else if (type == 'text' && item is TextAnnotation) {
      textAnnotations.add(item);
      if (item.id.isNotEmpty) {
        redoAnnotationApi(item.id);
      }
    } else if (type == 'cross' && item is CrossAnnotation) {
      crossAnnotations.add(item);
      if (item.id.isNotEmpty) {
        redoAnnotationApi(item.id);
      }
    }
  }

  // Clear all annotations on current page
  Future<void> clearAllAnnotations() async {
    final page = currentPage.value;

    lines.removeWhere((l) => l.pageNumber == page);
    currentLine.value = null;
    textAnnotations.removeWhere((t) => t.pageNumber == page);
    crossAnnotations.removeWhere((c) => c.pageNumber == page);

    await clearPageAnnotationsApi(page);
  }

  Future<void> downloadPdf() async {
    final pdfUrl = effectivePdfUrl.value.trim();
    if (pdfUrl.isEmpty || isPdfLoadError.value) {
      CustomSnackBar.showError(
        title: 'Download Failed',
        message: 'PDF document URL is invalid or not available.',
      );
      return;
    }

    isDownloading.value = true;
    downloadProgress.value = 0.0;

    // Show Progress Dialog
    Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.cloud_download_rounded, color: Colors.blue),
              SizedBox(width: 10),
              Text(
                'Downloading PDF',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Obx(() {
            final percent = (downloadProgress.value * 100).toInt();
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(
                  value: downloadProgress.value,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 16),
                Text(
                  '$percent%',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Downloading ${pdfDocument.value?.title ?? "Document"}...',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            );
          }),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final sanitizedName = (pdfDocument.value?.title ?? 'document').replaceAll(
        RegExp(r'[^\w\s\.]'),
        '_',
      );
      final fileName =
          '${sanitizedName}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final savePath = '${Directory.systemTemp.path}/$fileName';

      final client = dio.Dio();
      await client.download(
        pdfUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            downloadProgress.value = received / total;
          }
        },
      );

      downloadProgress.value = 1.0;
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      isDownloading.value = false;

      CustomSnackBar.showSuccess(
        title: 'Download Complete',
        message:
            '${pdfDocument.value?.title ?? "PDF"} downloaded successfully (100%).',
      );

      // Open downloaded PDF in viewer preview
      _openDownloadedPdf(savePath);
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      isDownloading.value = false;
      printMessage("⚠️ Error downloading PDF: $e");
      CustomSnackBar.showError(
        title: 'Download Error',
        message: 'Failed to download PDF document: $e',
      );
    }
  }

  void _openDownloadedPdf(String filePath) {
    if (!File(filePath).existsSync()) return;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'PDF Downloaded',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Saved to: $filePath',
              textAlign: TextAlign.center,
              style: Get.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      effectivePdfUrl.value = filePath;
                    },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('View PDF'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void sharePdf() {
    final doc = pdfDocument.value;
    final title = doc?.title.isNotEmpty == true
        ? doc!.title
        : 'PBD Site Map / PDF Document';
    final category = doc?.category.isNotEmpty == true
        ? doc!.category
        : 'Real Estate';
    final description = doc?.description.isNotEmpty == true
        ? doc!.description
        : '';
    final pdfUrl = effectivePdfUrl.value.trim();

    final shareText =
        '''
📄 *PBD Real Estate - Site Map & Document*

📌 *Title*: $title
📂 *Category*: $category
${description.isNotEmpty ? '📝 *Description*: $description\n' : ''}
🔗 *Document Link*: $pdfUrl

Shared via PBD Group Application
''';

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Share Document',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Choose how you want to share "$title"',
              style: Get.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Share via WhatsApp
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat_bubble_rounded,
                  color: Colors.green,
                ),
              ),
              title: const Text(
                'Share via WhatsApp',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () async {
                Get.back();
                final whatsappUrl = Uri.parse(
                  "https://wa.me/?text=${Uri.encodeComponent(shareText)}",
                );
                if (await canLaunchUrl(whatsappUrl)) {
                  await launchUrl(
                    whatsappUrl,
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  CustomSnackBar.showError(
                    message: 'Could not launch WhatsApp.',
                  );
                }
              },
            ),

            // Share via Email
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.email_rounded, color: Colors.blue),
              ),
              title: const Text(
                'Share via Email',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () async {
                Get.back();
                final mailUrl = Uri.parse(
                  "mailto:?subject=${Uri.encodeComponent("PBD Document: $title")}&body=${Uri.encodeComponent(shareText)}",
                );
                if (await canLaunchUrl(mailUrl)) {
                  await launchUrl(
                    mailUrl,
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  CustomSnackBar.showError(
                    message: 'Could not launch Email client.',
                  );
                }
              },
            ),

            // Copy Link to Clipboard
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.copy_rounded, color: Colors.amber),
              ),
              title: const Text(
                'Copy Document Link',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Get.back();
                Clipboard.setData(ClipboardData(text: shareText));
                CustomSnackBar.showSuccess(
                  message: 'Document details and link copied to clipboard!',
                );
              },
            ),

            // Open Link in Browser
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.open_in_browser_rounded,
                  color: Colors.purple,
                ),
              ),
              title: const Text(
                'Open Link in Browser',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () async {
                Get.back();
                if (pdfUrl.isNotEmpty) {
                  final uri = Uri.parse(pdfUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
