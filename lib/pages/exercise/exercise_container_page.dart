// lib/pages/exercise/exercise_container_page.dart - DUOLINGO STYLE UI - FIXED
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
  int hearts = 5;
  int totalXP = 0;
  List<Map<String, dynamic>> userAnswers = [];
  late AnimationController _progressAnimationController;
  late AnimationController _feedbackController;
  late Animation<double> _progressAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isNavigating = false;
  bool _isDisposed = false;
  
  // Exercise state management
  bool _hasAnswered = false;
  dynamic _selectedAnswer;
  bool? _isCorrect;
  List<String> _selectedWords = []; // For word ordering exercises
  Set<String> _selectedPairs = {}; // For matching exercises
  bool _isRecording = false; // For speaking exercises
  
  // Progress tracking
  DateTime _lessonStartTime = DateTime.now();
  int _totalScore = 0;
  int _maxScore = 0;
  bool _isSavingProgress = false;
  bool _lessonCompleted = false;
  
  // Theme colors
  static const Color primaryColor = Color(0xFF40C4AA);
  static const Color correctColor = Color(0xFF58CC02);
  static const Color wrongColor = Color(0xFFFF4B4B);

  @override
  void initState() {
    super.initState();
    _lessonStartTime = DateTime.now();
    
    // Progress animation
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Feedback animation
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _feedbackController,
      curve: Curves.easeOut,
    ));
    
    _updateProgress();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _progressAnimationController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _updateProgress() {
    final progress = (currentExerciseIndex + 1) / widget.exercises.length;
    _progressAnimationController.animateTo(progress);
  }

  @override
  Widget build(BuildContext context) {
    if (_lessonCompleted) {
      return _buildCompletionScreen();
    }
    
    if (currentExerciseIndex >= widget.exercises.length) {
      return _buildLoadingScreen();
    }

    final currentExercise = widget.exercises[currentExerciseIndex];
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _buildExerciseContent(currentExercise),
                  ),
                ),
                _buildBottomSection(),
              ],
            ),
            
            // Feedback overlay
            if (_hasAnswered)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildFeedbackOverlay(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Close button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(
              Icons.close,
              size: 24,
              color: Colors.grey,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Progress bar
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progressAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Gems/XP indicator
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF1CB0F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.diamond,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                '957',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseContent(Map<String, dynamic> exercise) {
    final type = exercise['type'] ?? '';
    final exerciseSubtype = exercise['exercise_subtype'] ?? type;
    
    // Handle 28 exercise subtypes
    switch (exerciseSubtype) {
      // Multiple Choice subtypes
      case 'vocabulary_multiple_choice':
      case 'grammar_multiple_choice':
      case 'listening_multiple_choice':
      case 'pronunciation_multiple_choice':
        return _buildMultipleChoiceExercise(exercise);
      
      // Fill Blank subtypes
      case 'vocabulary_fill_blank':
      case 'grammar_fill_blank':
      case 'listening_fill_blank':
      case 'writing_fill_blank':
        return _buildFillBlankExercise(exercise);
      
      // Translation subtypes
      case 'vocabulary_translation':
      case 'grammar_translation':
      case 'writing_translation':
        return _buildTranslationExercise(exercise);
      
      // Word Matching subtypes
      case 'vocabulary_word_matching':
        return _buildMatchingExercise(exercise);
      
      // Listening subtypes
      case 'vocabulary_listening':
      case 'grammar_listening':
      case 'pronunciation_listening':
        return _buildListeningExercise(exercise);
      
      // Speaking subtypes
      case 'vocabulary_speaking':
      case 'grammar_speaking':
      case 'pronunciation_speaking':
        return _buildSpeakingExercise(exercise);
      
      // Reading subtypes
      case 'vocabulary_reading':
      case 'grammar_reading':
      case 'comprehension_reading':
        return _buildReadingExercise(exercise);
      
      // Writing subtypes
      case 'vocabulary_writing':
      case 'grammar_writing':
      case 'sentence_writing':
        return _buildWritingExercise(exercise);
      
      // Fallback to original type handling
      default:
        switch (type) {
          case 'multiple_choice':
            return _buildMultipleChoiceExercise(exercise);
          case 'translation':
            return _buildTranslationExercise(exercise);
          case 'word_ordering':
            return _buildWordOrderingExercise(exercise);
          case 'listening':
            return _buildListeningExercise(exercise);
          case 'speaking':
            return _buildSpeakingExercise(exercise);
          case 'matching':
            return _buildMatchingExercise(exercise);
          default:
            return _buildPlaceholderContent(exercise);
        }
    }
  }

  Widget _buildMultipleChoiceExercise(Map<String, dynamic> exercise) {
    final content = exercise['content'] ?? {};
    final question = content['question'] ?? '';
    final options = List<String>.from(content['options'] ?? []);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question
        const Text(
          'What does this sentence mean?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Audio sentence
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.volume_up,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Answer options
        Expanded(
          child: ListView.builder(
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              final isSelected = _selectedAnswer == option;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: _hasAnswered ? null : () => _selectAnswer(option),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? primaryColor : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? primaryColor : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTranslationExercise(Map<String, dynamic> exercise) {
    final content = exercise['content'] ?? {};
    final sentence = content['sentence'] ?? '';
    final words = List<String>.from(content['wordBank'] ?? []);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        const Text(
          'Translate this sentence',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Sentence to translate
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.volume_up,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  sentence,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Selected words area
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 80), // Fixed: using constraints instead of min
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedWords.map((word) {
              return GestureDetector(
                onTap: () => _removeWordFromSelection(word),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    word,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        
        const Spacer(),
        
        // Word bank
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: words.map((word) {
            final isUsed = _selectedWords.contains(word);
            return GestureDetector(
              onTap: isUsed ? null : () => _addWordToSelection(word),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isUsed ? Colors.grey.shade200 : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isUsed ? Colors.grey.shade300 : Colors.grey.shade400,
                  ),
                ),
                child: Text(
                  word,
                  style: TextStyle(
                    color: isUsed ? Colors.grey.shade500 : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // FIXED: Added missing _buildWordOrderingExercise method
  Widget _buildWordOrderingExercise(Map<String, dynamic> exercise) {
    final content = exercise['content'] ?? {};
    final sentence = content['sentence'] ?? '';
    final words = List<String>.from(content['words'] ?? []);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        const Text(
          'Put these words in order',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Instructions
        Text(
          'Arrange the words to form the correct sentence:',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Target sentence (if available)
        if (sentence.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Target: $sentence',
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        const SizedBox(height: 32),
        
        // Selected words area (ordered)
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 80),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: _selectedWords.isEmpty
              ? const Text(
                  'Tap words below to build your sentence',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedWords.asMap().entries.map((entry) {
                    final index = entry.key;
                    final word = entry.value;
                    return GestureDetector(
                      onTap: () => _removeWordAtIndex(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          word,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
        
        const Spacer(),
        
        // Word bank
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: words.map((word) {
            final isUsed = _selectedWords.contains(word);
            return GestureDetector(
              onTap: isUsed ? null : () => _addWordToSelection(word),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isUsed ? Colors.grey.shade200 : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isUsed ? Colors.grey.shade300 : Colors.grey.shade400,
                  ),
                ),
                child: Text(
                  word,
                  style: TextStyle(
                    color: isUsed ? Colors.grey.shade500 : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSpeakingExercise(Map<String, dynamic> exercise) {
    final content = exercise['content'] ?? {};
    final sentence = content['sentence'] ?? '';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        const Text(
          'Speak this sentence',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        
        const SizedBox(height: 40),
        
        // Character
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.face,
              color: Colors.white,
              size: 60,
            ),
          ),
        ),
        
        const SizedBox(height: 40),
        
        // Sentence with audio
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.volume_up,
                color: primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  sentence,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const Spacer(),
        
        // Recording area
        Center(
          child: Column(
            children: [
              if (_isRecording)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      // Audio waveform visualization
                      SizedBox(
                        height: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(15, (index) {
                            return Container(
                              width: 4,
                              height: (index % 3 + 1) * 20.0,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                )
              else
                GestureDetector(
                  onTap: _toggleRecording,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: primaryColor, width: 2),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.mic,
                          color: primaryColor,
                          size: 32,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Tap to talk',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              const SizedBox(height: 20),
              
              // Can't talk now button
              TextButton(
                onPressed: () {},
                child: Text(
                  "Can't talk now",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMatchingExercise(Map<String, dynamic> exercise) {
    final content = exercise['content'] ?? {};
    final pairs = Map<String, String>.from(content['pairs'] ?? {});
    final leftWords = pairs.keys.toList()..shuffle();
    final rightWords = pairs.values.toList()..shuffle();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        const Text(
          'Tap the matching word pair',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        
        const SizedBox(height: 40),
        
        // Matching area
        Expanded(
          child: Row(
            children: [
              // Left column
              Expanded(
                child: Column(
                  children: leftWords.map((word) {
                    final isSelected = _selectedPairs.contains(word);
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => _selectMatchingWord(word),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isSelected ? primaryColor : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: isSelected ? primaryColor : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            word,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              
              const SizedBox(width: 20),
              
              // Right column
              Expanded(
                child: Column(
                  children: rightWords.map((word) {
                    final isSelected = _selectedPairs.contains(word);
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => _selectMatchingWord(word),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isSelected ? primaryColor : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: isSelected ? primaryColor : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            word,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListeningExercise(Map<String, dynamic> exercise) {
    final content = exercise['content'] ?? {};
    final words = List<String>.from(content['wordBank'] ?? []);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        const Text(
          'What does the audio say?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        
        const SizedBox(height: 40),
        
        // Audio player
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: const Column(
            children: [
              Icon(
                Icons.play_arrow,
                color: primaryColor,
                size: 40,
              ),
              SizedBox(height: 16),
              Text(
                'Tap to play audio',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 40),
        
        // Selected words area
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 80),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedWords.map((word) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  word,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        
        const Spacer(),
        
        // Word bank
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: words.map((word) {
            final isUsed = _selectedWords.contains(word);
            return GestureDetector(
              onTap: isUsed ? null : () => _addWordToSelection(word),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isUsed ? Colors.grey.shade200 : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isUsed ? Colors.grey.shade300 : Colors.grey.shade400,
                  ),
                ),
                child: Text(
                  word,
                  style: TextStyle(
                    color: isUsed ? Colors.grey.shade500 : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // NEW: Fill Blank Exercise
  Widget _buildFillBlankExercise(Map<String, dynamic> exercise) {
    final content = exercise['content'] ?? {};
    final sentence = content['sentence'] ?? '';
    final correctAnswer = content['correctAnswer'] ?? '';
    final alternatives = List<String>.from(content['alternatives'] ?? []);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        const Text(
          'Fill in the blank',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Sentence with blank
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            sentence,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Answer options
        Expanded(
          child: ListView.builder(
            itemCount: alternatives.length + 1, // +1 for correct answer
            itemBuilder: (context, index) {
              String option;
              if (index == 0) {
                option = correctAnswer;
              } else {
                option = alternatives[index - 1];
              }
              
              final isSelected = _selectedAnswer == option;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: _hasAnswered ? null : () => _selectAnswer(option),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? primaryColor : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? primaryColor : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // NEW: Reading Exercise
  Widget _buildReadingExercise(Map<String, dynamic> exercise) {
    final content = exercise['content'] ?? {};
    final text = content['text'] ?? '';
    final question = content['question'] ?? '';
    final options = List<String>.from(content['options'] ?? []);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        const Text(
          'Read and answer',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Reading text
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Question
        Text(
          question,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Answer options
        Expanded(
          child: ListView.builder(
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              final isSelected = _selectedAnswer == option;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: _hasAnswered ? null : () => _selectAnswer(option),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? primaryColor : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? primaryColor : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // NEW: Writing Exercise
  Widget _buildWritingExercise(Map<String, dynamic> exercise) {
    final content = exercise['content'] ?? {};
    final prompt = content['prompt'] ?? '';
    final wordBank = List<String>.from(content['wordBank'] ?? []);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        const Text(
          'Write your answer',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Writing prompt
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            prompt,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Selected words area
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 80),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedWords.map((word) {
              return GestureDetector(
                onTap: () => _removeWordFromSelection(word),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    word,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        
        const Spacer(),
        
        // Word bank
        if (wordBank.isNotEmpty)
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: wordBank.map((word) {
              final isUsed = _selectedWords.contains(word);
              return GestureDetector(
                onTap: isUsed ? null : () => _addWordToSelection(word),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUsed ? Colors.grey.shade200 : Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isUsed ? Colors.grey.shade300 : Colors.grey.shade400,
                    ),
                  ),
                  child: Text(
                    word,
                    style: TextStyle(
                      color: isUsed ? Colors.grey.shade500 : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildPlaceholderContent(Map<String, dynamic> exercise) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Exercise type: ${exercise['type']}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This exercise type will be implemented soon!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    if (_hasAnswered) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _canCheckAnswer() ? _checkAnswer : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _canCheckAnswer() ? primaryColor : Colors.grey.shade300,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            'Check Answers',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _canCheckAnswer() ? Colors.white : Colors.grey.shade500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackOverlay() {
    return Container(
      color: _isCorrect == true ? correctColor : wrongColor,
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  _isCorrect == true ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  _isCorrect == true ? 'Correct!' : 'Wrong!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.send, color: Colors.white),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.info_outline, color: Colors.white),
                ),
              ],
            ),
            
            if (_isCorrect == false) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Correct answer:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getCorrectAnswer(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _continueToNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _isCorrect == false ? 'OK' : 'CONTINUE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _isCorrect == true ? correctColor : wrongColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Spacer(),
              
              // Title
              const Text(
                'Lesson completed!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Character celebration
              Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.celebration,
                  color: Colors.white,
                  size: 100,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Stats
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.diamond,
                      color: Color(0xFF1CB0F6),
                      size: 32,
                    ),
                    SizedBox(width: 12),
                    Text(
                      '12',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Text(
                      'Diamonds',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1CB0F6),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Stats row
              Row(
                children: [
                  // Total XP
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Total XP',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.bolt,
                                color: Colors.orange.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$_totalScore',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Time
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: primaryColor.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Time',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.access_time,
                                color: primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getFormattedTime(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Accuracy
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.pink.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.pink.shade200),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Accuracy',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.pink,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.track_changes, // Fixed: changed from Icons.target to Icons.track_changes
                                color: Colors.pink.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_calculateAccuracy()}%',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pink.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'CONTINUE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Close button
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 24),
                ),
              ),
              
              const Spacer(),
              
              // Character
              Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.face,
                  color: Colors.white,
                  size: 80,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Loading text
              const Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Progress bar
              Container(
                width: 200,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.7,
                  child: Container(
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              const Text(
                'Complete the course faster to get more\nXP and Diamonds.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods
  void _selectAnswer(String answer) {
    if (_hasAnswered) return;
    
    setState(() {
      _selectedAnswer = answer;
    });
  }

  void _addWordToSelection(String word) {
    setState(() {
      _selectedWords.add(word);
    });
  }

  void _removeWordFromSelection(String word) {
    setState(() {
      _selectedWords.remove(word);
    });
  }

  // FIXED: Added missing _removeWordAtIndex method for word ordering
  void _removeWordAtIndex(int index) {
    setState(() {
      if (index >= 0 && index < _selectedWords.length) {
        _selectedWords.removeAt(index);
      }
    });
  }

  void _selectMatchingWord(String word) {
    setState(() {
      if (_selectedPairs.contains(word)) {
        _selectedPairs.remove(word);
      } else {
        _selectedPairs.add(word);
      }
    });
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });
  }

  bool _canCheckAnswer() {
    final currentExercise = widget.exercises[currentExerciseIndex];
    final type = currentExercise['type'] ?? '';
    final exerciseSubtype = currentExercise['exercise_subtype'] ?? type;
    
    // Handle 28 exercise subtypes
    switch (exerciseSubtype) {
      // Multiple Choice subtypes
      case 'vocabulary_multiple_choice':
      case 'grammar_multiple_choice':
      case 'listening_multiple_choice':
      case 'pronunciation_multiple_choice':
        return _selectedAnswer != null;
      
      // Fill Blank subtypes
      case 'vocabulary_fill_blank':
      case 'grammar_fill_blank':
      case 'listening_fill_blank':
      case 'writing_fill_blank':
        return _selectedAnswer != null;
      
      // Translation subtypes
      case 'vocabulary_translation':
      case 'grammar_translation':
      case 'writing_translation':
        return _selectedWords.isNotEmpty;
      
      // Word Matching subtypes
      case 'vocabulary_word_matching':
        return _selectedPairs.length >= 2;
      
      // Listening subtypes
      case 'vocabulary_listening':
      case 'grammar_listening':
      case 'pronunciation_listening':
        return _selectedWords.isNotEmpty;
      
      // Speaking subtypes
      case 'vocabulary_speaking':
      case 'grammar_speaking':
      case 'pronunciation_speaking':
        return _isRecording;
      
      // Reading subtypes
      case 'vocabulary_reading':
      case 'grammar_reading':
      case 'comprehension_reading':
        return _selectedAnswer != null;
      
      // Writing subtypes
      case 'vocabulary_writing':
      case 'grammar_writing':
      case 'sentence_writing':
        return _selectedWords.isNotEmpty;
      
      // Fallback to original type handling
      default:
        switch (type) {
          case 'multiple_choice':
            return _selectedAnswer != null;
          case 'translation':
          case 'listening':
          case 'word_ordering':
            return _selectedWords.isNotEmpty;
          case 'matching':
            return _selectedPairs.length >= 2;
          case 'speaking':
            return _isRecording;
          default:
            return true;
        }
    }
  }

  void _checkAnswer() {
    if (!_canCheckAnswer()) return;
    
    final currentExercise = widget.exercises[currentExerciseIndex];
    final content = currentExercise['content'] ?? {};
    final exerciseSubtype = currentExercise['exercise_subtype'] ?? currentExercise['type'] ?? '';
    
    bool isCorrect = false;
    
    // Check answer based on exercise subtype
    switch (exerciseSubtype) {
      // Multiple Choice subtypes
      case 'vocabulary_multiple_choice':
      case 'grammar_multiple_choice':
      case 'listening_multiple_choice':
      case 'pronunciation_multiple_choice':
        isCorrect = _selectedAnswer == content['correctAnswer'];
        break;
      
      // Fill Blank subtypes
      case 'vocabulary_fill_blank':
      case 'grammar_fill_blank':
      case 'listening_fill_blank':
      case 'writing_fill_blank':
        isCorrect = _selectedAnswer == content['correctAnswer'];
        break;
      
      // Translation subtypes
      case 'vocabulary_translation':
      case 'grammar_translation':
      case 'writing_translation':
        final correctAnswer = content['correctAnswer'] as String? ?? '';
        final userAnswer = _selectedWords.join(' ');
        isCorrect = userAnswer.toLowerCase() == correctAnswer.toLowerCase();
        break;
      
      // Word Matching subtypes
      case 'vocabulary_word_matching':
        // Check if selected pairs match the correct pairs
        final correctPairs = Map<String, String>.from(content['pairs'] ?? {});
        isCorrect = _selectedPairs.length == 2 && 
                   correctPairs.containsKey(_selectedPairs.first) &&
                   correctPairs[_selectedPairs.first] == _selectedPairs.last;
        break;
      
      // Listening subtypes
      case 'vocabulary_listening':
      case 'grammar_listening':
      case 'pronunciation_listening':
        final correctAnswer = content['correctAnswer'] as String? ?? '';
        final userAnswer = _selectedWords.join(' ');
        isCorrect = userAnswer.toLowerCase() == correctAnswer.toLowerCase();
        break;
      
      // Speaking subtypes
      case 'vocabulary_speaking':
      case 'grammar_speaking':
      case 'pronunciation_speaking':
        // For demo purposes, always correct
        isCorrect = true;
        break;
      
      // Reading subtypes
      case 'vocabulary_reading':
      case 'grammar_reading':
      case 'comprehension_reading':
        isCorrect = _selectedAnswer == content['correctAnswer'];
        break;
      
      // Writing subtypes
      case 'vocabulary_writing':
      case 'grammar_writing':
      case 'sentence_writing':
        final correctAnswer = content['correctAnswer'] as String? ?? '';
        final userAnswer = _selectedWords.join(' ');
        isCorrect = userAnswer.toLowerCase() == correctAnswer.toLowerCase();
        break;
      
      // Fallback to original type handling
      default:
        switch (currentExercise['type']) {
          case 'multiple_choice':
            isCorrect = _selectedAnswer == content['correctAnswer'];
            break;
          case 'translation':
          case 'listening':
            final correctAnswer = content['correctAnswer'] as String? ?? '';
            final userAnswer = _selectedWords.join(' ');
            isCorrect = userAnswer.toLowerCase() == correctAnswer.toLowerCase();
            break;
          case 'word_ordering':
            final correctOrder = List<String>.from(content['correctOrder'] ?? []);
            isCorrect = _selectedWords.join(' ') == correctOrder.join(' ');
            break;
          case 'matching':
            // Simple matching logic - check if selected pair is correct
            isCorrect = _selectedPairs.length == 2;
            break;
          case 'speaking':
            // For demo purposes, always correct
            isCorrect = true;
            break;
          default:
            isCorrect = true;
        }
    }
    
    setState(() {
      _hasAnswered = true;
      _isCorrect = isCorrect;
      if (isCorrect) {
        _totalScore += 10;
      } else {
        hearts = (hearts - 1).clamp(0, 5);
      }
    });
    
    _feedbackController.forward();
  }

  void _continueToNext() {
    _feedbackController.reverse();
    
    if (currentExerciseIndex < widget.exercises.length - 1) {
      setState(() {
        currentExerciseIndex++;
        _hasAnswered = false;
        _selectedAnswer = null;
        _selectedWords.clear();
        _selectedPairs.clear();
        _isCorrect = null;
        _isRecording = false;
      });
      _updateProgress();
    } else {
      setState(() {
        _lessonCompleted = true;
      });
    }
  }

  String _getCorrectAnswer() {
    final currentExercise = widget.exercises[currentExerciseIndex];
    final content = currentExercise['content'] ?? {};
    return content['correctAnswer'] ?? 'Answer not available';
  }

  String _getFormattedTime() {
    final duration = DateTime.now().difference(_lessonStartTime);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  int _calculateAccuracy() {
    if (userAnswers.isEmpty) return 100;
    final correctAnswers = userAnswers.where((answer) => answer['isCorrect'] == true).length;
    return ((correctAnswers / userAnswers.length) * 100).round();
  }
}