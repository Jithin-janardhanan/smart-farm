import 'package:get/get.dart';
import 'package:smartfarm/model/vales_model.dart';
import 'package:smartfarm/service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ValveController extends GetxController {
  var valves = <Valve>[].obs;
  var isLoading = false.obs;

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
