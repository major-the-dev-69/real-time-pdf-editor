// // ignore_for_file: use_build_context_synchronously, deprecated_member_use

// import 'dart:io';
// import 'dart:isolate';
// import 'dart:math';
// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';
// import 'package:nextgen_pdf_editor/controllers/annotation_controller.dart';
// import 'package:nextgen_pdf_editor/controllers/drawing_controller.dart';
// import 'package:nextgen_pdf_editor/controllers/highlight_controller.dart';
// import 'package:nextgen_pdf_editor/controllers/image_controller.dart';
// import 'package:nextgen_pdf_editor/controllers/text_box_controller.dart';
// import 'package:nextgen_pdf_editor/controllers/underline_controller.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:syncfusion_flutter_pdf/pdf.dart';

// /// A controller responsible for handling all save and manipulation
// /// operations on a PDF, including drawing, annotations, text boxes,
// /// images, adding/removing pages, and saving the final document.
// class SavePdfController extends ChangeNotifier {
//   /// Tracks whether a save operation is currently in progress.
//   bool isSaving = false;

//   /// Saves the current edits (drawings, images, annotations, and text boxes)
//   /// to a new PDF file.
//   ///
//   /// [pdfFile] - the original PDF file,
//   /// [totalPages] - number of pages in the document,
//   /// [context] - BuildContext for getting MediaQuery,
//   /// [drawingController], [imageController], [textBoxController],
//   /// [highlightController], [underlineController] - various controllers
//   /// managing different edit types,
//   /// [refresh] - callback to refresh UI if needed.
//   Future<void> saveDrawing({
//     required File pdfFile,
//     required int totalPages,
//     required BuildContext context,
//     required DrawingController drawingController,
//     required ImageController imageController,
//     required TextBoxController textBoxController,
//     required HighlightController highlightController,
//     required UnderlineController underlineController,
//     required Function refresh,
//   }) async {
//     if (isSaving) return;

//     isSaving = true;

//     try {
//       final screenWidth = MediaQuery.of(context).size.width;

//       if (!(drawingController.hasAnyContent() ||
//           imageController.hasAnyContent() ||
//           textBoxController.hasAnyContent() ||
//           highlightController.hasAnyContent() ||
//           underlineController.hasAnyContent())) {
//         return Navigator.pop(context, pdfFile);
//       }

//       final originalPdfBytes = await pdfFile.readAsBytes();

//       final List<PageEditDto> edits = [];

//       for (int i = 0; i < totalPages; i++) {
//         final pageIndex = i + 1;
//         // Check if page has any edits at all
//         final hasDrawings =
//             (drawingController.getAllDrawing()[pageIndex]?.isNotEmpty ?? false);
//         final hasImages =
//             (imageController.getAllImageBoxes()[pageIndex]?.isNotEmpty ??
//                 false);
//         final hasText =
//             (textBoxController.getAllTextBoxes()[pageIndex]?.isNotEmpty ??
//                 false);
//         final hasHighlight =
//             (highlightController.getHighlightHistory[pageIndex]?.isNotEmpty ??
//                 false);
//         final hasUnderline =
//             (underlineController.getUnderlineHistory[pageIndex]?.isNotEmpty ??
//                 false);

//         if (!(hasDrawings ||
//             hasImages ||
//             hasText ||
//             hasHighlight ||
//             hasUnderline)) {
//           // Skip page with no edits
//           continue;
//         }

//         drawingController.setPage(pageIndex);
//         await Future.delayed(const Duration(milliseconds: 50));
//         final List<ImageBoxDto> imageDtos = [];

//         for (final img in imageController.getAllImageBoxes()[pageIndex] ?? []) {
//           final bytes = await _convertImageToUint8List(img.image);
//           imageDtos.add(
//             ImageBoxDto(
//               imageBytes: bytes,
//               position: img.position,
//               width: img.width,
//               height: img.height,
//               rotation: img.rotation,
//             ),
//           );
//         }

//         final textBoxes = textBoxController.getAllTextBoxes()[pageIndex] ?? [];

//         var drawingData = await drawingController.getImageData();

//         edits.add(
//           PageEditDto(
//             pageIndex: i,
//             highlight: highlightController.getHighlightHistory[pageIndex] ?? [],
//             underline: underlineController.getUnderlineHistory[pageIndex] ?? [],
//             drawingBytes: drawingData?.buffer.asUint8List(),
//             images: imageDtos,
//             textBoxes: textBoxes,
//           ),
//         );
//         drawingData = null;
//       }

//       final PdfDocument updatedPdf = await Isolate.run(() async {
//         return await processAndSavePdf(
//           originalPdfBytes: originalPdfBytes,
//           edits: edits,
//           screenWidth: screenWidth,
//         );
//       });

//       // final output = await getTemporaryDirectory();
//       // final savedPath =
//       //     '${output.path}/${pdfFile.path.split('/').last.split('.').first}_${DateTime.now().millisecondsSinceEpoch}.pdf';

//       // final newFile = await File(savedPath).writeAsBytes(updatedPdf);
//       // print("abbssss");
//       // var f = await updatedPdf.save();
//       // print("after saveSync: ${f}");
//       // log.log(f.toString());
//       // await pdfFile.writeAsBytes(f);
//       // print("aBCC");
//       // pdfFile.writeAsBytes(f);

//       var filee = await saveLargePdf(updatedPdf, pdfFile.path.split('/').last);

//       Navigator.pop(context, filee);
//     } catch (e) {
//       debugPrint("❌ Error in saveDrawing: $e");
//     } finally {
//       isSaving = false;
//     }
//   }

//   Future<File> saveLargePdf(PdfDocument document, String filename) async {
//     final dir = await getApplicationDocumentsDirectory();
//     final file = File('${dir.path}/$filename');

//     // Save to bytes
//     final List<int> bytes = document.saveSync();
//     document.dispose();

//     // Write in chunks to reduce memory spike
//     final sink = file.openWrite();
//     const chunkSize = 1024 * 1024; // 1 MB
//     for (var i = 0; i < bytes.length; i += chunkSize) {
//       final end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
//       sink.add(bytes.sublist(i, end));
//       await sink.flush();
//     }
//     await sink.close();

//     return file;
//   }

//   /// Converts a [ui.Image] into a [Uint8List] for PDF embedding.
//   Future<Uint8List> _convertImageToUint8List(ui.Image image) async {
//     final ByteData? byteData = await image.toByteData(
//       format: ui.ImageByteFormat.png,
//     );
//     return byteData!.buffer.asUint8List();
//   }

//   /// Adds a blank page at the given [pageIndex] in the PDF.
//   ///
//   /// Returns the updated file if successful, or null otherwise.
//   Future<File?> addBlankPageAt(int pageIndex, File pdfFile) async {
//     final pdfDoc = PdfDocument(inputBytes: await pdfFile.readAsBytes());
//     if (pageIndex < 0 || pageIndex > pdfDoc.pages.count) {
//       debugPrint('Invalid page index: $pageIndex');
//       return null;
//     }

//     final Size pageSize = Size(
//       pdfDoc.pages[0].getClientSize().width,
//       pdfDoc.pages[0].getClientSize().height,
//     );

//     pdfDoc.pages.insert(pageIndex, pageSize);

//     return await saveFile(pdfDoc: pdfDoc, addTimestap: false, pdfFile: pdfFile);
//   }

//   /// Removes the page at [currentPage] (1-based index) from the PDF.
//   ///
//   /// Returns the updated file if successful, or null otherwise.
//   Future<File?> removePage(int currentPage, File pdfFile) async {
//     final PdfDocument pdfDoc = PdfDocument(
//       inputBytes: await pdfFile.readAsBytes(),
//     );

//     if (pdfDoc.pages.count > 1) {
//       pdfDoc.pages.removeAt(currentPage - 1);

//       return await saveFile(pdfDoc: pdfDoc, pdfFile: pdfFile);
//     }
//     return null;
//   }

//   /// Saves the modified [pdfDoc] either with or without a timestamp.
//   ///
//   /// [addTimestap] decides whether to append a timestamp to the filename.
//   Future<File?> saveFile({
//     bool addTimestap = false,
//     required File pdfFile,
//     required PdfDocument pdfDoc,
//   }) async {
//     final output = await getTemporaryDirectory();
//     final String originalName = pdfFile.path.split('/').last.split('.').first;

//     String savedPath = "";
//     if (addTimestap) {
//       final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
//       savedPath = '${output.path}/${originalName}_$timestamp.pdf';
//     } else {
//       savedPath = '${output.path}/$originalName.pdf';
//     }

//     final file = File(savedPath);

//     await file.writeAsBytes(await pdfDoc.save());
//     return file;
//   }
// }

// class ImageBoxDto {
//   final Uint8List imageBytes;
//   final Offset position;
//   final double width;
//   final double height;
//   final double rotation;

