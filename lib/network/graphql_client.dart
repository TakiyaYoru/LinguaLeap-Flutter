// lib/network/graphql_client.dart
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class GraphQLService {
  static GraphQLClient? _client;
  
  static GraphQLClient get client {
    if (_client == null) {
      _client = _createClient();
    }
    return _client!;
  }
  
  // ✅ NEW: Create fresh client
  static GraphQLClient _createClient() {
    final HttpLink httpLink = HttpLink(
      AppConstants.graphqlEndpoint,
      defaultHeaders: {
        'Content-Type': 'application/json',
      },
    );
    
    // Auth link để tự động thêm token vào header
    final AuthLink authLink = AuthLink(
      getToken: () async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(AppConstants.tokenKey);
        print('🔐 [GraphQLClient] Token from SharedPreferences: ${token != null ? 'Found' : 'Not found'}');
        if (token != null) {
          print('🔐 [GraphQLClient] Token length: ${token.length}');
          print('🔐 [GraphQLClient] Token preview: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
        }
        return token != null ? 'Bearer $token' : null;
      },
    );
    
    final Link link = authLink.concat(httpLink);
    
    return GraphQLClient(
      link: link,
      cache: GraphQLCache(store: InMemoryStore()),
    );
  }
  
  // ✅ NEW: Reset client và clear cache
  static void resetClient() {
    print('🔄 [GraphQLService] Resetting client and clearing cache...');
    _client?.cache.store.reset();
    _client = null;
    print('✅ [GraphQLService] Client reset completed');
  }
  
  // ✅ NEW: Clear cache only (không reset client)
  static void clearCache() {
    print('🧹 [GraphQLService] Clearing GraphQL cache...');
    _client?.cache.store.reset();
    print('✅ [GraphQLService] Cache cleared');
  }
  
  // Test query đơn giản
  static const String testQuery = '''
    query {
      hello
    }
  ''';
  
  static Future<bool> testGraphQLConnection() async {
    try {
      print('🔍 Testing GraphQL connection to: ${AppConstants.graphqlEndpoint}');
      
      final QueryOptions options = QueryOptions(document: gql(testQuery));
      print('📤 Sending GraphQL query: $testQuery');
      
      final QueryResult result = await client.query(options);
      
      print('📥 GraphQL response: ${result.data}');
      print('📊 GraphQL hasException: ${result.hasException}');
      
      if (result.hasException) {
        print('❌ GraphQL exceptions: ${result.exception}');
        print('❌ GraphQL exception type: ${result.exception.runtimeType}');
      }
      
      return !result.hasException;
    } catch (e) {
      print('❌ GraphQL connection error: $e');
      print('❌ Error type: ${e.runtimeType}');
      return false;
    }
  }
}