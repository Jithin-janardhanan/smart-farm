import 'package:get/get.dart';
import 'package:smartfarm/service/api_service.dart';


class ForgotPasswordController extends GetxController {
  var isLoading = false.obs;
  var email = ''.obs;

  final ApiService _authService = ApiService();

  Future<void> sendForgotPasswordRequest() async {
    if (email.value.isEmpty) {
      Get.snackbar("Error", "Please enter your email");
      return;
    }

    try {
      isLoading.value = true;
      final result = await _authService.forgotPassword(email.value);

      if (result["success"]) {
        Get.snackbar("Success", "Password reset link sent to your email");
      } else {
        Get.snackbar("Error", result["message"] ?? "Failed to send reset link");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
