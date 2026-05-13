import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final IconData icon;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.obscureText = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem nhãn có nên "bay lên" hay không
    // Bay lên khi: Đang được focus HOẶC đã có chữ bên trong
    final bool isFloating = _isFocused || widget.controller.text.isNotEmpty;

    return Stack(
      clipBehavior: Clip.none, // Cho phép nhãn bay ra khỏi khung Container
      children: [
        // 1. CÁI KHUNG 3D (CONTAINER)
        Container(
          height: 64, // Chiều cao cố định
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              // Viền đổi màu khi focus
              color: _isFocused ? AppColors.primary : Colors.grey.shade300,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _isFocused ? AppColors.primaryShadow.withOpacity(0.5) : Colors.grey.shade200,
                offset: const Offset(0, 4), // Bóng đổ 3D
                blurRadius: 0,
              )
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft, // Căn giữa nội dung

          // 2. TEXT FIELD (Nằm bên trong)
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            style: GoogleFonts.dongle(
                fontSize: 28,
                color: AppColors.textMain,
                height: 1.5 // Căn chỉnh dòng cho khớp
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              // Tắt hint mặc định để dùng cái Label tự chế của ta
              contentPadding: const EdgeInsets.only(top: 8, left: 40), // Cách lề trái để né icon
            ),
          ),
        ),

        // 3. ICON (Nằm cố định bên trái)
        Positioned(
          top: 18,
          left: 16,
          child: Icon(
            widget.icon,
            color: _isFocused ? AppColors.primary : Colors.grey.shade400,
            size: 28,
          ),
        ),

        // 4. ANIMATED LABEL (Nhãn biết bay)
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200), // Tốc độ bay (200ms là cực mượt)
          curve: Curves.easeOut, // Hiệu ứng bay nhẹ nhàng
          // Logic vị trí:
          // - Nếu Floating: Bay lên trên nóc (top: -12), thụt vào trái
          // - Nếu Không: Nằm giữa khung (top: 16), thụt vào sâu hơn (để né icon)
          top: isFloating ? -14 : 16,
          left: isFloating ? 20 : 56,

          child: InkWell(
            onTap: () => _focusNode.requestFocus(), // Bấm vào nhãn cũng focus được
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              color: Colors.white, // Nền trắng để che cái viền border bên dưới
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: GoogleFonts.dongle(
                  // Logic style:
                  // - Floating: Chữ nhỏ, màu xanh/đậm
                  // - Không: Chữ to, màu xám nhạt (như hint)
                  fontSize: isFloating ? 22 : 28,
                  fontWeight: isFloating ? FontWeight.bold : FontWeight.normal,
                  color: isFloating
                      ? (_isFocused ? AppColors.primary : AppColors.textMain)
                      : Colors.grey.shade400,
                  height: 1.0,
                ),
                child: Text(widget.label.toUpperCase()),
              ),
            ),
          ),
        ),
      ],
    );
  }
}