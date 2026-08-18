import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/api_services.dart';
import '../../../../widgets/custom_snack_bar.dart';
import '../../model/pdf_document_model.dart';

class PdfFormController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final categoryController = TextEditingController();
  final descriptionController = TextEditingController();

  final status = true.obs;
  final isLoading = false.obs;

  final siteId = ''.obs;
  final pdfUuid = ''.obs;
  final isEditMode = false.obs;

  final selectedFile = Rxn<File>();

  @override
  void onInit() {
    super.onInit();
    _checkArguments();
  }

  void _checkArguments() {
    final args = Get.arguments;
    if (args == null) return;

    if (args is Map<String, dynamic>) {
      siteId.value = args['siteId']?.toString() ?? args['site_id']?.toString() ?? '';

      final pdfObj = args['pdf'];
      if (pdfObj != null) {
        isEditMode.value = true;
        if (pdfObj is PdfDocumentModel) {
          pdfUuid.value = pdfObj.id;
          titleController.text = pdfObj.title;
          categoryController.text = pdfObj.category;
          descriptionController.text = pdfObj.description;
          status.value = pdfObj.status;
          if (siteId.value.isEmpty) {
            siteId.value = pdfObj.siteId;
          }
        } else if (pdfObj is Map<String, dynamic>) {
          pdfUuid.value = pdfObj['uuid']?.toString() ?? pdfObj['id']?.toString() ?? '';
          titleController.text = pdfObj['title']?.toString() ?? '';
          categoryController.text = pdfObj['category']?.toString() ?? '';
          descriptionController.text = pdfObj['description']?.toString() ?? '';
          status.value = pdfObj['status'] == true || pdfObj['status']?.toString() == '1';
        }
      }
    } else if (args is PdfDocumentModel) {
      isEditMode.value = true;
      pdfUuid.value = args.id;
      titleController.text = args.title;
      categoryController.text = args.category;
      descriptionController.text = args.description;
      status.value = args.status;
      siteId.value = args.siteId;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    categoryController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  void toggleStatus(bool? value) {
    status.value = value ?? true;
  }

  Future<void> pickPdfFile() async {
    try {
      final picker = ImagePicker();
      final pickedMedia = await picker.pickMedia();
      if (pickedMedia != null) {
        selectedFile.value = File(pickedMedia.path);
      }
    } catch (e) {
      CustomSnackBar.showError(message: "Failed to select file: $e");
    }
  }

  void clearSelectedFile() {
    selectedFile.value = null;
  }

  Future<void> submitPdf() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (!isEditMode.value && selectedFile.value == null) {
      CustomSnackBar.showError(message: "Please select a PDF file to upload");
      return;
    }

    if (!isEditMode.value && siteId.value.isEmpty) {
      CustomSnackBar.showError(message: "Site ID is required");
      return;
    }

    isLoading.value = true;

    try {
      final Map<String, dynamic> formMap = {
        'title': titleController.text.trim(),
        'category': categoryController.text.trim(),
        'description': descriptionController.text.trim(),
        'status': status.value ? "1" : "0",
      };

      if (isEditMode.value) {
        formMap['_method'] = 'PUT';
      }

      if (selectedFile.value != null) {
        formMap['pdf_file'] = await dio.MultipartFile.fromFile(
          selectedFile.value!.path,
          filename: selectedFile.value!.path.split('/').last,
        );
      }

      final formData = dio.FormData.fromMap(formMap);
      final apiServices = Get.find<ApiServices>();
      final ResponseModel response;

      if (isEditMode.value && pdfUuid.value.isNotEmpty) {
        final endpoint = 'pdfs/${pdfUuid.value}';
        response = await apiServices.callPostApi(
          endpoint,
          multipartRequest: formData,
          isUserRequired: true,
        );
      } else {
        final endpoint = 'sites/${siteId.value}/pdfs';
        response = await apiServices.callPostApi(
          endpoint,
          multipartRequest: formData,
          isUserRequired: true,
        );
      }

      if (response.status) {
        Get.back(result: true);
        CustomSnackBar.showSuccess(message: response.message);
      } else {
        CustomSnackBar.showError(message: response.message);
      }
    } catch (e) {
      CustomSnackBar.showError(message: "Error submitting PDF: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
