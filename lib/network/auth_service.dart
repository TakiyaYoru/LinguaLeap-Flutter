// lib/network/auth_service.dart
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'graphql_client.dart';
import '../graphql/auth_queries.dart';
import '../constants/app_constants.dart';

class AuthService {
  // Test login với GraphQL
  static Future<Map<String, dynamic>?> testLogin(String email, String password) async {
    try {
      print(' Attempting login for: $email');
      print('🔗 GraphQL endpoint: ${AppConstants.graphqlEndpoint}');
      print('📤 Sending login mutation...');

      final MutationOptions options = MutationOptions(
        document: gql(AuthQueries.login),
        variables: {
          'input': {
            'email': email,
            'password': password,
          }
        },
      );

      final QueryResult result = await GraphQLService.client.mutate(options);
      
      print('📥 Login result: ${result.data}');
      print('📊 Login hasException: ${result.hasException}');
      
      if (result.hasException) {
        print('❌ Login exceptions: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      print('✅ Login successful');
      return result.data?['login'];
    } catch (e) {
      print('❌ Login error: $e');
      print('❌ Error type: ${e.runtimeType}');
      return null;
    }
  }

  // Test register với GraphQL
  static Future<Map<String, dynamic>?> testRegister(String email, String password, String username, String displayName) async {
    try {
      final MutationOptions options = MutationOptions(
        document: gql(AuthQueries.register),
        variables: {
          'input': {
            'email': email,
            'password': password,
            'username': username,
            'displayName': displayName,
          }
        },
      );

      final QueryResult result = await GraphQLService.client.mutate(options);
      
      print('Register result: ${result.data}');
      print('Register errors: ${result.exception}');
      
      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return result.data?['register'];
    } catch (e) {
      print('Register error: $e');
      return null;
    }
  }

  // Save token to SharedPreferences
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
  }

  // Get token from SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  // ✅ ENHANCED: Clear token AND reset GraphQL client
  static Future<void> clearToken() async {
    print('🚪 [AuthService] Starting logout process...');
    
    // 1. Clear token from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    print('✅ [AuthService] Token cleared from SharedPreferences');
    
    // 2. Reset GraphQL client and clear cache
    GraphQLService.resetClient();
    
    // 3. Optional: Clear any other cached data if needed
    // await prefs.clear(); // ← Use này nếu muốn clear toàn bộ SharedPreferences
    
    print('✅ [AuthService] Logout completed - all caches cleared');
  }

  // ✅ NEW: Logout and navigate
  static Future<void> logout(BuildContext context) async {
    await clearToken();
    if (context.mounted) {
      context.go('/login');
    }
  }

  // Get current user từ backend
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final QueryOptions options = QueryOptions(
        document: gql(AuthQueries.getCurrentUser),
        fetchPolicy: FetchPolicy.networkOnly, // Luôn lấy data mới
      );

      final QueryResult result = await GraphQLService.client.query(options);
      
      print('Get current user result: ${result.data}');
      print('Get current user errors: ${result.exception}');
      
      if (result.hasException) {
        print('getCurrentUser error: ${result.exception}');
        return null;
      }

      return result.data?['me'];
    } catch (e) {
      print('getCurrentUser exception: $e');
      return null;
    }
  }

  // ✅ NEW: Check if current user is admin
  static Future<bool> isAdmin() async {
    try {
      final user = await getCurrentUser();
      if (user == null) return false;
      
      final role = user['role'] as String?;
      return role == 'admin';
    } catch (e) {
      print('❌ Error checking admin status: $e');
      return false;
    }
  }

  // ✅ NEW: Get current user role
  static Future<String?> getUserRole() async {
    try {
      final user = await getCurrentUser();
      if (user == null) return null;
      
      return user['role'] as String?;
    } catch (e) {
      print('❌ Error getting user role: $e');
      return null;
    }
  }
}