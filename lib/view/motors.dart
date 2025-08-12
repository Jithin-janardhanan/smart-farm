import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfarm/controller/motorlist_controller.dart';
import 'package:smartfarm/model/power_supply.dart';

class MotorListTab extends StatelessWidget {
  final int farmId;
  final String token;

  MotorListTab({super.key, required this.farmId, required this.token});

  final MotorController controller = Get.find<MotorController>();

  @override
  Widget build(BuildContext context) {
    // Start live data updates only once
    controller.startLiveDataUpdates(token, farmId);
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Inside MotorListTab build() -> before "In Motors" section
            Obx(() {
              if (controller.isLiveDataLoading.value &&
                  controller.liveData.value == null) {
                return const Center(child: CircularProgressIndicator());
              }

              // Use default zero data if null
              final data =
                  controller.liveData.value ??
                  LiveData(
                    id: 0,
                    farmName: "Farm $farmId",
                    voltage: [0.0, 0.0, 0.0],
                    currentR: 0.0,
                    currentY: 0.0,
                    currentB: 0.0,
                  );

              final isMotorRunning =
                  !(data.voltage.every((v) => v == 0.0) &&
                      data.currentR == 0.0 &&
                      data.currentY == 0.0 &&
                      data.currentB == 0.0);

              return Column(
                children: [
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Live Data - ${data.farmName}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (!isMotorRunning)
                            const Text(
                              "Motor is OFF",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          Text(
                            "Voltage: ${data.voltage.map((v) => '${v}V').join(', ')}",
                          ),
                          Text("Current R: ${data.currentR} A"),
                          Text("Current Y: ${data.currentY} A"),
                          Text("Current B: ${data.currentB} A"),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () =>
                                controller.fetchLiveData(token, farmId),
                            icon: const Icon(Icons.refresh),
                            label: const Text("Refresh"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // You can add rest of your UI here
                ],
              );
            }),

            Text(
              "In Motors",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            ...controller.inMotors.map(
              (motor) => Card(
                child: Obx(
                  () => ListTile(
                    title: Text(motor.name),
                    subtitle: Text(
                      'Lora: ${motor.loraId}, Status: ${motor.status.value}',
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: motor.status.value == "ON"
                            ? Colors.red
                            : Colors.green,
                      ),
                      onPressed: () {
                        final newStatus = motor.status.value == "ON"
                            ? "OFF"
                            : "ON";
                        controller.toggleMotor(
                          motorId: motor.id,
                          status: newStatus,
                          farmId: farmId,
                          token: token,
                        );
                      },
                      child: Text(
                        motor.status.value == "ON" ? "Turn OFF" : "Turn ON",
                        style: const TextStyle(color: Colors.white),
                      ),
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
            ...controller.outMotors.map(
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
              "Grouped Valves",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            Obx(() {
              final groups = controller.groupedValves;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(groups.length, (i) {
                  final group = groups[i];
                  return ExpansionTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${group.name} (ID: ${group.id})",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Obx(() {
                          return Switch(
                            value:
                                controller.groupToggleStates[group.id]?.value ??
                                false,
                            onChanged: (_) {
                              controller.toggleValveGroup(
                                groupId: group.id,
                                token: token,
                                farmId: farmId,
                              );
                            },
                          );
                        }),
                      ],
                    ),
                    children: group.valves.map<Widget>((valve) {
                      return Card(
                        margin: EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 12,
                        ),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      valve.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text("Lora: ${valve.loraId}"),
                                    Text(
                                      valve.status == 'ON'
                                          ? 'Status: Opened'
                                          : 'Status: Closed',
                                      style: TextStyle(
                                        color: valve.status == 'ON'
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                iconSize: 48,
                                icon: Icon(
                                  valve.status == "ON"
                                      ? Icons.toggle_on
                                      : Icons.toggle_off,
                                  color: valve.status == "ON"
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                onPressed: () {
                                  final newStatus = valve.status == "ON"
                                      ? "OFF"
                                      : "ON";
                                  controller.toggleValve(
                                    valveId: valve.id,
                                    status: newStatus,
                                    token: token,
                                    farmId: farmId,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
              );
            }),

            SizedBox(height: 16),
            Text(
              "Ungrouped Valves",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            Obx(() {
              if (controller.ungroupedValves.isEmpty) {
                return Text("No ungrouped valves found.");
              }

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: controller.ungroupedValves.map((valve) {
                  return Container(
                    width: MediaQuery.of(context).size.width / 2 - 24,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          valve.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Lora: ${valve.loraId}',
                          style: TextStyle(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 1),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              valve.status == "ON" ? "Opened" : "Closed",
                              style: TextStyle(
                                color: valve.status == "ON"
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: Icon(
                                  valve.status == "ON"
                                      ? Icons.toggle_on
                                      : Icons.toggle_off,
                                  color: valve.status == "ON"
                                      ? Colors.green
                                      : Colors.grey,
                                  size: 50,
                                ),
                                onPressed: () {
                                  final newStatus = valve.status == "ON"
                                      ? "OFF"
                                      : "ON";
                                  controller.toggleValve(
                                    valveId: valve.id,
                                    status: newStatus,
                                    token: token,
                                    farmId: farmId,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }),
            // Paste everything from the original MotorListPage body here
            // starting from `Text("In Motors")` to end of "Ungrouped Valves"
          ],
        ),
      );
    });
  }
}
