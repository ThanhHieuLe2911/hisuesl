import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hisuesl/core/constants/app_colors.dart';
import 'package:hisuesl/features/auth/services/auth_service.dart';
import 'package:hisuesl/features/home/screens/home_screen.dart';
import 'package:hisuesl/widgets/common_button.dart';
import 'package:hisuesl/widgets/custom_textfield.dart';
import 'package:hisuesl/widgets/custom_snackbar.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.trim().isEmpty) {
      CustomSnackBar.error(context, "Vui lòng nhập đầy đủ Email và Mật khẩu!");
      return;
    }

    setState(() => _isLoading = true);
    final user = await AuthService().login(_emailCtrl.text.trim(), _passCtrl.text.trim());
    setState(() => _isLoading = false);

    if (user != null && mounted) {
      CustomSnackBar.success(context, "Đăng nhập thành công!");

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        }
      });
    } else if (mounted) {
      CustomSnackBar.error(context, "Email hoặc mật khẩu không đúng!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Đăng nhập",
          style: GoogleFonts.dongle(
            fontSize: 40,
            color: AppColors.textMain,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Navigator.canPop(context)
            ? IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        )
            : null,
      ),
      body: SingleChildScrollView(
        // Thêm padding bottom để tránh bị sát cạnh dưới quá khi bàn phím hiện lên
        padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // --- MASCOT ---
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.pets_rounded, size: 60, color: AppColors.primary),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Chào mừng trở lại!",
              style: GoogleFonts.dongle(
                  fontSize: 32,
                  color: AppColors.textMain,
                  fontWeight: FontWeight.bold
              ),
            ),

            const SizedBox(height: 40), // Tăng khoảng cách một chút cho thoáng

            // --- INPUT FIELDS ---
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

            const SizedBox(height: 40),

            // --- NÚT ĐĂNG NHẬP ---
            _isLoading
                ? const CircularProgressIndicator(color: AppColors.primary)
                : CommonButton(
              text: "ĐĂNG NHẬP",
              onPressed: _handleLogin,
            ),

            // Khoảng cách hợp lý trước footer sau khi xóa nút Google
            const SizedBox(height: 40),

            // --- FOOTER ---
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                    "Chưa có tài khoản? ",
                    style: GoogleFonts.dongle(fontSize: 24, color: AppColors.textLight)
                ),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      "Đăng ký ngay",
                      style: GoogleFonts.dongle(
                          fontSize: 24,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}