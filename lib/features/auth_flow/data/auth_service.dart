import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:plan_ex_app/core/utils/app_logger.dart';

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
        await _auth.signOut();
        return "unverified";
      }

      return null;
    } on FirebaseAuthException catch (e) {
      AppLogger.logString("Firebase error code: ${e.code}");

      const invalidCredentialCodes = [
        "invalid-credential",
        "wrong-password",
        "user-not-found",
        "invalid-email",
        "auth/malformed-credential",
        "auth/invalid-credential",
      ];

      if (invalidCredentialCodes.contains(e.code)) {
        return "Invalid email or password.";
      }

      return e.message;
    } catch (e) {
      return "Something went wrong";
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

  Future<String?> signInWithGoogle() async {
    try {
      final google = GoogleSignIn.instance;

      await google.initialize();

      final eventCompleter = Completer<GoogleSignInAuthenticationEvent>();

      final sub = google.authenticationEvents.listen(
        (event) {
          if (!eventCompleter.isCompleted) {
            eventCompleter.complete(event);
          }
        },
        onError: (error) {
          if (!eventCompleter.isCompleted) {
            eventCompleter.completeError(error);
          }
        },
      );

      await google.authenticate();

      final event = await eventCompleter.future;

      await sub.cancel();

      final GoogleSignInAccount? googleUser = switch (event) {
        GoogleSignInAuthenticationEventSignIn() => event.user,
        GoogleSignInAuthenticationEventSignOut() => null,
      };

      if (googleUser == null) {
        return "cancelled";
      }

      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.emailVerified) {
        return null;
      } else if (user != null && !user.emailVerified) {
        return "unverified";
      } else {
        return 'error';
      }
    } catch (e) {
      return "Google sign-in failed: $e";
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await GoogleSignIn.instance.disconnect();
    } catch (_) {}
  }
}
