// lib/pages/course/lesson_detail_page.dart - Duolingo Style
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../network/exercise_service.dart';
import '../../network/lesson_service.dart';

class LessonDetailPage extends StatefulWidget {
  final String lessonId;
  final String lessonTitle;
  
  const LessonDetailPage({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
  });

  @override
  State<LessonDetailPage> createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends State<LessonDetailPage> {
  Map<String, dynamic>? lesson;
  List<Map<String, dynamic>> exercises = [];
  bool isLoading = true;
  String errorMessage = '';
  bool _isNavigating = false; // Prevent multiple navigation
  bool _isDisposed = false;
  DateTime? _lastNavigationTime;

  @override
  void initState() {
    super.initState();
    _loadLessonAndExercises();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  bool _canNavigate() {
    if (_isDisposed || _isNavigating) return false;
    
    final now = DateTime.now();
    if (_lastNavigationTime != null) {
      final difference = now.difference(_lastNavigationTime!);
      if (difference.inMilliseconds < 500) {
        return false; // Debounce navigation
      }
    }
    
    return true;
  }

  Future<void> _loadLessonAndExercises() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      print('🔥 Loading lesson and exercises for: ${widget.lessonId}');

      // Load lesson details
      final lessonData = await LessonService.getLesson(widget.lessonId);
      
      // Load exercises for this lesson
      final exercisesData = await ExerciseService.getLessonExercises(widget.lessonId);
      
      setState(() {
        lesson = lessonData;
        exercises = exercisesData ?? [];
        isLoading = false;
      });

      print('✅ Loaded lesson with ${exercises.length} exercises');
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading lesson: $e';
        isLoading = false;
      });
      print('❌ Error loading lesson: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return !_isNavigating; // Allow back navigation only if not currently navigating
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: Text(widget.lessonTitle),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: _isNavigating ? null : () => Navigator.of(context).pop(),
          ),
          actions: [
            if (lesson != null)
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: _isNavigating ? null : _showLessonInfo,
              ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading lesson...'),
          ],
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadLessonAndExercises,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lesson overview card
          if (lesson != null) _buildLessonOverview(),
          
          const SizedBox(height: 24),
          
          // Exercises preview section
          _buildExercisesPreview(),
          
          const SizedBox(height: 32),
          
