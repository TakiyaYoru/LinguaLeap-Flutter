// lib/widgets/exercises/simple_speaking_widget.dart
import 'package:flutter/material.dart';
import '../../theme/app_themes.dart';

class SimpleSpeakingWidget extends StatefulWidget {
  final Map<String, dynamic> content;
  final Map<String, dynamic> question;
  final Function(dynamic) onAnswerSubmitted;
  final Map<String, dynamic>? controllerState;

  const SimpleSpeakingWidget({
    Key? key,
    required this.content,
    required this.question,
    required this.onAnswerSubmitted,
    this.controllerState,
  }) : super(key: key);

  @override
  State<SimpleSpeakingWidget> createState() => _SimpleSpeakingWidgetState();
}

class _SimpleSpeakingWidgetState extends State<SimpleSpeakingWidget> {
  // Content data
  String? sentence;
  String? instruction;
  String? audioText;
  
  // UI state
  bool _isProcessing = false;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _initializeExercise();
  }

  void _initializeExercise() {
    try {
      final content = widget.content;
      sentence = content['sentence'] as String?;
      instruction = content['instruction'] as String?;
      audioText = content['audio_text'] as String?;
      
      print('🔍 [SimpleSpeakingWidget] Initialized:');
      print('  - sentence: ${sentence?.length ?? 0} chars');
      print('  - instruction: ${instruction?.length ?? 0} chars');
      print('  - audioText: ${audioText?.length ?? 0} chars');
      
    } catch (e) {
      print('❌ [SimpleSpeakingWidget] Error initializing exercise: $e');
      _error = 'Lỗi khởi tạo bài tập: $e';
    }
  }

  void _simulateRecording() async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    // Simulate processing time
    await Future.delayed(const Duration(seconds: 2));

    // Simulate speech recognition result
    final result = {
      'recognizedText': sentence ?? 'Hello, how are you today?',
      'accuracyScore': 0.85,
      'isCorrect': true,
      'feedback': 'Tuyệt vời! Phát âm chính xác.',
      'confidence': 0.85,
      'audioPath': '/tmp/simulated_recording.m4a',
    };

    setState(() {
      _isProcessing = false;
    });

    // Submit result
    widget.onAnswerSubmitted(result);
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
              
              // Sentence to pronounce
              if (sentence != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppThemes.speaking.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Câu cần phát âm:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppThemes.lightSecondaryLabel,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        sentence!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppThemes.lightLabel,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Instruction
              if (instruction != null && instruction!.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppThemes.speaking.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppThemes.speaking, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          instruction!,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppThemes.speaking,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Recording Section
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Recording button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _simulateRecording,
                  icon: _isProcessing 
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(Icons.mic, color: Colors.white),
                  label: Text(
                    _isProcessing ? 'Đang xử lý...' : 'Bắt đầu ghi âm (Test)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppThemes.speaking,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Info text
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Đây là phiên bản test đơn giản. Nhấn nút để mô phỏng kết quả ghi âm.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Error display
              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.red[700],
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
      ],
    );
  }
} 