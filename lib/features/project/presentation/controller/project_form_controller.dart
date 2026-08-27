import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_services.dart';
import '../../../../widgets/custom_snack_bar.dart';
import '../../model/real_estate_project_model.dart';
import '../../model/project_request_model.dart';

class ProjectFormController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final builderNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();

  final status = true.obs;
  final isLoading = false.obs;
  final isEditMode = false.obs;
  final editingProjectId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _checkArguments();
  }

  void _checkArguments() {
    final args = Get.arguments;
    if (args == null) return;

    if (args is RealEstateProject) {
      isEditMode.value = true;
      editingProjectId.value = args.id;
      titleController.text = args.title;
      locationController.text = args.location;
      builderNameController.text = '';
      descriptionController.text = '';
      status.value = args.status.toLowerCase() != 'inactive';
    } else if (args is Map<String, dynamic>) {
      isEditMode.value = true;
      editingProjectId.value = args['id']?.toString() ?? '';
      titleController.text = args['title']?.toString() ?? '';
      builderNameController.text =
          args['builder_name']?.toString() ??
          args['builderName']?.toString() ??
          '';
      descriptionController.text = args['description']?.toString() ?? '';
      locationController.text = args['location']?.toString() ?? '';
      status.value =
          args['status'] == true ||
          args['status']?.toString().toLowerCase() == 'true';
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    builderNameController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    super.onClose();
  }

  void toggleStatus(bool? value) {
    status.value = value ?? true;
  }

  Future<void> submitProject() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    final requestModel = ProjectRequestModel(
      title: titleController.text.trim(),
      builderName: builderNameController.text.trim(),
      description: descriptionController.text.trim(),
      location: locationController.text.trim(),
      status: status.value,
    );

    final apiServices = Get.find<ApiServices>();
    final ResponseModel response;

    if (isEditMode.value && editingProjectId.value.isNotEmpty) {
      response = await apiServices.callPutApi(
        '${ApiConstants.projects}/${editingProjectId.value}',
        req: requestModel.toJson(),
        isUserRequired: true,
      );
    } else {
      response = await apiServices.callPostApi(
        ApiConstants.projects,
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
