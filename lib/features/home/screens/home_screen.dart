// File: lib/features/home/screens/home_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hisuesl/core/constants/app_colors.dart';
import 'package:hisuesl/widgets/app_stat_pill.dart';
import 'package:hisuesl/widgets/app_bottom_sheet.dart';
import 'package:hisuesl/features/learn/screens/learn_screen.dart';
import 'package:hisuesl/features/home/screens/profile_screen.dart';
import 'package:hisuesl/features/learn/models/topic_model.dart';
import 'package:hisuesl/features/learn/services/topic_service.dart';
import 'package:hisuesl/features/learn/screens/quiz_screen.dart';
import 'package:hisuesl/features/learn/services/quiz_service.dart';
import '../widgets/heart_shop_sheet.dart';
import '../../leaderboard/screens/leaderboard_screen.dart';
import '../../chatbot/screens/hisubot_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final QuizService _quizService = QuizService();

  @override
  void initState() {
    super.initState();
    _quizService.syncOfflineHearts();
  }

  // --- CẬP NHẬT LIST MÀN HÌNH ---
  final List<Widget> _screens = [
    const PathView(),
    const LearnScreen(),
    const LeaderboardScreen(), // Màn hình Bảng xếp hạng
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _selectedIndex, children: _screens),

      // --- NÚT CHATBOT HISUBOT ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HisubotScreen()),
          );
        },
        backgroundColor: Colors.white,
        tooltip: 'Chat với Hisubot',
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.smart_toy_rounded, color: Colors.blueAccent, size: 32),
      ),
      // ---------------------------------------

      bottomNavigationBar: Container(
        decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade300, width: 2))),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey.shade400,
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: GoogleFonts.dongle(fontSize: 20, height: 1.0, fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.dongle(fontSize: 20, height: 1.0),
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Hành trình"),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: "Từ vựng"),
            BottomNavigationBarItem(icon: Icon(Icons.emoji_events_rounded), label: "Xếp hạng"),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Hồ sơ"),
          ],
        ),
      ),
    );
  }
}

class PathView extends StatefulWidget {
  const PathView({super.key});

  @override
  State<PathView> createState() => _PathViewState();
}

class _PathViewState extends State<PathView> {
  final TopicService _topicService = TopicService();
  late Future<List<TopicModel>> _topicsFuture;

  @override
  void initState() {
    super.initState();
    _topicsFuture = _topicService.getTopics();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text("Vui lòng đăng nhập"));

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final int hearts = data?['hearts'] ?? 0;
        final int points = data?['points'] ?? 0;
        final int streak = data?['dayStreak'] ?? 0;
        final Timestamp? lastHeartUpdate = data?['lastHeartUpdate'];
        final List<int> learnedUnits = (data?['learnedUnits'] ?? []).map<int>((e) => int.parse(e.toString())).toList();

        void openHeartShop() {
          AppBottomSheet.show(
            context: context,
            builder: (ctx) => HeartShopSheet(currentPoints: points),
          );
        }

