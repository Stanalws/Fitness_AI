// lib/views/tracker_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/tracker_viewmodel.dart';
import '../views/profile_page.dart';
import '../views/training_page.dart';
import '../views/results_page.dart';
import '../routes/slide_route.dart';

class TrackerPage extends StatelessWidget {
  const TrackerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TrackerViewModel(),
      child: Consumer<TrackerViewModel>(
        builder: (context, vm, _) {
          final screenWidth = MediaQuery.of(context).size.width;
          final buttonWidth = screenWidth * 0.4;
          const imageContainerHeight = 300.0;

          return Scaffold(
            backgroundColor: const Color(0xFF211111),
            body: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: screenWidth * 0.8,
                      height: imageContainerHeight,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              'assets/images/watch.png',
                              fit: BoxFit.contain,
                            ),
                          ),

                          if (vm.isLoading)
                            const Center(
                              child: CircularProgressIndicator(color: Colors.redAccent),
                            ),

                          if (!vm.isLoading && !vm.isAuthorized)
                            Center(
                              child: SizedBox(
                                width: buttonWidth,
                                height: 48,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE51919),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: vm.onButtonPressed,
                                  child: const Text(
                                    'Подключить',
                                    style: TextStyle(
                                      fontFamily: 'Lexend-Bold',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          if (!vm.isLoading && vm.isAuthorized)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.favorite, color: Colors.redAccent, size: 32),
                                    const SizedBox(width: 8),
                                    Text(
                                      vm.latestHeartRate.toStringAsFixed(0),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.directions_run, color: Colors.greenAccent, size: 32),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${vm.todaySteps}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (!vm.isLoading)
                      SizedBox(
                        width: buttonWidth,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196F3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () => vm.onSavePressed(context),
                          child: const Text(
                            'Сохранить',
                            style: TextStyle(
                              fontFamily: 'Lexend-Bold',
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(
                        height: 48,
                        width: 48,
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.blueAccent),
                        ),
                      ),

                    const SizedBox(height: 16),

                    if (!vm.isLoading && !vm.isAuthorized)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          'Для отображения данных\nнажмите «Подключить»',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: const Color(0xFF331919),
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white54,
              currentIndex: vm.currentIndex,
              type: BottomNavigationBarType.fixed,
              onTap: (index) => vm.onTapIndex(context, index),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
                BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Тренировка'),
                BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Трекер'),
                BottomNavigationBarItem(icon: Icon(Icons.timeline), label: 'Результаты'),
              ],
            ),
          );
        },
      ),
    );
  }
}
