import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfarm/service/api_service.dart';


class ResetPasswordView extends StatefulWidget {
  final String apiPath;
  const ResetPasswordView({super.key, required this.apiPath});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final TextEditingController _passwordController = TextEditingController();
  var isLoading = false.obs;

  Future<void> _resetPassword() async {
    final newPassword = _passwordController.text.trim();
    if (newPassword.isEmpty) {
      Get.snackbar("Error", "Please enter a new password");
      return;
    }

    isLoading.value = true;
    final result =
        await ApiService().resetPassword(widget.apiPath, newPassword);
    isLoading.value = false;

    if (result["success"] == true) {
      Get.snackbar("Success", "Password reset successful");
      Get.offAllNamed("/login");
    } else {
      Get.snackbar("Error", result["message"] ?? "Reset failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "New Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Obx(() => isLoading.value
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _resetPassword,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text("Submit"),
                  )),
          ],
        ),
      ),
    );
  }
}
