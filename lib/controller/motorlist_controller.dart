import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfarm/model/motor_model.dart';
import 'package:smartfarm/model/power_supply.dart';
import 'package:smartfarm/model/valves_model.dart';
import 'package:smartfarm/model/grouped_valve_listing_model.dart';
import 'package:smartfarm/service/api_service.dart';

class MotorController extends GetxController {
  var inMotors = <Motor>[].obs;
  var outMotors = <Motor>[].obs;
  var inValves = <Valve>[].obs;
  var outValves = <Valve>[].obs;
  var groupedValves = <ValveGroup>[].obs;
  var groupToggleStates = <int, RxBool>{}.obs;
  var liveData = Rxn<LiveData>();
  var isLiveDataLoading = false.obs;
  Timer? _liveDataTimer;
  var isLoading = false.obs;

  var ungroupedValves = <Valve>[].obs;

  Future<void> fetchMotorsAndValves(int farmId, String token) async {
    isLoading.value = true;

    try {
      final result = await ApiService.fetchMotorsAndValves(
        farmId: farmId,
        token: token,
      );

      inMotors.value = result['inMotors'] as List<Motor>;
      outMotors.value = result['outMotors'] as List<Motor>;
      // outValves.value = result['outValves'] as List<Valve>;
      // inValves.value = result['inValves'] as List<Valve>;

      await fetchGroupedValves(token, farmId);
      await fetchUngroupedValves(token, farmId);
    } catch (e) {
      Get.snackbar("Something went wrong", "Failed to fetch motors and valves");
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
      final message = await ApiService.controlMotor(
        motorId: motorId,
        status: status,
        token: token,
      );

      // update locally without re-fetching
      final motor =
          inMotors.firstWhereOrNull((m) => m.id == motorId) ??
          outMotors.firstWhereOrNull((m) => m.id == motorId);
      if (motor != null) {
        motor.status.value = status;
      }

      Get.snackbar("Success", message,  colorText: Colors.green.shade800,
      snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("Something went wrong", "Failed to toggle motor",colorText: Colors.red.shade800,snackPosition: SnackPosition.BOTTOM);
    }
  }

  var isLoadingGroups = false.obs;

  //fetch grouped valves

  Future<void> fetchGroupedValves(String token, int farmId) async {
    isLoadingGroups.value = true;
    try {
      final groups = await ApiService.getGroupedValveList(token, farmId);
      groupedValves.value = groups;

      for (var group in groups) {
        groupToggleStates[group.id] = RxBool(
          group.isOn,
        ); // assuming isOn maps to `is_on`
      }
    } catch (e) {
      Get.snackbar("Something went wrong", "Failed to load grouped valves",colorText: Colors.red.shade800,snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingGroups.value = false;
    }
  }

  //Group Valve Control

  Future<void> toggleValveGroup({
    required int groupId,
    required String token,
    required int farmId, // Add farmId as required
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

      await fetchGroupedValves(token, farmId); // ✅ Fix: pass farmId here
      Get.snackbar("Success", msg);
    } catch (e) {
      Get.snackbar("Something went wrong", "Failed to toggle valve group");
    } finally {
      isLoadingGroups.value = false;
    }
  }

  //fetch individual ungrouped valve

  Future<void> fetchUngroupedValves(String token, int farmId) async {
    try {
      final valves = await ApiService.getUngroupedValves(token, farmId);
      ungroupedValves.value = valves;
    } catch (e) {
      Get.snackbar("Something went wrong", "Failed to fetch ungrouped valves");
    }
  }
  // individual Valve Control

  Future<void> toggleValve({
    required int valveId,
    required String status, // "ON" or "OFF"
    required String token,
    required int farmId,
  }) async {
    try {
      // isLoading.value = true;

      final message = await ApiService.controlIndividualValve(
        valveId: valveId,
        status: status,
        token: token,
      );

      // Refresh valve data
      await fetchGroupedValves(token, farmId);
      await fetchUngroupedValves(token, farmId);

      Get.snackbar("Success", message);
    } catch (e) {
      Get.snackbar("Something went wrong", "Failed to toggle valve");
      print("Something went wrong: $e");
    } finally {
      isLoading.value = false;
    }
  }

  //powersupply

  Future<void> fetchLiveData(String token, int farmId) async {
    try {
      isLiveDataLoading.value = true;
      final data = await ApiService.getLiveData(token, farmId);
      liveData.value = data;
    } catch (e) {
      print("Live data fetch error: $e");
    } finally {
      isLiveDataLoading.value = false;
    }
  }

  void startLiveDataUpdates(String token, int farmId, {Duration interval = const Duration(seconds: 5)}) {
    // Stop any existing timer first
    _liveDataTimer?.cancel();

    // Start periodic updates
    _liveDataTimer = Timer.periodic(interval, (_) {
      fetchLiveData(token, farmId);
    });

    // Initial fetch right away
    fetchLiveData(token, farmId);
  }

  void stopLiveDataUpdates() {
    _liveDataTimer?.cancel();
    _liveDataTimer = null;
  }

  @override
  void onClose() {
    stopLiveDataUpdates();
    super.onClose();
  }
}
