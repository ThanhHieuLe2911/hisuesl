import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Design Token: Typography System
///
/// Quy tắc:
/// - Font chủ đạo: Dongle (thương hiệu HisuESL - KHÔNG thay đổi)
/// - Scale dựa trên Dongle, giữ cá tính playful/professional
/// - Font phụ RobotoMono dùng cho code snippet (chatbot markdown)
/// - Scale gọn: display > h1 > h2 > h3 > title > bodyLarge > body > label > caption > button > stat
/// - Tất cả style đều dùng GoogleFonts.xxx() với factory methods
///
/// Cách dùng:
///   import 'package:hisuesl/core/theme/app_typography.dart';
///   Text('Hello', style: AppTypography.h2)
///
/// Migration guide:
///   Phase sau: thay AppColors.textMain → AppColors.textPrimary
///              thay AppColors.textLight → AppColors.textSecondary

class AppTypography {
  AppTypography._();

  // ─── BASE FACTORY ────────────────────────────────────────────────────────

  static TextStyle _dongle({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double height = 1.0,
    double? letterSpacing,
    FontStyle fontStyle = FontStyle.normal,
  }) {
    return GoogleFonts.dongle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.textPrimary,
      height: height,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
    );
  }

  // ─── DISPLAY ─────────────────────────────────────────────────────────────
  // Dùng cho: tiêu đề lớn nhất trang, splash, celebration

  static TextStyle display({Color? color}) => _dongle(
    fontSize: 72,
    fontWeight: FontWeight.bold,
    color: color,
    height: 0.9,
    letterSpacing: -0.5,
  );

  // ─── HEADINGS ───────────────────────────────────────────────────────────
  // h1: AppBar title, Onboarding title
  // h2: Section heading, dialog title
  // h3: Card title, item title

  static TextStyle h1({Color? color}) => _dongle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: color,
    height: 1.0,
  );

  static TextStyle h2({Color? color}) => _dongle(
    fontSize: 38,
    fontWeight: FontWeight.bold,
    color: color,
    height: 1.0,
  );

  static TextStyle h3({Color? color}) => _dongle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: color,
    height: 1.0,
  );

  // ─── TITLE ───────────────────────────────────────────────────────────────
  // Dùng cho: subtitle section, card heading nhỏ hơn h3

  static TextStyle title({Color? color}) => _dongle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: color,
    height: 1.0,
  );

  static TextStyle titleMedium({Color? color}) => _dongle(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: color,
    height: 1.0,
  );

  // ─── BODY ────────────────────────────────────────────────────────────────
  // bodyLarge: vocab word (flashcard front), quiz question
  // body: body text, description

  static TextStyle bodyLarge({Color? color}) => _dongle(
    fontSize: 24,
    fontWeight: FontWeight.normal,
    color: color,
    height: 1.1,
  );

  static TextStyle body({Color? color}) => _dongle(
    fontSize: 22,
    fontWeight: FontWeight.normal,
    color: color,
    height: 1.1,
  );

  // ─── LABEL ───────────────────────────────────────────────────────────────
  // Dùng cho: nhãn phụ, subtitle item, tag

  static TextStyle label({Color? color}) => _dongle(
    fontSize: 20,
    fontWeight: FontWeight.normal,
    color: color,
    height: 1.0,
  );

  static TextStyle labelBold({Color? color}) => _dongle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: color,
    height: 1.0,
  );

  // ─── CAPTION ─────────────────────────────────────────────────────────────
  // Dùng cho: ghi chú nhỏ, placeholder text, sub-label

  static TextStyle caption({Color? color}) => _dongle(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: color,
    height: 1.0,
  );

  static TextStyle captionBold({Color? color}) => _dongle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: color,
    height: 1.0,
  );

  // ─── BUTTON ──────────────────────────────────────────────────────────────
  // Dùng cho: text trong button (UPPERCASE)
  // Dongle button: fontSize 30 ≈ visual 18-20px

  static TextStyle button({Color? color}) => _dongle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: color ?? Colors.white,
    height: 1.0,
    letterSpacing: 0.5,
  );

  static TextStyle buttonSmall({Color? color}) => _dongle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: color ?? Colors.white,
    height: 1.0,
    letterSpacing: 0.5,
  );

  // ─── STAT ─────────────────────────────────────────────────────────────────
  // Dùng cho: số liệu trong pill (hearts/points/streak), rank number

  static TextStyle stat({Color? color}) => _dongle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: color,
    height: 1.0,
  );

  static TextStyle statLarge({Color? color}) => _dongle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: color,
    height: 1.0,
  );

  static TextStyle statSmall({Color? color}) => _dongle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: color,
    height: 1.0,
  );

  // ─── VOCAB / FLASHCARD ─────────────────────────────────────────────────────
  // Dùng riêng cho flashcard để tách khỏi heading scale

  static TextStyle vocabWord({Color? color}) => _dongle(
    fontSize: 70,
    fontWeight: FontWeight.bold,
    color: color ?? AppColors.primary,
    height: 1.0,
  );

  static TextStyle vocabMeaning({Color? color}) => _dongle(
    fontSize: 55,
    fontWeight: FontWeight.bold,
    color: color ?? AppColors.textPrimary,
    height: 1.0,
  );

  static TextStyle vocabPronunciation({Color? color}) => TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.normal,
    fontStyle: FontStyle.italic,
    color: color ?? Colors.grey,
    height: 1.0,
  );

  static TextStyle vocabExample({Color? color}) => _dongle(
    fontSize: 30,
    fontWeight: FontWeight.normal,
    color: color ?? Colors.grey.shade600,
    height: 1.2,
  );

  // ─── QUIZ ─────────────────────────────────────────────────────────────────

  static TextStyle quizQuestion({Color? color}) => _dongle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: color ?? AppColors.textPrimary,
    height: 1.1,
  );

  static TextStyle quizOption({Color? color}) => _dongle(
    fontSize: 26,
    fontWeight: FontWeight.normal,
    color: color ?? Colors.black87,
    height: 1.0,
  );

  static TextStyle quizLabel({Color? color}) => _dongle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: color ?? Colors.grey,
    height: 1.0,
  );

  // ─── CHATBOT / MARKDOWN ───────────────────────────────────────────────────

  /// Markdown body text - dùng RobotoMono cho code block, Dongle cho text thường
  static TextStyle markdownBody({Color? color}) => _dongle(
    fontSize: 26,
    fontWeight: FontWeight.normal,
    color: color ?? Colors.black87,
    height: 1.1,
  );

  static TextStyle markdownCode({Color? color}) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: color ?? Colors.black87,
    height: 1.4,
    fontFamily: 'monospace',
    backgroundColor: Colors.grey.shade100,
  );

  static TextStyle markdownHeading1({Color? color}) => _dongle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: color,
    height: 1.0,
  );

  static TextStyle markdownHeading2({Color? color}) => _dongle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: color,
    height: 1.0,
  );

  static TextStyle markdownHeading3({Color? color}) => _dongle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: color,
    height: 1.0,
  );

  // ─── FORM / INPUT ─────────────────────────────────────────────────────────
  // Dongle input style trùng với body - giữ nhất quán với CustomTextField

  static TextStyle inputText({Color? color}) => _dongle(
    fontSize: 28,
    fontWeight: FontWeight.normal,
    color: color ?? AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle inputLabel({Color? color, bool isFloating = false}) => _dongle(
    fontSize: isFloating ? 22 : 28,
    fontWeight: isFloating ? FontWeight.bold : FontWeight.normal,
    color: color,
    height: 1.0,
  );

  static TextStyle inputHint({Color? color}) => _dongle(
    fontSize: 28,
    fontWeight: FontWeight.normal,
    color: color ?? Colors.grey.shade400,
    height: 1.0,
  );

  // ─── SNACKBAR ─────────────────────────────────────────────────────────────

  static TextStyle snackBar({Color? color}) => _dongle(
    fontSize: 26,
    fontWeight: FontWeight.normal,
    color: color ?? Colors.white,
    height: 1.1,
  );

  // ─── ACHIEVEMENT / GAME ────────────────────────────────────────────────────

  static TextStyle achievementTitle({Color? color}) => _dongle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: color ?? Colors.black87,
    height: 1.0,
  );

  static TextStyle achievementDesc({Color? color}) => _dongle(
    fontSize: 19,
    fontWeight: FontWeight.normal,
    color: color ?? Colors.grey.shade600,
    height: 1.0,
  );

  static TextStyle rankTitle({Color? color}) => _dongle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: color ?? AppColors.primary,
    height: 1.0,
  );

  // ─── PROFILE ──────────────────────────────────────────────────────────────

  static TextStyle profileName({Color? color}) => _dongle(
    fontSize: 42,
    fontWeight: FontWeight.bold,
    color: color ?? Colors.white,
    height: 1.0,
  );

  static TextStyle profileEmail({Color? color}) => _dongle(
    fontSize: 24,
    fontWeight: FontWeight.normal,
    color: color ?? Colors.white.withValues(alpha: 0.9),
    height: 1.0,
  );

  static TextStyle profileLevel({Color? color}) => _dongle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: color ?? Colors.white,
    height: 1.0,
  );

  // ─── LEADERBOARD ──────────────────────────────────────────────────────────

  static TextStyle leaderboardName({Color? color}) => _dongle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: color,
    height: 1.0,
  );

  static TextStyle leaderboardPoints({Color? color}) => _dongle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: color,
    height: 1.0,
  );

  static TextStyle leaderboardRank({Color? color}) => _dongle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: color,
    height: 1.0,
  );

  // ─── LEGACY SIZE MAP ──────────────────────────────────────────────────────
  // Map từ size thực tế đang dùng trong codebase → token mới
  // Dùng để migration dần ở các phase sau

  /// Dongle 70px ≈ vocab word (flashcard front)
  static const double sizeVocabWord = 70;

  /// Dongle 55px ≈ vocab meaning (flashcard back)
  static const double sizeVocabMeaning = 55;

  /// Dongle 48px ≈ h1 (app title)
  static const double sizeH1 = 48;

  /// Dongle 42px ≈ profile name
  static const double sizeProfileName = 42;

  /// Dongle 40px ≈ app bar title
  static const double sizeAppBarTitle = 40;

  /// Dongle 38px ≈ h2
  static const double sizeH2 = 38;

  /// Dongle 36px ≈ dialog title
  static const double sizeDialogTitle = 36;

  /// Dongle 32px ≈ h3
  static const double sizeH3 = 32;

  /// Dongle 30px ≈ button (UPPERCASE)
  static const double sizeButton = 30;

  /// Dongle 28px ≈ input/body
  static const double sizeBody = 28;

  /// Dongle 26px ≈ quiz question
  static const double sizeQuizQuestion = 32;

  /// Dongle 24px ≈ stat
  static const double sizeStat = 24;

  /// Dongle 22px ≈ label
  static const double sizeLabel = 22;

  /// Dongle 20px ≈ pill label
  static const double sizeCaption = 20;

  /// Dongle 18px ≈ caption
  static const double sizeSmall = 18;
}
