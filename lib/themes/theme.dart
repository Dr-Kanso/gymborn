import 'package:flutter/material.dart';

// Colors
const Color kPrimaryColor = Color(0xFF6D72C3); // Soft lavender
const Color kSecondaryColor = Color(0xFF5FD8D5); // Soft teal
const Color kAccentColor = Color(0xFFF9B9B7); // Soft coral
const Color kBackgroundColor = Color(0xFFF7F7FF); // Light background
const Color kTextColor = Color(0xFF2D2D34); // Dark grey text
const Color kLightTextColor = Color(0xFF6E7191); // Light grey text

// Stat colors
const Color kStrColor = Color(0xFFE07A7A); // Red for STR
const Color kEndColor = Color(0xFF76E5C4); // Green for END
const Color kWisColor = Color(0xFF8093F1); // Blue for WIS
const Color kRecColor = Color(0xFFFDCA40); // Yellow for REC

final ThemeData gymBornTheme = ThemeData(
  primaryColor: kPrimaryColor,
  scaffoldBackgroundColor: kBackgroundColor,
  colorScheme: ColorScheme.light(
    primary: kPrimaryColor,
    secondary: kSecondaryColor,
    surface: Colors.white,
    error: Colors.redAccent,
    onPrimary: Colors.white,
    onSecondary: kTextColor,
    onSurface: kTextColor,
    onError: Colors.white,
    brightness: Brightness.light,
  ),
  fontFamily: 'Quicksand',
  textTheme: TextTheme(
    displayLarge: TextStyle(color: kTextColor, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(color: kTextColor, fontWeight: FontWeight.bold),
    displaySmall: TextStyle(color: kTextColor, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(color: kTextColor, fontWeight: FontWeight.w700),
    headlineSmall: TextStyle(color: kTextColor),
    titleLarge: TextStyle(color: kTextColor, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(color: kTextColor),
    titleSmall: TextStyle(color: kTextColor, fontWeight: FontWeight.w500),
    bodyLarge: TextStyle(color: kTextColor),
    bodyMedium: TextStyle(color: kTextColor),
    labelLarge: TextStyle(color: kTextColor, fontWeight: FontWeight.w500),
    bodySmall: TextStyle(color: kLightTextColor),
    labelSmall: TextStyle(color: kLightTextColor),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kPrimaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
    ),
  ),
  cardTheme: CardTheme(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
    elevation: 4.0,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: kTextColor),
    titleTextStyle: TextStyle(
      color: kTextColor,
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
      fontFamily: 'Quicksand',
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: kPrimaryColor,
    unselectedItemColor: kLightTextColor,
    type: BottomNavigationBarType.fixed,
    elevation: 8.0,
  ),
);
