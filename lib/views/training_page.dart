import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_service.dart';
import '../models/user.dart';
import '../models/exercise.dart';
import '../models/current_workout.dart';
import '../services/api_service.dart';
import '../routes/slide_route.dart';
import 'profile_page.dart';
import 'tracker_page.dart';
import 'exercise_session_page.dart';
import '../views/results_page.dart';
import '../viewmodels/training_viewmodel.dart';

class TrainingPage extends StatefulWidget {
  const TrainingPage({Key? key}) : super(key: key);

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  late TrainingViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = TrainingViewModel()..navigationContext = context;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TrainingViewModel>.value(
      value: _vm,
      child: Consumer<TrainingViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Scaffold(
              backgroundColor: Color(0xff211111),
              body:
                  Center(child: CircularProgressIndicator(color: Colors.redAccent)),
            );
          }

          return Scaffold(
            backgroundColor: const Color(0xff211111),
            appBar: AppBar(
              backgroundColor: const Color(0xff211111),
              elevation: 0,
              automaticallyImplyLeading: false,
              title: const Text(''),
            ),
            body: vm.selectedExercises.isEmpty
                ? _buildInitialView(context, vm)
                : _buildResultView(context, vm),
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: const Color(0xff331919),
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white54,
              currentIndex: vm.currentIndex,
              onTap: (idx) {
                if (idx == vm.currentIndex) return;
                Widget destination;
                switch (idx) {
                  case 0:
                    destination = const ProfilePage();
                    break;
                  case 1:
                    destination = const TrainingPage();
                    break;
                  case 2:
                    destination = const TrackerPage();
                    break;
                  case 3:
                    destination = const ResultsPage();
                    break;
                  default:
                    return;
                }
                Navigator.of(context).pushReplacement(
                  SlideLeftRoute(page: destination),
                );
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.fitness_center), label: 'Тренировка'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.favorite), label: 'Трекер'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.timeline), label: 'Результаты'),
              ],
              type: BottomNavigationBarType.fixed,
            ),
          );
        },
      ),
    );
  }

  Widget _buildInitialView(BuildContext context, TrainingViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/training_illustration.png',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 24),
          const Text(
            'Готовы тренироваться? Тогда нажмите «Подобрать тренировку»!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text(
            'Не забудьте указать цель и заполнить профиль!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: (vm.isGenerating) ? null : vm.generateTraining,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE51919),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: vm.isGenerating
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Подобрать тренировку',
                      style: TextStyle(
                        fontFamily: 'Lexend-Bold',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          if (vm.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                vm.error!,
                style: const TextStyle(color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => vm.showGoalPickerDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE51919),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: Text(
                vm.selectedGoal == null
                    ? 'Указать цель'
                    : (vm.allGoals[vm.selectedGoal!] ?? 'Не указано'),
                style: const TextStyle(
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
  }

  Widget _buildResultView(BuildContext context, TrainingViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Тестовая тренировка',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontFamily: 'Lexend-Bold',
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: vm.selectedExercises.length,
              itemBuilder: (context, index) {
                final ex = vm.selectedExercises[index];
                return Card(
                  color: const Color(0xff331919),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFE51919),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Lexend-Bold',
                        ),
                      ),
                    ),
                    title: Text(
                      ex.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Lexend-Regular',
                      ),
                    ),
                    subtitle: Text(
                      ex.type,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                    onTap: () => vm.showExerciseDetails(context, ex),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: (vm.currentWorkoutId == null)
                  ? null
                  : () {
                      Navigator.of(context).push(
                        SlideLeftRoute(
                          page: ExerciseSessionPage(
                            exercises: vm.selectedExercises,
                            workoutId: vm.currentWorkoutId!,
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE51919),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Начать тренировку',
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
  }
}
