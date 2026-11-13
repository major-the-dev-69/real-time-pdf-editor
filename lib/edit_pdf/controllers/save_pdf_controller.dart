// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'annotation_controller.dart';
import 'drawing_controller.dart';
import 'highlight_controller.dart';
import 'image_controller.dart';
import 'save_pdf_second_thread.dart';
import 'text_box_controller.dart';
import 'underline_controller.dart';

/// A controller responsible for handling all save and manipulation
/// operations on a PDF, including drawing, annotations, text boxes,
/// images, adding/removing pages, and saving the final document.
class SavePdfController extends ChangeNotifier {
  /// Tracks whether a save operation is currently in progress.
  bool isSaving = false;
  ValueNotifier<int> pages = ValueNotifier<int>(0);

  /// Saves the current edits (drawings, images, annotations, and text boxes)
  /// to a new PDF file with memory optimization.
  Future<void> saveDrawing({
    required File pdfFile,
    required int totalPages,
    required BuildContext context,
    required DrawingController drawingController,
    required ImageController imageController,
    required TextBoxController textBoxController,
    required HighlightController highlightController,
    required UnderlineController underlineController,
    required Function refresh,
  }) async {
    if (isSaving) return;

    isSaving = true;
    PdfDocument? pdfDoc;

    try {
      // Early exit if nothing to save
      if (!(drawingController.hasAnyContent() ||
          imageController.hasAnyContent() ||
          textBoxController.hasAnyContent() ||
          highlightController.hasAnyContent() ||
          underlineController.hasAnyContent())) {
        return Navigator.pop(context, pdfFile);
      }

      final output = await getTemporaryDirectory();
      final String originalName = pdfFile.path.split('/').last.split('.').first;
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String savedPath = '${output.path}/${originalName}_$timestamp.pdf';
      final file = File(savedPath);

      // Copy the original file as base
      await pdfFile.copy(savedPath);

      const int batchSize = 5;

      for (
        int batchStart = 0;
        batchStart < totalPages;
        batchStart += batchSize
      ) {
        // final fileBytes = await readFileInChunks(file);
        pdfDoc ??= await Isolate.run(() async {
          return await processPdfDocViaUt(file);
        });

        final int batchEnd = (batchStart + batchSize > totalPages)
            ? totalPages
            : batchStart + batchSize;

        dev.log('Processing batch: pages ${batchStart + 1} to $batchEnd');

        /// ✅ Only proceed if something changed
        final bool batchModified = await _processPageBatch(
          pdfDoc!,
          batchStart,
          batchEnd,
          context,
          drawingController,
          imageController,
          textBoxController,
          highlightController,
          underlineController,
        );

        if (batchModified) {
          // Save only if something was added/changed
          await Isolate.run(() async {
            await savePdfDocToFile(pdfDoc!, file);
          });
          pdfDoc.dispose();
          pdfDoc = null;
          dev.log("Batch ${batchStart + 1}–$batchEnd saved");
        } else {
          dev.log("Batch ${batchStart + 1}–$batchEnd skipped (no changes)");
        }
        // Allow UI to refresh
        await Future.delayed(const Duration(milliseconds: 50));
      }
      if (pdfDoc != null) {
        await Isolate.run(() async {
          await savePdfDocToFile(pdfDoc!, file);
        });
      }
      dev.log('All pages processed, PDF saved at $savedPath');
      Navigator.pop(context, file);
    } catch (e) {
      debugPrint('Error while saving drawing and text: $e');
      rethrow;
    } finally {
      pdfDoc?.dispose();
      pdfDoc = null;
      isSaving = false;
    }
  }

  /// Processes a batch of pages to reduce memory usage
  Future<bool> _processPageBatch(
    PdfDocument pdfDoc,
    int batchStart,
    int batchEnd,
    BuildContext context,
    DrawingController drawingController,
    ImageController imageController,
    TextBoxController textBoxController,
    HighlightController highlightController,
    UnderlineController underlineController,
  ) async {
    bool modified = false;

    for (int i = batchStart; i < batchEnd; i++) {
      pages.value = i + 1;
      notifyListeners();
      drawingController.setPage(i + 1);
      final hasDrawings =
          (drawingController.getAllDrawing()[i + 1]?.isNotEmpty ?? false);
      final hasImages =
          (imageController.getAllImageBoxes()[i + 1]?.isNotEmpty ?? false);
      final hasText =
          (textBoxController.getAllTextBoxes()[i + 1]?.isNotEmpty ?? false);
      final hasHighlight =
          (highlightController.getHighlightHistory[i + 1]?.isNotEmpty ?? false);
      final hasUnderline =
          (underlineController.getUnderlineHistory[i + 1]?.isNotEmpty ?? false);

      if (!(hasDrawings ||
          hasImages ||
          hasText ||
          hasHighlight ||
          hasUnderline)) {
        continue;
      }
      modified = true;
      PdfPage page = pdfDoc.pages[i];

      dev.log('Processing page ${i + 1}');
      await Future.delayed(const Duration(milliseconds: 50));

      // Process annotations
      if (hasUnderline || hasHighlight) {
        await _processAnnotations(
          page,
          i,
          highlightController,
          underlineController,
        );
      }

      await Future.delayed(const Duration(milliseconds: 50));

      // Process images
      if (hasImages) {
        await _processImages(page, i, context, imageController);
      }

      // Process drawings
      if (hasDrawings) {
        await _processDrawings(page, drawingController);
      }

      // Process text boxes
      if (hasText) {
        await _processTextBoxes(page, i, context, textBoxController);
      }
    }
    return modified;
  }

