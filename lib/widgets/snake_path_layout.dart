// lib/widgets/snake_path_layout.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_themes.dart';

class SnakePathLayout extends StatelessWidget {
  final List<dynamic> lessons;
  final int unitIndex;
  final Function(String unitId, String lessonId, String status) onLessonTap;
  final String unitId;
  final Offset? previousUnitLastPosition; // Position of last lesson from previous unit

  const SnakePathLayout({
    super.key,
    required this.lessons,
    required this.unitIndex,
    required this.onLessonTap,
    required this.unitId,
    this.previousUnitLastPosition,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final centerX = screenWidth / 2;
    
    // Calculate lesson positions using snake algorithm
    final lessonPositions = _calculateSnakePositions(lessons.length, centerX);
    
    return SizedBox(
      height: _calculateTotalHeight(lessons.length),
      width: double.infinity,
      child: Stack(
        children: [
          // Draw connection paths first (behind lesson nodes)
          ..._buildConnectionPaths(lessonPositions),
          
          // Draw lesson nodes
          ...lessons.asMap().entries.map((entry) {
            final index = entry.key;
            final lesson = entry.value;
            
            // Skip if lesson is null or invalid
            if (lesson == null || lesson is! Map<String, dynamic>) {
              return const SizedBox.shrink();
            }
            
            final position = lessonPositions[index];
            
            return Positioned(
              left: position.dx - 40, // Center the 80px node
              top: position.dy - 40,
              child: _buildLessonNode(lesson, index, context),
            );
          }).toList(),
        ],
      ),
    );
  }

  // Calculate snake-like positions for lessons with alternating direction
  List<Offset> _calculateSnakePositions(int lessonCount, double centerX) {
    List<Offset> positions = [];
    
    // Snake parameters
    const double verticalSpacing = 120.0; // Space between levels
    const double amplitude = 80.0; // How far left/right the snake curves
    const double nodeRadius = 40.0;
    
    // Determine snake direction based on unit index
    // Even units (0, 2, 4...) curve to the left first
    // Odd units (1, 3, 5...) curve to the right first
    bool curveLeftFirst = unitIndex % 2 == 0;
    
    for (int i = 0; i < lessonCount; i++) {
      // Vertical position increases linearly
      double y = (i * verticalSpacing) + 60; // Start with some top padding
      
      // Horizontal position follows sine wave for snake effect
      // Adjust frequency based on lesson count for smooth curves
      double frequency = (lessonCount > 6) ? 1.2 : 1.0;
      double phase = (i / (lessonCount - 1)) * math.pi * frequency;
      
      // Apply direction alternating
      double direction = curveLeftFirst ? 1.0 : -1.0;
      double x = centerX + (amplitude * math.sin(phase) * direction);
      
      // Special handling for first lesson to connect with previous unit
      if (i == 0 && previousUnitLastPosition != null) {
        // Position first lesson closer to the last lesson of previous unit
        final targetX = previousUnitLastPosition!.dx;
        // Blend between target position and snake position for smooth transition
        x = (targetX * 0.4) + (x * 0.6);
      }
      
      // Ensure nodes don't go too far to edges
      x = x.clamp(nodeRadius + 20, centerX * 2 - nodeRadius - 20);
      
      positions.add(Offset(x, y));
    }
    
    return positions;
  }

  // Get the position of the last lesson (for unit connection)
  Offset? getLastLessonPosition(double screenWidth) {
    if (lessons.isEmpty) return null;
    final centerX = screenWidth / 2;
    final positions = _calculateSnakePositions(lessons.length, centerX);
    return positions.last;
  }

  // Calculate total height needed for the snake path
  double _calculateTotalHeight(int lessonCount) {
    return (lessonCount * 120.0) + 120.0; // Extra padding at bottom
  }

  // Build curved connection paths between lessons
  List<Widget> _buildConnectionPaths(List<Offset> positions) {
    List<Widget> paths = [];
    
    for (int i = 0; i < positions.length - 1; i++) {
      final start = positions[i];
      final end = positions[i + 1];
      
      paths.add(
        Positioned.fill(
          child: CustomPaint(
            painter: CurvedPathPainter(
              start: start,
              end: end,
              color: AppThemes.systemGray3,
              strokeWidth: 3.0,
            ),
          ),
        ),
      );
    }
    
    return paths;
  }

  // Build individual lesson node
  Widget _buildLessonNode(Map<String, dynamic> lesson, int index, BuildContext context) {
    // Handle both 'lessonId' and 'id' fields for compatibility
    final lessonId = lesson['lessonId'] as String? ?? lesson['id'] as String? ?? 'unknown';
    final status = lesson['status'] ?? 'locked';
    final isCurrentLesson = status == 'unlocked' || status == 'in_progress';
    
    return GestureDetector(
      onTap: () => onLessonTap(unitId, lessonId, status),
      child: Container(
        width: 80,
        height: 80,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Main lesson circle
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: _getLessonGradient(status),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _getLessonColor(status).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
              ),
              child: Icon(
                _getLessonIcon(status),
                color: Colors.white,
                size: status == 'locked' ? 24 : 28,
              ),
            ),
            
            // Lesson number badge
            Positioned(
              bottom: -8,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getLessonColor(status),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: _getLessonColor(status),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            
            // START! bubble for current lesson
            if (isCurrentLesson)
              Positioned(
                top: -25,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getLessonColor(status), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'START!',
                    style: TextStyle(
                      color: _getLessonColor(status),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getLessonGradient(String status) {
    switch (status) {
      case 'completed':
        return const LinearGradient(
          colors: [AppThemes.goldColor, AppThemes.systemOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'unlocked':
      case 'in_progress':
        return const LinearGradient(
          colors: [AppThemes.primaryGreen, AppThemes.primaryGreenLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return LinearGradient(
          colors: [AppThemes.systemGray3, AppThemes.systemGray2],
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

// Custom painter for curved paths between lessons
class CurvedPathPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Color color;
  final double strokeWidth;

  const CurvedPathPainter({
    required this.start,
    required this.end,
    required this.color,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(start.dx, start.dy);

    // Create smooth curved path between points
    final controlPoint1 = Offset(
      start.dx + (end.dx - start.dx) * 0.3,
      start.dy + (end.dy - start.dy) * 0.5,
    );
    final controlPoint2 = Offset(
      start.dx + (end.dx - start.dx) * 0.7,
      start.dy + (end.dy - start.dy) * 0.5,
    );

    path.cubicTo(
      controlPoint1.dx,
      controlPoint1.dy,
      controlPoint2.dx,
      controlPoint2.dy,
      end.dx,
      end.dy,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Unit connector for smooth transitions between units
class UnitConnector extends StatelessWidget {
  final Offset startPosition; // Last lesson of previous unit
  final Offset endPosition;   // First lesson of next unit
  final Map<String, dynamic> nextUnit;
  final int unitNumber;

  const UnitConnector({
    super.key,
    required this.startPosition,
    required this.endPosition,
    required this.nextUnit,
    required this.unitNumber,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: double.infinity,
      child: Stack(
        children: [
          // Connection path from last lesson to next unit
          Positioned.fill(
            child: CustomPaint(
              painter: UnitConnectionPainter(
                start: startPosition,
                end: endPosition,
                color: AppThemes.primaryGreen.withOpacity(0.6),
                strokeWidth: 4.0,
              ),
            ),
          ),
          
          // Unit title in the middle
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for unit connections
class UnitConnectionPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Color color;
  final double strokeWidth;

  UnitConnectionPainter({
    required this.start,
    required this.end,
    required this.color,
    this.strokeWidth = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(start.dx, start.dy);
    
    // Create flowing connection between units
    final midY = start.dy + (end.dy - start.dy) * 0.5;
    path.quadraticBezierTo(
      (start.dx + end.dx) * 0.5,
      midY,
      end.dx,
      end.dy,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}