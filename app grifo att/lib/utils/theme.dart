import 'package:flutter/material.dart';

class AppTheme {
  // Cores principais do Grifo
  static const Color grifoRed = Color(0xFF750000);
  static const Color grifoRedDark = Color(0xFF5a0000);
  static const Color grifoRedLight = Color(0xFF8B0000);
  
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: grifoRed,
      primary: grifoRed,
      secondary: grifoRedDark,
      error: Colors.red[700]!,
    ),
    scaffoldBackgroundColor: Colors.grey[50],
    
    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: grifoRed,
      foregroundColor: Colors.white,
      elevation: 2,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    // Cards
    cardTheme: CardTheme(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    
    // Botões elevados
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: grifoRed,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Botões de texto
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: grifoRed,
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    
    // Inputs
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: grifoRed, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red[700]!, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    
    // FloatingActionButton
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: grifoRed,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    
    // SnackBar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.grey[800],
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

