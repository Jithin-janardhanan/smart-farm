// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:smartfarm/controller/schedule_controller.dart';

// class SchedulePage extends StatelessWidget {
//   final int farmId;
//   final String token;
//   final ScrollController scrollController = ScrollController();
//   final formKey = GlobalKey();

//   SchedulePage({super.key, required this.farmId, required this.token});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(
//       ScheduleController(farmId: farmId, token: token),
//     );

//     return Scaffold(
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         return ListView(
//           controller: scrollController,
//           padding: const EdgeInsets.all(12),
//           children: [
//             ElevatedButton.icon(
//               onPressed: () {
//                 controller.showCreateForm.toggle();
//                 controller.resetForm();
//               },
//               icon: const Icon(Icons.add),
//               label: Obx(
//                 () => Text(
//                   controller.showCreateForm.value
//                       ? "Cancel"
//                       : "Create Schedule",
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),

//             // FORM SECTION
//             Obx(
//               () => Visibility(
//                 visible: controller.showCreateForm.value,
//                 child: Column(
//                   key: formKey,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       "Select Motor",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     ...controller.inMotors.map(
//                       (motor) => RadioListTile<int>(
//                         title: Text(motor.name),
//                         subtitle: Text("IN • Valves: ${motor.valveCount}"),
//                         value: motor.id,
//                         groupValue: controller.selectedMotorId.value,
//                         onChanged: (val) =>
//                             controller.selectedMotorId.value = val,
//                       ),
//                     ),
//                     ...controller.outMotors.map(
//                       (motor) => RadioListTile<int>(
//                         title: Text(motor.name),
//                         subtitle: Text("OUT • Valves: ${motor.valveCount}"),
//                         value: motor.id,
//                         groupValue: controller.selectedMotorId.value,
//                         onChanged: (val) =>
//                             controller.selectedMotorId.value = val,
//                       ),
//                     ),
//                     const Divider(),
//                     const Text(
//                       "Select Grouped Valve (optional)",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     ...controller.groupedValves.map(
//                       (group) => Obx(
//                         () => RadioListTile<int>(
//                           title: Text(group.name),
//                           subtitle: Text(
//                             "Includes ${group.valves.length} valves",
//                           ),
//                           value: group.id,
//                           groupValue: controller.selectedGroupId.value,
//                           onChanged: (val) => controller.selectGroup(val!),
//                         ),
//                       ),
//                     ),
//                     const Text(
//                       "Or Select Individual Valves",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: Row(
//                         children: controller.inValves
//                             .map(
//                               (valve) => Obx(
//                                 () => Container(
//                                   margin: EdgeInsets.all(8),
//                                   padding: EdgeInsets.all(12),
//                                   decoration: BoxDecoration(
//                                     border: Border.all(
//                                       color: Colors.grey.shade300,
//                                     ),
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         valve.name,
//                                         style: TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                       SizedBox(height: 8),
//                                       Checkbox(
//                                         value: controller.selectedValveIds
//                                             .contains(valve.id),
//                                         onChanged: (_) => controller
//                                             .toggleValveSelection(valve.id),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             )
//                             .toList(),
//                       ),
//                     ),

//                     SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: Row(
//                         children: controller.outValves
//                             .map(
//                               (valve) => Obx(
//                                 () => Container(
//                                   margin: EdgeInsets.all(8),
//                                   padding: EdgeInsets.all(12),
//                                   decoration: BoxDecoration(
//                                     border: Border.all(
//                                       color: Colors.grey.shade300,
//                                     ),
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         valve.name,
//                                         style: TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                       SizedBox(height: 8),
//                                       Checkbox(
//                                         value: controller.selectedValveIds
//                                             .contains(valve.id),
//                                         onChanged: (_) => controller
//                                             .toggleValveSelection(valve.id),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             )
//                             .toList(),
//                       ),
//                     ),

