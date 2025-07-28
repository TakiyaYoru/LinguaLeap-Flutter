// lib/models/exercise_crud_model.dart
import 'dart:convert';

class ExerciseCRUDModel {
  final String id;
  final String type;
  final String exerciseSubtype;
  final String title;
  final String instruction;
  final String content; // JSON string
  final int maxScore;
  final String difficulty;
  final int xpReward;
  final int? timeLimit;
  final int estimatedTime;
  final bool requiresAudio;
  final bool requiresMicrophone;
  final bool isActive;
  final bool isPremium;
  final int sortOrder;
  final int successRate;
  final int totalAttempts;
  final int correctAttempts;
  final List<String> skillFocus;
  final String createdAt;
  final String updatedAt;

  ExerciseCRUDModel({
    required this.id,
    required this.type,
    required this.exerciseSubtype,
    required this.title,
    required this.instruction,
    required this.content,
    required this.maxScore,
    required this.difficulty,
    required this.xpReward,
    this.timeLimit,
    required this.estimatedTime,
    required this.requiresAudio,
    required this.requiresMicrophone,
    required this.isActive,
    required this.isPremium,
    required this.sortOrder,
    required this.successRate,
    required this.totalAttempts,
    required this.correctAttempts,
    required this.skillFocus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExerciseCRUDModel.fromJson(Map<String, dynamic> json) {
    return ExerciseCRUDModel(
      id: json['_id'] ?? json['id'] ?? '',
      type: json['type'] ?? '',
      exerciseSubtype: json['exercise_subtype'] ?? '',
      title: json['title'] ?? '',
      instruction: json['instruction'] ?? '',
      content: json['content'] ?? '',
      maxScore: json['maxScore'] ?? 10,
      difficulty: json['difficulty'] ?? 'beginner',
      xpReward: json['xpReward'] ?? 5,
      timeLimit: json['timeLimit'],
      estimatedTime: json['estimatedTime'] ?? 20,
      requiresAudio: json['requiresAudio'] ?? false,
      requiresMicrophone: json['requiresMicrophone'] ?? false,
      isActive: json['isActive'] ?? true,
      isPremium: json['isPremium'] ?? false,
      sortOrder: json['sortOrder'] ?? 0,
      successRate: json['successRate'] ?? 0,
      totalAttempts: json['totalAttempts'] ?? 0,
      correctAttempts: json['correctAttempts'] ?? 0,
      skillFocus: List<String>.from(json['skillFocus'] ?? []),
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'type': type,
      'exercise_subtype': exerciseSubtype,
      'title': title,
      'instruction': instruction,
      'content': content,
      'maxScore': maxScore,
      'difficulty': difficulty,
      'xpReward': xpReward,
      'timeLimit': timeLimit,
      'estimatedTime': estimatedTime,
      'requiresAudio': requiresAudio,
      'requiresMicrophone': requiresMicrophone,
      'isActive': isActive,
      'isPremium': isPremium,
      'sortOrder': sortOrder,
      'successRate': successRate,
      'totalAttempts': totalAttempts,
      'correctAttempts': correctAttempts,
      'skillFocus': skillFocus,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Helper methods
  String get displayTitle => title.isNotEmpty ? title : typeDisplay;
  
  String get difficultyDisplay {
    switch (difficulty.toLowerCase()) {
      case 'beginner': return 'Dễ';
      case 'intermediate': return 'Trung bình';
      case 'advanced': return 'Khó';
      default: return difficulty;
    }
  }

  String get typeDisplay {
    // Use exercise_subtype for more specific display names
    switch (exerciseSubtype.toLowerCase()) {
      // Multiple Choice subtypes
      case 'vocabulary_multiple_choice': return 'Chọn từ vựng';
      case 'grammar_multiple_choice': return 'Chọn ngữ pháp';
      case 'listening_multiple_choice': return 'Nghe và chọn';
      case 'pronunciation_multiple_choice': return 'Chọn phát âm';
      
      // Fill Blank subtypes
      case 'vocabulary_fill_blank': return 'Điền từ vựng';
      case 'grammar_fill_blank': return 'Điền ngữ pháp';
      case 'listening_fill_blank': return 'Nghe và điền';
      case 'writing_fill_blank': return 'Viết và điền';
      
      // Translation subtypes
      case 'vocabulary_translation': return 'Dịch từ vựng';
      case 'grammar_translation': return 'Dịch ngữ pháp';
      case 'writing_translation': return 'Dịch câu';
      
      // Word Matching subtypes
      case 'vocabulary_word_matching': return 'Ghép từ vựng';
      
      // Listening subtypes
      case 'vocabulary_listening': return 'Nghe từ vựng';
      case 'grammar_listening': return 'Nghe ngữ pháp';
      case 'pronunciation_listening': return 'Nghe phát âm';
      
      // Speaking subtypes
      case 'vocabulary_speaking': return 'Nói từ vựng';
      case 'grammar_speaking': return 'Nói ngữ pháp';
      case 'pronunciation_speaking': return 'Phát âm';
      
      // Reading subtypes
      case 'vocabulary_reading': return 'Đọc từ vựng';
      case 'grammar_reading': return 'Đọc ngữ pháp';
      case 'comprehension_reading': return 'Đọc hiểu';
      
      // Writing subtypes
      case 'vocabulary_writing': return 'Viết từ vựng';
      case 'grammar_writing': return 'Viết ngữ pháp';
      case 'sentence_writing': return 'Viết câu';
      
      // True/False subtypes
      case 'vocabulary_true_false': return 'Đúng/Sai từ vựng';
      case 'grammar_true_false': return 'Đúng/Sai ngữ pháp';
      case 'listening_true_false': return 'Đúng/Sai nghe hiểu';
      
      // Drag & Drop subtypes
      case 'vocabulary_drag_drop': return 'Kéo thả từ vựng';
      case 'grammar_drag_drop': return 'Kéo thả ngữ pháp';
      case 'writing_drag_drop': return 'Kéo thả viết';
      
      // Fallback to original type display
      default:
        switch (type.toLowerCase()) {
          case 'multiple_choice': return 'Chọn đáp án';
          case 'fill_blank': return 'Điền từ';
          case 'listening': return 'Nghe hiểu';
          case 'translation': return 'Dịch';
          case 'speaking': return 'Phát âm';
          case 'reading': return 'Đọc hiểu';
          case 'word_matching': return 'Ghép từ';
          case 'true_false': return 'Đúng/Sai';
          case 'drag_drop': return 'Kéo thả';
          default: return type;
        }
    }
  }

  bool get hasTimeLimit => timeLimit != null && timeLimit! > 0;
  
  // Helper methods for exercise subtypes
  bool get isVocabularyExercise => exerciseSubtype.contains('vocabulary');
  bool get isGrammarExercise => exerciseSubtype.contains('grammar');
  bool get isListeningExercise => exerciseSubtype.contains('listening');
  bool get isSpeakingExercise => exerciseSubtype.contains('speaking');
  bool get isReadingExercise => exerciseSubtype.contains('reading');
  bool get isWritingExercise => exerciseSubtype.contains('writing');
  bool get isPronunciationExercise => exerciseSubtype.contains('pronunciation');
  
  // Exercise type helpers
  bool get isMultipleChoice => exerciseSubtype.contains('multiple_choice');
  bool get isFillBlank => exerciseSubtype.contains('fill_blank');
  bool get isTranslation => exerciseSubtype.contains('translation');
  bool get isWordMatching => exerciseSubtype.contains('word_matching');
  bool get isTrueFalse => exerciseSubtype.contains('true_false');
  bool get isDragDrop => exerciseSubtype.contains('drag_drop');
  
  // Get primary skill focus
  String get primarySkillFocus {
    if (isVocabularyExercise) return 'vocabulary';
    if (isGrammarExercise) return 'grammar';
    if (isListeningExercise) return 'listening';
    if (isSpeakingExercise) return 'speaking';
    if (isReadingExercise) return 'reading';
    if (isWritingExercise) return 'writing';
    if (isPronunciationExercise) return 'pronunciation';
    return 'general';
  }
  
  String get timeLimitDisplay {
    if (!hasTimeLimit) return 'Không giới hạn';
    final minutes = timeLimit! ~/ 60;
    final seconds = timeLimit! % 60;
    if (minutes > 0) {
      return seconds > 0 ? '${minutes}p ${seconds}s' : '${minutes}p';
    }
    return '${seconds}s';
  }

  // Parse content JSON
  Map<String, dynamic> get parsedContent {
    try {
      return jsonDecode(content);
    } catch (e) {
      print('⚠️ Error parsing content JSON: $e');
      return {};
    }
  }

  // Get content based on exercise type
  String? get question {
    final content = parsedContent;
    return content['question'] ?? content['text'] ?? content['prompt'];
  }

  List<String>? get options {
    final content = parsedContent;
    final options = content['options'];
    if (options is List) {
      return options.map((e) => e.toString()).toList();
    }
    return null;
  }

  String? get correctAnswer {
    final content = parsedContent;
    return content['correctAnswer']?.toString();
  }

  String? get sentence {
    final content = parsedContent;
    return content['sentence'];
  }

  Map<String, String>? get pairs {
    final content = parsedContent;
    final pairs = content['pairs'];
    if (pairs is Map) {
      return pairs.map((key, value) => MapEntry(key.toString(), value.toString()));
    }
    return null;
  }

  String? get audioText {
    final content = parsedContent;
    return content['audioText'] ?? content['audio_text'];
  }

  String? get textToSpeak {
    final content = parsedContent;
    return content['textToSpeak'];
  }

  String? get text {
    final content = parsedContent;
    return content['text'];
  }

  String? get prompt {
    final content = parsedContent;
    return content['prompt'];
  }

  String? get statement {
    final content = parsedContent;
    return content['statement'];
  }

  bool? get isCorrect {
    final content = parsedContent;
    return content['isCorrect'] ?? content['is_correct'];
  }

  List<String>? get items {
    final content = parsedContent;
    final items = content['items'];
    if (items is List) {
      return items.map((e) => e.toString()).toList();
    }
    return null;
  }

  List<Map<String, dynamic>>? get targets {
    final content = parsedContent;
    final targets = content['targets'];
    if (targets is List) {
      return targets.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return null;
  }

  Map<String, dynamic>? get feedback {
    final content = parsedContent;
    return content['feedback'];
  }

  String? get correctFeedback => feedback?['correct'];
  String? get incorrectFeedback => feedback?['incorrect'];
  String? get hint => feedback?['hint'];
}

// Response models for CRUD operations
class ExerciseCRUDPayload {
  final bool success;
  final String message;
  final ExerciseCRUDModel? exercise;

  ExerciseCRUDPayload({
    required this.success,
    required this.message,
    this.exercise,
  });

  factory ExerciseCRUDPayload.fromJson(Map<String, dynamic> json) {
    return ExerciseCRUDPayload(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      exercise: json['exercise'] != null 
          ? ExerciseCRUDModel.fromJson(json['exercise']) 
          : null,
    );
  }
}

class ExerciseListPayload {
  final bool success;
  final String message;
  final List<ExerciseCRUDModel> exercises;
  final int total;
  final int page;
  final int limit;

  ExerciseListPayload({
    required this.success,
    required this.message,
    required this.exercises,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory ExerciseListPayload.fromJson(Map<String, dynamic> json) {
    return ExerciseListPayload(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      exercises: (json['exercises'] as List?)
          ?.map((e) => ExerciseCRUDModel.fromJson(e))
          .toList() ?? [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
    );
  }
}

class ExerciseStatsPayload {
  final bool success;
  final String message;
  final ExerciseStats stats;

  ExerciseStatsPayload({
    required this.success,
    required this.message,
    required this.stats,
  });

  factory ExerciseStatsPayload.fromJson(Map<String, dynamic> json) {
    return ExerciseStatsPayload(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      stats: ExerciseStats.fromJson(json['stats']),
    );
  }
}

class ExerciseStats {
  final int total;
  final List<TypeCount> byType;
  final List<DifficultyCount> byDifficulty;
  final List<SkillCount> bySkill;
  final double averageSuccessRate;
  final int totalAttempts;
  final int totalCorrectAttempts;

  ExerciseStats({
    required this.total,
    required this.byType,
    required this.byDifficulty,
    required this.bySkill,
    required this.averageSuccessRate,
    required this.totalAttempts,
    required this.totalCorrectAttempts,
  });

  factory ExerciseStats.fromJson(Map<String, dynamic> json) {
    return ExerciseStats(
      total: json['total'] ?? 0,
      byType: (json['byType'] as List?)
          ?.map((e) => TypeCount.fromJson(e))
          .toList() ?? [],
      byDifficulty: (json['byDifficulty'] as List?)
          ?.map((e) => DifficultyCount.fromJson(e))
          .toList() ?? [],
      bySkill: (json['bySkill'] as List?)
          ?.map((e) => SkillCount.fromJson(e))
          .toList() ?? [],
      averageSuccessRate: (json['averageSuccessRate'] ?? 0).toDouble(),
      totalAttempts: json['totalAttempts'] ?? 0,
      totalCorrectAttempts: json['totalCorrectAttempts'] ?? 0,
    );
  }
}

class TypeCount {
  final String type;
  final int count;

  TypeCount({
    required this.type,
    required this.count,
  });

  factory TypeCount.fromJson(Map<String, dynamic> json) {
    return TypeCount(
      type: json['type'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class DifficultyCount {
  final String difficulty;
  final int count;

  DifficultyCount({
    required this.difficulty,
    required this.count,
  });

  factory DifficultyCount.fromJson(Map<String, dynamic> json) {
    return DifficultyCount(
      difficulty: json['difficulty'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class SkillCount {
  final String skill;
  final int count;

  SkillCount({
    required this.skill,
    required this.count,
  });

  factory SkillCount.fromJson(Map<String, dynamic> json) {
    return SkillCount(
      skill: json['skill'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

// Input models for mutations
class CreateExerciseInput {
  final String type;
  final String exerciseSubtype;
  final String title;
  final String instruction;
  final String content;
  final int maxScore;
  final String difficulty;
  final int xpReward;
  final int? timeLimit;
  final int estimatedTime;
  final bool requiresAudio;
  final bool requiresMicrophone;
  final bool? isPremium;
  final int? sortOrder;
  final List<String> skillFocus;

  CreateExerciseInput({
    required this.type,
    required this.exerciseSubtype,
    required this.title,
    required this.instruction,
    required this.content,
    required this.maxScore,
    required this.difficulty,
    required this.xpReward,
    this.timeLimit,
    required this.estimatedTime,
    required this.requiresAudio,
    required this.requiresMicrophone,
    this.isPremium,
    this.sortOrder,
    required this.skillFocus,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'exercise_subtype': exerciseSubtype,
      'title': title,
      'instruction': instruction,
      'content': content,
      'maxScore': maxScore,
      'difficulty': difficulty,
      'xpReward': xpReward,
      'timeLimit': timeLimit,
      'estimatedTime': estimatedTime,
      'requiresAudio': requiresAudio,
      'requiresMicrophone': requiresMicrophone,
      'isPremium': isPremium,
      'sortOrder': sortOrder,
      'skillFocus': skillFocus,
    };
  }
}

class UpdateExerciseInput {
  final String? type;
  final String? exerciseSubtype;
  final String? title;
  final String? instruction;
  final String? content;
  final int? maxScore;
  final String? difficulty;
  final int? xpReward;
  final int? timeLimit;
  final int? estimatedTime;
  final bool? requiresAudio;
  final bool? requiresMicrophone;
  final bool? isActive;
  final bool? isPremium;
  final int? sortOrder;
  final List<String>? skillFocus;

  UpdateExerciseInput({
    this.type,
    this.exerciseSubtype,
    this.title,
    this.instruction,
    this.content,
    this.maxScore,
    this.difficulty,
    this.xpReward,
    this.timeLimit,
    this.estimatedTime,
    this.requiresAudio,
    this.requiresMicrophone,
    this.isActive,
    this.isPremium,
    this.sortOrder,
    this.skillFocus,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (type != null) data['type'] = type;
    if (exerciseSubtype != null) data['exercise_subtype'] = exerciseSubtype;
    if (title != null) data['title'] = title;
    if (instruction != null) data['instruction'] = instruction;
    if (content != null) data['content'] = content;
    if (maxScore != null) data['maxScore'] = maxScore;
    if (difficulty != null) data['difficulty'] = difficulty;
    if (xpReward != null) data['xpReward'] = xpReward;
    if (timeLimit != null) data['timeLimit'] = timeLimit;
    if (estimatedTime != null) data['estimatedTime'] = estimatedTime;
    if (requiresAudio != null) data['requiresAudio'] = requiresAudio;
    if (requiresMicrophone != null) data['requiresMicrophone'] = requiresMicrophone;
    if (isActive != null) data['isActive'] = isActive;
    if (isPremium != null) data['isPremium'] = isPremium;
    if (sortOrder != null) data['sortOrder'] = sortOrder;
    if (skillFocus != null) data['skillFocus'] = skillFocus;
    return data;
  }
}

class ExerciseFilterInput {
  final String? type;
  final String? exerciseSubtype;
  final String? difficulty;
  final List<String>? skillFocus;
  final bool? isActive;
  final bool? isPremium;
  final bool? requiresAudio;
  final bool? requiresMicrophone;

  ExerciseFilterInput({
    this.type,
    this.exerciseSubtype,
    this.difficulty,
    this.skillFocus,
    this.isActive,
    this.isPremium,
    this.requiresAudio,
    this.requiresMicrophone,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (type != null) data['type'] = type;
    if (exerciseSubtype != null) data['exercise_subtype'] = exerciseSubtype;
    if (difficulty != null) data['difficulty'] = difficulty;
    if (skillFocus != null) data['skillFocus'] = skillFocus;
    if (isActive != null) data['isActive'] = isActive;
    if (isPremium != null) data['isPremium'] = isPremium;
    if (requiresAudio != null) data['requiresAudio'] = requiresAudio;
    if (requiresMicrophone != null) data['requiresMicrophone'] = requiresMicrophone;
    return data;
  }
} 