import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../services/api_service.dart';

class ExerciseResultsViewModel extends ChangeNotifier {
  final String workoutId;
  final List<Exercise> exercises;
  final Map<String, int> performedDuration;
  final Map<String, int> performedReps;
  final Map<String, double> avgHeartRate;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _repsControllers = {};
  final Map<String, int> _difficulty = {};
  bool _isSaving = false;

  bool get isSaving => _isSaving;
  Map<String, TextEditingController> get repsControllers => _repsControllers;
  Map<String, int> get difficulty => _difficulty;

  ExerciseResultsViewModel({
    required this.workoutId,
    required this.exercises,
    required this.performedDuration,
    required this.performedReps,
    required this.avgHeartRate,
  }) {
    _init();
  }

  void _init() {
    for (var ex in exercises) {
      if (!ex.isDurationBased) {
        _repsControllers[ex.id] = TextEditingController();
      }
      _difficulty[ex.id] = 3; // по умолчанию «3»
    }
  }

  void disposeControllers() {
    for (var c in _repsControllers.values) {
      c.dispose();
    }
  }

  Future<void> saveResults(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    final results = <Map<String, dynamic>>[];
    final dateCompleted = DateTime.now().toIso8601String();

    for (var ex in exercises) {
      final id = ex.id;
      final avgHr = avgHeartRate[id]?.round() ?? 0;

      if (ex.isDurationBased) {
        final dur = performedDuration[id] ?? 0;
        results.add({
          'exercise_id': id,
          'recommended_duration': ex.defaultDuration,
          'performed_duration': dur,
          'difficulty': _difficulty[id],
          'avg_heart_rate': avgHr,
        });
      } else {
        final repsText = _repsControllers[id]!.text;
        final reps = int.tryParse(repsText) ?? 0;
        results.add({
          'exercise_id': id,
          'recommended_reps': ex.defaultReps,
          'performed_reps': reps,
          'difficulty': _difficulty[id],
          'avg_heart_rate': avgHr,
        });
      }
    }

    final payload = {
      'workout_id': workoutId,
      'date_completed': dateCompleted,
      'results': results,
    };

    _isSaving = true;
    notifyListeners();

    try {
      await ApiService.completeWorkout(payload: payload);
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при сохранении результатов: $e')),
      );
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  int getDifficulty(String exId) => _difficulty[exId] ?? 3;

  void setDifficulty(String exId, int value) {
    _difficulty[exId] = value;
    notifyListeners();
  }
}
