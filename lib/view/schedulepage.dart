import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfarm/controller/schedule_controller.dart';
import 'package:smartfarm/utils/schedule_form_modal.dart';

class SchedulePage extends StatelessWidget {
  final int farmId;
  final String token;

  const SchedulePage({super.key, required this.farmId, required this.token});

  // ──────────────────────────────────────────────────────────────
  // Open modal (create or edit)
  // ──────────────────────────────────────────────────────────────
  void _showScheduleModal(
    BuildContext context,
    ScheduleController controller, {
    int? editScheduleId,
  }) {
    // Prepare form
    if (editScheduleId != null) {
      controller.loadScheduleForEditById(editScheduleId);
    } else {
      controller.resetForm();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (_) => ScheduleFormModal(controller: controller),
    ).whenComplete(() {
      controller.resetForm();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      ScheduleController(farmId: farmId, token: token),
    );
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colorScheme.primary,
        icon: const Icon(Icons.add),
        label: const Text("Create Schedule"),
        onPressed: () => _showScheduleModal(context, controller),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          );
        }

        return RefreshIndicator(
          color: colorScheme.primary,
          onRefresh: controller.fetchSchedules,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 10),
              Text(
                "Scheduled Entries",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // ────── Schedule List ──────
              Obx(() {
                if (controller.schedules.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                      child: Text(
                        "No schedules found.",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                }

                return Column(
                  children: controller.schedules.map((schedule) {
                    return Card(
                      color: colorScheme.surface,
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
                            // LEFT – Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Motor ID: ${schedule.motorId}",
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Start: ${schedule.startDate} ${schedule.startTime}",
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  Text(
                                    "End: ${schedule.endDate} ${schedule.endTime}",
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  if (schedule.valveGroupId != null)
                                    Text(
                                      "Valve Group: ${schedule.valveGroupId}",
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  Text(
                                    "Valves: ${schedule.valves.join(', ')}",
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  if (schedule.skipStatus)
                                    Container(
                                      margin: const EdgeInsets.only(top: 6),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.errorContainer,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        "Skipped Today",
                                        style: TextStyle(
                                          color: colorScheme.onErrorContainer,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // RIGHT – Actions
                            Column(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: colorScheme.primary,
                                  ),
                                  onPressed: () => _showScheduleModal(
                                    context,
                                    controller,
                                    editScheduleId: schedule.id,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: colorScheme.error,
                                  ),
                                  onPressed: () => Get.defaultDialog(
                                    title: "Confirm Delete",
                                    middleText:
                                        "Are you sure you want to delete this schedule?",
                                    textConfirm: "Yes",
                                    textCancel: "No",
                                    confirmTextColor: colorScheme.onPrimary,
                                    onConfirm: () {
                                      controller.deleteSchedule(schedule.id);
                                      Get.back();
                                    },
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      controller.toggleSkipStatus(schedule.id),
                                  child: Text(
                                    schedule.skipStatus
                                        ? "Undo Skip"
                                        : "Skip Today",
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.secondary,
                                    ),
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
}
