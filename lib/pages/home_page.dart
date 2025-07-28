// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../network/auth_service.dart';
import '../models/user_model.dart';
import '../theme/app_themes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserModel? user;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final userdata = await AuthService.getCurrentUser();
      
      if (userdata != null) {
        setState(() {
          user = UserModel.fromJson(userdata);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Unable to load user data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppThemes.lightGroupedBackground,
      appBar: AppBar(
        backgroundColor: AppThemes.lightSecondaryBackground,
        title: const Text('Trang chủ', style: TextStyle(color: AppThemes.lightLabel)),
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: AppThemes.primaryGreen),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${user?.displayName ?? 'User'}! 👋',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppThemes.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ready to learn English today?',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppThemes.lightSecondaryLabel,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (user != null) ...[
                    Row(
                      children: [
                        _buildStatChip('Level ${user!.currentLevel}', AppThemes.systemBlue),
                        const SizedBox(width: 8),
                        _buildStatChip('${user!.totalXP} XP', AppThemes.xp),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatChip('❤️ ${user!.hearts}/5', AppThemes.hearts),
                        const SizedBox(width: 8),
                        _buildStatChip('🔥 ${user!.currentStreak} days', AppThemes.streak),
                        const SizedBox(width: 8),
                        if (user!.isPremium)
                          _buildStatChip('👑 Premium', AppThemes.premium),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Promotion Banner
            _buildPromotionBanner(),
            
            // Practice Section
            _buildSectionTitle('Luyện tập'),
            _buildPracticeGrid(),
            
            // History Section
            _buildHistorySection(),

            // Saved Items Section
            _buildSavedSection(),

            // Notes Section
            _buildNotesSection(),

            const SizedBox(height: 16), // Reduced bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
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

  Widget _buildPromotionBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: NetworkImage('https://tinhhoaschool.edu.vn/wp-content/uploads/2021/07/slide-2.jpg'), // Placeholder
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.1), Colors.transparent],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppThemes.lightLabel,
        ),
      ),
    );
  }

  Widget _buildPracticeGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
        children: [
          _buildPracticeCard(
            'Luyện nói',
            Icons.mic,
            AppThemes.speaking,
            () => _showComingSoon('Luyện nói'),
          ),
          _buildPracticeCard(
            'Luyện nghe',
            Icons.headphones,
            AppThemes.listening,
            () => _showComingSoon('Luyện nghe'),
          ),
          _buildPracticeCard(
            'Luyện đọc',
            Icons.menu_book,
            AppThemes.reading,
            () => context.push('/reading-practice'),
          ),
          _buildPracticeCard(
            'Từ vựng',
            Icons.translate,
            AppThemes.vocabulary,
            () => context.push('/vocabulary'),
          ),
          _buildPracticeCard(
            'Exercise CRUD Test',
            Icons.science,
            AppThemes.primaryGreen,
            () => context.push('/exercise-crud-test'),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppThemes.lightLabel,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: AppThemes.primaryGreen),
              const SizedBox(width: 8),
              const Text(
                'Lịch sử học tập',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppThemes.lightLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildHistoryItem('Lesson 1: Basic Greetings', '2 hours ago', AppThemes.systemGreen),
          _buildHistoryItem('Vocabulary: Colors', '1 day ago', AppThemes.systemBlue),
          _buildHistoryItem('Grammar: Present Simple', '2 days ago', AppThemes.systemOrange),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String title, String time, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppThemes.lightLabel,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppThemes.lightSecondaryLabel,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bookmark, color: AppThemes.primaryGreen),
              const SizedBox(width: 8),
              const Text(
                'Đã lưu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppThemes.lightLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSavedItem('Useful Phrases', '15 items', AppThemes.systemTeal),
          _buildSavedItem('Grammar Rules', '8 items', AppThemes.systemPurple),
        ],
      ),
    );
  }

  Widget _buildSavedItem(String title, String count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.folder,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppThemes.lightLabel,
                  ),
                ),
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppThemes.lightSecondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppThemes.lightSecondaryLabel,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note, color: AppThemes.primaryGreen),
              const SizedBox(width: 8),
              const Text(
                'Ghi chú',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppThemes.lightLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildNoteItem('Remember to practice pronunciation', 'Today'),
          _buildNoteItem('Review irregular verbs', 'Yesterday'),
        ],
      ),
    );
  }

  Widget _buildNoteItem(String content, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: AppThemes.lightLabel,
            ),
          ),
          Text(
            date,
            style: TextStyle(
              fontSize: 12,
              color: AppThemes.lightSecondaryLabel,
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        backgroundColor: AppThemes.primaryGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}