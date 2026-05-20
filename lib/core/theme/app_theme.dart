import 'package:flutter/material.dart';

class AppColors {
  // Ana renkler
  static const bgPrimary = Color(0xFF060610);
  static const bgSecondary = Color(0xFF0F0F1E);
  static const bgCard = Color(0xFF111128);

  // Gradient renkler
  static const purple = Color(0xFF7C3AED);
  static const purpleLight = Color(0xFFA855F7);
  static const pink = Color(0xFFEC4899);
  static const pinkLight = Color(0xFFF472B6);
  static const orange = Color(0xFFF97316);
  static const amber = Color(0xFFF59E0B);

  // Accent
  static const teal = Color(0xFF34D399);
  static const blue = Color(0xFF3B82F6);

  // Text
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0x99FFFFFF);
  static const textTertiary = Color(0x40FFFFFF);
  static const textHint = Color(0x28FFFFFF);

  // Border
  static const borderSubtle = Color(0x15FFFFFF);
  static const borderLight = Color(0x25FFFFFF);

  // Gradientler
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, purpleLight, pink],
  );

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0B0420),
      Color(0xFF2D0B6B),
      Color(0xFF7C3AED),
      Color(0xFFDB2777),
      Color(0xFFF59E0B),
    ],
    stops: [0.0, 0.3, 0.62, 0.85, 1.0],
  );

  static const cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF160535),
      Color(0xFF3B0F8C),
      Color(0xFF7C3AED),
      Color(0xFFC026D3),
    ],
    stops: [0.0, 0.45, 0.75, 1.0],
  );
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgPrimary,
      fontFamily: 'SF Pro Display',

      colorScheme: ColorScheme.dark(
        primary: AppColors.purple,
        secondary: AppColors.pink,
        surface: AppColors.bgSecondary,
        background: AppColors.bgPrimary,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: -1.0,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: -0.6,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.3,
        ),
        bodyLarge: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
          height: 1.6,
        ),
        bodySmall: TextStyle(
          fontSize: 11,
          color: AppColors.textTertiary,
          letterSpacing: 0.04,
        ),
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}