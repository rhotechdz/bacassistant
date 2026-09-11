import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _systemUiChannel = MethodChannel('bacassistant/system_ui');

SystemUiOverlayStyle systemUiStyleFor(
  ColorScheme colorScheme, {
  required Brightness brightness,
  Color? barColor,
}) {
  final isDark = brightness == Brightness.dark;
  final iconBrightness = isDark ? Brightness.light : Brightness.dark;

  return SystemUiOverlayStyle(
    statusBarColor: barColor ?? colorScheme.surface,
    statusBarIconBrightness: iconBrightness,
    statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    systemStatusBarContrastEnforced: false,
    systemNavigationBarColor: barColor ?? colorScheme.surface,
    systemNavigationBarIconBrightness: iconBrightness,
    systemNavigationBarContrastEnforced: false,
  );
}

void applySystemUiStyle(ThemeData theme) {
  final style = systemUiStyleFor(
    theme.colorScheme,
    brightness: theme.brightness,
  );
  SystemChrome.setSystemUIOverlayStyle(style);
  unawaited(
    _systemUiChannel.invokeMethod<void>('setColors', <String, Object>{
      'color': theme.colorScheme.surface.toARGB32(),
      'darkIcons': theme.brightness == Brightness.light,
    }),
  );
}
