// lib/pages/exercise/exercise_container_page.dart - FIXED VERSION
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import '../../network/exercise_progress_service.dart';

class ExerciseContainerPage extends StatefulWidget {
  final String lessonId;
  final List<Map<String, dynamic>> exercises;
  
  const ExerciseContainerPage({
    super.key,
    required this.lessonId,
    required this.exercises,
  });

  @override
  State<ExerciseContainerPage> createState() => _ExerciseContainerPageState();
}

class _ExerciseContainerPageState extends State<ExerciseContainerPage>
    with TickerProviderStateMixin {
  int currentExerciseIndex = 0;
  int hearts = 5; // Duolingo-style hearts
  int totalXP = 0;
  List<Map<String, dynamic>> userAnswers = [];
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;
  bool _isNavigating = false; // Prevent multiple navigation
  bool _isDisposed = false; // Track if widget is disposed
  
  // Exercise state management
  bool _hasAnswered = false; // Track if current exercise has been answered
  String? _selectedAnswer; // Track selected answer
  bool? _isCorrect; // Track if answer is correct
  
  // Progress tracking
  DateTime _lessonStartTime = DateTime.now();
  Map<String, DateTime> _exerciseStartTimes = {};
  int _totalScore = 0;
  int _maxScore = 0;
  bool _isSavingProgress = false;
  
  // Lesson completion
  bool _lessonCompleted = false;
  Map<String, dynamic>? _lessonResult;
  
  // Debouncing for navigation actions
  DateTime? _lastNavigationTime;

  @override
  void initState() {
    super.initState();
    
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _updateProgress();
    
    // Start timer for first exercise
    if (widget.exercises.isNotEmpty) {
      _exerciseStartTimes[widget.exercises[0]['id']] = DateTime.now();
    }
  }

  @override
  void dispose() {
    // 🔥 CRITICAL FIX: Mark disposed FIRST
    _isDisposed = true;
    
    // Dispose animation controller BEFORE calling super
    _progressAnimationController.dispose();
    
    // Call super.dispose() LAST
    super.dispose();
  }

  // Helper method to check if navigation is safe
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

  // Safe navigation wrapper
  Future<void> _safeNavigate(Future<void> Function() navigationAction) async {
    if (!_canNavigate()) return;
    
    setState(() {
      _isNavigating = true;
      _lastNavigationTime = DateTime.now();
    });
    
    try {
      await navigationAction();
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

  // 🔥 FIXED: Safe exit method
  void _safeExitLesson() {
    if (_isDisposed || !mounted) return;
    
    try {
      if (GoRouter.of(context).canPop()) {
        GoRouter.of(context).pop();
      } else if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        // Last resort fallback
        context.go('/courses');
      }
    } catch (e) {
      print('❌ Safe exit error: $e');
      // Even if navigation fails, don't crash
    }
  }

  void _updateProgress() {
    if (_isDisposed || !mounted || _progressAnimationController.isAnimating) return;
    
    final progress = (currentExerciseIndex + 1) / widget.exercises.length;
    _progressAnimationController.animateTo(progress);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isDisposed || !mounted) return false;
        
        if (userAnswers.isEmpty) {
          _safeExitLesson();
        } else {
          _showExitConfirmation();
        }
        return false; // Always prevent default back behavior
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          if (_isDisposed || !mounted) return;
          
          if (userAnswers.isEmpty) {
            _safeExitLesson();
          } else {
            _showExitConfirmation();
          }
        },
      ),
      title: Column(
        children: [
          // Progress bar
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _progressAnimation.value,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
                minHeight: 6,
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            '${currentExerciseIndex + 1} / ${widget.exercises.length}',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
      actions: [
        // Hearts display (Duolingo style)
        Row(
          children: [
            Icon(
              Icons.favorite,
              color: hearts > 0 ? Colors.red : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              hearts.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: hearts > 0 ? Colors.red : Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (currentExerciseIndex >= widget.exercises.length) {
      return _buildCompletionScreen();
    }

    final currentExercise = widget.exercises[currentExerciseIndex];
    
    return Column(
      children: [
        // Exercise content
        Expanded(
          child: _buildExerciseWidget(currentExercise),
        ),
        
        // Bottom controls
        _buildBottomControls(),
      ],
    );
  }

  Widget _buildExerciseWidget(Map<String, dynamic> exercise) {
    final exerciseType = exercise['type'] ?? 'unknown';
    
    // For now, show a placeholder. We'll implement each type later
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise type indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getExerciseTypeColor(exerciseType).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getExerciseTypeDisplay(exerciseType),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getExerciseTypeColor(exerciseType),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Exercise title
          Text(
            exercise['title'] ?? 'Exercise',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Exercise instruction
          Text(
            exercise['instruction'] ?? '',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Exercise content based on type
          Expanded(
            child: _buildExerciseContent(exercise),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseContent(Map<String, dynamic> exercise) {
    final exerciseType = exercise['type'] ?? 'unknown';
    
    switch (exerciseType) {
      case 'multiple_choice':
        return _buildMultipleChoiceContent(exercise);
      case 'fill_blank':
        return _buildFillBlankContent(exercise);
      case 'word_matching':
        return _buildWordMatchingContent(exercise);
      case 'translation':
        return _buildTranslationContent(exercise);
      case 'true_false':
        return _buildTrueFalseContent(exercise);
      case 'sentence_building':
        return _buildSentenceBuildingContent(exercise);
      case 'listening':
        return _buildListeningContent(exercise);
      default:
        return _buildPlaceholderContent(exercise);
    }
  }

  Widget _buildMultipleChoiceContent(Map<String, dynamic> exercise) {
    final question = exercise['question']?['text'] ?? '';
    
    // Parse content if it's a string
    Map<String, dynamic> content;
    if (exercise['content'] is String) {
      try {
        content = Map<String, dynamic>.from(
          jsonDecode(exercise['content'] as String)
        );
      } catch (e) {
        print('❌ Error parsing exercise content: $e');
        content = {};
      }
    } else {
      content = Map<String, dynamic>.from(exercise['content'] ?? {});
    }
    
    final options = List<String>.from(content['options'] ?? []);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Text(
            question,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Options
        ...options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          
          // Determine option state
          bool isSelected = _selectedAnswer == option;
          bool isCorrect = _hasAnswered && _isCorrect == true && isSelected;
          bool isIncorrect = _hasAnswered && _isCorrect == false && isSelected;
          bool showCorrect = _hasAnswered && _getCorrectAnswerText(exercise) == option;
          
          // Determine colors
          Color backgroundColor = Colors.white;
          Color borderColor = Colors.grey.shade300;
          Color textColor = Colors.black;
          
          if (isCorrect) {
            backgroundColor = Colors.green.shade50;
            borderColor = Colors.green;
            textColor = Colors.green.shade800;
          } else if (isIncorrect) {
            backgroundColor = Colors.red.shade50;
            borderColor = Colors.red;
            textColor = Colors.red.shade800;
          } else if (showCorrect && _hasAnswered) {
            backgroundColor = Colors.green.shade50;
            borderColor = Colors.green.shade300;
            textColor = Colors.green.shade700;
          }
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              elevation: 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _hasAnswered ? null : () => _selectOption(option),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(12),
                          color: isCorrect ? Colors.green : 
                                 isIncorrect ? Colors.red : 
                                 showCorrect && _hasAnswered ? Colors.green.shade100 : Colors.white,
                        ),
                        child: Center(
                          child: isCorrect 
                            ? const Icon(Icons.check, color: Colors.white, size: 16)
                            : isIncorrect 
                              ? const Icon(Icons.close, color: Colors.white, size: 16)
                              : showCorrect && _hasAnswered 
                                ? const Icon(Icons.check, color: Colors.green, size: 16)
                                : Text(
                                    String.fromCharCode(65 + index), // A, B, C, D
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
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
                            color: textColor,
                            fontWeight: isSelected || showCorrect ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildFillBlankContent(Map<String, dynamic> exercise) {
    final question = exercise['question']?['text'] ?? '';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question with blank
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Text(
            question,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Input field
        TextField(
          decoration: InputDecoration(
            hintText: 'Type your answer here...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: const TextStyle(fontSize: 16),
          onSubmitted: (value) => _submitAnswer(value),
        ),
      ],
    );
  }

  Widget _buildWordMatchingContent(Map<String, dynamic> exercise) {
    // Parse content if it's a string
    Map<String, dynamic> content;
    if (exercise['content'] is String) {
      try {
        content = Map<String, dynamic>.from(
          jsonDecode(exercise['content'] as String)
        );
      } catch (e) {
        print('❌ Error parsing exercise content: $e');
        content = {};
      }
    } else {
      content = Map<String, dynamic>.from(exercise['content'] ?? {});
    }
    
    final pairs = List<Map<String, dynamic>>.from(content['pairs'] ?? []);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          exercise['question']?['text'] ?? 'Match the words',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Words and meanings
        ...pairs.map((pair) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.teal.shade200),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  pair['word'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward, color: Colors.teal),
              Expanded(
                child: Text(
                  pair['meaning'] ?? '',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildTranslationContent(Map<String, dynamic> exercise) {
    final question = exercise['question']?['text'] ?? '';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Source text
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Translate this:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                question,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Translation input
        TextField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter your translation...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: const TextStyle(fontSize: 16),
          onSubmitted: (value) => _submitAnswer(value),
        ),
      ],
    );
  }

  Widget _buildTrueFalseContent(Map<String, dynamic> exercise) {
    final question = exercise['question']?['text'] ?? '';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Statement
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Text(
            question,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        const SizedBox(height: 32),
        
        // True/False buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _selectOption(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'TRUE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _selectOption(false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'FALSE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSentenceBuildingContent(Map<String, dynamic> exercise) {
    // Parse content if it's a string
    Map<String, dynamic> content;
    if (exercise['content'] is String) {
      try {
        content = Map<String, dynamic>.from(
          jsonDecode(exercise['content'] as String)
        );
      } catch (e) {
        print('❌ Error parsing exercise content: $e');
        content = {};
      }
    } else {
      content = Map<String, dynamic>.from(exercise['content'] ?? {});
    }
    
    final words = List<String>.from(content['words'] ?? []);
    final targetSentence = content['target_sentence'] ?? '';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Build this sentence: "$targetSentence"',
          style: TextStyle(
            fontSize: 16,
            color: Colors.indigo.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Word chips to drag
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: words.map((word) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.indigo.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.indigo.shade300),
            ),
            child: Text(
              word,
              style: TextStyle(
                fontSize: 16,
                color: Colors.indigo.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          )).toList(),
        ),
        
        const SizedBox(height: 24),
        
        // Drop area
        Container(
          width: double.infinity,
          height: 60,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 2),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: const Center(
            child: Text(
              'Drop words here to build sentence',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListeningContent(Map<String, dynamic> exercise) {
    // Parse content if it's a string
    Map<String, dynamic> content;
    if (exercise['content'] is String) {
      try {
        content = Map<String, dynamic>.from(
          jsonDecode(exercise['content'] as String)
        );
      } catch (e) {
        print('❌ Error parsing exercise content: $e');
        content = {};
      }
    } else {
      content = Map<String, dynamic>.from(exercise['content'] ?? {});
    }
    
    final options = List<String>.from(content['options'] ?? []);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Audio player
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple.shade200),
          ),
          child: Column(
            children: [
              Icon(
                Icons.headphones,
                size: 48,
                color: Colors.purple.shade700,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _playAudio,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Play Audio'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Options
        ...options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              elevation: 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _selectOption(option),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + index),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          option,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPlaceholderContent(Map<String, dynamic> exercise) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(
            Icons.construction,
            size: 48,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 16),
          Text(
            'Exercise type: ${exercise['type']}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This exercise type will be implemented soon!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Skip button (only show if not answered)
          if (!_hasAnswered)
            Expanded(
              flex: 1,
              child: TextButton(
                onPressed: _skipExercise,
                child: const Text('Skip'),
              ),
            ),
          
          if (!_hasAnswered) const SizedBox(width: 16),
          
          // Continue button (only show if answered or last exercise)
          Expanded(
            flex: _hasAnswered ? 1 : 2,
            child: ElevatedButton(
              onPressed: (_isNavigating || (!_hasAnswered && currentExerciseIndex < widget.exercises.length - 1)) 
                  ? null 
                  : _continueToNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: (_isNavigating || (!_hasAnswered && currentExerciseIndex < widget.exercises.length - 1))
                    ? Colors.grey.shade300
                    : Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                  : Text(
                      currentExerciseIndex >= widget.exercises.length - 1
                          ? 'Finish'
                          : _hasAnswered 
                            ? 'Continue'
                            : 'Select an answer',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen() {
    final isPassed = _lessonResult?['passed'] ?? false;
    final percentage = _lessonResult?['percentage'] ?? 0.0;
    final xpEarned = _lessonResult?['xpEarned'] ?? totalXP;
    final unlockedLessons = _lessonResult?['unlockedLessons'] as List? ?? [];
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Completion status
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: isPassed ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPassed ? Icons.celebration : Icons.sentiment_dissatisfied,
              size: 60,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Status text
          Text(
            isPassed ? 'Lesson Passed!' : 'Lesson Failed',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isPassed ? Colors.green : Colors.red,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Score
          Text(
            'Score: $_totalScore/$_maxScore (${(percentage * 100).round()}%)',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // XP earned
          Text(
            'You earned $xpEarned XP!',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.orange,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Detailed stats
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isPassed ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isPassed ? Colors.green.shade200 : Colors.red.shade200,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Exercises completed:'),
                    Text('${widget.exercises.length}/${widget.exercises.length}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Correct answers:'),
                    Text('${userAnswers.where((a) => a['isCorrect'] == true).length}/${widget.exercises.length}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Hearts remaining:'),
                    Text('$hearts/5'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Time spent:'),
                    Text('${DateTime.now().difference(_lessonStartTime).inMinutes}m ${DateTime.now().difference(_lessonStartTime).inSeconds % 60}s'),
                  ],
                ),
              ],
            ),
          ),
          
          // Unlocked lessons
          if (unlockedLessons.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lock_open, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'New Lessons Unlocked!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...unlockedLessons.map((lesson) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(Icons.play_circle_outline, color: Colors.blue.shade600, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            lesson['title'] ?? 'New Lesson',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 32),
          
          // Action buttons
          Row(
            children: [
              // Retry button (if failed)
              if (!isPassed)
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isNavigating ? null : _retryLesson,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              
              if (!isPassed) const SizedBox(width: 16),
              
              // Continue button
              Expanded(
                child: ElevatedButton(
                  onPressed: _isNavigating ? null : _finishLesson,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isNavigating
                        ? Colors.grey.shade300
                        : Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                      : Text(
                          isPassed ? 'Continue' : 'Exit',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getExerciseTypeColor(String type) {
    switch (type) {
      case 'multiple_choice': return Colors.blue;
      case 'fill_blank': return Colors.green;
      case 'listening': return Colors.purple;
      case 'translation': return Colors.orange;
      case 'word_matching': return Colors.teal;
      case 'sentence_building': return Colors.indigo;
      case 'true_false': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getExerciseTypeDisplay(String type) {
    switch (type) {
      case 'multiple_choice': return 'Multiple Choice';
      case 'fill_blank': return 'Fill in the Blank';
      case 'listening': return 'Listening';
      case 'translation': return 'Translation';
      case 'word_matching': return 'Word Matching';
      case 'sentence_building': return 'Sentence Building';
      case 'true_false': return 'True or False';
      default: return type.replaceAll('_', ' ').toTitleCase();
    }
  }

  // Helper method to get correct answer text
  String _getCorrectAnswerText(Map<String, dynamic> exercise) {
    try {
      Map<String, dynamic> content;
      if (exercise['content'] is String) {
        content = Map<String, dynamic>.from(
          jsonDecode(exercise['content'] as String)
        );
      } else {
        content = Map<String, dynamic>.from(exercise['content'] ?? {});
      }
      
      if (exercise['type'] == 'multiple_choice') {
        final correctAnswerIndex = content['correct_answer'];
        final options = List<String>.from(content['options'] ?? []);
        if (correctAnswerIndex != null && options.isNotEmpty) {
          return options[correctAnswerIndex];
        }
      }
    } catch (e) {
      print('❌ Error getting correct answer text: $e');
    }
    return 'Unknown';
  }

  // Action methods
  void _selectOption(dynamic answer) {
    print('🎯 Selected answer: $answer');
    // TODO: Check if answer is correct
    _submitAnswer(answer);
  }

  void _submitAnswer(dynamic answer) async {
    if (_hasAnswered) return; // Prevent multiple submissions
    
    final currentExercise = widget.exercises[currentExerciseIndex];
    final isCorrect = _checkAnswer(currentExercise, answer);
    
    // Calculate time spent on this exercise
    final exerciseStartTime = _exerciseStartTimes[currentExercise['id']] ?? DateTime.now();
    final timeSpent = DateTime.now().difference(exerciseStartTime).inSeconds;
    
    // Calculate score
    final baseScore = currentExercise['xpReward'] as num? ?? 10;
    final score = ExerciseProgressService.calculateScore(
      isCorrect: isCorrect,
      baseScore: baseScore.toInt(),
      timeSpent: timeSpent,
      maxTime: 60, // 60 seconds max
    );
    
    // Update state
    setState(() {
      _hasAnswered = true;
      _selectedAnswer = answer.toString();
      _isCorrect = isCorrect;
      _totalScore += score;
      _maxScore += baseScore.toInt();
    });
    
    // Save exercise progress
    await _saveExerciseProgress(
      exerciseId: currentExercise['id'],
      userAnswer: answer,
      isCorrect: isCorrect,
      score: score,
      timeSpent: timeSpent,
    );
    
    userAnswers.add({
      'exerciseId': currentExercise['id'],
      'userAnswer': answer,
      'isCorrect': isCorrect,
      'score': score,
      'timeSpent': timeSpent,
    });
    
    if (isCorrect) {
      totalXP += score;
      _showCorrectFeedback();
    } else {
      hearts = (hearts - 1).clamp(0, 5);
      if (hearts <= 0) {
        await _completeLesson();
        _showGameOver();
        return;
      }
      _showIncorrectFeedback();
    }
  }

  Future<void> _saveExerciseProgress({
    required String exerciseId,
    required dynamic userAnswer,
    required bool isCorrect,
    required int score,
    required int timeSpent,
  }) async {
    try {
      await ExerciseProgressService.saveExerciseProgress(
        exerciseId: exerciseId,
        lessonId: widget.lessonId,
        userAnswer: userAnswer,
        isCorrect: isCorrect,
        score: score,
        timeSpent: timeSpent,
      );
    } catch (e) {
      print('❌ Error saving exercise progress: $e');
    }
  }

  Future<void> _completeLesson() async {
    if (_lessonCompleted) return;
    
    setState(() {
      _isSavingProgress = true;
    });
    
    try {
      final totalTimeSpent = DateTime.now().difference(_lessonStartTime).inSeconds;
      final isPassed = ExerciseProgressService.isLessonPassed(
        totalScore: _totalScore,
        maxScore: _maxScore,
        heartsRemaining: hearts,
      );
      
      // Save lesson progress
      final result = await ExerciseProgressService.saveLessonProgress(
        lessonId: widget.lessonId,
        courseId: widget.exercises.first['courseId'] ?? '',
        totalScore: _totalScore,
        maxScore: _maxScore,
        timeSpent: totalTimeSpent,
        heartsRemaining: hearts,
        isCompleted: true,
        exerciseResults: userAnswers,
      );
      
      setState(() {
        _lessonCompleted = true;
        _lessonResult = result;
        _isSavingProgress = false;
      });
      
      print('✅ Lesson completed:');
      print('   Passed: $isPassed');
      print('   Score: $_totalScore/$_maxScore');
      print('   Hearts: $hearts');
      print('   Time: ${totalTimeSpent}s');
      
    } catch (e) {
      print('❌ Error completing lesson: $e');
      setState(() {
        _isSavingProgress = false;
      });
    }
  }

  bool _checkAnswer(Map<String, dynamic> exercise, dynamic answer) {
    // Parse content if it's a string
    Map<String, dynamic> content;
    if (exercise['content'] is String) {
      try {
        content = Map<String, dynamic>.from(
          jsonDecode(exercise['content'] as String)
        );
      } catch (e) {
        print('❌ Error parsing exercise content: $e');
        content = {};
      }
    } else {
      content = Map<String, dynamic>.from(exercise['content'] ?? {});
    }
    
    final type = exercise['type'];
    
    switch (type) {
      case 'multiple_choice':
        // User selects text option, but correct_answer is index
        final correctAnswerIndex = content['correct_answer'];
        final options = List<String>.from(content['options'] ?? []);
        
        if (correctAnswerIndex != null && options.isNotEmpty) {
          final correctAnswerText = options[correctAnswerIndex];
          final isCorrect = answer == correctAnswerText;
          print('🎯 Checking multiple choice:');
          print('   User answer: $answer');
          print('   Correct answer text: $correctAnswerText');
          print('   Correct answer index: $correctAnswerIndex');
          print('   Is correct: $isCorrect');
          return isCorrect;
        }
        return false;
        
      case 'fill_blank':
        final correctAnswers = List<String>.from(content['correct_answers'] ?? []);
        return correctAnswers.any((correct) => 
          correct.toLowerCase().trim() == answer.toString().toLowerCase().trim());
          
      case 'true_false':
        final correctAnswer = content['correct_answer'];
        return answer == correctAnswer;
        
      default:
        return true; // Placeholder for other types
    }
  }

  void _showCorrectFeedback() {
    if (_isDisposed || !mounted) return;
    
    // Show success snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('Correct! +${widget.exercises[currentExerciseIndex]['xpReward'] ?? 10} XP'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Continue after delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!_isDisposed && mounted) {
        _continueToNext();
      }
    });
  }

  void _showIncorrectFeedback() {
    if (_isDisposed || !mounted) return;
    
    // Get correct answer for display
    final currentExercise = widget.exercises[currentExerciseIndex];
    String correctAnswerText = 'Unknown';
    
    try {
      Map<String, dynamic> content;
      if (currentExercise['content'] is String) {
        content = Map<String, dynamic>.from(
          jsonDecode(currentExercise['content'] as String)
        );
      } else {
        content = Map<String, dynamic>.from(currentExercise['content'] ?? {});
      }
      
      if (currentExercise['type'] == 'multiple_choice') {
        final correctAnswerIndex = content['correct_answer'];
        final options = List<String>.from(content['options'] ?? []);
        if (correctAnswerIndex != null && options.isNotEmpty) {
          correctAnswerText = options[correctAnswerIndex];
        }
      }
    } catch (e) {
      print('❌ Error getting correct answer: $e');
    }
    
    // Show error dialog with correct answer
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('❌ Incorrect'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Try again! You can do it!'),
            const SizedBox(height: 8),
            Text(
              'Correct answer: $correctAnswerText',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text('Hearts remaining: $hearts/5'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (Navigator.of(dialogContext).canPop()) {
                Navigator.of(dialogContext).pop();
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _continueToNext() async {
    if (_isNavigating || _isDisposed || !mounted) return;
    
    if (currentExerciseIndex < widget.exercises.length - 1) {
      setState(() {
        currentExerciseIndex++;
        _hasAnswered = false;
        _selectedAnswer = null;
        _isCorrect = null;
        _updateProgress();
      });
      
      // Start timer for next exercise
      final nextExercise = widget.exercises[currentExerciseIndex];
      _exerciseStartTimes[nextExercise['id']] = DateTime.now();
    } else {
      // Lesson completed - save progress
      await _completeLesson();
      
      setState(() {
        currentExerciseIndex = widget.exercises.length;
      });
    }
  }

  void _skipExercise() {
    if (_isDisposed || !mounted) return;
    
    userAnswers.add({
      'exerciseId': widget.exercises[currentExerciseIndex]['id'],
      'userAnswer': null,
      'isCorrect': false,
    });
    _continueToNext();
  }

  void _playAudio() {
    // TODO: Implement audio playback
    if (_isDisposed || !mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎵 Audio playback coming soon!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // 🔥 FIXED: Game over dialog with safety checks
  void _showGameOver() {
    if (_isDisposed || !mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text('Out of Hearts!'),
          content: const Text('You\'ve run out of hearts. Try the lesson again later or get more hearts.'),
          actions: [
            TextButton(
              onPressed: () {
                if (Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop(); // Close dialog first
                }
                
                // Safe exit after dialog closes
                Future.delayed(const Duration(milliseconds: 100), () {
                  _safeExitLesson();
                });
              },
              child: const Text('Exit'),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 FIXED: Finish lesson with safety checks
  void _finishLesson() async {
    if (_isDisposed || !mounted) return;
    
    await _safeNavigate(() async {
      // TODO: Save progress to backend
      await Future.delayed(const Duration(milliseconds: 300)); // Simulate API call
      
      if (_isDisposed || !mounted) return; // Check again after async
      
      _safeExitLesson(); // Use safe exit
    });
  }

  // 🔥 FIXED: Exit confirmation dialog with safety checks
  void _showExitConfirmation() {
    if (_isDisposed || !mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text('Exit Lesson?'),
          content: const Text('Your progress will be lost if you exit now.'),
          actions: [
            TextButton(
              onPressed: () {
                if (Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop(); // Close dialog only
                }
              },
              child: const Text('Stay'),
            ),
            TextButton(
              onPressed: () {
                if (Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop(); // Close dialog first
                }
                
                // Safe exit after dialog closes
                Future.delayed(const Duration(milliseconds: 100), () {
                  _safeExitLesson();
                });
              },
              child: const Text('Exit'),
            ),
          ],
        ),
      ),
    );
  }

  void _retryLesson() {
    if (_isDisposed || !mounted) return;
    
    setState(() {
      currentExerciseIndex = 0;
      hearts = 5;
      totalXP = 0;
      userAnswers.clear();
      _hasAnswered = false;
      _selectedAnswer = null;
      _isCorrect = null;
      _totalScore = 0;
      _maxScore = 0;
      _lessonCompleted = false;
      _lessonResult = null;
      _lessonStartTime = DateTime.now();
      _exerciseStartTimes.clear();
      _updateProgress();
    });
    
    // Start timer for first exercise
    if (widget.exercises.isNotEmpty) {
      _exerciseStartTimes[widget.exercises[0]['id']] = DateTime.now();
    }
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