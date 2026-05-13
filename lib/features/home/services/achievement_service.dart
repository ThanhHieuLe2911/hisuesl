import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Model đơn giản cho Thành tựu
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int rewardPoints;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.rewardPoints = 500,
  });
}

class AchievementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- DANH SÁCH THÀNH TỰU (Cấu hình tại đây) ---
  final List<Achievement> allAchievements = [
    Achievement(
      id: 'streak_3',
      title: 'Khởi Động',
      description: 'Đạt chuỗi 3 ngày liên tiếp',
      icon: Icons.local_fire_department,
      color: Colors.orange,
    ),
    Achievement(
      id: 'streak_7',
      title: 'Kiên Trì',
      description: 'Đạt chuỗi 7 ngày liên tiếp',
      icon: Icons.whatshot,
      color: Colors.red,
    ),
    Achievement(
      id: 'points_1000',
      title: 'Triệu Phú',
      description: 'Tích lũy 1000 điểm',
      icon: Icons.diamond,
      color: Colors.blue,
    ),
    Achievement(
      id: 'learned_5',
      title: 'Học Giả',
      description: 'Hoàn thành 5 bài học',
      icon: Icons.school,
      color: Colors.green,
    ),
    Achievement(
      id: 'rank_pro',
      title: 'Tinh Anh',
      description: 'Đạt mốc 2000 điểm tổng',
      icon: Icons.military_tech,
      color: Colors.amber,
    ),
    Achievement(
      id: 'streak_30',
      title: 'Huyền Thoại',
      description: 'Chuỗi 30 ngày bất bại',
      icon: Icons.auto_awesome,
      color: Colors.purple,
    ),
  ];

  // --- HÀM KIỂM TRA VÀ NHẬN THƯỞNG ---
  // Trả về tên các thành tựu vừa mới mở khóa để hiển thị thông báo
  Future<List<String>> checkAndClaimAchievements(Map<String, dynamic> userData) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    List<String> unlockedNames = [];
    List<String> newClaimedIds = [];

    // Lấy danh sách đã nhận (nếu chưa có thì là rỗng)
    List<dynamic> claimedRaw = userData['achievements'] ?? [];
    List<String> claimed = claimedRaw.map((e) => e.toString()).toList();

    // Lấy thông số user
    int streak = userData['dayStreak'] ?? 0;
    int totalPoints = userData['totalPoints'] ?? 0;
    List learnedUnits = userData['learnedUnits'] ?? [];

    // --- LOGIC KIỂM TRA ĐIỀU KIỆN ---
    for (var ach in allAchievements) {
      bool isConditionMet = false;

      // Check từng loại điều kiện
      if (ach.id == 'streak_3' && streak >= 3) isConditionMet = true;
      if (ach.id == 'streak_7' && streak >= 7) isConditionMet = true;
      if (ach.id == 'streak_30' && streak >= 30) isConditionMet = true;
      if (ach.id == 'points_1000' && totalPoints >= 1000) isConditionMet = true;
      if (ach.id == 'rank_pro' && totalPoints >= 2000) isConditionMet = true;
      if (ach.id == 'learned_5' && learnedUnits.length >= 5) isConditionMet = true;

      // Nếu đạt điều kiện VÀ CHƯA NHẬN -> Thêm vào danh sách cần update
      if (isConditionMet && !claimed.contains(ach.id)) {
        newClaimedIds.add(ach.id);
        unlockedNames.add(ach.title);
      }
    }

    // --- NẾU CÓ THÀNH TỰU MỚI -> UPDATE FIRESTORE ---
    if (newClaimedIds.isNotEmpty) {
      int totalReward = newClaimedIds.length * 500; // Mỗi cái 500 điểm

      await _firestore.collection('users').doc(user.uid).update({
        'achievements': FieldValue.arrayUnion(newClaimedIds), // Thêm ID vào mảng đã nhận
        'points': FieldValue.increment(totalReward),          // Cộng điểm tiêu
        'totalPoints': FieldValue.increment(totalReward),     // Cộng điểm rank
      });
    }

    return unlockedNames;
  }
}