// lib/core/constants/app_constants.dart
import '../utils/platform_helper.dart';

class AppConstants {
  static const String appName = 'LinguaLeap';
  
  // Backend URLs - Dynamic based on platform
  static String get baseUrl => PlatformHelper.getBackendUrl();
  
  // Test endpoint
  static String get healthCheck => PlatformHelper.getHealthCheckUrl();
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userDataKey = 'user_data';
  
  // GraphQL endpoint
  static String get graphqlEndpoint => PlatformHelper.getGraphQLEndpoint();
}