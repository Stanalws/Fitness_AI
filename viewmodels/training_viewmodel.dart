import 'dart:math';
import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../models/user.dart';
import '../models/exercise.dart';
import '../models/current_workout.dart';
import '../services/api_service.dart';

class TrainingViewModel extends ChangeNotifier {
  int _currentIndex = 1;
  String? _selectedGoal;
  bool _isLoading = true;
  User? _user;

  bool _isGenerating = false;
  String? _error;
  List<Exercise> _selectedExercises = [];
  String? _currentWorkoutId;

  final Map<String, String> _allGoals = {
    'похудение': 'Похудение',
    'набор_мышечной_массы': 'Набор мышечной массы',
    'выносливость': 'Выносливость',
    'тонус': 'Тонус',
  };

  int get currentIndex => _currentIndex;
  String? get selectedGoal => _selectedGoal;
  bool get isLoading => _isLoading;
  User? get user => _user;

  bool get isGenerating => _isGenerating;
  String? get error => _error;
  List<Exercise> get selectedExercises => _selectedExercises;
  String? get currentWorkoutId => _currentWorkoutId;

  Map<String, String> get allGoals => _allGoals;

  TrainingViewModel() {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    _isLoading = true;
    notifyListeners();
    try {
      final u = await UserService.getCurrentUser();
      _user = u;
      _selectedGoal = u.goal;
      notifyListeners();

      await _loadWorkoutFromDb();
    } catch (e) {
      debugPrint('Ошибка загрузки пользователя: $e');
    } finally {
      // setState(() => _isLoading = false);
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadWorkoutFromDb() async {
    if (_user == null) return;

    try {
      final cw = await ApiService.fetchCurrentWorkout();
      if (cw == null) return;
      _selectedGoal = cw.name;
      _currentWorkoutId = cw.workoutId;
      notifyListeners();

      final allExercises = await ApiService.fetchAllExercises();
      final loaded = allExercises
          .where((ex) => cw.exercises.contains(ex.id))
          .toList();

      if (loaded.isNotEmpty) {
        _selectedExercises = loaded;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Ошибка при загрузке тренировки из БД: $e');
    }
  }

  Future<void> showGoalPickerDialog(BuildContext context) async {
    final chosen = await showDialog<String>(
      context: context,
      builder: (ctx) {
        String? tempChoice = _selectedGoal;
        return AlertDialog(
          backgroundColor: const Color(0xff331919),
          title: const Text(
            'Выберите цель тренировки',
            style: TextStyle(color: Colors.white),
          ),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: _allGoals.entries.map((entry) {
                  final code = entry.key;
                  final label = entry.value;
                  return RadioListTile<String>(
                    activeColor: Colors.redAccent,
                    title:
                        Text(label, style: const TextStyle(color: Colors.white)),
                    value: code,
                    groupValue: tempChoice,
                    onChanged: (val) {
                      setStateDialog(() {
                        tempChoice = val;
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Отмена',
                  style: TextStyle(color: Color(0xFFE51919))),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(tempChoice),
              child: const Text('Сохранить',
                  style: TextStyle(color: Color(0xFFE51919))),
            ),
          ],
        );
      },
    );

    if (chosen != null && chosen != _selectedGoal) {
      _isLoading = true;
      notifyListeners();
      try {
        final updated = await UserService.updateUser(goal: chosen);
        _user = updated;
        _selectedGoal = chosen;
        notifyListeners();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Цель успешно сохранена')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при сохранении цели:\n$e')),
        );
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> generateTraining() async {
    if (_user == null) return;

    final missingProfile = _user!.height <= 0 ||
        _user!.weight <= 0 ||
        _user!.age <= 0 ||
        _user!.gender.isEmpty;

    final missingGoal = _selectedGoal == null;

    final missingContra = !_user!.noContra && _user!.limitations.isEmpty;

    if (missingProfile || missingGoal || missingContra) {
      String msg;
      if (missingProfile && missingGoal && missingContra) {
        msg =
            'Пожалуйста, заполните профиль, укажите цель и выберите противопоказания';
      } else if (missingProfile && missingGoal) {
        msg = 'Пожалуйста, заполните профиль и укажите цель';
      } else if (missingProfile && missingContra) {
        msg =
            'Пожалуйста, заполните профиль и выберите противопоказания (или «Нет ограничений»)';
      } else if (missingGoal && missingContra) {
        msg = 'Пожалуйста, укажите цель и выберите противопоказания';
      } else if (missingProfile) {
        msg = 'Пожалуйста, заполните профиль';
      } else if (missingGoal) {
        msg = 'Пожалуйста, укажите цель';
      } else {
        msg = 'Пожалуйста, выберите противопоказания (или «Нет ограничений»)';
      }
      ScaffoldMessenger.of(navigationContext!).showSnackBar(
        SnackBar(content: Text(msg)),
      );
      return;
    }

    _isGenerating = true;
    _error = null;
    _selectedExercises = [];
    _currentWorkoutId = null;
    notifyListeners();

    try {
      final user = _user!;

      final userContra = user.noContra
          ? <String>{}
          : user.limitations.where((c) => c != 'no_limitations').toSet();

      final allExercises = await ApiService.fetchAllExercises();

      final filtered = allExercises.where((ex) {
        return ex.contraindications.toSet().intersection(userContra).isEmpty;
      }).toList();

      final ageFiltered = user.age > 60
          ? filtered.where((ex) {
              return ex.difficulty <= 3 && ex.baseIntensity <= 0.5;
            }).toList()
          : filtered;

      final selected = _selectDiverse(ageFiltered, 8);

      _selectedExercises = selected;
      notifyListeners();

      final exerciseIds = selected.map((ex) => ex.id).toList();
      final workoutName = _selectedGoal!;
      final newId = await ApiService.createWorkout(
        name: workoutName,
        exercises: exerciseIds,

      _currentWorkoutId = newId;
      notifyListeners();
    } catch (e) {
      _error = 'Не удалось сформировать тренировку:\n$e';
      notifyListeners();
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  List<Exercise> _selectDiverse(List<Exercise> pool, int count) {
    final rand = Random();
    final selected = <Exercise>[];
    final usedMuscles = <String>{};
    final usedTypes = <String>{};

    final shuffled = List.of(pool)..shuffle(rand);

    for (var ex in shuffled) {
      if (selected.length >= count) break;

      final hasNewMuscle = ex.muscleGroups.any((m) => !usedMuscles.contains(m));
      final isNewType = !usedTypes.contains(ex.type);

      if (hasNewMuscle && isNewType) {
        selected.add(ex);
        usedMuscles.addAll(ex.muscleGroups);
        usedTypes.add(ex.type);
      }
    }

    if (selected.length < count) {
      for (var ex in shuffled) {
        if (selected.length >= count) break;
        if (!selected.contains(ex)) {
          selected.add(ex);
        }
      }
    }

    return selected.take(count).toList();
  }

  void showExerciseDetails(BuildContext context, Exercise ex) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xff331919),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            ex.name,
            style:
                const TextStyle(color: Colors.white, fontFamily: 'Lexend-Bold'),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (ex.isDurationBased)
                  Text(
                    'Длительность: ${ex.defaultDuration} сек',
                    style: const TextStyle(color: Colors.white70),
                  )
                else
                  Text(
                    'Повторений: ${ex.defaultReps}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                const SizedBox(height: 8),
                Text(
                  ex.description,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                Text(
                  'План выполнения:\n${ex.executionPlan}',
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Закрыть',
                  style: TextStyle(color: Color(0xFFE51919))),
            ),
          ],
        );
      },
    );
  }

  BuildContext? navigationContext;
}
