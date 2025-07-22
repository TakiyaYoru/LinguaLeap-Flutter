import 'package:flutter/material.dart';
import '../network/learnmap_service.dart';
import '../models/gamification_model.dart';

class LearnmapController extends ChangeNotifier {
  Map<String, dynamic>? learnmap;
  GamificationData? gamificationData;
  bool isLoading = false;
  bool isInitializing = false;
  String? error;
  String? courseId;

  Future<void> loadLearnmap(String courseId) async {
    this.courseId = courseId;
    isLoading = true;
    error = null;
    notifyListeners();
    
    try {
      print('🔄 Bắt đầu load learnmap cho course: $courseId');
      
      // Thử lấy progress hiện tại
      final data = await LearnmapService.getUserLearnmapProgress(courseId);
      print('📊 getUserLearnmapProgress result: $data');
      
      if (data == null) {
        // Nếu chưa có progress, khởi tạo mới
        print('🔄 Chưa có progress, bắt đầu khởi tạo...');
        isInitializing = true;
        notifyListeners();
        
        final newData = await LearnmapService.startCourseLearnmap(courseId);
        print('📊 startCourseLearnmap result: $newData');
        
        if (newData != null) {
          learnmap = newData;
          _updateGamificationData(newData);
          print('✅ Đã khởi tạo learnmap thành công cho course: $courseId');
        } else {
          error = 'Không thể khởi tạo learnmap - mutation trả về null';
          print('❌ startCourseLearnmap trả về null');
        }
        isInitializing = false;
      } else {
        // Nếu đã có progress, sử dụng dữ liệu hiện tại
        learnmap = data;
        _updateGamificationData(data);
        print('✅ Đã load learnmap thành công cho course: $courseId');
      }
    } catch (e) {
      error = e.toString();
      print('❌ loadLearnmap error: $e');
    }
    
    isLoading = false;
    notifyListeners();
  }

  void _updateGamificationData(Map<String, dynamic> data) {
    // Tạo gamification data từ learnmap data
    gamificationData = GamificationData(
      hearts: data['hearts'] ?? 5,
      streak: 4, // Tạm thời hardcode, sau sẽ lấy từ backend
      xp: 957, // Tạm thời hardcode, sau sẽ lấy từ backend
      coins: 0, // Tạm thời hardcode, sau sẽ lấy từ backend
      trophies: _calculateTrophies(data),
      isPremium: false, // Tạm thời hardcode, sau sẽ lấy từ backend
    );
  }

  int _calculateTrophies(Map<String, dynamic> data) {
    int trophies = 0;
    final units = data['unitProgress'] as List<dynamic>? ?? [];
    
    for (final unit in units) {
      final lessons = unit['lessonProgress'] as List<dynamic>? ?? [];
      int completedLessons = 0;
      
      for (final lesson in lessons) {
        if (lesson['status'] == 'completed') {
          completedLessons++;
        }
      }
      
      // Mỗi unit hoàn thành 100% = 1 trophy
      if (completedLessons == lessons.length && lessons.isNotEmpty) {
        trophies++;
      }
    }
    
    return trophies;
  }

  void reset() {
    learnmap = null;
    gamificationData = null;
    isLoading = false;
    isInitializing = false;
    error = null;
    notifyListeners();
  }

  // Method để update hearts khi user làm sai exercise
  void loseHeart() {
    if (gamificationData != null && gamificationData!.hearts > 0) {
      gamificationData = gamificationData!.copyWith(
        hearts: gamificationData!.hearts - 1,
      );
      notifyListeners();
    }
  }

  // Method để add XP khi user hoàn thành lesson
  void addXP(int xp) {
    if (gamificationData != null) {
      gamificationData = gamificationData!.copyWith(
        xp: gamificationData!.xp + xp,
      );
      notifyListeners();
    }
  }

  // Method để add coins khi user hoàn thành lesson
  void addCoins(int coins) {
    if (gamificationData != null) {
      gamificationData = gamificationData!.copyWith(
        coins: gamificationData!.coins + coins,
      );
      notifyListeners();
    }
  }

  // Method để update hearts
  Future<void> updateHearts(int newHearts) async {
    if (courseId == null) return;
    
    try {
      final result = await LearnmapService.updateLearnmapProgress(courseId!, {
        'hearts': newHearts,
      });
      
      if (result != null) {
        learnmap = result;
        _updateGamificationData(result);
        print('✅ Hearts updated: $newHearts');
      }
    } catch (e) {
      print('❌ Update hearts error: $e');
    }
  }

  // Method để update lesson progress
  Future<void> updateLessonProgress(String unitId, String lessonId, String status) async {
    if (courseId == null) {
      print('❌ courseId is null, cannot update lesson progress');
      return;
    }
    
    try {
      print('🔄 Updating lesson progress: $lessonId -> $status');
      
      final result = await LearnmapService.updateLearnmapProgress(courseId!, {
        'unitId': unitId,
        'lessonId': lessonId,
        'status': status,
        'completedAt': status == 'completed' ? DateTime.now().toIso8601String() : null,
      });
      
      if (result != null) {
        learnmap = result;
        _updateGamificationData(result);
        print('✅ Lesson progress updated: $lessonId -> $status');
        
        // Add XP và coins khi hoàn thành lesson
        if (status == 'completed') {
          addXP(50);
          addCoins(10);
        }
      } else {
        print('❌ updateLearnmapProgress returned null');
      }
    } catch (e) {
      print('❌ Update lesson progress error: $e');
      // Không throw error để tránh crash app
    }
  }
} 