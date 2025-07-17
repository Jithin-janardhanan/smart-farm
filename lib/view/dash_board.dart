import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartfarm/view/login_view.dart';
import '../controller/dashboard_controller.dart';

class DashboardPage extends StatelessWidget {
  final DashboardController controller = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Farmer Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Get.offAll(() => LoginPage());
            },
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        final farmer = controller.farmer.value;
        if (farmer == null) {
          return Center(child: Text("No profile data found."));
        }

        return ListView(
          padding: EdgeInsets.all(16),
          children: [
            Text("👤 Name: ${farmer.firstName} ${farmer.lastName}"),
            Text("📱 Phone: ${farmer.phoneNumber}"),
            Text("✉️ Email: ${farmer.email}"),
            Text("🆔 Aadhar: ${farmer.aadharNumber}"),
            Text("🏠 House: ${farmer.houseName}"),
            Text("🏘️ Village: ${farmer.village}"),
            Text("🏞️ District: ${farmer.district}"),
            Text("🌍 State: ${farmer.state}"),
            Text("📮 Pincode: ${farmer.pincode}"),
          ],
        );
      }),
    );
  }
}
