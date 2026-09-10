import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

// --- EVENTS ---
abstract class ThemeEvent {}

class ToggleTheme extends ThemeEvent {}

// --- STATE ---
class ThemeState {
  final ThemeMode themeMode;
  ThemeState(this.themeMode);
}

// --- BLOC ---
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState(ThemeMode.system)) {
    on<ToggleTheme>((event, emit) {
      final currentBrightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      final currentMode = state.themeMode == ThemeMode.system
          ? (currentBrightness == Brightness.dark
              ? ThemeMode.dark
              : ThemeMode.light)
          : state.themeMode;
      final newMode =
          currentMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      emit(ThemeState(newMode));
    });
  }
}
