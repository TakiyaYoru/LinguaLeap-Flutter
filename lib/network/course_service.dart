// lib/core/network/course_service.dart
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/course_queries.dart';
import '../constants/app_constants.dart';
import 'graphql_client.dart';

class CourseService {
  // Get all courses
  static Future<List<Map<String, dynamic>>?> getAllCourses() async {
    try {
      print('📚 Attempting to get all courses');
      print('🔗 GraphQL endpoint: ${AppConstants.graphqlEndpoint}');
      
      final QueryOptions options = QueryOptions(
        document: gql(CourseQueries.getAllCourses),
        fetchPolicy: FetchPolicy.networkOnly,
      );

      print('📤 Sending getCourses query...');
      final QueryResult result = await GraphQLService.client.query(options);
      
      print('📥 Get courses result: ${result.data}');
      print('📊 Get courses hasException: ${result.hasException}');
      
      if (result.hasException) {
        print('❌ Get courses exceptions: ${result.exception}');
        print('❌ Get courses exception type: ${result.exception.runtimeType}');
        return null;
      }

      final coursesData = result.data?['courses'];
      if (coursesData is List) {
        print('✅ Found ${coursesData.length} courses');
        return coursesData.cast<Map<String, dynamic>>();
      }
      
      print('⚠️ No courses data found');
      return null;
    } catch (e) {
      print('❌ Get courses error: $e');
      print('❌ Error type: ${e.runtimeType}');
      return null;
    }
  }

  // Get single course
  static Future<Map<String, dynamic>?> getCourse(String courseId) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(CourseQueries.getCourse),
        variables: {'id': courseId},
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult result = await GraphQLService.client.query(options);
      
      if (result.hasException) {
        print('getCourse error: ${result.exception}');
        return null;
      }

      return result.data?['course'];
    } catch (e) {
      print('getCourse error: $e');
      return null;
    }
  }

  // Get course units
  static Future<List<Map<String, dynamic>>?> getCourseUnits(String courseId) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(CourseQueries.getCourseUnits),
        variables: {'courseId': courseId},
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult result = await GraphQLService.client.query(options);
      
      if (result.hasException) {
        print('getCourseUnits error: ${result.exception}');
        return null;
      }

      final unitsData = result.data?['courseUnits'];
      if (unitsData is List) {
        return unitsData.cast<Map<String, dynamic>>();
      }
      
      return null;
    } catch (e) {
      print('getCourseUnits error: $e');
      return null;
    }
  }
}