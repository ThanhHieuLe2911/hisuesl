import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Design Token: Shadow System
///
/// Quy tắc:
/// - soft: shadow nhẹ cho card flat (future migration)
/// - medium: shadow trung bình cho elevated card
/// - hard: shadow cứng 3D cho button (hiện tại app dùng style này nhiều)
/// - deep: shadow sâu cho dialog/overlay
///
/// Offset & blur convention:
/// - Hard (3D): offset (0, 4) hoặc (0, 6), blurRadius = 0
/// - Soft: offset (0, 2-8), blurRadius = 4-20
/// - Deep: offset (0, 8-10), blurRadius = 10-20
///
/// Migration:
///   Thay BoxShadow(color: Colors.grey.shade200, offset: Offset(0, 4), blurRadius: 0)
///   → AppShadows.hard(color: Colors.grey.shade200)
///   Thay BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 5))
///   → AppShadows.medium(color: Colors.black.withValues(alpha: 0.1))

class AppShadows {
  AppShadows._();

  // ─── BASE FACTORY ──────────────────────────────────────────────────────

  /// Tạo shadow với color + opacity override
  static BoxShadow soft({
    Color? color,
    double opacity = 0.08,
    double offsetY = 4,
    double blurRadius = 8,
    double spreadRadius = 0,
  }) {
    return BoxShadow(
      color: (color ?? Colors.black).withValues(alpha: opacity),
      offset: Offset(0, offsetY),
      blurRadius: blurRadius,
      spreadRadius: spreadRadius,
    );
  }

  static BoxShadow medium({
    Color? color,
    double opacity = 0.10,
    double offsetY = 6,
    double blurRadius = 12,
    double spreadRadius = 0,
  }) {
    return BoxShadow(
      color: (color ?? Colors.black).withValues(alpha: opacity),
      offset: Offset(0, offsetY),
      blurRadius: blurRadius,
      spreadRadius: spreadRadius,
    );
  }

  /// Hard 3D shadow (không blur - tạo khối)
  static BoxShadow hard({
    Color? color,
    double offsetY = 4,
  }) {
    return BoxShadow(
      color: color ?? Colors.grey.shade300,
      offset: Offset(0, offsetY),
      blurRadius: 0,
    );
  }

  static BoxShadow deep({
    Color? color,
    double opacity = 0.15,
    double offsetY = 8,
    double blurRadius = 20,
    double spreadRadius = 0,
  }) {
    return BoxShadow(
      color: (color ?? Colors.black).withValues(alpha: opacity),
      offset: Offset(0, offsetY),
      blurRadius: blurRadius,
      spreadRadius: spreadRadius,
    );
  }

  // ─── PRESET SHADOW LISTS ───────────────────────────────────────────────

  /// Shadow mềm cho card flat (recommended cho design mới)
  static List<BoxShadow> get softShadow => [
    soft(opacity: 0.06, offsetY: 2, blurRadius: 6),
  ];

  /// Shadow mềm nhấn nhẹ
  static List<BoxShadow> get softElevated => [
    soft(opacity: 0.08, offsetY: 4, blurRadius: 8),
  ];

  /// Shadow trung bình cho card elevated
  static List<BoxShadow> get mediumShadow => [
    medium(opacity: 0.10, offsetY: 6, blurRadius: 12),
  ];

  /// Hard 3D shadow (button primary - style hiện tại)
  static List<BoxShadow> get hardShadow => [
    hard(color: AppColors.primaryShadow, offsetY: 4),
  ];

  /// Hard 3D shadow variant với color tùy chỉnh
  static List<BoxShadow> hardShadowOf(Color color) => [
    hard(color: color, offsetY: 4),
  ];

  /// Hard 3D shadow variant với offset lớn hơn (card cao hơn)
  static List<BoxShadow> get hardShadowElevated => [
    hard(color: AppColors.primaryShadow, offsetY: 6),
  ];

  /// Deep shadow cho dialog/overlay
  static List<BoxShadow> get deepShadow => [
    deep(opacity: 0.15, offsetY: 8, blurRadius: 20),
  ];

