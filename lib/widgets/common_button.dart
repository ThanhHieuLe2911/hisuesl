import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color shadowColor;
  final double height;
  final double width;

  const CommonButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = AppColors.primary,
    this.shadowColor = AppColors.primaryShadow, // Mặc định bóng đậm hơn nền
    this.height = 56,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {}, // Có thể thêm hiệu ứng nhún xuống ở đây sau này
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          // Tạo hiệu ứng 3D bằng bóng đổ cứng (không blur)
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              offset: const Offset(0, 4), // Bóng đổ xuống dưới 4px
              blurRadius: 0, // Không làm mờ -> tạo khối cứng
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          text.toUpperCase(),
          style: GoogleFonts.dongle( // Dùng font Dongle
            fontSize: 30, // Font Dongle cần size to
            color: Colors.white,
            fontWeight: FontWeight.bold,
            height: 1.0, // Căn chỉnh dòng cho font Dongle
          ),
        ),
      ),
    );
  }
}