
// lib/pages/practice/practice_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_themes.dart';

class PracticePage extends StatelessWidget {
  const PracticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.lightGroupedBackground,
      appBar: AppBar(
        backgroundColor: AppThemes.lightSecondaryBackground,
        title: const Text(
          'Luyện tập',
          style: TextStyle(color: AppThemes.lightLabel),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // Practice Stats
          _buildPracticeStats(),

          // Practice Categories
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Speaking Section
                _buildSectionHeader(
                  context,
                  icon: Icons.chat_bubble_outline,
                  title: 'Giao tiếp',
                  color: AppThemes.speaking,
                ),
                const SizedBox(height: 12),
                _buildPracticeCard(
                  context,
                  title: 'Luyện nói',
                  subtitle: 'Thực hành hội thoại và phát âm',
                  icon: Icons.mic,
                  color: AppThemes.speaking,
                  isComingSoon: true,
                  onTap: () => _showComingSoon(context, 'Luyện nói'),
                ),

                const SizedBox(height: 24),

                // Skills Section
                _buildSectionHeader(
                  context,
                  icon: Icons.trending_up,
                  title: 'Kỹ năng',
                  color: AppThemes.mistakes,
                ),
                const SizedBox(height: 12),
                _buildPracticeCard(
                  context,
                  title: 'Các lỗi sai cũ',
                  subtitle: 'Ôn tập những lỗi sai trước đây',
                  icon: Icons.error_outline,
                  color: AppThemes.mistakes,
                  isComingSoon: true,
                  onTap: () => _showComingSoon(context, 'Ôn tập lỗi sai'),
                ),
                const SizedBox(height: 12),
                _buildPracticeCard(
                  context,
                  title: 'Luyện nghe',
                  subtitle: 'Cải thiện kỹ năng nghe',
                  icon: Icons.headphones,
                  color: AppThemes.listening,
                  isComingSoon: true,
                  onTap: () => _showComingSoon(context, 'Luyện nghe'),
                ),
                const SizedBox(height: 12),
                _buildPracticeCard(
                  context,
                  title: 'Luyện đọc',
                  subtitle: 'Nâng cao khả năng đọc hiểu',
                  icon: Icons.menu_book,
                  color: AppThemes.reading,
                  isComingSoon: false,
                  onTap: () => context.push('/reading-practice'),
                ),

                const SizedBox(height: 24),

                // Study Corner Section
                _buildSectionHeader(
                  context,
                  icon: Icons.school,
                  title: 'Học tập',
                  color: AppThemes.primaryGreen,
                ),
                const SizedBox(height: 12),
                _buildPracticeCard(
                  context,
                  title: 'Radio',
                  subtitle: 'Radio tiếng Anh',
                  icon: Icons.radio,
                  color: AppThemes.systemTeal,
                  isComingSoon: true,
                  onTap: () => _showComingSoon(context, 'Radio tiếng Anh'),
                ),
                const SizedBox(height: 12),
                _buildPracticeCard(
                  context,
                  title: 'Từ vựng',
                  subtitle: 'Ôn tập từ vựng đã học',
                  icon: Icons.translate,
                  color: AppThemes.vocabulary,
                  isComingSoon: false,
                  onTap: () => context.push('/vocabulary'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeStats() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppThemes.primaryGreen,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppThemes.primaryGreen.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                icon: Icons.local_fire_department,
                value: '7',
                label: 'Streak',
                color: AppThemes.streak,
              ),
              _buildStatItem(
                icon: Icons.diamond,
                value: '1,247',
                label: 'XP',
                color: AppThemes.xp,
              ),
              _buildStatItem(
                icon: Icons.favorite,
                value: '5',
                label: 'Hearts',
                color: AppThemes.hearts,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.7, // 70% progress
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Level 5 - Intermediate',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppThemes.lightLabel,
          ),
        ),
      ],
    );
  }

  Widget _buildPracticeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isComingSoon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppThemes.lightBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppThemes.lightLabel,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppThemes.lightSecondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
            if (isComingSoon)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppThemes.systemOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Soon',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppThemes.systemOrange,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: AppThemes.lightSecondaryLabel,
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        backgroundColor: AppThemes.primaryGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}