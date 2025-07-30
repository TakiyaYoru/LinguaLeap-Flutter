# LinguaLeap Flutter - Refactored Architecture

## Tổng quan

Dự án đã được refactor để cải thiện khả năng bảo trì và mở rộng. File `lesson_detail_page.dart` ban đầu (1830 dòng) đã được chia thành các component nhỏ hơn, dễ quản lý.

## Cấu trúc mới

### 📁 `lib/widgets/exercises/`
Chứa các widget riêng biệt cho từng loại bài tập:

- **`exercise_widget_factory.dart`** - Factory pattern để tạo exercise widgets
- **`multiple_choice_widget.dart`** - Widget cho bài tập trắc nghiệm
- **`fill_blank_widget.dart`** - Widget cho bài tập điền từ
- **`true_false_widget.dart`** - Widget cho bài tập đúng/sai
- **`translation_widget.dart`** - Widget cho bài tập dịch thuật
- **`word_matching_widget.dart`** - Widget cho bài tập ghép từ

### 📁 `lib/widgets/dialogs/`
Chứa các dialog tái sử dụng:

- **`correct_answer_dialog.dart`** - Dialog hiển thị đáp án đúng
- **`wrong_answer_dialog.dart`** - Dialog hiển thị đáp án sai
- **`lesson_completion_dialog.dart`** - Dialog hoàn thành bài học

### 📁 `lib/controllers/exercises/`
Chứa base controller cho các exercise (để mở rộng trong tương lai):

- **`exercise_controller.dart`** - Base controller với các method chung

### 📁 `lib/pages/`
- **`lesson_detail_page_refactored.dart`** - Phiên bản refactored của lesson detail page

## Lợi ích của việc refactor

### 1. **Dễ bảo trì**
- Mỗi exercise type có file riêng, dễ sửa đổi
- Logic tách biệt rõ ràng
- Giảm complexity của file chính

### 2. **Dễ mở rộng**
- Thêm exercise type mới chỉ cần tạo widget mới
- Factory pattern tự động hỗ trợ exercise type mới
- Không cần sửa file chính

### 3. **Tái sử dụng**
- Dialogs có thể dùng cho các page khác
- Exercise widgets có thể dùng cho preview hoặc test
- Factory pattern cho phép tái sử dụng logic

### 4. **Testing**
- Mỗi component có thể test riêng biệt
- Dễ mock và test các exercise type
- Unit test cho từng widget

## Cách sử dụng

### Sử dụng phiên bản refactored:
```dart
// Thay vì sử dụng LessonDetailPage cũ
// Sử dụng LessonDetailPageRefactored
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => LessonDetailPageRefactored(
      lessonId: lessonId,
      unitId: unitId,
      lessonTitle: lessonTitle,
      currentHearts: hearts,
      onHeartsChanged: (newHearts) => setState(() => hearts = newHearts),
      onLessonCompleted: (unitId, lessonId, status) => handleLessonCompleted(),
    ),
  ),
);
```

### Thêm exercise type mới:
1. Tạo widget mới trong `lib/widgets/exercises/`
2. Thêm case trong `exercise_widget_factory.dart`
3. Thêm logic check answer trong `lesson_detail_page_refactored.dart`

## Migration Guide

### Từ phiên bản cũ sang mới:

1. **Backup file cũ:**
   ```bash
   cp lib/pages/lesson_detail_page.dart lib/pages/lesson_detail_page_backup.dart
   ```

2. **Thay thế import:**
   ```dart
   // Cũ
   import 'pages/lesson_detail_page.dart';
   
   // Mới
   import 'pages/lesson_detail_page_refactored.dart';
   ```

3. **Cập nhật class name:**
   ```dart
   // Cũ
   LessonDetailPage
   
   // Mới
   LessonDetailPageRefactored
   ```

## Cấu trúc dữ liệu

### Exercise Content Format:
```json
{
  "type": "multiple_choice",
  "content": "{\"options\":[\"A\",\"B\",\"C\",\"D\"],\"correctAnswer\":0}",
  "question": {"text": "Câu hỏi?"},
  "feedback": {
    "correct": "Đúng rồi!",
    "incorrect": "Chưa đúng!",
    "hint": "Gợi ý..."
  }
}
```

### Supported Exercise Types:
- ✅ `multiple_choice` - Trắc nghiệm
- ✅ `fill_blank` - Điền từ
- ✅ `true_false` - Đúng/Sai
- ✅ `translation` - Dịch thuật
- ✅ `word_matching` - Ghép từ
- 🔄 `listening` - Nghe hiểu (chưa implement)
- 🔄 `speaking` - Nói (chưa implement)
- 🔄 `reading` - Đọc hiểu (chưa implement)
- 🔄 `sentence_building` - Xây dựng câu (chưa implement)
- 🔄 `drag_drop` - Kéo thả (chưa implement)
- 🔄 `listen_choose` - Nghe và chọn (chưa implement)
- 🔄 `speak_repeat` - Nói và lặp lại (chưa implement)

## Performance Improvements

### Trước refactor:
- File 1830 dòng
- Tất cả logic trong 1 file
- Khó debug và maintain

### Sau refactor:
- Chia thành 10+ file nhỏ
- Mỗi file < 300 dòng
- Logic tách biệt rõ ràng
- Dễ debug và maintain

## Next Steps

1. **Implement remaining exercise types** (7 types còn lại)
2. **Add state management** cho exercise controllers
3. **Add unit tests** cho từng component
4. **Add integration tests** cho lesson flow
5. **Optimize performance** với lazy loading
6. **Add accessibility** features

## Troubleshooting

### Lỗi thường gặp:

1. **Import errors:**
   ```dart
   // Đảm bảo import đúng
   import '../widgets/exercises/exercise_widget_factory.dart';
   ```

2. **Exercise type not found:**
   ```dart
   // Thêm case trong factory
   case 'new_type':
     return NewTypeWidget(...);
   ```

3. **State not preserved:**
   ```dart
   // Implement state restoration
   controllerState: _getExerciseState(exerciseId),
   ```

## Contributing

Khi thêm tính năng mới:
1. Tạo widget riêng cho exercise type
2. Thêm vào factory
3. Cập nhật logic check answer
4. Thêm tests
5. Cập nhật documentation 