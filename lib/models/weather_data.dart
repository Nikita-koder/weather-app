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
