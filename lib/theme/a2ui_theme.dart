import 'package:flutter/material.dart';
import 'a2ui_colors.dart';

class A2Theme {
  A2Theme._();

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: A2Colors.bg,
      colorScheme: const ColorScheme.dark(
        surface: A2Colors.card,
        primary: A2Colors.cyan,
        secondary: A2Colors.ambre,
        error: A2Colors.rouge,
      ),
      fontFamily: 'system-ui',
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: A2Colors.blanc, fontWeight: FontWeight.w700),
        bodyMedium: TextStyle(color: A2Colors.blanc),
        labelSmall: TextStyle(
          color: A2Colors.gris1, // gris2 trop sombre sur fond dark — v1.4
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: A2Colors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: A2Colors.border2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: A2Colors.border2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: A2Colors.cyan),
        ),
        labelStyle: const TextStyle(
          color: A2Colors.gris1,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
        hintStyle: const TextStyle(
          color: A2Colors.gris1,
          fontWeight: FontWeight.w500,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: A2Colors.cyanDark,
          foregroundColor: Colors.black,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      cardTheme: CardThemeData(
        color: A2Colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: A2Colors.border),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }
}
