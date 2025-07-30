import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smartfarm/model/farms_model.dart';
import 'package:smartfarm/model/motor_model.dart';
import 'package:smartfarm/model/profile_model.dart';
import 'package:smartfarm/model/vales_model.dart';
import 'package:smartfarm/model/valve_group_model.dart';
import 'package:smartfarm/model/valve_group_request.dart';
import 'package:smartfarm/model/valve_grouping.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.20.29:8002/api';

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

    if (response.statusCode == 200) {
      final List jsonList = json.decode(response.body);
      return jsonList.map((e) => Farm.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load farms: ${response.body}');
    }
  }

  // GET MOTORS BY FARM ID

  static Future<Map<String, List<dynamic>>> fetchMotorsAndValves({
    required int farmId,
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/farms/$farmId/motors/');
    final headers = {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return {
        'inMotors': List<Motor>.from(
          data['motors']['in'].map((m) => Motor.fromJson(m)),
        ),
        'outMotors': List<Motor>.from(
          data['motors']['out'].map((m) => Motor.fromJson(m)),
        ),
        'inValves': List<Valve>.from(
          data['valves']['in'].map((v) => Valve.fromJson(v)),
        ),
        'outValves': List<Valve>.from(
          data['valves']['out'].map((v) => Valve.fromJson(v)),
        ),
      };
    } else {
      throw Exception('Failed to load motors and valves');
    }
  }

  //MOtor on and offf API

  static Future<String> controlMotor({
    required int motorId,
    required String status, // "ON" or "OFF"
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/motors/$motorId/manual-control/');
    final headers = {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };
    final body = json.encode({"status": status});

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['message'] ?? 'Success';
    } else {
      throw Exception('Failed to control motor');
    }
  }

  // static Future<List<Motor>> getMotorsByFarmId(String token, int farmId) async {
  //   final url = Uri.parse('$baseUrl/farms/$farmId/motors/');
  //   final headers = {
  //     'Authorization': 'Token $token',
  //     'Content-Type': 'application/json',
  //   };

  //   final response = await http.get(url, headers: headers);

  //   if (response.statusCode == 200) {
  //     try {
  //       final List<dynamic> jsonList = json.decode(response.body);
  //       return jsonList.map((e) => Motor.fromJson(e)).toList();
  //     } catch (e) {
  //       throw Exception('Motor parsing error: $e');
  //     }
  //   } else if (response.statusCode == 401) {
  //     throw Exception('Unauthorized: Invalid token');
  //   } else {
  //     throw Exception(
  //       "Failed to load motors for farm $farmId (Status ${response.statusCode}): ${response.body}",
  //     );
  //   }
  // }

  //Get valves for indviduals listing
  static Future<List<Valve>> getValves(String token, int farmId) async {
    final url = Uri.parse('$baseUrl/valves/?farm_id=$farmId');
    final headers = {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Valve.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load valves: ${response.statusCode}');
    }
  }

  static Future<Map<String, List<ValveGrouping>>> getGroupedValves(
    int farmId,
    String token,
  ) async {
    final url = Uri.parse('$baseUrl/farms/$farmId/valves/');
    final headers = {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);

      List<ValveGrouping> inValves = jsonList
          .where((v) => v['direction'] == 'IN')
          .map((v) => ValveGrouping.fromJson(v))
          .toList();

      List<ValveGrouping> outValves = jsonList
          .where((v) => v['direction'] == 'OUT')
          .map((v) => ValveGrouping.fromJson(v))
          .toList();

      return {'in': inValves, 'out': outValves};
    } else {
      throw Exception("Failed to fetch valves: ${response.reasonPhrase}");
    }
  }

  // list out grouped valve

  static Future<List<ValveGroup>> getGroupedValveList(String token) async {
    final url = Uri.parse('$baseUrl/valve-groups/');
    final headers = {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => ValveGroup.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch grouped valves");
    }
  }

  //creating group request

  static Future<bool> createValveGroup(
    String token,
    ValveGroupRequest request,
  ) async {
    final url = Uri.parse('$baseUrl/valve-groups/');
    final headers = {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Failed to create valve group: ${response.statusCode}');
    }
  }

  //Edit valve group

  static Future<bool> updateValveGroup({
    required String token,
    required int groupId,
    required int farmId,
    required String name,
    required List<int> valveIds,
  }) async {
    final url = Uri.parse('$baseUrl/valve-groups/$groupId/update/');
    final headers = {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'farm': farmId,
      'name': name,
      'valve_ids': valveIds,
    });

    final response = await http.put(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return true;
    } else {
      print("Failed to update valve group: ${response.body}");
      return false;
    }
  }
  //Group Valve Control

  static Future<String> controlValveGroup({
    required int groupId,
    required String status, // "ON" or "OFF"
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/valve-groups/$groupId/manual-control/');
    final headers = {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };

    final body = json.encode({"status": status});

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['message'] ?? 'Success';
    } else {
      throw Exception('Failed to control valve group');
    }
  }

  // LOGOUT
  static Future<String> logoutUser(String token) async {
    var url = Uri.parse('$baseUrl/logout/');

    try {
      var response = await http.post(
        url,
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['message'] ?? 'Logged out successfully';
      } else {
        final error = json.decode(response.body);
        throw Exception(
          error['detail'] ?? 'Logout failed: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error during logout: ${e.toString()}');
    }
  }
}
