import 'package:flutter/material.dart';
import 'package:weather_google_style/models/weather_data.dart';
import 'package:weather_google_style/weather_utils.dart';

class WeatherMainCard extends StatelessWidget {
  const WeatherMainCard({
    super.key,
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
                weatherIcon(data.weatherCode),
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
