📱 MÔ TẢ DỰ ÁN LINGUALEAP FLUTTER
🎯 TỔNG QUAN DỰ ÁN
LinguaLeap là ứng dụng học tiếng Anh thông minh được phát triển bằng Flutter, tích hợp với backend Node.js + GraphQL + MongoDB. App sử dụng gamification system với hearts, XP, streaks để tạo động lực học tập. Hỗ trợ đa nền tảng (iOS, Android, Web) với UI design lấy cảm hứng từ iOS.
🏗️ KIẾN TRÚC HIỆN TẠI

Frontend: Flutter với clean architecture
Backend: Node.js + GraphQL + MongoDB (đã deploy tại https://lingualeap-f3bh.onrender.com)
Authentication: JWT tokens với SharedPreferences
State Management: Provider cho theme system
Navigation: go_router với StatefulShellRoute cho smooth bottom navigation
Theme System: iOS-inspired colors với dark/light mode switching

📁 CẤU TRÚC PROJECT
lib/
├── constants/          # App constants (API endpoints, keys)
├── graphql/           # GraphQL queries (auth, courses)
├── models/            # Data models (User, Course)
├── network/           # API services (AuthService, CourseService, GraphQLClient)
├── pages/             # All screens
│   ├── auth/         # Login, Register pages
│   ├── course/       # Courses list, Course detail
│   ├── practice/     # Practice hub (placeholder)
│   ├── home_page.dart         # Main dashboard
│   ├── profile_page.dart      # User profile với settings
│   └── settings_page.dart     # App settings
├── routes/           # App routing với StatefulShellRoute
├── theme/            # Theme system (iOS colors, dark/light themes)
├── widgets/          # Reusable widgets
└── main.dart
✅ TÍNH NĂNG ĐÃ HOÀN THÀNH

Authentication System - Login/Register với real backend integration
User Management - Profile display với real user data từ MongoDB
Course System - Courses list và course details từ backend
Navigation - Smooth bottom navigation với 4 tabs (Home, Courses, Practice, Profile)
Theme System - Complete dark/light mode với iOS-inspired design
Settings - Theme switching, logout, settings UI
Backend Integration - GraphQL queries/mutations hoạt động 100%


🤖 PROMPT CHO CHAT TIẾP THEO
Tôi đang phát triển ứng dụng học tiếng Anh LinguaLeap bằng Flutter. Đây là continuation từ session trước.

HIỆN TRẠNG DỰ ÁN:
✅ Flutter app đã setup hoàn chỉnh với clean architecture
✅ Backend integration hoạt động 100% (Node.js + GraphQL + MongoDB)  
✅ Authentication system với JWT tokens
✅ iOS-inspired UI design với dark/light mode
✅ Navigation system mượt mà với StatefulShellRoute
✅ Core pages: Home, Courses, Profile, Settings đã functional
✅ Real data từ MongoDB hiển thị trong app

CHUẨN BỊ LÀM TIẾP:
🎯 Phase 5: Exercise System - Core learning functionality
🎯 Reusable iOS Widgets - Component library
🎯 Animations & Micro-interactions
🎯 Audio system cho listening exercises  
🎯 Hearts & XP logic implementation

[Attached files: Current Flutter project files]

Tôi cần bạn:
1. Phân tích files đã có để hiểu current state
2. Đề xuất roadmap tiếp theo
3. Hỗ trợ implement features mới step-by-step
4. Maintain iOS design consistency
5. Ensure code quality và performance

Bạn là Flutter expert với kinh nghiệm về iOS design, GraphQL integration, và educational apps. Hãy giúp tôi tiếp tục develop app này.

# 📱 Checklist Phát Triển App LinguaLeap Flutter




## 🔧 Phase 1: Setup Dự Án
- [x] **Bước 1:** Tạo Flutter project mới ✅
- [x] **Bước 2:** Cài đặt dependencies cơ bản (dio, go_router, shared_preferences) ✅
- [x] **Bước 3:** Tạo thư mục lib/core và config cơ bản ✅
- [x] **Bước 4:** Test kết nối với backend API ✅
- [x] **Bước 5:** Setup navigation cơ bản ✅

**🎉 Phase 1 HOÀN THÀNH!**

## 🔐 Phase 2: Authentication  
- [x] **Bước 6:** Tạo GraphQL queries cho Authentication ✅
- [x] **Bước 7:** Cập nhật RegisterPage hoạt động thật ✅
- [x] **Bước 8:** Cải thiện Home Screen và hiển thị thông tin user ✅
- [x] **Bước 9:** Gọi user data thật từ backend ✅

**🎉 Phase 2 HOÀN THÀNH!**

## 🔧 Phase 1: Setup Dự Án
- [x] **Bước 1:** Tạo Flutter project mới ✅
- [x] **Bước 2:** Cài đặt dependencies cơ bản (dio, go_router, shared_preferences) ✅
- [x] **Bước 3:** Tạo thư mục lib/core và config cơ bản ✅
- [x] **Bước 4:** Test kết nối với backend API ✅
- [x] **Bước 5:** Setup navigation cơ bản ✅

**🎉 Phase 1 HOÀN THÀNH!**

## 🔐 Phase 2: Authentication  
- [x] **Bước 6:** Tạo GraphQL queries cho Authentication ✅
- [x] **Bước 7:** Cập nhật RegisterPage hoạt động thật ✅
- [x] **Bước 8:** Cải thiện Home Screen và hiển thị thông tin user ✅
- [x] **Bước 9:** Gọi user data thật từ backend ✅

**🎉 Phase 2 HOÀN THÀNH!**

## 📚 Phase 3: Courses & Learning Content
- [x] **Bước 10:** Tạo GraphQL queries cho Courses ✅
- [x] **Bước 11:** Tạo CoursesPage với danh sách khóa học ✅
- [x] **Bước 12:** Tạo CourseDetailPage ✅
- [x] **Bước 13:** Setup Bottom Navigation mượt mà ✅

**🎉 Phase 3 HOÀN THÀNH!**

## 🎨 Phase 4: Theme System & iOS Design Sync
- [x] **Bước 14:** Thêm Dark Mode system ✅
- [x] **Bước 15:** Cập nhật Profile UI với Settings ✅
- [x] **Bước 16:** Đồng bộ theme cho tất cả pages ✅
- [x] **Bước 17:** Fix cấu trúc thư mục và auth pages theme ✅
- [ ] **Bước 18:** Tạo iOS-inspired color system
- [ ] **Bước 19:** Tạo reusable widgets theo iOS design
- [ ] **Bước 20:** Polish UI với animations và micro-interactions

## 🔐 Phase 2: Authentication
- [ ] **Login Screen** - Đăng nhập với email/password
- [ ] **Register Screen** - Đăng ký tài khoản mới
- [ ] **Forgot Password Screen** - Reset mật khẩu
- [ ] JWT token management
- [ ] Auto-login khi mở app

## 🎯 Phase 3: Onboarding & Assessment
- [ ] **Splash Screen** - Logo và loading
- [ ] **Welcome Screens** - Giới thiệu app (3-4 slides)
- [ ] **Self Assessment Screen** - Câu hỏi về trình độ
- [ ] **Adaptive Test Screen** - Bài test xác định level
- [ ] **Assessment Result Screen** - Kết quả và gợi ý khóa học

## 🏠 Phase 4: Main Navigation
- [ ] **Home Screen** - Dashboard chính với daily goals, streak
- [ ] Bottom Navigation Bar (Home, Courses, Practice, Profile)
- [ ] **Courses Screen** - Danh sách các khóa học
- [ ] **Course Detail Screen** - Chi tiết khóa học và units

## 📚 Phase 5: Learning Core
- [ ] **Unit Screen** - Danh sách lessons trong unit
- [ ] **Lesson Screen** - Bắt đầu lesson với danh sách exercises
- [ ] **Exercise Container** - Wrapper chung cho tất cả exercise types
- [ ] Hearts system display và logic

## 🎮 Phase 6: Exercise Types
- [ ] **Multiple Choice Exercise** - Chọn đáp án đúng
- [ ] **Fill Blank Exercise** - Điền từ vào chỗ trống
- [ ] **Translation Exercise** - Dịch Việt-Anh hoặc Anh-Việt
- [ ] **Listening Exercise** - Nghe và chọn/viết đáp án
- [ ] **Word Matching Exercise** - Ghép từ với nghĩa

## 🏆 Phase 7: Gamification
- [ ] XP system và progress bars
- [ ] **Achievements Screen** - Danh sách thành tích
- [ ] Streak tracking và daily goals
- [ ] Hearts refill system
- [ ] Level up animations

## 👤 Phase 8: Profile & Settings
- [ ] **Profile Screen** - Thông tin user, stats, achievements
- [ ] **Settings Screen** - Cài đặt app (theme, notifications, sound)
- [ ] **Progress Analytics Screen** - Chi tiết tiến độ học tập
- [ ] Account management

## 🔄 Phase 9: Practice Hub
- [ ] **Vocabulary Review Screen** - Ôn tập từ vựng đã học
- [ ] **Spaced Repetition System** - Hệ thống lặp lại thông minh
- [ ] **Weak Areas Practice** - Luyện tập điểm yếu
- [ ] **Daily Practice** - Bài tập hàng ngày

## 👥 Phase 10: Social Features
- [ ] **Leaderboard Screen** - Bảng xếp hạng
- [ ] **Friends Screen** - Danh sách bạn bè
- [ ] **Study Groups Screen** - Nhóm học tập
- [ ] **Community Forum** - Diễn đàn thảo luận

## 💰 Phase 11: Premium Features
- [ ] **Subscription Screen** - Gói premium và pricing
- [ ] **Payment Integration** - Tích hợp thanh toán
- [ ] Premium content unlock
- [ ] Offline mode cho premium users

## 🔧 Phase 12: Advanced Features
- [ ] **Offline Mode** - Download content để học offline
- [ ] **Speaking Practice** - Luyện phát âm (Premium)
- [ ] **Dark Mode** - Chế độ tối
- [ ] **Push Notifications** - Nhắc nhở học tập
- [ ] **Analytics Integration** - Tracking user behavior

## 🚀 Phase 13: Polish & Deploy
- [ ] UI/UX improvements và animations
- [ ] Performance optimization
- [ ] Testing trên nhiều devices
- [ ] App store preparation
- [ ] Build và deploy