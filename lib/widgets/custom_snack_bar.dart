import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../core/style/colors/app_colors.dart';

enum SnackBarType { success, warning, error, info }

class CustomSnackBar {
  CustomSnackBar._();

  static void show({
    required String message,
    SnackBarType type = SnackBarType.success,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
    String? title,
    Widget? icon,
    bool isDismissible = true,
    SnackPosition position = SnackPosition.TOP,
  }) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    final accentColor = _getAccentColor(type);

    Get.showSnackbar(
      GetSnackBar(
        titleText: title != null
            ? Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              )
            : null,
        messageText: Text(
          message,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.9),
            height: 1.3,
          ),
        ),
        duration: duration,
        snackPosition: position,
        backgroundColor: AppColors.navyBackground,
        borderRadius: 16,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        isDismissible: isDismissible,
        dismissDirection: position == SnackPosition.TOP
            ? DismissDirection.up
            : DismissDirection.down,
        forwardAnimationCurve: Curves.easeOutCubic,
        icon: icon ?? _buildIconWidget(type, accentColor),
        borderColor: accentColor.withValues(alpha: 0.35),
        borderWidth: 1,
        boxShadows: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.2),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
        onTap: onTap != null ? (_) => onTap() : null,
        mainButton: isDismissible
            ? IconButton(
                onPressed: () => Get.back(),
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Iconsax.close_square_copy,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 16,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  static void showSuccess({
    required String message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
    String? title,
    bool isDismissible = true,
  }) {
    show(
      message: message,
      type: SnackBarType.success,
      duration: duration,
      onTap: onTap,
      title: title ?? 'Success',
      isDismissible: isDismissible,
    );
  }

  static void showWarning({
    required String message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
    String? title,
    bool isDismissible = true,
  }) {
    show(
      message: message,
      type: SnackBarType.warning,
      duration: duration,
      onTap: onTap,
      title: title ?? 'Warning',
      isDismissible: isDismissible,
    );
  }

  static void showError({
    required String message,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
    String? title,
    bool isDismissible = true,
  }) {
    show(
      message: message,
      type: SnackBarType.error,
      duration: duration,
      onTap: onTap,
      title: title ?? 'Error',
      isDismissible: isDismissible,
    );
  }

  static void showInfo({
    required String message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
    String? title,
    bool isDismissible = true,
  }) {
    show(
      message: message,
      type: SnackBarType.info,
      duration: duration,
      onTap: onTap,
      title: title ?? 'Information',
      isDismissible: isDismissible,
    );
  }

  static void showSimple({
    required String message,
    Duration duration = const Duration(seconds: 2),
    Color? backgroundColor,
    Color? textColor,
  }) {
    Get.showSnackbar(
      GetSnackBar(
        messageText: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        duration: duration,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: backgroundColor ?? AppColors.navyCard,
        borderRadius: 24,
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }

  static Color _getAccentColor(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return AppColors.landscapeGreen;
      case SnackBarType.warning:
        return AppColors.sunOrange;
      case SnackBarType.error:
        return AppColors.roofRed;
      case SnackBarType.info:
        return const Color(0xFF3B82F6);
    }
  }

  static Widget _buildIconWidget(SnackBarType type, Color accentColor) {
    IconData iconData;
    switch (type) {
      case SnackBarType.success:
        iconData = Icons.check_rounded;
        break;
      case SnackBarType.warning:
        iconData = Icons.priority_high_rounded;
        break;
      case SnackBarType.error:
        iconData = Icons.close_rounded;
        break;
      case SnackBarType.info:
        iconData = Icons.info_outline_rounded;
        break;
    }

    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(left: 4, right: 8),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.18),
        shape: BoxShape.circle,
        border: Border.all(
          color: accentColor.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Icon(iconData, color: accentColor, size: 20),
    );
  }
}
