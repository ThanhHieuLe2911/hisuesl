# HisuESL - Project Overview

## 1) Tổng quan

HisuESL là một ứng dụng học tiếng Anh (ESL) dạng "lộ trình + từ vựng + quiz" kèm cơ chế game hoá (hearts/points/streak/achievements/rankings) và chatbot AI. Ứng dụng gồm **2 phần chính**:

- **Flutter App** (`/`): Ứng dụng di động Flutter dùng Firebase Authentication + Cloud Firestore
- **Backend PHP** (`/backend/`): REST API + Admin Panel quản lý nội dung học tập (topics, vocabularies, questions)

### Tính năng chính (Flutter App)

- Đăng nhập / đăng ký email + xác thực OTP qua email (SnackBar tùy chỉnh trên `LoginScreen`, `RegisterScreen`, `OtpScreen`)
- Chọn trình độ (A1/A2/B1/B2) khi onboarding
- Học từ vựng theo "unit", lật flashcard, lưu từ yêu thích
- Làm bài quiz nhiều loại câu hỏi (trắc nghiệm/typing/sắp xếp/nghe)
- Mua thêm hearts bằng điểm
- Hiển thị thành tựu (achievements) và bảng xếp hạng theo tổng điểm
- Chatbot "Hisubot Tutor" trả lời theo Gemini
- Nhắc học tập hằng ngày (local notifications) và phát âm thanh khi làm bài

---

## 2) Công nghệ & thư viện chính

### Flutter App (`pubspec.yaml`)

- **SDK:** Dart `^3.0.0`, Flutter SDK tương ứng
- **UI/UX:** `google_fonts`, `percent_indicator`, `flip_card`, `flutter_svg`, `flutter_markdown`
- **Firebase/Backend:** `firebase_core`, `firebase_auth`, `cloud_firestore`
- **State & Storage:** `provider`, `shared_preferences`
- **Âm thanh & TTS:** `audioplayers`, `flutter_tts`
- **Chatbot AI:** `flutter_gemini` (gọi Gemini qua `Gemini.init()` và `streamGenerateContent`)
- **Thông báo:** `flutter_local_notifications`, `timezone`, `flutter_timezone`
- **OTP:** `mailer` (SMTP Gmail)
- **HTTP:** `http` (kết nối backend PHP)
- **Ảnh:** `image_picker`, `flutter_image_compress`

### Backend PHP

- **Web Server:** Apache (`.htaccess` URL rewriting)
- **PHP:** Phiên bản tương thích với PDO MySQL
- **Database:** MySQL (PDO)
- **Frontend consumed by:** Flutter app qua REST API endpoints

---

## 3) Kiến trúc tổng thể

```
hisuesl/
├── lib/                        # Flutter App (Dart)
│   ├── main.dart               # Entry point: Firebase init, Notification init, Gemini init
│   ├── core/
│   │   ├── constants/         # Design tokens: colors
│   │   ├── theme/             # Design tokens: theme, shadows, radius, spacing, typography
│   │   └── services/          # Core services: notification, sound
│   ├── widgets/               # Shared widgets: buttons, snackbar, textfield, stat pill, bottom sheet
│   └── features/
│       ├── auth/              # Login, Register, OTP, Onboarding + AuthService, OtpService
│       ├── home/              # HomeScreen (PathView), ProfileScreen, EditProfileScreen + AchievementService
│       ├── learn/             # LearnScreen, FlashcardScreen, QuizScreen, FavoritesScreen + models, services, mock data
│       ├── leaderboard/       # LeaderboardScreen + LeaderboardService
│       └── chatbot/          # HisubotScreen (Gemini)
├── backend/                    # Backend PHP
│   ├── index.php              # REST API router (front controller)
│   ├── .env                   # Database credentials
│   ├── .htaccess             # Apache URL rewrite
│   ├── config/
│   │   └── database.php       # PDO MySQL connection + .env loader
│   ├── sql/
│   │   └── admin_schema.sql  # MySQL migration (admin_users, learning_stats)
│   ├── controllers/           # REST API controllers (Topic, Vocabulary, Question)
│   ├── models/               # Data access objects
│   └── admin/                 # Admin Panel CRUD UI
│       ├── login.php         # Auth
│       ├── logout.php
│       ├── index.php         # Dashboard
│       ├── export.php        # CSV export
│       ├── import.php        # CSV import
│       ├── topics/           # CRUD Topics
│       ├── vocabularies/     # CRUD Vocabularies
│       ├── questions/        # CRUD Questions
│       ├── partials/         # Layout: header, sidebar, footer
│       ├── includes/         # Middleware: auth_check
│       └── assets/
│           └── style.css     # Admin panel CSS
├── plan/                      # Planning documents
└── pubspec.yaml              # Flutter dependencies
```

---

## 4) Flutter App - Chi tiết

