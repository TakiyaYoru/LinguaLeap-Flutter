// lib/network/lesson_service.dart
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/lesson_exercise_queries.dart';
import 'graphql_client.dart';

class LessonService {
  // Get lessons for a unit
  static Future<List<Map<String, dynamic>>?> getUnitLessons(String unitId) async {
    try {
      print('📚 Loading lessons for unit: $unitId');
      
      final QueryOptions options = QueryOptions(
        document: gql(LessonExerciseQueries.getUnitLessons),
        variables: {'unitId': unitId},
        fetchPolicy: FetchPolicy.networkOnly,
      );

      print('📤 Sending getUnitLessons query...');
      final QueryResult result = await GraphQLService.client.query(options);
      
      print('📥 Get lessons response: ${result.data}');
      print('📊 Get lessons hasException: ${result.hasException}');
      
      if (result.hasException) {
        print('❌ Get lessons error: ${result.exception}');
        return null;
      }

      final lessonsData = result.data?['unitLessons'];
      if (lessonsData is List) {
        print('✅ Found ${lessonsData.length} lessons');
        return lessonsData.cast<Map<String, dynamic>>();
      }
      
      print('⚠️ No lessons data found');
      return null;
    } catch (e) {
      print('❌ Get lessons error: $e');
      return null;
    }
  }

  // Get single lesson
  static Future<Map<String, dynamic>?> getLesson(String lessonId) async {
    try {
      print('📚 Loading lesson: $lessonId');
      
      final QueryOptions options = QueryOptions(
        document: gql(LessonExerciseQueries.getLesson),
        variables: {'id': lessonId},
        fetchPolicy: FetchPolicy.networkOnly,
      );

      print('📤 Sending getLesson query...');
      final QueryResult result = await GraphQLService.client.query(options);
      
      print('📥 Get lesson response: ${result.data}');
      print('📊 Get lesson hasException: ${result.hasException}');
      
      if (result.hasException) {
        print('❌ Get lesson error: ${result.exception}');
        return null;
      }

      return result.data?['lesson'];
    } catch (e) {
      print('❌ Get lesson error: $e');
      return null;
    }
  }

  // ===============================================
  // SAMPLE DATA FOR DEVELOPMENT (comment lại)
  // ===============================================
  // static List<Map<String, dynamic>> _generateSampleLessonsData(String unitId) {
  //   print('📝 Generating sample lessons data for unit: $unitId');
  //   
  //   return [
  //     {
  //       'id': 'lesson_${unitId}_1',
  //       'title': 'Basic Greetings',
  //       'description': 'Learn how to say hello and goodbye in English',
  //       'unitId': unitId,
  //       'objective': 'Master basic greeting phrases',
  //       'estimatedDuration': 15,
  //       'totalExercises': 7,
  //       'difficulty': 'easy',
  //       'xpReward': 50,
  //       'isPremium': false,
  //       'isPublished': true,
  //       'sortOrder': 1,
  //       'isCompleted': false,
  //       'isUnlocked': true,
  //       'createdAt': DateTime.now().toIso8601String(),
  //       'updatedAt': DateTime.now().toIso8601String(),
  //     },
  //     {
  //       'id': 'lesson_${unitId}_2',
  //       'title': 'Introducing Yourself',
  //       'description': 'Learn to introduce yourself and ask about others',
  //       'unitId': unitId,
  //       'objective': 'Be able to make basic introductions',
  //       'estimatedDuration': 20,
  //       'totalExercises': 8,
  //       'difficulty': 'easy',
  //       'xpReward': 75,
  //       'isPremium': false,
  //       'isPublished': true,
  //       'sortOrder': 2,
  //       'isCompleted': false,
  //       'isUnlocked': true,
  //       'createdAt': DateTime.now().toIso8601String(),
  //       'updatedAt': DateTime.now().toIso8601String(),
  //     },
  //     {
  //       'id': 'lesson_${unitId}_3',
  //       'title': 'Common Phrases',
  //       'description': 'Essential phrases for daily conversation',
  //       'unitId': unitId,
  //       'objective': 'Use common phrases in conversation',
  //       'estimatedDuration': 25,
  //       'totalExercises': 9,
  //       'difficulty': 'medium',
  //       'xpReward': 100,
  //       'isPremium': false,
  //       'isPublished': true,
  //       'sortOrder': 3,
  //       'isCompleted': false,
  //       'isUnlocked': false, // Locked until previous lesson completed
  //       'unlockRequirements': {
  //         'previousLessonId': 'lesson_${unitId}_2',
  //         'minimumScore': 80,
  //       },
  //       'createdAt': DateTime.now().toIso8601String(),
  //       'updatedAt': DateTime.now().toIso8601String(),
  //     },
  //     {
  //       'id': 'lesson_${unitId}_4',
  //       'title': 'Numbers and Counting',
  //       'description': 'Learn numbers from 1 to 100',
  //       'unitId': unitId,
  //       'objective': 'Count and use numbers in context',
  //       'estimatedDuration': 18,
  //       'totalExercises': 6,
  //       'difficulty': 'easy',
  //       'xpReward': 60,
  //       'isPremium': false,
  //       'isPublished': true,
  //       'sortOrder': 4,
  //       'isCompleted': false,
  //       'isUnlocked': false,
  //       'unlockRequirements': {
  //         'previousLessonId': 'lesson_${unitId}_3',
  //         'minimumScore': 75,
  //       },
  //       'createdAt': DateTime.now().toIso8601String(),
  //       'updatedAt': DateTime.now().toIso8601String(),
  //     },
  //     {
  //       'id': 'lesson_${unitId}_5',
  //       'title': 'Colors and Shapes',
  //       'description': 'Learn basic colors and shapes vocabulary',
  //       'unitId': unitId,
  //       'objective': 'Identify and name colors and shapes',
  //       'estimatedDuration': 22,
  //       'totalExercises': 8,
  //       'difficulty': 'easy',
  //       'xpReward': 80,
  //       'isPremium': false,
  //       'isPublished': true,
  //       'sortOrder': 5,
  //       'isCompleted': false,
  //       'isUnlocked': false,
  //       'unlockRequirements': {
  //         'previousLessonId': 'lesson_${unitId}_4',
  //         'minimumScore': 70,
  //       },
  //       'createdAt': DateTime.now().toIso8601String(),
  //       'updatedAt': DateTime.now().toIso8601String(),
  //     },
  //   ];
  // }

