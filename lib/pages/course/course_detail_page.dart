// lib/pages/course/course_detail_page.dart - BULLETPROOF VERSION
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../network/course_service.dart';
import '../../models/course_model.dart';
import '../../utils/safe_navigator.dart'; // Import our safe navigator

class CourseDetailPage extends StatefulWidget {
  final String courseId;
  
  const CourseDetailPage({
    super.key,
    required this.courseId,
  });

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  CourseModel? course;
  List<Map<String, dynamic>> units = [];
  bool isLoading = true;
  String errorMessage = '';
  
  // 🔥 SIMPLIFIED: Remove complex navigation state
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _loadCourseDetail();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  // 🔥 BULLETPROOF: Handle unit tap with SafeNavigator
  Future<void> _handleUnitTap(Map<String, dynamic> unit) async {
    final unitId = unit['id'] ?? '';
    final unitTitle = unit['title'] ?? 'Unit';
    
    if (unitId.isEmpty) {
      _showError('Unit ID not found');
      return;
    }

    final route = '/unit/$unitId?title=${Uri.encodeComponent(unitTitle)}';
    await SafeNavigator.safePush(
      context, 
      route,
      debugName: 'unit_$unitId',
    );
  }

  // 🔥 BULLETPROOF: Handle back navigation
  Future<void> _handleBackTap() async {
    // Try GoRouter first, then Navigator
    if (GoRouter.of(context).canPop()) {
      GoRouter.of(context).pop();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      // Last resort: go to courses page
      context.go('/courses');
    }
  }

  void _showError(String message) {
    if (!mounted || _isDisposed) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _loadCourseDetail() async {
    try {
      if (!mounted) return;
      
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      // Load course info
      final courseData = await CourseService.getCourse(widget.courseId);
      
      if (!mounted || _isDisposed) return;
      
      if (courseData == null) {
        setState(() {
          errorMessage = 'Course not found';
          isLoading = false;
        });
        return;
      }

      // Load course units
      final unitsData = await CourseService.getCourseUnits(widget.courseId);
      
      if (!mounted || _isDisposed) return;
      
      setState(() {
        course = CourseModel.fromJson(courseData);
        units = unitsData ?? [];
        isLoading = false;
      });
    } catch (e) {
      if (!mounted || _isDisposed) return;
      
      setState(() {
        errorMessage = 'Error loading course: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(course?.title ?? 'Course'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        // 🔥 BULLETPROOF: Safe back button with SafeTapWidget
        leading: SafeTapWidget(
          onTap: _handleBackTap,
          child: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCourseDetail,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (course == null) {
      return const Center(child: Text('Course not found'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCourseHeader(),
          const SizedBox(height: 24),
          _buildUnitsSection(),
        ],
      ),
    );
  }

  Widget _buildCourseHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(int.parse(course!.color.replaceFirst('#', '0xFF'))),
            Color(int.parse(course!.color.replaceFirst('#', '0xFF'))).withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            course!.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            course!.description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatChip('${course!.totalUnits} Units', Icons.folder),
              const SizedBox(width: 12),
              _buildStatChip('${course!.totalLessons} Lessons', Icons.book),
              const SizedBox(width: 12),
              _buildStatChip('${course!.estimatedDuration}min', Icons.access_time),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Units (${units.length})',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        if (units.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No units available yet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: units.length,
            itemBuilder: (context, index) => _buildUnitCard(units[index], index),
          ),
      ],
    );
  }

  Widget _buildUnitCard(Map<String, dynamic> unit, int index) {
    final theme = unit['theme'] ?? 'general';
    final isUnlocked = unit['isUnlocked'] ?? (index == 0);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: SafeTapWidget(
        // 🔥 BULLETPROOF: Safe tap with built-in debouncing
        onTap: isUnlocked ? () => _handleUnitTap(unit) : null,
        enabled: isUnlocked,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isUnlocked 
              ? Theme.of(context).colorScheme.surface
              : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isUnlocked 
                ? Theme.of(context).primaryColor.withOpacity(0.3)
                : Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              // Unit Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isUnlocked 
                    ? _getThemeColor(theme)
                    : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  _getThemeIcon(theme),
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              
              // Unit Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unit['title'] ?? 'Unit ${index + 1}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isUnlocked ? null : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      unit['description'] ?? 'Learn the basics',
                      style: TextStyle(
                        fontSize: 14,
                        color: isUnlocked 
                          ? Colors.grey.shade600 
                          : Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.book_outlined,
                          size: 16,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${unit['totalLessons'] ?? 0} lessons',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.star_outline,
                          size: 16,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+${unit['xpReward'] ?? 0} XP',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Status Icon
              const SizedBox(width: 8),
              Icon(
                isUnlocked ? Icons.play_circle_fill : Icons.lock,
                color: isUnlocked 
                  ? Theme.of(context).primaryColor 
                  : Colors.grey.shade400,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getThemeColor(String theme) {
    switch (theme.toLowerCase()) {
      case 'greetings':
        return Colors.blue;
      case 'family':
        return Colors.green;
      case 'food':
        return Colors.orange;
      case 'travel':
        return Colors.purple;
      case 'work':
        return Colors.teal;
      default:
        return Colors.indigo;
    }
  }

  IconData _getThemeIcon(String theme) {
    switch (theme.toLowerCase()) {
      case 'greetings':
        return Icons.waving_hand;
      case 'family':
        return Icons.family_restroom;
      case 'food':
        return Icons.restaurant;
      case 'travel':
        return Icons.flight;
      case 'work':
        return Icons.work;
      default:
        return Icons.school;
    }
  }
}