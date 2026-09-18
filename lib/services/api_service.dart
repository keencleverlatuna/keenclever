import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  Future<bool> testConnection(String serverAddress) async {
    try {
      final baseUrl = serverAddress.trim().replaceFirst(
        RegExp(r'/$'),
        '',
      );

      final url = Uri.parse(
        '$baseUrl/bank_api/db_test.php',
      );

      final response = await http
          .get(url)
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        return false;
      }

      final data = jsonDecode(response.body);

      return data['success'] == true;
    } catch (e) {
      return false;
    }
  }
}