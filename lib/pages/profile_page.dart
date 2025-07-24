// lib/features/profile/presentation/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../network/auth_service.dart';
import '../models/user_model.dart';
import '../theme/app_themes.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final userdata = await AuthService.getCurrentUser();
      if (userdata != null) {
        setState(() {
          user = UserModel.fromJson(userdata);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.lightGroupedBackground,
      appBar: AppBar(
        backgroundColor: AppThemes.lightSecondaryBackground,
        title: const Text(
          'Hồ sơ',
          style: TextStyle(color: AppThemes.lightLabel),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: AppThemes.primaryGreen),
            onPressed: _openSettings,
            tooltip: 'Cài đặt',
          ),
        ],
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _buildProfile(),
    );
  }
  
  Widget _buildProfile() {
    if (user == null) {
      return const Center(
        child: Text('Unable to load profile'),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Profile header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
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
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppThemes.primaryGreen.withOpacity(0.2),
                  child: Text(
                    user!.displayName.isNotEmpty
                        ? user!.displayName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppThemes.primaryGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user!.displayName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppThemes.lightLabel,
                  ),
                ),
                Text(
                  '@${user!.username}',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppThemes.lightSecondaryLabel,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Level', user!.currentLevel, AppThemes.systemBlue),
                    _buildStatItem('XP', '${user!.totalXP}', AppThemes.xp),
                    _buildStatItem('Hearts', '${user!.hearts}/5', AppThemes.hearts),
                    _buildStatItem('Streak', '${user!.currentStreak}', AppThemes.streak),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Options
          Container(
            width: double.infinity,
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
                const Text(
                  'Cài đặt & Tùy chọn',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppThemes.lightLabel,
                  ),
                ),
                const SizedBox(height: 16),
                _buildOptionItem(
                  icon: Icons.settings,
                  title: 'Cài đặt',
                  onTap: _openSettings,
                ),
                const SizedBox(height: 12),
                _buildOptionItem(
                  icon: Icons.emoji_events,
                  title: 'Thành tích',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tính năng đang phát triển')),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildOptionItem(
                  icon: Icons.schedule,
                  title: 'Lịch sử học tập',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tính năng đang phát triển')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Account info
          Container(
            width: double.infinity,
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
                const Text(
                  'Thông tin tài khoản',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppThemes.lightLabel,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow('Email', user!.email),
                _buildInfoRow(
                    'Subscription', user!.subscriptionType.toUpperCase()),
                _buildInfoRow('Status', user!.isActive ? 'Active' : 'Inactive'),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppThemes.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppThemes.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppThemes.lightLabel,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppThemes.lightSecondaryLabel,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: AppThemes.lightSecondaryLabel,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppThemes.lightLabel,
            ),
          ),
        ],
      ),
    );
  }
}