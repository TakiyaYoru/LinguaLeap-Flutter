import 'package:flutter/material.dart';
import '../network/learnmap_service.dart';
import '../theme/app_themes.dart';
import 'dart:convert'; // Added for jsonDecode

class LessonDetailPage extends StatefulWidget {
  final String lessonId;
  final String unitId;
  final String lessonTitle;
  final int currentHearts;
  final Function(int) onHeartsChanged;
  final Function(String, String, String) onLessonCompleted;

  const LessonDetailPage({
    Key? key,
    required this.lessonId,
    required this.unitId,
    required this.lessonTitle,
    required this.currentHearts,
    required this.onHeartsChanged,
    required this.onLessonCompleted,
  }) : super(key: key);

  @override
  State<LessonDetailPage> createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends State<LessonDetailPage> 
    with TickerProviderStateMixin { // Added for animations
  List<Map<String, dynamic>> exercises = [];
  int currentExerciseIndex = 0;
  late int hearts;
  bool isLoading = true;
  String? error;
  bool isLessonCompleted = false;
  Set<String> completedExercises = {};
  String? _currentFillBlankAnswer; // Store current fill blank answer
  final TextEditingController _translationController = TextEditingController(); // For translation exercises

  // Word Matching State Variables
  Map<int, String> _wordMatchingSelections = {}; // wordIndex -> selectedMeaning
  Map<int, bool> _wordMatchingCompleted = {}; // wordIndex -> isCompleted
  Map<int, bool> _wordMatchingCorrect = {}; // wordIndex -> isCorrect
  List<String> _wordMatchingAvailableMeanings = []; // Available meanings for selection
  List<String> _wordMatchingOriginalMeanings = []; // Original meanings in order
  List<Map<String, dynamic>> _wordMatchingPairs = []; // Original pairs

  // Animation controllers for enhanced UI
  late AnimationController _progressAnimationController;
  late AnimationController _feedbackController;
  late Animation<double> _progressAnimation;
  late Animation<Offset> _slideAnimation;
  


  @override
  void initState() {
    super.initState();
    hearts = widget.currentHearts;
    
    // Initialize animations
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
    
    _loadExercises();
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    _feedbackController.dispose();
    _translationController.dispose();
    super.dispose();
  }

  void _updateProgress() {
    if (exercises.isNotEmpty) {
      final progress = (currentExerciseIndex + 1) / exercises.length;
      _progressAnimationController.animateTo(progress);
    }
  }

  Future<void> _loadExercises() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      print('🔄 Loading exercises for lesson: ${widget.lessonId}');
      final exercisesData = await LearnmapService.getExercisesByLesson(widget.lessonId);
      
      if (exercisesData != null) {
        setState(() {
          exercises = exercisesData;
          isLoading = false;
        });
        _updateProgress(); // Update progress animation
        print('✅ Loaded ${exercises.length} exercises');
      } else {
        setState(() {
          error = 'Không thể tải bài tập';
          isLoading = false;
        });
        print('❌ Failed to load exercises');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
      print('❌ Error loading exercises: $e');
    }
  }

  void _handleAnswer(int selectedAnswer) {
    if (isLessonCompleted) return;

    final exercise = exercises[currentExerciseIndex];
    final exerciseId = exercise['_id'];
    final isCorrect = _checkAnswer(exercise, selectedAnswer);
    
    print('🔄 [LessonDetailPage] Handling answer for exercise: $exerciseId, selected: $selectedAnswer, correct: $isCorrect');

    if (isCorrect) {
      // Đáp án đúng
      _markExerciseCompleted(exerciseId, 100);
      _showCorrectAnswerDialog();
    } else {
      // Đáp án sai - mất heart
      setState(() {
        hearts--;
      });
      widget.onHeartsChanged(hearts);

      if (hearts <= 0) {
        _showNoHeartsDialog();
      } else {
        _markExerciseWrong(exerciseId, selectedAnswer);
        _showWrongAnswerDialog();
      }
    }
  }

