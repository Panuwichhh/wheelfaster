// controllers/auth_controller.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  final _auth = FirebaseAuth.instance;

  Future<User?> signIn(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  User? get currentUser => _auth.currentUser;

  Future<void> signOut() async => _auth.signOut();
}
