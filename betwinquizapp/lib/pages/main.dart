import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:betwinquizapp/pages/Complete%20Profil%20Page/complete_profile_page.dart';
import 'package:betwinquizapp/pages/Game%20Type%20Selection%20Page/game_type_selection_page.dart';
import 'package:betwinquizapp/pages/Profile%20Page/profile_page.dart';
import 'package:betwinquizapp/pages/Quiz%20Page/quiz_page.dart';
import 'package:betwinquizapp/pages/Rankings%20Page/rankings_page.dart';
import 'package:betwinquizapp/pages/Register%20Page/register_page.dart';
import 'package:betwinquizapp/pages/Login%20Page/login_page.dart';
import 'package:betwinquizapp/pages/Home%20Page/home_page.dart';
import '../components/Theme.dart';
import '../services/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz App',
      theme: AppTheme.lightTheme.copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/':
            page = const LoginPage();
            break;
          case '/register':
            page = const RegisterPage();
            break;
          case '/home':
            page = const HomePage();
            break;
          case '/complete_profile_page':
            page = const CompleteProfilePage();
            break;
          case '/game-type-selection':
            page = const GameTypeSelectionPage();
            break;
          case '/quiz_page':
            page = const QuizPage();
            break;
          case '/rankings':
            page = const RankingsPage();
            break;
          case '/profile':
            page = const ProfilePage();
            break;
          default:
            page = const LoginPage();
        }

        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        );
      },
    );
  }
}
