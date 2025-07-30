import 'package:flutter/material.dart';
import '../../theme/app_themes.dart';

class WrongAnswerDialog extends StatelessWidget {
  final String incorrectMessage;
  final String? hintMessage;
  final VoidCallback onRetry;

  const WrongAnswerDialog({
    Key? key,
    required this.incorrectMessage,
    this.hintMessage,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      title: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppThemes.hearts,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel, color: Colors.white, size: 32),
            SizedBox(width: 12),
            Text(
              'Chưa đúng! 💪',
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
            incorrectMessage,
            style: const TextStyle(color: AppThemes.lightLabel, fontSize: 16, height: 1.4),
          ),
          if (hintMessage != null && hintMessage!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppThemes.hearts.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppThemes.hearts.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: AppThemes.hearts, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hintMessage!,
                      style: TextStyle(
                        color: AppThemes.hearts,
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
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text(
              'Thử lại',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemes.hearts,
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