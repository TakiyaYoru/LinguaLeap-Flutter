// lib/models/lesson_model.dart
class LessonModel {
  final String id;
  final String title;
  final String? description;
  final String unitId;
  final String courseId;
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
  final int xpReward;
  final int perfectScoreBonus;
  final int targetAccuracy;
  final int passThreshold;
  final int sortOrder;
  final String status;
  final bool isCompleted;
  final bool isUnlocked;
  final int? userScore;
  final UnlockRequirements? unlockRequirements;
  final String createdAt;
  final String updatedAt;

  LessonModel({
    required this.id,
    required this.title,
    this.description,
    required this.unitId,
    required this.courseId,
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
    required this.xpReward,
    required this.perfectScoreBonus,
    required this.targetAccuracy,
    required this.passThreshold,
    required this.sortOrder,
    required this.status,
    required this.isCompleted,
    required this.isUnlocked,
    this.userScore,
    this.unlockRequirements,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      unitId: json['unitId'] ?? '',
      courseId: json['courseId'] ?? '',
      type: json['type'] ?? '',
      lessonType: json['lesson_type'] ?? '',
      objective: json['objective'],
      vocabularyPool: (json['vocabulary_pool'] as List<dynamic>?)
          ?.map((e) => VocabularyPoolItem.fromJson(e))
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
      xpReward: json['xpReward'] ?? 0,
      perfectScoreBonus: json['perfectScoreBonus'] ?? 0,
      targetAccuracy: json['targetAccuracy'] ?? 80,
      passThreshold: json['passThreshold'] ?? 70,
      sortOrder: json['sortOrder'] ?? 0,
      status: json['status'] ?? 'available',
      isCompleted: json['isCompleted'] ?? false,
      isUnlocked: json['isUnlocked'] ?? false,
      userScore: json['userScore'],
      unlockRequirements: json['unlockRequirements'] != null
          ? UnlockRequirements.fromJson(json['unlockRequirements'])
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
      'unitId': unitId,
      'courseId': courseId,
      'type': type,
      'lesson_type': lessonType,
      'objective': objective,
      'vocabulary_pool': vocabularyPool.map((e) => e.toJson()).toList(),
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
      'xpReward': xpReward,
      'perfectScoreBonus': perfectScoreBonus,
      'targetAccuracy': targetAccuracy,
      'passThreshold': passThreshold,
      'sortOrder': sortOrder,
      'status': status,
      'isCompleted': isCompleted,
      'isUnlocked': isUnlocked,
      'userScore': userScore,
      'unlockRequirements': unlockRequirements?.toJson(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class VocabularyPoolItem {
  final VocabularyWord? vocabularyId;
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
      vocabularyId: json['vocabulary_id'] != null
          ? VocabularyWord.fromJson(json['vocabulary_id'])
          : null,
      contextInLesson: json['context_in_lesson'] ?? '',
      isMainFocus: json['is_main_focus'] ?? false,
      introductionOrder: json['introduction_order'] ?? 0,
      difficultyWeight: json['difficulty_weight'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vocabulary_id': vocabularyId?.toJson(),
      'context_in_lesson': contextInLesson,
      'is_main_focus': isMainFocus,
      'introduction_order': introductionOrder,
      'difficulty_weight': difficultyWeight,
    };
  }
}

class VocabularyWord {
  final String id;
  final String word;
  final String meaning;
  final String? pronunciation;
  final String? example;
  final String difficulty;
  final int frequencyScore;
  final String? audioUrl;
  final String? imageUrl;
  final String category;
  final List<String> tags;

  VocabularyWord({
    required this.id,
    required this.word,
    required this.meaning,
    this.pronunciation,
    this.example,
    required this.difficulty,
    required this.frequencyScore,
    this.audioUrl,
    this.imageUrl,
    required this.category,
    required this.tags,
  });

  factory VocabularyWord.fromJson(Map<String, dynamic> json) {
    return VocabularyWord(
      id: json['id'] ?? '',
      word: json['word'] ?? '',
      meaning: json['meaning'] ?? '',
      pronunciation: json['pronunciation'],
      example: json['example'],
      difficulty: json['difficulty'] ?? 'beginner',
      frequencyScore: json['frequency_score'] ?? 0,
      audioUrl: json['audioUrl'],
      imageUrl: json['imageUrl'],
      category: json['category'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'meaning': meaning,
      'pronunciation': pronunciation,
      'example': example,
      'difficulty': difficulty,
      'frequency_score': frequencyScore,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'category': category,
      'tags': tags,
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
      exerciseDistribution: ExerciseDistribution.fromJson(json['exercise_distribution'] ?? {}),
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

class UnlockRequirements {
  final String? previousLessonId;
  final int? minimumScore;

  UnlockRequirements({
    this.previousLessonId,
    this.minimumScore,
  });

  factory UnlockRequirements.fromJson(Map<String, dynamic> json) {
    return UnlockRequirements(
      previousLessonId: json['previousLessonId'],
      minimumScore: json['minimumScore'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'previousLessonId': previousLessonId,
      'minimumScore': minimumScore,
    };
  }
}

// ===============================================
// lib/models/exercise_model.dart
// ===============================================

class ExerciseModel {
  final String id;
  final String? title;
  final String instruction;
  final String courseId;
  final String unitId;
  final String lessonId;
  final String type;
  final String typeDisplayName;
  final ExerciseQuestion question;
  final String content;
  final int maxScore;
  final String difficulty;
  final int xpReward;
  final int? timeLimit;
  final int estimatedTime;
  final bool requiresAudio;
  final bool requiresMicrophone;
  final bool isPremium;
  final bool isActive;
  final int sortOrder;
  final int successRate;
  final ExerciseFeedback? feedback;
  final List<String> tags;
  final String createdAt;
  final String updatedAt;

  ExerciseModel({
    required this.id,
    this.title,
    required this.instruction,
    required this.courseId,
    required this.unitId,
    required this.lessonId,
    required this.type,
    required this.typeDisplayName,
    required this.question,
    required this.content,
    required this.maxScore,
    required this.difficulty,
    required this.xpReward,
    this.timeLimit,
    required this.estimatedTime,
    required this.requiresAudio,
    required this.requiresMicrophone,
    required this.isPremium,
    required this.isActive,
    required this.sortOrder,
    required this.successRate,
    this.feedback,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] ?? '',
      title: json['title'],
      instruction: json['instruction'] ?? '',
      courseId: json['courseId'] ?? '',
      unitId: json['unitId'] ?? '',
      lessonId: json['lessonId'] ?? '',
      type: json['type'] ?? '',
      typeDisplayName: json['type_display_name'] ?? '',
      question: ExerciseQuestion.fromJson(json['question'] ?? {}),
      content: json['content'] ?? '',
      maxScore: json['maxScore'] ?? 100,
      difficulty: json['difficulty'] ?? 'beginner',
      xpReward: json['xpReward'] ?? 10,
      timeLimit: json['timeLimit'],
      estimatedTime: json['estimatedTime'] ?? 60,
      requiresAudio: json['requires_audio'] ?? false,
      requiresMicrophone: json['requires_microphone'] ?? false,
      isPremium: json['isPremium'] ?? false,
      isActive: json['isActive'] ?? true,
      sortOrder: json['sortOrder'] ?? 0,
      successRate: json['successRate'] ?? 0,
      feedback: json['feedback'] != null 
          ? ExerciseFeedback.fromJson(json['feedback']) 
          : null,
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'instruction': instruction,
      'courseId': courseId,
      'unitId': unitId,
      'lessonId': lessonId,
      'type': type,
      'type_display_name': typeDisplayName,
      'question': question.toJson(),
      'content': content,
      'maxScore': maxScore,
      'difficulty': difficulty,
      'xpReward': xpReward,
      'timeLimit': timeLimit,
      'estimatedTime': estimatedTime,
      'requires_audio': requiresAudio,
      'requires_microphone': requiresMicrophone,
      'isPremium': isPremium,
      'isActive': isActive,
      'sortOrder': sortOrder,
      'successRate': successRate,
      'feedback': feedback?.toJson(),
      'tags': tags,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

// Exercise Types Enum
enum ExerciseType {
  multipleChoice('multiple_choice'),
  fillBlank('fill_blank'),
  listening('listening'),
  translation('translation'),
  speaking('speaking'),
  reading('reading'),
  wordMatching('word_matching'),
  sentenceBuilding('sentence_building'),
  trueFalse('true_false'),
  dragDrop('drag_drop');

  const ExerciseType(this.name);
  final String name;

  static ExerciseType fromString(String value) {
    return ExerciseType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => ExerciseType.multipleChoice,
    );
  }

  String get displayName {
    switch (this) {
      case ExerciseType.multipleChoice:
        return 'Multiple Choice';
      case ExerciseType.fillBlank:
        return 'Fill in the Blank';
      case ExerciseType.listening:
        return 'Listening';
      case ExerciseType.translation:
        return 'Translation';
      case ExerciseType.speaking:
        return 'Speaking';
      case ExerciseType.reading:
        return 'Reading';
      case ExerciseType.wordMatching:
        return 'Word Matching';
      case ExerciseType.sentenceBuilding:
        return 'Sentence Building';
      case ExerciseType.trueFalse:
        return 'True or False';
      case ExerciseType.dragDrop:
        return 'Drag & Drop';
    }
  }
}

// Exercise Question Model
class ExerciseQuestion {
  final String text;
  final String? audioUrl;
  final String? imageUrl;
  final String? videoUrl;

  ExerciseQuestion({
    required this.text,
    this.audioUrl,
    this.imageUrl,
    this.videoUrl,
  });

  factory ExerciseQuestion.fromJson(Map<String, dynamic> json) {
    return ExerciseQuestion(
      text: json['text'] ?? '',
      audioUrl: json['audioUrl'],
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
    };
  }
}

// Exercise Feedback Model
class ExerciseFeedback {
  final String correct;
  final String incorrect;
  final String? hint;

  ExerciseFeedback({
    required this.correct,
    required this.incorrect,
    this.hint,
  });

  factory ExerciseFeedback.fromJson(Map<String, dynamic> json) {
    return ExerciseFeedback(
      correct: json['correct'] ?? 'Correct! Well done!',
      incorrect: json['incorrect'] ?? 'Not quite right. Try again!',
      hint: json['hint'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'correct': correct,
      'incorrect': incorrect,
      'hint': hint,
    };
  }
}