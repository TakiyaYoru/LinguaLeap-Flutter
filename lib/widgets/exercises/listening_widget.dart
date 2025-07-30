// ===============================================
// IMPROVED LISTENING EXERCISE WIDGET - CROSS-PLATFORM
// ===============================================

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../theme/app_themes.dart';
import '../../utils/audio_service.dart';

class ListeningWidget extends StatefulWidget {
  final Map<String, dynamic> content;
  final Map<String, dynamic> question;
  final Function(dynamic) onAnswerSubmitted;
  final Map<String, dynamic>? controllerState;

  const ListeningWidget({
    Key? key,
    required this.content,
    required this.question,
    required this.onAnswerSubmitted,
    this.controllerState,
  }) : super(key: key);

  @override
  State<ListeningWidget> createState() => _ListeningWidgetState();
}

class _ListeningWidgetState extends State<ListeningWidget> {
  final AudioService _audioService = AudioService();
  List<dynamic> options = [];
  int? selectedOptionIndex;
  String? audioUrl;
  String? audioText;
  String? transcription;
  bool isAudioReady = false;
  int playCount = 0;
  static const int maxPlayCount = 3;
  String? audioError;
  bool isInitializing = true;
  Duration? audioDuration;
  Duration currentPosition = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeExercise();
    _initializeAudio();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ListeningWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if exercise content has changed
    if (oldWidget.content != widget.content || oldWidget.question != widget.question) {
      print('🔄 [ListeningWidget] Exercise content changed, resetting state...');
      _resetState();
      _initializeExercise();
      _initializeAudio();
    }
  }

  void _resetState() {
    setState(() {
      // Reset all state variables
      options = [];
      selectedOptionIndex = null;
      audioUrl = null;
      audioText = null;
      transcription = null;
      isAudioReady = false;
      playCount = 0;
      audioError = null;
      isInitializing = true;
      audioDuration = null;
      currentPosition = Duration.zero;
    });
    
    print('🔄 [ListeningWidget] State reset completed');
  }

  void _initializeExercise() {
    try {
      options = widget.content['options'] as List<dynamic>? ?? [];
      audioText = widget.content['audio_text'] as String?;
      transcription = widget.content['transcription'] as String?;
      
      // Get audio URL from multiple possible sources
      audioUrl = widget.content['audioUrl'] as String? ?? 
                 widget.question['audioUrl'] as String? ??
                 widget.content['audio_url'] as String? ??
                 widget.question['audio_url'] as String?;
      
      // Restore state if available
      if (widget.controllerState != null) {
        selectedOptionIndex = widget.controllerState!['selectedOptionIndex'];
        playCount = widget.controllerState!['playCount'] ?? 0;
      }
      
      print('🔍 [ListeningWidget] Initialized:');
      print('  - options: ${options.length} items');
      print('  - audioText: ${audioText?.length ?? 0} chars');
      print('  - transcription: ${transcription?.length ?? 0} chars');
      print('  - audioUrl: ${audioUrl?.length ?? 0} chars');
      
      // Validate audio URL
      if (audioUrl == null || audioUrl!.isEmpty) {
        audioError = 'Không tìm thấy URL audio';
        print('❌ [ListeningWidget] No audio URL found');
      } else if (!_isValidUrl(audioUrl!)) {
        audioError = 'URL audio không hợp lệ';
        print('❌ [ListeningWidget] Invalid audio URL: $audioUrl');
      }
    } catch (e) {
      print('❌ [ListeningWidget] Error initializing exercise: $e');
      audioError = 'Lỗi khởi tạo bài tập: $e';
    }
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https' || uri.scheme == 'data');
    } catch (e) {
      return false;
    }
  }

  Future<void> _initializeAudio() async {
    try {
      setState(() {
        isInitializing = true;
        audioError = null;
        // Reset audio-related state
        audioDuration = null;
        currentPosition = Duration.zero;
      });

      // Force reinitialize audio service for new exercise
      await _audioService.forceReinitialize();
      
      // Set up audio state listener
      _audioService.onStateChanged((state) {
        if (mounted) {
          setState(() {
            isAudioReady = state != AudioState.error && audioError == null;
            if (state == AudioState.error) {
              audioError = 'Lỗi khi phát audio';
            }
          });
        }
      });

      // Set up position listener for progress tracking
      _audioService.onPositionChanged((position) {
        if (mounted) {
          setState(() {
            currentPosition = position;
          });
        }
      });

      // Set up duration listener
      _audioService.onDurationChanged((duration) {
        if (mounted) {
          setState(() {
            audioDuration = duration;
          });
        }
      });
      
      // Check if audio URL is valid
      if (audioUrl != null && _isValidUrl(audioUrl!) && audioError == null) {
        setState(() {
          isAudioReady = true;
          isInitializing = false;
        });
        print('✅ [ListeningWidget] Audio ready: $audioUrl');
      } else {
        setState(() {
          isAudioReady = false;
          isInitializing = false;
          audioError = audioError ?? 'URL audio không hợp lệ';
        });
        print('⚠️ [ListeningWidget] Audio not ready: $audioError');
      }
      
    } catch (e) {
      print('❌ [ListeningWidget] Error initializing audio: $e');
      setState(() {
        audioError = 'Không thể khởi tạo audio player: $e';
        isAudioReady = false;
        isInitializing = false;
      });
    }
  }

  void _handleOptionSelected(int index) {
    setState(() {
      selectedOptionIndex = index;
    });
    widget.onAnswerSubmitted(index);
  }

  Future<void> _playAudio() async {
    if (audioUrl == null || playCount >= maxPlayCount || !isAudioReady || isInitializing) {
      return;
    }

    try {
      setState(() {
        playCount++;
        audioError = null; // Clear any previous errors
      });
      
      await _audioService.playAudio(audioUrl!);
      
      // Show play count indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎵 Đang phát audio (${playCount}/$maxPlayCount)'),
            duration: const Duration(seconds: 1),
            backgroundColor: AppThemes.primaryGreen,
          ),
        );
      }
    } catch (e) {
      print('❌ [ListeningWidget] Error playing audio: $e');
      
      // Handle specific web audio errors
      String errorMessage = 'Không thể phát audio';
      if (e.toString().contains('disposed')) {
        errorMessage = 'Audio player bị lỗi, đang thử lại...';
        // Try to reinitialize audio service
        try {
          await _audioService.dispose();
          await _initializeAudio();
          // Don't show error snackbar for this case
          return;
        } catch (reinitError) {
          errorMessage = 'Không thể khởi tạo lại audio player';
        }
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Audio quá tải, vui lòng thử lại';
      } else if (e.toString().contains('Invalid audio URL')) {
        errorMessage = 'URL audio không hợp lệ';
      }
      
      setState(() {
        audioError = errorMessage;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _pauseAudio() async {
    try {
      await _audioService.pauseAudio();
    } catch (e) {
      print('❌ [ListeningWidget] Error pausing audio: $e');
    }
  }

  void _resumeAudio() async {
    try {
      await _audioService.resumeAudio();
    } catch (e) {
      print('❌ [ListeningWidget] Error resuming audio: $e');
    }
  }

  void _stopAudio() async {
    try {
      await _audioService.stopAudio();
    } catch (e) {
      print('❌ [ListeningWidget] Error stopping audio: $e');
    }
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '--:--';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Audio Player Section
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppThemes.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppThemes.primaryGreen.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.headphones, color: AppThemes.primaryGreen, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Nghe và chọn đáp án đúng:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppThemes.primaryGreen,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Loading Indicator
              if (isInitializing) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppThemes.primaryGreen),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Đang khởi tạo audio...',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppThemes.lightSecondaryLabel,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              
              // Audio Error Display
              if (audioError != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          audioError!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              
              // Audio Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Play/Pause Button
                  GestureDetector(
                    onTap: isAudioReady && audioError == null && !isInitializing
                      ? (_audioService.isPlaying ? _pauseAudio : _playAudio) 
                      : null,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isAudioReady && audioError == null && !isInitializing
                          ? AppThemes.primaryGreen 
                          : Colors.grey,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (isAudioReady && audioError == null && !isInitializing
                              ? AppThemes.primaryGreen 
                              : Colors.grey).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        isAudioReady && audioError == null && !isInitializing
                          ? (_audioService.isPlaying ? Icons.pause : Icons.play_arrow)
                          : Icons.volume_off,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 20),
                  
                  // Stop Button
                  GestureDetector(
                    onTap: isAudioReady && audioError == null && !isInitializing ? _stopAudio : null,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isAudioReady && audioError == null && !isInitializing
                          ? AppThemes.systemGray4 
                          : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.stop,
                        color: isAudioReady && audioError == null && !isInitializing
                          ? Colors.white 
                          : Colors.grey.shade600,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Audio Progress (if available)
              if (audioDuration != null && audioDuration!.inSeconds > 0) ...[
                Column(
                  children: [
                    // Progress Bar
                    LinearProgressIndicator(
                      value: audioDuration!.inMilliseconds > 0 
                        ? currentPosition.inMilliseconds / audioDuration!.inMilliseconds 
                        : 0.0,
                      backgroundColor: AppThemes.systemGray4,
                      valueColor: AlwaysStoppedAnimation<Color>(AppThemes.primaryGreen),
                    ),
                    const SizedBox(height: 8),
                    // Time Display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(currentPosition),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppThemes.lightSecondaryLabel,
                          ),
                        ),
                        Text(
                          _formatDuration(audioDuration),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppThemes.lightSecondaryLabel,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              
              // Play Count Indicator
              Text(
                'Lượt nghe: $playCount/$maxPlayCount',
                style: TextStyle(
                  fontSize: 12,
                  color: playCount >= maxPlayCount 
                    ? Colors.red 
                    : AppThemes.lightSecondaryLabel,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              // Audio URL Debug Info (only in debug mode)
              if (kDebugMode && audioUrl != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Audio: ${audioUrl!.length > 50 ? audioUrl!.substring(0, 50) + '...' : audioUrl}',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppThemes.systemGray3,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              
              // Audio Text Preview (if available)
              if (audioText != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppThemes.systemGray4),
                  ),
                  child: Text(
                    'Nội dung: $audioText',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppThemes.lightSecondaryLabel,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Question Section
        if (widget.content['question'] != null || widget.question['text'] != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppThemes.lightBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppThemes.systemGray4),
            ),
            child: Text(
              widget.content['question'] as String? ?? widget.question['text'] as String? ?? 'What did you hear?',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppThemes.lightLabel,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Options List
        if (options.isNotEmpty) ...[
          Expanded(
            child: ListView.builder(
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index].toString();
                final optionLetter = String.fromCharCode(65 + index); // A, B, C, D...
                final isSelected = selectedOptionIndex == index;
             
               return Container(
                 margin: const EdgeInsets.only(bottom: 12),
                 child: Material(
                   borderRadius: BorderRadius.circular(16),
                   elevation: isSelected ? 4 : 2,
                   child: InkWell(
                     onTap: () => _handleOptionSelected(index),
                     borderRadius: BorderRadius.circular(16),
                     child: Container(
                       padding: const EdgeInsets.all(20),
                       decoration: BoxDecoration(
                         color: isSelected 
                           ? AppThemes.primaryGreen.withOpacity(0.1)
                           : AppThemes.lightBackground,
                         borderRadius: BorderRadius.circular(16),
                         border: Border.all(
                           color: isSelected 
                             ? AppThemes.primaryGreen 
                             : AppThemes.systemGray4, 
                           width: isSelected ? 2 : 1,
                         ),
                       ),
                       child: Row(
                         children: [
                           // Option letter circle
                           Container(
                             width: 40,
                             height: 40,
                             decoration: BoxDecoration(
                               color: isSelected 
                                 ? AppThemes.primaryGreen
                                 : AppThemes.primaryGreen.withOpacity(0.1),
                               shape: BoxShape.circle,
                               border: Border.all(
                                 color: isSelected 
                                   ? AppThemes.primaryGreen
                                   : AppThemes.primaryGreen.withOpacity(0.3),
                               ),
                             ),
                             child: Center(
                               child: Text(
                                 optionLetter,
                                 style: TextStyle(
                                   fontSize: 16,
                                   fontWeight: FontWeight.bold,
                                   color: isSelected 
                                     ? Colors.white
                                     : AppThemes.primaryGreen,
                                 ),
                               ),
                             ),
                           ),
                           const SizedBox(width: 16),
                           // Option text
                           Expanded(
                             child: Text(
                               option,
                               style: TextStyle(
                                 fontSize: 16,
                                 fontWeight: FontWeight.w500,
                                 color: isSelected 
                                   ? AppThemes.primaryGreen
                                   : AppThemes.lightLabel,
                                 height: 1.4,
                               ),
                             ),
                           ),
                           // Selection indicator
                           if (isSelected)
                             Icon(
                               Icons.check_circle,
                               color: AppThemes.primaryGreen,
                               size: 24,
                             )
                           else
                             Icon(
                               Icons.arrow_forward_ios,
                               color: AppThemes.systemGray4,
                               size: 16,
                             ),
                         ],
                       ),
                     ),
                   ),
                 ),
               );
             },
           ),
         ),
       ] else ...[
         // No options available
         Expanded(
           child: Center(
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Icon(Icons.error_outline, size: 48, color: AppThemes.systemGray3),
                 const SizedBox(height: 16),
                 Text(
                   'Không có đáp án nào',
                   style: TextStyle(
                     fontSize: 16,
                     color: AppThemes.lightSecondaryLabel,
                   ),
                 ),
                 const SizedBox(height: 8),
                 Text(
                   'Vui lòng kiểm tra lại dữ liệu bài tập',
                   style: TextStyle(
                     fontSize: 14,
                     color: AppThemes.systemGray3,
                   ),
                 ),
               ],
             ),
           ),
         ),
       ],
        
        // Transcription (if available and after answering)
        if (transcription != null && selectedOptionIndex != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppThemes.systemGray6,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppThemes.systemGray4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.text_snippet, color: AppThemes.primaryGreen, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Bản ghi chính xác:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppThemes.primaryGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  transcription!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppThemes.lightLabel,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}