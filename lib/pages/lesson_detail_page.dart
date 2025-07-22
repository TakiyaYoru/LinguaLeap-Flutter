import 'package:flutter/material.dart';
import '../network/learnmap_service.dart';
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

class _LessonDetailPageState extends State<LessonDetailPage> {
  List<Map<String, dynamic>> exercises = [];
  int currentExerciseIndex = 0;
  late int hearts;
  bool isLoading = true;
  String? error;
  bool isLessonCompleted = false;
  Set<String> completedExercises = {};

  @override
  void initState() {
    super.initState();
    hearts = widget.currentHearts;
    _loadExercises();
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
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Đúng rồi!'),
          ],
        ),
        content: Text(correctMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _nextExercise();
            },
            child: const Text('Tiếp tục'),
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
        title: const Row(
          children: [
            Icon(Icons.cancel, color: Colors.red),
            SizedBox(width: 8),
            Text('Chưa đúng'),
          ],
        ),
        content: Text(incorrectMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Đưa câu hỏi về cuối để làm lại
              final wrongExercise = exercises.removeAt(currentExerciseIndex);
              exercises.add(wrongExercise);
            },
            child: const Text('Thử lại'),
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
        title: const Row(
          children: [
            Icon(Icons.favorite_border, color: Colors.red),
            SizedBox(width: 8),
            Text('Hết hearts'),
          ],
        ),
        content: const Text('Bạn đã hết hearts. Hãy mua thêm hoặc chờ hồi phục.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _buyHearts();
            },
            child: const Text('Mua hearts'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Đóng'),
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
    } else {
      // Kiểm tra xem tất cả exercises đã completed chưa
      if (completedExercises.length == exercises.length) {
        _completeLesson();
      } else {
        // Còn exercises chưa completed, tiếp tục
        setState(() {
          currentExerciseIndex = 0; // Quay về đầu
        });
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
    if (widget.onLessonCompleted != null) {
      widget.onLessonCompleted(widget.unitId, widget.lessonId, 'completed');
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.orange),
            SizedBox(width: 8),
            Text('Chúc mừng!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Bạn đã hoàn thành lesson này!'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Icon(Icons.star, color: Colors.yellow, size: 32),
                    const Text('+50 XP'),
                  ],
                ),
                Column(
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.orange, size: 32),
                    const Text('+10 Coins'),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Chỉ pop dialog, không pop page
              Navigator.of(context).pop();
            },
            child: const Text('Hoàn thành'),
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
        // Question
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.purple[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple[200]!),
          ),
          child: Text(
            question,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Options
        ...options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value.toString();
          
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            child: ElevatedButton(
              onPressed: () => _handleAnswer(index),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Text(
                option,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.left,
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lessonTitle),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
        actions: [
          // Hearts indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.favorite, color: Colors.red),
                const SizedBox(width: 4),
                Text(
                  '$hearts',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Lỗi: $error'),
                      ElevatedButton(
                        onPressed: _loadExercises,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : isLessonCompleted
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 64),
                          const SizedBox(height: 16),
                          const Text(
                            'Lesson đã hoàn thành!',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Quay về Learnmap'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Progress indicator
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: LinearProgressIndicator(
                            value: (currentExerciseIndex + 1) / exercises.length,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[600]!),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Câu hỏi ${currentExerciseIndex + 1}/${exercises.length}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Exercise content
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: _buildExerciseWidget(),
                          ),
                        ),
                      ],
                    ),
    );
  }
} 