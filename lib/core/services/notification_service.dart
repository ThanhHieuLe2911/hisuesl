import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    if (Platform.isAndroid) {
      final androidImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
        await androidImplementation.requestExactAlarmsPermission();
      }
    }
  }

  // --- HÀM ĐẶT LỊCH (MAX CONFIG) ---
  Future<void> scheduleDailyNotification(int hour, int minute) async {
    await flutterLocalNotificationsPlugin.cancelAll();

    final scheduledTime = _nextInstanceOfTime(hour, minute);
    print("Đã đặt lịch (Local Time): $scheduledTime");

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Đến giờ học rồi! ⏰',
      'Vào học ngay để duy trì chuỗi Streak nào bạn ơi!',
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel_v4', // <--- ĐỔI LÊN v4 (BẮT BUỘC)
          'Nhắc nhở học tập',
          channelDescription: 'Thông báo nhắc nhở học tập hằng ngày',

          // [CẤU HÌNH TỐI ĐA ĐỂ HIỆN POP-UP]
          importance: Importance.max, // Mức quan trọng cao nhất
          priority: Priority.max,     // Độ ưu tiên cao nhất
          visibility: NotificationVisibility.public, // Hiện ngay cả khi khóa màn hình

          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
          fullScreenIntent: true, // Cho phép đánh thức màn hình
          category: AndroidNotificationCategory.alarm, // Đánh dấu là báo thức
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),

      // Giữ alarmClock vì bạn xác nhận nó chạy đúng giờ
      androidScheduleMode: AndroidScheduleMode.alarmClock,

      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> showInstantNotification() async {
    await flutterLocalNotificationsPlugin.show(
      1,
      'Kiểm tra thông báo',
      'Nếu bạn thấy tin này nghĩa là tính năng đã hoạt động tốt! 🎉',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Channel',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}