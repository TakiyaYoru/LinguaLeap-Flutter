// lib/core/models/progress_model.dart

class LessonProgressModel {
  final String id;
  final String userId;
  final String lessonId;
  final String courseId;
  final String unitId;
  final String status;
  final CompletionData completionData;
  final int xpEarned;
  final int heartsUsed;
  final String? completedAt;
  final int attempts;
  final int bestScore;
  final bool unlockNextLesson;

  LessonProgressModel({
    required this.id,
    required this.userId,
    required this.lessonId,
    required this.courseId,
    required this.unitId,
    required this.status,
    required this.completionData,
    required this.xpEarned,
    required this.heartsUsed,
    this.completedAt,
    required this.attempts,
    required this.bestScore,
    required this.unlockNextLesson,
  });

  factory LessonProgressModel.fromJson(Map<String, dynamic> json) {
    return LessonProgressModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      lessonId: json['lessonId'] ?? '',
      courseId: json['courseId'] ?? '',
      unitId: json['unitId'] ?? '',
      status: json['status'] ?? 'NOT_STARTED',
      completionData: CompletionData.fromJson(json['completion_data'] ?? {}),
      xpEarned: json['xp_earned'] ?? 0,
      heartsUsed: json['hearts_used'] ?? 0,
      completedAt: json['completed_at'],
      attempts: json['attempts'] ?? 0,
      bestScore: json['best_score'] ?? 0,
      unlockNextLesson: json['unlock_next_lesson'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'lessonId': lessonId,
      'courseId': courseId,
      'unitId': unitId,
      'status': status,
      'completion_data': completionData.toJson(),
      'xp_earned': xpEarned,
      'hearts_used': heartsUsed,
      'completed_at': completedAt,
      'attempts': attempts,
      'best_score': bestScore,
      'unlock_next_lesson': unlockNextLesson,
    };
  }
}

class CompletionData {
  final int score;
  final int timeTaken;
  final int exercisesCompleted;
  final int exercisesCorrect;
  final List<String> vocabularyEncountered;
  final bool perfectScore;

  CompletionData({
    required this.score,
    required this.timeTaken,
    required this.exercisesCompleted,
    required this.exercisesCorrect,
    required this.vocabularyEncountered,
    required this.perfectScore,
  });

  factory CompletionData.fromJson(Map<String, dynamic> json) {
    return CompletionData(
      score: json['score'] ?? 0,
      timeTaken: json['time_taken'] ?? 0,
      exercisesCompleted: json['exercises_completed'] ?? 0,
      exercisesCorrect: json['exercises_correct'] ?? 0,
      vocabularyEncountered: List<String>.from(json['vocabulary_encountered'] ?? []),
      perfectScore: json['perfect_score'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'time_taken': timeTaken,
      'exercises_completed': exercisesCompleted,
      'exercises_correct': exercisesCorrect,
      'vocabulary_encountered': vocabularyEncountered,
      'perfect_score': perfectScore,
    };
  }
}

class ExerciseBankModel {
  final String id;
  final String userId;
  final ExerciseContent exerciseContent;
  final String sourceLessonId;
  final String sourceUnitId;
  final String sourceCourseId;
  final ExercisePerformance? performance;
  final String? completedAt;
  final String? lastReviewed;
  final String? nextReviewDate;
  final int reviewCount;
  final String masteryLevel;

  ExerciseBankModel({
    required this.id,
    required this.userId,
    required this.exerciseContent,
    required this.sourceLessonId,
    required this.sourceUnitId,
    required this.sourceCourseId,
    this.performance,
    this.completedAt,
    this.lastReviewed,
    this.nextReviewDate,
    required this.reviewCount,
    required this.masteryLevel,
  });

  factory ExerciseBankModel.fromJson(Map<String, dynamic> json) {
    return ExerciseBankModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      exerciseContent: ExerciseContent.fromJson(json['exerciseContent'] ?? {}),
      sourceLessonId: json['source_lesson_id'] ?? '',
      sourceUnitId: json['source_unit_id'] ?? '',
      sourceCourseId: json['source_course_id'] ?? '',
      performance: json['performance'] != null 
          ? ExercisePerformance.fromJson(json['performance']) 
          : null,
      completedAt: json['completed_at'],
      lastReviewed: json['last_reviewed'],
      nextReviewDate: json['next_review_date'],
      reviewCount: json['review_count'] ?? 0,
      masteryLevel: json['mastery_level'] ?? 'NEW',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'exerciseContent': exerciseContent.toJson(),
      'source_lesson_id': sourceLessonId,
      'source_unit_id': sourceUnitId,
      'source_course_id': sourceCourseId,
      'performance': performance?.toJson(),
      'completed_at': completedAt,
      'last_reviewed': lastReviewed,
      'next_review_date': nextReviewDate,
      'review_count': reviewCount,
      'mastery_level': masteryLevel,
    };
  }
}

class ExerciseContent {
  final String type;
  final Map<String, dynamic> content;
  final List<String> vocabularyFocus;
  final String lessonContext;
  final String difficulty;
  final List<String> skillFocus;

  ExerciseContent({
    required this.type,
    required this.content,
    required this.vocabularyFocus,
    required this.lessonContext,
    required this.difficulty,
    required this.skillFocus,
  });

  factory ExerciseContent.fromJson(Map<String, dynamic> json) {
    return ExerciseContent(
      type: json['type'] ?? '',
      content: json['content'] ?? {},
      vocabularyFocus: List<String>.from(json['vocabulary_focus'] ?? []),
      lessonContext: json['lesson_context'] ?? '',
      difficulty: json['difficulty'] ?? 'beginner',
      skillFocus: List<String>.from(json['skill_focus'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'content': content,
      'vocabulary_focus': vocabularyFocus,
      'lesson_context': lessonContext,
      'difficulty': difficulty,
      'skill_focus': skillFocus,
    };
  }
}

class ExercisePerformance {
  final Map<String, dynamic> userAnswer;
  final bool isCorrect;
  final int score;
  final int timeTaken;
  final int attempts;

  ExercisePerformance({
    required this.userAnswer,
    required this.isCorrect,
    required this.score,
    required this.timeTaken,
    required this.attempts,
  });

  factory ExercisePerformance.fromJson(Map<String, dynamic> json) {
    return ExercisePerformance(
      userAnswer: json['user_answer'] ?? {},
      isCorrect: json['is_correct'] ?? false,
      score: json['score'] ?? 0,
      timeTaken: json['time_taken'] ?? 0,
      attempts: json['attempts'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_answer': userAnswer,
      'is_correct': isCorrect,
      'score': score,
      'time_taken': timeTaken,
      'attempts': attempts,
    };
  }
} 