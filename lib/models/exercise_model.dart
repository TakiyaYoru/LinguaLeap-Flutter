// lib/models/exercise_model.dart
import 'dart:convert';

class ExerciseModel {
  final String id;
  final String? title;
  final String instruction;
  final String typeDisplayName;
  final String courseId;
  final String unitId;
  final String lessonId;
  final String type;
  final PromptTemplate? promptTemplate;
  final GenerationRules? generationRules;
  final List<String> skillFocus;
  final ExerciseQuestion question;
  final Map<String, dynamic> content;
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
  final ExerciseFeedback feedback;
  final List<String> tags;
  final String createdAt;
  final String updatedAt;

  ExerciseModel({
    required this.id,
    this.title,
    required this.instruction,
    required this.typeDisplayName,
    required this.courseId,
    required this.unitId,
    required this.lessonId,
    required this.type,
    this.promptTemplate,
    this.generationRules,
    required this.skillFocus,
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
    required this.feedback,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'],
      instruction: json['instruction'] ?? '',
      typeDisplayName: json['type_display_name'] ?? 'Bài tập',
      courseId: json['courseId'] ?? '',
      unitId: json['unitId'] ?? '',
      lessonId: json['lessonId'] ?? '',
      type: json['type'] ?? '',
      promptTemplate: json['prompt_template'] != null 
          ? PromptTemplate.fromJson(json['prompt_template']) 
          : null,
      generationRules: json['generation_rules'] != null 
          ? GenerationRules.fromJson(json['generation_rules']) 
          : null,
      skillFocus: List<String>.from(json['skill_focus'] ?? []),
      question: ExerciseQuestion.fromJson(json['question'] ?? {}),
      content: _parseContent(json['content']),
      maxScore: json['maxScore'] ?? 100,
      difficulty: json['difficulty'] ?? 'beginner',
      xpReward: json['xpReward'] ?? 5,
      timeLimit: json['timeLimit'],
      estimatedTime: json['estimatedTime'] ?? 30,
      requiresAudio: json['requires_audio'] ?? false,
      requiresMicrophone: json['requires_microphone'] ?? false,
      isPremium: json['isPremium'] ?? false,
      isActive: json['isActive'] ?? true,
      sortOrder: json['sortOrder'] ?? 0,
      successRate: json['successRate'] ?? 0,
      feedback: ExerciseFeedback.fromJson(json['feedback'] ?? {}),
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
      'type_display_name': typeDisplayName,
      'courseId': courseId,
      'unitId': unitId,
      'lessonId': lessonId,
      'type': type,
      'prompt_template': promptTemplate?.toJson(),
      'generation_rules': generationRules?.toJson(),
      'skill_focus': skillFocus,
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
      'feedback': feedback.toJson(),
      'tags': tags,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Helper methods
  String get displayTitle => title ?? typeDisplayName;
  
  String get difficultyDisplay {
    switch (difficulty.toLowerCase()) {
      case 'beginner': return 'Dễ';
      case 'intermediate': return 'Trung bình';
      case 'advanced': return 'Khó';
      default: return difficulty;
    }
  }

  String get typeDisplay {
    switch (type.toLowerCase()) {
      case 'multiple_choice': return 'Chọn đáp án';
      case 'fill_blank': return 'Điền từ';
      case 'listening': return 'Nghe hiểu';
      case 'translation': return 'Dịch';
      case 'speaking': return 'Phát âm';
      case 'reading': return 'Đọc hiểu';
      case 'word_matching': return 'Ghép từ';
      case 'sentence_building': return 'Sắp xếp câu';
      case 'true_false': return 'Đúng/Sai';
      case 'drag_drop': return 'Kéo thả';
      case 'listen_choose': return 'Nghe và chọn';
      case 'speak_repeat': return 'Nói và lặp lại';
      default: return type;
    }
  }

  bool get hasTimeLimit => timeLimit != null && timeLimit! > 0;
  
  String get timeLimitDisplay {
    if (!hasTimeLimit) return 'Không giới hạn';
    final minutes = timeLimit! ~/ 60;
    final seconds = timeLimit! % 60;
    if (minutes > 0) {
      return seconds > 0 ? '${minutes}p ${seconds}s' : '${minutes}p';
    }
    return '${seconds}s';
  }
}

// AI Generation Models
class GeneratedExercise {
  final String type;
  final Map<String, dynamic> content;
  final VocabularyInfo? vocabulary;
  final int sortOrder;
  final String? audioUrl;

  GeneratedExercise({
    required this.type,
    required this.content,
    this.vocabulary,
    required this.sortOrder,
    this.audioUrl,
  });

  factory GeneratedExercise.fromJson(Map<String, dynamic> json) {
    return GeneratedExercise(
      type: json['type'] ?? '',
      content: _parseContent(json['content']),
      vocabulary: json['vocabulary'] != null 
          ? VocabularyInfo.fromJson(json['vocabulary']) 
          : null,
      sortOrder: json['sortOrder'] ?? 1,
      audioUrl: json['audioUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'content': content,
      'vocabulary': vocabulary?.toJson(),
      'sortOrder': sortOrder,
      'audioUrl': audioUrl,
    };
  }
}

class VocabularyInfo {
  final String word;
  final String meaning;
  final String? pronunciation;

  VocabularyInfo({
    required this.word,
    required this.meaning,
    this.pronunciation,
  });

  factory VocabularyInfo.fromJson(Map<String, dynamic> json) {
    return VocabularyInfo(
      word: json['word'] ?? '',
      meaning: json['meaning'] ?? '',
      pronunciation: json['pronunciation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'meaning': meaning,
      'pronunciation': pronunciation,
    };
  }
}

class PromptTemplate {
  final String? systemContext;
  final String? mainPrompt;
  final List<String> variables;
  final Map<String, dynamic> expectedOutputFormat;
  final Map<String, dynamic> fallbackTemplate;

  PromptTemplate({
    this.systemContext,
    this.mainPrompt,
    required this.variables,
    required this.expectedOutputFormat,
    required this.fallbackTemplate,
  });

  factory PromptTemplate.fromJson(Map<String, dynamic> json) {
    return PromptTemplate(
      systemContext: json['system_context'],
      mainPrompt: json['main_prompt'],
      variables: List<String>.from(json['variables'] ?? []),
      expectedOutputFormat: json['expected_output_format'] ?? {},
      fallbackTemplate: json['fallback_template'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'system_context': systemContext,
      'main_prompt': mainPrompt,
      'variables': variables,
      'expected_output_format': expectedOutputFormat,
      'fallback_template': fallbackTemplate,
    };
  }
}

class GenerationRules {
  final int maxAttempts;
  final List<String> validationRules;
  final bool difficultyAdaptation;
  final List<String> contentFilters;

  GenerationRules({
    required this.maxAttempts,
    required this.validationRules,
    required this.difficultyAdaptation,
    required this.contentFilters,
  });

  factory GenerationRules.fromJson(Map<String, dynamic> json) {
    return GenerationRules(
      maxAttempts: json['max_attempts'] ?? 3,
      validationRules: List<String>.from(json['validation_rules'] ?? []),
      difficultyAdaptation: json['difficulty_adaptation'] ?? true,
      contentFilters: List<String>.from(json['content_filters'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'max_attempts': maxAttempts,
      'validation_rules': validationRules,
      'difficulty_adaptation': difficultyAdaptation,
      'content_filters': contentFilters,
    };
  }
}

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

// Helper method to parse content from JSON string or object
Map<String, dynamic> _parseContent(dynamic content) {
  if (content == null) return {};
  
  if (content is Map<String, dynamic>) {
    return content;
  }
  
  if (content is String) {
    try {
      final Map<String, dynamic> parsed = jsonDecode(content);
      return parsed;
    } catch (e) {
      print('⚠️ Error parsing content JSON: $e');
      return {};
    }
  }
  
  return {};
} 
import 'dart:convert';

class ExerciseModel {
  final String id;
  final String? title;
  final String instruction;
  final String typeDisplayName;
  final String courseId;
  final String unitId;
  final String lessonId;
  final String type;
  final PromptTemplate? promptTemplate;
  final GenerationRules? generationRules;
  final List<String> skillFocus;
  final ExerciseQuestion question;
  final Map<String, dynamic> content;
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
  final ExerciseFeedback feedback;
  final List<String> tags;
  final String createdAt;
  final String updatedAt;

  ExerciseModel({
    required this.id,
    this.title,
    required this.instruction,
    required this.typeDisplayName,
    required this.courseId,
    required this.unitId,
    required this.lessonId,
    required this.type,
    this.promptTemplate,
    this.generationRules,
    required this.skillFocus,
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
    required this.feedback,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'],
      instruction: json['instruction'] ?? '',
      typeDisplayName: json['type_display_name'] ?? 'Bài tập',
      courseId: json['courseId'] ?? '',
      unitId: json['unitId'] ?? '',
      lessonId: json['lessonId'] ?? '',
      type: json['type'] ?? '',
      promptTemplate: json['prompt_template'] != null 
          ? PromptTemplate.fromJson(json['prompt_template']) 
          : null,
      generationRules: json['generation_rules'] != null 
          ? GenerationRules.fromJson(json['generation_rules']) 
          : null,
      skillFocus: List<String>.from(json['skill_focus'] ?? []),
      question: ExerciseQuestion.fromJson(json['question'] ?? {}),
      content: _parseContent(json['content']),
      maxScore: json['maxScore'] ?? 100,
      difficulty: json['difficulty'] ?? 'beginner',
      xpReward: json['xpReward'] ?? 5,
      timeLimit: json['timeLimit'],
      estimatedTime: json['estimatedTime'] ?? 30,
      requiresAudio: json['requires_audio'] ?? false,
      requiresMicrophone: json['requires_microphone'] ?? false,
      isPremium: json['isPremium'] ?? false,
      isActive: json['isActive'] ?? true,
      sortOrder: json['sortOrder'] ?? 0,
      successRate: json['successRate'] ?? 0,
      feedback: ExerciseFeedback.fromJson(json['feedback'] ?? {}),
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
      'type_display_name': typeDisplayName,
      'courseId': courseId,
      'unitId': unitId,
      'lessonId': lessonId,
      'type': type,
      'prompt_template': promptTemplate?.toJson(),
      'generation_rules': generationRules?.toJson(),
      'skill_focus': skillFocus,
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
      'feedback': feedback.toJson(),
      'tags': tags,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Helper methods
  String get displayTitle => title ?? typeDisplayName;
  
  String get difficultyDisplay {
    switch (difficulty.toLowerCase()) {
      case 'beginner': return 'Dễ';
      case 'intermediate': return 'Trung bình';
      case 'advanced': return 'Khó';
      default: return difficulty;
    }
  }

  String get typeDisplay {
    switch (type.toLowerCase()) {
      case 'multiple_choice': return 'Chọn đáp án';
      case 'fill_blank': return 'Điền từ';
      case 'listening': return 'Nghe hiểu';
      case 'translation': return 'Dịch';
      case 'speaking': return 'Phát âm';
      case 'reading': return 'Đọc hiểu';
      case 'word_matching': return 'Ghép từ';
      case 'sentence_building': return 'Sắp xếp câu';
      case 'true_false': return 'Đúng/Sai';
      case 'drag_drop': return 'Kéo thả';
      case 'listen_choose': return 'Nghe và chọn';
      case 'speak_repeat': return 'Nói và lặp lại';
      default: return type;
    }
  }

  bool get hasTimeLimit => timeLimit != null && timeLimit! > 0;
  
  String get timeLimitDisplay {
    if (!hasTimeLimit) return 'Không giới hạn';
    final minutes = timeLimit! ~/ 60;
    final seconds = timeLimit! % 60;
    if (minutes > 0) {
      return seconds > 0 ? '${minutes}p ${seconds}s' : '${minutes}p';
    }
    return '${seconds}s';
  }
}

// AI Generation Models
class GeneratedExercise {
  final String type;
  final Map<String, dynamic> content;
  final VocabularyInfo? vocabulary;
  final int sortOrder;
  final String? audioUrl;

  GeneratedExercise({
    required this.type,
    required this.content,
    this.vocabulary,
    required this.sortOrder,
    this.audioUrl,
  });

  factory GeneratedExercise.fromJson(Map<String, dynamic> json) {
    return GeneratedExercise(
      type: json['type'] ?? '',
      content: _parseContent(json['content']),
      vocabulary: json['vocabulary'] != null 
          ? VocabularyInfo.fromJson(json['vocabulary']) 
          : null,
      sortOrder: json['sortOrder'] ?? 1,
      audioUrl: json['audioUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'content': content,
      'vocabulary': vocabulary?.toJson(),
      'sortOrder': sortOrder,
      'audioUrl': audioUrl,
    };
  }
}

class VocabularyInfo {
  final String word;
  final String meaning;
  final String? pronunciation;

  VocabularyInfo({
    required this.word,
    required this.meaning,
    this.pronunciation,
  });

  factory VocabularyInfo.fromJson(Map<String, dynamic> json) {
    return VocabularyInfo(
      word: json['word'] ?? '',
      meaning: json['meaning'] ?? '',
      pronunciation: json['pronunciation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'meaning': meaning,
      'pronunciation': pronunciation,
    };
  }
}

class PromptTemplate {
  final String? systemContext;
  final String? mainPrompt;
  final List<String> variables;
  final Map<String, dynamic> expectedOutputFormat;
  final Map<String, dynamic> fallbackTemplate;

  PromptTemplate({
    this.systemContext,
    this.mainPrompt,
    required this.variables,
    required this.expectedOutputFormat,
    required this.fallbackTemplate,
  });

  factory PromptTemplate.fromJson(Map<String, dynamic> json) {
    return PromptTemplate(
      systemContext: json['system_context'],
      mainPrompt: json['main_prompt'],
      variables: List<String>.from(json['variables'] ?? []),
      expectedOutputFormat: json['expected_output_format'] ?? {},
      fallbackTemplate: json['fallback_template'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'system_context': systemContext,
      'main_prompt': mainPrompt,
      'variables': variables,
      'expected_output_format': expectedOutputFormat,
      'fallback_template': fallbackTemplate,
    };
  }
}

class GenerationRules {
  final int maxAttempts;
  final List<String> validationRules;
  final bool difficultyAdaptation;
  final List<String> contentFilters;

  GenerationRules({
    required this.maxAttempts,
    required this.validationRules,
    required this.difficultyAdaptation,
    required this.contentFilters,
  });

  factory GenerationRules.fromJson(Map<String, dynamic> json) {
    return GenerationRules(
      maxAttempts: json['max_attempts'] ?? 3,
      validationRules: List<String>.from(json['validation_rules'] ?? []),
      difficultyAdaptation: json['difficulty_adaptation'] ?? true,
      contentFilters: List<String>.from(json['content_filters'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'max_attempts': maxAttempts,
      'validation_rules': validationRules,
      'difficulty_adaptation': difficultyAdaptation,
      'content_filters': contentFilters,
    };
  }
}

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

// Helper method to parse content from JSON string or object
Map<String, dynamic> _parseContent(dynamic content) {
  if (content == null) return {};
  
  if (content is Map<String, dynamic>) {
    return content;
  }
  
  if (content is String) {
    try {
      final Map<String, dynamic> parsed = jsonDecode(content);
      return parsed;
    } catch (e) {
      print('⚠️ Error parsing content JSON: $e');
      return {};
    }
  }
  
  return {};
} 