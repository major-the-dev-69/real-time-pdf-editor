import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sai_associates/core/network/api_constants.dart';
import 'package:sai_associates/core/network/api_services.dart';
import 'package:sai_associates/widgets/custom_snack_bar.dart';

import '../../model/user_model.dart';
import 'user_controller.dart';

class UserFormController extends GetxController {
  final ApiServices _apiServices = Get.find<ApiServices>();

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();

  final selectedRole = 'admin'.obs;
  final status = true.obs;

  final isEditMode = false.obs;
  final editingUserId = 0.obs;
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  final List<String> roleOptions = ['admin', 'viewer'];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is UserModel) {
      initForm(args);
    } else if (args is Map<String, dynamic>) {
      final user = UserModel.fromJson(args);
      initForm(user);
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void initForm(UserModel user) {
    isEditMode.value = true;
    editingUserId.value = user.id ?? 0;
    nameController.text = user.name;
    emailController.text = user.email;
    mobileController.text = user.mobile;
    selectedRole.value = user.role.isNotEmpty ? user.role : 'admin';
    status.value = user.status;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleStatus(bool val) {
    status.value = val;
  }

  Future<void> saveUser() async {
    if (!formKey.currentState!.validate()) return;

    if (!isEditMode.value && passwordController.text.trim().isEmpty) {
      CustomSnackBar.showError(message: 'Password is required for new users.');
      return;
    }

    isLoading.value = true;

    try {
      if (isEditMode.value) {
        final endpoint = '${ApiConstants.users}/${editingUserId.value}';
        final payload = {
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'mobile': mobileController.text.trim(),
          'role': selectedRole.value,
          'status': status.value,
          if (passwordController.text.trim().isNotEmpty)
            'password': passwordController.text.trim(),
        };

        final response = await _apiServices.callPutApi(endpoint, req: payload);

        isLoading.value = false;

        if (response.status) {
          Get.back(result: true);
          CustomSnackBar.showSuccess(message: response.message);
          if (Get.isRegistered<UserController>()) {
            Get.find<UserController>().fetchUsers(isRefresh: true);
          }
        } else {
          CustomSnackBar.showError(message: response.message);
        }
      } else {
        final payload = {
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'mobile': mobileController.text.trim(),
          'password': passwordController.text.trim(),
          'role': selectedRole.value,
        };

        final response = await _apiServices.callPostApi(
          ApiConstants.users,
          req: payload,
        );

        isLoading.value = false;

        if (response.status) {
          CustomSnackBar.showSuccess(message: response.message);
          if (Get.isRegistered<UserController>()) {
            Get.find<UserController>().fetchUsers(isRefresh: true);
          }
          Get.back(result: true);
        } else {
          CustomSnackBar.showError(message: response.message);
        }
      }
    } catch (e) {
      isLoading.value = false;
      CustomSnackBar.showError(message: 'An unexpected error occurred: $e');
    }
  }
}
