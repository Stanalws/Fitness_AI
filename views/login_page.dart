import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../viewmodels/login_viewmodel.dart';
import '../services/api_service.dart';
import 'registration_page.dart';
import '../routes/slide_route.dart';
import 'reset_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _viewModel = LoginViewModel();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Lexend-Regular',
          fontWeight: FontWeight.w100,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xffc69393)),
          filled: true,
          fillColor: const Color(0xff331919),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xff663333)),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _viewModel.obscurePass ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white54,
                  ),
                  onPressed: _viewModel.toggleObscure,
                )
              : null,
        ),
        obscureText: isPassword ? _viewModel.obscurePass : false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, _) {
          return ListView(
            children: [
              const SizedBox(height: 140),
              const Center(
                child: Text(
                  'Вход',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontFamily: 'Lexend-Bold',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _viewModel.emailCtrl,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'[А-Яа-яЁё]')),
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._\-]')),
                ],
              ),
              _buildTextField(
                controller: _viewModel.passCtrl,
                label: 'Пароль',
                keyboardType: TextInputType.visiblePassword,
                isPassword: true,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'[А-Яа-яЁё]')),
                  FilteringTextInputFormatter.allow(
                    RegExp(r'''[A-Za-z0-9 !"#\$%&'()*+,\-./:;<=>?@\[\\\]^_`{|}~]'''),
                  ),
                  LengthLimitingTextInputFormatter(32),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Оставаться в системе',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Lexend-Regular',
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                  value: _viewModel.stayLoggedIn,
                  onChanged: _viewModel.setStayLoggedIn,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.white,
                  checkColor: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: () => _viewModel.onLogin(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE51919),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Войти',
                    style: TextStyle(
                      fontFamily: 'Lexend-Bold',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (_viewModel.errorText != null) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _viewModel.errorText!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(SlideLeftRoute(page: const ResetPasswordPage()));
                },
                child: const Center(
                  child: Text(
                    'Забыли пароль?',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Lexend-Bold',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 130),
              const Center(
                child: Text(
                  'Ещё не зарегистрированы?',
                  style: TextStyle(
                    color: Colors.white70,
                    fontFamily: 'Lexend-Regular',
                    fontWeight: FontWeight.w100,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    SlideLeftRoute(page: const RegistrationPage()),
                  );
                },
                child: const Center(
                  child: Text(
                    'Зарегистрироваться',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Lexend-Bold',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}
