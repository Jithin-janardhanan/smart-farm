// //fetch grouped valve and create new valve group

// import 'package:get/get.dart';
// import '../model/valve_group_model.dart';
// import '../model/valve_group_request.dart';
// import '../service/api_service.dart';

// class CreateValveGroupController extends GetxController {
//   var groupName = ''.obs;
//   var selectedValveIds = <int>{}.obs;
//   var isSubmitting = false.obs;
//   var isLoadingGroups = false.obs;
//   var showForm = false.obs; // ✅ this line is required

//   var groupedValves = <ValveGroup>[].obs;

//   Future<void> fetchGroupedValves(String token) async {
//     isLoadingGroups.value = true;
//     try {
//       final groups = await ApiService.getGroupedValveList(token);
//       groupedValves.value = groups;
//     } catch (e) {
//       print("Fetch group error: $e");
//     }
//     isLoadingGroups.value = false;
//   }

//   Future<void> submitGroup({
//     required String token,
//     required int farmId,
//     required void Function(bool success) onResult,
//   }) async {
//     if (groupName.value.isEmpty || selectedValveIds.isEmpty) {
//       onResult(false);
//       return;
//     }

//     isSubmitting.value = true;

//     final request = ValveGroupRequest(
//       farm: farmId,
//       name: groupName.value,
//       valveIds: selectedValveIds.toList(),
//     );

//     try {
//       await ApiService.createValveGroup(token, request);
//       onResult(true);
//     } catch (e) {
//       print("Create Group Error: $e");
//       onResult(false);
//     }

//     isSubmitting.value = false;
//   }

//   void toggleValve(int id) {
//     if (selectedValveIds.contains(id)) {
//       selectedValveIds.remove(id);
//     } else {
//       selectedValveIds.add(id);
//     }
//   }

//   void clearForm() {
//     groupName.value = '';
//     selectedValveIds.clear();
//   }

//   void toggleForm() {
//     showForm.toggle(); // ✅ works only if showForm is defined
//   }

// }
// create_valve_group_controller.dart
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:smartfarm/model/grouped_valve_listing_model.dart';
import 'package:smartfarm/model/create_group.dart';
import '../service/api_service.dart';

class CreateValveGroupController extends GetxController {
  var groupedValves = <ValveGroup>[].obs;

  var groupName = ''.obs;
  var selectedValveIds = <int>{}.obs;
  late TextEditingController groupNameController;

  var isSubmitting = false.obs;
  var isLoadingGroups = false.obs;
  var showForm = false.obs;

  var editingGroup = Rxn<ValveGroup>();
 @override
  void onInit() {
    super.onInit();
    groupNameController = TextEditingController();

    // Keep the observable in sync with the controller's text
    groupNameController.addListener(() {
      groupName.value = groupNameController.text;
    });
  }

  

  // Fetch list
  Future<void> fetchGroupedValves(String token, int farmId) async {
    isLoadingGroups.value = true;
    try {
      final groups = await ApiService.getGroupedValveList(token, farmId);
      groupedValves.value = groups;
    } catch (e) {
      print("Fetch group error: $e");
    } finally {
      isLoadingGroups.value = false;
    }
  }

  // Submit (create)
  Future<void> submitGroup({
    required String token,
    required int farmId,
    required void Function(bool success) onResult,
  }) async {
    if (groupName.value.isEmpty || selectedValveIds.isEmpty) {
      onResult(false);
      return;
    }

    isSubmitting.value = true;

    final request = ValveGroupRequest(
      farm: farmId,
      name: groupName.value,
      valveIds: selectedValveIds.toList(),
    );

    try {
      final created = await ApiService.createValveGroup(token, request);
      if (created) {
        await fetchGroupedValves(token, farmId);

        clearForm();
      }
      onResult(created);
    } catch (e) {
     
      onResult(false);
    }

    isSubmitting.value = false;
  }

  Future<void> deleteGroup({
    required String token,
    required int groupId,
    required int farmId,
    required void Function(bool success) onResult,
  }) async {
    isSubmitting.value = true;
    try {
      final success = await ApiService.deleteValveGroup(
        token: token,
        groupId: groupId,
      );
      if (success) {
        await fetchGroupedValves(token, farmId);
      }
      onResult(success);
    } catch (e) {
     
      onResult(false);
    }
    isSubmitting.value = false;
  }

  // Update (edit existing)
  Future<void> updateGroup({
    required String token,
    required int farmId,
    required void Function(bool success) onResult,
  }) async {
    final group = editingGroup.value;
    if (group == null || groupName.value.isEmpty || selectedValveIds.isEmpty) {
      onResult(false);
      return;
    }

    isSubmitting.value = true;

    try {
      final success = await ApiService.updateValveGroup(
        token: token,
        groupId: group.id,
        farmId: farmId,
        name: groupName.value,
        valveIds: selectedValveIds.toList(),
      );

      if (success) {
        await fetchGroupedValves(token, farmId);

        clearForm();
      }

      onResult(success);
    } catch (e) {
      debugPrint("Update Group Error: $e");
      onResult(false);
    }

    isSubmitting.value = false;
  }

  // Edit mode
   void startEditingGroup(ValveGroup group) {
    editingGroup.value = group;
    groupName.value = group.name;
    groupNameController.text = group.name; // <-- prefill
    selectedValveIds.value = group.valves.map((v) => v.id).toSet();
    showForm.value = true;
  }

   void clearForm() {
    groupName.value = '';
    groupNameController.clear(); // <-- clear controller text
    selectedValveIds.clear();
    editingGroup.value = null;
    showForm.value = false;
  }

  void toggleForm() {
    showForm.toggle();
    if (!showForm.value) clearForm();
  }

  void toggleValve(int id) {
    if (selectedValveIds.contains(id)) {
      selectedValveIds.remove(id);
    } else {
      selectedValveIds.add(id);
    }
  }
}
