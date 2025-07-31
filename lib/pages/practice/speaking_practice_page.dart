// lib/pages/practice/speaking_practice_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_themes.dart';
import '../../network/exercise_service.dart';
import '../../models/exercise_model.dart';

class SpeakingPracticePage extends StatefulWidget {
  const SpeakingPracticePage({Key? key}) : super(key: key);

  @override
  State<SpeakingPracticePage> createState() => _SpeakingPracticePageState();
}

class _SpeakingPracticePageState extends State<SpeakingPracticePage> {
  List<ExerciseModel> exercises = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadSpeakingExercises();
  }

  Future<void> _loadSpeakingExercises() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final result = await ExerciseService.getSpeakingExercises();
      
      if (result != null) {
        setState(() {
          exercises = result;
          isLoading = false;
        });
        print('✅ [SpeakingPracticePage] Loaded ${exercises.length} speaking exercises');
      } else {
        setState(() {
          error = 'Không thể tải danh sách bài tập speaking';
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ [SpeakingPracticePage] Error loading speaking exercises: $e');
      setState(() {
        error = 'Lỗi: $e';
        isLoading = false;
      });
    }
  }

  void _openSpeakingExercise(String exerciseId) {
    print('🎤 [SpeakingPracticePage] Opening speaking exercise: $exerciseId');
    context.push('/speaking-exercise/$exerciseId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.lightGroupedBackground,
      appBar: AppBar(
        backgroundColor: AppThemes.lightSecondaryBackground,
        elevation: 0,
        title: const Text(
          'Luyện nói',
          style: TextStyle(
            color: AppThemes.lightLabel,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppThemes.lightLabel),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadSpeakingExercises,
        child: _buildBody(),
      ),
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
              'Đang tải bài tập speaking...',
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
              onPressed: _loadSpeakingExercises,
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

    if (exercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mic_off,
              size: 64,
              color: AppThemes.speaking.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có bài tập speaking nào',
              style: TextStyle(
                color: AppThemes.lightLabel,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hãy thử lại sau hoặc liên hệ admin',
              style: TextStyle(
                color: AppThemes.lightSecondaryLabel,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return _buildExerciseCard(exercise, index);
      },
    );
  }

  Widget _buildExerciseCard(ExerciseModel exercise, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openSpeakingExercise(exercise.id),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with number and type
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppThemes.speaking,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bài tập ${index + 1}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppThemes.lightLabel,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.mic,
                                size: 16,
                                color: AppThemes.speaking,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Speaking Exercise',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppThemes.speaking,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppThemes.lightSecondaryLabel,
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Exercise content preview
                if (exercise.title != null && exercise.title!.isNotEmpty) ...[
                  Text(
                    exercise.title!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppThemes.lightLabel,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                
                // Instruction preview
                if (exercise.instruction.isNotEmpty) ...[
                  Text(
                    exercise.instruction,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppThemes.lightSecondaryLabel,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Exercise details
                Row(
                  children: [
                    _buildDetailChip(
                      Icons.timer,
                      '${exercise.estimatedTime}s',
                      AppThemes.lightSecondaryLabel,
                    ),
                    const SizedBox(width: 8),
                    _buildDetailChip(
                      Icons.star,
                      '${exercise.xpReward} XP',
                      AppThemes.primaryGreen,
                    ),
                    const SizedBox(width: 8),
                    _buildDetailChip(
                      Icons.signal_cellular_alt,
                      exercise.difficulty,
                      _getDifficultyColor(exercise.difficulty),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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