
// lib/pages/practice/practice_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_themes.dart';
import '../../network/exercise_service.dart';
import '../../models/exercise_model.dart';
import '../../network/gamification_service.dart';
import '../../network/auth_service.dart';
import '../../models/user_model.dart';
import 'random_practice_session.dart';

class PracticePage extends StatefulWidget {
  const PracticePage({super.key});

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  UserModel? user;
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final userData = await AuthService.getCurrentUser();
      if (userData != null) {
        setState(() {
          user = UserModel.fromJson(userData);
        });
      }
    } catch (e) {
      print('❌ [PracticePage] Error loading user data: $e');
    }
  }

  Future<void> _startRandomPractice() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      print('🎯 [PracticePage] Starting random practice...');
      
      // Get random exercises from database
      final exercises = await ExerciseService.getRandomExercises(limit: 10);
      
      if (exercises.isEmpty) {
        setState(() {
          error = 'Không có bài tập nào khả dụng';
          isLoading = false;
        });
        return;
      }

      print('✅ [PracticePage] Got ${exercises.length} random exercises');
      
      // Navigate to practice session
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RandomPracticeSession(
              exercises: exercises,
              onCompleted: _onPracticeCompleted,
            ),
          ),
        );
      }

      setState(() {
        isLoading = false;
      });
      
    } catch (e) {
      print('❌ [PracticePage] Error starting random practice: $e');
      setState(() {
        error = 'Lỗi khi tải bài tập: $e';
        isLoading = false;
      });
    }
  }

  void _onPracticeCompleted(bool allCorrect, int totalExercises) {
    print('🎯 [PracticePage] Practice completed:');
    print('  - All correct: $allCorrect');
    print('  - Total exercises: $totalExercises');
    
    if (allCorrect && totalExercises > 0) {
      print('🎁 [PracticePage] Awarding rewards...');
      // Award XP and diamonds
      _awardPracticeRewards();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.celebration, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Hoàn thành xuất sắc! +5 XP, +5 Diamonds',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: AppThemes.primaryGreen,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      print('❌ [PracticePage] Not all correct, no rewards');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hoàn thành! Làm đúng ${totalExercises - (totalExercises - (totalExercises ~/ 2))} / $totalExercises bài'),
          backgroundColor: AppThemes.systemOrange,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _awardPracticeRewards() async {
    try {
      print('🎁 [PracticePage] Starting to award practice rewards...');
      
      // Update user data locally
      if (user != null) {
        print('  - Current user XP: ${user!.totalXP}');
        print('  - Current user diamonds: ${user!.diamonds}');
        
        setState(() {
          user = user!.copyWith(
            totalXP: user!.totalXP + 5,
            diamonds: user!.diamonds + 5,
          );
        });
        
        print('  - New user XP: ${user!.totalXP}');
        print('  - New user diamonds: ${user!.diamonds}');
      } else {
        print('❌ [PracticePage] User is null!');
      }

      // Send to backend
      print('  - Sending to backend...');
      final result = await GamificationService.awardPracticeRewards(xp: 5, diamonds: 5);
      
      if (result != null) {
        print('✅ [PracticePage] Backend rewards awarded successfully');
        print('  - Result: $result');
      } else {
        print('❌ [PracticePage] Backend rewards failed');
      }
      
      print('✅ [PracticePage] Practice rewards awarded: +5 XP, +5 Diamonds');
    } catch (e) {
      print('❌ [PracticePage] Error awarding practice rewards: $e');
    }
  }

  void _openListeningPractice() {
    print('🎧 [PracticePage] Opening listening practice');
    context.push('/listening-practice');
  }

  void _openReadingPractice() {
    print('📖 [PracticePage] Opening reading practice');
    context.push('/reading-practice');
  }

  void _openSpeakingTest() {
    print('🎤 [PracticePage] Opening speaking test');
    context.push('/speaking-test');
  }

  void _openSpeakingPractice() {
    print('🎤 [PracticePage] Opening speaking practice');
    context.push('/speaking-practice');
  }

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

          // Random Practice Section
          _buildRandomPracticeSection(),



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
                  isComingSoon: false,
                  onTap: () => _openSpeakingPractice(),
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
                  isComingSoon: false,
                  onTap: _openListeningPractice,
                ),
                const SizedBox(height: 12),
                _buildPracticeCard(
                  context,
                  title: 'Luyện đọc',
                  subtitle: 'Nâng cao khả năng đọc hiểu',
                  icon: Icons.menu_book,
                  color: AppThemes.reading,
                  isComingSoon: false,
                  onTap: _openReadingPractice,
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

  Widget _buildRandomPracticeSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppThemes.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.auto_fix_high,
                  color: AppThemes.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Luyện tập',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppThemes.lightLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppThemes.primaryGreen.withOpacity(0.1),
                  AppThemes.systemBlue.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppThemes.primaryGreen.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppThemes.primaryGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Luyện tập ngẫu nhiên',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppThemes.lightLabel,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Làm đúng hết +5 XP, +5 Diamonds',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppThemes.lightSecondaryLabel,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (isLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppThemes.primaryGreen),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _startRandomPractice,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppThemes.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.play_arrow, size: 20),
                      label: const Text(
                        'Bắt đầu luyện tập',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            error!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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