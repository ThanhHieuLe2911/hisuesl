import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  String get _uid {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      throw Exception('User chưa đăng nhập');
    }
    return auth.currentUser!.uid;
  }

  DocumentReference get _userDoc {
    return _db.collection('users').doc(_uid);
  }

  /// Lấy thông tin user hiện tại
  Future<UserData?> getUserData() async {
    try {
      final doc = await _userDoc.get();
      if (!doc.exists) return null;
      
      final data = doc.data() as Map<String, dynamic>;
      return UserData.fromMap(data);
    } catch (e) {
      print('Lỗi lấy user data: $e');
      return null;
    }
  }

  /// Stream user data (cập nhật real-time)
  Stream<UserData?> streamUserData() {
    return _userDoc.snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserData.fromMap(doc.data() as Map<String, dynamic>);
    });
  }
}

/// Model chứa thông tin user cần thiết cho Hisubot
class UserData {
  final String name;
  final String level;
  final List<dynamic> learnedUnits;

  UserData({
    required this.name,
    required this.level,
    required this.learnedUnits,
  });

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      name: map['name'] as String? ?? 'Bạn',
      level: map['level'] as String? ?? 'Chưa chọn',
      learnedUnits: map['learnedUnits'] as List<dynamic>? ?? [],
    );
  }

  /// Lấy mức độ từ level string (A1, A2, B1, B2)
  String get levelTag {
    // Extract A1/A2/B1/B2 from level string like "Người mới (A1)"
    final regex = RegExp(r'\((A[12]|B[12])\)');
    final match = regex.firstMatch(level);
    if (match != null) {
      return match.group(1)!;
    }
    return 'A1'; // Default fallback
  }

  /// Tạo system prompt với user context
  String buildSystemPrompt() {
    return '''Bạn là Hisubot, gia sư tiếng Anh cho ứng dụng học tiếng Anh HisuESL.
Người dùng hiện tại: $name
Trình độ: $level (${levelTag})

QUAN TRỌNG: KHÔNG BAO GIỜ echo lại câu hỏi của người dùng. Chỉ trả lời trực tiếp câu hỏi mà không lặp lại nội dung câu hỏi.

Hướng dẫn:
1. Điều chỉnh độ khó giải thích phù hợp với trình độ $level của người dùng
2. Khi có thể, hãy tham chiếu đến từ vựng và chủ đề người dùng đã học
3. Trả lời bằng tiếng Việt, có thể kèm tiếng Anh khi cần thiết
4. Giải thích ngắn gọn, dễ hiểu, có ví dụ minh họa
5. Sử dụng markdown để định dạng câu trả lời (bold, list, code block nếu cần)
6. Khuyến khích người dùng học tập một cách tích cực''';
  }
}
