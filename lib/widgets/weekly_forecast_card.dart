import 'package:flutter/material.dart';
import 'package:weather_google_style/models/daily_forecast.dart';
import 'package:weather_google_style/weather_utils.dart';

class WeeklyForecastCard extends StatelessWidget {
  const WeeklyForecastCard({
    super.key,
    required this.isLoading,
    required this.errorText,
    required this.forecast,
  });

  final bool isLoading;
  final String? errorText;
  final List<DailyForecast> forecast;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Прогноз на 7 дней',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          if (isLoading)
            const SizedBox(
              height: 90,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (errorText != null)
            Text(
              errorText!,
              style: const TextStyle(color: Colors.redAccent),
            )
          else if (forecast.isEmpty)
            const Text('Нет данных прогноза')
          else
            Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    for (final day in forecast) ...[
                      DailyForecastTile(day: day),
                      const SizedBox(width: 10),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DailyForecastTile extends StatelessWidget {
  const DailyForecastTile({super.key, required this.day});

  final DailyForecast day;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F7FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day.weekdayShort,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Icon(weatherIcon(day.weatherCode), color: const Color(0xFF5F8EF4)),
          Text('${day.maxTemp.round()}° / ${day.minTemp.round()}°'),
        ],
      ),
    );
  }
}
