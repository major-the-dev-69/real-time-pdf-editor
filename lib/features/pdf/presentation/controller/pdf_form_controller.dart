import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/helper/logger_helper.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_services.dart';
import '../../../../widgets/custom_snack_bar.dart';
import '../../../project/model/real_estate_project_model.dart';
import '../../../site/model/project_site_model.dart';
import '../../model/pdf_document_model.dart';

class PdfFormController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final categoryController = TextEditingController();
  final descriptionController = TextEditingController();

  final status = true.obs;
  final isLoading = false.obs;

  final projectsList = <RealEstateProject>[].obs;
  final sitesList = <ProjectSiteModel>[].obs;

  final selectedProjectId = ''.obs;
  final selectedSiteId = ''.obs;

  final isLoadingProjects = false.obs;
  final isLoadingSites = false.obs;

  final siteId = ''.obs;
  final pdfUuid = ''.obs;
  final isEditMode = false.obs;

  final selectedFile = Rxn<File>();

  @override
  void onInit() {
    super.onInit();
    _checkArguments();
    fetchProjects();
  }

  void _checkArguments() {
    final args = Get.arguments;
    if (args == null) return;

    if (args is Map<String, dynamic>) {
      siteId.value =
          args['siteId']?.toString() ?? args['site_id']?.toString() ?? '';
      selectedSiteId.value = siteId.value;
      selectedProjectId.value =
          args['projectId']?.toString() ?? args['project_id']?.toString() ?? '';

      final pdfObj = args['pdf'];
      if (pdfObj != null) {
        isEditMode.value = true;
        if (pdfObj is PdfDocumentModel) {
          pdfUuid.value = pdfObj.id;
          titleController.text = pdfObj.title;
          categoryController.text = pdfObj.category;
          descriptionController.text = pdfObj.description;
          status.value = pdfObj.status;
          if (pdfObj.projectId.isNotEmpty) {
            selectedProjectId.value = pdfObj.projectId;
          }
          if (pdfObj.siteId.isNotEmpty) {
            selectedSiteId.value = pdfObj.siteId;
            siteId.value = pdfObj.siteId;
          }
        } else if (pdfObj is Map<String, dynamic>) {
          pdfUuid.value =
              pdfObj['uuid']?.toString() ?? pdfObj['id']?.toString() ?? '';
          titleController.text = pdfObj['title']?.toString() ?? '';
          categoryController.text = pdfObj['category']?.toString() ?? '';
          descriptionController.text = pdfObj['description']?.toString() ?? '';
          status.value =
              pdfObj['status'] == true || pdfObj['status']?.toString() == '1';

          final pId =
              pdfObj['projectId']?.toString() ??
              pdfObj['project_id']?.toString() ??
              (pdfObj['project'] is Map
                  ? pdfObj['project']['uuid']?.toString() ??
                        pdfObj['project']['id']?.toString()
                  : null);
          if (pId != null && pId.isNotEmpty) {
            selectedProjectId.value = pId;
          }

          final sId =
              pdfObj['siteId']?.toString() ??
              pdfObj['site_id']?.toString() ??
              (pdfObj['site'] is Map
                  ? pdfObj['site']['uuid']?.toString() ??
                        pdfObj['site']['id']?.toString()
                  : null);
          if (sId != null && sId.isNotEmpty) {
            selectedSiteId.value = sId;
            siteId.value = sId;
          }
        }
      }
    } else if (args is PdfDocumentModel) {
      isEditMode.value = true;
      pdfUuid.value = args.id;
      titleController.text = args.title;
      categoryController.text = args.category;
      descriptionController.text = args.description;
      status.value = args.status;
      selectedProjectId.value = args.projectId;
      selectedSiteId.value = args.siteId;
      siteId.value = args.siteId;
    }
  }

  Future<void> fetchProjects() async {
    isLoadingProjects.value = true;
    try {
      final response = await Get.find<ApiServices>().callGetApi(
        ApiConstants.projects,
        isUserRequired: true,
      );

      if (response.status && response.data != null) {
        final data = response.data;
        final rawProjects = data['projects'];
        if (rawProjects is List) {
          final fetched = rawProjects
              .map(
                (item) =>
                    RealEstateProject.fromJson(item as Map<String, dynamic>),
              )
              .toList();
          projectsList.assignAll(fetched);
        }
      }

      if (selectedProjectId.value.isNotEmpty) {
        await fetchSites(selectedProjectId.value);
      } else if (projectsList.isNotEmpty) {
        selectedProjectId.value = projectsList.first.id;
        await fetchSites(selectedProjectId.value);
      }
    } catch (e) {
      printMessage("⚠️ Error fetching projects in PdfFormController: $e");
    } finally {
      isLoadingProjects.value = false;
    }
  }

  Future<void> fetchSites(String targetProjectId) async {
    if (targetProjectId.isEmpty) {
      sitesList.clear();
      return;
    }

    isLoadingSites.value = true;
    try {
      final endpoint = '${ApiConstants.projects}/$targetProjectId/sites';
      final response = await Get.find<ApiServices>().callGetApi(
        endpoint,
        isUserRequired: true,
      );

      if (response.status && response.data != null) {
        final data = response.data;
        final rawSites = data['sites'];
        if (rawSites is List) {
          final fetched = rawSites
              .map((e) => ProjectSiteModel.fromJson(e as Map<String, dynamic>))
              .toList();
          sitesList.assignAll(fetched);
        }
      } else {
        sitesList.clear();
      }

      if (selectedSiteId.value.isNotEmpty) {
        final exists = sitesList.any((s) => s.uuid == selectedSiteId.value);
        if (!exists && sitesList.isNotEmpty) {
          selectedSiteId.value = sitesList.first.uuid;
        }
      } else if (sitesList.isNotEmpty) {
        selectedSiteId.value = sitesList.first.uuid;
      }
      siteId.value = selectedSiteId.value;
    } catch (e) {
      printMessage("⚠️ Error fetching sites in PdfFormController: $e");
      sitesList.clear();
    } finally {
      isLoadingSites.value = false;
    }
  }

  void onProjectChanged(String? newProjectId) {
    if (newProjectId == null || newProjectId == selectedProjectId.value) return;
    selectedProjectId.value = newProjectId;
    selectedSiteId.value = '';
    siteId.value = '';
    sitesList.clear();
    fetchSites(newProjectId);
  }

  void onSiteChanged(String? newSiteId) {
    selectedSiteId.value = newSiteId ?? '';
    siteId.value = selectedSiteId.value;
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
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result.first.path != null) {
        selectedFile.value = File(result.first.path!);
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

    final targetSiteUuid = selectedSiteId.value.isNotEmpty
        ? selectedSiteId.value
        : siteId.value;

    if (!isEditMode.value) {
      if (selectedProjectId.value.isEmpty) {
        CustomSnackBar.showError(message: "Please select a project");
        return;
      }
      if (targetSiteUuid.isEmpty) {
        CustomSnackBar.showError(message: "Please select a site");
        return;
      }
      if (selectedFile.value == null) {
        CustomSnackBar.showError(message: "Please select a PDF file to upload");
        return;
      }
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
        final endpoint = 'sites/$targetSiteUuid/pdfs';
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
