// import 'dart:developer';
// import 'package:firebase_messaging/firebase_messaging.dart';

// class NotificationService {
//   /// Get FCM token from Firebase
//   static Future<String?> getFcmToken() async {
//     try {
//       String? fcmToken = await FirebaseMessaging.instance.getToken();
//       if (fcmToken == null) {
//         log("❌ Failed to get FCM token");
//       } else {
//         log("📱 Got FCM Token: $fcmToken");
//       }
//       return fcmToken;
//     } catch (e) {
//       log("🚨 Error fetching FCM token: $e");
//       return null;
//     }
//   }
// }
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// ✅ Request notification permission (for Android 13+ and iOS)
  static Future<void> requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log("✅ User granted permission for notifications");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      log("⚠️ User granted provisional permission");
    } else {
      log("❌ User declined or has not accepted notification permission");
    }
  }

  /// ✅ Get FCM token from Firebase
  static Future<String?> getFcmToken() async {
    try {
      String? fcmToken = await _messaging.getToken();
      if (fcmToken == null) {
        log("❌ Failed to get FCM token");
      } else {
        log("📱 Got FCM Token: $fcmToken");
      }

      // 🔁 Optionally listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        log("🔄 FCM Token refreshed: $newToken");
        // 👉 Send the new token to your backend if needed
      });

      return fcmToken;
    } catch (e) {
      log("🚨 Error fetching FCM token: $e");
      return null;
    }
  }

  /// ✅ Handle background and foreground messages
  static void initializeListeners() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("📩 Foreground message: ${message.notification?.title}");
      // Handle UI alert or local notification if you want
    });

    // When app is opened via a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log("🚀 App opened by notification: ${message.notification?.title}");
      // Navigate to a screen if needed
    });
  }
}
