import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_assets.dart';
import '../controller/splash_controller.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final textTheme = context.textTheme;
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;

    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          // Background Orange Gradient matching design spec
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE64A19),
                    Color(0xFFD84315),
                    Color(0xFFE65100),
                  ],
                ),
              ),
            ),
          ),

          // Top-Right Matrix Grid of Dots Accent
          Positioned(
            top: 48,
            right: 24,
            child: Opacity(opacity: 0.35, child: _buildDotGrid()),
          ),

          // Translucent Background Circle Accents
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            top: 180,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 30,
                ),
              ),
            ),
          ),

          // Bottom White Curved Surface Container
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: MediaQuery.of(context).size.height * 0.28,
            child: ClipPath(
              clipper: SplashBottomWaveClipper(),
              child: Container(
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Circular Progress Spinner Indicator
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Version & Portal Footer Text
                    Text(
                      'v1.0.0 • Premium Real Estate Portal',
                      style: textTheme.bodySmall?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // Real Estate City Illustration (Positioned above the bottom white curve)
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).size.height * 0.08,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Image.asset(
                AppAssets.imgRealEstateVector,
                height: Get.width,
                color: context.theme.colorScheme.onPrimary,
              ),
            ),
          ),

          // Main Center Content (Diamond Logo, PBD Group Title, Tagline)
          SafeArea(
            child: Align(
              alignment: const Alignment(0, -0.2),
              child: Obx(
                () => AnimatedOpacity(
                  duration: const Duration(milliseconds: 800),
                  opacity: controller.opacity.value,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 800),
                    scale: controller.scale.value,
                    curve: Curves.easeOutBack,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Hero Diamond Logo Badge Container
                        Hero(
                          tag: 'app_logo_hero',
                          child: Transform.rotate(
                            angle: math.pi / 4,
                            child: Container(
                              width: 140,
                              height: 140,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.18),
                                    blurRadius: 28,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Transform.rotate(
                                  angle: -math.pi / 4,
                                  child: Image.asset(
                                    AppAssets.imgAppLogo,
                                    height: 90,
                                    width: 90,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 44),

                        // Hero Brand Title "PBD Group"
                        Hero(
                          tag: 'app_brand_name_hero',
                          child: Material(
                            type: MaterialType.transparency,
                            child: Text(
                              'PBD Group',
                              style: textTheme.headlineLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 34,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Subtitle Tagline with horizontal accent lines
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 2,
                              width: 24,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Your Trusted Real Estate Partner',
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.95),
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              height: 2,
                              width: 24,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  // Matrix Dot Grid Accent Widget
  Widget _buildDotGrid() {
    return Column(
      children: List.generate(5, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            children: List.generate(5, (colIndex) {
              return Container(
                margin: const EdgeInsets.only(left: 5),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

// Clipper for Convex White Curved Wave at Bottom
class SplashBottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.4);

    final controlPoint = Offset(size.width * 0.5, size.height * 0.05);
    final endPoint = Offset(size.width, size.height * 0.4);

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
