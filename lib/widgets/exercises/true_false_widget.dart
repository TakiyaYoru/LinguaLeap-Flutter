import 'package:flutter/material.dart';
import '../../theme/app_themes.dart';

class TrueFalseWidget extends StatefulWidget {
  final Map<String, dynamic> content;
  final Map<String, dynamic> question;
  final Function(dynamic) onAnswerSubmitted;
  final Map<String, dynamic>? controllerState;

  const TrueFalseWidget({
    Key? key,
    required this.content,
    required this.question,
    required this.onAnswerSubmitted,
    this.controllerState,
  }) : super(key: key);

  @override
  State<TrueFalseWidget> createState() => _TrueFalseWidgetState();
}

class _TrueFalseWidgetState extends State<TrueFalseWidget> {
  String? statement;
  bool? isTrue;
  bool? selectedAnswer;

  @override
  void initState() {
    super.initState();
    statement = widget.content['statement'] as String? ?? '';
    isTrue = widget.content['isTrue'] as bool?;
    
    // Restore state if available
    if (widget.controllerState != null) {
      selectedAnswer = widget.controllerState!['selectedAnswer'];
    }
  }

  void _handleAnswer(bool answer) {
    setState(() {
      selectedAnswer = answer;
    });
    widget.onAnswerSubmitted(answer);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Statement display with enhanced styling
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
                  Icon(Icons.quiz, color: AppThemes.primaryGreen, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Đọc câu và chọn đúng/sai:',
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
                statement ?? '',
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
        
        const SizedBox(height: 32),
        
        // True/False buttons with enhanced styling
        Row(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                child: Material(
                  borderRadius: BorderRadius.circular(16),
                  elevation: selectedAnswer == true ? 4 : 2,
                  child: InkWell(
                    onTap: () => _handleAnswer(true),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: selectedAnswer == true 
                          ? Colors.green.withOpacity(0.2)
                          : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selectedAnswer == true 
                            ? Colors.green 
                            : Colors.green.withOpacity(0.3), 
                          width: selectedAnswer == true ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            selectedAnswer == true 
                              ? Icons.check_circle 
                              : Icons.check_circle_outline, 
                            color: Colors.green, 
                            size: 24
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ĐÚNG',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 8),
                child: Material(
                  borderRadius: BorderRadius.circular(16),
                  elevation: selectedAnswer == false ? 4 : 2,
                  child: InkWell(
                    onTap: () => _handleAnswer(false),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: selectedAnswer == false 
                          ? Colors.red.withOpacity(0.2)
                          : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selectedAnswer == false 
                            ? Colors.red 
                            : Colors.red.withOpacity(0.3), 
                          width: selectedAnswer == false ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            selectedAnswer == false 
                              ? Icons.cancel 
                              : Icons.cancel_outlined, 
                            color: Colors.red, 
                            size: 24
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'SAI',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
} 