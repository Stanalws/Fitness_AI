import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../routes/slide_route.dart';
import 'edit_profile_page.dart';
import 'login_page.dart';
import 'settings_page.dart';
import 'tracker_page.dart';
import 'training_page.dart';
import 'results_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  String _humanizeGoal(String code) {
    switch (code) {
      case 'похудение':
        return 'Похудение';
      case 'набор_мышечной_массы':
        return 'Набор массы';
      case 'выносливость':
        return 'Повышение выносливости';
      case 'тонус':
        return 'Тонус';
      default:
        return code;
    }
  }

  Widget _buildStatCard(String title, String value) {
    return Expanded(
      child: Card(
        color: const Color(0xff331919),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(color: Colors.white54)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLimitationsList(BuildContext context, List<String> limitations, bool showAll,
      void Function() toggleShow) {
    final display = showAll
        ? limitations
        : (limitations.length > 2 ? limitations.sublist(0, 2) : limitations);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: display
              .map((lim) => Chip(
                    label: Text(lim),
                    backgroundColor: const Color(0xff663333),
                    labelStyle: const TextStyle(color: Colors.white),
                  ))
              .toList(),
        ),
        if (limitations.length > 2)
          TextButton(
            onPressed: toggleShow,
            child: Text(
              showAll ? 'Скрыть' : 'Показать все',
              style: const TextStyle(color: Color(0xffE51919)),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(),
      child: Consumer<ProfileViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Scaffold(
              backgroundColor: Color(0xff211111),
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (vm.error != null) {
            return Scaffold(
              backgroundColor: const Color(0xff211111),
              body: Center(
                child: Text(
                  vm.error!,
                  style: const TextStyle(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final user = vm.user!;

          return Scaffold(
            backgroundColor: const Color(0xff211111),
            appBar: AppBar(
              backgroundColor: const Color(0xff211111),
              elevation: 0,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).push(
                    SlideLeftRoute(page: const SettingsPage()),
                  );
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () => vm.logout(context),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1) Аватар
                  Center(
                    child: GestureDetector(
                      onTap: vm.pickAvatar,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade800,
                        backgroundImage:
                            vm.avatarFile != null ? FileImage(vm.avatarFile!) : null,
                        child: vm.avatarFile == null
                            ? const Icon(Icons.camera_alt, color: Colors.white38, size: 40)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(user.name,
                            style: const TextStyle(color: Colors.white, fontSize: 24)),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white70),
                          onPressed: () => vm.editName(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (user.lastHeartRate != null && user.lastSteps != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.favorite, color: Colors.redAccent, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          '${user.lastHeartRate!.toStringAsFixed(0)} уд/мин',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.directions_run, color: Colors.greenAccent, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          '${user.lastSteps} шагов',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    const Text(
                      'Данные трекера не найдены',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                  ],

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatCard('Рост', '${user.height} см'),
                      _buildStatCard('Вес', '${user.weight} кг'),
                      _buildStatCard('Возраст', '${user.age}'),
                      _buildStatCard('Пол', user.gender),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        const Text(
                          'Цель:',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          user.goal != null && user.goal!.isNotEmpty
                              ? _humanizeGoal(user.goal!)
                              : 'Не указано',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
				  
                  const Text(
                    'Ограничения:',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  if (user.noContra)
                    const Text('Нет ограничений', style: TextStyle(color: Colors.white))
                  else
                    _buildLimitationsList(
                      context,
                      user.limitations,
                      vm.showAllLimitations,
                      vm.toggleShowAllLimitations,
                    ),
                  const SizedBox(height: 30),

                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        final updated = await Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditProfilePage(
                              initialHeight: user.height,
                              initialWeight: user.weight,
                              initialAge: user.age,
                              initialGender: user.gender,
                              initialLimitations: user.limitations,
                              initialNoContra: user.noContra,
                            ),
                          ),
                        );
                        if (updated != null) {
                          vm.user = user.copyWith(
                            height: updated['height'] as int,
                            weight: updated['weight'] as int,
                            age: updated['age'] as int,
                            gender: updated['gender'] as String,
                            limitations:
                                (updated['limitations'] as List<dynamic>).cast<String>(),
                            noContra:
                                (updated['limitations'] as List<dynamic>).contains('no_limitations'),
                          );
                          vm.notifyListeners();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffE51919),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: const Text('Заполнить/изменить анкету'),
                    ),
                  ),
                ],
              ),
            ),
			
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: vm.currentIndex,
              backgroundColor: const Color(0xff211111),
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white54,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
                BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Тренировка'),
                BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Трекер'),
                BottomNavigationBarItem(icon: Icon(Icons.timeline), label: 'Результаты'),
              ],
              onTap: (idx) {
                if (idx == vm.currentIndex) return;
                vm.setCurrentIndex(idx);
                switch (idx) {
                  case 1:
                    Navigator.of(context).pushReplacement(
                      SlideLeftRoute(page: const TrainingPage()),
                    );
                    break;
                  case 2:
                    Navigator.of(context).pushReplacement(
                      SlideLeftRoute(page: const TrackerPage()),
                    );
                    break;
                  case 3:
                    Navigator.of(context).pushReplacement(
                      SlideLeftRoute(page: const ResultsPage()),				  
                    break;
                  default:
                    break;
                }
              },
            ),
          );
        },
      ),
    );
  }
}
