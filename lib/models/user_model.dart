// lib/shared/models/user_model.dart

class UserModel {
  final String id;
  final String username;
  final String email;
  final String displayName;
  final String? avatar;
  final String? bio;
  final String currentLevel;
  final int level;
  final int totalXP;
  final int diamonds;
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
    this.bio,
    required this.currentLevel,
    required this.level,
    required this.totalXP,
    required this.diamonds,
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
      bio: json['bio'],
      currentLevel: json['currentLevel'] ?? 'A1',
      level: json['level'] ?? 1,
      totalXP: json['totalXP'] ?? 0,
      diamonds: json['diamonds'] ?? 0,
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
      'bio': bio,
      'currentLevel': currentLevel,
      'level': level,
      'totalXP': totalXP,
      'diamonds': diamonds,
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

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? displayName,
    String? avatar,
    String? bio,
    String? currentLevel,
    int? level,
    int? totalXP,
    int? diamonds,
    int? hearts,
    int? currentStreak,
    int? longestStreak,
    String? subscriptionType,
    bool? isPremium,
    int? dailyGoal,
    bool? isEmailVerified,
    bool? isActive,
    String? role,
    String? createdAt,
    String? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      currentLevel: currentLevel ?? this.currentLevel,
      level: level ?? this.level,
      totalXP: totalXP ?? this.totalXP,
      diamonds: diamonds ?? this.diamonds,
      hearts: hearts ?? this.hearts,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      isPremium: isPremium ?? this.isPremium,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isActive: isActive ?? this.isActive,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}