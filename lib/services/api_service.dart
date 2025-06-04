import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/contraindication.dart';
import '../models/exercise.dart';
import '../models/current_workout.dart';
import '../models/completed_workout.dart';

class ApiService {
  static const _baseUrl = 'http://10.0.2.2:3000';
  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
  };
  
  static Future<void> register({
    required String email,
    required String name,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/register');
    final response = await http.post(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode({'email': email, 'name': name, 'password': password}),
    );
    _handleError(response, 'Не удалось завершить регистрацию');
  }

  static Future<void> resend({
    required String email,
    required String name,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/resend');
    final response = await http.post(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode({'email': email, 'name': name, 'password': password}),
    );
    _handleError(response, 'Не удалось отправить код повторно');
  }

  static Future<void> confirm({
    required String email,
    required String code,
  }) async {
    final uri = Uri.parse('$_baseUrl/confirm');
    final response = await http.post(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode({'email': email, 'code': code}),
    );
    _handleError(response, 'Код неверен или устарел');
  }
  
  static Future<void> deletePending(String email) async {
    final uri = Uri.parse('$_baseUrl/pending');
    final response = await http.delete(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode({'email': email}),
    );
    _handleError(response, 'Не удалось удалить временный код');
  }

  static Future<void> sendLoginCode(String email) async {
    final uri = Uri.parse('$_baseUrl/login/send-code');
    final response = await http.post(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode({'email': email}),
    );
    _handleError(response, 'Не удалось отправить код для входа');
  }

  static Future<String> confirmLoginCode({
    required String email,
    required String code,
  }) async {
    final uri = Uri.parse('$_baseUrl/login/confirm');
    final response = await http.post(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode({'email': email, 'code': code}),
    );
    _handleError(response, 'Не удалось подтвердить код');

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final token = data['token'] as String;
    await saveJwtToken(token);
    await saveCurrentUserEmail(email);
    return token;
  }

  static Future<void> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/login');
    final response = await http.post(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode({'email': email, 'password': password}),
    );
    _handleError(response, 'Ошибка авторизации');
  }

  static Future<void> resendLoginCode(String email) async {
    final uri = Uri.parse('$_baseUrl/login/resend');
    final response = await http.post(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode({'email': email}),
    );
    _handleError(response, 'Не удалось отправить код повторно');
  }

  static Future<bool> confirmResetCode(String email, String code) async {
    final uri = Uri.parse('$_baseUrl/reset-password/confirm-code');
    final response = await http.post(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode({'email': email, 'code': code}),
    );
    if (response.statusCode == 200) return true;

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['error'] != null) throw Exception(data['error']);
    return false;
  }

  static Future<void> sendResetCode(String email) async {
    final uri = Uri.parse('$_baseUrl/reset/send-code');
    final response = await http.post(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode({'email': email}),
    );
    _handleError(response, 'Не удалось отправить код');
  }

  static Future<void> resendResetCode(String email) async {
    final uri = Uri.parse('$_baseUrl/reset/resend');
    final response = await http.post(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode({'email': email}),
    );
    _handleError(response, 'Не удалось отправить новый код для сброса пароля');
  }

  static Future<void> updatePassword({
    required String email,
    required String newPassword,
  }) async {
    final uri = Uri.parse('$_baseUrl/reset-password/update');
    final response = await http.post(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode({'email': email, 'newPassword': newPassword}),
    );
    _handleError(response, 'Не удалось обновить пароль');
  }

  static Future<Map<String, dynamic>> fetchUserProfile() async {
    final token = await getJwtToken();
    if (token == null) throw Exception('Нет токена авторизации');

    final uri = Uri.parse('$_baseUrl/profile');
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    _handleError(response, 'Не удалось получить профиль');
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<void> updateUserProfile({
    required Map<String, dynamic> payload,
  }) async {
    final token = await getJwtToken();
    if (token == null) throw Exception('Нет токена авторизации');

    final uri = Uri.parse('$_baseUrl/profile/update');
    final response = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );
    _handleError(response, 'Не удалось обновить профиль');
  }

  static Future<void> updateUserName(String newName) async {
    final token = await getJwtToken();
    if (token == null) throw Exception('Нет токена авторизации');

    final uri = Uri.parse('$_baseUrl/profile/update-name');
    final response = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'name': newName}),
    );
    _handleError(response, 'Не удалось изменить имя');
  }

  static Future<void> saveTrackerData({
    required double heartRate,
    required int steps,
  }) async {
    final token = await getJwtToken();
    if (token == null) throw Exception('Нет токена авторизации');

    final uri = Uri.parse('$_baseUrl/profile/tracker');
    final response = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'lastHeartRate': heartRate,
        'lastSteps': steps,
      }),
    );
    _handleError(response, 'Не удалось сохранить данные трекера');
  }

  static Future<void> updateUserGoal(String goal) async {
    final token = await getJwtToken();
    if (token == null) throw Exception('Нет токена авторизации');

    final uri = Uri.parse('$_baseUrl/profile/update-goal');
    final response = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'goal': goal}),
    );
    _handleError(response, 'Не удалось изменить цель тренировки');
  }

  static Future<List<Contraindication>> fetchContraindications() async {
    final token = await getJwtToken();
    if (token == null) throw Exception('Нет токена авторизации');

    final uri = Uri.parse('$_baseUrl/contraindications');
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    _handleError(response, 'Не удалось получить список ограничений');

    final List<dynamic> rawList = jsonDecode(response.body) as List<dynamic>;
    return rawList
        .map((e) => Contraindication.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  static Future<List<Contraindication>> getUserContraindications() async {
    final profile = await fetchUserProfile();
    final List<dynamic> raw = profile['limitations'] as List<dynamic>? ?? [];
    return raw
        .map((e) => Contraindication.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  static Future<void> saveUserContraindications(
      List<Contraindication> list) async {
    final profile = await fetchUserProfile();
    final int height = (profile['height'] as num).toInt();
    final int weight = (profile['weight'] as num).toInt();
    final int age = (profile['age'] as num).toInt();
    final String gender = profile['gender'] as String;

    final payload = list.isEmpty
        ? ['no_limitations']
        : list.map((c) => c.toJson()).toList();

    await updateUserProfile(
      payload: {
        'height': height,
        'weight': weight,
        'age': age,
        'gender': gender,
        'limitations': payload.cast<String>(),
      },
    );
  }

  static Future<List<Exercise>> fetchAllExercises() async {
    final token = await getJwtToken();
    if (token == null) throw Exception('Нет токена авторизации');

    final uri = Uri.parse('$_baseUrl/exercises');
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    _handleError(response, 'Не удалось получить упражнения');

    final List<dynamic> rawList = jsonDecode(response.body) as List<dynamic>;
    return rawList
        .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  static Future<CurrentWorkout?> fetchCurrentWorkout() async {
    final token = await getJwtToken();
    if (token == null) throw Exception('Нет токена авторизации');

    final uri = Uri.parse('$_baseUrl/workout/current');
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 404) {
      // У пользователя ещё не было сохранённых тренировок
      return null;
    }

    _handleError(response, 'Не удалось получить текущую тренировку');

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    // Сервер возвращает { workout: { ... } }
    return CurrentWorkout.fromJson(data['workout'] as Map<String, dynamic>);
  }

  static Future<void> createWorkout({
    required String name,
    required List<String> exercises,
  }) async {
    final token = await getJwtToken();
    if (token == null) throw Exception('Нет токена авторизации');

    final uri = Uri.parse('$_baseUrl/workout');
    final body = {
      'name': name,
      'exercises': exercises,
    };

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 201) {
      final err = jsonDecode(response.body);
      throw Exception('Не удалось сохранить тренировку: ${err['error'] ?? response.statusCode}');
    }
  }

  static Future<void> completeWorkout({
    required Map<String, dynamic> payload,
  }) async {
    final token = await getJwtToken();
    if (token == null) throw Exception('Нет токена авторизации');

    final uri = Uri.parse('$_baseUrl/workout/complete');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Не удалось сохранить результаты тренировки');
    }
  }

  static Future<List<CompletedWorkout>> fetchWorkoutHistory({
    required List<Exercise> allExercises,
  }) async {
    final token = await getJwtToken();
    if (token == null) throw Exception('Нет токена авторизации');

    final uri = Uri.parse('$_baseUrl/workouts/history');
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    _handleError(response, 'Не удалось получить историю тренировок');

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final rawList = (data['workouts'] as List<dynamic>);

    final Map<String, String> nameMap = {
      for (var ex in allExercises) ex.id: ex.name
    };

    final history = rawList
        .map((raw) => CompletedWorkout.fromJson(raw as Map<String, dynamic>, nameMap))
        .toList(growable: false);

    return history;
  }

  static Future<void> saveCurrentUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_email', email);
  }

  static Future<String?> getCurrentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('current_email');
  }

  static Future<void> saveJwtToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getJwtToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('stay_logged_in');
    await prefs.remove('current_email');
  }

  static Future<void> setStayLoggedIn(bool stay) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('stay_logged_in', stay);
  }

  static Future<bool> getStayLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('stay_logged_in') ?? false;
  }

  static void _handleError(http.Response response, String fallbackMessage) {
    if (response.statusCode >= 400) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['error'] != null) {
          throw Exception(data['error']);
        } else {
          throw Exception(fallbackMessage);
        }
      } catch (_) {
        throw Exception(fallbackMessage);
      }
    }
  }
}
