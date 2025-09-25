import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0D0D0D); // Deep Charcoal
  static const Color card = Color(0xFF1E1E1E);       // Surface
  static const Color primary = Color(0xFF2979FF);    // Electric Blue
  static const Color secondary = Colors.white;  // Emerald Green
  static const Color accentOrange = Color(0xFFFF6D00);
  static const Color textMain = Colors.white;
  static const Color textSecondary = Color(0xFF9E9E9E);


}

ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.background,

  colorScheme: ColorScheme.dark(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    background: AppColors.background,
    onBackground: AppColors.textMain,
    surface: AppColors.card,
    onSurface: AppColors.textMain,
    error: AppColors.accentOrange,
    onError: Colors.white,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.background,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),

  cardTheme: const CardThemeData(
    color: AppColors.card,
    surfaceTintColor: AppColors.card,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
    elevation: 3,
  ),

  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontSize: 16, color: AppColors.textMain),
    bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondary),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppColors.textMain,
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF0D0D0D),
      foregroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
  ),

  chipTheme: ChipThemeData(
    backgroundColor: AppColors.primary.withOpacity(0.2),
    labelStyle: const TextStyle(color: AppColors.textMain),
    selectedColor: AppColors.accentOrange.withOpacity(0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
);
