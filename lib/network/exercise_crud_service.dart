// lib/network/exercise_crud_service.dart

import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/exercise_crud_model.dart';
import '../graphql/exercise_crud_queries.dart';
import 'graphql_client.dart';

class ExerciseCRUDService {
  final GraphQLClient _client = GraphQLService.client;

  // Get all exercises with pagination and filtering
  Future<ExerciseListPayload> getExercises({
    int page = 1,
    int limit = 10,
    ExerciseFilterInput? filter,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(ExerciseCRUDQueries.getExercises),
          variables: {
            'page': page,
            'limit': limit,
            'filter': filter?.toJson(),
            'sortBy': sortBy,
            'sortOrder': sortOrder,
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception?.graphqlErrors.first.message ?? 'Failed to get exercises');
      }

      final data = result.data?['getExercises'];
      if (data == null) {
        throw Exception('No data received');
      }

      return ExerciseListPayload.fromJson(data);
    } catch (e) {
      print('❌ Error getting exercises: $e');
      rethrow;
    }
  }

  // Get exercise by ID
  Future<ExerciseCRUDModel> getExercise(String id) async {
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(ExerciseCRUDQueries.getExercise),
          variables: {'id': id},
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception?.graphqlErrors.first.message ?? 'Failed to get exercise');
      }

      final data = result.data?['getExercise'];
      if (data == null) {
        throw Exception('Exercise not found');
      }

      return ExerciseCRUDModel.fromJson(data);
    } catch (e) {
      print('❌ Error getting exercise: $e');
      rethrow;
    }
  }

  // Get exercise by subtype
  Future<ExerciseCRUDModel> getExerciseBySubtype(String subtype) async {
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(ExerciseCRUDQueries.getExerciseBySubtype),
          variables: {'subtype': subtype},
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception?.graphqlErrors.first.message ?? 'Failed to get exercise by subtype');
      }

      final data = result.data?['getExerciseBySubtype'];
      if (data == null) {
        throw Exception('Exercise subtype not found');
      }

      return ExerciseCRUDModel.fromJson(data);
    } catch (e) {
      print('❌ Error getting exercise by subtype: $e');
      rethrow;
    }
  }

  // Get exercises by type
  Future<List<ExerciseCRUDModel>> getExercisesByType(String type) async {
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(ExerciseCRUDQueries.getExercisesByType),
          variables: {'type': type},
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception?.graphqlErrors.first.message ?? 'Failed to get exercises by type');
      }

      final data = result.data?['getExercisesByType'] as List?;
      if (data == null) {
        return [];
      }

      return data.map((e) => ExerciseCRUDModel.fromJson(e)).toList();
    } catch (e) {
      print('❌ Error getting exercises by type: $e');
      rethrow;
    }
  }

  // Get exercises by skill
  Future<List<ExerciseCRUDModel>> getExercisesBySkill(String skill) async {
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(ExerciseCRUDQueries.getExercisesBySkill),
          variables: {'skill': skill},
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception?.graphqlErrors.first.message ?? 'Failed to get exercises by skill');
      }

      final data = result.data?['getExercisesBySkill'] as List?;
      if (data == null) {
        return [];
      }

      return data.map((e) => ExerciseCRUDModel.fromJson(e)).toList();
    } catch (e) {
      print('❌ Error getting exercises by skill: $e');
      rethrow;
    }
  }

  // Get all exercise subtypes
  Future<List<String>> getExerciseSubtypes() async {
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(ExerciseCRUDQueries.getExerciseSubtypes),
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception?.graphqlErrors.first.message ?? 'Failed to get exercise subtypes');
      }

      final data = result.data?['getExerciseSubtypes'] as List?;
      if (data == null) {
        return [];
      }

      return data.map((e) => e.toString()).toList();
    } catch (e) {
      print('❌ Error getting exercise subtypes: $e');
      rethrow;
    }
  }

  // Get exercise statistics
  Future<ExerciseStatsPayload> getExerciseStats() async {
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(ExerciseCRUDQueries.getExerciseStats),
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception?.graphqlErrors.first.message ?? 'Failed to get exercise stats');
      }

      final data = result.data?['getExerciseStats'];
      if (data == null) {
        throw Exception('No stats data received');
      }

      return ExerciseStatsPayload.fromJson(data);
    } catch (e) {
      print('❌ Error getting exercise stats: $e');
      rethrow;
    }
  }

  // Get random exercise
  Future<ExerciseCRUDModel> getRandomExercise({ExerciseFilterInput? filter}) async {
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(ExerciseCRUDQueries.getRandomExercise),
          variables: {'filter': filter?.toJson()},
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception?.graphqlErrors.first.message ?? 'Failed to get random exercise');
      }

      final data = result.data?['getRandomExercise'];
      if (data == null) {
        throw Exception('No random exercise found');
      }

      return ExerciseCRUDModel.fromJson(data);
    } catch (e) {
      print('❌ Error getting random exercise: $e');
      rethrow;
    }
  }

  // Get exercises for lesson
  Future<List<ExerciseCRUDModel>> getLessonExercises({
    required String lessonId,
    int count = 6,
    List<String>? skillFocus,
  }) async {
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(ExerciseCRUDQueries.getLessonExercises),
          variables: {
            'lessonId': lessonId,
            'count': count,
            'skillFocus': skillFocus,
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception?.graphqlErrors.first.message ?? 'Failed to get lesson exercises');
      }

      final data = result.data?['getLessonExercises'] as List?;
      if (data == null) {
        return [];
      }

      return data.map((e) => ExerciseCRUDModel.fromJson(e)).toList();
    } catch (e) {
      print('❌ Error getting lesson exercises: $e');
      rethrow;
    }
  }

  // Create exercise
  Future<ExerciseCRUDPayload> createExercise(CreateExerciseInput input) async {
    try {
      final result = await _client.mutate(
        MutationOptions(
          document: gql(ExerciseCRUDQueries.createExercise),
          variables: {'input': input.toJson()},
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception?.graphqlErrors.first.message ?? 'Failed to create exercise');
      }

      final data = result.data?['createExercise'];
      if (data == null) {
        throw Exception('No response data received');
      }

      return ExerciseCRUDPayload.fromJson(data);
    } catch (e) {
      print('❌ Error creating exercise: $e');
      rethrow;
    }
  }

  // Update exercise
  Future<ExerciseCRUDPayload> updateExercise(String id, UpdateExerciseInput input) async {
    try {
      final result = await _client.mutate(
        MutationOptions(
          document: gql(ExerciseCRUDQueries.updateExercise),
          variables: {
            'id': id,
            'input': input.toJson(),
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception?.graphqlErrors.first.message ?? 'Failed to update exercise');
      }

      final data = result.data?['updateExercise'];
      if (data == null) {
        throw Exception('No response data received');
      }

      return ExerciseCRUDPayload.fromJson(data);
    } catch (e) {
      print('❌ Error updating exercise: $e');
      rethrow;
    }
  }

  // Delete exercise
  Future<ExerciseCRUDPayload> deleteExercise(String id) async {
    try {
      final result = await _client.mutate(
        MutationOptions(
          document: gql(ExerciseCRUDQueries.deleteExercise),
          variables: {'id': id},
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception?.graphqlErrors.first.message ?? 'Failed to delete exercise');
      }

      final data = result.data?['deleteExercise'];
      if (data == null) {
        throw Exception('No response data received');
      }

      return ExerciseCRUDPayload.fromJson(data);
    } catch (e) {
      print('❌ Error deleting exercise: $e');
      rethrow;
    }
  }

  // Toggle exercise active status
  Future<ExerciseCRUDPayload> toggleExerciseActive(String id) async {
    try {
      final result = await _client.mutate(
        MutationOptions(
          document: gql(ExerciseCRUDQueries.toggleExerciseActive),
          variables: {'id': id},
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception?.graphqlErrors.first.message ?? 'Failed to toggle exercise status');
      }

      final data = result.data?['toggleExerciseActive'];
      if (data == null) {
        throw Exception('No response data received');
      }

      return ExerciseCRUDPayload.fromJson(data);
    } catch (e) {
      print('❌ Error toggling exercise status: $e');
      rethrow;
    }
  }

  // Update exercise success rate
  Future<ExerciseCRUDPayload> updateExerciseSuccessRate(String id, bool isCorrect) async {
    try {
      final result = await _client.mutate(
        MutationOptions(
          document: gql(ExerciseCRUDQueries.updateExerciseSuccessRate),
          variables: {
            'id': id,
            'isCorrect': isCorrect,
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception?.graphqlErrors.first.message ?? 'Failed to update exercise success rate');
      }

      final data = result.data?['updateExerciseSuccessRate'];
      if (data == null) {
        throw Exception('No response data received');
      }

      return ExerciseCRUDPayload.fromJson(data);
    } catch (e) {
      print('❌ Error updating exercise success rate: $e');
      rethrow;
    }
  }

  // Bulk create exercises
  Future<ExerciseListPayload> bulkCreateExercises({
    required String template,
    required int count,
    List<String>? skillFocus,
  }) async {
    try {
      final result = await _client.mutate(
        MutationOptions(
          document: gql(ExerciseCRUDQueries.bulkCreateExercises),
          variables: {
            'template': template,
            'count': count,
            'skillFocus': skillFocus,
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception?.graphqlErrors.first.message ?? 'Failed to bulk create exercises');
      }

      final data = result.data?['bulkCreateExercises'];
      if (data == null) {
        throw Exception('No response data received');
      }

      return ExerciseListPayload.fromJson(data);
    } catch (e) {
      print('❌ Error bulk creating exercises: $e');
      rethrow;
    }
  }

  // Reorder exercises
  Future<ExerciseListPayload> reorderExercises(List<String> ids) async {
    try {
      final result = await _client.mutate(
        MutationOptions(
          document: gql(ExerciseCRUDQueries.reorderExercises),
          variables: {'ids': ids},
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception?.graphqlErrors.first.message ?? 'Failed to reorder exercises');
      }

      final data = result.data?['reorderExercises'];
      if (data == null) {
        throw Exception('No response data received');
      }

      return ExerciseListPayload.fromJson(data);
    } catch (e) {
      print('❌ Error reordering exercises: $e');
      rethrow;
    }
  }
} 