import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy Top 20 người dùng có điểm cao nhất
  Stream<QuerySnapshot> getLeaderboard() {
    return _firestore
        .collection('users')
        .orderBy('totalPoints', descending: true) // Sắp xếp giảm dần theo điểm tích lũy
        .limit(20)
        .snapshots();
  }

  // Logic Danh hiệu (Rank Title)
  String getRankTitle(int totalPoints) {
    if (totalPoints <= 500) return "Tân Binh Khởi Nguyên";
    if (totalPoints <= 2000) return "Dũng Sĩ Tinh Anh";
    if (totalPoints <= 5000) return "Bậc Thầy Thông Thái";
    if (totalPoints <= 10000) return "Đại Tướng Chinh Phạt";
    if (totalPoints <= 20000) return "Chiến Thần Bất Bại";
    return "👑 Tượng Đài Bất Diệt";
  }
}