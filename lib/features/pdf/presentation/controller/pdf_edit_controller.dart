import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../core/helper/logger_helper.dart';
import '../../../../core/network/api_services.dart';
import '../../../../core/network/pusher_service.dart';
import '../../model/annotation_model.dart';
import '../../model/pdf_document_model.dart';
import '../widgets/annotation_painter.dart';

enum AnnotationMode { view, draw, text, cross, erase }

class PdfEditController extends GetxController {
  final apiServices = Get.find<ApiServices>();

  final pdfDocument = Rxn<PdfDocumentModel>();
  final isFetchingDetails = false.obs;
  final isFetchingAnnotations = false.obs;

  late PdfViewerController pdfViewerController;

  // Page tracking
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final isLoaded = false.obs;

  // Zoom & Scale Tracking
  final zoomScale = 1.0.obs;

  void zoomIn() {
    if (zoomScale.value < 4.0) {
      zoomScale.value = double.parse(
        (zoomScale.value + 0.25).toStringAsFixed(2),
      );
      try {
        pdfViewerController.zoomLevel = zoomScale.value;
      } catch (_) {}
    }
  }

  void zoomOut() {
    if (zoomScale.value > 0.5) {
      zoomScale.value = double.parse(
        (zoomScale.value - 0.25).toStringAsFixed(2),
      );
      try {
        pdfViewerController.zoomLevel = zoomScale.value;
      } catch (_) {}
    }
  }

  void resetZoom() {
    zoomScale.value = 1.0;
    try {
      pdfViewerController.zoomLevel = 1.0;
    } catch (_) {}
  }

  void setZoomScale(double val) {
    if (val > 0) {
      zoomScale.value = double.parse(val.toStringAsFixed(2));
    }
  }

  Offset toPercentagePoint(Offset pixelPoint, Size renderSize) {
    if (renderSize.width <= 0 || renderSize.height <= 0) return pixelPoint;
    final pctX = double.parse(
      ((pixelPoint.dx / renderSize.width) * 100.0).toStringAsFixed(2),
    );
    final pctY = double.parse(
      ((pixelPoint.dy / renderSize.height) * 100.0).toStringAsFixed(2),
    );
    return Offset(pctX, pctY);
  }

  Offset toPixelPoint(Offset pctPoint, Size renderSize) {
    if (renderSize.width <= 0 || renderSize.height <= 0) return pctPoint;
    if (pctPoint.dx > 100.0 || pctPoint.dy > 100.0) return pctPoint;
    final px = (pctPoint.dx / 100.0) * renderSize.width;
    final py = (pctPoint.dy / 100.0) * renderSize.height;
    return Offset(px, py);
  }

  // Active Annotation Mode
  final activeMode = AnnotationMode.view.obs;

