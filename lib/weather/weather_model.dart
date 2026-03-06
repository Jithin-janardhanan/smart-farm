class WeatherModel {
  final String city;
  final CurrentWeather current;
  final List<Forecast> upcomingForecast;

  WeatherModel({
    required this.city,
    required this.current,
    required this.upcomingForecast,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      city: json['city'],
      current: CurrentWeather.fromJson(json['current']),
      upcomingForecast: List<Forecast>.from(
        json['upcoming_forecast'].map((x) => Forecast.fromJson(x)),
      ),
    );
  }
}

class CurrentWeather {
  final double temperature;
  final int humidity;
  final String description;
  final double windSpeed;

  CurrentWeather({
    required this.temperature,
    required this.humidity,
    required this.description,
    required this.windSpeed,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['temperature']).toDouble(),
      humidity: json['humidity'],
      description: json['description'],
      windSpeed: (json['wind_speed']).toDouble(),
    );
  }
}

class Forecast {
  final String date;
  final double temperature;
  final String description;
  final int humidity;
  final double windSpeed;

  Forecast({
    required this.date,
    required this.temperature,
    required this.description,
    required this.humidity,
    required this.windSpeed,
  });

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      date: json['date'],
      temperature: (json['temperature']).toDouble(),
      description: json['description'],
      humidity: json['humidity'],
      windSpeed: (json['wind_speed']).toDouble(),
    );
  }
}