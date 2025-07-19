import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfarm/controller/farm.controller.dart';
import 'package:smartfarm/view/profile.dart';

class HomePage extends StatelessWidget {
  final FarmController controller = Get.put(FarmController());

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
              onPressed: () => Get.to(ProfilePage()),
              icon: Icon(Icons.person),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.fetchFarms,
          child: ListView.builder(
            itemCount: controller.farms.length,
            itemBuilder: (context, index) {
              final farm = controller.farms[index];
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
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
