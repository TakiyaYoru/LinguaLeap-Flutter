import 'package:flutter/material.dart';
import '../../theme/app_themes.dart';

class WordMatchingWidget extends StatefulWidget {
  final Map<String, dynamic> content;
  final Map<String, dynamic> question;
  final Function(dynamic) onAnswerSubmitted;
  final Map<String, dynamic>? controllerState;

  const WordMatchingWidget({
    Key? key,
    required this.content,
    required this.question,
    required this.onAnswerSubmitted,
    this.controllerState,
  }) : super(key: key);

  @override
  State<WordMatchingWidget> createState() => _WordMatchingWidgetState();
}

class _WordMatchingWidgetState extends State<WordMatchingWidget> {
  // Word Matching State Variables
  Map<int, String> _wordMatchingSelections = {}; // wordIndex -> selectedMeaning
  Map<int, bool> _wordMatchingCompleted = {}; // wordIndex -> isCompleted
  Map<int, bool> _wordMatchingCorrect = {}; // wordIndex -> isCorrect
  List<String> _wordMatchingAvailableMeanings = []; // Available meanings for selection
  List<String> _wordMatchingOriginalMeanings = []; // Original meanings in order
  List<Map<String, dynamic>> _wordMatchingPairs = []; // Original pairs

  @override
  void initState() {
    super.initState();
    _initializeWordMatching();
    
    // Restore state if available
    if (widget.controllerState != null) {
      _wordMatchingSelections = Map<int, String>.from(widget.controllerState!['selections'] ?? {});
      _wordMatchingCompleted = Map<int, bool>.from(widget.controllerState!['completed'] ?? {});
      _wordMatchingCorrect = Map<int, bool>.from(widget.controllerState!['correct'] ?? {});
      _wordMatchingAvailableMeanings = List<String>.from(widget.controllerState!['availableMeanings'] ?? []);
      _wordMatchingOriginalMeanings = List<String>.from(widget.controllerState!['originalMeanings'] ?? []);
      _wordMatchingPairs = List<Map<String, dynamic>>.from(widget.controllerState!['pairs'] ?? []);
    }
  }

  void _initializeWordMatching() {
    if (_wordMatchingPairs.isEmpty) {
      final pairs = widget.content['pairs'] as List<dynamic>? ?? [];
      _wordMatchingPairs = List<Map<String, dynamic>>.from(pairs);
      _wordMatchingOriginalMeanings = pairs.map((pair) => pair['meaning'] as String).toList();
      _wordMatchingAvailableMeanings = List<String>.from(_wordMatchingOriginalMeanings)..shuffle();
      _wordMatchingSelections.clear();
      _wordMatchingCompleted.clear();
      _wordMatchingCorrect.clear();
    }
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
      
      // If all correct, submit the answer
      if (allCorrect) {
        widget.onAnswerSubmitted(_wordMatchingSelections);
      } else {
        // If any wrong, show feedback and reset wrong answers
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

  @override
  Widget build(BuildContext context) {
    final instruction = widget.content['instruction'] as String? ?? 'Ghép từ tiếng Anh với nghĩa tiếng Việt';
    
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
} 