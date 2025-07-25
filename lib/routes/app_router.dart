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
// ✅ NEW: Import admin pages
import '../pages/admin/admin_dashboard_page.dart';
import '../pages/admin/course_form_page.dart';
import '../pages/admin/unit_form_page.dart';
import '../pages/admin/course_detail_page.dart';
import '../pages/admin/lesson_form_page.dart';
import '../pages/admin/unit_detail_page.dart';
import '../pages/admin/lesson_detail_page.dart';
import '../pages/admin/exercise_form_page.dart';

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
  
  // ✅ NEW: Admin routes
  static const String adminDashboard = '/admin';
  static const String adminCourses = '/admin/courses';
  static const String adminUsers = '/admin/users';
  static const String adminCreateCourse = '/admin/courses/create';
  static const String adminEditCourse = '/admin/courses/edit/:courseId';
  static const String adminCreateUnit = '/admin/units/create';
  static const String adminEditUnit = '/admin/units/edit/:unitId';
  static const String adminCourseDetail = '/admin/courses/:courseId';
  static const String adminCreateLesson = '/admin/lessons/create';
  static const String adminEditLesson = '/admin/lessons/edit/:lessonId';
  static const String adminUnitDetail = '/admin/units/:unitId';
  static const String adminCreateExercise = '/admin/exercises/create';
  static const String adminEditExercise = '/admin/exercises/edit/:exerciseId';
  static const String adminLessonDetail = '/admin/lessons/:lessonId';
  
  static final GoRouter router = GoRouter(
    initialLocation: home,
    redirect: (context, state) async {
      // ✅ NEW: Check if user is admin and redirect to admin dashboard
      final isAdmin = await AuthService.isAdmin();
      final isLoggedIn = await AuthService.getToken() != null;
      
      // If not logged in and trying to access protected routes
      if (!isLoggedIn && state.matchedLocation != login && state.matchedLocation != register) {
        return login;
      }
      
      // If admin is logged in and trying to access regular routes, redirect to admin dashboard
      if (isAdmin && isLoggedIn && 
          !state.matchedLocation.startsWith('/admin') && 
          state.matchedLocation != login && 
          state.matchedLocation != register) {
        return adminDashboard;
      }
      
      // If regular user is logged in and trying to access admin routes
      if (!isAdmin && isLoggedIn && state.matchedLocation.startsWith('/admin')) {
        return home;
      }
      
      return null;
    },
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
      
      // ✅ NEW: Admin routes (no shell)
      GoRoute(
        path: adminDashboard,
        builder: (context, state) => const AdminDashboardPage(),
      ),
      GoRoute(
        path: adminCourses,
        builder: (context, state) => const AdminDashboardPage(),
      ),
      GoRoute(
        path: adminUsers,
        builder: (context, state) => const AdminDashboardPage(),
      ),
      GoRoute(
        path: adminCreateCourse,
        builder: (context, state) => const CourseFormPage(),
      ),
      GoRoute(
        path: adminEditCourse,
        builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          return CourseFormPage(courseId: courseId);
        },
      ),
      GoRoute(
        path: adminCreateUnit,
        builder: (context, state) {
          final courseId = state.uri.queryParameters['courseId'];
          return UnitFormPage(courseId: courseId);
        },
      ),
      GoRoute(
        path: adminEditUnit,
        builder: (context, state) {
          final unitId = state.pathParameters['unitId']!;
          final courseId = state.uri.queryParameters['courseId'];
          return UnitFormPage(unitId: unitId, courseId: courseId);
        },
      ),
      GoRoute(
        path: adminCourseDetail,
        builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          return CourseDetailPage(courseId: courseId);
        },
      ),
      GoRoute(
        path: adminCreateLesson,
        builder: (context, state) {
          final unitId = state.uri.queryParameters['unitId'];
          final courseId = state.uri.queryParameters['courseId'];
          return LessonFormPage(unitId: unitId, courseId: courseId);
        },
      ),
      GoRoute(
        path: adminEditLesson,
        builder: (context, state) {
          final lessonId = state.pathParameters['lessonId']!;
          final unitId = state.uri.queryParameters['unitId'];
          final courseId = state.uri.queryParameters['courseId'];
          return LessonFormPage(lessonId: lessonId, unitId: unitId, courseId: courseId);
        },
      ),
      GoRoute(
        path: adminUnitDetail,
        builder: (context, state) {
          final unitId = state.pathParameters['unitId']!;
          return UnitDetailPage(unitId: unitId);
        },
      ),
      GoRoute(
        path: adminLessonDetail,
        builder: (context, state) {
          final lessonId = state.pathParameters['lessonId']!;
          return LessonDetailPage(lessonId: lessonId);
        },
      ),
      // Admin exercise routes
      GoRoute(
        path: adminCreateExercise,
        builder: (context, state) {
          final lessonId = state.uri.queryParameters['lessonId'];
          final unitId = state.uri.queryParameters['unitId'];
          final courseId = state.uri.queryParameters['courseId'];
          return ExerciseFormPage(lessonId: lessonId, unitId: unitId, courseId: courseId);
        },
      ),
      GoRoute(
        path: adminEditExercise,
        builder: (context, state) {
          final exerciseId = state.pathParameters['exerciseId']!;
          final lessonId = state.uri.queryParameters['lessonId'];
          final unitId = state.uri.queryParameters['unitId'];
          final courseId = state.uri.queryParameters['courseId'];
          return ExerciseFormPage(
            exerciseId: exerciseId,
            lessonId: lessonId,
            unitId: unitId,
            courseId: courseId,
          );
        },
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
      
      // Main app with shell navigation (for regular users only)
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