//   ImageBoxDto({
//     required this.imageBytes,
//     required this.position,
//     required this.width,
//     required this.height,
//     required this.rotation,
//   });
// }

// class PageEditDto {
//   final int pageIndex;
//   final List<AnnotationAction> highlight;
//   final List<AnnotationAction> underline;
//   final List<TextBox> textBoxes;
//   final List<ImageBoxDto> images;
//   final Uint8List? drawingBytes;

//   PageEditDto({
//     required this.pageIndex,
//     required this.highlight,
//     required this.underline,
//     required this.textBoxes,
//     required this.images,
//     this.drawingBytes,
//   });
// }

// Future<PdfDocument> processAndSavePdf({
//   required Uint8List originalPdfBytes,
//   required List<PageEditDto> edits,
//   required double screenWidth,
// }) async {
//   final PdfDocument pdfDoc = PdfDocument(inputBytes: originalPdfBytes);

//   for (final edit in edits) {
//     final page = pdfDoc.pages[edit.pageIndex];
//     final width = page.getClientSize().width;
//     final height = page.getClientSize().height;

//     final scaleX = width / screenWidth;
//     final scaleY = height / (screenWidth * 1.414);

//     for (final action in edit.highlight) {
//       if (action.isAdd) {
//         for (final ann in action.pdfAnnotation) {
//           page.annotations.add(ann);
//         }
//       }
//     }

//     for (final action in edit.underline) {
//       if (action.isAdd) {
//         for (final ann in action.pdfAnnotation) {
//           page.annotations.add(ann);
//         }
//       }
//     }

//     for (final image in edit.images) {
//       final pdfImage = PdfBitmap(image.imageBytes);

//       final dx = image.position.dx * scaleX;
//       final dy = image.position.dy * scaleY;
//       final w = image.width * scaleX;
//       final h = image.height * scaleY;

//       page.graphics.save();
//       page.graphics.translateTransform(dx + w / 2, dy + h / 2);
//       page.graphics.rotateTransform(image.rotation * (180 / pi));
//       page.graphics.drawImage(
//         pdfImage,
//         Rect.fromLTWH(-w / 2 + 14, -h / 2 + 14, w, h),
//       );
//       page.graphics.restore();
//     }

//     if (edit.drawingBytes != null) {
//       final image = PdfBitmap(edit.drawingBytes!);
//       page.graphics.drawImage(image, Rect.fromLTWH(0, 0, width, height));
//     }

//     for (final box in edit.textBoxes) {
//       final dx = box.position.dx * scaleX;
//       final dy = box.position.dy * scaleY;
//       final w = box.width * scaleX;
//       final h = box.height * scaleY;

//       final font = PdfStandardFont(PdfFontFamily.helvetica, box.fontSize);
//       final brush = PdfSolidBrush(
//         PdfColor(
//           box.color?.red ?? 0,
//           box.color?.green ?? 0,
//           box.color?.blue ?? 0,
//         ),
//       );

//       page.graphics.drawString(
//         box.text,
//         font,
//         brush: brush,
//         bounds: Rect.fromLTWH(dx + 10, dy + 10, w, h),
//         format: PdfStringFormat(
//           alignment: PdfTextAlignment.center,
//           lineAlignment: PdfVerticalAlignment.middle,
//         ),
//       );
//     }
//   }

//   // final result = await pdfDoc.save();
//   // pdfDoc.dispose();
//   // return Uint8List.fromList(result);
//   return pdfDoc;
// }





//   // Future<void> saveDrawing({
//   //   required File pdfFile,
//   //   required int totalPages,
//   //   required BuildContext context,
//   //   required DrawingController drawingController,
//   //   required ImageController imageController,
//   //   required TextBoxController textBoxController,
//   //   required HighlightController highlightController,
//   //   required UnderlineController underlineController,
//   //   required Function refresh,
//   // }) async {
//   //   try {
//   //     if (!(drawingController.hasAnyContent() ||
//   //         imageController.hasAnyContent() ||
//   //         textBoxController.hasAnyContent() ||
//   //         highlightController.hasAnyContent() ||
//   //         underlineController.hasAnyContent())) {
//   //       return Navigator.pop(context, pdfFile);
//   //     }

//   //     final reader = PdfDocument(inputBytes: await pdfFile.readAsBytes());

//   //     final output = await getTemporaryDirectory();
//   //     final String originalName = pdfFile.path.split('/').last.split('.').first;
//   //     final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
//   //     final String savedPath = '${output.path}/${originalName}_$timestamp.pdf';
//   //     // final file = File(savedPath);

//   //     // Create final merged document
//   //     final finalDoc = PdfDocument();

//   //     for (int i = 0; i < totalPages; i++) {
//   //       dev.log('Processing page ${i + 1} of $totalPages');
//   //       drawingController.setPage(i + 1);
//   //       // GC hint
//   //       final page = reader.pages[i];

//   //       var finalpf = await _applyEditsToPage(
//   //         pdfDoc: reader,
//   //         page: page,
//   //         i: i,
//   //         context: context,
//   //         drawingController: drawingController,
//   //         imageController: imageController,
//   //         textBoxController: textBoxController,
//   //         highlightController: highlightController,
//   //         underlineController: underlineController,
//   //       );

//   //       // Append to output and clear memory
//   //       finalDoc.pages.add().graphics.drawPdfTemplate(
//   //         finalpf.createTemplate(),
//   //         Offset.zero,
//   //       );
//   //     }

//   //     // Save final document
//   //     final outputFile = File(savedPath);
//   //     await outputFile.writeAsBytes(await finalDoc.save());
//   //     finalDoc.dispose();

//   //     OpenFile.open(outputFile.path);
//   //   } catch (e) {
//   //     debugPrint('Error while saving drawing and text: $e');
//   //   } finally {
//   //     isSaving = false; // End loading
//   //     refresh();
//   //   }
//   // }

//   // Future<PdfPage> _applyEditsToPage({
//   //   required PdfDocument pdfDoc,
//   //   required PdfPage page,
//   //   required int i,
//   //   required BuildContext context,
//   //   required DrawingController drawingController,
//   //   required ImageController imageController,
//   //   required TextBoxController textBoxController,
//   //   required HighlightController highlightController,
//   //   required UnderlineController underlineController,
//   // }) async {
//   //   final hasDrawings =
//   //       (drawingController.getAllDrawing()[i + 1]?.isNotEmpty ?? false);
//   //   final hasImages =
//   //       (imageController.getAllImageBoxes()[i + 1]?.isNotEmpty ?? false);
//   //   final hasText =
//   //       (textBoxController.getAllTextBoxes()[i + 1]?.isNotEmpty ?? false);
//   //   final hasHighlight =
//   //       (highlightController.getHighlightHistory[i + 1]?.isNotEmpty ?? false);
//   //   final hasUnderline =
//   //       (underlineController.getUnderlineHistory[i + 1]?.isNotEmpty ?? false);

//   //   if (!(hasDrawings ||
//   //       hasImages ||
//   //       hasText ||
//   //       hasHighlight ||
//   //       hasUnderline)) {
//   //     // Skip page with no edits
//   //     return page;
//   //   }

//   //   // Allow time for page switch to complete
//   //   await Future.delayed(const Duration(milliseconds: 100));

//   //   // --- Add highlight annotations ---
//   //   if (hasHighlight) {
//   //     for (AnnotationAction action
//   //         in highlightController.getHighlightHistory[i + 1] ?? []) {
//   //       if (action.isAdd) {
//   //         for (int j = 0; j < action.pdfAnnotation.length; j++) {
//   //           if (i < pdfDoc.pages.count) {
//   //             pdfDoc.pages[i].annotations.add(action.pdfAnnotation[j]);
//   //           }
//   //         }
//   //       }
//   //     }
//   //   }

//   //   // --- Add underline annotations ---
//   //   if (hasUnderline) {
//   //     for (AnnotationAction action
//   //         in underlineController.getUnderlineHistory[i + 1] ?? []) {
//   //       if (action.isAdd) {
//   //         for (int j = 0; j < action.pdfAnnotation.length; j++) {
//   //           dev.log("Adding underline annotation on page ${i + 1}");
//   //           if (i < pdfDoc.pages.count) {
//   //             pdfDoc.pages[i].annotations.add(action.pdfAnnotation[j]);
//   //           }
//   //         }
//   //       }
//   //     }
//   //   }

//   //   // --- Add images onto PDF page ---
//   //   if (hasImages) {
//   //     for (var imageBox in imageController.getAllImageBoxes()[i + 1] ?? []) {
//   //       dev.log(
//   //         "Adding image on page ${i + 1} at position ${imageBox.position}",
//   //       );
//   //       final imgData = await _convertImageToUint8List(imageBox.image);
//   //       final PdfImage pdfImage = PdfBitmap(imgData);

