import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_services.dart';
import '../../../../widgets/custom_snack_bar.dart';
import '../../model/project_site_model.dart';
import '../../model/site_request_model.dart';

class SiteFormController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final descriptionController = TextEditingController();

  final status = true.obs;
  final isLoading = false.obs;

  final projectId = ''.obs;
  final siteUuid = ''.obs;
  final isEditMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkArguments();
  }

  void _checkArguments() {
    final args = Get.arguments;
    if (args == null) return;

    if (args is Map<String, dynamic>) {
      projectId.value = args['projectId']?.toString() ?? args['project_id']?.toString() ?? '';

      final siteObj = args['site'];
      if (siteObj != null) {
        isEditMode.value = true;
        if (siteObj is ProjectSiteModel) {
          siteUuid.value = siteObj.uuid;
          nameController.text = siteObj.name;
          codeController.text = siteObj.code;
          descriptionController.text = siteObj.description;
          status.value = siteObj.status;
          if (projectId.value.isEmpty) {
            projectId.value = siteObj.projectId;
          }
        } else if (siteObj is Map<String, dynamic>) {
          siteUuid.value = siteObj['uuid']?.toString() ?? siteObj['id']?.toString() ?? '';
          nameController.text = siteObj['name']?.toString() ?? '';
          codeController.text = siteObj['code']?.toString() ?? '';
          descriptionController.text = siteObj['description']?.toString() ?? '';
          status.value = siteObj['status'] == true || siteObj['status']?.toString().toLowerCase() == 'true';
        }
      }
    } else if (args is String) {
      projectId.value = args;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    codeController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  void toggleStatus(bool? value) {
    status.value = value ?? true;
  }

  Future<void> submitSite() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    final requestModel = SiteRequestModel(
      name: nameController.text.trim(),
      code: codeController.text.trim(),
      description: descriptionController.text.trim(),
      status: status.value,
    );

    final apiServices = Get.find<ApiServices>();
    final ResponseModel response;

    if (isEditMode.value && siteUuid.value.isNotEmpty) {
      final endpoint = '${ApiConstants.sites}/${siteUuid.value}';
      response = await apiServices.callPutApi(
        endpoint,
        req: requestModel.toJson(),
        isUserRequired: true,
      );
    } else {
      if (projectId.value.isEmpty) {
        CustomSnackBar.showError(message: "Project ID is missing");
        isLoading.value = false;
        return;
      }
      final endpoint = '${ApiConstants.projects}/${projectId.value}/sites';
      response = await apiServices.callPostApi(
        endpoint,
        req: requestModel.toJson(),
        isUserRequired: true,
      );
    }

    isLoading.value = false;

    if (response.status) {
      Get.back(result: true);
      CustomSnackBar.showSuccess(message: response.message);
    } else {
      CustomSnackBar.showError(message: response.message);
    }
  }
}
