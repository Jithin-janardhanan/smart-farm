import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartfarm/model/motor_model.dart';
import 'package:smartfarm/model/vales_model.dart';
import 'package:smartfarm/service/api_service.dart';

class MotorController extends GetxController {
  var motors = <Motor>[].obs;
  var valves = <Valve>[].obs;
  var isLoading = false.obs;

  Future<void> fetchMotors(int farmId) async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      motors.value = await ApiService.getMotorsByFarmId(token, farmId);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // valve listing function

  Future<void> fetchValves(int farmId) async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      valves.value = await ApiService.getValves(token, farmId);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
