import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plan_ex_app/core/utils/app_logger.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class AccountService {
  final _db = FirebaseFirestore.instance.collection('users');

  Stream<UserModel?> watchUser(String uid) {
    return _db.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.id, doc.data()!);
    });
  }

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
    await _db.doc(uid).set({'stats': stats}, SetOptions(merge: true));
  }

  Future<void> updateAvatar(String uid, String avatarUrl) async {
    await _db.doc(uid).update({'photoUrl': avatarUrl});
  }

  Future<String> uploadAvatarToSupabase(String uid, File file) async {
    final supabase = Supabase.instance.client;
    final id = const Uuid().v4();

    final ext = file.path.split('.').last;
    final filePath = "avatars/$uid/$id.$ext";
    final fileBytes = await file.readAsBytes();

    await supabase.storage
        .from('user_avatars')
        .uploadBinary(
          filePath,
          fileBytes,
          fileOptions: FileOptions(contentType: "image/$ext"),
        );

    return filePath;
  }

  Future<String?> getFreshAvatarUrl(String path) async {
    final supabase = Supabase.instance.client;
    return await supabase.storage
        .from('user_avatars')
        .createSignedUrl(path, 60 * 60 * 24 * 7);
  }

  Future<void> deleteSupabaseAvatarByPath(String path) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.storage.from('user_avatars').remove([path]);
    } catch (e) {
      AppLogger.error(e.toString());
    }
  }

  Future<void> deleteAvatarByUrl(String url) async {
    try {} catch (e) {
      AppLogger.error(e.toString());
    }
  }

  Future<void> deleteUserDocument(String uid) async {
    final userRef = _db.doc(uid);
    final subCollections = ['tasks', 'notes'];

    for (String collection in subCollections) {
      final colRef = userRef.collection(collection);
      final snapshots = await colRef.get();

      for (var doc in snapshots.docs) {
        await doc.reference.delete();
      }
    }
    await userRef.delete();
  }
}
