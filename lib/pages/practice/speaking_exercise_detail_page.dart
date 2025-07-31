// lib/pages/practice/speaking_exercise_detail_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_themes.dart';
import '../../network/exercise_service.dart';
import '../../models/exercise_model.dart';
import '../../widgets/exercises/speaking_widget.dart';
import '../../network/gamification_service.dart';

class SpeakingExerciseDetailPage extends StatefulWidget {
  final String exerciseId;

  const SpeakingExerciseDetailPage({
    Key? key,
    required this.exerciseId,
  }) : super(key: key);

  @override
  State<SpeakingExerciseDetailPage> createState() => _SpeakingExerciseDetailPageState();
}

class _SpeakingExerciseDetailPageState extends State<SpeakingExerciseDetailPage> {
  ExerciseModel? exercise;
  bool isLoading = true;
  String? error;
  bool isCompleted = false;

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

      final result = await ExerciseService.getExerciseById(widget.exerciseId);
      
      if (result != null) {
        setState(() {
          exercise = result;
          isLoading = false;
        });
        print('✅ [SpeakingExerciseDetailPage] Exercise loaded: ${exercise?.id}');
      } else {
        setState(() {
          error = 'Không thể tải bài tập speaking';
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ [SpeakingExerciseDetailPage] Error loading exercise: $e');
      setState(() {
        error = 'Lỗi: $e';
        isLoading = false;
      });
    }
  }

  void _onAnswerSubmitted(dynamic result) {
    print('🎤 [SpeakingExerciseDetailPage] Answer submitted: $result');
    
    if (result is Map<String, dynamic>) {
      final isCorrect = result['isCorrect'] as bool? ?? false;
      final accuracyScore = result['accuracyScore'] as double? ?? 0.0;
      final recognizedText = result['recognizedText'] as String? ?? '';
      final feedback = result['feedback'] as String? ?? '';
      
      print('🎤 [SpeakingExerciseDetailPage] Result details:');
      print('  - isCorrect: $isCorrect');
      print('  - accuracyScore: $accuracyScore');
      print('  - recognizedText: $recognizedText');
      print('  - feedback: $feedback');
      
      if (isCorrect || accuracyScore >= 0.7) {
        _completeExercise();
      }
    }
  }

  Future<void> _completeExercise() async {
    if (isCompleted) return;
    
    try {
      setState(() {
        isCompleted = true;
      });
      
      // Award rewards
      await _awardSpeakingRewards();
      
      // Show completion dialog
      _showCompletionDialog();
      
    } catch (e) {
      print('❌ [SpeakingExerciseDetailPage] Error completing exercise: $e');
    }
  }

  Future<void> _awardSpeakingRewards() async {
    try {
      final result = await GamificationService.awardSpeakingRewards();
      if (result != null && result.success) {
        print('✅ [SpeakingExerciseDetailPage] Rewards awarded:');
        print('  - XP: ${result.xpAwarded}');
        print('  - Diamonds: ${result.diamondsAwarded}');
      }
    } catch (e) {
      print('❌ [SpeakingExerciseDetailPage] Error awarding rewards: $e');
    }
  }

  void _showCompletionDialog() {
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
              Icons.check_circle,
              color: AppThemes.primaryGreen,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Hoàn thành!',
              style: TextStyle(
                color: AppThemes.lightLabel,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chúc mừng! Bạn đã hoàn thành bài tập speaking.',
              style: TextStyle(
                color: AppThemes.lightLabel,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppThemes.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppThemes.primaryGreen.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star,
                    color: AppThemes.primaryGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '+15 XP và +15 💎',
                    style: TextStyle(
                      color: AppThemes.primaryGreen,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop(); // Go back to practice page
            },
            child: const Text(
              'Tiếp tục',
              style: TextStyle(
                color: AppThemes.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
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
          exercise?.title ?? 'Bài tập Speaking',
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
          if (isCompleted)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppThemes.primaryGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Hoàn thành',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
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
              'Đang tải bài tập...',
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              error!,
              style: const TextStyle(
                color: AppThemes.lightLabel,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadExercise,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemes.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (exercise == null) {
      return const Center(
        child: Text(
          'Không tìm thấy bài tập',
          style: TextStyle(
            color: AppThemes.lightLabel,
            fontSize: 16,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Exercise info card
          Container(
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
                // Title
                if (exercise!.title != null && exercise!.title!.isNotEmpty) ...[
                  Text(
                    exercise!.title!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppThemes.lightLabel,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Instruction
                if (exercise!.instruction.isNotEmpty) ...[
                  Text(
                    exercise!.instruction,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppThemes.lightLabel,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Exercise details
                Row(
                  children: [
                    _buildDetailChip(
                      Icons.timer,
                      '${exercise!.estimatedTime}s',
                      AppThemes.lightSecondaryLabel,
                    ),
                    const SizedBox(width: 8),
                    _buildDetailChip(
                      Icons.star,
                      '${exercise!.xpReward} XP',
                      AppThemes.primaryGreen,
                    ),
                    const SizedBox(width: 8),
                    _buildDetailChip(
                      Icons.signal_cellular_alt,
                      exercise!.difficulty,
                      _getDifficultyColor(exercise!.difficulty),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Speaking widget
          Container(
            width: double.infinity,
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
            child: SpeakingWidget(
              content: _parseExerciseContent(exercise!),
              question: _parseExerciseQuestion(exercise!),
              onAnswerSubmitted: _onAnswerSubmitted,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _parseExerciseContent(ExerciseModel exercise) {
    try {
      // ExerciseModel.content is already a Map<String, dynamic>
      // Just return it directly or create a fallback
      if (exercise.content.isNotEmpty) {
        return exercise.content;
      } else {
        // If content is empty, create basic structure
        return {
          'sentence': exercise.instruction,
          'instruction': exercise.instruction,
          'audio_text': exercise.instruction,
          'audioUrl': null,
        };
      }
    } catch (e) {
      print('❌ [SpeakingExerciseDetailPage] Error parsing content: $e');
      // If parsing fails, create a basic content structure
      return {
        'sentence': exercise.instruction,
        'instruction': exercise.instruction,
        'audio_text': exercise.instruction,
        'audioUrl': null,
      };
    }
  }

  Map<String, dynamic> _parseExerciseQuestion(ExerciseModel exercise) {
    try {
      // Convert ExerciseQuestion object to Map
      return {
        'text': exercise.question.text.isNotEmpty ? exercise.question.text : exercise.instruction,
        'audioUrl': exercise.question.audioUrl,
        'imageUrl': exercise.question.imageUrl,
        'videoUrl': exercise.question.videoUrl,
      };
    } catch (e) {
      print('❌ [SpeakingExerciseDetailPage] Error parsing question: $e');
      // If parsing fails, create a basic question structure
      return {
        'text': exercise.instruction,
      };
    }
  }

  Widget _buildDetailChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return AppThemes.lightSecondaryLabel;
    }
  }
} 