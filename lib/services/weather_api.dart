import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:weather_google_style/models/daily_forecast.dart';
import 'package:weather_google_style/models/weather_data.dart';
import 'package:weather_google_style/weather_utils.dart';

class WeatherApi {
  Future<WeatherData> fetchCurrentWeather(String cityName) async {
    final geoUri = Uri.https(
      'geocoding-api.open-meteo.com',
      '/v1/search',
      {
        'name': cityName,
        'count': '1',
        'lang': 'ru',
        'format': 'json',
      },
    );

    final geoBody = await _getJson(geoUri, 'геокодированием');
    final results = geoBody['results'] as List<dynamic>?;
    if (results == null || results.isEmpty) {
      throw const ApiResponseException('Город не найден');
    }

    final location = results.first as Map<String, dynamic>;
    final latitude = location['latitude'] as num;
    final longitude = location['longitude'] as num;
    final resolvedCity = (location['name'] as String?) ?? cityName;
    final country = (location['country'] as String?) ?? '-';

    final weatherUri = Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      {
        'latitude': '$latitude',
        'longitude': '$longitude',
        'current':
            'temperature_2m,relative_humidity_2m,pressure_msl,wind_speed_10m,weather_code',
        'timezone': 'auto',
      },
    );

    final weatherBody = await _getJson(weatherUri, 'погодным API');
    final current = weatherBody['current'] as Map<String, dynamic>?;
    if (current == null) {
      throw const ApiResponseException('Сервис вернул пустые данные погоды');
    }

    final weatherCode = (current['weather_code'] as num?)?.toInt() ?? -1;
    final observedAt = (current['time'] as String?)?.replaceFirst('T', ' ') ?? '-';

    return WeatherData(
      city: resolvedCity,
      country: country,
      temperature: (current['temperature_2m'] as num?)?.toDouble() ?? 0,
      windSpeed: (current['wind_speed_10m'] as num?)?.toDouble() ?? 0,
      pressure: (current['pressure_msl'] as num?)?.toDouble() ?? 0,
      humidity: (current['relative_humidity_2m'] as num?)?.toDouble() ?? 0,
      weatherCode: weatherCode,
      observedAt: observedAt,
      weatherDescription: weatherDescriptionByCode(weatherCode),
    );
  }

  Future<List<DailyForecast>> fetchWeeklyForecast(String cityName) async {
    final geoUri = Uri.https(
      'geocoding-api.open-meteo.com',
      '/v1/search',
      {
        'name': cityName,
        'count': '1',
        'lang': 'ru',
        'format': 'json',
      },
    );

    final geoBody = await _getJson(geoUri, 'геокодированием');
    final results = geoBody['results'] as List<dynamic>?;
    if (results == null || results.isEmpty) {
      throw const ApiResponseException('Город не найден');
    }

    final location = results.first as Map<String, dynamic>;
    final latitude = location['latitude'] as num;
    final longitude = location['longitude'] as num;

    final dailyUri = Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      {
        'latitude': '$latitude',
        'longitude': '$longitude',
        'daily': 'weather_code,temperature_2m_max,temperature_2m_min',
        'forecast_days': '7',
        'timezone': 'auto',
      },
    );

    final dailyBody = await _getJson(dailyUri, 'недельным прогнозом');
    final daily = dailyBody['daily'] as Map<String, dynamic>?;
    if (daily == null) {
      throw const ApiResponseException('Сервис вернул пустые данные прогноза');
    }

    final times = (daily['time'] as List<dynamic>?) ?? <dynamic>[];
    final maxTemps = (daily['temperature_2m_max'] as List<dynamic>?) ?? <dynamic>[];
    final minTemps = (daily['temperature_2m_min'] as List<dynamic>?) ?? <dynamic>[];
    final codes = (daily['weather_code'] as List<dynamic>?) ?? <dynamic>[];

    final count = [times.length, maxTemps.length, minTemps.length, codes.length]
        .reduce((a, b) => a < b ? a : b);
    if (count == 0) {
      throw const ApiResponseException('Сервис вернул пустые данные прогноза');
    }

    final result = <DailyForecast>[];
    for (var i = 0; i < count; i++) {
      result.add(
        DailyForecast(
          date: times[i] as String? ?? '',
          maxTemp: (maxTemps[i] as num?)?.toDouble() ?? 0,
          minTemp: (minTemps[i] as num?)?.toDouble() ?? 0,
          weatherCode: (codes[i] as num?)?.toInt() ?? -1,
        ),
      );
    }
    return result;
  }

  Future<Map<String, dynamic>> _getJson(Uri uri, String sourceLabel) async {
    final response = await _getWithRetry(uri);
    if (response.statusCode != 200) {
      throw ApiResponseException(
        messageByStatusCode(response.statusCode, sourceLabel),
      );
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final hasError = body['error'] == true;
    if (hasError) {
      final reason = body['reason'] as String? ?? 'Неизвестная ошибка API';
      throw ApiResponseException(reason);
    }
    return body;
  }

  Future<http.Response> _getWithRetry(Uri uri) async {
    var response = await http.get(uri);
    if (response.statusCode == 502 ||
        response.statusCode == 503 ||
        response.statusCode == 504) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      response = await http.get(uri);
    }
    return response;
  }
}

class ApiResponseException implements Exception {
  const ApiResponseException(this.message);
  final String message;
}
