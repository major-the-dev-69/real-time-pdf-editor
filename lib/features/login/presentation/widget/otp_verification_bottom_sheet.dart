import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/utils/app_assets.dart';
import '../../../../widgets/custom_buttons.dart';
import '../controller/forgot_password_controller.dart';

class OtpVerificationBottomSheet extends StatelessWidget {
  final ForgotPasswordController controller;

  const OtpVerificationBottomSheet({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final textTheme = context.textTheme;
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: textTheme.headlineSmall?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.8),
          width: 1.5,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(color: primaryColor, width: 2),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: primaryColor.withValues(alpha: 0.05),
        border: Border.all(color: primaryColor.withValues(alpha: 0.5), width: 1.5),
      ),
    );

    final destination = controller.selectedInputMode.value == 'email'
        ? controller.emailController.text.trim()
        : controller.phoneController.text.trim();

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle Accent
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header Icon & Title
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    AppAssets.icLock,
                    color: primaryColor,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verify OTP Code',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sent to $destination',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Pinput Field
          Center(
            child: Pinput(
              length: 4,
              controller: controller.otpController,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              submittedPinTheme: submittedPinTheme,
              autofocus: true,
              showCursor: true,
              onCompleted: (pin) => controller.verifyOtpAndContinue(),
            ),
          ),
          const SizedBox(height: 24),

          // Resend Timer & Button
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't receive code? ",
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                if (controller.resendSeconds.value > 0)
                  Text(
                    'Resend in ${controller.resendSeconds.value}s',
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  )
                else
                  TextButton(
                    onPressed: controller.sendOtp,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Resend OTP',
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Verify Button
          Obx(
            () => CustomButton(
              title: 'VERIFY & CONTINUE',
              height: 50,
              borderRadius: 14,
              backgroundColor: primaryColor,
              isLoading: controller.isLoading.value,
              onPressed: controller.verifyOtpAndContinue,
              trailingWidget: Container(
                width: 34,
                height: 34,
                margin: const EdgeInsets.only(right: 6),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    AppAssets.icArrowRight,
                    color: primaryColor,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
