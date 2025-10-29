import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfarm/controller/schedule_controller.dart';

class SchedulePage extends StatelessWidget {
  final int farmId;
  final String token;

  SchedulePage({super.key, required this.farmId, required this.token});

  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      ScheduleController(farmId: farmId, token: token),
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      floatingActionButton: Obx(
        () => FloatingActionButton.extended(
          backgroundColor: controller.showCreateForm.value
              ? Colors.redAccent
              : Colors.green.shade700,
          icon: Icon(
            controller.showCreateForm.value ? Icons.close : Icons.add,
            color: Colors.white,
          ),
          label: Text(
            controller.showCreateForm.value ? "Cancel" : "Create Schedule",
            style: const TextStyle(color: Colors.white),
          ),
          onPressed: () {
            controller.showCreateForm.toggle();
            controller.resetForm();
          },
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchSchedules(),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 10),

              // --- CREATE/EDIT FORM ---
              Obx(
                () => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: controller.showCreateForm.value
                      ? _buildScheduleForm(context, controller)
                      : const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 20),

              // --- LIST OF SCHEDULES ---
              const Text(
                "Scheduled Entries",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Obx(() {
                if (controller.schedules.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                      child: Text(
                        "No schedules found.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  );
                }

                return Column(
                  children: controller.schedules.map((schedule) {
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // LEFT INFO
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Motor ID: ${schedule.motorId}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Start: ${schedule.startDate} ${schedule.startTime}",
                                  ),
                                  Text(
                                    "End: ${schedule.endDate} ${schedule.endTime}",
                                  ),
                                  if (schedule.valveGroupId != null)
                                    Text(
                                      "Valve Group: ${schedule.valveGroupId}",
                                    ),
                                  Text("Valves: ${schedule.valves.join(', ')}"),
                                  if (schedule.skipStatus)
                                    Container(
                                      margin: const EdgeInsets.only(top: 6),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
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

                            // RIGHT ACTIONS
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    controller.loadScheduleForEdit(schedule);
                                    controller.showCreateForm.value = true;
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
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
                                TextButton(
                                  onPressed: () =>
                                      controller.toggleSkipStatus(schedule.id),
                                  child: Text(
                                    schedule.skipStatus
                                        ? "Undo Skip"
                                        : "Skip Today",
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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

  /// 🧩 BUILD THE CREATE/EDIT FORM SECTION
  Widget _buildScheduleForm(
    BuildContext context,
    ScheduleController controller,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Motor",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            ...controller.inMotors.map(
              (motor) => RadioListTile<int>(
                title: Text(motor.name),
                subtitle: const Text("IN Motor"),
                value: motor.id,
                groupValue: controller.selectedMotorId.value,
                onChanged: (val) => controller.selectedMotorId.value = val,
              ),
            ),
            ...controller.outMotors.map(
              (motor) => RadioListTile<int>(
                title: Text(motor.name),
                subtitle: const Text("OUT Motor"),
                value: motor.id,
                groupValue: controller.selectedMotorId.value,
                onChanged: (val) => controller.selectedMotorId.value = val,
              ),
            ),
            const Divider(),

            const Text(
              "Grouped Valves",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: controller.groupedValves.map((group) {
                final isSelected = controller.selectedGroupId.value == group.id;
                return ChoiceChip(
                  label: Text(group.name),
                  selected: isSelected,
                  onSelected: (_) => controller.selectGroup(group.id),
                );
              }).toList(),
            ),
            const Divider(),

            const Text(
              "Individual Valves",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: [
                ...controller.inValves.map(
                  (valve) => FilterChip(
                    label: Text(valve.name),
                    selected: controller.selectedValveIds.contains(valve.id),
                    onSelected: (_) =>
                        controller.toggleValveSelection(valve.id),
                  ),
                ),
                ...controller.outValves.map(
                  (valve) => FilterChip(
                    label: Text(valve.name),
                    selected: controller.selectedValveIds.contains(valve.id),
                    onSelected: (_) =>
                        controller.toggleValveSelection(valve.id),
                  ),
                ),
              ],
            ),
            const Divider(),

            const Text(
              "Select Dates",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Obx(
                      () => Text(
                        controller.startDate.value == null
                            ? "Start Date"
                            : controller.startDate.value!
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0],
                      ),
                    ),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2026),
                      );
                      if (date != null) controller.startDate.value = date;
                    },
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.calendar_month),
                    label: Obx(
                      () => Text(
                        controller.endDate.value == null
                            ? "End Date"
                            : controller.endDate.value!
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0],
                      ),
                    ),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2026),
                      );
                      if (date != null) controller.endDate.value = date;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            const Text(
              "Select Time",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.access_time),
                    label: Obx(
                      () => Text(
                        controller.startTime.value == null
                            ? "Start Time"
                            : controller.startTime.value!.format(context),
                      ),
                    ),
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) controller.startTime.value = time;
                    },
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.timer_outlined),
                    label: Obx(
                      () => Text(
                        controller.endTime.value == null
                            ? "End Time"
                            : controller.endTime.value!.format(context),
                      ),
                    ),
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) controller.endTime.value = time;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  if (controller.editingScheduleId.value != null) {
                    await controller.editSchedule(
                      controller.editingScheduleId.value!,
                    );
                  } else {
                    await controller.submitSchedule();
                  }
                  controller.showCreateForm.value = false;
                  controller.resetForm();
                },
                child: Obx(
                  () => Text(
                    controller.editingScheduleId.value != null
                        ? "Update Schedule"
                        : "Submit Schedule",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
