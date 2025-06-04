import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../routes/slide_route.dart';
import '../views/login_page.dart';

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

class NewPasswordViewModel extends ChangeNotifier {
  final String email;
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController confirmCtrl = TextEditingController();
  bool obscurePass = true;
  bool obscureConfirm = true;
  String? errorText;
  String strengthLabel = '';
  Color strengthColor = Colors.transparent;
  String strengthAdvice = '';

  NewPasswordViewModel({required this.email}) {
    passCtrl.addListener(_checkPasswordStrength);
  }

  @override
  void dispose() {
    passCtrl.removeListener(_checkPasswordStrength);
    passCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  bool _hasSequential(String s) {
    if (s.length < 3) return false;
    for (int i = 0; i <= s.length - 3; i++) {
      int a = s.codeUnitAt(i), b = s.codeUnitAt(i + 1), c = s.codeUnitAt(i + 2);
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

    if (_hasSequential(pwd)) {
      label = 'Низкая';
      color = Colors.red;
      advice = 'Избегайте последовательностей (abc, 123 и т.д.)';
    } else if (score <= 2) {
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

    strengthLabel = label;
    strengthColor = color;
    strengthAdvice = advice;
    notifyListeners();
  }

  Future<void> onSubmit(BuildContext context) async {
    final pass = passCtrl.text;
    final confirm = confirmCtrl.text;

    if (strengthLabel == 'Низкая') {
      errorText = 'Повысьте уровень сложности пароля до "Средний"';
      notifyListeners();
      return;
    }

    if (pass.isEmpty || confirm.isEmpty) {
      errorText = 'Заполните оба поля';
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

    try {
      await ApiService.updatePassword(email: email, newPassword: pass);
      if (!context.mounted) return;
      Navigator.of(context).pushReplacement(SlideLeftRoute(page: const LoginPage()));
    } catch (e) {
      errorText = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void toggleObscurePass() {
    obscurePass = !obscurePass;
    notifyListeners();
  }

  void toggleObscureConfirm() {
    obscureConfirm = !obscureConfirm;
    notifyListeners();
  }
}
