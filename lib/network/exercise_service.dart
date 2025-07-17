// lib/network/exercise_service.dart - FIXED
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/lesson_exercise_queries.dart';
import 'graphql_client.dart';

class ExerciseService {
  // ===============================================
  // GET EXERCISES FOR LESSON
  // ===============================================
  static Future<List<Map<String, dynamic>>?> getLessonExercises(String lessonId) async {
    try {
      print('🎮 Fetching exercises for lesson: $lessonId');
      
      final QueryOptions options = QueryOptions(
        document: gql(LessonExerciseQueries.getLessonExercises),
        variables: {'lessonId': lessonId},
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult result = await GraphQLService.client.query(options);
      
      if (result.hasException) {
        print('❌ getLessonExercises error: ${result.exception}');
        return null;
      }

      final exercises = result.data?['lessonExercises'];
      if (exercises is List) {
        print('✅ Found ${exercises.length} exercises for lesson $lessonId');
        return exercises.cast<Map<String, dynamic>>();
      }
      
      print('⚠️ No exercises data found');
      return null;
    } catch (e) {
      print('❌ Error fetching lesson exercises: $e');
      return null;
    }
  }

  // ===============================================
  // GET SINGLE EXERCISE
  // ===============================================
  static Future<Map<String, dynamic>?> getExercise(String exerciseId) async {
    try {
      print('🎮 Fetching exercise: $exerciseId');
      
      final QueryOptions options = QueryOptions(
        document: gql(LessonExerciseQueries.getExercise),
        variables: {'id': exerciseId},
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult result = await GraphQLService.client.query(options);
      
      if (result.hasException) {
        print('❌ getExercise error: ${result.exception}');
        return null;
      }

      final exercise = result.data?['exercise'];
      if (exercise != null) {
        print('✅ Exercise found: ${exercise['title']}');
        return Map<String, dynamic>.from(exercise);
      }
      
      print('⚠️ No exercise data found');
      return null;
    } catch (e) {
      print('❌ Error fetching exercise: $e');
      return null;
    }
  }

  // ===============================================
  // GET EXERCISES BY TYPE (for Practice Mode)
  // ===============================================
  static Future<List<Map<String, dynamic>>?> getExercisesByType(
    String exerciseType, {
    int limit = 10,
  }) async {
    try {
      print('🎮 Fetching $exerciseType exercises (limit: $limit)');
      
      // For now, get all exercises and filter by type
      // TODO: Add backend query for filtering by type
      final QueryOptions options = QueryOptions(
        document: gql(LessonExerciseQueries.getLessonExercises),
        variables: {'lessonId': 'all'}, // This will need to be updated when backend supports type filtering
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult result = await GraphQLService.client.query(options);
      
      if (result.hasException) {
        print('❌ getExercisesByType error: ${result.exception}');
        return null;
      }

      final exercises = result.data?['lessonExercises'];
      if (exercises is List) {
        // Filter by type and limit
        final filteredExercises = exercises
            .where((exercise) => exercise['type'] == exerciseType)
            .take(limit)
            .cast<Map<String, dynamic>>()
            .toList();
        
        print('✅ Found ${filteredExercises.length} $exerciseType exercises');
        return filteredExercises;
      }
      
      return [];
    } catch (e) {
      print('❌ Error fetching exercises by type: $e');
      return null;
    }
  }

  // ===============================================
  // UTILITY METHODS
  // ===============================================
  static Future<void> delay({int milliseconds = 500}) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }
}