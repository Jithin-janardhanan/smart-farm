import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfarm/controller/motorlist_controller.dart';
import 'package:smartfarm/view/valve_grouping.dart';

class MotorListPage extends StatelessWidget {
  final int farmId;
  final String token; // Pass token from login

  MotorListPage({required this.farmId, required this.token});

  final MotorController controller = Get.put(MotorController());

  @override
  Widget build(BuildContext context) {
    controller.fetchMotorsAndValves(farmId, token);

    return Scaffold(
      appBar: AppBar(title: Text('Motors & Valves'),actions: [ElevatedButton(
  onPressed: () {
    Get.to(() => ValveGroupingPage(farmId: farmId, token: token));
  },
  child: Text("Go to Valve Grouping"),
),
],),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "In Motors",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ...controller.inMotors.map(
                (motor) => ListTile(
                  title: Text(motor.name),
                  subtitle: Text(
                    'Lora: ${motor.loraId}, Status: ${motor.status}',
                  ),
                ),
              ),

              SizedBox(height: 16),
              Text(
                "Out Motors",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ...controller.outMotors.map(
                (motor) => ListTile(
                  title: Text(motor.name),
                  subtitle: Text(
                    'Lora: ${motor.loraId}, Status: ${motor.status}',
                  ),
                ),
              ),

              SizedBox(height: 16),
              Text(
                "In Valves",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ...controller.inValves.map(
                (valve) => ListTile(
                  title: Text(valve.name),
                  subtitle: Text(
                    'Lora: ${valve.loraId}, Status: ${valve.status}',
                  ),
                ),
              ),

              SizedBox(height: 16),
              Text(
                "Out Valves",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ...controller.outValves.map(
                (valve) => ListTile(
                  title: Text(valve.name),
                  subtitle: Text(
                    'Lora: ${valve.loraId}, Status: ${valve.status}',
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