  /// Deep shadow với màu
  static List<BoxShadow> deepShadowOf(Color color) => [
    deep(opacity: 0.20, offsetY: 10, blurRadius: 20),
  ];

  /// Shadow cho FAB
  static List<BoxShadow> get fabShadow => [
    soft(opacity: 0.20, offsetY: 4, blurRadius: 10),
  ];

  /// Shadow cho avatar
  static List<BoxShadow> get avatarShadow => [
    soft(opacity: 0.15, offsetY: 4, blurRadius: 8),
  ];

  // ─── CARD SHADOW PRESETS ───────────────────────────────────────────────

  /// Card học tập (LearnScreen topic card) - style hiện tại
  static List<BoxShadow> get learnCard => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.15),
      offset: const Offset(0, 8),
      blurRadius: 0,
    ),
  ];

  /// Card yêu thích (FavoritesScreen)
  static List<BoxShadow> get favoriteCard => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.10),
      offset: const Offset(0, 5),
      blurRadius: 10,
    ),
  ];

  /// Card rank/achievement (ProfileScreen)
  static List<BoxShadow> get rankCard => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.10),
      offset: const Offset(0, 10),
      blurRadius: 20,
    ),
  ];

  /// Card streak celebration
  static List<BoxShadow> get streakCard => [
    BoxShadow(
      color: Colors.orange.withValues(alpha: 0.30),
      offset: const Offset(0, 10),
      blurRadius: 20,
    ),
  ];

  /// Chat bubble shadow
  static List<BoxShadow> get chatBubble => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      offset: const Offset(0, 2),
      blurRadius: 4,
    ),
  ];

  /// Input shadow (focus)
  static List<BoxShadow> get inputFocus => [
    BoxShadow(
      color: AppColors.primaryShadow.withValues(alpha: 0.50),
      offset: const Offset(0, 4),
      blurRadius: 0,
    ),
  ];

  /// Action chip shadow
  static List<BoxShadow> get actionChip => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      offset: const Offset(0, 2),
      blurRadius: 4,
    ),
  ];

  /// Bottom sheet shadow
  static List<BoxShadow> get bottomSheet => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      offset: const Offset(0, -4),
      blurRadius: 10,
    ),
  ];

  // ─── BACKWARD COMPATIBLE ALIAS ──────────────────────────────────────────

  /// 3D button shadow - giữ nguyên style hiện tại
  static List<BoxShadow> get primary3D => hardShadow;

  /// Legacy shadow từ code cũ
  static List<BoxShadow> get legacy3DCard => [
    BoxShadow(
      color: Colors.grey.shade200,
      offset: const Offset(0, 8),
      blurRadius: 0,
    ),
  ];

  /// Stat pill shadow
  static List<BoxShadow> get statPill => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      offset: const Offset(0, 2),
      blurRadius: 4,
    ),
  ];

  /// Quiz option shadow
  static List<BoxShadow> get quizOption => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      offset: const Offset(0, 4),
      blurRadius: 10,
    ),
  ];

  // ─── SHADOW DECORATION HELPERS ─────────────────────────────────────────

  /// Tạo BoxDecoration với shadow tùy chỉnh
  static BoxDecoration boxWithShadow({
    required Color backgroundColor,
    required double borderRadius,
    List<BoxShadow>? shadows,
    Color? borderColor,
    double borderWidth = 1.0,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: borderColor != null
          ? Border.all(color: borderColor, width: borderWidth)
          : null,
      boxShadow: shadows ?? mediumShadow,
    );
  }

  /// Card decoration chuẩn (soft style)
  static BoxDecoration cardBox({
    Color backgroundColor = Colors.white,
    double borderRadius = 20,
    Color? borderColor,
    double borderWidth = 1.0,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: borderColor != null
          ? Border.all(color: borderColor, width: borderWidth)
          : null,
      boxShadow: mediumShadow,
    );
  }

  /// Button decoration chuẩn (hard 3D style - hiện tại app dùng)
  static BoxDecoration buttonBox({
    required Color backgroundColor,
    required Color shadowColor,
    double borderRadius = 16,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        hard(color: shadowColor, offsetY: 4),
      ],
    );
  }
}