  /// Process highlight and underline annotations
  Future<void> _processAnnotations(
    PdfPage page,
    int pageIndex,
    HighlightController highlightController,
    UnderlineController underlineController,
  ) async {
    // Add highlight annotations
    final highlightActions =
        highlightController.getHighlightHistory[pageIndex + 1];
    if (highlightActions != null) {
      for (AnnotationAction action in highlightActions) {
        if (action.isAdd) {
          for (int j = 0; j < action.pdfAnnotation.length; j++) {
            page.annotations.add(action.pdfAnnotation[j]);
          }
        }
      }
    }

    // Add underline annotations
    final underlineActions =
        underlineController.getUnderlineHistory[pageIndex + 1];
    if (underlineActions != null) {
      for (AnnotationAction action in underlineActions) {
        if (action.isAdd) {
          for (int j = 0; j < action.pdfAnnotation.length; j++) {
            dev.log("Adding underline annotation on page ${pageIndex + 1}");
            page.annotations.add(action.pdfAnnotation[j]);
          }
        }
      }
    }
  }

  /// Process images with memory optimization
  Future<void> _processImages(
    PdfPage page,
    int pageIndex,
    BuildContext context,
    ImageController imageController,
  ) async {
    final imageBoxes = imageController.getAllImageBoxes()[pageIndex + 1];
    if (imageBoxes == null) return;

    for (var imageBox in imageBoxes) {
      try {
        dev.log(
          "Adding image on page ${pageIndex + 1} at position ${imageBox.position}",
        );

        // Convert image with optimization
        final imgData = await _convertImageToUint8ListOptimized(imageBox.image);

        final PdfImage pdfImage = await Isolate.run(() async {
          return await processDrawingsIsolate(imgData);
        });

        final double scaleFactorX =
            page.getClientSize().width / MediaQuery.of(context).size.width;
        final double scaleFactorY =
            page.getClientSize().height /
            (MediaQuery.of(context).size.width * 1.414);

        double scaledX = imageBox.position.dx * scaleFactorX;
        double scaledY = imageBox.position.dy * scaleFactorY;
        double scaledWidth = imageBox.width * scaleFactorX;
        double scaledHeight = imageBox.height * scaleFactorY;

        page.graphics.save();
        page.graphics.translateTransform(
          scaledX + scaledWidth / 2,
          scaledY + scaledHeight / 2,
        );
        page.graphics.rotateTransform(imageBox.rotation * (180 / pi));

        page.graphics.drawImage(
          pdfImage,
          Rect.fromLTWH(
            (-scaledWidth / 2) + 14,
            (-scaledHeight / 2) + 14,
            scaledWidth,
            scaledHeight,
          ),
        );

        page.graphics.restore();
        dev.log('Image drawing completed on page ${pageIndex + 1}');

        // Allow garbage collection
        await Future.delayed(Duration.zero);
      } catch (e) {
        dev.log('Error processing image on page ${pageIndex + 1}: $e');
      }
    }
  }

  /// Process drawings
  Future<void> _processDrawings(
    PdfPage page,
    DrawingController drawingController,
  ) async {
    try {
      ByteData? imageData = await drawingController.getImageData();
      if (imageData != null) {
        var imageBytes = imageData.buffer.asUint8List();
        final PdfImage image = await Isolate.run(() async {
          return await processDrawingsIsolate(imageBytes);
        });
        final double pageWidth = page.getClientSize().width;
        final double pageHeight = page.getClientSize().height;

        page.graphics.drawImage(
          image,
          Rect.fromLTWH(0, 0, pageWidth, pageHeight),
        );

        imageData = null;
      }
    } catch (e) {
      dev.log('Error processing drawing: $e');
    }
  }

