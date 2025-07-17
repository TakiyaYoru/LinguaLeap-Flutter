// lib/graphql/course_queries.dart

class CourseQueries {
  // Get all courses
  static const String getAllCourses = '''
    query GetAllCourses {
      courses {
        id
        title
        description
        level
        category
        skill_focus
        thumbnail
        color
        estimatedDuration
        totalUnits
        totalLessons
        totalExercises
        prerequisites {
          id
          title
        }
        challenge_test {
          total_questions
          pass_percentage
          must_correct_questions
          time_limit
        }
        isPremium
        isPublished
        publishedAt
        learningObjectives
        difficulty
        totalXP
        enrollmentCount
        completionCount
        averageRating
        completionRate
        slug
        createdBy {
          id
          username
          displayName
        }
        createdAt
        updatedAt
      }
    }
  ''';

  // Get single course by ID
  static const String getCourse = '''
    query GetCourse(\$id: ID!) {
      course(id: \$id) {
        id
        title
        description
        level
        category
        skill_focus
        thumbnail
        color
        estimatedDuration
        totalUnits
        totalLessons
        totalExercises
        prerequisites {
          id
          title
        }
        challenge_test {
          total_questions
          pass_percentage
          must_correct_questions
          time_limit
        }
        isPremium
        isPublished
        publishedAt
        learningObjectives
        difficulty
        totalXP
        enrollmentCount
        completionCount
        averageRating
        completionRate
        slug
        createdBy {
          id
          username
          displayName
        }
        createdAt
        updatedAt
      }
    }
  ''';

  // Get course units
  static const String getCourseUnits = '''
    query GetCourseUnits(\$courseId: ID!) {
      courseUnits(courseId: \$courseId) {
        id
        title
        description
        theme
        icon
        color
        totalLessons
        totalExercises
        estimatedDuration
        isPremium
        isPublished
        xpReward
        sortOrder
        progressPercentage
        isUnlocked
        createdAt
      }
    }
  ''';

  // Get unit lessons
  static const String getUnitLessons = '''
    query GetUnitLessons(\$unitId: ID!) {
      unitLessons(unitId: \$unitId) {
        id
        title
        description
        courseId
        unitId
        type
        lesson_type
        objective
        vocabulary_pool {
          vocabulary_id {
            id
            word
            meaning
            pronunciation
            example
            difficulty
            frequency_score
            audioUrl
            imageUrl
            category
            tags
          }
          context_in_lesson
          is_main_focus
          introduction_order
          difficulty_weight
        }
        lesson_context {
          situation
          cultural_context
          use_cases
          avoid_topics
        }
        grammar_point {
          title
          explanation
          pattern
          examples
        }
        exercise_generation {
          total_exercises
          exercise_distribution {
            multiple_choice
            fill_blank
            listening
            translation
            word_matching
            listen_choose
            speak_repeat
          }
          difficulty_progression
          vocabulary_coverage
        }
        icon
        thumbnail
        totalExercises
        estimatedDuration
        difficulty
        isPremium
        isPublished
        xpReward
        perfectScoreBonus
        targetAccuracy
        passThreshold
        sortOrder
        status
        isCompleted
        isUnlocked
        userScore
        createdAt
      }
    }
  ''';
}