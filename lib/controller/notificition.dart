// fcm_service.dart
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:smartfarm/service/api_service.dart';

import 'notification_service.dart';

class FCMService {
  /// Send FCM token to backend
  static Future<void> sendTokenToBackend(String token) async {
    String? fcmToken = await NotificationService.getFcmToken();
    if (fcmToken != null) {
      await ApiService.sendFcmToken(fcmToken, token);
    } else {
      log("❌ FCM token is null, cannot send to backend");
    }
  }

  /// Initialize notification listeners
  static void initNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("📩 Foreground message received: ${message.notification?.title} - ${message.notification?.body}");
      // Optionally show local notification
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log("🔔 Notification clicked/opened: ${message.notification?.title} - ${message.notification?.body}");
      // Handle navigation
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  }

  /// Background handler must be a top-level function
  static Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
    log("🌙 Background message received: ${message.notification?.title} - ${message.notification?.body}");
  }
}
