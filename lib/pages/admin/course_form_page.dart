import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../models/course_model.dart';
import '../../network/admin_service.dart';
import '../../utils/safe_navigator.dart';
import '../../routes/app_router.dart';

class CourseFormPage extends StatefulWidget {
  final CourseModel? course; // null for create, not null for edit
  final String? courseId; // for edit mode

  const CourseFormPage({Key? key, this.course, this.courseId}) : super(key: key);

  @override
  State<CourseFormPage> createState() => _CourseFormPageState();
}

class _CourseFormPageState extends State<CourseFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _colorController = TextEditingController();
  final _estimatedDurationController = TextEditingController();
  final _totalXPController = TextEditingController();
  final _learningObjectivesController = TextEditingController();

  String _selectedLevel = 'A1';
  String _selectedCategory = 'basic_communication';
  String _selectedDifficulty = 'beginner';
  List<String> _selectedSkillFocus = [];
  bool _isPremium = false;
  bool _isLoading = false;

  final List<String> _levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
  final List<String> _categories = [
    'basic_communication',
    'grammar',
    'vocabulary',
    'listening',
    'speaking',
    'reading',
    'writing',
    'business',
    'travel',
    'academic'
  ];
  final List<String> _difficulties = ['beginner', 'intermediate', 'advanced'];
  final List<String> _skillFocusOptions = [
    'vocabulary',
    'grammar',
    'listening',
    'speaking',
    'reading',
    'writing',
    'pronunciation',
    'culture'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.courseId != null && widget.course == null) {
      _loadCourseData();
    } else {
      _initializeForm();
    }
  }

  Future<void> _loadCourseData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Fetch course data from backend
      final courses = await AdminService.getAllCourses();
      final course = courses.firstWhere((c) => c.id == widget.courseId);
      
      setState(() {
        _titleController.text = course.title;
        _descriptionController.text = course.description;
        _colorController.text = course.color;
        _estimatedDurationController.text = course.estimatedDuration.toString();
        _totalXPController.text = course.totalXP.toString();
        _learningObjectivesController.text = course.learningObjectives.join(', ');
        
        _selectedLevel = course.level;
        _selectedCategory = course.category;
        _selectedDifficulty = course.difficulty;
        _selectedSkillFocus = List.from(course.skillFocus);
        _isPremium = course.isPremium;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading course: $e')),
        );
      }
    }
  }

  void _initializeForm() {
    if (widget.course != null) {
      // Edit mode
      _titleController.text = widget.course!.title;
      _descriptionController.text = widget.course!.description;
      _colorController.text = widget.course!.color;
      _estimatedDurationController.text = widget.course!.estimatedDuration.toString();
      _totalXPController.text = widget.course!.totalXP.toString();
      _learningObjectivesController.text = widget.course!.learningObjectives.join(', ');
      
      _selectedLevel = widget.course!.level;
      _selectedCategory = widget.course!.category;
      _selectedDifficulty = widget.course!.difficulty;
      _selectedSkillFocus = List.from(widget.course!.skillFocus);
      _isPremium = widget.course!.isPremium;
    } else {
      // Create mode - set defaults
      _colorController.text = '#4A90E2';
      _estimatedDurationController.text = '10';
      _totalXPController.text = '0';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _colorController.dispose();
    _estimatedDurationController.dispose();
    _totalXPController.dispose();
    _learningObjectivesController.dispose();
    super.dispose();
  }

  void _toggleSkillFocus(String skill) {
    setState(() {
      if (_selectedSkillFocus.contains(skill)) {
        _selectedSkillFocus.remove(skill);
      } else {
        _selectedSkillFocus.add(skill);
      }
    });
  }

  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final learningObjectives = _learningObjectivesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final courseData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'level': _selectedLevel,
        'category': _selectedCategory,
        'skill_focus': _selectedSkillFocus,
        'color': _colorController.text.trim(),
        'estimatedDuration': int.tryParse(_estimatedDurationController.text) ?? 10,
        'totalXP': int.tryParse(_totalXPController.text) ?? 0,
        'isPremium': _isPremium,
        'difficulty': _selectedDifficulty,
        'learningObjectives': learningObjectives,
      };

      if (widget.course != null || widget.courseId != null) {
        // Update existing course
        final courseId = widget.course?.id ?? widget.courseId!;
        await AdminService.updateCourse(courseId, courseData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Course updated successfully!')),
          );
        }
      } else {
        // Create new course
        await AdminService.createCourse(courseData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Course created successfully!')),
          );
        }
      }

      if (mounted) {
        // Use GoRouter to go back to admin dashboard
        context.go(AppRouter.adminDashboard);
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
  Widget build(BuildContext context) {
    final isEditMode = widget.course != null || widget.courseId != null;
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isEditMode ? 'Edit Course' : 'Create Course'),
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Course' : 'Create Course'),
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
                labelText: 'Course Title *',
                border: OutlineInputBorder(),
                hintText: 'Enter course title',
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
                labelText: 'Description *',
                border: OutlineInputBorder(),
                hintText: 'Enter course description',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Course Settings Section
            _buildSectionHeader('Course Settings'),
            const SizedBox(height: 16),
            
            // Level Dropdown
            DropdownButtonFormField<String>(
              value: _selectedLevel,
              decoration: const InputDecoration(
                labelText: 'Level *',
                border: OutlineInputBorder(),
              ),
              items: _levels.map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Text(level),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLevel = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category *',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category.replaceAll('_', ' ').toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Difficulty Dropdown
            DropdownButtonFormField<String>(
              value: _selectedDifficulty,
              decoration: const InputDecoration(
                labelText: 'Difficulty *',
                border: OutlineInputBorder(),
              ),
              items: _difficulties.map((difficulty) {
                return DropdownMenuItem(
                  value: difficulty,
                  child: Text(difficulty.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDifficulty = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Skill Focus Section
            _buildSectionHeader('Skill Focus'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _skillFocusOptions.map((skill) {
                final isSelected = _selectedSkillFocus.contains(skill);
                return FilterChip(
                  label: Text(skill.toUpperCase()),
                  selected: isSelected,
                  onSelected: (_) => _toggleSkillFocus(skill),
                  selectedColor: Colors.blue[100],
                  checkmarkColor: Colors.blue[700],
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Learning Objectives
            TextFormField(
              controller: _learningObjectivesController,
              decoration: const InputDecoration(
                labelText: 'Learning Objectives',
                border: OutlineInputBorder(),
                hintText: 'Enter objectives separated by commas',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Course Details Section
            _buildSectionHeader('Course Details'),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _estimatedDurationController,
                    decoration: const InputDecoration(
                      labelText: 'Duration (hours)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return null;
                      final duration = int.tryParse(value);
                      if (duration == null || duration <= 0) {
                        return 'Please enter a valid duration';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _totalXPController,
                    decoration: const InputDecoration(
                      labelText: 'Total XP',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return null;
                      final xp = int.tryParse(value);
                      if (xp == null || xp < 0) {
                        return 'Please enter valid XP';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _colorController,
              decoration: const InputDecoration(
                labelText: 'Theme Color',
                border: OutlineInputBorder(),
                hintText: '#4A90E2',
                prefixIcon: Icon(Icons.color_lens),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a color';
                }
                if (!RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(value.trim())) {
                  return 'Please enter a valid hex color (e.g., #4A90E2)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Premium Toggle
            SwitchListTile(
              title: const Text('Premium Course'),
              subtitle: const Text('Requires premium subscription'),
              value: _isPremium,
              onChanged: (value) {
                setState(() {
                  _isPremium = value;
                });
              },
              secondary: Icon(
                _isPremium ? Icons.star : Icons.star_border,
                color: _isPremium ? Colors.amber : Colors.grey,
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveCourse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  _isLoading ? 'Saving...' : (isEditMode ? 'Update Course' : 'Create Course'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue[700],
        ),
      ),
    );
  }
} 
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../models/course_model.dart';
import '../../network/admin_service.dart';
import '../../utils/safe_navigator.dart';
import '../../routes/app_router.dart';

class CourseFormPage extends StatefulWidget {
  final CourseModel? course; // null for create, not null for edit
  final String? courseId; // for edit mode

  const CourseFormPage({Key? key, this.course, this.courseId}) : super(key: key);

  @override
  State<CourseFormPage> createState() => _CourseFormPageState();
}

class _CourseFormPageState extends State<CourseFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _colorController = TextEditingController();
  final _estimatedDurationController = TextEditingController();
  final _totalXPController = TextEditingController();
  final _learningObjectivesController = TextEditingController();

  String _selectedLevel = 'A1';
  String _selectedCategory = 'basic_communication';
  String _selectedDifficulty = 'beginner';
  List<String> _selectedSkillFocus = [];
  bool _isPremium = false;
  bool _isLoading = false;

  final List<String> _levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
  final List<String> _categories = [
    'basic_communication',
    'grammar',
    'vocabulary',
    'listening',
    'speaking',
    'reading',
    'writing',
    'business',
    'travel',
    'academic'
  ];
  final List<String> _difficulties = ['beginner', 'intermediate', 'advanced'];
  final List<String> _skillFocusOptions = [
    'vocabulary',
    'grammar',
    'listening',
    'speaking',
    'reading',
    'writing',
    'pronunciation',
    'culture'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.courseId != null && widget.course == null) {
      _loadCourseData();
    } else {
      _initializeForm();
    }
  }

  Future<void> _loadCourseData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Fetch course data from backend
      final courses = await AdminService.getAllCourses();
      final course = courses.firstWhere((c) => c.id == widget.courseId);
      
      setState(() {
        _titleController.text = course.title;
        _descriptionController.text = course.description;
        _colorController.text = course.color;
        _estimatedDurationController.text = course.estimatedDuration.toString();
        _totalXPController.text = course.totalXP.toString();
        _learningObjectivesController.text = course.learningObjectives.join(', ');
        
        _selectedLevel = course.level;
        _selectedCategory = course.category;
        _selectedDifficulty = course.difficulty;
        _selectedSkillFocus = List.from(course.skillFocus);
        _isPremium = course.isPremium;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading course: $e')),
        );
      }
    }
  }

  void _initializeForm() {
    if (widget.course != null) {
      // Edit mode
      _titleController.text = widget.course!.title;
      _descriptionController.text = widget.course!.description;
      _colorController.text = widget.course!.color;
      _estimatedDurationController.text = widget.course!.estimatedDuration.toString();
      _totalXPController.text = widget.course!.totalXP.toString();
      _learningObjectivesController.text = widget.course!.learningObjectives.join(', ');
      
      _selectedLevel = widget.course!.level;
      _selectedCategory = widget.course!.category;
      _selectedDifficulty = widget.course!.difficulty;
      _selectedSkillFocus = List.from(widget.course!.skillFocus);
      _isPremium = widget.course!.isPremium;
    } else {
      // Create mode - set defaults
      _colorController.text = '#4A90E2';
      _estimatedDurationController.text = '10';
      _totalXPController.text = '0';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _colorController.dispose();
    _estimatedDurationController.dispose();
    _totalXPController.dispose();
    _learningObjectivesController.dispose();
    super.dispose();
  }

  void _toggleSkillFocus(String skill) {
    setState(() {
      if (_selectedSkillFocus.contains(skill)) {
        _selectedSkillFocus.remove(skill);
      } else {
        _selectedSkillFocus.add(skill);
      }
    });
  }

  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final learningObjectives = _learningObjectivesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final courseData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'level': _selectedLevel,
        'category': _selectedCategory,
        'skill_focus': _selectedSkillFocus,
        'color': _colorController.text.trim(),
        'estimatedDuration': int.tryParse(_estimatedDurationController.text) ?? 10,
        'totalXP': int.tryParse(_totalXPController.text) ?? 0,
        'isPremium': _isPremium,
        'difficulty': _selectedDifficulty,
        'learningObjectives': learningObjectives,
      };

      if (widget.course != null || widget.courseId != null) {
        // Update existing course
        final courseId = widget.course?.id ?? widget.courseId!;
        await AdminService.updateCourse(courseId, courseData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Course updated successfully!')),
          );
        }
      } else {
        // Create new course
        await AdminService.createCourse(courseData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Course created successfully!')),
          );
        }
      }

      if (mounted) {
        // Use GoRouter to go back to admin dashboard
        context.go(AppRouter.adminDashboard);
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
  Widget build(BuildContext context) {
    final isEditMode = widget.course != null || widget.courseId != null;
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isEditMode ? 'Edit Course' : 'Create Course'),
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Course' : 'Create Course'),
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
                labelText: 'Course Title *',
                border: OutlineInputBorder(),
                hintText: 'Enter course title',
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
                labelText: 'Description *',
                border: OutlineInputBorder(),
                hintText: 'Enter course description',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Course Settings Section
            _buildSectionHeader('Course Settings'),
            const SizedBox(height: 16),
            
            // Level Dropdown
            DropdownButtonFormField<String>(
              value: _selectedLevel,
              decoration: const InputDecoration(
                labelText: 'Level *',
                border: OutlineInputBorder(),
              ),
              items: _levels.map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Text(level),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLevel = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category *',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category.replaceAll('_', ' ').toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Difficulty Dropdown
            DropdownButtonFormField<String>(
              value: _selectedDifficulty,
              decoration: const InputDecoration(
                labelText: 'Difficulty *',
                border: OutlineInputBorder(),
              ),
              items: _difficulties.map((difficulty) {
                return DropdownMenuItem(
                  value: difficulty,
                  child: Text(difficulty.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDifficulty = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Skill Focus Section
            _buildSectionHeader('Skill Focus'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _skillFocusOptions.map((skill) {
                final isSelected = _selectedSkillFocus.contains(skill);
                return FilterChip(
                  label: Text(skill.toUpperCase()),
                  selected: isSelected,
                  onSelected: (_) => _toggleSkillFocus(skill),
                  selectedColor: Colors.blue[100],
                  checkmarkColor: Colors.blue[700],
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Learning Objectives
            TextFormField(
              controller: _learningObjectivesController,
              decoration: const InputDecoration(
                labelText: 'Learning Objectives',
                border: OutlineInputBorder(),
                hintText: 'Enter objectives separated by commas',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Course Details Section
            _buildSectionHeader('Course Details'),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _estimatedDurationController,
                    decoration: const InputDecoration(
                      labelText: 'Duration (hours)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return null;
                      final duration = int.tryParse(value);
                      if (duration == null || duration <= 0) {
                        return 'Please enter a valid duration';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _totalXPController,
                    decoration: const InputDecoration(
                      labelText: 'Total XP',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return null;
                      final xp = int.tryParse(value);
                      if (xp == null || xp < 0) {
                        return 'Please enter valid XP';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _colorController,
              decoration: const InputDecoration(
                labelText: 'Theme Color',
                border: OutlineInputBorder(),
                hintText: '#4A90E2',
                prefixIcon: Icon(Icons.color_lens),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a color';
                }
                if (!RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(value.trim())) {
                  return 'Please enter a valid hex color (e.g., #4A90E2)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Premium Toggle
            SwitchListTile(
              title: const Text('Premium Course'),
              subtitle: const Text('Requires premium subscription'),
              value: _isPremium,
              onChanged: (value) {
                setState(() {
                  _isPremium = value;
                });
              },
              secondary: Icon(
                _isPremium ? Icons.star : Icons.star_border,
                color: _isPremium ? Colors.amber : Colors.grey,
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveCourse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  _isLoading ? 'Saving...' : (isEditMode ? 'Update Course' : 'Create Course'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue[700],
        ),
      ),
    );
  }
} 