//   //       final double scaleFactorX =
//   //           page.getClientSize().width / MediaQuery.of(context).size.width;
//   //       final double scaleFactorY =
//   //           page.getClientSize().height /
//   //           (MediaQuery.of(context).size.width * 1.414);

//   //       double scaledX = imageBox.position.dx * scaleFactorX;
//   //       double scaledY = imageBox.position.dy * scaleFactorY;
//   //       double scaledWidth = imageBox.width * scaleFactorX;
//   //       double scaledHeight = imageBox.height * scaleFactorY;

//   //       // Save the current graphics state before transformations
//   //       page.graphics.save();

//   //       // Apply rotation and translation
//   //       page.graphics.translateTransform(
//   //         scaledX + scaledWidth / 2,
//   //         scaledY + scaledHeight / 2,
//   //       );
//   //       page.graphics.rotateTransform(imageBox.rotation * (180 / pi));

//   //       // Draw the image
//   //       page.graphics.drawImage(
//   //         pdfImage,
//   //         Rect.fromLTWH(
//   //           (-scaledWidth / 2) + 14,
//   //           (-scaledHeight / 2) + 14,
//   //           scaledWidth,
//   //           scaledHeight,
//   //         ),
//   //       );
//   //       dev.log('ending image drawing on page ${i + 1}');
//   //       // Restore the graphics state
//   //       page.graphics.restore();
//   //     }
//   //   }

//   //   // --- Add freehand drawing on the PDF page ---
//   //   if (hasDrawings) {
//   //     ByteData? imageData = await drawingController.getImageData();
//   //     if (imageData != null) {
//   //       dev.log('drawingController.getImageData() is not null');
//   //       final PdfImage image = PdfBitmap(imageData.buffer.asUint8List());

//   //       final double pageWidth = page.getClientSize().width;
//   //       final double pageHeight = page.getClientSize().height;

//   //       page.graphics.drawImage(
//   //         image,
//   //         Rect.fromLTWH(0, 0, pageWidth, pageHeight),
//   //       );
//   //     }
//   //   }

//   //   // --- Add text boxes on the PDF page ---
//   //   if (hasText) {
//   //     for (TextBox textBox
//   //         in textBoxController.getAllTextBoxes()[i + 1] ?? []) {
//   //       dev.log(
//   //         'textBoxController.getAllTextBoxes() is not null page ${i + 1}',
//   //       );
//   //       final double scaleFactorX =
//   //           page.getClientSize().width / MediaQuery.of(context).size.width;
//   //       final double scaleFactorY =
//   //           page.getClientSize().height /
//   //           (MediaQuery.of(context).size.width * 1.414);

//   //       double scaledX = textBox.position.dx * scaleFactorX;
//   //       double scaledY = textBox.position.dy * scaleFactorY;
//   //       double scaledWidth = textBox.width * scaleFactorX;
//   //       double scaledHeight = textBox.height * scaleFactorY;

//   //       page.graphics.drawString(
//   //         textBox.text,
//   //         PdfStandardFont(PdfFontFamily.helvetica, textBox.fontSize),
//   //         brush: PdfSolidBrush(
//   //           PdfColor(
//   //             textBox.color?.red ?? 0,
//   //             textBox.color?.green ?? 0,
//   //             textBox.color?.blue ?? 0,
//   //           ),
//   //         ),
//   //         bounds: Rect.fromLTWH(
//   //           scaledX + 10, // Padding for better text visibility
//   //           scaledY + 10,
//   //           scaledWidth,
//   //           scaledHeight,
//   //         ),
//   //         format: PdfStringFormat(
//   //           alignment: PdfTextAlignment.center,
//   //           lineAlignment: PdfVerticalAlignment.middle,
//   //         ),
//   //       );
//   //     }
//   //   }
//   //   return page;
//   // }



// // ---------------------------




// ///// ignore_for_file: use_build_context_synchronously, deprecated_member_use

// // import 'dart:io';
// // import 'dart:math';
// // import 'dart:typed_data';
// // import 'dart:ui' as ui;
// // import 'dart:developer' as dev;
// // import 'package:flutter/material.dart';
// // import 'package:nextgen_pdf_editor/controllers/annotation_controller.dart';
// // import 'package:nextgen_pdf_editor/controllers/drawing_controller.dart';
// // import 'package:nextgen_pdf_editor/controllers/highlight_controller.dart';
// // import 'package:nextgen_pdf_editor/controllers/image_controller.dart';
// // import 'package:nextgen_pdf_editor/controllers/text_box_controller.dart';
// // import 'package:nextgen_pdf_editor/controllers/underline_controller.dart';
// // import 'package:open_file/open_file.dart';
// // import 'package:path_provider/path_provider.dart';
// // import 'package:syncfusion_flutter_pdf/pdf.dart';

// // /// A controller responsible for handling all save and manipulation
// // /// operations on a PDF, including drawing, annotations, text boxes,
// // /// images, adding/removing pages, and saving the final document.
// // class SavePdfController extends ChangeNotifier {
// //   /// Tracks whether a save operation is currently in progress.
// //   bool isSaving = false;

// //   /// Saves the current edits (drawings, images, annotations, and text boxes)
// //   /// to a new PDF file with memory optimization.
// //   Future<void> saveDrawing({
// //     required File pdfFile,
// //     required int totalPages,
// //     required BuildContext context,
// //     required DrawingController drawingController,
// //     required ImageController imageController,
// //     required TextBoxController textBoxController,
// //     required HighlightController highlightController,
// //     required UnderlineController underlineController,
// //     required Function refresh,
// //   }) async {
// //     if (isSaving) {
// //       return;
// //     }

// //     PdfDocument? pdfDoc;

// //     try {
// //       isSaving = true;

// //       if (!(drawingController.hasAnyContent() ||
// //           imageController.hasAnyContent() ||
// //           textBoxController.hasAnyContent() ||
// //           highlightController.hasAnyContent() ||
// //           underlineController.hasAnyContent())) {
// //         return Navigator.pop(context, pdfFile);
// //       }

// //       final output = await getTemporaryDirectory();
// //       final String originalName = pdfFile.path.split('/').last.split('.').first;
// //       final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
// //       final String savedPath = '${output.path}/${originalName}_$timestamp.pdf';
// //       final file = File(savedPath);
// //       dev.log('debug: Saving PDF to $savedPath');

// //       // Read PDF file in chunks to avoid loading entire file at once
// //       final fileBytes = await _readFileInChunks(pdfFile);
// //       pdfDoc = PdfDocument(inputBytes: fileBytes);

// //       // Process pages in batches to reduce memory usage
// //       const int batchSize = 5; // Process 5 pages at a time
// //       for (
// //         int batchStart = 0;
// //         batchStart < totalPages;
// //         batchStart += batchSize
// //       ) {
// //         final int batchEnd =
// //             (batchStart + batchSize > totalPages)
// //                 ? totalPages
// //                 : batchStart + batchSize;

// //         dev.log('Processing batch: pages ${batchStart + 1} to $batchEnd');

// //         await _processPageBatch(
// //           pdfDoc,
// //           batchStart,
// //           batchEnd,
// //           context,
// //           drawingController,
// //           imageController,
// //           textBoxController,
// //           highlightController,
// //           underlineController,
// //         );

// //         // Force garbage collection after each batch
// //         await Future.delayed(const Duration(milliseconds: 50));
// //       }

// //       dev.log('All pages processed, saving PDF...');

// //       // Save with streaming to avoid memory spike
// //       await _saveDocumentWithStreaming(pdfDoc, file);

// //       dev.log('PDF saved successfully');

// //       Navigator.pop(context, file);

// //       // Open the saved file
// //       // OpenFile.open(savedPath);
// //     } catch (e) {
// //       debugPrint('Error while saving drawing and text: $e');
// //       rethrow;
// //     } finally {
// //       // Always dispose of the PDF document
// //       pdfDoc?.dispose();
// //       pdfDoc = null;
// //       isSaving = false;

// //       // Force garbage collection
// //       await Future.delayed(const Duration(milliseconds: 100));
// //     }
// //   }

// //   /// Reads file in chunks to avoid memory spikes
// //   Future<Uint8List> _readFileInChunks(File file) async {
// //     const int chunkSize = 1024 * 1024; // 1MB chunks
// //     final fileStream = file.openRead();
// //     final chunks = <int>[];

// //     await for (final chunk in fileStream) {
// //       chunks.addAll(chunk);

// //       // Yield control periodically to prevent blocking
// //       if (chunks.length % (chunkSize * 5) == 0) {
// //         await Future.delayed(Duration.zero);
// //       }
// //     }

// //     return Uint8List.fromList(chunks);
// //   }

