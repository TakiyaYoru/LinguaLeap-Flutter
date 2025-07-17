// lib/shared/models/user_model.dart

class UserModel {
  final String id;
  final String username;
  final String email;
  final String displayName;
  final String? avatar;
  final String currentLevel;
  final int totalXP;
  final int hearts;
  final int currentStreak;
  final int longestStreak;
  final String subscriptionType;
  final bool isPremium;
  final int dailyGoal;
  final bool isEmailVerified;
  final bool isActive;
  final String role;
  final String createdAt;
  final String updatedAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.displayName,
    this.avatar,
    required this.currentLevel,
    required this.totalXP,
    required this.hearts,
    required this.currentStreak,
    required this.longestStreak,
    required this.subscriptionType,
    required this.isPremium,
    required this.dailyGoal,
    required this.isEmailVerified,
    required this.isActive,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      avatar: json['avatar'],
      currentLevel: json['currentLevel'] ?? 'A1',
      totalXP: json['totalXP'] ?? 0,
      hearts: json['hearts'] ?? 5,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      subscriptionType: json['subscriptionType'] ?? 'free',
      isPremium: json['isPremium'] ?? false,
      dailyGoal: json['dailyGoal'] ?? 50,
      isEmailVerified: json['isEmailVerified'] ?? false,
      isActive: json['isActive'] ?? true,
      role: json['role'] ?? 'user',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'displayName': displayName,
      'avatar': avatar,
      'currentLevel': currentLevel,
      'totalXP': totalXP,
      'hearts': hearts,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'subscriptionType': subscriptionType,
      'isPremium': isPremium,
      'dailyGoal': dailyGoal,
      'isEmailVerified': isEmailVerified,
      'isActive': isActive,
      'role': role,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}