class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.weatherCode,
  });

  final String date;
  final double minTemp;
  final double maxTemp;
  final int weatherCode;

  String get weekdayShort {
    final parsed = DateTime.tryParse(date);
    if (parsed == null) {
      return date;
    }
    const names = <String>['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return names[parsed.weekday - 1];
  }
}
