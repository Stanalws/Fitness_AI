import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/results_viewmodel.dart';
import 'package:fl_chart/fl_chart.dart'; // для LineChart 
import '../views/profile_page.dart';
import '../views/training_page.dart';
import '../views/tracker_page.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({Key? key}) : super(key: key);

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ResultsViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = ResultsViewModel();
    _vm.init();

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _vm.disposeModel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ResultsViewModel>.value(
      value: _vm,
      child: Consumer<ResultsViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: const Color(0xff211111),
            appBar: AppBar(
              backgroundColor: const Color(0xff211111),
              elevation: 0,
              title: const Text(
                'Результаты',
                style: TextStyle(
                    color: Colors.white, fontFamily: 'Lexend-Bold'),
              ),
              centerTitle: true,
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.redAccent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                tabs: const [
                  Tab(text: 'История'),
                  Tab(text: 'Показатели'),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                vm.buildHistoryTab(context),
                vm.buildMetricsTab(context),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: vm.currentIndex,
              backgroundColor: const Color(0xff331919),
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white54,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: 'Профиль'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.fitness_center), label: 'Тренировка'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.favorite), label: 'Трекер'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.timeline), label: 'Результаты'),
              ],
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
            ),
          );
        },
      ),
    );
  }
}
