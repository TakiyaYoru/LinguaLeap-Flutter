# Google Speech-to-Text API Setup Guide

## 🎤 Setup Google Speech-to-Text API cho LinguaLeap

### **✅ GOOD NEWS: Sử dụng chung Google Cloud Project với TTS!**

Bạn đã có Google Cloud project `lingualeap-ed012` cho TTS, chúng ta sẽ **sử dụng chung** project này cho Speech-to-Text.

### **Step 1: Enable Speech-to-Text API (trong project hiện tại)**

1. **Truy cập Google Cloud Console:**
   ```
   https://console.cloud.google.com/
   ```

2. **Chọn project hiện tại:**
   - Project: `lingualeap-ed012` (cùng project với TTS)

3. **Vào API Library:**
   ```
   https://console.cloud.google.com/apis/library
   ```

4. **Tìm và enable Speech-to-Text API:**
   - Search: "Speech-to-Text API"
   - Click "Enable"

### **Step 2: Tạo API Key (hoặc sử dụng key hiện tại)**

1. **Vào Credentials:**
   ```
   https://console.cloud.google.com/apis/credentials
   ```

2. **Kiểm tra API keys hiện tại:**
   - Nếu đã có API key cho TTS → có thể sử dụng chung
   - Nếu chưa có → tạo API key mới

3. **Tạo API Key (nếu cần):**
   - Click "Create Credentials" → "API Key"
   - Copy API key được tạo

### **Step 3: Cấu hình API Key**

1. **Mở file:**
   ```
   lib/utils/speech_recognition_service.dart
   ```

2. **Thay thế API key:**
   ```dart
   // Sử dụng chung Google Cloud project với TTS
   // Project ID: lingualeap-ed012
   static const String _googleApiKey = 'YOUR_ACTUAL_GOOGLE_API_KEY_HERE';
   ```

### **Step 4: Test API**

1. **Chạy test:**
   ```bash
   cd LinguaLeap-Flutter
   flutter run
   ```

2. **Test speaking exercise:**
   - Vào admin panel
   - Tạo speaking exercise
   - Test recording và recognition

### **Step 5: Bảo mật API Key (Optional)**

1. **Tạo file .env trong Flutter project:**
   ```
   GOOGLE_SPEECH_API_KEY=your_api_key_here
   ```

2. **Thêm vào .gitignore:**
   ```
   .env
   ```

3. **Cập nhật code để đọc từ .env:**
   ```dart
   import 'package:flutter_dotenv/flutter_dotenv.dart';
   
   static const String _googleApiKey = String.fromEnvironment(
     'GOOGLE_SPEECH_API_KEY',
     defaultValue: 'YOUR_API_KEY',
   );
   ```

## 🔧 API Configuration

### **Audio Format Requirements:**
- **Encoding:** LINEAR16, FLAC, MP3, M4A
- **Sample Rate:** 8000-48000 Hz
- **Language:** en-US (English US)

### **Request Limits:**
- **Free Tier:** 60 minutes/month
- **Paid:** $0.006 per 15 seconds

### **Supported Features:**
- ✅ Real-time transcription
- ✅ Word-level confidence scores
- ✅ Automatic punctuation
- ✅ Multiple language support
- ✅ Speaker diarization

## 🚀 Usage Examples

### **Basic Recognition:**
```dart
final speechService = SpeechRecognitionService();
final result = await speechService.recognizeWithGoogle(
  audioFilePath, 
  targetText
);

print('Recognized: ${result.text}');
print('Confidence: ${result.confidence}');
print('Score: ${result.accuracyScore}');
```

### **Error Handling:**
```dart
try {
  final result = await speechService.recognizeWithGoogle(
    audioFilePath, 
    targetText
  );
  // Handle success
} catch (e) {
  print('Recognition failed: $e');
  // Handle error
}
```

## 📊 Scoring Algorithm

### **Accuracy Calculation:**
```dart
// Word matching (70% weight)
final targetWords = targetText.toLowerCase().split(' ');
final recognizedWords = recognizedText.toLowerCase().split(' ');
int correctWords = 0;
for (final targetWord in targetWords) {
  if (recognizedWords.contains(targetWord)) {
    correctWords++;
  }
}
final wordAccuracy = correctWords / targetWords.length;

// API confidence (30% weight)
final apiConfidence = confidence;

// Final score
final accuracyScore = (wordAccuracy * 0.7 + apiConfidence * 0.3);
```

### **Score Thresholds:**
- **90-100%:** "Tuyệt vời! Phát âm chính xác 100%"
- **80-89%:** "Rất tốt! Phát âm gần như chính xác"
- **60-79%:** "Khá tốt! Hãy chú ý phát âm rõ ràng hơn"
- **<60%:** "Hãy thử lại, nói chậm và rõ ràng hơn"

## 🔍 Troubleshooting

### **Common Issues:**

1. **API Key Invalid:**
   - Kiểm tra API key đúng chưa
   - Đảm bảo Speech-to-Text API đã enable trong project `lingualeap-ed012`

2. **Audio Format Error:**
   - Chuyển đổi audio sang LINEAR16 hoặc FLAC
   - Kiểm tra sample rate (8000-48000 Hz)

3. **Network Error:**
   - Kiểm tra internet connection
   - Kiểm tra firewall settings

4. **Permission Error:**
   - Đảm bảo microphone permission đã được grant
   - Kiểm tra app permissions

### **Debug Tips:**
```dart
// Enable debug logging
print('🎤 [SpeechRecognition] Starting recognition...');
print('📁 Audio file: $audioFilePath');
print('🎯 Target text: $targetText');
```

## 📈 Performance Optimization

### **Audio Optimization:**
- **Sample Rate:** 16000 Hz (đủ cho speech recognition)
- **Bit Rate:** 128 kbps
- **Format:** M4A hoặc FLAC

### **Network Optimization:**
- **Timeout:** 30 seconds
- **Retry:** 3 attempts
- **Fallback:** Azure Speech Services

### **Memory Management:**
- **Cleanup:** Xóa audio files sau khi xử lý
- **Caching:** Cache recognition results
- **Compression:** Nén audio trước khi gửi

## 🔐 Security Best Practices

1. **API Key Protection:**
   - Không commit API key vào git
   - Sử dụng environment variables
   - Rotate API keys regularly

2. **Audio Privacy:**
   - Xóa audio files sau khi xử lý
   - Không log audio content
   - Encrypt sensitive audio data

3. **Rate Limiting:**
   - Implement request throttling
   - Monitor API usage
   - Set up billing alerts

## 📞 Support

### **Google Cloud Support:**
- **Documentation:** https://cloud.google.com/speech-to-text/docs
- **API Reference:** https://cloud.google.com/speech-to-text/docs/reference/rest
- **Pricing:** https://cloud.google.com/speech-to-text/pricing

### **LinguaLeap Support:**
- **Issues:** Tạo issue trên GitHub
- **Discussions:** Thảo luận trên Discord
- **Email:** support@lingualeap.com 