// lib/core/graphql/auth_queries.dart

class AuthQueries {
  // Login mutation - sử dụng input object
  static const String login = '''
    mutation Login(\$input: LoginInput!) {
      login(input: \$input) {
        user {
          id
          username
          email
          displayName
          avatar
          currentLevel
          level
          totalXP
          diamonds
          hearts
          currentStreak
          longestStreak
          subscriptionType
          isPremium
          dailyGoal
          isEmailVerified
          isActive
          role
          createdAt
          updatedAt
        }
        token
      }
    }
  ''';

  // Register mutation - sử dụng input object
  static const String register = '''
    mutation Register(\$input: RegisterInput!) {
      register(input: \$input) {
        user {
          id
          username
          email
          displayName
          avatar
          currentLevel
          level
          totalXP
          diamonds
          hearts
          currentStreak
          longestStreak
          subscriptionType
          isPremium
          dailyGoal
          isEmailVerified
          isActive
          role
          createdAt
          updatedAt
        }
        token
      }
    }
  ''';

  // Get current user query
  static const String getCurrentUser = '''
    query GetCurrentUser {
      me {
        id
        username
        email
        displayName
        avatar
        currentLevel
        level
        totalXP
        diamonds
        hearts
        currentStreak
        longestStreak
        subscriptionType
        isPremium
        dailyGoal
        isEmailVerified
        isActive
        role
        createdAt
        updatedAt
      }
    }
  ''';

  // Update profile mutation
  static const String updateProfile = '''
    mutation UpdateProfile(\$input: UpdateProfileInput!) {
      updateProfile(input: \$input) {
        success
        message
        user {
          id
          username
          email
          displayName
          avatar
          bio
          currentLevel
          level
          totalXP
          diamonds
          hearts
          currentStreak
          longestStreak
          subscriptionType
          isPremium
          dailyGoal
          isEmailVerified
          isActive
          role
          createdAt
          updatedAt
        }
      }
    }
  ''';

  // Google authentication mutation
  static const String googleAuth = '''
    mutation GoogleAuth(\$input: GoogleAuthInput!) {
      googleAuth(input: \$input) {
        success
        message
        token
        user {
          id
          username
          email
          displayName
          avatar
          bio
          currentLevel
          level
          totalXP
          diamonds
          hearts
          currentStreak
          longestStreak
          subscriptionType
          isPremium
          dailyGoal
          isEmailVerified
          isActive
          role
          createdAt
          updatedAt
        }
      }
    }
  ''';
}