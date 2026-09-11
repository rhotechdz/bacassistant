import 'package:flutter/material.dart';
import 'package:bacassistant/themes/ui_colors.dart';
import 'package:bacassistant/utils/system_ui.dart';

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
    systemOverlayStyle: systemUiStyleFor(
      lightColorScheme,
      brightness: Brightness.light,
    ),
  ),
  scaffoldBackgroundColor: lightColorScheme.surface,
);
