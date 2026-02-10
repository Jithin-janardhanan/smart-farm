import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartfarm/service/api_service.dart';
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

 

  Future<void> _logoutAndRedirect(SharedPreferences prefs) async {
  await prefs.clear();
  Get.offAll(() => LoginPage());
}


  Future<void> _navigate() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  await Future.delayed(const Duration(seconds: 1));

  if (isLoggedIn && token != null && token.isNotEmpty) {
    final isValid = await ApiService.verifyToken(token);

    if (isValid) {
      Get.off(() => HomePage(token: token));
    } else {
      await _logoutAndRedirect(prefs);
    }
  } else {
    Get.off(() => LoginPage());
  }
}


  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
