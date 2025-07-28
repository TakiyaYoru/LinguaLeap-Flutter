// lib/controllers/exercise_crud_controller.dart

import 'package:get/get.dart';
import '../models/exercise_crud_model.dart';
import '../network/exercise_crud_service.dart';

class ExerciseCRUDController extends GetxController {
  final ExerciseCRUDService _service = ExerciseCRUDService();

  // Observable variables
  final RxList<ExerciseCRUDModel> exercises = <ExerciseCRUDModel>[].obs;
  final Rx<ExerciseCRUDModel?> currentExercise = Rx<ExerciseCRUDModel?>(null);
  final Rx<ExerciseStats?> exerciseStats = Rx<ExerciseStats?>(null);
  final RxList<String> exerciseSubtypes = <String>[].obs;
  
  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isCreating = false.obs;
  final RxBool isUpdating = false.obs;
  final RxBool isDeleting = false.obs;
  
  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalExercises = 0.obs;
  final RxInt limit = 10.obs;
  
  // Filtering
  final Rx<ExerciseFilterInput?> currentFilter = Rx<ExerciseFilterInput?>(null);
  final RxString currentSortBy = 'createdAt'.obs;
  final RxString currentSortOrder = 'desc'.obs;

  @override
  void onInit() {
    super.onInit();
    loadExerciseSubtypes();
    loadExerciseStats();
  }

  // Load exercise subtypes
  Future<void> loadExerciseSubtypes() async {
    try {
      isLoading.value = true;
      final subtypes = await _service.getExerciseSubtypes();
      exerciseSubtypes.value = subtypes;
    } catch (e) {
      print('❌ Error loading exercise subtypes: $e');
      Get.snackbar('Error', 'Failed to load exercise subtypes');
    } finally {
      isLoading.value = false;
    }
  }

  // Load exercise statistics
  Future<void> loadExerciseStats() async {
    try {
      final statsPayload = await _service.getExerciseStats();
      if (statsPayload.success) {
        exerciseStats.value = statsPayload.stats;
      }
    } catch (e) {
      print('❌ Error loading exercise stats: $e');
    }
  }

