// lib/models/unit_model.dart

class UnitModel {
  final String id;
  final String title;
  final String description;
  final String courseId;
  final String theme;
  final String? icon;
  final String color;
  final int totalLessons;
  final int totalExercises;
  final int estimatedDuration;
  final UnitPrerequisites? prerequisites;
  final ChallengeTest? challengeTest;
  final bool isPremium;
  final bool isPublished;
  final int xpReward;
  final int sortOrder;
  final double progressPercentage;
  final bool isUnlocked;
  final List<VocabularyItem> vocabulary;
  final String createdAt;

  UnitModel({
    required this.id,
    required this.title,
    required this.description,
    required this.courseId,
    required this.theme,
    this.icon,
    required this.color,
    required this.totalLessons,
    required this.totalExercises,
    required this.estimatedDuration,
    this.prerequisites,
    this.challengeTest,
    required this.isPremium,
    required this.isPublished,
    required this.xpReward,
    required this.sortOrder,
    required this.progressPercentage,
    required this.isUnlocked,
    required this.vocabulary,
    required this.createdAt,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      courseId: json['courseId'] ?? '',
      theme: json['theme'] ?? 'general',
      icon: json['icon'],
      color: json['color'] ?? '#4A90E2',
      totalLessons: json['totalLessons'] ?? 0,
      totalExercises: json['totalExercises'] ?? 0,
      estimatedDuration: json['estimatedDuration'] ?? 0,
      prerequisites: json['prerequisites'] != null 
        ? UnitPrerequisites.fromJson(json['prerequisites'])
        : null,
      challengeTest: json['challenge_test'] != null 
        ? ChallengeTest.fromJson(json['challenge_test'])
        : null,
      isPremium: json['isPremium'] ?? false,
      isPublished: json['isPublished'] ?? false,
      xpReward: json['xpReward'] ?? 0,
      sortOrder: json['sortOrder'] ?? 0,
      progressPercentage: (json['progressPercentage'] ?? 0).toDouble(),
      isUnlocked: json['isUnlocked'] ?? false,
      vocabulary: (json['vocabulary'] as List?)
          ?.map((v) => VocabularyItem.fromJson(v))
          .toList() ?? [],
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'courseId': courseId,
      'theme': theme,
      'icon': icon,
      'color': color,
      'totalLessons': totalLessons,
      'totalExercises': totalExercises,
      'estimatedDuration': estimatedDuration,
      'prerequisites': prerequisites?.toJson(),
      'challenge_test': challengeTest?.toJson(),
      'isPremium': isPremium,
      'isPublished': isPublished,
      'xpReward': xpReward,
      'sortOrder': sortOrder,
      'progressPercentage': progressPercentage,
      'isUnlocked': isUnlocked,
      'vocabulary': vocabulary.map((v) => v.toJson()).toList(),
      'createdAt': createdAt,
    };
  }
}

class UnitPrerequisites {
  final String? previousUnitId;
  final int minimumScore;
  final int requiredHearts;

  UnitPrerequisites({
    this.previousUnitId,
    required this.minimumScore,
    required this.requiredHearts,
  });

  factory UnitPrerequisites.fromJson(Map<String, dynamic> json) {
    return UnitPrerequisites(
      previousUnitId: json['previous_unit_id'],
      minimumScore: json['minimum_score'] ?? 80,
      requiredHearts: json['required_hearts'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'previous_unit_id': previousUnitId,
      'minimum_score': minimumScore,
      'required_hearts': requiredHearts,
    };
  }
}

class ChallengeTest {
  final int totalQuestions;
  final int passPercentage;
  final List<int> mustCorrectQuestions;
  final int timeLimit;

  ChallengeTest({
    required this.totalQuestions,
    required this.passPercentage,
    required this.mustCorrectQuestions,
    required this.timeLimit,
  });

  factory ChallengeTest.fromJson(Map<String, dynamic> json) {
    return ChallengeTest(
      totalQuestions: json['total_questions'] ?? 10,
      passPercentage: json['pass_percentage'] ?? 80,
      mustCorrectQuestions: List<int>.from(json['must_correct_questions'] ?? []),
      timeLimit: json['time_limit'] ?? 30,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_questions': totalQuestions,
      'pass_percentage': passPercentage,
      'must_correct_questions': mustCorrectQuestions,
      'time_limit': timeLimit,
    };
  }
}

class VocabularyItem {
  final String word;
  final String meaning;
  final String? pronunciation;
  final String? audioUrl;
  final VocabularyExample? example;

  VocabularyItem({
    required this.word,
    required this.meaning,
    this.pronunciation,
    this.audioUrl,
    this.example,
  });

  factory VocabularyItem.fromJson(Map<String, dynamic> json) {
    return VocabularyItem(
      word: json['word'] ?? '',
      meaning: json['meaning'] ?? '',
      pronunciation: json['pronunciation'],
      audioUrl: json['audioUrl'],
      example: json['example'] != null 
        ? VocabularyExample.fromJson(json['example'])
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'meaning': meaning,
      'pronunciation': pronunciation,
      'audioUrl': audioUrl,
      'example': example?.toJson(),
    };
  }
}

class VocabularyExample {
  final String sentence;
  final String translation;

  VocabularyExample({
    required this.sentence,
    required this.translation,
  });

  factory VocabularyExample.fromJson(Map<String, dynamic> json) {
    return VocabularyExample(
      sentence: json['sentence'] ?? '',
      translation: json['translation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sentence': sentence,
      'translation': translation,
    };
  }
} 