  // Drawing Customization
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
      if (args['pdf'] is PdfDocumentModel) {
        pdfDocument.value = args['pdf'] as PdfDocumentModel;
      }
      final uuid =
          args['uuid']?.toString() ??
          args['id']?.toString() ??
          args['pdf_uuid']?.toString() ??
          '';
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
      final response = await apiServices.callGetApi(
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
      printMessage("⚠️ Error fetching PDF details in PdfEditController: $e");
    } finally {
      isFetchingDetails.value = false;
    }
  }

  Future<void> fetchAnnotations(String pdfUuid) async {
    if (pdfUuid.isEmpty) return;
    isFetchingAnnotations.value = true;

    try {
      final endpoint = 'pdfs/$pdfUuid/annotations';
      final response = await apiServices.callGetApi(
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

              if (annotation.type == 'pencil' || annotation.type == 'draw') {
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

  // --- PUSHER REAL-TIME WEBSOCKET SUBSCRIPTION ---

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
        "📡 Handling Pusher Event in PdfEditController: ${event.eventName}",
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
      printMessage("⚠️ Error handling Pusher event in PdfEditController: $e");
    }
  }

  void _addOrUpdateSingleAnnotation(AnnotationModel annotation) {
    final pageNo = annotation.pageNumber;
    final payload = annotation.payload;

    if (annotation.type == 'pencil' || annotation.type == 'draw') {
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
      final response = await apiServices.callPostApi(
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
      final response = await apiServices.callPutApi(
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
      final response = await apiServices.callDeleteApi(
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
      final response = await apiServices.callPostApi(
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
      final response = await apiServices.callPostApi(
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
      final response = await apiServices.callPostApi(
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

  void startLine(Offset position, [Size renderSize = Size.zero]) {
    final pctPoint = renderSize != Size.zero
        ? toPercentagePoint(position, renderSize)
        : position;

    if (activeMode.value == AnnotationMode.draw) {
      currentLine.value = DrawnLine(
        points: [pctPoint],
        color: selectedColor.value,
        strokeWidth: selectedStrokeWidth.value,
        pageNumber: currentPage.value,
      );
    } else if (activeMode.value == AnnotationMode.erase) {
      eraseNear(position, renderSize);
    }
  }

  void updateLine(Offset position, [Size renderSize = Size.zero]) {
    final pctPoint = renderSize != Size.zero
        ? toPercentagePoint(position, renderSize)
        : position;

    if (activeMode.value == AnnotationMode.draw && currentLine.value != null) {
      final updatedPoints = List<Offset>.from(currentLine.value!.points)
        ..add(pctPoint);
      currentLine.value = DrawnLine(
        points: updatedPoints,
        color: selectedColor.value,
        strokeWidth: selectedStrokeWidth.value,
        pageNumber: currentPage.value,
      );
    } else if (activeMode.value == AnnotationMode.erase) {
      eraseNear(position, renderSize);
    }
  }

  Future<void> endLine() async {
    if (activeMode.value == AnnotationMode.draw && currentLine.value != null) {
      final newCompletedLine = currentLine.value!;
      lines.add(newCompletedLine);
      currentLine.value = null;

      final payload = AnnotationModel.createDrawPayload(
        newCompletedLine.points,
        newCompletedLine.color,
        newCompletedLine.strokeWidth,
      );
      final model = AnnotationModel(
        id: '',
        pdfId: pdfDocument.value?.id ?? '',
        pageNumber: currentPage.value,
        type: 'draw',
        scale: zoomScale.value,
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
  Future<void> addTextAnnotation(
    String text,
    Offset position, [
    Size renderSize = Size.zero,
  ]) async {
    if (text.trim().isEmpty) return;

    final pctPoint = renderSize != Size.zero
        ? toPercentagePoint(position, renderSize)
        : position;

    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final textAnn = TextAnnotation(
      id: tempId,
      position: pctPoint,
      text: text,
      color: selectedColor.value,
      fontSize: selectedFontSize.value,
      pageNumber: currentPage.value,
    );

    textAnnotations.add(textAnn);

    final payload = AnnotationModel.createTextPayload(
      text,
      pctPoint,
      selectedFontSize.value,
      selectedColor.value,
    );
    final model = AnnotationModel(
      id: '',
      pdfId: pdfDocument.value?.id ?? '',
      pageNumber: currentPage.value,
      type: 'text',
      scale: zoomScale.value,
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
  Future<void> addCrossAnnotation(
    Offset position, [
    Size renderSize = Size.zero,
  ]) async {
    final pctPoint = renderSize != Size.zero
        ? toPercentagePoint(position, renderSize)
        : position;

    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final crossAnn = CrossAnnotation(
      id: tempId,
      position: pctPoint,
      size: selectedCrossSize.value,
      color: selectedColor.value,
      pageNumber: currentPage.value,
    );

    crossAnnotations.add(crossAnn);

    final payload = AnnotationModel.createCrossPayload(
      pctPoint,
      selectedCrossSize.value,
      selectedColor.value,
    );
    final model = AnnotationModel(
      id: '',
      pdfId: pdfDocument.value?.id ?? '',
      pageNumber: currentPage.value,
      type: 'cross',
      scale: zoomScale.value,
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

  // Eraser Logic
  Future<void> eraseNear(Offset position, [Size renderSize = Size.zero]) async {
    const threshold = 25.0;
    final targetPage = currentPage.value;

    DrawnLine? lineToRemove;
    for (int i = lines.length - 1; i >= 0; i--) {
      final line = lines[i];
      if (line.pageNumber != targetPage && line.pageNumber > 0) continue;
      final hit = line.points.any((pt) {
        final pxPt = renderSize != Size.zero
            ? toPixelPoint(pt, renderSize)
            : pt;
        return (pxPt - position).distance <= threshold;
      });
      if (hit) {
        lineToRemove = line;
        break;
      }
    }

    if (lineToRemove != null) {
      lines.remove(lineToRemove);
      if (lineToRemove.id.isNotEmpty) {
        await deleteAnnotationApi(lineToRemove.id);
      }
      return;
    }

    TextAnnotation? textToRemove;
    for (int i = textAnnotations.length - 1; i >= 0; i--) {
      final textAnn = textAnnotations[i];
      if (textAnn.pageNumber != targetPage && textAnn.pageNumber > 0) continue;
      final pxPt = renderSize != Size.zero
          ? toPixelPoint(textAnn.position, renderSize)
          : textAnn.position;
      if ((pxPt - position).distance <= threshold) {
        textToRemove = textAnn;
        break;
      }
    }

    if (textToRemove != null) {
      textAnnotations.remove(textToRemove);
      if (textToRemove.id.isNotEmpty) {
        await deleteAnnotationApi(textToRemove.id);
      }
      return;
    }

    CrossAnnotation? crossToRemove;
    for (int i = crossAnnotations.length - 1; i >= 0; i--) {
      final crossAnn = crossAnnotations[i];
      if (crossAnn.pageNumber != targetPage && crossAnn.pageNumber > 0) {
        continue;
      }
      final pxPt = renderSize != Size.zero
          ? toPixelPoint(crossAnn.position, renderSize)
          : crossAnn.position;
      if ((pxPt - position).distance <= threshold) {
        crossToRemove = crossAnn;
        break;
      }
    }

    if (crossToRemove != null) {
      crossAnnotations.remove(crossToRemove);
      if (crossToRemove.id.isNotEmpty) {
        await deleteAnnotationApi(crossToRemove.id);
      }
    }
  }

  // Clear All Annotations for Current Page
  Future<void> clearAllAnnotations() async {
    final pageNo = currentPage.value;
    lines.removeWhere((l) => l.pageNumber == pageNo);
    textAnnotations.removeWhere((t) => t.pageNumber == pageNo);
    crossAnnotations.removeWhere((c) => c.pageNumber == pageNo);
    currentLine.value = null;

    await clearPageAnnotationsApi(pageNo);
  }

  // Undo Last Action
  Future<void> undo() async {
    final targetPage = currentPage.value;
    if (lines.any((l) => l.pageNumber == targetPage)) {
      final lastLine = lines.lastWhere((l) => l.pageNumber == targetPage);
      lines.remove(lastLine);
      redoStack.add({'type': 'line', 'item': lastLine});
      if (lastLine.id.isNotEmpty) {
        await undoAnnotationApi(lastLine.id);
      }
    } else if (textAnnotations.any((t) => t.pageNumber == targetPage)) {
      final lastText = textAnnotations.lastWhere(
        (t) => t.pageNumber == targetPage,
      );
      textAnnotations.remove(lastText);
      redoStack.add({'type': 'text', 'item': lastText});
      if (lastText.id.isNotEmpty) {
        await undoAnnotationApi(lastText.id);
      }
    } else if (crossAnnotations.any((c) => c.pageNumber == targetPage)) {
      final lastCross = crossAnnotations.lastWhere(
        (c) => c.pageNumber == targetPage,
      );
      crossAnnotations.remove(lastCross);
      redoStack.add({'type': 'cross', 'item': lastCross});
      if (lastCross.id.isNotEmpty) {
        await undoAnnotationApi(lastCross.id);
      }
    }
  }

  // Redo Last Action
  Future<void> redo() async {
    if (redoStack.isNotEmpty) {
      final lastAction = redoStack.removeLast();
      final type = lastAction['type'];
      final item = lastAction['item'];

      if (type == 'line' && item is DrawnLine) {
        lines.add(item);
        if (item.id.isNotEmpty) {
          await redoAnnotationApi(item.id);
        }
      } else if (type == 'text' && item is TextAnnotation) {
        textAnnotations.add(item);
        if (item.id.isNotEmpty) {
          await redoAnnotationApi(item.id);
        }
      } else if (type == 'cross' && item is CrossAnnotation) {
        crossAnnotations.add(item);
        if (item.id.isNotEmpty) {
          await redoAnnotationApi(item.id);
        }
      }
    }
  }
}
