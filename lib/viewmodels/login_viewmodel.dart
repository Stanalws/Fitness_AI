import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../routes/slide_route.dart';
import '../views/confirm_page.dart';

class LoginViewModel extends ChangeNotifier {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  bool obscurePass = true;
  String? errorText;
  bool stayLoggedIn = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  void toggleObscure() {
    obscurePass = !obscurePass;
    notifyListeners();
  }

  void setStayLoggedIn(bool? value) {
    stayLoggedIn = value ?? false;
    notifyListeners();
  }

  Future<void> onLogin(BuildContext context) async {
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text;

    if (email.isEmpty || pass.isEmpty) {
      errorText = 'Укажите email и пароль';
      notifyListeners();
      return;
    }

    errorText = null;
    notifyListeners();

    try {
      await ApiService.login(email: email, password: pass);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('stay_logged_in', stayLoggedIn);

      Navigator.push(
        context,
        SlideLeftRoute(page: ConfirmPage(email: email, mode: 'login')),
      );
    } catch (e) {
      errorText = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }
}
