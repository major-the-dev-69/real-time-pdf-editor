import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sai_associates/core/network/api_constants.dart';

import 'package:share_plus/share_plus.dart';

import '../../../../core/helper/logger_helper.dart';
import '../../../../core/network/api_services.dart';
import '../../../../widgets/custom_snack_bar.dart';
import '../../model/pdf_document_model.dart';

class PdfDetailController extends GetxController {
  final apiServices = Get.find<ApiServices>();

  final pdfDocument = Rxn<PdfDocumentModel>();
  final isFetchingDetails = false.obs;
  final isDownloading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is String) {
      fetchPdfDetails(args);
    } else if (Get.parameters['id'] != null) {
      fetchPdfDetails(Get.parameters['id']!);
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
      }
    } catch (e) {
      printMessage("⚠️ Error fetching PDF details: $e");
    } finally {
      isFetchingDetails.value = false;
    }
  }

  Future<void> deletePdf(String pdfUuid) async {
    if (pdfUuid.isEmpty) return;

    final endpoint = 'pdfs/$pdfUuid';
    final response = await apiServices.callDeleteApi(
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

  Future<void> copyLink() async {
    final pdf = pdfDocument.value;
    if (pdf == null || pdf.pdfUrl.isEmpty) {
      CustomSnackBar.showError(
        message: 'PDF document URL is invalid or unavailable',
      );
      return;
    }

    try {
      await Clipboard.setData(ClipboardData(text: pdf.pdfUrl));
      CustomSnackBar.showSuccess(
        title: 'Link Copied',
        message: 'PDF link copied to clipboard!',
      );
    } catch (e) {
      printMessage("⚠️ Error copying PDF link: $e");
      CustomSnackBar.showError(message: 'Could not copy PDF document link');
    }
  }

  Future<void> sharePdf() async {
    final pdf = pdfDocument.value;

    if (pdf == null || pdf.pdfUrl.isEmpty) {
      CustomSnackBar.showError(
        message: 'PDF document URL is invalid or unavailable',
      );
      return;
    }

    try {
      final currentRoute = Get.currentRoute;
      final deepLink = '${ApiConstants.baseUrl}$currentRoute?id=${pdf.id}';

      final message =
          '''
    📄 *${pdf.title}*

    Check out this document!

    Link: $deepLink

    Sent via *PBD Group Real Estate App* 🏢
  ''';

      await SharePlus.instance.share(
        ShareParams(text: message, subject: 'PDF Share'),
      );
    } catch (e) {
      printMessage('⚠️ Error sharing PDF: $e');

      CustomSnackBar.showError(message: 'Failed to open share sheet');
    }
  }
}
