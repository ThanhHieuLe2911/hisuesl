import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VocabService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lấy danh sách ID các từ yêu thích của User hiện tại
  Stream<List<String>> getFavoriteVocabIds() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    // Lắng nghe realtime sự thay đổi trong collection 'favorites'
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  // Thêm hoặc Xóa từ yêu thích (Toggle)
  Future<void> toggleFavorite(String vocabId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(vocabId);

    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      // Nếu đã thích -> Xóa (Bỏ thích)
      await docRef.delete();
    } else {
      // Nếu chưa thích -> Thêm vào (Chỉ cần lưu ID là đủ)
      await docRef.set({'addedAt': DateTime.now()});
    }
  }

  // Đánh dấu đã học xong 1 Unit
  Future<void> markUnitAsLearned(int unitId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Dùng arrayUnion để thêm ID vào mảng (không bị trùng lặp)
    await _firestore.collection('users').doc(user.uid).update({
      'learnedUnits': FieldValue.arrayUnion([unitId])
    });
  }
}