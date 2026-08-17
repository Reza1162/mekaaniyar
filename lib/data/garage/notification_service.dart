import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Schedules a recurring local reminder (no server, no Firebase) that
/// nudges the user to open the app and check whether any maintenance
/// item is due. Exact due dates aren't known in advance since they
/// depend on the user's manually-entered mileage, so a periodic check-in
/// notification is used instead of scheduling a notification per item.
class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  static Future<void> requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> scheduleWeeklyCheckIn() async {
    await init();
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'service_reminder_channel',
        'یادآوری سرویس خودرو',
        channelDescription: 'یادآوری هفتگی برای بررسی سرویس‌های موعد رسیده',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
    );
    await _plugin.periodicallyShow(
      1001,
      'یادآوری سرویس خودرو',
      'کیلومتر خودرو رو توی مکانیار بروزرسانی کن تا سرویس‌های موعد رسیده رو ببینی',
      RepeatInterval.weekly,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  static Future<void> cancelWeeklyCheckIn() async {
    await _plugin.cancel(1001);
  }

  /// Fires immediately when a specific item becomes overdue while the
  /// user has the app open (e.g. right after they update mileage).
  static Future<void> notifyOverdueItem(String vehicleName, String itemTitle) async {
    await init();
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'service_due_channel',
        'سرویس موعد رسیده',
        channelDescription: 'اطلاع فوری وقتی یک آیتم سرویس موعدش می‌رسد',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
    await _plugin.show(
      itemTitle.hashCode,
      'سرویس موعد رسیده: $vehicleName',
      itemTitle,
      details,
    );
  }
}
