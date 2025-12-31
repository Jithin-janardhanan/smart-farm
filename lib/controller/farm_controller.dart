// farm_controller.dart
import 'dart:async';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartfarm/model/farms_model.dart';
import 'package:smartfarm/model/motor_model.dart';
import 'package:smartfarm/service/api_service.dart';

class FarmController extends GetxController {
  var farms = <Farm>[].obs;
  var isLoading = false.obs;

  // motors fetched across all farms (dashboard)
  var allMotors = <Motor>[].obs;

  // finer loading flag for motors fetch
  var isFetchingAllMotors = false.obs;

  // computed getters
  int get totalFarms => farms.length;

  int get totalMotors => allMotors.length;

  int get runningMotors => allMotors
      .where(
        (m) => (m.status.value ?? '').toString().toLowerCase().contains('on'),
      )
      .length;

  int get stoppedMotors => allMotors
      .where(
        (m) => (m.status.value ?? '').toString().toLowerCase().contains('off'),
      )
      .length;

  @override
  void onInit() {
    super.onInit();
    fetchFarms();
    fetchAllMotors(); // load motors for dashboard
  }

  /// Fetch farms (uses stored token)
  Future<void> fetchFarms() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        log("Token not found while fetching farms");
        farms.clear();
        return;
      }

      final list = await ApiService.getFarms(token);
      farms.value = list;
    } catch (e, s) {
      log("Error fetching farms: $e");
      log("$s");
      farms.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch motors for every farm and combine into allMotors
  /// Uses SharedPreferences token saved in app
  Future<void> fetchAllMotors() async {
    try {
      isFetchingAllMotors.value = true;
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        log("Token not found while fetching motors");
        allMotors.clear();
        return;
      }

      // ensure farms list is present; fetch if empty
      if (farms.isEmpty) {
        await fetchFarms();
      }

      // call fetchMotorsAndValves for each farm in parallel
      final futures = farms.map((f) async {
        try {
          final map = await ApiService.fetchMotorsAndValves(
            farmId: f.id,
            token: token,
          );
          final inList = (map['inMotors'] ?? <Motor>[]) as List<Motor>;
          final outList = (map['outMotors'] ?? <Motor>[]) as List<Motor>;
          return <Motor>[...inList, ...outList];
        } catch (e) {
          // in case of per-farm error, return empty list but keep processing
          log("Failed to fetch motors for farm ${f.id}: $e");
          return <Motor>[];
        }
      }).toList();

      final results = await Future.wait(futures);
      // flatten
      final flattened = results.expand((x) => x).toList();

      // assign to reactive list
      allMotors.value = flattened;
      log("Fetched total motors: ${allMotors.length}");
    } catch (e, s) {
      log("Error in fetchAllMotors: $e");
      log("$s");
      allMotors.clear();
    } finally {
      isFetchingAllMotors.value = false;
    }
  }

  /// Emergency stop triggers a farm shutdown; refresh motor counts afterwards
  Future<void> triggerEmergencyStop(int farmId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    if (token.isEmpty) {
      Get.snackbar("Error", "Authentication token not found");
      return;
    }

    try {
      isLoading.value = true;

      await ApiService.emergencyStop(token, farmId);
      // refresh motors & farms to reflect new statuses if backend updates them
      await fetchAllMotors();
      await fetchFarms();
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar("Success", "Emergency stop issued for farm $farmId");
      isLoading.value = false;
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar("Error", e.toString());
    }
  }
}
