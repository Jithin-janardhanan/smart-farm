import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:smartfarm/model/farms_model.dart';
import 'package:smartfarm/model/profile_model.dart';
import 'package:smartfarm/view/home.dart';

class ApiService {
  static const String baseUrl = 'https://jithinj.pythonanywhere.com/api';

  // Login API

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
      Get.to(HomePage ());
      return json.decode(response.body);
    } else {
      throw Exception('Login failed: ${response.reasonPhrase}');
    }
  }

// fetch farmer profile API

  static Future<Farmer> getFarmerProfile(String token) async {
    var url = Uri.parse('$baseUrl/farmer-profile/');
    var headers = {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return Farmer.fromJson(jsonData);
    } else {
      throw Exception('Failed to load farmer profile');
    }
  }
// farmer profile  editing API
  static Future<bool> updateFarmerProfile(
    String token,
    Farmer updatedFarmer,
  ) async {
    var url = Uri.parse('$baseUrl/farmer-profile/');
    var headers = {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };

    var body = json.encode(
      updatedFarmer.toJson(),
    );

    final response = await http.put(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }
//fetch motos from a specific farm
  static Future<List<Farm>> getFarms(String token) async {
    final url = Uri.parse('https://jithinj.pythonanywhere.com/api/farms/');
    final headers = {'Authorization': 'Token $token'};

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List jsonList = json.decode(response.body);
      return jsonList.map((e) => Farm.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load farms');
    }
  }

}
