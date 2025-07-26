import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/valve_controller.dart';

class ValveGroupingPage extends StatelessWidget {
  final int farmId;
  final String token;

  ValveGroupingPage({required this.farmId, required this.token});

  final ValveController controller = Get.put(ValveController());

  @override
  Widget build(BuildContext context) {
    controller.fetchValves(farmId, token);

    return Scaffold(
      appBar: AppBar(title: Text('Valve Grouping')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("IN Valves", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...controller.inValves.map((valve) => ListTile(
                    title: Text(valve.name),
                    subtitle: Text('Lora: ${valve.loraId}, Status: ${valve.status}'),
                  )),

              SizedBox(height: 16),
              Text("OUT Valves", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...controller.outValves.map((valve) => ListTile(
                    title: Text(valve.name),
                    subtitle: Text('Lora: ${valve.loraId}, Status: ${valve.status}'),
                  )),
            ],
          ),
        );
      }),
    );
  }
}
