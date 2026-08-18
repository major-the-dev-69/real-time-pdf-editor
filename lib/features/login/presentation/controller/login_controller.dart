import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_services.dart';
import '../../../../db/shared_pref_manager.dart';
import '../../../../widgets/custom_snack_bar.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final rememberMe = false.obs;
  final isLoading = false.obs;

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    final req = {
      'email': usernameController.text.trim(),
      'password': passwordController.text.trim(),
    };

    final response = await Get.find<ApiServices>().callPostApi(
      ApiConstants.login,
      req: req,
      isUserRequired: false,
    );

    isLoading.value = false;

    if (response.status) {
      final data = response.data;
      if (data != null && data['token'] != null) {
        await SharedPrefManager().saveToken(data['token'].toString());
        if (data['user'] != null && data['user']['role'] != null) {
          await SharedPrefManager().saveRole(data['user']['role'].toString());
        }
      }
      
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      CustomSnackBar.showError(message: response.message);
    }
  }
}
