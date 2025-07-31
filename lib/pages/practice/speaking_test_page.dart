// lib/pages/practice/speaking_test_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_themes.dart';
import '../../widgets/exercises/speaking_widget.dart';
import '../../widgets/exercises/simple_speaking_widget.dart';

class SpeakingTestPage extends StatefulWidget {
  const SpeakingTestPage({Key? key}) : super(key: key);

  @override
  State<SpeakingTestPage> createState() => _SpeakingTestPageState();
}

class _SpeakingTestPageState extends State<SpeakingTestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.lightGroupedBackground,
      appBar: AppBar(
        backgroundColor: AppThemes.lightSecondaryBackground,
        elevation: 0,
        title: const Text(
          'Speaking Test',
          style: TextStyle(
            color: AppThemes.lightLabel,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppThemes.lightLabel),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Test speaking widget with sample data
            Container(
              width: double.infinity,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🎤 Speaking Exercise Test',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppThemes.lightLabel,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Test speaking widget with sample data',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppThemes.lightSecondaryLabel,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Test button first
                  ElevatedButton(
                    onPressed: () {
                      print('🎤 [SpeakingTestPage] Testing speech recognition...');
                      // Simulate a speaking result
                      final result = {
                        'recognizedText': 'Hello, how are you today?',
                        'accuracyScore': 0.85,
                        'isCorrect': true,
                        'feedback': 'Tuyệt vời! Phát âm chính xác.',
                        'confidence': 0.85,
                      };
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Test result: ${result.toString()}'),
                          backgroundColor: AppThemes.primaryGreen,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemes.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Test Speech Recognition'),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Simple Speaking widget (safe version)
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SimpleSpeakingWidget(
                      content: {
                        'sentence': 'Hello, how are you today?',
                        'instruction': 'Please repeat the sentence clearly',
                        'audio_text': 'Hello, how are you today?',
                        'audioUrl': null, // No audio for test
                      },
                      question: {
                        'text': 'Repeat the sentence',
                      },
                      onAnswerSubmitted: (result) {
                        print('🎤 Simple speaking result: $result');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Simple speaking result: ${result.toString()}'),
                            backgroundColor: AppThemes.primaryGreen,
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Original Speaking widget (may crash)
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning, color: Colors.red, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'Original Speaking Widget (May Crash)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SpeakingWidget(
                          content: {
                            'sentence': 'Hello, how are you today?',
                            'instruction': 'Please repeat the sentence clearly',
                            'audio_text': 'Hello, how are you today?',
                            'audioUrl': null, // No audio for test
                          },
                          question: {
                            'text': 'Repeat the sentence',
                          },
                          onAnswerSubmitted: (result) {
                            print('🎤 Original speaking result: $result');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Original speaking result: ${result.toString()}'),
                                backgroundColor: AppThemes.primaryGreen,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Error display section
            Container(
              width: double.infinity,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🐛 Debug Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppThemes.lightLabel,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Check console for detailed error messages',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppThemes.lightSecondaryLabel,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      print('🔍 [SpeakingTestPage] Manual debug check');
                      // Add any manual debug checks here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemes.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Check Debug Info'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 