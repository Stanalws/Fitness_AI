// lib/services/user_service.dart

import '../models/user.dart';
import 'api_service.dart';

class UserService {
  static User? _cachedUser;

  /// Получить текущего пользователя (из кэша или с сервера)
  static Future<User> getCurrentUser({bool forceRefresh = false}) async {
    if (_cachedUser != null && !forceRefresh) {
      return _cachedUser!;
    }
    final Map<String, dynamic> json = await ApiService.fetchUserProfile();
    final user = User.fromJson(json);
    _cachedUser = user;
    return user;
  }

	static Future<User> updateUser({
	  int? height,
	  int? weight,
	  int? age,
	  String? gender,
	  List<String>? limitations,
	  bool? noContra,
	  String? goal,
	}) async {
	  if (goal != null && height == null && weight == null && age == null && gender == null && limitations == null) {
		await ApiService.updateUserGoal(goal);
	  } else {
		final payload = <String, dynamic>{};
		if (height != null) payload['height'] = height;
		if (weight != null) payload['weight'] = weight;
		if (age != null) payload['age'] = age;
		if (gender != null) payload['gender'] = gender;
		if (limitations != null) {
		  payload['limitations'] = (noContra == true) ? ['no_limitations'] : limitations;
		}
		await ApiService.updateUserProfile(payload: payload);
	  }

	  final json = await ApiService.fetchUserProfile();
	  final freshUser = User.fromJson(json);
	  _cachedUser = freshUser;
	  return freshUser;
	}

  static Future<User> updateName(String newName) async {
    await ApiService.updateUserName(newName);
    final json = await ApiService.fetchUserProfile();
    final freshUser = User.fromJson(json);
    _cachedUser = freshUser;
    return freshUser;
  }

  static Future<User> updateTracker({
    required double lastHeartRate,
    required int lastSteps,
  }) async {
    await ApiService.saveTrackerData(
      heartRate: lastHeartRate,
      steps: lastSteps,
    );
    final json = await ApiService.fetchUserProfile();
    final freshUser = User.fromJson(json);
    _cachedUser = freshUser;
    return freshUser;
  }

  static Future<User> updateGoal(String newGoal) async {
    final freshUser = await updateUser(goal: newGoal);
    return freshUser;
  }

  static void clearCache() {
    _cachedUser = null;
  }
}
