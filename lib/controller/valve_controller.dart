//individual valve_list_controller.dart

import 'package:get/get.dart';
import '../model/valve_list.dart';
import '../service/api_service.dart';

class ValveController extends GetxController {
  var inValves = <ValveGrouping>[].obs;
  var outValves = <ValveGrouping>[].obs;
  var isLoading = false.obs;

  Future<void> fetchValves(int farmId, String token) async {
    isLoading.value = true;

    try {
      final result = await ApiService.getGroupedValves(farmId, token);
      inValves.value = result['in'] ?? [];
      outValves.value = result['out'] ?? [];
    } catch (e) {
      print("Valve fetch error: $e");
    }

    isLoading.value = false;
  }
}
