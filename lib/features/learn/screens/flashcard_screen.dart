import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../core/constants/app_colors.dart';
import '../models/topic_model.dart';
import '../models/vocab_model.dart';
import '../services/vocab_service.dart';

class FlashcardScreen extends StatefulWidget {
  final TopicModel topic;
  const FlashcardScreen({super.key, required this.topic});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  // Tăng Viewport để thẻ bên cạnh lộ ra ít hơn, tập trung vào thẻ chính
  final PageController _pageController = PageController(viewportFraction: 0.9);
  final VocabService _vocabService = VocabService();

  List<String> _favoriteIds = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
  }

  void _speak(String text) async => await _flutterTts.speak(text);

  void _finishLesson() async {
    await _vocabService.markUnitAsLearned(widget.topic.id);
    if (mounted) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Icon(Icons.stars_rounded, color: Colors.amber, size: 70),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Hoàn thành!", style: GoogleFonts.dongle(fontSize: 45, fontWeight: FontWeight.bold, height: 1.0)),
                Text("Bạn đã học hết từ vựng của bài này.", textAlign: TextAlign.center, style: GoogleFonts.dongle(fontSize: 26, color: Colors.grey)),
              ],
            ),
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: const StadiumBorder(),
                      elevation: 5,
                    ),
                    onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                      child: Text("TUYỆT VỜI", style: GoogleFonts.dongle(fontSize: 28, color: Colors.white)),
                    ),
                  ),
                ),
              )
            ],
          )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình để tính toán tỉ lệ
    final size = MediaQuery.of(context).size;
    bool isLastCard = _currentIndex == widget.topic.vocabularies.length - 1;

    return StreamBuilder<List<String>>(
        stream: _vocabService.getFavoriteVocabIds(),
        builder: (context, snapshot) {
          if (snapshot.hasData) _favoriteIds = snapshot.data!;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textMain, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
              title: LinearPercentIndicator(
                lineHeight: 10.0,
                percent: (_currentIndex + 1) / widget.topic.vocabularies.length,
                progressColor: AppColors.primary,
                backgroundColor: Colors.grey.shade200,
                barRadius: const Radius.circular(10),
                animation: true,
                animateFromLastPercent: true,
              ),
            ),
            body: Column(
              children: [
                const SizedBox(height: 10),
                Text(
                  "Unit ${widget.topic.id}: ${widget.topic.title}",
                  style: GoogleFonts.dongle(fontSize: 28, color: AppColors.textMain, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10), // Giảm khoảng cách này lại

                // --- PAGE VIEW VỚI TỈ LỆ CAO HƠN ---
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.topic.vocabularies.length,
                    onPageChanged: (index) => setState(() => _currentIndex = index),
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          double value = 1.0;
                          if (_pageController.position.haveDimensions) {
                            value = _pageController.page! - index;
                            value = (1 - (value.abs() * 0.1)).clamp(0.0, 1.0);
                          }

                          // --- TÍNH TOÁN KÍCH THƯỚC MỚI ---
                          // Chiều cao = 75% màn hình (trừ đi phần AppBar và Text)
                          // Chiều rộng = 90% màn hình
                          double cardHeight = size.height * 0.70;
                          double cardWidth = size.width * 0.90;

                          return Center(
                            child: SizedBox(
                              height: Curves.easeOut.transform(value) * cardHeight,
                              width: Curves.easeOut.transform(value) * cardWidth,
                              child: child,
                            ),
                          );
                        },
                        child: _buildFlashcardItem(widget.topic.vocabularies[index]),
                      );
                    },
                  ),
                ),

                // --- NÚT HOÀN THÀNH (Nằm đè lên phần dưới hoặc đẩy lên) ---
                // Mình dùng Container chiều cao cố định để giữ chỗ, tránh nhảy layout
                SizedBox(
                  height: 80,
                  child: Center(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: isLastCard ? 1.0 : 0.0,
                      child: isLastCard
                          ? SizedBox(
                        width: size.width * 0.8, // Nút rộng bằng 80% màn hình
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 8,
                          ),
                          onPressed: _finishLesson,
                          child: Text("HOÀN THÀNH BÀI HỌC", style: GoogleFonts.dongle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      )
                          : Text(
                        "${_currentIndex + 1}/${widget.topic.vocabularies.length}",
                        style: GoogleFonts.dongle(fontSize: 24, color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        }
    );
  }

  Widget _buildFlashcardItem(VocabModel vocab) {
    final bool isFav = _favoriteIds.contains(vocab.id);
    return FlipCard(
      direction: FlipDirection.HORIZONTAL,
      speed: 400,
      front: _buildCardFace(vocab, isFront: true, isFav: isFav),
      back: _buildCardFace(vocab, isFront: false, isFav: isFav),
    );
  }

  Widget _buildCardFace(VocabModel vocab, {required bool isFront, required bool isFav}) {
    return Container(
      // Margin nhỏ lại để card to ra
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 10),
            blurRadius: 20,
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 2),
      ),
      child: Stack(
        children: [
          // Nội dung chính
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isFront) ...[
                  // Từ vựng to hơn nữa
                  Text(vocab.word, style: GoogleFonts.dongle(fontSize: 70, color: AppColors.primary, fontWeight: FontWeight.bold, height: 1.0)),
                  const SizedBox(height: 10),
                  // Phiên âm
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
                    child: Text(vocab.pronunciation, style: const TextStyle(fontSize: 22, color: Colors.grey, fontStyle: FontStyle.italic)),
                  ),
                  const SizedBox(height: 40),
                  // Nút Loa to hơn, nổi bật hơn
                  GestureDetector(
                    onTap: () => _speak(vocab.word),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 10, offset: const Offset(0,4))]
                      ),
                      child: const Icon(Icons.volume_up_rounded, color: AppColors.primary, size: 50),
                    ),
                  ),
                ] else ...[
                  // Mặt sau
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(vocab.meaning, textAlign: TextAlign.center, style: GoogleFonts.dongle(fontSize: 55, color: AppColors.textMain, fontWeight: FontWeight.bold, height: 1.0)),
                  ),
                  const SizedBox(height: 15),
                  Text(vocab.type.toUpperCase(), style: GoogleFonts.dongle(fontSize: 26, color: Colors.orange, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text("Ex: ${vocab.exampleSentence}", textAlign: TextAlign.center, style: GoogleFonts.dongle(fontSize: 30, color: Colors.grey.shade600, height: 1.2)),
                  ),
                ],
              ],
            ),
          ),

          // Nút Yêu thích (Đẩy ra xa hơn một chút để thoáng)
          Positioned(
            top: 24, right: 24,
            child: IconButton(
              icon: Icon(isFav ? Icons.star_rounded : Icons.star_outline_rounded, color: isFav ? Colors.amber : Colors.grey.shade300, size: 44),
              onPressed: () => _vocabService.toggleFavorite(vocab.id),
            ),
          ),

          // Gợi ý lật (Bottom)
          if (isFront)
            Positioned(
                bottom: 30, left: 0, right: 0,
                child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.touch_app_rounded, color: Colors.grey.shade300, size: 20),
                        const SizedBox(width: 8),
                        Text("Chạm để lật", style: GoogleFonts.dongle(fontSize: 24, color: Colors.grey.shade300))
                      ],
                    )
                )
            ),
        ],
      ),
    );
  }
}