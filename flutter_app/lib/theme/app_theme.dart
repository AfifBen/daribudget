import 'package:flutter/material.dart';

class AppTheme {
  // Forest & Gold palette
  static const forest950 = Color(0xFF071C16);
  static const forest900 = Color(0xFF0B2B22);
  static const forest800 = Color(0xFF10362B);
  static const forest700 = Color(0xFF134233);
  static const forest600 = Color(0xFF17503F);
  static const forest100 = Color(0xFFE5F2ED);

  static const gold500 = Color(0xFFD8B45C);
  static const gold400 = Color(0xFFE4C77A);
  static const gold300 = Color(0xFFF0DB9D);

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: gold500,
        secondary: gold400,
        surface: forest800,
        error: Colors.redAccent,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: forest900,
      appBarTheme: const AppBarTheme(
        backgroundColor: forest900,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: forest800.withValues(alpha: 0.75),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: forest950,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: forest700.withValues(alpha: 0.6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: forest700.withValues(alpha: 0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: gold500),
        ),
        labelStyle: TextStyle(color: forest100.withValues(alpha: 0.7)),
        hintStyle: TextStyle(color: forest100.withValues(alpha: 0.45)),
      ),
    );
  }
}
