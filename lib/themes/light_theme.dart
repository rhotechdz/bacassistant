import 'package:bacassistant/themes/ui_colors.dart';
import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  fontFamily: 'Tajawal',
  useMaterial3: true,
  splashFactory: InkRipple.splashFactory,
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white, // or AppColors.text depending on contrast
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    error: AppColors.danger,
    onError: Colors.white,
    surface: AppColors.bgLight,
    onSurface: AppColors.text,
  ),
);

ThemeData darkTheme = ThemeData(
  fontFamily: 'Tajawal',
  useMaterial3: true,
  splashFactory: InkRipple.splashFactory,
  colorScheme: ColorScheme(
    brightness: Brightness.dark,
    primary: AppColorsDark.primary,
    onPrimary: AppColorsDark.text, // or AppColorsDark.text for contrast
    secondary: AppColorsDark.secondary,
    onSecondary: AppColorsDark.text,
    error: AppColorsDark.danger,
    onError: AppColorsDark.text,
    surface: AppColorsDark.bgLight,
    onSurface: AppColorsDark.text,
  ),
);
