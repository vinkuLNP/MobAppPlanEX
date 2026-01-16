import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:plan_ex_app/core/constants/app_keys.dart';
import 'package:plan_ex_app/core/constants/error_messages.dart';
import 'package:plan_ex_app/core/utils/app_logger.dart';
import 'package:plan_ex_app/features/auth_flow/data/enum.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/models/user_model.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final usersRef = FirebaseFirestore.instance.collection(AppKeys.usersKeyword);

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
      if (e.code == AppKeys.emailAlreadyInUse) {
        return SignUpStatus.alreadyVerified;
      }

      if (e.code == AppKeys.tooManyRequests) {
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
        return AppKeys.unverified;
      }

      return null;
    } on FirebaseAuthException catch (e) {
      AppLogger.logString("Firebase error code: ${e.code}");

      const invalidCredentialCodes = [
        AppKeys.invalidCredentials,
        AppKeys.wrongPassword,
        AppKeys.userNotFound,
        AppKeys.invalidEmail,
        AppKeys.authMalformedCredentials,
        AppKeys.authInvalidCredentials,
      ];

      if (invalidCredentialCodes.contains(e.code)) {
        return ErrorMessages.invalidCredentials;
      }

      return e.message;
    } catch (e) {
      return ErrorMessages.unknown;
    }
  }

  Future<String?> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return ErrorMessages.noUser;
      await user.sendEmailVerification();
      return null;
    } catch (e) {
      AppLogger.error(e.toString());
      return ErrorMessages.verificationAlreadySent;
    }
  }

  Future<String?> resetPassword(String email) async {
    try {
      final e = email.trim();
      final snap = await usersRef
          .where(AppKeys.emailKeyword, isEqualTo: e)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        return ErrorMessages.emailNotRegistered;
      } else {
        await _auth.sendPasswordResetEmail(email: email.trim());
        return null;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return ErrorMessages.unknown;
    }
  }

  bool _googleSigningIn = false;

  Future<String?> signInWithGoogle() async {
    if (_googleSigningIn) return AppKeys.inProgressKeyword;
    _googleSigningIn = true;

    final google = GoogleSignIn.instance;

    try {
      await google.initialize();

      Future<String?> attempt() async {
        try {
          await google.signOut();
        } catch (_) {}

        final completer = Completer<GoogleSignInAuthenticationEventSignIn>();

        final sub = google.authenticationEvents.listen(
          (event) {
            if (event is GoogleSignInAuthenticationEventSignIn &&
                !completer.isCompleted) {
              completer.complete(event);
            }
          },
          onError: (error) {
            if (!completer.isCompleted) {
              completer.completeError(error);
            }
          },
        );

        await google.authenticate();

        final event = await completer.future;
        await sub.cancel();

        final googleUser = event.user;
        final googleAuth = googleUser.authentication;

        if (googleAuth.idToken == null) {
          return AppKeys.missingIdTokenKeyword;
        }

        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return ErrorMessages.googleFailed;

        await createUserDocument(user);
        return null;
      }

      try {
        return await attempt();
      } on GoogleSignInException catch (e) {
        final msg = e.toString().toLowerCase();
        final isReauth =
            msg.contains(AppKeys.reauthKeyword) ||
            msg.contains(ErrorMessages.reAuthFailed);

        if (e.code == GoogleSignInExceptionCode.canceled && isReauth) {
          try {
            await google.disconnect();
          } catch (_) {}
          try {
            await google.signOut();
          } catch (_) {}

          try {
            return await attempt();
          } catch (_) {
            return ErrorMessages.googleReauthFailed;
          }
        }

        if (e.code == GoogleSignInExceptionCode.canceled) {
          return AppKeys.cancelled;
        }

        return "${ErrorMessages.googleSignINFailed} ${e.description ?? e.toString()}";
      }
    } catch (e) {
      return "${ErrorMessages.googleSignINFailed}  $e";
    } finally {
      _googleSigningIn = false;
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

    final model = UserModel.fromFirebaseUser(user, fullName: fullName);

    await usersRef.doc(user.uid).set(model.toMap());
  }
}
