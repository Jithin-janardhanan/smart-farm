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
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchFarms();
  }
}