        return SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24.0),
                    bottomRight: Radius.circular(24.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.15),
                      blurRadius: 10.0,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: openHeartShop,
                      child: HeartTimer(hearts: hearts, lastUpdate: lastHeartUpdate)
                    ),
                    AppStatPill(
                      icon: Icons.local_fire_department_rounded,
                      value: "$streak",
                      color: AppColors.streak
                    ),
                    AppStatPill(
                      icon: Icons.emoji_events_rounded,
                      value: "$points",
                      color: AppColors.trophy,
                      onTap: openHeartShop
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<TopicModel>>(
                  future: _topicsFuture,
                  builder: (context, topicSnapshot) {
                    if (topicSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (topicSnapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              "Không thể tải bài học",
                              style: GoogleFonts.dongle(fontSize: 22, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      );
                    }

                    final topics = topicSnapshot.data ?? [];
                    return Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Positioned.fill(
                          child: Center(
                            child: Container(
                              width: 12,
                              color: Colors.grey.shade200,
                            ),
                          ),
                        ),
                        ListView.builder(
                          padding: const EdgeInsets.only(top: 40, bottom: 100),
                          itemCount: topics.length + 1,
                          itemBuilder: (context, index) {
                            if (index == topics.length) return _buildChestNode();

                            final topic = topics[index];
                            bool isUnlocked = learnedUnits.contains(topic.id);
                            bool isCompleted = learnedUnits.contains(topic.id);

                            return _buildUnitNodeEnhanced(context, topic, isUnlocked, isCompleted);
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- WIDGET UNIT ĐẸP HƠN ---
  Widget _buildUnitNodeEnhanced(BuildContext context, TopicModel topic, bool isUnlocked, bool isCompleted) {
    Color baseColor = isUnlocked ? topic.color : Colors.grey.shade400; 
    Color shadowColor = isUnlocked
        ? HSLColor.fromColor(baseColor).withLightness(0.4).toColor()
        : Colors.grey.shade600; 

    return Container(
      margin: const EdgeInsets.only(bottom: 40), 
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              if (isUnlocked) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(unitId: topic.id)));
              } else {
                _showLockedDialog(context, topic.title);
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    color: shadowColor,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 90, height: 82, 
                  margin: const EdgeInsets.only(bottom: 8), 
                  decoration: BoxDecoration(
                    color: isUnlocked ? Colors.white : baseColor, 
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: baseColor, 
                        width: 4
                    ),
                  ),
                  child: Center(
                    child: isUnlocked
                        ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset(topic.imagePath, fit: BoxFit.contain),
                    )
                        : const Icon(Icons.lock_rounded, color: Colors.white54, size: 36),
                  ),
                ),
                if (isCompleted)
                  Positioned(
                    top: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: Colors.amber, 
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)]
                      ),
                      child: const Icon(Icons.star_rounded, color: Colors.white, size: 16),
                    ),
                  )
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: isUnlocked ? baseColor : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
                "UNIT ${topic.id}",
                style: GoogleFonts.dongle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? Colors.white : Colors.grey.shade600,
                    height: 1.0
                )
            ),
          ),
          Text(
              topic.title,
              style: GoogleFonts.dongle(fontSize: 22, color: Colors.grey.shade600, height: 1.0)
          ),
        ],
      ),
    );
  }

  void _showLockedDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline_rounded, size: 60, color: Colors.grey),
              const SizedBox(height: 16),
              Text("Bài học bị khóa!", style: GoogleFonts.dongle(fontSize: 32, fontWeight: FontWeight.bold)),
              Text("Hãy hoàn thành từ vựng bài '$title' trước nhé.", textAlign: TextAlign.center, style: GoogleFonts.dongle(fontSize: 24, color: Colors.grey)),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: const StadiumBorder()),
                onPressed: () => Navigator.pop(ctx),
                child: Text("ĐÃ HIỂU", style: GoogleFonts.dongle(fontSize: 24, color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChestNode() {
    return Container(
      width: 80, height: 80, margin: const EdgeInsets.only(bottom: 50, top: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.amber.shade800, shape: BoxShape.circle, boxShadow: const [BoxShadow(color: Color(0xFFFFA000), offset: Offset(0, 6))])),
          Container(
            width: 80, height: 72, margin: const EdgeInsets.only(bottom: 8),
            decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
            child: const Icon(Icons.card_giftcard, size: 40, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// --- GIỮ NGUYÊN HeartTimer CŨ ---
class HeartTimer extends StatefulWidget {
  final int hearts;
  final Timestamp? lastUpdate;
  const HeartTimer({super.key, required this.hearts, this.lastUpdate});
  @override
  State<HeartTimer> createState() => _HeartTimerState();
}

class _HeartTimerState extends State<HeartTimer> {
  Timer? _timer;
  String _timeString = "";
  final QuizService _quizService = QuizService();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(HeartTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hearts != oldWidget.hearts || widget.lastUpdate != oldWidget.lastUpdate) _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.hearts >= 5 || widget.lastUpdate == null) {
      setState(() => _timeString = "");
      return;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final diff = widget.lastUpdate!.toDate().add(const Duration(minutes: 10)).difference(DateTime.now());
      if (diff.isNegative) {
        timer.cancel();
        _quizService.regenerateOneHeart();
      } else {
        setState(() {
          _timeString = "${diff.inMinutes.remainder(60).toString().padLeft(2, '0')}:${diff.inSeconds.remainder(60).toString().padLeft(2, '0')}";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_rounded, color: AppColors.heart, size: 24),
          const SizedBox(width: 8),
          Text(
            "${widget.hearts}",
            style: GoogleFonts.dongle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.heart,
              height: 1.0,
            ),
          ),
          if (widget.hearts < 5 && _timeString.isNotEmpty)
            Text(
              " ($_timeString)",
              style: GoogleFonts.dongle(fontSize: 20, color: Colors.grey),
            ),
        ],
      ),
    );
  }
}