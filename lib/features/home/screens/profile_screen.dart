import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hisuesl/core/constants/app_colors.dart';
import 'package:hisuesl/features/auth/services/auth_service.dart';
import 'package:hisuesl/features/auth/screens/login_screen.dart';
import 'package:hisuesl/features/home/services/achievement_service.dart';
import 'package:hisuesl/widgets/app_bottom_sheet.dart';
import 'edit_profile_screen.dart';
import 'package:hisuesl/core/services/notification_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AchievementService _achievementService = AchievementService();
  bool _hasCheckedAchievements = false;

  // --- BIẾN CÀI ĐẶT ---
  bool _isSoundEnabled = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isSoundEnabled = prefs.getBool('isSoundEnabled') ?? true;
      final int hour = prefs.getInt('reminderHour') ?? 20;
      final int minute = prefs.getInt('reminderMinute') ?? 0;
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _toggleSound(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSoundEnabled', value);
    setState(() => _isSoundEnabled = value);
  }

  // --- HÀM CHỌN GIỜ HIỆN ĐẠI (CUPERTINO STYLE) ---
  void _showModernTimePicker() {
    TimeOfDay pendingReminderTime = _reminderTime;

    AppBottomSheet.show(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: 300,
          padding: const EdgeInsets.only(top: 10),
          color: Colors.white,
          child: Column(
            children: [
              AppBottomSheet.handleBar(width: 50),
              const SizedBox(height: 20),

              Text("Chọn giờ nhắc nhở", style: GoogleFonts.dongle(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.primary, height: 1.0)),

              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  initialDateTime: DateTime(2024, 1, 1, pendingReminderTime.hour, pendingReminderTime.minute),
                  onDateTimeChanged: (DateTime newDate) {
                    pendingReminderTime = TimeOfDay(hour: newDate.hour, minute: newDate.minute);
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setInt('reminderHour', pendingReminderTime.hour);
                      await prefs.setInt('reminderMinute', pendingReminderTime.minute);

                      await NotificationService().scheduleDailyNotification(
                          pendingReminderTime.hour,
                          pendingReminderTime.minute,
                      );

                      if (mounted) {
                        setState(() {
                          _reminderTime = pendingReminderTime;
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Đã đặt nhắc nhở lúc ${_formatTime(pendingReminderTime)}!", style: GoogleFonts.dongle(fontSize: 24, color: Colors.white)),
                          backgroundColor: AppColors.primary,
                        ));
                      }
                    },
                    child: Text("XÁC NHẬN", style: GoogleFonts.dongle(fontSize: 28, color: Colors.white)),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final min = time.minute.toString().padLeft(2, '0');
    return "$hour:$min";
  }

  String _getRankTitle(int points) {
    if (points <= 500) return "🛡️ Tân Binh Khởi Nguyên";
    if (points <= 2000) return "⚔️ Dũng Sĩ Tinh Anh";
    if (points <= 5000) return "📜 Bậc Thầy Thông Thái";
    if (points <= 10000) return "🌪️ Đại Tướng Chinh Phạt";
    if (points <= 20000) return "🔥 Chiến Thần Bất Bại";
    return "👑 Tượng Đài Bất Diệt";
  }

  List<dynamic> _getRankProgress(int points) {
    if (points <= 500) return [points, 500, points / 500];
    if (points <= 2000) return [points - 500, 1500, (points - 500) / 1500];
    if (points <= 5000) return [points - 2000, 3000, (points - 2000) / 3000];
    if (points <= 10000) return [points - 5000, 5000, (points - 5000) / 5000];
    if (points <= 20000) return [points - 10000, 10000, (points - 10000) / 10000];
    return [1, 1, 1.0];
  }

  List<dynamic> _calculateAchievementProgress(String id, int streak, int totalPoints, int learnedCount) {
    switch (id) {
      case 'streak_3': return [streak, 3, (streak / 3).clamp(0.0, 1.0)];
      case 'streak_7': return [streak, 7, (streak / 7).clamp(0.0, 1.0)];
      case 'points_1000': return [totalPoints, 1000, (totalPoints / 1000).clamp(0.0, 1.0)];
      case 'learned_5': return [learnedCount, 5, (learnedCount / 5).clamp(0.0, 1.0)];
      case 'rank_pro': return [totalPoints, 2000, (totalPoints / 2000).clamp(0.0, 1.0)];
      case 'streak_30': return [streak, 30, (streak / 30).clamp(0.0, 1.0)];
      default: return [0, 1, 0.0];
    }
  }

  void _showAchievementDialog(List<String> newBadges) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 20, spreadRadius: 5)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events_rounded, size: 80, color: Colors.amber),
              const SizedBox(height: 16),
              Text("THÀNH TỰU MỚI!", style: GoogleFonts.dongle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.orange, height: 1.0)),
              Text("Bạn vừa nhận được ${newBadges.length * 500} điểm", style: GoogleFonts.dongle(fontSize: 26, color: Colors.grey, height: 1.0)),
              const SizedBox(height: 16),
              ...newBadges.map((name) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(name, style: GoogleFonts.dongle(fontSize: 28, color: Colors.black87, fontWeight: FontWeight.bold, height: 1.0)),
                  ],
                ),
              )),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: const StadiumBorder()),
                child: Text("NHẬN QUÀ", style: GoogleFonts.dongle(fontSize: 28, color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text("Vui lòng đăng nhập"));

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Scaffold(backgroundColor: AppColors.background, body: Center(child: CircularProgressIndicator(color: AppColors.primary)));

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        if (data == null) return const SizedBox();

        if (!_hasCheckedAchievements) {
          _hasCheckedAchievements = true;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            List<String> newUnlocked = await _achievementService.checkAndClaimAchievements(data);
            if (newUnlocked.isNotEmpty && mounted) {
              _showAchievementDialog(newUnlocked);
            }
          });
        }

        final String name = data['name'] ?? "Người dùng";
        final String email = data['email'] ?? "Chưa có email";
        final String level = data['level'] ?? "Chưa chọn";
        final int totalPoints = data['totalPoints'] ?? 0;
        final int streak = data['dayStreak'] ?? 0;
        final List<dynamic> learnedList = data['learnedUnits'] ?? [];
        final int learnedCount = learnedList.length;
        final List<dynamic> claimedAchievements = data['achievements'] ?? [];

        final String? avatarBase64 = data['avatarBase64'];
        ImageProvider? avatarImage;
        if (avatarBase64 != null && avatarBase64.isNotEmpty) {
          try { avatarImage = MemoryImage(base64Decode(avatarBase64)); } catch (e) { print(e); }
        }

        final String rankTitle = _getRankTitle(totalPoints);
        final List<dynamic> progressData = _getRankProgress(totalPoints);
        final int currentProgressPoints = progressData[0];
        final int targetPoints = progressData[1];
        final double percent = (progressData[2] as double).clamp(0.0, 1.0);
        final int remainingPoints = targetPoints - currentProgressPoints;
        final bool isMaxRank = percent >= 1.0 && totalPoints > 20000;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            child: Column(
              children: [
                // HEADER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 60, bottom: 50),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 110, height: 110,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
                          image: avatarImage != null ? DecorationImage(image: avatarImage, fit: BoxFit.cover) : null,
                        ),
                        child: avatarImage == null ? const Icon(Icons.person, size: 60, color: Colors.grey) : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(name, style: GoogleFonts.dongle(fontSize: 42, fontWeight: FontWeight.bold, height: 1.0, color: Colors.white)),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfileScreen(currentName: name, currentAvatarBase64: avatarBase64))),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                              child: const Icon(Icons.edit, color: Colors.white, size: 18),
                            ),
                          )
                        ],
                      ),
                      Text(email, style: GoogleFonts.dongle(fontSize: 24, color: Colors.white.withOpacity(0.9), height: 1.0)),

                      const SizedBox(height: 8),
                      // LEVEL BADGE
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.3))
                        ),
                        child: Text(
                          "Level: $level",
                          style: GoogleFonts.dongle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold, height: 1.0),
                        ),
                      )
                    ],
                  ),
                ),

                // CONTENT
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // RANK CARD
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.amber.shade200, width: 2),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))]
                          ),
                          child: Column(
                            children: [
                              Text("Danh hiệu hiện tại", style: GoogleFonts.dongle(fontSize: 22, color: Colors.grey)),
                              Text(rankTitle, style: GoogleFonts.dongle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary, height: 1.0), textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              LinearPercentIndicator(
                                lineHeight: 20.0,
                                percent: percent,
                                backgroundColor: Colors.grey.shade200,
                                progressColor: Colors.amber,
                                barRadius: const Radius.circular(10),
                                animation: true,
                                center: Text("${(percent * 100).toInt()}%", style: GoogleFonts.dongle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary, height: 1.0)),
                              ),
                              const SizedBox(height: 12),
                              isMaxRank
                                  ? Text("Bạn đã đạt đẳng cấp tối thượng!", style: GoogleFonts.dongle(fontSize: 26, color: Colors.amber.shade700, fontWeight: FontWeight.bold), textAlign: TextAlign.center)
                                  : RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: GoogleFonts.dongle(fontSize: 24, color: Colors.grey.shade600, height: 1.0),
                                  children: [
                                    const TextSpan(text: "Cần thêm "),
                                    TextSpan(text: "$remainingPoints điểm", style: GoogleFonts.dongle(fontSize: 28, color: AppColors.primary, fontWeight: FontWeight.bold, height: 1.0)),
                                    const TextSpan(text: " nữa để thăng hạng"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // STATS
                        Row(
                          children: [
                            _buildStatCard("Streak", "$streak 🔥", Colors.orange.shade50, Colors.orange),
                            const SizedBox(width: 16),
                            _buildStatCard("Tổng điểm", "$totalPoints 💎", Colors.blue.shade50, Colors.blue),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildStatCard("Đã học", "$learnedCount bài 📚", Colors.green.shade50, Colors.green),
                            const SizedBox(width: 16),
                            Expanded(child: Container()),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // ACHIEVEMENTS
                        Text("Mục Tiêu & Thành Tựu", style: GoogleFonts.dongle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.0)),
                        const SizedBox(height: 12),

                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _achievementService.allAchievements.length,
                          separatorBuilder: (ctx, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = _achievementService.allAchievements[index];

                            List<dynamic> progData = _calculateAchievementProgress(item.id, streak, totalPoints, learnedCount);
                            double progPercent = progData[2];

                            // [FIX LOGIC] Mở khóa nếu đã nhận HOẶC tiến độ đạt 100%
                            final bool isUnlocked = claimedAchievements.contains(item.id) || progPercent >= 1.0;

                            int currentVal = progData[0];
                            int targetVal = progData[1];

                            if (isUnlocked) {
                              progPercent = 1.0;
                              currentVal = targetVal;
                            }

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: isUnlocked ? Border.all(color: item.color.withOpacity(0.5), width: 1.5) : Border.all(color: Colors.grey.shade200, width: 1.5),
                                boxShadow: isUnlocked ? [BoxShadow(color: item.color.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 3))] : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48, height: 48,
                                    decoration: BoxDecoration(color: isUnlocked ? item.color.withOpacity(0.1) : Colors.grey.shade100, shape: BoxShape.circle),
                                    child: Icon(isUnlocked ? item.icon : Icons.lock, color: isUnlocked ? item.color : Colors.grey.shade400, size: 24),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.title, style: GoogleFonts.dongle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.0)),
                                        Text(item.description, style: GoogleFonts.dongle(fontSize: 19, color: Colors.grey.shade600, height: 1.0)),
                                        const SizedBox(height: 4),
                                        LinearPercentIndicator(
                                          padding: EdgeInsets.zero,
                                          lineHeight: 10.0,
                                          percent: progPercent,
                                          backgroundColor: Colors.grey.shade200,
                                          progressColor: isUnlocked ? item.color : Colors.grey.shade400,
                                          barRadius: const Radius.circular(5),
                                          animation: true,
                                          trailing: Padding(
                                            padding: const EdgeInsets.only(left: 8.0),
                                            child: Text("$currentVal/$targetVal", style: GoogleFonts.dongle(fontSize: 18, color: Colors.grey.shade600, height: 1.0)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: isUnlocked ? Colors.amber.shade100 : Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                                    child: Column(
                                      children: [
                                        const Icon(Icons.stars_rounded, color: Colors.amber, size: 20),
                                        Text("+${item.rewardPoints}", style: GoogleFonts.dongle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber.shade800, height: 1.0)),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 30),

                        // SETTINGS
                        Text("Cài Đặt Ứng Dụng", style: GoogleFonts.dongle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.0)),
                        const SizedBox(height: 12),

                        // [ĐÃ SỬA GIAO DIỆN] Thêm viền (border) rõ hơn
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            // Thêm viền màu xám đậm và dày hơn một chút
                            border: Border.all(color: Colors.grey.shade300, width: 2.0),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Column(
                            children: [
                              // SOUND SWITCH
                              SwitchListTile(
                                title: Text("Hiệu ứng âm thanh", style: GoogleFonts.dongle(fontSize: 26, height: 1.0)),
                                subtitle: Text("Bật tiếng khi làm bài", style: GoogleFonts.dongle(fontSize: 20, color: Colors.grey, height: 1.0)),
                                secondary: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                                  child: Icon(Icons.volume_up_rounded, color: Colors.blue.shade400),
                                ),
                                value: _isSoundEnabled,
                                activeColor: AppColors.primary,
                                onChanged: _toggleSound,
                              ),
                              Divider(height: 1, color: Colors.grey.shade100),

                              // MODER REMINDER PICKER
                              ListTile(
                                onTap: _showModernTimePicker,
                                title: Text("Nhắc nhở học tập", style: GoogleFonts.dongle(fontSize: 26, height: 1.0)),
                                subtitle: Text("Hằng ngày vào lúc ${_formatTime(_reminderTime)}", style: GoogleFonts.dongle(fontSize: 20, color: AppColors.primary, height: 1.0)),
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: Colors.orange.shade50, shape: BoxShape.circle),
                                  child: Icon(Icons.alarm_rounded, color: Colors.orange.shade400),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                                  child: Text(_formatTime(_reminderTime), style: GoogleFonts.dongle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.0)),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // LOGOUT
                        GestureDetector(
                          onTap: () async {
                            await AuthService().logout();
                            if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.red.shade100, width: 1.5),
                                boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))]
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                                  child: const Icon(Icons.logout, color: Colors.red),
                                ),
                                const SizedBox(width: 16),
                                Text("Đăng xuất tài khoản", style: GoogleFonts.dongle(fontSize: 28, height: 1.0, fontWeight: FontWeight.bold, color: Colors.red.shade400)),
                                const Spacer(),
                                Icon(Icons.arrow_forward_ios, size: 18, color: Colors.red.shade200),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Thêm SizedBox để tránh bị nút Chatbot che
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, Color bgColor, Color textColor) {
    return Expanded(
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: textColor.withOpacity(0.2), width: 1.5),
            boxShadow: [BoxShadow(color: textColor.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: GoogleFonts.dongle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor, height: 1.0)),
            Text(title, style: GoogleFonts.dongle(fontSize: 22, color: textColor.withOpacity(0.8), height: 1.0)),
          ],
        ),
      ),
    );
  }
}