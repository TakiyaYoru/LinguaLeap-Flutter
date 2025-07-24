import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/learnmap_controller.dart';
import '../network/course_service.dart';
import '../network/learnmap_service.dart';
import '../theme/app_themes.dart';
import 'lesson_detail_page.dart';

class LearnmapPage extends StatefulWidget {
  const LearnmapPage({super.key});

  @override
  State<LearnmapPage> createState() => _LearnmapPageState();
}

class _LearnmapPageState extends State<LearnmapPage> with TickerProviderStateMixin {
  String? selectedCourseId;
  List<Map<String, dynamic>> courses = [];
  bool isLoadingCourses = true;
  String? error;
  LearnmapController? controller;
  late AnimationController _unlockAnimationController;
  late AnimationController _startBubbleAnimationController; // New animation controller
  late Animation<double> _startBubbleAnimation;
  
  // Scroll control
  final ScrollController _scrollController = ScrollController();
  bool _showBackToCurrentButton = false;
  int? _currentLessonIndex;
  int? _currentUnitIndex;

  // Unit gradient colors matching app theme
  final List<LinearGradient> unitGradients = [
    const LinearGradient(
      colors: [AppThemes.systemRed, AppThemes.systemOrange], // Red to Orange
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [AppThemes.primaryGreen, AppThemes.systemTeal], // Green to Teal
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [AppThemes.systemBlue, AppThemes.systemIndigo], // Blue to Indigo
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _unlockAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // START! bubble animation controller
    _startBubbleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Bounce animation for START! bubble
    _startBubbleAnimation = Tween<double>(
      begin: -15.0,
      end: -20.0,
    ).animate(CurvedAnimation(
      parent: _startBubbleAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Start the bounce animation and repeat
    _startBubbleAnimationController.repeat(reverse: true);
    
    // Scroll listener to show/hide back button
    _scrollController.addListener(_onScroll);
    
    _loadCourses();
  }

  @override
  void dispose() {
    _unlockAnimationController.dispose();
    _startBubbleAnimationController.dispose();
    _scrollController.dispose();
    controller?.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Show back button when scrolled away from current lesson
    if (_currentLessonIndex != null && _currentUnitIndex != null) {
      final currentPosition = _scrollController.offset;
      final shouldShow = currentPosition > 200; // Show after scrolling 200px
      
      if (shouldShow != _showBackToCurrentButton) {
        setState(() {
          _showBackToCurrentButton = shouldShow;
        });
      }
    }
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

  void _navigateToLesson(String unitId, String lessonId, String lessonStatus) {
    if (lessonStatus == 'locked') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complete previous lessons to unlock this one'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LessonDetailPage(
          lessonId: lessonId,
          unitId: unitId,
          lessonTitle: 'Lesson ${lessonId.substring(0, 8)}...',
          currentHearts: controller?.gamificationData?.hearts ?? 5,
          onHeartsChanged: (newHearts) {
            controller?.updateHearts(newHearts);
          },
          onLessonCompleted: (unitId, lessonId, status) {
            controller?.updateLessonProgress(unitId, lessonId, status);
          },
        ),
      ),
    ).then((_) {
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
              Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCourses,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    
    if (courses.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No courses available')),
      );
    }

    return Scaffold(
      backgroundColor: AppThemes.lightGroupedBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildCourseSelector(),
            if (selectedCourseId != null)
              Expanded(child: _buildLearnmapContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final gamificationData = controller?.gamificationData;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppThemes.primaryGreen, AppThemes.primaryGreenLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Language selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20,
                  height: 14,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: AppThemes.systemBlue,
                  ),
                  child: const Center(
                    child: Text('🇺🇸', style: TextStyle(fontSize: 10)),
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'EN',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Stats row
          Row(
            children: [
              // Streak
              _buildStatItem(
                icon: Icons.local_fire_department,
                iconColor: AppThemes.streak,
                value: '4',
              ),
              const SizedBox(width: 20),
              
              // XP/Gems
              _buildStatItem(
                icon: Icons.diamond,
                iconColor: AppThemes.xp,
                value: '957',
              ),
              const SizedBox(width: 20),
              
              // Hearts (real data)
              _buildStatItem(
                icon: Icons.favorite,
                iconColor: AppThemes.hearts,
                value: '${gamificationData?.hearts ?? 5}',
              ),
              const SizedBox(width: 20),
              
              // Premium star
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppThemes.premium,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildCourseSelector() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppThemes.primaryGreen, AppThemes.primaryGreenLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          final isSelected = course['id'] == selectedCourseId;
          
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedCourseId = course['id'];
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                  border: isSelected ? null : Border.all(
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  course['title'] ?? 'Unknown Course',
                  style: TextStyle(
                    color: isSelected ? AppThemes.primaryGreen : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLearnmapContent() {
    // Initialize controller if needed
    if (controller == null || controller!.courseId != selectedCourseId) {
      controller?.dispose();
      controller = LearnmapController();
      controller!.loadLearnmap(selectedCourseId!);
    }
    
    return Stack(
      children: [
        ListenableBuilder(
          listenable: controller!,
          builder: (context, child) {
            if (controller!.isLoading || controller!.isInitializing) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppThemes.primaryGreen),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading your learning path...',
                      style: TextStyle(color: AppThemes.lightSecondaryLabel),
                    ),
                  ],
                ),
              );
            }
            
            if (controller!.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: AppThemes.lightSecondaryLabel),
                    const SizedBox(height: 16),
                    Text('Error: ${controller!.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => controller!.loadLearnmap(selectedCourseId!),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            
            final learnmap = controller!.learnmap;
            if (learnmap == null) {
              return const Center(
                child: Text('No learning path data available'),
              );
            }
            
            final units = learnmap['unitProgress'] as List<dynamic>? ?? [];
            
            // Find current lesson position for auto-scroll
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _findAndScrollToCurrentLesson(units);
            });
            
            return ListView.builder(
              controller: _scrollController,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: units.length,
              itemBuilder: (context, unitIndex) {
                final unit = units[unitIndex];
                final lessons = unit['lessonProgress'] as List<dynamic>? ?? [];
                
                return Column(
                  children: [
                    _buildUnitHeader(unit, unitIndex + 1),
                    const SizedBox(height: 30),
                    _buildPerfectZigzagPath(lessons, unitIndex),
                    const SizedBox(height: 40),
                  ],
                );
              },
            );
          },
        ),
        
        // Floating back to current button
        if (_showBackToCurrentButton)
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _scrollToCurrentLesson,
              backgroundColor: AppThemes.primaryGreen,
              child: const Icon(
                Icons.my_location,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  void _findAndScrollToCurrentLesson(List<dynamic> units) {
    for (int unitIndex = 0; unitIndex < units.length; unitIndex++) {
      final lessons = units[unitIndex]['lessonProgress'] as List<dynamic>? ?? [];
      for (int lessonIndex = 0; lessonIndex < lessons.length; lessonIndex++) {
        final lesson = lessons[lessonIndex];
        final status = lesson['status'] ?? 'locked';
        
        if (status == 'unlocked' || status == 'in_progress') {
          _currentUnitIndex = unitIndex;
          _currentLessonIndex = lessonIndex;
          
          // Auto scroll to current lesson on first load
          if (_scrollController.hasClients) {
            final targetOffset = _calculateScrollOffset(unitIndex, lessonIndex);
            _scrollController.animateTo(
              targetOffset,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
            );
          }
          return;
        }
      }
    }
  }

  void _scrollToCurrentLesson() {
    if (_currentUnitIndex != null && _currentLessonIndex != null && _scrollController.hasClients) {
      final targetOffset = _calculateScrollOffset(_currentUnitIndex!, _currentLessonIndex!);
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  double _calculateScrollOffset(int unitIndex, int lessonIndex) {
    // Calculate approximate scroll position based on unit and lesson index
    const double unitHeaderHeight = 100.0;
    const double unitSpacing = 70.0;
    const double lessonNodeHeight = 120.0;
    const double lessonSpacing = 50.0;
    
    double offset = 16.0; // Initial padding
    
    // Add height for previous units
    for (int i = 0; i < unitIndex; i++) {
      offset += unitHeaderHeight + unitSpacing;
      // Add approximate height for lessons in previous units (assume 4 lessons per unit)
      offset += (4 * lessonNodeHeight) + (3 * lessonSpacing) + 40.0; // Unit bottom margin
    }
    
    // Add height for current unit header
    offset += unitHeaderHeight + 30.0; // Unit header + spacing
    
    // Add height for lessons before current lesson
    offset += lessonIndex * (lessonNodeHeight + lessonSpacing);
    
    // Center the current lesson in view
    offset -= 200.0; // Offset to center in viewport
    
    return offset.clamp(0.0, _scrollController.position.maxScrollExtent);
  }

  Widget _buildUnitHeader(Map<String, dynamic> unit, int unitNumber) {
    final gradient = unitGradients[(unitNumber - 1) % unitGradients.length];
    final lessons = unit['lessonProgress'] as List<dynamic>? ?? [];
    final completedLessons = lessons.where((l) => l['status'] == 'completed').length;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Trophy with unit number
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 24,
                ),
                Positioned(
                  bottom: 6,
                  child: Text(
                    '$unitNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Unit info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unit['title'] ?? 'Unit $unitNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completedLessons/${lessons.length} lessons',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Progress circle
          if (lessons.isNotEmpty)
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                value: completedLessons / lessons.length,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPerfectZigzagPath(List<dynamic> lessons, int unitIndex) {
    const double nodeSize = 120.0; // Increased more to accommodate START! bubble
    const double verticalSpacing = 40.0;
    
    return Container(
      width: double.infinity,
      child: Column(
        children: List.generate(lessons.length, (index) {
          final lesson = lessons[index];
          final status = lesson['status'] ?? 'locked';
          final isCurrentLesson = status == 'unlocked' || status == 'in_progress';
          
          // True "dích dắc" pattern: alternating left-right
          final isLeftSide = index % 2 == 0;
          final isLast = index == lessons.length - 1;
          
          return Column(
            children: [
              // Lesson node row with proper spacing
              SizedBox(
                height: nodeSize,
                child: Stack(
                  clipBehavior: Clip.none, // Allow overflow for START! bubble
                  children: [
                    // Lesson node positioned
                    Positioned(
                      left: isLeftSide ? 40 : null,
                      right: isLeftSide ? null : 40,
                      top: 20, // Add top padding for START! bubble
                      child: _buildLessonNode(
                        lesson, 
                        status, 
                        isCurrentLesson, 
                        unitIndex, 
                        index + 1
                      ),
                    ),
                    
                    // Lesson number overlay - positioned below node
                    Positioned(
                      left: isLeftSide ? 75 : null, // Centered on node
                      right: isLeftSide ? null : 75,
                      bottom: 15, // Position at bottom with some margin
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: _getLessonColor(status), 
                            width: 2.5
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: _getLessonColor(status),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Connection path
              if (!isLast)
                _buildZigzagConnectionPath(isLeftSide, index + 1 < lessons.length),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLessonNode(Map<String, dynamic> lesson, String status, bool isCurrentLesson, int unitIndex, int lessonNumber) {
    final lessonId = lesson['lessonId'] as String;
    
    // Get unitId from learnmap data
    String unitId;
    if (controller?.learnmap != null) {
      final units = controller!.learnmap!['unitProgress'] as List<dynamic>? ?? [];
      if (unitIndex < units.length) {
        unitId = units[unitIndex]['unitId'] as String;
      } else {
        unitId = 'unit_$unitIndex';
      }
    } else {
      unitId = 'unit_$unitIndex';
    }
    
    return GestureDetector(
      onTap: () => _navigateToLesson(unitId, lessonId, status),
      child: Container(
        width: 90, // Keep larger size
        height: 90, // Keep larger size
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none, // Allow START! bubble to overflow
          children: [
            // Main circle (larger)
            Container(
              width: 80, // Increased from 70
              height: 80, // Increased from 70
              decoration: BoxDecoration(
                gradient: _getLessonGradient(status),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _getLessonColor(status).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: Colors.white,
                  width: 4, // Thicker border
                ),
              ),
              child: Icon(
                _getLessonIcon(status),
                color: Colors.white,
                size: status == 'locked' ? 28 : 32, // Larger icons
              ),
            ),
            
            // START! bubble for current lesson - positioned above node with animation
            if (isCurrentLesson)
              AnimatedBuilder(
                animation: _startBubbleAnimation,
                builder: (context, child) {
                  return Positioned(
                    top: _startBubbleAnimation.value, // Animated position
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: _getLessonColor(status), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        'START!',
                        style: TextStyle(
                          color: _getLessonColor(status),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildZigzagConnectionPath(bool currentIsLeft, bool hasNext) {
    const double verticalSpacing = 50.0;
    
    if (!hasNext) return const SizedBox.shrink();
    
    // Next lesson will be on opposite side
    final nextIsLeft = !currentIsLeft;
    const double nodeOffset = 85.0; // Adjusted for better centering
    
    return Container(
      height: verticalSpacing,
      width: double.infinity,
      child: Stack(
        children: [
          // Vertical line down from current node
          Positioned(
            left: currentIsLeft ? nodeOffset : null,
            right: currentIsLeft ? null : nodeOffset,
            top: 0,
            child: Container(
              width: 2,
              height: verticalSpacing * 0.4,
              color: AppThemes.systemGray3,
            ),
          ),
          
          // Horizontal line connecting both sides
          Positioned(
            top: verticalSpacing * 0.4,
            left: nodeOffset,
            right: nodeOffset,
            child: Container(
              height: 2,
              color: AppThemes.systemGray3,
            ),
          ),
          
          // Vertical line up to next node
          Positioned(
            left: nextIsLeft ? nodeOffset : null,
            right: nextIsLeft ? null : nodeOffset,
            top: verticalSpacing * 0.4,
            child: Container(
              width: 2,
              height: verticalSpacing * 0.6,
              color: AppThemes.systemGray3,
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getLessonGradient(String status) {
    switch (status) {
      case 'completed':
        return const LinearGradient(
          colors: [AppThemes.goldColor, AppThemes.systemOrange], // Gold gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'unlocked':
      case 'in_progress':
        return const LinearGradient(
          colors: [AppThemes.primaryGreen, AppThemes.primaryGreenLight], // Green gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return LinearGradient(
          colors: [AppThemes.systemGray3, AppThemes.systemGray2], // Grey gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Color _getLessonColor(String status) {
    switch (status) {
      case 'completed':
        return AppThemes.goldColor;
      case 'unlocked':
      case 'in_progress':
        return AppThemes.primaryGreen;
      default:
        return AppThemes.systemGray3;
    }
  }

  IconData _getLessonIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check;
      case 'unlocked':
      case 'in_progress':
        return Icons.play_arrow;
      default:
        return Icons.lock;
    }
  }
}