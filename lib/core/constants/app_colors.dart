import 'package:flutter/material.dart';

/// Design Token: Color System
///
/// Quy tắc:
/// - Field legacy (không đổi tên) vì đang được dùng rộng rãi trong codebase
/// - Field mới có prefix/suffix rõ ràng để phân biệt
/// - Semantic alias giữ nguyên giá trị gốc, chỉ thêm tên gọi mới
/// - Các màu phụ (game/gamification) khai báo riêng để phase sau migrate

class AppColors {
  AppColors._();

  // ─── LEGACY FIELDS (Giữ nguyên - đang được dùng trong codebase) ───────
  // KHÔNG ĐỔI TÊN, KHÔNG XÓA ở phase này

  /// Màu chủ đạo của app - Xanh dương Elingo
  static const Color primary = Color(0xFF0099FF);

  /// Màu bóng 3D của nút (đậm hơn primary để tạo hiệu ứng khối)
  /// @deprecated Dùng AppShadows.hard thay thế ở các phase sau
  static const Color primaryShadow = Color(0xFF0077C8);

  /// Màu nền trang chủ — soft blue dịu mắt, khuyến khích học tập
  static const Color background = Color(0xFFEBF5FF);

  /// Màu nền phụ / input surface
  static const Color surface = Color(0xFFF5F5F5);

  /// Màu chữ chính (body text)
  static const Color textMain = Color(0xFF4B4B4B);

  /// Màu chữ phụ / placeholder
  static const Color textLight = Color(0xFF9E9E9E);

  /// Màu báo lỗi
  static const Color error = Color(0xFFFF4B4B);

  // ─── SEMANTIC ALIASES (Map từ legacy, tên mới chuẩn hơn) ────────────────
  // Dùng các field này ở các phase sau, legacy fields vẫn hoạt động

  /// Semantic: primary color (alias của primary)
  static const Color primaryColor = primary;

  /// Semantic: text chính (alias của textMain)
  static const Color textPrimary = textMain;

  /// Semantic: text phụ (alias của textLight)
  static const Color textSecondary = textLight;

  // ─── SEMANTIC COLORS MỚI ────────────────────────────────────────────────

  /// Màu thành công (xanh lá)
  static const Color success = Color(0xFF4CAF50);

  /// Màu cảnh báo
  static const Color warning = Color(0xFFFF9800);

  /// Màu thông tin
  static const Color info = Color(0xFF2196F3);

  /// Màu border mặc định
  static const Color border = Color(0xFFE0E0E0);

  /// Màu border nhấn mạnh
  static const Color borderStrong = Color(0xFFBDBDBD);

  /// Màu disabled state
  static const Color disabled = Color(0xFFE0E0E0);

  // ─── BRAND EXTENDED PALETTE ──────────────────────────────────────────────

  /// Primary variant: sáng hơn primary
  static const Color primaryLight = Color(0xFF4DB8FF);

  /// Primary variant: đậm hơn primary
  static const Color primaryDark = Color(0xFF0077C8);

  /// Màu background phụ (dùng thay thế surface khi cần)
  static const Color backgroundSecondary = Color(0xFFF5F7FA);

  // ─── GAME / GAMIFICATION COLORS ─────────────────────────────────────────

  /// Màu trái tim / hearts (gamification)
  static const Color heart = Color(0xFFFF4B4B);

  /// Màu streak / lửa
  static const Color streak = Color(0xFFFF6B35);

  /// Màu streak variant (orange amber)
  static const Color streakLight = Color(0xFFFF9800);

  /// Màu cup / giải thưởng
  static const Color trophy = Color(0xFFFFD700);

  /// Màu cup variant (bạc)
  static const Color trophySilver = Color(0xFFC0C0C0);

  /// Màu cup variant (đồng)
  static const Color trophyBronze = Color(0xFFCD7F32);

  /// Màu điểm số / kim cương
  static const Color point = Color(0xFF2196F3);

  /// Màu achievement unlocked
  static const Color achievement = Color(0xFFFFD700);

  /// Màu achievement locked
  static const Color achievementLocked = Color(0xFFBDBDBD);

  // ─── CHATBOT / HISUBOT PALETTE ───────────────────────────────────────────

  /// Màu chatbot user bubble
  static const Color chatbotUser = Color(0xFF0099FF);

  /// Màu chatbot bot bubble
  static const Color chatbotBot = Color(0xFFFFFFFF);

  /// Màu chatbot background
  static const Color chatbotBackground = Color(0xFFF2F6F9);

  // ─── GRAPH / PROGRESS PALETTE ───────────────────────────────────────────

  /// Màu progress bar background
  static const Color progressBackground = Color(0xFFE0E0E0);

  /// Màu progress bar fill
  static const Color progressFill = primary;

  // ─── SEMANTIC STATE COLORS ──────────────────────────────────────────────

  /// Màu đúng (quiz result)
  static const Color correct = success;

  /// Màu sai (quiz result)
  static const Color incorrect = error;

  /// Màu neutral / không chọn
  static const Color neutral = Color(0xFF9E9E9E);

  /// Màu nổi bật / highlight
  static const Color highlight = Color(0xFFFFF3E0);
}
