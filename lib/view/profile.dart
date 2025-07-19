import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartfarm/view/login_view.dart';
import '../controller/profile_controller.dart';

class ProfilePage extends StatelessWidget {
  final profileController controller = Get.put(profileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Farmer Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_outlined),
            onPressed: () {
              controller.fetchProfile();
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Get.offAll(() => LoginPage());
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    buildField("First Name", controller.firstNamecrl),
                    buildField("Last Name", controller.lastNamecrl),
                    buildField("Phone Number", controller.phoneNumbercrl),
                    buildField("Email", controller.emailcrl),
                    buildField("Aadhar Number", controller.aadharNumbercrl),
                    buildField("House Name", controller.houseNamecrl),
                    buildField("Village", controller.villagecrl),
                    buildField("District", controller.districtcrl),
                    buildField("State", controller.statecrl),
                    buildField("Pincode", controller.pincodecrl),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                controller.updateProfile();
              },
              child: Text("Save Profile"),
            ),
          ],
        );
      }),
    );
  }

  Widget buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
