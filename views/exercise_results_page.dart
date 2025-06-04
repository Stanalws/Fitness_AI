import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exercise.dart';
import '../viewmodels/exercise_results_viewmodel.dart';

class ExerciseResultsPage extends StatelessWidget {
  final String workoutId;
  final List<Exercise> exercises;
  final Map<String, int> performedDuration;
  final Map<String, int> performedReps;
  final Map<String, double> avgHeartRate;

  const ExerciseResultsPage({
    Key? key,
    required this.workoutId,
    required this.exercises,
    required this.performedDuration,
    required this.performedReps,
    required this.avgHeartRate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ExerciseResultsViewModel>(
      create: (_) => ExerciseResultsViewModel(
        workoutId: workoutId,
        exercises: exercises,
        performedDuration: performedDuration,
        performedReps: performedReps,
        avgHeartRate: avgHeartRate,
      ),
      child: const _ExerciseResultsContent(),
    );
  }
}

class _ExerciseResultsContent extends StatefulWidget {
  const _ExerciseResultsContent({Key? key}) : super(key: key);

  @override
  State<_ExerciseResultsContent> createState() => _ExerciseResultsContentState();
}

class _ExerciseResultsContentState extends State<_ExerciseResultsContent> {
  @override
  void dispose() {
    // Сохраняем логику dispose() в ViewModel
    context.read<ExerciseResultsViewModel>().disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ExerciseResultsViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xff211111),
      appBar: AppBar(
        backgroundColor: const Color(0xff211111),
        elevation: 0,
        title: const Text(
          'Результаты тренировки',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Lexend-Bold',
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Text(
              'Пожалуйста, укажите, сколько повторений вам удалось выполнить и оцените сложность выполнения упражнения. Длительность автоматически заполнена.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Lexend-Regular',
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Form(
                key: vm.formKey,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    for (var ex in vm.exercises)
                      Card(
                        color: const Color(0xff331919),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ex.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),

                              if (ex.isDurationBased) ...[
                                Text(
                                  'Рекомендовано: ${ex.defaultDuration} сек',
                                  style: const TextStyle(color: Colors.white54),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Выполнено: ${vm.performedDuration[ex.id] ?? 0} сек',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ] else ...[
                                Text(
                                  'Рекомендовано: ${ex.defaultReps} повторений',
                                  style: const TextStyle(color: Colors.white54),
                                ),
                                const SizedBox(height: 4),
                                TextFormField(
                                  controller: vm.repsControllers[ex.id],
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    labelText: 'Выполнено повторений',
                                    labelStyle: TextStyle(color: Colors.white70),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.white30),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.white),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Введите число повторений';
                                    }
                                    final parsed = int.tryParse(value);
                                    if (parsed == null || parsed < 0) {
                                      return 'Нужно число ≥ 0';
                                    }
                                    return null;
                                  },
                                ),
                              ],

                              const SizedBox(height: 8),
                              Text(
                                'Средний пульс: ${vm.avgHeartRate[ex.id]?.round() ?? 0}',
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  const Text(
                                    'Сложность:',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  const SizedBox(width: 8),
                                  DropdownButton<int>(
                                    value: vm.getDifficulty(ex.id),
                                    dropdownColor: const Color(0xff331919),
                                    style: const TextStyle(color: Colors.white),
                                    items: [1, 2, 3, 4, 5]
                                        .map((lvl) => DropdownMenuItem<int>(
                                              value: lvl,
                                              child: Text(
                                                lvl.toString(),
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        vm.setDifficulty(ex.id, val);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: vm.isSaving ? null : () => vm.saveResults(context),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  vm.isSaving ? Colors.grey : const Color(0xFFE51919),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
            child: vm.isSaving
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Сохранить результаты',
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
    );
  }
}
