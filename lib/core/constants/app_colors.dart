import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary — Blue (light theme)
  static const Color primary = Color(0xFF44ACFF);
  static const Color primaryLight = Color(0xFF89D4FF);
  static const Color primaryDark = Color(0xFF2890E0);

  // Secondary — Light Blue (light theme)
  static const Color secondary = Color(0xFF89D4FF);
  static const Color secondaryLight = Color(0xFFA8E0FF);

  // Accent — Pink (light theme)
  static const Color accent = Color(0xFFFE9EC7);
  static const Color accentLight = Color(0xFFFFBED9);

  // Dark mode accent variants
  static const Color primaryBright = Color(0xFFF48FB1);    // desaturated pink (buttons/links)
  static const Color accentBright = Color(0xFF81D4FA);     // muted blue (icons/highlights)
  static const Color secondaryBright = Color(0xFF81D4FA);  // muted blue
  static const Color successBright = Color(0xFF4ADE80);
  static const Color warningBright = Color(0xFFF67D31);    // orange
  static const Color errorBright = Color(0xFFFF5A7A);

  // ── Light theme gradients (blue → pink) ─────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF44ACFF), Color(0xFFFE9EC7), Color(0xFF89D4FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFF44ACFF), Color(0xFFFE9EC7)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF44ACFF), Color(0xFF89D4FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFE9EC7), Color(0xFFFFBED9)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ── Dark theme gradients (pink → blue) ──
  static const LinearGradient buttonGradientDark = LinearGradient(
    colors: [Color(0xFFF48FB1), Color(0xFF81D4FA)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient cardGradientDark = LinearGradient(
    colors: [Color(0xFF1E1E1E), Color(0xFF2A2A2A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Background
  static const Color backgroundLight = Color(0xFFF0F7FF);
  static const Color backgroundDark = Color(0xFF121212);

  // Surface
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight = Color(0xFFFFFFFF);

  // Misc
  static const Color divider = Color(0xFFE2E8F0);
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF1F5F9);

  // Dark mode text
  static const Color textPrimaryDark = Color(0xFFFFF9C4);
  static const Color textSecondaryDark = Color(0xFFB0BEC5);

  // Dark mode divider
  static const Color dividerDark = Color(0xFF2C2C2C);

  /// Returns the correct tint alpha for colored backgrounds.
  /// Dark mode needs higher alpha so colors don't look washed out.
  static double tintAlpha(bool isDark) => isDark ? 0.2 : 0.1;

  // ── Glassmorphism ──────────────────────────────────────────────

  static Color glassSurface(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.07)
      : Colors.white.withValues(alpha: 0.55);

  static Color glassBorder(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.10)
      : Colors.white.withValues(alpha: 0.35);

  // Light: pastel pink → cream → blue (from palette)
  // Dark: deep indigo → magenta (from dark palette)
  static LinearGradient glassBackgroundGradient(bool isDark) => isDark
      ? const LinearGradient(
          colors: [Color(0xFF121212), Color(0xFF1A1A1A), Color(0xFF1E1E1E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
      : const LinearGradient(
          colors: [Color(0xFFFFE4EF), Color(0xFFFCF8E0), Color(0xFFD9EEFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

  // Light blobs: palette colors (pink, cream, light blue)
  static List<Color> blobColorsLight = [
    const Color(0xFFFE9EC7).withValues(alpha: 0.5),
    const Color(0xFFF9F6C4).withValues(alpha: 0.45),
    const Color(0xFF89D4FF).withValues(alpha: 0.5),
  ];

  // Dark blobs: subtle accent glows
  static const List<Color> blobColorsDark = [
    Color(0xFFF48FB1),   // desaturated pink
    Color(0xFF81D4FA),   // muted blue
    Color(0xFF1E1E1E),   // surface dark
  ];
}
