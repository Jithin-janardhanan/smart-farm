// import 'package:get/get.dart';
// import 'package:smartfarm/model/motor_model.dart';
// import 'package:smartfarm/model/vales_model.dart';

// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class MotorController extends GetxController {
//   var inMotors = <Motor>[].obs;
//   var outMotors = <Motor>[].obs;
//   var inValves = <Valve>[].obs;
//   var outValves = <Valve>[].obs;
//   var isLoading = false.obs;

//   Future<void> fetchMotorsAndValves(int farmId, String token) async {
//     isLoading.value = true;

//     final url = 'http://192.168.20.29:8002/api/farms/$farmId/motors/';
//     var headers = {
//       'Authorization': 'Token $token',
//       'Content-Type': 'application/json',
//     };

//     final response = await http.get(Uri.parse(url), headers: headers);

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       inMotors.value = List<Motor>.from(
//         data['motors']['in'].map((m) => Motor.fromJson(m)),
//       );
//       outMotors.value = List<Motor>.from(
//         data['motors']['out'].map((m) => Motor.fromJson(m)),
//       );
//       inValves.value = List<Valve>.from(
//         data['valves']['in'].map((v) => Valve.fromJson(v)),
//       );
//       outValves.value = List<Valve>.from(
//         data['valves']['out'].map((v) => Valve.fromJson(v)),
//       );
//     } else {

//     }

//     isLoading.value = false;
//   }
// }
import 'package:get/get.dart';
import 'package:smartfarm/model/motor_model.dart';
import 'package:smartfarm/model/vales_model.dart';
import 'package:smartfarm/model/valve_group_model.dart';
import 'package:smartfarm/service/api_service.dart';

class MotorController extends GetxController {
  var inMotors = <Motor>[].obs;
  var outMotors = <Motor>[].obs;
  var inValves = <Valve>[].obs;
  var outValves = <Valve>[].obs;
  var groupedValves = <ValveGroup>[].obs;
  var groupToggleStates = <int, RxBool>{}.obs;

  var isLoading = false.obs;

  Future<void> fetchMotorsAndValves(int farmId, String token) async {
    isLoading.value = true;

    try {
      final result = await ApiService.fetchMotorsAndValves(
        farmId: farmId,
        token: token,
      );

      inMotors.value = result['inMotors'] as List<Motor>;
      outMotors.value = result['outMotors'] as List<Motor>;
      inValves.value = result['inValves'] as List<Valve>;
      outValves.value = result['outValves'] as List<Valve>;

      await fetchGroupedValves(token);
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch motors and valves");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleMotor({
    required int motorId,
    required String status,
    required int farmId,
    required String token,
  }) async {
    try {
      isLoading.value = true;
      String message = await ApiService.controlMotor(
        motorId: motorId,
        status: status,
        token: token,
      );

      // Refresh the motor list to reflect new status
      await fetchMotorsAndValves(farmId, token);
      Get.snackbar("Success", message);
    } catch (e) {
      Get.snackbar("Error", "Failed to toggle motor");
    } finally {
      isLoading.value = false;
    }
  }

  var isLoadingGroups = false.obs;

  Future<void> fetchGroupedValves(String token) async {
    isLoadingGroups.value = true;
    try {
      final groups = await ApiService.getGroupedValveList(token);
      groupedValves.value = groups;

      // Set up toggle states
      for (var group in groups) {
        final isGroupOn = group.valves.any((v) => v.status == "ON");
        groupToggleStates[group.id] = RxBool(isGroupOn);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load grouped valves");
    } finally {
      isLoadingGroups.value = false;
    }
  }

  //Group Valve Control
  Future<void> toggleValveGroup({
    required int groupId,
    required String token,
  }) async {
    final currentStatus = groupToggleStates[groupId]?.value ?? false;
    final newStatus = currentStatus ? "OFF" : "ON";

    try {
      isLoadingGroups.value = true;
      final msg = await ApiService.controlValveGroup(
        groupId: groupId,
        status: newStatus,
        token: token,
      );

      await fetchGroupedValves(token); // Refresh valves
      Get.snackbar("Success", msg);
    } catch (e) {
      Get.snackbar("Error", "Failed to toggle group valves");
    } finally {
      isLoadingGroups.value = false;
    }
  }
}
