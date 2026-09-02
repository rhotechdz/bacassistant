import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bacassistant/themes/ui_colors.dart';

final ColorScheme lightColorScheme = ColorScheme.fromSeed(
  seedColor: AppColors.primary,
  brightness: Brightness.light,
);

ThemeData lightTheme = ThemeData(
  colorScheme: lightColorScheme,
  fontFamily: 'Tajawal',
  useMaterial3: true,
  splashFactory: InkRipple.splashFactory,
  appBarTheme: AppBarTheme(
    backgroundColor: lightColorScheme.surface,
    foregroundColor: lightColorScheme.onSurface,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: lightColorScheme.surface,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: lightColorScheme.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  ),
  scaffoldBackgroundColor: lightColorScheme.surface,
);
