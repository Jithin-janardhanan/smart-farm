import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:smartfarm/model/farms_model.dart';
import 'package:smartfarm/model/motor_model.dart';
import 'package:smartfarm/model/profile_model.dart';
import 'package:smartfarm/view/home.dart';

class ApiService {
  static const String baseUrl = 'https://jithinj.pythonanywhere.com/api';

  // LOGIN
  static Future<Map<String, dynamic>> login(
    String phone,
    String password,
  ) async {
    var url = Uri.parse('$baseUrl/farmer-login/');
    var headers = {'Content-Type': 'application/json'};
    var body = json.encode({"phone_number": phone, "password": password});

    var request = http.Request('POST', url);
    request.body = body;
    request.headers.addAll(headers);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      Get.off(HomePage());
      return json.decode(response.body);
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  // GET PROFILE
  static Future<Farmer> getFarmerProfile(String token) async {
    var url = Uri.parse('$baseUrl/farmer-profile/');
    var headers = {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return Farmer.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load farmer profile: ${response.body}');
    }
  }

  // UPDATE PROFILE
  static Future<bool> updateFarmerProfile(
    String token,
    Farmer updatedFarmer,
  ) async {
    var url = Uri.parse('$baseUrl/farmer-profile/');
    var headers = {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };

    var body = json.encode(updatedFarmer.toJson());

    final response = await http.put(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }

  // GET FARMS
  static Future<List<Farm>> getFarms(String token) async {
    final url = Uri.parse('$baseUrl/farms/');
    final headers = {'Authorization': 'Token $token'};

    final response = await http.get(url, headers: headers);
    print('Saved Token: $token');
    print('Status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List jsonList = json.decode(response.body);
      return jsonList.map((e) => Farm.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load farms: ${response.body}');
    }
  }

  // GET MOTORS BY FARM ID
  static Future<List<Motor>> getMotorsByFarmId(String token, int farmId) async {
    final url = Uri.parse('$baseUrl/farms/$farmId/motors/');
    final headers = {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List jsonList = json.decode(response.body);
      return jsonList.map((e) => Motor.fromJson(e)).toList();
    } else {
      throw Exception(
        "Failed to load motors for farm $farmId: ${response.body}",
      );
    }
  }

  // LOGOUT
  static Future<String> logoutUser(String token) async {
    var url = Uri.parse('$baseUrl/logout/');
    var headers = {'Authorization': 'Token $token'};

    var request = http.Request('POST', url);
    request.headers.addAll(headers);
    request.body = ''; // Empty body

    http.StreamedResponse response = await request.send();
    var respond = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      final data = json.decode(respond.body);
      return data['message'] ?? 'Logged out successfully';
    } else {
      final error = json.decode(respond.body);
      throw Exception(error['detail'] ?? 'Logout failed: ${respond.body}');
    }
  }
}
