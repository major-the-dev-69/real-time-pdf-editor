import 'package:flutter/material.dart';

abstract class AppColors {
  AppColors._();

  // Primary Brand Colors (PBD Group Crimson Red & Royal Navy Blue)
  static const primary = Color(0xFFDD0000); // Signature PBD Red
  static const primaryDark = Color(0xFFB30000); // Deep Crimson Red
  static const primaryLight = Color(0xFFFDE8E8); // Soft Red Tint

  // Secondary  Colors
  static const secondary = Color(0xFF002A82); // PBD Royal Navy Blue
  static const secondaryDark = Color(0xFF001D5C);
  static const secondaryLight = Color(0xFFEBF1FF);

  // Logo Brand Accents & Direct Color Aliases
  static const pbdRed = Color(0xFFDD0000); // Vibrant Red from PBD Logo
  static const royalNavy = Color(0xFF002A82); // Deep Royal Navy Blue from Logo
  static const roofRed = Color(0xFFDD0000); // Red roof line & accent swoosh
  static const sunOrange = Color(0xFFDD0000); // Red brand accent
  static const sunAmber = Color(0xFFFFB300); // Golden amber accent
  static const landscapeGreen = Color(0xFF008744); // Emerald green status
  static const emeraldGreen = Color(0xFF008744);

  // Secondary & Dark Navy (Sidebar & Header Elements)
  static const navyBackground = Color(0xFF0A1B44); // Deep PBD Navy Background
  static const navySurface = Color(0xFF0F2459); // Surface Navy
  static const navyCard = Color(0xFF162D6B); // Card Navy

  // Neutral Background & Surface Colors (Light Mode)
  static const lightBackground = Color(0xFFF8FAFC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFE2E8F0);
  static const lightDivider = Color(0xFFF1F5F9);

  // Neutral Background & Surface Colors (Dark Mode)
  static const darkBackground = Color(0xFF091228);
  static const darkSurface = Color(0xFF101C3D);
  static const darkCard = Color(0xFF17264E);
  static const darkBorder = Color(0xFF233666);
  static const darkDivider = Color(0xFF233666);

  // Text Colors (Light Mode)
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF475569);
  static const textMuted = Color(0xFF94A3B8);
  static const textDisabled = Color(0xFFCBD5E1);

  // Text Colors (Dark Mode)
  static const textPrimaryDark = Color(0xFFF8FAFC);
  static const textSecondaryDark = Color(0xFF94A3B8);
  static const textMutedDark = Color(0xFF64748B);

  // Dashboard Metric Accent Tints (from Logo Palette)
  static const orangeTint = Color(0xFFFDE8E8); // Crimson Red tint
  static const redTint = Color(0xFFFDE8E8); // Crimson Red tint
  static const blueTint = Color(0xFFEBF1FF); // Royal Navy Blue tint
  static const greenTint = Color(0xFFE6F4EA); // Emerald Green tint
  static const yellowTint = Color(0xFFFFFBE6); // Amber tint

  // Status & Chart Colors
  static const success = Color(0xFF008744); // Emerald Green
  static const info = Color(0xFF002A82); // Royal Navy Blue
  static const warning = Color(0xFFFF9800); // Amber Warning
  static const error = Color(0xFFDD0000); // PBD Red
  static const overdue = Color(0xFFDD0000); // PBD Red

  // Sidebar Specific Colors
  static const sidebarItemInactive = Color(0xFF8E9BBA);
  static const sidebarItemActive = Color(0xFFFFFFFF);
  static const sidebarActiveBg = Color(0xFFDD0000);
}
