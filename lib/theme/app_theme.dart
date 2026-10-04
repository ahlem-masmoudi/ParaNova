import 'package:flutter/material.dart';

class AppTheme {
  // Couleurs principales - Thème Rose Pastel Cute 🌸
  static const Color rosePrimary = Color(0xFFFFB6C1); // Rose clair
  static const Color rosePastel = Color(0xFFFFC0CB); // Rose pastel
  static const Color lavandePastel = Color(0xFFE6E6FA); // Lavande
  static const Color bleuPastel = Color(0xFFB0E0E6); // Bleu pastel
  static const Color mintPastel = Color(0xFFB5EAD7); // Mint
  static const Color pechePastel = Color(0xFFFFDAB9); // Pêche
  static const Color roseFonce = Color(0xFFFF69B4); // Rose foncé
  static const Color blanc = Color(0xFFFFFBF5); // Blanc crème

  // Thème principal
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Couleurs principales
      primaryColor: rosePrimary,
      scaffoldBackgroundColor: blanc,
      colorScheme: const ColorScheme.light(
        primary: rosePrimary,
        secondary: lavandePastel,
        tertiary: mintPastel,
        surface: Colors.white,
        error: Color(0xFFFFB4AB),
        onPrimary: Colors.white,
        onSecondary: Color(0xFF5D4E6D),
        onSurface: Color(0xFF4A4458),
        onError: Colors.white,
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: rosePrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      // Cards - CORRIGÉ
      cardTheme: const CardThemeData(elevation: 2, color: Colors.white),

      // Boutons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: rosePrimary,
          foregroundColor: Colors.white,
          elevation: 3,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: roseFonce,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: rosePastel.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: rosePrimary.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: rosePrimary.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: rosePrimary, width: 2),
        ),
        labelStyle: const TextStyle(color: Color(0xFF5D4E6D)),
        hintStyle: TextStyle(color: Colors.grey[400]),
      ),

      // Texte
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4A4458),
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4A4458),
        ),
        bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF4A4458)),
        bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF5D4E6D)),
      ),

      // IconButton
      iconTheme: const IconThemeData(color: roseFonce),

      // Divider
      dividerTheme: DividerThemeData(
        color: rosePrimary.withOpacity(0.2),
        thickness: 1,
        space: 20,
      ),
    );
  }

  // Couleurs pour les catégories de produits
  static Color getCategorieColor(String categorie) {
    switch (categorie) {
      case 'Soins Solaires':
        return pechePastel;
      case 'Crèmes Hydratantes':
        return bleuPastel;
      case 'Soins du Visage':
        return rosePastel;
      case 'Hygiène & Bien-être':
        return mintPastel;
      case 'Compléments Alimentaires':
        return lavandePastel;
      case 'Soins Spécifiques':
        return const Color(0xFFFFE4E1);
      default:
        return Colors.grey[300]!;
    }
  }
}
