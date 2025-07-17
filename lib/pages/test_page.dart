import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/auth_queries.dart';
import '../graphql/course_queries.dart';
import '../graphql/progress_queries.dart';
import '../models/user_model.dart';
import '../models/course_model.dart';
import '../models/progress_model.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  String testResults = '';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Model Test Page'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: isLoading ? null : _testModels,
              child: Text(isLoading ? 'Testing...' : 'Test All Models'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    testResults.isEmpty ? 'Click "Test All Models" to start testing' : testResults,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testModels() async {
    setState(() {
      isLoading = true;
      testResults = '🧪 Starting model tests...\n\n';
    });

    try {
      // Test 1: User Model
      await _testUserModel();
      
      // Test 2: Course Model
      await _testCourseModel();
      
      // Test 3: Progress Models
      await _testProgressModels();

      setState(() {
        testResults += '\n✅ All tests completed successfully!';
      });
    } catch (e) {
      setState(() {
        testResults += '\n❌ Test failed: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _testUserModel() async {
    setState(() {
      testResults += '👤 Testing User Model...\n';
    });

    try {
      final client = GraphQLProvider.of(context).value;
      
      final result = await client.query(
        QueryOptions(
          document: gql(AuthQueries.getCurrentUser),
        ),
      );

      if (result.hasException) {
        throw Exception('GraphQL error: ${result.exception}');
      }

      final userData = result.data?['me'];
      if (userData == null) {
        throw Exception('No user data received');
      }

      // Test parsing
      final user = UserModel.fromJson(userData);
      
      setState(() {
        testResults += '✅ User Model Test PASSED\n';
        testResults += '   - ID: ${user.id}\n';
        testResults += '   - Username: ${user.username}\n';
        testResults += '   - Email: ${user.email}\n';
        testResults += '   - Level: ${user.currentLevel}\n';
        testResults += '   - XP: ${user.totalXP}\n';
        testResults += '   - Hearts: ${user.hearts}\n';
        testResults += '   - Role: ${user.role}\n';
        testResults += '   - Created: ${user.createdAt}\n';
        testResults += '   - Updated: ${user.updatedAt}\n\n';
      });
    } catch (e) {
      setState(() {
        testResults += '❌ User Model Test FAILED: $e\n\n';
      });
      rethrow;
    }
  }

  Future<void> _testCourseModel() async {
    setState(() {
      testResults += '📚 Testing Course Model...\n';
    });

    try {
      final client = GraphQLProvider.of(context).value;
      
      final result = await client.query(
        QueryOptions(
          document: gql(CourseQueries.getAllCourses),
        ),
      );

      if (result.hasException) {
        throw Exception('GraphQL error: ${result.exception}');
      }

      final coursesData = result.data?['courses'] as List<dynamic>?;
      if (coursesData == null || coursesData.isEmpty) {
        throw Exception('No courses data received');
      }

      // Test parsing first course
      final courseData = coursesData.first;
      final course = CourseModel.fromJson(courseData);
      
      setState(() {
        testResults += '✅ Course Model Test PASSED\n';
        testResults += '   - ID: ${course.id}\n';
        testResults += '   - Title: ${course.title}\n';
        testResults += '   - Level: ${course.level}\n';
        testResults += '   - Category: ${course.category}\n';
        testResults += '   - Skill Focus: ${course.skillFocus.join(', ')}\n';
        testResults += '   - Difficulty: ${course.difficulty}\n';
        testResults += '   - Total XP: ${course.totalXP}\n';
        testResults += '   - Enrollment: ${course.enrollmentCount}\n';
        testResults += '   - Completion: ${course.completionCount}\n';
        testResults += '   - Rating: ${course.averageRating}\n';
        testResults += '   - Slug: ${course.slug}\n';
        testResults += '   - Created By: ${course.createdBy?.username ?? 'N/A'}\n';
        testResults += '   - Created: ${course.createdAt}\n';
        testResults += '   - Updated: ${course.updatedAt}\n';
        
        if (course.challengeTest != null) {
          testResults += '   - Challenge: ${course.challengeTest!.totalQuestions} questions, ${course.challengeTest!.passPercentage}% pass\n';
        }
        
        testResults += '\n';
      });
    } catch (e) {
      setState(() {
        testResults += '❌ Course Model Test FAILED: $e\n\n';
      });
      rethrow;
    }
  }

  Future<void> _testProgressModels() async {
    setState(() {
      testResults += '📊 Testing Progress Models...\n';
    });

    try {
      final client = GraphQLProvider.of(context).value;
      
      final result = await client.query(
        QueryOptions(
          document: gql(ProgressQueries.getCompletedLessons),
        ),
      );

      if (result.hasException) {
        throw Exception('GraphQL error: ${result.exception}');
      }

      final progressData = result.data?['completedLessons'] as List<dynamic>?;
      
      setState(() {
        testResults += '✅ Progress Models Test PASSED\n';
        testResults += '   - Completed lessons count: ${progressData?.length ?? 0}\n';
        
        if (progressData != null && progressData.isNotEmpty) {
          final progress = LessonProgressModel.fromJson(progressData.first);
          testResults += '   - Sample progress:\n';
          testResults += '     * Lesson ID: ${progress.lessonId}\n';
          testResults += '     * Status: ${progress.status}\n';
          testResults += '     * XP Earned: ${progress.xpEarned}\n';
          testResults += '     * Attempts: ${progress.attempts}\n';
          testResults += '     * Best Score: ${progress.bestScore}\n';
          testResults += '     * Unlock Next: ${progress.unlockNextLesson}\n';
        }
        
        testResults += '\n';
      });
    } catch (e) {
      setState(() {
        testResults += '❌ Progress Models Test FAILED: $e\n\n';
      });
      rethrow;
    }
  }
} 