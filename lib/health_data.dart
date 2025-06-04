// lib/health_data.dart

import 'package:flutter/services.dart';

// Канал для чтения суммарных данных (шаги)
const _dataControllerChannel = MethodChannel('com.huawei.hms.flutter.health/data_controller');

// Канал для чтения данных SamplePoint (пульс)
const _healthControllerChannel = MethodChannel('com.huawei.hms.flutter.health/health_controller');

/// Читает сумму шагов за сегодня.
Future<int> readTodaySteps() async {
  try {
    final now = DateTime.now().millisecondsSinceEpoch;
    final startOfDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
        .millisecondsSinceEpoch;

    // Вызываем нативный метод "readDailySummationData"
    final result = await _dataControllerChannel.invokeMethod<Map>(
      'readDailySummationData',
      <String, dynamic>{
        'dataType': 'HEALTH_DATA_TYPE_STEP_SUM_DELTA',
        'startTime': startOfDay,
        'endTime': now,
      },
    );

    if (result != null && result.containsKey('FIELD_STEPS')) {
      // Конвертируем к int
      final val = result['FIELD_STEPS'];
      if (val is int) return val;
      if (val is double) return val.toInt();
    }
    return 0;
  } on PlatformException catch (e) {
    print('Ошибка чтения шагов: ${e.message}');
    return 0;
  } catch (e) {
    print('Неожиданная ошибка при readTodaySteps: $e');
    return 0;
  }
}

/// Читает последнее значение пульса (уд/мин) за сегодня.
Future<double> readLatestHeartRate() async {
  try {
    final now = DateTime.now().millisecondsSinceEpoch;
    final startOfDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
        .millisecondsSinceEpoch;

    // Вызываем нативный метод "readSamplePointData"
    final List<dynamic>? points = await _healthControllerChannel.invokeMethod<List<dynamic>>(
      'readSamplePointData',
      <String, dynamic>{
        'dataType': 'HEALTH_DATA_TYPE_HEART_RATE',
        'startTime': startOfDay,
        'endTime': now,
      },
    );

    if (points != null && points.isNotEmpty) {
      final last = points.last as Map;
      if (last.containsKey('FIELD_HEART_RATE')) {
        final hr = last['FIELD_HEART_RATE'];
        if (hr is int) return hr.toDouble();
        if (hr is double) return hr;
      }
    }
    return 0.0;
  } on PlatformException catch (e) {
    print('Ошибка чтения пульса: ${e.message}');
    return 0.0;
  } catch (e) {
    print('Неожиданная ошибка при readLatestHeartRate: $e');
    return 0.0;
  }
}
