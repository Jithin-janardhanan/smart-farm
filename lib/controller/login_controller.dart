import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartfarm/controller/farm_controller.dart';
import 'package:smartfarm/controller/notification_service.dart';
import 'package:smartfarm/model/user_model.dart';
import 'package:smartfarm/service/api_service.dart';
import 'package:smartfarm/view/home.dart';

class LoginController extends GetxController {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  var isLoading = false.obs;
  var isPasswordVisible = false.obs;
  var rememberMe = false.obs; // 🔹 NEW

  // 🔹 NEW: Secure storage instance
  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  @override
  void onInit() {
    super.onInit();
    _loadSavedCredentials(); // 🔹 NEW
  }

  // 🔹 NEW: Load saved credentials from secure storage
  Future<void> _loadSavedCredentials() async {
    try {
      final saved = await _secureStorage.read(key: 'rememberMe');
      if (saved == 'true') {
        final phone = await _secureStorage.read(key: 'saved_phone');
        final password = await _secureStorage.read(key: 'saved_password');
        if (phone != null) phoneController.text = phone;
        if (password != null) passwordController.text = password;
        rememberMe.value = true;
      }
    } catch (e) {
      // Silently fail — don't block login if secure storage is unavailable
      debugPrint('Secure storage read error: $e');
    }
  }

  // 🔹 NEW: Save or clear credentials based on toggle
  Future<void> _handleRememberMe(String phone, String password) async {
    try {
      if (rememberMe.value) {
        await _secureStorage.write(key: 'saved_phone', value: phone);
        await _secureStorage.write(key: 'saved_password', value: password);
        await _secureStorage.write(key: 'rememberMe', value: 'true');
      } else {
        await _secureStorage.delete(key: 'saved_phone');
        await _secureStorage.delete(key: 'saved_password');
        await _secureStorage.write(key: 'rememberMe', value: 'false');
      }
    } catch (e) {
      debugPrint('Secure storage write error: $e');
    }
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    String cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    if (cleanPhone.length > 15) return 'Phone number cannot exceed 15 digits';
    if (!RegExp(r'^\d+$').hasMatch(cleanPhone)) {
      return 'Phone number should contain only digits';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters long';
    return null;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void login() async {
    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        "Invalid Input",
        "Please enter both phone number and password.",
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
        icon: const Icon(Icons.error_outline, color: Colors.red),
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    isLoading.value = true;

    try {
      final phone = phoneController.text.trim();
      final password = passwordController.text.trim();

      final response = await ApiService.login(phone, password);
      final user = User.fromJson(response);

      await _handleRememberMe(
        phone,
        password,
      ); // 🔹 NEW — only saves on successful login

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', user.token);
      await prefs.setInt('user_id', user.userId);
      await prefs.setInt('farmer_id', user.farmerId);
      await prefs.setBool('isLoggedIn', true);

      Get.put(FarmController());
      Get.off(() => HomePage(token: user.token));

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await NotificationService.requestPermission();
        await NotificationService.getFcmToken();
        NotificationService.initializeListeners();
      });
    } catch (e) {
      String errorMessage = "Something went wrong. Please try again.";
      if (e.toString().contains("Invalid phone number or password")) {
        errorMessage = "Invalid phone number or password.";
      }
      Get.snackbar(
        "Login Failed",
        errorMessage,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
        icon: const Icon(Icons.error_outline, color: Colors.red),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    if (Get.isRegistered<LoginController>()) {
      phoneController.dispose();
      passwordController.dispose();
    }
    super.onClose();
  }
}
