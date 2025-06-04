import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ContraindicationsViewModel extends ChangeNotifier {
  List<dynamic> available = [];
  Set<String> selected = {};
  bool isLoading = true;
  String? error;

  final Map<String, List<String>> mutualExclusions = {
    'general_obesity_mild': ['general_obesity_severe'],
    'general_obesity_severe': ['general_obesity_mild'],
    'cv_hypertension': ['cv_hypotension'],
    'cv_hypotension': ['cv_hypertension'],
    'gyn_pregnancy_trim1': ['gyn_pregnancy_trim2', 'gyn_postpartum'],
    'gyn_pregnancy_trim2': ['gyn_pregnancy_trim1', 'gyn_postpartum'],
    'gyn_postpartum': ['gyn_pregnancy_trim1', 'gyn_pregnancy_trim2'],
    'general_diabetes_type1': ['general_diabetes_type2'],
    'general_diabetes_type2': ['general_diabetes_type1'],
  };

  Timer? _timer;
  int remaining = 30;
  bool get canResend => remaining == 0;

  ContraindicationsViewModel() {
    _loadContraindications();
  }

  Future<void> _loadContraindications() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final data = await ApiService.fetchContraindications();
      final allSelected = await ApiService.getUserContraindications();
      final selectedCodes = allSelected.where((code) => code != 'no_limitations').toList();

      available = data;
      selected = selectedCodes.toSet();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = 'Ошибка загрузки ограничений:\n$e';
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _showDiabetesWarning(BuildContext context) async {
    return await showGeneralDialog<bool>(
          context: context,
          barrierDismissible: false,
          barrierLabel: 'Диабет предупреждение',
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) {
            return const SizedBox.shrink();
          },
          transitionBuilder: (context, animation, secondaryAnimation, child) {
            return Transform.scale(
              scale: Curves.easeOutBack.transform(animation.value),
              child: Opacity(
                opacity: animation.value,
                child: Dialog(
                  backgroundColor: const Color(0xff331919),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Внимание',
                          style: TextStyle(
                            fontFamily: 'Lexend-Bold',
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'При сахарном диабете важно контролировать уровень сахара\n'
                          'перед и после тренировки.\n\n'
                          'Пожалуйста, проконсультируйтесь с врачом перед началом занятий.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Lexend-Regular',
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFFE51919),
                                textStyle: const TextStyle(
                                  fontFamily: 'Lexend-Bold',
                                  fontSize: 16,
                                ),
                              ),
                              child: const Text('Отмена'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFFE51919),
                                textStyle: const TextStyle(
                                  fontFamily: 'Lexend-Bold',
                                  fontSize: 16,
                                ),
                              ),
                              child: const Text('Понятно'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ) ??
        false;
  }

  Future<void> onCheckboxChanged(BuildContext context, bool? value, String code) async {
    if (value == true &&
        (code == 'general_diabetes_type1' || code == 'general_diabetes_type2')) {
      final accepted = await _showDiabetesWarning(context);
      if (!accepted) return;
    }

    if (value == true) {
      selected.add(code);
      final exclusions = mutualExclusions[code];
      if (exclusions != null) {
        for (var excl in exclusions) {
          selected.remove(excl);
        }
      }
    } else {
      selected.remove(code);
    }
    notifyListeners();
  }

  Future<void> saveSelection(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      final filtered = selected.where((c) => c != 'no_limitations').toList();
      await ApiService.saveUserContraindications(filtered);
      if (context.mounted) {
        Navigator.of(context).pop(filtered);
      }
    } catch (e) {
      error = 'Ошибка сохранения:\n$e';
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}