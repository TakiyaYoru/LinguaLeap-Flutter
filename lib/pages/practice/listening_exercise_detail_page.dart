// lib/pages/practice/listening_exercise_detail_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../models/exercise_model.dart';
import '../../network/exercise_service.dart';
import '../../theme/app_themes.dart';

class ListeningExerciseDetailPage extends StatefulWidget {
  final String exerciseId;
  
  const ListeningExerciseDetailPage({
    Key? key,
    required this.exerciseId,
  }) : super(key: key);

  @override
  State<ListeningExerciseDetailPage> createState() => _ListeningExerciseDetailPageState();
}

class _ListeningExerciseDetailPageState extends State<ListeningExerciseDetailPage> {
  ExerciseModel? exercise;
  bool isLoading = true;
  String? error;
  AudioPlayer? audioPlayer;
  bool isPlaying = false;
  bool isAudioReady = false;
  String? selectedAnswer;
  bool hasAnswered = false;
  bool isCorrect = false;

  @override
  void initState() {
    super.initState();
    _loadExercise();
    _initAudioPlayer();
  }

  @override
  void dispose() {
    audioPlayer?.dispose();
    super.dispose();
  }

  void _initAudioPlayer() {
    audioPlayer = AudioPlayer();
    audioPlayer!.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });
    
    audioPlayer!.onPlayerComplete.listen((_) {
      setState(() {
        isPlaying = false;
      });
    });
  }

  Future<void> _loadExercise() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      print('🎧 [ListeningExerciseDetailPage] Loading exercise: ${widget.exerciseId}');
      
      final exerciseData = await ExerciseService.getUserExercise(widget.exerciseId);
      
      if (exerciseData == null) {
        throw Exception('Exercise not found');
      }

      setState(() {
        exercise = exerciseData;
        isLoading = false;
      });

      print('✅ [ListeningExerciseDetailPage] Exercise loaded: ${exercise?.title}');
      
      // Prepare audio if available
      if (exercise?.content['audioUrl'] != null) {
        _prepareAudio();
      }
    } catch (e) {
      print('❌ [ListeningExerciseDetailPage] Error loading exercise: $e');
      setState(() {
        error = 'Lỗi khi tải bài nghe: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _prepareAudio() async {
    if (exercise?.content['audioUrl'] == null) return;
    
    try {
      await audioPlayer?.setSourceUrl(exercise!.content['audioUrl']);
      setState(() {
        isAudioReady = true;
      });
      print('✅ Audio prepared successfully');
    } catch (e) {
      print('❌ Error preparing audio: $e');
    }
  }

  void _toggleAudio() async {
    if (!isAudioReady) return;

    try {
      if (isPlaying) {
        await audioPlayer?.pause();
      } else {
        await audioPlayer?.resume();
      }
    } catch (e) {
      print('❌ Error playing audio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi phát audio: $e'),
          backgroundColor: AppThemes.systemOrange,
        ),
      );
    }
  }

  void _selectAnswer(String answer) {
    if (hasAnswered) return;
    
    setState(() {
      selectedAnswer = answer;
    });
  }

  void _submitAnswer() {
    if (selectedAnswer == null) return;
    
    // Debug: Print exercise content to understand the data structure
    print('🔍 [ListeningExerciseDetailPage] Debug exercise content:');
    print('  - Selected answer: $selectedAnswer');
    print('  - Exercise content: ${exercise?.content}');
    print('  - Exercise question text: ${exercise?.question.text}');
    
    // Get options list
    final options = exercise?.content['options'] as List<dynamic>? ?? [];
    print('  - Options: $options');
    
    // Find the index of selected answer
    int? selectedIndex;
    for (int i = 0; i < options.length; i++) {
      if (options[i].toString() == selectedAnswer) {
        selectedIndex = i;
        break;
      }
    }
    print('  - Selected index: $selectedIndex');
    
    // Try different possible locations for correct answer in content
    String? correctAnswer;
    
    // Check in content['correctAnswer']
    if (exercise?.content['correctAnswer'] != null) {
      correctAnswer = exercise!.content['correctAnswer'].toString();
      print('  - Found correctAnswer in content: $correctAnswer');
    }
    // Check in content['answer']
    else if (exercise?.content['answer'] != null) {
      correctAnswer = exercise!.content['answer'].toString();
      print('  - Found answer in content: $correctAnswer');
    }
    // Check in content['correct_answer']
    else if (exercise?.content['correct_answer'] != null) {
      correctAnswer = exercise!.content['correct_answer'].toString();
      print('  - Found correct_answer in content: $correctAnswer');
    }
    // Check in content['rightAnswer']
    else if (exercise?.content['rightAnswer'] != null) {
      correctAnswer = exercise!.content['rightAnswer'].toString();
      print('  - Found rightAnswer in content: $correctAnswer');
    }
    // Check if options contain the correct answer (first option as fallback)
    else if (options.isNotEmpty) {
      correctAnswer = options[0].toString();
      print('  - Using first option as fallback: $correctAnswer');
    }
    
    // Check if answer is correct (both text and index comparison)
    bool isAnswerCorrect = false;
    
    if (correctAnswer != null) {
      // Try to parse correctAnswer as index
      int? correctIndex;
      try {
        correctIndex = int.tryParse(correctAnswer);
      } catch (e) {
        correctIndex = null;
      }
      
      print('  - Correct answer: $correctAnswer');
      print('  - Correct index: $correctIndex');
      
      if (correctIndex != null && selectedIndex != null) {
        // Compare by index
        isAnswerCorrect = selectedIndex == correctIndex;
        print('  - Comparing by index: $selectedIndex == $correctIndex = $isAnswerCorrect');
      } else {
        // Compare by text
        isAnswerCorrect = selectedAnswer == correctAnswer;
        print('  - Comparing by text: "$selectedAnswer" == "$correctAnswer" = $isAnswerCorrect');
      }
    }
    
    print('  - Final result: $isAnswerCorrect');
    
    setState(() {
      hasAnswered = true;
      isCorrect = isAnswerCorrect;
    });
    
    _showResultDialog(isAnswerCorrect, correctAnswer, selectedIndex, options);
  }

  void _showResultDialog(bool isCorrect, String? correctAnswer, int? selectedIndex, List<dynamic> options) {
    String displayCorrectAnswer = 'Không có đáp án';
    
    if (correctAnswer != null) {
      // Try to parse correctAnswer as index
      int? correctIndex;
      try {
        correctIndex = int.tryParse(correctAnswer);
      } catch (e) {
        correctIndex = null;
      }
      
      if (correctIndex != null && correctIndex < options.length) {
        // Show the text of the correct option
        displayCorrectAnswer = options[correctIndex].toString();
      } else {
        // Show the correct answer as is
        displayCorrectAnswer = correctAnswer;
      }
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
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: isCorrect ? AppThemes.primaryGreen : AppThemes.systemOrange,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              isCorrect ? 'Chính xác!' : 'Chưa đúng',
              style: TextStyle(
                color: isCorrect ? AppThemes.primaryGreen : AppThemes.systemOrange,
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
              isCorrect 
                ? 'Bạn đã trả lời đúng!'
                : 'Đáp án đúng là: $displayCorrectAnswer',
              style: TextStyle(
                fontSize: 16,
                color: AppThemes.lightLabel,
              ),
            ),
            if (!isCorrect && exercise?.content['explanation'] != null) ...[
              const SizedBox(height: 12),
              Text(
                'Giải thích:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppThemes.lightSecondaryLabel,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                exercise!.content['explanation'],
                style: TextStyle(
                  fontSize: 14,
                  color: AppThemes.lightSecondaryLabel,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop(); // Go back to listening practice page
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
          exercise?.title ?? 'Bài nghe',
          style: const TextStyle(
            color: AppThemes.lightLabel,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppThemes.lightLabel),
          onPressed: () => context.pop(),
        ),
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
              'Đang tải bài nghe...',
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
          'Không tìm thấy bài nghe',
          style: TextStyle(
            color: AppThemes.lightSecondaryLabel,
            fontSize: 16,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          _buildHeaderCard(),
          const SizedBox(height: 16),
          
          // Audio player card
          if (exercise!.content['audioUrl'] != null) ...[
            _buildAudioCard(),
            const SizedBox(height: 16),
          ],
          
          // Question card
          _buildQuestionCard(),
          const SizedBox(height: 16),
          
          // Answer options card
          _buildAnswerOptionsCard(),
          const SizedBox(height: 24),
          
          // Submit button
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppThemes.listening.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.headphones,
                  color: AppThemes.listening,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise!.title ?? 'Bài nghe',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppThemes.lightLabel,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Listening Exercise',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppThemes.lightSecondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (exercise!.instruction.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              exercise!.instruction,
              style: const TextStyle(
                fontSize: 16,
                color: AppThemes.lightLabel,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAudioCard() {
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
                Icons.audiotrack,
                color: AppThemes.listening,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Audio',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppThemes.lightLabel,
                ),
              ),
              const Spacer(),
              if (!isAudioReady)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppThemes.listening),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isAudioReady ? _toggleAudio : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppThemes.listening,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: AppThemes.lightSecondaryBackground,
                    disabledForegroundColor: AppThemes.lightSecondaryLabel,
                  ),
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 24,
                  ),
                  label: Text(
                    isPlaying ? 'Tạm dừng' : 'Phát audio',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (exercise!.content['transcription'] != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppThemes.listening.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppThemes.listening.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.text_snippet,
                        size: 16,
                        color: AppThemes.listening,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Transcription',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppThemes.listening,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exercise!.content['transcription'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppThemes.lightLabel,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
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
              const Text(
                'Câu hỏi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppThemes.lightLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (exercise!.content['question'] != null)
            Text(
              exercise!.content['question'],
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
    final options = exercise?.content['options'] as List<dynamic>? ?? [];
    
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
            final option = entry.value.toString();
            final optionLetter = String.fromCharCode(65 + index); // A, B, C, D...
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: hasAnswered ? null : () => _selectAnswer(option),
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

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: selectedAnswer != null && !hasAnswered ? _submitAnswer : null,
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
          hasAnswered ? 'Đã trả lời' : 'Trả lời',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
} 