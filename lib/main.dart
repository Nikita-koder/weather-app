import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Погода',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4285F4),
          brightness: Brightness.light,
        ),
      ),
      home: const WeatherPage(),
    );
  }
}

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final WeatherApi _api = WeatherApi();
  final TextEditingController _cityController = TextEditingController(
    text: 'Moscow',
  );

  WeatherData? _weatherData;
  bool _isLoading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _loadWeather() async {
    final city = _cityController.text.trim();
    if (city.isEmpty) {
      setState(() {
        _errorText = 'Введите название города';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final weather = await _api.fetchCurrentWeather(city);
      if (!mounted) {
        return;
      }
      setState(() {
        _weatherData = weather;
      });
    } on ApiResponseException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorText = e.message;
      });
    } catch (e) {
      // Do not show UI error on local timeout/network/runtime issues.
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.w500,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      appBar: AppBar(
        title: const Text('Моя погода'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _SearchBar(
                controller: _cityController,
                onSubmitted: (_) => _loadWeather(),
                onPressed: _loadWeather,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_errorText != null)
                Expanded(
                  child: Center(
                    child: Text(
                      _errorText!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                )
              else if (_weatherData != null)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _WeatherMainCard(
                          data: _weatherData!,
                          titleStyle: titleStyle,
                        ),
                        const SizedBox(height: 16),
                        _DetailsCard(data: _weatherData!),
                      ],
                    ),
                  ),
                )
              else
                const Expanded(
                  child: Center(child: Text('Введите город для прогноза')),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onPressed,
    required this.onSubmitted,
    required this.isLoading,
  });

  final TextEditingController controller;
  final VoidCallback onPressed;
  final ValueChanged<String> onSubmitted;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(32),
      color: Colors.white,
      child: TextField(
        controller: controller,
        onSubmitted: onSubmitted,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Поиск города',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            onPressed: isLoading ? null : onPressed,
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить',
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

class _WeatherMainCard extends StatelessWidget {
  const _WeatherMainCard({
    required this.data,
    required this.titleStyle,
  });

  final WeatherData data;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF8AB4F8), Color(0xFF5F8EF4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x335F8EF4),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${data.city}, ${data.country}',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                _weatherIcon(data.weatherCode),
                color: Colors.white,
                size: 56,
              ),
              const SizedBox(width: 16),
              Text(
                '${data.temperature.round()}°',
                style: titleStyle?.copyWith(color: Colors.white, fontSize: 56),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            data.weatherDescription,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 6),
          Text(
            'Обновлено: ${data.observedAt}',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.data});

  final WeatherData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Wrap(
        runSpacing: 18,
        children: [
          _DetailRow(
            icon: Icons.air,
            label: 'Ветер',
            value: '${data.windSpeed.toStringAsFixed(1)} км/ч',
          ),
          _DetailRow(
            icon: Icons.compress,
            label: 'Давление',
            value: '${data.pressure.round()} гПа',
          ),
          _DetailRow(
            icon: Icons.water_drop,
            label: 'Влажность',
            value: '${data.humidity.round()}%',
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF5F8EF4)),
        const SizedBox(width: 12),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(value),
      ],
    );
  }
}

class WeatherData {
  const WeatherData({
    required this.city,
    required this.country,
    required this.temperature,
    required this.windSpeed,
    required this.pressure,
    required this.humidity,
    required this.weatherCode,
    required this.observedAt,
    required this.weatherDescription,
  });

  final String city;
  final String country;
  final double temperature;
  final double windSpeed;
  final double pressure;
  final double humidity;
  final int weatherCode;
  final String observedAt;
  final String weatherDescription;
}

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
      weatherDescription: _weatherDescriptionByCode(weatherCode),
    );
  }

  Future<Map<String, dynamic>> _getJson(Uri uri, String sourceLabel) async {
    final response = await _getWithRetry(uri);
    if (response.statusCode != 200) {
      throw ApiResponseException(
        _messageByStatusCode(response.statusCode, sourceLabel),
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

String _messageByStatusCode(int statusCode, String sourceLabel) {
  if (statusCode == 400) {
    return 'Некорректный запрос к $sourceLabel (400)';
  }
  if (statusCode == 404) {
    return 'Сервис $sourceLabel не найден (404)';
  }
  if (statusCode == 429) {
    return 'Слишком много запросов к $sourceLabel, попробуйте позже';
  }
  if (statusCode >= 500) {
    return 'Сервис $sourceLabel временно недоступен ($statusCode), попробуйте позже';
  }
  return 'Проблема с $sourceLabel ($statusCode)';
}

String _weatherDescriptionByCode(int weatherCode) => switch (weatherCode) {
      0 => 'Ясно',
      1 || 2 || 3 => 'Переменная облачность',
      45 || 48 => 'Туман',
      51 || 53 || 55 => 'Морось',
      56 || 57 => 'Ледяная морось',
      61 || 63 || 65 => 'Дождь',
      66 || 67 => 'Ледяной дождь',
      71 || 73 || 75 || 77 => 'Снег',
      80 || 81 || 82 => 'Ливневый дождь',
      85 || 86 => 'Снежные ливни',
      95 || 96 || 99 => 'Гроза',
      _ => 'Неизвестные условия',
    };

IconData _weatherIcon(int weatherCode) {
  if (weatherCode == 0) {
    return Icons.wb_sunny;
  }
  if (weatherCode >= 1 && weatherCode <= 3) {
    return Icons.cloud;
  }
  if (weatherCode == 45 || weatherCode == 48) {
    return Icons.foggy;
  }
  if ((weatherCode >= 51 && weatherCode <= 67) ||
      (weatherCode >= 80 && weatherCode <= 82)) {
    return Icons.grain;
  }
  if (weatherCode >= 71 && weatherCode <= 77) {
    return Icons.ac_unit;
  }
  if (weatherCode >= 95) {
    return Icons.thunderstorm;
  }
  return Icons.cloud_queue;
}
