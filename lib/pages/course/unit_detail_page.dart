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
  
  // Progress data
  Map<String, dynamic> userProgress = {
    "totalXP": 0,
    "currentStreak": 0,
    "hearts": 5,
    "unitProgress": 0.0,
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
          
          // Calculate unit progress
          if (lessons.isNotEmpty) {
            final completedCount = lessons.where((l) => l['isCompleted'] == true).length;
            userProgress['unitProgress'] = completedCount / lessons.length;
          }
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
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF40C4AA),
                    const Color(0xFF40C4AA).withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF40C4AA).withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar with Back Button
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const Spacer(),
                      _buildProgressRing(),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Title and Progress
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.unitTitle,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${lessons.length} lessons • ${(userProgress['unitProgress'] * 100).toInt()}% complete',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard(
                        icon: '🔥',
                        value: userProgress['currentStreak'].toString(),
                        label: 'Streak',
                        color: Colors.orange,
                      ),
                      _buildStatCard(
                        icon: '⭐',
                        value: userProgress['totalXP'].toString(),
                        label: 'XP',
                        color: Colors.amber,
                      ),
                      _buildStatCard(
                        icon: '❤️',
                        value: '${userProgress['hearts']}/5',
                        label: 'Hearts',
                        color: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Lessons List
            Expanded(
              child: _buildLessonsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRing() {
    final progress = userProgress['unitProgress'] as double;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 3,
          ),
          Text(
            '${(progress * 100).toInt()}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonsList() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF40C4AA)),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading lessons...',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
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
                elevation: 2,
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        final isCompleted = lesson['isCompleted'] ?? false;
        final isUnlocked = lesson['isUnlocked'] ?? (index == 0);
        final isCurrent = !isCompleted && isUnlocked;
        final isLocked = !isUnlocked;
        
        return Column(
          children: [
            if (index > 0)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? const Color(0xFF40C4AA).withOpacity(0.3) : Colors.grey.shade200,
              ),
            _buildLessonItem(
              lesson,
              index,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              isLocked: isLocked,
            ),
          ],
        );
      },
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
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLocked ? null : () => _handleLessonTap(lesson),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _getLessonColor(isCompleted, isCurrent, isLocked),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCompleted
                    ? const Color(0xFF40C4AA).withOpacity(0.3)
                    : Colors.grey.shade200,
                width: 1,
              ),
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
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _getIconColor(isCompleted, isCurrent, isLocked),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _getIconColor(isCompleted, isCurrent, isLocked).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      _getLessonIcon(lessonType, isCompleted, isCurrent, isLocked),
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                
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
                          color: isLocked ? Colors.grey.shade400 : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        lesson['description'] ?? 'Complete this lesson to continue',
                        style: TextStyle(
                          fontSize: 14,
                          color: isLocked ? Colors.grey.shade400 : Colors.grey.shade600,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
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
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getStatusColor(isCompleted, isCurrent, isLocked).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      isCompleted ? Icons.check_circle :
                      isCurrent ? Icons.play_circle_fill :
                      isLocked ? Icons.lock : Icons.arrow_forward_ios,
                      color: _getStatusColor(isCompleted, isCurrent, isLocked),
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLessonStat(IconData icon, String text, bool isLocked) {
    final color = isLocked ? Colors.grey.shade400 : Colors.grey.shade600;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getLessonColor(bool isCompleted, bool isCurrent, bool isLocked) {
    if (isLocked) return Colors.grey.shade50;
    if (isCompleted) return const Color(0xFF40C4AA).withOpacity(0.05);
    if (isCurrent) return Colors.white;
    return Colors.white;
  }

  Color _getIconColor(bool isCompleted, bool isCurrent, bool isLocked) {
    if (isLocked) return Colors.grey.shade400;
    if (isCompleted) return const Color(0xFF40C4AA);
    if (isCurrent) return const Color(0xFF40C4AA);
    return const Color(0xFF40C4AA);
  }

  Color _getStatusColor(bool isCompleted, bool isCurrent, bool isLocked) {
    if (isLocked) return Colors.grey.shade400;
    if (isCompleted) return const Color(0xFF40C4AA);
    if (isCurrent) return const Color(0xFF40C4AA);
    return Colors.grey.shade600;
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
