import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_text_widget.dart';
import 'package:plan_ex_app/core/constants/app_colors.dart';
import 'package:plan_ex_app/core/notifications/notification_service.dart';
import 'package:plan_ex_app/core/routes/app_routes.dart';
import 'package:plan_ex_app/core/utils/app_logger.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/repositories/account_repository.dart';
import 'package:plan_ex_app/features/dashboard_flow/domain/entities/task_entity.dart';
import 'package:plan_ex_app/features/dashboard_flow/domain/entities/user_entity.dart';
import 'package:plan_ex_app/features/dashboard_flow/provider/notes_provider.dart';
import 'package:plan_ex_app/features/dashboard_flow/provider/task_provider.dart';
import 'package:provider/provider.dart';

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

  StreamSubscription<UserEntity>? _userSub;
  bool _listening = false;
  void startUserListener() {
    final userDataId = FirebaseAuth.instance.currentUser!.uid;
    if (_listening) return;
    _listening = true;

    _userSub = repository.watchUser(userDataId).listen((data) async {
      user = data;

      nameController.text = data.fullName;
      emailController.text = data.email;

      if (user?.photoUrl != null && user!.photoUrl!.isNotEmpty) {
        avatarUrl = await getAvatarUrl(user!.photoUrl!);
      } else {
        avatarUrl = null;
      }

      notifyListeners();
    });
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }

  Future<void> loadAccountBasicInfo({bool force = false}) async {
    final uid = authUser?.uid;
    if (uid == null) return;
    if (initialAccountLoaded && !force) return;
    accountLoading = true;
    notifyListeners();

    final data = await repository.getUser(uid);

    user = data;

    nameController.text = user?.fullName ?? '';
    emailController.text = user?.email ?? '';
    if (user?.photoUrl != null && user!.photoUrl!.isNotEmpty) {
      // avatarUrl = await getAvatarUrl();
      avatarUrl = await getAvatarUrl(user!.photoUrl!);
    }

    initialAccountLoaded = true;
    accountLoading = false;
    notifyListeners();
  }

  Future<void> loadSettingsData({bool force = false}) async {
    final uid = authUser?.uid;
    if (uid == null) return;

    settingsLoading = true;
    notifyListeners();

    final settings = await repository.getUser(uid);

    user = settings;
    // await enforceNotificationPermissionOnHome();
    settingsLoading = false;
    notifyListeners();
  }

  Future<void> enforceNotificationPermissionOnHome({
    required BuildContext context,
  }) async {
    final uid = authUser?.uid;
    if (uid == null || user == null) return;

    final notificationsEnabledInApp =
        user!.dailySummary || user!.taskReminders || user!.overdueAlerts;

    if (!notificationsEnabledInApp) return;

    final hasPermission = await NotificationService.hasNotificationPermission();

    if (hasPermission) return;

    final granted = await NotificationService.requestPermissionIfNeeded();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: textWidget(
            text:
                'Notifications are disabled on this device. '
                'Enable them from system settings.',
            context: context,
            color: Colors.white,
          ),
          backgroundColor: Colors.black,
          action: SnackBarAction(
            label: 'Open Settings',
            onPressed: openAppSettings,
          ),
        ),
      );
    }

    if (!granted) {
      await repository.updateSettings(uid, {
        'darkMode': user!.darkMode,
        'showCreationDates': user!.showCreationDates,
        'dailySummary': false,
        'taskReminders': false,
        'overdueAlerts': false,
        'autoSave': user!.autoSave,
      });

      await NotificationService.cancelAll();

      user = user!.copyWith(
        dailySummary: false,
        taskReminders: false,
        overdueAlerts: false,
      );

      notifyListeners();
    }
  }

  Future<void> saveName(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final uid = authUser?.uid;
    if (uid == null) return;

    final newName = nameController.text.trim();
    final oldName = user?.fullName.trim() ?? '';
    if (newName == oldName) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: textWidget(
            context: context,
            color: Theme.of(context).cardColor,
            text: 'No changes detected',
          ),
        ),
      );
      return;
    }
    _setProcessing(true);
    notifyListeners();
    await repository.updateName(uid, newName);
    user = user?.copyWith(fullName: newName);
    saving = false;
    _setProcessing(false);
    notifyListeners();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: textWidget(
            context: context,
            color: Theme.of(context).cardColor,
            text: 'Name updated successfully',
          ),
        ),
      );
    }
  }

  Future<void> pickAndUploadAvatar(
    ImageSource source,
    BuildContext context,
  ) async {
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
    if (context.mounted) {
      final editedImage = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ImageEditor(image: File(picked.path).readAsBytesSync()),
        ),
      );

      if (editedImage == null) {
        _setProcessing(false);
        return;
      }

      final editedFile = await File(picked.path).writeAsBytes(editedImage);

      localImagePath = editedFile.path;
      notifyListeners();

      final file = File(editedFile.path);
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
  }

  Future<String?> getAvatarUrl(String photoUrl) async {
    if (photoUrl.startsWith('http')) {
      return photoUrl;
    }
    return await repository.getFreshAvatarUrl(photoUrl);
  }

  Future<void> toggleSetting(
    String key,
    bool value,
    BuildContext context,
  ) async {
    final uid = authUser?.uid;
    if (uid == null) return;

    if (value &&
        (key == 'dailySummary' ||
            key == 'taskReminders' ||
            key == 'overdueAlerts')) {
      final notificationAllowed =
          await NotificationService.requestPermissionIfNeeded();

      if (!notificationAllowed && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.black,
            content: textWidget(
              context: context,
              color: AppColors.whiteColor,
              text:
                  "Notifications are disabled. Please enable them in Settings to use this feature.",
            ),
            action: SnackBarAction(
              label: "Open Settings",
              onPressed: () {
                openAppSettings();
              },
            ),
          ),
        );
        return;
      }
    }
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
    if (context.mounted) {
      await handleNotificationChange(key, value, context);
    }
    _setProcessing(false);
    notifyListeners();
  }

  bool requirePremium(BuildContext context) {
    if (!isPremium) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: textWidget(
            context: context,
            color: Theme.of(context).cardColor,
            text: 'This feature is available for Premium users only',
          ),
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

  Future<void> handleNotificationChange(
    String key,
    bool value,
    BuildContext context,
  ) async {
    if (key == 'dailySummary') {
      if (value) {
        final notificationAllowed =
            await NotificationService.requestPermissionIfNeeded();
        final exactAlarmAllowed =
            await NotificationService.requestExactAlarmPermissionIfNeeded();

        if ((!notificationAllowed || !exactAlarmAllowed) && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: textWidget(
                context: context,
                color: Theme.of(context).cardColor,
                text: "Notification permission denied",
              ),
            ),
          );
          return;
        }
        final completed = user?.completedTasks;
        final total = user?.totalTasks;
        await NotificationService.scheduleDailySummaryAt(
          const TimeOfDay(hour: 10, minute: 30),
          "You completed $completed out of $total tasks today 🎯",
        );
      } else {
        await NotificationService.cancelDailySummary();
      }
    }

    if (key == 'overdueAlerts') {
      if (!value) {
        await NotificationService.cancelOverdueAlerts();
      }
    }

    if (key == 'taskReminders') {
      if (!value) {
        await NotificationService.cancelTaskReminders();
      }
    }
  }

  Future<void> restoreNotifications(List<TaskEntity> tasks) async {
    if (user == null) return;

    if (user!.dailySummary) {
      final completed = user?.completedTasks;
      final total = user?.totalTasks;
      await NotificationService.scheduleDailySummaryAt(
        const TimeOfDay(hour: 10, minute: 30),
        "You completed $completed out of $total tasks today 🎯",
      );
    }

    if (user!.taskReminders) {
      for (final task in tasks) {
        if (!task.completed && task.dueDate != null) {
          await NotificationService.scheduleTaskReminder(
            task.title,
            task.createdAt.toString(),
            task.dueDate!,
          );
        }
      }
    }

    if (user!.overdueAlerts) {
      for (final task in tasks) {
        if (!task.completed && task.isOverdue) {
          await NotificationService.scheduleOverdueAlertForTask(
            task.id,
            task.title,
            task.dueDate!,
          );
        }
      }
    }
  }

  Future<void> bootstrapNotifications(List<TaskEntity> tasks) async {
    await NotificationService.cancelAll();
    await restoreNotifications(tasks);
  }

  Future<void> upgrade() async {
    final uid = authUser?.uid;
    if (uid == null) return;
    await repository.upgradeUser(uid);
    user = user?.copyWith(isPaid: true);
    notifyListeners();
  }

  Future<String?> deleteAccount(
    BuildContext context, {
    String? passwordForReauth,
  }) async {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      return 'Requires Re-Login';
    }

    final uid = firebaseUser.uid;
    _setProcessing(true);

    try {
      if (firebaseUser.providerData.any((p) => p.providerId == 'google.com')) {
        final google = GoogleSignIn.instance;
        await google.initialize();

        final completer = Completer<GoogleSignInAuthenticationEvent>();

        final sub = google.authenticationEvents.listen(
          (event) {
            if (!completer.isCompleted) completer.complete(event);
          },
          onError: (e) {
            if (!completer.isCompleted) completer.completeError(e);
          },
        );

        await google.authenticate();
        final event = await completer.future;
        await sub.cancel();

        final GoogleSignInAccount? googleUser = switch (event) {
          GoogleSignInAuthenticationEventSignIn() => event.user,
          GoogleSignInAuthenticationEventSignOut() => null,
        };

        if (googleUser == null) return 'Google re-auth cancelled';

        final googleAuth = googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        await firebaseUser.reauthenticateWithCredential(credential);
      } else if (passwordForReauth != null && firebaseUser.email != null) {
        final cred = EmailAuthProvider.credential(
          email: firebaseUser.email!,
          password: passwordForReauth,
        );
        await firebaseUser.reauthenticateWithCredential(cred);
      }

      await repository.deleteUserDocument(uid);
      deleteAvatar();
      await firebaseUser.delete();

      if (context.mounted) await _forceLogout(context);

      return null;
    } catch (e) {
      if (context.mounted) await _forceLogout(context);
      if (e is FirebaseAuthException) return e.code;
      return e.toString();
    } finally {
      _setProcessing(false);
    }
  }

  void deleteAvatar() async {
    if (user?.photoUrl != null && user!.photoUrl!.isNotEmpty) {
      await repository.deleteAvatarByPath(user!.photoUrl!);
    }
  }

  clearCache() {
    repository.logout();
  }

  ThemeMode _localThemeMode = ThemeMode.light;

  ThemeMode get themeMode {
    if (user != null) {
      return user?.darkMode == true ? ThemeMode.dark : ThemeMode.light;
    }
    return _localThemeMode;
  }

  bool accountPassObscure = true;
  void toggleAccountPassObscure() {
    accountPassObscure = !accountPassObscure;
    notifyListeners();
  }

  Future<void> clearUser(BuildContext context) async {
    _localThemeMode = ThemeMode.light;
    user = null;
    Provider.of<NotesProvider>(context, listen: false).clearNotes();
    Provider.of<TasksProvider>(context, listen: false).clearTasks();
    nameController.clear();
    emailController.clear();
    avatarResolvedOnce = false;
    initialAccountLoaded = false;
    localImagePath = null;

    avatarUrl = '';
    accountLoading = false;
    settingsLoading = false;
    saving = false;
    repository.logout();

    await FirebaseAuth.instance.signOut();

    notifyListeners();
  }

  Future<void> _forceLogout(BuildContext context) async {
    try {
      await clearUser(context);
    } catch (_) {}

    if (context.mounted) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await clearUser(context);
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
