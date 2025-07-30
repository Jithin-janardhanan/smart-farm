import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfarm/controller/motorlist_controller.dart';
import 'package:smartfarm/view/valve_grouping.dart';

class MotorListPage extends StatelessWidget {
  final int farmId;
  final String token; // Pass token from login

  MotorListPage({super.key, required this.farmId, required this.token});

  final MotorController controller = Get.put(MotorController());

  @override
  Widget build(BuildContext context) {
    controller.fetchMotorsAndValves(farmId, token);

    return Scaffold(
      appBar: AppBar(
        title: Text('Motors & Valves'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.to(() => ValveGroupPage(farmId: farmId, token: token));
            },
            child: Text("Go to Valve Grouping"),
          ),
        ],
      ),
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
                (motor) => Card(
                  child: ListTile(
                    title: Text(motor.name),
                    subtitle: Text(
                      'Lora: ${motor.loraId}, Status: ${motor.status}',
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: motor.status == "ON"
                            ? Colors.red
                            : Colors.green,
                      ),
                      onPressed: () {
                        final newStatus = motor.status == "ON" ? "OFF" : "ON";
                        controller.toggleMotor(
                          motorId: motor.id,
                          status: newStatus,
                          farmId: farmId,
                          token: token,
                        );
                      },
                      child: Text(
                        motor.status == "ON" ? "Turn OFF" : "Turn ON",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16),
              Text(
                "Out Motors",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ...controller.inMotors.map(
                (motor) => Card(
                  child: ListTile(
                    title: Text(motor.name),
                    subtitle: Text(
                      'Lora: ${motor.loraId}, Status: ${motor.status}',
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: motor.status == "ON"
                            ? Colors.red
                            : Colors.green,
                      ),
                      onPressed: () {
                        final newStatus = motor.status == "ON" ? "OFF" : "ON";
                        controller.toggleMotor(
                          motorId: motor.id,
                          status: newStatus,
                          farmId: farmId,
                          token: token,
                        );
                      },
                      child: Text(
                        motor.status == "ON" ? "Turn OFF" : "Turn ON",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16),
              Text(
                "Valve Groups",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              Obx(() {
                return Column(
                  children: controller.groupedValves.map((group) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      child: ExpansionTile(
                        title: Text(group.name),
                        subtitle: Text("Group ID: ${group.id}"),
                        trailing: Obx(() {
                          return Switch(
                            value:
                                controller.groupToggleStates[group.id]?.value ??
                                false,
                            onChanged: (_) {
                              controller.toggleValveGroup(
                                groupId: group.id,
                                token: token,
                              );
                            },
                            activeColor: Colors.green,
                            inactiveThumbColor: Colors.red,
                          );
                        }),
                        children: group.valves.map((valve) {
                          return ListTile(
                            title: Text(valve.name),
                            subtitle: Text(
                              'Lora: ${valve.loraId}, Status: ${valve.status}',
                            ),
                            trailing: Icon(
                              valve.status == "ON"
                                  ? Icons.check_circle
                                  : Icons.power_off,
                              color: valve.status == "ON"
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }).toList(),
                );
              }),
            ],
          ),
        );
      }),
    );
  }
}
