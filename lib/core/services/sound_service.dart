import 'package:audioplayers/audioplayers.dart';

class SoundService {
  // Singleton pattern để dùng chung 1 instance
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();

  // Hàm phát nhạc chung
  Future<void> _playSound(String fileName) async {
    try {
      // Stop nhạc đang phát trước đó (nếu có) để tránh chồng chéo
      await _player.stop();
      // Phát file từ assets/sounds/
      await _player.play(AssetSource('sounds/$fileName'));
    } catch (e) {
      // In lỗi nếu không tìm thấy file hoặc lỗi thiết bị (không làm crash app)
      print("Lỗi phát âm thanh: $e");
    }
  }

  // --- CÁC HÀM GỌI NHANH ---

  // 1. Trả lời ĐÚNG
  Future<void> playCorrect() async => await _playSound('correct.mp3');

  // 2. Trả lời SAI
  Future<void> playWrong() async => await _playSound('wrong.mp3');

  // 3. Đạt STREAK (3, 5, 10 câu)
  Future<void> playStreak() async => await _playSound('streak.mp3');

  // 4. HOÀN THÀNH bài thi
  Future<void> playFinish() async => await _playSound('finish.mp3');
}