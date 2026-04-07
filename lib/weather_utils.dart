import 'package:flutter/material.dart';

String messageByStatusCode(int statusCode, String sourceLabel) {
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

String weatherDescriptionByCode(int weatherCode) => switch (weatherCode) {
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

IconData weatherIcon(int weatherCode) {
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
