import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartfarm/controller/farm_controller.dart';
import 'package:smartfarm/view/motors.dart';
import 'package:smartfarm/view/profile.dart';

class HomePage extends StatelessWidget {
  final String token;

  FarmController farmController = Get.put(FarmController());

  HomePage({super.key, required this.token});

  Future<void> navigateToMotors(int farmId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      Get.to(() => MotorListPage(farmId: farmId, token: token));
    } else {
      print("Token not found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Smart farm'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () => Get.to(ProfileView()),
              icon: Icon(Icons.person),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (farmController.isLoading.value) { 
          return Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: farmController.fetchFarms,
          child: ListView.builder(
            itemCount: farmController.farms.length,
            itemBuilder: (context, index) {
              final farm = farmController.farms[index];
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  onTap: () {
                    navigateToMotors(farm.id);
                  },

                  title: Text(
                    farm.farmName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("📍 ${farm.location}"),
                      Text("Area: ${farm.farmArea} acres"),
                      Text("GSM: ${farm.gsmNumber}"),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
