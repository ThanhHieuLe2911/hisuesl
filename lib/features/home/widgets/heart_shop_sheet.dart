import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hisuesl/features/learn/services/quiz_service.dart';
import 'package:hisuesl/widgets/app_bottom_sheet.dart';

class HeartShopSheet extends StatelessWidget {
  final int currentPoints;

  const HeartShopSheet({super.key, required this.currentPoints});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Thanh kéo nhỏ (Handle)
          AppBottomSheet.handleBar(),
          const SizedBox(height: 20),

          // Tiêu đề & Điểm hiện tại
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Cửa hàng Tim ❤️", style: GoogleFonts.dongle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.0)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 24),
                    const SizedBox(width: 4),
                    Text("$currentPoints", style: GoogleFonts.dongle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber.shade900, height: 1.0)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 20),

          // Danh sách các gói
          _buildShopItem(context, hearts: 1, cost: 1000, color: Colors.blue),
          _buildShopItem(context, hearts: 3, cost: 2500, color: Colors.purple),
          _buildShopItem(context, hearts: 5, cost: 4000, color: Colors.pink, isBestValue: true),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildShopItem(BuildContext context, {required int hearts, required int cost, required Color color, bool isBestValue = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 2),
        boxShadow: [BoxShadow(color: Colors.grey.shade100, offset: const Offset(0, 4), blurRadius: 10)],
      ),
      child: Row(
        children: [
          // Icon trái tim
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.favorite_rounded, color: color, size: 30),
          ),
          const SizedBox(width: 16),

          // Mô tả
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hồi $hearts Tim", style: GoogleFonts.dongle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.0)),
                if (isBestValue)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                    child: Text("TIẾT KIỆM NHẤT", style: GoogleFonts.dongle(fontSize: 16, color: Colors.white, height: 1.0)),
                  )
              ],
            ),
          ),

          // Nút mua
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: currentPoints >= cost ? color : Colors.grey.shade300,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
            ),
            onPressed: () => _handleBuy(context, cost, hearts),
            child: Row(
              children: [
                const Icon(Icons.emoji_events_rounded, size: 18, color: Colors.white),
                const SizedBox(width: 4),
                Text("$cost", style: GoogleFonts.dongle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold, height: 1.0)),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _handleBuy(BuildContext context, int cost, int amount) async {
    // Show Loading
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

    final result = await QuizService().buyHearts(cost, amount);

    if (context.mounted) {
      Navigator.pop(context); // Tắt Loading

      if (result == "success") {
        Navigator.pop(context); // Tắt Shop
        _showSuccessDialog(context, amount);
      } else {
        // Báo lỗi (Thiếu tiền hoặc Đầy tim)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result, style: GoogleFonts.dongle(fontSize: 24, color: Colors.white)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  void _showSuccessDialog(BuildContext context, int amount) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 60),
          content: Text("Thành công! Bạn đã nhận được $amount tim.", textAlign: TextAlign.center, style: GoogleFonts.dongle(fontSize: 28)),
        )
    );
  }
}