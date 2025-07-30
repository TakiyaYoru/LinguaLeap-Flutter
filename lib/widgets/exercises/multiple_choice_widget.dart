import 'package:flutter/material.dart';
import '../../theme/app_themes.dart';

class MultipleChoiceWidget extends StatefulWidget {
  final Map<String, dynamic> content;
  final Map<String, dynamic> question;
  final Function(dynamic) onAnswerSubmitted;
  final Map<String, dynamic>? controllerState;

  const MultipleChoiceWidget({
    Key? key,
    required this.content,
    required this.question,
    required this.onAnswerSubmitted,
    this.controllerState,
  }) : super(key: key);

  @override
  State<MultipleChoiceWidget> createState() => _MultipleChoiceWidgetState();
}

class _MultipleChoiceWidgetState extends State<MultipleChoiceWidget> {
  List<dynamic> options = [];
  int? selectedOptionIndex;

  @override
  void initState() {
    super.initState();
    options = widget.content['options'] as List<dynamic>? ?? [];
    
    // Restore state if available
    if (widget.controllerState != null) {
      selectedOptionIndex = widget.controllerState!['selectedOptionIndex'];
    }
  }

  void _handleOptionSelected(int index) {
    setState(() {
      selectedOptionIndex = index;
    });
    widget.onAnswerSubmitted(index);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index].toString();
        final optionLetter = String.fromCharCode(65 + index); // A, B, C, D...
        final isSelected = selectedOptionIndex == index;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            borderRadius: BorderRadius.circular(16),
            elevation: isSelected ? 4 : 2,
            child: InkWell(
              onTap: () => _handleOptionSelected(index),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSelected 
                    ? AppThemes.primaryGreen.withOpacity(0.1)
                    : AppThemes.lightBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected 
                      ? AppThemes.primaryGreen 
                      : AppThemes.systemGray4, 
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Option letter circle
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected 
                          ? AppThemes.primaryGreen
                          : AppThemes.primaryGreen.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected 
                            ? AppThemes.primaryGreen
                            : AppThemes.primaryGreen.withOpacity(0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          optionLetter,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected 
                              ? Colors.white
                              : AppThemes.primaryGreen,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Option text
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isSelected 
                            ? AppThemes.primaryGreen
                            : AppThemes.lightLabel,
                          height: 1.4,
                        ),
                      ),
                    ),
                    // Selection indicator
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: AppThemes.primaryGreen,
                        size: 24,
                      )
                    else
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppThemes.systemGray4,
                        size: 16,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 