// //   /// Processes a batch of pages to reduce memory usage
// //   Future<void> _processPageBatch(
// //     PdfDocument pdfDoc,
// //     int batchStart,
// //     int batchEnd,
// //     BuildContext context,
// //     DrawingController drawingController,
// //     ImageController imageController,
// //     TextBoxController textBoxController,
// //     HighlightController highlightController,
// //     UnderlineController underlineController,
// //   ) async {
// //     for (int i = batchStart; i < batchEnd; i++) {
// //       drawingController.setPage(i + 1);
// //       final hasDrawings =
// //           (drawingController.getAllDrawing()[i + 1]?.isNotEmpty ?? false);
// //       final hasImages =
// //           (imageController.getAllImageBoxes()[i + 1]?.isNotEmpty ?? false);
// //       final hasText =
// //           (textBoxController.getAllTextBoxes()[i + 1]?.isNotEmpty ?? false);
// //       final hasHighlight =
// //           (highlightController.getHighlightHistory[i + 1]?.isNotEmpty ?? false);
// //       final hasUnderline =
// //           (underlineController.getUnderlineHistory[i + 1]?.isNotEmpty ?? false);

// //       if (!(hasDrawings ||
// //           hasImages ||
// //           hasText ||
// //           hasHighlight ||
// //           hasUnderline)) {
// //         continue;
// //       }

// //       PdfPage page = pdfDoc.pages[i];

// //       dev.log('Processing page ${i + 1}');
// //       await Future.delayed(const Duration(milliseconds: 50));

// //       // Process annotations
// //       await _processAnnotations(
// //         page,
// //         i,
// //         highlightController,
// //         underlineController,
// //       );

// //       // Process images
// //       await _processImages(page, i, context, imageController);

// //       // Process drawings
// //       await _processDrawings(page, drawingController);

// //       // Process text boxes
// //       await _processTextBoxes(page, i, context, textBoxController);

// //       // Clear any temporary data after processing each page
// //       await Future.delayed(Duration.zero);
// //     }
// //   }

// //   /// Process highlight and underline annotations
// //   Future<void> _processAnnotations(
// //     PdfPage page,
// //     int pageIndex,
// //     HighlightController highlightController,
// //     UnderlineController underlineController,
// //   ) async {
// //     // Add highlight annotations
// //     final highlightActions =
// //         highlightController.getHighlightHistory[pageIndex + 1];
// //     if (highlightActions != null) {
// //       for (AnnotationAction action in highlightActions) {
// //         if (action.isAdd) {
// //           for (int j = 0; j < action.pdfAnnotation.length; j++) {
// //             page.annotations.add(action.pdfAnnotation[j]);
// //           }
// //         }
// //       }
// //     }

// //     // Add underline annotations
// //     final underlineActions =
// //         underlineController.getUnderlineHistory[pageIndex + 1];
// //     if (underlineActions != null) {
// //       for (AnnotationAction action in underlineActions) {
// //         if (action.isAdd) {
// //           for (int j = 0; j < action.pdfAnnotation.length; j++) {
// //             dev.log("Adding underline annotation on page ${pageIndex + 1}");
// //             page.annotations.add(action.pdfAnnotation[j]);
// //           }
// //         }
// //       }
// //     }
// //   }

// //   /// Process images with memory optimization
// //   Future<void> _processImages(
// //     PdfPage page,
// //     int pageIndex,
// //     BuildContext context,
// //     ImageController imageController,
// //   ) async {
// //     final imageBoxes = imageController.getAllImageBoxes()[pageIndex + 1];
// //     if (imageBoxes == null) return;

// //     for (var imageBox in imageBoxes) {
// //       try {
// //         dev.log(
// //           "Adding image on page ${pageIndex + 1} at position ${imageBox.position}",
// //         );

// //         // Convert image with optimization
// //         final imgData = await _convertImageToUint8ListOptimized(imageBox.image);
// //         final PdfImage pdfImage = PdfBitmap(imgData);

// //         final double scaleFactorX =
// //             page.getClientSize().width / MediaQuery.of(context).size.width;
// //         final double scaleFactorY =
// //             page.getClientSize().height /
// //             (MediaQuery.of(context).size.width * 1.414);

// //         double scaledX = imageBox.position.dx * scaleFactorX;
// //         double scaledY = imageBox.position.dy * scaleFactorY;
// //         double scaledWidth = imageBox.width * scaleFactorX;
// //         double scaledHeight = imageBox.height * scaleFactorY;

// //         page.graphics.save();
// //         page.graphics.translateTransform(
// //           scaledX + scaledWidth / 2,
// //           scaledY + scaledHeight / 2,
// //         );
// //         page.graphics.rotateTransform(imageBox.rotation * (180 / pi));

// //         page.graphics.drawImage(
// //           pdfImage,
// //           Rect.fromLTWH(
// //             (-scaledWidth / 2) + 14,
// //             (-scaledHeight / 2) + 14,
// //             scaledWidth,
// //             scaledHeight,
// //           ),
// //         );

// //         page.graphics.restore();
// //         dev.log('Image drawing completed on page ${pageIndex + 1}');

// //         // Allow garbage collection
// //         await Future.delayed(Duration.zero);
// //       } catch (e) {
// //         dev.log('Error processing image on page ${pageIndex + 1}: $e');
// //       }
// //     }
// //   }

// //   /// Process drawings
// //   Future<void> _processDrawings(
// //     PdfPage page,
// //     DrawingController drawingController,
// //   ) async {
// //     try {
// //       ByteData? imageData = await drawingController.getImageData();
// //       if (imageData != null) {
// //         dev.log('Processing drawing data');
// //         final PdfImage image = PdfBitmap(imageData.buffer.asUint8List());

// //         final double pageWidth = page.getClientSize().width;
// //         final double pageHeight = page.getClientSize().height;

// //         page.graphics.drawImage(
// //           image,
// //           Rect.fromLTWH(0, 0, pageWidth, pageHeight),
// //         );

// //         // Clear the image data reference
// //         imageData = null;
// //       }
// //     } catch (e) {
// //       dev.log('Error processing drawing: $e');
// //     }
// //   }

// //   /// Process text boxes
// //   Future<void> _processTextBoxes(
// //     PdfPage page,
// //     int pageIndex,
// //     BuildContext context,
// //     TextBoxController textBoxController,
// //   ) async {
// //     final textBoxes = textBoxController.getAllTextBoxes()[pageIndex + 1];
// //     if (textBoxes == null) return;

// //     for (TextBox textBox in textBoxes) {
// //       dev.log('Processing text box on page ${pageIndex + 1}');

// //       final double scaleFactorX =
// //           page.getClientSize().width / MediaQuery.of(context).size.width;
// //       final double scaleFactorY =
// //           page.getClientSize().height /
// //           (MediaQuery.of(context).size.width * 1.414);

// //       double scaledX = textBox.position.dx * scaleFactorX;
// //       double scaledY = textBox.position.dy * scaleFactorY;
// //       double scaledWidth = textBox.width * scaleFactorX;
// //       double scaledHeight = textBox.height * scaleFactorY;

// //       page.graphics.drawString(
// //         textBox.text,
// //         PdfStandardFont(PdfFontFamily.helvetica, textBox.fontSize),
// //         brush: PdfSolidBrush(
// //           PdfColor(
// //             textBox.color?.red ?? 0,
// //             textBox.color?.green ?? 0,
// //             textBox.color?.blue ?? 0,
// //           ),
// //         ),
// //         bounds: Rect.fromLTWH(
// //           scaledX + 10,
// //           scaledY + 10,
// //           scaledWidth,
// //           scaledHeight,
// //         ),
// //         format: PdfStringFormat(
// //           alignment: PdfTextAlignment.center,
// //           lineAlignment: PdfVerticalAlignment.middle,
// //         ),
// //       );
// //     }
// //   }

// //   /// Optimized image conversion with compression
// //   Future<Uint8List> _convertImageToUint8ListOptimized(ui.Image image) async {
// //     try {
// //       // Try PNG first, but with compression
// //       final ByteData? byteData = await image.toByteData(
// //         format: ui.ImageByteFormat.png,
// //       );

// //       if (byteData != null) {
// //         final imageData = byteData.buffer.asUint8List();

// //         // If image is too large, we might want to compress it further
// //         if (imageData.length > 5 * 1024 * 1024) {
// //           // 5MB threshold
// //           dev.log(
// //             'Large image detected (${imageData.length} bytes), consider compression',
// //           );
// //         }

// //         return imageData;
// //       }
// //     } catch (e) {
// //       dev.log('Error converting image to PNG: $e');
// //     }

// //     // Fallback to raw RGBA if PNG fails
// //     final ByteData? rawData = await image.toByteData(
// //       format: ui.ImageByteFormat.rawRgba,
// //     );
// //     return rawData?.buffer.asUint8List() ?? Uint8List(0);
// //   }

// //   /// Save document with streaming to reduce memory usage
// //   Future<void> _saveDocumentWithStreaming(PdfDocument pdfDoc, File file) async {
// //     try {
// //       // Get the document bytes
// //       final List<int> bytes = await pdfDoc.save();

// //       // Write in chunks to avoid memory spike
// //       final IOSink sink = file.openWrite();

