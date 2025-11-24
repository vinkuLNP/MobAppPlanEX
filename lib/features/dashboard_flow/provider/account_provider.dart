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

  UserEntity? user;
  bool loading = true;
  bool saving = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();


  String? localImagePath;

  Future<void> init() async {
    if (!loading) return;
    await loadUser();
  }

  Future<void> loadUser() async {
    loading = true;
    notifyListeners();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      loading = false;
      notifyListeners();
      return;
    }

    user = await repository.getUser(uid);

    nameController.text = user?.fullName ?? '';

    try {
      final notesSnap = await FirebaseFirestore.instance
          .collection('notes')
          .where('ownerId', isEqualTo: uid)
          .get();
      final tasksSnap = await FirebaseFirestore.instance
          .collection('tasks')
          .where('ownerId', isEqualTo: uid)
          .get();
      final completedTasksSnap = await FirebaseFirestore.instance
          .collection('tasks')
          .where('ownerId', isEqualTo: uid)
          .where('completed', isEqualTo: true)
          .get();

      final totalNotes = notesSnap.docs.length;
      final totalTasks = tasksSnap.docs.length;
      final completedTasks = completedTasksSnap.docs.length;

      user = user?.copyWith(
        totalNotes: totalNotes,
        totalTasks: totalTasks,
        completedTasks: completedTasks,
      );
    } catch (e) {
      AppLogger.error(e.toString());
    }

    loading = false;
    notifyListeners();
  }

  Future<void> saveName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    saving = true;
    notifyListeners();
    final newName = nameController.text.trim();
    await repository.updateName(uid, newName);
    user = user?.copyWith(fullName: newName);
    saving = false;
    notifyListeners();
  }

  Future<void> pickAndUploadAvatar(ImageSource source) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (picked == null) return;

    localImagePath = picked.path;
    notifyListeners();

    final file = File(picked.path);
    final oldUrl = user?.photoUrl;
    final newUrl = await repository.uploadAvatar(uid, file);

    if (oldUrl != null && oldUrl.isNotEmpty) {
      await repository.deleteAvatarByUrl(oldUrl);
    }

    user = user?.copyWith(photoUrl: newUrl);
    notifyListeners();
  }

  Future<void> toggleSetting(String key, bool value) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

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

    notifyListeners();
  }

  Future<void> upgrade() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await repository.upgradeUser(uid);
    user = user?.copyWith(isPaid: true);
    notifyListeners();
  }

  Future<String?> deleteAccount({required String? passwordForReauth}) async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final uid = firebaseUser?.uid;
    if (uid == null) return 'No user signed in';

    try {
      if (passwordForReauth != null && firebaseUser?.email != null) {
        final cred = EmailAuthProvider.credential(
          email: firebaseUser!.email!,
          password: passwordForReauth,
        );
        await firebaseUser.reauthenticateWithCredential(cred);
      }

      if (user?.photoUrl != null) {
        await repository.deleteAvatarByUrl(user!.photoUrl!);
      }

      await repository.deleteUserDocument(uid);

      await firebaseUser!.delete();

      return null;
    } on FirebaseAuthException catch (e) {
      return e.code;
    } catch (e) {
      return e.toString();
    }
  }
}
