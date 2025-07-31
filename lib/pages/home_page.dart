// lib/pages/home_page.dart
import 'package:flutter/material.dart';
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
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Static reference for lesson completion callback
  static HomePageState? _instance;
  
  // Daily goals and progress
  List<Map<String, dynamic>> dailyGoals = [
    {'title': 'Complete 3 lessons', 'target': 3, 'current': 0, 'icon': Icons.school, 'color': AppThemes.primaryGreen},
    {'title': 'Earn 50 XP', 'target': 50, 'current': 0, 'icon': Icons.bolt, 'color': AppThemes.xp},
    {'title': 'Practice 15 minutes', 'target': 15, 'current': 0, 'icon': Icons.timer, 'color': AppThemes.systemBlue},
    {'title': 'Maintain streak', 'target': 1, 'current': 0, 'icon': Icons.local_fire_department, 'color': AppThemes.streak},
  ];
  
  // Recent achievements
  List<Map<String, dynamic>> recentAchievements = [
    {'title': 'First Lesson', 'description': 'Completed your first lesson', 'icon': Icons.emoji_events, 'color': Colors.amber, 'unlocked': true},
    {'title': 'Streak Master', 'description': '7-day learning streak', 'icon': Icons.local_fire_department, 'color': AppThemes.streak, 'unlocked': false},
    {'title': 'XP Collector', 'description': 'Earned 1000 XP', 'icon': Icons.bolt, 'color': AppThemes.xp, 'unlocked': false},
    {'title': 'Diamond Hunter', 'description': 'Collected 100 diamonds', 'icon': Icons.diamond, 'color': AppThemes.systemIndigo, 'unlocked': false},
  ];

  // Leaderboard data
  List<Map<String, dynamic>> leaderboardData = [];

  @override
  void initState() {
    super.initState();
    _instance = this;
    _initializeAnimations();
    _loadUserInfo();
    
    // Listen for lesson completion events
    _setupLessonCompletionListener();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _pulseController.repeat(reverse: true);
    _slideController.forward();
  }

  @override
  void dispose() {
    if (_instance == this) {
      _instance = null;
    }
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _setupLessonCompletionListener() {
    // This will be called when lesson is completed
    // For now, we'll use a simple approach with static method
    // In a real app, you might use a state management solution like Provider or Riverpod
  }

  // Static method to update homepage when lesson is completed
  static void onLessonCompleted({int xpEarned = 5, int diamondsEarned = 10}) {
    if (_instance != null && _instance!.mounted) {
      _instance!.updateDailyGoalsOnLessonComplete(xpEarned: xpEarned);
      _instance!.updateUserDataOnLessonCompleted(xpEarned: xpEarned, diamondsEarned: diamondsEarned);
      print('✅ [HomePage] Updated via static method');
    }
  }

  Future<void> _loadUserInfo() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      // Load user data
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

  // Method to refresh daily goals specifically
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

  // Update daily goals locally when lesson is completed
  void updateDailyGoalsOnLessonComplete({int xpEarned = 5}) {
    setState(() {
      // Increment lessons completed
      dailyGoals[0]['current'] = (dailyGoals[0]['current'] as int) + 1;
      
      // Increment XP earned
      dailyGoals[1]['current'] = (dailyGoals[1]['current'] as int) + xpEarned;
      
      // Update practice time (assuming 5 minutes per lesson)
      dailyGoals[2]['current'] = (dailyGoals[2]['current'] as int) + 5;
      
      // Streak is maintained if user completes lesson
      dailyGoals[3]['current'] = 1;
    });
    
    print('✅ [HomePage] Daily goals updated locally');
    print('  - Lessons completed: ${dailyGoals[0]['current']}');
    print('  - XP earned: ${dailyGoals[1]['current']}');
    print('  - Practice time: ${dailyGoals[2]['current']} minutes');
    print('  - Streak maintained: ${dailyGoals[3]['current']}');
  }

  // Update user data when lesson is completed
  void updateUserDataOnLessonCompleted({int xpEarned = 5, int diamondsEarned = 10}) {
    if (user != null) {
      setState(() {
        user = user!.copyWith(
          totalXP: user!.totalXP + xpEarned,
          diamonds: user!.diamonds + diamondsEarned,
          currentStreak: user!.currentStreak + 1, // Increment streak
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
        print('✅ [HomePage] Achievements loaded: ${achievementsData.length} achievements');
      }
    } catch (e) {
      print('❌ [HomePage] Error loading achievements: $e');
    }
  }

  Future<void> _loadLeaderboard() async {
    try {
      final leaderboardData = await GamificationService.getLeaderboard(limit: 10);
      if (leaderboardData != null) {
        setState(() {
          this.leaderboardData = leaderboardData;
        });
        print('✅ [HomePage] Leaderboard loaded: ${leaderboardData.length} users');
      }
    } catch (e) {
      print('❌ [HomePage] Error loading leaderboard: $e');
    }
  }

  IconData _getAchievementIcon(String? iconName) {
    switch (iconName) {
      case 'emoji_events': return Icons.emoji_events;
      case 'local_fire_department': return Icons.local_fire_department;
      case 'bolt': return Icons.bolt;
      case 'diamond': return Icons.diamond;
      case 'school': return Icons.school;
      case 'timer': return Icons.timer;
      default: return Icons.star;
    }
  }

  Color _getAchievementColor(String? colorName) {
    switch (colorName) {
      case 'amber': return Colors.amber;
      case 'red': return AppThemes.streak;
      case 'orange': return AppThemes.xp;
      case 'blue': return AppThemes.systemIndigo;
      case 'green': return AppThemes.primaryGreen;
      default: return AppThemes.primaryGreen;
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
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Custom App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: AppThemes.lightSecondaryBackground,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'LinguaLeap',
                  style: TextStyle(
                    color: AppThemes.lightLabel,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppThemes.primaryGreen.withOpacity(0.1),
                        AppThemes.systemBlue.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                // Hearts indicator
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite, color: Colors.red.shade600, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${user?.hearts ?? 5}',
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Diamonds indicator
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.diamond, color: Colors.blue.shade600, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${user?.diamonds ?? 0}',
                        style: TextStyle(
                          color: Colors.blue.shade600,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Main Content
            SliverToBoxAdapter(
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    // Welcome Section with Level Progress
                    _buildWelcomeSection(),
                    
                    // Daily Goals Section
                    _buildDailyGoalsSection(),
                    
                    // Quick Actions
                    _buildQuickActionsSection(),
                    
                    // Recent Achievements
                    _buildAchievementsSection(),
                    
                    // Learning Stats
                    _buildLearningStatsSection(),
                    
                    // Leaderboard Preview
                    _buildLeaderboardPreview(),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      margin: const EdgeInsets.all(16),
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppThemes.primaryGreen.withOpacity(0.2),
          width: 1,
        ),
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
                      'Welcome back,',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppThemes.lightSecondaryLabel,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.displayName ?? 'Learner',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppThemes.lightLabel,
                      ),
                    ),
                  ],
                ),
              ),
              // Level Badge
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppThemes.primaryGreen,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppThemes.primaryGreen.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lv${user?.level ?? 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // XP Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'XP Progress',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppThemes.lightSecondaryLabel,
                    ),
                  ),
                  Text(
                    '${user?.totalXP ?? 0} XP',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppThemes.xp,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _calculateXPProgress(),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppThemes.xp, AppThemes.primaryGreen],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_getXPToNextLevel()} XP to next level',
                style: TextStyle(
                  fontSize: 12,
                  color: AppThemes.lightSecondaryLabel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyGoalsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daily Goals',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppThemes.lightLabel,
                ),
              ),
              Text(
                '${_getCompletedGoals()}/${dailyGoals.length}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppThemes.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: dailyGoals.length,
            itemBuilder: (context, index) {
              final goal = dailyGoals[index];
              final progress = goal['current'] / goal['target'];
              final isCompleted = progress >= 1.0;
              
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppThemes.lightBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCompleted 
                        ? goal['color'].withOpacity(0.3)
                        : Colors.grey.shade200,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: goal['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            goal['icon'],
                            color: goal['color'],
                            size: 20,
                          ),
                        ),
                        const Spacer(),
                        if (isCompleted)
                          const Icon(
                            Icons.check_circle,
                            color: AppThemes.primaryGreen,
                            size: 20,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      goal['title'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppThemes.lightLabel,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${goal['current']}/${goal['target']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppThemes.lightSecondaryLabel,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(goal['color']),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppThemes.lightLabel,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'Start Learning',
                  'Continue your journey',
                  Icons.school,
                  AppThemes.primaryGreen,
                  () => context.go('/learnmap'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  'Practice',
                  'Review & practice',
                  Icons.fitness_center,
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
                  'Vocabulary',
                  'Learn new words',
                  Icons.book,
                  AppThemes.systemOrange,
                  () => context.go('/vocabulary'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  'Leaderboard',
                  'See rankings',
                  Icons.leaderboard,
                  AppThemes.systemIndigo,
                  () => context.go('/leaderboard'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppThemes.lightBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppThemes.lightLabel,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: AppThemes.lightSecondaryLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Achievements',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppThemes.lightLabel,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recentAchievements.length,
              itemBuilder: (context, index) {
                final achievement = recentAchievements[index];
                return Container(
                  width: 160,
                  margin: EdgeInsets.only(right: index < recentAchievements.length - 1 ? 12 : 0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppThemes.lightBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: achievement['unlocked'] 
                          ? achievement['color'].withOpacity(0.3)
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            achievement['icon'],
                            color: achievement['unlocked'] 
                                ? achievement['color']
                                : Colors.grey.shade400,
                            size: 24,
                          ),
                          const Spacer(),
                          if (achievement['unlocked'])
                            const Icon(
                              Icons.check_circle,
                              color: AppThemes.primaryGreen,
                              size: 16,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        achievement['title'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: achievement['unlocked'] 
                              ? AppThemes.lightLabel
                              : Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        achievement['description'],
                        style: TextStyle(
                          fontSize: 12,
                          color: AppThemes.lightSecondaryLabel,
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

  Widget _buildLearningStatsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppThemes.lightBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Learning Stats',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppThemes.lightLabel,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total XP',
                  '${user?.totalXP ?? 0}',
                  Icons.bolt,
                  AppThemes.xp,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Current Streak',
                  '${user?.currentStreak ?? 0} days',
                  Icons.local_fire_department,
                  AppThemes.streak,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Lessons Completed',
                  '12', // TODO: Get from backend
                  Icons.school,
                  AppThemes.primaryGreen,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Study Time',
                  '2h 30m', // TODO: Get from backend
                  Icons.timer,
                  AppThemes.systemBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppThemes.lightLabel,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppThemes.lightSecondaryLabel,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardPreview() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Leaderboard',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppThemes.lightLabel,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/leaderboard'),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: AppThemes.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppThemes.lightBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                if (leaderboardData.isNotEmpty) ...[
                  ...leaderboardData.take(3).toList().asMap().entries.map((entry) {
                    final index = entry.key;
                    final player = entry.value;
                    final rank = index + 1;
                    final medalColor = rank == 1 ? Colors.amber : 
                                     rank == 2 ? Colors.grey.shade400 : 
                                     Colors.brown.shade300;
                    
                    return _buildLeaderboardItem(
                      player['displayName'] ?? player['username'] ?? 'Unknown',
                      '${player['totalXP']} XP',
                      rank,
                      medalColor,
                    );
                  }).toList(),
                ] else ...[
                  _buildLeaderboardItem('Loading...', '0 XP', 1, Colors.grey.shade400),
                  _buildLeaderboardItem('Loading...', '0 XP', 2, Colors.grey.shade400),
                  _buildLeaderboardItem('Loading...', '0 XP', 3, Colors.grey.shade400),
                ],
                if (user != null)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppThemes.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppThemes.primaryGreen.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Your rank: #${_calculateUserRank()}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppThemes.primaryGreen,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${user!.totalXP} XP',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppThemes.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(String name, String xp, int rank, Color medalColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: medalColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppThemes.lightLabel,
              ),
            ),
          ),
          Text(
            xp,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppThemes.xp,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  double _calculateXPProgress() {
    if (user == null) return 0.0;
    final currentLevel = user!.level;
    final currentXP = user!.totalXP;
    final xpForCurrentLevel = (currentLevel - 1) * 100; // 100 XP per level
    final xpForNextLevel = currentLevel * 100;
    final progress = (currentXP - xpForCurrentLevel) / (xpForNextLevel - xpForCurrentLevel);
    return progress.clamp(0.0, 1.0);
  }

  int _getXPToNextLevel() {
    if (user == null) return 100;
    final currentLevel = user!.level;
    final currentXP = user!.totalXP;
    final xpForCurrentLevel = (currentLevel - 1) * 100;
    final xpForNextLevel = currentLevel * 100;
    return xpForNextLevel - currentXP;
  }

  int _getCompletedGoals() {
    return dailyGoals.where((goal) => goal['current'] >= goal['target']).length;
  }

  int _calculateUserRank() {
    if (user == null || leaderboardData.isEmpty) return 0;
    
    final userXP = user!.totalXP;
    final userRank = leaderboardData.indexWhere((player) => 
      player['id'] == user!.id || 
      (player['displayName'] == user!.displayName && player['totalXP'] == userXP)
    );
    
    return userRank >= 0 ? userRank + 1 : leaderboardData.length + 1;
  }
}