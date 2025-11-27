import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plan_ex_app/core/notifications/notification_service.dart';
import 'package:plan_ex_app/core/routes/app_routes.dart';
import 'package:plan_ex_app/core/utils/app_logger.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/repositories/account_repository.dart';
import 'package:plan_ex_app/features/dashboard_flow/domain/entities/user_entity.dart';

class AccountProvider extends ChangeNotifier {
  final AccountRepository repository;
  AccountProvider(this.repository);
  User? get authUser => FirebaseAuth.instance.currentUser;

  bool get isPremium => true;
  // user?.isPaid == true;
  UserEntity? user;
  bool accountLoading = false;
  bool settingsLoading = false;
  bool saving = false;
  bool initialAccountLoaded = false;
  bool avatarResolvedOnce = false;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  String? avatarUrl;

  String? localImagePath;
  bool processing = false;

  void _setProcessing(bool value) {
    processing = value;
    notifyListeners();
  }

  bool requirePremium(BuildContext context) {
    if (!isPremium) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This feature is available for Premium users only'),
        ),
      );
      return false;
    }
    return true;
  }

  Widget premiumGuard({
    required BuildContext context,
    required Widget child,
    Widget? lockedChild,
  }) {
    if (!isPremium) {
      return lockedChild ??
          Stack(
            alignment: Alignment.center,
            children: [
              Opacity(opacity: 0.4, child: child),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(12),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Premium Only', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          );
    }
    return child;
  }

  Future<void> loadAccountBasicInfo() async {
    final uid = authUser?.uid;
    if (uid == null) return;
    if (initialAccountLoaded) return;
    accountLoading = true;
    notifyListeners();

    final data = await repository.getUser(uid);

    user = data;

    nameController.text = user?.fullName ?? '';
    emailController.text = user?.email ?? '';

    if (user?.photoUrl != null && user?.photoUrl != '' && !avatarResolvedOnce) {
      avatarUrl = await repository.getFreshAvatarUrl(user!.photoUrl!);
      avatarResolvedOnce = true;
    }
    initialAccountLoaded = true;
    accountLoading = false;
    notifyListeners();
  }

  Future<void> loadSettingsData() async {
    final uid = authUser?.uid;
    if (uid == null) return;

    settingsLoading = true;
    notifyListeners();

    final settings = await repository.getUser(uid);

    user = settings;

    settingsLoading = false;
    notifyListeners();
  }

  Future<void> saveName() async {
    final uid = authUser?.uid;
    if (uid == null) return;
    _setProcessing(true);
    notifyListeners();
    final newName = nameController.text.trim();
    await repository.updateName(uid, newName);
    user = user?.copyWith(fullName: newName);
    saving = false;
    _setProcessing(false);
    notifyListeners();
  }

  Future<void> pickAndUploadAvatar(ImageSource source) async {
    final uid = authUser?.uid;
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
    avatarUrl = await repository.getFreshAvatarUrl(newPath);
    user = user?.copyWith(photoUrl: newPath);
    avatarResolvedOnce = true;
    _setProcessing(false);
    notifyListeners();
  }

  Future<String?> getAvatarUrl() async {
    if (user?.photoUrl == null) return null;
    return await repository.getFreshAvatarUrl(user!.photoUrl!);
  }

  Future<void> toggleSetting(
    String key,
    bool value,
    BuildContext context,
  ) async {
    final uid = authUser?.uid;
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
    if (key == 'dailySummary' && value == true) {
      final notificationAllowed = await NotificationService.requestPermissionIfNeeded();
      final exactAlarmAllowed = await NotificationService.requestExactAlarmPermissionIfNeeded();


      if ((!notificationAllowed || !exactAlarmAllowed)  && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Notification permission denied")),
        );
        return;
      }

      final completed = user?.completedTasks;
      final total = user?.totalTasks;

      NotificationService.scheduleDailySummaryAt(
        const TimeOfDay(hour: 20, minute: 0), 
        "You completed $completed out of $total tasks today 🎯",
      );
    }

    if (key == 'overdueAlerts' && value == true) {
      final allowed = await NotificationService.requestPermissionIfNeeded();

      if (!allowed && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Notification permission denied")),
        );
        return;
      }

      NotificationService.showOverdueAlert(
        "You have overdue tasks. Complete them now ⚠️",
      );
    }

    _setProcessing(false);
    notifyListeners();
  }

  Future<void> upgrade() async {
    final uid = authUser?.uid;
    if (uid == null) return;
    await repository.upgradeUser(uid);
    user = user?.copyWith(isPaid: true);
    notifyListeners();
  }

  Future<String?> deleteAccount({required String? passwordForReauth}) async {
    final firebaseUser = authUser;
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

  ThemeMode _localThemeMode = ThemeMode.light;

  ThemeMode get themeMode {
    if (user != null) {
      return user?.darkMode == true ? ThemeMode.dark : ThemeMode.light;
    }
    return _localThemeMode;
  }

  Future<void> logout(BuildContext context) async {
    try {
      _localThemeMode = ThemeMode.light;
      user = null;
      await FirebaseAuth.instance.signOut();

      repository.logout();
      notifyListeners();
      if (context.mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      }
      _setProcessing(false);
    } on FirebaseAuthException catch (e) {
      AppLogger.error(e.toString());
      AppLogger.error(e.code.toString());
    } catch (e) {
      AppLogger.error(e.toString());
    } finally {
      _setProcessing(false);
    }
  }
}
