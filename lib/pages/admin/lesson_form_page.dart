import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/lesson_model.dart';
import '../../models/course_model.dart';
import '../../models/unit_model.dart';
import '../../network/admin_service.dart';
import '../../utils/safe_navigator.dart';
import '../../routes/app_router.dart';

class LessonFormPage extends StatefulWidget {
  final String? lessonId;
  final String? unitId;
  final String? courseId;

  const LessonFormPage({Key? key, this.lessonId, this.unitId, this.courseId}) : super(key: key);

  @override
  State<LessonFormPage> createState() => _LessonFormPageState();
}

class _LessonFormPageState extends State<LessonFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _objectiveController = TextEditingController();
  final _iconController = TextEditingController();
  final _thumbnailController = TextEditingController();

  String? _selectedCourseId;
  String? _selectedUnitId;
  String _selectedType = 'vocabulary';
  String _selectedLessonType = 'vocabulary';
  String _selectedDifficulty = 'beginner';
  
  List<CourseModel> _courses = [];
  List<UnitModel> _units = [];
  bool _isPremium = false;
  bool _isLoading = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoadingData = true;
      });

      // Load courses and units in parallel
      await Future.wait([
        _loadCourses(),
        _loadUnits(),
      ]);

      // Set default values
      if (widget.courseId != null) {
        _selectedCourseId = widget.courseId;
        await _loadUnitsForCourse(widget.courseId!);
      }
      if (widget.unitId != null) {
        _selectedUnitId = widget.unitId;
      }

      // Load lesson data if editing
      if (widget.lessonId != null) {
        await _loadLessonData();
      } else {
        _initializeForm();
      }

      setState(() {
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingData = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _loadCourses() async {
    try {
      final courses = await AdminService.getAllCourses();
      setState(() {
        _courses = courses;
      });
    } catch (e) {
      print('❌ Error loading courses: $e');
    }
  }

  Future<void> _loadUnits() async {
    try {
      final units = await AdminService.getAllUnits();
      setState(() {
        _units = units;
      });
    } catch (e) {
      print('❌ Error loading units: $e');
    }
  }

  Future<void> _loadUnitsForCourse(String courseId) async {
    try {
      final units = await AdminService.getAllUnits();
      final courseUnits = units.where((u) => u.courseId == courseId).toList();
      setState(() {
        _units = courseUnits;
      });
    } catch (e) {
      print('❌ Error loading units for course: $e');
    }
  }

  Future<void> _loadLessonData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Fetch lesson data from backend
      final lessons = await AdminService.getAllLessons();
      final lesson = lessons.firstWhere((l) => l.id == widget.lessonId);
      
      setState(() {
        _titleController.text = lesson.title;
        _descriptionController.text = lesson.description ?? '';
        _objectiveController.text = lesson.objective ?? '';
        _iconController.text = lesson.icon ?? '';
        _thumbnailController.text = lesson.thumbnail ?? '';
        
        _selectedCourseId = lesson.courseId;
        _selectedUnitId = lesson.unitId;
        _selectedType = lesson.type;
        _selectedLessonType = lesson.lessonType;
        _selectedDifficulty = lesson.difficulty;
        _isPremium = lesson.isPremium;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading lesson: $e')),
        );
      }
    }
  }

  void _initializeForm() {
    // Set default values for new lesson
    _selectedType = 'vocabulary';
    _selectedLessonType = 'vocabulary';
            _selectedDifficulty = 'beginner';
    _isPremium = false;
  }

  Future<void> _saveLesson() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCourseId == null || _selectedUnitId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select course and unit')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final lessonData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'courseId': _selectedCourseId,
        'unitId': _selectedUnitId,
        'type': _selectedType,
        'lesson_type': _selectedLessonType,
        'objective': _objectiveController.text.trim(),
        'icon': _iconController.text.trim().isEmpty ? null : _iconController.text.trim(),
        'thumbnail': _thumbnailController.text.trim().isEmpty ? null : _thumbnailController.text.trim(),
        'difficulty': _selectedDifficulty,
        'isPremium': _isPremium,
        'estimatedDuration': 15, // Default 15 minutes
        'xpReward': 10, // Default 10 XP
        'perfectScoreBonus': 5, // Default 5 XP bonus
        'targetAccuracy': 80, // Default 80%
        'passThreshold': 70, // Default 70%
        'sortOrder': 1, // Default sort order
      };

      if (widget.lessonId != null) {
        // Update existing lesson
        await AdminService.updateLesson(widget.lessonId!, lessonData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lesson updated successfully!')),
          );
        }
                    } else {
        // Create new lesson
        print('🔄 [LessonForm] Creating new lesson...');
        final newLessonData = await AdminService.createLesson(lessonData);
        print('📥 [LessonForm] Create result: $newLessonData');
        
        if (newLessonData != null) {
          final newLesson = LessonModel.fromJson(newLessonData);
          print('✅ [LessonForm] Lesson created successfully: ${newLesson.title}');
          // The parent page will reload when we navigate back
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lesson created successfully!')),
          );
        }
      }

      if (mounted) {
        // Navigate back - same as Course and Unit
        if (widget.unitId != null) {
          context.go('${AppRouter.adminUnitDetail.replaceAll(':unitId', widget.unitId!)}');
        } else {
          context.go(AppRouter.adminDashboard);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _objectiveController.dispose();
    _iconController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.lessonId != null;
    
    if (_isLoadingData) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isEditMode ? 'Edit Lesson' : 'Create Lesson'),
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Lesson' : 'Create Lesson'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Basic Information Section
            _buildSectionHeader('Basic Information'),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Lesson Title *',
                border: OutlineInputBorder(),
                hintText: 'Enter lesson title',
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
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                hintText: 'Enter lesson description',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _objectiveController,
              decoration: const InputDecoration(
                labelText: 'Learning Objective',
                border: OutlineInputBorder(),
                hintText: 'What will students learn?',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Course and Unit Selection
            _buildSectionHeader('Course & Unit Assignment'),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _selectedCourseId,
              decoration: const InputDecoration(
                labelText: 'Course *',
                border: OutlineInputBorder(),
              ),
              items: _courses.map((course) {
                return DropdownMenuItem(
                  value: course.id,
                  child: Text(course.title),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCourseId = value;
                    _selectedUnitId = null; // Reset unit selection
                  });
                  _loadUnitsForCourse(value);
                }
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a course';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedUnitId,
              decoration: const InputDecoration(
                labelText: 'Unit *',
                border: OutlineInputBorder(),
              ),
              items: _units.map((unit) {
                return DropdownMenuItem(
                  value: unit.id,
                  child: Text(unit.title),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedUnitId = value;
                  });
                }
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a unit';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Lesson Settings Section
            _buildSectionHeader('Lesson Settings'),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Lesson Type *',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'vocabulary', child: Text('Vocabulary')),
                DropdownMenuItem(value: 'grammar', child: Text('Grammar')),
                DropdownMenuItem(value: 'listening', child: Text('Listening')),
                DropdownMenuItem(value: 'speaking', child: Text('Speaking')),
                DropdownMenuItem(value: 'reading', child: Text('Reading')),
                DropdownMenuItem(value: 'writing', child: Text('Writing')),
                DropdownMenuItem(value: 'conversation', child: Text('Conversation')),
                DropdownMenuItem(value: 'review', child: Text('Review')),
                DropdownMenuItem(value: 'test', child: Text('Test')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a lesson type';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedLessonType,
              decoration: const InputDecoration(
                labelText: 'Lesson Focus *',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'vocabulary', child: Text('Vocabulary Focus')),
                DropdownMenuItem(value: 'grammar', child: Text('Grammar Focus')),
                DropdownMenuItem(value: 'mixed', child: Text('Mixed Focus')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedLessonType = value;
                  });
                }
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a lesson focus';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedDifficulty,
              decoration: const InputDecoration(
                labelText: 'Difficulty *',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
                DropdownMenuItem(value: 'intermediate', child: Text('Intermediate')),
                DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedDifficulty = value;
                  });
                }
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select difficulty';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Visual Settings
            _buildSectionHeader('Visual Settings'),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _iconController,
              decoration: const InputDecoration(
                labelText: 'Icon (optional)',
                border: OutlineInputBorder(),
                hintText: 'Icon name or URL',
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _thumbnailController,
              decoration: const InputDecoration(
                labelText: 'Thumbnail (optional)',
                border: OutlineInputBorder(),
                hintText: 'Thumbnail URL',
              ),
            ),
            const SizedBox(height: 16),

            // Premium Settings
            _buildSectionHeader('Premium Settings'),
            const SizedBox(height: 16),
            
            SwitchListTile(
              title: const Text('Premium Lesson'),
              subtitle: const Text('Only available to premium users'),
              value: _isPremium,
              onChanged: (value) {
                setState(() {
                  _isPremium = value;
                });
              },
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveLesson,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(isEditMode ? 'Update Lesson' : 'Create Lesson'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }
} 