import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authSubscription;

  AuthBloc() : super(AuthInitial()) {

    on<AppStarted>((event, emit) {
      emit(AuthLoading());

      _authSubscription = _auth.authStateChanges().listen((user) {
        if (user == null) {
          add(LoggedOut());
        } else {
          add(LoggedIn(user));
        }
      });
    });

    on<LoggedIn>((event, emit) {
      emit(Authenticated(event.user));
    });

    on<LoggedOut>((event, emit) async {
      //await _auth.signOut();
      emit(Unauthenticated());
    });
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
