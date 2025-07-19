import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:smartfarm/model/profile_model.dart';

import 'package:smartfarm/view/home.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.20.29:8002/api';

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
      Get.to(home());
      return json.decode(response.body);
    } else {
      throw Exception('Login failed: ${response.reasonPhrase}');
    }
  }

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
}
