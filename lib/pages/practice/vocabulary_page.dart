// lib/pages/practice/vocabulary_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/vocabulary_controller.dart';
import '../../models/vocabulary_model.dart';

class VocabularyPage extends StatelessWidget {
  const VocabularyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final VocabularyController controller = Get.put(VocabularyController());

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Vocabulary'),
        backgroundColor: Theme.of(context).colorScheme.background,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddWordDialog(context, controller),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refresh(),
        child: Column(
          children: [
            // Statistics Card
            _buildStatsCard(context, controller),
            
            // Filter Tabs
            _buildFilterTabs(context, controller),
            
            // Error Message
            Obx(() {
              if (controller.errorMessage.isNotEmpty) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.errorMessage,
                          style: TextStyle(color: Colors.red[700], fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            
            // Word List
            Expanded(
              child: Obx(() {
                if (controller.isLoading && controller.allWords.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.filteredWords.isEmpty) {
                  return _buildEmptyState(context, controller);
                }

                return _buildWordList(context, controller);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, VocabularyController controller) {
    return Obx(() => Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  if (controller.isLoading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Text(
                    '${controller.progressPercentage.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: controller.progressPercentage / 100,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total', controller.totalWords.toString()),
              _buildStatItem('Learned', controller.learnedWords.toString()),
              _buildStatItem('Learning', controller.unlearnedWords.toString()),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs(BuildContext context, VocabularyController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() => Row(
        children: VocabularyFilter.values.map((filter) {
          final isSelected = controller.currentFilter == filter;
          return Expanded(
            child: GestureDetector(
              onTap: () => controller.setFilter(filter),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected 
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  filter.shortName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isSelected 
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      )),
    );
  }

  Widget _buildWordList(BuildContext context, VocabularyController controller) {
    return Obx(() => ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.filteredWords.length,
      itemBuilder: (context, index) {
        final word = controller.filteredWords[index];
        return _buildWordCard(context, word, controller);
      },
    ));
  }

  Widget _buildWordCard(BuildContext context, VocabularyWord word, VocabularyController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: word.isLearned 
                ? Colors.green.withOpacity(0.3)
                : Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Word and pronunciation
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        word.word,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (word.pronunciation != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          word.pronunciation!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).primaryColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Status and actions
                Row(
                  children: [
                    // Learned status toggle
                    GestureDetector(
                      onTap: () => controller.toggleLearned(word.id),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: word.isLearned 
                              ? Colors.green.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          word.isLearned ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: word.isLearned ? Colors.green : Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Delete button
                    GestureDetector(
                      onTap: () => _showDeleteConfirmation(context, word, controller),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Meaning
            Text(
              word.meaning,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            
            // Example (if exists)
            if (word.example != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.format_quote,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        word.example!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Footer with metadata
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        word.category,
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(word.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
                if (word.isLearned && word.learnedAt != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Learned ${_formatDate(word.learnedAt!)}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, VocabularyController controller) {
    String message;
    String submessage;
    IconData icon;

    switch (controller.currentFilter) {
      case VocabularyFilter.all:
        message = 'No vocabulary words yet';
        submessage = 'Add your first word to get started!';
        icon = Icons.book_outlined;
        break;
      case VocabularyFilter.unlearned:
        message = 'No unlearned words';
        submessage = 'Great! All your words are learned.';
        icon = Icons.check_circle_outline;
        break;
      case VocabularyFilter.learned:
        message = 'No learned words yet';
        submessage = 'Start learning some words!';
        icon = Icons.school_outlined;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            submessage,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          if (controller.currentFilter == VocabularyFilter.all && !controller.isLoading) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddWordDialog(context, controller),
              icon: const Icon(Icons.add),
              label: const Text('Add Word'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'today';
      } else if (difference.inDays == 1) {
        return 'yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'unknown date';
    }
  }

  void _showDeleteConfirmation(BuildContext context, VocabularyWord word, VocabularyController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Word'),
          content: Text('Are you sure you want to delete "${word.word}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                controller.deleteWord(word.id);
                Navigator.of(context).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showAddWordDialog(BuildContext context, VocabularyController controller) {
    final wordController = TextEditingController();
    final meaningController = TextEditingController();
    final pronunciationController = TextEditingController();
    final exampleController = TextEditingController();
    String selectedCategory = 'general';
    int selectedDifficulty = 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Word'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: wordController,
                      decoration: const InputDecoration(
                        labelText: 'Word *',
                        hintText: 'Enter the word',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: meaningController,
                      decoration: const InputDecoration(
                        labelText: 'Meaning *',
                        hintText: 'Enter the meaning',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: pronunciationController,
                      decoration: const InputDecoration(
                        labelText: 'Pronunciation (optional)',
                        hintText: '/prəˌnʌnsiˈeɪʃən/',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: exampleController,
                      decoration: const InputDecoration(
                        labelText: 'Example (optional)',
                        hintText: 'Example sentence',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'general', child: Text('General')),
                        DropdownMenuItem(value: 'basic', child: Text('Basic')),
                        DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
                        DropdownMenuItem(value: 'academic', child: Text('Academic')),
                        DropdownMenuItem(value: 'business', child: Text('Business')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value ?? 'general';
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: selectedDifficulty,
                      decoration: const InputDecoration(
                        labelText: 'Difficulty',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('1 - Easy')),
                        DropdownMenuItem(value: 2, child: Text('2 - Moderate')),
                        DropdownMenuItem(value: 3, child: Text('3 - Medium')),
                        DropdownMenuItem(value: 4, child: Text('4 - Hard')),
                        DropdownMenuItem(value: 5, child: Text('5 - Very Hard')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedDifficulty = value ?? 1;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                Obx(() => ElevatedButton(
                  onPressed: controller.isLoading ? null : () async {
                    if (wordController.text.trim().isNotEmpty && 
                        meaningController.text.trim().isNotEmpty) {
                      final success = await controller.addWord(
                        word: wordController.text.trim(),
                        meaning: meaningController.text.trim(),
                        pronunciation: pronunciationController.text.trim().isNotEmpty 
                            ? pronunciationController.text.trim() 
                            : null,
                        example: exampleController.text.trim().isNotEmpty 
                            ? exampleController.text.trim() 
                            : null,
                        category: selectedCategory,
                        difficulty: selectedDifficulty,
                      );
                      
                      if (success) {
                        Navigator.of(context).pop();
                      }
                    } else {
                      Get.snackbar(
                        'Error',
                        'Please fill in both word and meaning',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                  child: controller.isLoading 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Add'),
                )),
              ],
            );
          },
        );
      },
    );
  }
}