import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Kiểm tra Tim trước khi vào thi & Đồng bộ tim
  Future<bool> checkHeartAvailability() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return false;

    int currentHearts = doc.data()?['hearts'] ?? 0;

    // Tự động đồng bộ tim nếu có thời gian chờ offline
    if (currentHearts < 5) {
      currentHearts = await _calculateRegeneratedHearts(doc);
    }

    return currentHearts > 0;
  }

  // 2. Logic Hồi tim Offline (Khi mở lại App sau một khoảng thời gian)
  Future<int> _calculateRegeneratedHearts(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    int hearts = data['hearts'] ?? 0;
    Timestamp? lastUpdate = data['lastHeartUpdate'];

    if (lastUpdate == null || hearts >= 5) return hearts;

    final diff = DateTime.now().difference(lastUpdate.toDate());
    int heartsRecovered = (diff.inMinutes / 10).floor();

    if (heartsRecovered > 0) {
      int newHearts = (hearts + heartsRecovered).clamp(0, 5);
      await _firestore.collection('users').doc(doc.id).update({
        'hearts': newHearts,
        'lastHeartUpdate': newHearts < 5 ? DateTime.now() : null
      });
      return newHearts;
    }
    return hearts;
  }

  // 3. HÀM QUAN TRỌNG: Hồi 1 tim khi đồng hồ đếm ngược về 0
  Future<void> regenerateOneHeart() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('users').doc(user.uid);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      int currentHearts = snapshot.data()?['hearts'] ?? 0;

      if (currentHearts < 5) {
        int nextHearts = currentHearts + 1;
        transaction.update(docRef, {
          'hearts': nextHearts,
          // Nếu vẫn chưa đủ 5 tim, reset mốc 10 phút mới ngay lập tức
          'lastHeartUpdate': nextHearts < 5 ? DateTime.now() : null
        });
      }
    });
  }

  // 4. MUA TIM BẰNG ĐIỂM
  Future<String> buyHearts(int cost, int amount) async {
    final user = _auth.currentUser;
    if (user == null) return "Lỗi người dùng";

    final docRef = _firestore.collection('users').doc(user.uid);

    try {
      return await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return "Lỗi dữ liệu";

        int currentPoints = snapshot.data()?['points'] ?? 0;
        int currentHearts = snapshot.data()?['hearts'] ?? 0;

        // Kiểm tra Max Tim
        if (currentHearts >= 5) {
          return "Tim đã đầy rồi!";
        }

        // Kiểm tra Điểm
        if (currentPoints < cost) {
          return "Bạn chưa đủ điểm!";
        }

        // Tính toán
        int newHearts = (currentHearts + amount).clamp(0, 5);
        int newPoints = currentPoints - cost;

        // --- LOGIC BẢO LƯU THỜI GIAN ---
        // Lấy mốc thời gian cũ
        dynamic lastHeartUpdate = snapshot.data()?['lastHeartUpdate'];

        // Nếu sau khi mua tim vẫn < 5: Giữ nguyên mốc cũ (để đồng hồ chạy tiếp)
        // Trừ khi mốc cũ là null (trường hợp lạ) thì mới set now
        if (newHearts < 5) {
          lastHeartUpdate ??= DateTime.now();
        } else {
          // Nếu tim đầy (>=5): Xóa mốc thời gian
          lastHeartUpdate = null;
        }

        transaction.update(docRef, {
          'points': newPoints,
          'hearts': newHearts,
          'lastHeartUpdate': lastHeartUpdate
        });

        return "success"; // Trả về chuỗi success để UI biết là thành công
      });
    } catch (e) {
      return "Giao dịch thất bại: $e";
    }
  }

  // 5. Đồng bộ tim ngay khi vừa mở App (HomeScreen initState)
  Future<void> syncOfflineHearts() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) await _calculateRegeneratedHearts(doc);
  }

  // 6. Trừ tim (Khi trả lời sai)
  Future<void> deductHeart() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final docRef = _firestore.collection('users').doc(user.uid);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      int currentHearts = snapshot.data()?['hearts'] ?? 0;
      if (currentHearts > 0) {
        transaction.update(docRef, {
          'hearts': currentHearts - 1,
          'lastHeartUpdate': DateTime.now(), // Bắt đầu đếm 10 phút từ đây
        });
      }
    });
  }

  // 7. Kết thúc bài thi: Cộng điểm & Streak (ĐÃ CẬP NHẬT LOGIC LEADERBOARD)
  Future<void> finishQuiz(int pointsEarned, int unitId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final docRef = _firestore.collection('users').doc(user.uid);

    final now = DateTime.now();

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;
      int currentPoints = data['points'] ?? 0;
      // Lấy tổng điểm tích lũy (nếu chưa có thì bằng 0)
      int totalPoints = data['totalPoints'] ?? 0;
      int currentStreak = data['dayStreak'] ?? 0;

      // Lấy ngày học cuối (Convert sang Local để khớp với giờ điện thoại)
      Timestamp? lastLearnTs = data['lastLearnDate'];
      DateTime? lastLearnDate = lastLearnTs?.toDate().toLocal();

      // Tính toán Streak mới
      int newStreak = currentStreak;

      if (lastLearnDate == null) {
        // Trường hợp học bài đầu tiên trong đời
        newStreak = 1;
      } else {
        // So sánh theo ngày lịch (bỏ qua giờ phút giây)
        final todayDate = DateTime(now.year, now.month, now.day);
        final lastDate = DateTime(lastLearnDate.year, lastLearnDate.month, lastLearnDate.day);

        final difference = todayDate.difference(lastDate).inDays;

        if (difference == 0) {
          newStreak = currentStreak;
        } else if (difference == 1) {
          newStreak = currentStreak + 1;
        } else {
          newStreak = 1;
        }
      }

      transaction.update(docRef, {
        'points': currentPoints + pointsEarned, // Điểm tiêu xài
        'totalPoints': totalPoints + pointsEarned, // Điểm tích lũy (đua top)
        'dayStreak': newStreak,
        'lastLearnDate': now,
        'learnedUnits': FieldValue.arrayUnion([unitId]),
      });
    });
  }
}