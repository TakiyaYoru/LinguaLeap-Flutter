// lib/network/exercise_service.dart

import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/exercise_queries.dart';
import '../models/exercise_model.dart';
import 'graphql_client.dart';

class ExerciseService {
  static GraphQLClient get _client => GraphQLService.client;

  // ===============================================
  // AI GENERATION OPERATIONS
  // ===============================================

  // Generate audio from text
  static Future<AudioGenerationResult> generateAudio(String text) async {
    try {
      print('🔊 [ExerciseService] Generating audio from text...');
      print('  - Text: $text');
      
      final result = await _client.mutate(MutationOptions(
        document: gql(ExerciseQueries.generateAudio),
        variables: {
          'input': {
            'text': text,
            'language': 'en-US',
            'voiceName': 'en-US-Standard-A',
            'speakingRate': 1.0,
            'pitch': 0.0,
          },
        },
        fetchPolicy: FetchPolicy.networkOnly,
        errorPolicy: ErrorPolicy.all,
      )).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Audio generation timeout after 60 seconds');
        },
      );

      if (result.hasException) {
        print('❌ [ExerciseService] Error generating audio: ${result.exception}');
        throw Exception('Failed to generate audio: ${result.exception}');
      }

      final audioData = result.data?['generateAudio'];
      print('🔊 [ExerciseService] Audio generation result: $audioData');
      
      if (audioData == null) {
        throw Exception('No audio data returned');
      }

