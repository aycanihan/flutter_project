import 'package:flutter/material.dart';

class AppColors {
  static final _eventGradients = const [
    LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF7C3AED), Color(0xFFEC4899)]),
    LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF2563EB), Color(0xFF06B6D4)]),
    LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF97316), Color(0xFFEF4444)]),
    LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomRight, colors: [Color(0xFF059669), Color(0xFF0D9488)]),
    LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF4338CA), Color(0xFFA855F7)]),
    LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFFEC4899), Color(0xFFF97316)]),
    LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Color(0xFFE11D48), Color(0xFF7C3AED)]),
    LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFD97706), Color(0xFFEC4899)]),
    LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF0EA5E9), Color(0xFF8B5CF6)]),
    LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF10B981), Color(0xFF3B82F6)]),
    LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomLeft, colors: [Color(0xFFEF4444), Color(0xFFF97316)]),
    LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF8B5CF6), Color(0xFF06B6D4)]),
    LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF14B8A6), Color(0xFF22D3EE)]),
    LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF43F5E), Color(0xFFEC4899)]),
    LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
    LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF84CC16), Color(0xFF22C55E)]),
    LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomRight, colors: [Color(0xFFEAB308), Color(0xFFF97316)]),
    LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0284C7), Color(0xFF0EA5E9)]),
    LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF7C3AED), Color(0xFF4338CA)]),
    LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF43F5E), Color(0xFFEF4444)]),
    LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Color(0xFF0891B2), Color(0xFF059669)]),
    LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFDB2777), Color(0xFF9333EA)]),
    LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF1D4ED8), Color(0xFF7C3AED)]),
    LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFDC2626), Color(0xFFD97706)]),
    LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomLeft, colors: [Color(0xFF0D9488), Color(0xFF0284C7)]),
    LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF9333EA), Color(0xFFEC4899)]),
    LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFFF59E0B), Color(0xFF10B981)]),
    LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF3B82F6), Color(0xFF14B8A6)]),
  ];

  static LinearGradient gradientForEvent(String id) =>
      _eventGradients[id.hashCode.abs() % _eventGradients.length];
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