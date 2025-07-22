import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_client.dart';
import '../graphql/learnmap_queries.dart';

class LearnmapService {
  static final GraphQLClient _client = GraphQLService.client;

  // Test authentication
  static Future<Map<String, dynamic>?> testAuthentication() async {
    try {
      final result = await _client.query(QueryOptions(
        document: gql('''
          query {
            hello
          }
        '''),
      ));

      if (result.hasException) {
        print('❌ Auth test error: ${result.exception}');
        return null;
      }

      print('✅ Auth test result: ${result.data}');
      return result.data;
    } catch (e) {
      print('❌ Auth test exception: $e');
      return null;
    }
  }

  // Lấy learnmap progress của user
  static Future<Map<String, dynamic>?> getUserLearnmapProgress(String courseId) async {
    try {
      final result = await _client.query(QueryOptions(
        document: gql(getUserLearnmapProgressQuery),
        variables: {'courseId': courseId},
      ));

      if (result.hasException) {
        print('❌ getUserLearnmapProgress error: ${result.exception}');
        return null;
      }

      return result.data?['userLearnmapProgress'];
    } catch (e) {
      print('❌ getUserLearnmapProgress exception: $e');
      return null;
    }
  }

  // Khởi tạo learnmap progress cho course
  static Future<Map<String, dynamic>?> startCourseLearnmap(String courseId) async {
    try {
      final result = await _client.mutate(MutationOptions(
        document: gql(startCourseLearnmapMutation),
        variables: {'courseId': courseId},
      ));

      if (result.hasException) {
        print('❌ startCourseLearnmap error: ${result.exception}');
        return null;
      }

      final data = result.data?['startCourseLearnmap'];
      print('📊 startCourseLearnmap response: $data'); // Added for debugging
      if (data != null && data['success'] == true) {
        print('✅ startCourseLearnmap success'); // Added for debugging
        return data['userLearnmapProgress'];
      } else {
        print('❌ startCourseLearnmap failed: success=${data?['success']}, message=${data?['message']}'); // Added for debugging
        return null;
      }
    } catch (e) {
      print('❌ startCourseLearnmap exception: $e');
      return null;
    }
  }

  // Cập nhật learnmap progress
  static Future<Map<String, dynamic>?> updateLearnmapProgress(String courseId, Map<String, dynamic> progressInput) async {
    try {
      final result = await _client.mutate(MutationOptions(
        document: gql(updateLearnmapProgressMutation),
        variables: {
          'courseId': courseId,
          'progressInput': progressInput,
        },
      ));

      if (result.hasException) {
        print('❌ updateLearnmapProgress error: ${result.exception}');
        return null;
      }

      final data = result.data?['updateLearnmapProgress'];
      print('📊 updateLearnmapProgress response: $data');
      if (data != null && data['success'] == true) {
        print('✅ updateLearnmapProgress success');
        return data['userLearnmapProgress'];
      } else {
        print('❌ updateLearnmapProgress failed: success=${data?['success']}, message=${data?['message']}');
        return null;
      }
    } catch (e) {
      print('❌ updateLearnmapProgress exception: $e');
      return null;
    }
  }

  // Lấy exercises của lesson
  static Future<List<Map<String, dynamic>>?> getExercisesByLesson(String lessonId) async {
    try {
      final result = await _client.query(QueryOptions(
        document: gql(getExercisesByLessonQuery),
        variables: {'lessonId': lessonId},
      ));

      if (result.hasException) {
        print('❌ getExercisesByLesson error: ${result.exception}');
        return null;
      }

      final data = result.data?['getExercisesByLesson'];
      print('📊 getExercisesByLesson response: $data');
      if (data != null && data['success'] == true) {
        print('✅ getExercisesByLesson success, found ${data['exercises']?.length ?? 0} exercises');
        return List<Map<String, dynamic>>.from(data['exercises'] ?? []);
      } else {
        print('❌ getExercisesByLesson failed: success=${data?['success']}, message=${data?['message']}');
        return null;
      }
    } catch (e) {
      print('❌ getExercisesByLesson exception: $e');
      return null;
    }
  }

  // Cập nhật exercise progress
  static Future<Map<String, dynamic>?> updateExerciseProgress(String lessonId, Map<String, dynamic> exerciseProgressInput) async {
    try {
      final result = await _client.mutate(MutationOptions(
        document: gql(updateExerciseProgressMutation),
        variables: {
          'lessonId': lessonId,
          'exerciseProgressInput': exerciseProgressInput,
        },
      ));

      if (result.hasException) {
        print('❌ updateExerciseProgress error: ${result.exception}');
        return null;
      }

      final data = result.data?['updateExerciseProgress'];
      print('📊 updateExerciseProgress response: $data');
      if (data != null && data['success'] == true) {
        print('✅ updateExerciseProgress success');
        return data['exerciseProgress'];
      } else {
        print('❌ updateExerciseProgress failed: success=${data?['success']}, message=${data?['message']}');
        return null;
      }
    } catch (e) {
      print('❌ updateExerciseProgress exception: $e');
      return null;
    }
  }
} 