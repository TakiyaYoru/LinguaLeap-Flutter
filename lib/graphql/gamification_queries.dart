// ===============================================
// GAMIFICATION GRAPHQL QUERIES - LINGUALEAP
// ===============================================

class GamificationQueries {
  // Get user gamification stats
  static const String getGamificationStats = '''
    query GetGamificationStats {
      gamificationStats {
        level
        totalXP
        diamonds
        hearts
        currentStreak
        longestStreak
        isPremium
        heartsRefillTime
      }
    }
  ''';

  // Get leaderboard
  static const String getLeaderboard = '''
    query GetLeaderboard(\$limit: Int) {
      leaderboard(limit: \$limit) {
        id
        username
        displayName
        totalXP
        level
        diamonds
        currentStreak
        rank
      }
    }
  ''';

  // Complete lesson
  static const String completeLesson = '''
    mutation CompleteLesson(\$lessonId: ID!, \$score: Int) {
      completeLesson(lessonId: \$lessonId, score: \$score) {
        success
        message
        xpEarned
        diamondsEarned
        levelUpBonus
        newLevel
        newTotalXP
        newDiamonds
      }
    }
  ''';

  // Complete unit
  static const String completeUnit = '''
    mutation CompleteUnit(\$unitId: ID!, \$score: Int) {
      completeUnit(unitId: \$unitId, score: \$score) {
        success
        message
        xpEarned
        diamondsEarned
        levelUpBonus
        newLevel
        newTotalXP
        newDiamonds
      }
    }
  ''';

  // Buy hearts with diamonds
  static const String buyHearts = '''
    mutation BuyHearts(\$heartCount: Int!) {
      buyHearts(heartCount: \$heartCount) {
        success
        message
        heartsBought
        diamondsSpent
        newHearts
        newDiamonds
      }
    }
  ''';

  // Refill hearts with diamonds
  static const String refillHearts = '''
    mutation RefillHearts {
      refillHearts {
        success
        message
        heartsRefilled
        diamondsSpent
        newHearts
        newDiamonds
      }
    }
  ''';

  // Use heart
  static const String useHeart = '''
    mutation UseHeart {
      useHeart {
        level
        totalXP
        diamonds
        hearts
        currentStreak
        longestStreak
        isPremium
        heartsRefillTime
      }
    }
  ''';

  // Get daily goals progress
  static const String getDailyGoals = '''
    query GetDailyGoals {
      dailyGoals {
        lessonsCompleted
        xpEarned
        practiceTime
        streakMaintained
        totalGoals
        completedGoals
        resetTime
      }
    }
  ''';

  // Get user achievements
  static const String getUserAchievements = '''
    query GetUserAchievements {
      userAchievements {
        id
        title
        description
        icon
        color
        unlocked
        unlockedAt
        progress
        target
      }
    }
  ''';

  // Award practice rewards
  static const String awardPracticeRewards = '''
    mutation AwardPracticeRewards(\$xp: Int!, \$diamonds: Int!) {
      awardPracticeRewards(xp: \$xp, diamonds: \$diamonds) {
        success
        message
        xpAwarded
        diamondsAwarded
        newTotalXP
        newDiamonds
      }
    }
  ''';
} 