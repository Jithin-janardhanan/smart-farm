import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smartfarm/weather/weather_model.dart';


class WeatherService {

  static String get baseUrl {
    final url = dotenv.env['BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception("❌ BASE_URL not found in .env file");
    }
    return url;
  }

  /// 🌤 Fetch Weather Data
  static Future<WeatherModel> fetchWeather({
    required String city,
    required String token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/weather/?city=$city');

      log("📡 Calling Weather API → $url");

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      log("📊 Status Code: ${response.statusCode}");
      log("📦 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return WeatherModel.fromJson(decoded);
      } else {
        throw Exception(
            "❌ Weather fetch failed: ${response.statusCode} - ${response.body}");
      }
    } catch (e, s) {
      log("💥 Exception in WeatherService.fetchWeather(): $e");
      log("🧾 Stacktrace: $s");
      rethrow;
    }
  }
}