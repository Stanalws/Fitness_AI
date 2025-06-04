import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/user_service.dart';
import '../routes/slide_route.dart';
import '../views/login_page.dart';

class ProfileViewModel extends ChangeNotifier {
  User? user;
  bool isLoading = true;
  String? error;
  File? avatarFile;
  bool showAllLimitations = false;
  int currentIndex = 0;

  ProfileViewModel() {
    loadUser();
  }

  Future<void> loadUser() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final fetched = await UserService.getCurrentUser();
      user = fetched;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = 'Не удалось загрузить профиль:\n$e';
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout(BuildContext context) async {
    await ApiService.clearAuthData();
    UserService.clearCache();
    Navigator.of(context).pushReplacement(
      SlideLeftRoute(page: const LoginPage()),
    );
  }

  Future<void> pickAvatar() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Обрезка',
          toolbarColor: Colors.black,
          backgroundColor: Colors.black,
          activeControlsWidgetColor: Colors.red,
          hideBottomControls: true,
          lockAspectRatio: true,
          initAspectRatio: CropAspectRatioPreset.square,
        ),
        IOSUiSettings(
          title: 'Обрезка',
          aspectRatioLockEnabled: true,
        ),
      ],
    );
    if (cropped == null) return;
    avatarFile = File(cropped.path);
    notifyListeners();
  }

  Future<void> editName(BuildContext context) async {
    if (user == null) return;
    final controller = TextEditingController(text: user!.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xff331919),
          title: const Text(
            'Изменить имя',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r"[A-Za-z\u0400-\u04FF ]")),
              LengthLimitingTextInputFormatter(30),
            ],
            decoration: const InputDecoration(
              hintText: 'Новый никнейм',
              hintStyle: TextStyle(color: Colors.white38),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена', style: TextStyle(color: Color(0xFFE51919))),
            ),
            TextButton(
              onPressed: () {
                final txt = controller.text.trim();
                if (txt.isNotEmpty) Navigator.of(context).pop(txt);
              },
              child: const Text('Сохранить', style: TextStyle(color: Color(0xFFE51919))),
            ),
          ],
        );
      },
    );

    if (newName != null && newName.isNotEmpty) {
      try {
        final updatedUser = await UserService.updateName(newName);
        user = updatedUser;
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Имя обновлено')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка обновления имени:\n$e')),
        );
      }
    }
  }

  void toggleShowAllLimitations() {
    showAllLimitations = !showAllLimitations;
    notifyListeners();
  }

  void setCurrentIndex(int idx) {
    currentIndex = idx;
    notifyListeners();
  }
}
