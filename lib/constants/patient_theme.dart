import 'package:flutter/material.dart';

/// Centralized Teal & White Theme System for PhysioVerse Patient Application
class PatientTheme {
  // Primary Teal Palette (matching reference screenshot media_1787385006975.jpg)
  static const Color primaryTeal = Color(0xFF00A98C);
  static const Color primaryTealDark = Color(0xFF007A65);
  static const Color primaryTealLight = Color(0xFFE0F7F4);
  static const Color primaryTealSubtle = Color(0xFFE6F7F5);

  // Backgrounds & Canvas
  static const Color pageBg = Color(0xFFF6F9F8);
  static const Color cardBg = Colors.white;
  static const Color inputBg = Color(0xFFF8FAFC);

  // Text Colors
  static const Color textDark = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textWhite = Colors.white;

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);

  // Status & Highlight Colors
  static const Color successGreen = Color(0xFF10B981);
  static const Color successGreenBg = Color(0xFFD1FAE5);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color warningOrangeBg = Color(0xFFFEF3C7);
  static const Color infoBlue = Color(0xFF0284C7);
  static const Color infoBlueBg = Color(0xFFE0F2FE);
  static const Color purpleProgress = Color(0xFF8B5CF6);
  static const Color purpleProgressBg = Color(0xFFEDE9FE);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color errorRedBg = Color(0xFFFEE2E2);

  // Box Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.02),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> tealButtonShadow = [
    BoxShadow(
      color: primaryTeal.withValues(alpha: 0.28),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}
