// lib/pages/practice/reading_practice_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReadingPracticePage extends StatefulWidget {
  const ReadingPracticePage({super.key});

  @override
  State<ReadingPracticePage> createState() => _ReadingPracticePageState();
}

class _ReadingPracticePageState extends State<ReadingPracticePage>
    with TickerProviderStateMixin {
  int currentQuestionIndex = -1; // Start with -1 to show passage first
  Map<int, String> userAnswers = {};
  bool isCompleted = false;
  bool showResults = false;
  int score = 0;
  int hearts = 5;
  int earnedXP = 0;
  
  late AnimationController _progressController;
  late AnimationController _heartController;
  late Animation<double> _progressAnimation;
  late Animation<double> _heartAnimation;

  // Mock reading passage data
  final Map<String, dynamic> readingData = {
    "title": "A Day at the Coffee Shop",
    "level": "Beginner (A1)",
    "estimatedTime": "10 minutes",
    "passage": """
Sarah works at a busy coffee shop in the city center. Every morning, she arrives at 7:00 AM to prepare for the day. She makes fresh coffee, arranges pastries in the display case, and cleans the tables.

The coffee shop opens at 8:00 AM. Many customers come for breakfast before work. They usually order coffee, tea, or hot chocolate with croissants or muffins. Sarah enjoys talking to regular customers who visit every day.

During lunch time, the shop gets very busy. People order sandwiches, salads, and cold drinks. Sarah works quickly to serve everyone. She likes her job because she meets different people from around the world.

The coffee shop closes at 6:00 PM. After closing, Sarah counts the money, washes the dishes, and prepares everything for the next day. She usually goes home at 7:30 PM, feeling tired but happy.
    """,
    "questions": [
      {
        "id": 1,
        "question": "What time does Sarah arrive at work?",
        "options": ["6:00 AM", "7:00 AM", "8:00 AM", "9:00 AM"],
        "correctAnswer": "7:00 AM",
        "explanation": "The passage states 'Every morning, she arrives at 7:00 AM to prepare for the day.'"
      },
      {
        "id": 2,
        "question": "What does Sarah do before the coffee shop opens?",
        "options": [
          "Serves customers",
          "Makes fresh coffee and arranges pastries",
          "Counts money",
          "Goes home"
        ],
        "correctAnswer": "Makes fresh coffee and arranges pastries",
        "explanation": "The text mentions she 'makes fresh coffee, arranges pastries in the display case, and cleans the tables' before opening."
      },
      {
        "id": 3,
        "question": "When does the coffee shop get very busy?",
        "options": [
          "In the morning",
          "During lunch time",
          "In the evening",
          "At closing time"
        ],
        "correctAnswer": "During lunch time",
        "explanation": "The passage clearly states 'During lunch time, the shop gets very busy.'"
      },
      {
        "id": 4,
        "question": "Why does Sarah like her job?",
        "options": [
          "Because it pays well",
          "Because it's easy",
          "Because she meets different people",
          "Because she works alone"
        ],
        "correctAnswer": "Because she meets different people",
        "explanation": "The text says 'She likes her job because she meets different people from around the world.'"
      },
      {
        "id": 5,
        "question": "What time does Sarah usually go home?",
        "options": ["6:00 PM", "7:00 PM", "7:30 PM", "8:00 PM"],
        "correctAnswer": "7:30 PM",
        "explanation": "The passage ends with 'She usually goes home at 7:30 PM, feeling tired but happy.'"
      }
    ]
  };

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    _heartAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _heartController,
      curve: Curves.elasticOut,
    ));
    
    _updateProgress();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  void _updateProgress() {
    if (currentQuestionIndex >= 0) {
      final progress = (currentQuestionIndex + 1) / readingData['questions'].length;
      _progressController.animateTo(progress);
    } else {
      _progressController.animateTo(0.0);
    }
  }

  void _answerQuestion(String answer) {
    setState(() {
      userAnswers[currentQuestionIndex] = answer;
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex < readingData['questions'].length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
      _updateProgress();
    } else {
      _completeReading();
    }
  }

  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
      _updateProgress();
    }
  }

  void _completeReading() {
    // Calculate score
    int correctAnswers = 0;
    final questions = readingData['questions'] as List;
    
    for (int i = 0; i < questions.length; i++) {
      if (userAnswers[i] == questions[i]['correctAnswer']) {
        correctAnswers++;
      }
    }
    
    setState(() {
      score = correctAnswers;
      isCompleted = true;
      showResults = true;
      
      // Calculate XP based on performance
      double percentage = (correctAnswers / questions.length) * 100;
      if (percentage >= 90) {
        earnedXP = 50;
      } else if (percentage >= 70) {
        earnedXP = 35;
      } else if (percentage >= 50) {
        earnedXP = 20;
      } else {
        earnedXP = 10;
      }
    });
    
    _heartController.forward().then((_) => _heartController.reverse());
  }

  void _retryReading() {
    setState(() {
      currentQuestionIndex = -1; // Reset to show passage again
      userAnswers.clear();
      isCompleted = false;
      showResults = false;
      score = 0;
      earnedXP = 0;
    });
    _progressController.reset();
    _updateProgress();
  }

  @override
  Widget build(BuildContext context) {
    if (showResults) {
      return _buildResultsScreen();
    }
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: () => context.pop(),
        ),
        title: currentQuestionIndex == -1 
            ? Text(
                'Reading Practice',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              )
            : Row(
                children: [
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return LinearProgressIndicator(
                          value: _progressAnimation.value,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  AnimatedBuilder(
                    animation: _heartAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _heartAnimation.value,
                        child: Row(
                          children: [
                            const Icon(Icons.favorite, color: Colors.red, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              '$hearts',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: currentQuestionIndex == -1 
            ? _buildPassageScreen() 
            : _buildQuestionScreen(),
      ),
    );
  }

  Widget _buildPassageScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                readingData['title'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.timeline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    readingData['level'],
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    readingData['estimatedTime'],
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Reading passage
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                readingData['passage'],
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Start button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                currentQuestionIndex = 0;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Start Questions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionScreen() {
    final questions = readingData['questions'] as List;
    final currentQuestion = questions[currentQuestionIndex];
    final userAnswer = userAnswers[currentQuestionIndex];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    '${currentQuestionIndex + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reading Comprehension',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Question ${currentQuestionIndex + 1} of ${questions.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Question text
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Text(
            currentQuestion['question'],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Answer options
        Expanded(
          child: ListView.builder(
            itemCount: currentQuestion['options'].length,
            itemBuilder: (context, index) {
              final option = currentQuestion['options'][index];
              final isSelected = userAnswer == option;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => _answerQuestion(option),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Theme.of(context).primaryColor.withOpacity(0.1)
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                            ? Theme.of(context).primaryColor
                            : Colors.grey.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected 
                                ? Theme.of(context).primaryColor
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected 
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected 
                                  ? FontWeight.w600 
                                  : FontWeight.normal,
                              color: isSelected 
                                  ? Theme.of(context).primaryColor
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        // Navigation buttons
        Row(
          children: [
            if (currentQuestionIndex > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousQuestion,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Previous'),
                ),
              ),
            if (currentQuestionIndex > 0) const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: userAnswer != null ? _nextQuestion : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  currentQuestionIndex == questions.length - 1 
                      ? 'Complete' 
                      : 'Next',
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
    );
  }

  Widget _buildResultsScreen() {
    final questions = readingData['questions'] as List;
    final totalQuestions = questions.length;
    final percentage = (score / totalQuestions * 100).round();
    
    String performanceText;
    Color performanceColor;
    IconData performanceIcon;
    
    if (percentage >= 90) {
      performanceText = "Excellent!";
      performanceColor = Colors.green;
      performanceIcon = Icons.star;
    } else if (percentage >= 70) {
      performanceText = "Good Job!";
      performanceColor = Colors.blue;
      performanceIcon = Icons.thumb_up;
    } else if (percentage >= 50) {
      performanceText = "Keep Practicing!";
      performanceColor = Colors.orange;
      performanceIcon = Icons.trending_up;
    } else {
      performanceText = "Need More Practice";
      performanceColor = Colors.red;
      performanceIcon = Icons.refresh;
    }
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Performance icon and text
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: performanceColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  performanceIcon,
                  size: 60,
                  color: performanceColor,
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                performanceText,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: performanceColor,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Reading Comprehension Complete',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Score display
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Score:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$score/$totalQuestions ($percentage%)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: performanceColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'XP Earned:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+$earnedXP XP',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Review answers button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _showAnswerReview(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Review Answers',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _retryReading,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Try Again',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _showAnswerReview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Answer Review',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: readingData['questions'].length,
                itemBuilder: (context, index) {
                  final question = readingData['questions'][index];
                  final userAnswer = userAnswers[index];
                  final correctAnswer = question['correctAnswer'];
                  final isCorrect = userAnswer == correctAnswer;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCorrect ? Colors.green : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isCorrect ? Icons.check_circle : Icons.cancel,
                              color: isCorrect ? Colors.green : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Question ${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          question['question'],
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        if (userAnswer != null) ...[
                          Text(
                            'Your answer: $userAnswer',
                            style: TextStyle(
                              color: isCorrect ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (!isCorrect) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Correct answer: $correctAnswer',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            question['explanation'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// To integrate into your app, add this route to your app_router.dart:
/*
GoRoute(
  path: '/reading-practice',
  builder: (context, state) => const ReadingPracticePage(),
),
*/