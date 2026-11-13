import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSnackBar {
  static void showSuccess({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      title: title,
      message: message,
      icon: Icons.check_circle_rounded,
      backgroundColor: const Color(0xFF10B981),
      duration: duration,
    );
  }

  static void showError({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      title: title,
      message: message,
      icon: Icons.error_rounded,
      backgroundColor: const Color(0xFFEF4444),
      duration: duration,
    );
  }

  static void showWarning({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      title: title,
      message: message,
      icon: Icons.warning_amber_rounded,
      backgroundColor: const Color(0xFFF59E0B),
      duration: duration,
    );
  }

  static void showInfo({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      title: title,
      message: message,
      icon: Icons.info_rounded,
      backgroundColor: const Color(0xFF3B82F6),
      duration: duration,
    );
  }

  static void _show({
    required String title,
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Duration duration,
  }) {
    Get.showSnackbar(
      GetSnackBar(
        backgroundColor: backgroundColor,
        duration: duration,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        forwardAnimationCurve: Curves.easeOutBack,
        reverseAnimationCurve: Curves.easeIn,
        boxShadows: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.35),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
        messageText: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 12),
            // Icon
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 17),
            ),

            const SizedBox(width: 12),

            // Title + Message
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Close button
            GestureDetector(
              onTap: () => Get.back(),
              child: Icon(
                Icons.close,
                color: Colors.white.withValues(alpha: 0.8),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
