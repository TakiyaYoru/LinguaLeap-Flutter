// ===============================================
// SPEAKING EXERCISE WIDGET - WITH SPEECH RECOGNITION
// ===============================================

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'dart:io';
import '../../theme/app_themes.dart';
import '../../utils/audio_service.dart';
import '../../utils/speech_recognition_service.dart';

class SpeakingWidget extends StatefulWidget {
  final Map<String, dynamic> content;
  final Map<String, dynamic> question;
  final Function(dynamic) onAnswerSubmitted;
  final Map<String, dynamic>? controllerState;

  const SpeakingWidget({
    Key? key,
    required this.content,
    required this.question,
    required this.onAnswerSubmitted,
    this.controllerState,
  }) : super(key: key);

  @override
  State<SpeakingWidget> createState() => _SpeakingWidgetState();
}

class _SpeakingWidgetState extends State<SpeakingWidget> {
  final AudioService _audioService = AudioService();
  final Record _audioRecorder = Record();
  
  // Content data
  String? sentence;
  String? instruction;
  String? pronunciationTips;
  String? audioText;
  String? audioUrl;
  
  // Recording state
  bool _isRecording = false;
  bool _isProcessing = false;
  bool _hasRecorded = false;
  String? _recordedAudioPath;
  Duration _recordingDuration = Duration.zero;
  
  // Speech recognition results
  String? _recognizedText;
  double _accuracyScore = 0.0;
  String? _feedback;
  bool _isCorrect = false;
  
