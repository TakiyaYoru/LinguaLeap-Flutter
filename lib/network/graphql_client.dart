// lib/core/network/graphql_client.dart
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class GraphQLService {
  static GraphQLClient? _client;
  
  static GraphQLClient get client {
    if (_client == null) {
      final HttpLink httpLink = HttpLink(
        AppConstants.graphqlEndpoint,
      );
      
      // Auth link để tự động thêm token vào header
      final AuthLink authLink = AuthLink(
        getToken: () async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(AppConstants.tokenKey);
          return token != null ? 'Bearer $token' : null;
        },
      );
      
      final Link link = authLink.concat(httpLink);
      
      _client = GraphQLClient(
        link: link,
        cache: GraphQLCache(store: InMemoryStore()),
      );
    }
    return _client!;
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