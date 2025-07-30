import 'package:flutter/material.dart';
import '../network/learnmap_service.dart';
import '../theme/app_themes.dart';
import '../widgets/exercises/exercise_widget_factory.dart';
import '../widgets/dialogs/correct_answer_dialog.dart';
import '../widgets/dialogs/wrong_answer_dialog.dart';
import '../widgets/dialogs/lesson_completion_dialog.dart';
import 'dart:convert';

class LessonDetailPageRefactored extends StatefulWidget {
  final String lessonId;
  final String unitId;
  final String lessonTitle;
  final int currentHearts;
  final Function(int) onHeartsChanged;
  final Function(String, String, String) onLessonCompleted;

  const LessonDetailPageRefactored({
    Key? key,
    required this.lessonId,
    required this.unitId,
    required this.lessonTitle,
    required this.currentHearts,
    required this.onHeartsChanged,
    required this.onLessonCompleted,
  }) : super(key: key);

  @override
  State<LessonDetailPageRefactored> createState() => _LessonDetailPageRefactoredState();
}

class _LessonDetailPageRefactoredState extends State<LessonDetailPageRefactored> 
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> exercises = [];
  int currentExerciseIndex = 0;
  late int hearts;
  bool isLoading = true;
  String? error;
  bool isLessonCompleted = false;
  Set<String> completedExercises = {};

  // Animation controllers for enhanced UI
  late AnimationController _progressAnimationController;
  late AnimationController _feedbackController;
  late Animation<double> _progressAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    hearts = widget.currentHearts;
    
    // Initialize animations
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _feedbackController,
      curve: Curves.easeOut,
    ));
    
    _loadExercises();
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _updateProgress() {
    if (exercises.isNotEmpty) {
      final progress = (currentExerciseIndex + 1) / exercises.length;
      _progressAnimationController.animateTo(progress);
    }
  }

  Future<void> _loadExercises() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      print('🔄 Loading exercises for lesson: ${widget.lessonId}');
      final exercisesData = await LearnmapService.getExercisesByLesson(widget.lessonId);
      
      if (exercisesData != null) {
        setState(() {
          exercises = exercisesData;
          isLoading = false;
        });
        _updateProgress();
        print('✅ Loaded ${exercises.length} exercises');
      } else {
        setState(() {
          error = 'Không thể tải bài tập';
          isLoading = false;
        });
        print('❌ Failed to load exercises');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
      print('❌ Error loading exercises: $e');
    }
  }

  void _handleAnswerSubmitted(dynamic userAnswer) {
    if (isLessonCompleted) return;

    final exercise = exercises[currentExerciseIndex];
    final exerciseId = exercise['_id'];
    final isCorrect = _checkAnswer(exercise, userAnswer);
    
    print('🔄 [LessonDetailPage] Handling answer for exercise: $exerciseId, correct: $isCorrect');

    if (isCorrect) {
      _markExerciseCompleted(exerciseId, 100);
      _showCorrectAnswerDialog();
    } else {
      setState(() {
        hearts--;
      });
      widget.onHeartsChanged(hearts);

      if (hearts <= 0) {
        _showNoHeartsDialog();
      } else {
        _markExerciseWrong(exerciseId, userAnswer);
        _showWrongAnswerDialog();
      }
    }
  }

  bool _checkAnswer(Map<String, dynamic> exercise, dynamic userAnswer) {
    final type = exercise['type'];
    
    switch (type) {
      case 'multiple_choice':
        try {
          final content = jsonDecode(exercise['content'] as String) as Map<String, dynamic>;
          if (content['correctAnswer'] != null) {
            return userAnswer == content['correctAnswer'];
          }
        } catch (e) {
          print('❌ Error parsing content JSON: $e');
        }
        return false;
        
      case 'fill_blank':
        try {
          final content = jsonDecode(exercise['content'] as String);
          final correctAnswer = content['correctAnswer'] as String?;
          final alternatives = content['alternatives'] as List<dynamic>? ?? [];
          final userAnswerStr = userAnswer.toString().toLowerCase().trim();
          
          if (correctAnswer != null) {
            if (userAnswerStr == correctAnswer.toLowerCase().trim()) {
              return true;
            }
            for (final alternative in alternatives) {
              if (userAnswerStr == alternative.toString().toLowerCase().trim()) {
                return true;
              }
            }
          }
        } catch (e) {
          print('❌ Error parsing fill_blank content: $e');
        }
        return false;
        
      case 'true_false':
        try {
          final content = jsonDecode(exercise['content'] as String);
          final isTrue = content['isTrue'] as bool?;
          return userAnswer == isTrue;
        } catch (e) {
          print('❌ Error parsing true_false content: $e');
        }
        return false;
        
      case 'translation':
        try {
          final content = jsonDecode(exercise['content'] as String);
          final targetText = content['targetText'] as String?;
          final userAnswerStr = userAnswer.toString().toLowerCase().trim();
          
          if (targetText != null) {
            return userAnswerStr == targetText.toLowerCase().trim();
          }
        } catch (e) {
          print('❌ Error parsing translation content: $e');
        }
        return false;
        
      case 'word_matching':
        try {
          final content = jsonDecode(exercise['content'] as String);
          final pairs = content['pairs'] as List<dynamic>? ?? [];
          final selections = userAnswer as Map<int, String>;
          
          if (selections.length == pairs.length) {
            for (int i = 0; i < pairs.length; i++) {
              final pair = pairs[i];
              final correctMeaning = pair['meaning'] as String;
              final selectedMeaning = selections[i];
              
              if (selectedMeaning != correctMeaning) {
                return false;
              }
            }
            return true;
          }
        } catch (e) {
          print('❌ Error parsing word_matching content: $e');
        }
        return false;
        
      default:
        return false;
    }
  }

  Future<void> _markExerciseCompleted(String exerciseId, int score) async {
    try {
      print('🔄 [LessonDetailPage] Calling updateExerciseProgress for exercise: $exerciseId');
      final result = await LearnmapService.updateExerciseProgress(widget.lessonId, {
        'exerciseId': exerciseId,
        'status': 'COMPLETED',
        'score': score,
        'attempts': 1,
      });

      if (result != null) {
        setState(() {
          completedExercises.add(exerciseId);
        });
        print('✅ Exercise marked as completed: $exerciseId');
        print('📊 Completed exercises: ${completedExercises.length}/${exercises.length}');
      } else {
        print('❌ updateExerciseProgress returned null');
      }
    } catch (e) {
      print('❌ Error marking exercise completed: $e');
    }
  }

  Future<void> _markExerciseWrong(String exerciseId, dynamic wrongAnswer) async {
    try {
      final result = await LearnmapService.updateExerciseProgress(widget.lessonId, {
        'exerciseId': exerciseId,
        'status': 'IN_PROGRESS',
        'score': 0,
        'attempts': 1,
        'wrongAnswers': [wrongAnswer.toString()],
      });

      if (result != null) {
        print('❌ Exercise marked as wrong: $exerciseId');
      }
    } catch (e) {
      print('❌ Error marking exercise wrong: $e');
    }
  }

  void _showCorrectAnswerDialog() {
    final exercise = exercises[currentExerciseIndex];
    final feedback = exercise['feedback'] as Map<String, dynamic>?;
    final correctMessage = feedback?['correct'] ?? 'Đúng rồi!';
    final hintMessage = feedback?['hint'] ?? '';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CorrectAnswerDialog(
        correctMessage: correctMessage,
        hintMessage: hintMessage,
        onContinue: () {
          Navigator.of(context).pop();
          _nextExercise();
        },
      ),
    );
  }

  void _showWrongAnswerDialog() {
    final exercise = exercises[currentExerciseIndex];
    final feedback = exercise['feedback'] as Map<String, dynamic>?;
    final incorrectMessage = feedback?['incorrect'] ?? 'Chưa đúng, hãy thử lại!';
    final hintMessage = feedback?['hint'] ?? '';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WrongAnswerDialog(
        incorrectMessage: incorrectMessage,
        hintMessage: hintMessage,
        onRetry: () {
          Navigator.of(context).pop();
          // Move wrong exercise to end to retry
          final wrongExercise = exercises.removeAt(currentExerciseIndex);
          exercises.add(wrongExercise);
        },
      ),
    );
  }

  void _showNoHeartsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppThemes.lightBackground,
        title: Row(
          children: [
            Icon(Icons.favorite_border, color: AppThemes.hearts, size: 32),
            const SizedBox(width: 12),
            Text('No Hearts Left!', style: TextStyle(color: AppThemes.lightLabel)),
          ],
        ),
        content: Text(
          'You\'ve run out of hearts. Purchase more hearts or wait for them to refill.',
          style: TextStyle(color: AppThemes.lightSecondaryLabel),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _buyHearts();
            },
            child: Text('GET HEARTS', style: TextStyle(color: AppThemes.primaryGreen)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppThemes.primaryGreen),
            child: const Text('CLOSE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _buyHearts() {
    setState(() {
      hearts = 5; // Temporary reset to 5
    });
    widget.onHeartsChanged(hearts);
  }

  void _nextExercise() {
    if (currentExerciseIndex < exercises.length - 1) {
      setState(() {
        currentExerciseIndex++;
      });
      _updateProgress();
    } else {
      if (completedExercises.length == exercises.length) {
        _completeLesson();
      } else {
        setState(() {
          currentExerciseIndex = 0; // Go back to start
        });
        _updateProgress();
      }
    }
  }

  void _completeLesson() {
    setState(() {
      isLessonCompleted = true;
    });

    print('🎉 [LessonDetailPage] Lesson completed! Unit: ${widget.unitId}, Lesson: ${widget.lessonId}');
    print('🎉 [LessonDetailPage] Completed exercises: ${completedExercises.length}/${exercises.length}');

    widget.onLessonCompleted(widget.unitId, widget.lessonId, 'completed');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LessonCompletionDialog(
        onContinue: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _buildExerciseWidget() {
    if (currentExerciseIndex >= exercises.length) {
      return const Center(child: Text('Không có câu hỏi nào'));
    }

    final exercise = exercises[currentExerciseIndex];
    final type = exercise['type'];
    final question = exercise['question'] as Map<String, dynamic>? ?? {};
    
    // Parse content from JSON string
    Map<String, dynamic> content = {};
    try {
      final contentString = exercise['content'] as String?;
      if (contentString != null) {
        content = jsonDecode(contentString) as Map<String, dynamic>;
      }
    } catch (e) {
      print('❌ Error parsing content JSON: $e');
      content = {};
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question Design
        Text(
          type == 'fill_blank' ? 'Fill in the blank' : 
          type == 'true_false' ? 'True or False' : 
          type == 'translation' ? 'Translate to Vietnamese' :
          type == 'word_matching' ? 'Match words with meanings' :
          'Choose the correct answer',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppThemes.lightLabel,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Audio sentence
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppThemes.lightBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppThemes.systemGray4),
          ),
          child: Row(
            children: [
              if (type != 'fill_blank') ...[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppThemes.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.volume_up,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Text(
                  question['text'] as String? ?? 'Câu hỏi',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppThemes.lightLabel,
                  ),
                  textAlign: type == 'fill_blank' ? TextAlign.center : TextAlign.start,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Exercise widget using factory
        Expanded(
          child: ExerciseWidgetFactory.createExerciseWidget(
            type: type,
            content: content,
            question: question,
            onAnswerSubmitted: _handleAnswerSubmitted,
            controllerState: null, // TODO: Implement state restoration
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced Top Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  // Close button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(Icons.close, size: 24, color: AppThemes.lightSecondaryLabel),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Enhanced Progress bar
                  Expanded(
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppThemes.systemGray5,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: exercises.isNotEmpty
                          ? AnimatedBuilder(
                              animation: _progressAnimation,
                              builder: (context, child) {
                                return FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: _progressAnimation.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppThemes.primaryGreen,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                );
                              },
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Enhanced Hearts indicator
                  Row(
                    children: List.generate(5, (index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 4),
                        child: Icon(
                          index < hearts ? Icons.favorite : Icons.favorite_border,
                          color: index < hearts ? AppThemes.hearts : AppThemes.systemGray3,
                          size: 20,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppThemes.primaryGreen),
                          const SizedBox(height: 16),
                          Text(
                            'Loading exercises...', 
                            style: TextStyle(color: AppThemes.lightSecondaryLabel)
                          ),
                        ],
                      ),
                    )
                  : error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 64, color: AppThemes.hearts),
                              const SizedBox(height: 16),
                              Text('Error: $error', textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadExercises,
                                style: ElevatedButton.styleFrom(backgroundColor: AppThemes.primaryGreen),
                                child: const Text('Try Again', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        )
                      : isLessonCompleted
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: AppThemes.primaryGreen,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.celebration,
                                      color: Colors.white,
                                      size: 60,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Lesson Complete!',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: AppThemes.primaryGreen,
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  SizedBox(
                                    width: 200,
                                    child: ElevatedButton.icon(
                                      onPressed: () => Navigator.of(context).pop(),
                                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                                      label: const Text(
                                        'Back to Map',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppThemes.primaryGreen,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(20),
                              child: _buildExerciseWidget(),
                            ),
            ),
          ],
        ),
      ),
    );
  }
} 