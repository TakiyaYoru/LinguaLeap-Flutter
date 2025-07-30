import 'package:flutter/material.dart';
import '../../theme/app_themes.dart';

class CorrectAnswerDialog extends StatelessWidget {
  final String correctMessage;
  final String? hintMessage;
  final VoidCallback onContinue;

  const CorrectAnswerDialog({
    Key? key,
    required this.correctMessage,
    this.hintMessage,
    required this.onContinue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      title: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppThemes.primaryGreen,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 32),
            SizedBox(width: 12),
            Text(
              'Chính xác! 🎉',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            correctMessage,
            style: const TextStyle(color: AppThemes.lightLabel, fontSize: 16, height: 1.4),
          ),
          if (hintMessage != null && hintMessage!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppThemes.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppThemes.primaryGreen.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: AppThemes.primaryGreen, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hintMessage!,
                      style: TextStyle(
                        color: AppThemes.primaryGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onContinue,
            icon: const Icon(Icons.arrow_forward, size: 20),
            label: const Text(
              'Tiếp tục',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemes.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }
} 