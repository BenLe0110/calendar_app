import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Scheme
  static const Color primaryColor = Color(0xFF2C3E50); // Deep blue-gray
  static const Color secondaryColor = Color(0xFFE74C3C); // Warm red
  static const Color accentColor = Color(0xFF3498DB); // Bright blue
  static const Color backgroundColor = Color(0xFFF8F9FA); // Light gray
  static const Color surfaceColor = Colors.white;
  static const Color textColor = Color(0xFF2C3E50);
  static const Color textLightColor = Color(0xFF7F8C8D);

  // Event Colors
  static const List<Color> eventColors = [
    Color(0xFF3498DB), // Blue
    Color(0xFF2ECC71), // Green
    Color(0xFFE74C3C), // Red
    Color(0xFFF1C40F), // Yellow
    Color(0xFF9B59B6), // Purple
    Color(0xFF1ABC9C), // Turquoise
  ];

  // Spacing System
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing48 = 48.0;

  // Animation Durations
  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Duration animationDurationNormal = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);

  // Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  // Responsive Layout
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  // Standard Padding
  static EdgeInsets standardPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.all(spacing32);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(spacing24);
    } else {
      return const EdgeInsets.all(spacing16);
    }
  }

  // Standard Margin
  static EdgeInsets standardMargin(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.all(spacing24);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(spacing16);
    } else {
      return const EdgeInsets.all(spacing8);
    }
  }

  // Animation Curves
  static const Curve easeInOutCurve = Curves.easeInOut;
  static const Curve easeOutCurve = Curves.easeOut;
  static const Curve easeInCurve = Curves.easeIn;
  static const Curve bounceOutCurve = Curves.bounceOut;

  // Typography
  static TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.playfairDisplay(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: textColor,
    ),
    displayMedium: GoogleFonts.playfairDisplay(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: textColor,
    ),
    displaySmall: GoogleFonts.playfairDisplay(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: textColor,
    ),
    headlineLarge: GoogleFonts.lato(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: textColor,
    ),
    headlineMedium: GoogleFonts.lato(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: textColor,
    ),
    headlineSmall: GoogleFonts.lato(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: textColor,
    ),
    titleLarge: GoogleFonts.lato(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: textColor,
    ),
    titleMedium: GoogleFonts.lato(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: textColor,
    ),
    titleSmall: GoogleFonts.lato(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: textColor,
    ),
    bodyLarge: GoogleFonts.lato(
      fontSize: 16,
      color: textColor,
    ),
    bodyMedium: GoogleFonts.lato(
      fontSize: 14,
      color: textColor,
    ),
    bodySmall: GoogleFonts.lato(
      fontSize: 12,
      color: textLightColor,
    ),
  );

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: secondaryColor,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: textLightColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: textLightColor.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),
      ),
    );
  }
}
