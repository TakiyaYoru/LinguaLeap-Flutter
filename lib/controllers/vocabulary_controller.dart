// lib/controllers/vocabulary_controller.dart
import 'package:get/get.dart';
import '../models/vocabulary_model.dart';
import '../network/vocabulary_service.dart';

class VocabularyController extends GetxController {
  // Observable lists
  final RxList<VocabularyWord> _allWords = <VocabularyWord>[].obs;
  final Rx<VocabularyFilter> _currentFilter = VocabularyFilter.all.obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  // Stats observables
  final RxInt _totalWords = 0.obs;
  final RxInt _learnedWords = 0.obs;
  final RxInt _unlearnedWords = 0.obs;
  final RxDouble _progressPercentage = 0.0.obs;

  // Getters
  List<VocabularyWord> get allWords => _allWords;
  VocabularyFilter get currentFilter => _currentFilter.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  // Stats getters
  int get totalWords => _totalWords.value;
  int get learnedWords => _learnedWords.value;
  int get unlearnedWords => _unlearnedWords.value;
  double get progressPercentage => _progressPercentage.value;

  // Filtered words based on current filter
  List<VocabularyWord> get filteredWords {
    switch (_currentFilter.value) {
      case VocabularyFilter.all:
        return _allWords;
      case VocabularyFilter.unlearned:
        return _allWords.where((word) => !word.isLearned).toList();
      case VocabularyFilter.learned:
        return _allWords.where((word) => word.isLearned).toList();
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadVocabulary();
  }

  // Load vocabulary from backend
  Future<void> loadVocabulary() async {
    try {
      print('🔄 Starting loadVocabulary...');
      _isLoading.value = true;
      _errorMessage.value = '';
      
      print('📞 Calling VocabularyService.getMyVocabulary()...');
      final response = await VocabularyService.getMyVocabulary();
      
      print('📦 Service response: $response');
      
      if (response != null) {
        print('✅ Response not null, parsing ${response.length} words...');
        
        final words = response
            .map((wordData) {
              print('📝 Parsing word: $wordData');
              return VocabularyWord.fromJson(wordData);
            })
            .toList();
            
        _allWords.value = words;
        print('💾 Set ${words.length} words to allWords');
        
        // Load stats as well
        print('📊 Loading stats...');
        await loadStats();
        print('✅ loadVocabulary completed successfully');
      } else {
        print('❌ Response is null');
        _errorMessage.value = 'Failed to load vocabulary';
        _allWords.clear();
      }
    } catch (e) {
      print('💥 Exception in loadVocabulary: $e');
      _errorMessage.value = 'Error loading vocabulary: $e';
    } finally {
      _isLoading.value = false;
      print('🏁 loadVocabulary finished, isLoading = false');
    }
  }

  // Load vocabulary statistics
  Future<void> loadStats() async {
    try {
      print('📊 Loading vocabulary stats...');
      final stats = await VocabularyService.getMyVocabularyStats();
      
      print('📈 Raw stats from backend: $stats');
      
      if (stats != null) {
        final total = stats['totalWords'] ?? 0;
        final learned = stats['learnedWords'] ?? 0;
        final unlearned = stats['unlearnedWords'] ?? 0;
        final progress = (stats['progressPercentage'] ?? 0.0).toDouble();
        
        print('📊 Parsed stats:');
        print('  - Total: $total');
        print('  - Learned: $learned');
        print('  - Unlearned: $unlearned');
        print('  - Progress: $progress%');
        
        _totalWords.value = total;
        _learnedWords.value = learned;
        _unlearnedWords.value = unlearned;
        _progressPercentage.value = progress;
        
        print('💾 Updated reactive values:');
        print('  - _totalWords.value: ${_totalWords.value}');
        print('  - Current allWords.length: ${_allWords.length}');
      } else {
        print('❌ Stats response is null');
      }
    } catch (e) {
      print('💥 Error loading stats: $e');
    }
  }

  // Add new word
  Future<bool> addWord({
    required String word,
    required String meaning,
    String? pronunciation,
    String? example,
    String? category,
    int? difficulty,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await VocabularyService.addVocabularyWord(
        word: word,
        meaning: meaning,
        pronunciation: pronunciation,
        example: example,
        category: category ?? 'general',
        difficulty: difficulty ?? 1,
      );

      if (response != null) {
        // Add to local list
        final newWord = VocabularyWord.fromJson(response);
        _allWords.insert(0, newWord);
        
        // Force full refresh instead of just loadStats
        print('🔄 Force refreshing all data after add...');
        await Future.delayed(Duration(milliseconds: 500)); // Wait for backend to update
        await loadVocabulary(); // This will reload both words and stats
        
        Get.snackbar(
          'Word Added',
          '"$word" has been added to your vocabulary',
          snackPosition: SnackPosition.BOTTOM,
        );
        
        return true;
      } else {
        _errorMessage.value = 'Failed to add word';
        Get.snackbar(
          'Error',
          'Failed to add word. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Error adding word: $e';
      Get.snackbar(
        'Error',
        'Error adding word: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Delete word
  Future<bool> deleteWord(String wordId) async {
    try {
      print('🗑️ Controller: Deleting word $wordId');
      _isLoading.value = true;
      _errorMessage.value = '';

      // Find word before delete for UI feedback
      final wordIndex = _allWords.indexWhere((word) => word.id == wordId);
      final wordToDelete = wordIndex != -1 ? _allWords[wordIndex] : null;
      print('📝 Word to delete: ${wordToDelete?.word}');

      final success = await VocabularyService.deleteVocabularyWord(wordId);
      print('🔍 Delete service result: $success');

      if (success) {
        // Remove from local list immediately
        if (wordIndex != -1) {
          _allWords.removeAt(wordIndex);
          print('✅ Removed from local list');
        }
        
        // Force full refresh to ensure sync with backend
        print('🔄 Force refreshing after delete...');
        await Future.delayed(Duration(milliseconds: 500)); // Wait for backend
        await loadVocabulary(); // This will reload everything from backend
        
        if (wordToDelete != null) {
          Get.snackbar(
            'Word Deleted',
            '"${wordToDelete.word}" has been removed',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
        return true;
      } else {
        // If delete failed, refresh to get current state
        print('❌ Delete failed, refreshing to get current state...');
        await loadVocabulary();
        
        _errorMessage.value = 'Failed to delete word';
        Get.snackbar(
          'Error',
          'Failed to delete word. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      print('💥 Exception in deleteWord: $e');
      
      // On error, refresh to get current state
      await loadVocabulary();
      
      _errorMessage.value = 'Error deleting word: $e';
      Get.snackbar(
        'Error',
        'Error deleting word: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
      print('🏁 Delete operation finished');
    }
  }

  // Toggle learned status
  Future<bool> toggleLearned(String wordId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await VocabularyService.toggleVocabularyLearned(wordId);

      if (response != null) {
        // Update local word
        final wordIndex = _allWords.indexWhere((word) => word.id == wordId);
        if (wordIndex != -1) {
          final updatedWord = VocabularyWord.fromJson(response);
          _allWords[wordIndex] = updatedWord;
          
          // Update stats
          await loadStats();
          
          Get.snackbar(
            updatedWord.isLearned ? 'Word Learned!' : 'Word Unmarked',
            updatedWord.isLearned 
                ? 'Great! "${updatedWord.word}" marked as learned'
                : '"${updatedWord.word}" marked as unlearned',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
        return true;
      } else {
        _errorMessage.value = 'Failed to update word';
        Get.snackbar(
          'Error',
          'Failed to update word. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'Error updating word: $e';
      Get.snackbar(
        'Error',
        'Error updating word: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Set filter
  void setFilter(VocabularyFilter filter) {
    _currentFilter.value = filter;
  }

  // Refresh data
  Future<void> refresh() async {
    await loadVocabulary();
  }
}