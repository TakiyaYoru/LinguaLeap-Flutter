// lib/graphql/lesson_exercise_queries.dart
class LessonExerciseQueries {
  // ===============================================
  // LESSON QUERIES
  // ===============================================

  // Get lessons for a specific unit
  static const String getUnitLessons = '''
    query GetUnitLessons(\$unitId: ID!) {
      unitLessons(unitId: \$unitId) {
        id
        title
        description
        unitId
        courseId
        objective
        estimatedDuration
        totalExercises
        difficulty
        xpReward
        isPremium
        isPublished
        sortOrder
        unlockRequirements {
          previousLessonId
          minimumScore
        }
        createdAt
        updatedAt
      }
    }
  ''';

  // Get single lesson by ID
  static const String getLesson = '''
    query GetLesson(\$id: ID!) {
      lesson(id: \$id) {
        id
        title
        description
        unitId
        courseId
        objective
        estimatedDuration
        totalExercises
        difficulty
        xpReward
        isPremium
        isPublished
        sortOrder
        unlockRequirements {
          previousLessonId
          minimumScore
        }
        createdAt
        updatedAt
      }
    }
  ''';

  // ===============================================
  // EXERCISE QUERIES
  // ===============================================

  // Get exercises for a specific lesson
  static const String getLessonExercises = '''
    query GetLessonExercises(\$lessonId: ID!) {
      lessonExercises(lessonId: \$lessonId) {
        id
        title
        instruction
        courseId
        unitId
        lessonId
        type
        question {
          text
          audioUrl
          imageUrl
          videoUrl
        }
        content
        maxScore
        difficulty
        xpReward
        timeLimit
        estimatedTime
        isPremium
        isActive
        sortOrder
        feedback {
          correct
          incorrect
          hint
        }
        tags
        createdAt
        updatedAt
      }
    }
  ''';

  // Get single exercise by ID
  static const String getExercise = '''
    query GetExercise(\$id: ID!) {
      exercise(id: \$id) {
        id
        title
        instruction
        courseId
        unitId
        lessonId
        type
        question {
          text
          audioUrl
          imageUrl
          videoUrl
        }
        content
        maxScore
        difficulty
        xpReward
        timeLimit
        estimatedTime
        isPremium
        isActive
        sortOrder
        feedback {
          correct
          incorrect
          hint
        }
        tags
        createdAt
        updatedAt
      }
    }
  ''';

  // ===============================================
  // PROGRESS QUERIES
  // ===============================================

  // Get user progress for lessons
  static const String getUserLessonProgress = '''
    query GetUserLessonProgress(\$userId: ID!, \$courseId: ID!) {
      userProgress(userId: \$userId, courseId: \$courseId) {
        lessonProgress {
          lessonId
          isCompleted
          isUnlocked
          currentScore
          bestScore
          attemptsCount
          timeSpent
          lastAttemptAt
          completedAt
        }
        exerciseProgress {
          exerciseId
          lessonId
          isCompleted
          score
          attempts
          timeSpent
          lastAttemptAt
          completedAt
        }
      }
    }
  ''';

  // ===============================================
  // CONTENT CREATION MUTATIONS (For Admin)
  // ===============================================

  // Create lesson (Admin only)
  static const String createLesson = '''
    mutation CreateLesson(\$input: CreateLessonInput!) {
      createLesson(input: \$input) {
        id
        title
        description
        unitId
        courseId
        objective
        estimatedDuration
        difficulty
        xpReward
        isPremium
        isPublished
        sortOrder
      }
    }
  ''';

  // Create exercise (Admin only) 
  static const String createExercise = '''
    mutation CreateExercise(\$input: CreateExerciseInput!) {
      createExercise(input: \$input) {
        id
        title
        instruction
        courseId
        unitId
        lessonId
        type
        question {
          text
          audioUrl
          imageUrl
          videoUrl
        }
        content
        maxScore
        difficulty
        xpReward
        timeLimit
        estimatedTime
        isPremium
        isActive
        sortOrder
        feedback {
          correct
          incorrect
          hint
        }
        tags
      }
    }
  ''';

  // ===============================================
  // BULK DATA CREATION FOR TESTING
  // ===============================================

  // Generate sample lessons for a unit
  static const String generateSampleLessons = '''
    mutation GenerateSampleLessons(\$unitId: ID!, \$count: Int) {
      generateSampleLessons(unitId: \$unitId, count: \$count) {
        success
        message
        createdLessons {
          id
          title
          totalExercises
        }
      }
    }
  ''';

  // Generate sample exercises for a lesson
  static const String generateSampleExercises = '''
    mutation GenerateSampleExercises(\$lessonId: ID!, \$types: [String!]) {
      generateSampleExercises(lessonId: \$lessonId, types: \$types) {
        success
        message
        createdExercises {
          id
          title
          type
        }
      }
    }
  ''';

  // ===============================================
  // AI GENERATION QUERIES
  // ===============================================

  // Get AI-generated exercises for a specific lesson
  static const String getLessonExercisesWithAI = '''
    query GetLessonExercisesWithAI(\$lessonId: ID!) {
      lessonExercisesWithAI(lessonId: \$lessonId) {
        id
        title
        instruction
        courseId
        unitId
        lessonId
        type
        question {
          text
          audioUrl
          imageUrl
          videoUrl
        }
        content
        maxScore
        difficulty
        xpReward
        timeLimit
        estimatedTime
        isPremium
        isActive
        sortOrder
        feedback {
          correct
          incorrect
          hint
        }
        tags
        createdAt
        updatedAt
      }
    }
  ''';

  // Generate single exercise content
  static const String generateExercise = '''
    mutation GenerateExercise(\$input: ExerciseGenerationInput!) {
      generateExercise(input: \$input) {
        success
        message
        content
        type
        difficulty
      }
    }
  ''';

  // Generate exercises for a lesson
  static const String generateLessonExercises = '''
    mutation GenerateLessonExercises(\$input: LessonExerciseGenerationInput!) {
      generateLessonExercises(input: \$input) {
        success
        message
        exercises {
          id
          title
          type
          content
          xpReward
        }
      }
    }
  ''';
}