// ===============================================
// LEADERBOARD PAGE - LINGUALEAP
// ===============================================

import 'package:flutter/material.dart';
import '../theme/app_themes.dart';
import '../network/gamification_service.dart';
import '../network/auth_service.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<Map<String, dynamic>>? leaderboardData;
  Map<String, dynamic>? currentUser;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      // Load current user data
      final userData = await AuthService.getCurrentUser();
      
      // Load leaderboard data
      final leaderboard = await GamificationService.getLeaderboard(limit: 100);

      setState(() {
        currentUser = userData;
        leaderboardData = leaderboard;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.lightGroupedBackground,
      appBar: AppBar(
        backgroundColor: AppThemes.lightSecondaryBackground,
        title: const Text(
          'Bảng xếp hạng',
          style: TextStyle(color: AppThemes.lightLabel),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppThemes.primaryGreen),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppThemes.primaryGreen),
            onPressed: _loadData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? _buildErrorWidget()
              : _buildLeaderboard(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppThemes.lightSecondaryLabel,
          ),
          const SizedBox(height: 16),
          Text(
            errorMessage,
            style: TextStyle(
              fontSize: 16,
              color: AppThemes.lightSecondaryLabel,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemes.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard() {
    if (leaderboardData == null || leaderboardData!.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có dữ liệu xếp hạng',
          style: TextStyle(
            fontSize: 16,
            color: AppThemes.lightSecondaryLabel,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: leaderboardData!.length,
        itemBuilder: (context, index) {
          final user = leaderboardData![index];
          final rank = user['rank'] ?? (index + 1);
          final isCurrentUser = currentUser != null && 
              currentUser!['id'] == user['id'];

          return _buildLeaderboardItem(user, rank, isCurrentUser);
        },
      ),
    );
  }

  Widget _buildLeaderboardItem(Map<String, dynamic> user, int rank, bool isCurrentUser) {
    final displayName = user['displayName'] ?? user['username'] ?? 'Unknown';
    final totalXP = user['totalXP'] ?? 0;
    final level = user['level'] ?? 1;
    final diamonds = user['diamonds'] ?? 0;
    final streak = user['currentStreak'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCurrentUser 
            ? AppThemes.primaryGreen.withOpacity(0.1)
            : AppThemes.lightBackground,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentUser
            ? Border.all(color: AppThemes.primaryGreen, width: 2)
            : Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: _buildRankBadge(rank),
        title: Row(
          children: [
            Expanded(
              child: Text(
                displayName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isCurrentUser 
                      ? AppThemes.primaryGreen 
                      : AppThemes.lightLabel,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isCurrentUser)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppThemes.primaryGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Bạn',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                _buildStatChip('Level $level', AppThemes.systemBlue),
                const SizedBox(width: 8),
                _buildStatChip('$totalXP XP', AppThemes.xp),
                const SizedBox(width: 8),
                _buildStatChip('💎 $diamonds', AppThemes.systemIndigo),
                const SizedBox(width: 8),
                _buildStatChip('🔥 $streak', AppThemes.streak),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    Color badgeColor;
    IconData? icon;
    
    switch (rank) {
      case 1:
        badgeColor = Colors.amber;
        icon = Icons.emoji_events;
        break;
      case 2:
        badgeColor = Colors.grey.shade400;
        icon = Icons.emoji_events;
        break;
      case 3:
        badgeColor = Colors.orange.shade700;
        icon = Icons.emoji_events;
        break;
      default:
        badgeColor = AppThemes.lightSecondaryLabel;
        icon = null;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: icon != null
            ? Icon(icon, color: Colors.white, size: 24)
            : Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildStatChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
} 