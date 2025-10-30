import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfarm/model/grouped_valve_listing_model.dart';
import 'package:smartfarm/model/motor_model.dart';
import 'package:smartfarm/model/schedule_model.dart';
import 'package:smartfarm/model/valve_list.dart';
import 'package:smartfarm/service/api_service.dart';
import 'package:smartfarm/utils/snackbar_helper.dart' as SnackbarHelper;

class ScheduleController extends GetxController {
  final int farmId;
  final String token;
  final editingScheduleId = RxnInt(); // null = new, int = editing

  // final RxBool showCreateForm = false.obs;

  ScheduleController({required this.farmId, required this.token});

  var isLoading = true.obs;
  var inMotors = <Motor>[].obs;
  var outMotors = <Motor>[].obs;
  var inValves = <ValveGrouping>[].obs;
  var outValves = <ValveGrouping>[].obs;
  var groupedValves = <ValveGroup>[].obs;
  var selectedMotorId = RxnInt();
  var selectedValveIds = <int>{}.obs;
  var selectedGroupId = RxnInt();
  var startDate = Rxn<DateTime>();
  var endDate = Rxn<DateTime>();
  var startTime = Rxn<TimeOfDay>();
  var endTime = Rxn<TimeOfDay>();
  var schedules = <Schedule>[].obs;
  var showCreateForm = false.obs;
  final RxBool isSubmitting = false.obs; // <-- loading flag
  @override
  void onInit() {
    super.onInit();
    loadAllData();
    fetchSchedules();
  }

  void loadScheduleForEditById(int scheduleId) {
    final schedule = schedules.firstWhere((s) => s.id == scheduleId);
    loadScheduleForEdit(schedule); // Reuse your existing method
  }

  Future<void> loadAllData() async {
    try {
      isLoading(true);

      final motorValveMap = await ApiService.fetchMotorsAndValves(
        farmId: farmId,
        token: token,
      );
      inMotors.value = motorValveMap['inMotors']!.cast<Motor>();
      outMotors.value = motorValveMap['outMotors']!.cast<Motor>();

      final valveMap = await ApiService.getGroupedValves(farmId, token);
      inValves.value = valveMap['in']!;
      outValves.value = valveMap['out']!;

      groupedValves.value = await ApiService.getGroupedValveList(token, farmId);
    } catch (e) {
      print("Load error: $e");
    } finally {
      isLoading(false);
    }
  }

  void toggleValveSelection(int valveId) {
    if (selectedValveIds.contains(valveId)) {
      selectedValveIds.remove(valveId);
    } else {
      selectedValveIds.add(valveId);
    }
  }

  void selectGroup(int groupId) {
    selectedGroupId.value = groupId;
    selectedValveIds.clear();
  }

  String formatTimeOfDay(TimeOfDay time) =>
      "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00";

  Future<void> submitSchedule() async {
    if (selectedMotorId.value == null ||
        (selectedValveIds.isEmpty && selectedGroupId.value == null) ||
        startDate.value == null ||
        endDate.value == null ||
        startTime.value == null ||
        endTime.value == null) {
      SnackbarHelper.showThemedSnackbar(
        "Missing data",
        "Please fill all required fields",
      );
      return;
    }

    try {
      final response = await ApiService.submitSchedule(
        token: token,
        farmId: farmId,
        motorId: selectedMotorId.value!,
        valves: selectedValveIds.toList(),
        valveGroupId: selectedGroupId.value,
        startDate: startDate.value!.toIso8601String().split('T').first,
        endDate: endDate.value!.toIso8601String().split('T').first,
        startTime: formatTimeOfDay(startTime.value!),
        endTime: formatTimeOfDay(endTime.value!),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        SnackbarHelper.showThemedSnackbar(
          "Success",
          "Schedule submitted successfully",
          isSuccess: true,
        );
        fetchSchedules(); // Refresh list
      } else {
        SnackbarHelper.showThemedSnackbar(
          "Something went wrong",
          response.body,
        );
      }
    } catch (e) {
      SnackbarHelper.showThemedSnackbar(
        "Something went wrong",
        "Failed to submit schedule: $e",
      );
    }
  }

  Future<void> fetchSchedules() async {
    try {
      isLoading.value = true;
      final list = await ApiService.fetchSchedules(
        farmId: farmId,
        token: token,
      );
      schedules.value = list;
    } catch (e) {
      SnackbarHelper.showThemedSnackbar(
        "Something went wrong",
        "Failed to fetch schedules: $e",
      );
    } finally {
      isLoading.value = false;
    }
  }

  void resetForm() {
    selectedMotorId.value = null;
    selectedGroupId.value = null;
    startDate.value = null;
    endDate.value = null;
    startTime.value = null;
    endTime.value = null;
    selectedValveIds.clear();
    editingScheduleId.value = null;
  }

  Future<void> editSchedule(int scheduleId) async {
    if (selectedMotorId.value == null ||
        (selectedValveIds.isEmpty && selectedGroupId.value == null) ||
        startDate.value == null ||
        endDate.value == null ||
        startTime.value == null ||
        endTime.value == null) {
      SnackbarHelper.showThemedSnackbar(
        "Missing data",
        "Please fill all required fields",
      );
      return;
    }

    try {
      final message = await ApiService.updateSchedule(
        scheduleId: scheduleId,
        token: token, // your auth token
        farmId: farmId, // your selected farm ID
        motorId: selectedMotorId.value!,
        valves: selectedValveIds.toList(),
        valveGroupId: selectedGroupId.value,
        startDate: startDate.value!.toIso8601String().split('T').first,
        endDate: endDate.value!.toIso8601String().split('T').first,
        startTimes: [formatTimeOfDay(startTime.value!)],
        endTimes: [formatTimeOfDay(endTime.value!)],
      );

      SnackbarHelper.showThemedSnackbar("Updated", message);
      await fetchSchedules(); // refresh after update
    } catch (e) {
      SnackbarHelper.showThemedSnackbar("Something went wrong", e.toString());
    }
  }

  void loadScheduleForEdit(Schedule schedule) {
    selectedMotorId.value = schedule.motorId;
    selectedGroupId.value = schedule.valveGroupId;
    // ignore: invalid_use_of_protected_member
    selectedValveIds.value = schedule.valves.toSet();

    startDate.value = DateTime.parse(schedule.startDate);
    endDate.value = DateTime.parse(schedule.endDate);

    final startParts = schedule.startTime.split(":");
    final endParts = schedule.endTime.split(":");

    startTime.value = TimeOfDay(
      hour: int.parse(startParts[0]),
      minute: int.parse(startParts[1]),
    );
    endTime.value = TimeOfDay(
      hour: int.parse(endParts[0]),
      minute: int.parse(endParts[1]),
    );

    editingScheduleId.value = schedule.id;
  }

  Future<void> deleteSchedule(int scheduleId) async {
    try {
      isLoading.value = true;
      final deleted = await ApiService.deleteSchedule(token, scheduleId);

      if (deleted) {
        SnackbarHelper.showThemedSnackbar(
          "Deleted",
          "Schedule deleted successfully",
        );
        await fetchSchedules();
      }
    } catch (e) {
      SnackbarHelper.showThemedSnackbar("Something went wrong", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleSkipStatus(int scheduleId) async {
    try {
      await ApiService.toggleSkipStatus(token: token, scheduleId: scheduleId);
      SnackbarHelper.showThemedSnackbar(
        "Success",
        "Skip status updated successfully",
      );
      await fetchSchedules(); // refresh the list
    } catch (e) {
      SnackbarHelper.showThemedSnackbar("Something went wrong", e.toString());
    }
  }
}
