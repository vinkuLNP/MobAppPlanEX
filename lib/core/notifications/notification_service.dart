import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:plan_ex_app/core/notifications/notification_streams.dart';
import 'package:plan_ex_app/core/routes/app_routes.dart';
import 'package:plan_ex_app/main.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static const int dailySummaryId = 100;
  static const int overdueAlertId = 101;
  static const int taskReminderId = 102;

  static Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings,    onDidReceiveNotificationResponse: (NotificationResponse response) {
      _handleNotificationTap(response);
    },
);
  }
static void _handleNotificationTap(NotificationResponse response) {
  final context = navigatorKey.currentContext;
  if (context == null) return;

  Navigator.of(context).pushNamedAndRemoveUntil(
    AppRoutes.home,
    (route) => false,
  );

  Future.delayed(const Duration(milliseconds: 300), () {
    homeScreenTaskTabStream.add(1);
  });
}

  static int generateTaskNotificationId(String taskId) => taskId.hashCode;

  static Future<bool> requestExactAlarmPermissionIfNeeded() async {
    if (!Platform.isAndroid) return true;

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin == null) return true;

    final granted = await androidPlugin.requestExactAlarmsPermission();
    return granted ?? false;
  }

  static Future<bool> requestPermissionIfNeeded() async {
    bool granted = true;

    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    if (iosPlugin != null) {
      final result = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      granted = result ?? false;
    }

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      final result = await androidPlugin.requestNotificationsPermission();
      granted = result ?? false;
    }

    return granted;
  }

  static Future<void> scheduleDailySummaryAt(
    TimeOfDay time,
    String body,
  ) async {
    final now = DateTime.now();
    final scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    final tz.TZDateTime tzTime = tz.TZDateTime.from(
      scheduled.isBefore(now)
          ? scheduled.add(const Duration(days: 1))
          : scheduled,
      tz.local,
    );

    await _notifications.zonedSchedule(
      dailySummaryId,
      "Daily Task Summary",
      body,
      tzTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_summary',
          'Daily Summary',
          importance: Importance.max,
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
      ),
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> scheduleTaskReminder(
    String title,
    String taskId,
    DateTime time,
  ) async {
    final tz.TZDateTime scheduledTime = tz.TZDateTime.from(time, tz.local);

    await _notifications.zonedSchedule(
      generateTaskNotificationId(taskId),
      "Task Reminder",
      title,
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminder',
          'Task Reminder',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> showOverdueAlert(String title) async {
    await _notifications.show(
      overdueAlertId,
      "Overdue Task",
      title,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'overdue_alert',
          'Overdue Alerts',
          importance: Importance.high,
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
      ),
    );
  }

  static Future<void> cancelDailySummary() async {
    await _notifications.cancel(dailySummaryId);
  }

  static Future<void> cancelTaskReminders() async {
    await _notifications.cancel(taskReminderId);
  }

  static Future<void> cancelOverdueAlerts() async {
    await _notifications.cancel(overdueAlertId);
  }

  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  static Future<void> scheduleOverdueAlertForTask(
    String taskId,
    String title,
    DateTime dueDate,
  ) async {
    final overdueTime = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
      10,
      25,
    );

    final tzTime = tz.TZDateTime.from(overdueTime, tz.local);

    await _notifications.zonedSchedule(
      generateTaskNotificationId(taskId) + 100000,
      "Overdue Task",
      "Task '$title' is overdue ⚠️",
      tzTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'overdue_alert',
          'Overdue Alerts',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}

