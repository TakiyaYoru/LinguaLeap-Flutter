# 🔑 Lấy Google API Key cho Speech-to-Text

## 📋 Project Info

- **Project ID:** `text-to-speech-lingualeap`
- **Service Account:** `tslingualeap@text-to-speech-lingualeap.iam.gserviceaccount.com`
- **Credentials File:** `google-credentials.json` (đã có)

---

## **Step 1: Vào Google Cloud Console**

1. **Truy cập:** https://console.cloud.google.com/
2. **Chọn project:** `text-to-speech-lingualeap`
3. **Xác nhận:** Bạn đang ở đúng project

---

## **Step 2: Enable Speech-to-Text API**

1. **Vào API Library:** https://console.cloud.google.com/apis/library
2. **Search:** "Speech-to-Text API"
3. **Click:** "Enable"
4. **Đợi:** API được enable (1-2 phút)

---

## **Step 3: Lấy API Key**

### **Option A: Sử dụng API Key hiện tại (nếu có)**

1. **Vào Credentials:** https://console.cloud.google.com/apis/credentials
2. **Tìm:** API Keys trong danh sách
3. **Copy:** API key có sẵn

### **Option B: Tạo API Key mới**

1. **Vào Credentials:** https://console.cloud.google.com/apis/credentials
2. **Click:** "Create Credentials" → "API Key"
3. **Copy:** API key được tạo
4. **Optional:** Click "Restrict Key" để bảo mật

---

## **Step 4: Tạo file .env**

Tạo file `.env` trong thư mục `LinguaLeap-Flutter`:

```env
# Google Cloud Speech-to-Text API Keys
# Project: text-to-speech-lingualeap

# Google Speech-to-Text API Key
GOOGLE_SPEECH_API_KEY=AIzaSyC...your_actual_api_key_here

# Azure Speech Services (optional)
AZURE_SPEECH_API_KEY=your_azure_api_key_here

# App Configuration
APP_NAME=LinguaLeap
APP_VERSION=1.0.0
```

---

## **Step 5: Test**

```bash
cd LinguaLeap-Flutter
flutter pub get
flutter run
```

---

## **🔒 Security Tips**

1. **Restrict API Key:**
   - Vào Credentials → Click API Key → Edit
   - Application restrictions: HTTP referrers
   - API restrictions: Speech-to-Text API

2. **Monitor Usage:**
   - Vào Billing → Reports
   - Kiểm tra usage của Speech-to-Text API

---

## **🐛 Troubleshooting**

### **API Key Invalid:**
- Kiểm tra API key đúng chưa
- Đảm bảo Speech-to-Text API đã enable
- Kiểm tra API restrictions

### **Project Not Found:**
- Đảm bảo đang ở đúng project `text-to-speech-lingualeap`
- Kiểm tra permissions của service account

### **API Not Enabled:**
- Vào API Library → Search "Speech-to-Text"
- Click "Enable" nếu chưa enable 