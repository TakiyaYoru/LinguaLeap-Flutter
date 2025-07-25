// lib/shared/models/course_model.dart

import 'package:flutter/material.dart';
import 'unit_model.dart';
import 'lesson_model.dart';

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
      totalQuestions: json['total_questions'] ?? 25,
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

class CreatedBy {
  final String id;
  final String username;
  final String displayName;

  CreatedBy({
    required this.id,
    required this.username,
    required this.displayName,
  });

  factory CreatedBy.fromJson(Map<String, dynamic> json) {
    return CreatedBy(
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

class CourseModel {
  final String id;
  final String title;
  final String description;
  final List<UnitModel> units;
  final int totalLessons;
  final int estimatedHours;
  final bool isPremium;
  final Color colorValue;
  final String level;
  final String language;
  final String imageUrl;

  // Additional fields from old model
  final String category;
  final List<String> skillFocus;
  final String difficulty;
  final int totalXP;
  final int enrollmentCount;
  final int completionCount;
  final double averageRating;
  final int completionRate;
  final String slug;
  final CreatedBy? createdBy;
  final String createdAt;
  final String updatedAt;
  final ChallengeTest? challengeTest;
  final int totalUnits;
  final int estimatedDuration;
  final String color;
  final bool isPublished;
  final String? publishedAt;
  final List<String> learningObjectives;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.units,
    required this.totalLessons,
    required this.estimatedHours,
    required this.isPremium,
    required this.colorValue,
    required this.level,
    required this.language,
    required this.imageUrl,
    // Additional fields
    this.category = 'general',
    this.skillFocus = const [],
    this.difficulty = 'beginner',
    this.totalXP = 0,
    this.enrollmentCount = 0,
    this.completionCount = 0,
    this.averageRating = 0.0,
    this.completionRate = 0,
    this.slug = '',
    this.createdBy,
    this.createdAt = '',
    this.updatedAt = '',
    this.challengeTest,
    this.totalUnits = 0,
    this.estimatedDuration = 0,
    this.color = '#40C4AA',
    this.isPublished = false,
    this.publishedAt,
    this.learningObjectives = const [],
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    // Parse color from string (format: '#RRGGBB' or 'RRGGBB')
    Color parseColor(String? colorStr) {
      if (colorStr == null) return const Color(0xFF40C4AA); // Default color
      
      String hex = colorStr.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex'; // Add alpha channel if missing
      }
      return Color(int.parse(hex, radix: 16));
    }

    return CourseModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      units: (json['units'] as List?)
              ?.map((unit) => UnitModel.fromJson(unit))
              .toList() ??
          [],
      totalLessons: json['totalLessons'] ?? 0,
      estimatedHours: json['estimatedHours'] ?? 0,
      isPremium: json['isPremium'] ?? false,
      colorValue: parseColor(json['colorValue'] ?? json['color']),
      level: json['level'] ?? 'Beginner',
      language: json['language'] ?? 'English',
      imageUrl: json['imageUrl'] ?? '',
      // Additional fields
      category: json['category'] ?? 'general',
      skillFocus: List<String>.from(json['skillFocus'] ?? []),
      difficulty: json['difficulty'] ?? 'beginner',
      totalXP: json['totalXP'] ?? 0,
      enrollmentCount: json['enrollmentCount'] ?? 0,
      completionCount: json['completionCount'] ?? 0,
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      completionRate: json['completionRate'] ?? 0,
      slug: json['slug'] ?? '',
      createdBy: json['createdBy'] != null ? CreatedBy.fromJson(json['createdBy']) : null,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      challengeTest: json['challengeTest'] != null ? ChallengeTest.fromJson(json['challengeTest']) : null,
      totalUnits: json['totalUnits'] ?? json['units']?.length ?? 0,
      estimatedDuration: json['estimatedDuration'] ?? json['estimatedHours'] * 60 ?? 0,
      color: json['color'] ?? json['colorValue'] ?? '#40C4AA',
      isPublished: json['isPublished'] ?? false,
      publishedAt: json['publishedAt'],
      learningObjectives: List<String>.from(json['learningObjectives'] ?? []),
    );
  }

  // Helper methods
  double getProgress(List<String> completedLessons) {
    if (totalLessons == 0) return 0.0;
    final completed = completedLessons
        .where((id) => id.startsWith(this.id))
        .length;
    return completed / totalLessons;
  }

  UnitModel? getCurrentUnit(String currentUnitId) {
    try {
      return units.firstWhere((unit) => unit.id == currentUnitId);
    } catch (e) {
      return null;
    }
  }

  // Note: This method now requires a network call to get lesson details
  // Consider using LessonService directly instead
  Future<LessonModel?> getCurrentLesson(String currentLessonId) async {
    try {
      // This should be handled by the UI layer using LessonService
      return null;
    } catch (e) {
      return null;
    }
  }

  String get durationText {
    if (estimatedDuration < 60) {
      return '${estimatedDuration}m';
    } else {
      final hours = estimatedDuration ~/ 60;
      final minutes = estimatedDuration % 60;
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
  }

  String get levelDisplay {
    switch (level.toLowerCase()) {
      case 'a1': return 'Beginner';
      case 'a2': return 'Elementary';
      case 'b1': return 'Intermediate';
      case 'b2': return 'Upper-Intermediate';
      case 'c1': return 'Advanced';
      case 'c2': return 'Proficient';
      default: return level;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'units': units.map((unit) => unit.toJson()).toList(),
      'totalLessons': totalLessons,
      'estimatedHours': estimatedHours,
      'isPremium': isPremium,
      'colorValue': '#${colorValue.value.toRadixString(16).substring(2)}',
      'level': level,
      'language': language,
      'imageUrl': imageUrl,
      // Additional fields
      'category': category,
      'skillFocus': skillFocus,
      'difficulty': difficulty,
      'totalXP': totalXP,
      'enrollmentCount': enrollmentCount,
      'completionCount': completionCount,
      'averageRating': averageRating,
      'completionRate': completionRate,
      'slug': slug,
      'createdBy': createdBy?.toJson(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'challengeTest': challengeTest?.toJson(),
      'totalUnits': totalUnits,
      'estimatedDuration': estimatedDuration,
      'color': color,
      'isPublished': isPublished,
      'publishedAt': publishedAt,
    };
  }
}
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'challengeTest': challengeTest?.toJson(),
      'totalUnits': totalUnits,
      'estimatedDuration': estimatedDuration,
      'color': color,
      'isPublished': isPublished,
      'publishedAt': publishedAt,
    };
  }
}