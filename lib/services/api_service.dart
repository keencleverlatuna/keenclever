import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  Future<bool> testConnection(String serverAddress) async {
    try {
      final url = Uri.parse(
        'http://$serverAddress/bank_api/test.php',
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
// sirr
//sirrr
