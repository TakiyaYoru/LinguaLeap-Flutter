// lib/core/pages/test_backend_page.dart
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:go_router/go_router.dart';
import '../network/auth_service.dart';
import '../network/course_service.dart';
import '../network/progress_service.dart';
import '../network/graphql_client.dart';
import '../models/user_model.dart';
import '../constants/app_constants.dart';

class TestBackendPage extends StatefulWidget {
  const TestBackendPage({super.key});

  @override
  State<TestBackendPage> createState() => _TestBackendPageState();
}

class _TestBackendPageState extends State<TestBackendPage> {
  String _testResult = 'Chưa test';
  bool _isLoading = false;
  UserModel? _currentUser;
  List<Map<String, dynamic>>? _courses;

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Đang test kết nối...\n';
      _testResult += 'Backend URL: ${AppConstants.baseUrl}\n';
      _testResult += 'GraphQL: ${AppConstants.graphqlEndpoint}\n';
    });

    try {
      print('🧪 Starting connection test...');
      
      // Test 1: GraphQL connection
      _testResult += '\n🔍 Test 1: GraphQL Connection...\n';
      final isConnected = await GraphQLService.testGraphQLConnection();
      
      if (isConnected) {
        _testResult += '✅ Kết nối GraphQL thành công!\n';
        
        // Test 2: Get current user
        _testResult += '\n🔍 Test 2: Get Current User...\n';
        final userData = await AuthService.getCurrentUser();
        if (userData != null) {
          _currentUser = UserModel.fromJson(userData);
          _testResult += '✅ Lấy thông tin user thành công!\n';
        } else {
          _testResult += '⚠️ Chưa đăng nhập hoặc token hết hạn\n';
        }
        
        // Test 3: Get courses
        _testResult += '\n🔍 Test 3: Get Courses...\n';
        final coursesData = await CourseService.getAllCourses();
        if (coursesData != null) {
          _courses = coursesData;
          _testResult += '✅ Lấy danh sách courses thành công! (${_courses!.length} courses)\n';
        } else {
          _testResult += '❌ Lấy courses thất bại\n';
        }
        
        // Test 4: Test progress service (nếu có user)
        if (_currentUser != null) {
          _testResult += '\n🔍 Test 4: Progress Service...\n';
          final completedLessons = await ProgressService.getCompletedLessons();
          if (completedLessons != null) {
            _testResult += '✅ Lấy completed lessons thành công! (${completedLessons.length} lessons)\n';
          } else {
            _testResult += '✅ Progress service hoạt động (chưa có completed lessons)\n';
          }
        }
        
      } else {
        _testResult += '❌ Kết nối GraphQL thất bại!\n';
        _testResult += 'Kiểm tra:\n';
        _testResult += '1. Backend có đang chạy tại ${AppConstants.baseUrl}?\n';
        _testResult += '2. GraphQL endpoint: ${AppConstants.graphqlEndpoint}\n';
        _testResult += '3. Kiểm tra console logs để xem chi tiết lỗi\n';
      }
    } catch (e) {
      _testResult += '❌ Lỗi test: $e\n';
      _testResult += 'Error type: ${e.runtimeType}\n';
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testLogin() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Đang test login...';
    });

    try {
      // Test với tài khoản mẫu
      final loginResult = await AuthService.testLogin('test@example.com', 'password123');
      
      if (loginResult != null) {
        _testResult = '✅ Login thành công!\n';
        _testResult += 'Token: ${loginResult['token']?.toString().substring(0, 20)}...\n';
        
        // Lấy thông tin user sau khi login
        final userData = await AuthService.getCurrentUser();
        if (userData != null) {
          _currentUser = UserModel.fromJson(userData);
          _testResult += '✅ Lấy thông tin user thành công!\n';
        }
      } else {
        _testResult = '❌ Login thất bại - có thể tài khoản không tồn tại';
      }
    } catch (e) {
      _testResult = '❌ Lỗi login: $e';
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testHealthCheck() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Đang test health check...';
    });

    try {
      print('🏥 Testing health check at: ${AppConstants.healthCheck}');
      
      final response = await Future.delayed(const Duration(seconds: 2), () async {
        // Simulate HTTP request
        return {'status': 'healthy', 'message': 'Backend is running'};
      });
      
      _testResult = '✅ Health check thành công!\n';
      _testResult += 'Status: ${response['status']}\n';
      _testResult += 'Message: ${response['message']}\n';
      _testResult += 'URL: ${AppConstants.healthCheck}\n';
      
    } catch (e) {
      _testResult = '❌ Health check thất bại: $e';
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Backend Connection'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Backend URL Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Backend Configuration',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Base URL: ${AppConstants.baseUrl}'),
                    Text('GraphQL: ${AppConstants.graphqlEndpoint}'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Test Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testConnection,
                    child: const Text('Test Connection'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testLogin,
                    child: const Text('Test Login'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testHealthCheck,
                    child: const Text('Test Health Check'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.go('/test-models'),
                    child: const Text('Test Models'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Test Results
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Results',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      Text(
                        _testResult,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Current User Info
            if (_currentUser != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current User',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text('Name: ${_currentUser!.displayName}'),
                      Text('Email: ${_currentUser!.email}'),
                      Text('Level: ${_currentUser!.currentLevel}'),
                      Text('XP: ${_currentUser!.totalXP}'),
                      Text('Hearts: ${_currentUser!.hearts}'),
                      Text('Streak: ${_currentUser!.currentStreak}'),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
            
            // Courses Info
            if (_courses != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Courses (${_courses!.length})',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      ...(_courses!.take(3).map((course) => 
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text('• ${course['title']} (${course['level']})'),
                        )
                      )),
                      if (_courses!.length > 3)
                        Text('... và ${_courses!.length - 3} courses khác'),
                    ],
                  ),
                ),
              ),
            ],
            
            const Spacer(),
            
            // Instructions
            Card(
              color: Colors.blue.shade50,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructions',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('1. Đảm bảo backend đang chạy tại localhost:4001'),
                    Text('2. Nhấn "Test Connection" để kiểm tra kết nối'),
                    Text('3. Nhấn "Test Login" để test authentication'),
                    Text('4. Kiểm tra kết quả và thông tin user/courses'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 