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

  // Listening-specific fields
  final _audioTextController = TextEditingController();
  final _transcriptionController = TextEditingController();
  final List<TextEditingController> _listeningOptionControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  int _correctListeningOptionIndex = 0;
  bool _isGeneratingAudio = false;

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
    
    // Dispose listening-specific controllers
    _audioTextController.dispose();
    _transcriptionController.dispose();
    for (var controller in _listeningOptionControllers) {
      controller.dispose();
    }
    
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
      if (_selectedType == 'multiple_choice' || _selectedType == 'fill_blank' || _selectedType == 'true_false' || _selectedType == 'translation' || _selectedType == 'word_matching' || _selectedType == 'listening') {
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
          case 'listening':
            if (content['audio_text'] != null) {
              _questionTextController.text = content['audio_text'].toString();
            }
            if (content['audioUrl'] != null) {
              _audioUrlController.text = content['audioUrl'].toString();
            }
            if (content['options'] != null && content['options'] is List) {
              final options = content['options'] as List;
              for (int i = 0; i < options.length && i < _listeningOptionControllers.length; i++) {
                _listeningOptionControllers[i].text = options[i].toString();
              }
            }
            if (content['correctAnswer'] != null) {
              _correctListeningOptionIndex = content['correctAnswer'] as int;
            }
            if (content['transcription'] != null) {
              _transcriptionController.text = content['transcription'].toString();
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
      
      case 'listening':
        return {
          'audio_text': _audioTextController.text.trim(),
          'question': _questionTextController.text.trim(),
          'options': _listeningOptionControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList(),
          'correctAnswer': _correctListeningOptionIndex,
          'transcription': _transcriptionController.text.trim(),
          'audioUrl': _audioUrlController.text.trim().isEmpty ? null : _audioUrlController.text.trim(),
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
      
      case 'speaking':
        return {
          'sentence': _questionTextController.text.trim(),
          'instruction': _instructionController.text.trim(),
          'audio_text': _audioTextController.text.trim(),
          'feedback': {
            'correct': _correctFeedbackController.text.trim(),
            'incorrect': _incorrectFeedbackController.text.trim(),
            'hint': _hintController.text.trim(),
          },
          'skill_focus': _selectedSkillFocus,
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
      backgroundColor: AppThemes.lightGroupedBackground,
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Exercise' : 'Create Exercise',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppThemes.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Show confirmation dialog if there are unsaved changes
            if (_hasUnsavedChanges()) {
              _showDiscardChangesDialog();
            } else {
              _navigateBack();
            }
          },
        ),
        actions: [
          if (!_isLoading) ...[
            TextButton(
              onPressed: () {
                // Show confirmation dialog if there are unsaved changes
                if (_hasUnsavedChanges()) {
                  _showDiscardChangesDialog();
                } else {
                  _navigateBack();
                }
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white, 
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: _saveExercise,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.white, 
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppThemes.primaryGreen,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information
                    _buildSectionCard('Basic Information', [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
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
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter an instruction';
                          }
                          return null;
                        },
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // Exercise Type and Settings
                    _buildSectionCard('Exercise Settings', [
                      // AI Generation Section
                      if (_selectedType == 'multiple_choice' || _selectedType == 'fill_blank' || _selectedType == 'true_false' || _selectedType == 'translation' || _selectedType == 'word_matching' || _selectedType == 'listening' || _selectedType == 'speaking') ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppThemes.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppThemes.primaryGreen.withOpacity(0.3),
                            ),
                          ),
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
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      maxLines: 3,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (_selectedType == 'multiple_choice' || _selectedType == 'fill_blank' || _selectedType == 'true_false' || _selectedType == 'translation' || _selectedType == 'word_matching' || _selectedType == 'listening' || _selectedType == 'speaking')
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
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Exercise Type',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
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
                            if (_selectedType == 'multiple_choice' || _selectedType == 'fill_blank' || _selectedType == 'true_false' || _selectedType == 'translation' || _selectedType == 'word_matching' || _selectedType == 'listening' || _selectedType == 'speaking') {
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
                                filled: true,
                                fillColor: Colors.white,
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
                                filled: true,
                                fillColor: Colors.white,
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
                                  if (_selectedType == 'multiple_choice' || _selectedType == 'fill_blank' || _selectedType == 'true_false' || _selectedType == 'translation' || _selectedType == 'word_matching' || _selectedType == 'listening' || _selectedType == 'speaking') {
                                    _aiContextController.text = _generateAISuggestion();
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // Scoring and Rewards
                    _buildSectionCard('Scoring & Rewards', [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: _maxScore.toString(),
                              decoration: const InputDecoration(
                                labelText: 'Max Score',
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
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
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                _xpReward = int.tryParse(value) ?? 5;
                              },
                            ),
                          ),
                        ],
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // Time Settings
                    _buildSectionCard('Time Settings', [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: _timeLimit.toString(),
                              decoration: const InputDecoration(
                                labelText: 'Time Limit (seconds)',
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
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
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                _estimatedTime = int.tryParse(value) ?? 30;
                              },
                            ),
                          ),
                        ],
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // Question Content
                    _buildSectionCard('Question Content', [
                      TextFormField(
                        controller: _questionTextController,
                        decoration: InputDecoration(
                          labelText: 'Question Text *',
                          hintText: _getQuestionHintText(),
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
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
                            filled: true,
                            fillColor: Colors.white,
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
                            filled: true,
                            fillColor: Colors.white,
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
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ]),
                    const SizedBox(height: 16),

                    // Exercise Specific Content
                    _buildSectionCard('Exercise Content', [
                      _buildExerciseSpecificForm(),
                    ]),
                    const SizedBox(height: 16),

                    // Feedback
                    _buildSectionCard('Feedback', [
                      TextFormField(
                        controller: _correctFeedbackController,
                        decoration: const InputDecoration(
                          labelText: 'Correct Answer Feedback',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _incorrectFeedbackController,
                        decoration: const InputDecoration(
                          labelText: 'Incorrect Answer Feedback',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _hintController,
                        decoration: const InputDecoration(
                          labelText: 'Hint',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        maxLines: 2,
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // Options
                    _buildSectionCard('Options', [
                      TextFormField(
                        initialValue: _sortOrder.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Sort Order',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _sortOrder = int.tryParse(value) ?? 1;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            CheckboxListTile(
                              title: const Text('Requires Audio'),
                              value: _requiresAudio,
                              onChanged: (value) {
                                setState(() {
                                  _requiresAudio = value ?? false;
                                });
                              },
                            ),
                            Divider(height: 1, color: Colors.grey.shade200),
                            CheckboxListTile(
                              title: const Text('Requires Microphone'),
                              value: _requiresMicrophone,
                              onChanged: (value) {
                                setState(() {
                                  _requiresMicrophone = value ?? false;
                                });
                              },
                            ),
                            Divider(height: 1, color: Colors.grey.shade200),
                            CheckboxListTile(
                              title: const Text('Premium Content'),
                              value: _isPremium,
                              onChanged: (value) {
                                setState(() {
                                  _isPremium = value ?? false;
                                });
                              },
                            ),
                            Divider(height: 1, color: Colors.grey.shade200),
                            CheckboxListTile(
                              title: const Text('Active'),
                              value: _isActive,
                              onChanged: (value) {
                                setState(() {
                                  _isActive = value ?? true;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ]),
                    
                    const SizedBox(height: 32),
                    
                    // Save Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppThemes.primaryGreen.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveExercise,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppThemes.primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _isEditMode ? Icons.save : Icons.add,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isEditMode ? 'Update Exercise' : 'Create Exercise',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
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
        Text(
          'Options:', 
          style: TextStyle(
            fontWeight: FontWeight.w600, 
            color: AppThemes.lightLabel,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(4, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
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
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            filled: true,
            fillColor: Colors.white,
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
            filled: true,
            fillColor: Colors.white,
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
        Text(
          'Word Pairs:', 
          style: TextStyle(
            fontWeight: FontWeight.w600, 
            color: AppThemes.lightLabel,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(4, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _wordControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Word ${index + 1}',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppThemes.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward, 
                    color: AppThemes.primaryGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _definitionControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Definition ${index + 1}',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
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
    // Check if this is a listening exercise
    final isListening = _selectedType == 'listening';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Audio Text Field for TTS (only for listening)
        if (isListening) ...[
          TextFormField(
            controller: _audioTextController,
            decoration: const InputDecoration(
              labelText: 'Audio Text (for TTS) *',
              border: OutlineInputBorder(),
              hintText: 'Enter the text that will be converted to audio...',
              helperText: 'This text will be converted to speech for the listening exercise',
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter audio text';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Generate Audio Button
          ElevatedButton.icon(
            onPressed: _isGeneratingAudio ? null : _generateAudioFromText,
            icon: _isGeneratingAudio 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.volume_up),
            label: Text(_isGeneratingAudio ? 'Generating Audio...' : 'Generate Audio from Text'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemes.systemBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          
          // Audio URL Field (auto-filled after generation)
          TextFormField(
            controller: _audioUrlController,
            decoration: const InputDecoration(
              labelText: 'Audio URL (auto-generated)',
              border: OutlineInputBorder(),
              hintText: 'Will be filled automatically after generating audio',
              helperText: 'This URL will be used to play the audio in the exercise',
            ),
            readOnly: true,
          ),
          const SizedBox(height: 16),
          
          // Transcription Field (for listening exercises)
          TextFormField(
            controller: _transcriptionController,
            decoration: const InputDecoration(
              labelText: 'Transcription (Optional)',
              border: OutlineInputBorder(),
              hintText: 'Enter the exact transcription of the audio...',
              helperText: 'This will be shown to students after they answer',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
        ],
        
        // Question Field
        TextFormField(
          controller: _questionTextController,
          decoration: InputDecoration(
            labelText: isListening ? 'Question for Students' : 'Reading Passage',
            border: const OutlineInputBorder(),
            hintText: isListening ? 'What did you hear?' : 'Enter the reading passage...',
            helperText: isListening 
              ? 'Question students will see after listening to the audio'
              : 'The text students will read',
          ),
          maxLines: isListening ? 2 : 5,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return isListening ? 'Please enter the question' : 'Please enter the reading passage';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Options Section (for listening exercises)
        if (isListening) ...[
          Text('Answer Options:', style: TextStyle(fontWeight: FontWeight.w600, color: AppThemes.lightLabel)),
          const SizedBox(height: 8),
          ...List.generate(4, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Radio<int>(
                    value: index,
                    groupValue: _correctListeningOptionIndex,
                    onChanged: (value) {
                      setState(() {
                        _correctListeningOptionIndex = value!;
                      });
                    },
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _listeningOptionControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Option ${String.fromCharCode(65 + index)}',
                        border: const OutlineInputBorder(),
                        hintText: 'Enter option ${String.fromCharCode(65 + index)}',
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
        
        // Reading-specific fields
        if (!isListening) ...[
          Text('Reading Questions:', style: TextStyle(fontWeight: FontWeight.w600, color: AppThemes.lightLabel)),
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
                        labelText: 'Question ${index + 1}',
                        border: const OutlineInputBorder(),
                        hintText: 'Enter question ${index + 1}',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter question ${index + 1}';
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
      ],
    );
  }

  Widget _buildSpeakingForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sentence to speak
        TextFormField(
          controller: _questionTextController,
          decoration: const InputDecoration(
            labelText: 'Câu/Từ cần nói *',
            border: OutlineInputBorder(),
            hintText: 'Hello',
          ),
          maxLines: 2,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập câu/từ cần nói';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Instruction
        TextFormField(
          controller: _instructionController,
          decoration: const InputDecoration(
            labelText: 'Hướng dẫn',
            border: OutlineInputBorder(),
            hintText: 'Đọc câu/từ này',
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        
        // Audio text (for TTS)
        TextFormField(
          controller: _audioTextController,
          decoration: const InputDecoration(
            labelText: 'Audio Text (cho TTS)',
            border: OutlineInputBorder(),
            hintText: 'Text để chuyển thành giọng nói (giống câu trên)',
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        
        // Feedback section
        Text(
          'Feedback',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppThemes.primaryGreen,
          ),
        ),
        const SizedBox(height: 12),
        
        TextFormField(
          controller: _correctFeedbackController,
          decoration: const InputDecoration(
            labelText: 'Feedback đúng',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            hintText: 'Tuyệt vời! Phát âm chính xác',
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _incorrectFeedbackController,
          decoration: const InputDecoration(
            labelText: 'Feedback sai',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            hintText: 'Hãy thử lại',
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _hintController,
          decoration: const InputDecoration(
            labelText: 'Gợi ý',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            hintText: 'Nói chậm và rõ ràng',
          ),
          maxLines: 2,
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
    switch (_selectedType) {
      case 'multiple_choice':
        return "Tạo cho tôi bài tập multiple choice về chủ đề _____";
      case 'fill_blank':
        return "Tạo cho tôi bài tập điền từ về chủ đề _____";
      case 'listening':
        return "Tạo cho tôi bài tập listening tập trung vào từ vựng với chủ đề _____";
      case 'speaking':
        if (_selectedSkillFocus == 'pronunciation') {
          return "Tạo cho tôi bài tập speaking tập trung vào phát âm với chủ đề _____";
        } else if (_selectedSkillFocus == 'fluency') {
          return "Tạo cho tôi bài tập speaking tập trung vào fluency với chủ đề _____";
        } else {
          return "Tạo cho tôi bài tập speaking với chủ đề _____";
        }
      case 'translation':
        return "Tạo cho tôi bài tập dịch về chủ đề _____";
      case 'true_false':
        return "Tạo cho tôi bài tập đúng/sai về chủ đề _____";
      default:
        return "Tạo cho tôi bài tập về chủ đề _____";
    }
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
      case 'listening':
        return ['listening', 'vocabulary', 'grammar'];
      case 'speaking':
        return ['pronunciation', 'fluency', 'intonation'];
      case 'fill_blank':
        return ['vocabulary', 'grammar'];
      case 'true_false':
        return ['vocabulary', 'listening', 'grammar'];
      default:
        return ['vocabulary', 'grammar', 'listening', 'speaking', 'reading', 'writing', 'pronunciation', 'comprehension'];
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

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppThemes.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getSectionIcon(title),
                    color: AppThemes.primaryGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppThemes.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  IconData _getSectionIcon(String title) {
    switch (title.toLowerCase()) {
      case 'basic information':
        return Icons.info_outline;
      case 'exercise settings':
        return Icons.settings;
      case 'scoring & rewards':
        return Icons.star;
      case 'time settings':
        return Icons.access_time;
      case 'question content':
        return Icons.question_answer;
      case 'exercise content':
        return Icons.fitness_center;
      case 'feedback':
        return Icons.feedback;
      case 'options':
        return Icons.tune;
      default:
        return Icons.settings;
    }
  }

  // Audio Generation Methods
  Future<void> _generateAudioFromText() async {
    if (_audioTextController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập text để tạo audio trước'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isGeneratingAudio = true;
    });

    try {
      print('🔊 [ExerciseForm] Generating audio from text...');
      print('  - Text: ${_audioTextController.text}');

      // Show loading message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔊 Đang tạo audio, vui lòng đợi...'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Generate audio using TTS
      final audioResult = await ExerciseService.generateAudio(
        _audioTextController.text.trim(),
      );

      // Update audio URL field
      setState(() {
        _audioUrlController.text = audioResult.audioUrl;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Tạo audio thành công!'),
            backgroundColor: AppThemes.systemGreen,
          ),
        );
      }

    } catch (e) {
      print('❌ [ExerciseForm] Error generating audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi tạo audio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isGeneratingAudio = false;
      });
    }
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
      if (_selectedSkillFocus.isNotEmpty) {
        if (_selectedType == 'listening') {
          // Listening supports vocabulary and grammar skill focus
          if (['vocabulary', 'grammar'].contains(_selectedSkillFocus)) {
            aiContext['skill_focus'] = [_selectedSkillFocus];
            aiContext['topic'] = _getTopicFromContext(_aiContextController.text.trim());
          }
        } else if (_selectedType == 'true_false') {
          // True/false supports vocabulary, listening, and grammar skill focus
          if (['vocabulary', 'listening', 'grammar'].contains(_selectedSkillFocus)) {
            aiContext['skill_focus'] = [_selectedSkillFocus];
          }
        } else if (_selectedType != 'fill_blank' && _selectedType != 'translation' && _selectedType != 'word_matching') {
          // Other exercises support general skill focus
          aiContext['skill_focus'] = [_selectedSkillFocus];
        }
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
      } else if (generatedExercise.type == 'listening') {
        final content = generatedExercise.content;
        print('🎧 [ExerciseForm] Listening content: $content');
        
        // Set audio text
        if (content['audio_text'] != null) {
          _audioTextController.text = content['audio_text'].toString();
        }
        
        // Set question
        if (content['question'] != null) {
          _questionTextController.text = content['question'].toString();
        }
        
        // Set options
        if (content['options'] != null && content['options'] is List) {
          final options = content['options'] as List;
          for (int i = 0; i < options.length && i < _listeningOptionControllers.length; i++) {
            _listeningOptionControllers[i].text = options[i].toString();
          }
        }
        
        // Set correct answer
        if (content['correctAnswer'] != null) {
          _correctListeningOptionIndex = content['correctAnswer'] as int;
        }
        
        // Set transcription
        if (content['transcription'] != null) {
          _transcriptionController.text = content['transcription'].toString();
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
        
        // Handle listening-specific data
        if (content['listening_focus'] != null) {
          final listeningFocus = content['listening_focus'] as Map<String, dynamic>;
          print('🎧 Listening focus data: $listeningFocus');
          
          // Set audio URL if available
          if (listeningFocus['audio_url'] != null) {
            _audioUrlController.text = listeningFocus['audio_url'].toString();
          }
        }
        
        // Handle skill-specific data for listening
        if (_selectedSkillFocus.isNotEmpty) {
          print('🎯 [ExerciseForm] Populating skill-specific data for listening: $_selectedSkillFocus');
          
          // Handle vocabulary listening data
          if (_selectedSkillFocus == 'vocabulary' && content['vocabulary_focus'] != null) {
            final vocabFocus = content['vocabulary_focus'] as Map<String, dynamic>;
            print('📚 Vocabulary listening data: $vocabFocus');
            
            // Set title with vocabulary info
            if (vocabFocus['target_word'] != null && _titleController.text.isEmpty) {
              _titleController.text = 'Listening: ${vocabFocus['target_word']}';
            }
          }
          
          // Handle grammar listening data
          if (_selectedSkillFocus == 'grammar' && content['grammar_focus'] != null) {
            final grammarFocus = content['grammar_focus'] as Map<String, dynamic>;
            print('📝 Grammar listening data: $grammarFocus');
            
            // Set title with grammar info
            if (grammarFocus['grammar_point'] != null && _titleController.text.isEmpty) {
              _titleController.text = 'Listening: ${grammarFocus['grammar_point']}';
            }
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

  String _getTopicFromContext(String context) {
    // Simple topic extraction from context
    final lowerContext = context.toLowerCase();
    
    if (lowerContext.contains('food') || lowerContext.contains('eat') || lowerContext.contains('apple') || lowerContext.contains('fruit')) {
      return 'food';
    } else if (lowerContext.contains('greet') || lowerContext.contains('hello') || lowerContext.contains('hi')) {
      return 'greetings';
    } else if (lowerContext.contains('family') || lowerContext.contains('mother') || lowerContext.contains('father')) {
      return 'family';
    } else if (lowerContext.contains('color') || lowerContext.contains('red') || lowerContext.contains('blue')) {
      return 'colors';
    } else if (lowerContext.contains('number') || lowerContext.contains('count') || lowerContext.contains('one') || lowerContext.contains('two')) {
      return 'numbers';
    } else if (lowerContext.contains('animal') || lowerContext.contains('dog') || lowerContext.contains('cat')) {
      return 'animals';
    } else if (lowerContext.contains('school') || lowerContext.contains('study') || lowerContext.contains('learn')) {
      return 'education';
    } else if (lowerContext.contains('work') || lowerContext.contains('job') || lowerContext.contains('office')) {
      return 'work';
    } else if (lowerContext.contains('home') || lowerContext.contains('house') || lowerContext.contains('room')) {
      return 'home';
    } else if (lowerContext.contains('time') || lowerContext.contains('clock') || lowerContext.contains('hour')) {
      return 'time';
    } else if (lowerContext.contains('weather') || lowerContext.contains('sunny') || lowerContext.contains('rain')) {
      return 'weather';
    } else if (lowerContext.contains('travel') || lowerContext.contains('trip') || lowerContext.contains('vacation')) {
      return 'travel';
    } else if (lowerContext.contains('shopping') || lowerContext.contains('buy') || lowerContext.contains('store')) {
      return 'shopping';
    } else if (lowerContext.contains('sport') || lowerContext.contains('game') || lowerContext.contains('play')) {
      return 'sports';
    } else if (lowerContext.contains('music') || lowerContext.contains('song') || lowerContext.contains('sing')) {
      return 'music';
    } else if (lowerContext.contains('movie') || lowerContext.contains('film') || lowerContext.contains('watch')) {
      return 'entertainment';
    } else if (lowerContext.contains('health') || lowerContext.contains('doctor') || lowerContext.contains('hospital')) {
      return 'health';
    } else if (lowerContext.contains('transport') || lowerContext.contains('car') || lowerContext.contains('bus')) {
      return 'transportation';
    } else if (lowerContext.contains('clothes') || lowerContext.contains('shirt') || lowerContext.contains('dress')) {
      return 'clothing';
    } else if (lowerContext.contains('body') || lowerContext.contains('head') || lowerContext.contains('hand')) {
      return 'body_parts';
    } else if (lowerContext.contains('emotion') || lowerContext.contains('happy') || lowerContext.contains('sad')) {
      return 'emotions';
    } else if (lowerContext.contains('daily') || lowerContext.contains('routine') || lowerContext.contains('morning')) {
      return 'daily_activities';
    } else {
      return 'general';
    }
  }

  // Navigation and unsaved changes handling
  bool _hasUnsavedChanges() {
    // Check if any field has been modified
    return _titleController.text.isNotEmpty ||
           _instructionController.text.isNotEmpty ||
           _questionTextController.text.isNotEmpty ||
           _aiContextController.text.isNotEmpty ||
           _correctFeedbackController.text != 'Correct! Well done!' ||
           _incorrectFeedbackController.text != 'Not quite right. Try again!' ||
           _hintController.text.isNotEmpty ||
           _audioUrlController.text.isNotEmpty ||
           _imageUrlController.text.isNotEmpty ||
           _videoUrlController.text.isNotEmpty ||
           _audioTextController.text.isNotEmpty ||
           _transcriptionController.text.isNotEmpty ||
           _sentenceController.text.isNotEmpty ||
           _correctAnswerController.text.isNotEmpty ||
           _sourceTextController.text.isNotEmpty ||
           _targetTextController.text.isNotEmpty ||
           _statementController.text.isNotEmpty ||
           _optionControllers.any((controller) => controller.text.isNotEmpty) ||
           _listeningOptionControllers.any((controller) => controller.text.isNotEmpty) ||
           _wordControllers.any((controller) => controller.text.isNotEmpty) ||
           _definitionControllers.any((controller) => controller.text.isNotEmpty) ||
           _wordOrderControllers.any((controller) => controller.text.isNotEmpty);
  }

  void _showDiscardChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text('You have unsaved changes. Are you sure you want to leave without saving?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateBack();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  void _navigateBack() {
    if (widget.lessonId != null) {
      context.go('${AppRouter.adminLessonDetail.replaceAll(':lessonId', widget.lessonId!)}');
    } else {
      context.go(AppRouter.adminDashboard);
    }
  }
} 
