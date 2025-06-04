import 'package:json_annotation/json_annotation.dart';

part 'current_workout.g.dart';

@JsonSerializable()
class CurrentWorkout {
  @JsonKey(name: 'workout_id')
  final String workoutId;

  @JsonKey(name: 'owner_id')
  final String ownerId;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'exercises')
  final List<String> exercises;

  @JsonKey(name: 'status')
  final String status;

  CurrentWorkout({
    required this.workoutId,
    required this.ownerId,
    required this.name,
    required this.createdAt,
    required this.exercises,
    required this.status,
  });

  factory CurrentWorkout.fromJson(Map<String, dynamic> json) =>
      _$CurrentWorkoutFromJson(json);

  Map<String, dynamic> toJson() => _$CurrentWorkoutToJson(this);
}