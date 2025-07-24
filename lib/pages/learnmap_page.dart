import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../controllers/learnmap_controller.dart';
import '../network/course_service.dart';
import '../network/learnmap_service.dart';
import '../theme/app_themes.dart';
import '../widgets/snake_path_layout.dart'; // Import new component
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
  late AnimationController _startBubbleAnimationController;
  late Animation<double> _startBubbleAnimation;
  
  // Scroll control
  final ScrollController _scrollController = ScrollController();
  bool _showBackToCurrentButton = false;
  int? _currentLessonIndex;
  int? _currentUnitIndex;

  // Course selector dropdown
  bool _showCourseDropdown = false;

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
        if (courses.isNotEmpty) {
          // Tìm course "English for Beginners" hoặc course thứ 3
          final targetCourse = courses.firstWhere(
            (course) => course['id'] == '687e0d13368265caaba5570c',
            orElse: () => courses.length >= 3 ? courses[2] : courses[0],
          );
          selectedCourseId = targetCourse['id'];
          print('🎯 Selected course: ${targetCourse['title']} (ID: $selectedCourseId)');
        }
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
      appBar: AppBar(
        backgroundColor: AppThemes.lightSecondaryBackground,
        title: const Text(
          'Học tiếng Anh',
          style: TextStyle(color: AppThemes.lightLabel),
        ),
        actions: [
          // Course selector dropdown
          PopupMenuButton<String>(
            icon: Icon(Icons.school, color: AppThemes.primaryGreen),
            onSelected: (courseId) {
              setState(() {
                selectedCourseId = courseId;
              });
            },
            itemBuilder: (context) => courses.map((course) {
              return PopupMenuItem<String>(
                value: course['id'],
                child: Row(
                  children: [
                    Icon(
                      Icons.check,
                      color: course['id'] == selectedCourseId 
                          ? AppThemes.primaryGreen 
                          : Colors.transparent,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        course['title'] ?? 'Unknown Course',
                        style: TextStyle(
                          color: course['id'] == selectedCourseId 
                              ? AppThemes.primaryGreen 
                              : AppThemes.lightLabel,
                          fontWeight: course['id'] == selectedCourseId 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (selectedCourseId != null)
              Expanded(child: _buildLearnmapContent()),
          ],
        ),
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
    
    return ListenableBuilder(
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
        
        return Stack(
          children: [
            // Main content with sticky header
            CustomScrollView(
              controller: _scrollController,
              physics: const ClampingScrollPhysics(),
              slivers: [
                // Sticky unit header
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyUnitHeaderDelegate(
                    units: units,
                    scrollController: _scrollController,
                  ),
                ),
                
                // Main snake path content
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, unitIndex) {
                        final unit = units[unitIndex];
                        final lessons = unit['lessonProgress'] as List<dynamic>? ?? [];
                        final unitId = unit['unitId'] as String;
                        
                        // Get previous unit's last lesson position for smooth connection
                        Offset? previousUnitLastPosition;
                        if (unitIndex > 0) {
                          final prevUnit = units[unitIndex - 1];
                          final prevLessons = prevUnit['lessonProgress'] as List<dynamic>? ?? [];
                          if (prevLessons.isNotEmpty) {
                            final screenWidth = MediaQuery.of(context).size.width;
                            final centerX = screenWidth / 2;
                            
                            // Calculate previous unit's last lesson position
                            final prevPositions = _calculateSnakePositions(
                              prevLessons.length, 
                              centerX, 
                              unitIndex - 1, 
                              null
                            );
                            if (prevPositions.isNotEmpty) {
                              previousUnitLastPosition = prevPositions.last;
                            }
                          }
                        }
                        
                        return Column(
                          children: [
                            const SizedBox(height: 30), // Space for sticky header
                            
                            // Snake path layout for this unit
                            SnakePathLayout(
                              lessons: lessons,
                              unitIndex: unitIndex,
                              unitId: unitId,
                              onLessonTap: _navigateToLesson,
                              previousUnitLastPosition: previousUnitLastPosition,
                            ),
                            
                            const SizedBox(height: 40),
                            
                            // Unit connector (except for last unit)
                            if (unitIndex < units.length - 1)
                              _buildUnitConnector(units[unitIndex + 1], unitIndex + 2),
                          ],
                        );
                      },
                      childCount: units.length,
                    ),
                  ),
                ),
              ],
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
      },
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
          // Save current position but don't auto scroll
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

  // Helper method to calculate snake positions
  List<Offset> _calculateSnakePositions(int lessonCount, double centerX, int unitIndex, Offset? previousLastPosition) {
    List<Offset> positions = [];
    
    // Snake parameters
    const double verticalSpacing = 120.0;
    const double amplitude = 80.0;
    const double nodeRadius = 40.0;
    
    // Determine snake direction based on unit index
    bool curveLeftFirst = unitIndex % 2 == 0;
    
    for (int i = 0; i < lessonCount; i++) {
      double y = (i * verticalSpacing) + 60;
      
      double frequency = (lessonCount > 6) ? 1.2 : 1.0;
      double phase = (i / (lessonCount - 1)) * math.pi * frequency;
      
      double direction = curveLeftFirst ? 1.0 : -1.0;
      double x = centerX + (amplitude * math.sin(phase) * direction);
      
      // Special handling for first lesson to connect with previous unit
      if (i == 0 && previousLastPosition != null) {
        final targetX = previousLastPosition.dx;
        x = (targetX * 0.4) + (x * 0.6);
      }
      
      x = x.clamp(nodeRadius + 20, centerX * 2 - nodeRadius - 20);
      positions.add(Offset(x, y));
    }
    
    return positions;
  }

  double _calculateScrollOffset(int unitIndex, int lessonIndex) {
    // Calculate approximate scroll position for snake path
    const double unitHeaderHeight = 100.0;
    const double unitSpacing = 70.0;
    const double lessonVerticalSpacing = 120.0;
    
    double offset = 16.0; // Initial padding
    
    // Add height for previous units
    for (int i = 0; i < unitIndex; i++) {
      offset += unitHeaderHeight + unitSpacing;
      // Calculate height for snake path (depends on lesson count)
      final prevUnit = controller?.learnmap?['unitProgress'][i];
      final prevLessons = prevUnit?['lessonProgress'] as List<dynamic>? ?? [];
      offset += (prevLessons.length * lessonVerticalSpacing) + 120.0; // Snake path height + bottom margin
    }
    
    // Add height for current unit header
    offset += unitHeaderHeight + 30.0;
    
    // Add height for lessons before current lesson in snake path
    offset += lessonIndex * lessonVerticalSpacing;
    
    // Center the current lesson in view
    offset -= 200.0;
    
    return offset.clamp(0.0, _scrollController.position.maxScrollExtent);
  }

  Widget _buildUnitConnector(Map<String, dynamic> nextUnit, int unitNumber) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          // Flowing connection line
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppThemes.systemGray3,
                  AppThemes.primaryGreen,
                  AppThemes.systemGray3,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Unit title in center
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: AppThemes.lightBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppThemes.primaryGreen.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppThemes.primaryGreen.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              nextUnit['title'] ?? 'Unit $unitNumber',
              style: TextStyle(
                color: AppThemes.primaryGreen,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Sticky Unit Header Delegate
class _StickyUnitHeaderDelegate extends SliverPersistentHeaderDelegate {
  final List<dynamic> units;
  final ScrollController scrollController;
  
  _StickyUnitHeaderDelegate({
    required this.units,
    required this.scrollController,
  });

  @override
  double get minExtent => 95.0;

  @override
  double get maxExtent => 95.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppThemes.lightGroupedBackground,
      child: _StickyUnitHeaderWidget(
        units: units,
        scrollController: scrollController,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

// Sticky Unit Header Widget
class _StickyUnitHeaderWidget extends StatefulWidget {
  final List<dynamic> units;
  final ScrollController scrollController;
  
  const _StickyUnitHeaderWidget({
    required this.units,
    required this.scrollController,
  });

  @override
  State<_StickyUnitHeaderWidget> createState() => _StickyUnitHeaderWidgetState();
}

class _StickyUnitHeaderWidgetState extends State<_StickyUnitHeaderWidget> {
  int currentUnitIndex = 0;
  
  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }
  
  void _onScroll() {
    if (!widget.scrollController.hasClients) return;
    
    final scrollOffset = widget.scrollController.offset;
    final newUnitIndex = _calculateCurrentUnitIndex(scrollOffset);
    
    if (newUnitIndex != currentUnitIndex) {
      setState(() {
        currentUnitIndex = newUnitIndex;
      });
    }
  }
  
  int _calculateCurrentUnitIndex(double scrollOffset) {
    // Calculate which unit is currently visible based on scroll position
    const double stickyHeaderHeight = 80.0;
    const double unitSpacing = 70.0;
    const double lessonVerticalSpacing = 120.0;
    const double unitConnectorHeight = 80.0;
    
    double accumulatedHeight = 0.0;
    
    for (int i = 0; i < widget.units.length; i++) {
      final lessons = widget.units[i]['lessonProgress'] as List<dynamic>? ?? [];
      
      // Calculate height for this unit's snake path
      double unitHeight = unitSpacing + (lessons.length * lessonVerticalSpacing) + 120.0; // Snake path height + margin
      
      // Add unit connector height (except for last unit)
      if (i < widget.units.length - 1) {
        unitHeight += unitConnectorHeight;
      }
      
      // Check if current scroll position is within this unit
      if (scrollOffset < accumulatedHeight + unitHeight) {
        return i;
      }
      
      accumulatedHeight += unitHeight;
    }
    
    // If scrolled past all units, return the last unit
    return widget.units.length - 1;
  }
  
  @override
  Widget build(BuildContext context) {
    if (widget.units.isEmpty || currentUnitIndex >= widget.units.length) {
      return Container(
        height: 80,
        color: AppThemes.lightGroupedBackground,
      );
    }
    
    final unit = widget.units[currentUnitIndex];
    final unitNumber = currentUnitIndex + 1;
    final lessons = unit['lessonProgress'] as List<dynamic>? ?? [];
    final completedLessons = lessons.where((l) => l['status'] == 'completed').length;
    
    // Unit colors matching app theme
    final List<Color> unitColors = [
      AppThemes.primaryGreen, // Unit 1
      AppThemes.systemBlue,   // Unit 2
      AppThemes.systemOrange, // Unit 3
    ];
    
    final color = unitColors[(unitNumber - 1) % unitColors.length];
    
    return Stack(
      children: [
        // Bottom shadow block
        Positioned(
          bottom: -4,
          left: 20,
          right: 20,
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: color.withOpacity(0.7),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        
        // Main box
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Unit info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'SECTION 1, UNIT $unitNumber',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      unit['title'] ?? 'Unit $unitNumber',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Menu icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.more_horiz,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}