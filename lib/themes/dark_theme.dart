import 'package:bacassistant/themes/ui_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: darkColorScheme.surface,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: darkColorScheme.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  ),
  scaffoldBackgroundColor: darkColorScheme.surface,
);
