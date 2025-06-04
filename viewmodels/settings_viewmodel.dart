import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../routes/slide_route.dart';
import '../views/login_page.dart';

class SingleCharInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length - oldValue.text.length > 1) {
      return oldValue;
    }
    return newValue;
  }
}

class SettingsViewModel extends ChangeNotifier {
  String? email;

  final codeCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  bool obscurePass = true;
  bool obscureConfirm = true;
  bool codeSent = false;
  bool loading = false;
  int countdown = 0;
  Timer? _timer;

  String strengthLabel = '';
  Color strengthColor = Colors.transparent;
  String strengthAdvice = '';

  final delCodeCtrl = TextEditingController();
  bool delSent = false;
  bool delLoading = false;
  int delCountdown = 0;
  Timer? _delTimer;

  SettingsViewModel() {
    _loadEmail();
    passCtrl.addListener(_checkPasswordStrength);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _delTimer?.cancel();
    codeCtrl.dispose();
    passCtrl.removeListener(_checkPasswordStrength);
    passCtrl.dispose();
    confirmCtrl.dispose();
    delCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadEmail() async {
    final prefs = await SharedPreferences.getInstance();
    email = prefs.getString('current_email');
    notifyListeners();
  }

  void _startTimer({required bool isDelete}) {
    if (!isDelete) {
      countdown = 30;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (countdown == 0) {
          t.cancel();
        } else {
          countdown--;
          notifyListeners();
        }
      });
    } else {
      delCountdown = 30;
      _delTimer?.cancel();
      _delTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (delCountdown == 0) {
          t.cancel();
        } else {
          delCountdown--;
          notifyListeners();
        }
      });
    }
    notifyListeners();
  }

  bool _hasSequential(String s) {
    if (s.length < 3) return false;
    for (int i = 0; i <= s.length - 3; i++) {
      if (s.codeUnitAt(i + 1) == s.codeUnitAt(i) + 1 &&
          s.codeUnitAt(i + 2) == s.codeUnitAt(i + 1) + 1) {
        return true;
      }
    }
    return false;
  }

  void _checkPasswordStrength() {
    final pwd = passCtrl.text;
    int score = 0;
    if (pwd.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(pwd)) score++;
    if (RegExp(r'[a-z]').hasMatch(pwd)) score++;
    if (RegExp(r'\d').hasMatch(pwd)) score++;
    if (RegExp(r'''[ !"#\$%&'()*+,\-./:;<=>?@\[\\\]\^_`{\|\}~]''').hasMatch(pwd)) score++;

    String label, advice;
    Color color;
    if (_hasSequential(pwd) || score <= 2) {
      label = 'Низкая';
      color = Colors.redAccent;
      advice = 'Избегайте последовательностей и добавьте цифры, заглавные и спецсимволы';
    } else if (score <= 4) {
      label = 'Средняя';
      color = Colors.orangeAccent;
      advice = 'Удлините до ≥10 символов';
    } else {
      label = 'Высокая';
      color = Colors.greenAccent;
      advice = 'Отлично, надёжный пароль';
    }

    strengthLabel = label;
    strengthColor = color;
    strengthAdvice = advice;
    notifyListeners();
  }

  Future<void> sendCode() async {
    if (email == null) return;
    loading = true;
    notifyListeners();
    try {
      await ApiService.sendResetCode(email!);
      codeSent = true;
      _startTimer(isDelete: false);
      notifyListeners();
      ScaffoldMessenger.of(_scaffoldContext!).showSnackBar(
        const SnackBar(content: Text('Код отправлен')),
      );
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(_scaffoldContext!).showSnackBar(
        SnackBar(content: Text('Ошибка: $msg')),
      );
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> confirmChange() async {
    if (email == null) return;
    final code = codeCtrl.text.trim();
    final pass = passCtrl.text.trim();
    final conf = confirmCtrl.text.trim();
    if (code.isEmpty || pass.isEmpty || conf.isEmpty) {
      ScaffoldMessenger.of(_scaffoldContext!).showSnackBar(
        const SnackBar(content: Text('Заполните все поля')),
      );
      return;
    }
    if (pass != conf) {
      ScaffoldMessenger.of(_scaffoldContext!).showSnackBar(
        const SnackBar(content: Text('Пароли не совпадают')),
      );
      return;
    }
    if (strengthLabel == 'Низкая') {
      ScaffoldMessenger.of(_scaffoldContext!).showSnackBar(
        const SnackBar(content: Text('Пароль слишком слабый')),
      );
      return;
    }
    loading = true;
    notifyListeners();
    try {
      final ok = await ApiService.confirmResetCode(email!, code);
      if (!ok) throw 'Неверный код';
      await ApiService.updatePassword(email: email!, newPassword: pass);
      ScaffoldMessenger.of(_scaffoldContext!).showSnackBar(
        const SnackBar(content: Text('Пароль обновлён')),
      );
      codeCtrl.clear();
      passCtrl.clear();
      confirmCtrl.clear();
      codeSent = false;
      notifyListeners();
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(_scaffoldContext!).showSnackBar(
        SnackBar(content: Text('Ошибка: $msg')),
      );
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> sendDelCode() async {
    if (email == null) return;
    delLoading = true;
    notifyListeners();
    try {
      await ApiService.sendDeleteCode(email: email!);
      delSent = true;
      _startTimer(isDelete: true);
      notifyListeners();
      ScaffoldMessenger.of(_scaffoldContext!).showSnackBar(
        const SnackBar(content: Text('Код отправлен')),
      );
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(_scaffoldContext!).showSnackBar(
        SnackBar(content: Text('Ошибка: $msg')),
      );
    } finally {
      delLoading = false;
      notifyListeners();
    }
  }

  Future<void> confirmDelete() async {
    if (email == null) return;
    final code = delCodeCtrl.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(_scaffoldContext!).showSnackBar(
        const SnackBar(content: Text('Введите код')),
      );
      return;
    }
    delLoading = true;
    notifyListeners();
    try {
      await ApiService.deleteAccount(email: email!, code: code);
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Navigator.of(_scaffoldContext!).pushAndRemoveUntil(
        SlideLeftRoute(page: const LoginPage()),
        (_) => false,
      );
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(_scaffoldContext!).showSnackBar(
        SnackBar(content: Text('Ошибка: $msg')),
      );
    } finally {
      delLoading = false;
      notifyListeners();
    }
  }

  Future<void> resendDelCode() async {
    if (email == null) return;
    delLoading = true;
    notifyListeners();
    try {
      await ApiService.resendDeleteCode(email: email!);
      _startTimer(isDelete: true);
      ScaffoldMessenger.of(_scaffoldContext!).showSnackBar(
        const SnackBar(content: Text('Новый код отправлен')),
      );
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(_scaffoldContext!).showSnackBar(
        SnackBar(content: Text('Ошибка: $msg')),
      );
    } finally {
      delLoading = false;
      notifyListeners();
    }
  }

  BuildContext? _scaffoldContext;
  void registerContext(BuildContext ctx) {
    _scaffoldContext = ctx;
  }
}
