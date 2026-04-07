import 'package:flutter/material.dart';
import 'package:weather_google_style/models/daily_forecast.dart';
import 'package:weather_google_style/models/weather_data.dart';
import 'package:weather_google_style/services/weather_api.dart';
import 'package:weather_google_style/widgets/details_card.dart';
import 'package:weather_google_style/widgets/search_bar.dart';
import 'package:weather_google_style/widgets/weather_main_card.dart';
import 'package:weather_google_style/widgets/weekly_forecast_card.dart';

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
  List<DailyForecast> _weeklyForecast = <DailyForecast>[];
  bool _isLoading = false;
  bool _isWeeklyLoading = false;
  String? _errorText;
  String? _weeklyErrorText;

  @override
  void initState() {
    super.initState();
    _refreshWeather();
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _refreshWeather() {
    _loadCurrentWeather();
    _loadWeeklyForecast();
  }

  Future<void> _loadCurrentWeather() async {
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
    } catch (_) {
      // Do not show UI error on local timeout/network/runtime issues.
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadWeeklyForecast() async {
    final city = _cityController.text.trim();
    if (city.isEmpty) {
      setState(() {
        _weeklyErrorText = 'Введите название города';
      });
      return;
    }

    setState(() {
      _isWeeklyLoading = true;
      _weeklyErrorText = null;
    });

    try {
      final forecast = await _api.fetchWeeklyForecast(city);
      if (!mounted) {
        return;
      }
      setState(() {
        _weeklyForecast = forecast;
      });
    } on ApiResponseException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _weeklyErrorText = e.message;
      });
    } catch (_) {
      // Do not show UI error on local timeout/network/runtime issues.
    } finally {
      if (mounted) {
        setState(() {
          _isWeeklyLoading = false;
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
              SearchBarWidget(
                controller: _cityController,
                onSubmitted: (_) => _refreshWeather(),
                onPressed: _refreshWeather,
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
                        WeatherMainCard(
                          data: _weatherData!,
                          titleStyle: titleStyle,
                        ),
                        const SizedBox(height: 16),
                        DetailsCard(data: _weatherData!),
                        const SizedBox(height: 16),
                        WeeklyForecastCard(
                          isLoading: _isWeeklyLoading,
                          errorText: _weeklyErrorText,
                          forecast: _weeklyForecast,
                        ),
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
