import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// ✅ INIT
  static Future<void> init() async {
    await requestPermission();
    await _initLocalNotifications();
    initializeListeners();
    await getFcmToken();
  }

  /// ✅ Local notification init
  static Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
    );

    await _localNotifications.initialize(initSettings);
  }

  /// ✅ Permission
  static Future<void> requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    log("🔔 Permission: ${settings.authorizationStatus}");
  }

  /// ✅ Token
  static Future<String?> getFcmToken() async {
    String? token = await _messaging.getToken();
    log("📱 FCM TOKEN: $token");
    return token;
  }

  /// ✅ LISTENERS
  static void initializeListeners() {
    /// 🔥 FOREGROUND
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("📩 Foreground message received");

      if (message.notification != null) {
        showLocalNotification(
          title: message.notification!.title ?? '',
          body: message.notification!.body ?? '',
        );
      }
    });

    /// 🔥 BACKGROUND TAP
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log("🚀 Opened from notification");
    });
  }

  /// ✅ SHOW LOCAL NOTIFICATION
  static Future<void> showLocalNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'smartfarm_channel',
          'SmartFarm Notifications',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }
}
