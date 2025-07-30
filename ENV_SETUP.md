# 🔧 Environment Variables Setup

## 📝 Tạo file .env

Tạo file `.env` trong thư mục `LinguaLeap-Flutter` với nội dung sau:

```env
# Google Cloud Speech-to-Text API Keys
# Sử dụng chung project với TTS: text-to-speech-lingualeap

# Google Speech-to-Text API Key (cùng với TTS)
GOOGLE_SPEECH_API_KEY=your_actual_google_api_key_here

# Azure Speech Services (fallback - optional)
AZURE_SPEECH_API_KEY=your_azure_api_key_here

# App Configuration
APP_NAME=LinguaLeap
APP_VERSION=1.0.0
```

## 🔑 Lấy Google API Key

1. **Truy cập:** https://console.cloud.google.com/apis/credentials
2. **Chọn project:** `text-to-speech-lingualeap` (cùng với TTS)
3. **Copy API key** từ danh sách credentials
4. **Thay thế** `your_actual_google_api_key_here` bằng API key thực

## 📁 File Structure

```
LinguaLeap-Flutter/
├── .env                    ← Tạo file này
├── lib/
├── pubspec.yaml
└── ...
```

## ✅ Test Setup

Sau khi tạo .env, chạy:

```bash
cd LinguaLeap-Flutter
flutter pub get
flutter run
```

## 🔒 Security

- **Không commit** file .env vào git
- File .env đã được thêm vào .gitignore
- API keys sẽ được load tự động khi app khởi động

## 🐛 Debug

Nếu gặp lỗi, kiểm tra:

1. **File .env tồn tại** trong thư mục gốc
2. **API key đúng** và không có khoảng trắng
3. **Speech-to-Text API đã enable** trong Google Cloud Console 