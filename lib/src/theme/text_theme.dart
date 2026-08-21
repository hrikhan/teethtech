import 'package:flutter/material.dart';

/// Defines the Material 3 typescale for TeethTech.
///
/// Headings utilize an elegant serif visual style while body & UI text uses clean sans-serif.
TextTheme buildTextTheme() {
  const baseTextTheme = TextTheme(
    // ── Display ──────────────────────────────────────────────────────────────
    displayLarge: TextStyle(
      fontSize: 52,
      fontWeight: FontWeight.w700,
      fontFamily: 'serif',
      letterSpacing: -0.5,
    ),
    displayMedium: TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.w700,
      fontFamily: 'serif',
      letterSpacing: -0.25,
    ),
    displaySmall: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      fontFamily: 'serif',
      letterSpacing: 0,
    ),

    // ── Headline ─────────────────────────────────────────────────────────────
    headlineLarge: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w700,
      fontFamily: 'serif',
      letterSpacing: -0.2,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      fontFamily: 'serif',
      letterSpacing: -0.1,
    ),
    headlineSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      fontFamily: 'serif',
      letterSpacing: 0,
    ),

    // ── Title (Sans-Serif UI) ────────────────────────────────────────────────
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.1,
    ),
    titleMedium: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    ),
    titleSmall: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    ),

    // ── Body ──────────────────────────────────────────────────────────────────
    bodyLarge: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.2,
      height: 1.4,
    ),
    bodyMedium: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.2,
      height: 1.4,
    ),
    bodySmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.3,
      height: 1.35,
    ),

    // ── Label ─────────────────────────────────────────────────────────────────
    labelLarge: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
    ),
  );

  return baseTextTheme;
}
