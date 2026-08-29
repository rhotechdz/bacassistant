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
  ThemeBloc() : super(ThemeState(ThemeMode.light)) {
    on<ToggleTheme>((event, emit) {
      final newMode = state.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
      emit(ThemeState(newMode));
    });
  }
}
