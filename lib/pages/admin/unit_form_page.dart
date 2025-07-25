import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../models/unit_model.dart';
import '../../models/course_model.dart';
import '../../network/admin_service.dart';
import '../../utils/safe_navigator.dart';
import '../../routes/app_router.dart';

class UnitFormPage extends StatefulWidget {
  final UnitModel? unit; // null for create, not null for edit
  final String? unitId; // for edit mode
  final String? courseId; // for create mode

  const UnitFormPage({Key? key, this.unit, this.unitId, this.courseId}) : super(key: key);

  @override
  State<UnitFormPage> createState() => _UnitFormPageState();
}

class _UnitFormPageState extends State<UnitFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedTheme = 'daily_life';
  final _iconController = TextEditingController();
  final _colorController = TextEditingController();
  final _estimatedDurationController = TextEditingController();
  final _xpRewardController = TextEditingController();
  final _sortOrderController = TextEditingController();

  String? _selectedCourseId;
  List<CourseModel> _courses = [];
  bool _isPremium = false;
  bool _isLoading = false;
  bool _isLoadingCourses = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
    if (widget.unitId != null && widget.unit == null) {
      _loadUnitData();
    } else {
      _initializeForm();
    }
  }

  Future<void> _loadCourses() async {
    try {
      final courses = await AdminService.getAllCourses();
      setState(() {
        _courses = courses;
        _isLoadingCourses = false;
      });
      
      // Set default course if provided
      if (widget.courseId != null) {
        _selectedCourseId = widget.courseId;
      }
    } catch (e) {
      setState(() {
        _isLoadingCourses = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading courses: $e')),
        );
      }
    }
  }

  Future<void> _loadUnitData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Fetch unit data from backend
      final units = await AdminService.getAllUnits();
      final unit = units.firstWhere((u) => u.id == widget.unitId);
      
      setState(() {
        _titleController.text = unit.title;
        _descriptionController.text = unit.description;
        _selectedTheme = unit.theme;
        _iconController.text = unit.icon ?? '';
        _colorController.text = unit.color;
        _estimatedDurationController.text = unit.estimatedDuration.toString();
        _xpRewardController.text = unit.xpReward.toString();
        _sortOrderController.text = unit.sortOrder.toString();
        
        _selectedCourseId = unit.courseId;
        _isPremium = unit.isPremium;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading unit: $e')),
        );
      }
    }
  }

  void _initializeForm() {
    if (widget.unit != null) {
      // Edit mode
      _titleController.text = widget.unit!.title;
      _descriptionController.text = widget.unit!.description;
              _selectedTheme = widget.unit!.theme;
      _iconController.text = widget.unit!.icon ?? '';
      _colorController.text = widget.unit!.color;
      _estimatedDurationController.text = widget.unit!.estimatedDuration.toString();
      _xpRewardController.text = widget.unit!.xpReward.toString();
      _sortOrderController.text = widget.unit!.sortOrder.toString();
      
      _selectedCourseId = widget.unit!.courseId;
      _isPremium = widget.unit!.isPremium;
    } else {
      // Create mode - set defaults
      _colorController.text = '#4A90E2';
      _estimatedDurationController.text = '30';
      _xpRewardController.text = '50';
      _sortOrderController.text = '1';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();

    _iconController.dispose();
    _colorController.dispose();
    _estimatedDurationController.dispose();
    _xpRewardController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  Future<void> _saveUnit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a course')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final unitData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'courseId': _selectedCourseId,
        'theme': _selectedTheme,
        'icon': _iconController.text.trim().isEmpty ? null : _iconController.text.trim(),
        'color': _colorController.text.trim(),
        'estimatedDuration': int.tryParse(_estimatedDurationController.text) ?? 30,
        'xpReward': int.tryParse(_xpRewardController.text) ?? 50,
        'isPremium': _isPremium,
        'sortOrder': int.tryParse(_sortOrderController.text) ?? 1,
      };

      if (widget.unit != null || widget.unitId != null) {
        // Update existing unit
        final unitId = widget.unit?.id ?? widget.unitId!;
        await AdminService.updateUnit(unitId, unitData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unit updated successfully!')),
          );
        }
      } else {
        // Create new unit
        await AdminService.createUnit(unitData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unit created successfully!')),
          );
        }
      }

      if (mounted) {
        // Navigate back
        if (widget.courseId != null) {
          context.go('${AppRouter.adminCourseDetail.replaceAll(':courseId', widget.courseId!)}');
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
  Widget build(BuildContext context) {
    final isEditMode = widget.unit != null || widget.unitId != null;
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isEditMode ? 'Edit Unit' : 'Create Unit'),
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Unit' : 'Create Unit'),
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
                labelText: 'Unit Title *',
                border: OutlineInputBorder(),
                hintText: 'Enter unit title',
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
                hintText: 'Enter unit description',
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

            // Course Selection
            _buildSectionHeader('Course Assignment'),
            const SizedBox(height: 16),
            
            if (_isLoadingCourses)
              const Center(child: CircularProgressIndicator())
            else
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
                  setState(() {
                    _selectedCourseId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a course';
                  }
                  return null;
                },
              ),
            const SizedBox(height: 16),

            // Unit Settings Section
            _buildSectionHeader('Unit Settings'),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _selectedTheme,
              decoration: const InputDecoration(
                labelText: 'Theme *',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'daily_life', child: Text('Daily Life')),
                DropdownMenuItem(value: 'family_friends', child: Text('Family & Friends')),
                DropdownMenuItem(value: 'food_dining', child: Text('Food & Dining')),
                DropdownMenuItem(value: 'travel_transport', child: Text('Travel & Transport')),
                DropdownMenuItem(value: 'work_career', child: Text('Work & Career')),
                DropdownMenuItem(value: 'health_fitness', child: Text('Health & Fitness')),
                DropdownMenuItem(value: 'shopping', child: Text('Shopping')),
                DropdownMenuItem(value: 'education', child: Text('Education')),
                DropdownMenuItem(value: 'entertainment', child: Text('Entertainment')),
                DropdownMenuItem(value: 'weather_seasons', child: Text('Weather & Seasons')),
                DropdownMenuItem(value: 'home_living', child: Text('Home & Living')),
                DropdownMenuItem(value: 'numbers_time', child: Text('Numbers & Time')),
                DropdownMenuItem(value: 'colors_shapes', child: Text('Colors & Shapes')),
                DropdownMenuItem(value: 'greetings_intro', child: Text('Greetings & Introduction')),
                DropdownMenuItem(value: 'hobbies_interests', child: Text('Hobbies & Interests')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedTheme = value!;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a theme';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _iconController,
              decoration: const InputDecoration(
                labelText: 'Icon (optional)',
                border: OutlineInputBorder(),
                hintText: 'Icon name or URL',
                prefixIcon: Icon(Icons.emoji_emotions),
              ),
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

            // Unit Details Section
            _buildSectionHeader('Unit Details'),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _estimatedDurationController,
                    decoration: const InputDecoration(
                      labelText: 'Duration (minutes)',
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
                    controller: _xpRewardController,
                    decoration: const InputDecoration(
                      labelText: 'XP Reward',
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
              controller: _sortOrderController,
              decoration: const InputDecoration(
                labelText: 'Sort Order',
                border: OutlineInputBorder(),
                hintText: '1, 2, 3...',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return null;
                final order = int.tryParse(value);
                if (order == null || order <= 0) {
                  return 'Please enter a valid sort order';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Premium Toggle
            SwitchListTile(
              title: const Text('Premium Unit'),
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
                onPressed: _isLoading ? null : _saveUnit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  _isLoading ? 'Saving...' : (isEditMode ? 'Update Unit' : 'Create Unit'),
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
import '../../models/unit_model.dart';
import '../../models/course_model.dart';
import '../../network/admin_service.dart';
import '../../utils/safe_navigator.dart';
import '../../routes/app_router.dart';

class UnitFormPage extends StatefulWidget {
  final UnitModel? unit; // null for create, not null for edit
  final String? unitId; // for edit mode
  final String? courseId; // for create mode

  const UnitFormPage({Key? key, this.unit, this.unitId, this.courseId}) : super(key: key);

  @override
  State<UnitFormPage> createState() => _UnitFormPageState();
}

class _UnitFormPageState extends State<UnitFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedTheme = 'daily_life';
  final _iconController = TextEditingController();
  final _colorController = TextEditingController();
  final _estimatedDurationController = TextEditingController();
  final _xpRewardController = TextEditingController();
  final _sortOrderController = TextEditingController();

  String? _selectedCourseId;
  List<CourseModel> _courses = [];
  bool _isPremium = false;
  bool _isLoading = false;
  bool _isLoadingCourses = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
    if (widget.unitId != null && widget.unit == null) {
      _loadUnitData();
    } else {
      _initializeForm();
    }
  }

  Future<void> _loadCourses() async {
    try {
      final courses = await AdminService.getAllCourses();
      setState(() {
        _courses = courses;
        _isLoadingCourses = false;
      });
      
      // Set default course if provided
      if (widget.courseId != null) {
        _selectedCourseId = widget.courseId;
      }
    } catch (e) {
      setState(() {
        _isLoadingCourses = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading courses: $e')),
        );
      }
    }
  }

  Future<void> _loadUnitData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Fetch unit data from backend
      final units = await AdminService.getAllUnits();
      final unit = units.firstWhere((u) => u.id == widget.unitId);
      
      setState(() {
        _titleController.text = unit.title;
        _descriptionController.text = unit.description;
        _selectedTheme = unit.theme;
        _iconController.text = unit.icon ?? '';
        _colorController.text = unit.color;
        _estimatedDurationController.text = unit.estimatedDuration.toString();
        _xpRewardController.text = unit.xpReward.toString();
        _sortOrderController.text = unit.sortOrder.toString();
        
        _selectedCourseId = unit.courseId;
        _isPremium = unit.isPremium;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading unit: $e')),
        );
      }
    }
  }

  void _initializeForm() {
    if (widget.unit != null) {
      // Edit mode
      _titleController.text = widget.unit!.title;
      _descriptionController.text = widget.unit!.description;
              _selectedTheme = widget.unit!.theme;
      _iconController.text = widget.unit!.icon ?? '';
      _colorController.text = widget.unit!.color;
      _estimatedDurationController.text = widget.unit!.estimatedDuration.toString();
      _xpRewardController.text = widget.unit!.xpReward.toString();
      _sortOrderController.text = widget.unit!.sortOrder.toString();
      
      _selectedCourseId = widget.unit!.courseId;
      _isPremium = widget.unit!.isPremium;
    } else {
      // Create mode - set defaults
      _colorController.text = '#4A90E2';
      _estimatedDurationController.text = '30';
      _xpRewardController.text = '50';
      _sortOrderController.text = '1';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();

    _iconController.dispose();
    _colorController.dispose();
    _estimatedDurationController.dispose();
    _xpRewardController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  Future<void> _saveUnit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a course')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final unitData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'courseId': _selectedCourseId,
        'theme': _selectedTheme,
        'icon': _iconController.text.trim().isEmpty ? null : _iconController.text.trim(),
        'color': _colorController.text.trim(),
        'estimatedDuration': int.tryParse(_estimatedDurationController.text) ?? 30,
        'xpReward': int.tryParse(_xpRewardController.text) ?? 50,
        'isPremium': _isPremium,
        'sortOrder': int.tryParse(_sortOrderController.text) ?? 1,
      };

      if (widget.unit != null || widget.unitId != null) {
        // Update existing unit
        final unitId = widget.unit?.id ?? widget.unitId!;
        await AdminService.updateUnit(unitId, unitData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unit updated successfully!')),
          );
        }
      } else {
        // Create new unit
        await AdminService.createUnit(unitData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unit created successfully!')),
          );
        }
      }

      if (mounted) {
        // Navigate back
        if (widget.courseId != null) {
          context.go('${AppRouter.adminCourseDetail.replaceAll(':courseId', widget.courseId!)}');
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
  Widget build(BuildContext context) {
    final isEditMode = widget.unit != null || widget.unitId != null;
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isEditMode ? 'Edit Unit' : 'Create Unit'),
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Unit' : 'Create Unit'),
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
                labelText: 'Unit Title *',
                border: OutlineInputBorder(),
                hintText: 'Enter unit title',
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
                hintText: 'Enter unit description',
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

            // Course Selection
            _buildSectionHeader('Course Assignment'),
            const SizedBox(height: 16),
            
            if (_isLoadingCourses)
              const Center(child: CircularProgressIndicator())
            else
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
                  setState(() {
                    _selectedCourseId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a course';
                  }
                  return null;
                },
              ),
            const SizedBox(height: 16),

            // Unit Settings Section
            _buildSectionHeader('Unit Settings'),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _selectedTheme,
              decoration: const InputDecoration(
                labelText: 'Theme *',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'daily_life', child: Text('Daily Life')),
                DropdownMenuItem(value: 'family_friends', child: Text('Family & Friends')),
                DropdownMenuItem(value: 'food_dining', child: Text('Food & Dining')),
                DropdownMenuItem(value: 'travel_transport', child: Text('Travel & Transport')),
                DropdownMenuItem(value: 'work_career', child: Text('Work & Career')),
                DropdownMenuItem(value: 'health_fitness', child: Text('Health & Fitness')),
                DropdownMenuItem(value: 'shopping', child: Text('Shopping')),
                DropdownMenuItem(value: 'education', child: Text('Education')),
                DropdownMenuItem(value: 'entertainment', child: Text('Entertainment')),
                DropdownMenuItem(value: 'weather_seasons', child: Text('Weather & Seasons')),
                DropdownMenuItem(value: 'home_living', child: Text('Home & Living')),
                DropdownMenuItem(value: 'numbers_time', child: Text('Numbers & Time')),
                DropdownMenuItem(value: 'colors_shapes', child: Text('Colors & Shapes')),
                DropdownMenuItem(value: 'greetings_intro', child: Text('Greetings & Introduction')),
                DropdownMenuItem(value: 'hobbies_interests', child: Text('Hobbies & Interests')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedTheme = value!;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a theme';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _iconController,
              decoration: const InputDecoration(
                labelText: 'Icon (optional)',
                border: OutlineInputBorder(),
                hintText: 'Icon name or URL',
                prefixIcon: Icon(Icons.emoji_emotions),
              ),
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

            // Unit Details Section
            _buildSectionHeader('Unit Details'),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _estimatedDurationController,
                    decoration: const InputDecoration(
                      labelText: 'Duration (minutes)',
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
                    controller: _xpRewardController,
                    decoration: const InputDecoration(
                      labelText: 'XP Reward',
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
              controller: _sortOrderController,
              decoration: const InputDecoration(
                labelText: 'Sort Order',
                border: OutlineInputBorder(),
                hintText: '1, 2, 3...',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return null;
                final order = int.tryParse(value);
                if (order == null || order <= 0) {
                  return 'Please enter a valid sort order';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Premium Toggle
            SwitchListTile(
              title: const Text('Premium Unit'),
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
                onPressed: _isLoading ? null : _saveUnit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  _isLoading ? 'Saving...' : (isEditMode ? 'Update Unit' : 'Create Unit'),
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