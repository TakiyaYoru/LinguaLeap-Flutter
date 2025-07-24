// lib/routes/app_router.dart - COMPLETE với Exercise Container
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:lingualeap_app/pages/practice/reading_practice_page.dart';


// Import các page
import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';
import '../pages/home_page.dart';
import '../pages/exercise/exercise_container_page.dart'; // ← NEW
import '../pages/practice/practice_page.dart';
import '../pages/practice/vocabulary_page.dart';
import '../pages/profile_page.dart';
import '../pages/settings_page.dart';
import '../network/auth_service.dart';
import '../models/user_model.dart';
import '../widgets/main_layout.dart';
import '../pages/learnmap_page.dart';

class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String courses = '/courses';
  static const String practice = '/practice';
  static const String vocabulary = '/vocabulary';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String courseDetail = '/course/:courseId';
  static const String unitDetail = '/unit/:unitId';
  static const String lessonDetail = '/lesson/:lessonId';
  static const String exerciseContainer = '/exercise/:lessonId'; // ← NEW
  static const String testBackend = '/test-backend';
  static const String testModels = '/test-models';
  static const String testUnits = '/test-units';
  
  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      // Auth routes (no shell)
      GoRoute(
        path: login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterPage(),
      ),
      
      // Reading practice route (no shell)
      GoRoute(
        path: '/reading-practice',
        builder: (context, state) => const ReadingPracticePage(),
      ),

      // Exercise container route (no shell) ← NEW
      GoRoute(
        path: exerciseContainer,
        builder: (context, state) {
          final lessonId = state.pathParameters['lessonId']!;
          
          // Get exercises from extra data
          final exercises = state.extra as List<Map<String, dynamic>>? ?? [];
          
          return ExerciseContainerPage(
            lessonId: lessonId,
            exercises: exercises,
          );
        },
      ),
      
      // Vocabulary route (no shell)
      GoRoute(
        path: vocabulary,
        builder: (context, state) => const VocabularyPage(),
      ),
      
      // Settings route (no shell)
      GoRoute(
        path: settings,
        builder: (context, state) => const SettingsPage(),
      ),
      
      // Main app with shell navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        branches: [
          // Home branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          
          // Courses branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: courses,
                builder: (context, state) => const LearnmapPage(),
              ),
            ],
          ),
          
          // Practice branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: practice,
                builder: (context, state) => const PracticePage(),
              ),
            ],
          ),
          
          // Profile branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: profile,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}