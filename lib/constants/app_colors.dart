import 'package:flutter/material.dart';

/// Centralized Dark Forest Green Theme Colors for RehabZ
class AppColors {
  // Primary Forest Green Palette (matching reference image)
  static const Color primary = Color(0xFF1E3A2B);       // Main Forest Green
  static const Color primaryDark = Color(0xFF12261C);   // Deep Dark Forest
  static const Color primaryLight = Color(0xFF2E5A44);  // Lighter Forest Accent
  static const Color accentGreen = Color(0xFF10B981);   // Vibrant Emerald Green
  static const Color accentMint = Color(0xFF34D399);    // Mint Highlight

  // Backgrounds
  static const Color pageBackground = Color(0xFF0F1F17); // Dark Forest Page BG
  static const Color cardBackground = Color(0xFF183326); // Dark Forest Card BG
  static const Color inputBackground = Color(0xFF132A1F); // Dark Forest Input BG

  // Borders & Dividers
  static const Color border = Color(0xFF254B37);         // Forest Border
  static const Color borderLight = Color(0xFF316147);    // Forest Border Light

  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC);   // White/Pure Off-White
  static const Color textSecondary = Color(0xFFA7F3D0); // Soft Mint Secondary
  static const Color textMuted = Color(0xFF6EE7B7);     // Muted Mint Text

  // Status & Badges
  static const Color activeBg = Color(0xFF064E3B);
  static const Color activeFg = Color(0xFF34D399);
  static const Color pendingBg = Color(0xFF78350F);
  static const Color pendingFg = Color(0xFFFBBF24);
  static const Color completedBg = Color(0xFF065F46);
  static const Color completedFg = Color(0xFF6EE7B7);
  static const Color warningBg = Color(0xFF7F1D1D);
  static const Color warningFg = Color(0xFFFCA5A5);

  // Gradients
  static const LinearGradient forestGradient = LinearGradient(
    colors: [Color(0xFF1E3A2B), Color(0xFF12261C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
