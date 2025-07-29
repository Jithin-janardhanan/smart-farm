import 'package:get/get.dart';
import 'package:smartfarm/model/motor_model.dart';
import 'package:smartfarm/model/vales_model.dart';


import 'dart:convert';
import 'package:http/http.dart' as http;

class MotorController extends GetxController {
  var inMotors = <Motor>[].obs;
  var outMotors = <Motor>[].obs;
  var inValves = <Valve>[].obs;
  var outValves = <Valve>[].obs;
  var isLoading = false.obs;

  Future<void> fetchMotorsAndValves(int farmId, String token) async {
    isLoading.value = true;

    final url = 'http://192.168.20.29:8002/api/farms/$farmId/motors/';
    var headers = {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      inMotors.value = List<Motor>.from(
        data['motors']['in'].map((m) => Motor.fromJson(m)),
      );
      outMotors.value = List<Motor>.from(
        data['motors']['out'].map((m) => Motor.fromJson(m)),
      );
      inValves.value = List<Valve>.from(
        data['valves']['in'].map((v) => Valve.fromJson(v)),
      );
      outValves.value = List<Valve>.from(
        data['valves']['out'].map((v) => Valve.fromJson(v)),
      );
    } else {
    
    }

    isLoading.value = false;
  }
}
