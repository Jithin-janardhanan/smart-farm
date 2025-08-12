import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartfarm/model/farms_model.dart';
import 'package:smartfarm/service/api_service.dart';

class FarmController extends GetxController {
  var farms = <Farm>[].obs;
  var isLoading = false.obs;

  Future<void> fetchFarms() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        throw Exception("Token not found");
      }

      farms.value = await ApiService.getFarms(token);
    } catch (e) {
      Get.snackbar("Something went wrong", e.toString(),snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> triggerEmergencyStop(int farmId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) throw Exception("Token not found");

      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await ApiService.emergencyStop(token, farmId);

      Get.back(); // close loading dialog
      Get.snackbar(
        "Success",
        "Emergency stop activated for farm $farmId",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.back();
      Get.snackbar("Something went wrong", e.toString(),snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchFarms();
  }
}
