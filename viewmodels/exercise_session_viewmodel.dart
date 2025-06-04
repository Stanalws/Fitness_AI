import 'dart:async';
import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../services/tracker_service.dart';
import '../services/api_service.dart';
import '../views/exercise_results_page.dart';

class ExerciseSessionViewModel extends ChangeNotifier {
  final List<Exercise> exercises;
  final String workoutId;

  ExerciseSessionViewModel({
    required this.exercises,
    required this.workoutId,
  }) {
    _init(); // эквивалент initState()
  }


  int _currentIndex = 0;
  bool _isResting = false;
  int _restSeconds = 20;
  Timer? _restTimer;
  DateTime? _exerciseStartTime;

  StreamSubscription<int>? _hrSubscription;
  int _hrSum = 0;
  int _hrCount = 0;

  final Map<String, double> _avgHeartRate = {};
  final Map<String, int> _performedDuration = {};
  final Map<String, int> _performedReps = {};
  final Map<String, int> _difficulty = {};

  int _elapsedSeconds = 0;
  Timer? _exerciseTimer;

  int get currentIndex => _currentIndex;
  bool get isResting => _isResting;
  int get restSeconds => _restSeconds;
  int get elapsedSeconds => _elapsedSeconds;

  Map<String, double> get avgHeartRate => _avgHeartRate;
  Map<String, int> get performedDuration => _performedDuration;
  Map<String, int> get performedReps => _performedReps;
  Map<String, int> get difficulty => _difficulty;

  void _init() {
    _startExercise();
  }

  void _startExercise() {
    final ex = exercises[_currentIndex];

    _hrSum = 0;
    _hrCount = 0;
    _elapsedSeconds = 0;

    _hrSubscription?.cancel();
    _hrSubscription = TrackerService.getHeartRateStream().listen((hr) {
      if (!_isResting) {
        _hrSum += hr;
        _hrCount++;
      }
    });

    if (ex.isDurationBased) {
      _exerciseStartTime = DateTime.now();
      _exerciseTimer?.cancel();
      _exerciseTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        _elapsedSeconds++;
        notifyListeners();
      });
    }

    notifyListeners();
  }

  void finishExercise(BuildContext context) {
    final ex = exercises[_currentIndex];

    double avgHr = 0;
    if (_hrCount > 0) {
      avgHr = _hrSum / _hrCount;
    }
    _avgHeartRate[ex.id] = avgHr;

    if (ex.isDurationBased && _exerciseStartTime != null) {
      _performedDuration[ex.id] = _elapsedSeconds;
    } else {
      _performedReps[ex.id] = 0;
    }

    _exerciseTimer?.cancel();

    _isResting = true;
    _restSeconds = 20;
    notifyListeners();

    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSeconds <= 0) {
        timer.cancel();
      } else {
        _restSeconds--;
        notifyListeners();
      }
    });
  }

  void skipRestOrNext(BuildContext context) {
    _restTimer?.cancel();
    _isResting = false;
    notifyListeners();

    if (_currentIndex < exercises.length - 1) {
      _currentIndex++;
      _startExercise();
    } else {
      _hrSubscription?.cancel();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ExerciseResultsPage(
            workoutId: workoutId,
            exercises: exercises,
            performedDuration: _performedDuration,
            performedReps: _performedReps,
            avgHeartRate: _avgHeartRate,
          ),
        ),
      );
    }
  }

  void addRestTime() {
    _restSeconds = (_restSeconds + 10).clamp(0, 50);
    notifyListeners();
  }

  void disposeTimers() {
    _restTimer?.cancel();
    _hrSubscription?.cancel();
    _exerciseTimer?.cancel();
  }

  @override
  void dispose() {
    disposeTimers();
    super.dispose();
  }
}
