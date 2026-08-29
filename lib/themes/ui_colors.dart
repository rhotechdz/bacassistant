import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // prevent instantiation

  static final Color bgDark = const HSLColor.fromAHSL(1.0, 267, 0.14, 0.90).toColor();
  static final Color bg = const HSLColor.fromAHSL(1.0, 267, 0.31, 0.96).toColor();
  static final Color bgLight = const HSLColor.fromAHSL(1.0, 267, 1.00, 1.00).toColor();

  static final Color text = const HSLColor.fromAHSL(1.0, 269, 0.33, 0.05).toColor();
  static final Color textMuted = const HSLColor.fromAHSL(1.0, 267, 0.08, 0.29).toColor();

  static final Color highlight = const HSLColor.fromAHSL(1.0, 267, 1.00, 1.00).toColor();

  static final Color border = const HSLColor.fromAHSL(1.0, 267, 0.05, 0.52).toColor();
  static final Color borderMuted = const HSLColor.fromAHSL(1.0, 267, 0.07, 0.64).toColor();

  static final Color primary = const HSLColor.fromAHSL(1.0, 271, 0.35, 0.33).toColor();
  static final Color secondary = const HSLColor.fromAHSL(1.0, 77, 0.93, 0.16).toColor();
  static final Color danger = const HSLColor.fromAHSL(1.0, 9, 0.21, 0.41).toColor();
  static final Color warning = const HSLColor.fromAHSL(1.0, 52, 0.23, 0.34).toColor();
  static final Color success = const HSLColor.fromAHSL(1.0, 147, 0.19, 0.36).toColor();
  static final Color info = const HSLColor.fromAHSL(1.0, 217, 0.22, 0.41).toColor();
}

class AppColorsDark {
  AppColorsDark._(); // prevent instantiation

  static final Color bgDark = const HSLColor.fromAHSL(1.0, 266, 0.29, 0.02).toColor();
  static final Color bg = const HSLColor.fromAHSL(1.0, 268, 0.18, 0.05).toColor();
  static final Color bgLight = const HSLColor.fromAHSL(1.0, 267, 0.10, 0.09).toColor();

  static final Color text = const HSLColor.fromAHSL(1.0, 267, 0.77, 0.96).toColor();
  static final Color textMuted = const HSLColor.fromAHSL(1.0, 267, 0.09, 0.71).toColor();

  static final Color highlight = const HSLColor.fromAHSL(1.0, 267, 0.06, 0.40).toColor();

  static final Color border = const HSLColor.fromAHSL(1.0, 267, 0.08, 0.29).toColor();
  static final Color borderMuted = const HSLColor.fromAHSL(1.0, 268, 0.11, 0.19).toColor();

  static final Color primary = const HSLColor.fromAHSL(1.0, 269, 0.55, 0.76).toColor();
  static final Color secondary = const HSLColor.fromAHSL(1.0, 83, 0.35, 0.60).toColor();
  static final Color danger = const HSLColor.fromAHSL(1.0, 9, 0.26, 0.64).toColor();
  static final Color warning = const HSLColor.fromAHSL(1.0, 52, 0.19, 0.57).toColor();
  static final Color success = const HSLColor.fromAHSL(1.0, 146, 0.17, 0.59).toColor();
  static final Color info = const HSLColor.fromAHSL(1.0, 217, 0.28, 0.65).toColor();
}
