import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<String?> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user?.updateDisplayName(fullName);
      await cred.user?.sendEmailVerification();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Something went wrong';
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (!cred.user!.emailVerified) {
        final msg = 'Please verify your email before signing in.';
        await _auth.signOut();
        return msg;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Something went wrong';
    }
  }

  Future<String?> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'No user logged in.';
      await user.sendEmailVerification();
      return null;
    } catch (e) {
      return 'Could not send verification email.';
    }
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Something went wrong';
    }
  }

  Future<void> signOut() async => _auth.signOut();
}