      final audioResult = AudioGenerationResult.fromJson(audioData);
      print('✅ [ExerciseService] Generated audio: ${audioResult.audioUrl}');
      return audioResult;
      
    } catch (e) {
      print('❌ [ExerciseService] Exception generating audio: $e');
      throw Exception('Failed to generate audio: $e');
    }
  }

  // Generate exercise with AI
  static Future<GeneratedExercise> generateExercise(String type, dynamic context) async {
    const int maxRetries = 3;
    const Duration retryDelay = Duration(seconds: 2);
    
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        print('🤖 [ExerciseService] Generating exercise with AI... (Attempt $attempt/$maxRetries)');
        print('  - Type: $type');
        print('  - Context: $context');
        
        // Handle context - ensure it's a Map for GraphQL input type
        Map<String, dynamic> contextToSend;
        if (context is String) {
          contextToSend = {
            'user_context': context,
          };
        } else if (context is Map<String, dynamic>) {
          contextToSend = Map<String, dynamic>.from(context);
        } else {
          contextToSend = {
            'user_context': context.toString(),
          };
        }

        final result = await _client.query(QueryOptions(
          document: gql(ExerciseQueries.generateExercise),
          variables: {
            'type': type,
            'context': contextToSend,
          },
          fetchPolicy: FetchPolicy.networkOnly,
          errorPolicy: ErrorPolicy.all,
        )        ).timeout(
          const Duration(seconds: 120), // Tăng timeout lên 2 phút
          onTimeout: () {
            throw Exception('AI generation timeout after 120 seconds');
          },
        );

        if (result.hasException) {
          print('❌ [ExerciseService] Error generating exercise: ${result.exception}');
          if (attempt < maxRetries) {
            print('🔄 [ExerciseService] Retrying in ${retryDelay.inSeconds} seconds...');
            await Future.delayed(retryDelay);
            continue;
          }
          throw Exception('Failed to generate exercise: ${result.exception}');
        }

        final exerciseData = result.data?['generateExercise'];
        print('📝 [ExerciseService] Raw exercise data: $exerciseData');
        
        if (exerciseData == null) {
          if (attempt < maxRetries) {
            print('🔄 [ExerciseService] No data returned, retrying...');
            await Future.delayed(retryDelay);
            continue;
          }
          throw Exception('No exercise data returned from AI');
        }

        final generatedExercise = GeneratedExercise.fromJson(exerciseData);
        print('✅ [ExerciseService] Generated exercise: ${generatedExercise.type}');
        print('📝 [ExerciseService] Exercise content: ${generatedExercise.content}');
        return generatedExercise;
      } catch (e) {
        print('❌ [ExerciseService] Exception generating exercise (Attempt $attempt): $e');
        if (attempt < maxRetries) {
          print('🔄 [ExerciseService] Retrying in ${retryDelay.inSeconds} seconds...');
          await Future.delayed(retryDelay);
        } else {
          throw Exception('Failed to generate exercise after $maxRetries attempts: $e');
        }
      }
    }
    
    throw Exception('Failed to generate exercise after $maxRetries attempts');
  }

  // ===============================================
  // ADMIN OPERATIONS
  // ===============================================

  // Get all exercises for admin
  static Future<List<ExerciseModel>> getAllExercises() async {
    try {
      print('🎮 [ExerciseService] Getting all exercises...');
      
      final result = await _client.query(QueryOptions(
        document: gql(ExerciseQueries.getAllExercises),
        fetchPolicy: FetchPolicy.networkOnly,
      ));

      if (result.hasException) {
        print('❌ [ExerciseService] Error getting exercises: ${result.exception}');
        throw Exception('Failed to get exercises: ${result.exception}');
      }

      final exercises = result.data?['adminExercises'] as List<dynamic>? ?? [];
      final exerciseModels = exercises.map((json) => ExerciseModel.fromJson(json)).toList();
      
      print('✅ [ExerciseService] Got ${exerciseModels.length} exercises');
      return exerciseModels;
    } catch (e) {
      print('❌ [ExerciseService] Exception getting exercises: $e');
      throw Exception('Failed to get exercises: $e');
    }
  }

  // Get exercises by lesson ID
  static Future<List<ExerciseModel>> getExercisesByLesson(String lessonId) async {
    try {
      print('🎮 [ExerciseService] Getting exercises for lesson: $lessonId');
      
      final result = await _client.query(QueryOptions(
        document: gql(ExerciseQueries.getExercisesByLesson),
        variables: {'lessonId': lessonId},
        fetchPolicy: FetchPolicy.networkOnly,
      ));

      if (result.hasException) {
        print('❌ [ExerciseService] Error getting lesson exercises: ${result.exception}');
        throw Exception('Failed to get lesson exercises: ${result.exception}');
      }

      final exercises = result.data?['lessonExercises'] as List<dynamic>? ?? [];
      final exerciseModels = exercises.map((json) => ExerciseModel.fromJson(json)).toList();
      
      print('✅ [ExerciseService] Got ${exerciseModels.length} exercises for lesson $lessonId');
      return exerciseModels;
    } catch (e) {
      print('❌ [ExerciseService] Exception getting lesson exercises: $e');
      throw Exception('Failed to get lesson exercises: $e');
    }
  }

  // Get single exercise by ID
  static Future<ExerciseModel?> getExercise(String id) async {
    try {
      print('🎮 [ExerciseService] Getting exercise: $id');
      
      final result = await _client.query(QueryOptions(
        document: gql(ExerciseQueries.getExercise),
        variables: {'id': id},
        fetchPolicy: FetchPolicy.networkOnly,
      ));

      if (result.hasException) {
        print('❌ [ExerciseService] Error getting exercise: ${result.exception}');
        throw Exception('Failed to get exercise: ${result.exception}');
      }

      final exerciseData = result.data?['exercise'];
      if (exerciseData == null) {
        print('⚠️ [ExerciseService] Exercise not found: $id');
        return null;
      }

      final exercise = ExerciseModel.fromJson(exerciseData);
      print('✅ [ExerciseService] Got exercise: ${exercise.displayTitle}');
      return exercise;
    } catch (e) {
      print('❌ [ExerciseService] Exception getting exercise: $e');
      throw Exception('Failed to get exercise: $e');
    }
  }

  // Create exercise
  static Future<ExerciseModel?> createExercise(Map<String, dynamic> inputData) async {
    try {
      print('🎮 [ExerciseService] Creating exercise...');
      print('📝 [ExerciseService] Exercise data: $inputData');
      
      final result = await _client.mutate(MutationOptions(
        document: gql(ExerciseQueries.createExercise),
        variables: {'input': inputData},
      ));

      if (result.hasException) {
        print('❌ [ExerciseService] Error creating exercise: ${result.exception}');
        throw Exception('Failed to create exercise: ${result.exception}');
      }

      final exerciseData = result.data?['createExercise'];
      if (exerciseData == null) {
        print('⚠️ [ExerciseService] No exercise data returned');
        return null;
      }

      final exercise = ExerciseModel.fromJson(exerciseData);
      print('✅ [ExerciseService] Created exercise: ${exercise.displayTitle} (ID: ${exercise.id})');
      return exercise;
    } catch (e) {
      print('❌ [ExerciseService] Exception creating exercise: $e');
      throw Exception('Failed to create exercise: $e');
    }
  }

  // Update exercise
  static Future<ExerciseModel?> updateExercise(String id, Map<String, dynamic> inputData) async {
    try {
      print('🎮 [ExerciseService] Updating exercise: $id');
      print('📝 [ExerciseService] Update data: $inputData');
      
      final result = await _client.mutate(MutationOptions(
        document: gql(ExerciseQueries.updateExercise),
        variables: {
          'id': id,
          'input': inputData,
        },
      ));

      if (result.hasException) {
        print('❌ [ExerciseService] Error updating exercise: ${result.exception}');
        throw Exception('Failed to update exercise: ${result.exception}');
      }

      final exerciseData = result.data?['updateExercise'];
      if (exerciseData == null) {
        print('⚠️ [ExerciseService] No exercise data returned');
        return null;
      }

      final exercise = ExerciseModel.fromJson(exerciseData);
      print('✅ [ExerciseService] Updated exercise: ${exercise.displayTitle}');
      return exercise;
    } catch (e) {
      print('❌ [ExerciseService] Exception updating exercise: $e');
      throw Exception('Failed to update exercise: $e');
    }
  }

  // Delete exercise
  static Future<bool> deleteExercise(String id) async {
    try {
      print('🎮 [ExerciseService] Deleting exercise: $id');
      
      final result = await _client.mutate(MutationOptions(
        document: gql(ExerciseQueries.deleteExercise),
        variables: {'id': id},
      ));

      if (result.hasException) {
        print('❌ [ExerciseService] Error deleting exercise: ${result.exception}');
        throw Exception('Failed to delete exercise: ${result.exception}');
      }

      final success = result.data?['deleteExercise'] ?? false;
      print('✅ [ExerciseService] Exercise deleted: $success');
      return success;
    } catch (e) {
      print('❌ [ExerciseService] Exception deleting exercise: $e');
      throw Exception('Failed to delete exercise: $e');
    }
  }

  // Publish exercise
  static Future<bool> publishExercise(String id) async {
    try {
      print('🎮 [ExerciseService] Publishing exercise: $id');
      
      final result = await _client.mutate(MutationOptions(
        document: gql(ExerciseQueries.publishExercise),
        variables: {'id': id},
      ));

      if (result.hasException) {
        print('❌ [ExerciseService] Error publishing exercise: ${result.exception}');
        throw Exception('Failed to publish exercise: ${result.exception}');
      }

      final exerciseData = result.data?['publishExercise'];
      if (exerciseData == null) {
        print('⚠️ [ExerciseService] No exercise data returned');
        return false;
      }

      print('✅ [ExerciseService] Exercise published: ${exerciseData['id']}');
      return true;
    } catch (e) {
      print('❌ [ExerciseService] Exception publishing exercise: $e');
      throw Exception('Failed to publish exercise: $e');
    }
  }

  // Unpublish exercise
  static Future<bool> unpublishExercise(String id) async {
    try {
      print('🎮 [ExerciseService] Unpublishing exercise: $id');
      
      final result = await _client.mutate(MutationOptions(
        document: gql(ExerciseQueries.unpublishExercise),
        variables: {'id': id},
      ));

      if (result.hasException) {
        print('❌ [ExerciseService] Error unpublishing exercise: ${result.exception}');
        throw Exception('Failed to unpublish exercise: ${result.exception}');
      }

      final exerciseData = result.data?['unpublishExercise'];
      if (exerciseData == null) {
        print('⚠️ [ExerciseService] No exercise data returned');
        return false;
      }

      print('✅ [ExerciseService] Exercise unpublished: ${exerciseData['id']}');
      return true;
    } catch (e) {
      print('❌ [ExerciseService] Exception unpublishing exercise: $e');
      throw Exception('Failed to unpublish exercise: $e');
    }
  }

  // ===============================================
  // RANDOM PRACTICE OPERATIONS
  // ===============================================

  // Get random exercises for practice
  static Future<List<ExerciseModel>> getRandomExercises({int limit = 10}) async {
    try {
      print('🎯 [ExerciseService] Getting random exercises...');
      print('  - Limit: $limit');
      
      final result = await _client.query(QueryOptions(
        document: gql(ExerciseQueries.getRandomExercises),
        variables: {'limit': limit},
        fetchPolicy: FetchPolicy.networkOnly,
      ));

      if (result.hasException) {
        print('❌ [ExerciseService] Error getting random exercises: ${result.exception}');
        throw Exception('Failed to get random exercises: ${result.exception}');
      }

      final exercises = result.data?['randomExercises'] as List<dynamic>? ?? [];
      final exerciseModels = exercises.map((json) => ExerciseModel.fromJson(json)).toList();
      
      print('✅ [ExerciseService] Got ${exerciseModels.length} random exercises');
      return exerciseModels;
    } catch (e) {
      print('❌ [ExerciseService] Exception getting random exercises: $e');
      throw Exception('Failed to get random exercises: $e');
    }
  }

  // Get listening exercises
  static Future<List<ExerciseModel>> getListeningExercises() async {
    try {
      print('🎧 [ExerciseService] Getting listening exercises...');
      
      final result = await _client.query(
        QueryOptions(
          document: gql(ExerciseQueries.getListeningExercises),
          fetchPolicy: FetchPolicy.cacheAndNetwork,
        ),
      );

      if (result.hasException) {
        print('❌ [ExerciseService] Error getting listening exercises: ${result.exception}');
        throw Exception('Failed to get listening exercises: ${result.exception}');
      }

      final exercises = result.data?['listeningExercises'] as List<dynamic>? ?? [];
      print('✅ [ExerciseService] Found ${exercises.length} listening exercises');

      return exercises.map((exercise) => ExerciseModel.fromJson(exercise)).toList();
    } catch (e) {
      print('❌ [ExerciseService] Error in getListeningExercises: $e');
      rethrow;
    }
  }

  // Get reading exercises
  static Future<List<ExerciseModel>> getReadingExercises() async {
    try {
      print('📖 [ExerciseService] Getting reading exercises...');
      
      final result = await _client.query(
        QueryOptions(
          document: gql(ExerciseQueries.getReadingExercises),
          fetchPolicy: FetchPolicy.cacheAndNetwork,
        ),
      );

      if (result.hasException) {
        print('❌ [ExerciseService] Error getting reading exercises: ${result.exception}');
        throw Exception('Failed to get reading exercises: ${result.exception}');
      }

      final exercises = result.data?['readingExercises'] as List<dynamic>? ?? [];
      print('✅ [ExerciseService] Found ${exercises.length} reading exercises');

      return exercises.map((exercise) => ExerciseModel.fromJson(exercise)).toList();
    } catch (e) {
      print('❌ [ExerciseService] Error in getReadingExercises: $e');
      rethrow;
    }
  }

  // Get speaking exercises
  static Future<List<ExerciseModel>> getSpeakingExercises() async {
    try {
      print('🎤 [ExerciseService] Getting speaking exercises...');
      
      final result = await _client.query(
        QueryOptions(
          document: gql(ExerciseQueries.getSpeakingExercises),
          fetchPolicy: FetchPolicy.cacheAndNetwork,
        ),
      );

      if (result.hasException) {
        print('❌ [ExerciseService] Error getting speaking exercises: ${result.exception}');
        throw Exception('Failed to get speaking exercises: ${result.exception}');
      }

      final exercises = result.data?['speakingExercises'] as List<dynamic>? ?? [];
      print('✅ [ExerciseService] Found ${exercises.length} speaking exercises');

      return exercises.map((exercise) => ExerciseModel.fromJson(exercise)).toList();
    } catch (e) {
      print('❌ [ExerciseService] Error in getSpeakingExercises: $e');
      rethrow;
    }
  }

  // Get exercise by ID
  static Future<ExerciseModel?> getExerciseById(String exerciseId) async {
    try {
      print('🎮 [ExerciseService] Getting exercise by ID: $exerciseId');
      
      final result = await _client.query(
        QueryOptions(
          document: gql(ExerciseQueries.getExerciseById),
          variables: {'id': exerciseId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        print('❌ [ExerciseService] Error getting exercise by ID: ${result.exception}');
        return null;
      }

      final exerciseData = result.data?['exercise'];
      if (exerciseData != null) {
        return ExerciseModel.fromJson(exerciseData);
      }
      return null;
    } catch (e) {
      print('❌ [ExerciseService] Error getting exercise by ID: $e');
      return null;
    }
  }

  // ===============================================
  // USER OPERATIONS
  // ===============================================

  // Get exercises for lesson (user view)
  static Future<List<ExerciseModel>> getLessonExercises(String lessonId) async {
    try {
      print('🎮 [ExerciseService] Getting user exercises for lesson: $lessonId');
      
      final result = await _client.query(QueryOptions(
        document: gql(ExerciseQueries.getLessonExercises),
        variables: {'lessonId': lessonId},
        fetchPolicy: FetchPolicy.networkOnly,
      ));

      if (result.hasException) {
        print('❌ [ExerciseService] Error getting user lesson exercises: ${result.exception}');
        throw Exception('Failed to get user lesson exercises: ${result.exception}');
      }

      final exercises = result.data?['lessonExercises'] as List<dynamic>? ?? [];
      final exerciseModels = exercises.map((json) => ExerciseModel.fromJson(json)).toList();
      
      print('✅ [ExerciseService] Got ${exerciseModels.length} user exercises for lesson $lessonId');
      return exerciseModels;
    } catch (e) {
      print('❌ [ExerciseService] Exception getting user lesson exercises: $e');
      throw Exception('Failed to get user lesson exercises: $e');
    }
  }

  // Get single exercise for user
  static Future<ExerciseModel?> getUserExercise(String id) async {
    try {
      print('🎮 [ExerciseService] Getting user exercise: $id');
      
      final result = await _client.query(QueryOptions(
        document: gql(ExerciseQueries.getUserExercise),
        variables: {'id': id},
        fetchPolicy: FetchPolicy.networkOnly,
      ));

      if (result.hasException) {
        print('❌ [ExerciseService] Error getting user exercise: ${result.exception}');
        throw Exception('Failed to get user exercise: ${result.exception}');
      }

      final exerciseData = result.data?['exercise'];
      if (exerciseData == null) {
        print('⚠️ [ExerciseService] User exercise not found: $id');
        return null;
      }

      final exercise = ExerciseModel.fromJson(exerciseData);
      print('✅ [ExerciseService] Got user exercise: ${exercise.displayTitle}');
      return exercise;
    } catch (e) {
      print('❌ [ExerciseService] Exception getting user exercise: $e');
      throw Exception('Failed to get user exercise: $e');
    }
  }

  // Submit exercise answer
  static Future<Map<String, dynamic>?> submitExerciseAnswer(
    String exerciseId, 
    String answer, 
    int timeSpent
  ) async {
    try {
      print('🎮 [ExerciseService] Submitting answer for exercise: $exerciseId');
      print('📝 [ExerciseService] Answer: $answer, Time: ${timeSpent}s');
      
      final result = await _client.mutate(MutationOptions(
        document: gql(ExerciseQueries.submitExerciseAnswer),
        variables: {
          'exerciseId': exerciseId,
          'answer': answer,
          'timeSpent': timeSpent,
        },
      ));

      if (result.hasException) {
        print('❌ [ExerciseService] Error submitting answer: ${result.exception}');
        throw Exception('Failed to submit answer: ${result.exception}');
      }

      final answerData = result.data?['submitExerciseAnswer'];
      if (answerData == null) {
        print('⚠️ [ExerciseService] No answer data returned');
        return null;
      }

      print('✅ [ExerciseService] Answer submitted successfully');
      print('📊 [ExerciseService] Result: $answerData');
      return answerData;
    } catch (e) {
      print('❌ [ExerciseService] Exception submitting answer: $e');
      throw Exception('Failed to submit answer: $e');
    }
  }

  // Update exercise progress
  static Future<Map<String, dynamic>?> updateExerciseProgress(
    String exerciseId, 
    Map<String, dynamic> progress
  ) async {
    try {
      print('🎮 [ExerciseService] Updating progress for exercise: $exerciseId');
      print('📝 [ExerciseService] Progress: $progress');
      
      final result = await _client.mutate(MutationOptions(
        document: gql(ExerciseQueries.updateExerciseProgress),
        variables: {
          'exerciseId': exerciseId,
          'progress': progress,
        },
      ));

      if (result.hasException) {
        print('❌ [ExerciseService] Error updating progress: ${result.exception}');
        throw Exception('Failed to update progress: ${result.exception}');
      }

      final progressData = result.data?['updateExerciseProgress'];
      if (progressData == null) {
        print('⚠️ [ExerciseService] No progress data returned');
        return null;
      }

      print('✅ [ExerciseService] Progress updated successfully');
      print('📊 [ExerciseService] Progress: $progressData');
      return progressData;
    } catch (e) {
      print('❌ [ExerciseService] Exception updating progress: $e');
      throw Exception('Failed to update progress: $e');
    }
  }
}