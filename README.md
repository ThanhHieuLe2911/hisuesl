# HisuESL

Ứng dụng di động **Flutter** hỗ trợ học tiếng Anh theo lộ trình: từ vựng (flashcard), quiz nhiều dạng câu, gamification (hearts, điểm, streak), bảng xếp hạng, thành tựu và chatbot gợi ý bằng **Google Gemini**. Backend người dùng dùng **Firebase Authentication** và **Cloud Firestore**.

| | |
|---|---|
| **Nền tảng** | Android, iOS (theo cấu hình Firebase) |
| **SDK Dart** | ^3.0.0 |
| **Phiên bản app** | 1.0.0+1 (theo `pubspec.yaml`) |

---

## Mục lục

- [Tính năng chính](#tính-năng-chính)
- [Công nghệ sử dụng](#công-nghệ-sử-dụng)
- [Yêu cầu hệ thống](#yêu-cầu-hệ-thống)
- [Cài đặt và chạy dự án](#cài-đặt-và-chạy-dự-án)
- [Cấu hình](#cấu-hình)
- [Cấu trúc thư mục](#cấu-trúc-thư-mục)
- [Design System](#design-system)
- [Backend API](#backend-api)
- [Tài liệu chi tiết](#tài-liệu-chi-tiết)
- [Kiểm thử](#kiểm-thử)
- [Lưu ý bảo mật](#lưu-ý-bảo-mật)

---

## Tính năng chính

- **Tài khoản:** đăng nhập / đăng ký email-mật khẩu, xác thực **OTP qua email**, onboarding chọn trình độ (A1-B2).
- **Học tập:** lộ trình unit, flashcard, quiz (trắc nghiệm, gõ từ, nghe + TTS, sắp xếp từ), từ yêu thích (Firestore subcollection).
- **Gamification:** hearts (giới hạn lượt, hồi theo thời gian), điểm, streak, mua hearts bằng điểm, achievements.
- **Cộng đồng:** leaderboard theo `totalPoints`.
- **Hisubot Tutor:** hội thoại với Gemini (streaming, hiển thị Markdown), hỗ trợ **nhiều cuộc trò chuyện**, lưu lịch sử chat.
- **Tiện ích:** thông báo nhắc học hằng ngày, âm thanh khi làm bài, chỉnh sửa hồ sơ và avatar (nén, lưu Base64 trên Firestore).

---

## Công nghệ sử dụng

| Nhóm | Thư viện / dịch vụ |
|------|---------------------|
| Framework | Flutter |
| Backend & Auth | `firebase_core`, `firebase_auth`, `cloud_firestore` |
| UI | `google_fonts`, `flutter_svg`, `percent_indicator`, `flip_card`, `flutter_markdown` |
| Trạng thái / lưu cục bộ | `provider`, `shared_preferences` |
| Âm thanh / TTS | `audioplayers`, `flutter_tts` |
| AI | `flutter_gemini` |
| Thông báo | `flutter_local_notifications`, `timezone`, `flutter_timezone` |
| Email OTP | `mailer` (SMTP) |
| Ảnh | `image_picker`, `flutter_image_compress` |
| HTTP Client | `http` |
| Environment | `flutter_dotenv` |

---

## Yêu cầu hệ thống

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (khuyến nghị kênh stable, tương thích Dart ^3.0.0).
- [Android Studio](https://developer.android.com/studio) hoặc Xcode (macOS) để build tương ứng nền tảng.
- Tài khoản **Firebase** (đã tạo app Android/iOS, bật Email/Password, tạo Firestore).
- **MySQL** server cho backend API (quản lý topics, vocabularies, questions).
- PHP 8.0+ với extension PDO cho backend API.
- (Tuỳ chọn) Thiết bị thật hoặc emulator (Android Studio, **LDPlayer**, ...).

---

## Cài đặt và chạy dự án

### 1. Cài đặt Flutter

```bash
# Clone hoặc giải nén mã nguồn, sau đó:
cd hisuesl

# Cài dependency
flutter pub get

# Kiểm tra môi trường
flutter doctor

# Liệt kê thiết bị / emulator
flutter devices
```

### 2. Cài đặt Backend API (PHP)

```bash
# Di chuyển vào thư mục backend
cd backend

# Cấu hình database trong .env
# DB_HOST=localhost
# DB_NAME=hisuesl_db
# DB_USER=root
# DB_PASS=your_password
```

Cấu hình web server (Apache/Nginx) trỏ vào thư mục `backend/` với URL ví dụ: `http://192.168.1.xx/hisuesl_backend/api/`

### 3. Chạy ứng dụng

```bash
# Chạy app (chọn thiết bị nếu có nhiều máy)
flutter run
flutter run -d <device_id>
```

Đảm bảo thư mục assets tồn tại theo khai báo trong `pubspec.yaml`:

- `assets/icons/`
- `assets/images/`
- `assets/sounds/`

---

## Cấu hình

### 1. Firebase

Thêm file cấu hình do Firebase Console tạo (ví dụ `google-services.json` cho Android, `GoogleService-Info.plist` cho iOS) và đảm bảo bundle ID / application ID khớp với project Firebase.

### 2. Gemini API

Khóa API được khởi tạo trong `lib/main.dart` (`Gemini.init`) và đọc từ file `.env`:

```env
GEMINI_API_KEY=your_gemini_api_key
```

**Không** đưa khóa thật lên kho mã công khai; nên dùng biến môi trường hoặc `--dart-define` khi build.

### 3. Gửi email OTP

Cấu hình SMTP (ví dụ Gmail App Password) trong `lib/features/auth/services/otp_service.dart`. **Không** commit mật khẩu ứng dụng vào Git.

### 4. Backend API URL

Cấu hình base URL trong `lib/features/learn/services/api_service.dart`:

```dart
static const String baseUrl = 'http://192.168.1.40/hisuesl_backend/api/';
```

### 5. Quy tắc Firestore

Cấu hình Security Rules phù hợp production (đọc/ghi `users`, `favorites`, `conversations`, v.v.).

---

## Cấu trúc thư mục

```
hisuesl/
├── backend/                    # Backend PHP REST API
│   ├── api/                   # (public API endpoints)
│   ├── config/
│   │   └── database.php       # Kết nối MySQL (hỗ trợ .env)
│   ├── controllers/           # REST controllers
│   │   ├── TopicController.php
│   │   ├── VocabularyController.php
│   │   └── QuestionController.php
│   ├── models/                # Data models
│   │   ├── Topic.php
│   │   ├── Vocabulary.php
│   │   └── Question.php
│   ├── admin/                 # Admin panel CRUD
│   │   ├── index.php         # Dashboard
│   │   ├── login.php         # Admin login
│   │   ├── import.php        # Import dữ liệu
│   │   ├── export.php        # Export dữ liệu
│   │   ├── topics/           # Quản lý topics
│   │   ├── vocabularies/     # Quản lý từ vựng
│   │   ├── questions/        # Quản lý câu hỏi quiz
│   │   └── partials/         # Header, footer, sidebar
│   ├── index.php             # API router
│   └── .env                  # Database config (không commit)
│
├── lib/
│   ├── main.dart             # Khởi tạo Firebase, NotificationService, Gemini
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_colors.dart         # Design Token: Color System
│   │   ├── theme/
│   │   │   ├── app_theme.dart          # Material Theme hoàn chỉnh
│   │   │   ├── app_typography.dart    # Typography Scale
│   │   │   ├── app_radius.dart         # Border Radius System
│   │   │   ├── app_spacing.dart       # Spacing System (8px grid)
│   │   │   └── app_shadows.dart       # Shadow System
│   │   └── services/
│   │       ├── notification_service.dart  # Thông báo nhắc học
│   │       └── sound_service.dart         # Phát âm thanh
│   │
│   ├── widgets/               # Reusable Components
│   │   ├── app_stat_pill.dart       # Stat pills (hearts/points/streak)
│   │   ├── app_bottom_sheet.dart    # Bottom sheet wrapper
│   │   ├── custom_snackbar.dart      # Custom SnackBar
│   │   ├── app_button.dart          # AppButton foundation
│   │   ├── custom_textfield.dart     # Custom text field
│   │   └── common_button.dart       # Common button
│   │
│   └── features/
│       ├── auth/
│       │   ├── screens/
│       │   │   ├── login_screen.dart
│       │   │   ├── register_screen.dart
│       │   │   ├── otp_screen.dart
│       │   │   └── onboarding_screen.dart
│       │   └── services/
│       │       ├── auth_service.dart
│       │       └── otp_service.dart
│       │
│       ├── home/
│       │   ├── screens/
│       │   │   ├── home_screen.dart        # Bottom nav + PathView
│       │   │   ├── profile_screen.dart
│       │   │   └── edit_profile_screen.dart
│       │   ├── services/
│       │   │   └── achievement_service.dart
│       │   └── widgets/
│       │       └── heart_shop_sheet.dart
│       │
│       ├── learn/
│       │   ├── screens/
│       │   │   ├── learn_screen.dart
│       │   │   ├── flashcard_screen.dart
│       │   │   ├── quiz_screen.dart
│       │   │   ├── favorites_screen.dart
│       │   │   └── favorite_detail_screen.dart
│       │   ├── services/
│       │   │   ├── topic_service.dart      # Load topics từ backend API
│       │   │   ├── question_service.dart   # Load questions từ backend API
│       │   │   ├── vocab_service.dart
│       │   │   ├── quiz_service.dart
│       │   │   └── api_service.dart        # HTTP client cho backend
│       │   ├── data/
│       │   │   ├── mock_data.dart
│       │   │   └── mock_quiz_data.dart
│       │   └── models/
│       │       ├── topic_model.dart
│       │       ├── vocab_model.dart
│       │       └── question_model.dart
│       │
│       ├── leaderboard/
│       │   ├── screens/
│       │   │   └── leaderboard_screen.dart
│       │   └── services/
│       │       └── leaderboard_service.dart
│       │
│       └── chatbot/
│           ├── screens/
│           │   └── hisubot_screen.dart     # Multi-conversation chatbot
│           ├── services/
│           │   ├── chat_history_service.dart  # Conversation management
│           │   └── user_data_service.dart     # User context for AI
│           ├── models/
│           │   └── conversation.dart
│           └── widgets/
│               └── conversation_list_drawer.dart
│
├── assets/
│   ├── icons/
│   ├── images/
│   └── sounds/
│
└── pubspec.yaml
```

---

## Design System

HisuESL sử dụng hệ thống **Design Tokens** để đảm bảo tính nhất quán về UI/UX.

### Color System (`app_colors.dart`)

```dart
// Primary
AppColors.primary          // #0099FF - Màu chủ đạo
AppColors.primaryShadow     // #0077C8 - Shadow 3D
AppColors.background       // #EBF5FF - Nền soft blue

// Semantic
AppColors.success          // #4CAF50 - Xanh lá (đúng)
AppColors.error            // #FFFF4B4B - Đỏ (sai)
AppColors.warning           // #FFFF9800 - Cam (cảnh báo)

// Gamification
AppColors.heart            // #FFFF4B4B - Trái tim
AppColors.streak           // #FFFF6B35 - Streak/lửa
AppColors.trophy           // #FFFFD700 - Cup vàng
AppColors.point            // #FF2196F3 - Điểm
```

### Typography Scale (`app_typography.dart`)

```dart
// Font chủ đạo: Dongle
AppTypography.display()    // 72px - Tiêu đề lớn nhất
AppTypography.h1()          // 48px - AppBar title
AppTypography.h2()          // 38px - Section heading
AppTypography.h3()          // 32px - Card title
AppTypography.body()        // 22px - Body text
AppTypography.button()      // 30px - Button text
```

### Spacing System (`app_spacing.dart`)

```dart
// Hệ 8px grid
AppSpacing.xs      // 8px
AppSpacing.sm      // 12px
AppSpacing.md      // 16px (default)
AppSpacing.lg      // 24px
AppSpacing.xl      // 32px
```

### Radius System (`app_radius.dart`)

```dart
AppRadius.small    // 12px  - Pill, tag
AppRadius.medium   // 16px  - Button, input
AppRadius.large    // 24px  - Dialog
AppRadius.xl       // 32px  - Bottom sheet
AppRadius.round    // 999px - Circle
```

### Shadow System (`app_shadows.dart`)

```dart
AppShadows.soft      // Shadow mềm cho card flat
AppShadows.hard       // Shadow 3D cho button
AppShadows.deep       // Shadow sâu cho dialog
```

---

## Backend API

### Cấu trúc Database

```
hisuesl_db/
├── topics          # Bảng chủ đề/bài học
│   ├── id
│   ├── title
│   ├── description
│   ├── color
│   ├── image_path
│   ├── unit_order
│   └── is_active
│
├── vocabularies    # Bảng từ vựng
│   ├── id
│   ├── unit_id     # FK -> topics.id
│   ├── word
│   ├── pronunciation
│   ├── meaning
│   ├── example
│   └── is_active
│
└── questions       # Bảng câu hỏi quiz
    ├── id
    ├── unit_id     # FK -> topics.id
    ├── question_type  # multiple_choice, typing, listening, arrange
    ├── question_text
    ├── options      # JSON array
    ├── correct_answer
    ├── audio_url
    └── is_active
```

### API Endpoints

| Method | Endpoint | Mô tả |
|--------|----------|--------|
| GET | `/api/topics` | Lấy danh sách topics |
| GET | `/api/topics?id=X` | Lấy topic theo ID |
| GET | `/api/vocabularies?unit_id=X` | Lấy từ vựng theo unit |
| GET | `/api/questions?unit_id=X` | Lấy câu hỏi theo unit |
| GET | `/api/health` | Health check endpoint |

### Admin Panel

Truy cập `/backend/admin/` để quản lý:

- **Dashboard**: Tổng quan số lượng topics, vocabularies, questions
- **Topics**: Thêm, sửa, xóa chủ đề bài học
- **Vocabularies**: Quản lý từ vựng theo từng unit
- **Questions**: Tạo câu hỏi quiz với nhiều loại
- **Import/Export**: Nhập/xuất dữ liệu hàng loạt

---

## Kiểm thử

```bash
flutter test
```

---

## Lưu ý bảo mật

- API key Gemini và thông tin SMTP trong mã nguồn **không an toàn** cho kho công khai.
- OTP hiện đối chiếu phía client (`actualOtp` truyền giữa màn hình); môi trường production nên xác thực OTP qua backend hoặc dịch vụ chuyên dụng.
- Backend API nên được bảo vệ bằng authentication và HTTPS trong production.
- File `.env` chứa thông tin database và API keys **không được commit** vào Git.

---

## Giấy phép & đóng góp

Dự án mang cờ `publish_to: 'none'` trong `pubspec.yaml` (thường dùng nội bộ / học tập). Nếu mở rộng team, bổ sung `LICENSE` và hướng dẫn đóng góp theo nhu cầu.
