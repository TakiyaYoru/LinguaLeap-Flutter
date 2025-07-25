// lib/network/learnmap_service.dart
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
        fetchPolicy: FetchPolicy.networkOnly, // ✅ Always fetch fresh
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

  // ✅ FIXED: Lấy learnmap progress với FetchPolicy.networkOnly
  static Future<Map<String, dynamic>?> getUserLearnmapProgress(String courseId) async {
    try {
      print('📊 [LearnmapService] Fetching fresh UserLearnmapProgress for course: $courseId');
      
      final result = await _client.query(QueryOptions(
        document: gql(getUserLearnmapProgressQuery),
        variables: {'courseId': courseId},
        fetchPolicy: FetchPolicy.networkOnly, // ✅ CRITICAL: Always fetch fresh data
      ));

      if (result.hasException) {
        print('❌ getUserLearnmapProgress error: ${result.exception}');
        return null;
      }

      final data = result.data?['userLearnmapProgress'];
      if (data != null) {
        print('✅ [LearnmapService] Fresh UserLearnmapProgress loaded successfully');
        print('   - User ID: ${data['userId']}');
        print('   - Course ID: ${data['courseId']}');
        print('   - Hearts: ${data['hearts']}');
      } else {
        print('⚠️ [LearnmapService] No UserLearnmapProgress found for course: $courseId');
      }
      
      return data;
    } catch (e) {
      print('❌ getUserLearnmapProgress exception: $e');
      return null;
    }
  }

  // ✅ FIXED: Khởi tạo learnmap progress với FetchPolicy.networkOnly
  static Future<Map<String, dynamic>?> startCourseLearnmap(String courseId) async {
    try {
      print('🚀 [LearnmapService] Starting fresh learnmap for course: $courseId');
      
      final result = await _client.mutate(MutationOptions(
        document: gql(startCourseLearnmapMutation),
        variables: {'courseId': courseId},
        fetchPolicy: FetchPolicy.networkOnly, // ✅ Fresh mutation
      ));

      if (result.hasException) {
        print('❌ startCourseLearnmap error: ${result.exception}');
        return null;
      }

      final data = result.data?['startCourseLearnmap'];
      print('📊 startCourseLearnmap response: $data');
      
      if (data != null && data['success'] == true) {
        final userProgress = data['userLearnmapProgress'];
        print('✅ [LearnmapService] Fresh learnmap started successfully');
        print('   - User ID: ${userProgress?['userId']}');
        print('   - Course ID: ${userProgress?['courseId']}');
        return userProgress;
      } else {
        print('❌ startCourseLearnmap failed: success=${data?['success']}, message=${data?['message']}');
        return null;
      }
    } catch (e) {
      print('❌ startCourseLearnmap exception: $e');
      return null;
    }
  }

  // ✅ FIXED: Cập nhật learnmap progress với FetchPolicy.networkOnly
  static Future<Map<String, dynamic>?> updateLearnmapProgress(String courseId, Map<String, dynamic> progressInput) async {
    try {
      print('🔄 [LearnmapService] Updating learnmap progress for course: $courseId');
      
      final result = await _client.mutate(MutationOptions(
        document: gql(updateLearnmapProgressMutation),
        variables: {
          'courseId': courseId,
          'progressInput': progressInput,
        },
        fetchPolicy: FetchPolicy.networkOnly, // ✅ Fresh mutation
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

  // ✅ FIXED: Lấy exercises với FetchPolicy.networkOnly
  static Future<List<Map<String, dynamic>>?> getExercisesByLesson(String lessonId) async {
    try {
      print('📚 [LearnmapService] Fetching fresh exercises for lesson: $lessonId');
      
      final result = await _client.query(QueryOptions(
        document: gql(getExercisesByLessonQuery),
        variables: {'lessonId': lessonId},
        fetchPolicy: FetchPolicy.networkOnly, // ✅ Fresh exercises
      ));

      if (result.hasException) {
        print('❌ getExercisesByLesson error: ${result.exception}');
        return null;
      }

      final data = result.data?['getExercisesByLesson'];
      print('📊 getExercisesByLesson response: $data');
      
      if (data != null && data['success'] == true) {
        final exercises = data['exercises'] as List<dynamic>?;
        print('✅ getExercisesByLesson success, found ${exercises?.length ?? 0} exercises');
        return exercises?.cast<Map<String, dynamic>>();
      } else {
        print('❌ getExercisesByLesson failed: success=${data?['success']}, message=${data?['message']}');
        return [];
      }
    } catch (e) {
      print('❌ getExercisesByLesson exception: $e');
      return null;
    }
  }

  // ✅ ADDED: Update exercise progress method
  static Future<Map<String, dynamic>?> updateExerciseProgress(String lessonId, Map<String, dynamic> exerciseProgressInput) async {
    try {
      print('🔄 [LearnmapService] Updating exercise progress for lesson: $lessonId');
      print('   - Exercise data: $exerciseProgressInput');
      
      final result = await _client.mutate(MutationOptions(
        document: gql(updateExerciseProgressMutation),
        variables: {
          'lessonId': lessonId,
          'exerciseProgressInput': exerciseProgressInput,
        },
        fetchPolicy: FetchPolicy.networkOnly, // ✅ Fresh mutation
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