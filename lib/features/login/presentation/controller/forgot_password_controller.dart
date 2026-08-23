import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_services.dart';
import '../../../../widgets/custom_snack_bar.dart';

class ForgotPasswordController extends GetxController {
  final forgotFormKey = GlobalKey<FormState>();
  final resetFormKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Input Mode: 'email' or 'phone'
  final selectedInputMode = 'email'.obs;
  final isLoading = false.obs;
  final isVerifyingOtp = false.obs;
  final isResettingPassword = false.obs;

  // OTP Timer Countdown
  final resendSeconds = 0.obs;
  Timer? _timer;

  @override
  void onClose() {
    _timer?.cancel();
    emailController.dispose();
    phoneController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void switchInputMode(String mode) {
    selectedInputMode.value = mode;
  }

  void startResendTimer() {
    _timer?.cancel();
    resendSeconds.value = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds.value > 0) {
        resendSeconds.value--;
      } else {
        timer.cancel();
      }
    });
  }

  /// 1. Send OTP API Call (POST /forgot-password/send-otp)
  Future<bool> sendOtp() async {
    if (!forgotFormKey.currentState!.validate()) {
      return false;
    }

    final email = emailController.text.trim();
    if (email.isEmpty) {
      CustomSnackBar.showError(
        title: 'Error',
        message: 'Please enter your email address',
      );
      return false;
    }

    isLoading.value = true;
    try {
      final req = {'email': email};
      final response = await Get.find<ApiServices>().callPostApi(
        ApiConstants.sendOtp,
        req: req,
        isUserRequired: false,
      );

      if (response.status) {
        startResendTimer();
        otpController.clear();
        CustomSnackBar.showSuccess(
          title: 'OTP Sent',
          message: response.message.isNotEmpty
              ? response.message
              : 'OTP sent successfully to $email',
        );
        return true;
      } else {
        CustomSnackBar.showError(
          title: 'Failed to Send OTP',
          message: response.message,
        );
        return false;
      }
    } catch (e) {
      CustomSnackBar.showError(
        title: 'Error',
        message: 'An unexpected error occurred while sending OTP: $e',
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// 2. Verify OTP API Call (POST /forgot-password/verify-otp)
  Future<void> verifyOtpAndContinue() async {
    final email = emailController.text.trim();
    final enteredPin = otpController.text.trim();

    if (enteredPin.length != 6) {
      CustomSnackBar.showError(
        title: 'Invalid OTP',
        message: 'Please enter a valid 6-digit OTP code',
      );
      return;
    }

    isVerifyingOtp.value = true;
    try {
      final req = {
        'email': email,
        'otp': enteredPin,
      };

      final response = await Get.find<ApiServices>().callPostApi(
        ApiConstants.verifyOtp,
        req: req,
        isUserRequired: false,
      );

      if (response.status) {
        if (Get.isBottomSheetOpen == true) {
          Get.back(); // Close OTP Bottom Sheet
        }
        CustomSnackBar.showSuccess(
          title: 'OTP Verified',
          message: response.message.isNotEmpty
              ? response.message
              : 'OTP verified successfully',
        );
        Get.toNamed(AppRoutes.resetPassword);
      } else {
        CustomSnackBar.showError(
          title: 'Verification Failed',
          message: response.message,
        );
      }
    } catch (e) {
      CustomSnackBar.showError(
        title: 'Error',
        message: 'An unexpected error occurred while verifying OTP: $e',
      );
    } finally {
      isVerifyingOtp.value = false;
    }
  }

  /// 3. Reset Password API Call (POST /forgot-password/reset)
  Future<void> resetPassword() async {
    if (!resetFormKey.currentState!.validate()) {
      return;
    }

    final email = emailController.text.trim();
    final newPassword = newPasswordController.text.trim();

    isResettingPassword.value = true;
    try {
      final req = {
        'email': email,
        'password': newPassword,
      };

      final response = await Get.find<ApiServices>().callPostApi(
        ApiConstants.resetPassword,
        req: req,
        isUserRequired: false,
      );

      if (response.status) {
        CustomSnackBar.showSuccess(
          title: 'Success',
          message: response.message.isNotEmpty
              ? response.message
              : 'Password reset successfully',
        );
        Get.offAllNamed(AppRoutes.login);
      } else {
        CustomSnackBar.showError(
          title: 'Reset Failed',
          message: response.message,
        );
      }
    } catch (e) {
      CustomSnackBar.showError(
        title: 'Error',
        message: 'An unexpected error occurred while resetting password: $e',
      );
    } finally {
      isResettingPassword.value = false;
    }
  }
}
