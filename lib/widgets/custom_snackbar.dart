import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

/// Reusable Custom SnackBar cho toàn app
///
/// Quy tắc:
/// - Dùng AppColors cho màu
/// - Font Dongle cho text
/// - Floating behavior, không elevation
/// - Chỉ cần gọi: CustomSnackBar.show(context, message, isError: bool)
///
/// Ví dụ:
///   CustomSnackBar.show(context, "Đăng nhập thành công!", isError: false);
///   CustomSnackBar.show(context, "Vui lòng nhập đầy đủ thông tin!");
///   CustomSnackBar.show(context, "Email không hợp lệ!", type: SnackBarType.error);
///
/// Migration guide:
///   Thay _showCustomSnackBar("...") → CustomSnackBar.show(context, "...")

enum SnackBarType {
  success,
  error,
  info,
}

class CustomSnackBar {
  CustomSnackBar._();

  // ─── API CHÍNH ──────────────────────────────────────────────────────

  /// Hiển thị SnackBar tùy chỉnh
  ///
  /// [message] - Nội dung hiển thị
  /// [isError] - true = error (đỏ), false = success (xanh dương primary)
  /// Hoặc dùng [type] để chỉ định rõ loại
  static void show(
    BuildContext context,
    String message, {
    bool isError = true,
    SnackBarType? type,
    Duration duration = const Duration(seconds: 3),
  }) {
    final SnackBarType resolvedType = type ?? (isError ? SnackBarType.error : SnackBarType.success);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: _SnackBarContent(
          message: message,
          type: resolvedType,
        ),
      ),
    );
  }

  /// Hiển thị SnackBar thành công (màu xanh primary)
  static void success(BuildContext context, String message, {Duration? duration}) {
    show(context, message, isError: false, duration: duration ?? const Duration(seconds: 3));
  }

  /// Hiển thị SnackBar lỗi (màu đỏ)
  static void error(BuildContext context, String message, {Duration? duration}) {
    show(context, message, isError: true, duration: duration ?? const Duration(seconds: 3));
  }

  /// Hiển thị SnackBar thông tin (màu info)
  static void info(BuildContext context, String message, {Duration? duration}) {
    show(context, message, type: SnackBarType.info, duration: duration ?? const Duration(seconds: 3));
  }
}

// ─── INTERNAL WIDGET ────────────────────────────────────────────────────

class _SnackBarContent extends StatelessWidget {
  final String message;
  final SnackBarType type;

  const _SnackBarContent({
    required this.message,
    required this.type,
  });

  Color get _backgroundColor {
    switch (type) {
      case SnackBarType.success:
        return AppColors.primary;
      case SnackBarType.error:
        return AppColors.error;
      case SnackBarType.info:
        return AppColors.info;
    }
  }

  Color get _shadowColor {
    switch (type) {
      case SnackBarType.success:
        return AppColors.primary;
      case SnackBarType.error:
        return AppColors.error;
      case SnackBarType.info:
        return AppColors.info;
    }
  }

  IconData get _icon {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_circle_outline_rounded;
      case SnackBarType.error:
        return Icons.error_outline_rounded;
      case SnackBarType.info:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _shadowColor.withValues(alpha: 0.30),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            _icon,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.dongle(
                fontSize: 26,
                color: Colors.white,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
