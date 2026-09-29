import 'package:flutter/material.dart';
import 'theme_controller.dart';

/// Atlanta Design System — Color Tokens.
/// Dynamically reactive to [ThemeController.instance] accent color changes.
class AppColors {
  AppColors._();

  // ── Primary & Accent Colors (Dynamic) ────────────────────
  static Color get primaryBlue => ThemeController.instance.primary;
  static Color get secondaryBlue => ThemeController.instance.secondary;
  static Color get primaryBlueLight => ThemeController.instance.primaryLight;
  static Color get neonCyan => ThemeController.instance.neon;
  static Color get neuralPurple => ThemeController.instance.currentAccent == AtlantaAccent.purple
      ? const Color(0xFFC084FC)
      : const Color(0xFF7928CA);

  // ── Backgrounds ──────────────────────────────────────────
  static const Color deepBackground = Color(0xFF050A12);
  static const Color secondaryBackground = Color(0xFF0B1220);
  static const Color cardSurface = Color(0xFF111C2B);
  static const Color elevatedSurface = Color(0xFF162438);

  // ── Text ─────────────────────────────────────────────────
  static const Color primaryWhite = Color(0xFFF5F9FF);
  static const Color secondaryText = Color(0xFF9AAEC4);
  static const Color mutedText = Color(0xFF5A6F8A);
  static const Color disabledText = Color(0xFF3A4D66);

  // ── Border ───────────────────────────────────────────────
  static const Color border = Color(0xFF23354D);
  static const Color borderLight = Color(0xFF2D4060);
  static Color get borderFocus => ThemeController.instance.borderFocus;

  // ── Status ───────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color successMuted = Color(0xFF15803D);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningMuted = Color(0xFF92400E);
  static const Color error = Color(0xFFEF4444);
  static const Color errorMuted = Color(0xFF991B1B);
  static const Color info = Color(0xFF3B82F6);

  // ── Glow / Effects (Dynamic) ──────────────────────────────
  static Color get primaryGlow => ThemeController.instance.primaryGlow;
  static Color get primaryGlowStrong => ThemeController.instance.primaryGlowStrong;
  static Color get orbGlow => ThemeController.instance.orbGlow;
  static Color get orbCore => ThemeController.instance.orbCore;
  static Color get orbInner => ThemeController.instance.orbInner;
  static Color get orbOuter => ThemeController.instance.orbOuter;

  // ── Priority ─────────────────────────────────────────────
  static const Color priorityLow = Color(0xFF22C55E);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityHigh = Color(0xFFEF4444);

  // ── Navigation (Dynamic) ──────────────────────────────────
  static Color get navActive => ThemeController.instance.navActive;
  static const Color navInactive = Color(0xFF5A6F8A);
  static Color get navActiveBackground => ThemeController.instance.navActiveBackground;

  // ── Shimmer ──────────────────────────────────────────────
  static const Color shimmerBase = Color(0xFF111C2B);
  static const Color shimmerHighlight = Color(0xFF1A2940);
}