// //       const int chunkSize = 64 * 1024; // 64KB chunks
// //       for (int i = 0; i < bytes.length; i += chunkSize) {
// //         final int end =
// //             (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
// //         sink.add(bytes.sublist(i, end));

// //         // Yield control periodically
// //         if (i % (chunkSize * 10) == 0) {
// //           await Future.delayed(Duration.zero);
// //         }
// //       }

// //       await sink.flush();
// //       await sink.close();
// //     } catch (e) {
// //       dev.log('Error in streaming save: $e');
// //       rethrow;
// //     }
// //   }

// //   /// Adds a blank page at the given [pageIndex] in the PDF.
// //   Future<File?> addBlankPageAt(int pageIndex, File pdfFile) async {
// //     PdfDocument? pdfDoc;
// //     try {
// //       pdfDoc = PdfDocument(inputBytes: await _readFileInChunks(pdfFile));

// //       if (pageIndex < 0 || pageIndex > pdfDoc.pages.count) {
// //         debugPrint('Invalid page index: $pageIndex');
// //         return null;
// //       }

// //       final Size pageSize = Size(
// //         pdfDoc.pages[0].getClientSize().width,
// //         pdfDoc.pages[0].getClientSize().height,
// //       );

// //       pdfDoc.pages.insert(pageIndex, pageSize);

// //       return await saveFile(
// //         pdfDoc: pdfDoc,
// //         addTimestap: false,
// //         pdfFile: pdfFile,
// //       );
// //     } finally {
// //       pdfDoc?.dispose();
// //     }
// //   }

// //   /// Removes the page at [currentPage] (1-based index) from the PDF.
// //   Future<File?> removePage(int currentPage, File pdfFile) async {
// //     PdfDocument? pdfDoc;
// //     try {
// //       pdfDoc = PdfDocument(inputBytes: await _readFileInChunks(pdfFile));

// //       if (pdfDoc.pages.count > 1) {
// //         pdfDoc.pages.removeAt(currentPage - 1);
// //         return await saveFile(pdfDoc: pdfDoc, pdfFile: pdfFile);
// //       }
// //       return null;
// //     } finally {
// //       pdfDoc?.dispose();
// //     }
// //   }

// //   /// Saves the modified [pdfDoc] either with or without a timestamp.
// //   Future<File?> saveFile({
// //     bool addTimestap = false,
// //     required File pdfFile,
// //     required PdfDocument pdfDoc,
// //   }) async {
// //     try {
// //       final output = await getTemporaryDirectory();
// //       final String originalName = pdfFile.path.split('/').last.split('.').first;

// //       String savedPath = "";
// //       if (addTimestap) {
// //         final String timestamp =
// //             DateTime.now().millisecondsSinceEpoch.toString();
// //         savedPath = '${output.path}/${originalName}_$timestamp.pdf';
// //       } else {
// //         savedPath = '${output.path}/$originalName.pdf';
// //       }

// //       final file = File(savedPath);

// //       // Use streaming save method
// //       await _saveDocumentWithStreaming(pdfDoc, file);
// //       return file;
// //     } catch (e) {
// //       dev.log('Error saving file: $e');
// //       rethrow;
// //     } finally {
// //       pdfDoc.dispose();
// //     }
// //   }
// // }



// //-----final working 

// /*

// // ignore_for_file: use_build_context_synchronously, deprecated_member_use

// import 'dart:io';
// import 'dart:math';
// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'dart:developer' as dev;
// import 'package:flutter/material.dart';
// import 'package:nextgen_pdf_editor/controllers/annotation_controller.dart';
// import 'package:nextgen_pdf_editor/controllers/drawing_controller.dart';
// import 'package:nextgen_pdf_editor/controllers/highlight_controller.dart';
// import 'package:nextgen_pdf_editor/controllers/image_controller.dart';
// import 'package:nextgen_pdf_editor/controllers/text_box_controller.dart';
// import 'package:nextgen_pdf_editor/controllers/underline_controller.dart';
// import 'package:open_file/open_file.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:syncfusion_flutter_pdf/pdf.dart';

// /// A controller responsible for handling all save and manipulation
// /// operations on a PDF, including drawing, annotations, text boxes,
// /// images, adding/removing pages, and saving the final document.
// class SavePdfController extends ChangeNotifier {
//   /// Tracks whether a save operation is currently in progress.
//   bool isSaving = false;

//   /// Saves the current edits (drawings, images, annotations, and text boxes)
//   /// to a new PDF file with memory optimization.
//   Future<void> saveDrawing({
//     required File pdfFile,
//     required int totalPages,
//     required BuildContext context,
//     required DrawingController drawingController,
//     required ImageController imageController,
//     required TextBoxController textBoxController,
//     required HighlightController highlightController,
//     required UnderlineController underlineController,
//     required Function refresh,
//   }) async {
//     if (isSaving) {
//       return;
//     }

//     PdfDocument? pdfDoc;

//     try {
//       isSaving = true;

//       if (!(drawingController.hasAnyContent() ||
//           imageController.hasAnyContent() ||
//           textBoxController.hasAnyContent() ||
//           highlightController.hasAnyContent() ||
//           underlineController.hasAnyContent())) {
//         return Navigator.pop(context, pdfFile);
//       }

//       final output = await getTemporaryDirectory();
//       final String originalName = pdfFile.path.split('/').last.split('.').first;
//       final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
//       final String savedPath = '${output.path}/${originalName}_$timestamp.pdf';
//       final file = File(savedPath);
//       dev.log('debug: Saving PDF to $savedPath');

//       // Read PDF file in chunks to avoid loading entire file at once
//       final fileBytes = await _readFileInChunks(pdfFile);
//       pdfDoc = PdfDocument(inputBytes: fileBytes);

//       // Process pages in batches to reduce memory usage
//       const int batchSize = 5; // Process 5 pages at a time
//       for (
//         int batchStart = 0;
//         batchStart < totalPages;
//         batchStart += batchSize
//       ) {
//         final int batchEnd =
//             (batchStart + batchSize > totalPages)
//                 ? totalPages
//                 : batchStart + batchSize;

//         dev.log('Processing batch: pages ${batchStart + 1} to $batchEnd');

//         await _processPageBatch(
//           pdfDoc,
//           batchStart,
//           batchEnd,
//           context,
//           drawingController,
//           imageController,
//           textBoxController,
//           highlightController,
//           underlineController,
//         );

//         // Force garbage collection after each batch
//         await Future.delayed(const Duration(milliseconds: 50));
//       }

//       dev.log('All pages processed, saving PDF...');

//       // Save with streaming to avoid memory spike
//       await _saveDocumentWithStreaming(pdfDoc, file);

//       dev.log('PDF saved successfully');

//       Navigator.pop(context, file);

//       // Open the saved file
//       // OpenFile.open(savedPath);
//     } catch (e) {
//       debugPrint('Error while saving drawing and text: $e');
//       rethrow;
//     } finally {
//       // Always dispose of the PDF document
//       pdfDoc?.dispose();
//       pdfDoc = null;
//       isSaving = false;

//       // Force garbage collection
//       await Future.delayed(const Duration(milliseconds: 100));
//     }
//   }

//   /// Reads file in chunks to avoid memory spikes
//   Future<Uint8List> _readFileInChunks(File file) async {
//     const int chunkSize = 1024 * 1024; // 1MB chunks
//     final fileStream = file.openRead();
//     final chunks = <int>[];

//     await for (final chunk in fileStream) {
//       chunks.addAll(chunk);

//       // Yield control periodically to prevent blocking
//       if (chunks.length % (chunkSize * 5) == 0) {
//         await Future.delayed(Duration.zero);
//       }
//     }

//     return Uint8List.fromList(chunks);
//   }

//   /// Processes a batch of pages to reduce memory usage
//   Future<void> _processPageBatch(
//     PdfDocument pdfDoc,
//     int batchStart,
//     int batchEnd,
//     BuildContext context,
//     DrawingController drawingController,
//     ImageController imageController,
//     TextBoxController textBoxController,
//     HighlightController highlightController,
//     UnderlineController underlineController,
//   ) async {
//     for (int i = batchStart; i < batchEnd; i++) {
//       drawingController.setPage(i + 1);
//       final hasDrawings =
//           (drawingController.getAllDrawing()[i + 1]?.isNotEmpty ?? false);
//       final hasImages =
//           (imageController.getAllImageBoxes()[i + 1]?.isNotEmpty ?? false);
//       final hasText =
//           (textBoxController.getAllTextBoxes()[i + 1]?.isNotEmpty ?? false);
//       final hasHighlight =
//           (highlightController.getHighlightHistory[i + 1]?.isNotEmpty ?? false);
//       final hasUnderline =
//           (underlineController.getUnderlineHistory[i + 1]?.isNotEmpty ?? false);

