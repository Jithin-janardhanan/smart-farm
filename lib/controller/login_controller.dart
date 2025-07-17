import 'dart:developer';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartfarm/model/user.model.dart';
import 'package:smartfarm/service/api_service.dart';


class LoginController extends GetxController {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoading = false.obs;

  void login() async {
    isLoading.value = true;

    try {
      final response = await ApiService.login(
        phoneController.text.trim(),
        passwordController.text.trim(),
      );

      final user = User.fromJson(response);

      // ✅ Save token using SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', user.token);
      await prefs.setInt('user_id', user.userId);
      await prefs.setInt('farmer_id', user.farmerId);

      Get.snackbar("Success", "Token saved & login successful");
      log("Token saved: ${user.token}");



    } catch (e) {
      log("debug:${e.toString()}");
      Get.snackbar("Error", e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