//                     const Divider(),
//                     const Text(
//                       "Select Date Range",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: TextButton(
//                             onPressed: () async {
//                               final date = await showDatePicker(
//                                 context: context,
//                                 initialDate: DateTime.now(),
//                                 firstDate: DateTime(2024),
//                                 lastDate: DateTime(2026),
//                               );
//                               if (date != null) {
//                                 controller.startDate.value = date;
//                               }
//                             },
//                             child: Obx(
//                               () => Text(
//                                 controller.startDate.value == null
//                                     ? "Start Date"
//                                     : "Start: ${controller.startDate.value!.toLocal().toString().split(' ')[0]}",
//                               ),
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           child: TextButton(
//                             onPressed: () async {
//                               final date = await showDatePicker(
//                                 context: context,
//                                 initialDate: DateTime.now(),
//                                 firstDate: DateTime(2024),
//                                 lastDate: DateTime(2026),
//                               );
//                               if (date != null) {
//                                 controller.endDate.value = date;
//                               }
//                             },
//                             child: Obx(
//                               () => Text(
//                                 controller.endDate.value == null
//                                     ? "End Date"
//                                     : "End: ${controller.endDate.value!.toLocal().toString().split(' ')[0]}",
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 12),
//                     const Text(
//                       "Select Time",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: TextButton(
//                             onPressed: () async {
//                               final time = await showTimePicker(
//                                 context: context,
//                                 initialTime: TimeOfDay.now(),
//                               );
//                               if (time != null) {
//                                 controller.startTime.value = time;
//                               }
//                             },
//                             child: Obx(
//                               () => Text(
//                                 controller.startTime.value == null
//                                     ? "Start Time"
//                                     : "Start: ${controller.startTime.value!.format(context)}",
//                               ),
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           child: TextButton(
//                             onPressed: () async {
//                               final time = await showTimePicker(
//                                 context: context,
//                                 initialTime: TimeOfDay.now(),
//                               );
//                               if (time != null) {
//                                 controller.endTime.value = time;
//                               }
//                             },
//                             child: Obx(
//                               () => Text(
//                                 controller.endTime.value == null
//                                     ? "End Time"
//                                     : "End: ${controller.endTime.value!.format(context)}",
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 20),
//                     ElevatedButton(
//                       onPressed: () {
//                         if (controller.editingScheduleId.value != null) {
//                           controller.editSchedule(
//                             controller.editingScheduleId.value!,
//                           );
//                         } else {
//                           controller.submitSchedule();
//                         }
//                       },
//                       child: Obx(
//                         () => Text(
//                           controller.editingScheduleId.value != null
//                               ? "Update Schedule"
//                               : "Submit Schedule",
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                     const Divider(),
//                   ],
//                 ),
//               ),
//             ),

//             const Text(
//               "Scheduled Entries",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Obx(() {
//               if (controller.schedules.isEmpty) {
//                 return const Text("No schedules found.");
//               }

//               return Column(
//                 children: controller.schedules.map((schedule) {
//                   final isEditing =
//                       controller.editingScheduleId.value == schedule.id;

//                   return Container(
//                     margin: const EdgeInsets.symmetric(vertical: 6),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 8,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(8),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.2),
//                           blurRadius: 4,
//                           offset: Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // LEFT SIDE: Schedule Info
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 "Motor ID: ${schedule.motorId}",
//                                 style: TextStyle(fontWeight: FontWeight.bold),
//                               ),
//                               Text(
//                                 "Start: ${schedule.startDate} ${schedule.startTime}",
//                               ),
//                               Text(
//                                 "End: ${schedule.endDate} ${schedule.endTime}",
//                               ),
//                               if (schedule.valveGroupId != null)
//                                 Text("Valve Group: ${schedule.valveGroupId}"),
//                               Text("Valves: ${schedule.valves.join(', ')}"),
//                               if (schedule.skipStatus)
//                                 Container(
//                                   margin: const EdgeInsets.only(top: 4),
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 8,
//                                     vertical: 4,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: Colors.red.shade100,
//                                     borderRadius: BorderRadius.circular(6),
//                                   ),
//                                   child: const Text(
//                                     "Skipped Today",
//                                     style: TextStyle(
//                                       color: Colors.red,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),

