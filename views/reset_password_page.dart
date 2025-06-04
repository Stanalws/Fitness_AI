import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../routes/slide_route.dart';
import '../views/confirm_page.dart';
import '../viewmodels/reset_password_viewmodel.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ResetPasswordViewModel(),
      child: Consumer<ResetPasswordViewModel>(
        builder: (context, vm, _) {
          return WillPopScope(
            onWillPop: () async {
              Navigator.pop(context);
              return false;
            },
            child: Scaffold(
              backgroundColor: const Color(0xFF211111),
              appBar: AppBar(
                backgroundColor: const Color(0xFF211111),
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 190),
                    const Center(
                      child: Text(
                        'Восстановление пароля',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontFamily: 'Lexend-Bold',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: vm.emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._\-]')),
                      ],
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Lexend-Regular',
                        fontWeight: FontWeight.w100,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Color(0xffc69393)),
                        filled: true,
                        fillColor: const Color(0xff331919),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xff663333)),
                        ),
                      ),
                    ),
                    if (vm.errorText != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        vm.errorText!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => vm.onSubmit(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffe51919),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Продолжить',
                          style: TextStyle(
                            fontFamily: 'Lexend-Bold',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Colors.white,
                          ),
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
}
