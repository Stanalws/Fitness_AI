import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../views/contraindications_page.dart';

class EditProfileViewModel extends ChangeNotifier {
  final TextEditingController heightController;
  final TextEditingController weightController;
  final TextEditingController ageController;

  String gender;
  List<String> limitations;
  bool noContra;
  bool isSaving = false;
  String? error;

  EditProfileViewModel({
    required int initialHeight,
    required int initialWeight,
    required int initialAge,
    required String initialGender,
    required List<String> initialLimitations,
    required bool initialNoContra,
  })  : heightController =
            TextEditingController(text: initialHeight.toString()),
        weightController =
            TextEditingController(text: initialWeight.toString()),
        ageController = TextEditingController(text: initialAge.toString()),
        gender = initialGender,
        limitations = List<String>.from(initialLimitations),
        noContra = initialNoContra;

  @override
  void dispose() {
    heightController.dispose();
    weightController.dispose();
    ageController.dispose();
    super.dispose();
  }

  Future<void> selectLimitations(BuildContext context) async {
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(builder: (_) => const ContraindicationsPage()),
    );
    if (result != null) {
      limitations = List<String>.from(result);
      noContra = false;
      notifyListeners();
    }
  }

  Future<void> saveProfile(BuildContext context) async {
    final h = int.tryParse(heightController.text.trim()) ?? 0;
    final w = int.tryParse(weightController.text.trim()) ?? 0;
    final a = int.tryParse(ageController.text.trim()) ?? 0;

    if (h < 100 || h > 251) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Рост должен быть от 100 до 251 см')),
      );
      return;
    }
    if (w < 30 || w > 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Вес должен быть от 30 до 300 кг')),
      );
      return;
    }
    if (a < 10 || a > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Возраст должен быть от 10 до 100 лет')),
      );
      return;
    }

    isSaving = true;
    error = null;
    notifyListeners();

    try {
      final updatedUser = await UserService.updateUser(
        height: h,
        weight: w,
        age: a,
        gender: gender,
        limitations: limitations,
        noContra: noContra,
      );
      Navigator.of(context).pop(<String, dynamic>{
        'height': updatedUser.height,
        'weight': updatedUser.weight,
        'age': updatedUser.age,
        'gender': updatedUser.gender,
        'limitations': updatedUser.limitations,
      });
    } catch (e) {
      error = 'Ошибка при сохранении:\n$e';
      isSaving = false;
      notifyListeners();
    }
  }

  void setGender(String? value) {
    if (value != null) {
      gender = value;
      notifyListeners();
    }
  }

  void setNoContra(bool? value) {
    noContra = value ?? false;
    if (noContra) {
      limitations.clear();
    }
    notifyListeners();
  }
}
