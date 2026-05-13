import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hisuesl/core/constants/app_colors.dart';
import 'package:hisuesl/widgets/common_button.dart';
import 'package:hisuesl/widgets/custom_textfield.dart';
import 'package:hisuesl/widgets/custom_snackbar.dart';
import 'package:hisuesl/features/auth/services/otp_service.dart';
import 'package:hisuesl/features/auth/screens/otp_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _isLoading = false;

  // --- LOGIC GỬI OTP THAY VÌ TẠO TÀI KHOẢN NGAY ---
  void _handleRegister() async {
    FocusScope.of(context).unfocus();

    if (_nameCtrl.text.trim().isEmpty) {
      CustomSnackBar.error(context, "Vui lòng nhập tên của bạn!");
      return;
    }
    if (_emailCtrl.text.trim().isEmpty || !_emailCtrl.text.contains("@")) {
      CustomSnackBar.error(context, "Email không hợp lệ!");
      return;
    }
    if (_passCtrl.text.length < 6) {
      CustomSnackBar.error(context, "Mật khẩu phải từ 6 ký tự!");
      return;
    }
    if (_passCtrl.text != _confirmPassCtrl.text) {
      CustomSnackBar.error(context, "Mật khẩu không khớp!");
      return;
    }

    setState(() => _isLoading = true);

    String otpCode = OtpService.generateOtp();
    bool isSent = await OtpService.sendOtpEmail(_emailCtrl.text.trim(), otpCode);

    setState(() => _isLoading = false);

    if (isSent && mounted) {
      CustomSnackBar.success(context, "Đã gửi mã OTP đến email của bạn!");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text.trim(),
            name: _nameCtrl.text.trim(),
            actualOtp: otpCode,
          ),
        ),
      );
    } else if (mounted) {
      CustomSnackBar.error(context, "Không thể gửi email OTP. Vui lòng kiểm tra lại email!");
    }
  }

  // --- UI DƯỚI NÀY GIỮ NGUYÊN 100% CỦA BẠN ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              "Tạo tài khoản mới",
              style: GoogleFonts.dongle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.textMain, height: 1.0),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                "Bắt đầu hành trình học tập ngay thôi!",
                textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dongle(fontSize: 24, color: AppColors.textLight, height: 1.0),
              ),
            ),
            const SizedBox(height: 30),
            CustomTextField(
              label: "Tên hiển thị",
              controller: _nameCtrl,
              icon: Icons.person_rounded,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: "Email",
              controller: _emailCtrl,
              icon: Icons.email_rounded,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: "Mật khẩu",
              controller: _passCtrl,
              icon: Icons.lock_rounded,
              obscureText: true,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: "Nhập lại mật khẩu",
              controller: _confirmPassCtrl,
              icon: Icons.lock_outline_rounded,
              obscureText: true,
            ),
            const SizedBox(height: 40),
            _isLoading
                ? const CircularProgressIndicator(color: AppColors.primary)
                : CommonButton(text: "ĐĂNG KÝ NGAY", onPressed: _handleRegister),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Đã có tài khoản? ", style: GoogleFonts.dongle(fontSize: 24, color: AppColors.textLight)),
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                  child: Text("Đăng nhập", style: GoogleFonts.dongle(fontSize: 24, color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}