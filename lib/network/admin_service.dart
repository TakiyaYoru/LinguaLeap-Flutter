// lib/network/admin_service.dart
import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_client.dart';
import '../graphql/admin_queries.dart';
import '../models/course_model.dart';
import '../models/unit_model.dart';
import '../models/lesson_model.dart';

class AdminService {
  // Get all courses for admin
  static Future<List<CourseModel>> getAllCourses() async {
    try {
      print('📚 [AdminService] Getting all courses...');

      final QueryOptions options = QueryOptions(
        document: gql(AdminQueries.getAllCourses),
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult result = await GraphQLService.client.query(options);
      
      print('📥 [AdminService] Get courses result: ${result.data}');
      
      if (result.hasException) {
        print('❌ [AdminService] Get courses error: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      final courses = result.data?['adminCourses'] as List<dynamic>? ?? [];
      print('📊 [AdminService] Raw courses data: ${courses.length} items');
      
      final courseModels = courses.map((course) {
        try {
          return CourseModel.fromJson(course);
        } catch (e) {
          print('❌ [AdminService] Error parsing course: $e');
          print('📋 [AdminService] Course data: $course');
          rethrow;
        }
      }).toList();
      
      print('✅ [AdminService] Successfully parsed ${courseModels.length} courses');
      return courseModels;
    } catch (e) {
      print('❌ [AdminService] Error getting courses: $e');
      throw Exception('Failed to load courses: $e');
    }
  }

  // Create new course
  static Future<Map<String, dynamic>?> createCourse(Map<String, dynamic> courseData) async {
    try {
      print('📚 [AdminService] Creating course: ${courseData['title']}');

      final MutationOptions options = MutationOptions(
        document: gql(AdminQueries.createCourse),
        variables: {
          'input': courseData,
        },
      );

      final QueryResult result = await GraphQLService.client.mutate(options);
      
      print('📥 [AdminService] Create course result: ${result.data}');
      
      if (result.hasException) {
        print('❌ [AdminService] Create course error: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      return result.data?['createCourse'];
    } catch (e) {
      print('❌ [AdminService] Error creating course: $e');
      throw Exception('Failed to create course: $e');
    }
  }

  // Update course
  static Future<Map<String, dynamic>?> updateCourse(String courseId, Map<String, dynamic> courseData) async {
    try {
      print('📚 [AdminService] Updating course: $courseId');

      final MutationOptions options = MutationOptions(
        document: gql(AdminQueries.updateCourse),
        variables: {
          'id': courseId,
          'input': courseData,
        },
      );

      final QueryResult result = await GraphQLService.client.mutate(options);
      
      print('📥 [AdminService] Update course result: ${result.data}');
      
      if (result.hasException) {
        print('❌ [AdminService] Update course error: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      return result.data?['updateCourse'];
    } catch (e) {
      print('❌ [AdminService] Error updating course: $e');
      throw Exception('Failed to update course: $e');
    }
  }

  // Delete course
  static Future<bool> deleteCourse(String courseId) async {
    try {
      print('🗑️ [AdminService] Deleting course: $courseId');

      final MutationOptions options = MutationOptions(
        document: gql(AdminQueries.deleteCourse),
        variables: {
          'id': courseId,
        },
      );

      final QueryResult result = await GraphQLService.client.mutate(options);
      
      print('📥 [AdminService] Delete course result: ${result.data}');
      
      if (result.hasException) {
        print('❌ [AdminService] Delete course error: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      return result.data?['deleteCourse'] ?? false;
    } catch (e) {
      print('❌ [AdminService] Error deleting course: $e');
      throw Exception('Failed to delete course: $e');
    }
  }

  // Publish course
  static Future<Map<String, dynamic>?> publishCourse(String courseId) async {
    try {
      print('📢 [AdminService] Publishing course: $courseId');

      final MutationOptions options = MutationOptions(
        document: gql(AdminQueries.publishCourse),
        variables: {
          'id': courseId,
        },
      );

      final QueryResult result = await GraphQLService.client.mutate(options);
      
      print('📥 [AdminService] Publish course result: ${result.data}');
      
      if (result.hasException) {
        print('❌ [AdminService] Publish course error: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      return result.data?['publishCourse'];
    } catch (e) {
      print('❌ [AdminService] Error publishing course: $e');
      throw Exception('Failed to publish course: $e');
    }
  }

  // Unpublish course
  static Future<Map<String, dynamic>?> unpublishCourse(String courseId) async {
    try {
      print('📢 [AdminService] Unpublishing course: $courseId');

      final MutationOptions options = MutationOptions(
        document: gql(AdminQueries.unpublishCourse),
        variables: {
          'id': courseId,
        },
      );

      final QueryResult result = await GraphQLService.client.mutate(options);
      
      print('📥 [AdminService] Unpublish course result: ${result.data}');
      
      if (result.hasException) {
        print('❌ [AdminService] Unpublish course error: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      return result.data?['unpublishCourse'];
    } catch (e) {
      print('❌ [AdminService] Error unpublishing course: $e');
      throw Exception('Failed to unpublish course: $e');
    }
  }

  // ===============================================
  // UNIT CRUD OPERATIONS
  // ===============================================

  // Get all units
  static Future<List<UnitModel>> getAllUnits() async {
    try {
      print('📚 [AdminService] Getting all units...');

      final QueryOptions options = QueryOptions(
        document: gql(AdminQueries.getAllUnits),
        fetchPolicy: FetchPolicy.noCache,
      );

      final QueryResult result = await GraphQLService.client.query(options);
      
      print('📥 [AdminService] Get units result: ${result.data}');
      
      if (result.hasException) {
        print('❌ [AdminService] Get units error: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      final units = result.data?['adminUnits'] as List<dynamic>? ?? [];
      print('📋 [AdminService] Parsing ${units.length} units...');
      
      final unitModels = units.map((unit) {
        try {
          return UnitModel.fromJson(unit);
        } catch (e) {
          print('⚠️ [AdminService] Error parsing unit: $e');
          return null;
        }
      }).whereType<UnitModel>().toList();
      
      print('✅ [AdminService] Successfully parsed ${unitModels.length} units');
      return unitModels;
    } catch (e) {
      print('❌ [AdminService] Error getting units: $e');
      throw Exception('Failed to get units: $e');
    }
  }

  // Create unit
  static Future<Map<String, dynamic>?> createUnit(Map<String, dynamic> unitData) async {
    try {
      print('➕ [AdminService] Creating unit: $unitData');

      final MutationOptions options = MutationOptions(
        document: gql(AdminQueries.createUnit),
        variables: {
          'input': unitData,
        },
      );

      final QueryResult result = await GraphQLService.client.mutate(options);
      
      print('📥 [AdminService] Create unit result: ${result.data}');
      
      if (result.hasException) {
        print('❌ [AdminService] Create unit error: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      return result.data?['createUnit'];
    } catch (e) {
      print('❌ [AdminService] Error creating unit: $e');
      throw Exception('Failed to create unit: $e');
    }
  }

  // Update unit
  static Future<Map<String, dynamic>?> updateUnit(String unitId, Map<String, dynamic> unitData) async {
    try {
      print('✏️ [AdminService] Updating unit: $unitId');

      final MutationOptions options = MutationOptions(
        document: gql(AdminQueries.updateUnit),
        variables: {
          'id': unitId,
          'input': unitData,
        },
      );

      final QueryResult result = await GraphQLService.client.mutate(options);
      
      print('📥 [AdminService] Update unit result: ${result.data}');
      
      if (result.hasException) {
        print('❌ [AdminService] Update unit error: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      return result.data?['updateUnit'];
    } catch (e) {
      print('❌ [AdminService] Error updating unit: $e');
      throw Exception('Failed to update unit: $e');
    }
  }

  // Delete unit
  static Future<bool> deleteUnit(String unitId) async {
    try {
      print('🗑️ [AdminService] Deleting unit: $unitId');

      final MutationOptions options = MutationOptions(
        document: gql(AdminQueries.deleteUnit),
        variables: {
          'id': unitId,
        },
      );

      final QueryResult result = await GraphQLService.client.mutate(options);
      
      print('📥 [AdminService] Delete unit result: ${result.data}');
      
      if (result.hasException) {
        print('❌ [AdminService] Delete unit error: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      return result.data?['deleteUnit'] ?? false;
    } catch (e) {
      print('❌ [AdminService] Error deleting unit: $e');
      throw Exception('Failed to delete unit: $e');
    }
  }

  // Publish unit
  static Future<Map<String, dynamic>?> publishUnit(String unitId) async {
    try {
      print('📢 [AdminService] Publishing unit: $unitId');

      final MutationOptions options = MutationOptions(
        document: gql(AdminQueries.publishUnit),
        variables: {
          'id': unitId,
        },
      );

      final QueryResult result = await GraphQLService.client.mutate(options);
      
      print('📥 [AdminService] Publish unit result: ${result.data}');
      
      if (result.hasException) {
        print('❌ [AdminService] Publish unit error: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      return result.data?['publishUnit'];
    } catch (e) {
      print('❌ [AdminService] Error publishing unit: $e');
      throw Exception('Failed to publish unit: $e');
    }
  }

  // Unpublish unit
  static Future<Map<String, dynamic>?> unpublishUnit(String unitId) async {
    try {
      print('📢 [AdminService] Unpublishing unit: $unitId');

      final MutationOptions options = MutationOptions(
        document: gql(AdminQueries.unpublishUnit),
        variables: {
          'id': unitId,
        },
      );

      final QueryResult result = await GraphQLService.client.mutate(options);
      
      print('📥 [AdminService] Unpublish unit result: ${result.data}');
      
      if (result.hasException) {
        print('❌ [AdminService] Unpublish unit error: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      return result.data?['unpublishUnit'];
    } catch (e) {
      print('❌ [AdminService] Error unpublishing unit: $e');
      throw Exception('Failed to unpublish unit: $e');
    }
  }

  // ===============================================
  // LESSON METHODS
  // ===============================================

  // Get all lessons
  static Future<List<LessonModel>> getAllLessons() async {
    try {
      print('📝 [AdminService] Getting all lessons...');

      final QueryOptions options = QueryOptions(
        document: gql(AdminQueries.getAllLessons),
        fetchPolicy: FetchPolicy.noCache,
      );

      final QueryResult result = await GraphQLService.client.query(options);
      
      print('📥 [AdminService] Get lessons result: ${result.data}');
      
      if (result.hasException) {
        print('❌ [AdminService] Get lessons error: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      final List<dynamic> lessonsData = result.data?['adminLessons'] ?? [];
      print('📊 [AdminService] Raw lessons data: ${lessonsData.length} items');
      
      final List<LessonModel> lessons = lessonsData
          .map((lesson) => LessonModel.fromJson(lesson))
          .toList();
      
      print('✅ [AdminService] Successfully parsed ${lessons.length} lessons');
      return lessons;
    } catch (e) {
      print('❌ [AdminService] Error getting lessons: $e');
      throw Exception('Failed to get lessons: $e');
    }
  }

  // Create lesson
  static Future<Map<String, dynamic>?> createLesson(Map<String, dynamic> lessonData) async {
    try {
      print('📝 [AdminService] Creating lesson: ${lessonData['title']}');

      final MutationOptions options = MutationOptions(
        document: gql(AdminQueries.createLesson),
        variables: {
          'input': lessonData,
        },
      );

      final QueryResult result = await GraphQLService.client.mutate(options);
      
      print('📥 [AdminService] Create lesson result: ${result.data}');
      
      if (result.hasException) {
        print('❌ [AdminService] Create lesson error: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      return result.data?['createLesson'];
    } catch (e) {
      print('❌ [AdminService] Error creating lesson: $e');
      throw Exception('Failed to create lesson: $e');
    }
  }

  // Update lesson
  static Future<Map<String, dynamic>?> updateLesson(String lessonId, Map<String, dynamic> lessonData) async {
    try {
      print('📝 [AdminService] Updating lesson: $lessonId');

      final MutationOptions options = MutationOptions(
        document: gql(AdminQueries.updateLesson),
        variables: {
          'id': lessonId,
          'input': lessonData,
        },
      );

      final QueryResult result = await GraphQLService.client.mutate(options);
      
      print('📥 [AdminService] Update lesson result: ${result.data}');
      
      if (result.hasException) {
        print('❌ [AdminService] Update lesson error: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      return result.data?['updateLesson'];
    } catch (e) {
      print('❌ [AdminService] Error updating lesson: $e');
      throw Exception('Failed to update lesson: $e');
    }
  }

  // Delete lesson
  static Future<bool> deleteLesson(String lessonId) async {
    try {
      print('🗑️ [AdminService] Deleting lesson: $lessonId');

      final MutationOptions options = MutationOptions(
        document: gql(AdminQueries.deleteLesson),
        variables: {
          'id': lessonId,
        },
      );

      final QueryResult result = await GraphQLService.client.mutate(options);
      
      print('📥 [AdminService] Delete lesson result: ${result.data}');
      
      if (result.hasException) {
        print('❌ [AdminService] Delete lesson error: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      return result.data?['deleteLesson'] ?? false;
    } catch (e) {
      print('❌ [AdminService] Error deleting lesson: $e');
      throw Exception('Failed to delete lesson: $e');
    }
  }

  // Publish lesson
  static Future<Map<String, dynamic>?> publishLesson(String lessonId) async {
    try {
      print('📢 [AdminService] Publishing lesson: $lessonId');

      final MutationOptions options = MutationOptions(
        document: gql(AdminQueries.publishLesson),
        variables: {
          'id': lessonId,
        },
      );

      final QueryResult result = await GraphQLService.client.mutate(options);
      
      print('📥 [AdminService] Publish lesson result: ${result.data}');
      
      if (result.hasException) {
        print('❌ [AdminService] Publish lesson error: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      return result.data?['publishLesson'];
    } catch (e) {
      print('❌ [AdminService] Error publishing lesson: $e');
      throw Exception('Failed to publish lesson: $e');
    }
  }

  // Unpublish lesson
  static Future<Map<String, dynamic>?> unpublishLesson(String lessonId) async {
    try {
      print('📢 [AdminService] Unpublishing lesson: $lessonId');

      final MutationOptions options = MutationOptions(
        document: gql(AdminQueries.unpublishLesson),
        variables: {
          'id': lessonId,
        },
      );

      final QueryResult result = await GraphQLService.client.mutate(options);
      
      print('📥 [AdminService] Unpublish lesson result: ${result.data}');
      
      if (result.hasException) {
        print('❌ [AdminService] Unpublish lesson error: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      return result.data?['unpublishLesson'];
    } catch (e) {
      print('❌ [AdminService] Error unpublishing lesson: $e');
      throw Exception('Failed to unpublish lesson: $e');
    }
  }
} 