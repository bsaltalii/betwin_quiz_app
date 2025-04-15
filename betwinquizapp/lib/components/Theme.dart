import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6CA8F1);
  static const Color secondaryColor = Color.fromRGBO(253, 164, 3, 1.0);

  static const _defaultTextStyle = TextStyle(color: Colors.black);

  static final _quicksandTextStyle = GoogleFonts.quicksand(
    color: Colors.white,
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
  );

  static final _buttonTextStyle = GoogleFonts.quicksand(
    fontWeight: FontWeight.w600,
    fontSize: 18,
    letterSpacing: 1.5,
  );

  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: secondaryColor,
      onSecondary: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
    textTheme: GoogleFonts.quicksandTextTheme().copyWith(
      bodyLarge: _defaultTextStyle.copyWith(fontSize: 16.0),
      bodyMedium: _defaultTextStyle.copyWith(fontSize: 14.0),
      titleLarge: _defaultTextStyle.copyWith(
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      titleTextStyle: _quicksandTextStyle,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryColor,
          disabledBackgroundColor: secondaryColor,
          disabledForegroundColor: Colors.white,
          foregroundColor: Colors.white,
          textStyle: _buttonTextStyle,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        )
    ),
  );
}
