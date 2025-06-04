import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  Widget _buildPasswordField({
    required TextEditingController ctrl,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    bool disablePaste = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
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
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE51919)),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? Icons.visibility_off : Icons.visibility,
              color: Colors.white70,
            ),
            onPressed: onToggle,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsViewModel(),
      child: Consumer<SettingsViewModel>(
        builder: (context, vm, _) {
          vm.registerContext(context);
          const bg = Color(0xFF211111);
          const card = Color(0xFF331919);
          const accent = Color(0xFFE51919);

          return Scaffold(
            backgroundColor: bg,
            appBar: AppBar(
              backgroundColor: bg,
              title: const Text('Настройки', style: TextStyle(color: Colors.white)),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // текущий email
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Аккаунт: ${vm.email ?? '...'}',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 24),

                // смена пароля
                const Text(
                  'Смена пароля',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Lexend-Bold',
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!vm.codeSent) ...[
                        ElevatedButton(
                          onPressed: vm.loading || vm.countdown > 0 ? null : vm.sendCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: vm.loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Получить код', style: TextStyle(color: Colors.white)),
                        ),
                        if (vm.countdown > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Повторная отправка через ${vm.countdown} с',
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                      ] else ...[
                        TextField(
                          controller: vm.codeCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Код из письма',
                            labelStyle: const TextStyle(color: Color(0xffc69393)),
                            filled: true,
                            fillColor: card,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xff663333)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: accent),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildPasswordField(
                          ctrl: vm.passCtrl,
                          label: 'Новый пароль',
                          obscure: vm.obscurePass,
                          onToggle: () => vm.obscurePass = !vm.obscurePass..then((_) => vm.notifyListeners()),
                        ),
                        if (vm.strengthLabel.isNotEmpty) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('Сложность: ',
                                      style: TextStyle(color: Colors.white70)),
                                  Text(vm.strengthLabel,
                                      style: TextStyle(
                                          color: vm.strengthColor,
                                          fontFamily: 'Lexend-Bold')),
                                ],
                              ),
                              Text(vm.strengthAdvice,
                                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                        _buildPasswordField(
                          ctrl: vm.confirmCtrl,
                          label: 'Подтвердите пароль',
                          obscure: vm.obscureConfirm,
                          onToggle: () =>
                              vm.obscureConfirm = !vm.obscureConfirm..then((_) => vm.notifyListeners()),
                          disablePaste: true,
                        ),
                        ElevatedButton(
                          onPressed: vm.loading ? null : vm.confirmChange,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: vm.loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Обновить пароль',
                                  style: TextStyle(color: Colors.white)),
                        ),
                        if (vm.countdown == 0)
                          Center(
                            child: TextButton(
                              onPressed: vm.sendCode,
                              child:
                                  const Text('Повторная отправка', style: TextStyle(color: Colors.white)),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Повторная отправка через ${vm.countdown} с',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                const Text(
                  'Удалить аккаунт',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Lexend-Bold',
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      if (!vm.delSent) ...[
                        ElevatedButton(
                          onPressed: vm.delLoading || vm.delCountdown > 0 ? null : vm.sendDelCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: vm.delLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Получить код удаления',
                                  style: TextStyle(color: Colors.white)),
                        ),
                        if (vm.delCountdown > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Повторная отправка через ${vm.delCountdown} с',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                      ] else ...[
                        TextField(
                          controller: vm.delCodeCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Код удаления',
                            labelStyle: const TextStyle(color: Color(0xffc69393)),
                            filled: true,
                            fillColor: card,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xff663333)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.redAccent),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: vm.delLoading ? null : vm.confirmDelete,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: vm.delLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Удалить аккаунт',
                                  style: TextStyle(color: Colors.white)),
                        ),
                        if (vm.delCountdown == 0)
                          Center(
                            child: TextButton(
                              onPressed: vm.resendDelCode,
                              child: const Text('Повторная отправка',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Повторная отправка через ${vm.delCountdown} с',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
