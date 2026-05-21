import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ZeroPointColors {
  static const bg = Color(0xFF0A0C0F);
  static const surface = Color(0xFF111418);
  static const panel = Color(0xFF161B22);
  static const border = Color(0xFF2A3240);
  static const accent = Color(0xFFFF6000);
  static const accentDim = Color(0x44FF6000);
  static const accentGlow = Color(0x22FF6000);
  static const success = Color(0xFF00E5A0);
  static const danger = Color(0xFFFF2244);
  static const textPrimary = Color(0xFFE8ECF0);
  static const textSecondary = Color(0xFF6B7A8D);
  static const textMuted = Color(0xFF3D4A5C);
  static const mapOverlay = Color(0xCC0A0C0F);
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ZeroPointColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: ZeroPointColors.accent,
        surface: ZeroPointColors.surface,
        onSurface: ZeroPointColors.textPrimary,
      ),
      textTheme: GoogleFonts.shareTechTextTheme(
        ThemeData.dark().textTheme.apply(
          bodyColor: ZeroPointColors.textPrimary,
          displayColor: ZeroPointColors.textPrimary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}