//       if (!(hasDrawings ||
//           hasImages ||
//           hasText ||
//           hasHighlight ||
//           hasUnderline)) {
//         continue;
//       }

//       PdfPage page = pdfDoc.pages[i];

//       dev.log('Processing page ${i + 1}');
//       await Future.delayed(const Duration(milliseconds: 50));

//       // Process annotations
//       await _processAnnotations(
//         page,
//         i,
//         highlightController,
//         underlineController,
//       );

//       // Process images
//       await _processImages(page, i, context, imageController);

//       // Process drawings
//       await _processDrawings(page, drawingController);

//       // Process text boxes
//       await _processTextBoxes(page, i, context, textBoxController);

//       // Clear any temporary data after processing each page
//       await Future.delayed(Duration.zero);
//     }
//   }

//   /// Process highlight and underline annotations
//   Future<void> _processAnnotations(
//     PdfPage page,
//     int pageIndex,
//     HighlightController highlightController,
//     UnderlineController underlineController,
//   ) async {
//     // Add highlight annotations
//     final highlightActions =
//         highlightController.getHighlightHistory[pageIndex + 1];
//     if (highlightActions != null) {
//       for (AnnotationAction action in highlightActions) {
//         if (action.isAdd) {
//           for (int j = 0; j < action.pdfAnnotation.length; j++) {
//             page.annotations.add(action.pdfAnnotation[j]);
//           }
//         }
//       }
//     }

//     // Add underline annotations
//     final underlineActions =
//         underlineController.getUnderlineHistory[pageIndex + 1];
//     if (underlineActions != null) {
//       for (AnnotationAction action in underlineActions) {
//         if (action.isAdd) {
//           for (int j = 0; j < action.pdfAnnotation.length; j++) {
//             dev.log("Adding underline annotation on page ${pageIndex + 1}");
//             page.annotations.add(action.pdfAnnotation[j]);
//           }
//         }
//       }
//     }
//   }

//   /// Process images with memory optimization
//   Future<void> _processImages(
//     PdfPage page,
//     int pageIndex,
//     BuildContext context,
//     ImageController imageController,
//   ) async {
//     final imageBoxes = imageController.getAllImageBoxes()[pageIndex + 1];
//     if (imageBoxes == null) return;

//     for (var imageBox in imageBoxes) {
//       try {
//         dev.log(
//           "Adding image on page ${pageIndex + 1} at position ${imageBox.position}",
//         );

//         // Convert image with optimization
//         final imgData = await _convertImageToUint8ListOptimized(imageBox.image);
//         final PdfImage pdfImage = PdfBitmap(imgData);

//         final double scaleFactorX =
//             page.getClientSize().width / MediaQuery.of(context).size.width;
//         final double scaleFactorY =
//             page.getClientSize().height /
//             (MediaQuery.of(context).size.width * 1.414);

//         double scaledX = imageBox.position.dx * scaleFactorX;
//         double scaledY = imageBox.position.dy * scaleFactorY;
//         double scaledWidth = imageBox.width * scaleFactorX;
//         double scaledHeight = imageBox.height * scaleFactorY;

//         page.graphics.save();
//         page.graphics.translateTransform(
//           scaledX + scaledWidth / 2,
//           scaledY + scaledHeight / 2,
//         );
//         page.graphics.rotateTransform(imageBox.rotation * (180 / pi));

//         page.graphics.drawImage(
//           pdfImage,
//           Rect.fromLTWH(
//             (-scaledWidth / 2) + 14,
//             (-scaledHeight / 2) + 14,
//             scaledWidth,
//             scaledHeight,
//           ),
//         );

//         page.graphics.restore();
//         dev.log('Image drawing completed on page ${pageIndex + 1}');

//         // Allow garbage collection
//         await Future.delayed(Duration.zero);
//       } catch (e) {
//         dev.log('Error processing image on page ${pageIndex + 1}: $e');
//       }
//     }
//   }

//   /// Process drawings
//   Future<void> _processDrawings(
//     PdfPage page,
//     DrawingController drawingController,
//   ) async {
//     try {
//       ByteData? imageData = await drawingController.getImageData();
//       if (imageData != null) {
//         dev.log('Processing drawing data');
//         final PdfImage image = PdfBitmap(imageData.buffer.asUint8List());

//         final double pageWidth = page.getClientSize().width;
//         final double pageHeight = page.getClientSize().height;

//         page.graphics.drawImage(
//           image,
//           Rect.fromLTWH(0, 0, pageWidth, pageHeight),
//         );

//         // Clear the image data reference
//         imageData = null;
//       }
//     } catch (e) {
//       dev.log('Error processing drawing: $e');
//     }
//   }

//   /// Process text boxes
//   Future<void> _processTextBoxes(
//     PdfPage page,
//     int pageIndex,
//     BuildContext context,
//     TextBoxController textBoxController,
//   ) async {
//     final textBoxes = textBoxController.getAllTextBoxes()[pageIndex + 1];
//     if (textBoxes == null) return;

//     for (TextBox textBox in textBoxes) {
//       dev.log('Processing text box on page ${pageIndex + 1}');

//       final double scaleFactorX =
//           page.getClientSize().width / MediaQuery.of(context).size.width;
//       final double scaleFactorY =
//           page.getClientSize().height /
//           (MediaQuery.of(context).size.width * 1.414);

//       double scaledX = textBox.position.dx * scaleFactorX;
//       double scaledY = textBox.position.dy * scaleFactorY;
//       double scaledWidth = textBox.width * scaleFactorX;
//       double scaledHeight = textBox.height * scaleFactorY;

//       page.graphics.drawString(
//         textBox.text,
//         PdfStandardFont(PdfFontFamily.helvetica, textBox.fontSize),
//         brush: PdfSolidBrush(
//           PdfColor(
//             textBox.color?.red ?? 0,
//             textBox.color?.green ?? 0,
//             textBox.color?.blue ?? 0,
//           ),
//         ),
//         bounds: Rect.fromLTWH(
//           scaledX + 10,
//           scaledY + 10,
//           scaledWidth,
//           scaledHeight,
//         ),
//         format: PdfStringFormat(
//           alignment: PdfTextAlignment.center,
//           lineAlignment: PdfVerticalAlignment.middle,
//         ),
//       );
//     }
//   }

//   /// Optimized image conversion with compression
//   Future<Uint8List> _convertImageToUint8ListOptimized(ui.Image image) async {
//     try {
//       // Try PNG first, but with compression
//       final ByteData? byteData = await image.toByteData(
//         format: ui.ImageByteFormat.png,
//       );

//       if (byteData != null) {
//         final imageData = byteData.buffer.asUint8List();

//         // If image is too large, we might want to compress it further
//         if (imageData.length > 5 * 1024 * 1024) {
//           // 5MB threshold
//           dev.log(
//             'Large image detected (${imageData.length} bytes), consider compression',
//           );
//         }

//         return imageData;
//       }
//     } catch (e) {
//       dev.log('Error converting image to PNG: $e');
//     }

//     // Fallback to raw RGBA if PNG fails
//     final ByteData? rawData = await image.toByteData(
//       format: ui.ImageByteFormat.rawRgba,
//     );
//     return rawData?.buffer.asUint8List() ?? Uint8List(0);
//   }

//   /// Save document with streaming to reduce memory usage
//   Future<void> _saveDocumentWithStreaming(PdfDocument pdfDoc, File file) async {
//     try {
//       // Get the document bytes
//       final List<int> bytes = await pdfDoc.save();

//       // Write in chunks to avoid memory spike
//       final IOSink sink = file.openWrite();

//       const int chunkSize = 64 * 1024; // 64KB chunks
//       for (int i = 0; i < bytes.length; i += chunkSize) {
//         final int end =
//             (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
//         sink.add(bytes.sublist(i, end));

//         // Yield control periodically
//         if (i % (chunkSize * 10) == 0) {
//           await Future.delayed(Duration.zero);
//         }
//       }

//       await sink.flush();
//       await sink.close();
//     } catch (e) {
//       dev.log('Error in streaming save: $e');
//       rethrow;
//     }
//   }

//   /// Adds a blank page at the given [pageIndex] in the PDF.
//   Future<File?> addBlankPageAt(int pageIndex, File pdfFile) async {
//     PdfDocument? pdfDoc;
//     try {
//       pdfDoc = PdfDocument(inputBytes: await _readFileInChunks(pdfFile));

//       if (pageIndex < 0 || pageIndex > pdfDoc.pages.count) {
//         debugPrint('Invalid page index: $pageIndex');
//         return null;
//       }

//       final Size pageSize = Size(
//         pdfDoc.pages[0].getClientSize().width,
//         pdfDoc.pages[0].getClientSize().height,
//       );

//       pdfDoc.pages.insert(pageIndex, pageSize);

//       return await saveFile(
//         pdfDoc: pdfDoc,
//         addTimestap: false,
//         pdfFile: pdfFile,
//       );
//     } finally {
//       pdfDoc?.dispose();
//     }
//   }

