import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_assets.dart';
import '../../../../widgets/custom_buttons.dart';
import '../../../../widgets/custom_text_field.dart';
import '../controller/forgot_password_controller.dart';
import '../widget/otp_verification_bottom_sheet.dart';

class ForgotPasswordPage extends GetView<ForgotPasswordController> {
  const ForgotPasswordPage({super.key});

  void _openOtpBottomSheet(BuildContext context) {
    if (!controller.forgotFormKey.currentState!.validate()) {
      return;
    }
    controller.sendOtp();
    Get.bottomSheet(
      OtpVerificationBottomSheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final textTheme = context.textTheme;
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      body: Stack(
        children: [
          // Top-Left Curved Orange Shape Accent
          Positioned(
            top: 0,
            left: 0,
            child: ClipPath(
              clipper: _TopLeftOrangeCornerClipper(),
              child: Container(
                width: 140,
                height: 180,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFE64A19), Color(0xFFD84315)],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: -30,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.6,
              child: Image.asset(AppAssets.imgCityWatermark),
            ),
          ),
          // Main Scrollable Body Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Form(
                  key: controller.forgotFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Row: Back Button (Top-Left) & Logo (Top-Right)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () => Get.back(),
                            icon: const Icon(AppAssets.backArrow),
                            color: Colors.white,
                            style: IconButton.styleFrom(
                              backgroundColor: primaryColor.withValues(
                                alpha: 0.25,
                              ),
                            ),
                          ),
                          Image.asset(
                            AppAssets.imgAppLogo,
                            height: Get.height * 0.12,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Title & Accent Underline
                      Text(
                        'Forgot Password?',
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),

                      Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Text(
                        'Select how you want to receive your OTP verification code',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.65),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Main White Card Container with Floating Avatar Badge
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topCenter,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 28),
                            padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.black.withValues(alpha: 0.04),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Segmented Tab Toggle (Email vs Phone Number)
                                Obx(
                                  () => Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => controller
                                                .switchInputMode('email'),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    controller
                                                            .selectedInputMode
                                                            .value ==
                                                        'email'
                                                    ? Colors.white
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                boxShadow:
                                                    controller
                                                            .selectedInputMode
                                                            .value ==
                                                        'email'
                                                    ? [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withValues(
                                                                alpha: 0.04,
                                                              ),
                                                          blurRadius: 4,
                                                          offset: const Offset(
                                                            0,
                                                            2,
                                                          ),
                                                        ),
                                                      ]
                                                    : null,
                                              ),
                                              child: Text(
                                                'Email Address',
                                                textAlign: TextAlign.center,
                                                style: textTheme.bodyMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          controller
                                                                  .selectedInputMode
                                                                  .value ==
                                                              'email'
                                                          ? primaryColor
                                                          : colorScheme
                                                                .onSurface
                                                                .withValues(
                                                                  alpha: 0.6,
                                                                ),
                                                      fontSize: 13,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => controller
                                                .switchInputMode('phone'),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    controller
                                                            .selectedInputMode
                                                            .value ==
                                                        'phone'
                                                    ? Colors.white
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                boxShadow:
                                                    controller
                                                            .selectedInputMode
                                                            .value ==
                                                        'phone'
                                                    ? [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withValues(
                                                                alpha: 0.04,
                                                              ),
                                                          blurRadius: 4,
                                                          offset: const Offset(
                                                            0,
                                                            2,
                                                          ),
                                                        ),
                                                      ]
                                                    : null,
                                              ),
                                              child: Text(
                                                'Phone Number',
                                                textAlign: TextAlign.center,
                                                style: textTheme.bodyMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          controller
                                                                  .selectedInputMode
                                                                  .value ==
                                                              'phone'
                                                          ? primaryColor
                                                          : colorScheme
                                                                .onSurface
                                                                .withValues(
                                                                  alpha: 0.6,
                                                                ),
                                                      fontSize: 13,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Dynamic Input Field
                                Obx(
                                  () =>
                                      controller.selectedInputMode.value ==
                                          'email'
                                      ? CustomTextField(
                                          controller:
                                              controller.emailController,
                                          labelText: 'Email Address',
                                          hintText:
                                              'Enter your registered email',
                                          prefixIcon: AppAssets.icEmail,
                                          prefixIconColor: primaryColor,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          validator: (value) {
                                            if (value == null ||
                                                value.trim().isEmpty) {
                                              return 'Please enter your Email Address';
                                            }
                                            if (!GetUtils.isEmail(
                                              value.trim(),
                                            )) {
                                              return 'Please enter a valid Email Address';
                                            }
                                            return null;
                                          },
                                        )
                                      : CustomTextField(
                                          controller:
                                              controller.phoneController,
                                          labelText: 'Phone Number',
                                          hintText: 'Enter your mobile number',
                                          prefixIcon: AppAssets.icPhone,
                                          prefixIconColor: primaryColor,
                                          keyboardType: TextInputType.phone,
                                          validator: (value) {
                                            if (value == null ||
                                                value.trim().isEmpty) {
                                              return 'Please enter your Phone Number';
                                            }
                                            if (value.trim().length < 10) {
                                              return 'Please enter a valid 10-digit Phone Number';
                                            }
                                            return null;
                                          },
                                        ),
                                ),
                                const SizedBox(height: 28),

                                // Send OTP Button
                                Obx(
                                  () => CustomButton(
                                    title: 'SEND OTP',
                                    height: 52,
                                    borderRadius: 14,
                                    backgroundColor: primaryColor,
                                    isLoading: controller.isLoading.value,
                                    onPressed: () =>
                                        _openOtpBottomSheet(context),
                                    trailingWidget: Container(
                                      width: 36,
                                      height: 36,
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
                          ),

                          // Floating Lock Avatar Badge
                          Positioned(
                            top: 0,
                            child: Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: primaryColor.withValues(alpha: 0.15),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  AppAssets.icLock,
                                  color: primaryColor,
                                  size: 26,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Orange Wave Footer Banner
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 64,
            child: ClipPath(
              clipper: _BottomOrangeFooterClipper(),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE64A19), Color(0xFFD84315)],
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Text(
                      'PBD Group Real Estate Portal',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        letterSpacing: 0.4,
                      ),
                    ),
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

class _TopLeftOrangeCornerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.8, 0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _BottomOrangeFooterClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.35);

    final controlPoint = Offset(size.width * 0.5, -size.height * 0.1);
    final endPoint = Offset(size.width, size.height * 0.35);

    path.quadraticBezierTo(
      controlPoint.dx,
      controlPoint.dy,
      endPoint.dx,
      endPoint.dy,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