  /// Process text boxes
  Future<void> _processTextBoxes(
    PdfPage page,
    int pageIndex,
    BuildContext context,
    TextBoxController textBoxController,
  ) async {
    final textBoxes = textBoxController.getAllTextBoxes()[pageIndex + 1];
    if (textBoxes == null) return;

    for (TextBox textBox in textBoxes) {
      dev.log('Processing text box on page ${pageIndex + 1}');

      final double scaleFactorX =
          page.getClientSize().width / MediaQuery.of(context).size.width;
      final double scaleFactorY =
          page.getClientSize().height /
          (MediaQuery.of(context).size.width * 1.414);

      double scaledX = textBox.position.dx * scaleFactorX;
      double scaledY = textBox.position.dy * scaleFactorY;
      double scaledWidth = textBox.width * scaleFactorX;
      double scaledHeight = textBox.height * scaleFactorY;

      page.graphics.drawString(
        textBox.text,
        PdfStandardFont(PdfFontFamily.helvetica, textBox.fontSize),
        brush: PdfSolidBrush(
          PdfColor(
            textBox.color?.red ?? 0,
            textBox.color?.green ?? 0,
            textBox.color?.blue ?? 0,
          ),
        ),
        bounds: Rect.fromLTWH(
          scaledX + 10,
          scaledY + 10,
          scaledWidth,
          scaledHeight,
        ),
        format: PdfStringFormat(
          alignment: PdfTextAlignment.center,
          lineAlignment: PdfVerticalAlignment.middle,
        ),
      );
    }
  }

  /// Optimized image conversion with compression
  Future<Uint8List> _convertImageToUint8ListOptimized(ui.Image image) async {
    try {
      // Try PNG first, but with compression
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData != null) {
        final imageData = byteData.buffer.asUint8List();

        // If image is too large, we might want to compress it further
        if (imageData.length > 5 * 1024 * 1024) {
          // 5MB threshold
          dev.log(
            'Large image detected (${imageData.length} bytes), consider compression',
          );
        }

        return imageData;
      }
    } catch (e) {
      dev.log('Error converting image to PNG: $e');
    }

    // Fallback to raw RGBA if PNG fails
    final ByteData? rawData = await image.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    return rawData?.buffer.asUint8List() ?? Uint8List(0);
  }

  /// Save document with streaming to reduce memory usage
  Future<void> _saveDocumentWithStreaming(PdfDocument pdfDoc, File file) async {
    try {
      dev.log('1');
      // Get the document bytes
      final List<int> bytes = await pdfDoc.save();
      dev.log('2');
      // Write in chunks to avoid memory spike
      final IOSink sink = file.openWrite();
      dev.log('3');
      const int chunkSize = 64 * 1024; // 64KB chunks
      for (int i = 0; i < bytes.length; i += chunkSize) {
        final int end = (i + chunkSize < bytes.length)
            ? i + chunkSize
            : bytes.length;
        sink.add(bytes.sublist(i, end));

        // Yield control periodically
        if (i % (chunkSize * 10) == 0) {
          await Future.delayed(Duration.zero);
        }
      }
      dev.log('4');
      await sink.flush();
      await sink.close();
    } catch (e) {
      dev.log('Error in streaming save: $e');
      rethrow;
    }
  }

  /// Adds a blank page at the given [pageIndex] in the PDF.
  Future<File?> addBlankPageAt(int pageIndex, File pdfFile) async {
    PdfDocument? pdfDoc;
    try {
      pdfDoc = PdfDocument(inputBytes: await readFileInChunks(pdfFile));

      if (pageIndex < 0 || pageIndex > pdfDoc.pages.count) {
        debugPrint('Invalid page index: $pageIndex');
        return null;
      }

      final Size pageSize = Size(
        pdfDoc.pages[0].getClientSize().width,
        pdfDoc.pages[0].getClientSize().height,
      );

      pdfDoc.pages.insert(pageIndex, pageSize);

      return await saveFile(
        pdfDoc: pdfDoc,
        addTimestap: false,
        pdfFile: pdfFile,
      );
    } finally {
      pdfDoc?.dispose();
    }
  }

  /// Removes the page at [currentPage] (1-based index) from the PDF.
  Future<File?> removePage(int currentPage, File pdfFile) async {
    PdfDocument? pdfDoc;
    try {
      pdfDoc = PdfDocument(inputBytes: await readFileInChunks(pdfFile));

      if (pdfDoc.pages.count > 1) {
        pdfDoc.pages.removeAt(currentPage - 1);
        return await saveFile(pdfDoc: pdfDoc, pdfFile: pdfFile);
      }
      return null;
    } finally {
      pdfDoc?.dispose();
    }
  }

  /// Saves the modified [pdfDoc] either with or without a timestamp.
  Future<File?> saveFile({
    bool addTimestap = false,
    required File pdfFile,
    required PdfDocument pdfDoc,
  }) async {
    try {
      final output = await getTemporaryDirectory();
      final String originalName = pdfFile.path.split('/').last.split('.').first;

      String savedPath = "";
      if (addTimestap) {
        final String timestamp = DateTime.now().millisecondsSinceEpoch
            .toString();
        savedPath = '${output.path}/${originalName}_$timestamp.pdf';
      } else {
        savedPath = '${output.path}/$originalName.pdf';
      }

      final file = File(savedPath);

      // Use streaming save method
      await _saveDocumentWithStreaming(pdfDoc, file);
      return file;
    } catch (e) {
      dev.log('Error saving file: $e');
      rethrow;
    } finally {
      pdfDoc.dispose();
    }
  }
}
