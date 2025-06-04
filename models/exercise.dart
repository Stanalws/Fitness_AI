// lib/models/exercise.dart

import 'package:json_annotation/json_annotation.dart';

part 'exercise.g.dart';

@JsonSerializable()
class Exercise {
  @JsonKey(name: 'exercise_id')
  final String id;

  final String name;

  @JsonKey(name: 'muscle_groups')
  final List<String> muscleGroups;

  @JsonKey(name: 'suitable_goals')
  final List<String> suitableGoals;

  final String type;


  final List<String> contraindications;

  @JsonKey(name: 'is_duration_based')
  final bool isDurationBased;
  
  @JsonKey(name: 'default_duration')
  final int defaultDuration;

  @JsonKey(name: 'default_reps')
  final int defaultReps;

  final int difficulty;

  @JsonKey(name: 'base_intensity')
  final double baseIntensity;

  final String description;

  @JsonKey(name: 'execution_plan')
  final String executionPlan;

  Exercise({
    required this.id,
    required this.name,
    required this.muscleGroups,
    required this.suitableGoals,
    required this.type,
    required this.contraindications,
    required this.isDurationBased,
    required this.defaultDuration,
    required this.defaultReps,
    required this.difficulty,
    required this.baseIntensity,
    required this.description,
    required this.executionPlan,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseToJson(this);
}
