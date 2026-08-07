import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography definitions for the HiraKata app.
///
/// Uses Inter for UI text and Noto Sans JP for Japanese characters.
class AppTypography {
  AppTypography._();

  // ── UI Text Styles (Inter) ──────────────────────────────────────────

  /// Large headline — used for hero sections
  static TextStyle headlineLarge = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  /// Medium headline — section titles
  static TextStyle headlineMedium = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.3,
  );

  /// Small headline
  static TextStyle headlineSmall = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
  );

  /// Title large
  static TextStyle titleLarge = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  /// Title medium
  static TextStyle titleMedium = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  /// Title small
  static TextStyle titleSmall = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  /// Body large
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// Body medium — default text
  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// Body small
  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// Label large — buttons, tabs
  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.4,
  );

  /// Label medium
  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.4,
  );

  /// Label small — captions
  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.4,
  );

  // ── Kana Display Styles (Noto Sans JP) ──────────────────────────────

  /// Extra large kana — hero display on lesson screens
  static TextStyle kanaHero = GoogleFonts.notoSansJp(
    fontSize: 120,
    fontWeight: FontWeight.w400,
    height: 1.1,
  );

  /// Large kana — flashcards and practice
  static TextStyle kanaLarge = GoogleFonts.notoSansJp(
    fontSize: 72,
    fontWeight: FontWeight.w400,
    height: 1.1,
  );

  /// Medium kana — lists and grids
  static TextStyle kanaMedium = GoogleFonts.notoSansJp(
    fontSize: 40,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );

  /// Small kana — inline text
  static TextStyle kanaSmall = GoogleFonts.notoSansJp(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );

  /// Example word display
  static TextStyle exampleWord = GoogleFonts.notoSansJp(
    fontSize: 28,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  /// Build a complete [TextTheme] for Material 3.
  static TextTheme textTheme() {
    return TextTheme(
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      headlineSmall: headlineSmall,
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      titleSmall: titleSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
    );
  }
}
