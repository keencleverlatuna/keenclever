import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/account.dart';

class AccountApiService {
  final String serverAddress;

  AccountApiService({
    required this.serverAddress,
  });

  String get baseUrl =>
      'http://$serverAddress/bank_api/accounts.php';

  Future<List<Account>> getAccounts() async {
    final response = await http
        .get(Uri.parse(baseUrl))
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception('Failed to load accounts.');
    }

    final data = jsonDecode(response.body);

    if (data['success'] != true) {
      throw Exception(
        data['message'] ?? 'Failed to load accounts.',
      );
    }

    final List<dynamic> accountsJson = data['data'] ?? [];

    return accountsJson
        .map((json) => Account.fromJson(json))
        .toList();
  }

  Future<void> createAccount({
    required String accountNumber,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required double balance,
  }) async {
    final response = await http
        .post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'account_number': accountNumber,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'balance': balance,
      }),
    )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception('Failed to create account.');
    }

    final data = jsonDecode(response.body);

    if (data['success'] != true) {
      throw Exception(
        data['message'] ?? 'Failed to create account.',
      );
    }
  }

  Future<void> updateAccount({
    required int id,
    required String accountNumber,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required double balance,
  }) async {
    final response = await http
        .put(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id': id,
        'account_number': accountNumber,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'balance': balance,
      }),
    )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception('Failed to update account.');
    }

    final data = jsonDecode(response.body);

    if (data['success'] != true) {
      throw Exception(
        data['message'] ?? 'Failed to update account.',
      );
    }
  }

  Future<void> deleteAccount(int id) async {
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
      throw Exception('Failed to delete account.');
    }

    final data = jsonDecode(response.body);

    if (data['success'] != true) {
      throw Exception(
        data['message'] ?? 'Failed to delete account.',
      );
    }
  }

  Future<double> withdraw({
    required int id,
    required double amount,
  }) async {
    final response = await http
        .post(
      Uri.parse('$baseUrl?action=withdraw'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id': id,
        'amount': amount,
      }),
    )
        .timeout(const Duration(seconds: 5));

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        data['message'] ?? 'Withdrawal failed.',
      );
    }

    if (data['success'] != true) {
      throw Exception(
        data['message'] ?? 'Withdrawal failed.',
      );
    }

    return double.parse(
      data['new_balance'].toString(),
    );
  }

  Future<double> deposit({
    required int id,
    required double amount,
  }) async {
    final response = await http
        .post(
      Uri.parse('$baseUrl?action=deposit'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id': id,
        'amount': amount,
      }),
    )
        .timeout(const Duration(seconds: 5));

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        data['message'] ?? 'Deposit failed.',
      );
    }

    if (data['success'] != true) {
      throw Exception(
        data['message'] ?? 'Deposit failed.',
      );
    }

    return double.parse(
      data['new_balance'].toString(),
    );
  }
}