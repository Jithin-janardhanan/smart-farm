import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfarm/controller/motorlist_controller.dart';

class MotorListPage extends StatelessWidget {
  final int farmId;
  final MotorController controller = Get.put(MotorController());

  MotorListPage({super.key, required this.farmId});

  @override
  Widget build(BuildContext context) {
    controller.fetchMotors(farmId);

    return Scaffold(
      appBar: AppBar(title: Text("Motors")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: controller.motors.length,
          itemBuilder: (context, index) {
            final motor = controller.motors[index];
            return Card(
              margin: EdgeInsets.all(10),
              child: ListTile(
                title: Text(motor.name),
                subtitle: Text("Lora ID: ${motor.loraId}\nFarm: ${motor.farm}"),
                trailing: Icon(
                  motor.isActive ? Icons.power : Icons.power_off,
                  color: motor.isActive ? Colors.green : Colors.red,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