//                         // RIGHT SIDE: Edit & Delete Icons
//                         Row(
//                           children: [
//                             IconButton(
//                               icon: Icon(Icons.edit, color: Colors.blue),
//                               onPressed: () {
//                                 controller.loadScheduleForEdit(schedule);
//                                 controller.showCreateForm.value = true;
//                               },
//                             ),
//                             IconButton(
//                               icon: Icon(Icons.delete, color: Colors.red),
//                               onPressed: () {
//                                 Get.defaultDialog(
//                                   title: "Confirm Delete",
//                                   middleText:
//                                       "Are you sure you want to delete this schedule?",
//                                   textConfirm: "Yes",
//                                   textCancel: "No",
//                                   confirmTextColor: Colors.white,
//                                   onConfirm: () {
//                                     controller.deleteSchedule(schedule.id);
//                                     Get.back();
//                                   },
//                                 );
//                               },
//                             ),
//                             if (!schedule.skipStatus)
//                               TextButton(
//                                 onPressed: () =>
//                                     controller.toggleSkipStatus(schedule.id),
//                                 child: const Text("Skip for the day"),
//                               )
//                             else
//                               TextButton(
//                                 onPressed: () =>
//                                     controller.toggleSkipStatus(schedule.id),
//                                 child: const Text("Undo Skip"),
//                               ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//               );
//             }),
//           ],
//         );
//       }),
//     );
//   }
// }

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
      // appBar: AppBar(
      //   title: const Text('Schedule'),
      //   backgroundColor: Colors.green,
      //   foregroundColor: Colors.white,
      //   elevation: 2,
      // ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            // Create/Cancel Button
            SizedBox(
              width: double.infinity,
              child: Obx(() {
                final isCancel = controller.showCreateForm.value;

                return ElevatedButton.icon(
                  onPressed: () {
                    controller.showCreateForm.toggle();
                    controller.resetForm();
                  },
                  icon: Icon(isCancel ? Icons.close : Icons.add),
                  label: Text(isCancel ? "Cancel" : "Create Schedule"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCancel
                        ? Colors.transparent
                        : Colors.green,
                    foregroundColor: isCancel ? Colors.red : Colors.white,
                    side: isCancel
                        ? const BorderSide(color: Colors.red, width: 2)
                        : BorderSide.none,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),

            // FORM SECTION
            Obx(
              () => Visibility(
                visible: controller.showCreateForm.value,
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      key: formKey,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Select Motor",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...controller.inMotors.map(
                          (motor) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: RadioListTile<int>(
                              title: Text(
                                motor.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                "IN • Valves: ${motor.valveCount}",
                              ),
                              value: motor.id,
                              groupValue: controller.selectedMotorId.value,
                              onChanged: (val) =>
                                  controller.selectedMotorId.value = val,
                            ),
                          ),
                        ),
                        ...controller.outMotors.map(
                          (motor) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: RadioListTile<int>(
                              title: Text(
                                motor.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                "OUT • Valves: ${motor.valveCount}",
                              ),
                              value: motor.id,
                              groupValue: controller.selectedMotorId.value,
                              onChanged: (val) =>
                                  controller.selectedMotorId.value = val,
                            ),
                          ),
                        ),
                        const Divider(height: 30),
                        const Text(
                          "Select Grouped Valve (optional)",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...controller.groupedValves.map(
                          (group) => Obx(
                            () => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: RadioListTile<int>(
                                title: Text(
                                  group.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  "Includes ${group.valves.length} valves",
                                ),
                                value: group.id,
                                groupValue: controller.selectedGroupId.value,
                                onChanged: (val) =>
                                    controller.selectGroup(val!),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Or Select Individual Valves",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (controller.inValves.isNotEmpty) ...[
                          const Text(
                            "IN Valves:",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
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
                                        margin: const EdgeInsets.all(8),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color:
                                              controller.selectedValveIds
                                                  .contains(valve.id)
                                              ? Colors.green.shade50
                                              : Colors.white,
                                          border: Border.all(
                                            color:
                                                controller.selectedValveIds
                                                    .contains(valve.id)
                                                ? Colors.green
                                                : Colors.grey.shade300,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              valve.name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Checkbox(
                                              value: controller.selectedValveIds
                                                  .contains(valve.id),
                                              onChanged: (_) => controller
                                                  .toggleValveSelection(
                                                    valve.id,
                                                  ),
                                              activeColor: Colors.green,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],

                        if (controller.outValves.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text(
                            "OUT Valves:",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: controller.outValves
                                  .map(
                                    (valve) => Obx(
                                      () => Container(
                                        margin: const EdgeInsets.all(8),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color:
                                              controller.selectedValveIds
                                                  .contains(valve.id)
                                              ? Colors.green.shade50
                                              : Colors.white,
                                          border: Border.all(
                                            color:
                                                controller.selectedValveIds
                                                    .contains(valve.id)
                                                ? Colors.green
                                                : Colors.grey.shade300,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              valve.name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Checkbox(
                                              value: controller.selectedValveIds
                                                  .contains(valve.id),
                                              onChanged: (_) => controller
                                                  .toggleValveSelection(
                                                    valve.id,
                                                  ),
                                              activeColor: Colors.green,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],

                        const Divider(height: 40),
                        const Text(
                          "Select Date Range",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
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
                                icon: const Icon(
                                  Icons.calendar_today,
                                  size: 20,
                                ),
                                label: Obx(
                                  () => Text(
                                    controller.startDate.value == null
                                        ? "Start Date"
                                        : controller.startDate.value!.toLocal().toString().split(' ')[0],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.all(16),
                                  side: const BorderSide(color: Colors.green),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
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
                                icon: const Icon(
                                  Icons.calendar_today,
                                  size: 20,
                                ),
                                label: Obx(
                                  () => Text(
                                    controller.endDate.value == null
                                        ? "End Date"
                                        : controller.endDate.value!.toLocal().toString().split(' ')[0],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.all(16),
                                  side: const BorderSide(color: Colors.green),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        const Text(
                          "Select Time",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );
                                  if (time != null) {
                                    controller.startTime.value = time;
                                  }
                                },
                                icon: const Icon(Icons.access_time, size: 20),
                                label: Obx(
                                  () => Text(
                                    controller.startTime.value == null
                                        ? "Start Time"
                                        : controller.startTime.value!.format(context),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.all(16),
                                  side: const BorderSide(color: Colors.green),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );
                                  if (time != null) {
                                    controller.endTime.value = time;
                                  }
                                },
                                icon: const Icon(Icons.access_time, size: 20),
                                label: Obx(
                                  () => Text(
                                    controller.endTime.value == null
                                        ? "End Time"
                                        : controller.endTime.value!.format(context),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.all(16),
                                  side: const BorderSide(color: Colors.green),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (controller.editingScheduleId.value != null) {
                                controller.editSchedule(
                                  controller.editingScheduleId.value!,
                                );
                              } else {
                                controller.submitSchedule();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Obx(
                              () => Text(
                                controller.editingScheduleId.value != null
                                    ? "Update Schedule"
                                    : "Submit Schedule",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              "Scheduled Entries",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.schedules.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No schedules found.",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Create your first schedule above",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: controller.schedules.map((schedule) {
                  final isEditing =
                      controller.editingScheduleId.value == schedule.id;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // LEFT SIDE: Schedule Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "Motor ID: ${schedule.motorId}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade800,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "${schedule.startDate} to ${schedule.endDate}",
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.access_time,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "${schedule.startTime} - ${schedule.endTime}",
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    if (schedule.valveGroupId != null) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.group_work,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Valve Group: ${schedule.valveGroupId}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.settings,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "Valves: ${schedule.valves.join(', ')}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (schedule.skipStatus) ...[
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade100,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.orange.shade300,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.pause_circle,
                                              color: Colors.orange.shade700,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "Skipped Today",
                                              style: TextStyle(
                                                color: Colors.orange.shade700,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // RIGHT SIDE: Action Buttons
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    color: Colors.blue,
                                    onPressed: () {
                                      controller.loadScheduleForEdit(schedule);
                                      controller.showCreateForm.value = true;
                                    },
                                    tooltip: "Edit",
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () {
                                      Get.defaultDialog(
                                        title: "Confirm Delete",
                                        middleText:
                                            "Are you sure you want to delete this schedule?",
                                        textConfirm: "Yes",
                                        textCancel: "No",
                                        confirmTextColor: Colors.white,
                                        buttonColor: Colors.red,
                                        onConfirm: () {
                                          controller.deleteSchedule(
                                            schedule.id,
                                          );
                                          Get.back();
                                        },
                                      );
                                    },
                                    tooltip: "Delete",
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Skip button at bottom
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () =>
                                  controller.toggleSkipStatus(schedule.id),
                              icon: Icon(
                                schedule.skipStatus
                                    ? Icons.play_circle
                                    : Icons.pause_circle,
                                size: 18,
                              ),
                              label: Text(
                                schedule.skipStatus
                                    ? "Undo Skip"
                                    : "Skip for the day",
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: schedule.skipStatus
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ),
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