  bool _checkAnswer(Map<String, dynamic> exercise, int selectedAnswer) {
    final type = exercise['type'];
    
    switch (type) {
      case 'multiple_choice':
        // Parse content từ JSON string
        final contentString = exercise['content'] as String?;
        if (contentString != null) {
          try {
            final content = jsonDecode(contentString) as Map<String, dynamic>;
            if (content['correctAnswer'] != null) {
              return selectedAnswer == content['correctAnswer'];
            }
          } catch (e) {
            print('❌ Error parsing content JSON: $e');
          }
        }
        // Fallback: kiểm tra trong question text
        final questionText = exercise['question']['text'] as String?;
        if (questionText != null) {
          // Tạm thời hardcode cho demo, sau này sẽ parse từ content
          return selectedAnswer == 0; // Giả sử đáp án đầu tiên là đúng
        }
        break;
      case 'fill_blank':
        // Logic cho fill blank
        try {
          final content = jsonDecode(exercise['content'] as String);
          final correctAnswer = content['correctAnswer'] as String?;
          final alternatives = content['alternatives'] as List<dynamic>? ?? [];
          final userAnswer = _currentFillBlankAnswer ?? selectedAnswer.toString();
          
          if (correctAnswer != null) {
            // Kiểm tra đáp án chính
            if (userAnswer.toLowerCase().trim() == correctAnswer.toLowerCase().trim()) {
              return true;
            }
            // Kiểm tra các đáp án thay thế
            for (final alternative in alternatives) {
              if (userAnswer.toLowerCase().trim() == alternative.toString().toLowerCase().trim()) {
                return true;
              }
            }
          }
        } catch (e) {
          print('❌ Error parsing fill_blank content: $e');
        }
        return false;
      case 'true_false':
        // Logic cho true/false
        try {
          final content = jsonDecode(exercise['content'] as String);
          final isTrue = content['isTrue'] as bool?;
          final userAnswer = _currentFillBlankAnswer == 'true';
          
          if (isTrue != null) {
            return userAnswer == isTrue;
          }
        } catch (e) {
          print('❌ Error parsing true_false content: $e');
        }
        return false;
      case 'translation':
        // Logic cho translation
        try {
          final content = jsonDecode(exercise['content'] as String);
          final targetText = content['targetText'] as String?;
          final userAnswer = _currentFillBlankAnswer ?? '';
          
          if (targetText != null) {
            // So sánh đơn giản, có thể cải thiện bằng fuzzy matching
            return userAnswer.toLowerCase().trim() == targetText.toLowerCase().trim();
          }
        } catch (e) {
          print('❌ Error parsing translation content: $e');
        }
        return false;
      case 'word_matching':
        // Logic cho word matching - kiểm tra xem tất cả cặp đã đúng chưa
        try {
          // Kiểm tra xem tất cả cặp đã được chọn và đúng chưa
          if (_wordMatchingSelections.length == _wordMatchingPairs.length) {
            for (int i = 0; i < _wordMatchingPairs.length; i++) {
              final pair = _wordMatchingPairs[i];
              final correctMeaning = pair['meaning'] as String;
              final selectedMeaning = _wordMatchingSelections[i];
              
              if (selectedMeaning != correctMeaning) {
                return false; // Có ít nhất 1 cặp sai
              }
            }
            return true; // Tất cả cặp đều đúng
          }
        } catch (e) {
          print('❌ Error parsing word_matching content: $e');
        }
        return false;
      default:
        return selectedAnswer == 0; // Tạm thời
    }
    
    return false;
  }

  Future<void> _markExerciseCompleted(String exerciseId, int score) async {
    try {
      print('🔄 [LessonDetailPage] Calling updateExerciseProgress for exercise: $exerciseId');
      final result = await LearnmapService.updateExerciseProgress(widget.lessonId, {
        'exerciseId': exerciseId,
        'status': 'COMPLETED',
        'score': score,
        'attempts': 1,
      });

      if (result != null) {
        setState(() {
          completedExercises.add(exerciseId);
        });
        print('✅ Exercise marked as completed: $exerciseId');
        print('📊 Completed exercises: ${completedExercises.length}/${exercises.length}');
      } else {
        print('❌ updateExerciseProgress returned null');
      }
    } catch (e) {
      print('❌ Error marking exercise completed: $e');
    }
  }

