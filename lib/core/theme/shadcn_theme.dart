import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Custom shadcn/ui theme configuration for Revoland app
class FiboShadcnTheme {
  /// Light theme configuration
  static ShadThemeData get lightTheme {
    return ShadThemeData(
      brightness: Brightness.light,
      colorScheme: const ShadColorScheme(
        primary: Color(0xFFFF6600), // 🔸 FPT Orange
        primaryForeground: Color(0xFFFFFFFF), // White text on orange button
        secondary: Color(0xFFF2F2F2), // Light gray for background cards
        secondaryForeground: Color(0xFF333333),
        background: Color(0xFFFFFFFF), // White background
        foreground: Color(0xFF000000), // Black text
        muted: Color(0xFFF9F9F9), // Soft neutral section background
        mutedForeground: Color(0xFF666666), // Gray text
        accent: Color(0xFFFFA366), // Lighter orange for hover/active
        accentForeground: Color(0xFF000000),
        destructive: Color(0xFFE53935), // Red for delete/danger
        destructiveForeground: Color(0xFFFFFFFF),
        border: Color(0xFFE0E0E0), // Subtle border
        input: Color(0xFFE5E5E5),
        ring: Color(0xFFFF6600), // Orange outline focus ring
        card: Color(0xFFFFFFFF),
        cardForeground: Color(0xFF000000),
        popover: Color(0xFFFFFFFF),
        popoverForeground: Color(0xFF000000),
        selection: Color(0xFFFF6600), // Orange selection highlight
      ),
      textTheme: ShadTextTheme(family: 'Manrope'),
      primaryButtonTheme: ShadButtonTheme(
        decoration: ShadDecoration(
          color: Color(0xFFFF6600),
          border: ShadBorder(radius: BorderRadius.circular(16)),
        ),
      ),
      secondaryButtonTheme: ShadButtonTheme(
        decoration: ShadDecoration(
          border: ShadBorder(
            // style: BorderStyle(
            //   color: Color(0xFFFF6600), // viền cam FPT
            //   width: 1.5,
            // ),
            radius: BorderRadius.circular(16),
          ),
        ),
      ),

      inputTheme: ShadInputTheme(
        decoration: ShadDecoration(
          border: ShadBorder(
            // color: Color(0xFFE0E0E0), // viền xám nhạt mặc định
            // width: 1.0,
            radius: BorderRadius.circular(12),
          ),
          focusedBorder: ShadBorder(
            // color: Color(0xFFFF6600), // viền cam khi focus
            // width: 1.5,
            radius: BorderRadius.circular(12),
          ),
        ),
        placeholderStyle: TextStyle(
          fontSize: 16,
          color: Color(0xFF999999),
          fontFamily: 'Manrope',
        ),
      ),
    );
  }

  /// Dark theme configuration
  static ShadThemeData get darkTheme {
    return ShadThemeData(
      brightness: Brightness.dark,
      colorScheme: const ShadColorScheme(
        primary: Color(0xFFFF6600),
        primaryForeground: Color(0xFFFFFFFF),
        background: Color(0xFF121212),
        foreground: Color(0xFFFFFFFF),
        muted: Color(0xFF1E1E1E),
        mutedForeground: Color(0xFFBBBBBB),
        border: Color(0xFF2A2A2A),
        input: Color(0xFF2A2A2A),
        ring: Color(0xFFFF6600),
        card: Color(0xFF1A1A1A),
        cardForeground: Color(0xFFFFFFFF),
        selection: Color(0xFFFF6600),
        destructive: Color(0xFFE53935),
        destructiveForeground: Color(0xFFFFFFFF),
        accent: Color(0xFFFFA366),
        accentForeground: Color(0xFF000000),
        secondary: Color(0xFF333333),
        secondaryForeground: Color(0xFFFFFFFF),
        popover: Color(0xFF1A1A1A),
        popoverForeground: Color(0xFFFFFFFF),
      ),
      textTheme: ShadTextTheme(family: 'Manrope'),
    );
  }
}
