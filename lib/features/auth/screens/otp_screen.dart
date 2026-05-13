import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hisuesl/core/constants/app_colors.dart';
import 'package:hisuesl/features/auth/services/auth_service.dart';
import 'package:hisuesl/widgets/common_button.dart';
import 'package:hisuesl/widgets/custom_textfield.dart';
import 'package:hisuesl/widgets/custom_snackbar.dart';
import 'onboarding_screen.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String password;
  final String name;
  final String actualOtp; // Mã OTP thật hệ thống đã gửi

  const OtpScreen({
    super.key,
    required this.email,
    required this.password,
    required this.name,
    required this.actualOtp,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpCtrl = TextEditingController();
  bool _isLoading = false;

  void _verifyAndRegister() async {
    FocusScope.of(context).unfocus();

    if (_otpCtrl.text.trim() != widget.actualOtp) {
      CustomSnackBar.error(context, "Mã OTP không chính xác, vui lòng thử lại!");
      return;
    }

    setState(() => _isLoading = true);

    final user = await AuthService().register(
      widget.email,
      widget.password,
      widget.name,
    );

    setState(() => _isLoading = false);

    if (user != null && mounted) {
      CustomSnackBar.success(context, "Đăng ký tài khoản thành công!");

      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
              (route) => false,
        );
      });
    } else if (mounted) {
      CustomSnackBar.error(context, "Đăng ký thất bại (Email đã tồn tại hoặc lỗi mạng)");
    }
  }

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
            const SizedBox(height: 20),
            Text(
              "Xác thực Email",
              style: GoogleFonts.dongle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.textMain, height: 1.0),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                "Nhập mã 6 số đã được gửi đến:\n${widget.email}",
                textAlign: TextAlign.center,
                style: GoogleFonts.dongle(fontSize: 26, color: AppColors.textLight, height: 1.1),
              ),
            ),
            const SizedBox(height: 40),
            CustomTextField(
              label: "Mã OTP",
              controller: _otpCtrl,
              icon: Icons.security_rounded,
            ),
            const SizedBox(height: 40),
            _isLoading
                ? const CircularProgressIndicator(color: AppColors.primary)
                : CommonButton(text: "XÁC NHẬN", onPressed: _verifyAndRegister),
          ],
        ),
      ),
    );
  }
}