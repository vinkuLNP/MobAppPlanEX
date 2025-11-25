import 'dart:io';

import 'package:plan_ex_app/features/dashboard_flow/data/database/account_service.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/models/user_model.dart';
import 'package:plan_ex_app/features/dashboard_flow/domain/entities/user_entity.dart';

class AccountRepository {
  final AccountService service;

  AccountRepository(this.service);

  Future<UserEntity> getUser(String uid) async {
    final user = await service.getUser(uid);
    if (user != null) return user;

    final newUser = UserModel(uid: uid, fullName: '', email: '', isPaid: false);

    await service.createUser(newUser);
    return newUser;
  }

  Future<void> updateName(String uid, String name) =>
      service.updateName(uid, name);

  Future<void> upgradeUser(String uid) => service.upgradeUser(uid);

  Future<String> uploadAvatar(String uid, File file) =>
      service.uploadAvatar(uid, file);

  Future<void> updateSettings(String uid, Map<String, dynamic> settings) =>
      service.updateSettings(uid, settings);

  Future<void> updateStats(String uid, Map<String, dynamic> stats) =>
      service.updateStats(uid, stats);

  Future<void> deleteUserDocument(String uid) =>
      service.deleteUserDocument(uid);

  Future<void> deleteAvatarByUrl(String url) => service.deleteAvatarByUrl(url);
}
