import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // LD Player / Real device: http://192.168.1.94/
  // Android Emulator (Google SDK): http://10.0.2.2/
  static const String baseUrl = 'http://192.168.1.40/hisuesl_backend/api/';

  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl$endpoint'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return {'success': true, 'data': data, 'isList': true};
        }
        return {'success': true, 'data': data, 'isList': false};
      } else {
        return {'success': false, 'error': 'HTTP ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
