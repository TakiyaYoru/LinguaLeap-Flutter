// lib/pages/course/unit_detail_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../network/lesson_service.dart';

class UnitDetailPage extends StatefulWidget {
  final String unitId;
  final String unitTitle;
  
  const UnitDetailPage({
    super.key,
    required this.unitId,
    required this.unitTitle,
  });

  @override
  State<UnitDetailPage> createState() => _UnitDetailPageState();
}

class _UnitDetailPageState extends State<UnitDetailPage> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> lessons = [];
  bool isLoading = true;
  String errorMessage = '';
  bool _isDisposed = false;
  DateTime? _lastTapTime;
  
  // Animation controller for path drawing
  late AnimationController _pathController;
  
  // Mock data for progress - should come from backend
  final currentLessonId = "lesson_3";
  final completedLessons = ["lesson_1", "lesson_2"];
  final userProgress = {
    "totalXP": 450,
    "currentStreak": 5,
    "hearts": 5,
    "unitProgress": 0.4, // 40% complete
  };

  @override
  void initState() {
    super.initState();
    _loadLessons();
    
    // Initialize animation controller
    _pathController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    // Start path animation after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pathController.forward();
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _pathController.dispose();
    super.dispose();
  }

  bool _canTap() {
    final now = DateTime.now();
    if (_lastTapTime == null || now.difference(_lastTapTime!) > const Duration(milliseconds: 500)) {
      _lastTapTime = now;
      return true;
    }
    return false;
  }

  Future<void> _loadLessons() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final lessonsData = await LessonService.getUnitLessons(widget.unitId);
      
      if (!mounted || _isDisposed) return;
      
      if (lessonsData != null) {
        setState(() {
          lessons = lessonsData;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load lessons';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted || _isDisposed) return;
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: CustomScrollView(
        slivers: [
          // Custom app bar with unit info
          _buildAppBar(),
          
          // Main content
          SliverToBoxAdapter(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: const Color(0xFF40C4AA),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF40C4AA),
                const Color(0xFF40C4AA).withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    widget.unitTitle,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${lessons.length} lessons • ${userProgress['unitProgress']! * 100}% complete',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Progress stats
                  Row(
                    children: [
                      _buildStatChip('🔥 ${userProgress['currentStreak']} days', Colors.orange),
                      const SizedBox(width: 8),
                      _buildStatChip('⭐ ${userProgress['totalXP']} XP', Colors.amber),
                      const SizedBox(width: 8),
                      _buildStatChip('❤️ ${userProgress['hearts']}/5', Colors.red),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF40C4AA)),
        ),
      );
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
              onPressed: _loadLessons,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF40C4AA),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          
          // Learning path
          ...List.generate(lessons.length, (index) {
            final lesson = lessons[index];
            final isCompleted = completedLessons.contains(lesson['id']);
            final isCurrent = lesson['id'] == currentLessonId;
            final isLocked = !isCompleted && !isCurrent && completedLessons.isNotEmpty;
            
            return _buildLessonItem(
              lesson,
              index,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              isLocked: isLocked,
            );
          }),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: color.withOpacity(0.9),
        ),
      ),
    );
  }

  Widget _buildLessonItem(
    Map<String, dynamic> lesson,
    int index, {
    bool isCompleted = false,
    bool isCurrent = false,
    bool isLocked = false,
  }) {
    final lessonType = lesson['type'] ?? 'lesson';
    
    return Column(
      children: [
        // Connection line
        if (index > 0)
          AnimatedBuilder(
            animation: _pathController,
            builder: (context, child) {
              return Container(
                width: 3,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      isCompleted ? const Color(0xFF40C4AA) : Colors.grey.shade300,
                      isCompleted ? const Color(0xFF40C4AA).withOpacity(0.3) : Colors.grey.shade200,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              );
            },
          ),
          
        // Lesson card
        InkWell(
          onTap: isLocked ? null : () => _handleLessonTap(lesson),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getLessonColor(isCompleted, isCurrent, isLocked),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Status icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getIconColor(isCompleted, isCurrent, isLocked),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      _getLessonIcon(lessonType, isCompleted, isCurrent, isLocked),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Lesson info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson['title'] ?? 'Lesson ${index + 1}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isLocked ? Colors.grey : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lesson['description'] ?? 'Complete this lesson to continue',
                        style: TextStyle(
                          fontSize: 14,
                          color: isLocked ? Colors.grey : Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildLessonStat(
                            Icons.timer_outlined,
                            '${lesson['estimatedDuration'] ?? 5}m',
                            isLocked,
                          ),
                          const SizedBox(width: 16),
                          _buildLessonStat(
                            Icons.star_outline,
                            '+${lesson['xpReward'] ?? 10} XP',
                            isLocked,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Right icon/status
                Icon(
                  isCompleted ? Icons.check_circle :
                  isCurrent ? Icons.play_circle_fill :
                  isLocked ? Icons.lock : Icons.arrow_forward_ios,
                  color: isCompleted ? Colors.green :
                         isCurrent ? const Color(0xFF40C4AA) :
                         isLocked ? Colors.grey : Colors.grey.shade400,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLessonStat(IconData icon, String text, bool isLocked) {
    final color = isLocked ? Colors.grey : Colors.grey.shade600;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getLessonColor(bool isCompleted, bool isCurrent, bool isLocked) {
    if (isLocked) return Colors.grey.shade100;
    if (isCompleted) return Colors.green.shade50;
    if (isCurrent) return const Color(0xFF40C4AA).withOpacity(0.1);
    return Colors.white;
  }

  Color _getIconColor(bool isCompleted, bool isCurrent, bool isLocked) {
    if (isLocked) return Colors.grey;
    if (isCompleted) return Colors.green;
    if (isCurrent) return const Color(0xFF40C4AA);
    return Colors.orange;
  }

  IconData _getLessonIcon(String type, bool isCompleted, bool isCurrent, bool isLocked) {
    if (isLocked) return Icons.lock;
    if (isCompleted) return Icons.check;
    if (isCurrent) return Icons.play_arrow;
    
    switch (type) {
      case 'vocabulary':
        return Icons.book;
      case 'grammar':
        return Icons.edit;
      case 'conversation':
        return Icons.chat;
      case 'listening':
        return Icons.headphones;
      case 'reading':
        return Icons.article;
      default:
        return Icons.school;
    }
  }

  void _handleLessonTap(Map<String, dynamic> lesson) {
    if (!_canTap()) return;
    
    final lessonId = lesson['id'] ?? '';
    final lessonTitle = lesson['title'] ?? 'Lesson';
    
    if (lessonId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lesson ID not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.push('/lesson/$lessonId?title=${Uri.encodeComponent(lessonTitle)}');
  }
}