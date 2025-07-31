// lib/pages/profile_page.dart - Enhanced iOS-Style UX/UI
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../network/auth_service.dart';
import '../models/user_model.dart';
import '../theme/app_themes.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  UserModel? user;
  bool isLoading = true;
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadUserInfo();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // =================== LOGIC (UNCHANGED) ===================
  Future<void> _loadUserInfo() async {
    try {
      final userdata = await AuthService.getCurrentUser();
      if (userdata != null) {
        print('📊 [ProfilePage] User data loaded:');
        print('  - Level: ${userdata['level']}');
        print('  - Total XP: ${userdata['totalXP']}');
        print('  - Diamonds: ${userdata['diamonds']}');
        print('  - Hearts: ${userdata['hearts']}');
        
        setState(() {
          user = UserModel.fromJson(userdata);
          isLoading = false;
        });
        
        // Start animations after data loads
        _fadeController.forward();
        _slideController.forward();
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ [ProfilePage] Error loading user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await AuthService.clearToken();
    if (mounted) {
      context.go('/login');
    }
  }

  Future<void> _openSettings() async {
    context.push('/settings');
  }

  Future<void> _openEditProfile() async {
    if (user != null) {
      context.push('/edit-profile', extra: user);
    }
  }
  // =================== END LOGIC ===================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppThemes.darkGroupedBackground : AppThemes.lightGroupedBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // iOS-style App Bar with large title
          SliverAppBar(
            expandedHeight: 100,
            floating: false,
            pinned: true,
            backgroundColor: isDark ? AppThemes.darkSecondaryBackground : AppThemes.lightSecondaryBackground,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Hồ sơ',
                style: TextStyle(
                  color: isDark ? AppThemes.darkLabel : AppThemes.lightLabel,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  fontFamily: '-apple-system',
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: _buildActionButton(
                  icon: CupertinoIcons.settings,
                  onPressed: _openSettings,
                  tooltip: 'Cài đặt',
                ),
              ),
            ],
          ),
          
          // Content
          SliverToBoxAdapter(
            child: isLoading 
              ? _buildLoadingState()
              : user == null 
                ? _buildErrorState()
                : _buildProfileContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppThemes.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onPressed,
          child: Icon(
            icon,
            color: AppThemes.primaryGreen,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppThemes.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const CupertinoActivityIndicator(
              radius: 16,
              color: AppThemes.primaryGreen,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Đang tải thông tin...',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark 
                ? AppThemes.darkSecondaryLabel 
                : AppThemes.lightSecondaryLabel,
              fontSize: 16,
              fontFamily: '-apple-system',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppThemes.systemRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              CupertinoIcons.exclamationmark_circle,
              color: AppThemes.systemRed,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Không thể tải thông tin hồ sơ',
            style: TextStyle(
              color: isDark ? AppThemes.darkLabel : AppThemes.lightLabel,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: '-apple-system',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Vui lòng thử lại sau',
            style: TextStyle(
              color: isDark ? AppThemes.darkSecondaryLabel : AppThemes.lightSecondaryLabel,
              fontSize: 16,
              fontFamily: '-apple-system',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _buildStatsGrid(),
              const SizedBox(height: 24),
              _buildProgressCard(),
              const SizedBox(height: 24),
              _buildMenuSection(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppThemes.darkSecondaryBackground : AppThemes.lightBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar with level badge
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppThemes.primaryGreen,
                      AppThemes.primaryGreen.withOpacity(0.7),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppThemes.primaryGreen.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    user!.displayName.isNotEmpty
                        ? user!.displayName[0].toUpperCase()
                        : user!.email[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: '-apple-system',
                    ),
                  ),
                ),
              ),
              
              // Level badge
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppThemes.systemOrange,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? AppThemes.darkSecondaryBackground : AppThemes.lightBackground,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppThemes.systemOrange.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${user!.level}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: '-apple-system',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Name and email
          Text(
            user!.displayName.isNotEmpty ? user!.displayName : 'Người dùng',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? AppThemes.darkLabel : AppThemes.lightLabel,
              fontFamily: '-apple-system',
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 4),
          
          Text(
            user!.email,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppThemes.darkSecondaryLabel : AppThemes.lightSecondaryLabel,
              fontFamily: '-apple-system',
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Level info and edit button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppThemes.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppThemes.primaryGreen.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Cấp độ ${user!.currentLevel}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppThemes.primaryGreen,
                    fontFamily: '-apple-system',
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Edit Profile Button
              GestureDetector(
                onTap: () => _openEditProfile(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppThemes.primaryGreen,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppThemes.primaryGreen.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        CupertinoIcons.pencil,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Chỉnh sửa',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: '-apple-system',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(child: _buildStatCard(
          icon: CupertinoIcons.flame,
          title: 'XP',
          value: '${user!.totalXP}',
          color: AppThemes.systemOrange,
          subtitle: 'Tổng điểm',
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(
          icon: CupertinoIcons.heart_fill,
          title: 'Tim',
          value: '${user!.hearts}',
          color: AppThemes.systemRed,
          subtitle: 'Còn lại',
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(
          icon: CupertinoIcons.sparkles,
          title: 'Kim cương',
          value: '${user!.diamonds}',
          color: AppThemes.secondary,
          subtitle: 'Tích lũy',
        )),
      ],
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
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppThemes.darkSecondaryBackground : AppThemes.lightBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 2),
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
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
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
    );
  }

  Widget _buildProgressCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final streakDays = user!.currentStreak;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppThemes.primaryGreen,
            AppThemes.primaryGreen.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
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
              const Icon(
                CupertinoIcons.calendar,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Chuỗi học tập',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: '-apple-system',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Text(
                '$streakDays',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFamily: '-apple-system',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ngày liên tiếp',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontFamily: '-apple-system',
                      ),
                    ),
                    Text(
                      'Kỷ lục: ${user!.longestStreak} ngày',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                        fontFamily: '-apple-system',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Column(
      children: [
        _buildMenuCard([
          _buildMenuItem(
            icon: CupertinoIcons.person,
            title: 'Thông tin cá nhân',
            subtitle: 'Cập nhật hồ sơ của bạn',
            onTap: () {
              // TODO: Navigate to edit profile
            },
          ),
          _buildMenuItem(
            icon: CupertinoIcons.chart_bar,
            title: 'Thống kê học tập',
            subtitle: 'Xem tiến độ và thành tích',
            onTap: () {
              // TODO: Navigate to stats
            },
          ),
          _buildMenuItem(
            icon: CupertinoIcons.heart,
            title: 'Từ vựng đã lưu',
            subtitle: 'Danh sách từ yêu thích',
            onTap: () {
              context.push('/vocabulary');
            },
          ),
        ]),
        
        const SizedBox(height: 16),
        
        _buildMenuCard([
          _buildMenuItem(
            icon: CupertinoIcons.settings,
            title: 'Cài đặt',
            subtitle: 'Tùy chỉnh ứng dụng',
            onTap: _openSettings,
          ),
          _buildMenuItem(
            icon: CupertinoIcons.question_circle,
            title: 'Trợ giúp',
            subtitle: 'Hỗ trợ và câu hỏi thường gặp',
            onTap: () {
              // TODO: Navigate to help
            },
          ),
        ]),
        
        const SizedBox(height: 16),
        
        _buildMenuCard([
          _buildMenuItem(
            icon: CupertinoIcons.square_arrow_right,
            title: 'Đăng xuất',
            subtitle: 'Thoát khỏi tài khoản',
            onTap: _showLogoutDialog,
            textColor: AppThemes.systemRed,
            showArrow: false,
          ),
        ]),
      ],
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppThemes.darkSecondaryBackground : AppThemes.lightBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
    bool showArrow = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = textColor ?? (isDark ? AppThemes.darkLabel : AppThemes.lightLabel);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (textColor ?? AppThemes.primaryGreen).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: textColor ?? AppThemes.primaryGreen,
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: primaryTextColor,
                        fontFamily: '-apple-system',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppThemes.darkSecondaryLabel : AppThemes.lightSecondaryLabel,
                        fontFamily: '-apple-system',
                      ),
                    ),
                  ],
                ),
              ),
              
              if (showArrow)
                Icon(
                  CupertinoIcons.chevron_right,
                  color: isDark ? AppThemes.darkTertiaryLabel : AppThemes.lightTertiaryLabel,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text(
            'Đăng xuất',
            style: TextStyle(
              fontFamily: '-apple-system',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?',
            style: TextStyle(
              fontFamily: '-apple-system',
            ),
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text(
                'Hủy',
                style: TextStyle(
                  color: AppThemes.primaryGreen,
                  fontFamily: '-apple-system',
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text(
                'Đăng xuất',
                style: TextStyle(
                  fontFamily: '-apple-system',
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
            ),
          ],
        );
      },
    );
  }
}