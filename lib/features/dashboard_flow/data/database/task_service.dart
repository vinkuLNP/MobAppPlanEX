import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';

class TaskService {
  CollectionReference<Map<String, dynamic>> _col() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("tasks");
  }

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return FirebaseFirestore.instance.collection("users").doc(uid);
  }

  Stream<List<TaskModel>> watchTasks() {
    return _col()
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => TaskModel.fromDoc(d)).toList());
  }

  Future<Map<String, dynamic>> addTask(TaskModel model) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await _col().add(model.toMap());
    return await _updateTaskStats(uid);
  }

  Future<Map<String, dynamic>> deleteTask(String id) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await _col().doc(id).delete();
    return await _updateTaskStats(uid);
  }

  Future<Map<String, dynamic>> toggleComplete(String id, bool value) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await _col().doc(id).update({"completed": value});
    return await _updateTaskStats(uid);
  }

  Future<void> updateTask(TaskModel model) =>
      _col().doc(model.id).update(model.toMap());

  Future<Map<String, dynamic>> _updateTaskStats(String uid) async {
    final allTasks = await _col().get();
    final completed = await _col().where("completed", isEqualTo: true).get();

    final stats = {
      "totalTasks": allTasks.docs.length,
      "completedTasks": completed.docs.length,
    };

    await _userDoc(uid).set({"stats": stats}, SetOptions(merge: true));

    return stats;
  }
}
