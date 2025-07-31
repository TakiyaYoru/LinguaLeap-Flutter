// lib/pages/practice/reading_exercise_detail_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/exercise_model.dart';
import '../../network/exercise_service.dart';
import '../../network/gamification_service.dart';
import '../../theme/app_themes.dart';

class ReadingExerciseDetailPage extends StatefulWidget {
  final String exerciseId;
  
  const ReadingExerciseDetailPage({
    Key? key,
    required this.exerciseId,
  }) : super(key: key);

  @override
  State<ReadingExerciseDetailPage> createState() => _ReadingExerciseDetailPageState();
}

class _ReadingExerciseDetailPageState extends State<ReadingExerciseDetailPage> {
  ExerciseModel? exercise;
  bool isLoading = true;
  String? error;
  bool showPassage = true;
  int currentQuestionIndex = 0;
  Map<int, String> userAnswers = {};
  bool _isCompleted = false;
  List<Map<String, dynamic>> questions = [];

  @override
  void initState() {
    super.initState();
    _loadExercise();
  }

  Future<void> _loadExercise() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      print('📖 [ReadingExerciseDetailPage] Loading exercise: ${widget.exerciseId}');
      
      final exerciseData = await ExerciseService.getUserExercise(widget.exerciseId);
      
      if (exerciseData == null) {
        throw Exception('Exercise not found');
      }

      setState(() {
        exercise = exerciseData;
        isLoading = false;
      });

      // Parse questions from content
      _parseQuestions();

