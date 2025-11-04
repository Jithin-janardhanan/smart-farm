// fcm_service.dart
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
    
    }
  }

  /// Initialize notification listeners
  static void initNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
     
      // Optionally show local notification
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  
      // Handle navigation
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  }

  /// Background handler must be a top-level function
  static Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {

  }
}
