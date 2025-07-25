import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/lesson_exercise_queries.dart';
import 'graphql_client.dart';

class LessonReorderService {
  final GraphQLClient _client = GraphQLClientManager.client;

  // Lấy danh sách lessons của unit để reorder
  Future<Map<String, dynamic>> getUnitLessonsForAdmin(String unitId) async {
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(LessonExerciseQueries.getUnitLessonsForAdmin),
          variables: {
            'unitId': unitId,
          },
        ),
      );

      if (result.hasException) {
        throw Exception('Failed to get unit lessons: ${result.exception.toString()}');
      }

      final data = result.data?['getUnitLessonsForAdmin'];
      if (data == null) {
        throw Exception('No data returned');
      }

      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
        'lessons': data['lessons'] ?? [],
      };
    } catch (e) {
      print('Error getting unit lessons: $e');
      return {
        'success': false,
        'message': 'Failed to get unit lessons: $e',
        'lessons': [],
      };
    }
  }

  // Reorder lessons trong unit
  Future<Map<String, dynamic>> reorderLessons(String unitId, List<String> lessonIds) async {
    try {
      final result = await _client.mutate(
        MutationOptions(
          document: gql(LessonExerciseQueries.reorderLessons),
          variables: {
            'unitId': unitId,
            'lessonIds': lessonIds,
          },
        ),
      );

      if (result.hasException) {
        throw Exception('Failed to reorder lessons: ${result.exception.toString()}');
      }

      final data = result.data?['reorderLessons'];
      if (data == null) {
        throw Exception('No data returned');
      }

      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
        'lessons': data['lessons'] ?? [],
      };
    } catch (e) {
      print('Error reordering lessons: $e');
      return {
        'success': false,
        'message': 'Failed to reorder lessons: $e',
        'lessons': [],
      };
    }
  }

  // Helper method để tạo danh sách lesson IDs từ danh sách lessons đã sắp xếp
  List<String> extractLessonIds(List<dynamic> lessons) {
    return lessons.map((lesson) => lesson['id'] as String).toList();
  }

  // Helper method để sort lessons theo sortOrder
  List<dynamic> sortLessonsByOrder(List<dynamic> lessons) {
    final sortedLessons = List<dynamic>.from(lessons);
    sortedLessons.sort((a, b) => (a['sortOrder'] ?? 0).compareTo(b['sortOrder'] ?? 0));
    return sortedLessons;
  }
} 