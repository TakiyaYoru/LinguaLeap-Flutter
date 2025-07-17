// lib/network/vocabulary_service.dart
import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_client.dart';
import '../graphql/vocabulary_queries.dart';

class VocabularyService {
  // Get user's vocabulary with filters
  static Future<List<Map<String, dynamic>>?> getMyVocabulary({
    bool? isLearned,
    String? category,
    String? search,
    String? sortBy,
    int? limit,
  }) async {
    try {
      print('🔍 Getting vocabulary with filters: ${{
        if (isLearned != null) 'isLearned': isLearned,
        if (category != null) 'category': category,
        if (search != null) 'search': search,
        if (sortBy != null) 'sortBy': sortBy,
        if (limit != null) 'limit': limit,
      }}');

      final QueryOptions options = QueryOptions(
        document: gql(VocabularyQueries.getMyVocabulary),
        variables: {
          'filters': {
            if (isLearned != null) 'isLearned': isLearned,
            if (category != null) 'category': category,
            if (search != null) 'search': search,
            if (sortBy != null) 'sortBy': sortBy,
            if (limit != null) 'limit': limit,
          }
        },
        fetchPolicy: FetchPolicy.networkOnly, // Force network call
      );

      print('🌐 Making GraphQL query...');
      final QueryResult result = await GraphQLService.client.query(options);

      print('📡 GraphQL Result:');
      print('  - hasException: ${result.hasException}');
      print('  - data: ${result.data}');
      print('  - errors: ${result.exception}');

      if (result.hasException) {
        print('❌ GraphQL Error: ${result.exception.toString()}');
        return null;
      }

      final List<dynamic>? vocabularyList = result.data?['myVocabulary'];
      print('📚 Vocabulary List: $vocabularyList');
      
      return vocabularyList?.cast<Map<String, dynamic>>();
    } catch (e) {
      print('💥 Exception in getMyVocabulary: $e');
      return null;
    }
  }

  // Get vocabulary statistics
  static Future<Map<String, dynamic>?> getMyVocabularyStats() async {
    try {
      print('📊 Fetching vocabulary stats...');
      
      final QueryOptions options = QueryOptions(
        document: gql(VocabularyQueries.getMyVocabularyStats),
        fetchPolicy: FetchPolicy.networkOnly, // Force fresh data
      );

      final QueryResult result = await GraphQLService.client.query(options);

      print('📈 Stats GraphQL result:');
      print('  - hasException: ${result.hasException}');
      print('  - data: ${result.data}');
      
      if (result.hasException) {
        print('❌ GraphQL Error in stats: ${result.exception.toString()}');
        return null;
      }

      final statsData = result.data?['myVocabularyStats'];
      print('📊 Raw stats data: $statsData');
      
      return statsData;
    } catch (e) {
      print('💥 Exception in getMyVocabularyStats: $e');
      return null;
    }
  }

  // Add vocabulary word
  static Future<Map<String, dynamic>?> addVocabularyWord({
    required String word,
    required String meaning,
    String? pronunciation,
    String? example,
    String? category,
    List<String>? tags,
    int? difficulty,
  }) async {
    try {
      final MutationOptions options = MutationOptions(
        document: gql(VocabularyQueries.addVocabularyWord),
        variables: {
          'input': {
            'word': word,
            'meaning': meaning,
            if (pronunciation != null) 'pronunciation': pronunciation,
            if (example != null) 'example': example,
            if (category != null) 'category': category,
            if (tags != null) 'tags': tags,
            if (difficulty != null) 'difficulty': difficulty,
          }
        },
      );

      final QueryResult result = await GraphQLService.client.mutate(options);

      if (result.hasException) {
        print('GraphQL Error: ${result.exception.toString()}');
        return null;
      }

      return result.data?['addVocabularyWord'];
    } catch (e) {
      print('Error adding vocabulary word: $e');
      return null;
    }
  }

  // Toggle learned status
  static Future<Map<String, dynamic>?> toggleVocabularyLearned(String id) async {
    try {
      final MutationOptions options = MutationOptions(
        document: gql(VocabularyQueries.toggleVocabularyLearned),
        variables: {'id': id},
      );

      final QueryResult result = await GraphQLService.client.mutate(options);

      if (result.hasException) {
        print('GraphQL Error: ${result.exception.toString()}');
        return null;
      }

      return result.data?['toggleVocabularyLearned'];
    } catch (e) {
      print('Error toggling vocabulary learned: $e');
      return null;
    }
  }

  // Delete vocabulary word
  static Future<bool> deleteVocabularyWord(String id) async {
    try {
      print('🗑️ Deleting vocabulary word: $id');
      
      final MutationOptions options = MutationOptions(
        document: gql(VocabularyQueries.deleteVocabularyWord),
        variables: {'id': id},
      );

      print('📡 Making delete mutation...');
      final QueryResult result = await GraphQLService.client.mutate(options);

      print('🔍 Delete result:');
      print('  - hasException: ${result.hasException}');
      print('  - data: ${result.data}');
      print('  - errors: ${result.exception}');

      if (result.hasException) {
        print('❌ GraphQL Error in delete: ${result.exception.toString()}');
        return false;
      }

      final deleteResult = result.data?['deleteVocabularyWord'];
      print('✅ Delete success: $deleteResult');
      
      return deleteResult ?? false;
    } catch (e) {
      print('💥 Exception in deleteVocabularyWord: $e');
      return false;
    }
  }
}