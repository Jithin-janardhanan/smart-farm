import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfarm/controller/schedule_controller.dart';

class SchedulePage extends StatelessWidget {
  final int farmId;
  final String token;

  const SchedulePage({Key? key, required this.farmId, required this.token})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      ScheduleController(farmId: farmId, token: token),
    );

    return Scaffold(
      //
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            const Text(
              "Select Motor",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...controller.inMotors.map(
              (motor) => RadioListTile<int>(
                title: Text(motor.name),
                subtitle: Text("IN • Valves: ${motor.valveCount}"),
                value: motor.id,
                groupValue: controller.selectedMotorId.value,
                onChanged: (val) => controller.selectedMotorId.value = val,
              ),
            ),
            ...controller.outMotors.map(
              (motor) => RadioListTile<int>(
                title: Text(motor.name),
                subtitle: Text("OUT • Valves: ${motor.valveCount}"),
                value: motor.id,
                groupValue: controller.selectedMotorId.value,
                onChanged: (val) => controller.selectedMotorId.value = val,
              ),
            ),

            const Divider(),
            const Text(
              "Select Grouped Valve (optional)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...controller.groupedValves.map(
              (group) => Obx(
                () => RadioListTile<int>(
                  title: Text(group.name),
                  subtitle: Text("Includes ${group.valves.length} valves"),
                  value: group.id,
                  groupValue: controller.selectedGroupId.value,
                  onChanged: (val) => controller.selectGroup(val!),
                ),
              ),
            ),
            const Divider(),
            const Text(
              "Select Date Range",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2026),
                      );
                      if (date != null) controller.startDate.value = date;
                    },
                    child: Obx(
                      () => Text(
                        controller.startDate.value == null
                            ? "Start Date"
                            : "Start: ${controller.startDate.value!.toLocal().toString().split(' ')[0]}",
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2026),
                      );
                      if (date != null) controller.endDate.value = date;
                    },
                    child: Obx(
                      () => Text(
                        controller.endDate.value == null
                            ? "End Date"
                            : "End: ${controller.endDate.value!.toLocal().toString().split(' ')[0]}",
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Text(
              "Select Time",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) controller.startTime.value = time;
                    },
                    child: Obx(
                      () => Text(
                        controller.startTime.value == null
                            ? "Start Time"
                            : "Start: ${controller.startTime.value!.format(context)}",
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) controller.endTime.value = time;
                    },
                    child: Obx(
                      () => Text(
                        controller.endTime.value == null
                            ? "End Time"
                            : "End: ${controller.endTime.value!.format(context)}",
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const Divider(),
            const Text(
              "Or Select Individual Valves",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...controller.inValves.map(
              (valve) => Obx(
                () => CheckboxListTile(
                  title: Text(valve.name),
                  subtitle: Text("IN • ${valve.loraId} • ${valve.status}"),
                  value: controller.selectedValveIds.contains(valve.id),
                  onChanged: (_) => controller.toggleValveSelection(valve.id),
                ),
              ),
            ),
            ...controller.outValves.map(
              (valve) => Obx(
                () => CheckboxListTile(
                  title: Text(valve.name),
                  subtitle: Text("OUT • ${valve.loraId} • ${valve.status}"),
                  value: controller.selectedValveIds.contains(valve.id),
                  onChanged: (_) => controller.toggleValveSelection(valve.id),
                ),
              ),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => controller.submitSchedule(),

              child: const Text("Submit Schedule"),
            ),
            const SizedBox(height: 30),
            const Divider(),
            const Text(
              "Scheduled Entries",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Obx(() {
              if (controller.schedules.isEmpty) {
                return const Text("No schedules found.");
              }

              return Column(
                children: controller.schedules.map((schedule) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    elevation: 2,
                    child: ListTile(
                      title: Text("Motor ID: ${schedule..motorId}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Start: ${schedule.startDate} ${schedule.startTime}",
                          ),
                          Text("End: ${schedule.endDate} ${schedule.endTime}"),
                          if (schedule.valveGroupId != null)
                            Text("Valve Group: ${schedule.valveGroupId}"),
                          Text("Valves: ${schedule.valves.join(', ')}"),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        );
      }),
    );
  }
}
