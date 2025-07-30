# 🚀 Quick Speech-to-Text Setup (5 phút)

## ✅ Sử dụng chung Google Cloud Project với TTS

### **Project hiện tại:** `text-to-speech-lingualeap`

---

## **Step 1: Enable Speech-to-Text API (2 phút)**

1. **Truy cập:** https://console.cloud.google.com/
2. **Chọn project:** `text-to-speech-lingualeap`
3. **Vào API Library:** https://console.cloud.google.com/apis/library
4. **Search:** "Speech-to-Text API"
5. **Click:** "Enable"

---

## **Step 2: Lấy API Key (1 phút)**

1. **Vào Credentials:** https://console.cloud.google.com/apis/credentials
2. **Kiểm tra:** Nếu đã có API key → copy luôn
3. **Nếu chưa có:** Click "Create Credentials" → "API Key" → copy

---

## **Step 3: Cập nhật code (1 phút)**

1. **Mở file:** `lib/utils/speech_recognition_service.dart`
2. **Thay thế dòng 25:**
   ```dart
   static const String _googleApiKey = 'YOUR_ACTUAL_API_KEY_HERE';
   ```

---

## **Step 4: Test (1 phút)**

```bash
cd LinguaLeap-Flutter
flutter pub get
flutter run
```

---

## **🎯 Kết quả:**

✅ **TTS + Speech-to-Text** trong cùng 1 project  
✅ **Chung billing** và **chung quota**  
✅ **Không cần tạo project mới**  
✅ **Setup trong 5 phút**  

---

## **🔧 Nếu gặp lỗi:**

### **API Key Invalid:**
- Kiểm tra API key đúng chưa
- Đảm bảo Speech-to-Text API đã enable

### **Permission Error:**
- Kiểm tra microphone permission trong app

### **Network Error:**
- Kiểm tra internet connection

---

## **📞 Support:**

- **Documentation:** https://cloud.google.com/speech-to-text/docs
- **Pricing:** $0.006 per 15 seconds (sau free tier)
- **Free Tier:** 60 minutes/month 