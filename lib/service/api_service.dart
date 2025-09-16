import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smartfarm/model/farms_model.dart';
import 'package:smartfarm/model/motor_model.dart';
import 'package:smartfarm/model/power_supply.dart';
import 'package:smartfarm/model/profile_model.dart';
import 'package:smartfarm/model/schedule_model.dart';
import 'package:smartfarm/model/valves_model.dart';
import 'package:smartfarm/model/grouped_valve_listing_model.dart';
import 'package:smartfarm/model/create_group.dart';
import 'package:smartfarm/model/valve_list.dart';

class ApiService {
  static const String baseUrl = 'https://anjalip1999.pythonanywhere.com/api';

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

  //power supply

  static Future<LiveData> getLiveData(String token, int farmId) async {
    final url = Uri.parse('$baseUrl/farms/$farmId/live-data/');

    final headers = {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return LiveData.fromJson(data);
    } else {
      throw Exception("Failed to fetch live data");
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

  //  To stop all the motors in any farm

  static Future<void> emergencyStop(String token, int farmId) async {
    final url = Uri.parse('$baseUrl/farms/$farmId/shutdown/');
    final headers = {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };

    final response = await http.post(url, headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to stop farm: ${response.body}');
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
        // 'inValves': List<Valve>.from(
        //   data['valves']['in'].map((v) => Valve.fromJson(v)),
        // ),
        // 'outValves': List<Valve>.from(
        //   data['valves']['out'].map((v) => Valve.fromJson(v)),
        // ),
      };
    } else {
      throw Exception('Failed to load motors and valves');
    }
  }

  //Motor on and offf API

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

  //Get valves for indviduals listing

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

  // Get ungrouped Valve List

  static Future<List<Valve>> getUngroupedValves(
    String token,
    int farmId,
  ) async {
    final url = Uri.parse('$baseUrl/valves/ungrouped/?farm_id=$farmId');

    final headers = {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data as List).map((v) => Valve.fromJson(v)).toList();
    } else {
      throw Exception("Failed to fetch ungrouped valves");
    }
  }

  // list out grouped valve

  static Future<List<ValveGroup>> getGroupedValveList(
    String token,
    int farmId,
  ) async {
    final url = Uri.parse('$baseUrl/valve-groups/?farm_id=$farmId');

    final headers = {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);

      return jsonList.map((e) => ValveGroup.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch grouped valves: ${response.body}");
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
      return false;
    }
  }

  //Delete grouped valve

  static Future<bool> deleteValveGroup({
    required String token,
    required int groupId,
  }) async {
    final url = Uri.parse('$baseUrl/valve-groups/$groupId/update/');
    final headers = {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };

    final response = await http.delete(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      return false;
    }
  }

  //Grouped Valve Control

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

  // individual Valve control

  static Future<String> controlIndividualValve({
    required int valveId,
    required String status,
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/valves/$valveId/manual-control/');
    final headers = {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };

    final body = json.encode({'status': status});
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['message'] ?? 'Valve $status successful';
    } else {
      throw Exception('Failed to toggle valve: ${response.reasonPhrase}');
    }
  }

  //create new schedule

  static Future<http.Response> submitSchedule({
    required String token,
    required int farmId,
    required int motorId,
    required List<int> valves,
    int? valveGroupId,
    required String startDate,
    required String endDate,
    required String startTime,
    required String endTime,
  }) async {
    final url = Uri.parse('$baseUrl/schedules/');
    final headers = {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };

    final body = json.encode({
      "farm": farmId,
      "motor": motorId,
      "valves": valves,
      "valve_group": valveGroupId,
      "start_date": startDate,
      "end_date": endDate,
      "start_times": [startTime],
      "end_times": [endTime],
    });

    return await http.post(url, headers: headers, body: body);
  }

  // fetch scheduled events

  static Future<List<Schedule>> fetchSchedules({
    required int farmId,
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/farm-schedule/$farmId/');
    final headers = {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };

    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Schedule.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load schedules: ${response.body}');
    }
  }

  //Edit scheduled Events

  static Future<String> updateSchedule({
    required int scheduleId,
    required int farmId,
    required String token,
    required int motorId,
    required List<int> valves,
    int? valveGroupId,
    required String startDate,
    required String endDate,
    required List<String> startTimes,
    required List<String> endTimes,
  }) async {
    final url = Uri.parse('$baseUrl/schedules/$scheduleId/');
    final headers = {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };

    final body = json.encode({ 
      "farm": farmId,
      "motor": motorId,
      "valves": valves,
      "valve_group": valveGroupId,
      "start_date": startDate,
      "end_date": endDate,
      "start_times": startTimes,
      "end_times": endTimes,
    });

    final response = await http.put(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return "Schedule updated successfully";
    } else {
      throw Exception('Failed to update schedule: ${response.body}');
    }
  }

  //skip schedules

  static Future<void> toggleSkipStatus({
    required String token,
    required int scheduleId,
  }) async {
    var url = Uri.parse('$baseUrl/schedules/skip/$scheduleId/');
    var headers = {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };

    final response = await http.post(url, headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to update skip status: ${response.body}');
    }
  }

  //Delete schedules

  static Future<bool> deleteSchedule(String token, int scheduleId) async {
    final url = Uri.parse('$baseUrl/schedules/$scheduleId/');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true; // Deleted successfully
    } else {
      throw Exception('Failed to delete schedule: ${response.body}');
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
