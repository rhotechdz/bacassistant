import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {

  final firebaseAuth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn.instance;

  Future<UserCredential> signInWithGoogle() async {

    try {
      await _googleSignIn.initialize();

      final account = await _googleSignIn.authenticate();
      final auth = account.authentication;

      final credential = GoogleAuthProvider.credential(idToken: auth.idToken);

      final result = await firebaseAuth.signInWithCredential(credential);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOutWithGoogle() async {
    await _googleSignIn.signOut();
    await firebaseAuth.signOut();
  }
}
