// lib/pages/exercise/exercise_crud_test_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/exercise_crud_controller.dart';
import '../../models/exercise_crud_model.dart';
import '../../theme/app_themes.dart';

class ExerciseCRUDTestPage extends StatelessWidget {
  ExerciseCRUDTestPage({Key? key}) : super(key: key);

  final ExerciseCRUDController controller = Get.put(ExerciseCRUDController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise CRUD Test'),
        backgroundColor: AppThemes.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadExercises(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Section
              _buildStatisticsSection(),
              const SizedBox(height: 24),
              
              // Actions Section
              _buildActionsSection(),
              const SizedBox(height: 24),
              
              // Exercises List
              _buildExercisesList(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatisticsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📊 Exercise Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppThemes.primaryGreen,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              final stats = controller.exerciseStats.value;
              if (stats == null) {
                return const Text('Loading stats...');
              }
              
              return Column(
                children: [
                  _buildStatRow('Total Exercises', '${stats.total}'),
                  _buildStatRow('Average Success Rate', '${stats.averageSuccessRate.toStringAsFixed(1)}%'),
                  _buildStatRow('Total Attempts', '${stats.totalAttempts}'),
                  _buildStatRow('Correct Attempts', '${stats.totalCorrectAttempts}'),
                  const SizedBox(height: 8),
                  Text(
                    'By Type:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...stats.byType.map((type) => 
                    _buildStatRow('  ${type.type}', '${type.count}', isSubItem: true)
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {bool isSubItem = false}) {
    return Padding(
      padding: EdgeInsets.only(left: isSubItem ? 16 : 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isSubItem ? 12 : 14,
              color: isSubItem ? Colors.grey[600] : Colors.black87,
            ),
          ),
                      Text(
              value,
              style: TextStyle(
                fontSize: isSubItem ? 12 : 14,
                fontWeight: FontWeight.bold,
                color: AppThemes.primaryGreen,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🔧 Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppThemes.primaryGreen,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildActionButton(
                  'Load All',
                  Icons.list,
                  () => controller.loadExercises(),
                ),
                _buildActionButton(
                  'Random',
                  Icons.shuffle,
                  () => controller.getRandomExercise(),
                ),
                _buildActionButton(
                  'Vocabulary',
                  Icons.translate,
                  () => controller.loadExercisesBySkill('vocabulary'),
                ),
                _buildActionButton(
                  'Multiple Choice',
                  Icons.check_circle,
                  () => controller.loadExercisesByType('multiple_choice'),
                ),
                _buildActionButton(
                  'Create Test',
                  Icons.add,
                  () => _showCreateExerciseDialog(),
                ),
                _buildActionButton(
                  'Bulk Create',
                  Icons.copy,
                  () => _showBulkCreateDialog(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppThemes.primaryGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildExercisesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '📝 Exercises (${controller.exercises.length})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppThemes.primaryGreen,
              ),
            ),
            Text(
              'Page ${controller.currentPage.value}/${controller.totalPages.value}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.exercises.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No exercises found. Try loading some exercises!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.exercises.length,
            itemBuilder: (context, index) {
              final exercise = controller.exercises[index];
              return _buildExerciseCard(exercise);
            },
          );
        }),
        const SizedBox(height: 16),
        if (controller.currentPage.value < controller.totalPages.value)
          Center(
            child: ElevatedButton(
              onPressed: controller.loadMoreExercises,
              child: const Text('Load More'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemes.secondary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildExerciseCard(ExerciseCRUDModel exercise) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.displayTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exercise.exerciseSubtype,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(exercise),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              exercise.instruction,
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoChip('${exercise.difficultyDisplay}', Icons.speed),
                const SizedBox(width: 8),
                _buildInfoChip('${exercise.maxScore} pts', Icons.star),
                const SizedBox(width: 8),
                _buildInfoChip('${exercise.successRate}%', Icons.trending_up),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Skills: ${exercise.skillFocus.join(', ')}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 16),
                      onPressed: () => _showEditExerciseDialog(exercise),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 16),
                      onPressed: () => _showDeleteExerciseDialog(exercise),
                      tooltip: 'Delete',
                    ),
                    IconButton(
                      icon: Icon(
                        exercise.isActive ? Icons.visibility : Icons.visibility_off,
                        size: 16,
                      ),
                      onPressed: () => controller.toggleExerciseActive(exercise.id),
                      tooltip: exercise.isActive ? 'Deactivate' : 'Activate',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(ExerciseCRUDModel exercise) {
    Color color;
    String text;
    
    if (!exercise.isActive) {
      color = Colors.grey;
      text = 'Inactive';
    } else if (exercise.isPremium) {
      color = Colors.amber;
      text = 'Premium';
    } else {
      color = Colors.green;
      text = 'Active';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateExerciseDialog() {
    final titleController = TextEditingController();
    final instructionController = TextEditingController();
    String selectedType = 'multiple_choice';
    String selectedSubtype = 'vocabulary_multiple_choice';

    Get.dialog(
      AlertDialog(
        title: const Text('Create Exercise'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: instructionController,
                decoration: const InputDecoration(
                  labelText: 'Instruction',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                items: ['multiple_choice', 'fill_blank', 'translation', 'listening']
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) {
                  selectedType = value!;
                  selectedSubtype = '${selectedSubtype.split('_').last}_$selectedType';
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final input = CreateExerciseInput(
                type: selectedType,
                exerciseSubtype: selectedSubtype,
                title: titleController.text,
                instruction: instructionController.text,
                content: '{"question": "Test question", "options": ["A", "B", "C", "D"], "correctAnswer": 0}',
                maxScore: 10,
                difficulty: 'beginner',
                xpReward: 5,
                estimatedTime: 20,
                requiresAudio: false,
                requiresMicrophone: false,
                skillFocus: ['vocabulary'],
              );
              
              final success = await controller.createExercise(input);
              if (success) {
                Get.back();
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showBulkCreateDialog() {
    String selectedTemplate = 'vocabulary_multiple_choice';
    final countController = TextEditingController(text: '5');

    Get.dialog(
      AlertDialog(
        title: const Text('Bulk Create Exercises'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedTemplate,
              decoration: const InputDecoration(
                labelText: 'Template',
                border: OutlineInputBorder(),
              ),
              items: controller.exerciseSubtypes
                  .map((subtype) => DropdownMenuItem(value: subtype, child: Text(subtype)))
                  .toList(),
              onChanged: (value) => selectedTemplate = value!,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: countController,
              decoration: const InputDecoration(
                labelText: 'Count',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final count = int.tryParse(countController.text) ?? 5;
              final success = await controller.bulkCreateExercises(
                template: selectedTemplate,
                count: count,
              );
              if (success) {
                Get.back();
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditExerciseDialog(ExerciseCRUDModel exercise) {
    final titleController = TextEditingController(text: exercise.title);
    final instructionController = TextEditingController(text: exercise.instruction);

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Exercise'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: instructionController,
              decoration: const InputDecoration(
                labelText: 'Instruction',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final input = UpdateExerciseInput(
                title: titleController.text,
                instruction: instructionController.text,
              );
              
              final success = await controller.updateExercise(exercise.id, input);
              if (success) {
                Get.back();
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteExerciseDialog(ExerciseCRUDModel exercise) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Exercise'),
        content: Text('Are you sure you want to delete "${exercise.displayTitle}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await controller.deleteExercise(exercise.id);
              if (success) {
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 