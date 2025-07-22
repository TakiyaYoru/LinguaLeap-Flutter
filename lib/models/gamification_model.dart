class GamificationData {
  final int hearts;
  final int streak;
  final int xp;
  final int coins;
  final int trophies;
  final bool isPremium;

  GamificationData({
    required this.hearts,
    required this.streak,
    required this.xp,
    required this.coins,
    required this.trophies,
    required this.isPremium,
  });

  factory GamificationData.fromJson(Map<String, dynamic> json) {
    return GamificationData(
      hearts: json['hearts'] ?? 5,
      streak: json['streak'] ?? 0,
      xp: json['xp'] ?? 0,
      coins: json['coins'] ?? 0,
      trophies: json['trophies'] ?? 0,
      isPremium: json['isPremium'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hearts': hearts,
      'streak': streak,
      'xp': xp,
      'coins': coins,
      'trophies': trophies,
      'isPremium': isPremium,
    };
  }

  GamificationData copyWith({
    int? hearts,
    int? streak,
    int? xp,
    int? coins,
    int? trophies,
    bool? isPremium,
  }) {
    return GamificationData(
      hearts: hearts ?? this.hearts,
      streak: streak ?? this.streak,
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      trophies: trophies ?? this.trophies,
      isPremium: isPremium ?? this.isPremium,
    );
  }
} 