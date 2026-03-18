import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../models/habit.dart';
import '../constants/app_constants.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _permissionGranted = false;

  Future<void> init() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();
    try {
      final localTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz));
      if (kDebugMode) print('[Notifications] Timezone set to: $localTz');
    } catch (e) {
      tz.setLocalLocation(tz.UTC);
      if (kDebugMode) print('[Notifications] Timezone fallback to UTC: $e');
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const linuxSettings =
        LinuxInitializationSettings(defaultActionName: 'Open');

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
        linux: linuxSettings,
      ),
    );

    // Request permissions
    await _requestPermissions();

    _initialized = true;
    if (kDebugMode) {
      print('[Notifications] Initialized. Permission granted: $_permissionGranted');
    }
  }

  Future<void> _requestPermissions() async {
    try {
      if (Platform.isIOS) {
        final granted = await _plugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true);
        _permissionGranted = granted ?? false;
      } else if (Platform.isMacOS) {
        final granted = await _plugin
            .resolvePlatformSpecificImplementation<
                MacOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true);
        _permissionGranted = granted ?? false;
      } else if (Platform.isAndroid) {
        final granted = await _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
        _permissionGranted = granted ?? false;
      } else {
        _permissionGranted = true; // Linux/other — assume granted
      }
      if (kDebugMode) {
        print('[Notifications] Permission result: $_permissionGranted');
      }
    } catch (e) {
      if (kDebugMode) print('[Notifications] Permission request error: $e');
    }
  }

  Future<void> scheduleHabitReminder(Habit habit) async {
    if (habit.reminderTime == null) return;
    if (!_initialized) {
      if (kDebugMode) print('[Notifications] Not initialized, skipping schedule');
      return;
    }
    if (!_permissionGranted) {
      if (kDebugMode) print('[Notifications] Permission not granted, skipping schedule');
      return;
    }

    final parts = habit.reminderTime!.split(':');
    if (parts.length != 2) return;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return;

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final notificationId = habit.id.hashCode & 0x7FFFFFFF;

    if (kDebugMode) {
      print('[Notifications] Scheduling "${habit.name}" (id: $notificationId) at $scheduledDate');
    }

    const androidDetails = AndroidNotificationDetails(
      AppConstants.kNotificationChannelId,
      AppConstants.kNotificationChannelName,
      channelDescription: AppConstants.kNotificationChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    try {
      await _plugin.zonedSchedule(
        notificationId,
        '${habit.icon} Time for ${habit.name}!',
        'Keep your streak going! 🔥',
        scheduledDate,
        const NotificationDetails(
          android: androidDetails,
          iOS: darwinDetails,
          macOS: darwinDetails,
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      if (kDebugMode) print('[Notifications] Successfully scheduled for $scheduledDate');
    } catch (e, stack) {
      if (kDebugMode) {
        print('[Notifications] Scheduling FAILED: $e');
        print(stack);
      }
    }
  }

  /// Show an immediate test notification (no scheduling — fires right now).
  Future<void> sendTestNotification({int seconds = 5}) async {
    if (!_initialized || !_permissionGranted) {
      if (kDebugMode) print('[Notifications] Test skipped: initialized=$_initialized, granted=$_permissionGranted');
      return;
    }
    if (kDebugMode) print('[Notifications] Sending immediate test notification');
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        AppConstants.kNotificationChannelId,
        AppConstants.kNotificationChannelName,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
          presentAlert: true, presentBadge: false, presentSound: true),
      macOS: DarwinNotificationDetails(
          presentAlert: true, presentBadge: false, presentSound: true),
    );
    try {
      await _plugin.show(
        999999,
        '🔔 Test Notification',
        'Habit Builder notifications are working!',
        details,
      );
      if (kDebugMode) print('[Notifications] Test notification sent successfully');
    } catch (e, stack) {
      if (kDebugMode) {
        print('[Notifications] Test notification FAILED: $e');
        print(stack);
      }
    }
  }

  Future<void> cancelHabitReminder(String habitId) async {
    if (!_initialized) return;
    await _plugin.cancel(habitId.hashCode & 0x7FFFFFFF);
    if (kDebugMode) print('[Notifications] Cancelled reminder for $habitId');
  }

  Future<void> cancelAll() async {
    if (!_initialized) return;
    await _plugin.cancelAll();
  }

  bool get isPermissionGranted => _permissionGranted;
}
