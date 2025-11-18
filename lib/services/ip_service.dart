import 'dart:convert';
import 'package:http/http.dart' as http;

class IpService {
  Future<String?> getPublicIp() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.ipify.org?format=json'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['ip'];
      }
    } catch (e) {
      print("Error getting IP: $e");
    }
    return null; // ดึงไม่ได้ให้เป็น null
  }
}
