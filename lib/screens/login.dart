import 'package:flutter/material.dart';
import 'package:bacassistant/services/google_sign_in/auth_service.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void _onPhoneLogin(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Phone login pressed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Signed in as'),
                        content: Column(
                          children: [
                            Text(AuthService().firebaseAuth.currentUser?.uid ?? 'No user signed in'),
                            Text(AuthService().firebaseAuth.currentUser?.displayName ?? 'No user signed in'),
                            Text(AuthService().firebaseAuth.currentUser?.email ?? 'No user signed in'),
                            Text(AuthService().firebaseAuth.currentUser?.photoURL ?? 'No user signed in'),

                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Get Current User ID'),
              ),
              FilledButton.icon(
                icon: const Icon(Icons.phone),
                label: const Text('Login with Phone Number'),
                onPressed: () => _onPhoneLogin(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.abc_outlined),
                label: const Text('Login with Google'),
                onPressed: () async {
                  try {
                    await AuthService().signInWithGoogle();
                  } catch (error) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Google login failed: $error')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: Colors.grey),
                ),
              ),
              FilledButton(
                onPressed: () {
                  AuthService().signOutWithGoogle();
                },
                child: const Text('Sign Out'),
              )
            ],
          ),
        ),
      ),
    );
  }
}