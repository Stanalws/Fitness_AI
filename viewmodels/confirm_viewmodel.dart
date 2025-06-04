import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../routes/slide_route.dart';
import '../views/login_page.dart';
import '../views/new_password_page.dart';
import '../views/profile_page.dart';

class ConfirmViewModel extends ChangeNotifier {
  final String email;
  final String? name;
  final String? password;
  final String mode;
  late final List<TextEditingController> codeControllers;
  late final List<FocusNode> focusNodes;
  Timer? _timer;
  int remaining = 30;

  ConfirmViewModel({
    required this.email,
    this.name,
    this.password,
    this.mode = 'register',
  }) {
    codeControllers = List.generate(6, (_) => TextEditingController());
    focusNodes = List.generate(6, (_) => FocusNode());
    _startTimer();
  }

  bool get canResend => remaining == 0;
  bool get isLogin => mode == 'login';

  void _startTimer() {
    _timer?.cancel();
    remaining = 30;
    notifyListeners();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remaining > 0) {
        remaining--;
        notifyListeners();
      } else {
        t.cancel();
      }
    });
  }

  void clearAllFields() {
    for (final c in codeControllers) {
      c.clear();
    }
    focusNodes.first.requestFocus();
    notifyListeners();
  }

  Future<void> onResend(BuildContext context) async {
    if (!canResend) return;
    clearAllFields();
    _startTimer();

    try {
      if (mode == 'login') {
        await ApiService.resendLoginCode(email);
      } else if (mode == 'register') {
        await ApiService.deletePending(email);
        await ApiService.resend(
          email: email,
          name: name!,
          password: password!,
        );
      } else if (mode == 'reset') {
        await ApiService.sendResetCode(email);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Новый код выслан')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> onConfirm(BuildContext context) async {
    final code = codeControllers.map((c) => c.text).join();
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите все 6 цифр кода')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      if (mode == 'login') {
        await ApiService.confirmLoginCode(email: email, code: code);
        Navigator.pop(context);
        Navigator.of(context).pushAndRemoveUntil(
          SlideLeftRoute(page: const ProfilePage()),
          (_) => false,
        );
      } else if (mode == 'register') {
        await ApiService.confirm(email: email, code: code);
        Navigator.pop(context);
        Navigator.of(context).pushReplacement(
          SlideLeftRoute(page: const LoginPage()),
        );
      } else if (mode == 'reset') {
        final ok = await ApiService.confirmResetCode(email, code);
        Navigator.pop(context);
        if (!ok) throw Exception('Неверный код или срок действия истёк');

        Navigator.of(context).pushReplacement(
          SlideLeftRoute(page: NewPasswordPage(email: email)),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      clearAllFields();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<bool> onWillPop(BuildContext context) async {
    if (mode == 'register') {
      await ApiService.deletePending(email);
    }
    if (mode == 'login') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else {
      Navigator.pop(context);
    }
    return false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in codeControllers) {
      c.dispose();
    }
    for (final f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }
}
