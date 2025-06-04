import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/reset_password_page.dart';
import 'pages/new_password_page.dart';
import 'pages/profile_page.dart';
import 'pages/edit_profile_page.dart';
import 'pages/contraindications_page.dart';
import 'pages/settings_page.dart';
import 'pages/tracker_page.dart';
import 'pages/training_page.dart';
import 'views/results_page.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness App',
      initialRoute: '/login',
      navigatorObservers: [routeObserver],
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const StartPage());

          case '/register':
            return MaterialPageRoute(builder: (_) => const RegistrationPage());

          case '/confirm':
            final args = settings.arguments as Map<String, dynamic>;
            return SlideLeftRoute(
              page: ConfirmPage(
                email: args['email'] as String,
                name: args['name'] as String,
                password: args['password'] as String,
              ),
            );

          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginPage());

          case '/reset-password':
            return MaterialPageRoute(builder: (_) => const ResetPasswordPage());

          case '/new-password':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => NewPasswordPage(
                email: args['email'] as String,
              ),
            );

          case '/profile':
            return MaterialPageRoute(builder: (_) => const ProfilePage());

          case '/edit-profile':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => EditProfilePage(
                initialHeight: args['initialHeight'] as int,
                initialWeight: args['initialWeight'] as int,
                initialAge: args['initialAge'] as int,
                initialGender: args['initialGender'] as String,
                initialLimitations:
                    (args['initialLimitations'] as List<dynamic>).cast<String>(),
                initialNoContra: args['initialNoContra'] as bool,
              ),
            );

          case '/contraindications':
            return MaterialPageRoute(
                builder: (_) => const ContraindicationsPage());

          case '/settings':
            return MaterialPageRoute(builder: (_) => const SettingsPage());

          case '/tracker':
            return MaterialPageRoute(builder: (_) => const TrackerPage());

          case '/training':
            return MaterialPageRoute(builder: (_) => const TrainingPage());

          case '/results':
            return MaterialPageRoute(builder: (_) => const ResultsPage());

          default:
            return null;
        }
      },
    );
  }
}
