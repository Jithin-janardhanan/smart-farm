import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfarm/controller/group_valve_controller.dart';
import 'package:smartfarm/controller/valve_controller.dart';
import 'package:smartfarm/model/colors_model.dart';
import 'package:smartfarm/model/grouped_valve_listing_model.dart';

class ValveGroupPage extends StatelessWidget {
  final String token;
  final int farmId;

  ValveGroupPage({super.key, required this.token, required this.farmId});

  final groupController = Get.put(CreateValveGroupController());
  final valveController = Get.put(ValveController());

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subTextColor = isDark
        ? AppColors.darkSubText
        : AppColors.lightSubText;
    final primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    groupController.fetchGroupedValves(token, farmId);
    valveController.fetchValves(farmId, token);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Valve Groups',
          style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
        ),
        backgroundColor: surfaceColor,
        foregroundColor: primaryColor,
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
                      ? AppColors.errorRed.withOpacity(0.15)
                      : primaryColor.withOpacity(0.15),
                  foregroundColor: groupController.showForm.value
                      ? AppColors.errorRed
                      : primaryColor,
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
          color: primaryColor,
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
                // 🌿 Form Section
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: groupController.showForm.value ? null : 0,
                  child: groupController.showForm.value
                      ? _buildFormSection(
                          surfaceColor,
                          textColor,
                          primaryColor,
                          subTextColor,
                        )
                      : const SizedBox(),
                ),

                // 🌿 Groups List Header
                Row(
                  children: [
                    Icon(Icons.widgets_outlined, color: subTextColor),
                    const SizedBox(width: 8),
                    Text(
                      'Your Groups',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${groupController.groupedValves.length}',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (groupController.groupedValves.isEmpty)
                  _buildEmptyState(primaryColor, subTextColor)
                else
                  ...groupController.groupedValves.map(
                    (group) => _buildGroupCard(
                      group,
                      surfaceColor,
                      textColor,
                      subTextColor,
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFormSection(
    Color surfaceColor,
    Color textColor,
    Color primaryColor,
    Color subTextColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.greenGlow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.create_outlined, color: primaryColor),
                const SizedBox(width: 8),
                Obx(
                  () => Text(
                    groupController.editingGroup.value != null
                        ? 'Edit Group'
                        : 'Create New Group',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Group Name Input
            TextField(
              controller: groupController.groupNameController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Group Name',
                labelStyle: TextStyle(color: subTextColor),
                hintText: 'Enter a name for your valve group',
                hintStyle: TextStyle(color: subTextColor.withOpacity(0.6)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.label_outline, color: primaryColor),
                filled: true,
                fillColor: surfaceColor.withOpacity(0.9),
              ),
            ),

            const SizedBox(height: 20),

            // Valve Selection
            _buildValveSelection(primaryColor, subTextColor),

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
                    backgroundColor: primaryColor,
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

  Widget _buildValveSelection(Color primaryColor, Color subTextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Valves',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: subTextColor,
          ),
        ),
        const SizedBox(height: 12),
        if (valveController.inValves.isNotEmpty) ...[
          _buildValveSection(
            title: 'Inlet Valves',
            icon: Icons.input,
            valves: valveController.inValves,
            color: primaryColor,
          ),
          const SizedBox(height: 12),
        ],
        if (valveController.outValves.isNotEmpty) ...[
          _buildValveSection(
            title: 'Outlet Valves',
            icon: Icons.output,
            valves: valveController.outValves,
            color: Colors.orange,
          ),
        ],
      ],
    );
  }

  Widget _buildValveSection({
    required String title,
    required IconData icon,
    required List valves,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.w500, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: valves
                  .map((valve) => _buildValveChip(valve, color))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValveChip(valve, Color color) {
    return Obx(
      () => FilterChip(
        label: Text(valve.name),
        selected: groupController.selectedValveIds.contains(valve.id),
        onSelected: (_) => groupController.toggleValve(valve.id),
        selectedColor: color.withOpacity(0.2),
        checkmarkColor: color,
      ),
    );
  }

  Widget _buildGroupCard(
    ValveGroup group,
    Color surfaceColor,
    Color textColor,
    Color subTextColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.greenGlow,
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
                    color: AppColors.lightPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.widgets,
                    color: AppColors.lightPrimary,
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${group.valves.length} valve${group.valves.length == 1 ? '' : 's'}',
                        style: TextStyle(color: subTextColor, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: subTextColor),
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
                          color: AppColors.lightPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          valve.name,
                          style: TextStyle(fontSize: 12, color: subTextColor),
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

  Widget _buildEmptyState(Color primaryColor, Color subTextColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.widgets_outlined, size: 64, color: subTextColor),
          const SizedBox(height: 16),
          Text(
            'No valve groups yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: subTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first group to organize your valves',
            textAlign: TextAlign.center,
            style: TextStyle(color: subTextColor.withOpacity(0.8)),
          ),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: () => groupController.showForm.value = true,
            icon: const Icon(Icons.add),
            label: const Text('Create Group'),
            style: TextButton.styleFrom(foregroundColor: primaryColor),
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
          Get.snackbar(
            success ? 'Success' : 'Error',
            success ? 'Group updated successfully' : 'Failed to update group',
            backgroundColor: success
                ? AppColors.successGreen.withOpacity(0.2)
                : AppColors.errorRed.withOpacity(0.2),
            colorText: success ? Colors.green[800] : Colors.red[800],
            snackPosition: SnackPosition.TOP,
          );
        },
      );
    } else {
      groupController.submitGroup(
        token: token,
        farmId: farmId,
        onResult: (success) {
          Get.snackbar(
            success ? 'Success' : 'Error',
            success ? 'Group created successfully' : 'Failed to create group',
            backgroundColor: success
                ? AppColors.successGreen.withOpacity(0.2)
                : AppColors.errorRed.withOpacity(0.2),
            colorText: success ? Colors.green[800] : Colors.red[800],
            snackPosition: SnackPosition.TOP,
          );
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
                  Get.back();
                  Get.snackbar(
                    success ? 'Deleted' : 'Error',
                    success
                        ? 'Group removed successfully'
                        : 'Failed to delete group',
                    backgroundColor: success
                        ? AppColors.successGreen.withOpacity(0.2)
                        : AppColors.errorRed.withOpacity(0.2),
                    colorText: success ? Colors.green[800] : Colors.red[800],
                    snackPosition: SnackPosition.TOP,
                  );
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
