// lib/pages/practice/listening_practice_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/exercise_model.dart';
import '../../network/exercise_service.dart';
import '../../theme/app_themes.dart';

class ListeningPracticePage extends StatefulWidget {
  const ListeningPracticePage({Key? key}) : super(key: key);

  @override
  State<ListeningPracticePage> createState() => _ListeningPracticePageState();
}

class _ListeningPracticePageState extends State<ListeningPracticePage> {
  List<ExerciseModel> listeningExercises = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadListeningExercises();
  }

  Future<void> _loadListeningExercises() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      print('🎧 [ListeningPracticePage] Loading listening exercises...');
      
      // Get all listening exercises
      final exercises = await ExerciseService.getListeningExercises();
      
      setState(() {
        listeningExercises = exercises;
        isLoading = false;
      });

      print('✅ [ListeningPracticePage] Loaded ${exercises.length} listening exercises');
    } catch (e) {
      print('❌ [ListeningPracticePage] Error loading listening exercises: $e');
      setState(() {
        error = 'Lỗi khi tải bài nghe: $e';
        isLoading = false;
      });
    }
  }

  void _openListeningExercise(ExerciseModel exercise) {
    // Navigate to listening exercise detail page
    context.push('/listening-exercise/${exercise.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.lightGroupedBackground,
      appBar: AppBar(
        backgroundColor: AppThemes.lightSecondaryBackground,
        title: const Text(
          'Luyện nghe',
          style: TextStyle(color: AppThemes.lightLabel),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppThemes.lightLabel),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadListeningExercises,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppThemes.primaryGreen),
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
              onPressed: _loadListeningExercises,
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
      );
    }

    if (listeningExercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.headphones,
              size: 64,
              color: AppThemes.lightSecondaryLabel,
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có bài nghe nào',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppThemes.lightLabel,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy quay lại sau khi có bài nghe mới',
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
      itemCount: listeningExercises.length,
      itemBuilder: (context, index) {
        final exercise = listeningExercises[index];
        return _buildListeningExerciseCard(exercise);
      },
    );
  }

  Widget _buildListeningExerciseCard(ExerciseModel exercise) {
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
          onTap: () => _openListeningExercise(exercise),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Exercise icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppThemes.listening.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.headphones,
                    color: AppThemes.listening,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Exercise info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.title ?? 'Bài nghe ${exercise.id}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppThemes.lightLabel,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (exercise.content['question'] != null)
                        Text(
                          exercise.content['question'],
                          style: TextStyle(
                            fontSize: 14,
                            color: AppThemes.lightSecondaryLabel,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.play_circle_outline,
                            size: 16,
                            color: AppThemes.listening,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Nhấn để nghe',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppThemes.listening,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppThemes.lightSecondaryLabel,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 