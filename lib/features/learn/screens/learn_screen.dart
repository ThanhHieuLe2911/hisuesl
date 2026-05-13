import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../models/topic_model.dart';
import '../services/topic_service.dart';
import 'flashcard_screen.dart';
import 'favorites_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final TopicService _topicService = TopicService();
  late Future<List<TopicModel>> _topicsFuture;

  @override
  void initState() {
    super.initState();
    _topicsFuture = _topicService.getTopics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            "Chủ đề từ vựng",
            style: GoogleFonts.dongle(
              fontSize: 38,
              color: AppColors.textMain,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade200, offset: const Offset(0, 2), blurRadius: 0)
                ]
            ),
            child: IconButton(
              icon: const Icon(Icons.star_rounded, color: Colors.amber, size: 28),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FavoritesScreen())
                );
              },
            ),
          )
        ],
      ),
      body: FutureBuilder<List<TopicModel>>(
        future: _topicsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    "Không thể tải dữ liệu",
                    style: GoogleFonts.dongle(fontSize: 22, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          final topics = snapshot.data ?? [];
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];
              return _buildTopicCard(context, topic);
            },
          );
        },
      ),
    );
  }

  Widget _buildTopicCard(BuildContext context, TopicModel topic) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FlashcardScreen(topic: topic)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: topic.color.withOpacity(0.2),
              offset: const Offset(0, 8),
              blurRadius: 0,
            )
          ],
          border: Border.all(color: Colors.grey.shade100, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: topic.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  topic.imagePath,
                  width: 50,
                  height: 50,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.image_not_supported, color: topic.color, size: 30),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "UNIT ${topic.id}",
              style: GoogleFonts.dongle(
                fontSize: 22,
                color: topic.color.withOpacity(0.8),
                fontWeight: FontWeight.bold,
                height: 1.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                topic.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dongle(
                  fontSize: 26,
                  color: AppColors.textMain,
                  fontWeight: FontWeight.bold,
                  height: 0.9,
                ),
              ),
            ),
            Text(
              "${topic.vocabularies.length} từ vựng",
              style: GoogleFonts.dongle(
                fontSize: 20,
                color: Colors.grey.shade400,
                height: 1.0,
              ),
            )
          ],
        ),
      ),
    );
  }
}
