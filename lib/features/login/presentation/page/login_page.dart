import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../widgets/city_watermark_widget.dart';
import '../../../../widgets/custom_buttons.dart';
import '../../../../widgets/custom_text_field.dart';
import '../controller/login_controller.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final textTheme = context.textTheme;
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;

    return Scaffold(
      body: Stack(
        children: [
          // Top-Left Curved Decorative Orange Shape
          Positioned(
            top: 0,
            left: 0,
            child: ClipPath(
              clipper: TopLeftOrangeCornerClipper(),
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

          // Faint City Skyline Watermark in Header Background
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
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Header Section: PBD Group Logo at Top-Right
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4, top: 4),
                          child: Hero(
                            tag: 'app_logo_hero',
                            child: Image.asset(
                              AppAssets.imgAppLogo,
                              height: Get.height * 0.1,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Welcome Back Header & Subtitle
                      Text(
                        'Welcome Back!',
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Primary Orange Rounded Bar Accent Underneath "Welcome Back!"
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
                        'Sign in to access your real estate dashboard',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.65),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Login Card with Floating Top User Avatar Badge
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topCenter,
                        children: [
                          // White Card Container
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
                                CustomTextField(
                                  controller: controller.usernameController,
                                  labelText: 'Username',
                                  hintText: 'Enter your username',
                                  prefixIcon: AppAssets.icUser,
                                  prefixIconColor: primaryColor,
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your Username / ID';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                CustomTextField(
                                  controller: controller.passwordController,
                                  labelText: 'Password',
                                  hintText: 'Enter your password',
                                  prefixIcon: AppAssets.icLock,
                                  prefixIconColor: primaryColor,
                                  isPassword: true,
                                  textInputAction: TextInputAction.done,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your Password';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Remember Me Checkbox & Forgot Password Row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Obx(
                                      () => Row(
                                        children: [
                                          SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: Checkbox(
                                              value:
                                                  controller.rememberMe.value,
                                              onChanged:
                                                  controller.toggleRememberMe,
                                              activeColor: primaryColor,
                                              side: BorderSide(
                                                color: colorScheme.onSurface
                                                    .withValues(alpha: 0.4),
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Remember Me',
                                            style: textTheme.bodyMedium
                                                ?.copyWith(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: colorScheme.onSurface
                                                      .withValues(alpha: 0.75),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Get.toNamed(AppRoutes.forgotPassword);
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        'Forgot Password?',
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Sign In Button with Right-Aligned White Circle Arrow Badge
                                Obx(
                                  () => CustomButton(
                                    title: 'SIGN IN',
                                    height: 52,
                                    borderRadius: 14,
                                    backgroundColor: primaryColor,
                                    isLoading: controller.isLoading.value,
                                    onPressed: controller.login,
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

                          // Floating Avatar Badge
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
                                  AppAssets.icUser,
                                  color: primaryColor,
                                  size: 26,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Quick Action Feature Icons Row (Manage Properties, Track Performance, Grow Network)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildFeatureItem(
                            context: context,
                            icon: AppAssets.icManageProperties,
                            labelLine1: 'Manage',
                            labelLine2: 'Properties',
                          ),
                          _buildFeatureDot(context),
                          _buildFeatureItem(
                            context: context,
                            icon: AppAssets.icTrackPerformance,
                            labelLine1: 'Track',
                            labelLine2: 'Performance',
                          ),
                          _buildFeatureDot(context),
                          _buildFeatureItem(
                            context: context,
                            icon: AppAssets.icGrowNetwork,
                            labelLine1: 'Grow Your',
                            labelLine2: 'Network',
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
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: context.mediaQueryPadding.bottom + 40,
        child: ClipPath(
          clipper: BottomOrangeFooterClipper(),
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
    );
  }

  // Feature Action Item Widget
  Widget _buildFeatureItem({
    required BuildContext context,
    required IconData icon,
    required String labelLine1,
    required String labelLine2,
  }) {
    final theme = context.theme;
    final textTheme = context.textTheme;
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;

    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.05),
            shape: BoxShape.circle,
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Center(child: Icon(icon, color: primaryColor, size: 24)),
        ),
        const SizedBox(height: 8),
        Text(
          labelLine1,
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 11,
            color: colorScheme.onSurface.withValues(alpha: 0.75),
          ),
        ),
        Text(
          labelLine2,
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 11,
            color: colorScheme.onSurface.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }

  // Dot Separator Widget between Feature Items
  Widget _buildFeatureDot(BuildContext context) {
    return Container(
      width: 3,
      height: 3,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.onSurface.withValues(alpha: 0.25),
        shape: BoxShape.circle,
      ),
    );
  }
}

// Clipper for Top-Left Orange Corner Shape
class TopLeftOrangeCornerClipper extends CustomClipper<Path> {
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

// Clipper for Bottom Orange Curved Footer Banner
class BottomOrangeFooterClipper extends CustomClipper<Path> {
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
