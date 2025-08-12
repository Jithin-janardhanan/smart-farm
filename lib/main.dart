import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfarm/model/colors_model.dart';
import 'package:smartfarm/view/splash.dart';

// void main() {
//   runApp( MyApp());
// }
// class MyApp extends StatelessWidget {
//    const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'Smart Farm',

//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primaryColor: AppColors.primaryColor,
//         primarySwatch: Colors.green,
//         // tested with just a hot reload.
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//       ),
//       home: SplashScreen(),
//     );
//   }
// }

void main() {
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
