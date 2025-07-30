import 'package:flutter/material.dart';
import 'multiple_choice_widget.dart';
import 'fill_blank_widget.dart';
import 'true_false_widget.dart';
import 'translation_widget.dart';
import 'word_matching_widget.dart';

class ExerciseWidgetFactory {
  static Widget createExerciseWidget({
    required String type,
    required Map<String, dynamic> content,
    required Map<String, dynamic> question,
    required Function(dynamic) onAnswerSubmitted,
    required Map<String, dynamic>? controllerState,
  }) {
    switch (type) {
      case 'multiple_choice':
        return MultipleChoiceWidget(
          content: content,
          question: question,
          onAnswerSubmitted: onAnswerSubmitted,
          controllerState: controllerState,
        );
      
      case 'fill_blank':
        return FillBlankWidget(
          content: content,
          question: question,
          onAnswerSubmitted: onAnswerSubmitted,
          controllerState: controllerState,
        );
      
      case 'true_false':
        return TrueFalseWidget(
          content: content,
          question: question,
          onAnswerSubmitted: onAnswerSubmitted,
          controllerState: controllerState,
        );
      
      case 'translation':
        return TranslationWidget(
          content: content,
          question: question,
          onAnswerSubmitted: onAnswerSubmitted,
          controllerState: controllerState,
        );
      
      case 'word_matching':
        return WordMatchingWidget(
          content: content,
          question: question,
          onAnswerSubmitted: onAnswerSubmitted,
          controllerState: controllerState,
        );
      
      default:
        return Container(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Exercise type "$type" not implemented yet',
            style: const TextStyle(color: Colors.red),
          ),
        );
    }
  }
} 