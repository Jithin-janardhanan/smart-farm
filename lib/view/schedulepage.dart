import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfarm/controller/schedule_controller.dart';

class SchedulePage extends StatelessWidget {
  final int farmId;
  final String token;
  final ScrollController scrollController = ScrollController();
  final formKey = GlobalKey();

  SchedulePage({super.key, required this.farmId, required this.token});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      ScheduleController(farmId: farmId, token: token),
    );

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(12),
          children: [
            ElevatedButton.icon(
              onPressed: () {
                controller.showCreateForm.toggle();
                controller.resetForm();
              },
              icon: const Icon(Icons.add),
              label: Obx(
                () => Text(
                  controller.showCreateForm.value
                      ? "Cancel"
                      : "Create Schedule",
                ),
              ),
            ),
            const SizedBox(height: 16),

            // FORM SECTION
            Obx(
              () => Visibility(
                visible: controller.showCreateForm.value,
                child: Column(
                  key: formKey,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Select Motor",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...controller.inMotors.map(
                      (motor) => RadioListTile<int>(
                        title: Text(motor.name),
                        subtitle: Text("IN • Valves: ${motor.valveCount}"),
                        value: motor.id,
                        groupValue: controller.selectedMotorId.value,
                        onChanged: (val) =>
                            controller.selectedMotorId.value = val,
                      ),
                    ),
                    ...controller.outMotors.map(
                      (motor) => RadioListTile<int>(
                        title: Text(motor.name),
                        subtitle: Text("OUT • Valves: ${motor.valveCount}"),
                        value: motor.id,
                        groupValue: controller.selectedMotorId.value,
                        onChanged: (val) =>
                            controller.selectedMotorId.value = val,
                      ),
                    ),
                    const Divider(),
                    const Text(
                      "Select Grouped Valve (optional)",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...controller.groupedValves.map(
                      (group) => Obx(
                        () => RadioListTile<int>(
                          title: Text(group.name),
                          subtitle: Text(
                            "Includes ${group.valves.length} valves",
                          ),
                          value: group.id,
                          groupValue: controller.selectedGroupId.value,
                          onChanged: (val) => controller.selectGroup(val!),
                        ),
                      ),
                    ),
                    const Text(
                      "Or Select Individual Valves",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: controller.inValves
                            .map(
                              (valve) => Obx(
                                () => Container(
                                  margin: EdgeInsets.all(8),
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        valve.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Checkbox(
                                        value: controller.selectedValveIds
                                            .contains(valve.id),
                                        onChanged: (_) => controller
                                            .toggleValveSelection(valve.id),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: controller.outValves
                            .map(
                              (valve) => Obx(
                                () => Container(
                                  margin: EdgeInsets.all(8),
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        valve.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Checkbox(
                                        value: controller.selectedValveIds
                                            .contains(valve.id),
                                        onChanged: (_) => controller
                                            .toggleValveSelection(valve.id),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),

                    const Divider(),
                    const Text(
                      "Select Date Range",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                              if (date != null) {
                                controller.startDate.value = date;
                              }
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
                              if (date != null) {
                                controller.endDate.value = date;
                              }
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                              if (time != null) {
                                controller.startTime.value = time;
                              }
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
                              if (time != null) {
                                controller.endTime.value = time;
                              }
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

                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (controller.editingScheduleId.value != null) {
                          controller.editSchedule(
                            controller.editingScheduleId.value!,
                          );
                        } else {
                          controller.submitSchedule();
                        }
                      },
                      child: Obx(
                        () => Text(
                          controller.editingScheduleId.value != null
                              ? "Update Schedule"
                              : "Submit Schedule",
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Divider(),
                  ],
                ),
              ),
            ),

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
                  final isEditing =
                      controller.editingScheduleId.value == schedule.id;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // LEFT SIDE: Schedule Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Motor ID: ${schedule.motorId}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Start: ${schedule.startDate} ${schedule.startTime}",
                              ),
                              Text(
                                "End: ${schedule.endDate} ${schedule.endTime}",
                              ),
                              if (schedule.valveGroupId != null)
                                Text("Valve Group: ${schedule.valveGroupId}"),
                              Text("Valves: ${schedule.valves.join(', ')}"),
                              if (schedule.skipStatus)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    "Skipped Today",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // RIGHT SIDE: Edit & Delete Icons
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                controller.loadScheduleForEdit(schedule);
                                controller.showCreateForm.value = true;
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                Get.defaultDialog(
                                  title: "Confirm Delete",
                                  middleText:
                                      "Are you sure you want to delete this schedule?",
                                  textConfirm: "Yes",
                                  textCancel: "No",
                                  confirmTextColor: Colors.white,
                                  onConfirm: () {
                                    controller.deleteSchedule(schedule.id);
                                    Get.back();
                                  },
                                );
                              },
                            ),
                            if (!schedule.skipStatus)
                              TextButton(
                                onPressed: () =>
                                    controller.toggleSkipStatus(schedule.id),
                                child: const Text("Skip for the day"),
                              )
                            else
                              TextButton(
                                onPressed: () =>
                                    controller.toggleSkipStatus(schedule.id),
                                child: const Text("Undo Skip"),
                              ),
                          ],
                        ),
                      ],
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
