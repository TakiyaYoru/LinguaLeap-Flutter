// lib/models/lesson_model.dart
class LessonModel {
  final String id;
  final String title;
  final String? description;
  final String courseId;
  final String unitId;
  final String type;
  final String lessonType;
  final String? objective;
  final List<VocabularyPoolItem> vocabularyPool;
  final LessonContext? lessonContext;
  final GrammarPoint? grammarPoint;
  final ExerciseGeneration? exerciseGeneration;
  final String? icon;
  final String? thumbnail;
  final int totalExercises;
  final int estimatedDuration;
  final String difficulty;
  final bool isPremium;
  final bool isPublished;
  final String? publishedAt;
  final int xpReward;
  final int perfectScoreBonus;
  final int targetAccuracy;
  final int passThreshold;
  final int sortOrder;
  final String status;
  final bool isCompleted;
  final bool isUnlocked;
  final int? userScore;
  final User? createdBy;
  final String createdAt;
  final String updatedAt;

  LessonModel({
    required this.id,
    required this.title,
    this.description,
    required this.courseId,
    required this.unitId,
    required this.type,
    required this.lessonType,
    this.objective,
    required this.vocabularyPool,
    this.lessonContext,
    this.grammarPoint,
    this.exerciseGeneration,
    this.icon,
    this.thumbnail,
    required this.totalExercises,
    required this.estimatedDuration,
    required this.difficulty,
    required this.isPremium,
    required this.isPublished,
    this.publishedAt,
    required this.xpReward,
    required this.perfectScoreBonus,
    required this.targetAccuracy,
    required this.passThreshold,
    required this.sortOrder,
    required this.status,
    required this.isCompleted,
    required this.isUnlocked,
    this.userScore,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      courseId: json['courseId'] ?? '',
      unitId: json['unitId'] ?? '',
      type: json['type'] ?? '',
      lessonType: json['lesson_type'] ?? 'vocabulary',
      objective: json['objective'],
      vocabularyPool: (json['vocabulary_pool'] as List<dynamic>?)
          ?.map((item) => VocabularyPoolItem.fromJson(item))
          .toList() ?? [],
      lessonContext: json['lesson_context'] != null
          ? LessonContext.fromJson(json['lesson_context'])
          : null,
      grammarPoint: json['grammar_point'] != null
          ? GrammarPoint.fromJson(json['grammar_point'])
          : null,
      exerciseGeneration: json['exercise_generation'] != null
          ? ExerciseGeneration.fromJson(json['exercise_generation'])
          : null,
      icon: json['icon'],
      thumbnail: json['thumbnail'],
      totalExercises: json['totalExercises'] ?? 0,
      estimatedDuration: json['estimatedDuration'] ?? 0,
      difficulty: json['difficulty'] ?? 'beginner',
      isPremium: json['isPremium'] ?? false,
      isPublished: json['isPublished'] ?? false,
      publishedAt: json['publishedAt'],
      xpReward: json['xpReward'] ?? 0,
      perfectScoreBonus: json['perfectScoreBonus'] ?? 0,
      targetAccuracy: json['targetAccuracy'] ?? 80,
      passThreshold: json['passThreshold'] ?? 70,
      sortOrder: json['sortOrder'] ?? 0,
      status: json['status'] ?? 'locked',
      isCompleted: json['isCompleted'] ?? false,
      isUnlocked: json['isUnlocked'] ?? false,
      userScore: json['userScore'],
      createdBy: json['createdBy'] != null
          ? User.fromJson(json['createdBy'])
          : null,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'courseId': courseId,
      'unitId': unitId,
      'type': type,
      'lesson_type': lessonType,
      'objective': objective,
      'vocabulary_pool': vocabularyPool.map((item) => item.toJson()).toList(),
      'lesson_context': lessonContext?.toJson(),
      'grammar_point': grammarPoint?.toJson(),
      'exercise_generation': exerciseGeneration?.toJson(),
      'icon': icon,
      'thumbnail': thumbnail,
      'totalExercises': totalExercises,
      'estimatedDuration': estimatedDuration,
      'difficulty': difficulty,
      'isPremium': isPremium,
      'isPublished': isPublished,
      'publishedAt': publishedAt,
      'xpReward': xpReward,
      'perfectScoreBonus': perfectScoreBonus,
      'targetAccuracy': targetAccuracy,
      'passThreshold': passThreshold,
      'sortOrder': sortOrder,
      'status': status,
      'isCompleted': isCompleted,
      'isUnlocked': isUnlocked,
      'userScore': userScore,
      'createdBy': createdBy?.toJson(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Helper methods
  String get typeDisplay {
    switch (type.toLowerCase()) {
      case 'vocabulary': return 'Từ vựng';
      case 'grammar': return 'Ngữ pháp';
      case 'listening': return 'Nghe hiểu';
      case 'speaking': return 'Nói';
      case 'reading': return 'Đọc hiểu';
      case 'writing': return 'Viết';
      case 'conversation': return 'Hội thoại';
      case 'review': return 'Ôn tập';
      case 'test': return 'Kiểm tra';
      default: return type;
    }
  }

  String get difficultyDisplay {
    switch (difficulty.toLowerCase()) {
      case 'easy': return 'Dễ';
      case 'medium': return 'Trung bình';
      case 'hard': return 'Khó';
      default: return difficulty;
    }
  }

  LessonModel copyWith({
    String? id,
    String? title,
    String? description,
    String? courseId,
    String? unitId,
    String? type,
    String? lessonType,
    String? objective,
    List<VocabularyPoolItem>? vocabularyPool,
    LessonContext? lessonContext,
    GrammarPoint? grammarPoint,
    ExerciseGeneration? exerciseGeneration,
    String? icon,
    String? thumbnail,
    int? totalExercises,
    int? estimatedDuration,
    String? difficulty,
    bool? isPremium,
    bool? isPublished,
    String? publishedAt,
    int? xpReward,
    int? perfectScoreBonus,
    int? targetAccuracy,
    int? passThreshold,
    int? sortOrder,
    String? status,
    bool? isCompleted,
    bool? isUnlocked,
    int? userScore,
    User? createdBy,
    String? createdAt,
    String? updatedAt,
  }) {
    return LessonModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      courseId: courseId ?? this.courseId,
      unitId: unitId ?? this.unitId,
      type: type ?? this.type,
      lessonType: lessonType ?? this.lessonType,
      objective: objective ?? this.objective,
      vocabularyPool: vocabularyPool ?? this.vocabularyPool,
      lessonContext: lessonContext ?? this.lessonContext,
      grammarPoint: grammarPoint ?? this.grammarPoint,
      exerciseGeneration: exerciseGeneration ?? this.exerciseGeneration,
      icon: icon ?? this.icon,
      thumbnail: thumbnail ?? this.thumbnail,
      totalExercises: totalExercises ?? this.totalExercises,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      difficulty: difficulty ?? this.difficulty,
      isPremium: isPremium ?? this.isPremium,
      isPublished: isPublished ?? this.isPublished,
      publishedAt: publishedAt ?? this.publishedAt,
      xpReward: xpReward ?? this.xpReward,
      perfectScoreBonus: perfectScoreBonus ?? this.perfectScoreBonus,
      targetAccuracy: targetAccuracy ?? this.targetAccuracy,
      passThreshold: passThreshold ?? this.passThreshold,
      sortOrder: sortOrder ?? this.sortOrder,
      status: status ?? this.status,
      isCompleted: isCompleted ?? this.isCompleted,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      userScore: userScore ?? this.userScore,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class VocabularyPoolItem {
  final String? vocabularyId;
  final String contextInLesson;
  final bool isMainFocus;
  final int introductionOrder;
  final int difficultyWeight;

  VocabularyPoolItem({
    this.vocabularyId,
    required this.contextInLesson,
    required this.isMainFocus,
    required this.introductionOrder,
    required this.difficultyWeight,
  });

  factory VocabularyPoolItem.fromJson(Map<String, dynamic> json) {
    return VocabularyPoolItem(
      vocabularyId: json['vocabulary_id'],
      contextInLesson: json['context_in_lesson'] ?? '',
      isMainFocus: json['is_main_focus'] ?? true,
      introductionOrder: json['introduction_order'] ?? 1,
      difficultyWeight: json['difficulty_weight'] ?? 3,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vocabulary_id': vocabularyId,
      'context_in_lesson': contextInLesson,
      'is_main_focus': isMainFocus,
      'introduction_order': introductionOrder,
      'difficulty_weight': difficultyWeight,
    };
  }
}

class LessonContext {
  final String? situation;
  final String? culturalContext;
  final List<String> useCases;
  final List<String> avoidTopics;

  LessonContext({
    this.situation,
    this.culturalContext,
    required this.useCases,
    required this.avoidTopics,
  });

  factory LessonContext.fromJson(Map<String, dynamic> json) {
    return LessonContext(
      situation: json['situation'],
      culturalContext: json['cultural_context'],
      useCases: List<String>.from(json['use_cases'] ?? []),
      avoidTopics: List<String>.from(json['avoid_topics'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'situation': situation,
      'cultural_context': culturalContext,
      'use_cases': useCases,
      'avoid_topics': avoidTopics,
    };
  }
}

class GrammarPoint {
  final String? title;
  final String? explanation;
  final String? pattern;
  final List<String> examples;

  GrammarPoint({
    this.title,
    this.explanation,
    this.pattern,
    required this.examples,
  });

  factory GrammarPoint.fromJson(Map<String, dynamic> json) {
    return GrammarPoint(
      title: json['title'],
      explanation: json['explanation'],
      pattern: json['pattern'],
      examples: List<String>.from(json['examples'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'explanation': explanation,
      'pattern': pattern,
      'examples': examples,
    };
  }
}

class ExerciseGeneration {
  final int totalExercises;
  final ExerciseDistribution exerciseDistribution;
  final bool difficultyProgression;
  final String vocabularyCoverage;

  ExerciseGeneration({
    required this.totalExercises,
    required this.exerciseDistribution,
    required this.difficultyProgression,
    required this.vocabularyCoverage,
  });

  factory ExerciseGeneration.fromJson(Map<String, dynamic> json) {
    return ExerciseGeneration(
      totalExercises: json['total_exercises'] ?? 0,
      exerciseDistribution: ExerciseDistribution.fromJson(
          json['exercise_distribution'] ?? {}),
      difficultyProgression: json['difficulty_progression'] ?? false,
      vocabularyCoverage: json['vocabulary_coverage'] ?? 'all',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_exercises': totalExercises,
      'exercise_distribution': exerciseDistribution.toJson(),
      'difficulty_progression': difficultyProgression,
      'vocabulary_coverage': vocabularyCoverage,
    };
  }
}

class ExerciseDistribution {
  final int multipleChoice;
  final int fillBlank;
  final int listening;
  final int translation;
  final int wordMatching;
  final int listenChoose;
  final int speakRepeat;

  ExerciseDistribution({
    required this.multipleChoice,
    required this.fillBlank,
    required this.listening,
    required this.translation,
    required this.wordMatching,
    required this.listenChoose,
    required this.speakRepeat,
  });

  factory ExerciseDistribution.fromJson(Map<String, dynamic> json) {
    return ExerciseDistribution(
      multipleChoice: json['multiple_choice'] ?? 0,
      fillBlank: json['fill_blank'] ?? 0,
      listening: json['listening'] ?? 0,
      translation: json['translation'] ?? 0,
      wordMatching: json['word_matching'] ?? 0,
      listenChoose: json['listen_choose'] ?? 0,
      speakRepeat: json['speak_repeat'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'multiple_choice': multipleChoice,
      'fill_blank': fillBlank,
      'listening': listening,
      'translation': translation,
      'word_matching': wordMatching,
      'listen_choose': listenChoose,
      'speak_repeat': speakRepeat,
    };
  }
}

class User {
  final String id;
  final String username;
  final String displayName;

  User({
    required this.id,
    required this.username,
    required this.displayName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      displayName: json['displayName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
    };
  }
}