

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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Valve Groups',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.green[700],
        elevation: 0.5,
        actions: [
          Obx(
            () => Container(
              margin: const EdgeInsets.only(right: 16),
              child: IconButton.filled(
                icon: Icon(
                  groupController.showForm.value ? Icons.close : Icons.add,
                  size: 22,
                ),
                onPressed: () => groupController.toggleForm(),
                style: IconButton.styleFrom(
                  backgroundColor: groupController.showForm.value
                      ? Colors.red[100]
                      : Colors.green[100],
                  foregroundColor: groupController.showForm.value
                      ? Colors.red[700]
                      : Colors.green[700],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (groupController.isLoadingGroups.value ||
            valveController.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Loading valve groups...',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await groupController.fetchGroupedValves(token, farmId);
            await valveController.fetchValves(farmId, token);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Form Section
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: groupController.showForm.value ? null : 0,
                  child: groupController.showForm.value
                      ? _buildFormSection()
                      : const SizedBox(),
                ),

                // Groups List
                Row(
                  children: [
                    Icon(Icons.widgets_outlined, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    const Text(
                      'Your Groups',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${groupController.groupedValves.length}',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (groupController.groupedValves.isEmpty)
                  _buildEmptyState()
                else
                  ...groupController.groupedValves.map(
                    (group) => _buildGroupCard(group),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFormSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.create_outlined, color: Colors.green[700]),
                const SizedBox(width: 8),
                Obx(
                  () => Text(
                    groupController.editingGroup.value != null
                        ? 'Edit Group'
                        : 'Create New Group',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Group Name Input
            TextField(
              controller: groupController.groupNameController,
              decoration: InputDecoration(
                labelText: 'Group Name',
                hintText: 'Enter a name for your valve group',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.label_outline),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),

            const SizedBox(height: 20),

            // Valve Selection
            _buildValveSelection(),

            const SizedBox(height: 24),

            // Submit Button
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: groupController.isSubmitting.value
                      ? null
                      : () => _handleSubmit(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: groupController.isSubmitting.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          groupController.editingGroup.value != null
                              ? 'Update Group'
                              : 'Create Group',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValveSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Valves',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        // In Valves
        if (valveController.inValves.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.input, size: 16, color: Colors.green[700]),
                    const SizedBox(width: 4),
                    Text(
                      'Inlet Valves',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: valveController.inValves
                        .map((valve) => _buildValveChip(valve))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Out Valves
        if (valveController.outValves.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.output, size: 16, color: Colors.orange[700]),
                    const SizedBox(width: 4),
                    Text(
                      'Outlet Valves',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: valveController.outValves
                        .map((valve) => _buildValveChip(valve))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildValveChip(valve) {
    return Obx(
      () => FilterChip(
        label: Text(valve.name),
        selected: groupController.selectedValveIds.contains(valve.id),
        onSelected: (_) => groupController.toggleValve(valve.id),
        selectedColor: Colors.blue[100],
        checkmarkColor: Colors.blue[700],
      ),
    );
  }

  Widget _buildGroupCard(ValveGroup group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.widgets,
                    color: Colors.green[700],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${group.valves.length} valve${group.valves.length == 1 ? '' : 's'}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                  onSelected: (value) {
                    if (value == 'edit') {
                      groupController.startEditingGroup(group);
                    } else if (value == 'delete') {
                      _showDeleteDialog(group);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (group.valves.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: group.valves
                    .map(
                      (valve) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          valve.name,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.widgets_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No valve groups yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first group to organize your valves',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: () => groupController.showForm.value = true,
            icon: const Icon(Icons.add),
            label: const Text('Create Group'),
          ),
        ],
      ),
    );
  }

  void _handleSubmit() {
    if (groupController.editingGroup.value != null) {
      groupController.updateGroup(
        token: token,
        farmId: farmId,
        onResult: (success) {
          if (success) {
            Get.snackbar(
              'Success',
              'Group updated successfully',
              backgroundColor: Colors.green[100],
              colorText: Colors.green[800],
              snackPosition: SnackPosition.TOP,
            );
          } else {
            Get.snackbar(
              'Error',
              'Failed to update group',
              backgroundColor: Colors.red[100],
              colorText: Colors.red[800],
              snackPosition: SnackPosition.TOP,
            );
          }
        },
      );
    } else {
      groupController.submitGroup(
        token: token,
        farmId: farmId,
        onResult: (success) {
          if (success) {
            Get.snackbar(
              'Success',
              'Group created successfully',
              backgroundColor: Colors.green[100],
              colorText: Colors.green[800],
              snackPosition: SnackPosition.TOP,
            );
          } else {
            Get.snackbar(
              'Error',
              'Failed to create group',
              backgroundColor: Colors.red[100],
              colorText: Colors.red[800],
              snackPosition: SnackPosition.TOP,
            );
          }
        },
      );
    }
  }

  void _showDeleteDialog(ValveGroup group) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Delete Group'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${group.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              groupController.deleteGroup(
                token: token,
                groupId: group.id,
                farmId: farmId,
                onResult: (success) {
                  Get.back(); // Close dialog
                  if (success) {
                    Get.snackbar(
                      'Deleted',
                      'Group removed successfully',
                      backgroundColor: Colors.green[100],
                      colorText: Colors.green[800],
                      snackPosition: SnackPosition.TOP,
                    );
                  } else {
                    Get.snackbar(
                      'Error',
                      'Failed to delete group',
                      backgroundColor: Colors.red[100],
                      colorText: Colors.red[800],
                      snackPosition: SnackPosition.TOP,
                    );
                  }
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
