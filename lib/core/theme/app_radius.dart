import 'package:flutter/material.dart';

/// Design Token: Radius / Border Radius System
///
/// Quy tắc:
/// - Scale gọn: small → medium → large → xl → round
/// - Dựa trên giá trị thực tế trong codebase:
///   12px  → radiusSmall (pill/tag nhỏ, action chip)
///   16px  → radiusMedium (button, input, card nhỏ, quiz option)
///   20px  → radiusMediumLarge (card trung bình, pill stat)
///   24px  → radiusLarge (dialog, card lớn, quiz result, result sheet)
///   30px  → radiusHeader (profile header gradient)
///   32px  → radiusXL (bottom sheet, flashcard, finish dialog)
///   999   → radiusRound (circle avatar, FAB)
///
/// Migration:
///   Thay BorderRadius.circular(16) → AppRadius.medium
///   Thay BorderRadius.circular(24) → AppRadius.large

class AppRadius {
  AppRadius._();

  // ─── SCALE ─────────────────────────────────────────────────────────────

  /// 8px - Rounded nhẹ (placeholder / future use)
  static const double none = 8.0;

  /// 12px - Pill nhỏ, tag, action chip, text badge
  static const double small = 12.0;

  /// 16px - Button, input field, quiz option, card nhỏ
  static const double medium = 16.0;

  /// 20px - Card trung bình, stat pill
  static const double mediumLarge = 20.0;

  /// 24px - Dialog, card lớn, quiz result, quiz result sheet
  static const double large = 24.0;

  /// 30px - Header gradient (profile header)
  static const double header = 30.0;

  /// 32px - Bottom sheet, flashcard, finish dialog, onboarding option
  static const double xl = 32.0;

  /// 40px - Flashcard lớn (legacy, giữ tương thích)
  static const double flashcard = 40.0;

  /// Circle - Avatar, FAB, round button
  static const double round = 999.0;

  // ─── BORDERRADIUS HELPERS ──────────────────────────────────────────────

  static BorderRadius radiusSmall = BorderRadius.circular(small);
  static BorderRadius radiusMedium = BorderRadius.circular(medium);
  static BorderRadius radiusMediumLarge = BorderRadius.circular(mediumLarge);
  static BorderRadius radiusLarge = BorderRadius.circular(large);
  static BorderRadius radiusHeader = BorderRadius.circular(header);
  static BorderRadius radiusXl = BorderRadius.circular(xl);
  static BorderRadius radiusRound = BorderRadius.circular(round);

  /// BorderRadius tùy chỉnh
  static BorderRadius custom(double value) => BorderRadius.circular(value);

  /// BorderRadius.only với giá trị tùy chỉnh
  static BorderRadius only({
    double? topLeft,
    double? topRight,
    double? bottomLeft,
    double? bottomRight,
  }) {
    return BorderRadius.only(
      topLeft: Radius.circular(topLeft ?? medium),
      topRight: Radius.circular(topRight ?? medium),
      bottomLeft: Radius.circular(bottomLeft ?? medium),
      bottomRight: Radius.circular(bottomRight ?? medium),
    );
  }

  /// Bottom sheet: top-left và top-right bo tròn, bottom-left/right vuông
  static BorderRadius bottomSheet() {
    return BorderRadius.only(
      topLeft: Radius.circular(xl),
      topRight: Radius.circular(xl),
      bottomLeft: Radius.circular(0),
      bottomRight: Radius.circular(0),
    );
  }

  /// Chat bubble: user (bo phải dưới), bot (bo trái dưới)
  static BorderRadius bubbleUser() {
    return BorderRadius.only(
      topLeft: Radius.circular(large),
      topRight: Radius.circular(large),
      bottomLeft: Radius.circular(small),
      bottomRight: Radius.circular(large),
    );
  }

  static BorderRadius bubbleBot() {
    return BorderRadius.only(
      topLeft: Radius.circular(large),
      topRight: Radius.circular(large),
      bottomLeft: Radius.circular(large),
      bottomRight: Radius.circular(small),
    );
  }

  /// Pill shape (trái tim/hearts pill)
  static BorderRadius pill() {
    return BorderRadius.circular(round);
  }

  // ─── ALIAS BACKWARD COMPATIBLE ─────────────────────────────────────────

  /// Legacy alias - giữ tương thích với code cũ
  static const double buttonRadius = medium;       // 16
  static const double inputRadius = medium;       // 16
  static const double cardRadius = mediumLarge;    // 20
  static const double dialogRadius = large;        // 24
  static const double bottomSheetRadius = xl;      // 32
  static const double flashcardRadius = xl;        // 32 (code cũ dùng 32)
  static const double quizOptionRadius = medium;   // 16
  static const double statPillRadius = mediumLarge;// 20
  static const double achievementRadius = medium;  // 16

  // ─── RADIUS PRESETS CHO DECORATION ─────────────────────────────────────

  /// Button decoration radius
  static BoxDecoration buttonDecoration({
    required Color backgroundColor,
    Color? shadowColor,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(medium),
      boxShadow: [
        BoxShadow(
          color: shadowColor ?? Colors.black.withValues(alpha: 0.15),
          offset: const Offset(0, 4),
          blurRadius: 0,
        ),
      ],
    );
  }

  /// Card decoration radius
  static BoxDecoration cardDecoration({
    Color backgroundColor = Colors.white,
    double radius = mediumLarge,
    Color? borderColor,
    double borderWidth = 1.0,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(radius),
      border: borderColor != null
          ? Border.all(color: borderColor, width: borderWidth)
          : null,
    );
  }

  /// Dialog decoration radius
  static BoxDecoration dialogDecoration({double radius = large}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  /// Bottom sheet decoration radius
  static BoxDecoration bottomSheetDecoration({double radius = xl}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(radius),
        topRight: Radius.circular(radius),
      ),
    );
  }

  /// Flashcard decoration radius
  static BoxDecoration flashcardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(xl),
      border: Border.all(color: Colors.grey.shade100, width: 2),
    );
  }

  /// Stat pill decoration radius
  static BoxDecoration statPillDecoration({
    required Color backgroundColor,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(mediumLarge),
      border: borderColor != null
          ? Border.all(color: borderColor, width: 2)
          : null,
    );
  }

  /// Circle decoration
  static BoxDecoration circleDecoration({
    required Color backgroundColor,
    Color? borderColor,
    double borderWidth = 2.0,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      shape: BoxShape.circle,
      border: borderColor != null
          ? Border.all(color: borderColor, width: borderWidth)
          : null,
    );
  }
}
