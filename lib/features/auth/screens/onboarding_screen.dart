import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hisuesl/core/constants/app_colors.dart';
import 'package:hisuesl/widgets/app_button.dart';
import '../../home/screens/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String? _selectedLevel;
  bool _isLoading = false;

  final List<String> _levels = ['Người mới (A1)', 'Sơ cấp (A2)', 'Trung cấp (B1)', 'Cao cấp (B2)'];

  void _saveAndGoHome() async {
    if (_selectedLevel == null) return;
    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Cập nhật level vào Database
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'level': _selectedLevel,
      });

      if (mounted) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false // Xóa hết lịch sử màn hình trước đó
        );
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        // 1. Tiêu đề dùng Font Dongle
        title: Text(
          "Chọn trình độ",
          style: GoogleFonts.dongle(
            fontSize: 40,
            color: AppColors.textMain,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false, // Ẩn nút back vì đây là màn hình bắt buộc
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
        child: Column(
          children: [
            // 2. Mô tả dùng Font Dongle
            Text(
              "Để HisuESL gợi ý bài học phù hợp nhất cho bạn nhé!",
              textAlign: TextAlign.center,
              style: GoogleFonts.dongle(
                  fontSize: 28,
                  color: AppColors.textLight,
                  height: 1.1
              ),
            ),
            const SizedBox(height: 30),

            // Danh sách các lựa chọn 3D
            Expanded(
              child: ListView.builder(
                itemCount: _levels.length,
                itemBuilder: (ctx, index) {
                  return _build3DOption(_levels[index]);
                },
              ),
            ),

            const SizedBox(height: 20),

            // Nút hoàn thành 3D (Dùng AppButton với disabled/primary variants)
            _isLoading
                ? const CircularProgressIndicator(color: AppColors.primary)
                : (_selectedLevel == null
                    ? AppButton.disabled(text: "HOÀN THÀNH")
                    : AppButton.primary(text: "HOÀN THÀNH", onPressed: _saveAndGoHome)),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- WIDGET CON: Nút lựa chọn 3D ---
  Widget _build3DOption(String text) {
    final isSelected = _selectedLevel == text;

    // Màu sắc và độ cao bóng thay đổi theo trạng thái chọn
    final bgColor = isSelected ? AppColors.primary : Colors.white;
    final textColor = isSelected ? Colors.white : AppColors.textMain;
    final shadowColor = isSelected ? AppColors.primaryShadow : Colors.grey.shade200;
    final double shadowOffset = isSelected ? 2.0 : 6.0; // Đã chọn thì bóng thấp (lún xuống), chưa chọn thì bóng cao (nổi lên)

    return GestureDetector(
      onTap: () => setState(() => _selectedLevel = text),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20), // Khoảng cách giữa các nút
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isSelected ? AppColors.primaryShadow : Colors.grey.shade300,
                width: isSelected ? 0 : 2 // Nếu chọn rồi thì bỏ viền đi cho đẹp
            ),
            // Hiệu ứng bóng 3D cứng
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                offset: Offset(0, shadowOffset),
                blurRadius: 0,
              )
            ]
        ),
        child: Row(
          children: [
            // Text dùng Font Dongle
            Text(
              text,
              style: GoogleFonts.dongle(
                  fontSize: 32,
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  height: 1.0
              ),
            ),
            const Spacer(),
            // Icon check khi được chọn
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle
                ),
                child: const Icon(Icons.check, color: AppColors.primary, size: 20),
              )
            else
              Icon(Icons.circle_outlined, color: Colors.grey.shade300, size: 28),
          ],
        ),
      ),
    );
  }
}