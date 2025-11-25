import 'package:shared_preferences/shared_preferences.dart';
import 'package:plan_ex_app/features/dashboard_flow/domain/entities/user_entity.dart';

class AccountLocalDataSource {
  final SharedPreferences prefs;
  AccountLocalDataSource(this.prefs);

  Future<void> saveUser(UserEntity user) async {
    await prefs.setString('uid', user.uid);
    await prefs.setString('fullName', user.fullName);
    await prefs.setString('email', user.email);
    await prefs.setBool('isPaid', user.isPaid);
    await prefs.setString('photoUrl', user.photoUrl ?? '');
    await prefs.setInt(
      'createdAt',
      user.createdAt?.millisecondsSinceEpoch ?? 0,
    );

    await prefs.setBool('darkMode', user.darkMode);
    await prefs.setBool('showCreationDates', user.showCreationDates);
    await prefs.setBool('dailySummary', user.dailySummary);
    await prefs.setBool('taskReminders', user.taskReminders);
    await prefs.setBool('overdueAlerts', user.overdueAlerts);
    await prefs.setBool('autoSave', user.autoSave);

    await prefs.setInt('totalNotes', user.totalNotes);
    await prefs.setInt('totalTasks', user.totalTasks);
    await prefs.setInt('completedTasks', user.completedTasks);
  }

  UserEntity? getUser() {
    final uid = prefs.getString('uid');
    if (uid == null) return null;

    return UserEntity(
      uid: uid,
      fullName: prefs.getString('fullName') ?? '',
      email: prefs.getString('email') ?? '',
      isPaid: prefs.getBool('isPaid') ?? false,
      photoUrl: prefs.getString('photoUrl'),
      createdAt: prefs.getInt('createdAt') == 0
          ? null
          : DateTime.fromMillisecondsSinceEpoch(prefs.getInt('createdAt')!),
      darkMode: prefs.getBool('darkMode') ?? false,
      showCreationDates: prefs.getBool('showCreationDates') ?? false,
      dailySummary: prefs.getBool('dailySummary') ?? false,
      taskReminders: prefs.getBool('taskReminders') ?? false,
      overdueAlerts: prefs.getBool('overdueAlerts') ?? false,
      autoSave: prefs.getBool('autoSave') ?? false,
      totalNotes: prefs.getInt('totalNotes') ?? 0,
      totalTasks: prefs.getInt('totalTasks') ?? 0,
      completedTasks: prefs.getInt('completedTasks') ?? 0,
    );
  }

  Future<void> clear() async {
    await prefs.clear();
  }
}
