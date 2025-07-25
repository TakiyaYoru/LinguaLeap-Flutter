// lib/pages/admin/admin_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../network/auth_service.dart';
import '../../models/user_model.dart';
import '../../theme/app_themes.dart';
import '../../network/admin_service.dart';
import '../../network/exercise_service.dart';
import '../../models/course_model.dart';
import '../../models/unit_model.dart';
import '../../models/lesson_model.dart';
import '../../models/exercise_model.dart';
import '../../routes/app_router.dart';
import 'lesson_detail_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> with WidgetsBindingObserver {
  UserModel? user;
  List<CourseModel> courses = [];
  List<UnitModel> units = [];
  List<LessonModel> lessons = [];
  List<ExerciseModel> exercises = [];
  bool isLoading = true;
  String errorMessage = '';
  int selectedTabIndex = 0;
  bool _needsReload = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && mounted) {
      // Force reload when app resumes
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _loadData();
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload data when returning to this page
    if (_needsReload) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadData();
          _needsReload = false;
        }
      });
    }
  }





  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      // Load user info
      final userData = await AuthService.getCurrentUser();
      if (userData != null) {
        setState(() {
          user = UserModel.fromJson(userData);
        });
      }

      // Load courses, units, lessons, and exercises
      await Future.wait([
        _loadCourses(),
        _loadUnits(),
        _loadLessons(),
        _loadExercises(),
      ]);
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _loadCourses() async {
    try {
      print('🔄 [AdminDashboard] Loading courses...');
      final coursesData = await AdminService.getAllCourses();
      print('📥 [AdminDashboard] Received ${coursesData.length} courses');
      print('📋 [AdminDashboard] Courses: ${coursesData.map((c) => c.title).toList()}');
      
      setState(() {
        courses = coursesData;
      });
      print('✅ [AdminDashboard] State updated with ${courses.length} courses');
    } catch (e) {
      print('❌ [AdminDashboard] Error loading courses: $e');
      setState(() {
        errorMessage = 'Failed to load courses: $e';
      });
    }
  }

  Future<void> _loadUnits() async {
    try {
      print('🔄 [AdminDashboard] Loading units...');
      final unitsData = await AdminService.getAllUnits();
      print('📥 [AdminDashboard] Received ${unitsData.length} units');
      print('📋 [AdminDashboard] Units: ${unitsData.map((u) => u.title).toList()}');
      
      setState(() {
        units = unitsData;
      });
      print('✅ [AdminDashboard] State updated with ${units.length} units');
    } catch (e) {
      print('❌ [AdminDashboard] Error loading units: $e');
      setState(() {
        errorMessage = 'Failed to load units: $e';
      });
    }
  }

  Future<void> _loadLessons() async {
    try {
      print('🔄 [AdminDashboard] Loading lessons...');
      final lessonsData = await AdminService.getAllLessons();
      print('📥 [AdminDashboard] Received ${lessonsData.length} lessons');
      print('📋 [AdminDashboard] Lessons: ${lessonsData.map((l) => l.title).toList()}');
      
      setState(() {
        lessons = lessonsData;
      });
      print('✅ [AdminDashboard] State updated with ${lessons.length} lessons');
    } catch (e) {
      print('❌ [AdminDashboard] Error loading lessons: $e');
      setState(() {
        errorMessage = 'Failed to load lessons: $e';
      });
    }
  }

  Future<void> _loadExercises() async {
    try {
      print('🔄 [AdminDashboard] Loading exercises...');
      final exercisesData = await ExerciseService.getAllExercises();
      print('📥 [AdminDashboard] Received ${exercisesData.length} exercises');
      print('📋 [AdminDashboard] Exercises: ${exercisesData.map((e) => e.displayTitle).toList()}');
      
      setState(() {
        exercises = exercisesData;
        isLoading = false;
      });
      print('✅ [AdminDashboard] State updated with ${exercises.length} exercises');
    } catch (e) {
      print('❌ [AdminDashboard] Error loading exercises: $e');
      setState(() {
        errorMessage = 'Failed to load exercises: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppThemes.lightGroupedBackground,
      appBar: AppBar(
        backgroundColor: AppThemes.lightSecondaryBackground,
        title: const Text('Admin Dashboard', style: TextStyle(color: AppThemes.lightLabel)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppThemes.primaryGreen),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: Icon(Icons.add, color: AppThemes.primaryGreen),
            onPressed: () {
              switch (selectedTabIndex) {
                case 0: // Courses
                  _needsReload = true;
                  context.go(AppRouter.adminCreateCourse);
                  break;
                case 1: // Units
                  _needsReload = true;
                  context.go(AppRouter.adminCreateUnit);
                  break;
                case 2: // Lessons
                  _needsReload = true;
                  context.go(AppRouter.adminCreateLesson);
                  break;
              }
            },
            tooltip: 'Create ${_getCreateButtonText()}',
          ),
          IconButton(
            icon: Icon(Icons.logout, color: AppThemes.primaryGreen),
            onPressed: () => AuthService.logout(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Welcome Section
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppThemes.lightBackground,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.admin_panel_settings, color: AppThemes.primaryGreen, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${user?.displayName ?? 'Admin'}! 👋',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppThemes.primaryGreen,
                            ),
                          ),
                          Text(
                            'Admin Dashboard - Manage your content',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppThemes.lightSecondaryLabel,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard('Courses', courses.length.toString(), Icons.book),
                    const SizedBox(width: 12),
                    _buildStatCard('Published', courses.where((c) => c.isPublished).length.toString(), Icons.published_with_changes),
                    const SizedBox(width: 12),
                    _buildStatCard('Draft', courses.where((c) => !c.isPublished).length.toString(), Icons.edit_note),
                  ],
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppThemes.lightBackground,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton('Courses', 0, Icons.book),
                ),
                Expanded(
                  child: _buildTabButton('Units', 1, Icons.layers),
                ),
                            Expanded(
              child: _buildTabButton('Lessons', 2, Icons.menu_book),
            ),
            Expanded(
              child: _buildTabButton('Exercises', 3, Icons.fitness_center),
            ),
            Expanded(
              child: _buildTabButton('Users', 4, Icons.people),
            ),
            Expanded(
              child: _buildTabButton('Settings', 5, Icons.settings),
            ),
              ],
            ),
          ),

          // Content Area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              child: _buildTabContent(),
            ),
          ),
        ],
      ),
      floatingActionButton: selectedTabIndex == 0 || selectedTabIndex == 1 || selectedTabIndex == 2 ? FloatingActionButton(
        onPressed: () {
          switch (selectedTabIndex) {
            case 0:
              _needsReload = true;
              context.go(AppRouter.adminCreateCourse);
              break;
            case 1:
              _needsReload = true;
              context.go(AppRouter.adminCreateUnit);
              break;
            case 2:
              _needsReload = true;
              context.go(AppRouter.adminCreateLesson);
              break;
          }
        },
        backgroundColor: AppThemes.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppThemes.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppThemes.primaryGreen.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppThemes.primaryGreen, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppThemes.primaryGreen,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppThemes.lightSecondaryLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, int index, IconData icon) {
    final isSelected = selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppThemes.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppThemes.lightSecondaryLabel,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppThemes.lightSecondaryLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (selectedTabIndex) {
      case 0:
        return _buildCoursesTab();
      case 1:
        return _buildUnitsTab();
              case 2:
          return _buildLessonsTab();
        case 3:
          return _buildExercisesTab();
        case 4:
          return _buildUsersTab();
        case 5:
          return _buildSettingsTab();
      default:
        return _buildCoursesTab();
    }
  }

  String _getCreateButtonText() {
    switch (selectedTabIndex) {
      case 0:
        return 'Course';
      case 1:
        return 'Unit';
      case 2:
        return 'Lesson';
      case 3:
        return 'Exercise';
      default:
        return 'Item';
    }
  }

  Widget _buildCoursesTab() {
    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppThemes.lightSecondaryLabel),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: TextStyle(color: AppThemes.lightSecondaryLabel),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCourses,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 64, color: AppThemes.lightSecondaryLabel),
            const SizedBox(height: 16),
            Text(
              'No courses yet',
              style: TextStyle(
                fontSize: 18,
                color: AppThemes.lightSecondaryLabel,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first course to get started',
              style: TextStyle(
                color: AppThemes.lightSecondaryLabel,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return _buildCourseCard(course);
      },
    );
  }

  Widget _buildUnitsTab() {
    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppThemes.lightSecondaryLabel),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: TextStyle(color: AppThemes.lightSecondaryLabel),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUnits,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (units.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.layers_outlined, size: 64, color: AppThemes.lightSecondaryLabel),
            const SizedBox(height: 16),
            Text(
              'No units yet',
              style: TextStyle(
                fontSize: 18,
                color: AppThemes.lightSecondaryLabel,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first unit to get started',
              style: TextStyle(
                color: AppThemes.lightSecondaryLabel,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: units.length,
      itemBuilder: (context, index) {
        final unit = units[index];
        return _buildUnitCard(unit);
      },
    );
  }

  Widget _buildUnitCard(UnitModel unit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppThemes.lightBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppThemes.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.layers,
            color: AppThemes.primaryGreen,
          ),
        ),
        title: Text(
          unit.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppThemes.lightLabel,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              unit.description,
              style: TextStyle(
                color: AppThemes.lightSecondaryLabel,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildStatusChip(
                  unit.isPublished ? 'Published' : 'Draft',
                  unit.isPublished ? AppThemes.systemGreen : AppThemes.systemOrange,
                ),
                const SizedBox(width: 8),
                _buildStatusChip(
                  unit.theme,
                  AppThemes.systemBlue,
                ),
                const SizedBox(width: 8),
                if (unit.isPremium)
                  _buildStatusChip(
                    'Premium',
                    AppThemes.premium,
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleUnitAction(value, unit),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: unit.isPublished ? 'unpublish' : 'publish',
              child: Row(
                children: [
                  Icon(
                    unit.isPublished ? Icons.visibility_off : Icons.publish,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(unit.isPublished ? 'Unpublish' : 'Publish'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(CourseModel course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppThemes.lightBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: () => context.go('${AppRouter.adminCourseDetail.replaceAll(':courseId', course.id)}'),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppThemes.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.book,
            color: AppThemes.primaryGreen,
          ),
        ),
        title: Text(
          course.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppThemes.lightLabel,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              course.description,
              style: TextStyle(
                color: AppThemes.lightSecondaryLabel,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildStatusChip(
                  course.isPublished ? 'Published' : 'Draft',
                  course.isPublished ? AppThemes.systemGreen : AppThemes.systemOrange,
                ),
                const SizedBox(width: 8),
                _buildStatusChip(
                  course.level,
                  AppThemes.systemBlue,
                ),
                const SizedBox(width: 8),
                if (course.isPremium)
                  _buildStatusChip(
                    'Premium',
                    AppThemes.premium,
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleCourseAction(value, course),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: course.isPublished ? 'unpublish' : 'publish',
              child: Row(
                children: [
                  Icon(
                    course.isPublished ? Icons.visibility_off : Icons.publish,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(course.isPublished ? 'Unpublish' : 'Publish'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildLessonsTab() {
    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppThemes.lightSecondaryLabel),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: TextStyle(color: AppThemes.lightSecondaryLabel),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadLessons,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (lessons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_outlined, size: 64, color: AppThemes.lightSecondaryLabel),
            const SizedBox(height: 16),
            Text(
              'No lessons yet',
              style: TextStyle(
                fontSize: 18,
                color: AppThemes.lightSecondaryLabel,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first lesson to get started',
              style: TextStyle(
                color: AppThemes.lightSecondaryLabel,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        return _buildLessonCard(lesson);
      },
    );
  }

  Widget _buildExercisesTab() {
    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppThemes.lightSecondaryLabel),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: TextStyle(color: AppThemes.lightSecondaryLabel),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadExercises,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (exercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64, color: AppThemes.lightSecondaryLabel),
            const SizedBox(height: 16),
            Text(
              'No exercises yet',
              style: TextStyle(
                fontSize: 18,
                color: AppThemes.lightSecondaryLabel,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first exercise to get started',
              style: TextStyle(
                color: AppThemes.lightSecondaryLabel,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return _buildExerciseCard(exercise);
      },
    );
  }

  Widget _buildExerciseCard(ExerciseModel exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppThemes.lightBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppThemes.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getExerciseTypeIcon(exercise.type),
            color: AppThemes.primaryGreen,
          ),
        ),
        title: Text(
          exercise.displayTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppThemes.lightLabel,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              exercise.instruction,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppThemes.lightSecondaryLabel,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildChip('Type', exercise.typeDisplay),
                const SizedBox(width: 6),
                _buildChip('Difficulty', exercise.difficultyDisplay),
                const SizedBox(width: 6),
                _buildChip('XP', '${exercise.xpReward}'),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: AppThemes.lightSecondaryLabel),
          onSelected: (action) => _handleExerciseAction(action, exercise),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: exercise.isActive ? 'unpublish' : 'publish',
              child: Row(
                children: [
                  Icon(
                    exercise.isActive ? Icons.visibility_off : Icons.visibility,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(exercise.isActive ? 'Unpublish' : 'Publish'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonCard(LessonModel lesson) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppThemes.lightBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: () {
          context.go('${AppRouter.adminLessonDetail.replaceAll(':lessonId', lesson.id)}');
        },
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppThemes.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getLessonTypeIcon(lesson.type),
            color: AppThemes.primaryGreen,
          ),
        ),
        title: Text(
          lesson.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppThemes.lightLabel,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              lesson.description ?? '',
              style: TextStyle(
                color: AppThemes.lightSecondaryLabel,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildStatusChip(
                  lesson.isPublished ? 'Published' : 'Draft',
                  lesson.isPublished ? AppThemes.systemGreen : AppThemes.systemOrange,
                ),
                const SizedBox(width: 8),
                _buildStatusChip(
                  lesson.type,
                  AppThemes.systemBlue,
                ),
                const SizedBox(width: 8),
                _buildStatusChip(
                  lesson.difficulty,
                  AppThemes.systemPurple,
                ),
                const SizedBox(width: 8),
                if (lesson.isPremium)
                  _buildStatusChip(
                    'Premium',
                    AppThemes.premium,
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleLessonAction(value, lesson),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: lesson.isPublished ? 'unpublish' : 'publish',
              child: Row(
                children: [
                  Icon(
                    lesson.isPublished ? Icons.visibility_off : Icons.publish,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(lesson.isPublished ? 'Unpublish' : 'Publish'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getLessonTypeIcon(String type) {
    switch (type) {
      case 'vocabulary':
        return Icons.translate;
      case 'grammar':
        return Icons.rule;
      case 'listening':
        return Icons.hearing;
      case 'speaking':
        return Icons.record_voice_over;
      case 'reading':
        return Icons.menu_book;
      case 'writing':
        return Icons.edit;
      case 'conversation':
        return Icons.chat;
      case 'review':
        return Icons.refresh;
      case 'test':
        return Icons.quiz;
      default:
        return Icons.book;
    }
  }

  IconData _getExerciseTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'multiple_choice': return Icons.check_circle_outline;
      case 'fill_blank': return Icons.text_fields;
      case 'listening': return Icons.headphones;
      case 'translation': return Icons.translate;
      case 'speaking': return Icons.record_voice_over;
      case 'reading': return Icons.menu_book;
      case 'word_matching': return Icons.compare_arrows;
      case 'sentence_building': return Icons.format_list_bulleted;
      case 'true_false': return Icons.check_box;
      case 'drag_drop': return Icons.drag_handle;
      case 'listen_choose': return Icons.hearing;
      case 'speak_repeat': return Icons.repeat;
      default: return Icons.fitness_center;
    }
  }

  Widget _buildUsersTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: AppThemes.lightSecondaryLabel),
          const SizedBox(height: 16),
          Text(
            'User Management',
            style: TextStyle(
              fontSize: 18,
              color: AppThemes.lightSecondaryLabel,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming soon in Phase 2',
            style: TextStyle(
              color: AppThemes.lightSecondaryLabel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings_outlined, size: 64, color: AppThemes.lightSecondaryLabel),
          const SizedBox(height: 16),
          Text(
            'Admin Settings',
            style: TextStyle(
              fontSize: 18,
              color: AppThemes.lightSecondaryLabel,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming soon',
            style: TextStyle(
              color: AppThemes.lightSecondaryLabel,
            ),
          ),
        ],
      ),
    );
  }

  void _handleLessonAction(String action, LessonModel lesson) {
    switch (action) {
      case 'edit':
        _needsReload = true;
        context.go('${AppRouter.adminEditLesson.replaceAll(':lessonId', lesson.id)}?unitId=${lesson.unitId}&courseId=${lesson.courseId}');
        break;
      case 'publish':
        _publishLesson(lesson.id);
        break;
      case 'unpublish':
        _unpublishLesson(lesson.id);
        break;
      case 'delete':
        _showDeleteLessonDialog(lesson);
        break;
    }
  }

  void _handleExerciseAction(String action, ExerciseModel exercise) {
    switch (action) {
      case 'edit':
        _needsReload = true;
        context.go('${AppRouter.adminEditExercise.replaceAll(':exerciseId', exercise.id)}?lessonId=${exercise.lessonId}&unitId=${exercise.unitId}&courseId=${exercise.courseId}');
        break;
      case 'publish':
        _publishExercise(exercise.id);
        break;
      case 'unpublish':
        _unpublishExercise(exercise.id);
        break;
      case 'delete':
        _showDeleteExerciseDialog(exercise);
        break;
    }
  }

  void _handleCourseAction(String action, CourseModel course) {
    switch (action) {
      case 'edit':
        _needsReload = true;
        context.go('${AppRouter.adminEditCourse.replaceAll(':courseId', course.id)}?courseId=${course.id}');
        break;
      case 'publish':
        _publishCourse(course.id);
        break;
      case 'unpublish':
        _unpublishCourse(course.id);
        break;
      case 'delete':
        _showDeleteCourseDialog(course);
        break;
    }
  }

  void _handleUnitAction(String action, UnitModel unit) {
    switch (action) {
      case 'edit':
        _needsReload = true;
        context.go('${AppRouter.adminEditUnit.replaceAll(':unitId', unit.id)}');
        break;
      case 'publish':
        _publishUnit(unit.id);
        break;
      case 'unpublish':
        _unpublishUnit(unit.id);
        break;
      case 'delete':
        _showDeleteUnitDialog(unit);
        break;
    }
  }

  void _showCreateCourseDialog() {
    // TODO: Implement create course dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Create Course - Coming Soon!'),
        backgroundColor: AppThemes.primaryGreen,
      ),
    );
  }

  void _showEditCourseDialog(CourseModel course) {
    // TODO: Implement edit course dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit Course: ${course.title} - Coming Soon!'),
        backgroundColor: AppThemes.primaryGreen,
      ),
    );
  }

  void _showDeleteCourseDialog(CourseModel course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Are you sure you want to delete "${course.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteCourse(course.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteUnitDialog(UnitModel unit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Unit'),
        content: Text('Are you sure you want to delete "${unit.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteUnit(unit.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _publishCourse(String courseId) async {
    try {
      await AdminService.publishCourse(courseId);
      await _loadCourses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course published successfully!'),
            backgroundColor: AppThemes.systemGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to publish course: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _unpublishCourse(String courseId) async {
    try {
      await AdminService.unpublishCourse(courseId);
      await _loadCourses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course unpublished successfully!'),
            backgroundColor: AppThemes.systemOrange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to unpublish course: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteCourse(String courseId) async {
    try {
      // Remove from UI immediately
      setState(() {
        courses.removeWhere((course) => course.id == courseId);
      });
      
      await AdminService.deleteCourse(courseId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course deleted successfully!'),
            backgroundColor: AppThemes.systemGreen,
          ),
        );
      }
    } catch (e) {
      // If error, reload to restore the item
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete course: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _publishUnit(String unitId) async {
    try {
      await AdminService.publishUnit(unitId);
      await _loadUnits();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unit published successfully!'),
            backgroundColor: AppThemes.systemGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to publish unit: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _unpublishUnit(String unitId) async {
    try {
      await AdminService.unpublishUnit(unitId);
      await _loadUnits();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unit unpublished successfully!'),
            backgroundColor: AppThemes.systemOrange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to unpublish unit: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteUnit(String unitId) async {
    try {
      // Remove from UI immediately
      setState(() {
        units.removeWhere((unit) => unit.id == unitId);
      });
      
      await AdminService.deleteUnit(unitId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unit deleted successfully!'),
            backgroundColor: AppThemes.systemGreen,
          ),
        );
      }
    } catch (e) {
      // If error, reload to restore the item
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete unit: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteLessonDialog(LessonModel lesson) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Lesson'),
        content: Text('Are you sure you want to delete "${lesson.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteLesson(lesson.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _publishLesson(String lessonId) async {
    try {
      await AdminService.publishLesson(lessonId);
      await _loadLessons();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lesson published successfully!'),
            backgroundColor: AppThemes.systemGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to publish lesson: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _unpublishLesson(String lessonId) async {
    try {
      await AdminService.unpublishLesson(lessonId);
      await _loadLessons();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lesson unpublished successfully!'),
            backgroundColor: AppThemes.systemOrange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to unpublish lesson: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteLesson(String lessonId) async {
    try {
      // Remove from UI immediately
      setState(() {
        lessons.removeWhere((lesson) => lesson.id == lessonId);
      });
      
      await AdminService.deleteLesson(lessonId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lesson deleted successfully!'),
            backgroundColor: AppThemes.systemGreen,
          ),
        );
      }
    } catch (e) {
      // If error, reload to restore the item
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete lesson: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppThemes.lightSecondaryBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 12,
          color: AppThemes.lightSecondaryLabel,
        ),
      ),
    );
  }

  Future<void> _publishExercise(String exerciseId) async {
    try {
      await ExerciseService.publishExercise(exerciseId);
      await _loadExercises();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exercise published successfully!'),
            backgroundColor: AppThemes.systemGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to publish exercise: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _unpublishExercise(String exerciseId) async {
    try {
      await ExerciseService.unpublishExercise(exerciseId);
      await _loadExercises();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exercise unpublished successfully!'),
            backgroundColor: AppThemes.systemOrange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to unpublish exercise: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteExerciseDialog(ExerciseModel exercise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exercise'),
        content: Text('Are you sure you want to delete "${exercise.displayTitle}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteExercise(exercise.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteExercise(String exerciseId) async {
    try {
      // Remove from UI immediately
      setState(() {
        exercises.removeWhere((exercise) => exercise.id == exerciseId);
      });
      
      await ExerciseService.deleteExercise(exerciseId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exercise deleted successfully!'),
            backgroundColor: AppThemes.systemGreen,
          ),
        );
      }
    } catch (e) {
      // If error, reload to restore the item
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete exercise: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../network/auth_service.dart';
import '../../models/user_model.dart';
import '../../theme/app_themes.dart';
import '../../network/admin_service.dart';
import '../../network/exercise_service.dart';
import '../../models/course_model.dart';
import '../../models/unit_model.dart';
import '../../models/lesson_model.dart';
import '../../models/exercise_model.dart';
import '../../routes/app_router.dart';
import 'lesson_detail_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> with WidgetsBindingObserver {
  UserModel? user;
  List<CourseModel> courses = [];
  List<UnitModel> units = [];
  List<LessonModel> lessons = [];
  List<ExerciseModel> exercises = [];
  bool isLoading = true;
  String errorMessage = '';
  int selectedTabIndex = 0;
  bool _needsReload = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && mounted) {
      // Force reload when app resumes
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _loadData();
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload data when returning to this page
    if (_needsReload) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadData();
          _needsReload = false;
        }
      });
    }
  }





  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      // Load user info
      final userData = await AuthService.getCurrentUser();
      if (userData != null) {
        setState(() {
          user = UserModel.fromJson(userData);
        });
      }

      // Load courses, units, lessons, and exercises
      await Future.wait([
        _loadCourses(),
        _loadUnits(),
        _loadLessons(),
        _loadExercises(),
      ]);
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _loadCourses() async {
    try {
      print('🔄 [AdminDashboard] Loading courses...');
      final coursesData = await AdminService.getAllCourses();
      print('📥 [AdminDashboard] Received ${coursesData.length} courses');
      print('📋 [AdminDashboard] Courses: ${coursesData.map((c) => c.title).toList()}');
      
      setState(() {
        courses = coursesData;
      });
      print('✅ [AdminDashboard] State updated with ${courses.length} courses');
    } catch (e) {
      print('❌ [AdminDashboard] Error loading courses: $e');
      setState(() {
        errorMessage = 'Failed to load courses: $e';
      });
    }
  }

  Future<void> _loadUnits() async {
    try {
      print('🔄 [AdminDashboard] Loading units...');
      final unitsData = await AdminService.getAllUnits();
      print('📥 [AdminDashboard] Received ${unitsData.length} units');
      print('📋 [AdminDashboard] Units: ${unitsData.map((u) => u.title).toList()}');
      
      setState(() {
        units = unitsData;
      });
      print('✅ [AdminDashboard] State updated with ${units.length} units');
    } catch (e) {
      print('❌ [AdminDashboard] Error loading units: $e');
      setState(() {
        errorMessage = 'Failed to load units: $e';
      });
    }
  }

  Future<void> _loadLessons() async {
    try {
      print('🔄 [AdminDashboard] Loading lessons...');
      final lessonsData = await AdminService.getAllLessons();
      print('📥 [AdminDashboard] Received ${lessonsData.length} lessons');
      print('📋 [AdminDashboard] Lessons: ${lessonsData.map((l) => l.title).toList()}');
      
      setState(() {
        lessons = lessonsData;
      });
      print('✅ [AdminDashboard] State updated with ${lessons.length} lessons');
    } catch (e) {
      print('❌ [AdminDashboard] Error loading lessons: $e');
      setState(() {
        errorMessage = 'Failed to load lessons: $e';
      });
    }
  }

  Future<void> _loadExercises() async {
    try {
      print('🔄 [AdminDashboard] Loading exercises...');
      final exercisesData = await ExerciseService.getAllExercises();
      print('📥 [AdminDashboard] Received ${exercisesData.length} exercises');
      print('📋 [AdminDashboard] Exercises: ${exercisesData.map((e) => e.displayTitle).toList()}');
      
      setState(() {
        exercises = exercisesData;
        isLoading = false;
      });
      print('✅ [AdminDashboard] State updated with ${exercises.length} exercises');
    } catch (e) {
      print('❌ [AdminDashboard] Error loading exercises: $e');
      setState(() {
        errorMessage = 'Failed to load exercises: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppThemes.lightGroupedBackground,
      appBar: AppBar(
        backgroundColor: AppThemes.lightSecondaryBackground,
        title: const Text('Admin Dashboard', style: TextStyle(color: AppThemes.lightLabel)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppThemes.primaryGreen),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: Icon(Icons.add, color: AppThemes.primaryGreen),
            onPressed: () {
              switch (selectedTabIndex) {
                case 0: // Courses
                  _needsReload = true;
                  context.go(AppRouter.adminCreateCourse);
                  break;
                case 1: // Units
                  _needsReload = true;
                  context.go(AppRouter.adminCreateUnit);
                  break;
                case 2: // Lessons
                  _needsReload = true;
                  context.go(AppRouter.adminCreateLesson);
                  break;
              }
            },
            tooltip: 'Create ${_getCreateButtonText()}',
          ),
          IconButton(
            icon: Icon(Icons.logout, color: AppThemes.primaryGreen),
            onPressed: () => AuthService.logout(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Welcome Section
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppThemes.lightBackground,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.admin_panel_settings, color: AppThemes.primaryGreen, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${user?.displayName ?? 'Admin'}! 👋',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppThemes.primaryGreen,
                            ),
                          ),
                          Text(
                            'Admin Dashboard - Manage your content',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppThemes.lightSecondaryLabel,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard('Courses', courses.length.toString(), Icons.book),
                    const SizedBox(width: 12),
                    _buildStatCard('Published', courses.where((c) => c.isPublished).length.toString(), Icons.published_with_changes),
                    const SizedBox(width: 12),
                    _buildStatCard('Draft', courses.where((c) => !c.isPublished).length.toString(), Icons.edit_note),
                  ],
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppThemes.lightBackground,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton('Courses', 0, Icons.book),
                ),
                Expanded(
                  child: _buildTabButton('Units', 1, Icons.layers),
                ),
                            Expanded(
              child: _buildTabButton('Lessons', 2, Icons.menu_book),
            ),
            Expanded(
              child: _buildTabButton('Exercises', 3, Icons.fitness_center),
            ),
            Expanded(
              child: _buildTabButton('Users', 4, Icons.people),
            ),
            Expanded(
              child: _buildTabButton('Settings', 5, Icons.settings),
            ),
              ],
            ),
          ),

          // Content Area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              child: _buildTabContent(),
            ),
          ),
        ],
      ),
      floatingActionButton: selectedTabIndex == 0 || selectedTabIndex == 1 || selectedTabIndex == 2 ? FloatingActionButton(
        onPressed: () {
          switch (selectedTabIndex) {
            case 0:
              _needsReload = true;
              context.go(AppRouter.adminCreateCourse);
              break;
            case 1:
              _needsReload = true;
              context.go(AppRouter.adminCreateUnit);
              break;
            case 2:
              _needsReload = true;
              context.go(AppRouter.adminCreateLesson);
              break;
          }
        },
        backgroundColor: AppThemes.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppThemes.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppThemes.primaryGreen.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppThemes.primaryGreen, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppThemes.primaryGreen,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppThemes.lightSecondaryLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, int index, IconData icon) {
    final isSelected = selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppThemes.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppThemes.lightSecondaryLabel,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppThemes.lightSecondaryLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (selectedTabIndex) {
      case 0:
        return _buildCoursesTab();
      case 1:
        return _buildUnitsTab();
              case 2:
          return _buildLessonsTab();
        case 3:
          return _buildExercisesTab();
        case 4:
          return _buildUsersTab();
        case 5:
          return _buildSettingsTab();
      default:
        return _buildCoursesTab();
    }
  }

  String _getCreateButtonText() {
    switch (selectedTabIndex) {
      case 0:
        return 'Course';
      case 1:
        return 'Unit';
      case 2:
        return 'Lesson';
      case 3:
        return 'Exercise';
      default:
        return 'Item';
    }
  }

  Widget _buildCoursesTab() {
    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppThemes.lightSecondaryLabel),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: TextStyle(color: AppThemes.lightSecondaryLabel),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCourses,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 64, color: AppThemes.lightSecondaryLabel),
            const SizedBox(height: 16),
            Text(
              'No courses yet',
              style: TextStyle(
                fontSize: 18,
                color: AppThemes.lightSecondaryLabel,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first course to get started',
              style: TextStyle(
                color: AppThemes.lightSecondaryLabel,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return _buildCourseCard(course);
      },
    );
  }

  Widget _buildUnitsTab() {
    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppThemes.lightSecondaryLabel),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: TextStyle(color: AppThemes.lightSecondaryLabel),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUnits,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (units.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.layers_outlined, size: 64, color: AppThemes.lightSecondaryLabel),
            const SizedBox(height: 16),
            Text(
              'No units yet',
              style: TextStyle(
                fontSize: 18,
                color: AppThemes.lightSecondaryLabel,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first unit to get started',
              style: TextStyle(
                color: AppThemes.lightSecondaryLabel,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: units.length,
      itemBuilder: (context, index) {
        final unit = units[index];
        return _buildUnitCard(unit);
      },
    );
  }

  Widget _buildUnitCard(UnitModel unit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppThemes.lightBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppThemes.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.layers,
            color: AppThemes.primaryGreen,
          ),
        ),
        title: Text(
          unit.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppThemes.lightLabel,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              unit.description,
              style: TextStyle(
                color: AppThemes.lightSecondaryLabel,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildStatusChip(
                  unit.isPublished ? 'Published' : 'Draft',
                  unit.isPublished ? AppThemes.systemGreen : AppThemes.systemOrange,
                ),
                const SizedBox(width: 8),
                _buildStatusChip(
                  unit.theme,
                  AppThemes.systemBlue,
                ),
                const SizedBox(width: 8),
                if (unit.isPremium)
                  _buildStatusChip(
                    'Premium',
                    AppThemes.premium,
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleUnitAction(value, unit),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: unit.isPublished ? 'unpublish' : 'publish',
              child: Row(
                children: [
                  Icon(
                    unit.isPublished ? Icons.visibility_off : Icons.publish,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(unit.isPublished ? 'Unpublish' : 'Publish'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(CourseModel course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppThemes.lightBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: () => context.go('${AppRouter.adminCourseDetail.replaceAll(':courseId', course.id)}'),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppThemes.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.book,
            color: AppThemes.primaryGreen,
          ),
        ),
        title: Text(
          course.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppThemes.lightLabel,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              course.description,
              style: TextStyle(
                color: AppThemes.lightSecondaryLabel,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildStatusChip(
                  course.isPublished ? 'Published' : 'Draft',
                  course.isPublished ? AppThemes.systemGreen : AppThemes.systemOrange,
                ),
                const SizedBox(width: 8),
                _buildStatusChip(
                  course.level,
                  AppThemes.systemBlue,
                ),
                const SizedBox(width: 8),
                if (course.isPremium)
                  _buildStatusChip(
                    'Premium',
                    AppThemes.premium,
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleCourseAction(value, course),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: course.isPublished ? 'unpublish' : 'publish',
              child: Row(
                children: [
                  Icon(
                    course.isPublished ? Icons.visibility_off : Icons.publish,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(course.isPublished ? 'Unpublish' : 'Publish'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildLessonsTab() {
    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppThemes.lightSecondaryLabel),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: TextStyle(color: AppThemes.lightSecondaryLabel),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadLessons,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (lessons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_outlined, size: 64, color: AppThemes.lightSecondaryLabel),
            const SizedBox(height: 16),
            Text(
              'No lessons yet',
              style: TextStyle(
                fontSize: 18,
                color: AppThemes.lightSecondaryLabel,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first lesson to get started',
              style: TextStyle(
                color: AppThemes.lightSecondaryLabel,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        return _buildLessonCard(lesson);
      },
    );
  }

  Widget _buildExercisesTab() {
    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppThemes.lightSecondaryLabel),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: TextStyle(color: AppThemes.lightSecondaryLabel),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadExercises,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (exercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64, color: AppThemes.lightSecondaryLabel),
            const SizedBox(height: 16),
            Text(
              'No exercises yet',
              style: TextStyle(
                fontSize: 18,
                color: AppThemes.lightSecondaryLabel,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first exercise to get started',
              style: TextStyle(
                color: AppThemes.lightSecondaryLabel,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return _buildExerciseCard(exercise);
      },
    );
  }

  Widget _buildExerciseCard(ExerciseModel exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppThemes.lightBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppThemes.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getExerciseTypeIcon(exercise.type),
            color: AppThemes.primaryGreen,
          ),
        ),
        title: Text(
          exercise.displayTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppThemes.lightLabel,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              exercise.instruction,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppThemes.lightSecondaryLabel,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildChip('Type', exercise.typeDisplay),
                const SizedBox(width: 6),
                _buildChip('Difficulty', exercise.difficultyDisplay),
                const SizedBox(width: 6),
                _buildChip('XP', '${exercise.xpReward}'),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: AppThemes.lightSecondaryLabel),
          onSelected: (action) => _handleExerciseAction(action, exercise),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: exercise.isActive ? 'unpublish' : 'publish',
              child: Row(
                children: [
                  Icon(
                    exercise.isActive ? Icons.visibility_off : Icons.visibility,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(exercise.isActive ? 'Unpublish' : 'Publish'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonCard(LessonModel lesson) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppThemes.lightBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: () {
          context.go('${AppRouter.adminLessonDetail.replaceAll(':lessonId', lesson.id)}');
        },
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppThemes.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getLessonTypeIcon(lesson.type),
            color: AppThemes.primaryGreen,
          ),
        ),
        title: Text(
          lesson.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppThemes.lightLabel,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              lesson.description ?? '',
              style: TextStyle(
                color: AppThemes.lightSecondaryLabel,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildStatusChip(
                  lesson.isPublished ? 'Published' : 'Draft',
                  lesson.isPublished ? AppThemes.systemGreen : AppThemes.systemOrange,
                ),
                const SizedBox(width: 8),
                _buildStatusChip(
                  lesson.type,
                  AppThemes.systemBlue,
                ),
                const SizedBox(width: 8),
                _buildStatusChip(
                  lesson.difficulty,
                  AppThemes.systemPurple,
                ),
                const SizedBox(width: 8),
                if (lesson.isPremium)
                  _buildStatusChip(
                    'Premium',
                    AppThemes.premium,
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleLessonAction(value, lesson),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: lesson.isPublished ? 'unpublish' : 'publish',
              child: Row(
                children: [
                  Icon(
                    lesson.isPublished ? Icons.visibility_off : Icons.publish,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(lesson.isPublished ? 'Unpublish' : 'Publish'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getLessonTypeIcon(String type) {
    switch (type) {
      case 'vocabulary':
        return Icons.translate;
      case 'grammar':
        return Icons.rule;
      case 'listening':
        return Icons.hearing;
      case 'speaking':
        return Icons.record_voice_over;
      case 'reading':
        return Icons.menu_book;
      case 'writing':
        return Icons.edit;
      case 'conversation':
        return Icons.chat;
      case 'review':
        return Icons.refresh;
      case 'test':
        return Icons.quiz;
      default:
        return Icons.book;
    }
  }

  IconData _getExerciseTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'multiple_choice': return Icons.check_circle_outline;
      case 'fill_blank': return Icons.text_fields;
      case 'listening': return Icons.headphones;
      case 'translation': return Icons.translate;
      case 'speaking': return Icons.record_voice_over;
      case 'reading': return Icons.menu_book;
      case 'word_matching': return Icons.compare_arrows;
      case 'sentence_building': return Icons.format_list_bulleted;
      case 'true_false': return Icons.check_box;
      case 'drag_drop': return Icons.drag_handle;
      case 'listen_choose': return Icons.hearing;
      case 'speak_repeat': return Icons.repeat;
      default: return Icons.fitness_center;
    }
  }

  Widget _buildUsersTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: AppThemes.lightSecondaryLabel),
          const SizedBox(height: 16),
          Text(
            'User Management',
            style: TextStyle(
              fontSize: 18,
              color: AppThemes.lightSecondaryLabel,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming soon in Phase 2',
            style: TextStyle(
              color: AppThemes.lightSecondaryLabel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings_outlined, size: 64, color: AppThemes.lightSecondaryLabel),
          const SizedBox(height: 16),
          Text(
            'Admin Settings',
            style: TextStyle(
              fontSize: 18,
              color: AppThemes.lightSecondaryLabel,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming soon',
            style: TextStyle(
              color: AppThemes.lightSecondaryLabel,
            ),
          ),
        ],
      ),
    );
  }

  void _handleLessonAction(String action, LessonModel lesson) {
    switch (action) {
      case 'edit':
        _needsReload = true;
        context.go('${AppRouter.adminEditLesson.replaceAll(':lessonId', lesson.id)}?unitId=${lesson.unitId}&courseId=${lesson.courseId}');
        break;
      case 'publish':
        _publishLesson(lesson.id);
        break;
      case 'unpublish':
        _unpublishLesson(lesson.id);
        break;
      case 'delete':
        _showDeleteLessonDialog(lesson);
        break;
    }
  }

  void _handleExerciseAction(String action, ExerciseModel exercise) {
    switch (action) {
      case 'edit':
        _needsReload = true;
        context.go('${AppRouter.adminEditExercise.replaceAll(':exerciseId', exercise.id)}?lessonId=${exercise.lessonId}&unitId=${exercise.unitId}&courseId=${exercise.courseId}');
        break;
      case 'publish':
        _publishExercise(exercise.id);
        break;
      case 'unpublish':
        _unpublishExercise(exercise.id);
        break;
      case 'delete':
        _showDeleteExerciseDialog(exercise);
        break;
    }
  }

  void _handleCourseAction(String action, CourseModel course) {
    switch (action) {
      case 'edit':
        _needsReload = true;
        context.go('${AppRouter.adminEditCourse.replaceAll(':courseId', course.id)}?courseId=${course.id}');
        break;
      case 'publish':
        _publishCourse(course.id);
        break;
      case 'unpublish':
        _unpublishCourse(course.id);
        break;
      case 'delete':
        _showDeleteCourseDialog(course);
        break;
    }
  }

  void _handleUnitAction(String action, UnitModel unit) {
    switch (action) {
      case 'edit':
        _needsReload = true;
        context.go('${AppRouter.adminEditUnit.replaceAll(':unitId', unit.id)}');
        break;
      case 'publish':
        _publishUnit(unit.id);
        break;
      case 'unpublish':
        _unpublishUnit(unit.id);
        break;
      case 'delete':
        _showDeleteUnitDialog(unit);
        break;
    }
  }

  void _showCreateCourseDialog() {
    // TODO: Implement create course dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Create Course - Coming Soon!'),
        backgroundColor: AppThemes.primaryGreen,
      ),
    );
  }

  void _showEditCourseDialog(CourseModel course) {
    // TODO: Implement edit course dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit Course: ${course.title} - Coming Soon!'),
        backgroundColor: AppThemes.primaryGreen,
      ),
    );
  }

  void _showDeleteCourseDialog(CourseModel course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Are you sure you want to delete "${course.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteCourse(course.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteUnitDialog(UnitModel unit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Unit'),
        content: Text('Are you sure you want to delete "${unit.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteUnit(unit.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _publishCourse(String courseId) async {
    try {
      await AdminService.publishCourse(courseId);
      await _loadCourses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course published successfully!'),
            backgroundColor: AppThemes.systemGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to publish course: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _unpublishCourse(String courseId) async {
    try {
      await AdminService.unpublishCourse(courseId);
      await _loadCourses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course unpublished successfully!'),
            backgroundColor: AppThemes.systemOrange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to unpublish course: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteCourse(String courseId) async {
    try {
      // Remove from UI immediately
      setState(() {
        courses.removeWhere((course) => course.id == courseId);
      });
      
      await AdminService.deleteCourse(courseId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course deleted successfully!'),
            backgroundColor: AppThemes.systemGreen,
          ),
        );
      }
    } catch (e) {
      // If error, reload to restore the item
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete course: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _publishUnit(String unitId) async {
    try {
      await AdminService.publishUnit(unitId);
      await _loadUnits();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unit published successfully!'),
            backgroundColor: AppThemes.systemGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to publish unit: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _unpublishUnit(String unitId) async {
    try {
      await AdminService.unpublishUnit(unitId);
      await _loadUnits();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unit unpublished successfully!'),
            backgroundColor: AppThemes.systemOrange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to unpublish unit: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteUnit(String unitId) async {
    try {
      // Remove from UI immediately
      setState(() {
        units.removeWhere((unit) => unit.id == unitId);
      });
      
      await AdminService.deleteUnit(unitId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unit deleted successfully!'),
            backgroundColor: AppThemes.systemGreen,
          ),
        );
      }
    } catch (e) {
      // If error, reload to restore the item
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete unit: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteLessonDialog(LessonModel lesson) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Lesson'),
        content: Text('Are you sure you want to delete "${lesson.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteLesson(lesson.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _publishLesson(String lessonId) async {
    try {
      await AdminService.publishLesson(lessonId);
      await _loadLessons();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lesson published successfully!'),
            backgroundColor: AppThemes.systemGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to publish lesson: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _unpublishLesson(String lessonId) async {
    try {
      await AdminService.unpublishLesson(lessonId);
      await _loadLessons();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lesson unpublished successfully!'),
            backgroundColor: AppThemes.systemOrange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to unpublish lesson: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteLesson(String lessonId) async {
    try {
      // Remove from UI immediately
      setState(() {
        lessons.removeWhere((lesson) => lesson.id == lessonId);
      });
      
      await AdminService.deleteLesson(lessonId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lesson deleted successfully!'),
            backgroundColor: AppThemes.systemGreen,
          ),
        );
      }
    } catch (e) {
      // If error, reload to restore the item
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete lesson: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppThemes.lightSecondaryBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 12,
          color: AppThemes.lightSecondaryLabel,
        ),
      ),
    );
  }

  Future<void> _publishExercise(String exerciseId) async {
    try {
      await ExerciseService.publishExercise(exerciseId);
      await _loadExercises();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exercise published successfully!'),
            backgroundColor: AppThemes.systemGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to publish exercise: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _unpublishExercise(String exerciseId) async {
    try {
      await ExerciseService.unpublishExercise(exerciseId);
      await _loadExercises();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exercise unpublished successfully!'),
            backgroundColor: AppThemes.systemOrange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to unpublish exercise: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteExerciseDialog(ExerciseModel exercise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exercise'),
        content: Text('Are you sure you want to delete "${exercise.displayTitle}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteExercise(exercise.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteExercise(String exerciseId) async {
    try {
      // Remove from UI immediately
      setState(() {
        exercises.removeWhere((exercise) => exercise.id == exerciseId);
      });
      
      await ExerciseService.deleteExercise(exerciseId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exercise deleted successfully!'),
            backgroundColor: AppThemes.systemGreen,
          ),
        );
      }
    } catch (e) {
      // If error, reload to restore the item
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete exercise: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 