  // static Map<String, dynamic> _generateSampleLessonData(String lessonId) {
  //   print('📝 Generating sample lesson data for: $lessonId');
  //   
  //   // Extract unit ID from lesson ID pattern
  //   final unitId = lessonId.contains('_') ? lessonId.split('_')[1] : 'unknown';
  //   
  //   return {
  //     'id': lessonId,
  //     'title': 'Sample Lesson',
  //     'description': 'This is a sample lesson for development purposes',
  //     'unitId': unitId,
  //     'courseId': 'course_1',
  //     'objective': 'Learn sample content for testing',
  //     'estimatedDuration': 20,
  //     'totalExercises': 7,
  //     'difficulty': 'easy',
  //     'xpReward': 75,
  //     'isPremium': false,
  //     'isPublished': true,
  //     'sortOrder': 1,
  //     'isCompleted': false,
  //     'isUnlocked': true,
  //     'createdAt': DateTime.now().toIso8601String(),
  //     'updatedAt': DateTime.now().toIso8601String(),
  //   };
  // }

  // ===============================================
  // CHECK LESSON UNLOCK STATUS
  // ===============================================
  static bool isLessonUnlocked(
    Map<String, dynamic> lesson,
    List<Map<String, dynamic>> completedLessons,
  ) {
    // If no unlock requirements, it's unlocked
    if (lesson['unlockRequirements'] == null) {
      return true;
    }

    final requirements = lesson['unlockRequirements'];
    final previousLessonId = requirements['previousLessonId'];
    final minimumScore = requirements['minimumScore'] ?? 0;

    // Check if previous lesson is completed with minimum score
    if (previousLessonId != null) {
      final previousLesson = completedLessons.firstWhere(
        (completed) => completed['lessonId'] == previousLessonId,
        orElse: () => {},
      );

      if (previousLesson.isEmpty) {
        return false; // Previous lesson not completed
      }

      final score = previousLesson['bestScore'] ?? 0;
      return score >= minimumScore;
    }

    return true;
  }

  // ===============================================
  // UTILITY METHODS
  // ===============================================
  static Future<void> delay({int milliseconds = 500}) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }
}