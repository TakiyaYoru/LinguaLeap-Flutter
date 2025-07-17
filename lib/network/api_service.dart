// lib/core/network/api_service.dart
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

class ApiService {
  late Dio _dio;
  
  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
  }
  
  // Test kết nối với backend
  Future<bool> testConnection() async {
    try {
      final response = await _dio.get('/health');
      print('Backend response: ${response.data}');
      return response.statusCode == 200;
    } catch (e) {
      print('Connection error: $e');
      return false;
    }
  }
}