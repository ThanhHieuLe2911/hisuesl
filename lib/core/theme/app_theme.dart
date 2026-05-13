import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import 'app_typography.dart';
import 'app_radius.dart';

/// Design Token: App Theme
///
/// Quy tắc:
/// - Đây là foundation theme, CÓ THỂ áp dụng từng phần ở các phase sau
/// - KHÔNG ép toàn bộ app dùng theme này ở phase này
/// - Mục tiêu: tạo nền móng để phase sau áp dụng dần
///
/// Cách dùng Phase sau:
///   1. Thêm vào MaterialApp: theme: AppTheme.light
///   2. Hoặc chỉ dùng AppTheme.xxx để lấy config
///
/// Cách dùng NGAY (an toàn):
///   import 'package:hisuesl/core/theme/app_theme.dart';
///   Container(
///     decoration: BoxDecoration(
///       color: AppTheme.scaffoldBackground,
///       borderRadius: AppRadius.radiusMediumLarge,
///     ),
///   )

class AppTheme {
  AppTheme._();

  // ─── SCAFFOLD / BACKGROUND ──────────────────────────────────────────

  /// Màu nền scaffold mặc định
  static const Color scaffoldBackground = AppColors.background;

  /// Màu nền scaffold phụ (dùng thay thế khi cần)
  static const Color scaffoldBackgroundSecondary = AppColors.backgroundSecondary;

  // ─── COLOR SCHEME ─────────────────────────────────────────────────────

