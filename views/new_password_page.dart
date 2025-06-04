import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/new_password_viewmodel.dart';

class NewPasswordPage extends StatelessWidget {
  final String email;
  const NewPasswordPage({Key? key, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NewPasswordViewModel(email: email),
      child: Consumer<NewPasswordViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: const Color(0xFF211111),
            appBar: AppBar(
              backgroundColor: const Color(0xFF211111),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.only(top: 160, left: 16, right: 16, bottom: 16),
              child: ListView(
                children: [
                  const Text(
                    'Новый пароль',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Lexend-Bold',
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildPasswordField(
                    controller: vm.passCtrl,
                    label: 'Новый пароль',
                    obscure: vm.obscurePass,
                    onToggle: vm.toggleObscurePass,
                  ),
                  if (vm.strengthLabel.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 12, bottom: 4),
                      child: Row(
                        children: [
                          const Text('Сложность: ', style: TextStyle(color: Colors.white70)),
                          Text(
                            vm.strengthLabel,
                            style: TextStyle(color: vm.strengthColor, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12, bottom: 12),
                      child: Text(
                        vm.strengthAdvice,
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ),
                  ],
                  _buildPasswordField(
                    controller: vm.confirmCtrl,
                    label: 'Подтвердите пароль',
                    obscure: vm.obscureConfirm,
                    onToggle: vm.toggleObscureConfirm,
                    disablePaste: true,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => vm.onSubmit(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE51919),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      minimumSize: const Size(double.infinity, 48),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Обновить пароль',
                      style: TextStyle(
                        fontFamily: 'Lexend-Bold',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (vm.errorText != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      vm.errorText!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

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
