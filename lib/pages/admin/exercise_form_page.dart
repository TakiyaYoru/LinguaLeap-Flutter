// lib/pages/admin/exercise_form_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lingualeap_app/constants/app_constants.dart';
import 'package:lingualeap_app/models/exercise_model.dart';
import 'package:lingualeap_app/network/exercise_service.dart';
import 'package:lingualeap_app/theme/app_themes.dart';
import 'package:lingualeap_app/routes/app_router.dart';

class ExerciseFormPage extends StatefulWidget {
  final String? exerciseId;
  final String? lessonId;
  final String? unitId;
  final String? courseId;

  const ExerciseFormPage({
    super.key,
    this.exerciseId,
    this.lessonId,
    this.unitId,
    this.courseId,
  });

  @override
  State<ExerciseFormPage> createState() => _ExerciseFormPageState();
}

class _ExerciseFormPageState extends State<ExerciseFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _instructionController = TextEditingController();
  final _questionTextController = TextEditingController();
  final _audioUrlController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _correctFeedbackController = TextEditingController();
  final _incorrectFeedbackController = TextEditingController();
  final _hintController = TextEditingController();

  // AI Generation
  final _aiContextController = TextEditingController();
  bool _isGenerating = false;

  // Multiple Choice
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  int _correctOptionIndex = 0;

  // Fill Blank
  final _sentenceController = TextEditingController();
  final _correctAnswerController = TextEditingController();

  // Translation
  final _sourceTextController = TextEditingController();
  final _targetTextController = TextEditingController();

  // True/False
  final _statementController = TextEditingController();
  bool _isStatementTrue = true; // For true/false exercises

  // Word Matching
  final List<TextEditingController> _wordControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  final List<TextEditingController> _definitionControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  // Sentence Building
  final List<TextEditingController> _wordOrderControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  String _selectedType = 'multiple_choice';
  String _selectedDifficulty = 'beginner';
  String _selectedSkillFocus = 'vocabulary';
  
  int _maxScore = 100;
  int _xpReward = 5;
  int _timeLimit = 0;
  int _estimatedTime = 30;
  int _sortOrder = 1;
  
  bool _requiresAudio = false;
  bool _requiresMicrophone = false;
  bool _isPremium = false;
  bool _isActive = true;
  
  bool _isLoading = false;
  bool _isEditMode = false;

  final List<String> _exerciseTypes = [
    'multiple_choice',
    'fill_blank',
    'listening',
    'translation',
    'speaking',
    'reading',
    'word_matching',
    'sentence_building',
    'true_false',
    'drag_drop',
    'listen_choose',
    'speak_repeat',
  ];

  final List<String> _difficulties = ['beginner', 'intermediate', 'advanced'];
  final List<String> _skillFocuses = [
    'vocabulary',
    'grammar',
    'listening',
    'speaking',
    'reading',
    'writing',
    'pronunciation',
    'comprehension',
  ];



  @override
  void initState() {
    super.initState();
    _isEditMode = widget.exerciseId != null;
    if (_isEditMode) {
      _loadExerciseData();
    }
    _initializeDefaultContent();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _instructionController.dispose();
    _questionTextController.dispose();
    _audioUrlController.dispose();
    _imageUrlController.dispose();
    _videoUrlController.dispose();
    _correctFeedbackController.dispose();
    _incorrectFeedbackController.dispose();
    _hintController.dispose();
    _aiContextController.dispose();
    _sentenceController.dispose();
    _correctAnswerController.dispose();
    _sourceTextController.dispose();
    _targetTextController.dispose();
    _statementController.dispose();
    
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    for (var controller in _wordControllers) {
      controller.dispose();
    }
    for (var controller in _definitionControllers) {
      controller.dispose();
    }
    for (var controller in _wordOrderControllers) {
      controller.dispose();
    }
    
    super.dispose();
  }

  void _initializeDefaultContent() {
    if (!_isEditMode) {
      _correctFeedbackController.text = 'Correct! Well done!';
      _incorrectFeedbackController.text = 'Not quite right. Try again!';
      
      // Set default options for multiple choice
      _optionControllers[0].text = 'Option A';
      _optionControllers[1].text = 'Option B';
      _optionControllers[2].text = 'Option C';
      _optionControllers[3].text = 'Option D';
      
      // Set default sentence for fill blank
      _sentenceController.text = 'Complete the sentence: _____ is the capital of Vietnam.';
      _correctAnswerController.text = 'Hanoi';
      
      // Set default statement for true/false
      _statementController.text = 'This is a true statement.';
      
      // Set default words for matching
      
      // Auto-fill AI suggestion for supported exercise types
      if (_selectedType == 'multiple_choice' || _selectedType == 'fill_blank' || _selectedType == 'true_false' || _selectedType == 'translation' || _selectedType == 'word_matching') {
        _aiContextController.text = _generateAISuggestion();
      }
      _wordControllers[0].text = 'Hello';
      _definitionControllers[0].text = 'Xin chào';
      _wordControllers[1].text = 'Goodbye';
      _definitionControllers[1].text = 'Tạm biệt';
      _wordControllers[2].text = 'Thank you';
      _definitionControllers[2].text = 'Cảm ơn';
      _wordControllers[3].text = 'Please';
      _definitionControllers[3].text = 'Xin vui lòng';
      
      // Set default words for sentence building
      _wordOrderControllers[0].text = 'I';
      _wordOrderControllers[1].text = 'am';
      _wordOrderControllers[2].text = 'a';
      _wordOrderControllers[3].text = 'student';
      _wordOrderControllers[4].text = '.';
    }
  }

  Future<void> _loadExerciseData() async {
    if (widget.exerciseId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final exercise = await ExerciseService.getExercise(widget.exerciseId!);
      if (exercise != null) {
        _titleController.text = exercise.title ?? '';
        _instructionController.text = exercise.instruction;
        _questionTextController.text = exercise.question.text;
        _audioUrlController.text = exercise.question.audioUrl?.toString() ?? '';
        _imageUrlController.text = exercise.question.imageUrl?.toString() ?? '';
        _videoUrlController.text = exercise.question.videoUrl?.toString() ?? '';
        _correctFeedbackController.text = exercise.feedback?.correct?.toString() ?? '';
        _incorrectFeedbackController.text = exercise.feedback?.incorrect?.toString() ?? '';
        _hintController.text = exercise.feedback?.hint?.toString() ?? '';
        
        _selectedType = exercise.type;
        _selectedDifficulty = exercise.difficulty;
        _selectedSkillFocus = exercise.skillFocus.isNotEmpty ? exercise.skillFocus.first : 'vocabulary';
        
        _maxScore = exercise.maxScore;
        _xpReward = exercise.xpReward;
        _timeLimit = exercise.timeLimit ?? 0;
        _estimatedTime = exercise.estimatedTime;
        _sortOrder = exercise.sortOrder;
        
        _requiresAudio = exercise.requiresAudio;
        _requiresMicrophone = exercise.requiresMicrophone;
        _isPremium = exercise.isPremium;
        _isActive = exercise.isActive;

        // Load exercise-specific content
        _loadExerciseSpecificContent(exercise);
      }
    } catch (e) {
      print('❌ Error loading exercise: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load exercise: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadExerciseSpecificContent(ExerciseModel exercise) {
    try {
      final content = exercise.content;
      if (content != null) {
        // Parse content based on exercise type
        switch (exercise.type) {
          case 'multiple_choice':
            if (content['options'] != null && content['options'] is List) {
              final options = content['options'] as List;
              for (int i = 0; i < options.length && i < _optionControllers.length; i++) {
                _optionControllers[i].text = options[i].toString();
              }
            }
            if (content['correctAnswer'] != null) {
              _correctOptionIndex = content['correctAnswer'] as int;
            }
            break;
            
          case 'fill_blank':
            if (content['sentence'] != null) {
              _sentenceController.text = content['sentence'].toString();
            }
            if (content['correctAnswer'] != null) {
              _correctAnswerController.text = content['correctAnswer'].toString();
            }
            break;
            
          case 'true_false':
            if (content['statement'] != null) {
              _statementController.text = content['statement'].toString();
            }
            if (content['isTrue'] != null) {
              _isStatementTrue = content['isTrue'] as bool;
            }
            break;
          case 'translation':
            if (content['sourceText'] != null) {
              _sourceTextController.text = content['sourceText'].toString();
            }
            if (content['targetText'] != null) {
              _targetTextController.text = content['targetText'].toString();
            }
            break;
          case 'word_matching':
            if (content['pairs'] != null && content['pairs'] is List) {
              final pairs = content['pairs'] as List;
              for (int i = 0; i < pairs.length && i < _wordControllers.length; i++) {
                final pair = pairs[i] as Map<String, dynamic>;
                if (pair['word'] != null) {
                  _wordControllers[i].text = pair['word'].toString();
                }
                if (pair['meaning'] != null) {
                  _definitionControllers[i].text = pair['meaning'].toString();
                }
              }
            }
            break;
            
          case 'word_matching':
            if (content['pairs'] != null && content['pairs'] is List) {
              final pairs = content['pairs'] as List;
              for (int i = 0; i < pairs.length && i < _wordControllers.length; i++) {
                final pair = pairs[i] as Map<String, dynamic>;
                if (pair['word'] != null) {
                  _wordControllers[i].text = pair['word'].toString();
                }
                if (pair['meaning'] != null) {
                  _definitionControllers[i].text = pair['meaning'].toString();
                }
              }
            }
            break;
            
          case 'sentence_building':
            if (content['words'] != null && content['words'] is List) {
              final words = content['words'] as List;
              for (int i = 0; i < words.length && i < _wordOrderControllers.length; i++) {
                _wordOrderControllers[i].text = words[i].toString();
              }
            }
            break;
        }
      }
    } catch (e) {
      print('❌ Error loading exercise specific content: $e');
    }
  }

  Map<String, dynamic> _buildExerciseContent() {
    switch (_selectedType) {
      case 'multiple_choice':
        return {
          'options': _optionControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList(),
          'correctAnswer': _correctOptionIndex,
        };
      
      case 'fill_blank':
        return {
          'sentence': _sentenceController.text.trim(),
          'correctAnswer': _correctAnswerController.text.trim(),
        };
      
      case 'translation':
        return {
          'sourceText': _sourceTextController.text.trim(),
          'targetText': _targetTextController.text.trim(),
        };
      
      case 'true_false':
        return {
          'statement': _statementController.text.trim(),
          'isTrue': _isStatementTrue,
        };
      
      case 'word_matching':
        final pairs = <Map<String, String>>[];
        for (int i = 0; i < _wordControllers.length; i++) {
          if (_wordControllers[i].text.trim().isNotEmpty && 
              _definitionControllers[i].text.trim().isNotEmpty) {
            pairs.add({
              'word': _wordControllers[i].text.trim(),
              'meaning': _definitionControllers[i].text.trim(),
            });
          }
        }
        return {
          'pairs': pairs,
          'instruction': 'Ghép từ tiếng Anh với nghĩa tiếng Việt tương ứng',
        };
      
      case 'sentence_building':
        final words = _wordOrderControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
        return {
          'words': words,
          'correctOrder': List.generate(words.length, (index) => index),
        };
      
      default:
        return {};
    }
  }

  String _buildExerciseContentJson() {
    final content = _buildExerciseContent();
    return content.isNotEmpty ? jsonEncode(content) : '{}';
  }

  Future<void> _saveExercise() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      print('🔍 [ExerciseForm] Widget IDs:');
      print('  - courseId: ${widget.courseId} (${widget.courseId.runtimeType})');
      print('  - unitId: ${widget.unitId} (${widget.unitId.runtimeType})');
      print('  - lessonId: ${widget.lessonId} (${widget.lessonId.runtimeType})');
      
      final exerciseData = {
        'title': _titleController.text.trim(),
        'instruction': _instructionController.text.trim(),
        'courseId': widget.courseId?.toString(),
        'unitId': widget.unitId?.toString(),
        'lessonId': widget.lessonId?.toString(),
        'type': _selectedType,
        'skill_focus': [_selectedSkillFocus],
        'question': {
          'text': _questionTextController.text.trim(),
          'audioUrl': _audioUrlController.text.trim().isEmpty ? null : _audioUrlController.text.trim(),
          'imageUrl': _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
          'videoUrl': _videoUrlController.text.trim().isEmpty ? null : _videoUrlController.text.trim(),
        },
        'content': _buildExerciseContentJson(),
        'maxScore': _maxScore,
        'difficulty': _selectedDifficulty,
        'xpReward': _xpReward,
        'timeLimit': _timeLimit > 0 ? _timeLimit : null,
        'estimatedTime': _estimatedTime,
        'requires_audio': _requiresAudio,
        'requires_microphone': _requiresMicrophone,
        'isPremium': _isPremium,
        'isActive': _isActive,
        'sortOrder': _sortOrder,
        'feedback': {
          'correct': _correctFeedbackController.text.trim(),
          'incorrect': _incorrectFeedbackController.text.trim(),
          'hint': _hintController.text.trim(),
        },
        'tags': [],
      };

      if (_isEditMode) {
        await ExerciseService.updateExercise(widget.exerciseId!, exerciseData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exercise updated successfully!')),
        );
      } else {
        await ExerciseService.createExercise(exerciseData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exercise created successfully!')),
        );
      }

      // Navigate back
      if (widget.lessonId != null) {
        context.go('${AppRouter.adminLessonDetail.replaceAll(':lessonId', widget.lessonId!)}');
      } else {
        context.go(AppRouter.adminDashboard);
      }
    } catch (e) {
      print('❌ Error saving exercise: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save exercise: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Exercise' : 'Create Exercise'),
        backgroundColor: AppThemes.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _saveExercise,
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information
                    _buildSectionTitle('Basic Information'),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _instructionController,
                      decoration: const InputDecoration(
                        labelText: 'Instruction *',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter an instruction';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Exercise Type and Settings
                    _buildSectionTitle('Exercise Settings'),
                    const SizedBox(height: 16),
                    
                    // AI Generation Section
                    if (_selectedType == 'multiple_choice' || _selectedType == 'fill_blank' || _selectedType == 'true_false' || _selectedType == 'translation' || _selectedType == 'word_matching') ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.auto_awesome, color: AppThemes.primaryGreen),
                                  const SizedBox(width: 8),
                                  Text(
                                    'AI Generation',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppThemes.primaryGreen,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _aiContextController,
                                      decoration: InputDecoration(
                                        labelText: 'AI Context/Idea',
                                        hintText: _getAIHintText(),
                                        border: const OutlineInputBorder(),
                                      ),
                                      maxLines: 3,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (_selectedType == 'multiple_choice' || _selectedType == 'fill_blank' || _selectedType == 'true_false' || _selectedType == 'translation' || _selectedType == 'word_matching')
                                    IconButton(
                                      onPressed: () {
                                        _aiContextController.text = _generateAISuggestion();
                                      },
                                      icon: const Icon(Icons.auto_fix_high, color: AppThemes.primaryGreen),
                                      tooltip: 'Tự động điền gợi ý',
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _isGenerating ? null : _generateWithAI,
                                  icon: _isGenerating 
                                      ? SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : Icon(Icons.auto_awesome, size: 18),
                                  label: Text(_isGenerating ? 'Generating...' : 'Generate with AI'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppThemes.primaryGreen,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Exercise Type',
                        border: OutlineInputBorder(),
                      ),
                      items: _exerciseTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_getTypeDisplayName(type)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                          // Reset skill focus to first available option for new type
                          final availableSkills = _getSkillFocusOptions();
                          _selectedSkillFocus = availableSkills.isNotEmpty ? availableSkills.first : '';
                          // Auto-fill AI suggestion when exercise type changes
                          if (_selectedType == 'multiple_choice' || _selectedType == 'fill_blank' || _selectedType == 'true_false' || _selectedType == 'translation' || _selectedType == 'word_matching') {
                            _aiContextController.text = _generateAISuggestion();
                          }
                        });
                      },
                    ),


                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            value: _selectedDifficulty,
                            decoration: const InputDecoration(
                              labelText: 'Difficulty',
                              border: OutlineInputBorder(),
                            ),
                            items: _difficulties.map((difficulty) {
                              return DropdownMenuItem(
                                value: difficulty,
                                child: Text(_getDifficultyDisplay(difficulty)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedDifficulty = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            value: _selectedSkillFocus,
                            decoration: const InputDecoration(
                              labelText: 'Skill Focus',
                              border: OutlineInputBorder(),
                            ),
                            items: _getSkillFocusOptions().map((skill) {
                              return DropdownMenuItem(
                                value: skill,
                                child: Text(skill.toUpperCase()),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedSkillFocus = value!;
                                // Auto-fill AI suggestion when skill focus changes
                                if (_selectedType == 'multiple_choice' || _selectedType == 'fill_blank' || _selectedType == 'true_false' || _selectedType == 'translation' || _selectedType == 'word_matching') {
                                  _aiContextController.text = _generateAISuggestion();
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Scoring and Rewards
                    _buildSectionTitle('Scoring & Rewards'),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _maxScore.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Max Score',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              _maxScore = int.tryParse(value) ?? 100;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            initialValue: _xpReward.toString(),
                            decoration: const InputDecoration(
                              labelText: 'XP Reward',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              _xpReward = int.tryParse(value) ?? 5;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Time Settings
                    _buildSectionTitle('Time Settings'),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _timeLimit.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Time Limit (seconds)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              _timeLimit = int.tryParse(value) ?? 0;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            initialValue: _estimatedTime.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Estimated Time (seconds)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              _estimatedTime = int.tryParse(value) ?? 30;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Question Content
                    _buildSectionTitle('Question Content'),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _questionTextController,
                      decoration: InputDecoration(
                        labelText: 'Question Text *',
                        hintText: _getQuestionHintText(),
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter question text';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Dynamic Audio/Image/Video fields based on skill focus
                    if (_shouldShowAudioField()) ...[
                      TextFormField(
                        controller: _audioUrlController,
                        decoration: InputDecoration(
                          labelText: _getAudioLabelText(),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    if (_shouldShowImageField()) ...[
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Image URL (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    if (_shouldShowVideoField()) ...[
                      TextFormField(
                        controller: _videoUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Video URL (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    const SizedBox(height: 16),

                    // Exercise Specific Content
                    _buildSectionTitle('Exercise Content'),
                    const SizedBox(height: 16),
                    _buildExerciseSpecificForm(),
                    const SizedBox(height: 16),

                    // Feedback
                    _buildSectionTitle('Feedback'),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _correctFeedbackController,
                      decoration: const InputDecoration(
                        labelText: 'Correct Answer Feedback',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _incorrectFeedbackController,
                      decoration: const InputDecoration(
                        labelText: 'Incorrect Answer Feedback',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _hintController,
                      decoration: const InputDecoration(
                        labelText: 'Hint',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // Options
                    _buildSectionTitle('Options'),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      initialValue: _sortOrder.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Sort Order',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _sortOrder = int.tryParse(value) ?? 1;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    CheckboxListTile(
                      title: const Text('Requires Audio'),
                      value: _requiresAudio,
                      onChanged: (value) {
                        setState(() {
                          _requiresAudio = value ?? false;
                        });
                      },
                    ),
                    
                    CheckboxListTile(
                      title: const Text('Requires Microphone'),
                      value: _requiresMicrophone,
                      onChanged: (value) {
                        setState(() {
                          _requiresMicrophone = value ?? false;
                        });
                      },
                    ),
                    
                    CheckboxListTile(
                      title: const Text('Premium Content'),
                      value: _isPremium,
                      onChanged: (value) {
                        setState(() {
                          _isPremium = value ?? false;
                        });
                      },
                    ),
                    
                    CheckboxListTile(
                      title: const Text('Active'),
                      value: _isActive,
                      onChanged: (value) {
                        setState(() {
                          _isActive = value ?? true;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveExercise,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppThemes.primaryGreen,
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(_isEditMode ? 'Update Exercise' : 'Create Exercise'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildExerciseSpecificForm() {
    switch (_selectedType) {
      case 'multiple_choice':
        return _buildMultipleChoiceForm();
      case 'fill_blank':
        return _buildFillBlankForm();
      case 'translation':
        return _buildTranslationForm();
      case 'true_false':
        return _buildTrueFalseForm();
      case 'word_matching':
        return _buildWordMatchingForm();
      case 'sentence_building':
        return _buildSentenceBuildingForm();
      case 'listening':
      case 'reading':
        return _buildListeningReadingForm();
      case 'speaking':
      case 'speak_repeat':
        return _buildSpeakingForm();
      case 'drag_drop':
        return _buildDragDropForm();
      case 'listen_choose':
        return _buildListenChooseForm();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMultipleChoiceForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Options:', style: TextStyle(fontWeight: FontWeight.w600, color: AppThemes.lightLabel)),
        const SizedBox(height: 8),
        ...List.generate(4, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Radio<int>(
                  value: index,
                  groupValue: _correctOptionIndex,
                  onChanged: (value) {
                    setState(() {
                      _correctOptionIndex = value!;
                    });
                  },
                ),
                Expanded(
                  child: TextFormField(
                    controller: _optionControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Option ${String.fromCharCode(65 + index)}',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter option ${String.fromCharCode(65 + index)}';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFillBlankForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _sentenceController,
          decoration: const InputDecoration(
            labelText: 'Sentence with blank',
            border: OutlineInputBorder(),
            hintText: 'Complete the sentence: _____ is the capital of Vietnam.',
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter the sentence';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _correctAnswerController,
          decoration: const InputDecoration(
            labelText: 'Correct Answer',
            border: OutlineInputBorder(),
            hintText: 'Hanoi',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter the correct answer';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTranslationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _sourceTextController,
          decoration: const InputDecoration(
            labelText: 'Source Text',
            border: OutlineInputBorder(),
            hintText: 'Hello, how are you?',
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter the source text';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _targetTextController,
          decoration: const InputDecoration(
            labelText: 'Target Translation',
            border: OutlineInputBorder(),
            hintText: 'Xin chào, bạn khỏe không?',
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter the target translation';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTrueFalseForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _statementController,
          decoration: const InputDecoration(
            labelText: 'Statement',
            border: OutlineInputBorder(),
            hintText: 'This is a true statement.',
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter the statement';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text('Correct Answer: ', style: TextStyle(fontWeight: FontWeight.w600, color: AppThemes.lightLabel)),
            const SizedBox(width: 16),
            Row(
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: _isStatementTrue,
                  onChanged: (value) {
                    setState(() {
                      _isStatementTrue = value!;
                    });
                  },
                ),
                const Text('True'),
                const SizedBox(width: 16),
                Radio<bool>(
                  value: false,
                  groupValue: _isStatementTrue,
                  onChanged: (value) {
                    setState(() {
                      _isStatementTrue = value!;
                    });
                  },
                ),
                const Text('False'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWordMatchingForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Word Pairs:', style: TextStyle(fontWeight: FontWeight.w600, color: AppThemes.lightLabel)),
        const SizedBox(height: 8),
        ...List.generate(4, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _wordControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Word ${index + 1}',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, color: AppThemes.primaryGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _definitionControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Definition ${index + 1}',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSentenceBuildingForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Words in correct order:', style: TextStyle(fontWeight: FontWeight.w600, color: AppThemes.lightLabel)),
        const SizedBox(height: 8),
        ...List.generate(5, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextFormField(
              controller: _wordOrderControllers[index],
              decoration: InputDecoration(
                labelText: 'Word ${index + 1}',
                border: const OutlineInputBorder(),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildListeningReadingForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _audioUrlController,
          decoration: const InputDecoration(
            labelText: 'Audio URL *',
            border: OutlineInputBorder(),
            hintText: 'https://example.com/audio.mp3',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter audio URL';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _questionTextController,
          decoration: const InputDecoration(
            labelText: 'Question',
            border: OutlineInputBorder(),
            hintText: 'What did you hear?',
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildSpeakingForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _questionTextController,
          decoration: const InputDecoration(
            labelText: 'Speaking Prompt',
            border: OutlineInputBorder(),
            hintText: 'Repeat after me: "Hello, how are you?"',
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _audioUrlController,
          decoration: const InputDecoration(
            labelText: 'Audio URL (for pronunciation)',
            border: OutlineInputBorder(),
            hintText: 'https://example.com/pronunciation.mp3',
          ),
        ),
      ],
    );
  }

  Widget _buildDragDropForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _questionTextController,
          decoration: const InputDecoration(
            labelText: 'Drag and Drop Instructions',
            border: OutlineInputBorder(),
            hintText: 'Drag the words to form a correct sentence.',
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        Text('Words to drag:', style: TextStyle(fontWeight: FontWeight.w600, color: AppThemes.lightLabel)),
        const SizedBox(height: 8),
        ...List.generate(5, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextFormField(
              controller: _wordOrderControllers[index],
              decoration: InputDecoration(
                labelText: 'Word ${index + 1}',
                border: const OutlineInputBorder(),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildListenChooseForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _audioUrlController,
          decoration: const InputDecoration(
            labelText: 'Audio URL *',
            border: OutlineInputBorder(),
            hintText: 'https://example.com/audio.mp3',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter audio URL';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Text('Options to choose from:', style: TextStyle(fontWeight: FontWeight.w600, color: AppThemes.lightLabel)),
        const SizedBox(height: 8),
        ...List.generate(4, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Radio<int>(
                  value: index,
                  groupValue: _correctOptionIndex,
                  onChanged: (value) {
                    setState(() {
                      _correctOptionIndex = value!;
                    });
                  },
                ),
                Expanded(
                  child: TextFormField(
                    controller: _optionControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Option ${String.fromCharCode(65 + index)}',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _getTypeDisplayName(String type) {
    switch (type) {
      case 'multiple_choice': return 'Multiple Choice';
      case 'fill_blank': return 'Fill in the Blank';
      case 'listening': return 'Listening';
      case 'translation': return 'Translation';
      case 'speaking': return 'Speaking';
      case 'reading': return 'Reading';
      case 'word_matching': return 'Word Matching';
      case 'sentence_building': return 'Sentence Building';
      case 'true_false': return 'True/False';
      case 'drag_drop': return 'Drag & Drop';
      case 'listen_choose': return 'Listen & Choose';
      case 'speak_repeat': return 'Speak & Repeat';
      default: return type.replaceAll('_', ' ').toUpperCase();
    }
  }

  String _getAIHintText() {
    if (_selectedType == 'multiple_choice') {
      return 'Ví dụ: "Tạo câu hỏi về số đếm tiếng Anh", "Bài tập về màu sắc cơ bản", "Câu hỏi về chào hỏi"';
    } else if (_selectedType == 'fill_blank') {
      return 'Ví dụ: "Tạo câu điền từ về chào hỏi", "Bài tập điền từ về số đếm", "Câu điền từ về màu sắc"';
    } else if (_selectedType == 'true_false') {
      return 'Ví dụ: "Tạo câu đúng/sai về chào hỏi", "Bài tập đúng/sai về số đếm", "Câu đúng/sai về màu sắc"';
    } else if (_selectedType == 'translation') {
      return 'Ví dụ: "Tạo bài tập dịch về chào hỏi", "Bài tập dịch về số đếm", "Câu dịch về màu sắc"';
    } else if (_selectedType == 'word_matching') {
      return 'Ví dụ: "Tạo bài tập ghép từ về chào hỏi", "Bài tập ghép từ về số đếm", "Ghép từ về màu sắc"';
    }
    return 'Nhập ý tưởng cho bài tập...';
  }

  // Generate AI suggestion based on exercise type and skill focus
  String _generateAISuggestion() {
    final skillFocusDisplay = _getSkillFocusDisplayName(_selectedSkillFocus);
    
    if (_selectedType == 'multiple_choice') {
      return 'Tạo cho tôi câu hỏi với skill focus là $skillFocusDisplay với chủ đề _____';
    } else if (_selectedType == 'fill_blank') {
      return 'Tạo cho tôi câu điền từ với skill focus là $skillFocusDisplay với chủ đề _____';
    } else if (_selectedType == 'true_false') {
      return 'Tạo cho tôi câu đúng/sai với skill focus là $skillFocusDisplay với chủ đề _____';
    } else if (_selectedType == 'translation') {
      return 'Tạo cho tôi bài tập dịch thuật với skill focus là $skillFocusDisplay với chủ đề _____';
    } else if (_selectedType == 'word_matching') {
      return 'Tạo cho tôi bài tập ghép từ với skill focus là $skillFocusDisplay với chủ đề _____';
    }
    
    return 'Tạo cho tôi bài tập với skill focus là $skillFocusDisplay với chủ đề _____';
  }

  // Get display name for skill focus
  String _getSkillFocusDisplayName(String skillFocus) {
    switch (skillFocus) {
      case 'vocabulary': return 'Vocabulary';
      case 'grammar': return 'Grammar';
      case 'listening': return 'Listening';
      case 'speaking': return 'Speaking';
      case 'reading': return 'Reading';
      case 'writing': return 'Writing';
      case 'pronunciation': return 'Pronunciation';
      case 'fluency': return 'Fluency';
      case 'comprehension': return 'Comprehension';
      case 'syntax': return 'Syntax';
      default: return skillFocus.toUpperCase();
    }
  }

  List<String> _getSkillFocusOptions() {
    switch (_selectedType) {
      case 'multiple_choice':
        return ['vocabulary', 'grammar', 'listening', 'pronunciation'];
      case 'fill_blank':
        return ['vocabulary', 'grammar', 'listening', 'writing'];
      case 'listening':
        return ['listening'];
      case 'translation':
        return ['vocabulary', 'grammar', 'writing'];
      case 'speaking':
        return ['speaking', 'pronunciation', 'fluency'];
      case 'reading':
        return ['vocabulary', 'grammar', 'fluency'];
      case 'word_matching':
        return ['vocabulary'];
      case 'sentence_building':
        return ['vocabulary', 'grammar', 'writing'];
      case 'true_false':
        return ['vocabulary', 'grammar', 'listening'];
      case 'drag_drop':
        return ['vocabulary', 'grammar', 'writing'];
      case 'listen_choose':
        return ['listening'];
      case 'speak_repeat':
        return ['speaking', 'pronunciation', 'fluency'];
      default:
        return ['vocabulary', 'grammar', 'comprehension'];
    }
  }

  String _getQuestionHintText() {
    if (_selectedType == 'fill_blank') {
      return 'Ví dụ: "Điền từ vào chỗ trống", "Complete the sentence"';
    } else if (_selectedType == 'true_false') {
      return 'Ví dụ: "Đọc câu và chọn đúng/sai", "True or False"';
    } else if (_selectedType == 'translation') {
      return 'Ví dụ: "Dịch câu sau sang tiếng Việt", "Translate to Vietnamese"';
    } else if (_selectedType == 'word_matching') {
      return 'Ví dụ: "Ghép từ tiếng Anh với nghĩa tiếng Việt", "Match words with meanings"';
    }
    return 'Nhập câu hỏi cho bài tập...';
  }

  bool _shouldShowAudioField() {
    return true; // Show for all exercise types
  }

  bool _shouldShowImageField() {
    return true; // Show for all exercise types
  }

  bool _shouldShowVideoField() {
    return true; // Show for all exercise types
  }

  String _getAudioLabelText() {
    return 'Audio URL (optional)';
  }

  String _getDefaultQuestionText() {
    if (_selectedType == 'fill_blank') {
      return 'Điền từ vào chỗ trống';
    } else if (_selectedType == 'true_false') {
      return 'Đọc câu và chọn đúng/sai';
    } else if (_selectedType == 'translation') {
      return 'Dịch câu sau sang tiếng Việt';
    } else if (_selectedType == 'word_matching') {
      return 'Ghép từ tiếng Anh với nghĩa tiếng Việt';
    }
    return 'Câu hỏi bài tập';
  }

  String _getDifficultyDisplay(String difficulty) {
    switch (difficulty) {
      case 'beginner': return 'Dễ';
      case 'intermediate': return 'Trung bình';
      case 'advanced': return 'Khó';
      default: return difficulty;
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppThemes.primaryGreen,
      ),
    );
  }

  // AI Generation Methods
  Future<void> _generateWithAI() async {
    if (_aiContextController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập ý tưởng cho AI trước'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      print('🤖 [ExerciseForm] Generating exercise with AI...');
      print('  - Type: $_selectedType');
      print('  - Context: ${_aiContextController.text}');

      // Show loading message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🤖 AI đang tạo bài tập, vui lòng đợi...'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Prepare context with skill focus
      Map<String, dynamic> aiContext = {
        'user_context': _aiContextController.text.trim(),
      };
      
      // Add skill focus for exercises that support it
      if (_selectedSkillFocus.isNotEmpty && _selectedType != 'fill_blank' && _selectedType != 'true_false' && _selectedType != 'translation' && _selectedType != 'word_matching') {
        aiContext['skill_focus'] = [_selectedSkillFocus];
      }

      final generatedExercise = await ExerciseService.generateExercise(
        _selectedType,
        aiContext,
      );

      // Populate form with AI generated data
      _populateFormWithAIData(generatedExercise);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Tạo bài tập thành công! Hãy kiểm tra và chỉnh sửa nếu cần.'),
            backgroundColor: AppThemes.systemGreen,
          ),
        );
      }

    } catch (e) {
      print('❌ [ExerciseForm] Error generating exercise: $e');
      if (mounted) {
        String errorMessage = 'Không thể tạo bài tập';
        if (e.toString().contains('TimeoutException')) {
          errorMessage = 'Hệ thống đang bận, vui lòng thử lại sau';
        } else if (e.toString().contains('No stream event')) {
          errorMessage = 'Kết nối bị gián đoạn, vui lòng thử lại';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  void _populateFormWithAIData(GeneratedExercise generatedExercise) {
    try {
      print('📝 [ExerciseForm] Populating form with AI data...');
      print('📝 [ExerciseForm] Exercise type: ${generatedExercise.type}');
      print('📝 [ExerciseForm] Exercise content: ${generatedExercise.content}');
      
      // Parse content based on exercise type
      if (generatedExercise.type == 'multiple_choice') {
        final content = generatedExercise.content;
        
        // Set question text
        if (content['question'] != null) {
          _questionTextController.text = content['question'].toString();
        }
        
        // Set options
        if (content['options'] != null && content['options'] is List) {
          final options = content['options'] as List;
          for (int i = 0; i < options.length && i < _optionControllers.length; i++) {
            _optionControllers[i].text = options[i].toString();
          }
        }
        
        // Set correct answer
        if (content['correctAnswer'] != null) {
          _correctOptionIndex = content['correctAnswer'] as int;
        }
        
        // Set feedback
        if (content['feedback'] != null) {
          final feedback = content['feedback'] as Map<String, dynamic>;
          if (feedback['correct'] != null) {
            _correctFeedbackController.text = feedback['correct'].toString();
          }
          if (feedback['incorrect'] != null) {
            _incorrectFeedbackController.text = feedback['incorrect'].toString();
          }
          if (feedback['hint'] != null) {
            _hintController.text = feedback['hint'].toString();
          }
        }
      } else if (generatedExercise.type == 'true_false') {
        final content = generatedExercise.content;
        
        // Set statement
        if (content['statement'] != null) {
          _statementController.text = content['statement'].toString();
        }
        
        // Set correct answer
        if (content['isTrue'] != null) {
          _isStatementTrue = content['isTrue'] as bool;
        }
        
        // Set question text based on skill focus
        if (_questionTextController.text.isEmpty) {
          _questionTextController.text = _getDefaultQuestionText();
        }
        
        // Set feedback
        if (content['feedback'] != null) {
          final feedback = content['feedback'] as Map<String, dynamic>;
          if (feedback['correct'] != null) {
            _correctFeedbackController.text = feedback['correct'].toString();
          }
          if (feedback['incorrect'] != null) {
            _incorrectFeedbackController.text = feedback['incorrect'].toString();
          }
          if (feedback['hint'] != null) {
            _hintController.text = feedback['hint'].toString();
          }
        }
      } else if (generatedExercise.type == 'translation') {
        final content = generatedExercise.content;
        
        // Set source text
        if (content['sourceText'] != null) {
          _sourceTextController.text = content['sourceText'].toString();
        }
        
        // Set target text
        if (content['targetText'] != null) {
          _targetTextController.text = content['targetText'].toString();
        }
        
        // Set question text based on skill focus
        if (_questionTextController.text.isEmpty) {
          _questionTextController.text = _getDefaultQuestionText();
        }
        
        // Set feedback
        if (content['feedback'] != null) {
          final feedback = content['feedback'] as Map<String, dynamic>;
          if (feedback['correct'] != null) {
            _correctFeedbackController.text = feedback['correct'].toString();
          }
          if (feedback['incorrect'] != null) {
            _incorrectFeedbackController.text = feedback['incorrect'].toString();
          }
          if (feedback['hint'] != null) {
            _hintController.text = feedback['hint'].toString();
          }
        }
      } else if (generatedExercise.type == 'word_matching') {
        final content = generatedExercise.content;
        print('📝 [ExerciseForm] Word matching content: $content');
        
        // Set word pairs
        if (content['pairs'] != null && content['pairs'] is List) {
          final pairs = content['pairs'] as List;
          print('📝 [ExerciseForm] Word pairs: $pairs');
          for (int i = 0; i < pairs.length && i < _wordControllers.length; i++) {
            final pair = pairs[i] as Map<String, dynamic>;
            if (pair['word'] != null) {
              _wordControllers[i].text = pair['word'].toString();
              print('📝 [ExerciseForm] Set word $i: ${pair['word']}');
            }
            if (pair['meaning'] != null) {
              _definitionControllers[i].text = pair['meaning'].toString();
              print('📝 [ExerciseForm] Set meaning $i: ${pair['meaning']}');
            }
          }
        }
        
        // Set question text based on skill focus
        if (_questionTextController.text.isEmpty) {
          _questionTextController.text = _getDefaultQuestionText();
        }
        
        // Set feedback
        if (content['feedback'] != null) {
          final feedback = content['feedback'] as Map<String, dynamic>;
          if (feedback['correct'] != null) {
            _correctFeedbackController.text = feedback['correct'].toString();
          }
          if (feedback['incorrect'] != null) {
            _incorrectFeedbackController.text = feedback['incorrect'].toString();
          }
          if (feedback['hint'] != null) {
            _hintController.text = feedback['hint'].toString();
          }
        }
      } else if (generatedExercise.type == 'fill_blank') {
        final content = generatedExercise.content;
        
        // Set sentence
        if (content['sentence'] != null) {
          _sentenceController.text = content['sentence'].toString();
        }
        
        // Set correct answer
        if (content['correctAnswer'] != null) {
          _correctAnswerController.text = content['correctAnswer'].toString();
        }
        
        // Set question text based on skill focus
        if (_questionTextController.text.isEmpty) {
          _questionTextController.text = _getDefaultQuestionText();
        }
        
        // Populate skill-specific data for non-fill_blank exercises
        if (_selectedSkillFocus.isNotEmpty && generatedExercise.type != 'fill_blank' && generatedExercise.type != 'true_false' && generatedExercise.type != 'translation' && generatedExercise.type != 'word_matching') {
          print('🎯 [ExerciseForm] Populating skill-specific data for: $_selectedSkillFocus');
          
          // Handle vocabulary data
          if (_selectedSkillFocus == 'vocabulary' && content['vocabulary'] != null) {
            final vocab = content['vocabulary'] as Map<String, dynamic>;
            print('📚 Vocabulary data: $vocab');
          }
          
          // Handle listening data
          if (_selectedSkillFocus == 'listening' && content['listening'] != null) {
            final listening = content['listening'] as Map<String, dynamic>;
            print('🎧 Listening data: $listening');
          }
          
          // Handle reading data
          if (_selectedSkillFocus == 'reading' && content['reading'] != null) {
            final reading = content['reading'] as Map<String, dynamic>;
            print('📖 Reading data: $reading');
          }
          
          // Handle grammar data
          if (_selectedSkillFocus == 'grammar' && content['grammar'] != null) {
            final grammar = content['grammar'] as Map<String, dynamic>;
            print('📝 Grammar data: $grammar');
          }
          
          // Handle pronunciation data
          if (_selectedSkillFocus == 'pronunciation' && content['pronunciation'] != null) {
            final pronunciation = content['pronunciation'] as Map<String, dynamic>;
            print('🗣️ Pronunciation data: $pronunciation');
          }
        }
        
        // Set feedback
        if (content['feedback'] != null) {
          final feedback = content['feedback'] as Map<String, dynamic>;
          if (feedback['correct'] != null) {
            _correctFeedbackController.text = feedback['correct'].toString();
          }
          if (feedback['incorrect'] != null) {
            _incorrectFeedbackController.text = feedback['incorrect'].toString();
          }
          if (feedback['hint'] != null) {
            _hintController.text = feedback['hint'].toString();
          }
        }
      }
      
      // Set vocabulary info if available
      if (generatedExercise.vocabulary != null) {
        final vocab = generatedExercise.vocabulary!;
        if (_titleController.text.isEmpty) {
          _titleController.text = '${vocab.word} - ${vocab.meaning}';
        }
        if (_instructionController.text.isEmpty) {
          _instructionController.text = 'Choose the correct meaning for "${vocab.word}"';
        }
      }
      
      print('✅ [ExerciseForm] Form populated with AI data');
      setState(() {}); // Trigger UI update
      
    } catch (e) {
      print('❌ [ExerciseForm] Error populating form with AI data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Generated data loaded, but some fields may need manual adjustment'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
} 