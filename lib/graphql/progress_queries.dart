// lib/core/graphql/progress_queries.dart

class ProgressQueries {
  // Lesson Progress Queries
  static const String startLesson = '''
    mutation StartLesson(\$lessonId: ID!, \$unitId: ID!, \$courseId: ID!) {
      startLesson(lessonId: \$lessonId, unitId: \$unitId, courseId: \$courseId) {
        id
        userId
        lessonId
        courseId
        unitId
        status
        completion_data {
          score
          time_taken
          exercises_completed
          exercises_correct
          vocabulary_encountered
          perfect_score
        }
        xp_earned
        hearts_used
        completed_at
        attempts
        best_score
        unlock_next_lesson
      }
    }
  ''';

  static const String completeLesson = '''
    mutation CompleteLesson(\$input: CompleteLessonInput!) {
      completeLesson(input: \$input) {
        id
        userId
        lessonId
        courseId
        unitId
        status
        completion_data {
          score
          time_taken
          exercises_completed
          exercises_correct
          vocabulary_encountered
          perfect_score
        }
        xp_earned
        hearts_used
        completed_at
        attempts
        best_score
        unlock_next_lesson
      }
    }
  ''';

  static const String updateLessonProgress = '''
    mutation UpdateLessonProgress(\$lessonId: ID!, \$progress: LessonProgressInput!) {
      updateLessonProgress(lessonId: \$lessonId, progress: \$progress) {
        id
        userId
        lessonId
        courseId
        unitId
        status
        completion_data {
          score
          time_taken
          exercises_completed
          exercises_correct
          vocabulary_encountered
          perfect_score
        }
        xp_earned
        hearts_used
        completed_at
        attempts
        best_score
        unlock_next_lesson
      }
    }
  ''';

  static const String getUnitProgress = '''
    query GetUnitProgress(\$unitId: ID!) {
      unitProgress(unitId: \$unitId) {
        id
        userId
        lessonId
        courseId
        unitId
        status
        completion_data {
          score
          time_taken
          exercises_completed
          exercises_correct
          vocabulary_encountered
          perfect_score
        }
        xp_earned
        hearts_used
        completed_at
        attempts
        best_score
        unlock_next_lesson
      }
    }
  ''';

  static const String getCourseProgress = '''
    query GetCourseProgress(\$courseId: ID!) {
      courseProgress(courseId: \$courseId) {
        id
        userId
        lessonId
        courseId
        unitId
        status
        completion_data {
          score
          time_taken
          exercises_completed
          exercises_correct
          vocabulary_encountered
          perfect_score
        }
        xp_earned
        hearts_used
        completed_at
        attempts
        best_score
        unlock_next_lesson
      }
    }
  ''';

  static const String getCompletedLessons = '''
    query GetCompletedLessons {
      completedLessons {
        id
        userId
        lessonId
        courseId
        unitId
        status
        completion_data {
          score
          time_taken
          exercises_completed
          exercises_correct
          vocabulary_encountered
          perfect_score
        }
        xp_earned
        hearts_used
        completed_at
        attempts
        best_score
        unlock_next_lesson
      }
    }
  ''';

  // Exercise Progress Queries
  static const String saveExerciseProgress = '''
    mutation SaveExerciseProgress(\$input: ExerciseProgressInput!) {
      saveExerciseProgress(input: \$input) {
        success
        message
        exerciseProgress {
          id
          exerciseId
          lessonId
          userId
          userAnswer
          isCorrect
          score
          timeSpent
          completedAt
        }
      }
    }
  ''';

  static const String saveLessonProgress = '''
    mutation SaveLessonProgress(\$input: LessonProgressInput!) {
      saveLessonProgress(input: \$input) {
        success
        message
        passed
        totalScore
        maxScore
        percentage
        xpEarned
        heartsRemaining
        unlockedLessons {
          id
          title
          description
        }
        lessonProgress {
          id
          lessonId
          courseId
          userId
          status
          totalScore
          maxScore
          timeSpent
          heartsRemaining
          isCompleted
          completedAt
          attempts
          bestScore
        }
      }
    }
  ''';

