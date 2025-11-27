import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

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

    await _notifications.initialize(settings);
  }

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
      4,
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

  static Future<void> scheduleTaskReminder(String title, DateTime time) async {
    final tz.TZDateTime scheduledTime = tz.TZDateTime.from(time, tz.local);

    await _notifications.zonedSchedule(
      2,
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
      3,
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
}
