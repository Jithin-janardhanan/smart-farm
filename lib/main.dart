import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:smartfarm/model/colors_model.dart';
import 'package:smartfarm/view/splash.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 👇 load dotenv first
  await dotenv.load(fileName: ".env");

  // 👇 log BASE_URL to confirm it worked
  print("✅ BASE_URL loaded: ${dotenv.env['BASE_URL']}");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Smart Farm',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryColor,
        scaffoldBackgroundColor: AppColors.background,
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
        useMaterial3: true,
      ),
      home: SplashScreen(), // Replace with your starting screen
    );
  }
}
