// lib/pages/practice/random_practice_session.dart
import 'package:flutter/material.dart';
import '../../models/exercise_model.dart';
import '../../theme/app_themes.dart';

import '../../widgets/exercises/multiple_choice_widget.dart';
import '../../widgets/exercises/true_false_widget.dart';
import '../../widgets/exercises/fill_blank_widget.dart';
import '../../widgets/exercises/translation_widget.dart';
import '../../widgets/dialogs/correct_answer_dialog.dart';
import '../../widgets/dialogs/wrong_answer_dialog.dart';

class RandomPracticeSession extends StatefulWidget {
  final List<ExerciseModel> exercises;
  final Function(bool allCorrect, int totalExercises) onCompleted;

  const RandomPracticeSession({
    Key? key,
    required this.exercises,
    required this.onCompleted,
  }) : super(key: key);

  @override
  State<RandomPracticeSession> createState() => _RandomPracticeSessionState();
}

class _RandomPracticeSessionState extends State<RandomPracticeSession> {
  int currentExerciseIndex = 0;
  int correctAnswers = 0;
  bool isCompleted = false;
  List<bool> exerciseResults = [];

  @override
  void initState() {
    super.initState();
    exerciseResults = List.filled(widget.exercises.length, false);
  }

  void _onExerciseCompleted(dynamic answer) {
    final currentExercise = widget.exercises[currentExerciseIndex];
    final isCorrect = _checkAnswer(currentExercise, answer);
    
    setState(() {
      exerciseResults[currentExerciseIndex] = isCorrect;
      if (isCorrect) {
        correctAnswers++;
      }
    });

    // Show result dialog
    _showResultDialog(isCorrect, currentExercise);
  }

  bool _checkAnswer(ExerciseModel exercise, dynamic answer) {
    try {
      switch (exercise.type) {
        case 'multiple_choice':
          final correctAnswer = exercise.content['correctAnswer'] as int? ?? 0;
          return answer == correctAnswer;
        
        case 'true_false':
          final correctAnswer = exercise.content['correctAnswer'] as bool? ?? true;
          return answer == correctAnswer;
        
        case 'fill_blank':
          final correctAnswers = (exercise.content['correctAnswers'] as List<dynamic>? ?? [])
              .map((e) => e.toString().toLowerCase().trim())
              .toList();
          final userAnswer = answer.toString().toLowerCase().trim();
          return correctAnswers.contains(userAnswer);
        
        case 'translation':
          final correctAnswers = (exercise.content['correctAnswers'] as List<dynamic>? ?? [])
              .map((e) => e.toString().toLowerCase().trim())
              .toList();
          final userAnswer = answer.toString().toLowerCase().trim();
          return correctAnswers.contains(userAnswer);
        
        default:
          return true; // Default to correct for unknown types
      }
    } catch (e) {
      print('❌ Error checking answer: $e');
      return true; // Default to correct on error
    }
  }