//   /// Removes the page at [currentPage] (1-based index) from the PDF.
//   Future<File?> removePage(int currentPage, File pdfFile) async {
//     PdfDocument? pdfDoc;
//     try {
//       pdfDoc = PdfDocument(inputBytes: await _readFileInChunks(pdfFile));

//       if (pdfDoc.pages.count > 1) {
//         pdfDoc.pages.removeAt(currentPage - 1);
//         return await saveFile(pdfDoc: pdfDoc, pdfFile: pdfFile);
//       }
//       return null;
//     } finally {
//       pdfDoc?.dispose();
//     }
//   }

//   /// Saves the modified [pdfDoc] either with or without a timestamp.
//   Future<File?> saveFile({
//     bool addTimestap = false,
//     required File pdfFile,
//     required PdfDocument pdfDoc,
//   }) async {
//     try {
//       final output = await getTemporaryDirectory();
//       final String originalName = pdfFile.path.split('/').last.split('.').first;

//       String savedPath = "";
//       if (addTimestap) {
//         final String timestamp =
//             DateTime.now().millisecondsSinceEpoch.toString();
//         savedPath = '${output.path}/${originalName}_$timestamp.pdf';
//       } else {
//         savedPath = '${output.path}/$originalName.pdf';
//       }

//       final file = File(savedPath);

//       // Use streaming save method
//       await _saveDocumentWithStreaming(pdfDoc, file);
//       return file;
//     } catch (e) {
//       dev.log('Error saving file: $e');
//       rethrow;
//     } finally {
//       pdfDoc.dispose();
//     }
//   }
// }

//  */















// ///////////////working with isolate 
// ///
// ///
// /*
// // ignore_for_file: use_build_context_synchronously, deprecated_member_use

// import 'dart:io';
// import 'dart:isolate';
// import 'dart:math';
// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'dart:developer' as dev;
// import 'package:flutter/material.dart';
// import 'package:nextgen_pdf_editor/controllers/annotation_controller.dart';
// import 'package:nextgen_pdf_editor/controllers/drawing_controller.dart';
// import 'package:nextgen_pdf_editor/controllers/highlight_controller.dart';
// import 'package:nextgen_pdf_editor/controllers/image_controller.dart';
// import 'package:nextgen_pdf_editor/controllers/save_pdf_second_thread.dart';
// import 'package:nextgen_pdf_editor/controllers/text_box_controller.dart';
// import 'package:nextgen_pdf_editor/controllers/underline_controller.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:syncfusion_flutter_pdf/pdf.dart';

// /// A controller responsible for handling all save and manipulation
// /// operations on a PDF, including drawing, annotations, text boxes,
// /// images, adding/removing pages, and saving the final document.
// class SavePdfController extends ChangeNotifier {
//   /// Tracks whether a save operation is currently in progress.
//   bool isSaving = false;

//   /// Saves the current edits (drawings, images, annotations, and text boxes)
//   /// to a new PDF file with memory optimization.
//   Future<void> saveDrawing({
//     required File pdfFile,
//     required int totalPages,
//     required BuildContext context,
//     required DrawingController drawingController,
//     required ImageController imageController,
//     required TextBoxController textBoxController,
//     required HighlightController highlightController,
//     required UnderlineController underlineController,
//     required Function refresh,
//   }) async {
//     if (isSaving) {
//       return;
//     }

//     PdfDocument? pdfDoc;

//     try {
//       isSaving = true;

//       if (!(drawingController.hasAnyContent() ||
//           imageController.hasAnyContent() ||
//           textBoxController.hasAnyContent() ||
//           highlightController.hasAnyContent() ||
//           underlineController.hasAnyContent())) {
//         return Navigator.pop(context, pdfFile);
//       }

//       final output = await getTemporaryDirectory();
//       final String originalName = pdfFile.path.split('/').last.split('.').first;
//       final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
//       final String savedPath = '${output.path}/${originalName}_$timestamp.pdf';
//       final file = File(savedPath);

//       // Read PDF file in chunks to avoid loading entire file at once
//       // final fileBytes = await _readFileInChunks(pdfFile);
//       final fileBytes = await Isolate.run(() async {
//         return await readFileInChunks(pdfFile);
//       });

//       PdfDocument pdfDoc = await Isolate.run(() async {
//         return await processPdfDocViaUt(fileBytes);
//       });

//       // Process pages in batches to reduce memory usage
//       const int batchSize = 5; // Process 5 pages at a time
//       for (
//         int batchStart = 0;
//         batchStart < totalPages;
//         batchStart += batchSize
//       ) {
//         final int batchEnd =
//             (batchStart + batchSize > totalPages)
//                 ? totalPages
//                 : batchStart + batchSize;

//         dev.log('Processing batch: pages ${batchStart + 1} to $batchEnd');

//         await _processPageBatch(
//           pdfDoc,
//           batchStart,
//           batchEnd,
//           context,
//           drawingController,
//           imageController,
//           textBoxController,
//           highlightController,
//           underlineController,
//         );
//       }

//       dev.log('All pages processed, saving PDF...');

//       // Save with streaming to avoid memory spike
//       await Isolate.run(() async {
//         return await savePdfDocToFile(pdfDoc, file);
//       });
//       // await _saveDocumentWithStreaming(pdfDoc, file);

//       dev.log('PDF saved successfully');

//       Navigator.pop(context, file);

//       // Open the saved file
//       // OpenFile.open(savedPath);
//     } catch (e) {
//       debugPrint('Error while saving drawing and text: $e');
//       rethrow;
//     } finally {
//       // Always dispose of the PDF document
//       pdfDoc?.dispose();
//       pdfDoc = null;
//       isSaving = false;

//       // Force garbage collection
//       await Future.delayed(const Duration(milliseconds: 100));
//     }
//   }

//   /// Processes a batch of pages to reduce memory usage
//   Future<void> _processPageBatch(
//     PdfDocument pdfDoc,
//     int batchStart,
//     int batchEnd,
//     BuildContext context,
//     DrawingController drawingController,
//     ImageController imageController,
//     TextBoxController textBoxController,
//     HighlightController highlightController,
//     UnderlineController underlineController,
//   ) async {
//     for (int i = batchStart; i < batchEnd; i++) {

//       drawingController.setPage(i + 1);
//       final hasDrawings =
//           (drawingController.getAllDrawing()[i + 1]?.isNotEmpty ?? false);
//       final hasImages =
//           (imageController.getAllImageBoxes()[i + 1]?.isNotEmpty ?? false);
//       final hasText =
//           (textBoxController.getAllTextBoxes()[i + 1]?.isNotEmpty ?? false);
//       final hasHighlight =
//           (highlightController.getHighlightHistory[i + 1]?.isNotEmpty ?? false);
//       final hasUnderline =
//           (underlineController.getUnderlineHistory[i + 1]?.isNotEmpty ?? false);

//       if (!(hasDrawings ||
//           hasImages ||
//           hasText ||
//           hasHighlight ||
//           hasUnderline)) {
//         continue;
//       }

//       PdfPage page = pdfDoc.pages[i];

//       dev.log('Processing page ${i + 1}');
//       await Future.delayed(const Duration(milliseconds: 50));

//       // Process annotations
//       if (hasUnderline || hasHighlight) {
//         await _processAnnotations(
//           page,
//           i,
//           highlightController,
//           underlineController,
//         );
//       }

//       await Future.delayed(const Duration(milliseconds: 50));

//       // Process images
//       if (hasImages) {
//         await _processImages(page, i, context, imageController);
//       }

//       // Process drawings
//       if (hasDrawings) {
//         await _processDrawings(page, drawingController);
//       }

//       // Process text boxes
//       if (hasText) {
//         await _processTextBoxes(page, i, context, textBoxController);
//       }
//     }
//   }

//   /// Process highlight and underline annotations
//   Future<void> _processAnnotations(
//     PdfPage page,
//     int pageIndex,
//     HighlightController highlightController,
//     UnderlineController underlineController,
//   ) async {
//     // Add highlight annotations
//     final highlightActions =
//         highlightController.getHighlightHistory[pageIndex + 1];
//     if (highlightActions != null) {
//       for (AnnotationAction action in highlightActions) {
//         if (action.isAdd) {
//           for (int j = 0; j < action.pdfAnnotation.length; j++) {
//             page.annotations.add(action.pdfAnnotation[j]);
//           }
//         }
//       }
//     }

//     // Add underline annotations
//     final underlineActions =
//         underlineController.getUnderlineHistory[pageIndex + 1];
//     if (underlineActions != null) {
//       for (AnnotationAction action in underlineActions) {
//         if (action.isAdd) {
//           for (int j = 0; j < action.pdfAnnotation.length; j++) {
//             dev.log("Adding underline annotation on page ${pageIndex + 1}");
//             page.annotations.add(action.pdfAnnotation[j]);
//           }
//         }
//       }
//     }
//   }