  /// ColorScheme primary
  static const ColorScheme colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.primaryLight,
    onSecondary: Colors.white,
    error: AppColors.error,
    onError: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
  );

  // ─── APP BAR THEME ───────────────────────────────────────────────────

  static AppBarTheme get appBarTheme => const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: false,
    iconTheme: IconThemeData(color: AppColors.textMain),
    titleTextStyle: TextStyle(
      fontFamily: 'Dongle',
      fontSize: 40,
      fontWeight: FontWeight.bold,
      color: AppColors.textMain,
    ),
  );

  // ─── TEXT THEME ─────────────────────────────────────────────────────

  /// TextTheme cơ bản (foundation)
  /// Dùng làm base, phase sau override dần
  static TextTheme get textTheme => TextTheme(
    displayLarge: AppTypography.display(),
    displayMedium: AppTypography.h1(),
    displaySmall: AppTypography.h2(),
    headlineLarge: AppTypography.h2(),
    headlineMedium: AppTypography.h3(),
    headlineSmall: AppTypography.title(),
    titleLarge: AppTypography.titleMedium(),
    titleMedium: AppTypography.bodyLarge(),
    titleSmall: AppTypography.body(),
    bodyLarge: AppTypography.bodyLarge(),
    bodyMedium: AppTypography.body(),
    bodySmall: AppTypography.caption(),
    labelLarge: AppTypography.button(),
    labelMedium: AppTypography.label(),
    labelSmall: AppTypography.caption(),
  );

  // ─── INPUT DECORATION THEME ─────────────────────────────────────────

  /// Input decoration base (dùng cho TextField/TextFormField)
  /// Phù hợp với style Material Outlined
  static InputDecorationTheme get inputDecorationTheme => InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: AppRadius.radiusMedium,
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppRadius.radiusMedium,
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppRadius.radiusMedium,
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: AppRadius.radiusMedium,
      borderSide: const BorderSide(color: AppColors.error),
    ),
    hintStyle: AppTypography.inputHint(),
    labelStyle: AppTypography.inputLabel(),
  );

  // ─── ELEVATED BUTTON THEME ──────────────────────────────────────────

  /// Elevated button style (Material default - flat style)
  static ElevatedButtonThemeData get elevatedButtonTheme => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusMedium,
      ),
      textStyle: AppTypography.button(),
    ),
  );

  // ─── TEXT BUTTON THEME ──────────────────────────────────────────────

  static TextButtonThemeData get textButtonTheme => TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      textStyle: AppTypography.button(color: AppColors.primary),
    ),
  );

  // ─── OUTLINED BUTTON THEME ──────────────────────────────────────────

  static OutlinedButtonThemeData get outlinedButtonTheme => OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary, width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusMedium,
      ),
      textStyle: AppTypography.button(color: AppColors.primary),
    ),
  );

  // ─── SNACK BAR THEME ────────────────────────────────────────────────

  static SnackBarThemeData get snackBarTheme => SnackBarThemeData(
    backgroundColor: AppColors.primary,
    contentTextStyle: AppTypography.snackBar(),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.radiusMedium,
    ),
    elevation: 0,
  );

  // ─── DIALOG THEME ───────────────────────────────────────────────────

  static DialogTheme get dialogTheme => DialogTheme(
    backgroundColor: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.radiusLarge,
    ),
    titleTextStyle: AppTypography.h3(),
    contentTextStyle: AppTypography.body(),
  );

  // ─── BOTTOM SHEET THEME ──────────────────────────────────────────────

  static BottomSheetThemeData get bottomSheetTheme => const BottomSheetThemeData(
    backgroundColor: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
  );

  // ─── CARD THEME ─────────────────────────────────────────────────────

  static CardTheme get cardTheme => CardTheme(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.radiusMediumLarge,
    ),
    margin: EdgeInsets.zero,
  );

  // ─── DIVIDER THEME ──────────────────────────────────────────────────

  static const DividerThemeData dividerTheme = DividerThemeData(
    color: AppColors.border,
    thickness: 1,
    space: 1,
  );

  // ─── PROGRESS INDICATOR THEME ───────────────────────────────────────

  static const ProgressIndicatorThemeData progressIndicatorTheme = ProgressIndicatorThemeData(
    color: AppColors.primary,
    linearTrackColor: AppColors.progressBackground,
    circularTrackColor: AppColors.progressBackground,
  );

  // ─── SWITCH THEME ───────────────────────────────────────────────────

  static SwitchThemeData get switchTheme => SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }
      return Colors.grey;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary.withValues(alpha: 0.30);
      }
      return Colors.grey.shade300;
    }),
  );

  // ─── LIST TILE THEME ────────────────────────────────────────────────

  static ListTileThemeData get listTileTheme => ListTileThemeData(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.radiusMedium,
    ),
    titleTextStyle: AppTypography.body(),
    subtitleTextStyle: AppTypography.caption(),
  );

  // ─── CHIP THEME ────────────────────────────────────────────────────

  static ChipThemeData get chipTheme => ChipThemeData(
    backgroundColor: Colors.grey.shade100,
    selectedColor: AppColors.primary.withValues(alpha: 0.15),
    labelStyle: AppTypography.label(),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.radiusSmall,
    ),
  );

  // ─── FULL THEME DATA ────────────────────────────────────────────────
  // CẢNH BÁO: Áp dụng toàn bộ theme này có thể thay đổi giao diện nhiều màn hình
  // Chỉ dùng sau khi đã migrate toàn bộ screen sang tokens mới

  /// Light theme hoàn chỉnh
  /// Dùng: MaterialApp(theme: AppTheme.light)
  /// Nhưng CẦN test kỹ trước khi áp dụng toàn app
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: scaffoldBackground,
    appBarTheme: appBarTheme,
    textTheme: textTheme,
    inputDecorationTheme: inputDecorationTheme,
    elevatedButtonTheme: elevatedButtonTheme,
    textButtonTheme: textButtonTheme,
    outlinedButtonTheme: outlinedButtonTheme,
    snackBarTheme: snackBarTheme,
    dialogTheme: dialogTheme,
    bottomSheetTheme: bottomSheetTheme,
    cardTheme: cardTheme,
    dividerTheme: dividerTheme,
    progressIndicatorTheme: progressIndicatorTheme,
    switchTheme: switchTheme,
    listTileTheme: listTileTheme,
    chipTheme: chipTheme,
    fontFamily: 'Dongle',
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
  );

  // ─── THEME EXTENSION ────────────────────────────────────────────────
  // Dùng khi cần extend theme với custom properties

  /// Extension để lấy custom properties từ context
  /// Cách dùng:
  ///   final theme = Theme.of(context);
  ///   if (theme.isHisuESL) { ... }

  static bool isHisuESLTheme(BuildContext context) {
    return Theme.of(context).fontFamily == 'Dongle';
  }
}

// ─── THEME MIXIN / UTILITY ──────────────────────────────────────────────

/// Mixin để screen/widget dễ truy cập tokens
mixin AppThemeMixin<T extends StatefulWidget> on State<T> {
  /// Lấy color scheme
  ColorScheme get colorScheme => Theme.of(context).colorScheme;

  /// Lấy text theme
  TextTheme get textTheme => Theme.of(context).textTheme;

  /// Kiểm tra is dark mode (hiện tại app chỉ có light)
  bool get isDarkMode => Theme.of(context).brightness == Brightness.dark;
}

/// Extension trên BuildContext để truy cập nhanh
extension AppThemeContext on BuildContext {
  /// Lấy AppColors.primary một cách ngắn gọn
  Color get primary => AppColors.primary;

  /// Lấy AppColors.textPrimary
  Color get textColor => AppColors.textPrimary;

  /// Lấy theme hiện tại
  ThemeData get theme => Theme.of(this);
}
