import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plan_ex_app/core/utils/app_logger.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/models/user_model.dart';

class AccountService {
  final _db = FirebaseFirestore.instance.collection('users');

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.id, doc.data()!);
  }

  Future<void> createUser(UserModel model) async {
    await _db.doc(model.uid).set(model.toMap());
  }

  Future<void> updateName(String uid, String name) async {
    await _db.doc(uid).update({'fullName': name});
  }

  Future<void> upgradeUser(String uid) async {
    await _db.doc(uid).update({'isPaid': true});
  }

  Future<void> updateSettings(String uid, Map<String, dynamic> settings) async {
    await _db.doc(uid).update({'settings': settings});
  }

  Future<void> updateStats(String uid, Map<String, dynamic> stats) async {
    await _db.doc(uid).update({'stats': stats});
  }

  Future<String> uploadAvatar(String uid, File file) async {
    return 'url';
  }

  Future<void> deleteAvatarByUrl(String url) async {
    try {
    } catch (e) {
      AppLogger.error(e.toString());
    }
  }

  Future<void> deleteUserDocument(String uid) async {
    await _db.doc(uid).delete();
  }
}
