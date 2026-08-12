import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/app_routes.dart';
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

  // OTP Timer Countdown
  final resendSeconds = 30.obs;
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
    resendSeconds.value = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds.value > 0) {
        resendSeconds.value--;
      } else {
        timer.cancel();
      }
    });
  }

  void sendOtp() {
    if (!forgotFormKey.currentState!.validate()) {
      return;
    }

    final destination = selectedInputMode.value == 'email'
        ? emailController.text.trim()
        : phoneController.text.trim();

    isLoading.value = true;
    Future.delayed(const Duration(milliseconds: 600), () {
      isLoading.value = false;
      startResendTimer();
      CustomSnackBar.showSuccess(
        title: 'OTP Sent',
        message: 'Verification code sent to $destination',
      );
    });
  }

  void verifyOtpAndContinue() {
    final enteredPin = otpController.text.trim();
    if (enteredPin.length < 4) {
      CustomSnackBar.showError(
        title: 'Invalid OTP',
        message: 'Please enter a valid 4-digit OTP code',
      );
      return;
    }

    isLoading.value = true;
    Future.delayed(const Duration(milliseconds: 600), () {
      isLoading.value = false;
      Get.back(); // Close Bottom Sheet
      Get.toNamed(AppRoutes.resetPassword);
    });
  }

  void resetPassword() {
    if (!resetFormKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;
    Future.delayed(const Duration(milliseconds: 800), () {
      isLoading.value = false;
      CustomSnackBar.showSuccess(
        title: 'Password Reset Successful',
        message: 'Your password has been updated. Please sign in with your new password.',
      );
      Get.offAllNamed(AppRoutes.login);
    });
  }
}
