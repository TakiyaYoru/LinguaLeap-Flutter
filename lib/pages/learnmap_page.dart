import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/learnmap_controller.dart';
import '../network/course_service.dart';
import '../network/learnmap_service.dart';
import 'lesson_detail_page.dart';

class LearnmapPage extends StatefulWidget {
  const LearnmapPage({super.key});

  @override
  State<LearnmapPage> createState() => _LearnmapPageState();
}

class _LearnmapPageState extends State<LearnmapPage> {
  String? selectedCourseId;
  List<Map<String, dynamic>> courses = [];
  bool isLoadingCourses = true;
  String? error;
  LearnmapController? controller;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    setState(() {
      isLoadingCourses = true;
      error = null;
    });
    try {
      final data = await CourseService.getAllCourses();
      setState(() {
        courses = data ?? [];
        if (courses.isNotEmpty) selectedCourseId = courses[0]['id'];
      });
    } catch (e) {
      setState(() { error = e.toString(); });
    }
    setState(() { isLoadingCourses = false; });
  }

  Future<void> _testAuth() async {
    final result = await LearnmapService.testAuthentication();
    final isAuth = result != null;
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Auth test: ${isAuth ? "SUCCESS" : "FAILED"}'),
          backgroundColor: isAuth ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _navigateToLesson(String unitId, String lessonId, String lessonStatus) {
    if (lessonStatus == 'locked') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lesson này chưa được mở khóa!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    print('🔄 Navigating to lesson: $lessonId (status: $lessonStatus)');

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LessonDetailPage(
          lessonId: lessonId,
          unitId: unitId,
          lessonTitle: 'Lesson ${lessonId.substring(0, 8)}...',
          currentHearts: controller?.gamificationData?.hearts ?? 5,
          onHeartsChanged: (newHearts) {
            print('🔄 Hearts changed: $newHearts');
            controller?.updateHearts(newHearts);
          },
          onLessonCompleted: (unitId, lessonId, status) {
            print('🔄 Lesson completed: $lessonId -> $status');
            controller?.updateLessonProgress(unitId, lessonId, status);
          },
        ),
      ),
    ).then((_) {
      // Refresh learnmap khi quay về
      print('🔄 Returning from lesson, refreshing learnmap');
      if (controller != null && selectedCourseId != null) {
        controller!.loadLearnmap(selectedCourseId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingCourses) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              ElevatedButton(
                onPressed: _loadCourses,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }
    
    if (courses.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Không có khóa học nào')),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // Top Bar với gamification elements (như ảnh)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple[600]!, Colors.purple[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Builder(
              builder: (context) {
                if (controller == null) {
                  return Row(
                    children: [
                      // Language selector
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.flag, color: Colors.blue, size: 16),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'EN',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Default gamification stats
                      Row(
                        children: [
                          const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                          const SizedBox(width: 4),
                          const Text(
                            '0',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.blue[400],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.diamond, color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '0',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.star_border, color: Colors.yellow, size: 20),
                        ],
                      ),
                    ],
                  );
                }
                
                return ListenableBuilder(
                  listenable: controller!,
                  builder: (context, child) {
                    final gamificationData = controller!.gamificationData;
                    return Row(
                      children: [
                        // Language selector
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(Icons.flag, color: Colors.blue, size: 16),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'EN',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Gamification stats
                        Row(
                          children: [
                            // Streak
                            Row(
                              children: [
                                const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  '${gamificationData?.streak ?? 0}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            // XP/Currency
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[400],
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.diamond, color: Colors.white, size: 16),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${gamificationData?.xp ?? 0}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            // Premium/Star
                            Icon(
                              gamificationData?.isPremium == true 
                                ? Icons.star 
                                : Icons.star_border,
                              color: Colors.yellow,
                              size: 20,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          
          // Course selector
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: courses.length,
              itemBuilder: (context, idx) {
                final course = courses[idx];
                final isSelected = course['id'] == selectedCourseId;
                return GestureDetector(
                  onTap: () {
                    setState(() { selectedCourseId = course['id']; });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.purple[600] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected ? Border.all(color: Colors.purple[800]!, width: 2) : null,
                    ),
                    child: Center(
                      child: Text(
                        course['title'] ?? '',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Main learnmap content
          if (selectedCourseId != null)
            Expanded(
              child: Builder(
                builder: (context) {
                  // Tạo controller nếu chưa có hoặc courseId thay đổi
                  if (controller == null || controller!.courseId != selectedCourseId) {
                    controller?.dispose();
                    controller = LearnmapController();
                    controller!.loadLearnmap(selectedCourseId!);
                  }
                  
                  return ListenableBuilder(
                    listenable: controller!,
                    builder: (context, child) {
                      if (controller!.isLoading) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Đang tải learnmap...'),
                            ],
                          ),
                        );
                      }
                      
                      if (controller!.isInitializing) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Đang khởi tạo lộ trình học...'),
                            ],
                          ),
                        );
                      }
                      
                      if (controller!.error != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, size: 64, color: Colors.red[300]),
                              const SizedBox(height: 16),
                              Text('Lỗi: ${controller!.error}'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => controller!.loadLearnmap(selectedCourseId!),
                                child: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      final learnmap = controller!.learnmap;
                      if (learnmap == null) {
                        return const Center(
                          child: Text('Không có dữ liệu learnmap'),
                        );
                      }
                      
                      final units = learnmap['unitProgress'] as List<dynamic>? ?? [];
                      final gamificationData = controller!.gamificationData;
                      
                      // Debug log
                      print('🔍 [LearnmapPage] Units count: ${units.length}');
                      for (int i = 0; i < units.length; i++) {
                        final unit = units[i];
                        final lessons = unit['lessonProgress'] as List<dynamic>? ?? [];
                        print('  📚 Unit $i: ${lessons.length} lessons, status: ${unit['status']}');
                      }
                      
                      return Column(
                        children: [
                          // Hearts indicator và refresh button
                          Container(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Hearts
                                Row(
                                  children: [
                                    const Icon(Icons.favorite, color: Colors.red),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${gamificationData?.hearts ?? 5}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                // Refresh button
                                IconButton(
                                  onPressed: () {
                                    print('🔄 [LearnmapPage] Manual refresh triggered');
                                    controller?.loadLearnmap(selectedCourseId!);
                                  },
                                  icon: const Icon(Icons.refresh, color: Colors.blue),
                                ),
                              ],
                            ),
                          ),
                          
                          // Learnmap content
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: units.length,
                              itemBuilder: (context, unitIdx) {
                                final unit = units[unitIdx];
                                final lessons = unit['lessonProgress'] as List<dynamic>? ?? [];
                                final unitStatus = unit['status'] ?? 'locked';
                                
                                return _buildUnitSection(unitIdx, unit, lessons, unitStatus);
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUnitSection(int unitIdx, Map<String, dynamic> unit, List<dynamic> lessons, String unitStatus) {
    final gamificationData = controller?.gamificationData;
    final completedLessons = lessons.where((l) => l['status'] == 'completed').length;
    final totalLessons = lessons.length;
    final trophyCount = completedLessons == totalLessons && totalLessons > 0 ? 1 : 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Unit header với trophy
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getUnitColor(unitIdx),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unit ${unitIdx + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '$completedLessons/$totalLessons lessons',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Trophy icon với count
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 20,
                      ),
                      if (trophyCount > 0) ...[
                        const SizedBox(width: 4),
                        Text(
                          '$trophyCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Lessons path
          if (lessons.isNotEmpty)
            ...lessons.asMap().entries.map((entry) {
              final lessonIdx = entry.key;
              final lesson = entry.value;
              final lessonStatus = lesson['status'] ?? 'locked';
              final isLast = lessonIdx == lessons.length - 1;
              
              return _buildLessonNode(
                lessonIdx,
                lesson,
                lessonStatus,
                isLast,
                unitIdx,
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildLessonNode(int lessonIdx, Map<String, dynamic> lesson, String status, bool isLast, int unitIdx) {
    final lessonId = lesson['lessonId'] as String;
    
    // Lấy unitId từ learnmap data
    String unitId;
    if (controller?.learnmap != null) {
      final units = controller!.learnmap!['unitProgress'] as List<dynamic>? ?? [];
      if (unitIdx < units.length) {
        unitId = units[unitIdx]['unitId'] as String;
      } else {
        unitId = 'unit_$unitIdx'; // Fallback
      }
    } else {
      unitId = 'unit_$unitIdx'; // Fallback
    }
    
    return GestureDetector(
      onTap: () => _navigateToLesson(unitId, lessonId, status),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            // Lesson node
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getLessonColor(status),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _getLessonIcon(status),
                color: Colors.white,
                size: 24,
              ),
            ),
            
            // Connection line
            if (!isLast)
              Expanded(
                child: Container(
                  height: 2,
                  color: Colors.grey[300],
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            
            // Lesson info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lesson ${lessonIdx + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Trạng thái: $status',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getUnitColor(int unitIdx) {
    final colors = [
      Colors.red[600]!,
      Colors.green[600]!,
      Colors.blue[600]!,
      Colors.orange[600]!,
      Colors.purple[600]!,
    ];
    return colors[unitIdx % colors.length];
  }

  Color _getLessonColor(String status) {
    switch (status) {
      case 'locked':
        return Colors.grey[400]!;
      case 'unlocked':
        return Colors.blue[400]!;
      case 'in_progress':
        return Colors.orange[400]!;
      case 'completed':
        return Colors.green[400]!;
      default:
        return Colors.grey[400]!;
    }
  }

  IconData _getLessonIcon(String status) {
    switch (status) {
      case 'locked':
        return Icons.lock;
      case 'unlocked':
        return Icons.lock_open;
      case 'in_progress':
        return Icons.play_circle_outline;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.lock;
    }
  }
} 