import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class TaskService {
  final CollectionReference _col = FirebaseFirestore.instance.collection('tasks');

  Stream<List<TaskModel>> watchTasks() {
    return _col.orderBy('createdAt', descending: true).snapshots().map(
        (snap) => snap.docs.map((d) => TaskModel.fromDoc(d)).toList());
  }

  Future<void> addTask(TaskModel model) => _col.add(model.toMap());

  Future<void> updateTask(TaskModel model) => _col.doc(model.id).update(model.toMap());

  Future<void> deleteTask(String id) => _col.doc(id).delete();

  Future<void> toggleComplete(String id, bool value) => _col.doc(id).update({'completed': value});
}
