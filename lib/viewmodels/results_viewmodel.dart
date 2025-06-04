import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/completed_workout.dart';
import '../models/exercise.dart';
import '../services/api_service.dart';
import '../routes/slide_route.dart';
import '../views/profile_page.dart';
import '../views/training_page.dart';
import '../views/tracker_page.dart';

class ResultsViewModel extends ChangeNotifier {
  List<Exercise> _allExercises = [];
  Future<List<CompletedWorkout>>? _historyFuture;

  final int _currentIndex = 3;

  List<Exercise> get allExercises => _allExercises;
  Future<List<CompletedWorkout>> get historyFuture => _historyFuture!;
  int get currentIndex => _currentIndex;

  void init() {
    ApiService.fetchAllExercises().then((list) {
      _allExercises = list;
      _historyFuture = ApiService.fetchWorkoutHistory(allExercises: _allExercises);
      notifyListeners();
    }).catchError((e) {
      _allExercises = [];
      _historyFuture = Future.error(e);
      notifyListeners();
    });
  }

  void disposeModel() {

  }

  Widget buildHistoryTab(BuildContext context) {
    return FutureBuilder<List<CompletedWorkout>>(
      future: historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.redAccent),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Ошибка загрузки истории:\n${snapshot.error}',
              style: const TextStyle(color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
          );
        }
        final history = snapshot.data!;
        if (history.isEmpty) {
          return const Center(
            child: Text(
              'У вас ещё нет завершённых тренировок',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final w = history[index];
            return Card(
              color: const Color(0xff331919),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ListTile(
                title: Text(
                  w.name,
                  style: const TextStyle(
                      color: Colors.white, fontFamily: 'Lexend-Regular'),
                ),
                subtitle: Text(
                  // ДД.MM.ГГГГ
                  '${w.dateCompleted.day.toString().padLeft(2, '0')}.' 
                  '${w.dateCompleted.month.toString().padLeft(2, '0')}.' 
                  '${w.dateCompleted.year}',
                  style: const TextStyle(color: Colors.white54),
                ),
                trailing:
                    const Icon(Icons.chevron_right, color: Colors.white54),
                onTap: () => _showWorkoutDetails(context, w),
              ),
            );
          },
        );
      },
    );
  }

  void _showWorkoutDetails(BuildContext context, CompletedWorkout w) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xff211111),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxHeight: 500),
            child: Column(
              children: [
                Text(
                  w.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Lexend-Bold',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Дата: ${w.dateCompleted.day.toString().padLeft(2, '0')}.' 
                  '${w.dateCompleted.month.toString().padLeft(2, '0')}.' 
                  '${w.dateCompleted.year}',
                  style: const TextStyle(color: Colors.white54),
                ),
                const Divider(color: Colors.white24, height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: w.exercises.length,
                    itemBuilder: (context, i) {
                      final ex = w.exercises[i];
                      return Card(
                        color: const Color(0xff2a2424),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ex.exerciseName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (ex.isDurationBased) ...[
                                Text(
                                  'Рекомендовано: ${ex.recommendedDuration} сек',
                                  style: const TextStyle(color: Colors.white54),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Выполнено: ${ex.performedDuration} сек',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ] else ...[
                                Text(
                                  'Рекомендовано: ${ex.recommendedReps} повторений',
                                  style: const TextStyle(color: Colors.white54),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Выполнено: ${ex.performedReps} повторений',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Средний пульс: ${ex.avgHeartRate}',
                                    style:
                                        const TextStyle(color: Colors.redAccent),
                                  ),
                                  Text(
                                    'Сложность: ${ex.difficulty}',
                                    style:
                                        const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE51919),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Закрыть',
                      style: TextStyle(
                          color: Colors.white, fontFamily: 'Lexend-Bold'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildMetricsTab(BuildContext context) {
    return FutureBuilder<List<CompletedWorkout>>(
      future: historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.redAccent),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Ошибка загрузки метрик:\n${snapshot.error}',
              style: const TextStyle(color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
          );
        }
        final allHistory = snapshot.data!;
        if (allHistory.isEmpty) {
          return const Center(
            child: Text(
              'Нет данных для графиков',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        final recent = allHistory.length <= 5
            ? allHistory
            : allHistory.sublist(allHistory.length - 5);

        final List<double> hrPoints = [];
        final List<double> percentPoints = [];
        final List<double> diffPoints = [];
        final List<String> labels = [];

        for (var w in recent) {
          double sumHr = 0;
          int cntHr = 0;
          for (var ex in w.exercises) {
            sumHr += ex.avgHeartRate;
            cntHr++;
          }
          final avgHrWorkout = cntHr > 0 ? sumHr / cntHr : 0.0;
          hrPoints.add(avgHrWorkout);

          double sumPct = 0;
          int cntPct = 0;
          for (var ex in w.exercises) {
            if (ex.isDurationBased) {
              if (ex.recommendedDuration > 0) {
                sumPct += ex.performedDuration / ex.recommendedDuration * 100;
                cntPct++;
              }
            } else {
              if (ex.recommendedReps > 0) {
                sumPct += ex.performedReps / ex.recommendedReps * 100;
                cntPct++;
              }
            }
          }
          final avgPctWorkout = cntPct > 0 ? sumPct / cntPct : 0.0;
          percentPoints.add(avgPctWorkout);

          double sumDiff = 0;
          int cntDiff = 0;
          for (var ex in w.exercises) {
            sumDiff += ex.difficulty;
            cntDiff++;
          }
          final avgDiffWorkout = cntDiff > 0 ? sumDiff / cntDiff : 0.0;
          diffPoints.add(avgDiffWorkout);

          labels.add(
            '${w.dateCompleted.day.toString().padLeft(2, '0')}.' 
            '${w.dateCompleted.month.toString().padLeft(2, '0')}',
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildChartSection(
                title: 'Средний пульс тренировки',
                labels: labels,
                values: hrPoints,
                yUnit: 'уд/мин',
                maxY: (hrPoints.reduce((a, b) => a > b ? a : b) * 1.2)
                    .ceilToDouble(),
              ),
              const SizedBox(height: 24),
              _buildChartSection(
                title: 'Средний % выполнения упражнений',
                labels: labels,
                values: percentPoints,
                yUnit: '%',
                maxY: 100,
              ),
              const SizedBox(height: 24),
              _buildChartSection(
                title: 'Средняя сложность тренировки',
                labels: labels,
                values: diffPoints,
                yUnit: '',
                maxY: 5,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChartSection({
    required String title,
    required List<String> labels,
    required List<double> values,
    required String yUnit, // единица измерения
    required double maxY,
  }) {
    if (values.length < 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:
                const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Lexend-Bold'),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Недостаточно данных для построения графика',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < values.length; i++) {
      spots.add(FlSpot(i.toDouble(), values[i]));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Lexend-Bold'),
            ),
            Text(
              yUnit,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              backgroundColor: const Color(0xff211111),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => const FlLine(color: Colors.white12),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: maxY / 5,
                    getTitlesWidget: (value, _) {
                      final int intVal = value.toInt();
                      return Text(
                        '$intVal',
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      );
                    },
                    reservedSize: 32,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      if (value % 1 != 0) return const SizedBox.shrink();
                      final idx = value.toInt();
                      if (idx < 0 || idx >= labels.length) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        labels[idx],
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      );
                    },
                    reservedSize: 28,
                  ),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true,
                border: const Border(
                  left: BorderSide(color: Colors.white24),
                  bottom: BorderSide(color: Colors.white24),
                ),
              ),
              minX: 0,
              maxX: (values.length - 1).toDouble(),
              minY: 0,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  barWidth: 3,
                  color: Colors.redAccent,
                  dotData: FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
