import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../data/mock_data.dart';
import '../services/vocab_service.dart';
import 'favorite_detail_screen.dart'; // Import màn hình chi tiết ở trên

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final VocabService vocabService = VocabService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.textMain),
        title: Text(
          "Kho từ vựng của tôi",
          style: GoogleFonts.dongle(fontSize: 32, color: AppColors.textMain, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<String>>(
        stream: vocabService.getFavoriteVocabIds(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final favIds = snapshot.data!;
          if (favIds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.stars_rounded, size: 100, color: Colors.grey.shade200),
                  Text("Bạn chưa lưu từ vựng nào!", style: GoogleFonts.dongle(fontSize: 26, color: Colors.grey)),
                ],
              ),
            );
          }

          // --- LOGIC QUAN TRỌNG: Lọc ra các Unit có chứa từ yêu thích ---
          final favTopics = mockTopics.where((topic) {
            // Kiểm tra xem Unit này có từ nào nằm trong danh sách favIds không
            return topic.vocabularies.any((vocab) => favIds.contains(vocab.id));
          }).toList();

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.9,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16
            ),
            itemCount: favTopics.length,
            itemBuilder: (context, index) {
              final topic = favTopics[index];
              // Đếm xem trong Unit này có bao nhiêu từ được thích
              final count = topic.vocabularies.where((v) => favIds.contains(v.id)).length;

              return GestureDetector(
                onTap: () {
                  // Chuyển sang màn hình chi tiết
                  Navigator.push(context, MaterialPageRoute(builder: (_) => FavoriteDetailScreen(topic: topic)));
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                      ]
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 70, width: 70,
                        decoration: BoxDecoration(color: topic.color.withOpacity(0.1), shape: BoxShape.circle),
                        child: Center(
                          child: Image.asset(topic.imagePath, width: 40, height: 40, fit: BoxFit.contain),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text("UNIT ${topic.id}", style: GoogleFonts.dongle(fontSize: 22, color: Colors.grey, height: 1.0)),
                      Text(topic.title, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.dongle(fontSize: 26, color: AppColors.textMain, fontWeight: FontWeight.bold, height: 1.0)),
                      const SizedBox(height: 8),
                      // Badge đếm số lượng
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(10)),
                        child: Text("$count từ đã lưu", style: GoogleFonts.dongle(fontSize: 20, color: Colors.amber.shade900, fontWeight: FontWeight.bold, height: 1.0)),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}