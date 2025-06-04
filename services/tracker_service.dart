import 'dart:async';
import 'package:flutter/services.dart';
import 'package:huawei_health/huawei_health.dart';
import '../health_auth.dart';

class TrackerService {
  static const MethodChannel _channel = MethodChannel('com.huawei.hms.flutter.health/data');

  static Future<bool> initAuthorization() async {
    return await requestHuaweiHealthAuthorization();
  }

  static Stream<int> getHeartRateStream() {
    return HmsHealth.getHealthDataStream(HealthDataType.HEART_RATE);
  }
}
