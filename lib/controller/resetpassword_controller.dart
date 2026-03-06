import 'package:get/get.dart';
import 'package:smartfarm/service/api_service.dart';


class ResetPasswordController extends GetxController {
  final String apiPath;
  ResetPasswordController(this.apiPath);

  var newPassword = ''.obs;
  var isLoading = false.obs;
  final ApiService _authService = ApiService();

  Future<void> submitNewPassword() async {
    if (newPassword.value.isEmpty) {
      Get.snackbar("Error", "Please enter a new password");
      return;
    }

    try {
      isLoading.value = true;
      final result = await _authService.resetPassword(apiPath, newPassword.value);

      if (result["success"]) {
        Get.snackbar("Success", "Password reset successful");
        Get.offAllNamed("/login");
      } else {
        Get.snackbar("Error", result["message"]);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
