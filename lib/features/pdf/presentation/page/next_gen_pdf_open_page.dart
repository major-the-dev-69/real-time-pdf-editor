import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../../../core/utils/app_assets.dart';
import '../../../../edit_pdf/nextgen_pdf_edit_screen.dart';
import '../../../../widgets/custom_buttons.dart';
import '../../../../widgets/custom_snack_bar.dart';
import '../controller/pdf_detail_controller.dart';
import '../controller/pdf_edit_controller.dart';

class NextGenPdfOpenPage extends StatefulWidget {
  const NextGenPdfOpenPage({super.key});

  @override
  State<NextGenPdfOpenPage> createState() => _NextGenPdfOpenPageState();
}

class _NextGenPdfOpenPageState extends State<NextGenPdfOpenPage> {
  File? _pdfFile;
  bool _isLoading = true;
  double _downloadProgress = 0.0;
  String _statusMessage = 'Initializing PDF Editor...';

  @override
  void initState() {
    super.initState();
    _loadPdfFile();
  }

  Future<void> _loadPdfFile() async {
    try {
      final args = Get.arguments;

      // 1. If File object is passed directly
      if (args is File && await args.exists()) {
        setState(() {
          _pdfFile = args;
          _isLoading = false;
        });
        return;
      }

      if (args is Map<String, dynamic>) {
        if (args['file'] is File && await (args['file'] as File).exists()) {
          setState(() {
            _pdfFile = args['file'] as File;
            _isLoading = false;
          });
          return;
        }

        if (args['path'] is String && File(args['path']).existsSync()) {
          setState(() {
            _pdfFile = File(args['path']);
            _isLoading = false;
          });
          return;
        }
      }

      // 2. Try fetching URL from arguments or registered controllers
      String? pdfUrl;
      if (args is Map<String, dynamic> && args['url'] is String) {
        pdfUrl = args['url'];
      } else if (args is String &&
          (args.startsWith('http://') || args.startsWith('https://'))) {
        pdfUrl = args;
      } else if (Get.isRegistered<PdfEditController>()) {
        final controller = Get.find<PdfEditController>();
        pdfUrl = controller.effectivePdfUrl.value;
      } else if (Get.isRegistered<PdfDetailController>()) {
        final controller = Get.find<PdfDetailController>();
        pdfUrl = controller.pdfDocument.value?.pdfUrl;
      }

      if (pdfUrl != null &&
          pdfUrl.isNotEmpty &&
          (pdfUrl.startsWith('http://') || pdfUrl.startsWith('https://'))) {
        await _downloadPdfFromUrl(pdfUrl);
        return;
      }

      // 3. Fallback: Create a sample blank test PDF file for testing
      await _createSampleTestPdf();
    } catch (e) {
      setState(() {
        _statusMessage = 'Error loading PDF: $e';
      });
      await _createSampleTestPdf();
    }
  }

  Future<void> _downloadPdfFromUrl(String url) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Downloading PDF for NextGen Editor...';
      _downloadProgress = 0.0;
    });

    try {
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'nextgen_test_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final savePath = '${tempDir.path}/$fileName';

      final client = dio.Dio();
      await client.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      final file = File(savePath);
      if (await file.exists()) {
        setState(() {
          _pdfFile = file;
          _isLoading = false;
        });
      } else {
        await _createSampleTestPdf();
      }
    } catch (e) {
      CustomSnackBar.showError(
        title: 'Download Failed',
        message: 'Could not download remote PDF. Loading sample test document.',
      );
      await _createSampleTestPdf();
    }
  }

  Future<void> _createSampleTestPdf() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Generating Sample PDF for Testing...';
    });

    try {
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/sample_test_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      final PdfDocument document = PdfDocument();
      final PdfPage page1 = document.pages.add();
      final PdfGraphics graphics1 = page1.graphics;

      final PdfFont titleFont = PdfStandardFont(
        PdfFontFamily.helvetica,
        24,
        style: PdfFontStyle.bold,
      );
      final PdfFont bodyFont = PdfStandardFont(PdfFontFamily.helvetica, 14);

      graphics1.drawString(
        'NextGen PDF Editor Test Document',
        titleFont,
        brush: PdfBrushes.darkBlue,
        bounds: const Rect.fromLTWH(20, 40, 500, 40),
      );

      graphics1.drawString(
        'This is a sample document for testing annotations, drawings, highlights, text insertion, and images.',
        bodyFont,
        brush: PdfBrushes.black,
        bounds: const Rect.fromLTWH(20, 100, 460, 100),
      );

      // Add a second page
      final PdfPage page2 = document.pages.add();
      final PdfGraphics graphics2 = page2.graphics;
      graphics2.drawString(
        'Page 2 - Test Content',
        titleFont,
        brush: PdfBrushes.darkGreen,
        bounds: const Rect.fromLTWH(20, 40, 500, 40),
      );

      final List<int> bytes = await document.save();
      document.dispose();

      await file.writeAsBytes(bytes);

      setState(() {
        _pdfFile = file;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Failed to generate test PDF: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('NextGen PDF Editor (Test)'),
          leading: IconButton(
            icon: const Icon(AppAssets.backArrow),
            onPressed: () => Get.back(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                Text(
                  _statusMessage,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_downloadProgress > 0 && _downloadProgress < 1.0) ...[
                  const SizedBox(height: 16),
                  LinearProgressIndicator(value: _downloadProgress),
                  const SizedBox(height: 8),
                  Text(
                    '${(_downloadProgress * 100).toInt()}%',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    if (_pdfFile == null || !_pdfFile!.existsSync()) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('NextGen PDF Editor (Test)'),
          leading: IconButton(
            icon: const Icon(AppAssets.backArrow),
            onPressed: () => Get.back(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(_statusMessage),
              const SizedBox(height: 16),
              CustomButton(
                title: 'Generate Sample Test PDF',
                icon: Icons.refresh_rounded,
                width: 240,
                onPressed: _createSampleTestPdf,
              ),
            ],
          ),
        ),
      );
    }

    return NGPdfEditScreen(
      pdfFile: _pdfFile!,
      draw: true,
      text: true,
      highlight: true,
      underline: true,
      image: true,
      page: true,
    );
  }
}
