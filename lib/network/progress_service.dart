// lib/core/network/progress_service.dart
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/progress_queries.dart';
import 'graphql_client.dart';

class ProgressService {
  // Lesson Progress Methods
  static Future<Map<String, dynamic>?> startLesson(String lessonId) async {
    try {
      final MutationOptions options = MutationOptions(
        document: gql(ProgressQueries.startLesson),
        variables: {
          'lessonId': lessonId,
        },
      );

      final QueryResult result = await GraphQLService.client.mutate(options);
      
      print('Start lesson result: ${result.data}');
      print('Start lesson errors: ${result.exception}');
      
      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return result.data?['startLesson'];
    } catch (e) {
      print('Start lesson error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> completeLesson({
    required String lessonId,
    required String courseId,
    required String unitId,
    required int score,
    required int timeTaken,
    required int exercisesCompleted,
    required int exercisesCorrect,
    required List<String> vocabularyEncountered,
    required bool perfectScore,
    required int heartsUsed,
  }) async {
    try {
      final MutationOptions options = MutationOptions(
        document: gql(ProgressQueries.completeLesson),
        variables: {
          'input': {
            'lessonId': lessonId,
            'courseId': courseId,
            'unitId': unitId,
            'completion_data': {
              'score': score,
              'time_taken': timeTaken,
              'exercises_completed': exercisesCompleted,
              'exercises_correct': exercisesCorrect,
              'vocabulary_encountered': vocabularyEncountered,
              'perfect_score': perfectScore,
            },
            'hearts_used': heartsUsed,
          }
        },
      );

      final QueryResult result = await GraphQLService.client.mutate(options);
      
      print('Complete lesson result: ${result.data}');
      print('Complete lesson errors: ${result.exception}');
      
      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return result.data?['completeLesson'];
    } catch (e) {
      print('Complete lesson error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> updateLessonProgress({
    required String lessonId,
    required Map<String, dynamic> progress,
  }) async {
    try {
      final MutationOptions options = MutationOptions(
        document: gql(ProgressQueries.updateLessonProgress),
        variables: {
          'lessonId': lessonId,
          'progress': progress,
        },
      );

      final QueryResult result = await GraphQLService.client.mutate(options);
      
      print('Update lesson progress result: ${result.data}');
      print('Update lesson progress errors: ${result.exception}');
      
      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return result.data?['updateLessonProgress'];
    } catch (e) {
      print('Update lesson progress error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getLessonProgress(String lessonId) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(ProgressQueries.getLessonProgress),
        variables: {
          'lessonId': lessonId,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult result = await GraphQLService.client.query(options);
      
      print('Get lesson progress result: ${result.data}');
      print('Get lesson progress errors: ${result.exception}');
      
      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return result.data?['lessonProgress'];
    } catch (e) {
      print('Get lesson progress error: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>?> getUnitProgress(String unitId) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(ProgressQueries.getUnitProgress),
        variables: {
          'unitId': unitId,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult result = await GraphQLService.client.query(options);
      
      print('Get unit progress result: ${result.data}');
      print('Get unit progress errors: ${result.exception}');
      
      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      final List<dynamic> progressList = result.data?['unitProgress'] ?? [];
      return progressList.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Get unit progress error: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>?> getCourseProgress(String courseId) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(ProgressQueries.getCourseProgress),
        variables: {
          'courseId': courseId,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult result = await GraphQLService.client.query(options);
      
      print('Get course progress result: ${result.data}');
      print('Get course progress errors: ${result.exception}');
      
      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      final List<dynamic> progressList = result.data?['courseProgress'] ?? [];
      return progressList.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Get course progress error: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>?> getCompletedLessons() async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(ProgressQueries.getCompletedLessons),
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult result = await GraphQLService.client.query(options);
      
      print('Get completed lessons result: ${result.data}');
      print('Get completed lessons errors: ${result.exception}');
      
      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      final List<dynamic> progressList = result.data?['completedLessons'] ?? [];
      return progressList.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Get completed lessons error: $e');
      return null;
    }
  }

  // Exercise Bank Methods
  static Future<Map<String, dynamic>?> saveExerciseToBank({
    required Map<String, dynamic> exerciseContent,
    required String sourceLessonId,
    required String sourceUnitId,
    required String sourceCourseId,
    Map<String, dynamic>? performance,
  }) async {
    try {
      final MutationOptions options = MutationOptions(
        document: gql(ProgressQueries.saveExerciseToBank),
        variables: {
          'input': {
            'exerciseContent': exerciseContent,
            'source_lesson_id': sourceLessonId,
            'source_unit_id': sourceUnitId,
            'source_course_id': sourceCourseId,
            if (performance != null) 'performance': performance,
          }
        },
      );

      final QueryResult result = await GraphQLService.client.mutate(options);
      
      print('Save exercise to bank result: ${result.data}');
      print('Save exercise to bank errors: ${result.exception}');
      
      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return result.data?['saveExerciseToBank'];
    } catch (e) {
      print('Save exercise to bank error: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>?> getMyExerciseBank({
    Map<String, dynamic>? filters,
  }) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(ProgressQueries.getMyExerciseBank),
        variables: {
          if (filters != null) 'filters': filters,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult result = await GraphQLService.client.query(options);
      
      print('Get my exercise bank result: ${result.data}');
      print('Get my exercise bank errors: ${result.exception}');
      
      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      final List<dynamic> exerciseList = result.data?['myExerciseBank'] ?? [];
      return exerciseList.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Get my exercise bank error: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>?> getExercisesForReview({
    int? limit,
  }) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(ProgressQueries.getExercisesForReview),
        variables: {
          if (limit != null) 'limit': limit,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult result = await GraphQLService.client.query(options);
      
      print('Get exercises for review result: ${result.data}');
      print('Get exercises for review errors: ${result.exception}');
      
      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      final List<dynamic> exerciseList = result.data?['exercisesForReview'] ?? [];
      return exerciseList.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Get exercises for review error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> updateExercisePerformance({
    required String exerciseId,
    required Map<String, dynamic> performance,
  }) async {
    try {
      final MutationOptions options = MutationOptions(
        document: gql(ProgressQueries.updateExercisePerformance),
        variables: {
          'id': exerciseId,
          'performance': performance,
        },
      );

      final QueryResult result = await GraphQLService.client.mutate(options);
      
      print('Update exercise performance result: ${result.data}');
      print('Update exercise performance errors: ${result.exception}');
      
      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return result.data?['updateExercisePerformance'];
    } catch (e) {
      print('Update exercise performance error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> recordExerciseReview({
    required String exerciseId,
    required bool isCorrect,
  }) async {
    try {
      final MutationOptions options = MutationOptions(
        document: gql(ProgressQueries.recordExerciseReview),
        variables: {
          'id': exerciseId,
          'isCorrect': isCorrect,
        },
      );

      final QueryResult result = await GraphQLService.client.mutate(options);
      
      print('Record exercise review result: ${result.data}');
      print('Record exercise review errors: ${result.exception}');
      
      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return result.data?['recordExerciseReview'];
    } catch (e) {
      print('Record exercise review error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> getUserProgress() async {
    try {
      final result = await GraphQLService.client.query(
        QueryOptions(
          document: gql('''
            query GetUserProgress {
              userProgress {
                currentUnitId
                currentLessonId
                completedLessons
                streak
                dailyXPGoal
                currentDayXP
                hearts
                totalXP
              }
            }
          '''),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw result.exception!;
      }

      return result.data?['userProgress'] ?? {
        'currentUnitId': '',
        'currentLessonId': '',
        'completedLessons': [],
        'streak': 0,
        'dailyXPGoal': 50,
        'currentDayXP': 0,
        'hearts': 5,
        'totalXP': 0,
      };
    } catch (e) {
      print('Error getting user progress: $e');
      // Return default values on error
      return {
        'currentUnitId': '',
        'currentLessonId': '',
        'completedLessons': [],
        'streak': 0,
        'dailyXPGoal': 50,
        'currentDayXP': 0,
        'hearts': 5,
        'totalXP': 0,
      };
    }
  }
} 