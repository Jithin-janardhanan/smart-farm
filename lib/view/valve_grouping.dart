// valve_group_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfarm/controller/group_valve_controller.dart';
import 'package:smartfarm/controller/valve_controller.dart';
import 'package:smartfarm/model/grouped_valve_listing_model.dart';

class ValveGroupPage extends StatelessWidget {
  final String token;
  final int farmId;

  ValveGroupPage({super.key, required this.token, required this.farmId});

  final groupController = Get.put(CreateValveGroupController());
  final valveController = Get.put(ValveController());

  @override
  Widget build(BuildContext context) {
    groupController.fetchGroupedValves(token, farmId);

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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => groupController.startEditingGroup(group),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                Get.defaultDialog(
                  title: "Delete Group",
                  middleText:
                      "Are you sure you want to delete '${group.name}'?",
                  textConfirm: "Yes",
                  textCancel: "No",
                  confirmTextColor: Colors.white,
                  onConfirm: () {
                    groupController.deleteGroup(
                      token: token,
                      groupId: group.id,
                      farmId: farmId,
                      onResult: (success) {
                        if (success) {
                          Get.back(); // close dialog
                          Get.snackbar("Deleted", "Group removed successfully");
                        } else {
                          Get.snackbar("Error", "Failed to delete group");
                        }
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
