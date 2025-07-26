// lib/pages/admin/lesson_detail_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/lesson_model.dart';
import '../../models/exercise_model.dart';
import '../../network/admin_service.dart';
import '../../network/exercise_service.dart';
import '../../theme/app_themes.dart';
import '../../routes/app_router.dart';

class LessonDetailPage extends StatefulWidget {
  final String lessonId;

  const LessonDetailPage({
    super.key,
    required this.lessonId,
  });

  @override
  State<LessonDetailPage> createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends State<LessonDetailPage> {
  LessonModel? lesson;
  List<ExerciseModel> exercises = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // Load lesson data
      final allLessons = await AdminService.getAllLessons();
      final lessonData = allLessons.firstWhere(
        (l) => l.id == widget.lessonId,
        orElse: () => throw Exception('Lesson not found'),
      );
      
      // Load exercises for this lesson
      final lessonExercises = await ExerciseService.getExercisesByLesson(widget.lessonId);

      setState(() {
        lesson = lessonData;
        exercises = lessonExercises;
        isLoading = false;
      });
    } catch (e) {
      print('❌ [LessonDetail] Error loading data: $e');
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _handleExerciseAction(String action, ExerciseModel exercise) {
    switch (action) {
      case 'edit':
        context.go('${AppRouter.adminEditExercise.replaceAll(':exerciseId', exercise.id)}?lessonId=${exercise.lessonId}&unitId=${exercise.unitId}&courseId=${exercise.courseId}');
        break;
      case 'publish':
        _publishExercise(exercise.id);
        break;
      case 'unpublish':
        _unpublishExercise(exercise.id);
        break;
      case 'delete':
        _showDeleteExerciseDialog(exercise);
        break;
    }
  }

  Future<void> _publishExercise(String exerciseId) async {
    try {
      await ExerciseService.publishExercise(exerciseId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exercise published successfully!'),
            backgroundColor: AppThemes.systemGreen,
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to publish exercise: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _unpublishExercise(String exerciseId) async {
    try {
      await ExerciseService.unpublishExercise(exerciseId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exercise unpublished successfully!'),
            backgroundColor: AppThemes.systemGreen,
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to unpublish exercise: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteExerciseDialog(ExerciseModel exercise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exercise'),
        content: Text('Are you sure you want to delete "${exercise.displayTitle}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteExercise(exercise.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteExercise(String exerciseId) async {
    try {
      // Remove from UI immediately
      setState(() {
        exercises.removeWhere((exercise) => exercise.id == exerciseId);
      });
      
      await ExerciseService.deleteExercise(exerciseId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exercise deleted successfully!'),
            backgroundColor: AppThemes.systemGreen,
          ),
        );
      }
    } catch (e) {
      // If error, reload to restore the item
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete exercise: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEditOrderDialog() {
    final orderController = TextEditingController(text: lesson?.sortOrder.toString() ?? '1');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Lesson Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current order: ${lesson?.sortOrder ?? 1}'),
            const SizedBox(height: 16),
            TextField(
              controller: orderController,
              decoration: const InputDecoration(
                labelText: 'New Order',
                border: OutlineInputBorder(),
                hintText: 'Enter new sort order (1, 2, 3...)',
              ),
              keyboardType: TextInputType.number,
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
              final newOrder = int.tryParse(orderController.text);
              if (newOrder == null || newOrder < 1) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid order number'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              
              Navigator.of(context).pop();
              await _updateLessonOrder(newOrder);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateLessonOrder(int newOrder) async {
    if (lesson == null) return;
    
    try {
      setState(() {
        isLoading = true;
      });
      
      final result = await AdminService.setLessonOrder(lesson!.id!, newOrder);
      
      if (result != null) {
        // Update local lesson data
        lesson = lesson!.copyWith(sortOrder: newOrder);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lesson order updated successfully to $newOrder'),
              backgroundColor: Colors.green,
            ),
          );
        }
        
        // Refresh data
        await _loadData();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update lesson order'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.lightGroupedBackground,
      appBar: AppBar(
        backgroundColor: AppThemes.lightSecondaryBackground,
        title: Text(
          lesson?.title ?? 'Lesson Detail',
          style: TextStyle(color: AppThemes.lightLabel),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppThemes.lightLabel),
          onPressed: () => context.go(AppRouter.adminDashboard),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppThemes.primaryGreen),
            onPressed: _loadData,
            tooltip: 'Refresh',
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
                      Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text('Error: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLessonInfo(),
                      const SizedBox(height: 24),
                      _buildExercisesSection(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildLessonInfo() {
    if (lesson == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getLessonTypeIcon(lesson!.type),
                  color: AppThemes.primaryGreen,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    lesson!.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppThemes.lightLabel,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: lesson!.isPublished ? AppThemes.systemGreen : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    lesson!.isPublished ? 'Published' : 'Draft',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (lesson!.description?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Text(
                lesson!.description!,
                style: TextStyle(
                  color: AppThemes.lightSecondaryLabel,
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoChip('Type', lesson!.typeDisplay),
                const SizedBox(width: 8),
                _buildInfoChip('Difficulty', lesson!.difficultyDisplay),
                const SizedBox(width: 8),
                _buildInfoChip('XP', '${lesson!.xpReward}'),
                const SizedBox(width: 8),
                _buildInfoChip('Order', '${lesson!.sortOrder}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoChip('Duration', '${lesson!.estimatedDuration}m'),
                const SizedBox(width: 8),
                _buildInfoChip('Exercises', '${lesson!.totalExercises}'),
                const SizedBox(width: 8),
                _buildInfoChip('Premium', lesson!.isPremium ? 'Yes' : 'No'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppThemes.lightSecondaryBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 12,
          color: AppThemes.lightSecondaryLabel,
        ),
      ),
    );
  }

  Widget _buildExercisesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Exercises (${exercises.length})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppThemes.lightLabel,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    final unitId = lesson?.unitId?.toString() ?? '';
                    final courseId = lesson?.courseId?.toString() ?? '';
                    context.go('${AppRouter.adminCreateExercise}?lessonId=${widget.lessonId}&unitId=$unitId&courseId=$courseId');
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Exercise'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppThemes.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _showEditOrderDialog,
                  icon: const Icon(Icons.sort, size: 18),
                  label: const Text('Edit Order'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (exercises.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(Icons.fitness_center, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No exercises yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first exercise to get started',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: exercises.asMap().entries.map((entry) {
                  final index = entry.key;
                  final exercise = entry.value;
                  return Column(
                    children: [
                      _buildExerciseCard(exercise),
                      if (index < exercises.length - 1) const SizedBox(height: 12),
                    ],
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(ExerciseModel exercise) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppThemes.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getExerciseTypeIcon(exercise.type),
            color: AppThemes.primaryGreen,
            size: 24,
          ),
        ),
        title: Text(
          exercise.displayTitle,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppThemes.lightLabel,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              exercise.instruction,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppThemes.lightSecondaryLabel,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildExerciseChip('Type', exercise.typeDisplay),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildExerciseChip('Difficulty', exercise.difficultyDisplay),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildExerciseChip('XP', '${exercise.xpReward}'),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: AppThemes.lightSecondaryLabel),
          onSelected: (action) => _handleExerciseAction(action, exercise),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: exercise.isActive ? 'unpublish' : 'publish',
              child: Row(
                children: [
                  Icon(
                    exercise.isActive ? Icons.visibility_off : Icons.visibility,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(exercise.isActive ? 'Unpublish' : 'Publish'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppThemes.lightSecondaryBackground,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 10,
          color: AppThemes.lightSecondaryLabel,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  IconData _getLessonTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'vocabulary': return Icons.translate;
      case 'grammar': return Icons.rule;
      case 'listening': return Icons.headphones;
      case 'speaking': return Icons.record_voice_over;
      case 'reading': return Icons.menu_book;
      case 'writing': return Icons.edit_note;
      case 'conversation': return Icons.chat;
      case 'review': return Icons.refresh;
      case 'test': return Icons.quiz;
      default: return Icons.school;
    }
  }

  IconData _getExerciseTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'multiple_choice': return Icons.check_circle_outline;
      case 'fill_blank': return Icons.text_fields;
      case 'listening': return Icons.headphones;
      case 'translation': return Icons.translate;
      case 'speaking': return Icons.record_voice_over;
      case 'reading': return Icons.menu_book;
      case 'word_matching': return Icons.compare_arrows;
      case 'sentence_building': return Icons.format_list_bulleted;
      case 'true_false': return Icons.check_box;
      case 'drag_drop': return Icons.drag_handle;
      case 'listen_choose': return Icons.hearing;
      case 'speak_repeat': return Icons.repeat;
      default: return Icons.fitness_center;
    }
  }
} 