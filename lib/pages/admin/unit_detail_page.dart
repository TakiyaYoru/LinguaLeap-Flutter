import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/src/router.dart';
import '../../models/course_model.dart';
import '../../models/unit_model.dart';
import '../../models/lesson_model.dart';
import '../../network/admin_service.dart';
import '../../theme/app_themes.dart';
import '../../routes/app_router.dart';

class UnitDetailPage extends StatefulWidget {
  final String unitId;

  const UnitDetailPage({Key? key, required this.unitId}) : super(key: key);

  @override
  State<UnitDetailPage> createState() => _UnitDetailPageState();
}

class _UnitDetailPageState extends State<UnitDetailPage> with WidgetsBindingObserver {
  UnitModel? unit;
  CourseModel? course;
  List<LessonModel> lessons = [];
  bool isLoading = true;
  String errorMessage = '';
  bool _needsReload = false; // Add reload flag

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Always reload when returning to this page
    print('🔄 [UnitDetail] didChangeDependencies - triggering reload');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        print('🔄 [UnitDetail] Executing reload...');
        _loadData();
      }
    });
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







  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      // Load unit, course, and lessons in parallel
      await Future.wait([
        _loadUnit(),
        _loadLessons(),
      ]);
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _loadUnit() async {
    try {
      final units = await AdminService.getAllUnits();
      final unitData = units.firstWhere((u) => u.id == widget.unitId);
      setState(() {
        unit = unitData;
      });
      
      // Load course for this unit
      await _loadCourse(unitData.courseId);
    } catch (e) {
      print('❌ Error loading unit: $e');
    }
  }

  Future<void> _loadCourse(String courseId) async {
    try {
      final courses = await AdminService.getAllCourses();
      final courseData = courses.firstWhere((c) => c.id == courseId);
      setState(() {
        course = courseData;
      });
    } catch (e) {
      print('❌ Error loading course: $e');
    }
  }

  Future<void> _loadLessons() async {
    try {
      print('🔄 [UnitDetail] Loading lessons for unit: ${widget.unitId}');
      final allLessons = await AdminService.getAllLessons();
      print('📥 [UnitDetail] Received ${allLessons.length} total lessons');
      
      final unitLessons = allLessons.where((l) => l.unitId == widget.unitId).toList();
      print('📋 [UnitDetail] Found ${unitLessons.length} lessons for this unit');
      print('📋 [UnitDetail] Lesson titles: ${unitLessons.map((l) => l.title).toList()}');
      
      setState(() {
        lessons = unitLessons;
        isLoading = false;
      });
      print('✅ [UnitDetail] State updated with ${lessons.length} lessons');
    } catch (e) {
      print('❌ [UnitDetail] Error loading lessons: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _handleLessonAction(String action, LessonModel lesson) {
    switch (action) {
      case 'edit':
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (unit == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Unit Not Found'),
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Unit not found'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppThemes.lightGroupedBackground,
      appBar: AppBar(
        backgroundColor: AppThemes.lightSecondaryBackground,
        title: Text('${unit!.title} - Lessons', style: const TextStyle(color: AppThemes.lightLabel)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppThemes.primaryGreen),
          onPressed: () => context.go('${AppRouter.adminCourseDetail.replaceAll(':courseId', unit!.courseId)}'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppThemes.primaryGreen),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: Icon(Icons.add, color: AppThemes.primaryGreen),
            onPressed: () => context.go('${AppRouter.adminCreateLesson}?unitId=${unit!.id}&courseId=${unit!.courseId}'),
            tooltip: 'Add Lesson',
          ),
        ],
      ),
      body: Column(
        children: [
          // Unit Info Section
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
                    Container(
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
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            unit!.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppThemes.primaryGreen,
                            ),
                          ),
                          Text(
                            unit!.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppThemes.lightSecondaryLabel,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (course != null)
                            Text(
                              'Course: ${course!.title}',
                              style: TextStyle(
                                fontSize: 12,
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
                    _buildStatCard('Lessons', lessons.length.toString(), Icons.book),
                    const SizedBox(width: 12),
                    _buildStatCard('Published', lessons.where((l) => l.isPublished).length.toString(), Icons.published_with_changes),
                    const SizedBox(width: 12),
                    _buildStatCard('Draft', lessons.where((l) => !l.isPublished).length.toString(), Icons.edit_note),
                  ],
                ),
              ],
            ),
          ),

          // Lessons List
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildLessonsList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonsList() {
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
              onPressed: _loadData,
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
            Icon(Icons.book_outlined, size: 64, color: AppThemes.lightSecondaryLabel),
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
              'Add your first lesson to get started',
              style: TextStyle(
                color: AppThemes.lightSecondaryLabel,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.go('${AppRouter.adminCreateLesson}?unitId=${unit!.id}&courseId=${unit!.courseId}'),
              icon: const Icon(Icons.add),
              label: const Text('Add Lesson'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemes.primaryGreen,
                foregroundColor: Colors.white,
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
} 