  void _showResultDialog(bool isCorrect, ExerciseModel exercise) {
    if (isCorrect) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => CorrectAnswerDialog(
          correctMessage: exercise.feedback?.correct ?? 'Chính xác! Bạn đã trả lời đúng.',
          hintMessage: exercise.feedback?.hint,
          onContinue: () {
            Navigator.of(context).pop(); // Close dialog
            _moveToNextExercise();
          },
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WrongAnswerDialog(
          incorrectMessage: '${exercise.feedback?.incorrect ?? 'Chưa chính xác!'}\n\nĐáp án đúng: ${_getCorrectAnswerText(exercise)}',
          hintMessage: exercise.feedback?.hint,
          onRetry: () {
            Navigator.of(context).pop(); // Close dialog
            _moveToNextExercise(); // Always move to next exercise after answering
          },
        ),
      );
    }
  }

  String _getCorrectAnswerText(ExerciseModel exercise) {
    try {
      switch (exercise.type) {
        case 'multiple_choice':
          final correctIndex = exercise.content['correctAnswer'] as int? ?? 0;
          final options = exercise.content['options'] as List<dynamic>? ?? [];
          if (correctIndex < options.length) {
            return options[correctIndex].toString();
          }
          return 'Option ${String.fromCharCode(65 + correctIndex)}';
        
        case 'true_false':
          final correctAnswer = exercise.content['correctAnswer'] as bool? ?? true;
          return correctAnswer ? 'True' : 'False';
        
        case 'fill_blank':
        case 'translation':
          final correctAnswers = (exercise.content['correctAnswers'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList();
          return correctAnswers.join(', ');
        
        default:
          return 'Không có đáp án';
      }
    } catch (e) {
      return 'Không có đáp án';
    }
  }

  void _moveToNextExercise() {
    // Move to next exercise or complete session
    if (currentExerciseIndex < widget.exercises.length - 1) {
      setState(() {
        currentExerciseIndex++;
      });
    } else {
      _completeSession();
    }
  }

  void _completeSession() {
    setState(() {
      isCompleted = true;
    });

    final allCorrect = correctAnswers == widget.exercises.length;
    widget.onCompleted(allCorrect, widget.exercises.length);
  }

  void _skipExercise() {
    _onExerciseCompleted(false);
  }

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return _buildCompletionScreen();
    }

    final currentExercise = widget.exercises[currentExerciseIndex];
    final progress = (currentExerciseIndex + 1) / widget.exercises.length;

    return Scaffold(
      backgroundColor: AppThemes.lightGroupedBackground,
      appBar: AppBar(
        backgroundColor: AppThemes.lightSecondaryBackground,
        title: Text(
          'Luyện tập (${currentExerciseIndex + 1}/${widget.exercises.length})',
          style: const TextStyle(color: AppThemes.lightLabel),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppThemes.lightLabel),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _skipExercise,
            child: Text(
              'Bỏ qua',
              style: TextStyle(color: AppThemes.systemOrange),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          Container(
            width: double.infinity,
            height: 4,
            color: Colors.grey.shade200,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                color: AppThemes.primaryGreen,
              ),
            ),
          ),

          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Bài ${currentExerciseIndex + 1}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppThemes.lightLabel,
                  ),
                ),
                const Spacer(),
                Text(
                  'Đúng: $correctAnswers',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppThemes.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Exercise content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildExerciseWidget(currentExercise),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen() {
    final allCorrect = correctAnswers == widget.exercises.length;
    final accuracy = (correctAnswers / widget.exercises.length) * 100;

    return Scaffold(
      backgroundColor: AppThemes.lightGroupedBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Result icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: allCorrect 
                      ? AppThemes.primaryGreen.withOpacity(0.1)
                      : AppThemes.systemOrange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  allCorrect ? Icons.celebration : Icons.emoji_events,
                  size: 60,
                  color: allCorrect ? AppThemes.primaryGreen : AppThemes.systemOrange,
                ),
              ),

              const SizedBox(height: 32),

              // Result title
              Text(
                allCorrect ? 'Hoàn thành xuất sắc!' : 'Hoàn thành!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppThemes.lightLabel,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Result details
              Text(
                'Đúng $correctAnswers/${widget.exercises.length} bài (${accuracy.round()}%)',
                style: TextStyle(
                  fontSize: 18,
                  color: AppThemes.lightSecondaryLabel,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Rewards
              if (allCorrect) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppThemes.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppThemes.primaryGreen.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bolt, color: AppThemes.primaryGreen, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        '+5 XP',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppThemes.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Icon(Icons.diamond, color: AppThemes.systemIndigo, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        '+5 Diamonds',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppThemes.systemIndigo,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Action buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppThemes.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Quay lại',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // Restart practice
                    setState(() {
                      currentExerciseIndex = 0;
                      correctAnswers = 0;
                      isCompleted = false;
                      exerciseResults = List.filled(widget.exercises.length, false);
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppThemes.primaryGreen,
                    side: BorderSide(color: AppThemes.primaryGreen),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Luyện tập lại',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseWidget(ExerciseModel exercise) {
    print('🎯 Building exercise widget for type: ${exercise.type}');
    print('   Title: ${exercise.title}');
    print('   Content: ${exercise.content}');
    
    // Build the appropriate exercise widget based on type
    Widget exerciseWidget;
    
    try {
      switch (exercise.type) {
        case 'multiple_choice':
          exerciseWidget = MultipleChoiceWidget(
            content: exercise.content,
            question: exercise.question.toJson(),
            onAnswerSubmitted: _onExerciseCompleted,
            controllerState: null,
          );
          break;
        
        case 'true_false':
          exerciseWidget = TrueFalseWidget(
            content: exercise.content,
            question: exercise.question.toJson(),
            onAnswerSubmitted: _onExerciseCompleted,
            controllerState: null,
          );
          break;
        
        case 'fill_blank':
          exerciseWidget = FillBlankWidget(
            content: exercise.content,
            question: exercise.question.toJson(),
            onAnswerSubmitted: _onExerciseCompleted,
            controllerState: null,
          );
          break;
        
        case 'translation':
          exerciseWidget = TranslationWidget(
            content: exercise.content,
            question: exercise.question.toJson(),
            onAnswerSubmitted: _onExerciseCompleted,
            controllerState: null,
          );
          break;
        
        case 'listening':
        case 'speaking':
          // Skip listening and speaking exercises for now
          exerciseWidget = _buildFallbackWidget(exercise);
          break;
        
        default:
          exerciseWidget = _buildFallbackWidget(exercise);
      }
    } catch (e) {
      print('❌ Error building exercise widget: $e');
      exerciseWidget = _buildFallbackWidget(exercise);
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise title
          Text(
            exercise.title ?? 'Exercise ${currentExerciseIndex + 1}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppThemes.lightLabel,
            ),
          ),
          const SizedBox(height: 16),
          
          // Exercise type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppThemes.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              exercise.type.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppThemes.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Exercise widget - Wrap in Container with fixed height and unique key
          Container(
            height: 300, // Fixed height to avoid layout issues
            child: exerciseWidget,
            key: ValueKey('exercise_${currentExerciseIndex}_${exercise.id}'),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackWidget(ExerciseModel exercise) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise title
          Text(
            exercise.title ?? 'Exercise ${currentExerciseIndex + 1}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppThemes.lightLabel,
            ),
          ),
          const SizedBox(height: 16),
          
          // Exercise type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppThemes.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              exercise.type.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppThemes.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Exercise content display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (exercise.type == 'listening') ...[
                  Text(
                    '🎧 Listening Exercise',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppThemes.lightLabel,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (exercise.content['question'] != null) ...[
                    Text(
                      'Question: ${exercise.content['question']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppThemes.lightLabel,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (exercise.content['transcription'] != null) ...[
                    Text(
                      'Audio: ${exercise.content['transcription']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppThemes.lightSecondaryLabel,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (exercise.content['options'] != null) ...[
                    Text(
                      'Options: ${exercise.content['options'].join(', ')}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppThemes.lightSecondaryLabel,
                      ),
                    ),
                  ],
                ] else if (exercise.type == 'speaking') ...[
                  Text(
                    '🎤 Speaking Exercise',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppThemes.lightLabel,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Practice speaking exercise',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppThemes.lightSecondaryLabel,
                    ),
                  ),
                ] else ...[
                  Text(
                    'Exercise Content:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppThemes.lightLabel,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exercise.content.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppThemes.lightSecondaryLabel,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _onExerciseCompleted(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppThemes.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Đúng',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _onExerciseCompleted(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppThemes.systemOrange,
                    side: BorderSide(color: AppThemes.systemOrange),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Sai',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 