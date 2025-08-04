import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:smartfarm/model/grouped_valve_listing_model.dart';
import 'package:smartfarm/model/motor_model.dart';
import 'package:smartfarm/model/schedule_model.dart';

import 'package:smartfarm/model/valve_list.dart';
import 'package:smartfarm/service/api_service.dart';

class ScheduleController extends GetxController {
  final int farmId;
  final String token;

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

  @override
  void onInit() {
    super.onInit();
    loadAllData();
    fetchSchedules(); 
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

  Future<void> submitSchedule() async {
    if (selectedMotorId.value == null ||
        (selectedValveIds.isEmpty && selectedGroupId.value == null) ||
        startDate.value == null ||
        endDate.value == null ||
        startTime.value == null ||
        endTime.value == null) {
      Get.snackbar("Missing data", "Please fill all required fields");
      return;
    }

    final url = Uri.parse('http://192.168.20.29:8002/api/schedules/');
    final headers = {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };

    final body = json.encode({
      "farm": farmId, //
      "motor": selectedMotorId.value,
      "valves": selectedValveIds.toList(),
      "valve_group": selectedGroupId.value,
      "start_date": startDate.value!.toIso8601String().split('T').first,
      "end_date": endDate.value!.toIso8601String().split('T').first,
      "start_times": [formatTimeOfDay(startTime.value!)],
      "end_times": [formatTimeOfDay(endTime.value!)],
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      Get.snackbar("Success", "Schedule submitted");
    } else {
      Get.snackbar("Error", response.body);
    }
  }

  String formatTimeOfDay(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00";
  }

  // var schedules = <Schedule>[].obs;

  Future<void> fetchSchedules() async {
    try {
      isLoading.value = true;
      final url = Uri.parse(
        'http://192.168.20.29:8002/api/farm-schedule/$farmId/',
      );
      log("$url");
      final headers = {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        schedules.value = data.map((e) => Schedule.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load schedules: ${response.body}');
      }
    } catch (e) {
      print("Error loading schedules: $e");
      Get.snackbar("Error", "Failed to load schedule list");
    } finally {
      isLoading.value = false;
    }
  }
}
