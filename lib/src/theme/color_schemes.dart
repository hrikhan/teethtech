import 'package:flutter/material.dart';

/// App-specific color extensions for TeethTech Dental Supply Marketplace.
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.info,
    required this.onInfo,
    required this.b2bAccent,
    required this.onB2bAccent,
    required this.verifiedBadge,
    this.successContainer,
    this.onSuccessContainer,
    this.warningContainer,
    this.onWarningContainer,
    this.infoContainer,
    this.onInfoContainer,
  });

  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color info;
  final Color onInfo;
  final Color b2bAccent;
  final Color onB2bAccent;
  final Color verifiedBadge;
  final Color? successContainer;
  final Color? onSuccessContainer;
  final Color? warningContainer;
  final Color? onWarningContainer;
  final Color? infoContainer;
  final Color? onInfoContainer;

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? info,
    Color? onInfo,
    Color? b2bAccent,
    Color? onB2bAccent,
    Color? verifiedBadge,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? infoContainer,
    Color? onInfoContainer,
  }) {
    return AppColorsExtension(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      b2bAccent: b2bAccent ?? this.b2bAccent,
      onB2bAccent: onB2bAccent ?? this.onB2bAccent,
      verifiedBadge: verifiedBadge ?? this.verifiedBadge,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    covariant ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      b2bAccent: Color.lerp(b2bAccent, other.b2bAccent, t)!,
      onB2bAccent: Color.lerp(onB2bAccent, other.onB2bAccent, t)!,
      verifiedBadge: Color.lerp(verifiedBadge, other.verifiedBadge, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t),
      onSuccessContainer: Color.lerp(onSuccessContainer, other.onSuccessContainer, t),
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t),
      onWarningContainer: Color.lerp(onWarningContainer, other.onWarningContainer, t),
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t),
      onInfoContainer: Color.lerp(onInfoContainer, other.onInfoContainer, t),
    );
  }
}

/// Helper class to define the actual color palettes
class AppPalettes {
  AppPalettes._();

  // Primary TeethTech Cerulean Blue
  static const Color primaryBlue = Color(0xFF167CD1);
  static const Color primaryDark = Color(0xFF0F5B9B);
  static const Color primaryLight = Color(0xFF3898EC);

  static const light = AppColorsExtension(
    success: Color(0xFF00897B),
    onSuccess: Colors.white,
    successContainer: Color(0xFFE0F2F1),
    onSuccessContainer: Color(0xFF004D40),
    warning: Color(0xFFD97706),
    onWarning: Colors.white,
    warningContainer: Color(0xFFFEF3C7),
    onWarningContainer: Color(0xFF92400E),
    info: primaryBlue,
    onInfo: Colors.white,
    infoContainer: Color(0xFFE1F0FB),
    onInfoContainer: Color(0xFF083C66),
    b2bAccent: Color(0xFFD97706),
    onB2bAccent: Colors.white,
    verifiedBadge: Color(0xFF0284C7),
  );

  static const dark = AppColorsExtension(
    success: Color(0xFF4DB6AC),
    onSuccess: Color(0xFF00332C),
    successContainer: Color(0xFF004D40),
    onSuccessContainer: Color(0xFFB2DFDB),
    warning: Color(0xFFFBBF24),
    onWarning: Color(0xFF451A03),
    warningContainer: Color(0xFF78350F),
    onWarningContainer: Color(0xFFFDE68A),
    info: primaryLight,
    onInfo: Color(0xFF00223E),
    infoContainer: Color(0xFF0D4775),
    onInfoContainer: Color(0xFFBCE0FD),
    b2bAccent: Color(0xFFF59E0B),
    onB2bAccent: Color(0xFF1E1000),
    verifiedBadge: Color(0xFF38BDF8),
  );
}

/// Material 3 ColorScheme for TeethTech Light Mode
ColorScheme buildTeethTechLightColorScheme() {
  return const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF167CD1),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFE1F0FB),
    onPrimaryContainer: Color(0xFF083C66),
    secondary: Color(0xFF0F5B9B),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFE2EDF7),
    onSecondaryContainer: Color(0xFF062B4A),
    tertiary: Color(0xFFD97706), // Gold B2B / Deal accent
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFFEF3C7),
    onTertiaryContainer: Color(0xFF78350F),
    error: Color(0xFFDC2626),
    onError: Colors.white,
    errorContainer: Color(0xFFFEE2E2),
    onErrorContainer: Color(0xFF991B1B),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF0F172A),
    surfaceDim: Color(0xFFF1F5F9),
    surfaceBright: Color(0xFFFFFFFF),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF8FAFC),
    surfaceContainer: Color(0xFFF1F5F9),
    surfaceContainerHigh: Color(0xFFE2E8F0),
    surfaceContainerHighest: Color(0xFFCBD5E1),
    onSurfaceVariant: Color(0xFF64748B),
    outline: Color(0xFF94A3B8),
    outlineVariant: Color(0xFFE2E8F0),
    shadow: Color(0x1A000000),
    scrim: Color(0x66000000),
    inverseSurface: Color(0xFF1E293B),
    onInverseSurface: Color(0xFFF8FAFC),
    inversePrimary: Color(0xFF70B8F6),
  );
}

/// Material 3 ColorScheme for TeethTech Dark Mode
ColorScheme buildTeethTechDarkColorScheme() {
  return const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF167CD1),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFF0D4775),
    onPrimaryContainer: Color(0xFFBCE0FD),
    secondary: Color(0xFF3898EC),
    onSecondary: Color(0xFF00223E),
    secondaryContainer: Color(0xFF103657),
    onSecondaryContainer: Color(0xFFC7E4FD),
    tertiary: Color(0xFFF59E0B),
    onTertiary: Color(0xFF2E1500),
    tertiaryContainer: Color(0xFF78350F),
    onTertiaryContainer: Color(0xFFFDE68A),
    error: Color(0xFFEF4444),
    onError: Color(0xFF450A0A),
    errorContainer: Color(0xFF991B1B),
    onErrorContainer: Color(0xFFFEE2E2),
    surface: Color(0xFF0B111A), // Deep navy/near-black
    onSurface: Color(0xFFF8FAFC),
    surfaceDim: Color(0xFF080D14),
    surfaceBright: Color(0xFF172334),
    surfaceContainerLowest: Color(0xFF06090E),
    surfaceContainerLow: Color(0xFF101925),
    surfaceContainer: Color(0xFF131D2A), // Elevated card surface
    surfaceContainerHigh: Color(0xFF1E2B3D),
    surfaceContainerHighest: Color(0xFF28384E),
    onSurfaceVariant: Color(0xFF94A3B8),
    outline: Color(0xFF475569),
    outlineVariant: Color(0xFF233348),
    shadow: Color(0x33000000),
    scrim: Color(0x80000000),
    inverseSurface: Color(0xFFF1F5F9),
    onInverseSurface: Color(0xFF0F172A),
    inversePrimary: Color(0xFF0F5B9B),
  );
}
