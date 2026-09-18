import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/transaction.dart';

class TransactionApiService {
  final String serverAddress;

  TransactionApiService(this.serverAddress);

  String get baseUrl =>
      '$serverAddress/bank_api/transactions.php';

  Future<List<Transaction>> getTransactions() async {
    final response = await http
        .get(Uri.parse(baseUrl))
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load transactions. '
            'Server returned ${response.statusCode}.',
      );
    }

    final data = jsonDecode(response.body);

    if (data['success'] != true) {
      throw Exception(
        data['message']?.toString() ??
            'Failed to load transactions.',
      );
    }

    final List<dynamic> transactionData =
        data['data'] ?? [];

    return transactionData
        .map(
          (item) => Transaction.fromJson(
        item as Map<String, dynamic>,
      ),
    )
        .toList();
  }

  Future<void> deleteTransaction(int id) async {
    final response = await http
        .delete(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id': id,
      }),
    )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to delete transaction. '
            'Server returned ${response.statusCode}.',
      );
    }

    final data = jsonDecode(response.body);

    if (data['success'] != true) {
      throw Exception(
        data['message']?.toString() ??
            'Failed to delete transaction.',
      );
    }
  }
}