// lib/pages/practice/reading_practice_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/exercise_model.dart';
import '../../network/exercise_service.dart';
import '../../theme/app_themes.dart';

class ReadingPracticePage extends StatefulWidget {
  const ReadingPracticePage({Key? key}) : super(key: key);

  @override
  State<ReadingPracticePage> createState() => _ReadingPracticePageState();
}

class _ReadingPracticePageState extends State<ReadingPracticePage> {
  List<ExerciseModel> readingExercises = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadReadingExercises();
  }

  Future<void> _loadReadingExercises() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      print('📖 [ReadingPracticePage] Loading reading exercises...');
      
      final exercises = await ExerciseService.getReadingExercises();
      
      setState(() {
        readingExercises = exercises;
        isLoading = false;
      });

      print('✅ [ReadingPracticePage] Loaded ${exercises.length} reading exercises');
    } catch (e) {
      print('❌ [ReadingPracticePage] Error loading reading exercises: $e');
      setState(() {
        error = 'Lỗi khi tải danh sách bài đọc: $e';
        isLoading = false;
      });
    }
  }

  void _openReadingExercise(ExerciseModel exercise) {
    print('📖 [ReadingPracticePage] Opening reading exercise: ${exercise.id}');
    context.push('/reading-exercise/${exercise.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.lightGroupedBackground,
      appBar: AppBar(
        backgroundColor: AppThemes.lightSecondaryBackground,
        elevation: 0,
        title: const Text(
          'Luyện đọc',
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
                onPressed: _loadReadingExercises,
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

    if (readingExercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book,
              size: 64,
              color: AppThemes.lightSecondaryLabel,
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có bài đọc nào',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppThemes.lightLabel,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy quay lại sau khi có bài đọc mới',
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: readingExercises.length,
      itemBuilder: (context, index) {
        final exercise = readingExercises[index];
        return _buildReadingExerciseCard(exercise);
      },
    );
  }

  Widget _buildReadingExerciseCard(ExerciseModel exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () => _openReadingExercise(exercise),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppThemes.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.menu_book,
                        color: AppThemes.primaryGreen,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.title ?? 'Bài đọc',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppThemes.lightLabel,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            exercise.typeDisplayName,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppThemes.lightSecondaryLabel,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: AppThemes.lightSecondaryLabel,
                      size: 16,
                    ),
                  ],
                ),
                if (exercise.instruction.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    exercise.instruction,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppThemes.lightLabel,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(exercise.difficulty).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        exercise.difficultyDisplay,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getDifficultyColor(exercise.difficulty),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppThemes.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${exercise.xpReward} XP',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppThemes.primaryGreen,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (exercise.estimatedTime > 0)
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppThemes.lightSecondaryLabel,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${exercise.estimatedTime}s',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppThemes.lightSecondaryLabel,
                            ),
                          ),
                        ],
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

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return AppThemes.primaryGreen;
      case 'intermediate':
        return AppThemes.systemOrange;
      case 'advanced':
        return AppThemes.systemRed;
      default:
        return AppThemes.primaryGreen;
    }
  }
}