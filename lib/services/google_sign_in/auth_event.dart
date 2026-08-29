import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthEvent {}

class AppStarted extends AuthEvent {}
class LoggedIn extends AuthEvent {
  final User user;
  LoggedIn(this.user);
}
class LoggedOut extends AuthEvent {}
