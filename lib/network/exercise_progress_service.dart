// lib/network/exercise_progress_service.dart - Exercise Progress Service
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/progress_queries.dart';
import 'graphql_client.dart';

class ExerciseProgressService {
  // ===============================================
  // SAVE EXERCISE PROGRESS
  // ===============================================
  static Future<bool> saveExerciseProgress({
    required String exerciseId,
    required String lessonId,
    required dynamic userAnswer,
    required bool isCorrect,
    required int score,
    required int timeSpent,
  }) async {
    try {
      print('💾 Saving exercise progress for: $exerciseId');
      
      final MutationOptions options = MutationOptions(
        document: gql(ProgressQueries.saveExerciseProgress),
        variables: {
          'input': {
            'exerciseId': exerciseId,
            'lessonId': lessonId,
            'userAnswer': userAnswer.toString(),
            'isCorrect': isCorrect,
            'score': score,
            'timeSpent': timeSpent,
          }
        },
      );

      final QueryResult result = await GraphQLService.client.mutate(options);
      
      if (result.hasException) {
        print('❌ saveExerciseProgress error: ${result.exception}');
        return false;
      }

      final success = result.data?['saveExerciseProgress']?['success'] ?? false;
      if (success) {
        print('✅ Exercise progress saved successfully');
      } else {
        print('❌ Failed to save exercise progress');
      }
      
      return success;
    } catch (e) {
      print('❌ Error saving exercise progress: $e');
      return false;
    }
  }

  // ===============================================
  // SAVE LESSON PROGRESS
  // ===============================================
  static Future<Map<String, dynamic>?> saveLessonProgress({
    required String lessonId,
    required String courseId,
    required int totalScore,
    required int maxScore,
    required int timeSpent,
    required int heartsRemaining,
    required bool isCompleted,
    required List<Map<String, dynamic>> exerciseResults,
  }) async {
    try {
      print('💾 Saving lesson progress for: $lessonId');
      
      final MutationOptions options = MutationOptions(
        document: gql(ProgressQueries.saveLessonProgress),
        variables: {
          'input': {
            'lessonId': lessonId,
            'courseId': courseId,
            'totalScore': totalScore,
            'maxScore': maxScore,
            'timeSpent': timeSpent,
            'heartsRemaining': heartsRemaining,
            'isCompleted': isCompleted,
            'exerciseResults': exerciseResults,
          }
        },
      );

      final QueryResult result = await GraphQLService.client.mutate(options);
      
      if (result.hasException) {
        print('❌ saveLessonProgress error: ${result.exception}');
        return null;
      }

      final progressData = result.data?['saveLessonProgress'];
      if (progressData != null) {
        print('✅ Lesson progress saved successfully');
        print('   Passed: ${progressData['passed']}');
        print('   Unlocked lessons: ${progressData['unlockedLessons']?.length ?? 0}');
        return Map<String, dynamic>.from(progressData);
      }
      
      print('❌ Failed to save lesson progress');
      return null;
    } catch (e) {
      print('❌ Error saving lesson progress: $e');
      return null;
    }
  }

  // ===============================================
  // GET USER PROGRESS
  // ===============================================
  static Future<Map<String, dynamic>?> getUserProgress({
    required String courseId,
  }) async {
    try {
      print('📊 Getting user progress for course: $courseId');
      
      final QueryOptions options = QueryOptions(
        document: gql(ProgressQueries.getUserProgress),
        variables: {'courseId': courseId},
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult result = await GraphQLService.client.query(options);
      
      if (result.hasException) {
        print('❌ getUserProgress error: ${result.exception}');
        return null;
      }

      final progressData = result.data?['userProgress'];
      if (progressData != null) {
        print('✅ User progress retrieved successfully');
        return Map<String, dynamic>.from(progressData);
      }
      
      print('⚠️ No user progress found');
      return null;
    } catch (e) {
      print('❌ Error getting user progress: $e');
      return null;
    }
  }

  // ===============================================
  // GET LESSON PROGRESS
  // ===============================================
  static Future<Map<String, dynamic>?> getLessonProgress({
    required String lessonId,
  }) async {
    try {
      print('📊 Getting lesson progress for: $lessonId');
      
      final QueryOptions options = QueryOptions(
        document: gql(ProgressQueries.getLessonProgress),
        variables: {'lessonId': lessonId},
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult result = await GraphQLService.client.query(options);
      
      if (result.hasException) {
        print('❌ getLessonProgress error: ${result.exception}');
        return null;
      }

      final progressData = result.data?['lessonProgress'];
      if (progressData != null) {
        print('✅ Lesson progress retrieved successfully');
        return Map<String, dynamic>.from(progressData);
      }
      
      print('⚠️ No lesson progress found');
      return null;
    } catch (e) {
      print('❌ Error getting lesson progress: $e');
      return null;
    }
  }

  // ===============================================
  // UTILITY METHODS
  // ===============================================
  static int calculateScore({
    required bool isCorrect,
    required int baseScore,
    required int timeSpent,
    required int maxTime,
  }) {
    if (!isCorrect) return 0;
    
    // Base score for correct answer
    int score = baseScore;
    
    // Time bonus (faster = more points)
    if (timeSpent < maxTime) {
      double timeBonus = (maxTime - timeSpent) / maxTime;
      score += (baseScore * timeBonus * 0.5).round();
    }
    
    return score;
  }

  static bool isLessonPassed({
    required int totalScore,
    required int maxScore,
    required int heartsRemaining,
    double passThreshold = 0.7, // 70% to pass
  }) {
    double scorePercentage = totalScore / maxScore;
    return scorePercentage >= passThreshold && heartsRemaining > 0;
  }

  static Future<void> delay({int milliseconds = 500}) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }
} 