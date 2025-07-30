// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:smartfarm/controller/group_valve_controller.dart';
// import 'package:smartfarm/controller/valve_controller.dart';

// class CreateValveGroupPage extends StatelessWidget {
//   final int farmId;
//   final String token;

//   CreateValveGroupPage({super.key, required this.farmId, required this.token});

//   final CreateValveGroupController groupController = Get.put(
//     CreateValveGroupController(),
//   );
//   final ValveController valveController = Get.put(ValveController());
//   final TextEditingController nameController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     valveController.fetchValves(farmId, token);
//     groupController.fetchGroupedValves(token);

//     return Scaffold(
//       appBar: AppBar(title: Text('Valve Groups')),
//       body: Obx(() {
//         if (groupController.isLoadingGroups.value) {
//           return Center(child: CircularProgressIndicator());
//         }

//         return SingleChildScrollView(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // 🔹 List existing grouped valves
//               Text(
//                 "Grouped Valves",
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//               ),
//               SizedBox(height: 10),
//               ...groupController.groupedValves.map(
//                 (group) => Card(
//                   elevation: 2,
//                   margin: EdgeInsets.symmetric(vertical: 8),
//                   child: Padding(
//                     padding: const EdgeInsets.all(12.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           group.name,
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         ...group.valves.map(
//                           (v) => Padding(
//                             padding: const EdgeInsets.only(left: 8.0, top: 4),
//                             child: Text("• ${v.name} (${v.direction})"),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//               SizedBox(height: 20),

//               // 🔹 Toggle button
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "Create New Group",
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                   ),
//                   IconButton(
//                     icon: Obx(
//                       () => Icon(
//                         groupController.showForm.value
//                             ? Icons.expand_less
//                             : Icons.expand_more,
//                       ),
//                     ),
//                     onPressed: groupController.toggleForm,
//                   ),
//                 ],
//               ),

//               // 🔹 Group creation form
//               Obx(
//                 () => groupController.showForm.value
//                     ? Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           TextField(
//                             controller: nameController,
//                             onChanged: (val) =>
//                                 groupController.groupName.value = val,
//                             decoration: InputDecoration(
//                               labelText: "Group Name",
//                               border: OutlineInputBorder(),
//                             ),
//                           ),
//                           SizedBox(height: 10),
//                           Text("Select Valves"),
//                           ...valveController.inValves.map(
//                             (v) => Obx(
//                               () => CheckboxListTile(
//                                 value: groupController.selectedValveIds
//                                     .contains(v.id),
//                                 onChanged: (_) =>
//                                     groupController.toggleValve(v.id),
//                                 title: Text(v.name),
//                                 subtitle: Text('IN - ${v.loraId}'),
//                               ),
//                             ),
//                           ),
//                           ...valveController.outValves.map(
//                             (v) => Obx(
//                               () => CheckboxListTile(
//                                 value: groupController.selectedValveIds
//                                     .contains(v.id),
//                                 onChanged: (_) =>
//                                     groupController.toggleValve(v.id),
//                                 title: Text(v.name),
//                                 subtitle: Text('OUT - ${v.loraId}'),
//                               ),
//                             ),
//                           ),
//                           ElevatedButton(
//                             onPressed: () {
//                               groupController.submitGroup(
//                                 token: token,
//                                 farmId: farmId,
//                                 onResult: (success) {
//                                   if (success) {
//                                     Get.snackbar(
//                                       "Success",
//                                       "Valve group created",
//                                     );
//                                     nameController.clear();
//                                     groupController.clearForm();
//                                     groupController.fetchGroupedValves(
//                                       token,
//                                     ); // reload
//                                   } else {
//                                     Get.snackbar(
//                                       "Error",
//                                       "Failed to create group",
//                                     );
//                                   }
//                                 },
//                               );
//                             },
//                             child: Text("Create Group"),
//                           ),
//                         ],
//                       )
//                     : SizedBox.shrink(),
//               ),
//             ],
//           ),
//         );
//       }),
//     );
//   }

// }
// valve_group_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfarm/controller/group_valve_controller.dart';
import 'package:smartfarm/controller/valve_controller.dart';
import 'package:smartfarm/model/valve_group_model.dart';

class ValveGroupPage extends StatelessWidget {
  final String token;
  final int farmId;

  ValveGroupPage({super.key, required this.token, required this.farmId});

  final groupController = Get.put(CreateValveGroupController());
  final valveController = Get.put(ValveController());

  @override
  Widget build(BuildContext context) {
    groupController.fetchGroupedValves(token);
    valveController.fetchValves(farmId, token);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Valve Groaups'),
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                groupController.showForm.value ? Icons.close : Icons.add,
              ),
              onPressed: () => groupController.toggleForm(),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (groupController.isLoadingGroups.value ||
            valveController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (groupController.showForm.value) _buildFormSection(),
              const SizedBox(height: 24),
              const Text(
                'Grouped Valves',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...groupController.groupedValves.map(
                (group) => _buildGroupCard(group),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFormSection() {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: "Group Name"),
              onChanged: (value) => groupController.groupName.value = value,
              controller: TextEditingController(
                text: groupController.groupName.value,
              ),
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Select Valves (In)"),
            ),
            Obx(
              () => Column(
                children: valveController.inValves.map((valve) {
                  return CheckboxListTile(
                    title: Text(valve.name),
                    value: groupController.selectedValveIds.contains(valve.id),
                    onChanged: (_) => groupController.toggleValve(valve.id),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Select Valves (Out)"),
            ),
            Obx(
              () => Column(
                children: valveController.outValves.map((valve) {
                  return CheckboxListTile(
                    title: Text(valve.name),
                    value: groupController.selectedValveIds.contains(valve.id),
                    onChanged: (_) => groupController.toggleValve(valve.id),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => ElevatedButton(
                onPressed: groupController.isSubmitting.value
                    ? null
                    : () {
                        if (groupController.editingGroup.value != null) {
                          groupController.updateGroup(
                            token: token,
                            farmId: farmId,
                            onResult: (success) {
                              if (success) {
                                Get.snackbar("Success", "Group updated");
                              } else {
                                Get.snackbar("Error", "Update failed");
                              }
                            },
                          );
                        } else {
                          groupController.submitGroup(
                            token: token,
                            farmId: farmId,
                            onResult: (success) {
                              if (success) {
                                Get.snackbar("Success", "Group created");
                              } else {
                                Get.snackbar("Error", "Creation failed");
                              }
                            },
                          );
                        }
                      },
                child: Text(
                  groupController.editingGroup.value != null
                      ? "Update Group"
                      : "Create Group",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupCard(ValveGroup group) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(group.name),
        subtitle: Text("Valves: ${group.valves.map((v) => v.name).join(', ')}"),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => groupController.startEditingGroup(group),
        ),
      ),
    );
  }
}
