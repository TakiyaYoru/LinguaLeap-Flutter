import 'package:flutter/material.dart';
import '../../theme/app_themes.dart';

class FillBlankWidget extends StatefulWidget {
  final Map<String, dynamic> content;
  final Map<String, dynamic> question;
  final Function(dynamic) onAnswerSubmitted;
  final Map<String, dynamic>? controllerState;

  const FillBlankWidget({
    Key? key,
    required this.content,
    required this.question,
    required this.onAnswerSubmitted,
    this.controllerState,
  }) : super(key: key);

  @override
  State<FillBlankWidget> createState() => _FillBlankWidgetState();
}

class _FillBlankWidgetState extends State<FillBlankWidget> {
  final TextEditingController _answerController = TextEditingController();
  String? sentence;
  String? correctAnswer;
  List<dynamic> alternatives = [];

  @override
  void initState() {
    super.initState();
    sentence = widget.content['sentence'] as String? ?? '';
    correctAnswer = widget.content['correctAnswer'] as String?;
    alternatives = widget.content['alternatives'] as List<dynamic>? ?? [];
    
    // Restore state if available
    if (widget.controllerState != null) {
      _answerController.text = widget.controllerState!['userAnswer'] ?? '';
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final answer = _answerController.text.trim();
    if (answer.isNotEmpty) {
      widget.onAnswerSubmitted(answer);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sentence with blank - enhanced styling
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
                  Icon(Icons.edit_note, color: AppThemes.primaryGreen, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Điền từ vào chỗ trống:',
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
                sentence ?? '',
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
        
        // Answer input with enhanced styling
        TextFormField(
          controller: _answerController,
          decoration: InputDecoration(
            labelText: 'Đáp án của bạn',
            hintText: 'Nhập từ cần điền...',
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
            prefixIcon: Icon(Icons.keyboard, color: AppThemes.primaryGreen),
          ),
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
          onFieldSubmitted: (answer) {
            if (answer.trim().isNotEmpty) {
              widget.onAnswerSubmitted(answer.trim());
            }
          },
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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