// ===============================================
// FIXED LISTENING EXERCISE WIDGET
// ===============================================

import 'package:flutter/material.dart';
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

  void _initializeExercise() {
    options = widget.content['options'] as List<dynamic>? ?? [];
    audioText = widget.content['audio_text'] as String?;
    transcription = widget.content['transcription'] as String?;
    
    // Get audio URL from content or question with better validation
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
    print('  - options: $options');
    print('  - audioText: $audioText');
    print('  - transcription: $transcription');
    print('  - audioUrl: $audioUrl');
    
    // Validate audio URL
    if (audioUrl == null || audioUrl!.isEmpty) {
      audioError = 'Không tìm thấy URL audio';
      print('❌ No audio URL found');
    } else if (!_isValidUrl(audioUrl!)) {
      audioError = 'URL audio không hợp lệ';
      print('❌ Invalid audio URL: $audioUrl');
    }
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  Future<void> _initializeAudio() async {
    try {
      await _audioService.initialize();
      
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
      
      // Check if audio URL is valid
      if (audioUrl != null && _isValidUrl(audioUrl!) && audioError == null) {
        setState(() {
          isAudioReady = true;
        });
        print('✅ [ListeningWidget] Audio ready: $audioUrl');
      } else {
        setState(() {
          isAudioReady = false;
          audioError = audioError ?? 'URL audio không hợp lệ';
        });
        print('⚠️ [ListeningWidget] Audio not ready: $audioError');
      }
      
    } catch (e) {
      print('❌ Error initializing audio: $e');
      setState(() {
        audioError = 'Không thể khởi tạo audio player';
        isAudioReady = false;
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
    if (audioUrl == null || playCount >= maxPlayCount || !isAudioReady) {
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
      print('❌ Error playing audio: $e');
      setState(() {
        audioError = 'Không thể phát audio: ${e.toString()}';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $audioError'),
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
      print('❌ Error pausing audio: $e');
    }
  }

  void _resumeAudio() async {
    try {
      await _audioService.resumeAudio();
    } catch (e) {
      print('❌ Error resuming audio: $e');
    }
  }

  void _stopAudio() async {
    try {
      await _audioService.stopAudio();
    } catch (e) {
      print('❌ Error stopping audio: $e');
    }
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
                    onTap: isAudioReady && audioError == null 
                      ? (_audioService.isPlaying ? _pauseAudio : _playAudio) 
                      : null,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isAudioReady && audioError == null 
                          ? AppThemes.primaryGreen 
                          : Colors.grey,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (isAudioReady && audioError == null 
                              ? AppThemes.primaryGreen 
                              : Colors.grey).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        isAudioReady && audioError == null
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
                    onTap: isAudioReady && audioError == null ? _stopAudio : null,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isAudioReady && audioError == null 
                          ? AppThemes.systemGray4 
                          : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.stop,
                        color: isAudioReady && audioError == null 
                          ? Colors.white 
                          : Colors.grey.shade600,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
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
              if (audioUrl != null) ...[
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