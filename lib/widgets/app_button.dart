import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

/// Reusable AppButton Foundation
///
/// Quy tắc:
/// - Font Dongle cho text
/// - Dùng AppColors cho màu (gamification tokens)
/// - 3D hard shadow style (phong cách HisuESL)
/// - TUYỆT ĐỐI KHÔNG dùng raised/flat Material style
///
/// Variant:
///
///   AppButton.primary(text, onPressed)
///     → background: AppColors.primary, shadow: AppColors.primaryShadow
///
///   AppButton.outlined(text, onPressed)
///     → background: transparent, border: AppColors.primary, text: AppColors.primary
///
///   AppButton.disabled(text)
///     → background: Colors.grey.shade300, shadow: Colors.grey.shade400
///     → onPressed bị ignore
///
/// Ví dụ:
///
///   AppButton.primary(
///     text: "HOÀN THÀNH",
///     onPressed: _saveAndGoHome,
///   )
///
///   AppButton.disabled("HOÀN THÀNH")
///
/// Migration guide:
///   Thay CommonButton(text, onPressed, backgroundColor, shadowColor)
///   → AppButton.primary(text, onPressed)
///
/// Lưu ý:
/// - CommonButton vẫn tiếp tục dùng được song song
/// - AppButton là lớp wrapper dùng design tokens, không thay thế CommonButton
/// - KHÔNG over-engineer ở phase này

enum AppButtonVariant {
  primary,
  outlined,
  disabled,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final double height;
  final double? width;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.height = 56,
    this.width,
    this.isLoading = false,
  });

  /// Primary button: nền xanh, shadow 3D
  factory AppButton.primary({
    required String text,
    VoidCallback? onPressed,
    double height = 56,
    double? width,
    bool isLoading = false,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      variant: AppButtonVariant.primary,
      height: height,
      width: width,
      isLoading: isLoading,
    );
  }

  /// Outlined button: viền xanh, nền trong suốt
  factory AppButton.outlined({
    required String text,
    VoidCallback? onPressed,
    double height = 56,
    double? width,
    bool isLoading = false,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      variant: AppButtonVariant.outlined,
      height: height,
      width: width,
      isLoading: isLoading,
    );
  }

  /// Disabled button: nền xám, không shadow
  factory AppButton.disabled({
    required String text,
    double height = 56,
    double? width,
  }) {
    return AppButton(
      text: text,
      onPressed: null,
      variant: AppButtonVariant.disabled,
      height: height,
      width: width,
    );
  }

  // ─── COLORS PER VARIANT ─────────────────────────────────────────────

  Color get _backgroundColor {
    switch (variant) {
      case AppButtonVariant.primary:
        return AppColors.primary;
      case AppButtonVariant.outlined:
        return Colors.transparent;
      case AppButtonVariant.disabled:
        return Colors.grey.shade300;
    }
  }

  Color get _textColor {
    switch (variant) {
      case AppButtonVariant.primary:
        return Colors.white;
      case AppButtonVariant.outlined:
        return AppColors.primary;
      case AppButtonVariant.disabled:
        return Colors.grey.shade600;
    }
  }

  Color? get _borderColor {
    switch (variant) {
      case AppButtonVariant.outlined:
        return AppColors.primary;
      default:
        return null;
    }
  }

  Color get _shadowColor {
    switch (variant) {
      case AppButtonVariant.primary:
        return AppColors.primaryShadow;
      case AppButtonVariant.outlined:
        return Colors.grey.shade300;
      case AppButtonVariant.disabled:
        return Colors.grey.shade400;
    }
  }

  bool get _hasShadow {
    return variant != AppButtonVariant.disabled;
  }

  // ─── BUILD ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (variant == AppButtonVariant.disabled || isLoading) ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: _borderColor != null
              ? Border.all(color: _borderColor!, width: 2)
              : null,
          boxShadow: _hasShadow
              ? [
                  BoxShadow(
                    color: _shadowColor,
                    offset: const Offset(0, 4),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: _textColor,
                ),
              )
            : Text(
                text.toUpperCase(),
                style: GoogleFonts.dongle(
                  fontSize: 30,
                  color: _textColor,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),
      ),
    );
  }
}
