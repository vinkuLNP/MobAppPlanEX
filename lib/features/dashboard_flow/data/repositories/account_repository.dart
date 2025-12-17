import 'dart:io';

import 'package:plan_ex_app/features/dashboard_flow/data/database/account_local_datasource.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/database/account_service.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/models/user_model.dart';
import 'package:plan_ex_app/features/dashboard_flow/domain/entities/user_entity.dart';

class AccountRepository {
  final AccountService service;
  final AccountLocalDataSource local;

  AccountRepository(this.service, this.local);

  Stream<UserEntity> watchUser(String uid) async* {
    final cached = local.getUser();
    if (cached != null && cached.uid == uid) {
      yield cached;
    }

    await for (final user in service.watchUser(uid)) {
      if (user == null) continue;

      await local.saveUser(user);

      yield user;
    }
  }

  Future<UserEntity> getUser(String uid) async {
    final cached = local.getUser();
    if (cached != null && cached.uid == uid) {
      return cached;
    }

    final user = await service.getUser(uid);
    if (user != null) {
      await local.saveUser(user);
      return user;
    }

    final newUser = UserModel(
      uid: uid,
      fullName: '',
      email: '',
      isPaid: false,
      photoUrl: '',
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

    await service.createUser(newUser);
    await local.saveUser(newUser);
    return newUser;
  }

  Future<void> updateName(String uid, String name) async {
    await service.updateName(uid, name);

    final current = local.getUser();
    if (current != null) {
      await local.saveUser(current.copyWith(fullName: name));
    }
  }

  Future<void> upgradeUser(String uid) async {
    await service.upgradeUser(uid);

    final current = local.getUser();
    if (current != null) {
      await local.saveUser(current.copyWith(isPaid: true));
    }
  }

  Future<String> uploadAvatar(String uid, File file) =>
      service.uploadAvatarToSupabase(uid, file);

  Future<String?> getFreshAvatarUrl(String path) =>
      service.getFreshAvatarUrl(path);

  Future<void> deleteAvatarByPath(String path) =>
      service.deleteSupabaseAvatarByPath(path);

  Future<void> updateAvatar(String uid, String avatarUrl) async {
    await service.updateAvatar(uid, avatarUrl);

    final current = local.getUser();
    if (current != null) {
      await local.saveUser(current.copyWith(photoUrl: avatarUrl));
    }
  }

  Future<void> updateSettings(String uid, Map<String, dynamic> partial) async {
final current = local.getUser();
  if (current == null) return;
 final merged = {
    'darkMode': partial['darkMode'] ?? current.darkMode,
    'showCreationDates':
        partial['showCreationDates'] ?? current.showCreationDates,
    'dailySummary': partial['dailySummary'] ?? current.dailySummary,
    'taskReminders': partial['taskReminders'] ?? current.taskReminders,
    'overdueAlerts': partial['overdueAlerts'] ?? current.overdueAlerts,
    'autoSave': partial['autoSave'] ?? current.autoSave,
  };

    await service.updateSettings(uid, merged);

      await local.saveUser(
        current.copyWith(
          darkMode: merged['darkMode'],
          showCreationDates: merged['showCreationDates'],
          dailySummary: merged['dailySummary'],
          taskReminders: merged['taskReminders'],
          overdueAlerts: merged['overdueAlerts'],
          autoSave: merged['autoSave'],
        ),
      );
  }

  Future<void> updateStats(String uid, Map<String, dynamic> stats) async {
    await service.updateStats(uid, stats);

    final current = local.getUser();
    if (current != null) {
      await local.saveUser(
        current.copyWith(
          totalNotes: stats['totalNotes'],
          totalTasks: stats['totalTasks'],
          completedTasks: stats['completedTasks'],
        ),
      );
    }
  }

  Future<void> deleteUserDocument(String uid) async {
    await service.deleteUserDocument(uid);
    await local.clear();
  }

  Future<void> logout() async {
    await local.clear();
  }
}
