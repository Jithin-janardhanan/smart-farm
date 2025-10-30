import 'dart:async';
import 'package:get/get.dart';
import 'package:smartfarm/model/motor_model.dart';
import 'package:smartfarm/model/power_supply.dart';
import 'package:smartfarm/model/telemetry_data.model.dart';
import 'package:smartfarm/model/valves_model.dart';
import 'package:smartfarm/model/grouped_valve_listing_model.dart';
import 'package:smartfarm/service/api_service.dart';
import 'package:smartfarm/utils/snackbar_helper.dart'; // 👈 Import your reusable snackbar

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

  var motorLoading = <int, RxBool>{}.obs;
  var valveLoading = <int, RxBool>{}.obs;
  var groupLoading = <int, RxBool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Map) {
      final token = args['token'];
      final farmId = args['farmId'];

      if (token != null && farmId != null) {
        _initData(token, farmId);
      } else {
        print("⚠️ Token or Farm ID missing in Get.arguments");
      }
    } else {
      print("⚠️ No arguments passed to MotorController");
    }
  }

  Future<void> _initData(String token, int farmId) async {
    isLoading.value = true;
    try {
      await fetchMotorsAndValves(farmId, token);
      await fetchTelemetryData(token, farmId);
      await fetchLiveData(token, farmId);
      startLiveDataUpdates(token, farmId);
    } catch (e) {
      showThemedSnackbar(
        "Initialization Failed",
        "Error while loading farm data",
        isError: true,
      );
      print("Initialization error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMotorsAndValves(int farmId, String token) async {
    isLoading.value = true;
    try {
      final result = await ApiService.fetchMotorsAndValves(
        farmId: farmId,
        token: token,
      );

      inMotors.value = result['inMotors'] as List<Motor>;
      outMotors.value = result['outMotors'] as List<Motor>;

      await fetchGroupedValves(token, farmId);
      await fetchUngroupedValves(token, farmId);
    } catch (e) {
      showThemedSnackbar(
        "Something went wrong",
        "Failed to fetch motors and valves",
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllData(String token, int farmId) async {
    isLoading.value = true;
    try {
      await Future.wait([
        fetchLiveData(token, farmId),
        fetchMotorsAndValves(farmId, token),
        fetchTelemetryData(token, farmId),
      ]);
    } catch (e) {
      showThemedSnackbar("Oops", "Failed to refresh farm data", isError: true);
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
    motorLoading[motorId] = true.obs;
    try {
      final message = await ApiService.controlMotor(
        motorId: motorId,
        status: status,
        token: token,
      );

      final motor =
          inMotors.firstWhereOrNull((m) => m.id == motorId) ??
          outMotors.firstWhereOrNull((m) => m.id == motorId);

      if (motor != null) motor.status.value = status;

      showThemedSnackbar("Success", message, isSuccess: true);
    } catch (e) {
      showThemedSnackbar(
        "Oops",
        e.toString().replaceFirst("Exception: ", ""),
        isError: true,
      );
    } finally {
      motorLoading[motorId]?.value = false;
    }
  }

  var isLoadingGroups = false.obs;

  Future<void> fetchGroupedValves(String token, int farmId) async {
    isLoadingGroups.value = true;
    try {
      final groups = await ApiService.getGroupedValveList(token, farmId);
      groupedValves.value = groups;

      for (var group in groups) {
        groupToggleStates[group.id] = RxBool(group.isOn);
      }
    } catch (e) {
      showThemedSnackbar(
        "Something went wrong",
        "Failed to load grouped valves",
        isError: true,
      );
    } finally {
      isLoadingGroups.value = false;
    }
  }

  var telemetryData = <TelemetryData>[].obs;

  Future<void> fetchTelemetryData(String token, int farmId) async {
    isLoading.value = true;
    try {
      final result = await ApiService.getTelemetryData(token, farmId);
      telemetryData.assignAll(result);
    } catch (e) {
      print("Error fetching telemetry data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleValveGroup({
    required int groupId,
    required String token,
    required int farmId,
  }) async {
    groupLoading[groupId] = true.obs;
    try {
      final currentStatus = groupToggleStates[groupId]?.value ?? false;
      final newStatus = currentStatus ? "OFF" : "ON";

      final msg = await ApiService.controlValveGroup(
        groupId: groupId,
        status: newStatus,
        token: token,
      );

      await fetchGroupedValves(token, farmId);
      showThemedSnackbar("Success", msg, isSuccess: true);
    } catch (e) {
      showThemedSnackbar("Oops", "Failed to toggle valve group", isError: true);
    } finally {
      groupLoading[groupId]?.value = false;
    }
  }

  Future<void> fetchUngroupedValves(String token, int farmId) async {
    try {
      final valves = await ApiService.getUngroupedValves(token, farmId);
      ungroupedValves.value = valves;
    } catch (e) {
      showThemedSnackbar(
        "Something went wrong",
        "Failed to fetch ungrouped valves",
        isError: true,
      );
    }
  }

  Future<void> toggleValve({
    required int valveId,
    required String status,
    required String token,
    required int farmId,
  }) async {
    valveLoading[valveId] = true.obs;
    try {
      final message = await ApiService.controlIndividualValve(
        valveId: valveId,
        status: status,
        token: token,
      );

      await fetchGroupedValves(token, farmId);
      await fetchUngroupedValves(token, farmId);

      showThemedSnackbar("Success", message, isSuccess: true);
    } catch (e) {
      showThemedSnackbar("Oops", "Failed to toggle valve", isError: true);
      print("Something went wrong: $e");
    } finally {
      valveLoading[valveId]?.value = false;
    }
  }

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

  void startLiveDataUpdates(
    String token,
    int farmId, {
    Duration interval = const Duration(seconds: 5),
  }) {
    _liveDataTimer?.cancel();
    _liveDataTimer = Timer.periodic(interval, (_) {
      fetchLiveData(token, farmId);
    });
    fetchTelemetryData(token, farmId);
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
