import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartfarm/controller/notification_service.dart';
import 'package:smartfarm/view/home.dart';
import 'package:smartfarm/view/login_view.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _navigate();
//   }


//   Future<void> _navigate() async {
//   print("Splash: start navigation");
//   final prefs = await SharedPreferences.getInstance();
//   final token = prefs.getString('token');
//   final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
//   print("Splash: token=$token, isLoggedIn=$isLoggedIn");

//   await Future.delayed(const Duration(seconds: 1));

//   if (isLoggedIn && token != null && token.isNotEmpty) {
//     print("Splash: going to HomePage");
//     Get.off(() => HomePage(token: token));
//   } else {
//     print("Splash: going to LoginPage");
//     Get.off(() => LoginPage());
//   }
// }


//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(body: Center(child: CircularProgressIndicator()));
//   }
// }
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Request notification permission after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await NotificationService.requestPermission();
      await NotificationService.getFcmToken();
      NotificationService.initializeListeners();

      // After setting up notifications, navigate
      _navigate();
    });
  }

  Future<void> _navigate() async {
    print("Splash: start navigation");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    print("Splash: token=$token, isLoggedIn=$isLoggedIn");

    await Future.delayed(const Duration(seconds: 1));

    if (isLoggedIn && token != null && token.isNotEmpty) {
      print("Splash: going to HomePage");
      Get.off(() => HomePage(token: token));
    } else {
      print("Splash: going to LoginPage");
      Get.off(() => LoginPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}