          // Start lesson button (Duolingo style)
          _buildStartLessonButton(),
        ],
      ),
    );
  }

  Widget _buildLessonOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.school,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson!['title'] ?? widget.lessonTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (lesson!['objective'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        lesson!['objective'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Stats row
          Row(
            children: [
              _buildStatItem(
                Icons.quiz,
                '${exercises.length}',
                'Exercises',
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                Icons.access_time,
                '${lesson!['estimatedDuration'] ?? 0}',
                'Minutes',
              ),
              const SizedBox(width: 26),
              _buildStatItem(
                Icons.star,
                '+${lesson!['xpReward'] ?? 0}',
                'XP',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExercisesPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.list_alt,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            const Text(
              'What you\'ll practice',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (exercises.isEmpty)
          _buildEmptyExercises()
        else
          _buildExerciseTypesGrid(),
      ],
    );
  }

  Widget _buildEmptyExercises() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.quiz_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No exercises available yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseTypesGrid() {
    // Group exercises by type to show variety
    final Map<String, int> exerciseTypes = {};
    for (final exercise in exercises) {
      final type = exercise['type'] ?? 'unknown';
      exerciseTypes[type] = (exerciseTypes[type] ?? 0) + 1;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: exerciseTypes.length,
      itemBuilder: (context, index) {
        final type = exerciseTypes.keys.elementAt(index);
        final count = exerciseTypes[type]!;
        return _buildExerciseTypeChip(type, count);
      },
    );
  }

  Widget _buildExerciseTypeChip(String type, int count) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getExerciseTypeColor(type).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getExerciseTypeColor(type).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getExerciseTypeIcon(type),
            color: _getExerciseTypeColor(type),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getExerciseTypeDisplay(type),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getExerciseTypeColor(type),
                  ),
                ),
                Text(
                  '$count exercise${count > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartLessonButton() {
    final bool canStart = exercises.isNotEmpty;
    
    return Column(
      children: [
        // Progress indicator (fake for now)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ready to start?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Complete all ${exercises.length} exercises to earn ${lesson?['xpReward'] ?? 0} XP',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Start lesson button 
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (canStart && !_isNavigating) ? _startLesson : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: (canStart && !_isNavigating)
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade300,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: (canStart && !_isNavigating) ? 3 : 0,
            ),
            child: _isNavigating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        canStart ? Icons.play_arrow : Icons.lock,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        canStart ? 'Start Lesson' : 'No Exercises Available',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  // Helper methods for exercise types
  Color _getExerciseTypeColor(String type) {
    switch (type) {
      case 'multiple_choice':
        return Colors.blue;
      case 'fill_blank':
        return Colors.green;
      case 'listening':
        return Colors.purple;
      case 'translation':
        return Colors.orange;
      case 'word_matching':
        return Colors.teal;
      case 'sentence_building':
        return Colors.indigo;
      case 'true_false':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getExerciseTypeIcon(String type) {
    switch (type) {
      case 'multiple_choice':
        return Icons.radio_button_checked;
      case 'fill_blank':
        return Icons.edit;
      case 'listening':
        return Icons.headphones;
      case 'translation':
        return Icons.translate;
      case 'word_matching':
        return Icons.compare_arrows;
      case 'sentence_building':
        return Icons.text_fields;
      case 'true_false':
        return Icons.check_circle;
      default:
        return Icons.quiz;
    }
  }

  String _getExerciseTypeDisplay(String type) {
    switch (type) {
      case 'multiple_choice':
        return 'Multiple Choice';
      case 'fill_blank':
        return 'Fill Blanks';
      case 'listening':
        return 'Listening';
      case 'translation':
        return 'Translation';
      case 'word_matching':
        return 'Word Match';
      case 'sentence_building':
        return 'Sentence Build';
      case 'true_false':
        return 'True/False';
      default:
        return type.replaceAll('_', ' ').toTitleCase();
    }
  }

  void _startLesson() async {
    if (exercises.isEmpty || !_canNavigate()) return;
    
    setState(() {
      _isNavigating = true;
      _lastNavigationTime = DateTime.now();
    });
    
    try {
      print('🚀 Starting lesson with ${exercises.length} exercises');
      
      // Navigate to ExerciseContainerPage với exercises data
      await context.push('/exercise/${widget.lessonId}', extra: exercises);
    } catch (e) {
      print('❌ Navigation error: $e');
      if (mounted && !_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigation error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted && !_isDisposed) {
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

  void _showStartConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Lesson?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You\'re about to start:'),
            const SizedBox(height: 8),
            Text('• ${exercises.length} exercises'),
            Text('• ${lesson?['estimatedDuration'] ?? 0} minutes'),
            Text('• +${lesson?['xpReward'] ?? 0} XP reward'),
            const SizedBox(height: 12),
            Text(
              'Complete all exercises to earn the full reward!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_isNavigating) return;
              
              Navigator.of(context).pop();
              await Future.delayed(const Duration(milliseconds: 100));
              if (mounted) {
                _startLesson();
              }
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  void _showLessonInfo() {
    if (lesson == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lesson!['title'] ?? 'Lesson Info'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (lesson!['description'] != null) ...[
                const Text(
                  'Description:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(lesson!['description']),
                const SizedBox(height: 12),
              ],
              
              if (lesson!['objective'] != null) ...[
                const Text(
                  'Learning Objective:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(lesson!['objective']),
                const SizedBox(height: 12),
              ],
              
              const Text(
                'Details:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text('Difficulty: ${lesson!['difficulty'] ?? 'N/A'}'),
              Text('Duration: ${lesson!['estimatedDuration'] ?? 0} minutes'),
              Text('XP Reward: +${lesson!['xpReward'] ?? 0}'),
              Text('Premium: ${lesson!['isPremium'] == true ? 'Yes' : 'No'}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Extension for title case
extension StringExtension on String {
  String toTitleCase() {
    return split(' ').map((word) => 
      word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' : ''
    ).join(' ');
  }
}