// ===============================================
// GAMIFICATION SERVICE - LINGUALEAP
// ===============================================

import 'dart:convert';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/gamification_queries.dart';
import 'graphql_client.dart';

// Import PracticeRewardResult model
class PracticeRewardResult {
  final bool success;
  final String message;
  final int xpAwarded;
  final int diamondsAwarded;
  final int newTotalXP;
  final int newDiamonds;

  PracticeRewardResult({
    required this.success,
    required this.message,
    required this.xpAwarded,
    required this.diamondsAwarded,
    required this.newTotalXP,
    required this.newDiamonds,
  });

  factory PracticeRewardResult.fromJson(Map<String, dynamic> json) {
    return PracticeRewardResult(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      xpAwarded: json['xpAwarded'] ?? 0,
      diamondsAwarded: json['diamondsAwarded'] ?? 0,
      newTotalXP: json['newTotalXP'] ?? 0,
      newDiamonds: json['newDiamonds'] ?? 0,
    );
  }
}

class GamificationService {
  static GraphQLClient get _client => GraphQLService.client;

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

  // Award practice rewards
  static Future<PracticeRewardResult> awardPracticeRewards({
    int xp = 5,
    int diamonds = 5,
  }) async {
    try {
      print('🏆 [GamificationService] Awarding practice rewards...');
      print('  - XP: $xp');
      print('  - Diamonds: $diamonds');
      
      final result = await _client.mutate(
        MutationOptions(
          document: gql(GamificationQueries.awardPracticeRewards),
          variables: {
            'xp': xp,
            'diamonds': diamonds,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        print('❌ [GamificationService] Error awarding practice rewards: ${result.exception}');
        throw Exception('Failed to award practice rewards: ${result.exception}');
      }

      final rewardData = result.data?['awardPracticeRewards'];
      print('✅ [GamificationService] Practice rewards awarded successfully');
      
      return PracticeRewardResult.fromJson(rewardData);
    } catch (e) {
      print('❌ [GamificationService] Exception awarding practice rewards: $e');
      throw Exception('Failed to award practice rewards: $e');
    }
  }

  // Award reading completion rewards
  static Future<PracticeRewardResult> awardReadingRewards({
    int xp = 10,
    int diamonds = 10,
  }) async {
    try {
      print('🏆 [GamificationService] Awarding reading completion rewards...');
      print('  - XP: $xp');
      print('  - Diamonds: $diamonds');
      
      final result = await _client.mutate(
        MutationOptions(
          document: gql(GamificationQueries.awardPracticeRewards), // Reuse same mutation
          variables: {
            'xp': xp,
            'diamonds': diamonds,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        print('❌ [GamificationService] Error awarding reading rewards: ${result.exception}');
        throw Exception('Failed to award reading rewards: ${result.exception}');
      }

      final rewardData = result.data?['awardPracticeRewards'];
      print('✅ [GamificationService] Reading rewards awarded successfully');
      
      return PracticeRewardResult.fromJson(rewardData);
    } catch (e) {
      print('❌ [GamificationService] Exception awarding reading rewards: $e');
      throw Exception('Failed to award reading rewards: $e');
    }
  }

  // Award speaking completion rewards
  static Future<PracticeRewardResult> awardSpeakingRewards({
    int xp = 15,
    int diamonds = 15,
  }) async {
    try {
      print('🏆 [GamificationService] Awarding speaking completion rewards...');
      print('  - XP: $xp');
      print('  - Diamonds: $diamonds');
      
      final result = await _client.mutate(
        MutationOptions(
          document: gql(GamificationQueries.awardPracticeRewards), // Reuse same mutation
          variables: {
            'xp': xp,
            'diamonds': diamonds,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        print('❌ [GamificationService] Error awarding speaking rewards: ${result.exception}');
        throw Exception('Failed to award speaking rewards: ${result.exception}');
      }

      final rewardData = result.data?['awardPracticeRewards'];
      print('✅ [GamificationService] Speaking rewards awarded successfully');
      
      return PracticeRewardResult.fromJson(rewardData);
    } catch (e) {
      print('❌ [GamificationService] Exception awarding speaking rewards: $e');
      throw Exception('Failed to award speaking rewards: $e');
    }
  }
} 