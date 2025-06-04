import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exercise.dart';
import '../viewmodels/exercise_session_viewmodel.dart';
import '../services/tracker_service.dart';

class ExerciseSessionPage extends StatelessWidget {
  final List<Exercise> exercises;
  final String workoutId;

  const ExerciseSessionPage({
    Key? key,
    required this.exercises,
    required this.workoutId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ExerciseSessionViewModel>(
      create: (_) => ExerciseSessionViewModel(
        exercises: exercises,
        workoutId: workoutId,
      ),
      child: const _ExerciseSessionView(),
    );
  }
}

class _ExerciseSessionView extends StatelessWidget {
  const _ExerciseSessionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ExerciseSessionViewModel>();
    final ex = vm.exercises[vm.currentIndex];

    if (vm.isResting) {
      return Scaffold(
        backgroundColor: const Color(0xff211111),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Отдых: ${vm.restSeconds} сек',
                style: const TextStyle(color: Colors.white, fontSize: 32),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: vm.addRestTime,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE51919),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '+10 сек',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Lexend-Bold',
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => vm.skipRestOrNext(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE51919),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  (vm.currentIndex < vm.exercises.length - 1)
                      ? 'Следующее упражнение'
                      : 'К результатам',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Lexend-Bold',
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xff211111),
      appBar: AppBar(
        backgroundColor: const Color(0xff211111),
        elevation: 0,
        title: Text(
          ex.name,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Lexend-Bold',
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (ex.isDurationBased) ...[
              Text(
                'Время: ${vm.elapsedSeconds} сек',
                style: const TextStyle(color: Colors.white70, fontSize: 18),
              ),
              const SizedBox(height: 4),
              Text(
                'Номинальная длительность: ${ex.defaultDuration} сек',
                style: const TextStyle(color: Colors.white70, fontSize: 18),
              ),
            ] else
              Text(
                'Повторений: ${ex.defaultReps}',
                style: const TextStyle(color: Colors.white70, fontSize: 18),
              ),
            const SizedBox(height: 8),
            StreamBuilder<int>(
              stream: TrackerService.getHeartRateStream(),
              builder: (context, snapshot) {
                final hr = snapshot.data;
                return Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.redAccent),
                    const SizedBox(width: 6),
                    Text(
                      hr != null ? '$hr' : '--',
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontFamily: 'Lexend-Bold',
                        fontSize: 18,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              ex.executionPlan,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => vm.finishExercise(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE51919),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Завершить упражнение',
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
      ),
    );
  }
}
