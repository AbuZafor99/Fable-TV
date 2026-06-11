import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants/app_colors.dart';

/// Pure dark theme — no light mode. Space Grotesk for display/headings,
/// Plus Jakarta Sans for body, per the NimbusTV design handoff.
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark();
    final body = GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
      bodyColor: TColors.textPrimary,
      displayColor: TColors.textPrimary,
    );
    final textTheme = body.copyWith(
      headlineLarge: GoogleFonts.spaceGrotesk(
          textStyle: body.headlineLarge,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5),
      headlineMedium: GoogleFonts.spaceGrotesk(
          textStyle: body.headlineMedium,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5),
      headlineSmall: GoogleFonts.spaceGrotesk(
          textStyle: body.headlineSmall,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3),
      titleLarge: GoogleFonts.spaceGrotesk(
          textStyle: body.titleLarge,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4),
      titleMedium: GoogleFonts.spaceGrotesk(
          textStyle: body.titleMedium,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2),
    );

    return base.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: TColors.bgDark,
      cardColor: TColors.bgCard,
      colorScheme: const ColorScheme.dark(
        primary: TColors.primary,
        secondary: TColors.accent,
        surface: TColors.bgCard,
        onPrimary: Colors.white,
        onSurface: TColors.textPrimary,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: TColors.textPrimary,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TColors.bgCard,
        hintStyle: const TextStyle(color: TColors.textDisabled),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: TColors.dividerStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: TColors.dividerStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: TColors.primary),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: TColors.bgSheet,
        selectedItemColor: TColors.primary,
        unselectedItemColor: TColors.textDisabled,
        type: BottomNavigationBarType.fixed,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: TColors.bgSheet,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
      ),
      dividerColor: TColors.divider,
      sliderTheme: const SliderThemeData(
        activeTrackColor: TColors.primary,
        inactiveTrackColor: TColors.dividerStrong,
        thumbColor: Colors.white,
      ),
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: TColors.primary),
    );
  }
}
