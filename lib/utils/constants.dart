import 'package:flutter/material.dart';

/// Central place for colors, spacing, and service type definitions.
/// Keeping this here means the whole app's look can be tweaked from one file.

class AppColors {
  static const Color background = Color(0xFF121417);
  static const Color surface = Color(0xFF1C1F24);
  static const Color surfaceLight = Color(0xFF262A30);
  static const Color accent = Color(0xFFFFA726); // amber accent
  static const Color danger = Color(0xFFEF5350);
  static const Color success = Color(0xFF66BB6A);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFA0A5AC);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.accent,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: AppColors.textPrimary),
        bodyLarge: TextStyle(color: AppColors.textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      useMaterial3: true,
    );
  }
}

/// Service types used across maintenance logs and reminder rules.
/// Each has a default interval in km and months ("whichever comes first").
class ServiceType {
  final String key;
  final String label;
  final IconData icon;
  final int defaultIntervalKm;
  final int defaultIntervalMonths;

  const ServiceType(this.key, this.label, this.icon, this.defaultIntervalKm,
      this.defaultIntervalMonths);

  static const oilChange = ServiceType(
      'oil_change', 'Oil Change', Icons.opacity, 3000, 3);
  static const chain =
      ServiceType('chain', 'Chain Cleaning/Adjust', Icons.link, 1000, 1);
  static const tires =
      ServiceType('tires', 'Tires', Icons.trip_origin, 15000, 24);
  static const brakes =
      ServiceType('brakes', 'Brake Pads', Icons.album, 8000, 12);
  static const tuneUp =
      ServiceType('tune_up', 'General Tune-Up', Icons.build, 6000, 6);
  static const other =
      ServiceType('other', 'Other', Icons.miscellaneous_services, 0, 0);

  static const all = [oilChange, chain, tires, brakes, tuneUp, other];

  static ServiceType fromKey(String key) {
    return all.firstWhere((s) => s.key == key, orElse: () => other);
  }
}
