import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plan_ex_app/features/dashboard_flow/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.uid,
    required super.fullName,
    required super.email,
    required super.isPaid,
    super.photoUrl,
    super.createdAt,
    super.darkMode,
    super.showCreationDates,
    super.dailySummary,
    super.taskReminders,
    super.overdueAlerts,
    super.autoSave,
    super.totalNotes,
    super.totalTasks,
    super.completedTasks,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      isPaid: map['isPaid'] ?? false,
      photoUrl: map['photoUrl'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      darkMode: map['settings']?['darkMode'] ?? false,
      showCreationDates: map['settings']?['showCreationDates'] ?? false,
      dailySummary: map['settings']?['dailySummary'] ?? false,
      taskReminders: map['settings']?['taskReminders'] ?? false,
      overdueAlerts: map['settings']?['overdueAlerts'] ?? false,
      autoSave: map['settings']?['autoSave'] ?? false,
      totalNotes: map['stats']?['totalNotes'] ?? 0,
      totalTasks: map['stats']?['totalTasks'] ?? 0,
      completedTasks: map['stats']?['completedTasks'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'isPaid': isPaid,
      'photoUrl': photoUrl,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'settings': {
        'darkMode': darkMode,
        'showCreationDates': showCreationDates,
        'dailySummary': dailySummary,
        'taskReminders': taskReminders,
        'overdueAlerts': overdueAlerts,
        'autoSave': autoSave,
      },
      'stats': {
        'totalNotes': totalNotes,
        'totalTasks': totalTasks,
        'completedTasks': completedTasks,
      },
    };
  }
}
