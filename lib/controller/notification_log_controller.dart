import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartfarm/service/api_service.dart';

class NotificationController extends GetxController {
  var notifications = [].obs;
  var isLoading = false.obs;

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) throw Exception('Token not found');
      notifications.value = await ApiService.getNotifications(token);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }
}
