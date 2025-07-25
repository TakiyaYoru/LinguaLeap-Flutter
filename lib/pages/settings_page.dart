// lib/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../network/auth_service.dart';
import '../theme/theme_manager.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  // ✅ ENHANCED: Logout with proper cache clearing
  Future<void> _logout(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Show loading indicator
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      try {
        // ✅ ENHANCED: Use AuthService.logout() which includes cache reset
        await AuthService.logout(context);
      } catch (e) {
        // Handle any logout errors
        print('❌ Logout error: $e');
        if (context.mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi đăng xuất: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showThemeDialog(BuildContext context) {
    final themeManager = context.read<ThemeManager>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn giao diện'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Sáng'),
              value: ThemeMode.light,
              groupValue: themeManager.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeManager.setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Tối'),
              value: ThemeMode.dark,
              groupValue: themeManager.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeManager.setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Theo hệ thống'),
              value: ThemeMode.system,
              groupValue: themeManager.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeManager.setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = context.watch<ThemeManager>();
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Cài đặt'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account Section
          _buildSectionHeader('Tài khoản'),
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: 'Thông tin cá nhân',
            subtitle: 'Quản lý thông tin tài khoản',
            onTap: () {
              // Navigate to profile edit
              context.push('/profile');
            },
          ),
          _buildSettingsTile(
            icon: Icons.security,
            title: 'Bảo mật',
            subtitle: 'Mật khẩu và xác thực',
            onTap: () {
              // Navigate to security settings
            },
          ),
          
          const SizedBox(height: 20),
          
          // Appearance Section
          _buildSectionHeader('Giao diện'),
          _buildSettingsTile(
            icon: Icons.palette_outlined,
            title: 'Chủ đề',
            subtitle: _getThemeText(themeManager.themeMode),
            onTap: () => _showThemeDialog(context),
          ),
          _buildSettingsTile(
            icon: Icons.language,
            title: 'Ngôn ngữ',
            subtitle: 'Tiếng Việt',
            onTap: () {
              // Navigate to language settings
            },
          ),
          
          const SizedBox(height: 20),
          
          // Learning Section
          _buildSectionHeader('Học tập'),
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Thông báo',
            subtitle: 'Nhắc nhở học tập hàng ngày',
            onTap: () {
              // Navigate to notification settings
            },
          ),
          _buildSettingsTile(
            icon: Icons.backup_outlined,
            title: 'Sao lưu dữ liệu',
            subtitle: 'Đồng bộ tiến trình học tập',
            onTap: () {
              // Navigate to backup settings
            },
          ),
          
          const SizedBox(height: 20),
          
          // Support Section
          _buildSectionHeader('Hỗ trợ'),
          _buildSettingsTile(
            icon: Icons.help_outline,
            title: 'Trợ giúp',
            subtitle: 'FAQ và hướng dẫn sử dụng',
            onTap: () {
              // Navigate to help
            },
          ),
          _buildSettingsTile(
            icon: Icons.feedback_outlined,
            title: 'Phản hồi',
            subtitle: 'Góp ý cải thiện ứng dụng',
            onTap: () {
              // Navigate to feedback
            },
          ),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'Về LinguaLeap',
            subtitle: 'Phiên bản 1.0.0',
            onTap: () {
              // Show about dialog
            },
          ),
          
          const SizedBox(height: 30),
          
          // Logout Button
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton.icon(
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.logout),
              label: const Text(
                'Đăng xuất',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  String _getThemeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Sáng';
      case ThemeMode.dark:
        return 'Tối';
      case ThemeMode.system:
        return 'Theo hệ thống';
    }
  }
}