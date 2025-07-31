// ===============================================
// GAMIFICATION SERVICE - LINGUALEAP
// ===============================================

import 'dart:convert';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/gamification_queries.dart';
import 'graphql_client.dart';

class GamificationService {

  // Get user gamification stats
  static Future<Map<String, dynamic>?> getGamificationStats() async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(GamificationQueries.getGamificationStats),
      );

      final QueryResult result = await GraphQLService.client.query(options);
      
      if (result.hasException) {
        print('❌ Error getting gamification stats: ${result.exception}');
        return null;
      }

      return result.data?['gamificationStats'];
    } catch (e) {
      print('❌ Error getting gamification stats: $e');
      return null;
    }
  }

  // Get leaderboard
  static Future<List<Map<String, dynamic>>?> getLeaderboard({int limit = 50}) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(GamificationQueries.getLeaderboard),
        variables: {'limit': limit},
      );

      final QueryResult result = await GraphQLService.client.query(options);
      
      if (result.hasException) {
        print('❌ Error getting leaderboard: ${result.exception}');
        return null;
      }

      final List<dynamic> leaderboardData = result.data?['leaderboard'] ?? [];
      return leaderboardData.cast<Map<String, dynamic>>();
    } catch (e) {
      print('❌ Error getting leaderboard: $e');
      return null;
    }
  }

  // Complete lesson
  static Future<Map<String, dynamic>?> completeLesson(String lessonId, {int score = 0}) async {
    try {
      final MutationOptions options = MutationOptions(
        document: gql(GamificationQueries.completeLesson),
        variables: {
          'lessonId': lessonId,
          'score': score,
        },
      );

      final QueryResult result = await GraphQLService.client.mutate(options);
      
      if (result.hasException) {
        print('❌ Error completing lesson: ${result.exception}');
        return null;
      }

      return result.data?['completeLesson'];
    } catch (e) {
      print('❌ Error completing lesson: $e');
      return null;
    }
  }

  // Complete unit
  static Future<Map<String, dynamic>?> completeUnit(String unitId, {int score = 0}) async {
    try {
      final MutationOptions options = MutationOptions(
        document: gql(GamificationQueries.completeUnit),
        variables: {
          'unitId': unitId,
          'score': score,
        },
      );

      final QueryResult result = await GraphQLService.client.mutate(options);
      
      if (result.hasException) {
        print('❌ Error completing unit: ${result.exception}');
        return null;
      }

      return result.data?['completeUnit'];
    } catch (e) {
      print('❌ Error completing unit: $e');
      return null;
    }
  }

  // Buy hearts with diamonds
  static Future<Map<String, dynamic>?> buyHearts(int heartCount) async {
    try {
      final MutationOptions options = MutationOptions(
        document: gql(GamificationQueries.buyHearts),
        variables: {'heartCount': heartCount},
      );

      final QueryResult result = await GraphQLService.client.mutate(options);
      
      if (result.hasException) {
        print('❌ Error buying hearts: ${result.exception}');
        return null;
      }

      return result.data?['buyHearts'];
    } catch (e) {
      print('❌ Error buying hearts: $e');
      return null;
    }
  }

  // Refill hearts with diamonds
  static Future<Map<String, dynamic>?> refillHearts() async {
    try {
      final MutationOptions options = MutationOptions(
        document: gql(GamificationQueries.refillHearts),
      );

      final QueryResult result = await GraphQLService.client.mutate(options);
      
      if (result.hasException) {
        print('❌ Error refilling hearts: ${result.exception}');
        return null;
      }

      return result.data?['refillHearts'];
    } catch (e) {
      print('❌ Error refilling hearts: $e');
      return null;
    }
  }

  // Use heart
  static Future<Map<String, dynamic>?> useHeart() async {
    try {
      final MutationOptions options = MutationOptions(
        document: gql(GamificationQueries.useHeart),
      );

      final QueryResult result = await GraphQLService.client.mutate(options);
      
      if (result.hasException) {
        print('❌ Error using heart: ${result.exception}');
        return null;
      }

      return result.data?['useHeart'];
    } catch (e) {
      print('❌ Error using heart: $e');
      return null;
    }
  }

  // Get daily goals progress
  static Future<Map<String, dynamic>?> getDailyGoals() async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(GamificationQueries.getDailyGoals),
      );

      final QueryResult result = await GraphQLService.client.query(options);
      
      if (result.hasException) {
        print('❌ Error getting daily goals: ${result.exception}');
        return null;
      }

      return result.data?['dailyGoals'];
    } catch (e) {
      print('❌ Error getting daily goals: $e');
      return null;
    }
  }

  // Get user achievements
  static Future<List<Map<String, dynamic>>?> getUserAchievements() async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(GamificationQueries.getUserAchievements),
      );

      final QueryResult result = await GraphQLService.client.query(options);
      
      if (result.hasException) {
        print('❌ Error getting user achievements: ${result.exception}');
        return null;
      }

      final List<dynamic> achievementsData = result.data?['userAchievements'] ?? [];
      return achievementsData.cast<Map<String, dynamic>>();
    } catch (e) {
      print('❌ Error getting user achievements: $e');
      return null;
    }
  }
} 