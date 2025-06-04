import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../views/profile_page.dart';
import '../routes/slide_route.dart';

class StartViewModel {
  Future<void> checkAutoLogin(BuildContext context) async {
    final stayLoggedIn = await ApiService.getStayLoggedIn();
    final token = await ApiService.getJwtToken();

    if (stayLoggedIn && token != null) {
      print('Автоматический вход: stay_logged_in=$stayLoggedIn, token найден');
      if (!context.mounted) return;
      Navigator.of(context).pushReplacement(
        SlideLeftRoute(page: const ProfilePage()),
      );
    } else {
      print('Автовход не выполнен: stay_logged_in=$stayLoggedIn, token=$token');
    }
  }
}
