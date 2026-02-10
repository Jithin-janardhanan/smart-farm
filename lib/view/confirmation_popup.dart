import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

Future<void> showMotorConfirmationDialog({
  required String motorName,
  required VoidCallback onConfirm,
  required Function(int durationMinutes) onTimedConfirm,
}) {
  // Observable state inside the dialog
  final RxBool useTimer = false.obs;
  final RxBool isHour = false.obs; // false = minutes, true = hours
  final TextEditingController timerValueController = TextEditingController();
  final RxString timerError = ''.obs;

  return Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Obx(() {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Icon ──────────────────────────────────────────────
              const Center(
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 52,
                ),
              ),
              const SizedBox(height: 12),

              // ── Title ─────────────────────────────────────────────
              const Center(
                child: Text(
                  "Confirm Motor Start",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ── Subtitle ──────────────────────────────────────────
              Center(
                child: Text(
                  "Turn ON  $motorName?",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ),

              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // ── Timer toggle row ──────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 20,
                        color: useTimer.value
                            ? Theme.of(Get.context!).colorScheme.primary
                            : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Set Timer",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: useTimer.value
                              ? Theme.of(Get.context!).colorScheme.primary
                              : null,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: useTimer.value,
                    onChanged: (val) {
                      useTimer.value = val;
                      if (!val) {
                        timerValueController.clear();
                        timerError.value = '';
                      }
                    },
                    activeThumbColor:
                        Theme.of(Get.context!).colorScheme.primary,
                  ),
                ],
              ),

              // ── Timer input (visible only when useTimer is ON) ────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) => SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: -1,
                  child: child,
                ),
                child: useTimer.value
                    ? Padding(
                        key: const ValueKey('timer-input'),
                        padding: const EdgeInsets.only(top: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Unit toggle (Minutes / Hours) ────────
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(Get.context!)
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withOpacity(0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _UnitToggleButton(
                                      label: "Minutes",
                                      icon: Icons.schedule,
                                      selected: !isHour.value,
                                      onTap: () {
                                        isHour.value = false;
                                        timerValueController.clear();
                                        timerError.value = '';
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: _UnitToggleButton(
                                      label: "Hours",
                                      icon: Icons.hourglass_bottom_rounded,
                                      selected: isHour.value,
                                      onTap: () {
                                        isHour.value = true;
                                        timerValueController.clear();
                                        timerError.value = '';
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // ── Value input ───────────────────────────
                            TextField(
                              controller: timerValueController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                labelText: isHour.value
                                    ? "Duration (hours)"
                                    : "Duration (minutes)",
                                hintText:
                                    isHour.value ? "e.g. 2" : "e.g. 30",
                                prefixIcon: Icon(
                                  Icons.timer,
                                  color: Theme.of(Get.context!)
                                      .colorScheme
                                      .primary,
                                ),
                                suffixText:
                                    isHour.value ? "hr" : "min",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                errorText: timerError.value.isNotEmpty
                                    ? timerError.value
                                    : null,
                              ),
                              onChanged: (_) {
                                if (timerError.value.isNotEmpty) {
                                  timerError.value = '';
                                }
                              },
                            ),

                            // ── Helper chip ───────────────────────────
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Wrap(
                                spacing: 6,
                                children: (isHour.value
                                        ? [1, 2, 4, 8]
                                        : [15, 30, 45, 60])
                                    .map(
                                      (v) => ActionChip(
                                        label: Text(
                                          "$v ${isHour.value ? 'hr' : 'min'}",
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        padding: EdgeInsets.zero,
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () {
                                          timerValueController.text =
                                              v.toString();
                                          timerError.value = '';
                                        },
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('no-timer')),
              ),

              const SizedBox(height: 20),

              // ── Action buttons ────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(
                        useTimer.value
                            ? Icons.timer_outlined
                            : Icons.power_settings_new,
                        size: 18,
                      ),
                      label: Text(useTimer.value ? "Start Timer" : "Turn ON"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        if (useTimer.value) {
                          // ── Validate ────────────────────────────
                          final raw =
                              int.tryParse(timerValueController.text.trim());
                          if (raw == null || raw <= 0) {
                            timerError.value =
                                'Please enter a valid duration';
                            return;
                          }

                          final maxVal = isHour.value ? 24 : 1440;
                          if (raw > maxVal) {
                            timerError.value = isHour.value
                                ? 'Maximum 24 hours allowed'
                                : 'Maximum 1440 minutes allowed';
                            return;
                          }

                          final minutes =
                              isHour.value ? raw * 60 : raw;

                          Get.back();
                          onTimedConfirm(minutes);
                        } else {
                          Get.back();
                          onConfirm();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    ),
    barrierDismissible: false,
  );
}

// ── Private helper widget ──────────────────────────────────────────────────

class _UnitToggleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _UnitToggleButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color:
                    selected ? colorScheme.onPrimary : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}