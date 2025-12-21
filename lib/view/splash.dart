import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartfarm/view/home.dart';
import 'package:smartfarm/view/login_view.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Request notification permission after fiwhatrst frame
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   await NotificationService.requestPermission();
    //   await NotificationService.getFcmToken();
    //   NotificationService.initializeListeners();

    //   // After setting up notifications, navigate
    //   _navigate();
    // });
    _navigate();
  }

  Future<void> _navigate() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    await Future.delayed(const Duration(seconds: 1));

    if (isLoggedIn && token != null && token.isNotEmpty) {
      Get.off(() => HomePage(token: token));
    } else {
      Get.off(() => LoginPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
