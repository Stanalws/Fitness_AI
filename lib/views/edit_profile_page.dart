import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/edit_profile_viewmodel.dart';

class EditProfilePage extends StatelessWidget {
  final int initialHeight;
  final int initialWeight;
  final int initialAge;
  final String initialGender;
  final List<String> initialLimitations;
  final bool initialNoContra;

  const EditProfilePage({
    Key? key,
    required this.initialHeight,
    required this.initialWeight,
    required this.initialAge,
    required this.initialGender,
    required this.initialLimitations,
    required this.initialNoContra,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditProfileViewModel(
        initialHeight: initialHeight,
        initialWeight: initialWeight,
        initialAge: initialAge,
        initialGender: initialGender,
        initialLimitations: initialLimitations,
        initialNoContra: initialNoContra,
      ),
      child: Consumer<EditProfileViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: const Color(0xff211111),
            appBar: AppBar(
              backgroundColor: const Color(0xff331919),
              title: const Text('Редактировать профиль'),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Рост
                  TextField(
                    controller: vm.heightController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Рост (см)',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Вес
                  TextField(
                    controller: vm.weightController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Вес (кг)',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Возраст
                  TextField(
                    controller: vm.ageController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Возраст',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Пол
                  Row(
                    children: [
                      const Text('Пол:', style: TextStyle(color: Colors.white70)),
                      const SizedBox(width: 16),
                      Radio<String>(
                        value: 'Мужской',
                        groupValue: vm.gender,
                        onChanged: vm.setGender,
                        activeColor: const Color(0xffE51919),
                      ),
                      const Text('Мужской', style: TextStyle(color: Colors.white)),
                      const SizedBox(width: 16),
                      Radio<String>(
                        value: 'Женский',
                        groupValue: vm.gender,
                        onChanged: vm.setGender,
                        activeColor: const Color(0xffE51919),
                      ),
                      const Text('Женский', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    tileColor: const Color(0xff331919),
                    title: const Text(
                      'Нет ограничений по здоровью',
                      style: TextStyle(color: Colors.white),
                    ),
                    value: vm.noContra,
                    onChanged: vm.setNoContra,
                    activeColor: const Color(0xffE51919),
                    checkColor: Colors.white,
                  ),
                  if (!vm.noContra)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Выберите ограничения:', style: TextStyle(color: Colors.white70)),
                        TextButton(
                          onPressed: () => vm.selectLimitations(context),
                          child: const Text(
                            'Добавить/изменить',
                            style: TextStyle(color: Color(0xffE51919)),
                          ),
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: vm.limitations
                              .map((lim) => Chip(
                                    label: Text(lim, style: const TextStyle(color: Colors.white)),
                                    backgroundColor: const Color(0xff663333),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  if (vm.error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      vm.error!,
                      style: const TextStyle(color: Colors.redAccent),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: vm.isSaving ? null : () => vm.saveProfile(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffE51919),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: vm.isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Сохранить'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
