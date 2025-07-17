// lib/features/courses/presentation/pages/courses_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../network/course_service.dart';
import '../../network/progress_service.dart';
import '../../models/course_model.dart';
import '../../models/unit_model.dart';
import '../../models/lesson_model.dart' show LessonModel;
import '../../network/lesson_service.dart'; // Added import for LessonService

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  List<CourseModel> courses = [];
  bool isLoading = true;
  String errorMessage = '';
  
  // Progress data
  Map<String, dynamic> userProgress = {
    'currentUnitId': '',
    'currentLessonId': '',
    'completedLessons': <String>[],
    'streak': 0,
    'dailyXPGoal': 50,
    'currentDayXP': 0,
    'hearts': 5,
    'totalXP': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      // Load courses and progress in parallel
      final futures = await Future.wait([
        CourseService.getAllCourses(),
        ProgressService.getUserProgress(),
      ]);

      final coursesData = futures[0] as List<dynamic>?;
      final progressData = futures[1] as Map<String, dynamic>?;

      if (!mounted) return;

      if (coursesData != null) {
        setState(() {
          courses = coursesData
              .map((courseJson) => CourseModel.fromJson(courseJson))
              .toList();
        });
      }

      if (progressData != null) {
        setState(() {
          userProgress = {
            'currentUnitId': progressData['currentUnitId'] ?? '',
            'currentLessonId': progressData['currentLessonId'] ?? '',
            'completedLessons': List<String>.from(progressData['completedLessons'] ?? []),
            'streak': progressData['streak'] ?? 0,
            'dailyXPGoal': progressData['dailyXPGoal'] ?? 50,
            'currentDayXP': progressData['currentDayXP'] ?? 0,
            'hearts': progressData['hearts'] ?? 5,
            'totalXP': progressData['totalXP'] ?? 0,
          };
        });
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  // Get current course progress
  double _getCourseProgress(String courseId) {
    try {
      final course = courses.firstWhere((c) => c.id == courseId);
      final totalLessons = course.totalLessons ?? 0;
      if (totalLessons == 0) return 0.0;

      final completedInCourse = userProgress['completedLessons']
          .where((lessonId) => lessonId.startsWith(courseId))
          .length;

      return completedInCourse / totalLessons;
    } catch (e) {
      return 0.0;
    }
  }

  // Get current lesson info
  Future<Map<String, dynamic>> _getCurrentLessonInfo() async {
    try {
      if (courses.isEmpty || userProgress['currentLessonId'] == null) {
        return {
          'courseId': '',
          'lessonTitle': 'No lesson in progress',
          'courseTitle': '',
        };
      }

      final currentLessonId = userProgress['currentLessonId'];
      
      // Find course containing current lesson
      for (final course in courses) {
        // Get lesson details using LessonService
        final lessonData = await LessonService.getLesson(currentLessonId);
        
        if (lessonData != null && lessonData['courseId'] == course.id) {
          return {
            'courseId': course.id,
            'lessonTitle': lessonData['title'] ?? 'Untitled Lesson',
            'courseTitle': course.title,
          };
        }
      }

      return {
        'courseId': '',
        'lessonTitle': 'Lesson not found',
        'courseTitle': '',
      };
    } catch (e) {
      print('❌ Error getting current lesson info: $e');
      return {
        'courseId': '',
        'lessonTitle': 'Error loading lesson',
        'courseTitle': '',
      };
    }
  }

  // Get current unit progress
  double _getUnitProgress(String unitId) {
    try {
      final completedInUnit = userProgress['completedLessons']
          .where((lessonId) => lessonId.startsWith(unitId))
          .length;
      
      // Assuming 10 lessons per unit for now
      // TODO: Get actual unit lesson count from backend
      return completedInUnit / 10;
    } catch (e) {
      return 0.0;
    }
  }

  Widget _buildCompactLearningProgress() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getCurrentLessonInfo(),
      builder: (context, snapshot) {
        // Find current course and unit
        CourseModel? currentCourse;
        UnitModel? currentUnit;
        double progress = 0.0;

        if (snapshot.hasData && snapshot.data!['courseId'].isNotEmpty) {
          try {
            currentCourse = courses.firstWhere(
              (course) => course.id == snapshot.data!['courseId']
            );
            currentUnit = currentCourse.getCurrentUnit(userProgress['currentUnitId']);
            progress = currentCourse.getProgress(
              List<String>.from(userProgress['completedLessons'] ?? [])
            );
          } catch (e) {
            print('Error finding current progress: $e');
          }
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF40C4AA),
                  const Color(0xFF40C4AA).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF40C4AA).withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  final currentLessonId = userProgress['currentLessonId'];
                  if (currentLessonId?.isNotEmpty == true) {
                    context.go('/lesson/$currentLessonId');
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // Left side - Text content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              currentCourse?.title ?? 'Bắt đầu học ngay!',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (currentUnit != null && snapshot.hasData) ...[
                              const SizedBox(height: 4),
                              Text(
                                '${currentUnit.title} - ${snapshot.data!['lessonTitle']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 8),
                            // Progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Right side - Continue button
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.play_arrow,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInlineQuickStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCompactStat(
            icon: Icons.local_fire_department,
            value: '${userProgress['streak']}',
            label: 'Streak',
            color: Colors.orange,
          ),
          _buildCompactStat(
            icon: Icons.star,
            value: '${userProgress['totalXP']}',
            label: 'XP',
            color: Colors.amber,
          ),
          _buildCompactStat(
            icon: Icons.favorite,
            value: '${userProgress['hearts']}',
            label: 'Hearts',
            color: Colors.red,
          ),
          _buildCompactStat(
            icon: Icons.timeline,
            value: '${userProgress['currentDayXP']}/${userProgress['dailyXPGoal']}',
            label: 'Hôm nay',
            color: const Color(0xFF40C4AA),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF40C4AA),
        title: const Text(
          'Học tiếng Anh',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.diamond_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: const Color(0xFF40C4AA),
        child: ListView(
          children: [
            // Compact Learning Progress Section
            _buildCompactLearningProgress(),
            
            // Inline Quick Stats
            _buildInlineQuickStats(),

            // Course List Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Khóa học của bạn',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...courses.map((course) => _buildCourseCard(course)).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(CourseModel course) {
    final progress = course.getProgress(
      List<String>.from(userProgress['completedLessons'] ?? [])
    );
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.go('/course/${course.id}'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: course.colorValue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.school,
                        color: course.colorValue,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            course.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
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
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(course.colorValue),
                          minHeight: 4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${(progress * 100).round()}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: course.colorValue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildCourseStatChip(
                      Icons.book,
                      '${course.totalLessons} bài học',
                    ),
                    const SizedBox(width: 12),
                    _buildCourseStatChip(
                      Icons.timer,
                      '${course.estimatedHours}h',
                    ),
                    const Spacer(),
                    if (course.isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.amber.withOpacity(0.5),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Premium',
                              style: TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}