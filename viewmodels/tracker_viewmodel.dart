import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../health_auth.dart';
import 'package:huawei_health/huawei_health.dart';
import '../services/user_service.dart';
import '../services/api_service.dart';
import '../routes/slide_route.dart';
import '../views/profile_page.dart';

class TrackerViewModel extends ChangeNotifier {
  final int currentIndex = 2;

  bool isAuthorized = false;
  bool isLoading = false;

  double latestHeartRate = 0.0;
  int todaySteps = 0;

  StreamSubscription<Map<String, dynamic>>? _healthDataSubscription;

  TrackerViewModel() {
    _initializeHealthStreaming();
  }

  @override
  void dispose() {
    _healthDataSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeHealthStreaming() async {
    isLoading = true;
    notifyListeners();

    bool granted = false;
    try {
      granted = await requestHuaweiHealthAuthorization();
    } on PlatformException catch (e) {
      debugPrint('Ошибка при запросе авторизации HMS Health: $e');
      granted = false;
    }

    if (!granted) {
      isAuthorized = false;
      isLoading = false;
      notifyListeners();
      return;
    }

    isAuthorized = true;
    _healthDataSubscription?.cancel();

    try {
      _healthDataSubscription = HealthController.onDataChanged.listen(
        _onHealthDataChanged,
        onError: (err) {
          debugPrint('Ошибка стрима HealthController: $err');
        },
      );
      await HealthController.subscribeHealthData([
        HealthDataType.HEART_RATE,
        HealthDataType.STEP_SUM_DELTA,
      ]);
    } on Exception catch (e) {
      debugPrint('Не удалось подписаться на HealthController: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  void _onHealthDataChanged(Map<String, dynamic> dataMap) {
    if (dataMap.containsKey(HealthDataType.HEART_RATE.name)) {
      final rawHr = dataMap[HealthDataType.HEART_RATE.name];
      latestHeartRate = (rawHr is num) ? rawHr.toDouble() : 0.0;
    }
    if (dataMap.containsKey(HealthDataType.STEP_SUM_DELTA.name)) {
      final rawSteps = dataMap[HealthDataType.STEP_SUM_DELTA.name];
      todaySteps = (rawSteps is int) ? rawSteps : 0;
    }
    notifyListeners();
  }

  Future<void> onButtonPressed() async {
    await _initializeHealthStreaming();
  }

  Future<void> onSavePressed(BuildContext context) async {
    if (!isAuthorized) {
      await _initializeHealthStreaming();
      if (!isAuthorized) return;
    }

    isLoading = true;
    notifyListeners();
    try {
      await UserService.updateTracker(
        lastHeartRate: latestHeartRate,
        lastSteps: todaySteps,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Данные трекера сохранены в профиле')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось сохранить данные трекера:\n$e')),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void onTapIndex(BuildContext context, int index) {
    if (index == currentIndex) return;
    Widget destination;
    switch (index) {
      case 0:
        destination = const ProfilePage();
        break;
      case 1:
        destination = const TrainingPage();
        break;
      case 2:
        // Уже на TrackerPage — просто выходим и не меняем экран
        return;
      case 3:
        destination = const ResultsPage();
        break;
      default:
        return;    }
    Navigator.of(context).pushReplacement(
      SlideLeftRoute(page: destination),
    );
  }
}
