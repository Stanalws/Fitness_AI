import 'package:flutter/material.dart';
import '../routes/slide_route.dart';
import '../viewmodels/registration_viewmodel.dart';
import 'confirm_page.dart';
import 'login_page.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _viewModel = RegistrationViewModel();

  @override
  void initState() {
    super.initState();
    // слушатель уже подключён во ViewModel
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF211111),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF211111),
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
            child: ListView(
              children: [
                const Text(
                  'Регистрация',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Lexend-Bold',
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _viewModel.emailCtrl,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._\-]')),
                  ],
                ),
                _buildTextField(
                  controller: _viewModel.nameCtrl,
                  label: 'Имя',
                  keyboardType: TextInputType.name,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r"[A-Za-z\u0400-\u04FF ]")),
                    LengthLimitingTextInputFormatter(30),
                  ],
                ),
                _buildPasswordField(
                  controller: _viewModel.passCtrl,
                  label: 'Пароль',
                  obscure: _viewModel.obscurePass,
                  onToggle: () {
                    setState(() => _viewModel.obscurePass = !_viewModel.obscurePass);
                    _viewModel.notifyListeners();
                  },
                ),
                if (_viewModel.strengthLabel.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 4),
                    child: Row(
                      children: [
                        const Text('Сложность: ', style: TextStyle(color: Colors.white70)),
                        Text(
                          _viewModel.strengthLabel,
                          style: TextStyle(color: _viewModel.strengthColor, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 12),
                    child: Text(
                      _viewModel.strengthAdvice,
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ),
                ],
                _buildPasswordField(
                  controller: _viewModel.confirmPassCtrl,
                  label: 'Подтвердите пароль',
                  obscure: _viewModel.obscureConfirm,
                  onToggle: () {
                    setState(() => _viewModel.obscureConfirm = !_viewModel.obscureConfirm);
                    _viewModel.notifyListeners();
                  },
                  disablePaste: true,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE51919),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    minimumSize: const Size(double.infinity, 48),
                    elevation: 0,
                  ),
                  onPressed: () => _viewModel.createAccount(context),
                  child: const Text(
                    'Создать аккаунт',
                    style: TextStyle(
                      fontFamily: 'Lexend-Bold',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (_viewModel.errorText != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _viewModel.errorText!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 8),
                const Text(
                  'Продолжая, вы соглашаетесь с Условиями использования и Политикой конфиденциальности.',
                  style: TextStyle(
                    fontFamily: 'Lexend-Regular',
                    fontWeight: FontWeight.w100,
                    fontSize: 12,
                    color: Color(0xffc69393),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Уже зарегистрированы?',
                    style: TextStyle(
                      fontFamily: 'Lexend-Bold',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        SlideLeftRoute(page: const LoginPage()),
                      );
                    },
                    child: const Text(
                      'Войти',
                      style: TextStyle(
                        fontFamily: 'Lexend-Bold',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      );

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    bool disablePaste = false,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: controller,
          obscureText: obscure,
          enableSuggestions: false,
          autocorrect: false,
          enableInteractiveSelection: !disablePaste,
          toolbarOptions: ToolbarOptions(
            copy: !disablePaste,
            cut: !disablePaste,
            paste: !disablePaste,
            selectAll: !disablePaste,
          ),
          keyboardType: TextInputType.visiblePassword,
          inputFormatters: [
            if (disablePaste) SingleCharInputFormatter(),
            FilteringTextInputFormatter.allow(
              RegExp(r'''[A-Za-z0-9 !"#\$%&'()*+,\-./:;<=>?@\[\\\]\^_`{\|\}~]'''),
            ),
            LengthLimitingTextInputFormatter(32),
          ],
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off : Icons.visibility,
                color: Colors.white,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      );
}