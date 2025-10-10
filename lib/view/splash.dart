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
    _navigate();
  }

  // Future<void> _navigate() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('token');
  //   final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  //   await Future.delayed(const Duration(seconds: 1)); // optional splash delay

  //   if (isLoggedIn && token != null && token.isNotEmpty) {
  //     Get.off(() => HomePage(token: token));
  //   } else {
  //     Get.off(() => LoginPage());
  //   }
  // }

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
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
