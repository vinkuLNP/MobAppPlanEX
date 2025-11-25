import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plan_ex_app/core/utils/app_logger.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/repositories/account_repository.dart';
import 'package:plan_ex_app/features/dashboard_flow/domain/entities/user_entity.dart';

class AccountProvider extends ChangeNotifier {
  final AccountRepository repository;
  AccountProvider(this.repository);
  final auth = FirebaseAuth.instance.currentUser;

  UserEntity? user;
  bool loading = true;
  bool saving = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();

  String? localImagePath;
  bool processing = false;

  void _setProcessing(bool value) {
    processing = value;
    notifyListeners();
  }

  Future<void> init() async {
    loading = true;
    notifyListeners();

    final cached = repository.local.getUser();
    if (cached != null) {
      user = cached;
      nameController.text = user!.fullName;
      emailController.text = user!.email;
      notifyListeners();
    }

    await loadUser();
  }

  Future<void> loadUser() async {
    loading = true;
    notifyListeners();

    final uid = auth?.uid;
    if (uid == null) {
      loading = false;
      notifyListeners();
      return;
    }

    user = await repository.getUser(uid);

    nameController.text = user?.fullName ?? '';
    emailController.text = user?.email ?? '';
    try {
      FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .snapshots()
          .listen((doc) {
            final stats = doc.data()?['stats'];
            if (stats != null) {
              repository.updateStats(uid, {
                'totalNotes': stats['totalNotes'],
                'totalTasks': stats['totalTasks'],
                'completedTasks': stats['completedTasks'],
              });
            }
          });
    } catch (e) {
      AppLogger.error(e.toString());
    }

    loading = false;
    notifyListeners();
  }

  Future<void> saveName() async {
    final uid = auth?.uid;
    if (uid == null) return;
    _setProcessing(true);
    saving = true;
    notifyListeners();
    final newName = nameController.text.trim();
    await repository.updateName(uid, newName);
    user = user?.copyWith(fullName: newName);
    saving = false;
    _setProcessing(false);
    notifyListeners();
  }

  Future<void> pickAndUploadAvatar(ImageSource source) async {
    final uid = auth?.uid;
    if (uid == null) return;
    _setProcessing(true);
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (picked == null) {
      _setProcessing(false);
      return;
    }

    localImagePath = picked.path;
    notifyListeners();

    final file = File(picked.path);
    final oldPath = user?.photoUrl;
    final newPath = await repository.uploadAvatar(uid, file);
    await repository.updateAvatar(uid, newPath);

    if (oldPath != null && oldPath.isNotEmpty) {
      await repository.deleteAvatarByPath(oldPath);
    }

    user = user?.copyWith(photoUrl: newPath);
    _setProcessing(false);
    notifyListeners();
  }

  Future<String?> getAvatarUrl() async {
    if (user?.photoUrl == null) return null;
    return await repository.getFreshAvatarUrl(user!.photoUrl!);
  }

  Future<void> toggleSetting(String key, bool value) async {
    final uid = auth?.uid;
    if (uid == null) return;
    _setProcessing(true);
    final settings = {
      'darkMode': user?.darkMode ?? false,
      'showCreationDates': user?.showCreationDates ?? false,
      'dailySummary': user?.dailySummary ?? false,
      'taskReminders': user?.taskReminders ?? false,
      'overdueAlerts': user?.overdueAlerts ?? false,
      'autoSave': user?.autoSave ?? false,
    };

    settings[key] = value;
    await repository.updateSettings(uid, settings);

    user = user?.copyWith(
      darkMode: settings['darkMode'],
      showCreationDates: settings['showCreationDates'],
      dailySummary: settings['dailySummary'],
      taskReminders: settings['taskReminders'],
      overdueAlerts: settings['overdueAlerts'],
      autoSave: settings['autoSave'],
    );
    _setProcessing(false);
    notifyListeners();
  }

  Future<void> upgrade() async {
    final uid = auth?.uid;
    if (uid == null) return;
    await repository.upgradeUser(uid);
    user = user?.copyWith(isPaid: true);
    notifyListeners();
  }

  Future<String?> deleteAccount({required String? passwordForReauth}) async {
    final firebaseUser = auth;
    final uid = firebaseUser?.uid;
    if (uid == null) return 'No user signed in';
    _setProcessing(true);
    try {
      if (passwordForReauth != null && firebaseUser?.email != null) {
        final cred = EmailAuthProvider.credential(
          email: firebaseUser!.email!,
          password: passwordForReauth,
        );
        await firebaseUser.reauthenticateWithCredential(cred);
      }

      if (user?.photoUrl != null) {
        await repository.deleteAvatarByPath(user!.photoUrl!);
      }

      await repository.deleteUserDocument(uid);

      await firebaseUser!.delete();
      _setProcessing(false);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.code;
    } catch (e) {
      return e.toString();
    } finally {
      _setProcessing(false);
    }
  }
}
