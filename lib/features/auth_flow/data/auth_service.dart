import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:plan_ex_app/core/utils/app_logger.dart';
import 'package:plan_ex_app/features/auth_flow/data/enum.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/models/user_model.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final usersRef = FirebaseFirestore.instance.collection('users');

  Future<SignUpStatus> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = cred.user;
      if (user == null) return SignUpStatus.failure;

      await user.updateDisplayName(fullName);

      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }

      await createUserDocument(user, fullName: fullName);

      return SignUpStatus.success;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        try {
          final loginCred = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );

          final existingUser = loginCred.user;

          if (existingUser != null && !existingUser.emailVerified) {
            await existingUser.sendEmailVerification();
            return SignUpStatus.unverifiedExisting;
          }

          return SignUpStatus.alreadyVerified;
        } on FirebaseAuthException catch (loginError) {
          if (loginError.code == 'wrong-password' ||
              loginError.code == 'invalid-credential') {
            await _auth.sendPasswordResetEmail(email: email);

            return SignUpStatus.resetPasswordSent;
          }

          return SignUpStatus.failure;
        }
      }

      if (e.code == 'too-many-requests') {
        return SignUpStatus.tooManyRequests;
      }

      return SignUpStatus.failure;
    } catch (_) {
      return SignUpStatus.failure;
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
        return "Invalid email or password!";
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
      AppLogger.error(e.toString());
      return 'Verification link has already been sent to your email. For another verification email, Try again later.';
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
        await createUserDocument(user);
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

  Future<String?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);

      final user = userCredential.user;

      if (user != null && user.emailVerified) {
        await createUserDocument(user);
        return null;
      } else if (user != null && !user.emailVerified) {
        return "unverified";
      } else {
        return "error";
      }
    } catch (e) {
      if (e.toString().contains("AuthorizationErrorCode.canceled")) {
        return "cancelled";
      }
      return "Apple sign-in failed: $e";
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await GoogleSignIn.instance.disconnect();
    } catch (_) {}
  }

  Future<void> createUserDocument(User user, {String fullName = ''}) async {
    final doc = await usersRef.doc(user.uid).get();

    if (doc.exists) return;

    final model = UserModel(
      uid: user.uid,
      fullName: user.displayName ?? fullName,
      email: user.email ?? "",
      isPaid: false,
      photoUrl: user.photoURL ?? "",
      createdAt: DateTime.now(),
      darkMode: false,
      showCreationDates: false,
      dailySummary: false,
      taskReminders: false,
      overdueAlerts: false,
      autoSave: false,
      totalNotes: 0,
      totalTasks: 0,
      completedTasks: 0,
    );

    await usersRef.doc(user.uid).set(model.toMap());
  }
}
