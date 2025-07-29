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
import 'package:get/get.dart';
import 'package:smartfarm/model/valve_group_model.dart';
import 'package:smartfarm/model/valve_group_request.dart';
import '../service/api_service.dart';

class CreateValveGroupController extends GetxController {
  var groupedValves = <ValveGroup>[].obs;

  var groupName = ''.obs;
  var selectedValveIds = <int>{}.obs;

  var isSubmitting = false.obs;
  var isLoadingGroups = false.obs;
  var showForm = false.obs;

  var editingGroup = Rxn<ValveGroup>();

  // Fetch list
  Future<void> fetchGroupedValves(String token) async {
    isLoadingGroups.value = true;
    try {
      final groups = await ApiService.getGroupedValveList(token);
      groupedValves.value = groups;
    } catch (e) {
      print("Fetch group error: $e");
    }
    isLoadingGroups.value = false;
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
        await fetchGroupedValves(token);
        clearForm();
      }
      onResult(created);
    } catch (e) {
      print("Create Group Error: $e");
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
        await fetchGroupedValves(token);
        clearForm();
      }

      onResult(success);
    } catch (e) {
      print("Update Group Error: $e");
      onResult(false);
    }

    isSubmitting.value = false;
  }

  // Edit mode
  void startEditingGroup(ValveGroup group) {
    editingGroup.value = group;
    groupName.value = group.name;
    selectedValveIds.value = group.valves.map((v) => v.id).toSet();
    showForm.value = true;
  }

  void clearForm() {
    groupName.value = '';
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
