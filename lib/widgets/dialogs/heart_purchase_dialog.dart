// ===============================================
// HEART PURCHASE DIALOG - LINGUALEAP
// ===============================================

import 'package:flutter/material.dart';
import '../../theme/app_themes.dart';
import '../../network/gamification_service.dart';

class HeartPurchaseDialog extends StatefulWidget {
  final int currentDiamonds;
  final int currentHearts;
  final VoidCallback? onHeartsPurchased;

  const HeartPurchaseDialog({
    super.key,
    required this.currentDiamonds,
    required this.currentHearts,
    this.onHeartsPurchased,
  });

  @override
  State<HeartPurchaseDialog> createState() => _HeartPurchaseDialogState();
}

class _HeartPurchaseDialogState extends State<HeartPurchaseDialog> {
  bool isLoading = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppThemes.lightBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppThemes.hearts.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.favorite,
                    color: AppThemes.hearts,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Hết hearts rồi!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppThemes.lightLabel,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Current stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppThemes.lightGroupedBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Hearts', '${widget.currentHearts}/5', AppThemes.hearts),
                  _buildStatItem('Diamonds', '${widget.currentDiamonds}', AppThemes.systemIndigo),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Options
            const Text(
              'Chọn cách lấy thêm hearts:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppThemes.lightLabel,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Buy hearts option
            _buildPurchaseOption(
              title: 'Mua 1 heart',
              subtitle: 'Giá: 20 diamonds',
              icon: Icons.favorite,
              color: AppThemes.hearts,
              onTap: () => _buyHearts(1),
            ),
            
            const SizedBox(height: 12),
            
            // Refill hearts option
            _buildPurchaseOption(
              title: 'Làm đầy hearts',
              subtitle: 'Giá: ${(5 - widget.currentHearts) * 10} diamonds',
              icon: Icons.refresh,
              color: AppThemes.systemBlue,
              onTap: _refillHearts,
            ),
            
            const SizedBox(height: 20),
            
            // Error message
            if (errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  errorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            
            const SizedBox(height: 20),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Để sau',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppThemes.lightSecondaryLabel,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _waitForRefill,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemes.systemBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Chờ refill',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppThemes.lightSecondaryLabel,
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
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
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppThemes.lightSecondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppThemes.lightSecondaryLabel,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _buyHearts(int heartCount) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final result = await GamificationService.buyHearts(heartCount);
      
      if (result != null && result['success'] == true) {
        if (mounted) {
          Navigator.of(context).pop();
          widget.onHeartsPurchased?.call();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Mua hearts thành công!'),
              backgroundColor: AppThemes.primaryGreen,
            ),
          );
        }
      } else {
        setState(() {
          errorMessage = result?['message'] ?? 'Có lỗi xảy ra';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Không đủ diamonds hoặc có lỗi xảy ra';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refillHearts() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final result = await GamificationService.refillHearts();
      
      if (result != null && result['success'] == true) {
        if (mounted) {
          Navigator.of(context).pop();
          widget.onHeartsPurchased?.call();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Làm đầy hearts thành công!'),
              backgroundColor: AppThemes.primaryGreen,
            ),
          );
        }
      } else {
        setState(() {
          errorMessage = result?['message'] ?? 'Có lỗi xảy ra';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Không đủ diamonds hoặc có lỗi xảy ra';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _waitForRefill() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hearts sẽ tự động refill sau 30 phút'),
        backgroundColor: AppThemes.systemBlue,
      ),
    );
  }
} 