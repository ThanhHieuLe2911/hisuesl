import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../models/topic_model.dart';
import '../models/vocab_model.dart';
import '../services/vocab_service.dart';

class FavoriteDetailScreen extends StatefulWidget {
  final TopicModel topic;
  const FavoriteDetailScreen({super.key, required this.topic});

  @override
  State<FavoriteDetailScreen> createState() => _FavoriteDetailScreenState();
}

class _FavoriteDetailScreenState extends State<FavoriteDetailScreen> {
  final VocabService _vocabService = VocabService();
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _flutterTts.setLanguage("en-US");
  }

  void _speak(String text) => _flutterTts.speak(text);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.textMain),
        title: Text(
          "Yêu thích: ${widget.topic.title}",
          style: GoogleFonts.dongle(fontSize: 30, color: AppColors.textMain),
        ),
      ),
      // Lắng nghe Stream để cập nhật Realtime (Xóa cái là mất ngay)
      body: StreamBuilder<List<String>>(
        stream: _vocabService.getFavoriteVocabIds(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final favIds = snapshot.data!;

          // Lọc ra các từ trong Unit này mà có ID nằm trong danh sách yêu thích
          final favoriteVocabs = widget.topic.vocabularies
              .where((vocab) => favIds.contains(vocab.id))
              .toList();

          if (favoriteVocabs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.heart_broken_rounded, size: 80, color: Colors.grey.shade300),
                  Text("Đã xóa hết từ yêu thích trong bài này!", style: GoogleFonts.dongle(fontSize: 24, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favoriteVocabs.length,
            itemBuilder: (context, index) {
              return _buildFavItem(favoriteVocabs[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildFavItem(VocabModel vocab) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 10, offset: const Offset(0, 5))],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Nút Loa
          GestureDetector(
            onTap: () => _speak(vocab.word),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.volume_up_rounded, color: AppColors.primary, size: 24),
            ),
          ),
          const SizedBox(width: 16),

          // Thông tin từ vựng
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(vocab.word, style: GoogleFonts.dongle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.0, color: AppColors.textMain)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(6)),
                      child: Text(vocab.type, style: GoogleFonts.dongle(fontSize: 18, color: Colors.orange, height: 1.0)),
                    )
                  ],
                ),
                Text(vocab.meaning, style: GoogleFonts.dongle(fontSize: 24, color: Colors.grey.shade600, height: 1.0)),
              ],
            ),
          ),

          // Nút Xóa (Thùng rác)
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            onPressed: () {
              // Xóa khỏi danh sách yêu thích
              _vocabService.toggleFavorite(vocab.id);
            },
          )
        ],
      ),
    );
  }
}