import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../routes/slide_route.dart';
import '../views/confirm_page.dart';

class ResetPasswordViewModel extends ChangeNotifier {
  final TextEditingController emailCtrl = TextEditingController();
  String? errorText;

  @override
  void dispose() {
    emailCtrl.dispose();
    super.dispose();
  }

  Future<void> onSubmit(BuildContext context) async {
    final email = emailCtrl.text.trim();
    if (email.isEmpty) {
      errorText = 'Укажите email';
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
      await ApiService.sendResetCode(email);
      if (!context.mounted) return;
      Navigator.pop(context);

      Navigator.push(
        context,
        SlideLeftRoute(
          page: ConfirmPage.forReset(email: email),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }
}