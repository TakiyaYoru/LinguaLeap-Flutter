import 'package:flutter/material.dart';
import '../network/learnmap_service.dart';
import '../theme/app_themes.dart';
import 'dart:convert'; // Added for jsonDecode

class LessonDetailPage extends StatefulWidget {
  final String lessonId;
  final String unitId;
  final String lessonTitle;
  final int currentHearts;
  final Function(int) onHeartsChanged;
  final Function(String, String, String) onLessonCompleted;

  const LessonDetailPage({
    Key? key,
    required this.lessonId,
    required this.unitId,
    required this.lessonTitle,
    required this.currentHearts,
    required this.onHeartsChanged,
    required this.onLessonCompleted,
  }) : super(key: key);

  @override
  State<LessonDetailPage> createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends State<LessonDetailPage> 
    with TickerProviderStateMixin { // Added for animations
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
        _updateProgress(); // Update progress animation
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

  void _handleAnswer(int selectedAnswer) {
    if (isLessonCompleted) return;

    final exercise = exercises[currentExerciseIndex];
    final exerciseId = exercise['_id'];
    final isCorrect = _checkAnswer(exercise, selectedAnswer);
    
    print('🔄 [LessonDetailPage] Handling answer for exercise: $exerciseId, selected: $selectedAnswer, correct: $isCorrect');

    if (isCorrect) {
      // Đáp án đúng
      _markExerciseCompleted(exerciseId, 100);
      _showCorrectAnswerDialog();
    } else {
      // Đáp án sai - mất heart
      setState(() {
        hearts--;
      });
      widget.onHeartsChanged(hearts);

      if (hearts <= 0) {
        _showNoHeartsDialog();
      } else {
        _markExerciseWrong(exerciseId, selectedAnswer);
        _showWrongAnswerDialog();
      }
    }
  }

  bool _checkAnswer(Map<String, dynamic> exercise, int selectedAnswer) {
    final type = exercise['type'];
    
    switch (type) {
      case 'multiple_choice':
        // Parse content từ JSON string
        final contentString = exercise['content'] as String?;
        if (contentString != null) {
          try {
            final content = jsonDecode(contentString) as Map<String, dynamic>;
            if (content['correctAnswer'] != null) {
              return selectedAnswer == content['correctAnswer'];
            }
          } catch (e) {
            print('❌ Error parsing content JSON: $e');
          }
        }
        // Fallback: kiểm tra trong question text
        final questionText = exercise['question']['text'] as String?;
        if (questionText != null) {
          // Tạm thời hardcode cho demo, sau này sẽ parse từ content
          return selectedAnswer == 0; // Giả sử đáp án đầu tiên là đúng
        }
        break;
      case 'fill_blank':
        // Logic cho fill blank
        return selectedAnswer == 0; // Tạm thời
      default:
        return selectedAnswer == 0; // Tạm thời
    }
    
    return false;
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

  Future<void> _markExerciseWrong(String exerciseId, int wrongAnswer) async {
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
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppThemes.primaryGreen,
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 32),
            SizedBox(width: 12),
            Text('Correct!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          correctMessage,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _nextExercise();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppThemes.primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('CONTINUE', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showWrongAnswerDialog() {
    final exercise = exercises[currentExerciseIndex];
    final feedback = exercise['feedback'] as Map<String, dynamic>?;
    final incorrectMessage = feedback?['incorrect'] ?? 'Chưa đúng, hãy thử lại!';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppThemes.hearts,
        title: const Row(
          children: [
            Icon(Icons.cancel, color: Colors.white, size: 32),
            SizedBox(width: 12),
            Text('Wrong!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          incorrectMessage,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Đưa câu hỏi về cuối để làm lại
              final wrongExercise = exercises.removeAt(currentExerciseIndex);
              exercises.add(wrongExercise);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppThemes.hearts,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('TRY AGAIN', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
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
      hearts = 5; // Tạm thời reset về 5
    });
    widget.onHeartsChanged(hearts);
  }

  void _nextExercise() {
    if (currentExerciseIndex < exercises.length - 1) {
      setState(() {
        currentExerciseIndex++;
      });
      _updateProgress(); // Update progress animation
    } else {
      // Kiểm tra xem tất cả exercises đã completed chưa
      if (completedExercises.length == exercises.length) {
        _completeLesson();
      } else {
        // Còn exercises chưa completed, tiếp tục
        setState(() {
          currentExerciseIndex = 0; // Quay về đầu
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

    // Gọi callback để cập nhật progress
    widget.onLessonCompleted(widget.unitId, widget.lessonId, 'completed');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppThemes.lightBackground,
        title: Column(
          children: [
            Text(
              'Lesson completed!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppThemes.primaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            // Character illustration
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppThemes.primaryGreen, AppThemes.primaryGreenLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.celebration,
                color: Colors.white,
                size: 40,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Diamonds section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppThemes.systemBlue, AppThemes.systemIndigo],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.diamond, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    'Diamonds',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const Text(
                    '12',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Stats row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppThemes.xp, AppThemes.systemOrange],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Total XP',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.flash_on, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            const Text(
                              '24',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppThemes.primaryGreen, AppThemes.primaryGreenLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Time',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.timer, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            const Text(
                              '1:45',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppThemes.hearts, AppThemes.systemRed],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Accuracy',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.track_changes, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            const Text(
                              '87%',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemes.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'CONTINUE',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseWidget() {
    if (currentExerciseIndex >= exercises.length) {
      return const Center(child: Text('Không có câu hỏi nào'));
    }

    final exercise = exercises[currentExerciseIndex];
    final type = exercise['type'];
    final question = exercise['question']['text'] as String? ?? 'Câu hỏi';
    
    // Parse content từ JSON string
    List<dynamic> options = [];
    try {
      final contentString = exercise['content'] as String?;
      if (contentString != null) {
        final content = jsonDecode(contentString) as Map<String, dynamic>;
        options = content['options'] as List<dynamic>? ?? [];
      }
    } catch (e) {
      print('❌ Error parsing content JSON: $e');
      options = [];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question Design
        const Text(
          'Translate this sentence',
          style: TextStyle(
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
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppThemes.lightLabel,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Options Design
        Expanded(
          child: ListView.builder(
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index].toString();
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Material(
                  borderRadius: BorderRadius.circular(16),
                  elevation: 0,
                  child: InkWell(
                    onTap: () => _handleAnswer(index),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppThemes.lightBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppThemes.systemGray4, width: 2),
                      ),
                      child: Text(
                        option,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppThemes.lightLabel,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            },
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