import 'dart:developer';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartfarm/controller/farm_controller.dart';
import 'package:smartfarm/model/user_model.dart';
import 'package:smartfarm/service/api_service.dart';
import 'package:smartfarm/view/home.dart';

class LoginController extends GetxController {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  var isLoading = false.obs;
  var isPasswordVisible = false.obs;

  // Phone number validation
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove any spaces or special characters for validation
    String cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanPhone.length < 10) {
      return 'Phone number must be at least 10 digits';
    }

    if (cleanPhone.length > 15) {
      return 'Phone number cannot exceed 15 digits';
    }

    // Check if it contains only digits
    if (!RegExp(r'^\d+$').hasMatch(cleanPhone)) {
      return 'Phone number should contain only digits';
    }

    return null;
  }

  // Password validation
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    return null;
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void login() async {
    log("🔍 Login function triggered");

    // Validate form before proceeding
    if (!formKey.currentState!.validate()) {
      log("⚠️ Form validation failed");
      Get.snackbar(
        "Validation Something went wrong",
        "Please fix the errors above",
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
        icon: Icon(Icons.error_outline, color: Colors.red.shade800),
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    isLoading.value = true;
    log("⏳ isLoading set to true");

    try {
      log(
        "📡 Sending login request with phone: ${phoneController.text.trim()}",
      );
      final response = await ApiService.login(
        phoneController.text.trim(),
        passwordController.text.trim(),
      );
      log("✅ API Response: $response");

      final user = User.fromJson(response);
      log(
        "👤 User parsed: id=${user.userId}, farmerId=${user.farmerId}, token=${user.token}",
      );

      // ✅ Save token using SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', user.token);
      await prefs.setInt('user_id', user.userId);
      await prefs.setInt('farmer_id', user.farmerId);
      await prefs.setBool('isLoggedIn', true);

      log("💾 Token saved to SharedPreferences: ${user.token}");

      // Put FarmController
      Get.put(FarmController());
      log("📦 FarmController initialized");

      // Navigate to HomePage
      Get.off(() => HomePage(token: user.token));
      log("➡️ Navigated to HomePage with token");

      Get.snackbar(
        "Success",
        "Login successful!",
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade800,
        icon: Icon(Icons.check_circle_outline, color: Colors.green.shade800),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e, stacktrace) {
      log("❌ Login error: ${e.toString()}", stackTrace: stacktrace);
      Get.snackbar(
        "Login Failed",
        "Please check your credentials and try again",
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
        icon: Icon(Icons.error_outline, color: Colors.red.shade800),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
      log("✅ isLoading set to false (finished login process)");
    }
  }

  // void login() async {
  //   // Validate form before proceeding
  //   if (!formKey.currentState!.validate()) {
  //     Get.snackbar(
  //       "Validation Something went wrong",
  //       "Please fix the errors above",
  //       backgroundColor: Colors.red.shade50,
  //       colorText: Colors.red.shade800,
  //       icon: Icon(Icons.error_outline, color: Colors.red.shade800),
  //       snackPosition: SnackPosition.TOP,
  //     );
  //     return;
  //   }

  //   isLoading.value = true;

  //   try {
  //     final response = await ApiService.login(
  //       phoneController.text.trim(),
  //       passwordController.text.trim(),
  //     );

  //     final user = User.fromJson(response);

  //     // ✅ Save token using SharedPreferences
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     await prefs.setString('token', user.token);
  //     await prefs.setInt('user_id', user.userId);
  //     await prefs.setInt('farmer_id', user.farmerId);
  //     await prefs.setBool('isLoggedIn', true);
  //     Get.put(FarmController());
  //     Get.off(() => HomePage(token: user.token));

  //     Get.snackbar(
  //       "Success",
  //       "Login successful!",
  //       backgroundColor: Colors.green.shade50,
  //       colorText: Colors.green.shade800,
  //       icon: Icon(Icons.check_circle_outline, color: Colors.green.shade800),
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //     log("Token saved: ${user.token}");
  //   } catch (e) {
  //     log("debug:${e.toString()}");
  //     Get.snackbar(
  //       "Login Failed",
  //       "Please check your credentials and try again",
  //       backgroundColor: Colors.red.shade50,
  //       colorText: Colors.red.shade800,
  //       icon: Icon(Icons.error_outline, color: Colors.red.shade800),
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
