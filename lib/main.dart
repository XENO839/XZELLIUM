import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// Screens
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/guest_result_screen.dart';
import 'screens/short_assessment_screen.dart';
import 'screens/category_selection_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/full_assessment_screen.dart';
import 'screens/result_screen.dart';
import 'screens/mock_interview_screen.dart';
import 'screens/interview_feedback_screen.dart';

// Auth Guard
import 'widgets/auth_guard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase already initialized or failed once, no rethrow needed.
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xzellium',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0E0E12),
        fontFamily: 'Inter',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE9455A),
          brightness: Brightness.dark,
        ),
      ),
      home: const AuthGate(),
      onGenerateRoute: _generateRoute,
    );
  }

  Route _generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    late Widget page;

    switch (settings.name) {
      case '/auth':
        page = const AuthScreen();
        break;

      case '/home':
        page = const AuthProtectedPage(child: HomeScreen());
        break;

      case '/guest-result':
        page = const GuestResultScreen();
        break;

      case '/short-assessment':
        page = const ShortAssessmentScreen();
        break;

      case '/category-select':
        page = const CategorySelectionScreen();
        break;

      case '/full-assessment':
        if (args is String) {
          page = AuthProtectedPage(child: FullAssessmentScreen(domain: args));
        } else {
          page = const AuthProtectedPage(child: HomeScreen());
        }
        break;

      case '/result':
        if (args is Map<String, dynamic> &&
            args.containsKey('scorePercent') &&
            args.containsKey('domain')) {
          page = AuthProtectedPage(
            child: ResultScreen(
              scorePercent: args['scorePercent'],
              domain: args['domain'],
            ),
          );
        } else {
          page = const AuthProtectedPage(child: HomeScreen());
        }
        break;

      case '/mock-interview':
        page = const AuthProtectedPage(child: MockInterviewScreen());
        break;

      case '/interview-feedback':
        if (args is String) {
          page = AuthProtectedPage(
            child: InterviewFeedbackScreen(feedback: args),
          );
        } else {
          page = const AuthProtectedPage(child: HomeScreen());
        }
        break;

      default:
        page = const LandingScreen();
    }

    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFE9455A)),
            ),
          );
        }

        if (snapshot.hasData) {
          return const HomeScreen();
        } else {
          return const LandingScreen();
        }
      },
    );
  }
}