      print('✅ [ReadingExerciseDetailPage] Exercise loaded: ${exercise?.title}');
    } catch (e) {
      print('❌ [ReadingExerciseDetailPage] Error loading exercise: $e');
      setState(() {
        error = 'Lỗi khi tải bài đọc: $e';
        isLoading = false;
      });
    }
  }

  void _parseQuestions() {
    if (exercise?.content == null) return;
    
    try {
      final content = exercise!.content;
      
      // Try to get questions from different possible locations
      if (content['questions'] != null) {
        questions = List<Map<String, dynamic>>.from(content['questions']);
      } else if (content['question'] != null) {
        // Single question format
        questions = [Map<String, dynamic>.from(content['question'])];
      }
      
      print('📝 [ReadingExerciseDetailPage] Parsed ${questions.length} questions');
    } catch (e) {
      print('❌ [ReadingExerciseDetailPage] Error parsing questions: $e');
    }
  }

  void _togglePassage() {
    setState(() {
      showPassage = !showPassage;
    });
  }

  void _selectAnswer(String answer) {
    setState(() {
      userAnswers[currentQuestionIndex] = answer;
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      _completeExercise();
    }
  }

  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  void _completeExercise() {
    int correctAnswers = 0;
    
    for (int i = 0; i < questions.length; i++) {
      final userAnswer = userAnswers[i];
      final correctAnswer = questions[i]['correctAnswer'];
      
      if (userAnswer == correctAnswer) {
        correctAnswers++;
      }
    }
    
    final score = (correctAnswers / questions.length * 100).round();
    final exerciseCompleted = correctAnswers >= 3; // Hoàn thành nếu đúng 3/4 câu hỏi
    
    setState(() {
      _isCompleted = true;
    });
    
    // Award rewards if completed (3/4 questions correct)
    if (exerciseCompleted) {
      _awardReadingRewards();
    }
    
    _showCompletionDialog(score, correctAnswers, questions.length, exerciseCompleted);
  }

  Future<void> _awardReadingRewards() async {
    try {
      print('🏆 [ReadingExerciseDetailPage] Awarding reading completion rewards...');
      
      final result = await GamificationService.awardReadingRewards(
        xp: 10,
        diamonds: 10,
      );
      
      print('✅ [ReadingExerciseDetailPage] Rewards awarded: ${result.message}');
      print('  - XP: +${result.xpAwarded}');
      print('  - Diamonds: +${result.diamondsAwarded}');
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Hoàn thành! +10 XP và +10 💎'),
            backgroundColor: AppThemes.primaryGreen,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ [ReadingExerciseDetailPage] Error awarding rewards: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi cập nhật phần thưởng: $e'),
            backgroundColor: AppThemes.systemOrange,
          ),
        );
      }
    }
  }

  void _showCompletionDialog(int score, int correctAnswers, int totalQuestions, bool isCompleted) {
    String performanceText;
    Color performanceColor;
    IconData performanceIcon;
    
    if (isCompleted) {
      // Hoàn thành (3/4 câu hỏi đúng)
      performanceText = "Hoàn thành!";
      performanceColor = AppThemes.primaryGreen;
      performanceIcon = Icons.star;
    } else if (score >= 50) {
      performanceText = "Cần cải thiện!";
      performanceColor = AppThemes.systemOrange;
      performanceIcon = Icons.trending_up;
    } else {
      performanceText = "Cần luyện tập thêm!";
      performanceColor = AppThemes.systemRed;
      performanceIcon = Icons.refresh;
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              performanceIcon,
              color: performanceColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              performanceText,
              style: TextStyle(
                color: performanceColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kết quả: $correctAnswers/$totalQuestions (${score}%)',
              style: const TextStyle(
                fontSize: 16,
                color: AppThemes.lightLabel,
              ),
            ),
            const SizedBox(height: 12),
            if (isCompleted) ...[
              Text(
                '🎉 Chúc mừng! Bạn đã hoàn thành bài đọc!',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppThemes.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Phần thưởng: +10 XP và +10 💎',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppThemes.primaryGreen,
                ),
              ),
            ] else ...[
              Text(
                'Cần trả lời đúng ít nhất 3/4 câu hỏi để hoàn thành',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppThemes.lightSecondaryLabel,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'XP nhận được: ${exercise?.xpReward ?? 5}',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppThemes.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop(); // Go back to reading practice page
            },
            style: TextButton.styleFrom(
              foregroundColor: AppThemes.primaryGreen,
            ),
            child: const Text('Hoàn thành'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.lightGroupedBackground,
      appBar: AppBar(
        backgroundColor: AppThemes.lightSecondaryBackground,
        elevation: 0,
        title: Text(
          exercise?.title ?? 'Bài đọc',
          style: const TextStyle(
            color: AppThemes.lightLabel,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppThemes.lightLabel),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (questions.isNotEmpty)
            IconButton(
              icon: Icon(
                showPassage ? Icons.visibility_off : Icons.visibility,
                color: AppThemes.primaryGreen,
              ),
              onPressed: _togglePassage,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppThemes.primaryGreen),
            ),
            SizedBox(height: 16),
            Text(
              'Đang tải bài đọc...',
              style: TextStyle(
                color: AppThemes.lightSecondaryLabel,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppThemes.systemOrange,
              ),
              const SizedBox(height: 16),
              Text(
                'Có lỗi xảy ra',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppThemes.lightLabel,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error!,
                style: TextStyle(
                  fontSize: 14,
                  color: AppThemes.lightSecondaryLabel,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadExercise,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemes.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (exercise == null) {
      return const Center(
        child: Text(
          'Không tìm thấy bài đọc',
          style: TextStyle(
            color: AppThemes.lightSecondaryLabel,
            fontSize: 16,
          ),
        ),
      );
    }

    return Column(
      children: [
        // Progress indicator
        if (questions.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            color: AppThemes.lightSecondaryBackground,
            child: Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: (currentQuestionIndex + 1) / questions.length,
                    backgroundColor: AppThemes.lightSecondaryBackground,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppThemes.primaryGreen),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${currentQuestionIndex + 1}/${questions.length}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppThemes.lightLabel,
                  ),
                ),
              ],
            ),
          ),
        ],
        
        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reading passage (toggleable)
                if (showPassage && exercise!.content['passage'] != null) ...[
                  _buildPassageCard(),
                  const SizedBox(height: 24),
                ],
                
                // Questions
                if (questions.isNotEmpty) ...[
                  _buildQuestionCard(),
                  const SizedBox(height: 24),
                  _buildAnswerOptionsCard(),
                ] else ...[
                  _buildNoQuestionsCard(),
                ],
              ],
            ),
          ),
        ),
        
        // Navigation buttons
        if (questions.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousQuestion,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Câu trước'),
                    ),
                  ),
                if (currentQuestionIndex > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: userAnswers[currentQuestionIndex] != null ? _nextQuestion : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemes.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: AppThemes.lightSecondaryBackground,
                      disabledForegroundColor: AppThemes.lightSecondaryLabel,
                    ),
                    child: Text(
                      currentQuestionIndex == questions.length - 1 ? 'Hoàn thành' : 'Câu tiếp',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPassageCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.menu_book,
                color: AppThemes.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Bài đọc',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppThemes.lightLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            exercise!.content['passage'],
            style: const TextStyle(
              fontSize: 16,
              color: AppThemes.lightLabel,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    final currentQuestion = questions[currentQuestionIndex];
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.quiz,
                color: AppThemes.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Câu hỏi ${currentQuestionIndex + 1}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppThemes.lightLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            currentQuestion['question'] ?? 'Không có câu hỏi',
            style: const TextStyle(
              fontSize: 16,
              color: AppThemes.lightLabel,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOptionsCard() {
    final currentQuestion = questions[currentQuestionIndex];
    final options = List<String>.from(currentQuestion['options'] ?? []);
    final selectedAnswer = userAnswers[currentQuestionIndex];
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.radio_button_checked,
                color: AppThemes.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Chọn đáp án',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppThemes.lightLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final optionLetter = String.fromCharCode(65 + index); // A, B, C, D...
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => _selectAnswer(option),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: selectedAnswer == option
                        ? AppThemes.primaryGreen.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selectedAnswer == option
                          ? AppThemes.primaryGreen
                          : AppThemes.lightSecondaryBackground,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: selectedAnswer == option
                              ? AppThemes.primaryGreen
                              : AppThemes.lightSecondaryBackground,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            optionLetter,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: selectedAnswer == option
                                  ? Colors.white
                                  : AppThemes.lightSecondaryLabel,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 16,
                            color: selectedAnswer == option
                                ? AppThemes.primaryGreen
                                : AppThemes.lightLabel,
                            fontWeight: selectedAnswer == option
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (selectedAnswer == option)
                        const Icon(
                          Icons.check_circle,
                          color: AppThemes.primaryGreen,
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildNoQuestionsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.quiz,
            size: 48,
            color: AppThemes.lightSecondaryLabel,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có câu hỏi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppThemes.lightLabel,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bài đọc này chưa có câu hỏi để trả lời',
            style: TextStyle(
              fontSize: 14,
              color: AppThemes.lightSecondaryLabel,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 