  static const String getUserProgress = '''
    query GetUserProgress(\$courseId: ID!) {
      userProgress(courseId: \$courseId) {
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
        totalXP
        totalLessonsCompleted
        totalExercisesCompleted
        currentStreak
        longestStreak
      }
    }
  ''';

  static const String getLessonProgress = '''
    query GetLessonProgress(\$lessonId: ID!) {
      lessonProgress(lessonId: \$lessonId) {
        id
        lessonId
        courseId
        userId
        status
        totalScore
        maxScore
        timeSpent
        heartsRemaining
        isCompleted
        completedAt
        attempts
        bestScore
        exerciseResults {
          exerciseId
          userAnswer
          isCorrect
          score
          timeSpent
        }
      }
    }
  ''';

  // Exercise Bank Queries
  static const String saveExerciseToBank = '''
    mutation SaveExerciseToBank(\$input: SaveExerciseInput!) {
      saveExerciseToBank(input: \$input) {
        id
        userId
        exerciseContent {
          type
          content
          vocabulary_focus
          lesson_context
          difficulty
          skill_focus
        }
        source_lesson_id
        source_unit_id
        source_course_id
        performance {
          user_answer
          is_correct
          score
          time_taken
          attempts
        }
        completed_at
        last_reviewed
        next_review_date
        review_count
        mastery_level
      }
    }
  ''';

  static const String getMyExerciseBank = '''
    query GetMyExerciseBank(\$filters: ExerciseBankFilters) {
      myExerciseBank(filters: \$filters) {
        id
        userId
        exerciseContent {
          type
          content
          vocabulary_focus
          lesson_context
          difficulty
          skill_focus
        }
        source_lesson_id
        source_unit_id
        source_course_id
        performance {
          user_answer
          is_correct
          score
          time_taken
          attempts
        }
        completed_at
        last_reviewed
        next_review_date
        review_count
        mastery_level
      }
    }
  ''';

  static const String getExercisesForReview = '''
    query GetExercisesForReview(\$limit: Int) {
      exercisesForReview(limit: \$limit) {
        id
        userId
        exerciseContent {
          type
          content
          vocabulary_focus
          lesson_context
          difficulty
          skill_focus
        }
        source_lesson_id
        source_unit_id
        source_course_id
        performance {
          user_answer
          is_correct
          score
          time_taken
          attempts
        }
        completed_at
        last_reviewed
        next_review_date
        review_count
        mastery_level
      }
    }
  ''';

  static const String updateExercisePerformance = '''
    mutation UpdateExercisePerformance(\$id: ID!, \$performance: PerformanceInput!) {
      updateExercisePerformance(id: \$id, performance: \$performance) {
        id
        userId
        exerciseContent {
          type
          content
          vocabulary_focus
          lesson_context
          difficulty
          skill_focus
        }
        source_lesson_id
        source_unit_id
        source_course_id
        performance {
          user_answer
          is_correct
          score
          time_taken
          attempts
        }
        completed_at
        last_reviewed
        next_review_date
        review_count
        mastery_level
      }
    }
  ''';

  static const String recordExerciseReview = '''
    mutation RecordExerciseReview(\$id: ID!, \$isCorrect: Boolean!) {
      recordExerciseReview(id: \$id, isCorrect: \$isCorrect) {
        id
        userId
        exerciseContent {
          type
          content
          vocabulary_focus
          lesson_context
          difficulty
          skill_focus
        }
        source_lesson_id
        source_unit_id
        source_course_id
        performance {
          user_answer
          is_correct
          score
          time_taken
          attempts
        }
        completed_at
        last_reviewed
        next_review_date
        review_count
        mastery_level
      }
    }
  ''';
} 