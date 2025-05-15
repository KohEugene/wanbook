
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FlutterLocalNotification {
  FlutterLocalNotification._();

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('mipmap/ic_launcher');

    const DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static void requestNotificationPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static Future<void> showNotification() async {
    const AndroidNotificationDetails androidNotificationDetails = 
      AndroidNotificationDetails('channel id', 'channel name',
                  channelDescription: 'channel description',
                  importance: Importance.max,
                  priority: Priority.max,
                  showWhen: false
      );

    const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails, 
                  iOS: DarwinNotificationDetails(badgeNumber: 1));

      await flutterLocalNotificationsPlugin.show(
          0, '아제목뭐하지', '한 페이지씩 완성하는 독서 습관! 책멍이와 함께해요!', notificationDetails);
  }
}