//   /// Process images with memory optimization
//   Future<void> _processImages(
//     PdfPage page,
//     int pageIndex,
//     BuildContext context,
//     ImageController imageController,
//   ) async {
//     final imageBoxes = imageController.getAllImageBoxes()[pageIndex + 1];
//     if (imageBoxes == null) return;

//     for (var imageBox in imageBoxes) {
//       try {
//         dev.log(
//           "Adding image on page ${pageIndex + 1} at position ${imageBox.position}",
//         );

//         // Convert image with optimization
//         final imgData = await _convertImageToUint8ListOptimized(imageBox.image);

//         final PdfImage pdfImage = await Isolate.run(() async {
//           return await processDrawingsIsolate(imgData);
//         });

//         final double scaleFactorX =
//             page.getClientSize().width / MediaQuery.of(context).size.width;
//         final double scaleFactorY =
//             page.getClientSize().height /
//             (MediaQuery.of(context).size.width * 1.414);

//         double scaledX = imageBox.position.dx * scaleFactorX;
//         double scaledY = imageBox.position.dy * scaleFactorY;
//         double scaledWidth = imageBox.width * scaleFactorX;
//         double scaledHeight = imageBox.height * scaleFactorY;

//         page.graphics.save();
//         page.graphics.translateTransform(
//           scaledX + scaledWidth / 2,
//           scaledY + scaledHeight / 2,
//         );
//         page.graphics.rotateTransform(imageBox.rotation * (180 / pi));

//         page.graphics.drawImage(
//           pdfImage,
//           Rect.fromLTWH(
//             (-scaledWidth / 2) + 14,
//             (-scaledHeight / 2) + 14,
//             scaledWidth,
//             scaledHeight,
//           ),
//         );

//         page.graphics.restore();
//         dev.log('Image drawing completed on page ${pageIndex + 1}');

//         // Allow garbage collection
//         await Future.delayed(Duration.zero);
//       } catch (e) {
//         dev.log('Error processing image on page ${pageIndex + 1}: $e');
//       }
//     }
//   }

//   /// Process drawings
//   Future<void> _processDrawings(
//     PdfPage page,
//     DrawingController drawingController,
//   ) async {
//     try {
//       ByteData? imageData = await drawingController.getImageData();
//       if (imageData != null) {
//         var imageBytes = imageData.buffer.asUint8List();
//         final PdfImage image = await Isolate.run(() async {
//           return await processDrawingsIsolate(imageBytes);
//         });
//         final double pageWidth = page.getClientSize().width;
//         final double pageHeight = page.getClientSize().height;

//         page.graphics.drawImage(
//           image,
//           Rect.fromLTWH(0, 0, pageWidth, pageHeight),
//         );

//         imageData = null;
//       }
//     } catch (e) {
//       dev.log('Error processing drawing: $e');
//     }
//   }

//   /// Process text boxes
//   Future<void> _processTextBoxes(
//     PdfPage page,
//     int pageIndex,
//     BuildContext context,
//     TextBoxController textBoxController,
//   ) async {
//     final textBoxes = textBoxController.getAllTextBoxes()[pageIndex + 1];
//     if (textBoxes == null) return;

//     for (TextBox textBox in textBoxes) {
//       dev.log('Processing text box on page ${pageIndex + 1}');

//       final double scaleFactorX =
//           page.getClientSize().width / MediaQuery.of(context).size.width;
//       final double scaleFactorY =
//           page.getClientSize().height /
//           (MediaQuery.of(context).size.width * 1.414);

//       double scaledX = textBox.position.dx * scaleFactorX;
//       double scaledY = textBox.position.dy * scaleFactorY;
//       double scaledWidth = textBox.width * scaleFactorX;
//       double scaledHeight = textBox.height * scaleFactorY;

//       page.graphics.drawString(
//         textBox.text,
//         PdfStandardFont(PdfFontFamily.helvetica, textBox.fontSize),
//         brush: PdfSolidBrush(
//           PdfColor(
//             textBox.color?.red ?? 0,
//             textBox.color?.green ?? 0,
//             textBox.color?.blue ?? 0,
//           ),
//         ),
//         bounds: Rect.fromLTWH(
//           scaledX + 10,
//           scaledY + 10,
//           scaledWidth,
//           scaledHeight,
//         ),
//         format: PdfStringFormat(
//           alignment: PdfTextAlignment.center,
//           lineAlignment: PdfVerticalAlignment.middle,
//         ),
//       );
//     }
//   }

//   /// Optimized image conversion with compression
//   Future<Uint8List> _convertImageToUint8ListOptimized(ui.Image image) async {
//     try {
//       // Try PNG first, but with compression
//       final ByteData? byteData = await image.toByteData(
//         format: ui.ImageByteFormat.png,
//       );

//       if (byteData != null) {
//         final imageData = byteData.buffer.asUint8List();

//         // If image is too large, we might want to compress it further
//         if (imageData.length > 5 * 1024 * 1024) {
//           // 5MB threshold
//           dev.log(
//             'Large image detected (${imageData.length} bytes), consider compression',
//           );
//         }

//         return imageData;
//       }
//     } catch (e) {
//       dev.log('Error converting image to PNG: $e');
//     }

//     // Fallback to raw RGBA if PNG fails
//     final ByteData? rawData = await image.toByteData(
//       format: ui.ImageByteFormat.rawRgba,
//     );
//     return rawData?.buffer.asUint8List() ?? Uint8List(0);
//   }

//   /// Save document with streaming to reduce memory usage
//   Future<void> _saveDocumentWithStreaming(PdfDocument pdfDoc, File file) async {
//     try {
//       dev.log('1');
//       // Get the document bytes
//       final List<int> bytes = await pdfDoc.save();
//       dev.log('2');
//       // Write in chunks to avoid memory spike
//       final IOSink sink = file.openWrite();
//       dev.log('3');
//       const int chunkSize = 64 * 1024; // 64KB chunks
//       for (int i = 0; i < bytes.length; i += chunkSize) {
//         final int end =
//             (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
//         sink.add(bytes.sublist(i, end));

//         // Yield control periodically
//         if (i % (chunkSize * 10) == 0) {
//           await Future.delayed(Duration.zero);
//         }
//       }
//       dev.log('4');
//       await sink.flush();
//       await sink.close();
//     } catch (e) {
//       dev.log('Error in streaming save: $e');
//       rethrow;
//     }
//   }

//   /// Adds a blank page at the given [pageIndex] in the PDF.
//   Future<File?> addBlankPageAt(int pageIndex, File pdfFile) async {
//     PdfDocument? pdfDoc;
//     try {
//       pdfDoc = PdfDocument(inputBytes: await readFileInChunks(pdfFile));

//       if (pageIndex < 0 || pageIndex > pdfDoc.pages.count) {
//         debugPrint('Invalid page index: $pageIndex');
//         return null;
//       }

//       final Size pageSize = Size(
//         pdfDoc.pages[0].getClientSize().width,
//         pdfDoc.pages[0].getClientSize().height,
//       );

//       pdfDoc.pages.insert(pageIndex, pageSize);

//       return await saveFile(
//         pdfDoc: pdfDoc,
//         addTimestap: false,
//         pdfFile: pdfFile,
//       );
//     } finally {
//       pdfDoc?.dispose();
//     }
//   }

//   /// Removes the page at [currentPage] (1-based index) from the PDF.
//   Future<File?> removePage(int currentPage, File pdfFile) async {
//     PdfDocument? pdfDoc;
//     try {
//       pdfDoc = PdfDocument(inputBytes: await readFileInChunks(pdfFile));

//       if (pdfDoc.pages.count > 1) {
//         pdfDoc.pages.removeAt(currentPage - 1);
//         return await saveFile(pdfDoc: pdfDoc, pdfFile: pdfFile);
//       }
//       return null;
//     } finally {
//       pdfDoc?.dispose();
//     }
//   }

//   /// Saves the modified [pdfDoc] either with or without a timestamp.
//   Future<File?> saveFile({
//     bool addTimestap = false,
//     required File pdfFile,
//     required PdfDocument pdfDoc,
//   }) async {
//     try {
//       final output = await getTemporaryDirectory();
//       final String originalName = pdfFile.path.split('/').last.split('.').first;

//       String savedPath = "";
//       if (addTimestap) {
//         final String timestamp =
//             DateTime.now().millisecondsSinceEpoch.toString();
//         savedPath = '${output.path}/${originalName}_$timestamp.pdf';
//       } else {
//         savedPath = '${output.path}/$originalName.pdf';
//       }

//       final file = File(savedPath);

//       // Use streaming save method
//       await _saveDocumentWithStreaming(pdfDoc, file);
//       return file;
//     } catch (e) {
//       dev.log('Error saving file: $e');
//       rethrow;
//     } finally {
//       pdfDoc.dispose();
//     }
//   }
// }

//  */