/// Design Token: Spacing System
///
/// Quy tắc:
/// - Hệ 8px grid (spacing chuẩn UX)
/// - Giá trị nhỏ hơn (4px) dùng cho micro spacing trong component
/// - Giá trị lớn hơn (48, 64) dùng cho section spacing
/// - Tên gọi rõ ràng: xxs < xs < sm < md < lg < xl < xxl < xxxl
///
/// Mapping từ giá trị đang dùng trong codebase:
///   4px  → spacing4 / xxs
///   8px  → spacing8 / xs
///   12px → spacing12 / sm (half-md)
///   16px → spacing16 / md
///   20px → spacing20
///   24px → spacing24 / lg
///   32px → spacing32 / xl
///   40px → spacing40
///   48px → spacing48 / xxl
///
/// Migration:
///   Thay hardcoded number bằng token: padding: EdgeInsets.all(AppSpacing.md)
///   Thay padding: const EdgeInsets.symmetric(horizontal: 24) → padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg)

class AppSpacing {
  AppSpacing._();

  // ─── MICRO SPACING ──────────────────────────────────────────────────────
  // Dùng trong component (icon vs text, chip padding nhỏ)

  /// 4px - Micro spacing nhỏ nhất
  static const double spacing4 = 4.0;

  // ─── BASE SPACING ───────────────────────────────────────────────────────
  // Hệ 8px grid

  /// 8px - xs (extra small)
  static const double xs = 8.0;

  /// 12px - sm (small), nửa giữa xs và md
  static const double sm = 12.0;

  /// 16px - md (medium) - Padding mặc định của hầu hết components
  static const double md = 16.0;

  /// 20px - Thường dùng giữa form fields
  static const double mdLg = 20.0;

  /// 24px - lg (large) - Screen padding phổ biến nhất
  static const double lg = 24.0;

  /// 32px - xl (extra large) - Section spacing
  static const double xl = 32.0;

  /// 40px - Section spacing lớn
  static const double xxl = 40.0;

  /// 48px - Spacing giữa các section lớn
  static const double xxxl = 48.0;

  /// 56px - Chiều cao button tiêu chuẩn
  static const double buttonHeight = 56.0;

  /// 64px - Header height
  static const double headerHeight = 64.0;

  /// 80px - Hero section height
  static const double heroHeight = 80.0;

  // ─── ALIAS (Backward compatible) ───────────────────────────────────────

  static const double spacing8 = xs;
  static const double spacing12 = sm;
  static const double spacing16 = md;
  static const double spacing20 = mdLg;
  static const double spacing24 = lg;
  static const double spacing32 = xl;
  static const double spacing40 = xxl;
  static const double spacing48 = xxxl;

  /// Legacy: spacing nhỏ nhất
  static const double spacing4_alias = spacing4;

  /// Legacy: spacing thường dùng (16)
  static const double spacing_default = md;

  /// Legacy: padding screen horizontal phổ biến (24)
  static const double screenHorizontal = lg;

  /// Legacy: padding screen vertical (16)
  static const double screenVertical = md;

  // ─── EDGEINSETS HELPERS ─────────────────────────────────────────────────

  /// All = md (16)
  static const EdgeInsets all = EdgeInsets.all(md);

  /// All = xs (8)
  static const EdgeInsets allXs = EdgeInsets.all(xs);

  /// All = sm (12)
  static const EdgeInsets allSm = EdgeInsets.all(sm);

  /// All = lg (24)
  static const EdgeInsets allLg = EdgeInsets.all(lg);

  /// All = xl (32)
  static const EdgeInsets allXl = EdgeInsets.all(xl);

  /// Horizontal = lg (24), Vertical = md (16)
  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: lg, vertical: md);

  /// Horizontal = lg (24)
  static const EdgeInsets horizontal = EdgeInsets.symmetric(horizontal: lg);

  /// Vertical = lg (24)
  static const EdgeInsets vertical = EdgeInsets.symmetric(vertical: lg);

  /// Symmetric horizontal
  static EdgeInsets symmetricH(double horizontal) => EdgeInsets.symmetric(horizontal: horizontal);

  /// Symmetric vertical
  static EdgeInsets symmetricV(double vertical) => EdgeInsets.symmetric(vertical: vertical);

  // ─── PADDING PRESETS CHO TỪNG COMPONENT ────────────────────────────────

  /// Card padding mặc định
  static const EdgeInsets cardPadding = EdgeInsets.all(md);

  /// Card padding khi có nhiều nội dung
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(lg);

  /// List item padding
  static const EdgeInsets listItem = EdgeInsets.symmetric(horizontal: md, vertical: sm);

  /// Form field spacing (vertical gap giữa fields)
  static const double formFieldSpacing = mdLg;

  /// Chip padding
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(horizontal: sm, vertical: spacing4);

  /// Button padding
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: lg, vertical: sm);

  /// AppBar title padding
  static const EdgeInsets appBarTitlePadding = EdgeInsets.only(left: md);

  /// Dialog padding
  static const EdgeInsets dialogPadding = EdgeInsets.all(lg);

  /// Bottom sheet padding
  static const EdgeInsets bottomSheetPadding = EdgeInsets.all(lg);

  // ─── GAP HELPERS ────────────────────────────────────────────────────────

  /// Gap nhỏ nhất (4px)
  static const SizedBox gap4 = SizedBox(width: spacing4, height: spacing4);

  /// Gap xs (8px)
  static const SizedBox gapXs = SizedBox(width: xs, height: xs);

  /// Gap sm (12px)
  static const SizedBox gapSm = SizedBox(width: sm, height: sm);

  /// Gap md (16px)
  static const SizedBox gapMd = SizedBox(width: md, height: md);

  /// Gap lg (24px)
  static const SizedBox gapLg = SizedBox(width: lg, height: lg);

  /// Gap xl (32px)
  static const SizedBox gapXl = SizedBox(width: xl, height: xl);

  /// Horizontal gap xs
  static const SizedBox gapHorizontalXs = SizedBox(width: xs);

  /// Horizontal gap md
  static const SizedBox gapHorizontalMd = SizedBox(width: md);

  /// Horizontal gap lg
  static const SizedBox gapHorizontalLg = SizedBox(width: lg);

  /// Vertical gap xs
  static const SizedBox gapVerticalXs = SizedBox(height: xs);

  /// Vertical gap sm
  static const SizedBox gapVerticalSm = SizedBox(height: sm);

  /// Vertical gap md
  static const SizedBox gapVerticalMd = SizedBox(height: md);

  /// Vertical gap lg
  static const SizedBox gapVerticalLg = SizedBox(height: lg);

  /// Vertical gap xl
  static const SizedBox gapVerticalXl = SizedBox(height: xl);

  /// Vertical gap xxl
  static const SizedBox gapVerticalXxl = SizedBox(height: xxl);
}
