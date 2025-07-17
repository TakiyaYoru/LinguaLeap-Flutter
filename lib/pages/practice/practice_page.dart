// lib/pages/practice/practice_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PracticePage extends StatelessWidget {
  const PracticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF40C4AA),
        title: const Text(
          'Luyện tập',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
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
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildPracticeCard(
                  context,
                  title: 'Luyện nói',
                  subtitle: 'Thực hành hội thoại và phát âm',
                  icon: Icons.mic,
                  color: Colors.blue,
                  isComingSoon: true,
                  onTap: () => _showComingSoon(context, 'Luyện nói'),
                ),

                const SizedBox(height: 24),

                // Skills Section
                _buildSectionHeader(
                  context,
                  icon: Icons.trending_up,
                  title: 'Kỹ năng',
                  color: Colors.orange,
                ),
                const SizedBox(height: 12),
                _buildPracticeCard(
                  context,
                  title: 'Các lỗi sai cũ',
                  subtitle: 'Ôn tập những lỗi sai trước đây',
                  icon: Icons.error_outline,
                  color: Colors.red,
                  isComingSoon: true,
                  onTap: () => _showComingSoon(context, 'Ôn tập lỗi sai'),
                ),
                const SizedBox(height: 12),
                _buildPracticeCard(
                  context,
                  title: 'Luyện nghe',
                  subtitle: 'Cải thiện kỹ năng nghe',
                  icon: Icons.headphones,
                  color: Colors.purple,
                  isComingSoon: true,
                  onTap: () => _showComingSoon(context, 'Luyện nghe'),
                ),
                const SizedBox(height: 12),
                _buildPracticeCard(
                  context,
                  title: 'Luyện đọc',
                  subtitle: 'Nâng cao khả năng đọc hiểu',
                  icon: Icons.menu_book,
                  color: Colors.teal,
                  isComingSoon: false,
                  onTap: () => context.push('/reading-practice'),
                ),

                const SizedBox(height: 24),

                // Study Corner Section
                _buildSectionHeader(
                  context,
                  icon: Icons.school,
                  title: 'Học tập',
                  color: Colors.green,
                ),
                const SizedBox(height: 12),
                _buildPracticeCard(
                  context,
                  title: 'Radio',
                  subtitle: 'Nghe podcast và radio tiếng Anh',
                  icon: Icons.radio,
                  color: Colors.indigo,
                  isComingSoon: true,
                  onTap: () => _showComingSoon(context, 'Radio tiếng Anh'),
                ),
                const SizedBox(height: 12),
                _buildPracticeCard(
                  context,
                  title: 'Từ vựng',
                  subtitle: 'Quản lý và ôn tập từ vựng',
                  icon: Icons.book,
                  color: Colors.green,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.timer,
            value: '30',
            label: 'Phút',
            color: Colors.blue,
          ),
          _buildStatItem(
            icon: Icons.check_circle,
            value: '15',
            label: 'Hoàn thành',
            color: Colors.green,
          ),
          _buildStatItem(
            icon: Icons.trending_up,
            value: '85%',
            label: 'Chính xác',
            color: const Color(0xFF40C4AA),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
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
            size: 20,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: color,
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
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isComingSoon)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.withOpacity(0.5),
                      ),
                    ),
                    child: const Text(
                      'Coming soon',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature is coming soon!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}