// lib/models/vocabulary_model.dart
class VocabularyWord {
  final String id;
  final String userId;
  final String word;
  final String meaning;
  final String? pronunciation;
  final String? example;
  final String difficulty;
  final int frequencyScore;
  final List<VocabularyDefinition> definitions;
  final bool isLearned;
  final String? learnedAt;
  final String category;
  final List<String> tags;
  final int reviewCount;
  final int correctAnswers;
  final int totalAttempts;
  final String? lastReviewed;
  final String? nextReviewDate;
  final String source;
  final String? sourceReference;
  final String? lessonId;
  final String? unitId;
  final String? courseId;
  final String? audioUrl;
  final String? imageUrl;
  final bool isActive;
  final int? daysSinceCreated;
  final int? daysSinceLearned;
  final int? successRate;
  final bool? isDueForReview;
  final String createdAt;

  VocabularyWord({
    required this.id,
    required this.userId,
    required this.word,
    required this.meaning,
    this.pronunciation,
    this.example,
    required this.difficulty,
    required this.frequencyScore,
    required this.definitions,
    required this.isLearned,
    this.learnedAt,
    required this.category,
    required this.tags,
    required this.reviewCount,
    required this.correctAnswers,
    required this.totalAttempts,
    this.lastReviewed,
    this.nextReviewDate,
    required this.source,
    this.sourceReference,
    this.lessonId,
    this.unitId,
    this.courseId,
    this.audioUrl,
    this.imageUrl,
    required this.isActive,
    this.daysSinceCreated,
    this.daysSinceLearned,
    this.successRate,
    this.isDueForReview,
    required this.createdAt,
  });

  // Create from API JSON response
  factory VocabularyWord.fromJson(Map<String, dynamic> json) {
    return VocabularyWord(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      word: json['word'] ?? '',
      meaning: json['meaning'] ?? '',
      pronunciation: json['pronunciation'],
      example: json['example'],
      difficulty: json['difficulty'] ?? 'beginner',
      frequencyScore: json['frequency_score'] ?? 0,
      definitions: (json['definitions'] as List<dynamic>?)
          ?.map((e) => VocabularyDefinition.fromJson(e))
          .toList() ?? [],
      isLearned: json['isLearned'] ?? false,
      learnedAt: json['learnedAt'],
      category: json['category'] ?? 'general',
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      reviewCount: json['reviewCount'] ?? 0,
      correctAnswers: json['correctAnswers'] ?? 0,
      totalAttempts: json['totalAttempts'] ?? 0,
      lastReviewed: json['lastReviewed'],
      nextReviewDate: json['nextReviewDate'],
      source: json['source'] ?? 'manual',
      sourceReference: json['sourceReference'],
      lessonId: json['lessonId'],
      unitId: json['unitId'],
      courseId: json['courseId'],
      audioUrl: json['audioUrl'],
      imageUrl: json['imageUrl'],
      isActive: json['isActive'] ?? true,
      daysSinceCreated: json['daysSinceCreated'],
      daysSinceLearned: json['daysSinceLearned'],
      successRate: json['successRate'],
      isDueForReview: json['isDueForReview'],
      createdAt: json['createdAt'] ?? '',
    );
  }

  @override
  String toString() {
    return 'VocabularyWord(word: $word, meaning: $meaning, isLearned: $isLearned)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VocabularyWord && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class VocabularyDefinition {
  final String context;
  final String meaning;
  final String? example;

  VocabularyDefinition({
    required this.context,
    required this.meaning,
    this.example,
  });

  factory VocabularyDefinition.fromJson(Map<String, dynamic> json) {
    return VocabularyDefinition(
      context: json['context'] ?? '',
      meaning: json['meaning'] ?? '',
      example: json['example'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'context': context,
      'meaning': meaning,
      'example': example,
    };
  }
}

// Filter enum for vocabulary list
enum VocabularyFilter {
  all,
  unlearned,
  learned,
}

extension VocabularyFilterExtension on VocabularyFilter {
  String get displayName {
    switch (this) {
      case VocabularyFilter.all:
        return 'All Words';
      case VocabularyFilter.unlearned:
        return 'Unlearned';
      case VocabularyFilter.learned:
        return 'Learned';
    }
  }

  String get shortName {
    switch (this) {
      case VocabularyFilter.all:
        return 'All';
      case VocabularyFilter.unlearned:
        return 'New';
      case VocabularyFilter.learned:
        return 'Learned';
    }
  }
}