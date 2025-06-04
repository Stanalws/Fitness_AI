import 'package:flutter/foundation.dart';

class ExerciseResult {
  final String exerciseId;
  final String exerciseName;
  final bool isDurationBased;
  final int recommendedReps;
  final int recommendedDuration;
  final int performedReps;
  final int performedDuration;
  final int difficulty;
  final int avgHeartRate;

  ExerciseResult({
    required this.exerciseId,
    required this.exerciseName,
    required this.isDurationBased,
    required this.recommendedReps,
    required this.recommendedDuration,
    required this.performedReps,
    required this.performedDuration,
    required this.difficulty,
    required this.avgHeartRate,
  });

  factory ExerciseResult.fromJson(Map<String, dynamic> ex, Map<String, String> nameMap) {
    return ExerciseResult(
      exerciseId: ex['exercise_id'] as String,
      exerciseName: nameMap[ex['exercise_id']!] ?? ex['exercise_id']!,
      isDurationBased: ex.containsKey('recommended_duration'),
      recommendedReps: (ex['recommended_reps'] as int?) ?? 0,
      recommendedDuration: (ex['recommended_duration'] as int?) ?? 0,
      performedReps: (ex['performed_reps'] as int?) ?? 0,
      performedDuration: (ex['performed_duration'] as int?) ?? 0,
      difficulty: ex['difficulty'] as int,
      avgHeartRate: ex['avg_heart_rate'] as int,
    );
  }
}

class CompletedWorkout {
  final String id;
  final String name;
  final DateTime dateCompleted;
  final List<ExerciseResult> exercises;

  CompletedWorkout({
    required this.id,
    required this.name,
    required this.dateCompleted,
    required this.exercises,
  });

  factory CompletedWorkout.fromJson(Map<String, dynamic> json, Map<String, String> nameMap) {
    final workout = json['workout'] as Map<String, dynamic>?;
    final id = workout != null
        ? workout['id'] as String
        : (json['id'] as String);

    final name = workout != null
        ? workout['name'] as String
        : (json['name'] as String);

    final dateStr = workout != null
        ? (workout['date_completed'] as String)
        : (json['date_completed'] as String);

    final dateCompleted = DateTime.parse(dateStr);

    final rawResults = json['results'] as List<dynamic>;
    final exercises = rawResults
        .map((e) => ExerciseResult.fromJson(e as Map<String, dynamic>, nameMap))
        .toList(growable: false);

    return CompletedWorkout(
      id: id,
      name: name,
      dateCompleted: dateCompleted,
      exercises: exercises,
    );
  }
}
