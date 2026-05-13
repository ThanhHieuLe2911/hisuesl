import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

/// Reusable BottomSheet components cho toàn app
///
/// Quy tắc:
/// - Dùng AppColors, AppSpacing cho màu/spacing
/// - Font Dongle cho text
/// - KHÔNG over-engineer — chỉ extract phần thật sự dùng chung
///
/// Hai pattern trong app:
/// 1. HeartShopSheet: flexible content, mainAxisSize=min
/// 2. Profile time picker: fixed height (300px), CupertinoDatePicker Expanded
///
/// Phần dùng chung:
///   - Handle bar (size configurable)
///   - Border-radius top chuẩn (xl=32px)
///   - Helper function wrap content
///
/// Phần KHÔNG dùng chung (để mỗi sheet tự quyết định):
///   - Container height
///   - Nội dung bên trong
///   - CTA button
///   - State management
///
/// Migration guide:
///   Thay `showModalBottomSheet(...)` → `AppBottomSheet.show(...)`
///   Thay handle bar inline → `AppBottomSheetHandleBar()`

class AppBottomSheet {
  AppBottomSheet._();

  // ─── HANDLE BAR ──────────────────────────────────────────────────────────

  /// Handle bar chuẩn cho bottom sheet
  ///
  /// Dùng thay thế Container handle bar inline
  ///
  /// Ví dụ:
  ///   AppBottomSheetHandleBar(width: 40, height: 5)
  static Widget handleBar({
    double width = 40,
    double height = 5,
    Color? color,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? Colors.grey.shade300,
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }

  // ─── SHOW HELPER ─────────────────────────────────────────────────────────

  /// Wrapper cho showModalBottomSheet với style chuẩn HisuESL
  ///
  /// Tự động áp:
  ///   - borderRadius top: xl (32px)
  ///   - backgroundColor: white
  ///   - isScrollControlled: true
  ///   - elevation: 0 (dùng shadow riêng trong content)
  ///
  /// Ví dụ:
  ///   AppBottomSheet.show(
  ///     context: context,
  ///     builder: (ctx) => MySheetContent(),
  ///   );
  ///
  /// Hoặc dùng trực tiếp thay vì wrap toàn bộ content:
  ///   showModalBottomSheet(
  ///     context: context,
  ///     isScrollControlled: true,
  ///     backgroundColor: Colors.transparent,
  ///     shape: AppBottomSheet.shape,
  ///     builder: (ctx) => MySheetContent(),
  ///   );
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    bool isScrollControlled = true,
    bool isDismissible = true,
    Color backgroundColor = Colors.transparent,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      backgroundColor: backgroundColor,
      shape: shape,
      builder: builder,
    );
  }

  /// Shape chuẩn cho bottom sheet container
  /// Dùng khi muốn control riêng showModalBottomSheet params
  static const ShapeBorder shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
  );

  // ─── TITLE STYLE ─────────────────────────────────────────────────────────

  /// Title text style chuẩn cho bottom sheet
  ///
  /// Dùng cho:
  ///   - "Cửa hàng Tim" style title
  ///   - "Chọn giờ nhắc nhở" style title
  static TextStyle get titleStyle => GoogleFonts.dongle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.0,
  );
}
