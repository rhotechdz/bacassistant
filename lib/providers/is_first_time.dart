import 'package:flutter_bloc/flutter_bloc.dart';

// --- EVENTS ---
abstract class FirstTimeEvent {}
class CheckFirstTime extends FirstTimeEvent {}
class SetFirstTimeDone extends FirstTimeEvent {}

// --- STATE ---
class FirstTimeState {
  final bool isFirstTime;
  FirstTimeState(this.isFirstTime);
}

// --- BLOC ---
class FirstTimeBloc extends Bloc<FirstTimeEvent, FirstTimeState> {
  FirstTimeBloc() : super(FirstTimeState(true)) {
    on<CheckFirstTime>((event, emit) {
      // In real app you’d read SharedPreferences
      emit(FirstTimeState(state.isFirstTime));
    });

    on<SetFirstTimeDone>((event, emit) {
      // Save to SharedPreferences normally
      emit(FirstTimeState(false));
    });
  }
}
