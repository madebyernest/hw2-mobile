import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final Stream<User?> authState = _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> register({
    required String email,
    required String password,
  }) =>
      _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  Future<void> signOut() => _auth.signOut();

  static String message(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return 'That email address looks invalid.';
        case 'weak-password':
          return 'Password must be at least 6 characters.';
        case 'email-already-in-use':
          return 'An account already exists for that email.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Email or password is incorrect.';
        case 'network-request-failed':
          return 'Network problem. Check your connection and retry.';
        case 'too-many-requests':
          return 'Too many attempts. Try again later.';
      }
    }
    return 'Something went wrong. Please try again.';
  }
}
