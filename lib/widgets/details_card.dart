import 'package:flutter/material.dart';
import 'package:weather_google_style/models/weather_data.dart';

class DetailsCard extends StatelessWidget {
  const DetailsCard({super.key, required this.data});

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
