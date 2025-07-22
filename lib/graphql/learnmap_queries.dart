import 'package:graphql_flutter/graphql_flutter.dart';

// Query để lấy learnmap progress của user
const String getUserLearnmapProgressQuery = '''
  query GetUserLearnmapProgress(\$courseId: ID!) {
    userLearnmapProgress(courseId: \$courseId) {
      _id
      userId
      courseId
      hearts
      lastHeartUpdate
      unitProgress {
        unitId
        status
        completedAt
        lessonProgress {
          lessonId
          status
          completedAt
          exerciseProgress {
            exerciseId
            status
            score
            attempts
            lastAttemptedAt
            wrongAnswers
          }
          reviewHistory {
            score
            xpEarned
            coinEarned
            reviewedAt
          }
        }
      }
      fastTrackHistory {
        unitId
        lessonIds
        challengeAttemptId
        completedAt
      }
    }
  }
''';

// Mutation để khởi tạo learnmap progress
const String startCourseLearnmapMutation = '''
  mutation StartCourseLearnmap(\$courseId: ID!) {
    startCourseLearnmap(courseId: \$courseId) {
      success
      message
      userLearnmapProgress {
        _id
        userId
        courseId
        hearts
        lastHeartUpdate
        unitProgress {
          unitId
          status
          completedAt
          lessonProgress {
            lessonId
            status
            completedAt
            exerciseProgress {
              exerciseId
              status
              score
              attempts
              lastAttemptedAt
              wrongAnswers
            }
          }
        }
        fastTrackHistory {
          unitId
          lessonIds
          challengeAttemptId
          completedAt
        }
      }
    }
  }
''';

// Mutation để cập nhật learnmap progress
const String updateLearnmapProgressMutation = '''
  mutation UpdateLearnmapProgress(\$courseId: ID!, \$progressInput: ProgressInput!) {
    updateLearnmapProgress(courseId: \$courseId, progressInput: \$progressInput) {
      success
      message
      userLearnmapProgress {
        _id
        userId
        courseId
        hearts
        lastHeartUpdate
        unitProgress {
          unitId
          status
          completedAt
          lessonProgress {
            lessonId
            status
            completedAt
            exerciseProgress {
              exerciseId
              status
              score
              attempts
              lastAttemptedAt
              wrongAnswers
            }
          }
        }
        fastTrackHistory {
          unitId
          lessonIds
          challengeAttemptId
          completedAt
        }
      }
    }
  }
''';

// Query để lấy exercises của lesson
const String getExercisesByLessonQuery = '''
  query GetExercisesByLesson(\$lessonId: ID!) {
    getExercisesByLesson(lessonId: \$lessonId) {
      success
      message
      exercises {
        _id
        title
        instruction
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
        feedback {
          correct
          incorrect
          hint
        }
        timeLimit
        estimatedTime
        xpReward
        sortOrder
      }
    }
  }
''';

// Mutation để cập nhật exercise progress
const String updateExerciseProgressMutation = '''
  mutation UpdateExerciseProgress(\$lessonId: ID!, \$exerciseProgressInput: ExerciseProgressInput!) {
    updateExerciseProgress(lessonId: \$lessonId, exerciseProgressInput: \$exerciseProgressInput) {
      success
      message
      exerciseProgress {
        exerciseId
        status
        score
        attempts
        lastAttemptedAt
        wrongAnswers
      }
    }
  }
'''; 