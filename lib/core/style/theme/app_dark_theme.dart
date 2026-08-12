import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../colors/app_colors.dart';

/// Modern Material 3 Dark Theme for PBD Group Application.
abstract class AppDarkTheme {
  AppDarkTheme._();

  static const String fontFamily = 'Lato';

  static ThemeData get theme {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryDark,
      onPrimaryContainer: Color(0xFFFFDADA),
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.navyCard,
      onSecondaryContainer: Color(0xFFDCE6FF),
      tertiary: AppColors.landscapeGreen,
      onTertiary: Colors.white,
      surface: AppColors.darkSurface,
      onSurface: AppColors.textPrimaryDark,
      surfaceContainerLowest: Color(0xFF060D1E),
      surfaceContainerLow: AppColors.darkBackground,
      surfaceContainer: AppColors.darkSurface,
      surfaceContainerHigh: AppColors.darkCard,
      surfaceContainerHighest: AppColors.darkBorder,
      error: AppColors.error,
      onError: Colors.white,
      outline: AppColors.darkBorder,
      outlineVariant: Color(0xFF1B2A50),
      shadow: Color(0x33000000),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: colorScheme,
      splashColor: AppColors.primary.withValues(alpha: 0.12),
      highlightColor: AppColors.primary.withValues(alpha: 0.06),

      // AppBar Modern Dark Styling
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimaryDark, size: 22),
        actionsIconTheme: IconThemeData(color: AppColors.textPrimaryDark, size: 22),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: AppColors.textPrimaryDark,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),

      // Modern Card Theme (Dark)
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),

      // Button Themes (Filled, Elevated, Outlined, Text)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Field Decoration Theme (Dark Mode)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: const TextStyle(
          fontFamily: fontFamily,
          color: AppColors.textMutedDark,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          fontFamily: fontFamily,
          color: AppColors.textSecondaryDark,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: const TextStyle(
          fontFamily: fontFamily,
          color: AppColors.primary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Navigation Bar (Bottom Navigation M3 Dark)
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        indicatorColor: AppColors.primary.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontFamily: fontFamily,
              color: AppColors.textPrimaryDark,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            );
          }
          return const TextStyle(
            fontFamily: fontFamily,
            color: AppColors.textSecondaryDark,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return const IconThemeData(color: AppColors.textSecondaryDark, size: 24);
        }),
      ),

      // Floating Action Button (Dark)
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        hoverElevation: 6,
        focusElevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Dialog & BottomSheet Themes (Dark)
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          fontFamily: fontFamily,
          color: AppColors.textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 10,
        showDragHandle: true,
        dragHandleColor: AppColors.darkBorder,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // Chip Theme (Dark)
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkCard,
        selectedColor: AppColors.primary.withValues(alpha: 0.25),
        disabledColor: AppColors.darkSurface,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: const TextStyle(
          fontFamily: fontFamily,
          color: AppColors.textPrimaryDark,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(
          fontFamily: fontFamily,
          color: AppColors.primary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: const BorderSide(color: AppColors.darkBorder, width: 1),
      ),

      // SnackBar Theme (Dark)
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.navyCard,
        contentTextStyle: const TextStyle(
          fontFamily: fontFamily,
          color: AppColors.textPrimaryDark,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
      ),

      // Divider & Icon Themes
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textSecondaryDark,
        size: 20,
      ),

      // Modern Dark Typography System
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: fontFamily,
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w800,
          fontSize: 32,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontFamily: fontFamily,
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w700,
          fontSize: 28,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontFamily: fontFamily,
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w700,
          fontSize: 24,
          letterSpacing: -0.3,
        ),
        headlineLarge: TextStyle(
          fontFamily: fontFamily,
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w700,
          fontSize: 22,
          letterSpacing: -0.3,
        ),
        headlineMedium: TextStyle(
          fontFamily: fontFamily,
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w700,
          fontSize: 20,
          letterSpacing: -0.2,
        ),
        headlineSmall: TextStyle(
          fontFamily: fontFamily,
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
        titleLarge: TextStyle(
          fontFamily: fontFamily,
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
        titleMedium: TextStyle(
          fontFamily: fontFamily,
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        titleSmall: TextStyle(
          fontFamily: fontFamily,
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        bodyLarge: TextStyle(
          fontFamily: fontFamily,
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w400,
          fontSize: 15,
          height: 1.4,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          color: AppColors.textSecondaryDark,
          fontWeight: FontWeight.w400,
          fontSize: 13.5,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          fontFamily: fontFamily,
          color: AppColors.textMutedDark,
          fontWeight: FontWeight.w400,
          fontSize: 12,
          height: 1.3,
        ),
        labelLarge: TextStyle(
          fontFamily: fontFamily,
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontFamily: fontFamily,
          color: AppColors.textSecondaryDark,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        labelSmall: TextStyle(
          fontFamily: fontFamily,
          color: AppColors.textMutedDark,
          fontWeight: FontWeight.w500,
          fontSize: 11,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
