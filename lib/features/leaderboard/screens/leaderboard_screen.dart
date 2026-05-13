import 'dart:convert'; // Import quan trọng để dùng base64Decode
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hisuesl/core/constants/app_colors.dart';
import '../services/leaderboard_service.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LeaderboardService leaderboardService = LeaderboardService();
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Bảng Xếp Hạng", style: GoogleFonts.dongle(fontSize: 32, color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: leaderboardService.getLeaderboard(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Chưa có dữ liệu xếp hạng"));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;

              final String name = userData['name'] ?? 'Người dùng bí ẩn';
              final int totalPoints = userData['totalPoints'] ?? 0;

              // --- XỬ LÝ ẢNH ĐẠI DIỆN ---
              // Ưu tiên 1: Ảnh Base64 (Do người dùng upload)
              // Ưu tiên 2: Ảnh URL (Legacy)
              // Fallback: Ảnh mặc định
              final String? avatarBase64 = userData['avatarBase64'];
              final String? avatarUrl = userData['avatarUrl'];

              ImageProvider? avatarImage;

              if (avatarBase64 != null && avatarBase64.isNotEmpty) {
                try {
                  avatarImage = MemoryImage(base64Decode(avatarBase64));
                } catch (e) {
                  print("Lỗi decode ảnh leaderboard: $e");
                }
              }

              if (avatarImage == null) {
                if (avatarUrl != null && avatarUrl.isNotEmpty) {
                  avatarImage = NetworkImage(avatarUrl);
                } else {
                  // Fallback cuối cùng
                  avatarImage = NetworkImage('https://i.pravatar.cc/150?u=${users[index].id}');
                }
              }

              final bool isMe = currentUser != null && users[index].id == currentUser.uid;
              final String rankTitle = leaderboardService.getRankTitle(totalPoints);

              // Top 3 có màu đặc biệt
              Color rankColor = Colors.grey.shade100;
              Color textColor = Colors.black;
              IconData? rankIcon;

              if (index == 0) {
                rankColor = const Color(0xFFFFD700); // Vàng
                rankIcon = Icons.emoji_events;
              } else if (index == 1) {
                rankColor = const Color(0xFFC0C0C0); // Bạc
              } else if (index == 2) {
                rankColor = const Color(0xFFCD7F32); // Đồng
              }

              if (isMe) {
                rankColor = AppColors.primary.withOpacity(0.1);
                textColor = AppColors.primary;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: rankColor,
                  borderRadius: BorderRadius.circular(16),
                  border: isMe ? Border.all(color: AppColors.primary, width: 2) : null,
                ),
                child: Row(
                  children: [
                    // Số thứ tự
                    SizedBox(
                      width: 35,
                      child: Text(
                        "#${index + 1}",
                        style: GoogleFonts.dongle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
                      ),
                    ),

                    // Avatar
                    CircleAvatar(
                      backgroundImage: avatarImage,
                      backgroundColor: Colors.grey.shade300,
                      radius: 24,
                    ),
                    const SizedBox(width: 16),

                    // Tên và Danh hiệu
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(name, style: GoogleFonts.dongle(fontSize: 26, fontWeight: FontWeight.bold, color: textColor, height: 1.0)),
                          Text(rankTitle, style: GoogleFonts.dongle(fontSize: 18, color: Colors.grey[700], height: 1.0)),
                        ],
                      ),
                    ),

                    // Điểm số
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (rankIcon != null) Icon(rankIcon, color: Colors.orange, size: 20),
                        Text("$totalPoints pts", style: GoogleFonts.dongle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                      ],
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}