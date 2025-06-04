import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/confirm_viewmodel.dart';
import '../routes/slide_route.dart';
import 'login_page.dart';
import 'new_password_page.dart';
import 'profile_page.dart';

class ConfirmPage extends StatelessWidget {
  final String email;
  final String? name;
  final String? password;
  final String mode;

  const ConfirmPage({
    Key? key,
    required this.email,
    this.name,
    this.password,
    this.mode = 'register',
  }) : super(key: key);

  factory ConfirmPage.forReset({required String email}) {
    return ConfirmPage(email: email, mode: 'reset');
  }

  bool get isLogin => mode == 'login';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ConfirmViewModel(
        email: email,
        name: name,
        password: password,
        mode: mode,
      ),
      child: Consumer<ConfirmViewModel>(
        builder: (context, vm, _) {
          final title = vm.mode == 'login'
              ? 'Введите код для входа'
              : vm.mode == 'reset'
                  ? 'Код для сброса пароля'
                  : 'Введите код для подтверждения регистрации';

          return WillPopScope(
            onWillPop: () => vm.onWillPop(context),
            child: Scaffold(
              backgroundColor: const Color(0xFF211111),
              appBar: AppBar(
                backgroundColor: const Color(0xFF211111),
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () async {
                    if (vm.mode == 'register') {
                      await vm.onWillPop(context);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.fromLTRB(16, 140, 16, 16),
                child: Column(
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'Lexend-Bold',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        6,
                        (i) => _buildDigitField(context, i),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => vm.onConfirm(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE51919),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Подтвердить',
                          style: TextStyle(
                            fontFamily: 'Lexend-Bold',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: vm.canResend ? () => vm.onResend(context) : null,
                      child: Text(
                        vm.canResend
                            ? 'Повторить отправку'
                            : 'Выслать код повторно через ${vm.remaining} сек',
                        style: TextStyle(
                          color: vm.canResend ? Colors.white : Colors.white54,
                          fontFamily: 'Lexend-Regular',
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDigitField(BuildContext context, int idx) {
    final vm = Provider.of<ConfirmViewModel>(context, listen: false);
    return SizedBox(
      width: 48,
      height: 48,
      child: TextField(
        controller: vm.codeControllers[idx],
        focusNode: vm.focusNodes[idx],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontFamily: 'Lexend-Bold',
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFF331919),
          counterText: '',
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF663333)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE51919), width: 2),
          ),
        ),
        onChanged: (v) {
          if (v.length > 1) {
            final digits = v.replaceAll(RegExp(r'\D'), '');
            for (var i = 0; i < 6; i++) {
              vm.codeControllers[i].text = i < digits.length ? digits[i] : '';
            }
            FocusScope.of(context).unfocus();
            return;
          }
          if (v.isNotEmpty) {
            if (idx < 5) {
              vm.focusNodes[idx + 1].requestFocus();
            } else {
              vm.focusNodes[idx].unfocus();
            }
          } else if (idx > 0) {
            vm.focusNodes[idx - 1].requestFocus();
          }
        },
      ),
    );
  }
}