  // UI state
  bool _isAudioReady = false;
  bool _isInitializing = true;
  bool _recorderInitialized = false;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _initializeExercise();
    _initializeAudio();
    _requestPermissions();
    // Temporarily disable recorder initialization to prevent crashes
    // Future.delayed(const Duration(milliseconds: 500), () {
    //   if (mounted) {
    //     _initializeRecorder();
    //   }
    // });
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioService.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SpeakingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.content != widget.content || oldWidget.question != widget.question) {
      print('🔄 [SpeakingWidget] Exercise content changed, resetting state...');
      _resetState();
      _initializeExercise();
      _initializeAudio();
    }
  }

  void _resetState() {
    setState(() {
      sentence = null;
      instruction = null;
      pronunciationTips = null;
      audioText = null;
      audioUrl = null;
      _isRecording = false;
      _isProcessing = false;
      _hasRecorded = false;
      _recordedAudioPath = null;
      _recordingDuration = Duration.zero;
      _recognizedText = null;
      _accuracyScore = 0.0;
      _feedback = null;
      _isCorrect = false;
      _isAudioReady = false;
      _isInitializing = true;
      _error = null;
    });
  }

  void _initializeExercise() {
    try {
      final content = widget.content;
      sentence = content['sentence'] as String?;
      instruction = content['instruction'] as String?;
      audioText = content['audio_text'] as String?;
      audioUrl = content['audioUrl'] as String? ?? content['audio_url'] as String?;
      
      print('🔍 [SpeakingWidget] Initialized:');
      print('  - sentence: ${sentence?.length ?? 0} chars');
      print('  - instruction: ${instruction?.length ?? 0} chars');
      print('  - audioText: ${audioText?.length ?? 0} chars');
      print('  - audioUrl: ${audioUrl?.length ?? 0} chars');
      
    } catch (e) {
      print('❌ [SpeakingWidget] Error initializing exercise: $e');
      _error = 'Lỗi khởi tạo bài tập: $e';
    }
  }

  Future<void> _initializeAudio() async {
    try {
      setState(() {
        _isInitializing = true;
        _error = null;
      });

      await _audioService.forceReinitialize();
      
      // Set up audio state listener
      _audioService.onStateChanged((state) {
        if (mounted) {
          setState(() {
            _isAudioReady = state != AudioState.error && _error == null;
            if (state == AudioState.error) {
              _error = 'Lỗi khi phát audio';
            }
          });
        }
      });
      
      if (audioUrl != null && _isValidUrl(audioUrl!)) {
        setState(() {
          _isAudioReady = true;
          _isInitializing = false;
        });
        print('✅ [SpeakingWidget] Audio ready: $audioUrl');
      } else {
        setState(() {
          _isAudioReady = false;
          _isInitializing = false;
        });
        // Only log warning if audio is expected but not provided
        if (audioText != null && audioText!.isNotEmpty) {
          print('⚠️ [SpeakingWidget] Audio text provided but no audio URL');
        } else {
          print('ℹ️ [SpeakingWidget] No audio URL needed for this exercise');
        }
      }
      
    } catch (e) {
      print('❌ [SpeakingWidget] Error initializing audio: $e');
      setState(() {
        _error = 'Không thể khởi tạo audio player: $e';
        _isAudioReady = false;
        _isInitializing = false;
      });
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

  Future<void> _requestPermissions() async {
    try {
      final micStatus = await Permission.microphone.request();
      if (micStatus != PermissionStatus.granted) {
        setState(() {
          _error = 'Cần quyền microphone để ghi âm';
        });
      }
    } catch (e) {
      print('⚠️ [SpeakingWidget] Permission request error: $e');
    }
  }

  Future<void> _initializeRecorder() async {
    try {
      print('🎤 [SpeakingWidget] Initializing recorder...');
      
      // Check if recorder is available first
      bool isAvailable = false;
      try {
        isAvailable = await _audioRecorder.hasPermission();
        print('🎤 [SpeakingWidget] Recorder permission check: $isAvailable');
      } catch (e) {
        print('⚠️ [SpeakingWidget] Permission check failed: $e');
        isAvailable = false;
      }
      
      if (!isAvailable) {
        print('⚠️ [SpeakingWidget] Recorder not available, will request permission when needed');
        setState(() {
          _error = 'Cần quyền microphone để ghi âm';
        });
        return;
      }
      
      print('✅ [SpeakingWidget] Recorder initialized successfully');
      setState(() {
        _recorderInitialized = true;
        _error = null;
      });
    } catch (e) {
      print('❌ [SpeakingWidget] Error initializing recorder: $e');
      setState(() {
        _error = 'Không thể khởi tạo recorder: $e';
        _recorderInitialized = false;
      });
    }
  }

  Future<void> _playAudio() async {
    if (audioUrl == null || !_isAudioReady) return;

    try {
      await _audioService.playAudio(audioUrl!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎵 Đang phát audio mẫu'),
            duration: const Duration(seconds: 1),
            backgroundColor: AppThemes.primaryGreen,
          ),
        );
      }
    } catch (e) {
      print('❌ [SpeakingWidget] Error playing audio: $e');
      setState(() {
        _error = 'Không thể phát audio: $e';
      });
    }
  }

  Future<void> _startRecording() async {
    try {
      print('🎤 [SpeakingWidget] Starting recording...');
      
      // Check if recorder is initialized
      if (!_recorderInitialized) {
        setState(() {
          _error = 'Recorder chưa được khởi tạo. Vui lòng thử lại.';
        });
        return;
      }
      
      // Check if recorder is available
      bool hasPermission = false;
      try {
        hasPermission = await _audioRecorder.hasPermission();
        print('🎤 [SpeakingWidget] Has permission: $hasPermission');
      } catch (e) {
        print('❌ [SpeakingWidget] Permission check failed: $e');
        hasPermission = false;
      }
      
      if (!hasPermission) {
        setState(() {
          _error = 'Không có quyền ghi âm. Vui lòng cấp quyền microphone.';
        });
        return;
      }

      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero;
        _error = null;
      });

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      String path;
      
      try {
        if (kIsWeb) {
          // Web: Use simple path for record plugin
          path = 'recording_$timestamp.m4a';
          print('🎤 [SpeakingWidget] Web recording path: $path');
        } else {
          // Mobile: Use file system path
          path = '/tmp/recording_$timestamp.m4a';
          print('🎤 [SpeakingWidget] Mobile recording path: $path');
        }

        await _audioRecorder.start(path: path);
        _updateRecordingDuration();
        print('✅ [SpeakingWidget] Recording started successfully');
      } catch (e) {
        print('❌ [SpeakingWidget] Error in recorder.start(): $e');
        throw Exception('Không thể khởi động recorder: $e');
      }
      
    } catch (e) {
      print('❌ [SpeakingWidget] Error starting recording: $e');
      setState(() {
        _error = 'Không thể bắt đầu ghi âm: $e';
        _isRecording = false;
      });
    }
  }

  Future<void> _stopRecording() async {
    try {
      print('🎤 [SpeakingWidget] Stopping recording...');
      
      String? path;
      try {
        path = await _audioRecorder.stop();
        print('🎤 [SpeakingWidget] Recording stopped: $path');
      } catch (e) {
        print('❌ [SpeakingWidget] Error stopping recorder: $e');
        // Create a dummy path for fallback
        path = '/tmp/fallback_recording.m4a';
      }
      
      setState(() {
        _isRecording = false;
        _hasRecorded = true;
        _recordedAudioPath = path;
      });
      
      // Process the recording
      await _processRecording();
      
    } catch (e) {
      print('❌ [SpeakingWidget] Error stopping recording: $e');
      setState(() {
        _error = 'Không thể dừng ghi âm: $e';
        _isRecording = false;
      });
    }
  }

  void _updateRecordingDuration() {
    if (_isRecording) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && _isRecording) {
          setState(() {
            _recordingDuration += const Duration(seconds: 1);
          });
          _updateRecordingDuration();
        }
      });
    }
  }

  Future<void> _processRecording() async {
    if (_recordedAudioPath == null) return;

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      print('🎤 [SpeakingWidget] Processing recording...');
      
      // Use SpeechRecognitionService
      final speechService = SpeechRecognitionService();
      final result = await speechService.recognizeSpeech(_recordedAudioPath!, sentence ?? '');
      
      setState(() {
        _recognizedText = result.text;
        _accuracyScore = result.accuracyScore;
        _isCorrect = result.isCorrect;
        _feedback = result.feedback;
        _isProcessing = false;
      });

      print('✅ [SpeakingWidget] Speech recognition completed');
      print('  - Recognized text: $_recognizedText');
      print('  - Accuracy score: $_accuracyScore');
      print('  - Is correct: $_isCorrect');

      // Submit result
      widget.onAnswerSubmitted({
        'recognizedText': _recognizedText,
        'accuracyScore': _accuracyScore,
        'isCorrect': _isCorrect,
        'feedback': _feedback,
        'audioPath': _recordedAudioPath,
        'confidence': _accuracyScore, // Use accuracy score as confidence
      });

    } catch (e) {
      print('❌ [SpeakingWidget] Error processing recording: $e');
      
      // Fallback: Create a basic result even if speech recognition fails
      setState(() {
        _recognizedText = 'Không thể nhận diện giọng nói';
        _accuracyScore = 0.0;
        _isCorrect = false;
        _feedback = 'Có lỗi xảy ra khi xử lý ghi âm. Vui lòng thử lại.';
        _isProcessing = false;
        _error = 'Không thể xử lý ghi âm: $e';
      });
      
      // Still submit a result for the exercise flow
      widget.onAnswerSubmitted({
        'recognizedText': _recognizedText,
        'accuracyScore': _accuracyScore,
        'isCorrect': _isCorrect,
        'feedback': _feedback,
        'audioPath': _recordedAudioPath,
        'confidence': _accuracyScore,
        'error': _error,
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header Section
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppThemes.speaking.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppThemes.speaking.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.record_voice_over, color: AppThemes.speaking, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Luyện phát âm:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppThemes.speaking,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Target Sentence
              if (sentence != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppThemes.speaking.withOpacity(0.3)),
                  ),
                  child: Text(
                    sentence!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              
              // Instruction
              if (instruction != null) ...[
                Text(
                  instruction!,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppThemes.lightSecondaryLabel,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
              ],
              
              // Pronunciation Tips
              if (pronunciationTips != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppThemes.speaking.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppThemes.speaking.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: AppThemes.speaking, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          pronunciationTips!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppThemes.speaking,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Audio Sample Section
        if (audioUrl != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppThemes.lightBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppThemes.systemGray4),
            ),
            child: Column(
              children: [
                Text(
                  'Nghe mẫu:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppThemes.lightLabel,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _isAudioReady ? _playAudio : null,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _isAudioReady ? AppThemes.speaking : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        
                         // Recording Section
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _isRecording ? AppThemes.speaking.withOpacity(0.1) : AppThemes.lightBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isRecording ? AppThemes.speaking : AppThemes.systemGray4,
              width: _isRecording ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              
              // Recorder Status
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _recorderInitialized ? Colors.green : Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _recorderInitialized ? 'Recorder sẵn sàng' : 'Recorder chưa khởi tạo',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _recorderInitialized ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Initialize Recorder Button
              if (!_recorderInitialized) ...[
                ElevatedButton(
                  onPressed: () async {
                    try {
                      print('🎤 [SpeakingWidget] Manually initializing recorder...');
                      await _initializeRecorder();
                      setState(() {
                        _recorderInitialized = true;
                        _error = null;
                      });
                    } catch (e) {
                      print('❌ [SpeakingWidget] Manual initialization failed: $e');
                      setState(() {
                        _error = 'Không thể khởi tạo recorder: $e';
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Khởi tạo Recorder'),
                ),
                const SizedBox(height: 12),
              ],
              
              // Recording Status
              if (_recorderInitialized) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _isRecording ? Colors.red : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isRecording ? 'Đang ghi âm...' : 'Sẵn sàng ghi âm',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _isRecording ? AppThemes.speaking : AppThemes.lightLabel,
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Recording Duration
              if (_isRecording || _hasRecorded) ...[
                Text(
                  _formatDuration(_recordingDuration),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _isRecording ? AppThemes.speaking : AppThemes.lightLabel,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Recording Controls
              if (_recorderInitialized) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Record/Stop Button
                    GestureDetector(
                      onTap: _isProcessing ? null : (_isRecording ? _stopRecording : _startRecording),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: _isRecording ? Colors.red : AppThemes.speaking,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (_isRecording ? Colors.red : AppThemes.speaking).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isRecording ? Icons.stop : Icons.mic,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Processing Indicator
        if (_isProcessing) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppThemes.lightBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppThemes.systemGray4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppThemes.speaking),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Đang xử lý ghi âm...',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppThemes.lightSecondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        
        // Error Display
        if (_error != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _error!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Results Section
        if (_recognizedText != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isCorrect ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isCorrect ? Colors.green : Colors.orange,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Score
                Row(
                  children: [
                    Icon(
                      _isCorrect ? Icons.check_circle : Icons.info_outline,
                      color: _isCorrect ? Colors.green : Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Điểm: ${(_accuracyScore * 100).round()}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _isCorrect ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Recognized Text
                Text(
                  'Bạn đã nói:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppThemes.lightLabel,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _recognizedText!,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppThemes.lightLabel,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Feedback
                if (_feedback != null) ...[
                  Text(
                    'Nhận xét:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppThemes.lightLabel,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _feedback!,
                    style: TextStyle(
                      fontSize: 14,
                      color: _isCorrect ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
        
        // Error Display
        if (_error != null) ...[
          const SizedBox(height: 16),
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
                    _error!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade700,
                    ),
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