// lib/graphql/exercise_crud_queries.dart

class ExerciseCRUDQueries {
  // Get all exercises with pagination and filtering
  static const String getExercises = '''
    query GetExercises(\$page: Int, \$limit: Int, \$filter: ExerciseFilterInput, \$sortBy: String, \$sortOrder: String) {
      getExercises(page: \$page, limit: \$limit, filter: \$filter, sortBy: \$sortBy, sortOrder: \$sortOrder) {
        success
        message
        exercises {
          _id
          type
          exercise_subtype
          title
          instruction
          content
          maxScore
          difficulty
          xpReward
          timeLimit
          estimatedTime
          requiresAudio
          requiresMicrophone
          isActive
          isPremium
          sortOrder
          successRate
          totalAttempts
          correctAttempts
          skillFocus
          createdAt
          updatedAt
        }
        total
        page
        limit
      }
    }
  ''';

  // Get exercise by ID
  static const String getExercise = '''
    query GetExercise(\$id: ID!) {
      getExercise(id: \$id) {
        _id
        type
        exercise_subtype
        title
        instruction
        content
        maxScore
        difficulty
        xpReward
        timeLimit
        estimatedTime
        requiresAudio
        requiresMicrophone
        isActive
        isPremium
        sortOrder
        successRate
        totalAttempts
        correctAttempts
        skillFocus
        createdAt
        updatedAt
      }
    }
  ''';

  // Get exercise by subtype
  static const String getExerciseBySubtype = '''
    query GetExerciseBySubtype(\$subtype: String!) {
      getExerciseBySubtype(subtype: \$subtype) {
        _id
        type
        exercise_subtype
        title
        instruction
        content
        maxScore
        difficulty
        xpReward
        timeLimit
        estimatedTime
        requiresAudio
        requiresMicrophone
        isActive
        isPremium
        sortOrder
        successRate
        totalAttempts
        correctAttempts
        skillFocus
        createdAt
        updatedAt
      }
    }
  ''';

  // Get exercises by type
  static const String getExercisesByType = '''
    query GetExercisesByType(\$type: String!) {
      getExercisesByType(type: \$type) {
        _id
        type
        exercise_subtype
        title
        instruction
        content
        maxScore
        difficulty
        xpReward
        timeLimit
        estimatedTime
        requiresAudio
        requiresMicrophone
        isActive
        isPremium
        sortOrder
        successRate
        totalAttempts
        correctAttempts
        skillFocus
        createdAt
        updatedAt
      }
    }
  ''';

  // Get exercises by skill
  static const String getExercisesBySkill = '''
    query GetExercisesBySkill(\$skill: String!) {
      getExercisesBySkill(skill: \$skill) {
        _id
        type
        exercise_subtype
        title
        instruction
        content
        maxScore
        difficulty
        xpReward
        timeLimit
        estimatedTime
        requiresAudio
        requiresMicrophone
        isActive
        isPremium
        sortOrder
        successRate
        totalAttempts
        correctAttempts
        skillFocus
        createdAt
        updatedAt
      }
    }
  ''';

  // Get all exercise subtypes
  static const String getExerciseSubtypes = '''
    query GetExerciseSubtypes {
      getExerciseSubtypes
    }
  ''';

  // Get exercise statistics
  static const String getExerciseStats = '''
    query GetExerciseStats {
      getExerciseStats {
        success
        message
        stats {
          total
          byType {
            type
            count
          }
          byDifficulty {
            difficulty
            count
          }
          bySkill {
            skill
            count
          }
          averageSuccessRate
          totalAttempts
          totalCorrectAttempts
        }
      }
    }
  ''';

  // Get random exercise
  static const String getRandomExercise = '''
    query GetRandomExercise(\$filter: ExerciseFilterInput) {
      getRandomExercise(filter: \$filter) {
        _id
        type
        exercise_subtype
        title
        instruction
        content
        maxScore
        difficulty
        xpReward
        timeLimit
        estimatedTime
        requiresAudio
        requiresMicrophone
        isActive
        isPremium
        sortOrder
        successRate
        totalAttempts
        correctAttempts
        skillFocus
        createdAt
        updatedAt
      }
    }
  ''';

  // Get exercises for lesson
  static const String getLessonExercises = '''
    query GetLessonExercises(\$lessonId: ID!, \$count: Int!, \$skillFocus: [String!]) {
      getLessonExercises(lessonId: \$lessonId, count: \$count, skillFocus: \$skillFocus) {
        _id
        type
        exercise_subtype
        title
        instruction
        content
        maxScore
        difficulty
        xpReward
        timeLimit
        estimatedTime
        requiresAudio
        requiresMicrophone
        isActive
        isPremium
        sortOrder
        successRate
        totalAttempts
        correctAttempts
        skillFocus
        createdAt
        updatedAt
      }
    }
  ''';

  // Create exercise
  static const String createExercise = '''
    mutation CreateExercise(\$input: CreateExerciseInput!) {
      createExercise(input: \$input) {
        success
        message
        exercise {
          _id
          type
          exercise_subtype
          title
          instruction
          content
          maxScore
          difficulty
          xpReward
          timeLimit
          estimatedTime
          requiresAudio
          requiresMicrophone
          isActive
          isPremium
          sortOrder
          successRate
          totalAttempts
          correctAttempts
          skillFocus
          createdAt
          updatedAt
        }
      }
    }
  ''';

  // Update exercise
  static const String updateExercise = '''
    mutation UpdateExercise(\$id: ID!, \$input: UpdateExerciseInput!) {
      updateExercise(id: \$id, input: \$input) {
        success
        message
        exercise {
          _id
          type
          exercise_subtype
          title
          instruction
          content
          maxScore
          difficulty
          xpReward
          timeLimit
          estimatedTime
          requiresAudio
          requiresMicrophone
          isActive
          isPremium
          sortOrder
          successRate
          totalAttempts
          correctAttempts
          skillFocus
          createdAt
          updatedAt
        }
      }
    }
  ''';

  // Delete exercise
  static const String deleteExercise = '''
    mutation DeleteExercise(\$id: ID!) {
      deleteExercise(id: \$id) {
        success
        message
        exercise {
          _id
          title
        }
      }
    }
  ''';

  // Toggle exercise active status
  static const String toggleExerciseActive = '''
    mutation ToggleExerciseActive(\$id: ID!) {
      toggleExerciseActive(id: \$id) {
        success
        message
        exercise {
          _id
          title
          isActive
          updatedAt
        }
      }
    }
  ''';

  // Update exercise success rate
  static const String updateExerciseSuccessRate = '''
    mutation UpdateExerciseSuccessRate(\$id: ID!, \$isCorrect: Boolean!) {
      updateExerciseSuccessRate(id: \$id, isCorrect: \$isCorrect) {
        success
        message
        exercise {
          _id
          title
          successRate
          totalAttempts
          correctAttempts
        }
      }
    }
  ''';

  // Bulk create exercises
  static const String bulkCreateExercises = '''
    mutation BulkCreateExercises(\$template: String!, \$count: Int!, \$skillFocus: [String!]) {
      bulkCreateExercises(template: \$template, count: \$count, skillFocus: \$skillFocus) {
        success
        message
        exercises {
          _id
          title
          exercise_subtype
          skillFocus
        }
        total
      }
    }
  ''';

  // Reorder exercises
  static const String reorderExercises = '''
    mutation ReorderExercises(\$ids: [ID!]!) {
      reorderExercises(ids: \$ids) {
        success
        message
        exercises {
          _id
          title
          sortOrder
        }
        total
      }
    }
  ''';
} 