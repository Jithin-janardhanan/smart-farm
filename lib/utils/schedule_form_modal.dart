import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfarm/controller/schedule_controller.dart';
import 'package:smartfarm/utils/snackbar_helper.dart' as SnackbarHelper;

class ScheduleFormModal extends StatelessWidget {
  final ScheduleController controller;

  const ScheduleFormModal({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // ─── Drag handle ───
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // ─── Title + Close ───
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(
                    () => Text(
                      controller.editingScheduleId.value != null
                          ? "Edit Schedule"
                          : "Create Schedule",
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),

            // ─── Scrollable content ───
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: _buildFormContent(
                  context,
                  controller,
                  textTheme,
                  colorScheme,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Extracted the inner form content here
  Widget _buildFormContent(
    BuildContext context,
    ScheduleController controller,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // ────── MOTOR SELECTION ──────
        Text(
          "Select Motor",
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final selectedId = controller.selectedMotorId.value;
          return Column(
            children: [
              ...controller.inMotors.map(
                (motor) => RadioListTile<int>(
                  value: motor.id,
                  groupValue: selectedId,
                  onChanged: (val) => controller.selectedMotorId.value = val,
                  activeColor: colorScheme.primary,
                  title: Text(motor.name, style: textTheme.bodyLarge),
                  subtitle: Text(
                    "IN Motor",
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              ...controller.outMotors.map(
                (motor) => RadioListTile<int>(
                  value: motor.id,
                  groupValue: selectedId,
                  onChanged: (val) => controller.selectedMotorId.value = val,
                  activeColor: colorScheme.primary,
                  title: Text(motor.name, style: textTheme.bodyLarge),
                  subtitle: Text(
                    "OUT Motor",
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),

        const Divider(height: 32),

        // ────── VALVE GROUPS ──────
        Text(
          "Grouped Valves",
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Wrap(
            spacing: 8,
            children: controller.groupedValves.map((group) {
              final isSelected = controller.selectedGroupId.value == group.id;
              return ChoiceChip(
                label: Text(group.name),
                selected: isSelected,
                onSelected: (_) => controller.selectGroup(group.id),
                selectedColor: colorScheme.primaryContainer,
                backgroundColor: colorScheme.surface,
                labelStyle: TextStyle(
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected ? colorScheme.primary : colorScheme.outline,
                ),
              );
            }).toList(),
          ),
        ),

        const Divider(height: 32),

        // ────── INDIVIDUAL VALVES ──────
        Text(
          "Individual Valves",
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Wrap(
            spacing: 6,
            children: [
              ...controller.inValves.map(
                (valve) => _buildValveChip(valve, controller, colorScheme),
              ),
              ...controller.outValves.map(
                (valve) => _buildValveChip(valve, controller, colorScheme),
              ),
            ],
          ),
        ),

        const Divider(height: 32),

        // ────── DATES ──────
        Text(
          "Select Dates",
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildDatePickers(context, controller, colorScheme, textTheme),

        const SizedBox(height: 16),

        // ────── TIMES ──────
        Text(
          "Select Time",
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildTimePickers(context, controller, colorScheme, textTheme),

        const SizedBox(height: 24),

        // ────── SUBMIT BUTTON ──────
        _buildSubmitButton(context, controller, colorScheme),
      ],
    );
  }

  Widget _buildValveChip(
    valve,
    ScheduleController controller,
    ColorScheme colorScheme,
  ) {
    final isSelected = controller.selectedValveIds.contains(valve.id);
    return FilterChip(
      label: Text(valve.name),
      selected: isSelected,
      onSelected: (_) => controller.toggleValveSelection(valve.id),
      selectedColor: colorScheme.secondaryContainer,
      backgroundColor: colorScheme.surface,
      labelStyle: TextStyle(
        color: isSelected
            ? colorScheme.onSecondaryContainer
            : colorScheme.onSurface,
      ),
      side: BorderSide(
        color: isSelected ? colorScheme.secondary : colorScheme.outline,
      ),
    );
  }

  Widget _buildDatePickers(
    BuildContext context,
    ScheduleController controller,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today),
            label: Obx(
              () => Text(
                controller.startDate.value == null
                    ? "Start Date"
                    : controller.startDate.value!.toLocal().toString().split(
                        ' ',
                      )[0],
                style: textTheme.bodyMedium,
              ),
            ),
            onPressed: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2024),
                lastDate: DateTime(2026),
              );
              if (d != null) controller.startDate.value = d;
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.calendar_month),
            label: Obx(
              () => Text(
                controller.endDate.value == null
                    ? "End Date"
                    : controller.endDate.value!.toLocal().toString().split(
                        ' ',
                      )[0],
                style: textTheme.bodyMedium,
              ),
            ),
            onPressed: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2024),
                lastDate: DateTime(2026),
              );
              if (d != null) controller.endDate.value = d;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimePickers(
    BuildContext context,
    ScheduleController controller,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.access_time),
            label: Obx(
              () => Text(
                controller.startTime.value == null
                    ? "Start Time"
                    : controller.startTime.value!.format(context),
                style: textTheme.bodyMedium,
              ),
            ),
            onPressed: () async {
              final t = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (t != null) controller.startTime.value = t;
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.timer_outlined),
            label: Obx(
              () => Text(
                controller.endTime.value == null
                    ? "End Time"
                    : controller.endTime.value!.format(context),
                style: textTheme.bodyMedium,
              ),
            ),
            onPressed: () async {
              final t = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (t != null) controller.endTime.value = t;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    ScheduleController controller,
    ColorScheme colorScheme,
  ) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          onPressed: controller.isSubmitting.value
              ? null
              : () async {
                  controller.isSubmitting.value = true;
                  try {
                    if (controller.editingScheduleId.value != null) {
                      await controller.editSchedule(
                        controller.editingScheduleId.value!,
                      );
                    } else {
                      await controller.submitSchedule();
                    }

                    if (context.mounted) Navigator.of(context).pop();
                    controller.fetchSchedules();
                  } catch (e) {
                    log("Error submitting schedule: $e");
                    SnackbarHelper.showThemedSnackbar("Error", e.toString());
                  } finally {
                    controller.isSubmitting.value = false;
                  }
                },
          child: controller.isSubmitting.value
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  controller.editingScheduleId.value != null
                      ? "Update Schedule"
                      : "Create Schedule",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
