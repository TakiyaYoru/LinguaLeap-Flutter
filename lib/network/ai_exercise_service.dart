// lib/network/ai_exercise_service.dart - AI Exercise Service
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/lesson_exercise_queries.dart';
import 'graphql_client.dart';

class AIExerciseService {
  // ===============================================
  // GET AI-GENERATED EXERCISES FOR LESSON
  // ===============================================
  static Future<List<Map<String, dynamic>>?> getAILessonExercises(String lessonId) async {
    try {
      print('🤖 Fetching AI-generated exercises for lesson: $lessonId');
      
      final QueryOptions options = QueryOptions(
        document: gql(LessonExerciseQueries.getLessonExercisesWithAI),
        variables: {'lessonId': lessonId},
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult result = await GraphQLService.client.query(options);
      
      if (result.hasException) {
        print('❌ getAILessonExercises error: ${result.exception}');
        return null;
      }

      final exercises = result.data?['lessonExercisesWithAI'];
      if (exercises is List) {
        print('✅ Found ${exercises.length} AI-generated exercises for lesson $lessonId');
        return exercises.cast<Map<String, dynamic>>();
      }
      
      print('⚠️ No AI exercises data found');
      return null;
    } catch (e) {
      print('❌ Error fetching AI lesson exercises: $e');
      return null;
    }
  }

  // ===============================================
  // GENERATE EXERCISE CONTENT
  // ===============================================
  static Future<Map<String, dynamic>?> generateExerciseContent(
    String exerciseType,
    Map<String, dynamic> context,
  ) async {
    try {
      print('🤖 Generating exercise content for type: $exerciseType');
      
      final MutationOptions options = MutationOptions(
        document: gql(LessonExerciseQueries.generateExercise),
        variables: {
          'input': {
            'type': exerciseType,
            'context': context,
          }
        },
      );

      final QueryResult result = await GraphQLService.client.mutate(options);
      
      if (result.hasException) {
        print('❌ generateExerciseContent error: ${result.exception}');
        return null;
      }

      final generatedContent = result.data?['generateExercise'];
      if (generatedContent != null) {
        print('✅ Generated exercise content successfully');
        return Map<String, dynamic>.from(generatedContent);
      }
      
      print('⚠️ No generated content found');
      return null;
    } catch (e) {
      print('❌ Error generating exercise content: $e');
      return null;
    }
  }

  // ===============================================
  // GENERATE LESSON EXERCISES
  // ===============================================
  static Future<List<Map<String, dynamic>>?> generateLessonExercises(
    String lessonId,
    Map<String, dynamic> lessonContext,
  ) async {
    try {
      print('🤖 Generating exercises for lesson: $lessonId');
      
      final MutationOptions options = MutationOptions(
        document: gql(LessonExerciseQueries.generateLessonExercises),
        variables: {
          'input': {
            'lessonId': lessonId,
            'context': lessonContext,
          }
        },
      );

      final QueryResult result = await GraphQLService.client.mutate(options);
      
      if (result.hasException) {
        print('❌ generateLessonExercises error: ${result.exception}');
        return null;
      }

      final generatedExercises = result.data?['generateLessonExercises']?['exercises'];
      if (generatedExercises is List) {
        print('✅ Generated ${generatedExercises.length} exercises for lesson $lessonId');
        return generatedExercises.cast<Map<String, dynamic>>();
      }
      
      print('⚠️ No generated exercises found');
      return null;
    } catch (e) {
      print('❌ Error generating lesson exercises: $e');
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