  // Load exercises with pagination and filtering
  Future<void> loadExercises({
    int page = 1,
    ExerciseFilterInput? filter,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    try {
      isLoading.value = true;
      
      final payload = await _service.getExercises(
        page: page,
        limit: limit.value,
        filter: filter,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      if (payload.success) {
        if (page == 1) {
          exercises.value = payload.exercises;
        } else {
          exercises.addAll(payload.exercises);
        }
        
        currentPage.value = payload.page;
        totalExercises.value = payload.total;
        totalPages.value = (payload.total / limit.value).ceil();
        currentFilter.value = filter;
        currentSortBy.value = sortBy;
        currentSortOrder.value = sortOrder;
      }
    } catch (e) {
      print('❌ Error loading exercises: $e');
      Get.snackbar('Error', 'Failed to load exercises');
    } finally {
      isLoading.value = false;
    }
  }

  // Load more exercises (pagination)
  Future<void> loadMoreExercises() async {
    if (currentPage.value < totalPages.value && !isLoading.value) {
      await loadExercises(
        page: currentPage.value + 1,
        filter: currentFilter.value,
        sortBy: currentSortBy.value,
        sortOrder: currentSortOrder.value,
      );
    }
  }

  // Load exercise by ID
  Future<void> loadExercise(String id) async {
    try {
      isLoading.value = true;
      final exercise = await _service.getExercise(id);
      currentExercise.value = exercise;
    } catch (e) {
      print('❌ Error loading exercise: $e');
      Get.snackbar('Error', 'Failed to load exercise');
    } finally {
      isLoading.value = false;
    }
  }

  // Load exercise by subtype
  Future<void> loadExerciseBySubtype(String subtype) async {
    try {
      isLoading.value = true;
      final exercise = await _service.getExerciseBySubtype(subtype);
      currentExercise.value = exercise;
    } catch (e) {
      print('❌ Error loading exercise by subtype: $e');
      Get.snackbar('Error', 'Failed to load exercise');
    } finally {
      isLoading.value = false;
    }
  }

  // Load exercises by type
  Future<void> loadExercisesByType(String type) async {
    try {
      isLoading.value = true;
      final exercisesList = await _service.getExercisesByType(type);
      exercises.value = exercisesList;
    } catch (e) {
      print('❌ Error loading exercises by type: $e');
      Get.snackbar('Error', 'Failed to load exercises');
    } finally {
      isLoading.value = false;
    }
  }

  // Load exercises by skill
  Future<void> loadExercisesBySkill(String skill) async {
    try {
      isLoading.value = true;
      final exercisesList = await _service.getExercisesBySkill(skill);
      exercises.value = exercisesList;
    } catch (e) {
      print('❌ Error loading exercises by skill: $e');
      Get.snackbar('Error', 'Failed to load exercises');
    } finally {
      isLoading.value = false;
    }
  }

  // Get random exercise
  Future<void> getRandomExercise({ExerciseFilterInput? filter}) async {
    try {
      isLoading.value = true;
      final exercise = await _service.getRandomExercise(filter: filter);
      currentExercise.value = exercise;
    } catch (e) {
      print('❌ Error getting random exercise: $e');
      Get.snackbar('Error', 'Failed to get random exercise');
    } finally {
      isLoading.value = false;
    }
  }

  // Load exercises for lesson
  Future<void> loadLessonExercises({
    required String lessonId,
    int count = 6,
    List<String>? skillFocus,
  }) async {
    try {
      isLoading.value = true;
      final exercisesList = await _service.getLessonExercises(
        lessonId: lessonId,
        count: count,
        skillFocus: skillFocus,
      );
      exercises.value = exercisesList;
    } catch (e) {
      print('❌ Error loading lesson exercises: $e');
      Get.snackbar('Error', 'Failed to load lesson exercises');
    } finally {
      isLoading.value = false;
    }
  }

  // Create exercise
  Future<bool> createExercise(CreateExerciseInput input) async {
    try {
      isCreating.value = true;
      final payload = await _service.createExercise(input);
      
      if (payload.success && payload.exercise != null) {
        exercises.insert(0, payload.exercise!);
        Get.snackbar('Success', 'Exercise created successfully');
        await loadExerciseStats(); // Refresh stats
        return true;
      } else {
        Get.snackbar('Error', payload.message);
        return false;
      }
    } catch (e) {
      print('❌ Error creating exercise: $e');
      Get.snackbar('Error', 'Failed to create exercise');
      return false;
    } finally {
      isCreating.value = false;
    }
  }

  // Update exercise
  Future<bool> updateExercise(String id, UpdateExerciseInput input) async {
    try {
      isUpdating.value = true;
      final payload = await _service.updateExercise(id, input);
      
      if (payload.success && payload.exercise != null) {
        final index = exercises.indexWhere((e) => e.id == id);
        if (index != -1) {
          exercises[index] = payload.exercise!;
        }
        
        if (currentExercise.value?.id == id) {
          currentExercise.value = payload.exercise!;
        }
        
        Get.snackbar('Success', 'Exercise updated successfully');
        await loadExerciseStats(); // Refresh stats
        return true;
      } else {
        Get.snackbar('Error', payload.message);
        return false;
      }
    } catch (e) {
      print('❌ Error updating exercise: $e');
      Get.snackbar('Error', 'Failed to update exercise');
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  // Delete exercise
  Future<bool> deleteExercise(String id) async {
    try {
      isDeleting.value = true;
      final payload = await _service.deleteExercise(id);
      
      if (payload.success) {
        exercises.removeWhere((e) => e.id == id);
        if (currentExercise.value?.id == id) {
          currentExercise.value = null;
        }
        Get.snackbar('Success', 'Exercise deleted successfully');
        await loadExerciseStats(); // Refresh stats
        return true;
      } else {
        Get.snackbar('Error', payload.message);
        return false;
      }
    } catch (e) {
      print('❌ Error deleting exercise: $e');
      Get.snackbar('Error', 'Failed to delete exercise');
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  // Toggle exercise active status
  Future<bool> toggleExerciseActive(String id) async {
    try {
      final payload = await _service.toggleExerciseActive(id);
      
      if (payload.success && payload.exercise != null) {
        final index = exercises.indexWhere((e) => e.id == id);
        if (index != -1) {
          exercises[index] = payload.exercise!;
        }
        
        if (currentExercise.value?.id == id) {
          currentExercise.value = payload.exercise!;
        }
        
        final status = payload.exercise!.isActive ? 'activated' : 'deactivated';
        Get.snackbar('Success', 'Exercise $status successfully');
        return true;
      } else {
        Get.snackbar('Error', payload.message);
        return false;
      }
    } catch (e) {
      print('❌ Error toggling exercise status: $e');
      Get.snackbar('Error', 'Failed to toggle exercise status');
      return false;
    }
  }

  // Update exercise success rate
  Future<bool> updateExerciseSuccessRate(String id, bool isCorrect) async {
    try {
      final payload = await _service.updateExerciseSuccessRate(id, isCorrect);
      
      if (payload.success && payload.exercise != null) {
        final index = exercises.indexWhere((e) => e.id == id);
        if (index != -1) {
          exercises[index] = payload.exercise!;
        }
        
        if (currentExercise.value?.id == id) {
          currentExercise.value = payload.exercise!;
        }
        
        return true;
      } else {
        print('❌ Error updating success rate: ${payload.message}');
        return false;
      }
    } catch (e) {
      print('❌ Error updating exercise success rate: $e');
      return false;
    }
  }

  // Bulk create exercises
  Future<bool> bulkCreateExercises({
    required String template,
    required int count,
    List<String>? skillFocus,
  }) async {
    try {
      isCreating.value = true;
      final payload = await _service.bulkCreateExercises(
        template: template,
        count: count,
        skillFocus: skillFocus,
      );
      
      if (payload.success) {
        exercises.addAll(payload.exercises);
        Get.snackbar('Success', 'Created ${payload.total} exercises successfully');
        await loadExerciseStats(); // Refresh stats
        return true;
      } else {
        Get.snackbar('Error', payload.message);
        return false;
      }
    } catch (e) {
      print('❌ Error bulk creating exercises: $e');
      Get.snackbar('Error', 'Failed to bulk create exercises');
      return false;
    } finally {
      isCreating.value = false;
    }
  }

  // Reorder exercises
  Future<bool> reorderExercises(List<String> ids) async {
    try {
      final payload = await _service.reorderExercises(ids);
      
      if (payload.success) {
        // Update sort order in local list
        for (int i = 0; i < payload.exercises.length; i++) {
          final exercise = payload.exercises[i];
          final index = exercises.indexWhere((e) => e.id == exercise.id);
          if (index != -1) {
            exercises[index] = exercise;
          }
        }
        
        Get.snackbar('Success', 'Exercises reordered successfully');
        return true;
      } else {
        Get.snackbar('Error', payload.message);
        return false;
      }
    } catch (e) {
      print('❌ Error reordering exercises: $e');
      Get.snackbar('Error', 'Failed to reorder exercises');
      return false;
    }
  }

  // Clear current exercise
  void clearCurrentExercise() {
    currentExercise.value = null;
  }

  // Clear all exercises
  void clearExercises() {
    exercises.clear();
    currentPage.value = 1;
    totalPages.value = 1;
    totalExercises.value = 0;
  }

  // Get exercise by ID from local list
  ExerciseCRUDModel? getExerciseById(String id) {
    try {
      return exercises.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  // Filter exercises by type
  List<ExerciseCRUDModel> getExercisesByType(String type) {
    return exercises.where((e) => e.type == type).toList();
  }

  // Filter exercises by skill
  List<ExerciseCRUDModel> getExercisesBySkill(String skill) {
    return exercises.where((e) => e.skillFocus.contains(skill)).toList();
  }

  // Filter exercises by difficulty
  List<ExerciseCRUDModel> getExercisesByDifficulty(String difficulty) {
    return exercises.where((e) => e.difficulty == difficulty).toList();
  }

  // Get active exercises only
  List<ExerciseCRUDModel> get activeExercises {
    return exercises.where((e) => e.isActive).toList();
  }

  // Get premium exercises only
  List<ExerciseCRUDModel> get premiumExercises {
    return exercises.where((e) => e.isPremium).toList();
  }

  // Get exercises requiring audio
  List<ExerciseCRUDModel> get audioExercises {
    return exercises.where((e) => e.requiresAudio).toList();
  }

  // Get exercises requiring microphone
  List<ExerciseCRUDModel> get microphoneExercises {
    return exercises.where((e) => e.requiresMicrophone).toList();
  }
} 