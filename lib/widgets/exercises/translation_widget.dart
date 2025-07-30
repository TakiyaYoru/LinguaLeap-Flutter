import 'package:flutter/material.dart';
import '../../theme/app_themes.dart';

class TranslationWidget extends StatefulWidget {
  final Map<String, dynamic> content;
  final Map<String, dynamic> question;
  final Function(dynamic) onAnswerSubmitted;
  final Map<String, dynamic>? controllerState;

  const TranslationWidget({
    Key? key,
    required this.content,
    required this.question,
    required this.onAnswerSubmitted,
    this.controllerState,
  }) : super(key: key);

  @override
  State<TranslationWidget> createState() => _TranslationWidgetState();
}

class _TranslationWidgetState extends State<TranslationWidget> {
  final TextEditingController _translationController = TextEditingController();
  String? sourceText;
  String? targetText;

  @override
  void initState() {
    super.initState();
    sourceText = widget.content['sourceText'] as String? ?? '';
    targetText = widget.content['targetText'] as String?;
    
    // Restore state if available
    if (widget.controllerState != null) {
      _translationController.text = widget.controllerState!['userAnswer'] ?? '';
    }
  }

  @override
  void dispose() {
    _translationController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final answer = _translationController.text.trim();
    if (answer.isNotEmpty) {
      widget.onAnswerSubmitted(answer);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Source text display with enhanced styling
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppThemes.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppThemes.primaryGreen.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.translate, color: AppThemes.primaryGreen, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Dịch câu sau:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppThemes.primaryGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                sourceText ?? '',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppThemes.lightLabel,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Translation input field with enhanced styling
        TextFormField(
          controller: _translationController,
          onFieldSubmitted: (value) => _handleSubmit(),
          decoration: InputDecoration(
            labelText: 'Bản dịch tiếng Việt',
            hintText: 'Nhập bản dịch của bạn...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppThemes.systemGray4),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppThemes.systemGray4),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppThemes.primaryGreen, width: 2),
            ),
            filled: true,
            fillColor: AppThemes.lightBackground,
            prefixIcon: Icon(Icons.edit, color: AppThemes.primaryGreen),
          ),
          maxLines: 3,
          style: const TextStyle(
            fontSize: 16,
            color: AppThemes.lightLabel,
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Submit button with enhanced styling
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _handleSubmit,
            icon: const Icon(Icons.check_circle_outline, size: 20),
            label: const Text(
              'Kiểm tra đáp án',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemes.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }
} 