import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double borderRadius;
  final bool isLoading;
  final double? width;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.height = 48,
    this.borderRadius = 12,
    this.isLoading = false,
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final textTheme = context.textTheme;
    final colorScheme = theme.colorScheme;

    final effectiveBgColor = backgroundColor ?? colorScheme.primary;
    final effectiveTextColor = textColor ?? colorScheme.onPrimary;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            vertical: isLoading ? 0 : 10,
            horizontal: 12,
          ),
          backgroundColor: effectiveBgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      color: effectiveTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(
                      icon,
                      color: effectiveTextColor,
                      size: 20,
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class CustomOutlinedButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final Color? borderColor;
  final Color? textColor;
  final double height;
  final double borderRadius;
  final bool isLoading;
  final double? width;
  final IconData? icon;
  final IconData? startIcon;
  final double borderWidth;

  const CustomOutlinedButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.borderColor,
    this.textColor,
    this.height = 50,
    this.borderRadius = 12,
    this.isLoading = false,
    this.width,
    this.icon,
    this.startIcon,
    this.borderWidth = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final textTheme = context.textTheme;
    final colorScheme = theme.colorScheme;

    final effectiveColor = textColor ?? colorScheme.primary;
    final effectiveBorderColor = borderColor ?? effectiveColor;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            vertical: isLoading ? 0 : 12,
            horizontal: 12,
          ),
          side: BorderSide(
            color: effectiveBorderColor,
            width: borderWidth,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isLoading
            ? SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (startIcon != null) ...[
                    Icon(startIcon, color: effectiveColor, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      color: effectiveColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(icon, color: effectiveColor, size: 20),
                  ],
                ],
              ),
      ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  final double size;
  final IconData iconData;
  final bool isLoading;
  final double borderWidth;
  final Color? backgroundColor;
  final VoidCallback? onPressed;

  const CustomIconButton({
    super.key,
    required this.size,
    required this.iconData,
    this.isLoading = false,
    this.borderWidth = 1,
    this.backgroundColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final bg = backgroundColor ?? colorScheme.surface;

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(
          color: colorScheme.primary,
          width: borderWidth,
        ),
      ),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        child: Center(
          child: isLoading
              ? SizedBox(
                  height: size * 0.5,
                  width: size * 0.5,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                  ),
                )
              : Icon(iconData, size: size * 0.5, color: colorScheme.primary),
        ),
      ),
    );
  }
}
