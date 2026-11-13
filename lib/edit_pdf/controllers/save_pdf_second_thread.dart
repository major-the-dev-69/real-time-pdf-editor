import 'dart:io';
import 'dart:typed_data';

import 'package:syncfusion_flutter_pdf/pdf.dart';

Future<PdfImage> processDrawingsIsolate(Uint8List imageBytes) async {
  final PdfImage image = PdfBitmap(imageBytes);
  return image;
}

Future<Uint8List> readFileInChunks(File file) async {
  const int chunkSize = 1024 * 1024; // 1MB chunks
  final fileStream = file.openRead();
  final chunks = <int>[];

  await for (final chunk in fileStream) {
    chunks.addAll(chunk);

    // Yield control periodically to prevent blocking
    if (chunks.length % (chunkSize * 5) == 0) {
      await Future.delayed(Duration.zero);
    }
  }

  return Uint8List.fromList(chunks);
}

Future<PdfDocument> processPdfDocViaUt(File file) async {
  var bytes = await readFileInChunks(file);

  final PdfDocument pdfDoc = PdfDocument(inputBytes: bytes);
  return pdfDoc;
}

Future<List<int>> savePdfDocToFile(PdfDocument pdfDoc, File file) async {
  try {
    // Get the document bytes
    final List<int> bytes = await pdfDoc.save();

    // Write in chunks to avoid memory spike
    final IOSink sink = file.openWrite();
    const int chunkSize = 64 * 1024; // 64KB chunks
    for (int i = 0; i < bytes.length; i += chunkSize) {
      final int end =
          (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
      sink.add(bytes.sublist(i, end));
      await sink.flush();
      // Yield control periodically to prevent blocking
      if (i % (chunkSize * 5) == 0) {
        await Future.delayed(Duration.zero);
      }
    }
    await sink.close();
    return bytes;
  } catch (e) { 
    return [];
  }
}
