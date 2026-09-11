import 'package:bacassistant/themes/ui_colors.dart';
import 'package:flutter/material.dart';
import 'package:bacassistant/utils/system_ui.dart';

final ColorScheme darkColorScheme = ColorScheme.fromSeed(
  seedColor: AppColorsDark.primary,
  brightness: Brightness.dark,
);

final ThemeData darkTheme = ThemeData(
  colorScheme: darkColorScheme,
  fontFamily: 'Tajawal',
  useMaterial3: true,
  splashFactory: InkRipple.splashFactory,
  appBarTheme: AppBarTheme(
    backgroundColor: darkColorScheme.surface,
    foregroundColor: darkColorScheme.onSurface,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    systemOverlayStyle: systemUiStyleFor(
      darkColorScheme,
      brightness: Brightness.dark,
    ),
  ),
  scaffoldBackgroundColor: darkColorScheme.surface,
);
