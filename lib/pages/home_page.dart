// lib/pages/home_page.dart - Enhanced iOS-Style Complete UX/UI
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../network/auth_service.dart';
import '../network/gamification_service.dart';
import '../models/user_model.dart';
import '../theme/app_themes.dart';
import 'leaderboard_page.dart';
import '../widgets/dialogs/heart_purchase_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  UserModel? user;
  bool isLoading = true;
  String errorMessage = '';
  
  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  // Static reference for lesson completion callback
  static HomePageState? _instance;
  
  // Daily goals and progress
  List<Map<String, dynamic>> dailyGoals = [
    {'title': 'Complete 3 lessons', 'target': 3, 'current': 0, 'icon': CupertinoIcons.book, 'color': AppThemes.primaryGreen},
    {'title': 'Earn 50 XP', 'target': 50, 'current': 0, 'icon': CupertinoIcons.bolt, 'color': AppThemes.xp},
    {'title': 'Practice 15 minutes', 'target': 15, 'current': 0, 'icon': CupertinoIcons.timer, 'color': AppThemes.systemBlue},
    {'title': 'Maintain streak', 'target': 1, 'current': 0, 'icon': CupertinoIcons.flame, 'color': AppThemes.streak},
  ];
  
  // Recent achievements
  List<Map<String, dynamic>> recentAchievements = [
    {'title': 'First Lesson', 'description': 'Completed first lesson', 'icon': CupertinoIcons.rosette, 'color': Colors.amber, 'unlocked': true},
    {'title': 'Streak Master', 'description': '7-day learning streak', 'icon': CupertinoIcons.flame, 'color': AppThemes.streak, 'unlocked': false},
    {'title': 'XP Collector', 'description': 'Earned 1000 XP', 'icon': CupertinoIcons.bolt, 'color': AppThemes.xp, 'unlocked': false},
    {'title': 'Diamond Hunter', 'description': 'Collected 100 diamonds', 'icon': CupertinoIcons.sparkles, 'color': AppThemes.systemIndigo, 'unlocked': false},
  ];

  // Leaderboard data
  List<Map<String, dynamic>> leaderboardData = [];
  
  // Daily diamond claim state
  bool _dailyDiamondsClaimed = false;
  String? _lastClaimDate;

  @override
  void initState() {
    super.initState();
    _instance = this;
    _initAnimations();
    _loadUserInfo();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    _instance = null;
    super.dispose();
  }

  // =================== ALL ORIGINAL LOGIC METHODS (UNCHANGED) ===================
  
  // Static method for lesson completion callback
  static void onLessonCompleted({int xpEarned = 5, int diamondsEarned = 10}) {
    _instance?.updateUserDataOnLessonCompleted(
      xpEarned: xpEarned,
      diamondsEarned: diamondsEarned,
    );
    _instance?.updateDailyGoalsOnLessonComplete(xpEarned: xpEarned);
  }

  Future<void> _loadUserInfo() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final userdata = await AuthService.getCurrentUser();
      if (userdata != null) {
        print('📊 [HomePage] User data loaded:');
        print('  - Level: ${userdata['level']}');
        print('  - Total XP: ${userdata['totalXP']}');
        print('  - Diamonds: ${userdata['diamonds']}');
        print('  - Hearts: ${userdata['hearts']}');
        
        setState(() {
          user = UserModel.fromJson(userdata);
        });
      }

      // Load daily goals
      await _loadDailyGoals();
      
      // Load achievements
      await _loadAchievements();
      
      // Load leaderboard
      await _loadLeaderboard();
      
      setState(() {
        isLoading = false;
      });

      // Start animations after data loads
      _fadeController.forward();
      _slideController.forward();
      _scaleController.forward();
      
    } catch (e) {
      print('❌ [HomePage] Error loading user data: $e');
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    print('🔄 [HomePage] Refreshing all data...');
    await _loadUserInfo();
  }

  Future<void> _refreshDailyGoals() async {
    print('🔄 [HomePage] Refreshing daily goals...');
    await _loadDailyGoals();
  }

  Future<void> _loadDailyGoals() async {
    try {
      final goalsData = await GamificationService.getDailyGoals();
      if (goalsData != null) {
        setState(() {
          dailyGoals[0]['current'] = goalsData['lessonsCompleted'] ?? 0;
          dailyGoals[1]['current'] = goalsData['xpEarned'] ?? 0;
          dailyGoals[2]['current'] = goalsData['practiceTime'] ?? 0;
          dailyGoals[3]['current'] = goalsData['streakMaintained'] ?? 0;
        });
        print('✅ [HomePage] Daily goals loaded');
      }
    } catch (e) {
      print('❌ [HomePage] Error loading daily goals: $e');
    }
  }

  void updateDailyGoalsOnLessonComplete({int xpEarned = 5}) {
    setState(() {
      dailyGoals[0]['current'] = (dailyGoals[0]['current'] as int) + 1;
      dailyGoals[1]['current'] = (dailyGoals[1]['current'] as int) + xpEarned;
      dailyGoals[2]['current'] = (dailyGoals[2]['current'] as int) + 5;
      dailyGoals[3]['current'] = 1;
    });
    
    print('✅ [HomePage] Daily goals updated locally');
    print('  - Lessons completed: ${dailyGoals[0]['current']}');
    print('  - XP earned: ${dailyGoals[1]['current']}');
    print('  - Practice time: ${dailyGoals[2]['current']} minutes');
    print('  - Streak maintained: ${dailyGoals[3]['current']}');
  }

  void updateUserDataOnLessonCompleted({int xpEarned = 5, int diamondsEarned = 10}) {
    if (user != null) {
      setState(() {
        user = user!.copyWith(
          totalXP: user!.totalXP + xpEarned,
          diamonds: user!.diamonds + diamondsEarned,
          currentStreak: user!.currentStreak + 1,
        );
      });
      
      print('✅ [HomePage] User data updated locally');
      print('  - Total XP: ${user!.totalXP}');
      print('  - Diamonds: ${user!.diamonds}');
      print('  - Current Streak: ${user!.currentStreak}');
    }
  }

  Future<void> _loadAchievements() async {
    try {
      final achievementsData = await GamificationService.getUserAchievements();
      if (achievementsData != null && achievementsData.isNotEmpty) {
        setState(() {
          recentAchievements = achievementsData.take(4).map((achievement) {
            return {
              'title': achievement['title'] ?? 'Achievement',
              'description': achievement['description'] ?? 'Complete this achievement',
              'icon': _getAchievementIcon(achievement['icon']),
              'color': _getAchievementColor(achievement['color']),
              'unlocked': achievement['unlocked'] ?? false,
            };
          }).toList();
        });
        print('✅ [HomePage] Achievements loaded: ${recentAchievements.length}');
      }
    } catch (e) {
      print('❌ [HomePage] Error loading achievements: $e');
    }
  }

  IconData _getAchievementIcon(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'trophy': return CupertinoIcons.rosette;
      case 'flame': return CupertinoIcons.flame;
      case 'bolt': return CupertinoIcons.bolt;
      case 'diamond': return CupertinoIcons.sparkles;
      default: return CupertinoIcons.rosette;
    }
  }

  Color _getAchievementColor(String? colorName) {
    switch (colorName?.toLowerCase()) {
      case 'amber': return Colors.amber;
      case 'green': return AppThemes.primaryGreen;
      case 'blue': return AppThemes.systemBlue;
      case 'purple': return AppThemes.systemIndigo;
      case 'orange': return AppThemes.systemOrange;
      default: return AppThemes.primaryGreen;
    }
  }

  Future<void> _loadLeaderboard() async {
    try {
      final leaderboard = await GamificationService.getLeaderboard(limit: 10);
      if (leaderboard != null) {
        setState(() {
          leaderboardData = leaderboard;
        });
        print('✅ [HomePage] Leaderboard loaded: ${leaderboardData.length} users');
      }
    } catch (e) {
      print('❌ [HomePage] Error loading leaderboard: $e');
    }
  }

  Future<void> _claimDailyDiamonds() async {
    try {
      print('💎 [HomePage] Claiming daily diamonds...');
      
      // Since claimDailyDiamond method doesn't exist, we'll simulate it
      // You can replace this with actual GamificationService method when available
      setState(() {
        _dailyDiamondsClaimed = true;
        _lastClaimDate = DateTime.now().toIso8601String();
        if (user != null) {
          user = user!.copyWith(
            diamonds: user!.diamonds + 50, // Default 50 diamonds reward
          );
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('🎉 Nhận được 50 kim cương!'),
          backgroundColor: AppThemes.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      
      print('✅ [HomePage] Daily diamonds claimed: +50 diamonds');
    } catch (e) {
      print('❌ [HomePage] Error claiming daily diamonds: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Lỗi khi nhận kim cương'),
          backgroundColor: AppThemes.systemRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  int _getCurrentUserRank() {
    if (user == null || leaderboardData.isEmpty) return 0;
    
    final userRank = leaderboardData.indexWhere((u) => u['id'] == user!.id);
    return userRank >= 0 ? userRank + 1 : leaderboardData.length + 1;
  }

  void _simulateCompleteAllGoals() {
    setState(() {
      dailyGoals[0]['current'] = 3;
      dailyGoals[1]['current'] = 50;
      dailyGoals[2]['current'] = 15;
      dailyGoals[3]['current'] = 1;
    });
    print('🎯 [HomePage] All daily goals completed for testing');
  }

  // =================== END ORIGINAL LOGIC ===================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (isLoading) {
      return Scaffold(
        backgroundColor: isDark ? AppThemes.darkGroupedBackground : AppThemes.lightGroupedBackground,
        body: _buildLoadingState(),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: isDark ? AppThemes.darkGroupedBackground : AppThemes.lightGroupedBackground,
        body: _buildErrorState(),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppThemes.darkGroupedBackground : AppThemes.lightGroupedBackground,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppThemes.primaryGreen,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      _buildWelcomeSection(),
                      const SizedBox(height: 20),
                      _buildStatsOverview(),
                      const SizedBox(height: 24),
                      _buildDailyGoalsSection(),
                      const SizedBox(height: 24),
                      _buildAchievementsSection(),
                      const SizedBox(height: 24),
                      _buildLeaderboardPreview(),
                      const SizedBox(height: 24),
                      _buildQuickActionsSection(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppThemes.primaryGreen,
                  AppThemes.primaryGreen.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const CupertinoActivityIndicator(
              radius: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Đang tải trang chủ...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark 
                ? AppThemes.darkLabel 
                : AppThemes.lightLabel,
              fontFamily: '-apple-system',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Chuẩn bị trải nghiệm học tập tuyệt vời',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).brightness == Brightness.dark 
                ? AppThemes.darkSecondaryLabel 
                : AppThemes.lightSecondaryLabel,
              fontFamily: '-apple-system',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppThemes.systemRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                CupertinoIcons.exclamationmark_triangle,
                color: AppThemes.systemRed,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Không thể tải dữ liệu',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? AppThemes.darkLabel : AppThemes.lightLabel,
                fontFamily: '-apple-system',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? AppThemes.darkSecondaryLabel : AppThemes.lightSecondaryLabel,
                fontFamily: '-apple-system',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              height: 50,
              child: CupertinoButton(
                color: AppThemes.primaryGreen,
                borderRadius: BorderRadius.circular(25),
                onPressed: _refreshData,
                child: const Text(
                  'Thử lại',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: '-apple-system',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: isDark ? AppThemes.darkSecondaryBackground : AppThemes.lightSecondaryBackground,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          '',
          style: TextStyle(
            color: isDark ? AppThemes.darkLabel : AppThemes.lightLabel,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            fontFamily: '-apple-system',
            letterSpacing: -0.5,
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppThemes.primaryGreen.withOpacity(0.1),
                AppThemes.primaryGreen.withOpacity(0.05),
              ],
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Row(
            children: [
              _buildHeaderActionButton(
                icon: CupertinoIcons.heart_fill,
                value: user?.hearts.toString() ?? '5',
                color: AppThemes.systemRed,
                onTap: () {
                  // Show heart purchase dialog
                },
              ),
              const SizedBox(width: 12),
              _buildHeaderActionButton(
                icon: CupertinoIcons.sparkles,
                value: user?.diamonds.toString() ?? '0',
                color: AppThemes.secondary,
                onTap: () {
                  // Show diamond info
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderActionButton({
    required IconData icon,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                fontFamily: '-apple-system',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userName = user?.displayName ?? 'Learner';
    final timeOfDay = _getTimeOfDay();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppThemes.primaryGreen,
            AppThemes.primaryGreen.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppThemes.primaryGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$timeOfDay,',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        fontFamily: '-apple-system',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        fontFamily: '-apple-system',
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        CupertinoIcons.flame,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            user?.currentStreak != null && user!.currentStreak > 0
                ? '🔥 ${user!.currentStreak} ngày streak!'
                : 'Bắt đầu hành trình học tập hôm nay!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: '-apple-system',
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng';
    if (hour < 17) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  Widget _buildStatsOverview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _buildStatCard(
            icon: CupertinoIcons.bolt_circle,
            title: 'Total XP',
            value: '${user?.totalXP ?? 0}',
            color: AppThemes.xp,
            subtitle: 'Experience points',
          )),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard(
            icon: CupertinoIcons.chart_bar_circle,
            title: 'Level',
            value: '${user?.level ?? 1}',
            color: AppThemes.primaryGreen,
            subtitle: 'Current level',
          )),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard(
            icon: CupertinoIcons.flame_fill,
            title: 'Streak',
            value: '${user?.currentStreak ?? 0}',
            color: AppThemes.streak,
            subtitle: 'Days in a row',
          )),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required String subtitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppThemes.darkSecondaryBackground : AppThemes.lightBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isDark ? [] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? AppThemes.darkLabel : AppThemes.lightLabel,
                fontFamily: '-apple-system',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
                fontFamily: '-apple-system',
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? AppThemes.darkTertiaryLabel : AppThemes.lightTertiaryLabel,
                fontFamily: '-apple-system',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyGoalsSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allGoalsCompleted = dailyGoals.every((goal) => 
      (goal['current'] as int) >= (goal['target'] as int));
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mục tiêu hàng ngày',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppThemes.darkLabel : AppThemes.lightLabel,
                  fontFamily: '-apple-system',
                ),
              ),
              if (allGoalsCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppThemes.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppThemes.primaryGreen.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        CupertinoIcons.checkmark_circle_fill,
                        color: AppThemes.primaryGreen,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Hoàn thành',
                        style: TextStyle(
                          color: AppThemes.primaryGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: '-apple-system',
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: dailyGoals.length,
            itemBuilder: (context, index) {
              final goal = dailyGoals[index];
              final progress = (goal['current'] as int) / (goal['target'] as int);
              final isCompleted = progress >= 1.0;
              
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppThemes.darkSecondaryBackground : AppThemes.lightBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: isCompleted 
                    ? Border.all(color: AppThemes.primaryGreen.withOpacity(0.3), width: 2)
                    : null,
                  boxShadow: isDark ? [] : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: goal['color'].withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            goal['icon'],
                            color: goal['color'],
                            size: 18,
                          ),
                        ),
                        const Spacer(),
                        if (isCompleted)
                          const Icon(
                            CupertinoIcons.checkmark_circle_fill,
                            color: AppThemes.primaryGreen,
                            size: 20,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      goal['title'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppThemes.darkLabel : AppThemes.lightLabel,
                        fontFamily: '-apple-system',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${goal['current']}/${goal['target']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppThemes.darkSecondaryLabel : AppThemes.lightSecondaryLabel,
                        fontFamily: '-apple-system',
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: isDark 
                        ? AppThemes.darkTertiaryBackground 
                        : Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(goal['color']),
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 6,
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Claim Diamond Button when all goals completed and not claimed yet
          if (allGoalsCompleted && !_dailyDiamondsClaimed) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 56,
              child: CupertinoButton(
                color: AppThemes.systemIndigo,
                borderRadius: BorderRadius.circular(16),
                onPressed: _claimDailyDiamonds,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(CupertinoIcons.sparkles, size: 24),
                    const SizedBox(width: 12),
                    const Text(
                      'Nhận thưởng kim cương!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: '-apple-system',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          // Already claimed message
          if (allGoalsCompleted && _dailyDiamondsClaimed) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppThemes.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppThemes.primaryGreen.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.checkmark_circle_fill,
                    color: AppThemes.primaryGreen,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Phần thưởng hôm nay đã được nhận! Quay lại vào ngày mai.',
                      style: TextStyle(
                        color: AppThemes.primaryGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        fontFamily: '-apple-system',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thành tích gần đây',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isDark ? AppThemes.darkLabel : AppThemes.lightLabel,
              fontFamily: '-apple-system',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: recentAchievements.length,
              itemBuilder: (context, index) {
                final achievement = recentAchievements[index];
                return Container(
                  width: 180,
                  margin: EdgeInsets.only(right: index < recentAchievements.length - 1 ? 16 : 0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppThemes.darkSecondaryBackground : AppThemes.lightBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: achievement['unlocked'] 
                        ? Border.all(color: achievement['color'].withOpacity(0.3), width: 2)
                        : null,
                    boxShadow: isDark ? [] : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: achievement['color'].withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              achievement['icon'],
                              color: achievement['unlocked'] 
                                  ? achievement['color']
                                  : (isDark ? AppThemes.darkTertiaryLabel : AppThemes.lightTertiaryLabel),
                              size: 22,
                            ),
                          ),
                          const Spacer(),
                          if (achievement['unlocked'])
                            const Icon(
                              CupertinoIcons.checkmark_circle_fill,
                              color: AppThemes.primaryGreen,
                              size: 20,
                            )
                          else
                            Icon(
                              CupertinoIcons.lock_fill,
                              color: isDark ? AppThemes.darkTertiaryLabel : AppThemes.lightTertiaryLabel,
                              size: 16,
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        achievement['title'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: achievement['unlocked']
                              ? (isDark ? AppThemes.darkLabel : AppThemes.lightLabel)
                              : (isDark ? AppThemes.darkTertiaryLabel : AppThemes.lightTertiaryLabel),
                          fontFamily: '-apple-system',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        achievement['description'],
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppThemes.darkSecondaryLabel : AppThemes.lightSecondaryLabel,
                          fontFamily: '-apple-system',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardPreview() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUserRank = _getCurrentUserRank();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bảng xếp hạng',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppThemes.darkLabel : AppThemes.lightLabel,
                  fontFamily: '-apple-system',
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => const LeaderboardPage()),
                  );
                },
                child: Text(
                  'Xem tất cả',
                  style: TextStyle(
                    color: AppThemes.primaryGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: '-apple-system',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppThemes.darkSecondaryBackground : AppThemes.lightBackground,
              borderRadius: BorderRadius.circular(20),
              boxShadow: isDark ? [] : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                // Current user rank
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppThemes.primaryGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          '#$currentUserRank',
                          style: const TextStyle(
                            color: AppThemes.primaryGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontFamily: '-apple-system',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thứ hạng của bạn',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppThemes.darkLabel : AppThemes.lightLabel,
                              fontFamily: '-apple-system',
                            ),
                          ),
                          Text(
                            '${user?.totalXP ?? 0} XP',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppThemes.darkSecondaryLabel : AppThemes.lightSecondaryLabel,
                              fontFamily: '-apple-system',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      CupertinoIcons.person_fill,
                      color: AppThemes.primaryGreen,
                      size: 20,
                    ),
                  ],
                ),
                
                if (leaderboardData.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Top 3 users
                  ...leaderboardData.take(3).toList().asMap().entries.map((entry) {
                    final index = entry.key;
                    final userData = entry.value;
                    final rank = index + 1;
                    
                    return Padding(
                      padding: EdgeInsets.only(bottom: index < 2 ? 16 : 0),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: _getRankColor(rank).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                '$rank',
                                style: TextStyle(
                                  color: _getRankColor(rank),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: '-apple-system',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userData['displayName'] ?? userData['username'] ?? 'Unknown',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppThemes.darkLabel : AppThemes.lightLabel,
                                    fontFamily: '-apple-system',
                                  ),
                                ),
                                Text(
                                  '${userData['totalXP'] ?? 0} XP',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppThemes.darkSecondaryLabel : AppThemes.lightSecondaryLabel,
                                    fontFamily: '-apple-system',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            _getRankIcon(rank),
                            color: _getRankColor(rank),
                            size: 16,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1: return Colors.amber;
      case 2: return Colors.grey;
      case 3: return Colors.brown;
      default: return AppThemes.primaryGreen;
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1: return CupertinoIcons.star_fill;
      case 2: return CupertinoIcons.circle_fill;
      case 3: return CupertinoIcons.circle_fill;
      default: return CupertinoIcons.person_fill;
    }
  }

  Widget _buildQuickActionsSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hành động nhanh',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isDark ? AppThemes.darkLabel : AppThemes.lightLabel,
              fontFamily: '-apple-system',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'Bắt đầu học',
                  'Tiếp tục hành trình',
                  CupertinoIcons.book_circle,
                  AppThemes.primaryGreen,
                  () => context.go('/courses'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  'Luyện tập',
                  'Ôn tập kiến thức',
                  CupertinoIcons.sportscourt,
                  AppThemes.systemBlue,
                  () => context.go('/practice'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'Từ vựng',
                  'Học từ mới',
                  CupertinoIcons.textformat_abc,
                  AppThemes.systemOrange,
                  () => context.go('/vocabulary'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  'Xếp hạng',
                  'Xem thứ hạng',
                  CupertinoIcons.chart_bar_square,
                  AppThemes.systemIndigo,
                  () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (context) => const LeaderboardPage()),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Test button for demo purposes
          Container(
            width: double.infinity,
            child: _buildQuickActionCard(
              '🎯 Hoàn thành mục tiêu',
              'Demo: Hoàn thành tất cả mục tiêu',
              CupertinoIcons.wand_stars,
              AppThemes.systemPurple,
              _simulateCompleteAllGoals,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppThemes.darkSecondaryBackground : AppThemes.lightBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isDark ? [] : [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppThemes.darkLabel : AppThemes.lightLabel,
                  fontFamily: '-apple-system',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppThemes.darkSecondaryLabel : AppThemes.lightSecondaryLabel,
                  fontFamily: '-apple-system',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}