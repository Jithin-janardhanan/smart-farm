
// import 'dart:developer';
// import 'package:firebase_messaging/firebase_messaging.dart';

// class NotificationService {
//   static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

//   /// ✅ Request notification permission (for Android 13+ and iOS)
//   static Future<void> requestPermission() async {
//     NotificationSettings settings = await _messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       log("✅ User granted permission for notifications");
//     } else if (settings.authorizationStatus ==
//         AuthorizationStatus.provisional) {
//       log("⚠️ User granted provisional permission");
//     } else {
//       log("❌ User declined or has not accepted notification permission");
//     }
//   }

//   /// ✅ Get FCM token from Firebase
//   static Future<String?> getFcmToken() async {
//     try {
//       String? fcmToken = await _messaging.getToken();
//       if (fcmToken == null) {
//         log("❌ Failed to get FCM token");
//       } else {
//         log("📱 Got FCM Token: $fcmToken");
//       }

//       // 🔁 Optionally listen for token refresh
//       _messaging.onTokenRefresh.listen((newToken) {
//         log("🔄 FCM Token refreshed: $newToken");
//         // 👉 Send the new token to your backend if needed
//       });

//       return fcmToken;
//     } catch (e) {
//       log("🚨 Error fetching FCM token: $e");
//       return null;
//     }
//   }

//   /// ✅ Handle background and foreground messages
//   static void initializeListeners() {
//     // Foreground messages
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       log("📩 Foreground message: ${message.notification?.title}");
//       // Handle UI alert or local notification if you want
//     });

//     // When app is opened via a notification
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       log("🚀 App opened by notification: ${message.notification?.title}");
//       // Navigate to a screen if needed
//     });
//   }
// }
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

    const InitializationSettings initSettings =
        InitializationSettings(android: androidInit);

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

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }
}