### 4.1 Entry Point (`lib/main.dart`)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().init();

  Gemini.init(
    apiKey: 'AIzaSyDniuZBZtccOg-7raBjySRc-FszYJbo7OU',
    enableDebugging: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = false;
    try { isLoggedIn = AuthService().currentUser != null; } catch (_) {}

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HisuESL',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
```

- Khởi tạo Firebase, NotificationService, Gemini
- Quyết định màn hình đầu: đã đăng nhập → `HomeScreen`, chưa → `LoginScreen`

---

### 4.2 Design System (`lib/core/`)

#### 4.2.1 Colors (`lib/core/constants/app_colors.dart`)

Tập màu dùng chung: `primary` (#0099FF), `background` (#EBF5FF), `surface`, `textMain`, `textPrimary`, `textSecondary`, `textLight`, `error`, `success`, `warning`, `heart`, `streak`, `trophy`, `chatbotUser`, `chatbotBot`, `border`, `progressBackground`, `primaryShadow`, `primaryLight`, `info`, v.v.

#### 4.2.2 Theme (`lib/core/theme/app_theme.dart`)

Full Material `ThemeData` gồm:
- `colorScheme`: brightness, primary, secondary, error, surface
- `appBarTheme`: transparent background, Dongle font 40px
- `textTheme`: mapping 14 text styles qua `AppTypography`
- `inputDecorationTheme`: filled TextField với OutlineInputBorder
- `elevatedButtonTheme`, `textButtonTheme`, `outlinedButtonTheme`
- `snackBarTheme`: floating, no elevation
- `dialogTheme`, `bottomSheetTheme`, `cardTheme`, `dividerTheme`
- `progressIndicatorTheme`, `switchTheme`, `listTileTheme`, `chipTheme`
- `AppThemeMixin` (State mixin), `AppThemeContext` (BuildContext extension)

#### 4.2.3 Shadows (`lib/core/theme/app_shadows.dart`)

Hệ thống shadow với factory methods và presets:
- Factory: `soft()`, `medium()`, `hard()` (3D không blur), `deep()`
- Presets: `softShadow`, `softElevated`, `mediumShadow`, `hardShadow`, `hardShadowElevated`, `deepShadow`, `fabShadow`, `avatarShadow`, `learnCard`, `favoriteCard`, `rankCard`, `streakCard`, `chatBubble`, `inputFocus`, `actionChip`, `bottomSheet`, `statPill`, `quizOption`
- Helpers: `boxWithShadow()`, `cardBox()`, `buttonBox()`

#### 4.2.4 Radius (`lib/core/theme/app_radius.dart`)

Hệ thống border radius: `none` (8px), `small` (12px), `medium` (16px), `mediumLarge` (20px), `large` (24px), `header` (30px), `xl` (32px), `flashcard` (40px), `round` (999px). Helpers: `bottomSheet()`, `bubbleUser()`, `bubbleBot()`, `pill()`. Decorations: `buttonDecoration()`, `cardDecoration()`, `dialogDecoration()`, `bottomSheetDecoration()`, `flashcardDecoration()`, `statPillDecoration()`, `circleDecoration()`.

#### 4.2.5 Spacing (`lib/core/theme/app_spacing.dart`)

Hệ thống spacing 8px grid: `spacing4` (4px), `xs` (8px), `sm` (12px), `md` (16px), `mdLg` (20px), `lg` (24px), `xl` (32px), `xxl` (40px), `xxxl` (48px), `buttonHeight` (56px), `headerHeight` (64px), `heroHeight` (80px). EdgeInsets presets, Gap helpers (SizedBox), padding presets cho từng component.

#### 4.2.6 Typography (`lib/core/theme/app_typography.dart`)

Font chủ đạo: **Dongle** (Google Fonts), font phụ RobotoMono cho code. Scale: `display()` (72px), `h1()` (48px), `h2()` (38px), `h3()` (32px), `title()` (28px), `titleMedium()` (26px), `bodyLarge()` (24px), `body()` (22px), `label()` (20px), `caption()` (18px), `button()` (30px, uppercase), `vocabWord()` (70px), `vocabMeaning()` (55px), `quizQuestion()` (32px), `quizOption()` (26px), markdown styles, input styles, snackbar, achievement, rank, profile, leaderboard.

---

### 4.3 Shared Widgets (`lib/widgets/`)

| File | Mô tả |
|------|--------|
| `app_bottom_sheet.dart` | Handle bar chuẩn + wrapper `show()` + shape `RoundedRectangle` (32px top) + `titleStyle` |
| `app_button.dart` | Button 3D variants: `primary` (blue + shadow), `outlined` (border), `disabled` (grey) |
| `app_stat_pill.dart` | Stat pill: icon + value + color + onTap. `AppTextPill`: text-only variant |
| `common_button.dart` | Legacy 3D button (backgroundColor + shadowColor) |
| `custom_snackbar.dart` | `CustomSnackBar.show()` / `success()` / `error()` / `info()` với 3 loại (`SnackBarType`) |
| `custom_textfield.dart` | TextField floating label + 3D box shadow effect + icon prefix |

---

### 4.4 Core Services (`lib/core/services/`)

#### NotificationService (`lib/core/services/notification_service.dart`)

- `init()`: khởi tạo `flutter_local_notifications` + timezone
- `scheduleDailyNotification(hour, minute)`: lập lịch notification hằng ngày với `zonedSchedule` + `matchDateTimeComponents: DateTimeComponents.time`
- `showInstantNotification()`: test notification
- `cancelAll()`: hủy tất cả

#### SoundService (`lib/core/services/sound_service.dart`)

Singleton pattern. Phát âm thanh từ `assets/sounds/`: `playCorrect()` (correct.mp3), `playWrong()` (wrong.mp3), `playStreak()` (streak.mp3), `playFinish()` (finish.mp3).

---

### 4.5 Auth Feature (`lib/features/auth/`)

#### Screens

| File | Mô tả |
|------|--------|
| `screens/login_screen.dart` | Form email/password. SnackBar tùy chỉnh: success = `AppColors.primary`, error = `AppColors.error`. Đăng nhập thành công → SnackBar xanh → 500ms → `pushReplacement` HomeScreen |
| `screens/register_screen.dart` | Form: tên hiển thị, email, mật khẩu, nhập lại mật khẩu. Validate: tên không rỗng, email có `@`, mật khẩu ≥ 6 ký tự, khớp xác nhận. `OtpService.generateOtp()` + `sendOtpEmail()`. Thành công → SnackBar xanh → `Navigator.push` OtpScreen kèm `email`, `password`, `name`, **`actualOtp`** |
| `screens/otp_screen.dart` | Nhập mã 6 số. So khớp `_otpCtrl` với `actualOtp`. Đúng → `AuthService.register()`. Thành công → SnackBar xanh → 1 giây → `pushAndRemoveUntil` OnboardingScreen |
| `screens/onboarding_screen.dart` | Chọn trình độ dạng nhãn đầy đủ (Người mới (A1) … Cao cấp (B2)), 3D option cards. Cập nhật `level` trên Firestore → `pushAndRemoveUntil` HomeScreen |

#### Services

**`services/auth_service.dart`:**
- `currentUser` getter: trả về `FirebaseAuth.instance.currentUser`
- `register(email, password, name)`: tạo Firebase user + `set` doc `users/{uid}` (uid, email, name, createdAt, level="Chưa chọn", hearts=5, points=0, avatarBase64=null)
- `login(email, password)`: Firebase `signInWithEmailAndPassword`
- `logout()`: `signOut()`
- `updateUserProfile({name, base64Image})`: cập nhật Firestore
- `changePassword(currentPassword, newPassword)`: re-authenticate bằng `reauthenticateWithCredential` rồi `updatePassword`

**`services/otp_service.dart`:**
- `generateOtp()`: 6 chữ số ngẫu nhiên
- `sendOtpEmail(toEmail, otp)`: gửi HTML email qua Gmail SMTP (`mailer`). Hardcoded credentials. Nội dung: chào mừng + mã OTP (inline style, màu xanh). Trả `true/false`.

---

### 4.6 Home Feature (`lib/features/home/`)

#### Screens

**`screens/home_screen.dart`:**
- `HomeScreen`: Scaffold với `IndexedStack` (giữ trạng thái tab) + bottom navigation + FAB mở Hisubot
- `PathView` (tab "Hành trình"): vẽ lộ trình theo `mockTopics`, unit unlock theo `learnedUnits`, tap unit → `QuizScreen`
- `HeartTimer`: hiển thị countdown đến lần hồi hearts tiếp theo (10 phút/cái), tự gọi `regenerateOneHeart()` khi đến 0
- Bottom nav: Journey, Vocabulary, Ranking, Profile

**`screens/profile_screen.dart`:**
- Header với avatar (Base64 decode → `CircleAvatar`), name, email, level badge
- Rank card: title rank (6 bậc: "Tân Binh Khởi Nguyên" ≤ 500 … "Tượng Đài Bất Diệt" > 20000) + progress bar
- Stats: Streak, Total Points, Learned Units (3 pill cards)
- Achievement list: 6 achievements với progress check
- Settings: switch "Hiệu ứng âm thanh" (SharedPreferences), picker giờ nhắc nhở (CupertinoDatePicker) → "XÁC NHẬN" → `NotificationService.scheduleDailyNotification()`
- `AchievementService.checkAndClaimAchievements()` được gọi đúng 1 lần sau build (`_hasCheckedAchievements` + `addPostFrameCallback`)
- Logout button

**`screens/edit_profile_screen.dart`:**
- Avatar picker (camera/gallery) → `flutter_image_compress` → Base64 → Firestore
- Name editing → `AuthService.updateUserProfile`
- Đổi mật khẩu: old + new → `AuthService.changePassword`
- Dialog feedback thành công/lỗi

#### Widgets

**`widgets/heart_shop_sheet.dart`:**
- 3 gói mua hearts:
  - 1 tim / 1.000 điểm
  - 3 tim / 2.500 điểm
  - 5 tim / 4.000 điểm
- `QuizService.buyHearts(cost, amount)` theo Firestore transaction

#### Services

**`services/achievement_service.dart`:**

6 thành tựu, mỗi cái thưởng +500 điểm:

| ID | Title | Description | Điều kiện | Thưởng |
|----|-------|-------------|-----------|---------|
| streak_3 | Khởi Động | Chuỗi 3 ngày | dayStreak ≥ 3 | 500 pts |
| streak_7 | Kiên Trì | Chuỗi 7 ngày | dayStreak ≥ 7 | 500 pts |
| streak_30 | Huyền Thoại | Chuỗi 30 ngày | dayStreak ≥ 30 | 500 pts |
| points_1000 | Triệu Phú | Tích lũy 1000 điểm | totalPoints ≥ 1000 | 500 pts |
| learned_5 | Học Giả | Hoàn thành 5 bài | learnedUnits.length ≥ 5 | 500 pts |
| rank_pro | Tinh Anh | Đạt 2000 điểm tổng | totalPoints ≥ 2000 | 500 pts |

`checkAndClaimAchievements(userData)`: kiểm tra điều kiện, `arrayUnion` IDs mới vào `achievements`, `increment` points + totalPoints.

---

### 4.7 Learn Feature (`lib/features/learn/`)

#### Models

**`models/topic_model.dart`:** `id` (int), `title`, `description`, `imagePath`, `color` (Color), `vocabularies` (List<VocabModel>), `isLearned`. Factory `fromJson` parse từ backend API + `_parseColor` từ HEX string.

**`models/vocab_model.dart`:** `id` (String), `word`, `meaning`, `pronunciation`, `type`, `exampleSentence`, `audioUrl`, `isFavorite`. Factory `fromJson` parse từ backend.

**`models/question_model.dart`:** `id` (String), `unitId` (int), `type` (`QuestionType` enum), `questionText`, `correctAnswer` (dynamic), `options` (List<String>?), `explanation`. Factory `fromJson` decode JSON `options` và `correct_answer`. Enum `QuestionType`: `multipleChoice`, `arrange`, `listening`, `typing`.

#### Services

**`services/api_service.dart`:**
- Base URL: `http://192.168.1.40/hisuesl_backend/api/`
- `get(endpoint)`: HTTP GET với timeout 10s, trả `{'success': bool, 'data': dynamic, 'isList': bool, 'error': string?}`

**`services/topic_service.dart`:**
- `getTopics()`: gọi backend `topics`, fetch vocab mỗi topic, fallback `mockTopics`
- `getTopicById(id)`: gọi backend `topics?id=N` + vocab, fallback `mockTopics`

**`services/question_service.dart`:**
- `getQuestionsByUnit(unitId)`: gọi backend `questions?unit_id=N`, fallback `getQuestionsForUnit(unitId)` từ mock

**`services/vocab_service.dart`:**
- `getFavoriteVocabIds()`: Stream lắng nghe subcollection `users/{uid}/favorites`, trả `List<String>` (doc IDs)
- `toggleFavorite(vocabId)`: toggle doc trong subcollection (delete nếu exists, set nếu không)
- `markUnitAsLearned(unitId)`: `FieldValue.arrayUnion([unitId])` vào `learnedUnits`

**`services/quiz_service.dart`:**
- `checkHeartAvailability()`: kiểm tra hearts + `_calculateRegeneratedHearts` nếu < 5
- `_calculateRegeneratedHearts(doc)`: hồi `(diff_in_minutes / 10).floor()` tim, update `hearts` + `lastHeartUpdate`
- `regenerateOneHeart()`: Firestore transaction: nếu hearts < 5 → +1 heart, set `lastHeartUpdate = now` (hoặc null nếu đầy)
- `buyHearts(cost, amount)`: transaction kiểm tra points đủ + hearts chưa đầy, trừ points, cộng hearts, quản lý `lastHeartUpdate` (giữ mốc cũ nếu vẫn < 5)
- `syncOfflineHearts()`: gọi `_calculateRegeneratedHearts` trong `initState` HomeScreen
- `deductHeart()`: transaction trừ 1 heart + set `lastHeartUpdate = now`
- `finishQuiz(pointsEarned, unitId)`: transaction: cộng points + totalPoints, tính dayStreak theo `lastLearnDate` (so sánh theo ngày), `arrayUnion` unitId vào `learnedUnits`

#### Data

**`data/mock_data.dart`:**

8 topics (units), mỗi topic 15 vocabularies:

| ID | Title | Color | Icon |
|----|-------|-------|------|
| 1 | Chào hỏi & Làm quen | #4CB050 (Green) | handshake.png |
| 2 | Thời tiết | #03A9F4 (Blue) | weather.png |
| 3 | Thời gian & Ngày tháng | #FF9800 (Orange) | clock.png |
| 4 | Mua sắm | #E91E63 (Pink) | shopping.png |
| 5 | Thể thao | #F44336 (Red) | sport.png |
| 6 | Công việc | #795548 (Brown) | job.png |
| 7 | Hoạt động hằng ngày | #9C27B0 (Purple) | daily.png |
| 8 | Giáo dục | #607D8B (Grey) | education.png |

**`data/mock_quiz_data.dart`:**

80 câu hỏi (10 câu/unit), 4 loại:
- `multipleChoice`: chọn 1 đáp án trong 4 options
- `typing`: nhập đáp án (so sánh lowercase)
- `listening`: phát TTS câu hỏi bằng `flutter_tts`, so sánh `_selectedAnswer == correctAnswer`
- `arrange`: sắp xếp words thành câu đúng bằng `join(" ")`

Hàm `getQuestionsForUnit(unitId)` trả về `mockQuestionsByUnit[unitId]` hoặc rỗng.

#### Screens

| File | Mô tả |
|------|--------|
| `screens/learn_screen.dart` | Grid view 8 topic cards (màu sắc + icon + số vocab). Tap → `FlashcardScreen`. Nút "Từ đã thích" → `FavoritesScreen` |
| `screens/flashcard_screen.dart` | `FlipCard` (flutter_flip_card) hiển thị word/meaning, TTS pronunciation, toggle favorite (star icon), progress bar, "HOÀN THÀNH" → `markUnitAsLearned()` |
| `screens/quiz_screen.dart` | Quiz logic: check hearts → shuffle 10 câu → duyệt từng câu. Mỗi câu: hiển thị theo `QuestionType`, nút "KIỂM TRA" → đúng/sai update UI. Sound effects. Bottom sheet "Chính xác/Sai rồi" + "TIẾP TỤC". Streak celebration at 3/5/10. Lưu lỗi sai local. Kết thúc → `finishQuiz()` + dialog kết quả. Hết hearts → dialog mua hearts |
| `screens/favorites_screen.dart` | Grid topics có từ yêu thích. Badge số từ mỗi topic. Tap → `FavoriteDetailScreen` |
| `screens/favorite_detail_screen.dart` | Danh sách từ yêu thích trong topic (từ `VocabService.getFavoriteVocabIds()` Stream), nút xoá từng từ, TTS pronunciation |

---

### 4.8 Leaderboard Feature (`lib/features/leaderboard/`)

**`screens/leaderboard_screen.dart`:**
- Top 20 users by `totalPoints` descending (Firestore `orderBy` + `limit(20)`)
- Top 3: gold/silver/bronze colors
- Mỗi row: rank number, avatar (Base64 → CircleAvatar, URL fallback, gravatar fallback), name, rank title, points
- Current user highlight (border)
- `LeaderboardService.getLeaderboard()` returns `Stream<QuerySnapshot>`

**`services/leaderboard_service.dart`:**
- `getLeaderboard()`: `orderBy('totalPoints', descending: true).limit(20).snapshots()`
- `getRankTitle(totalPoints)`: 6 bậc tương tự ProfileScreen

---

### 4.9 Chatbot Feature (`lib/features/chatbot/`)

**`screens/hisubot_screen.dart`:**
- Chat UI: `ListView` messages trong state, `BottomChatBar` input
- User bubble (màu `AppColors.chatbotUser`), bot bubble (màu `AppColors.chatbotBot`, BorderRadius đặc biệt)
- Khi gửi: thêm user bubble → gọi `gemini.streamGenerateContent(prompt, modelName: 'gemini-1.5-flash')` → streaming chunks → append vào bot bubble hiện tại
- Bot content render bằng `MarkdownBody` (`flutter_markdown`)
- Prompt: "Bạn là Hisubot, gia sư tiếng Anh. Trả lời rõ ràng, dễ hiểu."
- `ScrollController` auto-scroll xuống cuối

---

## 5) Luồng người dùng (User Flow)

### 5.1 Mở app (`main.dart`)
- Đã đăng nhập (`AuthService().currentUser != null`) → `HomeScreen`
- Chưa đăng nhập → `LoginScreen`

### 5.2 Đăng nhập (`LoginScreen`)
- Thiếu email/mật khẩu: `CustomSnackBar.error()` đỏ
- `AuthService.login(email, password)`
- Thành công: `CustomSnackBar.success()` xanh → 500ms → `pushReplacement` HomeScreen
- Thất bại: `CustomSnackBar.error()` đỏ

### 5.3 Đăng ký (`RegisterScreen` → `OtpScreen` → `OnboardingScreen`)
1. `RegisterScreen`: validate → `OtpService.generateOtp()` + `sendOtpEmail()` → SnackBar success → `Navigator.push` OtpScreen với `actualOtp`
2. `OtpScreen`: nhập OTP → so sánh string với `actualOtp` → `AuthService.register()` → SnackBar success → 1 giây → `pushAndRemoveUntil` OnboardingScreen
3. `OnboardingScreen`: chọn level (A1–B2 dạng nhãn đầy đủ) → `update level` → `pushAndRemoveUntil` HomeScreen

### 5.4 Dùng app (`HomeScreen`)
- Tab 1 `PathView`: lộ trình + unlock theo `learnedUnits`, tap → `QuizScreen`
- Tab 2 `LearnScreen`: topic grid → `FlashcardScreen` → `QuizScreen`
- Tab 3 `LeaderboardScreen`: top 20
- Tab 4 `ProfileScreen`: rank + achievements + settings
- FAB: mở `HisubotScreen`

---

## 6) Firestore Schema (Flutter App)

### 6.1 Collection `users`

Document: `users/{uid}`

**Khởi tạo khi đăng ký (`AuthService.register`):**
```
uid: string
email: string
name: string
createdAt: DateTime
level: "Chưa chọn"
hearts: 5
points: 0
avatarBase64: null
```

**Các trường xuất hiện trong vòng đời app:**
```
uid, email, name, createdAt
level ("Chưa chọn" | "Người mới (A1)" | ... | "Cao cấp (B2)")
hearts (0..5)
lastHeartUpdate (Timestamp | null) — mốc đếm hồi hearts 10 phút
points (điểm tiêu dùng)
totalPoints (điểm tích lũy xếp hạng)
dayStreak (chuỗi ngày học liên tiếp)
lastLearnDate (Timestamp — dùng tính streak)
learnedUnits (mảng int — unitId đã học xong)
achievements (mảng string — ID thành tựu đã claim)
avatarBase64 (string Base64 | null)
avatarUrl (string — legacy fallback, không dùng khi tạo user)
```

### 6.2 Subcollection `users/{uid}/favorites`

- Doc id = `vocabId`
- Data: `{ addedAt: DateTime }`
- `VocabService.getFavoriteVocabIds()` stream danh sách doc id

---

## 7) Backend PHP - REST API

### 7.1 Router (`backend/index.php`)

Front controller với CORS headers `*`. Rewrite rule `.htaccess` chuyển `/api/*` vào đây.

| Endpoint | File | Method |
|----------|------|--------|
| `GET /api/topics` | controllers/TopicController.php | list all |
| `GET /api/topics?id=N` | controllers/TopicController.php | get by id |
| `GET /api/vocabularies?unit_id=N` | controllers/VocabularyController.php | by unit |
| `GET /api/questions?unit_id=N` | controllers/QuestionController.php | by unit |
| `GET /api/health` | inline JSON | health check |
| * | inline 404 | error |

### 7.2 Controllers

| File | Logic |
|------|-------|
| `controllers/TopicController.php` | GET: list all → `TopicModel.getAll()`, hoặc by id → `TopicModel.getById()` |
| `controllers/VocabularyController.php` | GET: `unit_id` required → `VocabularyModel.getByUnit()` |
| `controllers/QuestionController.php` | GET: `unit_id` required → `QuestionModel.getByUnit()` (decode JSON options + correct_answer) |

### 7.3 Models

| File | Methods |
|------|---------|
| `models/Topic.php` | `getAll()` — `SELECT * FROM topics ORDER BY id ASC`; `getById(id)` |
| `models/Vocabulary.php` | `getByUnit(unitId)` — `SELECT * FROM vocabularies WHERE unit_id = ?`; `getById(id)` |
| `models/Question.php` | `getByUnit(unitId)` — decode JSON fields `options` và `correct_answer`; `getById(id)` |

### 7.4 Config

**`backend/config/database.php`:** Đọc `.env` (key=value, bỏ qua `#` comments) → `$db = new PDO("mysql:host=...;charset=utf8mb4", ...)`. Exit 500 nếu lỗi.

**`backend/.env`:**
```
DB_HOST=localhost
DB_NAME=hisuesl_db
DB_USER=root
DB_PASS=
```

---

## 8) Backend PHP - Admin Panel

### 8.1 Authentication

- `admin/login.php`: Form username/password → `SELECT * FROM admin_users WHERE username = ?` → `password_verify()` bcrypt → set `$_SESSION['admin_id']` + `$_SESSION['admin_username']` → redirect `index.php`
- `admin/logout.php`: `session_destroy()` → redirect `login.php`
- `admin/includes/auth_check.php`: standalone middleware, redirect `login.php` nếu không có `$_SESSION['admin_id']`
- `admin/partials/header.php`: include `auth_check.php`, HTML head, sidebar, flash messages
- Default credential: `admin` / `admin` (hash trong `admin_schema.sql`)

### 8.2 Dashboard (`admin/index.php`)

- Stats cards: Topics count, Vocabularies count, Questions count
- Phân bố câu hỏi theo loại (type badge + progress bar)
- Top 5 unit nhiều vocab nhất (bar chart style)
- Quick actions: CRUD buttons + Export/Import CSV

### 8.3 Topics CRUD (`admin/topics/`)

- `index.php`: list + vocab count per topic + edit/delete actions
- `create.php`: form (title, description, image_path, color HEX + color picker sync JS)
- `edit.php`: pre-populate form từ DB → UPDATE
- `delete.php`: kiểm tra FK vocab → block nếu có, else DELETE

### 8.4 Vocabularies CRUD (`admin/vocabularies/`)

- `index.php`: list + search (word/meaning LIKE) + filter by topic + pagination 20/page + edit only
- `create.php`: form (word, meaning, pronunciation, type dropdown, example_sentence, unit_id dropdown)
- `edit.php`: pre-populate → UPDATE

### 8.5 Questions CRUD (`admin/questions/`)

- `index.php`: list + filter by topic + filter by type (multiple_choice/true_false/fill_blank) + pagination + edit only
- `create.php`: form (unit_id, type, question_text, correct_answer, options textarea). Options format: dòng đầu tiên đánh dấu `*` = đáp án đúng. Live preview bằng JS. `INSERT IGNORE`
- `edit.php`: pre-populate → UPDATE

### 8.6 Export/Import

**`admin/export.php`:**
- Download file CSV UTF-8 BOM
- 3 sections: `=== TOPICS ===`, `=== VOCABULARIES ===`, `=== QUESTIONS ===`
- Filename: `hisuesl_export_YYYYMMDD.csv`

**`admin/import.php`:**
- 3-step: upload → preview (10 rows) → confirm
- Drag & drop file input
- BOM stripping
- Section detection từ header
- `INSERT IGNORE` để skip trùng ID
- Report: X inserted, Y skipped, errors list (max 20 shown)

### 8.7 Admin CSS (`admin/assets/style.css`)

- Dark sidebar: `#1a1a2e`, accent `#6c5ce7`
- Light content: `#f0f2f5`
- RemixIcon icons
- Responsive: desktop fixed sidebar, tablet icon-only, mobile hidden + hamburger toggle
- Components: stats cards, tables, buttons (gradient accent), alerts, forms, pagination

---

## 9) Cơ chế game hoá (Hearts, Points, Streak, Achievements)

### 9.1 Hearts

- Mặc định khi tạo user: `hearts = 5`, max = 5
- Hồi offline: `QuizService._calculateRegeneratedHearts()` — `(diff_in_minutes / 10).floor()` tim hồi, update `hearts` và `lastHeartUpdate` (null nếu đầy)
- Đồng bộ khi mở app: `HomeScreen` gọi `syncOfflineHearts()` trong `initState`
- Countdown: `HeartTimer` hiển thị thời gian đến mốc kế tiếp, gọi `regenerateOneHeart()` khi đến 0
- Tiêu: `QuizService.deductHeart()` — transaction trừ 1 + set `lastHeartUpdate = now`
- Mua: `HeartShopSheet` → `QuizService.buyHearts()` — transaction kiểm tra points đủ + max 5, trừ points, cộng hearts

### 9.2 Points & Streak

- Trả lời đúng: tăng `_streak`, cộng `_score` theo multiplier (3/5/10 streak → x3/x5/x10, else x1)
- Trả lời sai: `_streak = 0`, `deductHeart()`
- Kết thúc quiz: `QuizService.finishQuiz()` — cộng `points` + `totalPoints`, tính `dayStreak` (so sánh ngày với `lastLearnDate`, 1 ngày → +1, >1 → reset 1, 0 → giữ)

### 9.3 Achievements

`AchievementService.checkAndClaimAchievements(userData)`:
- 6 thành tựu với điều kiện cụ thể
- Nếu đạt và chưa claim → `FieldValue.arrayUnion(newIds)` + cộng 500 pts mỗi cái
- Được gọi 1 lần sau khi `ProfileScreen` build (`addPostFrameCallback`)

### 9.4 Rank System

| Ngưỡng totalPoints | Title |
|--------------------|-------|
| ≤ 500 | Tân Binh Khởi Nguyên |
| ≤ 2.000 | Dũng Sĩ Tinh Anh |
| ≤ 5.000 | Bậc Thầy Thông Thái |
| ≤ 10.000 | Đại Tướng Chinh Phạt |
| ≤ 20.000 | Chiến Thần Bất Bại |
| > 20.000 | 👑 Tượng Đài Bất Diệt |

---

## 10) Thông báo & Âm thanh

### 10.1 Nhắc học tập hằng ngày

- `ProfileScreen`: switch `isSoundEnabled` (SharedPreferences), CupertinoDatePicker giờ nhắc nhở, nút "XÁC NHẬN" → `NotificationService.scheduleDailyNotification(hour, minute)`
- `NotificationService`: khởi tạo timezone, `zonedSchedule` với channel `daily_reminder_channel_v4`, `matchDateTimeComponents: DateTimeComponents.time`

### 10.2 Âm thanh khi làm bài

- `QuizScreen` và `ProfileScreen` đọc `isSoundEnabled` từ SharedPreferences
- Đúng: `SoundService.playCorrect()` → `assets/sounds/correct.mp3`
- Sai: `SoundService.playWrong()` → `assets/sounds/wrong.mp3`
- Streak milestone: `SoundService.playStreak()` → `assets/sounds/streak.mp3`
- Kết thúc quiz: `SoundService.playFinish()` → `assets/sounds/finish.mp3`

---

## 11) Database Schema (MySQL)

**`backend/sql/admin_schema.sql`:**

```sql
CREATE TABLE admin_users (
    id         INT PRIMARY KEY AUTO_INCREMENT,
    username   VARCHAR(100) NOT NULL UNIQUE,
    password   VARCHAR(255) NOT NULL,  -- bcrypt hash
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- Default: admin / admin
INSERT INTO admin_users (username, password) VALUES
('admin', '$2y$10$1ZZ9Aa4RYNJdnfrMTOSYNeUv14h9vUiPRoNZxxYTcnyzHbxD642YO');

CREATE TABLE learning_stats (
    id            INT PRIMARY KEY AUTO_INCREMENT,
    stat_date     DATE         NOT NULL,
    new_users     INT          DEFAULT 0,
    quizzes_taken INT          DEFAULT 0,
    total_points  INT          DEFAULT 0,
    created_at    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);
```

**Các bảng content (được Flutter app sử dụng, không có trong SQL file này):**
- `topics` (id, title, description, image_path, color)
- `vocabularies` (id, unit_id, word, meaning, pronunciation, type, example_sentence, audio_url)
- `questions` (id, unit_id, type, question_text, correct_answer, options)

---

## 12) Security

### Flutter App
- Firebase Authentication (email/password)
- Firestore Security Rules cần được cấu hình riêng
- **Hardcoded secrets (NGUY HIỂM):**
  - `main.dart`: Gemini API key `AIzaSyDniuZBZtccOg-7raBjySRc-FszYJbo7OU`
  - `otp_service.dart`: Gmail SMTP credentials (`lecheche123456789@gmail.com` / `ssgk zrsa hxxb asez`)
  - `api_service.dart`: Backend base URL `http://192.168.1.40/hisuesl_backend/api/` (có thể đổi IPv4 của mạng Internet)

### Backend PHP
- Session-based auth cho admin panel (`$_SESSION['admin_id']`)
- `password_verify()` bcrypt cho admin
- PDO prepared statements cho tất cả queries (chống SQL injection)
- `htmlspecialchars()` escaping cho mọi output
- CORS `*` trên API endpoints (production nên giới hạn)
- File upload validation: extension whitelist (.csv/.txt), size limit 5MB
- BOM stripping khi import CSV
- Không có CSRF tokens (form admin không có protection)

---

## 13) Lưu ý bảo mật (Production)

1. **Gemini API Key** hardcoded trong `main.dart` — nên chuyển vào environment variables hoặc Cloud Functions
2. **SMTP credentials** hardcoded trong `otp_service.dart` — nên chuyển vào `.env` hoặc dùng backend trung gian
3. **OTP client-side validation** — mã đúng truyền sang `OtpScreen` qua constructor (`actualOtp`) — production nên lưu OTP trên server với expiry
4. **Backend base URL** hardcoded là local IPv4 của mạng Internet — production cần domain/hosted URL
5. **Admin credentials** mặc định `admin`/`admin` — nên đổi password ngay sau khi deploy

---

## 14) Hướng dẫn chạy dự án

### Flutter App

1. Cài Flutter SDK
2. Chạy `flutter pub get`
3. Kết nối Firebase (config + tạo project Firebase, thêm cấu hình cho Android/iOS)
4. Đảm bảo assets tồn tại: `assets/icons/`, `assets/images/`, `assets/sounds/`
5. Cấu hình Gemini API key trong `main.dart` (hoặc biến môi trường)
6. Chạy: `flutter run`

### Backend PHP

1. Cài Apache + PHP + MySQL (VD: XAMPP, WAMP, Laragon)
2. Tạo database `hisuesl_db` trong MySQL
3. Import `backend/sql/admin_schema.sql` trong phpMyAdmin
4. Copy `backend/` vào web root (VD: `htdocs/hisuesl_backend/`)
5. Cấu hình `.env` với credentials MySQL
6. Truy cập Admin Panel: `http://localhost/hisuesl_backend/admin/`
7. Đăng nhập: `admin` / `admin`
8. Cập nhật base URL trong `lib/features/learn/services/api_service.dart` cho đúng IP/domain

---

## 15) Ghi chú về test

`test/widget_test.dart` hiện mang nội dung "counter smoke test" kiểu template mặc định của Flutter, không phản ánh UI thực tế của app (do `main.dart` không phải counter app). Cần cập nhật test theo component thật của dự án.

---

## 16) File Inventory

### Flutter App (44 Dart files)

```
lib/main.dart
lib/core/constants/app_colors.dart
lib/core/theme/app_theme.dart
lib/core/theme/app_shadows.dart
lib/core/theme/app_radius.dart
lib/core/theme/app_spacing.dart
lib/core/theme/app_typography.dart
lib/core/services/notification_service.dart
lib/core/services/sound_service.dart
lib/widgets/app_bottom_sheet.dart
lib/widgets/app_button.dart
lib/widgets/app_stat_pill.dart
lib/widgets/common_button.dart
lib/widgets/custom_snackbar.dart
lib/widgets/custom_textfield.dart
lib/features/auth/screens/login_screen.dart
lib/features/auth/screens/register_screen.dart
lib/features/auth/screens/otp_screen.dart
lib/features/auth/screens/onboarding_screen.dart
lib/features/auth/services/auth_service.dart
lib/features/auth/services/otp_service.dart
lib/features/home/screens/home_screen.dart
lib/features/home/screens/profile_screen.dart
lib/features/home/screens/edit_profile_screen.dart
lib/features/home/widgets/heart_shop_sheet.dart
lib/features/home/services/achievement_service.dart
lib/features/learn/screens/learn_screen.dart
lib/features/learn/screens/flashcard_screen.dart
lib/features/learn/screens/quiz_screen.dart
lib/features/learn/screens/favorites_screen.dart
lib/features/learn/screens/favorite_detail_screen.dart
lib/features/learn/models/topic_model.dart
lib/features/learn/models/vocab_model.dart
lib/features/learn/models/question_model.dart
lib/features/learn/services/api_service.dart
lib/features/learn/services/topic_service.dart
lib/features/learn/services/question_service.dart
lib/features/learn/services/vocab_service.dart
lib/features/learn/services/quiz_service.dart
lib/features/learn/data/mock_data.dart
lib/features/learn/data/mock_quiz_data.dart
lib/features/leaderboard/screens/leaderboard_screen.dart
lib/features/leaderboard/services/leaderboard_service.dart
lib/features/chatbot/screens/hisubot_screen.dart
test/widget_test.dart
```

### Backend PHP (31 files)

```
backend/index.php
backend/.env
backend/.htaccess
backend/config/database.php
backend/sql/admin_schema.sql
backend/controllers/TopicController.php
backend/controllers/VocabularyController.php
backend/controllers/QuestionController.php
backend/models/Topic.php
backend/models/Vocabulary.php
backend/models/Question.php
backend/admin/login.php
backend/admin/logout.php
backend/admin/index.php
backend/admin/export.php
backend/admin/import.php
backend/admin/topics/index.php
backend/admin/topics/create.php
backend/admin/topics/edit.php
backend/admin/topics/delete.php
backend/admin/vocabularies/index.php
backend/admin/vocabularies/create.php
backend/admin/vocabularies/edit.php
backend/admin/questions/index.php
backend/admin/questions/create.php
backend/admin/questions/edit.php
backend/admin/partials/header.php
backend/admin/partials/sidebar.php
backend/admin/partials/footer.php
backend/admin/includes/auth_check.php
backend/admin/assets/style.css
```

### Other

```
plan/upgrade_backend/stage_final_backend_admin.md
pubspec.yaml
```
