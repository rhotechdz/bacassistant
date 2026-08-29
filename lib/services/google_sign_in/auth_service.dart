import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static const _webClientId =
      '380411814037-epmk3f1ce3bt7l12mvbnodg6qt4dpb3i.apps.googleusercontent.com';

  final firebaseAuth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn.instance;

  Future<UserCredential> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize(
        serverClientId: _webClientId,
      );

      final account = await _googleSignIn.authenticate();
      final auth = account.authentication;

      final idToken = auth.idToken;

      if (idToken == null) {
        throw StateError(
          'Google Sign-In did not return an ID token. Check the Android OAuth client configuration.',
        );
      }

      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      return await firebaseAuth.signInWithCredential(credential);
    } on GoogleSignInException catch (error) {
      final description = error.description;
      final details = error.details;
      throw StateError(
        'Google Sign-In failed (${error.code})'
        '${description == null ? '' : ': $description'}'
        '${details == null ? '' : ' [$details]'}',
      );
    } on FirebaseAuthException catch (error) {
      throw StateError(
        'Firebase Google authentication failed (${error.code}): '
        '${error.message ?? 'No further details were provided.'}',
      );
    }
  }

  Future<void> signOutWithGoogle() async {
    await _googleSignIn.signOut();
    await firebaseAuth.signOut();
  }
}
