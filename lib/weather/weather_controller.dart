import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartfarm/weather/weather_model.dart';
import 'package:smartfarm/weather/weather_service.dart';

class WeatherController extends ChangeNotifier {
  WeatherModel? weather;
  bool isLoading = false;
  String? error;

  Future<void> getWeather(String city) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        error = "Auth token not found";
        return;
      }

      weather = await WeatherService.fetchWeather(
        city: city,
        token: token,
      );
    } catch (e) {
      error = "Weather unavailable";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}