import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfarm/controller/forgot_password_controller.dart';


class ForgotPasswordView extends StatelessWidget {
  final ForgotPasswordController controller =
      Get.put(ForgotPasswordController());

  ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Enter your email address to receive password reset link:",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => controller.email.value = value,
              ),
              const SizedBox(height: 20),
              controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.sendForgotPasswordRequest,
                        child: const Text("Send Reset Link"),
                      ),
                    ),
            ],
          );
        }),
      ),
    );
  }
}
