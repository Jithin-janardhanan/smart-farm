// import 'package:get/get.dart';
// import 'package:smartfarm/service/api_service.dart';

// import '../model/valve_group_model.dart';

// class ValveGroupListController extends GetxController {
//   var groupName = ''.obs;
//   var selectedValveIds = <int>{}.obs;
//   var isSubmitting = false.obs;
//   var showForm = false.obs;

//   var groupedValves = <ValveGroup>[].obs;
//   var isLoadingGroups = false.obs;

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

//   void toggleForm() {
//     showForm.toggle();
//   }

//   // Submit logic remains same
// }
