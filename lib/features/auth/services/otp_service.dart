import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class OtpService {
  // Hàm tạo mã OTP 6 số ngẫu nhiên
  static String generateOtp() {
    Random random = Random();
    String otp = '';
    for (int i = 0; i < 6; i++) {
      otp += random.nextInt(10).toString();
    }
    return otp;
  }

  // Hàm gửi Email chứa OTP
  static Future<bool> sendOtpEmail(String toEmail, String otp) async {
    String username = 'lecheche123456789@gmail.com';
    String password = 'ssgk zrsa hxxb asez';

    final smtpServer = gmail(username, password);

    // Nội dung Email
    final message = Message()
      ..from = Address(username, 'HisuESL App')
      ..recipients.add(toEmail)
      ..subject = 'Mã xác thực tài khoản HisuESL'
      ..html = '''
        <h3>Chào mừng bạn đến với HisuESL!</h3>
        <p>Mã xác thực OTP của bạn là: <strong style="font-size: 24px; color: #2196F3;">$otp</strong></p>
        <p>Mã này dùng để xác minh địa chỉ email của bạn hợp lệ. Vui lòng không chia sẻ mã này cho bất kỳ ai.</p>
      ''';

    try {
      await send(message, smtpServer);
      return true; // Gửi thành công
    } catch (e) {
      print('Lỗi gửi email: $e');
      return false; // Gửi thất bại
    }
  }
}