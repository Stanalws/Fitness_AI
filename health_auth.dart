// lib/health_auth.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Имя канала для авторизации HMS Health Kit (берётся из плагина Java/Channel.java)
const _authChannel = MethodChannel('com.huawei.hms.flutter.health/auth');

/// Запрашивает у пользователя вход через Huawei ID и разрешения Health Kit.
/// Возвращает true, если вход и разрешения даны, иначе false.
Future<bool> requestHuaweiHealthAuthorization() async {
  try {
    // Вызываем нативный метод "requestAuthorization" без предварительной проверки
    // (плагин внутри сначала предложит войти в Huawei ID, а потом запросит Health разрешения).
    final bool granted = await _authChannel.invokeMethod<bool>(
      'requestAuthorization',
      <String, dynamic>{
        // Сюда передаём список типов данных, которые хотим запросить у Health Kit.
        // Строки точно совпадают с enum-константами в Java: HealthDataType.
        'dataTypes': <String>[
          'HEALTH_DATA_TYPE_STEP_SUM_DELTA', // шаги
          'HEALTH_DATA_TYPE_HEART_RATE',     // пульс
        ],
      },
    ) ?? false;

    return granted;
  } on PlatformException catch (e) {
    debugPrint('Ошибка авторизации HMS Health: ${e.message}');
    return false;
  } catch (e) {
    debugPrint('Неожиданная ошибка при requestHuaweiHealthAuthorization: $e');
    return false;
  }
}
