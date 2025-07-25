import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/course_model.dart';
import '../../models/unit_model.dart';
import '../../network/admin_service.dart';
import '../../theme/app_themes.dart';
import '../../routes/app_router.dart';

class CourseDetailPage extends StatefulWidget {
  final String courseId;

  const CourseDetailPage({Key? key, required this.courseId}) : super(key: key);

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  CourseModel? course;
  List<UnitModel> units = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload data when returning to this page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadData();
      }
    });
  }



  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      // Load course and units in parallel
      await Future.wait([
        _loadCourse(),
        _loadUnits(),
      ]);
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _loadCourse() async {
    try {
      final courses = await AdminService.getAllCourses();
      final courseData = courses.firstWhere((c) => c.id == widget.courseId);
      setState(() {
        course = courseData;
      });
    } catch (e) {
      print('❌ Error loading course: $e');
    }
  }

  Future<void> _loadUnits() async {
    try {
      final allUnits = await AdminService.getAllUnits();
      final courseUnits = allUnits.where((u) => u.courseId == widget.courseId).toList();
      setState(() {
        units = courseUnits;
        isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading units: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _handleUnitAction(String action, UnitModel unit) {
    switch (action) {
      case 'edit':
        context.go('${AppRouter.adminEditUnit.replaceAll(':unitId', unit.id)}?courseId=${course!.id}');
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (course == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Course Not Found'),
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Course not found'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppThemes.lightGroupedBackground,
      appBar: AppBar(
        backgroundColor: AppThemes.lightSecondaryBackground,
        title: Text('${course!.title} - Units', style: const TextStyle(color: AppThemes.lightLabel)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppThemes.primaryGreen),
          onPressed: () => context.go(AppRouter.adminDashboard),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppThemes.primaryGreen),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: Icon(Icons.add, color: AppThemes.primaryGreen),
            onPressed: () => context.go('${AppRouter.adminCreateUnit}?courseId=${course!.id}'),
            tooltip: 'Add Unit',
          ),
        ],
      ),
      body: Column(
        children: [
          // Course Info Section
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
                        Icons.book,
                        color: AppThemes.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course!.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppThemes.primaryGreen,
                            ),
                          ),
                          Text(
                            course!.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppThemes.lightSecondaryLabel,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard('Units', units.length.toString(), Icons.layers),
                    const SizedBox(width: 12),
                    _buildStatCard('Published', units.where((u) => u.isPublished).length.toString(), Icons.published_with_changes),
                    const SizedBox(width: 12),
                    _buildStatCard('Draft', units.where((u) => !u.isPublished).length.toString(), Icons.edit_note),
                  ],
                ),
              ],
            ),
          ),

          // Units List
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildUnitsList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitsList() {
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
              'Add your first unit to get started',
              style: TextStyle(
                color: AppThemes.lightSecondaryLabel,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.go('${AppRouter.adminCreateUnit}?courseId=${course!.id}'),
              icon: const Icon(Icons.add),
              label: const Text('Add Unit'),
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
          onTap: () => context.go('${AppRouter.adminUnitDetail.replaceAll(':unitId', unit.id)}'),
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