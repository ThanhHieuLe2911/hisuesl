import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy user hiện tại
  User? get currentUser => _auth.currentUser;

  // Đăng ký (CODE CŨ - GIỮ NGUYÊN)
  Future<User?> register(String email, String password, String name) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'uid': credential.user!.uid,
          'email': email,
          'name': name,
          'createdAt': DateTime.now(),
          'level': 'Chưa chọn',
          'hearts': 5,
          'points': 0,
          // Thêm trường avatar mặc định để tránh null sau này
          'avatarBase64': null,
        });
      }
      return credential.user;
    } catch (e) {
      print("Lỗi Đăng ký: $e");
      return null;
    }
  }

  // Đăng nhập (CODE CŨ - GIỮ NGUYÊN)
  Future<User?> login(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print("Lỗi Đăng nhập: $e");
      return null;
    }
  }

  // Đăng xuất (CODE CŨ - GIỮ NGUYÊN)
  Future<void> logout() async {
    await _auth.signOut();
  }

  // --- TÍNH NĂNG MỚI: CẬP NHẬT HỒ SƠ ---
  Future<String> updateUserProfile({required String name, String? base64Image}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return "User not found";

      Map<String, dynamic> updateData = {'name': name};

      // Nếu có ảnh mới thì cập nhật, không thì thôi
      if (base64Image != null) {
        updateData['avatarBase64'] = base64Image;
      }

      await _firestore.collection('users').doc(user.uid).update(updateData);
      return "Success";
    } catch (e) {
      return e.toString();
    }
  }

  // --- TÍNH NĂNG MỚI: ĐỔI MẬT KHẨU ---
  Future<String> changePassword(String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return "User not found";
      if (user.email == null) return "Email not found";

      // 1. Firebase yêu cầu xác thực lại (Re-authenticate) trước khi đổi pass
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // 2. Đổi mật khẩu
      await user.updatePassword(newPassword);
      return "Success";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') return "Mật khẩu hiện tại không đúng";
      return e.message ?? "Lỗi đổi mật khẩu";
    } catch (e) {
      return e.toString();
    }
  }
}