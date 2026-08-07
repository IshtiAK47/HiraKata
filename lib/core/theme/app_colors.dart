import 'package:flutter/material.dart';

/// Semantic color tokens for the HiraKata app.
///
/// Provides a calm, premium color palette with indigo/purple tones.
/// Colors are defined as seed values; actual theme colors are generated
/// by Material 3's [ColorScheme.fromSeed].
class AppColors {
  AppColors._();

  // ── Brand seed ──────────────────────────────────────────────────────
  /// Primary seed color — calm indigo
  static const Color seed = Color(0xFF5C6BC0);

  // ── Light mode surface overrides ────────────────────────────────────
  static const Color lightBackground = Color(0xFFF8F9FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF0F1F8);
  static const Color lightCardGradientStart = Color(0xFFE8EAF6);
  static const Color lightCardGradientEnd = Color(0xFFF3E5F5);

  // ── Dark mode surface overrides ─────────────────────────────────────
  static const Color darkBackground = Color(0xFF0F1118);
  static const Color darkSurface = Color(0xFF1A1C24);
  static const Color darkSurfaceVariant = Color(0xFF22242E);
  static const Color darkCardGradientStart = Color(0xFF1A237E);
  static const Color darkCardGradientEnd = Color(0xFF311B92);

  // ── Semantic colors ─────────────────────────────────────────────────
  static const Color success = Color(0xFF43A047);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFFFA726);
  static const Color warningLight = Color(0xFFFFF3E0);

  // ── Category colors ─────────────────────────────────────────────────
  /// Color for Hiragana-related UI elements
  static const Color hiragana = Color(0xFF5C6BC0);

  /// Color for Katakana-related UI elements
  static const Color katakana = Color(0xFF7E57C2);

  /// Color for practice UI elements
  static const Color practice = Color(0xFF26A69A);

  /// Color for progress UI elements
  static const Color progress = Color(0xFFEF5350);

  // ── Kana display ────────────────────────────────────────────────────
  /// Color for large kana character display
  static const Color kanaDisplay = Color(0xFF1A1C24);
  static const Color kanaDisplayDark = Color(0xFFF8F9FC);
}
