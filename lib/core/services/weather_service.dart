import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Real-time meteorological telemetry model.
class WeatherData {
  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final String condition;
  final int humidity;
  final double windSpeed;
  final bool isDay;
  final IconData icon;

  const WeatherData({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.isDay,
    required this.icon,
  });

  String get formattedTemp => '${temperature.round()}°C';

  Map<String, dynamic> toJson() => {
        'cityName': cityName,
        'country': country,
        'temperature': temperature,
        'feelsLike': feelsLike,
        'condition': condition,
        'humidity': humidity,
        'windSpeed': windSpeed,
        'isDay': isDay,
        'iconCode': icon.codePoint,
      };

  static IconData resolveConditionIcon(String condition, bool isDay) {
    final lower = condition.toLowerCase();
    if (lower.contains('rain') || lower.contains('shower') || lower.contains('drizzle')) {
      return Icons.water_drop_rounded;
    }
    if (lower.contains('snow') || lower.contains('flurry') || lower.contains('ice')) {
      return Icons.ac_unit_rounded;
    }
    if (lower.contains('thunder') || lower.contains('storm')) {
      return Icons.thunderstorm_rounded;
    }
    if (lower.contains('cloud') || lower.contains('overcast') || lower.contains('gloomy')) {
      return isDay ? Icons.cloud_queue_rounded : Icons.nights_stay_rounded;
    }
    if (lower.contains('fog') || lower.contains('mist') || lower.contains('haze')) {
      return Icons.foggy;
    }
    return isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round;
  }

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final condition = json['condition'] as String? ?? 'Clear';
    final isDay = json['isDay'] as bool? ?? true;
    return WeatherData(
      cityName: json['cityName'] as String? ?? 'Global Node',
      country: json['country'] as String? ?? 'Earth',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 20.0,
      feelsLike: (json['feelsLike'] as num?)?.toDouble() ?? 20.0,
      condition: condition,
      humidity: json['humidity'] as int? ?? 50,
      windSpeed: (json['windSpeed'] as num?)?.toDouble() ?? 5.0,
      isDay: isDay,
      icon: resolveConditionIcon(condition, isDay),
    );
  }
}

/// Weather Service interfacing with Open-Meteo & GeoIP for zero-friction,
/// high-accuracy real-time location weather details.
class WeatherService extends ChangeNotifier {
  static final WeatherService instance = WeatherService._internal();

  WeatherService._internal() {
    refreshWeather();
  }

  WeatherData _currentWeather = const WeatherData(
    cityName: 'Cyber Core Hub',
    country: 'Local',
    temperature: 24.0,
    feelsLike: 25.0,
    condition: 'Optimal Grid',
    humidity: 55,
    windSpeed: 8.5,
    isDay: true,
    icon: Icons.wb_sunny_rounded,
  );

  bool _isLoading = false;
  String? _errorMessage;

  WeatherData get currentWeather => _currentWeather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> refreshWeather() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Detect location via GeoIP
      String city = 'Local Node';
      String country = 'Mesh';
      double lat = 23.8103; // Default coordinates (fallback Dhaka / global)
      double lon = 90.4125;

      try {
        final geoRes = await http
            .get(Uri.parse('https://ipapi.co/json/'))
            .timeout(const Duration(seconds: 4));

        if (geoRes.statusCode == 200) {
          final geoData = jsonDecode(geoRes.body) as Map<String, dynamic>;
          city = geoData['city'] as String? ?? 'Local Node';
          country = geoData['country_code'] as String? ?? 'US';
          lat = (geoData['latitude'] as num?)?.toDouble() ?? lat;
          lon = (geoData['longitude'] as num?)?.toDouble() ?? lon;
        }
      } catch (geoErr) {
        debugPrint('GeoIP lookup note (using local cache): $geoErr');
      }

      // 2. Fetch real-world live forecast from Open-Meteo
      final weatherUrl = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,wind_speed_10m',
      );

      final weatherRes = await http.get(weatherUrl).timeout(const Duration(seconds: 6));

      if (weatherRes.statusCode == 200) {
        final data = jsonDecode(weatherRes.body) as Map<String, dynamic>;
        final current = data['current'] as Map<String, dynamic>? ?? {};

        final temp = (current['temperature_2m'] as num?)?.toDouble() ?? 24.0;
        final feelsLike = (current['apparent_temperature'] as num?)?.toDouble() ?? temp;
        final humidity = (current['relative_humidity_2m'] as num?)?.toInt() ?? 50;
        final wind = (current['wind_speed_10m'] as num?)?.toDouble() ?? 5.0;
        final isDay = (current['is_day'] as num?)?.toInt() == 1;
        final code = (current['weather_code'] as num?)?.toInt() ?? 0;

        final conditionInfo = _parseWmoCode(code, isDay);

        _currentWeather = WeatherData(
          cityName: city,
          country: country,
          temperature: temp,
          feelsLike: feelsLike,
          condition: conditionInfo.$1,
          humidity: humidity,
          windSpeed: wind,
          isDay: isDay,
          icon: conditionInfo.$2,
        );
        _errorMessage = null;
      }
    } catch (e) {
      debugPrint('Weather fetch note: $e');
      _errorMessage = 'Offline Weather Cache Active';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  (String, IconData) _parseWmoCode(int code, bool isDay) {
    switch (code) {
      case 0:
        return ('Clear Sky', isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round);
      case 1:
        return ('Mainly Clear', isDay ? Icons.wb_sunny_outlined : Icons.nightlight_outlined);
      case 2:
        return ('Partly Cloudy', isDay ? Icons.cloud_queue_rounded : Icons.cloud_outlined);
      case 3:
        return ('Overcast', Icons.cloud_rounded);
      case 45:
      case 48:
        return ('Foggy', Icons.foggy);
      case 51:
      case 53:
      case 55:
        return ('Drizzle', Icons.grain_rounded);
      case 61:
      case 63:
      case 65:
        return ('Rain', Icons.water_drop_rounded);
      case 71:
      case 73:
      case 75:
      case 77:
        return ('Snow', Icons.ac_unit_rounded);
      case 80:
      case 81:
      case 82:
        return ('Rain Showers', Icons.beach_access_rounded);
      case 95:
      case 96:
      case 99:
        return ('Thunderstorm', Icons.flash_on_rounded);
      default:
        return ('Optimal Sky', isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round);
    }
  }
}
