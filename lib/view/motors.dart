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
    controller.fetchValves(farmId);

    return Scaffold(
      appBar: AppBar(title: Text("Motors & Valves")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Motor List
            Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: controller.motors.length,
                itemBuilder: (context, index) {
                  final motor = controller.motors[index];
                  return Card(
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(motor.name),
                      subtitle: Text(
                        "Lora ID: ${motor.loraId}\nFarm: ${motor.farm}",
                      ),
                      trailing: Icon(
                        motor.isActive ? Icons.power : Icons.power_off,
                        color: motor.isActive ? Colors.green : Colors.red,
                      ),
                    ),
                  );
                },
              );
            }),

            Divider(thickness: 2),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Valves",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            // Valve List
            Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: controller.valves.length,
                itemBuilder: (context, index) {
                  final valve = controller.valves[index];
                  return Card(
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(valve.name),
                      subtitle: Text(
                        "Lora ID: ${valve.loraId}\nStatus: ${valve.status}\nMotor: ${valve.motor}",
                      ),
                      trailing: Icon(
                        valve.isActive ? Icons.check_circle : Icons.cancel,
                        color: valve.isActive ? Colors.green : Colors.red,
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
