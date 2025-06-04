import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

class SingleCharInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length - oldValue.text.length > 1) return oldValue;
    return newValue;
  }
}

class RegistrationViewModel extends ChangeNotifier {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController confirmPassCtrl = TextEditingController();

  bool obscurePass = true;
  bool obscureConfirm = true;

  String? errorText;
  String strengthLabel = '';
  Color strengthColor = Colors.transparent;
  String strengthAdvice = '';

  RegistrationViewModel() {
    passCtrl.addListener(_checkPasswordStrength);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }

  @override
  void dispose() {
    passCtrl.removeListener(_checkPasswordStrength);
    emailCtrl.dispose();
    nameCtrl.dispose();
    passCtrl.dispose();
    confirmPassCtrl.dispose();
    super.dispose();
  }

  bool _hasSequential(String s) {
    if (s.length < 3) return false;
    final l = s.toLowerCase();
    for (int i = 0; i <= l.length - 3; i++) {
      int a = l.codeUnitAt(i), b = l.codeUnitAt(i + 1), c = l.codeUnitAt(i + 2);
      if (b == a + 1 && c == b + 1) return true;
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

    String label;
    Color color;
    String advice;

    if (score <= 2) {
      label = 'Низкая';
      color = Colors.red;
      advice = 'Добавьте цифры, заглавные буквы и спецсимволы';
    } else if (score <= 4) {
      label = 'Средняя';
      color = Colors.orange;
      advice = 'Увеличьте длину до ≥10 и добавьте спецсимволы';
    } else {
      label = 'Высокая';
      color = Colors.green;
      advice = 'Отлично! Пароль надёжный';
    }

    if (_hasSequential(pwd)) {
      label = 'Низкая';
      color = Colors.red;
      advice = 'Избегайте последовательностей (abc, 123 и т.д.)';
    }

    strengthLabel = label;
    strengthColor = color;
    strengthAdvice = advice;
    notifyListeners();
  }

  Future<void> createAccount(BuildContext context) async {
    final email = emailCtrl.text.trim();
    final name = nameCtrl.text.trim();
    final pass = passCtrl.text;
    final confirm = confirmPassCtrl.text;

    if (strengthLabel == 'Низкая') {
      errorText = 'Повысьте уровень сложности пароля до "Средний"';
      notifyListeners();
      return;
    }

    if ([email, name, pass, confirm].any((s) => s.isEmpty)) {
      errorText = 'Все поля обязательны для заполнения';
      notifyListeners();
      return;
    }

    if (pass != confirm) {
      errorText = 'Пароли не совпадают';
      notifyListeners();
      return;
    }

    errorText = null;
    notifyListeners();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await ApiService.register(email: email, name: name, password: pass);
      Navigator.pop(context);
      Navigator.of(context).push(
        SlideLeftRoute(
          page: ConfirmPage(
            email: email,
            name: name,
            password: pass,
            mode: 'register',
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      errorText = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }
}