  Future<void> _markExerciseWrong(String exerciseId, int wrongAnswer) async {
    try {
      final result = await LearnmapService.updateExerciseProgress(widget.lessonId, {
        'exerciseId': exerciseId,
        'status': 'IN_PROGRESS',
        'score': 0,
        'attempts': 1,
        'wrongAnswers': [wrongAnswer.toString()],
      });

      if (result != null) {
        print('❌ Exercise marked as wrong: $exerciseId');
      }
    } catch (e) {
      print('❌ Error marking exercise wrong: $e');
    }
  }

  Widget _buildFillBlankWidget(Map<String, dynamic> content) {
    final sentence = content['sentence'] as String? ?? '';
    final TextEditingController answerController = TextEditingController();
    
    return Column(
      children: [
        // Sentence with blank - enhanced styling
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppThemes.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppThemes.primaryGreen.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.edit_note, color: AppThemes.primaryGreen, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Điền từ vào chỗ trống:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppThemes.primaryGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                sentence,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppThemes.lightLabel,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Answer input with enhanced styling
        TextFormField(
          controller: answerController,
          decoration: InputDecoration(
            labelText: 'Đáp án của bạn',
            hintText: 'Nhập từ cần điền...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppThemes.systemGray4),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppThemes.systemGray4),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppThemes.primaryGreen, width: 2),
            ),
            filled: true,
            fillColor: AppThemes.lightBackground,
            prefixIcon: Icon(Icons.keyboard, color: AppThemes.primaryGreen),
          ),
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
          onFieldSubmitted: (answer) {
            if (answer.trim().isNotEmpty) {
              _handleFillBlankAnswer(answer.trim());
            }
          },
        ),
        
        const SizedBox(height: 20),
        
        // Submit button with enhanced styling
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              final answer = answerController.text.trim();
              if (answer.isNotEmpty) {
                _handleFillBlankAnswer(answer);
              }
            },
            icon: const Icon(Icons.check_circle_outline, size: 20),
            label: const Text(
              'Kiểm tra đáp án',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemes.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }

  void _handleFillBlankAnswer(String answer) {
    // Store the answer string for fill_blank exercises
    _currentFillBlankAnswer = answer;
    _handleAnswer(0); // Use 0 as index, but we'll use _currentFillBlankAnswer in _checkAnswer
  }

  Widget _buildTrueFalseWidget(Map<String, dynamic> content) {
    final statement = content['statement'] as String? ?? '';
    
    return Column(
      children: [
        // Statement display with enhanced styling
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppThemes.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppThemes.primaryGreen.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.quiz, color: AppThemes.primaryGreen, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Đọc câu và chọn đúng/sai:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppThemes.primaryGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                statement,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppThemes.lightLabel,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // True/False buttons with enhanced styling
        Row(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                child: Material(
                  borderRadius: BorderRadius.circular(16),
                  elevation: 2,
                  child: InkWell(
                    onTap: () => _handleTrueFalseAnswer(true),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green.withOpacity(0.3), width: 2),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle_outline, color: Colors.green, size: 24),
                          const SizedBox(height: 8),
                          const Text(
                            'ĐÚNG',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 8),
                child: Material(
                  borderRadius: BorderRadius.circular(16),
                  elevation: 2,
                  child: InkWell(
                    onTap: () => _handleTrueFalseAnswer(false),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.cancel_outlined, color: Colors.red, size: 24),
                          const SizedBox(height: 8),
                          const Text(
                            'SAI',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleTrueFalseAnswer(bool isTrue) {
    // Store the answer for true/false exercises
    _currentFillBlankAnswer = isTrue.toString();
    _handleAnswer(isTrue ? 0 : 1); // Use 0 for true, 1 for false
  }

  Widget _buildTranslationWidget(Map<String, dynamic> content) {
    final sourceText = content['sourceText'] as String? ?? '';
    
    return Column(
      children: [
        // Source text display with enhanced styling
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppThemes.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppThemes.primaryGreen.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.translate, color: AppThemes.primaryGreen, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Dịch câu sau:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppThemes.primaryGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                sourceText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppThemes.lightLabel,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Translation input field with enhanced styling
        TextFormField(
          controller: _translationController,
          onFieldSubmitted: (value) => _handleTranslationAnswer(value),
          decoration: InputDecoration(
            labelText: 'Bản dịch tiếng Việt',
            hintText: 'Nhập bản dịch của bạn...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppThemes.systemGray4),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppThemes.systemGray4),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppThemes.primaryGreen, width: 2),
            ),
            filled: true,
            fillColor: AppThemes.lightBackground,
            prefixIcon: Icon(Icons.edit, color: AppThemes.primaryGreen),
          ),
          maxLines: 3,
          style: const TextStyle(
            fontSize: 16,
            color: AppThemes.lightLabel,
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Submit button with enhanced styling
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _handleTranslationAnswer(_translationController.text),
            icon: const Icon(Icons.check_circle_outline, size: 20),
            label: const Text(
              'Kiểm tra đáp án',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemes.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }

  void _handleTranslationAnswer(String answer) {
    // Store the answer for translation exercises
    _currentFillBlankAnswer = answer;
    _handleAnswer(0); // For translation, we'll check the answer in _checkAnswer method
  }

  Widget _buildWordMatchingWidget(Map<String, dynamic> content) {
    final pairs = content['pairs'] as List<dynamic>? ?? [];
    final instruction = content['instruction'] as String? ?? 'Ghép từ tiếng Anh với nghĩa tiếng Việt';
    
    // Initialize word matching state if not already done
    if (_wordMatchingPairs.isEmpty) {
      _wordMatchingPairs = List<Map<String, dynamic>>.from(pairs);
      _wordMatchingOriginalMeanings = pairs.map((pair) => pair['meaning'] as String).toList();
      _wordMatchingAvailableMeanings = List<String>.from(_wordMatchingOriginalMeanings)..shuffle();
      _wordMatchingSelections.clear();
      _wordMatchingCompleted.clear();
      _wordMatchingCorrect.clear();
    }
    
    return Column(
      children: [
        // Instruction
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppThemes.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppThemes.primaryGreen.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.link, color: AppThemes.primaryGreen, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  instruction,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppThemes.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Word-Matching pairs
        Expanded(
          child: ListView.builder(
            itemCount: _wordMatchingPairs.length,
            itemBuilder: (context, index) {
              final pair = _wordMatchingPairs[index];
              final word = pair['word'] as String? ?? '';
              final correctMeaning = pair['meaning'] as String? ?? '';
              final isCompleted = _wordMatchingCompleted[index] ?? false;
              final isCorrect = _wordMatchingCorrect[index] ?? false;
              final selectedMeaning = _wordMatchingSelections[index];
              
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    // English word
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isCompleted 
                            ? (isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1))
                            : AppThemes.lightBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCompleted 
                              ? (isCorrect ? Colors.green : Colors.red)
                              : AppThemes.systemGray4,
                            width: isCompleted ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          word,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isCompleted ? (isCorrect ? Colors.green : Colors.red) : AppThemes.lightLabel,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    
                    // Arrow
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        isCompleted ? (isCorrect ? Icons.check_circle : Icons.cancel) : Icons.arrow_forward,
                        color: isCompleted ? (isCorrect ? Colors.green : Colors.red) : AppThemes.primaryGreen,
                        size: 24,
                      ),
                    ),
                    
                    // Meaning selection
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isCompleted 
                            ? (isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1))
                            : AppThemes.lightBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCompleted 
                              ? (isCorrect ? Colors.green : Colors.red)
                              : AppThemes.systemGray4,
                            width: isCompleted ? 2 : 1,
                          ),
                        ),
                        child: isCompleted
                          ? Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                selectedMeaning ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isCorrect ? Colors.green : Colors.red,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : DropdownButton<String>(
                              value: selectedMeaning,
                              hint: Text(
                                'Chọn nghĩa',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppThemes.systemGray3,
                                ),
                              ),
                              isExpanded: true,
                              underline: const SizedBox.shrink(),
                              items: _wordMatchingAvailableMeanings.map((meaning) {
                                return DropdownMenuItem(
                                  value: meaning,
                                  child: Text(
                                    meaning,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppThemes.lightLabel,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (selectedMeaning) {
                                if (selectedMeaning != null) {
                                  _handleWordMatchingSelection(index, selectedMeaning);
                                }
                              },
                            ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Check button - only show if all pairs are selected
        if (_wordMatchingSelections.length == _wordMatchingPairs.length)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _checkWordMatchingAnswers(),
              icon: const Icon(Icons.check_circle_outline, size: 20),
              label: const Text(
                'Kiểm tra đáp án',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemes.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
            ),
          ),
      ],
    );
  }

  void _handleWordMatchingAnswer(int index, String selectedMeaning) {
    // Store the answer for word matching exercises
    // This is a simplified approach - in a real app you'd want to store all matches
    _currentFillBlankAnswer = selectedMeaning;
  }

  void _handleWordMatchingSelection(int wordIndex, String selectedMeaning) {
    setState(() {
      _wordMatchingSelections[wordIndex] = selectedMeaning;
    });
  }

  void _checkWordMatchingAnswers() {
    setState(() {
      bool allCorrect = true;
      
      // Check each pair
      for (int i = 0; i < _wordMatchingPairs.length; i++) {
        final pair = _wordMatchingPairs[i];
        final correctMeaning = pair['meaning'] as String;
        final selectedMeaning = _wordMatchingSelections[i];
        
        final isCorrect = selectedMeaning == correctMeaning;
        
        _wordMatchingCompleted[i] = true;
        _wordMatchingCorrect[i] = isCorrect;
        
        if (!isCorrect) {
          allCorrect = false;
        }
      }
      
      // If all correct, mark exercise as completed
      if (allCorrect) {
        final exercise = exercises[currentExerciseIndex];
        final exerciseId = exercise['_id'];
        _markExerciseCompleted(exerciseId, 100);
        _showCorrectAnswerDialog();
      } else {
        // If any wrong, reset after showing feedback
        _showWordMatchingWrongAnswerDialog();
      }
    });
  }

  void _showWordMatchingWrongAnswerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppThemes.hearts,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Icon(Icons.cancel, color: Colors.white, size: 32),
              SizedBox(width: 12),
              Text(
                'Chưa đúng! 💪',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hãy kiểm tra lại các cặp từ của bạn!',
              style: TextStyle(color: AppThemes.lightLabel, fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppThemes.hearts.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppThemes.hearts.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: AppThemes.hearts, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Các cặp sai sẽ được reset để bạn thử lại',
                      style: TextStyle(
                        color: AppThemes.hearts,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _resetWordMatchingWrongAnswers();
              },
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text(
                'Thử lại',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemes.hearts,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resetWordMatchingWrongAnswers() {
    setState(() {
      // Reset only wrong answers
      for (int i = 0; i < _wordMatchingPairs.length; i++) {
        if (_wordMatchingCorrect[i] == false) {
          _wordMatchingSelections.remove(i);
          _wordMatchingCompleted[i] = false;
          _wordMatchingCorrect[i] = false;
        }
      }
    });
  }

  Widget _buildMultipleChoiceWidget(List<dynamic> options) {
    return ListView.builder(
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index].toString();
        final optionLetter = String.fromCharCode(65 + index); // A, B, C, D...
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            borderRadius: BorderRadius.circular(16),
            elevation: 2,
            child: InkWell(
              onTap: () => _handleAnswer(index),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppThemes.lightBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppThemes.systemGray4, width: 2),
                ),
                child: Row(
                  children: [
                    // Option letter circle
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppThemes.primaryGreen.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppThemes.primaryGreen.withOpacity(0.3)),
                      ),
                      child: Center(
                        child: Text(
                          optionLetter,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppThemes.primaryGreen,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Option text
                    Expanded(
                      child: Text(
                        option,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppThemes.lightLabel,
                          height: 1.4,
                        ),
                      ),
                    ),
                    // Arrow icon
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppThemes.systemGray4,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCorrectAnswerDialog() {
    final exercise = exercises[currentExerciseIndex];
    final feedback = exercise['feedback'] as Map<String, dynamic>?;
    final correctMessage = feedback?['correct'] ?? 'Đúng rồi!';
    final hintMessage = feedback?['hint'] ?? '';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppThemes.primaryGreen,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 32),
              SizedBox(width: 12),
              Text(
                'Chính xác! 🎉',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              correctMessage,
              style: const TextStyle(color: AppThemes.lightLabel, fontSize: 16, height: 1.4),
            ),
            if (hintMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppThemes.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppThemes.primaryGreen.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: AppThemes.primaryGreen, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hintMessage,
                        style: TextStyle(
                          color: AppThemes.primaryGreen,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _nextExercise();
              },
              icon: const Icon(Icons.arrow_forward, size: 20),
              label: const Text(
                'Tiếp tục',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemes.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showWrongAnswerDialog() {
    final exercise = exercises[currentExerciseIndex];
    final feedback = exercise['feedback'] as Map<String, dynamic>?;
    final incorrectMessage = feedback?['incorrect'] ?? 'Chưa đúng, hãy thử lại!';
    final hintMessage = feedback?['hint'] ?? '';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppThemes.hearts,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Icon(Icons.cancel, color: Colors.white, size: 32),
              SizedBox(width: 12),
              Text(
                'Chưa đúng! 💪',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              incorrectMessage,
              style: const TextStyle(color: AppThemes.lightLabel, fontSize: 16, height: 1.4),
            ),
            if (hintMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppThemes.hearts.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppThemes.hearts.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: AppThemes.hearts, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hintMessage,
                        style: TextStyle(
                          color: AppThemes.hearts,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Đưa câu hỏi về cuối để làm lại
                    final wrongExercise = exercises.removeAt(currentExerciseIndex);
                    exercises.add(wrongExercise);
                  },
                  icon: const Icon(Icons.refresh, size: 20),
                  label: const Text(
                    'Thử lại',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppThemes.hearts,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showNoHeartsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppThemes.lightBackground,
        title: Row(
          children: [
            Icon(Icons.favorite_border, color: AppThemes.hearts, size: 32),
            const SizedBox(width: 12),
            Text('No Hearts Left!', style: TextStyle(color: AppThemes.lightLabel)),
          ],
        ),
        content: Text(
          'You\'ve run out of hearts. Purchase more hearts or wait for them to refill.',
          style: TextStyle(color: AppThemes.lightSecondaryLabel),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _buyHearts();
            },
            child: Text('GET HEARTS', style: TextStyle(color: AppThemes.primaryGreen)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppThemes.primaryGreen),
            child: const Text('CLOSE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _buyHearts() {
    setState(() {
      hearts = 5; // Tạm thời reset về 5
    });
    widget.onHeartsChanged(hearts);
  }

  void _nextExercise() {
    if (currentExerciseIndex < exercises.length - 1) {
      setState(() {
        currentExerciseIndex++;
        // Reset word matching state for new exercise
        _wordMatchingSelections.clear();
        _wordMatchingCompleted.clear();
        _wordMatchingCorrect.clear();
        _wordMatchingAvailableMeanings.clear();
        _wordMatchingOriginalMeanings.clear();
        _wordMatchingPairs.clear();
      });
      _updateProgress(); // Update progress animation
    } else {
      // Kiểm tra xem tất cả exercises đã completed chưa
      if (completedExercises.length == exercises.length) {
        _completeLesson();
      } else {
        // Còn exercises chưa completed, tiếp tục
        setState(() {
          currentExerciseIndex = 0; // Quay về đầu
          // Reset word matching state for new exercise
          _wordMatchingSelections.clear();
          _wordMatchingCompleted.clear();
          _wordMatchingCorrect.clear();
          _wordMatchingAvailableMeanings.clear();
          _wordMatchingOriginalMeanings.clear();
          _wordMatchingPairs.clear();
        });
        _updateProgress();
      }
    }
  }

  void _completeLesson() {
    setState(() {
      isLessonCompleted = true;
    });

    print('🎉 [LessonDetailPage] Lesson completed! Unit: ${widget.unitId}, Lesson: ${widget.lessonId}');
    print('🎉 [LessonDetailPage] Completed exercises: ${completedExercises.length}/${exercises.length}');

    // Gọi callback để cập nhật progress
    widget.onLessonCompleted(widget.unitId, widget.lessonId, 'completed');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppThemes.lightBackground,
        title: Column(
          children: [
            Text(
              'Lesson completed!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppThemes.primaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            // Character illustration
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppThemes.primaryGreen, AppThemes.primaryGreenLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.celebration,
                color: Colors.white,
                size: 40,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Diamonds section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppThemes.systemBlue, AppThemes.systemIndigo],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.diamond, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    'Diamonds',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const Text(
                    '12',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Stats row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppThemes.xp, AppThemes.systemOrange],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Total XP',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.flash_on, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            const Text(
                              '24',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppThemes.primaryGreen, AppThemes.primaryGreenLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Time',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.timer, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            const Text(
                              '1:45',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppThemes.hearts, AppThemes.systemRed],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Accuracy',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.track_changes, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            const Text(
                              '87%',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemes.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'CONTINUE',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseWidget() {
    if (currentExerciseIndex >= exercises.length) {
      return const Center(child: Text('Không có câu hỏi nào'));
    }

    final exercise = exercises[currentExerciseIndex];
    final type = exercise['type'];
    final question = exercise['question']['text'] as String? ?? 'Câu hỏi';
    
    // Parse content từ JSON string
    Map<String, dynamic> content = {};
    List<dynamic> options = [];
    try {
      final contentString = exercise['content'] as String?;
      if (contentString != null) {
        content = jsonDecode(contentString) as Map<String, dynamic>;
        if (type == 'multiple_choice') {
          options = content['options'] as List<dynamic>? ?? [];
        }
      }
    } catch (e) {
      print('❌ Error parsing content JSON: $e');
      options = [];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question Design
        Text(
          type == 'fill_blank' ? 'Fill in the blank' : 
          type == 'true_false' ? 'True or False' : 
          type == 'translation' ? 'Translate to Vietnamese' :
          type == 'word_matching' ? 'Match words with meanings' :
          'Choose the correct answer',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppThemes.lightLabel,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Audio sentence
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppThemes.lightBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppThemes.systemGray4),
          ),
          child: Row(
            children: [
              if (type != 'fill_blank') ...[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppThemes.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.volume_up,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppThemes.lightLabel,
                  ),
                  textAlign: type == 'fill_blank' ? TextAlign.center : TextAlign.start,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Options Design
        Expanded(
          child: type == 'fill_blank' 
            ? _buildFillBlankWidget(content)
            : type == 'true_false'
            ? _buildTrueFalseWidget(content)
            : type == 'translation'
            ? _buildTranslationWidget(content)
            : type == 'word_matching'
            ? _buildWordMatchingWidget(content)
            : _buildMultipleChoiceWidget(options),
          ),
      ],
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.lightBackground,
            body: SafeArea(
        child: Column(
          children: [
            // Enhanced Top Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  // Close button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(Icons.close, size: 24, color: AppThemes.lightSecondaryLabel),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Enhanced Progress bar
                  Expanded(
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppThemes.systemGray5,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: exercises.isNotEmpty
                          ? AnimatedBuilder(
                              animation: _progressAnimation,
                              builder: (context, child) {
                                return FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: _progressAnimation.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppThemes.primaryGreen,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                );
                              },
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Enhanced Hearts indicator
                  Row(
                    children: List.generate(5, (index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 4),
                        child: Icon(
                          index < hearts ? Icons.favorite : Icons.favorite_border,
                          color: index < hearts ? AppThemes.hearts : AppThemes.systemGray3,
                          size: 20,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppThemes.primaryGreen),
                          const SizedBox(height: 16),
                          Text(
                            'Loading exercises...', 
                            style: TextStyle(color: AppThemes.lightSecondaryLabel)
                          ),
                        ],
                      ),
                    )
                  : error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 64, color: AppThemes.hearts),
                              const SizedBox(height: 16),
                              Text('Error: $error', textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadExercises,
                                style: ElevatedButton.styleFrom(backgroundColor: AppThemes.primaryGreen),
                                child: const Text('Try Again', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        )
                      : isLessonCompleted
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: AppThemes.primaryGreen,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.celebration,
                                      color: Colors.white,
                                      size: 60,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Lesson Complete!',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: AppThemes.primaryGreen,
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  SizedBox(
                                    width: 200,
                                    child: ElevatedButton.icon(
                                      onPressed: () => Navigator.of(context).pop(),
                                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                                      label: const Text(
                                        'Back to Map',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppThemes.primaryGreen,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(20),
                              child: _buildExerciseWidget(),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}