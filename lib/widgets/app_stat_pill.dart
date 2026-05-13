import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable StatPill widget cho hearts / points / streak / countdown
///
/// Quy tắc:
/// - Stateless, pure UI
/// - Dùng AppColors cho màu (hearts/streak/points đã có token)
/// - Font Dongle cho text
/// - Dùng cho: hearts, points, streak, rank badge
///
/// Ví dụ:
///
///   AppStatPill(
///     icon: Icons.favorite_rounded,
///     value: "5",
///     color: AppColors.heart,
///   )
///
///   AppStatPill(
///     icon: Icons.local_fire_department_rounded,
///     value: "$streak",
///     color: AppColors.streak,
///     onTap: openHeartShop,
///   )
///
/// Migration guide:
///   Thay _buildStatPill(...) → AppStatPill(...)

class AppStatPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  final VoidCallback? onTap;
  final bool showShadow;

  const AppStatPill({
    super.key,
    required this.icon,
    required this.value,
    required this.color,
    this.onTap,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300, width: 2),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Text(
            value,
            style: GoogleFonts.dongle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
              height: 1.0,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}

/// Variant: pill chỉ có text/value (không icon)
/// Dùng cho: badge nhỏ, tag không cần icon
class AppTextPill extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final EdgeInsets padding;

  const AppTextPill({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: borderColor != null ? Border.all(color: borderColor!, width: 1.5) : null,
      ),
      child: Text(
        text,
        style: GoogleFonts.dongle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textColor ?? Colors.grey.shade600,
          height: 1.0,
        ),
      ),
    );
  }
}
