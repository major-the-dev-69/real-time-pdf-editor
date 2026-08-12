import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/helper/logger_helper.dart';
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

    try {
      final apiService = Get.find<ApiServices>();

      final enteredUsername = usernameController.text.trim();
      final enteredPassword = passwordController.text.trim();

      final response = await apiService.callPostApi(
        ApiConstants.getLogin,
        req: {
          "Username": enteredUsername,
          "Password": enteredPassword,
        },
      );

      isLoading.value = false;

      String returnedUid = '';
      String returnedRole = '';
      bool isStatusTrue = false;

      final data = response.data;
      if (data != null) {
        List responseList = [];
        if (data is Map && data.containsKey('Response') && data['Response'] is List) {
          responseList = data['Response'] as List;
        } else if (data is List) {
          responseList = data;
        } else if (data is Map) {
          responseList = [data];
        }

        if (responseList.isNotEmpty && responseList[0] is Map) {
          final firstItem = Map<String, dynamic>.from(responseList[0] as Map);
          returnedUid = (firstItem['uid'] ?? firstItem['username'] ?? '').toString().trim();
          returnedRole = (firstItem['Role'] ?? firstItem['role'] ?? firstItem['RoleId'] ?? firstItem['roleid'] ?? '').toString().trim();
          final statusVal = firstItem['status'];
          if (statusVal == true || statusVal.toString().toLowerCase() == 'true') {
            isStatusTrue = true;
          }
        }
      }

      final isUidMatch = returnedUid.isNotEmpty &&
          returnedUid.toLowerCase() == enteredUsername.toLowerCase();

      if (isUidMatch || isStatusTrue) {
        final uidToSave = returnedUid.isNotEmpty ? returnedUid : enteredUsername;
        if (returnedRole.isEmpty && uidToSave.toUpperCase().startsWith('AMC')) {
          returnedRole = '3';
        }

        await SharedPrefManager().saveToken(uidToSave);
        await SharedPrefManager().saveRole(returnedRole);

        CustomSnackBar.showSuccess(
          title: 'Welcome Back!',
          message: 'Logged in successfully as $uidToSave',
        );

        if (returnedRole == '3' || uidToSave.toUpperCase().startsWith('AMC')) {
          Get.offAllNamed(AppRoutes.customerDashboard);
        } else {
          Get.offAllNamed(AppRoutes.dashboard);
        }
      } else {
        CustomSnackBar.showError(
          title: 'Login Failed',
          message: 'Invalid Username or Password',
        );
      }
    } catch (e, stk) {
      printMessage("login $e $stk ");
      isLoading.value = false;
      CustomSnackBar.showError(
        title: 'Login Error',
        message: 'Unable to process login. Please try again.',
      );
    }
  }
}
