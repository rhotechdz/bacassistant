import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  splashFactory: InkRipple.splashFactory,
  fontFamily: 'Tajawal',
  colorSchemeSeed: Colors.indigo,
  brightness: Brightness.dark,
  appBarTheme: AppBarTheme(
    backgroundColor: const Color(0xFFF0EFFF),
    iconTheme: IconThemeData(
      color: Colors.lightBlue[300]
    ),
  ),
  /* colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue, // change seed for your brand color
    brightness: Brightness.light,
  ), */
  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontSize: 16),
    bodyMedium: TextStyle(fontSize: 14),
  ),
);