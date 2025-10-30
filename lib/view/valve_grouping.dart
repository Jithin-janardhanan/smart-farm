import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfarm/controller/group_valve_controller.dart';
import 'package:smartfarm/controller/valve_controller.dart';
import 'package:smartfarm/model/grouped_valve_listing_model.dart';
import 'package:smartfarm/utils/snackbar_helper.dart';

class ValveGroupPage extends StatelessWidget {
  final String token;
  final int farmId;

  ValveGroupPage({super.key, required this.token, required this.farmId});

  final groupController = Get.put(CreateValveGroupController());
  final valveController = Get.put(ValveController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    groupController.fetchGroupedValves(token, farmId);
    valveController.fetchValves(farmId, token);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Valve Groups',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.primary,
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
                      ? colorScheme.errorContainer.withOpacity(0.3)
                      : colorScheme.primaryContainer.withOpacity(0.3),
                  foregroundColor: groupController.showForm.value
                      ? colorScheme.error
                      : colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (groupController.isLoadingGroups.value ||
            valveController.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  'Loading valve groups...',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
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
                      ? _buildFormSection(context)
                      : const SizedBox(),
                ),

                // Groups List Header
                Row(
                  children: [
                    Icon(
                      Icons.widgets_outlined,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Your Groups',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${groupController.groupedValves.length}',
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (groupController.groupedValves.isEmpty)
                  _buildEmptyState(context)
                else
                  ...groupController.groupedValves.map(
                    (group) => _buildGroupCard(context, group),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFormSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
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
                Icon(Icons.create_outlined, color: colorScheme.primary),
                const SizedBox(width: 8),
                Obx(
                  () => Text(
                    groupController.editingGroup.value != null
                        ? 'Edit Group'
                        : 'Create New Group',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
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
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: colorScheme.outline.withOpacity(0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                prefixIcon: Icon(
                  Icons.label_outline,
                  color: colorScheme.onSurfaceVariant,
                ),
                filled: true,
                fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Valve Selection
            _buildValveSelection(context),

            const SizedBox(height: 24),

            // Submit Button
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: groupController.isSubmitting.value
                      ? null
                      : () => _handleSubmit(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: groupController.isSubmitting.value
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: colorScheme.onPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          groupController.editingGroup.value != null
                              ? 'Update Group'
                              : 'Create Group',
                          style: textTheme.labelLarge?.copyWith(
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

  Widget _buildValveSelection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Valves',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),

        // In Valves
        if (valveController.inValves.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.primary.withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.input, size: 16, color: colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Inlet Valves',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
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
                        .map((valve) => _buildValveChip(context, valve))
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
              color: colorScheme.secondaryContainer.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.secondary.withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.output, size: 16, color: colorScheme.secondary),
                    const SizedBox(width: 4),
                    Text(
                      'Outlet Valves',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.secondary,
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
                        .map((valve) => _buildValveChip(context, valve))
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

  Widget _buildValveChip(BuildContext context, dynamic valve) {
    final colorScheme = Theme.of(context).colorScheme;
    return Obx(
      () => FilterChip(
        label: Text(valve.name),
        selected: groupController.selectedValveIds.contains(valve.id),
        onSelected: (_) => groupController.toggleValve(valve.id),
        selectedColor: colorScheme.primaryContainer,
        checkmarkColor: colorScheme.primary,
        backgroundColor: colorScheme.surfaceVariant.withOpacity(0.3),
        labelStyle: TextStyle(
          color: groupController.selectedValveIds.contains(valve.id)
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurfaceVariant,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: groupController.selectedValveIds.contains(valve.id)
                ? colorScheme.primary
                : colorScheme.outline.withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, ValveGroup group) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
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
                    color: colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.widgets,
                    color: colorScheme.primary,
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
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${group.valves.length} valve${group.valves.length == 1 ? '' : 's'}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      groupController.startEditingGroup(group);
                    } else if (value == 'delete') {
                      _showDeleteDialog(context, group);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text('Edit', style: textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: colorScheme.error),
                          const SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: TextStyle(color: colorScheme.error),
                          ),
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
                          color: colorScheme.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          valve.name,
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
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

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.widgets_outlined,
            size: 64,
            color: colorScheme.outline.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No valve groups yet',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first group to organize your valves',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: () => groupController.showForm.value = true,
            icon: Icon(Icons.add, color: colorScheme.primary),
            label: Text(
              'Create Group',
              style: TextStyle(color: colorScheme.primary),
            ),
            style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
          ),
        ],
      ),
    );
  }

  void _handleSubmit(BuildContext context) {
    if (groupController.editingGroup.value != null) {
      groupController.updateGroup(
        token: token,
        farmId: farmId,
        onResult: (success) {
          if (success) {
            showThemedSnackbar(
              'Success',
              'Group updated successfully',
              isSuccess: true,
            );
          } else {
            showThemedSnackbar(
              'Error',
              'Failed to update group',
              isError: true,
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
            showThemedSnackbar(
              'Success',
              'Group created successfully',
              isSuccess: true,
            );
          } else {
            showThemedSnackbar(
              'Error',
              'Failed to create group',
              isError: true,
            );
          }
        },
      );
    }
  }

  void _showDeleteDialog(BuildContext context, ValveGroup group) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: colorScheme.surface,
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: colorScheme.error),
            const SizedBox(width: 8),
            Text('Delete Group', style: textTheme.titleMedium),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${group.name}"? This action cannot be undone.',
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              groupController.deleteGroup(
                token: token,
                groupId: group.id,
                farmId: farmId,
                onResult: (success) {
                  Get.back(); // Close dialog first
                  if (success) {
                    showThemedSnackbar(
                      'Deleted',
                      'Group removed successfully',
                      isSuccess: true,
                    );
                  } else {
                    showThemedSnackbar(
                      'Error',
                      'Failed to delete group',
                      isError: true,
                    );
                  }
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
