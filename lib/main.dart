import 'package:flutter/material.dart';
import 'package:weather_google_style/weather_page.dart';

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
