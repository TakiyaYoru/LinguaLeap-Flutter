// lib/graphql/exercise_queries.dart

class ExerciseQueries {
  // ===============================================
  // AI GENERATION QUERIES
  // ===============================================

  // Generate single exercise with AI
  static const String generateExercise = '''
    query GenerateExercise(\$type: String!, \$context: String!) {
      generateExercise(type: \$type, context: \$context) {
        type
        content
        vocabulary {
          word
          meaning
          pronunciation
        }
        sortOrder
        audioUrl
      }
    }
  ''';
  // ===============================================
  // ADMIN QUERIES
  // ===============================================

  // Get all exercises for admin
  static const String getAllExercises = '''
    query GetAllExercises {
      adminExercises {
        id
        title
        instruction
        type_display_name
        courseId
        unitId
        lessonId
        type
        skill_focus
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
        requires_audio
        requires_microphone
        isPremium
        isActive
        sortOrder
        successRate
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

  // Get exercises by lesson ID
  static const String getExercisesByLesson = '''
    query GetExercisesByLesson(\$lessonId: ID!) {
      lessonExercises(lessonId: \$lessonId) {
        id
        title
        instruction
        type_display_name
        courseId
        unitId
        lessonId
        type
        skill_focus
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
        requires_audio
        requires_microphone
        isPremium
        isActive
        sortOrder
        successRate
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
        type_display_name
        courseId
        unitId
        lessonId
        type
        prompt_template {
          system_context
          main_prompt
          variables
          expected_output_format
          fallback_template
        }
        generation_rules {
          max_attempts
          validation_rules
          difficulty_adaptation
          content_filters
        }
        skill_focus
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
        requires_audio
        requires_microphone
        isPremium
        isActive
        sortOrder
        successRate
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
  // ADMIN MUTATIONS
  // ===============================================

  // Create exercise
  static const String createExercise = '''
    mutation CreateExercise(\$input: CreateExerciseInput!) {
      createExercise(input: \$input) {
        id
        title
        instruction
        type_display_name
        courseId
        unitId
        lessonId
        type
        skill_focus
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
        requires_audio
        requires_microphone
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

  // Update exercise
  static const String updateExercise = '''
    mutation UpdateExercise(\$id: ID!, \$input: UpdateExerciseInput!) {
      updateExercise(id: \$id, input: \$input) {
        id
        title
        instruction
        type_display_name
        courseId
        unitId
        lessonId
        type
        skill_focus
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
        requires_audio
        requires_microphone
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

  // Delete exercise
  static const String deleteExercise = '''
    mutation DeleteExercise(\$id: ID!) {
      deleteExercise(id: \$id)
    }
  ''';

  // Publish exercise
  static const String publishExercise = '''
    mutation PublishExercise(\$id: ID!) {
      publishExercise(id: \$id) {
        id
        isActive
        updatedAt
      }
    }
  ''';

  // Unpublish exercise
  static const String unpublishExercise = '''
    mutation UnpublishExercise(\$id: ID!) {
      unpublishExercise(id: \$id) {
        id
        isActive
        updatedAt
      }
    }
  ''';

  // ===============================================
  // USER QUERIES
  // ===============================================

  // Get exercises for lesson (user view)
  static const String getLessonExercises = '''
    query GetLessonExercises(\$lessonId: ID!) {
      lessonExercises(lessonId: \$lessonId) {
        id
        title
        instruction
        type_display_name
        type
        skill_focus
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
        requires_audio
        requires_microphone
        isPremium
        sortOrder
        feedback {
          correct
          incorrect
          hint
        }
      }
    }
  ''';

  // Get single exercise for user
  static const String getUserExercise = '''
    query GetUserExercise(\$id: ID!) {
      exercise(id: \$id) {
        id
        title
        instruction
        type_display_name
        type
        skill_focus
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
        requires_audio
        requires_microphone
        isPremium
        feedback {
          correct
          incorrect
          hint
        }
      }
    }
  ''';

  // ===============================================
  // PROGRESS MUTATIONS
  // ===============================================

  // Submit exercise answer
  static const String submitExerciseAnswer = '''
    mutation SubmitExerciseAnswer(\$exerciseId: ID!, \$answer: String!, \$timeSpent: Int!) {
      submitExerciseAnswer(exerciseId: \$exerciseId, answer: \$answer, timeSpent: \$timeSpent) {
        id
        isCorrect
        score
        feedback
        correctAnswer
        explanation
      }
    }
  ''';

  // Update exercise progress
  static const String updateExerciseProgress = '''
    mutation UpdateExerciseProgress(\$exerciseId: ID!, \$progress: ExerciseProgressInput!) {
      updateExerciseProgress(exerciseId: \$exerciseId, progress: \$progress) {
        id
        status
        score
        attempts
        completedAt
      }
    }
  ''';
} 

class ExerciseQueries {
  // ===============================================
  // AI GENERATION QUERIES
  // ===============================================

  // Generate single exercise with AI
  static const String generateExercise = '''
    query GenerateExercise(\$type: String!, \$context: String!) {
      generateExercise(type: \$type, context: \$context) {
        type
        content
        vocabulary {
          word
          meaning
          pronunciation
        }
        sortOrder
        audioUrl
      }
    }
  ''';
  // ===============================================
  // ADMIN QUERIES
  // ===============================================

  // Get all exercises for admin
  static const String getAllExercises = '''
    query GetAllExercises {
      adminExercises {
        id
        title
        instruction
        type_display_name
        courseId
        unitId
        lessonId
        type
        skill_focus
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
        requires_audio
        requires_microphone
        isPremium
        isActive
        sortOrder
        successRate
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

  // Get exercises by lesson ID
  static const String getExercisesByLesson = '''
    query GetExercisesByLesson(\$lessonId: ID!) {
      lessonExercises(lessonId: \$lessonId) {
        id
        title
        instruction
        type_display_name
        courseId
        unitId
        lessonId
        type
        skill_focus
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
        requires_audio
        requires_microphone
        isPremium
        isActive
        sortOrder
        successRate
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
        type_display_name
        courseId
        unitId
        lessonId
        type
        prompt_template {
          system_context
          main_prompt
          variables
          expected_output_format
          fallback_template
        }
        generation_rules {
          max_attempts
          validation_rules
          difficulty_adaptation
          content_filters
        }
        skill_focus
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
        requires_audio
        requires_microphone
        isPremium
        isActive
        sortOrder
        successRate
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
  // ADMIN MUTATIONS
  // ===============================================

  // Create exercise
  static const String createExercise = '''
    mutation CreateExercise(\$input: CreateExerciseInput!) {
      createExercise(input: \$input) {
        id
        title
        instruction
        type_display_name
        courseId
        unitId
        lessonId
        type
        skill_focus
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
        requires_audio
        requires_microphone
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

  // Update exercise
  static const String updateExercise = '''
    mutation UpdateExercise(\$id: ID!, \$input: UpdateExerciseInput!) {
      updateExercise(id: \$id, input: \$input) {
        id
        title
        instruction
        type_display_name
        courseId
        unitId
        lessonId
        type
        skill_focus
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
        requires_audio
        requires_microphone
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

  // Delete exercise
  static const String deleteExercise = '''
    mutation DeleteExercise(\$id: ID!) {
      deleteExercise(id: \$id)
    }
  ''';

  // Publish exercise
  static const String publishExercise = '''
    mutation PublishExercise(\$id: ID!) {
      publishExercise(id: \$id) {
        id
        isActive
        updatedAt
      }
    }
  ''';

  // Unpublish exercise
  static const String unpublishExercise = '''
    mutation UnpublishExercise(\$id: ID!) {
      unpublishExercise(id: \$id) {
        id
        isActive
        updatedAt
      }
    }
  ''';

  // ===============================================
  // USER QUERIES
  // ===============================================

  // Get exercises for lesson (user view)
  static const String getLessonExercises = '''
    query GetLessonExercises(\$lessonId: ID!) {
      lessonExercises(lessonId: \$lessonId) {
        id
        title
        instruction
        type_display_name
        type
        skill_focus
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
        requires_audio
        requires_microphone
        isPremium
        sortOrder
        feedback {
          correct
          incorrect
          hint
        }
      }
    }
  ''';

  // Get single exercise for user
  static const String getUserExercise = '''
    query GetUserExercise(\$id: ID!) {
      exercise(id: \$id) {
        id
        title
        instruction
        type_display_name
        type
        skill_focus
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
        requires_audio
        requires_microphone
        isPremium
        feedback {
          correct
          incorrect
          hint
        }
      }
    }
  ''';

  // ===============================================
  // PROGRESS MUTATIONS
  // ===============================================

  // Submit exercise answer
  static const String submitExerciseAnswer = '''
    mutation SubmitExerciseAnswer(\$exerciseId: ID!, \$answer: String!, \$timeSpent: Int!) {
      submitExerciseAnswer(exerciseId: \$exerciseId, answer: \$answer, timeSpent: \$timeSpent) {
        id
        isCorrect
        score
        feedback
        correctAnswer
        explanation
      }
    }
  ''';

  // Update exercise progress
  static const String updateExerciseProgress = '''
    mutation UpdateExerciseProgress(\$exerciseId: ID!, \$progress: ExerciseProgressInput!) {
      updateExerciseProgress(exerciseId: \$exerciseId, progress: \$progress) {
        id
        status
        score
        attempts
        completedAt
      }
    }
  ''';
} 